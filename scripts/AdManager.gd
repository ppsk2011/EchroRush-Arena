extends Node
## AdManager – AdMob integration architecture stub (Phase 4).
##
## This script defines the interface and data flow for mobile ads WITHOUT
## actually implementing them.  When you are ready to add ads:
##   1. Install the GodotAds plugin (or an equivalent) from the Asset Library.
##   2. Replace each TODO block below with real plugin calls.
##   3. Set ad_unit_ids to your actual AdMob unit IDs.
##
## Design decisions:
##   • All ad logic is isolated here; the rest of the codebase just calls
##     AdManager.show_interstitial() or AdManager.show_rewarded().
##   • Signals let callers react to ad completion without tight coupling.
##   • Interstitials are gated behind a run-count threshold so players aren't
##     shown an ad on every single death.


# ── Signals ───────────────────────────────────────────────────────────────────
signal rewarded_ad_completed   ## Player watched the rewarded ad in full.
signal interstitial_closed     ## Interstitial was dismissed.


# ── Configuration ─────────────────────────────────────────────────────────────
## Replace with real unit IDs from the AdMob dashboard.
const AD_UNIT_IDS: Dictionary = {
	"android_banner":       "ca-app-pub-XXXXX/XXXXX",
	"android_interstitial": "ca-app-pub-XXXXX/XXXXX",
	"android_rewarded":     "ca-app-pub-XXXXX/XXXXX",
	"ios_banner":           "ca-app-pub-XXXXX/XXXXX",
	"ios_interstitial":     "ca-app-pub-XXXXX/XXXXX",
	"ios_rewarded":         "ca-app-pub-XXXXX/XXXXX",
}

## Show an interstitial only every N runs to avoid ad fatigue.
const INTERSTITIAL_RUN_INTERVAL: int = 3

var _initialized: bool = false


func _ready() -> void:
	_initialize()


# ── Initialisation ────────────────────────────────────────────────────────────

func _initialize() -> void:
	# TODO: detect platform, load the AdMob plugin singleton, set test device IDs
	# Example (GodotAds plugin):
	#   if Engine.has_singleton("AdMob"):
	#       var admob = Engine.get_singleton("AdMob")
	#       admob.initialize()
	_initialized = false
	print("AdManager: stub initialised (no real ads)")


# ── Public API ────────────────────────────────────────────────────────────────

## Call this from GameManager after each run.
## Shows an interstitial every INTERSTITIAL_RUN_INTERVAL runs.
func maybe_show_interstitial(run_count: int) -> void:
	if run_count % INTERSTITIAL_RUN_INTERVAL != 0:
		return
	show_interstitial()


func show_interstitial() -> void:
	if not _initialized:
		interstitial_closed.emit()  # Stub: treat as immediately closed
		return
	# TODO: admob.show_interstitial_ad()
	print("AdManager: would show interstitial")


func show_rewarded() -> void:
	if not _initialized:
		rewarded_ad_completed.emit()  # Stub: treat as watched
		return
	# TODO: admob.show_rewarded_ad()
	print("AdManager: would show rewarded ad")


func show_banner() -> void:
	if not _initialized:
		return
	# TODO: admob.show_banner_ad()
	print("AdManager: would show banner")


func hide_banner() -> void:
	if not _initialized:
		return
	# TODO: admob.hide_banner_ad()
	print("AdManager: would hide banner")
