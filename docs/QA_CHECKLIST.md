# Endless Runner QA Checklist

Use this before each milestone tag/release. Mark each item as `PASS`, `FAIL`, or `N/A`.

## Build and Launch
- [ ] Game opens from Godot Play without script/parser errors.
- [ ] Intro -> Menu -> Run flow works every time.
- [ ] Restart after death returns to playable state cleanly.

## Movement
- [ ] Short tap gives short jump.
- [ ] Hold gives full jump.
- [ ] Double jump is available once per airtime.
- [ ] Speed up/down controls feel responsive and bounded.
- [ ] Player cannot get stuck on platform edges.

## Spawn Fairness
- [ ] Safe opening runway always appears.
- [ ] First hazards do not appear in first few seconds.
- [ ] Platform gaps are consistently reachable.
- [ ] Vertical lane spacing is readable and playable.

## Hazards and Pickups
- [ ] Hazard hitboxes match visuals.
- [ ] Coin pickup feels consistent.
- [ ] Health pickups spawn at intended rarity.
- [ ] Speed decrease pickups are not over-spawning.
- [ ] Multi-route sections appear at expected frequency.

## HUD and Readability
- [ ] HUD always shows score/health/status/mission.
- [ ] Platform type legend remains visible and stable.
- [ ] Mission/sector messages append cleanly without hiding core HUD info.
- [ ] Score, high score, and run summary are legible.

## Audio
- [ ] Menu music plays on menu only.
- [ ] Gameplay music loops during run.
- [ ] SFX (jump/coin/hit) are audible and balanced.
- [ ] No static/distortion clipping during normal play.

## Performance
- [ ] No visible hitch when transitioning from opening section.
- [ ] No major frame drops during heavy spawn moments.
- [ ] No growing slowdown over a 10+ minute run.

## Regression Checks
- [ ] Pause/resume works.
- [ ] Death flow and restart work repeatedly.
- [ ] Existing saves/high score handling still works.

## Test Session Notes
- Build/Commit tested:
- Tester:
- Date:
- Issues found:
