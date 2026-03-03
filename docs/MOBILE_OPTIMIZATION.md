# Mobile Optimisation Guide – EchoRush Arena

## Rendering

| Setting | Value | Reason |
|---------|-------|--------|
| Renderer | GL Compatibility | Broadest Android/iOS device support |
| Viewport | 1080 × 1920, stretch canvas_items | One canonical size scales to all screens |
| Physics ticks | 60 Hz | Matches target frame rate; no interpolation overhead |
| MSAA | Off | Use FXAA instead if aliasing is visible |
| Shadow quality | Disabled | 2D game – no shadows needed |

## Memory

* **Object pooling** – `GhostPool` pre-allocates `MAX_GHOSTS + 2` ghost nodes at
  scene load so there are zero in-run allocations for the ghost lifecycle.
* **Recorded positions array** – each element is a `Vector2` (8 bytes).  At 60 FPS
  over 30 s, one run produces ~14 KB.  With 5 ghosts that is ~70 KB – negligible.
* **Orbs** – `OrbSpawner` allocates only `ORB_COUNT` orbs and frees them on reset.
  No pooling needed for such a small count.
* Avoid calling `queue_free` + `instantiate` for ghosts; use `GhostPool` instead.

## Frame timing

* All gameplay logic lives in `_physics_process` (fixed 60 Hz) so replay is
  frame-perfect regardless of rendering frame rate fluctuations.
* Visual-only updates (`_draw`, label text) are triggered by signals or `queue_redraw()`
  only when data changes, not every render frame.
* The `timer_updated` signal is emitted every physics tick only while a run is
  active, keeping idle CPU usage near zero on the end-of-run screen.

## Touch input

* A single touch index is tracked (`_active_touch_id`).  If a second finger lands
  (e.g. accidental palm touch) it is ignored, preventing erratic movement.
* Mouse fallback is included for editor / desktop testing; it compiles to nothing
  on export if input maps are not present.

## Build size

* No external plugins, fonts, or texture atlases are included in the MVP.
* `_draw()` calls replace sprite sheets – zero texture memory for circles.
* Target < 60 MB APK.  With no audio assets the build should be well under 10 MB.

## Android export checklist

1. Set **Minimum SDK** to 24 (Android 7.0) for broad coverage.
2. Set **Target SDK** to 34 (latest recommended).
3. Enable **arm64-v8a** and **armeabi-v7a** architectures.
4. Sign the release build with a dedicated keystore (never commit keystore files).
5. Enable **Immersive Mode** (`screen/immersive_mode=true` in export preset).
6. Set `package/unique_name` to your reverse-domain identifier.

## iOS export checklist

1. Xcode 15+ required for Godot 4 iOS export.
2. Set deployment target to iOS 16.0 minimum.
3. Provide all required icon sizes in the export preset.
4. Enable **Portrait** orientation only in Xcode project settings.

## AdMob integration (when ready)

1. Install [Godot AdMob plugin](https://github.com/poingstudios/godot-admob-android)
   for Android and the equivalent iOS plugin.
2. In `AdManager.gd`, replace the `# TODO` stubs with real plugin calls.
3. Use **test ad unit IDs** during development; never ship test IDs.
4. Gate interstitials behind `INTERSTITIAL_RUN_INTERVAL` (default every 3 runs)
   to comply with AdMob frequency policies.
5. Rewarded ads can be offered as a "continue" mechanic in a future update.

## Profiling tips

* Use the Godot **Debugger → Monitors** tab to watch:
  * `Physics 2D → Step time` (should stay < 5 ms at 60 FPS)
  * `Memory → Static` (should stay flat after scene load)
  * `Draw calls` (should stay under 20 for this game)
* On Android, use **Android GPU Inspector** or **Snapdragon Profiler** for GPU
  bottlenecks.
* On iOS, use **Xcode Instruments → Game Performance** template.
