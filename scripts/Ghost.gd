extends Area2D
## Ghost – Replays a previously recorded player run.
##
## Responsibilities:
##   • Receive a positions array and advance through it one element per
##     physics frame (frame-perfect replay of the original run).
##   • Flash briefly at frames where the original player collected an orb
##     (visual hint that the ghost "collected" something).
##   • Be invisible / disabled when not in use (managed by GhostPool).
##
## Design decision: ghosts are Area2D so the player can detect overlap, but
## ghosts never detect each other – they are purely passive replayers.


# ── State ─────────────────────────────────────────────────────────────────────

var _positions: Array         = []   ## Recorded world-space positions.
var _orb_frames: Array        = []   ## Physics-frame indices of orb collections.
var _frame: int               = 0    ## Current replay frame index.
var _is_replaying: bool       = false
var _ghost_color: Color       = Color.WHITE
var _flash_timer: float       = 0.0  ## Seconds remaining in orb-collect flash.

const FLASH_DURATION: float   = 0.25 ## How long the orb-collect flash lasts.
const GHOST_RADIUS: float     = GameSettings.PLAYER_RADIUS


# ── Lifecycle ─────────────────────────────────────────────────────────────────

func _ready() -> void:
	add_to_group("ghost")


## Initialise the ghost with replay data.  Called by GhostPool / GameManager.
## orb_frames contains the _frame indices at which the original player collected
## an orb, used to trigger a brief visual flash.
func setup(positions: Array, ghost_color: Color, orb_frames: Array = []) -> void:
	_positions  = positions.duplicate()
	_orb_frames = orb_frames.duplicate()
	_ghost_color = Color(ghost_color.r, ghost_color.g, ghost_color.b,
			GameSettings.GHOST_ALPHA)
	_frame      = 0
	_flash_timer = 0.0
	_is_replaying = false
	modulate    = Color.WHITE  # Reset any tint from previous use
	if not _positions.is_empty():
		global_position = _positions[0]


## Begins the frame-by-frame position replay.
func start_replay() -> void:
	if _positions.is_empty():
		return
	_frame        = 0
	_is_replaying = true
	global_position = _positions[0]
	queue_redraw()


# ── Per-frame logic ───────────────────────────────────────────────────────────

func _physics_process(delta: float) -> void:
	if not _is_replaying:
		return

	# Advance one frame in the recording
	if _frame < _positions.size():
		global_position = _positions[_frame]

		# Trigger flash when this frame had an orb collection
		if _frame in _orb_frames:
			_flash_timer = FLASH_DURATION

		_frame += 1
	else:
		_is_replaying = false  # Replay finished; ghost stays at last position

	# Tick the flash effect
	if _flash_timer > 0.0:
		_flash_timer -= delta
		queue_redraw()
	elif _flash_timer < 0.0:
		_flash_timer = 0.0
		queue_redraw()


# ── Pooling support ───────────────────────────────────────────────────────────

## Resets all state so this ghost instance can be reused by GhostPool.
func reset() -> void:
	_is_replaying = false
	_frame        = 0
	_positions.clear()
	_orb_frames.clear()
	_flash_timer  = 0.0
	queue_redraw()


# ── Visuals ───────────────────────────────────────────────────────────────────

func _draw() -> void:
	var draw_color: Color = _ghost_color

	# Bright flash when replaying an orb-collection moment
	if _flash_timer > 0.0:
		var t: float = _flash_timer / FLASH_DURATION
		draw_color = _ghost_color.lerp(Color.WHITE, t)

	draw_circle(Vector2.ZERO, GHOST_RADIUS, draw_color)
