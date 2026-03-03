extends Area2D
## Orb – Collectible pickup (passive).
##
## The player detects overlap via its own collision mask; GameManager then
## calls queue_free() on the orb and awards score via ScoreSystem.
## The orb itself has no collision mask – it does not detect anything,
## keeping physics queries minimal.


func _ready() -> void:
	add_to_group("orb")


# ── Visuals ───────────────────────────────────────────────────────────────────

func _draw() -> void:
	# Outer glow ring
	draw_circle(Vector2.ZERO, GameSettings.ORB_RADIUS, Color(1.0, 0.85, 0.10, 0.35))
	# Solid core
	draw_circle(Vector2.ZERO, GameSettings.ORB_RADIUS * 0.65, Color(1.0, 0.90, 0.20))
