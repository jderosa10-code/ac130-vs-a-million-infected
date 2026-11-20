# AC-130 vs a Million Infected — Game Design Doc

Version 0.1.0 (prototype) · last updated 2026-11-19 · solo dev: Jacob · built live in Roblox Studio through the Studio MCP

This file is the memory of the game. Read it before working on the game; update it (and CHANGELOG.md, VERSION) whenever the game changes.

## 1. Pitch

**You are the gunner on an AC-130. Survivors run for the bunker, a million infected chase them, and you keep them alive from the sky.**

- Title: **AC-130 vs a Million Infected** (menu shows "AC-130" big, "VS A MILLION INFECTED" under it).
- Thumbnail concept: thermal-camera view looking down, green-boxed survivors running, a red horde behind them, a 105mm blast in the middle. No title text on it, light VFX.
- References: mechanics from the iPhone game *Zombie Gunship*; structure and UI style from Roblox *Survive a Million Monkeys*. Copy mechanics only — no names or art from either.

## 2. Building blocks

| Block | What it is | Source |
|---|---|---|
| Fantasy | Gunship gunner looking down a thermal sight | Zombie Gunship |
| Core loop | Shoot infected → earn Cash → buy gun tiers mid-run → survive more waves → earn Gems → permanent upgrades in the hangar | Monkeys |
| Unique mechanic (the twist) | Friendlies are on the ground with the enemy: 3 strikes for hitting them, and each gun has a different blast size, so picking the right gun matters | Zombie Gunship, new on Roblox in this structure |
| Guns | 25mm (fast, small), 40mm (group clearer), 105mm (huge, slow). Keys 1/2/3, R reloads | — |
| Abilities | Repair bunker (C, $250), A-10 run you draw with two clicks (F, $600), Nuke (V, $2500) | — |
| Enemy types | Runner (wave 2+), Brute (3+), Bomber (4+, explodes), Spitter (6+, holds range), Armored (7+, immune to 25mm) | Monkeys' special monkeys |
| Bosses | Every 5 waves, big named infected with a title-card cutscene | Monkeys |
| Tension | Bunker HP 100, friendly-fire strikes, endless waves that ramp | — |
| Modes | Normal, Hardcore (unlocks at best wave 10) | Monkeys |
| Progression | In-run: Cash and gun tiers (4 tiers). Permanent: Gems and per-gun stat upgrades (5 levels) | Monkeys |
| Long-term | Best wave and total kills leaderboards. No collection/index yet | — |

## 3. Proven mechanics map

- Endless waves + START / AUTO-SKIP + boss every 5: Survive a Million Monkeys.
- In-run cash upgrades and persistent gems: Survive a Million Monkeys.
- Forced first-join tutorial with an unwinnable wave and a rescue: Survive a Million Monkeys.
- Create/Join lobby before a run: common Roblox co-op pattern.
- **Unproven on Roblox:** no avatar during play (you are a camera on a gunship), and friendly-fire strikes. Watch the tutorial funnel for both.

## 4. Depth and social

- Runs aren't solved: gun choice per group, when to spend Cash on tiers vs abilities, protecting friendlies near the horde.
- Co-op (agreed, **not built**): everyone is on the same gunship as extra gunners. Each has their own guns, ammo and cash; the bunker and waves are shared. Crew size 1–4 from the mission screen.
- Lobbies run on separate servers so friends join together: PLAY → Create or Join (UI exists, backend **not built** — needs a published place, TeleportService, MemoryStore).
- Clippable moments: nuke, A-10 strafing run you aimed yourself, boss intros.

## 5. First 5 minutes (the tutorial, "FIRST MISSION")

