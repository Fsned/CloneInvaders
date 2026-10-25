# CloneInvaders overhaul: plan & progress

Goal: turn CloneInvaders into a vertical arcade shooter with light bullet-hell. Enemies fire
readable bullet patterns (a moving "maze"), and you grow from a pea-shooter into a screen-filling spread.

Decisions made: classic upward auto-fire · pick 1 of 3 upgrades · desktop first, portrait (9:16, 1080x1920).

## How to play

| Action | Keys |
|---|---|
| Move | WASD / arrow keys, or hold the left mouse button to fly toward the cursor |
| Focus | hold Shift (slower, tighter shots, shows the hitbox) |
| Bomb | X or right-click (clears all enemy bullets) |
| Upgrade picker | click a card, or press 1 / 2 / 3 |
| Pause | Esc / P |

Shooting is automatic. Only the small glowing dot in the middle of the ship can be hit.
Being hit while you still have a bomb fires it automatically (auto-bomb, `Player.AUTO_BOMB`).

## Status

### Phase 0: Godot 4 port ✅ (commit b3bbf59)

### Phase 1: Core shooter feel ✅
- [x] Tiny hitbox (7 px), graze zone, invulnerability frames with blinking after a hit
- [x] Focus mode, hull as pips (start 3, max 8), bombs (start 2, max 5)
- [x] `BulletField`: all bullets and pickups as plain data (fast, easy to clear)
- [x] Pattern library (`Patterns.gd`): aimed, fan, ring, ring with gap, spiral, wall with gap, stop-and-snap
- [x] Vertical parallax starfield + drifting planets
- [x] Removed +1 score per second; score now comes from kills, chains, grazes, scrap

### Phase 2: Progression ✅
- [x] Spread / Lance weapons, levels 1 to 8 (`WeaponData.gd`)
- [x] Homing missiles (3 levels), fire rate, damage, hull, repair, thrusters, magnet, +bomb
- [x] Pick-1-of-3 upgrade screen (`UpgradePicker.gd`, cards in `Upgrades.gd`)
- [x] Triggered by the scrap meter (12, then +10 scrap each time) and after waves 2, 4, mid-boss, 6

### Phase 3: Enemies & Stage 1 ✅
- [x] 7 enemy types + 2 bosses, all in `EnemyTypes.gd`: Grunt, Weaver, Diver (kamikaze), Spinner,
      Carrier, Mine (explodes into a ring, damages nearby enemies), Asteroid (cover that blocks bullets),
      Carrier Prime (mid-boss), Skull Mothership (3-phase boss)
- [x] Stage 1: 7 waves, written as data in `Stages.gd`, played by `StageDirector.gd`
- [x] Loops after the boss: enemies get tougher (HP x1.5, fire rate x1.25, bullet speed x1.1) and worth more
- [x] Tutorial rebuilt as a gentle stage (keeps the original "Hello! / My very first game :D" intro)
- [x] Fairness rule: enemies don't shoot from deep in the player's half

### Phase 4: Score, feel, balance 🟡 partly done
- [x] Combo chains (up to x3), graze bonus, no-hit stage bonus, bullet-cancel points, highscore
- [x] Screen shake, hit flash, explosions, sparks, floating score text, wave/boss banners, boss health bar
- [x] Sound effects (`Sfx` autoload, uses the Kenney sounds already in `2. SFX/Audio`)
- [~] Balance: tuned with a test bot (see below). Real human playtesting still needed.
- [ ] Clean up dead code (see list below)

## Not done yet / next steps
1. **Playtest and tune by hand.** All numbers live in `EnemyTypes.gd`, `Stages.gd`, `WeaponData.gd`,
   `Upgrades.gd` and the constants at the top of `Player.gd` / `LevelTemplate.gd`.
   - The bot results swung: first too hard (died in wave 1-2), then too easy (4 loops in 520 s).
   - The last tune (boss HP 3600/12000, steeper loop scaling) has **not been verified yet**.
2. **Menus for the new 9:16 layout.**
   - The welcome, pause, settings and lose menus still use the old Godot 3 layouts.
   - Their `align`/`valign` label properties are Godot 3 names and are ignored in Godot 4, so text may not be centred.
   - A proper results screen (score, chain, grazes, no-hit) would replace the small "you died" box.
3. **Stage 2+.** Only Stage 1 exists, and it loops. New stages are just new functions in `Stages.gd`.
4. **Settings.** Add an auto-bomb on/off toggle and maybe screen shake on/off.
5. **Mobile.**
   - Hold-to-move should work with touch (mouse emulation), but it's untested.
   - The Android export needs a new Godot 4 build template (the `android/` folder is Godot 3).
6. **Re-export** the Windows/Linux builds in `9. Exports/` from Godot 4. The ones there are old Godot 3 builds.
7. **Remove dead code.** It's no longer used by the levels, but kept in case you want to look at it:
   - characters and spawners: `CharacterTemplate.*` (still the base scene of `Player.tscn`, so detach first),
     `Skullship.*`, `mobSpawner.*`, `Utility/objectSpawner.*`, `KinematicBody2D.gd`
   - old objects: `LaserBullet.*`, `Bomb.*`, `Freezer.tscn`, old physics `Asteroid.*`/`asteroidFragment.*`,
     `Pickup.*`, `healthPickup.tscn`, `shootingSpeed.tscn`, `scraps/*.tscn`, `scrap1.gd`
   - old GUI: `6. GUI/ActionBar.*`, `HealthBar.tscn`, `PowerBar.tscn`, `Bar.gd`
   - other: `Utility/Weapon.gd`, `Utility/PlayerProperties.gd`, `Utility/global.gd`, the Dialog system
     (`Utility/dialog.gd`, `4. Scenes/Dialog/*`), `3. Levels/LevelTutorial.gd`, `Utility/TrelloTool/*`
   - the old Godot 3 `.import/` folder on disk (already untracked)
8. **Music.** Still the single original track.

## Balance testing
`_devcheck/` (git-ignored) contains a bot that plays the game and logs hull, score, upgrades and hits per wave:

```
"C:\Program Files (x86)\Godot\Godot_v4.7.2-stable_win64_console.exe" --path . res://_devcheck/bot.tscn -- skill=0.5 seed=1 secs=400 speed=2.5 shots=1
```

`skill` (0 to 1) controls reaction time, how far ahead it looks, and how many bullets it overlooks.
`shots=1` saves screenshots every 15 s into `_devcheck/`.

## Where things are
| File | What |
|---|---|
| `3. Levels/LevelTemplate.gd` | session: score, combo, scrap meter, game over, loops |
| `5. Gameplay/StageDirector.gd` | plays waves, banners, boss bar, upgrade picks between waves |
| `5. Gameplay/Stages.gd` | stage scripts (data) |
| `5. Gameplay/Enemy.gd`, `EnemyTypes.gd` | enemy behaviour + stats, boss phases |
| `5. Gameplay/BulletField.gd`, `Patterns.gd` | bullets, pickups, collisions; pattern library |
| `5. Gameplay/WeaponData.gd`, `Upgrades.gd` | player shot patterns; upgrade cards |
| `5. Gameplay/Effects.gd` | explosions, sparks, floating text, screen shake |
| `4. Scenes/Characters/Player.gd` | player ship |
| `6. GUI/GUI.gd`, `UpgradePicker.gd` | HUD; upgrade screen |
| `3. Levels/Background.gd` | starfield |
| `Utility/Sfx.gd` | sound effects |
