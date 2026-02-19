# Endless Runner Redux (Godot 4 Prototype)

This is a clean Godot 4 reboot of the original libGDX runner.

## Current scope
- Splash screen -> Menu -> Game flow
- Auto-runner movement
- Mario-style jump feel (coyote + buffer + hold)
- Procedural multi-lane platforms with stronger verticality
- Coins and hazards
- Score counter

## Run
1. Install Godot 4.x (recommended: latest stable 4.2+).
2. Open Godot.
3. Import project folder: `EndlessRunnerGodot`.
4. Run project.

## Files
- `project.godot`
- `scenes/Splash.tscn`
- `scenes/Menu.tscn`
- `scenes/Main.tscn`
- `scripts/splash.gd`
- `scripts/menu.gd`
- `scripts/main.gd`
- `scripts/player.gd`

## Next build targets
- Bring in real sci-fi/medieval art assets
- Add health + invincibility pickups
- Add combo-based coin multipliers
- Add difficulty ramp profiles (early/mid/late)
