extends Node
## SaveSystem – Persistent data storage singleton.
## Autoloaded as "SaveSystem".
## Uses ConfigFile (INI-style) stored in the user:// data directory so it
## survives app updates on both Android and iOS.
##
## Design decision: leaderboard submission is stubbed here so the backend
## can be swapped in later without touching game-logic scripts.


const SAVE_PATH: String = "user://echo_rush_save.cfg"


# ── Persisted fields ─────────────────────────────────────────────────────────
var high_score: int = 0
var selected_skin: int = 0
var total_runs: int = 0


func _ready() -> void:
	load_data()


# ── Core I/O ─────────────────────────────────────────────────────────────────

func save_data() -> void:
	var config := ConfigFile.new()
	config.set_value("progress", "high_score", high_score)
	config.set_value("progress", "selected_skin", selected_skin)
	config.set_value("progress", "total_runs", total_runs)
	var err: int = config.save(SAVE_PATH)
	if err != OK:
		push_error("SaveSystem: failed to write save file (error %d)" % err)


func load_data() -> void:
	var config := ConfigFile.new()
	if config.load(SAVE_PATH) != OK:
		return  # First launch – default values stay
	high_score    = config.get_value("progress", "high_score",    0)
	selected_skin = config.get_value("progress", "selected_skin", 0)
	total_runs    = config.get_value("progress", "total_runs",    0)


# ── Helpers ───────────────────────────────────────────────────────────────────

## Returns true when a new personal best is set and saves immediately.
func update_high_score(score: int) -> bool:
	if score > high_score:
		high_score = score
		save_data()
		return true
	return false


func increment_run_count() -> void:
	total_runs += 1
	save_data()


## Clamps index to valid skin range before persisting.
func set_skin(skin_index: int) -> void:
	selected_skin = clamp(skin_index, 0, GameSettings.SKIN_COLORS.size() - 1)
	save_data()


# ── Leaderboard stub (Phase 3) ────────────────────────────────────────────────
## Architecture prepared for a future online leaderboard.
## Replace the print() calls with real HTTP requests (HTTPRequest node) or a
## GDNative SDK (e.g. PlayFab, Firebase) when the backend is ready.

func submit_score_to_leaderboard(score: int, player_name: String) -> void:
	# TODO: POST to your leaderboard API
	print("Leaderboard stub – submitting score %d for '%s'" % [score, player_name])


## Returns an Array of {name, score} dictionaries.
func fetch_leaderboard() -> Array:
	# TODO: GET from your leaderboard API and return parsed results
	return []
