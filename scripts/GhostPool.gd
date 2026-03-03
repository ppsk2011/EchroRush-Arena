extends Node
## GhostPool – Object pool for Ghost instances (Phase 4 optimisation).
##
## Pre-allocates MAX_GHOSTS + 2 ghosts at startup so there are never any
## mid-run allocations.  Disabled/invisible ghosts are parked here; the
## GameManager fetches one per run and returns the oldest when the cap is hit.
##
## Design decision: pool size slightly exceeds MAX_GHOSTS so there is a spare
## while the "oldest" ghost's removal is processed.


@export var ghost_scene: PackedScene  ## Assign Ghost.tscn in the Inspector.
@export var pool_size: int = GameSettings.MAX_GHOSTS + 2

var _pool: Array = []


func _ready() -> void:
	_initialize_pool()


func _initialize_pool() -> void:
	for i in pool_size:
		_create_ghost()


func _create_ghost() -> void:
	var ghost: Area2D = ghost_scene.instantiate()
	ghost.visible      = false
	ghost.process_mode = Node.PROCESS_MODE_DISABLED
	add_child(ghost)
	_pool.append(ghost)


# ── Public API ────────────────────────────────────────────────────────────────

## Retrieve an available ghost from the pool.
## If the pool is exhausted (should not happen under normal MAX_GHOSTS use),
## a new ghost is created and added – avoids a hard crash at the cost of a
## one-off allocation.
func get_ghost() -> Area2D:
	for ghost in _pool:
		if not ghost.visible:
			ghost.visible      = true
			ghost.process_mode = Node.PROCESS_MODE_INHERIT
			return ghost

	push_warning("GhostPool: pool exhausted – expanding by one")
	var ghost: Area2D = ghost_scene.instantiate()
	add_child(ghost)
	_pool.append(ghost)
	return ghost


## Return a ghost to the pool so it can be reused.
func return_ghost(ghost: Area2D) -> void:
	ghost.reset()
	ghost.visible      = false
	ghost.process_mode = Node.PROCESS_MODE_DISABLED
