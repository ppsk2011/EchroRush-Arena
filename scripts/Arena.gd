extends Node2D
## Arena – Visual representation of the circular play area.
##
## Draws the arena floor and border using _draw() – no textures needed,
## keeping the build lightweight.  Exports radius/colours so a designer can
## tweak them in the editor without touching code.


@export var radius: float         = GameSettings.ARENA_RADIUS
@export var floor_color: Color    = Color(0.07, 0.07, 0.14)   ## Dark navy floor
@export var border_color: Color   = Color(0.30, 0.75, 1.00)   ## Cyan border
@export var border_width: float   = 5.0
@export var border_segments: int  = 64  ## Higher = smoother circle


func _draw() -> void:
	# Fill
	draw_circle(Vector2.ZERO, radius, floor_color)
	# Border outline (polyline approximation of a circle)
	var pts := PackedVector2Array()
	for i in border_segments + 1:
		var angle: float = i * TAU / border_segments
		pts.append(Vector2(cos(angle), sin(angle)) * radius)
	draw_polyline(pts, border_color, border_width, true)
