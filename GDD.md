# AC-130 vs a Million Infected — Game Design Doc

Version 0.3.0 (prototype) · last updated 2026-11-19 · solo dev: Jacob · built live in Roblox Studio through the Studio MCP

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
| Abilities | Repair bunker (C, $250), A-10 run you draw with two clicks (F, $600), Nuke (V, $2500) | A-10 has its own Armory upgrades: run length, firepower, call cost |
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
- Co-op (built in 0.4.0): everyone is on the same gunship as extra gunners. Each has their own guns, ammo, cash and in-run tiers; the bunker, waves and abilities' effects are shared. Crew of 1–4. Everyone gets the run's gems; kills count per gunner.
- Crews (parties): PLAY → CREATE makes a crew with a 5-letter code; JOIN lists open public crews (and friends-only crews of friends) or takes a code. The host picks mode and PUBLIC/FRIENDS and presses DEPLOY.
- Clippable moments: nuke, A-10 strafing run you aimed yourself, boss intros.

## 5. First 5 minutes (the tutorial, "FIRST MISSION")

Paced slowly on purpose: one new thing per wave, with a pause between waves.

1. Cinematic intro (~23 s, letterboxed): inside the gunship cabin, the player's own avatar walks down the aisle, sits, the chair swivels to the console, the camera pushes into the screen.
2. Radio guy **GARMIN** (still portrait that cuts between poses) talks in typed-out lines with a typewriter font.
3. Wave 1: 3 friendlies from the west road, 6 infected from the east road. Only the 25mm is unlocked. Teaches fire/move/zoom.
4. Wave 2: 9 infected from the south, still 25mm only.
5. Wave 3: the 40mm unlocks; tight pack of 12 from the north.
6. Forced upgrade: cash is topped up, the upgrade button appears, player buys one gun tier.
7. Wave 4: pack of 10 with a Brute from the east, to try the upgrade on.
8. Wave 5: the 105mm unlocks; pack of 13 with a Bomber from the south.
9. The turn: a boss that takes visible damage but cannot drop below 30% health, then a 16 s horde from all sides while the bunker drains (it can't actually fall).
10. The save: two A-10 runs, then the Nuke button appears with cash to pay for it and the player fires it themselves (auto-fires after 35 s).
11. Ending cutscene "EXTRACTION": a Little Bird lands on the helipad by the bunker, three survivors run out and ride the benches, it flies off.
12. Back to the hangar; PLAY is locked until the first permanent upgrade is bought.

Rules:
- Teaching waves are staged (fixed counts, fixed roads, friendlies far from infected).
- Guns not taught yet are greyed out and say LOCKED; the upgrade button and abilities are hidden until they are handed over. The server enforces the locks (`TutUnlock` attribute).
- A bouncing arrow (Jacob's image, asset 78822479272148) points at the button to click next (`TutArrow` attribute) instead of hint text. The only text hint left is the controls line on wave 1.
- Plain words only — "Spooky" and "Sortie" were removed because players won't know them. The plane's callsign is **Reaper 41**.

## 6. Progression and economy

- **Cash** (in-run): from kills. Spent on gun tiers (4) and abilities.
- **Gems** (permanent): earned per run. Spent in the hangar on per-gun stat upgrades (max level 5).
- Saved per player: Gems, BestWave, TotalKills, TutorialDone, each upgrade level (DataStore "GunshipProfile_v2").
- Ranks (from Zombie Gunship): 3 objectives at a time; finish all 3 to be promoted (RECRUIT to GENERAL, 19 ranks). Each rank is +10% cash and gems for good, a promotion pays gems, and an objective can be skipped for gems. Rules and text in `Convoy.Ranks`, state in `ConvoyServer.Ranks`.
- Not designed yet: time-to-endgame target, rebirth or index, second map (OUTPOST is shown locked), daily rewards.
- Risk: only 3 guns × a few stats × 5 levels is shallow for D7+. Needs a longer ladder before launch.

## 7. Retention (not designed yet)

- D1: beat your best wave, unlock Hardcore at wave 10.
- D7 / D28: ranks (objectives always give a next goal). Candidates: daily rewards, weekly boss, more maps, an infected index.

## 8. Monetization (v0.7.0)

- Battle offers (dev products, popups in a run): Emergency Repair R$25 (bunker under 35%), Instant Nuke R$39 (boss arrives), Cash Drop R$19 (every third break, 1000 + 200 x wave cash), Second Chance R$49 (bunker falls: 10 s freeze, once per run, anyone in the crew). Max one small popup per 50 s; never in the tutorial. Toast to the crew on every purchase.
- Gem packs: 500 / 1,500 / 5,000 for R$49 / 129 / 399.
- Passes: 2x Gems R$199, 2x Cash R$149.
- Late purchases (run already over) refund 150 gems. Free players can still reach everything.
- IDs and text live in `Convoy.Shop`; prices are changed in Creator Hub.

## 9. Analytics (not built)

Funnel to add: tutorial started → intro finished → first kill → switched to 40mm → bought tier → reached boss → tutorial done → first hangar upgrade → first real run → wave 5.

## 10. Tech notes

- Place: saved to Roblox (universe 10777953252, place 108596658459731). **All code lives in the place file**, not in this repo (no Rojo). Saving does not work in Studio playtests until "Enable Studio Access to API Services" is turned on.
- Servers (built in 0.4.0, `ConvoyServer.Lobbies`): one place for everything. `ServerRole` attribute = Studio / Lobby / Mission. Public servers are the hangar lobby (max server size 12); DEPLOY reserves a server of the same place and teleports the crew there (TeleportData kind/mode/crew). New players are sent to their own reserved tutorial server. Crews are listed across servers in MemoryStore sorted map `Parties` (key = code, 120 s expiry). Joining a crew on another hangar server teleports you to that server. Players are saved right before every teleport. In Studio everything runs on the one server (teleports can't be tested in Studio). Split maps into their own places only if maps get heavy.
- No player characters: `CharacterAutoLoads = false`, streaming off. The client is a camera.
- Server publishes state as attributes on `ReplicatedStorage.Convoy` and on the Player; clients read them. Remotes: `Convoy.Remotes.Action` (client → server), `Convoy.Remotes.FX` (server → clients).
- Main scripts: `ServerScriptService.ConvoyServer.Mission` (waves, tutorial, profile), `Avatars` (builds each player's avatar rig for cutscenes), `StarterPlayerScripts.GunshipClient` (camera, thermal, cutscenes), `GunshipUI` (all screens), `HangarLife` (hangar crew and vehicles), `ConvoyAudio`; shared modules `Config`, `Upgrades`, `FXLib`, `SFX`.
- World: `workspace.DMZ` — city map, `Hangar` (hub), `Cabin` (gunship interior set for cutscenes), `Bunker`.
- Debug attributes on `ReplicatedStorage.Convoy`: `DebugBossEvery`, `DebugStartWave`, `SkipTutorial`, `ForceTutorial` (ON while testing — turn off before launch).
- Not done: mobile and console controls, exploit validation pass, performance pass.

## Style rules (Jacob's)

- Models are built from Roblox parts with the stud / weld / inlet / universal surface textures (weld is the favourite for metal). The AC-130, A-10, hangar vehicles and cabin all follow this.
- Don't hand-build characters — use rigs Jacob adds or toolbox ones. GARMIN and the hangar crew come from his dummy.
- UI: text needs strokes, nothing small, buttons scale from the centre, hover and click sounds on every button, fade-to-black transitions.
- Never the default Roblox sparkle particle. Textures must not contain barcodes, QR patterns or URLs.
- Infected are tinted slightly red, friendlies slightly green.

## Status at v0.5.0

**Working:** full solo loop (hangar → mission setup → waves, bosses, abilities → results), tutorial, upgrades and saving, leaderboard card, cutscenes (deploy, boss, nuke, A-10, intro), part-built AC-130 / A-10 / Little Bird / vehicles, hangar with crew, helipad at the bunker.

**Next up, in order:**
1. (Built in 0.4.0) Co-op + crews. Needs a live test with two accounts after publishing.
2. (Done in 0.2.1) SVG-made FX textures are uploaded under the group (327304402) and wired in `Config.TEXTURES`. New textures: put the PNG in `BlenderExports\fx`, upload through Open Cloud with the group as creator, then use the image ID from the decal.
3. Mobile controls.
4. Longer progression, retention and monetization design (sections 6–8).
5. Later: daily rewards, second map, voice lines, rebuilding the mesh buildings from parts.

## Bosses (v0.5.0)

A boss comes every 5 waves, in this order: Tank, Hive, Screamer, Burrower, Spitter Queen, Swarm Lord, Titan. Then they repeat, tougher each time round. Each boss teaches one idea (front armour, splitting, buffing others, hiding underground, range, guards, needing an ability). The first time each special move happens in a run, it plays a short cutscene. After that it's just a banner.
