extends Node
## OrbSpawner – Manages collectible orb placement for each run.
##
## Spawns GameSettings.ORB_COUNT orbs at random positions inside the arena.
## Accepts an optional seed so daily-challenge mode reproduces the exact same
## layout every day (deterministic RNG).


@export var orb_scene: PackedScene         ## Assign Orb.tscn in the Inspector.
@export var arena_center: Vector2 = Vector2.ZERO
@export var arena_radius: float   = GameSettings.ARENA_RADIUS

var _active_orbs: Array = []


# ── Public API ────────────────────────────────────────────────────────────────

## Spawn fresh orbs.  Pass seed_override >= 0 for daily-challenge mode.
func spawn_orbs(seed_override: int = -1) -> void:
	clear_orbs()

	var rng := RandomNumberGenerator.new()
	if seed_override >= 0:
		rng.seed = seed_override       # Reproducible layout
	else:
		rng.randomize()                # Normal random run

	for i in GameSettings.ORB_COUNT:
		var orb: Area2D = orb_scene.instantiate()
		get_parent().add_child(orb)    # Add to the main scene tree

		# Random point inside a circle (uniform distribution)
		var angle: float = rng.randf_range(0.0, TAU)
		var dist: float  = rng.randf_range(
				GameSettings.ORB_RADIUS * 3.0,
				arena_radius - GameSettings.ARENA_EDGE_MARGIN - GameSettings.ORB_RADIUS)
		orb.global_position = arena_center + Vector2(cos(angle), sin(angle)) * dist

		_active_orbs.append(orb)


## Remove a specific orb from tracking (called by GameManager on collection).
func remove_orb(orb: Area2D) -> void:
	_active_orbs.erase(orb)


## Remove all orbs immediately (called on run reset).
func clear_orbs() -> void:
	for orb in _active_orbs:
		if is_instance_valid(orb):
			orb.queue_free()
	_active_orbs.clear()
