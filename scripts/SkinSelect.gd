extends Control
## SkinSelect – Skin selection overlay (Phase 3).
##
## Instantiated at runtime by GameManager when the player taps "Skins" in the
## end-of-run panel.  Emits skin_selected and closes itself.


signal skin_selected(index: int)

@onready var _skin_grid: GridContainer = $Background/VBox/SkinGrid
@onready var _back_btn:  Button        = $Background/VBox/BackButton

var _skin_buttons: Array = []


func _ready() -> void:
	_back_btn.pressed.connect(_on_back_pressed)
	_build_skin_grid()


func _build_skin_grid() -> void:
	for i in GameSettings.SKIN_COLORS.size():
		var btn := Button.new()
		btn.custom_minimum_size = Vector2(140, 80)
		btn.text                = GameSettings.SKIN_NAMES[i]

		# Colour the button background to preview the skin
		var style := StyleBoxFlat.new()
		style.bg_color           = GameSettings.SKIN_COLORS[i]
		style.corner_radius_top_left     = 8
		style.corner_radius_top_right    = 8
		style.corner_radius_bottom_left  = 8
		style.corner_radius_bottom_right = 8
		btn.add_theme_stylebox_override("normal", style)

		# Mark the currently selected skin
		if i == SaveSystem.selected_skin:
			btn.disabled = true

		btn.pressed.connect(_on_skin_pressed.bind(i))
		_skin_grid.add_child(btn)
		_skin_buttons.append(btn)


func _on_skin_pressed(index: int) -> void:
	SaveSystem.set_skin(index)

	# Update button states
	for i in _skin_buttons.size():
		_skin_buttons[i].disabled = (i == index)

	skin_selected.emit(index)


func _on_back_pressed() -> void:
	queue_free()
