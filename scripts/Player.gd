extends Area2D
## Player – Touch-controlled avatar.
##
## Responsibilities:
##   • Translate touch/drag events into constant-speed directional movement.
##   • Enforce the circular arena boundary.
##   • Record every physics-frame position for later ghost replay.
##   • Detect overlap with ghosts (→ die) and orbs (→ collect).
##
## Design decision: Area2D instead of CharacterBody2D because we do not need
## the physics engine for wall/collision response – boundary clamping is handled
## manually, which is both simpler and cheaper on mobile.


# ── Signals ───────────────────────────────────────────────────────────────────

## Emitted when the player is hit by a ghost.
signal died

## Emitted when the player overlaps an orb.  The orb node is passed so the
## caller (GameManager) can remove it from the spawner's tracking list.
signal orb_collected(orb: Area2D)


# ── State ─────────────────────────────────────────────────────────────────────

## Current movement speed (pixels / second).  Set by GameManager each run.
var speed: float = GameSettings.BASE_PLAYER_SPEED

## True while the player can move and take damage.
var is_alive: bool = false

## Circular arena centre in world-space.  Updated on reset().
var arena_center: Vector2 = Vector2.ZERO

## Position history recorded every physics frame.  Handed to GhostPool on death.
var recorded_positions: Array = []

## World-space position the player is moving toward (set by touch/mouse events).
var _target: Vector2 = Vector2.ZERO

## Index of the active touch point (-1 when no touch is held).
var _active_touch_id: int = -1


# ── Lifecycle ─────────────────────────────────────────────────────────────────

func _ready() -> void:
	add_to_group("player")
	area_entered.connect(_on_area_entered)


## Called by GameManager before each run to configure speed, look, and position.
func setup(run_speed: float, skin_color: Color, center: Vector2) -> void:
	speed       = run_speed
	arena_center = center
	_target     = center
	global_position = center
	modulate    = skin_color


## Activates the player and clears the previous recording.
func start() -> void:
	is_alive = true
	recorded_positions.clear()
	_active_touch_id = -1
	_target = global_position


## Returns the position log for ghost-replay creation.
func get_recorded_positions() -> Array:
	return recorded_positions


# ── Per-frame logic ───────────────────────────────────────────────────────────

func _physics_process(delta: float) -> void:
	if not is_alive:
		return
	_move_toward_target(delta)
	_record_position()


func _input(event: InputEvent) -> void:
	if not is_alive:
		return

	if event is InputEventScreenTouch:
		if event.pressed:
			_active_touch_id = event.index
			_target = event.position
		elif event.index == _active_touch_id:
			_active_touch_id = -1

	elif event is InputEventScreenDrag:
		if event.index == _active_touch_id or _active_touch_id == -1:
			_active_touch_id = event.index
			_target = event.position

	# ── Desktop fallback (editor / PC testing) ────────────────────────────
	elif event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			_target = event.position
	elif event is InputEventMouseMotion:
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			_target = event.position


# ── Movement ──────────────────────────────────────────────────────────────────

func _move_toward_target(delta: float) -> void:
	var dir: Vector2 = _target - global_position
	if dir.length_squared() < 4.0:
		return  # Already close enough – no micro-jitter

	var new_pos: Vector2 = global_position + dir.normalized() * speed * delta

	# Keep player inside the circular arena
	var offset: Vector2 = new_pos - arena_center
	var max_r: float     = GameSettings.ARENA_RADIUS - GameSettings.ARENA_EDGE_MARGIN
	if offset.length_squared() > max_r * max_r:
		offset  = offset.normalized() * max_r
		new_pos = arena_center + offset

	global_position = new_pos


func _record_position() -> void:
	recorded_positions.append(global_position)


# ── Collision ─────────────────────────────────────────────────────────────────

func _on_area_entered(area: Area2D) -> void:
	if not is_alive:
		return
	if area.is_in_group("ghost"):
		die()
	elif area.is_in_group("orb"):
		orb_collected.emit(area)


func die() -> void:
	if not is_alive:
		return
	is_alive = false
	died.emit()


# ── Visuals ───────────────────────────────────────────────────────────────────

func _draw() -> void:
	# Player drawn as a filled circle; modulate (set via setup()) tints the colour.
	draw_circle(Vector2.ZERO, GameSettings.PLAYER_RADIUS, Color.WHITE)