1. 0:00 — Cinematic intro (~23 s, letterboxed): inside the gunship cabin, the player's own avatar walks down the aisle, sits, the chair swivels to the console, the camera pushes into the screen.
2. Radio guy **GARMIN** (still portrait that cuts between poses) talks in typed-out lines with a typewriter font.
3. Wave 1: 3 friendlies from the west road, 6 infected from the east road. Teaches fire/move/zoom.
4. Wave 2: tight pack of 12 from the north. Teaches the 40mm and reload.
5. Forced upgrade: cash is topped up, player buys one gun tier.
6. Wave 3: pack of 13 with a Bomber from the south. Teaches the 105mm.
7. The turn: unkillable boss, then a 15 s horde from all sides while the bunker drains (it can't actually fall).
8. The save: two A-10 runs, then a nuke. Back to the hangar; PLAY is locked until the first permanent upgrade is bought.

Rules: teaching waves are staged (fixed counts, fixed roads, friendlies far from infected). Plain words only — "Spooky" and "Sortie" were removed because players won't know them. The plane's callsign is **Reaper 41**.

## 6. Progression and economy

- **Cash** (in-run): from kills. Spent on gun tiers (4) and abilities.
- **Gems** (permanent): earned per run. Spent in the hangar on per-gun stat upgrades (max level 5).
- Saved per player: Gems, BestWave, TotalKills, TutorialDone, each upgrade level (DataStore "GunshipProfile_v2").
- Not designed yet: time-to-endgame target, rebirth or index, second map (OUTPOST is shown locked), classes, daily rewards.
- Risk: only 3 guns × a few stats × 5 levels is shallow for D7+. Needs a longer ladder before launch.

## 7. Retention (not designed yet)

- D1: beat your best wave, unlock Hardcore at wave 10.
- D7 / D28: nothing yet. Candidates: daily rewards, weekly boss, classes, more maps, an infected index.

## 8. Monetization (not designed yet)

Nothing is built. Candidates to decide later: revive bunker, 2x Gems pass, starter pack, extra ability slot. Free players must be able to reach everything.

## 9. Analytics (not built)

Funnel to add: tutorial started → intro finished → first kill → switched to 40mm → bought tier → reached boss → tutorial done → first hangar upgrade → first real run → wave 5.

## 10. Tech notes

- Place: unsaved/unpublished Studio place at the time of v0.1.0. **All code lives in the place file**, not in this repo (no Rojo).
- No player characters: `CharacterAutoLoads = false`, streaming off. The client is a camera.
- Server publishes state as attributes on `ReplicatedStorage.Convoy` and on the Player; clients read them. Remotes: `Convoy.Remotes.Action` (client → server), `Convoy.Remotes.FX` (server → clients).
- Main scripts: `ServerScriptService.ConvoyServer.Mission` (waves, tutorial, profile), `Avatars` (builds each player's avatar rig for cutscenes), `StarterPlayerScripts.GunshipClient` (camera, thermal, cutscenes), `GunshipUI` (all screens), `HangarLife` (hangar crew and vehicles), `ConvoyAudio`; shared modules `Config`, `Upgrades`, `FXLib`, `SFX`.
- World: `workspace.DMZ` — city map, `Hangar` (hub), `Cabin` (gunship interior set for cutscenes), `Bunker`.
- Debug attributes on `ReplicatedStorage.Convoy`: `DebugBossEvery`, `DebugStartWave`, `SkipTutorial`.
- Not done: mobile and console controls, exploit validation pass, performance pass.

## Style rules (Jacob's)

- Models are built from Roblox parts with the stud / weld / inlet / universal surface textures (weld is the favourite for metal). The AC-130, A-10, hangar vehicles and cabin all follow this.
- Don't hand-build characters — use rigs Jacob adds or toolbox ones. GARMIN and the hangar crew come from his dummy.
- UI: text needs strokes, nothing small, buttons scale from the centre, hover and click sounds on every button, fade-to-black transitions.
- Never the default Roblox sparkle particle. Textures must not contain barcodes, QR patterns or URLs.
- Infected are tinted slightly red, friendlies slightly green.

## Status at v0.1.0

**Working:** full solo loop (hangar → mission setup → waves, bosses, abilities → results), tutorial, upgrades and saving, leaderboard card, cutscenes (deploy, boss, nuke, A-10, intro), part-built AC-130 / A-10 / vehicles, hangar with crew.

**Next up, in order:**
1. Co-op on one gunship + real Create/Join lobbies.
2. Wire the six SVG-made FX textures (fireball, smoke, flash, dirt, spark, shockwave) once uploaded.
3. Mobile controls.
4. Longer progression, retention and monetization design (sections 6–8).
5. Later: classes, daily rewards, second map, voice lines, rebuilding the mesh buildings from parts.
