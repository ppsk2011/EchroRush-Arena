extends Node
## GameSettings – Global configuration singleton for EchoRush Arena.
## Autoloaded as "GameSettings" so every script can reference it directly.
## Design decision: constants live here so tuning a single file adjusts the
## whole game without hunting through individual scripts.


# ── Run configuration ──────────────────────────────────────────────────────
## Maximum number of ghost replays visible at one time.
const MAX_GHOSTS: int = 5

## Maximum seconds per run before time-out survival.
const RUN_DURATION: float = 30.0

## Base movement speed (pixels / second) at run 1.
const BASE_PLAYER_SPEED: float = 300.0

## Speed added each new run (creates escalating difficulty).
const SPEED_INCREMENT_PER_RUN: float = 10.0

## Hard cap on player speed regardless of run count.
const MAX_SPEED: float = 600.0


# ── Arena configuration ─────────────────────────────────────────────────────
## Radius of the circular play area (pixels).
const ARENA_RADIUS: float = 400.0

## Margin kept between player/orbs and the arena edge (pixels).
const ARENA_EDGE_MARGIN: float = 30.0


# ── Orb configuration ───────────────────────────────────────────────────────
## Number of collectible orbs spawned at the start of each run.
const ORB_COUNT: int = 5

## Score added per collected orb.
const ORB_SCORE_VALUE: int = 10

## Visual radius of an orb (pixels).
const ORB_RADIUS: float = 14.0


# ── Player / ghost visuals ──────────────────────────────────────────────────
## Radius of the player circle (pixels).
const PLAYER_RADIUS: float = 20.0

## Ghost opacity (0–1). Ghosts are translucent so the player stays readable.
const GHOST_ALPHA: float = 0.40


# ── Skin system (Phase 3) ───────────────────────────────────────────────────
## Available player colours.  Index matches SaveSystem.selected_skin.
const SKIN_COLORS: Array = [
	Color(1.00, 1.00, 1.00),  # 0 Classic
	Color(0.18, 0.80, 1.00),  # 1 Cyber
	Color(1.00, 0.50, 0.10),  # 2 Flame
	Color(0.20, 0.85, 0.30),  # 3 Nature
	Color(0.72, 0.30, 1.00),  # 4 Mystic
	Color(1.00, 0.20, 0.20),  # 5 Danger
]

const SKIN_NAMES: Array = [
	"Classic",
	"Cyber",
	"Flame",
	"Nature",
	"Mystic",
	"Danger",
]


# ── Daily challenge (Phase 3) ───────────────────────────────────────────────
## Seed derived from today's date; ensures every player sees the same orb
## layout in daily challenge mode.
var daily_seed: int = 0


func _ready() -> void:
	_generate_daily_seed()


func _generate_daily_seed() -> void:
	var date: Dictionary = Time.get_date_dict_from_system()
	daily_seed = date.year * 10000 + date.month * 100 + date.day
