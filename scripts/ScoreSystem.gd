extends Node
## ScoreSystem – Tracks score and orb-collection timing for the current run.
##
## The physics-frame counter is used so Ghost.gd can flash at the exact frames
## the original player collected orbs (frame-accurate replay of pickups).


signal score_changed(new_score: int)

var _score: int        = 0
var _orb_frames: Array = []   ## Physics-frame indices of each orb collection.
var _frame: int        = 0    ## Increments every physics tick while active.
var _active: bool      = false


func _physics_process(_delta: float) -> void:
	if _active:
		_frame += 1


# ── Public API ────────────────────────────────────────────────────────────────

func reset() -> void:
	_score      = 0
	_orb_frames = []
	_frame      = 0
	_active     = true
	score_changed.emit(0)


func stop() -> void:
	_active = false


func add_orb_score() -> void:
	_score += GameSettings.ORB_SCORE_VALUE
	_orb_frames.append(_frame)
	score_changed.emit(_score)


func get_score() -> int:
	return _score


## Returns the frame-index list used by Ghost to replay pickup flashes.
func get_orb_collection_frames() -> Array:
	return _orb_frames
