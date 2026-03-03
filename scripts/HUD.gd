extends CanvasLayer
## HUD – In-game UI overlay (Phase 2).
##
## Displays score, run count, high score, and a timer bar.
## Shows an end-of-run panel with result and restart / skin buttons.
## All positioning uses anchor presets so it scales cleanly on any resolution.


signal restart_pressed
signal skins_pressed

# ── Node references ───────────────────────────────────────────────────────────
@onready var _score_label:      Label       = $ScoreLabel
@onready var _run_label:        Label       = $TopBar/RunLabel
@onready var _high_score_label: Label       = $TopBar/HighScoreLabel
@onready var _timer_bar:        ProgressBar = $TimerBar
@onready var _end_panel:        Panel       = $EndPanel
@onready var _end_message:      Label       = $EndPanel/VBox/MessageLabel
@onready var _end_score:        Label       = $EndPanel/VBox/ScoreLabel
@onready var _restart_btn:      Button      = $EndPanel/VBox/RestartButton
@onready var _skins_btn:        Button      = $EndPanel/VBox/SkinsButton


func _ready() -> void:
	_restart_btn.pressed.connect(func() -> void: restart_pressed.emit())
	_skins_btn.pressed.connect(func() -> void: skins_pressed.emit())
	_end_panel.visible = false
	update_high_score(SaveSystem.high_score)


# ── Update helpers (called by GameManager) ────────────────────────────────────

func update_score(score: int) -> void:
	_score_label.text = "Score: %d" % score


func update_run_count(run: int) -> void:
	_run_label.text = "Run #%d" % run


func update_high_score(score: int) -> void:
	_high_score_label.text = "Best: %d" % score


## ratio is 0.0–1.0 (time remaining / total run time).
func update_timer(ratio: float) -> void:
	_timer_bar.value = ratio * 100.0


# ── End-of-run panel ─────────────────────────────────────────────────────────

func show_run_end(score: int, survived: bool) -> void:
	_end_score.text   = "Score: %d" % score
	_end_message.text = "You survived!" if survived else "Caught by a ghost!"
	update_high_score(SaveSystem.high_score)
	_end_panel.visible = true


func hide_run_end() -> void:
	_end_panel.visible = false
