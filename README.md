# EchoRush Arena

A fast-paced 2D mobile ghost-avoidance game built with **Godot 4.x / GDScript**.

## Concept

Move inside a circular arena.  Every run records your exact path.  When you die
(or survive the 30-second timer), your path becomes a ghost that replays in the
next run.  Avoid all ghosts while collecting score orbs.  Up to **5 ghosts** are
active at once; the oldest is replaced when the limit is reached.

## Phases implemented

| Phase | Feature |
|-------|---------|
| 1 – Core MVP | Touch movement · Ghost recording & replay · Collision · GameManager · <1 s restart |
| 2 – Gameplay Depth | Collectible orbs · Score counter · Ghost orb-flash replay · HUD overlay · Speed ramp |
| 3 – Retention | Colour skin system · Persistent high score · Daily challenge seed · Leaderboard stub · Save system |
| 4 – Production | GhostPool object pooling · Memory management · Frame-perfect physics · Android/iOS export · AdMob architecture stub |

## Project structure

```
scenes/         .tscn scene files (Main, Player, Ghost, Orb, HUD, SkinSelect)
scripts/        GDScript source
  autoloads/    GameSettings.gd · SaveSystem.gd  (project autoloads)
docs/           MOBILE_OPTIMIZATION.md
export_presets.cfg  Android + iOS export configuration
project.godot   Godot 4 project configuration
```

## Download & play on Android

Every push to `main` automatically builds a debug APK via GitHub Actions.

1. Go to the **Actions** tab in this repository.
2. Click the latest **"Build Mobile (Android APK / iOS)"** workflow run.
3. Scroll to **Artifacts** at the bottom of the page.
4. Download **EchoRushArena-Android-APK** and unzip it.
5. Transfer `EchoRushArena.apk` to your Android device (or open it directly
   if you're browsing from your phone).
6. On the device, enable **Install from unknown sources** in Settings →
   Security, then tap the APK to install.

> **iOS** – the same workflow exports an Xcode project artifact
> (`EchoRushArena-iOS-Xcode-Project`).  Open it in Xcode 15+, select your
> development team, and run on a connected device or archive for TestFlight /
> Ad Hoc distribution.  A paid Apple Developer account is required for
> on-device installation.

## Quick start (editor)

1. Open the project folder in **Godot 4.2+**.
2. Press **F5** (or the Play button) to run in the editor.
3. Click and drag the mouse to move the player (touch on device).

## Requirements

* Godot 4.2 or newer
* GL Compatibility renderer (selected automatically)
* Android SDK / Xcode for mobile export (see `docs/MOBILE_OPTIMIZATION.md`)
