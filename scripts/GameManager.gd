extends Node2D
## GameManager – Central game-loop controller (all phases).
##
## Lifecycle for each run:
##   1. start_run()  → reset player + orbs, replay existing ghosts, start timer
##   2. Player moves, collects orbs, ScoreSystem accumulates score
##   3. Run ends when:
##        a. Timer expires   (player survived)
##        b. Player overlaps a ghost (player died)
##   4. _end_run() saves recording, creates a new ghost, updates persistent data
##   5. HUD shows end panel → player taps Restart → start_run() again
##
## Ghosts are managed by GhostPool (object pool, Phase 4).
## The oldest ghost is returned to the pool when MAX_GHOSTS is exceeded.


# ── Signals ───────────────────────────────────────────────────────────────────
signal run_started(run_number: int)
signal run_ended(score: int, survived: bool)
signal timer_updated(ratio: float)  ## Emitted each physics frame while running.


# ── Exported references (set in Main.tscn) ───────────────────────────────────
## Scene used to create the skin-selection overlay.
@export var skin_select_scene: PackedScene

## Whether the current run uses daily-challenge orb seeding.
@export var daily_challenge_mode: bool = false


# ── Node references ───────────────────────────────────────────────────────────
@onready var _arena:        Node2D      = $Arena
@onready var _player:       Area2D      = $Player
@onready var _ghost_pool:   Node        = $GhostPool
@onready var _orb_spawner:  Node        = $OrbSpawner
@onready var _score_system: Node        = $ScoreSystem
@onready var _run_timer:    Timer       = $RunTimer
@onready var _hud:          CanvasLayer = $HUD
@onready var _ad_manager:   Node        = $AdManager


# ── Runtime state ─────────────────────────────────────────────────────────────
var _current_run: int  = 0
var _is_running:  bool = false
var _active_ghosts: Array = []  ## Ordered list of currently visible ghosts.


# ── Lifecycle ─────────────────────────────────────────────────────────────────

func _ready() -> void:
	_configure_timer()
	_configure_orb_spawner()
	_connect_signals()
	# Short delay so the HUD can finish its _ready() before we touch it
	call_deferred("start_run")


func _configure_timer() -> void:
	_run_timer.wait_time = GameSettings.RUN_DURATION
	_run_timer.one_shot  = true
	_run_timer.timeout.connect(_on_run_timer_timeout)


func _configure_orb_spawner() -> void:
	_orb_spawner.arena_center = _arena.global_position
	_orb_spawner.arena_radius = GameSettings.ARENA_RADIUS


func _connect_signals() -> void:
	_player.died.connect(_on_player_died)
	_player.orb_collected.connect(_on_orb_collected)
	_score_system.score_changed.connect(_hud.update_score)
	_hud.restart_pressed.connect(_on_restart_pressed)
	_hud.skins_pressed.connect(_on_skins_pressed)


# ── Per-frame ─────────────────────────────────────────────────────────────────

func _physics_process(_delta: float) -> void:
	if _is_running:
		# Drive the timer-bar in the HUD
		timer_updated.emit(_run_timer.time_left / GameSettings.RUN_DURATION)
		_hud.update_timer(_run_timer.time_left / GameSettings.RUN_DURATION)


# ── Run control ───────────────────────────────────────────────────────────────

func start_run() -> void:
	if _is_running:
		return

	_current_run += 1
	_is_running   = true

	# Prepare subsystems
	_score_system.reset()
	_orb_spawner.spawn_orbs(
		GameSettings.daily_seed if daily_challenge_mode else -1
	)

	# (Re-)start all active ghost replays
	for ghost in _active_ghosts:
		ghost.start_replay()

	# Configure and activate the player
	var skin_color: Color = GameSettings.SKIN_COLORS[SaveSystem.selected_skin]
	_player.setup(_get_run_speed(), skin_color, _arena.global_position)
	_player.start()

	_run_timer.start()
	_hud.hide_run_end()
	_hud.update_run_count(_current_run)

	run_started.emit(_current_run)


func _end_run(survived: bool) -> void:
	if not _is_running:
		return

	_is_running = false
	_run_timer.stop()
	_score_system.stop()
	_player.is_alive = false

	var final_score: int = _score_system.get_score()

	# Persist stats
	SaveSystem.update_high_score(final_score)
	SaveSystem.increment_run_count()

	# Build and store ghost data for this run
	var run_data: Dictionary = {
		"positions":  _player.get_recorded_positions(),
		"orb_frames": _score_system.get_orb_collection_frames(),
		"score":      final_score,
	}
	if run_data.positions.size() > 0:
		_add_ghost(run_data)

	_hud.show_run_end(final_score, survived)
	run_ended.emit(final_score, survived)

	# Optional: show interstitial ad every N runs (stubbed)
	_ad_manager.maybe_show_interstitial(_current_run)


func _on_player_died() -> void:
	_end_run(false)


func _on_run_timer_timeout() -> void:
	_end_run(true)


func _on_orb_collected(orb: Area2D) -> void:
	_score_system.add_orb_score()
	_orb_spawner.remove_orb(orb)
	if is_instance_valid(orb):
		orb.queue_free()


# ── Ghost management ──────────────────────────────────────────────────────────

func _add_ghost(run_data: Dictionary) -> void:
	# Return the oldest ghost to the pool if we are at the limit
	if _active_ghosts.size() >= GameSettings.MAX_GHOSTS:
		var oldest: Area2D = _active_ghosts.pop_front()
		_ghost_pool.return_ghost(oldest)

	var ghost: Area2D = _ghost_pool.get_ghost()
	var skin_color: Color = GameSettings.SKIN_COLORS[SaveSystem.selected_skin]
	ghost.setup(run_data.positions, skin_color, run_data.orb_frames)
	_active_ghosts.append(ghost)


# ── Speed scaling ─────────────────────────────────────────────────────────────

func _get_run_speed() -> float:
	return minf(
		GameSettings.BASE_PLAYER_SPEED + (_current_run - 1) * GameSettings.SPEED_INCREMENT_PER_RUN,
		GameSettings.MAX_SPEED
	)


# ── UI callbacks ──────────────────────────────────────────────────────────────

func _on_restart_pressed() -> void:
	# Clear orbs, wait one frame for any queued frees, then restart
	_orb_spawner.clear_orbs()
	await get_tree().process_frame
	start_run()


func _on_skins_pressed() -> void:
	if skin_select_scene == null:
		push_warning("GameManager: skin_select_scene not assigned")
		return
	var overlay: Control = skin_select_scene.instantiate()
	add_child(overlay)
	overlay.skin_selected.connect(_on_skin_selected)


func _on_skin_selected(_index: int) -> void:
	# Colour will be applied on the next start_run(); nothing to do now.
	pass
