# Changelog

Versions follow MAJOR.MINOR.PATCH. The current version is also in `VERSION` and on the `GameVersion` attribute of `ReplicatedStorage.Convoy` in the place.

## 0.3.0 — 2026-11-19

- Tutorial: friendlies can't be hurt. Aiming at them doesn't fire, splash doesn't hurt them, and Garmin calls "check fire" (red text).
- Tutorial: groups start 130-250 studs from the bunker (the gunship orbits right over the normal spawns at 400), on a stretch of road that is visible from the gunship over the next few seconds, not behind a building. They stay in a tight lane on the road, and the sensor swings to where they actually spawn.

## 0.2.9 — 2026-11-19

- Going between the hangar and the mission-setup map view now fades to black, and the camera jumps while the screen is black instead of gliding through the hangar walls.

## 0.2.8 — 2026-11-19

- New Shop screen (opened from SHOP in the hub or the + on the gem bar): three gem packs and two passes. Nothing is for sale yet — items are listed in the `Convoy.Shop` module and show SOON until real product IDs are filled in. The server already grants gems for gem-pack purchases once IDs exist.
- New Settings screen: music on/off, sound volume, replay tutorial, controls list (settings are not saved between visits yet).
- A-10 ability button uses a photo of the A-10 model with a white stroke.

## 0.2.7 — 2026-11-19

- Tutorial horde: the bunker only loses health while infected are actually at its walls.
- Enemy type markers are small coloured name tags (BRUTE, BOMBER, ...) instead of symbols.
- Heads now match body skin colour (the head texture was plain white); friendlies get a simple part-built face.
- Gunship engine and helicopter loops skip the faded ends of their clips.

## 0.2.6 — 2026-11-19

- Nuke mushroom cloud is textured smoke and fire particles instead of solid spheres; the fireball burns out into it.
- Garmin's lines highlight key words: red for warnings, amber for what to do.
- Bodies fall in random directions at different speeds and lose the red outline.
- Tutorial nuke fires itself after 12 seconds if the player doesn't.
- Less glare everywhere: weaker bloom, lower sun brightness, hangar lights halved, darker hangar ambient, floor markings no longer glow.
- The 15 realistic mesh cars are replaced with brick cars (which also explode).
- American flag built from parts on the hangar's back wall.
- Radio box moved up so it no longer covers the bunker bar.

## 0.2.5 — 2026-11-19

- Cars explode when shot (three 25mm hits, or one 40mm / 105mm / nearby blast): a 20-stud blast that kills everything around, the car is left charred and burning, and cars parked close together cook off in a chain. They reset each run. The 16 already-burning wrecks stay as scenery.
- Dead infected and friendlies fall to the ground and dissolve after about two seconds instead of vanishing.
- New part-built nuke model in the same style as the aircraft, used in the nuke cutscene.
- Nuke explosion rebuilt: white screen flash, fireball that cools as it rises, stem and smoke cap (mushroom cloud), shock ring, dust wall, burning crater; the cutscene holds wide for longer.

## 0.2.4 — 2026-11-19

- A-10 no longer points its nose straight at the target: it flies a real shallow dive with an eased nose-down, then pulls up.
- Survivors climb onto the Little Bird with a generated animation (asset 115792846811060): hands on the bench, hop up backwards, settle.
- Little Bird run-in is a curving, banking turn onto final; slower pedal turns in the hover; rotor-wash dust while it is low.

## 0.2.3 — 2026-11-19

- Cabin is darker (dimmer red lights, no glowing strips, lower exposure in cabin shots).
- Tutorial swings the sensor onto whatever Garmin is talking about (survivors, each pack, the boss); compass words removed from his lines.
- Type icons sit above the health bar instead of over it.
- Infected spread out: each keeps its own lane and they push apart instead of stacking.
- Extraction cutscene: the Little Bird comes in high, flares, banks and wobbles; survivors run to the skids, turn and hop onto the benches (one runs round the nose).
- A-10 cutscene: camera flies on the same path maths as the jet (no stutter); the jet slides down into frame.
- Sound: softer bunker-hit thump, quieter boss footfalls and rarer roar, low-bunker alarm no longer plays in the menu or tutorial.
- Bunker beacon lights dimmed.
- After the tutorial the arrow points at WEAPONS, then at the Upgrade button.

## 0.2.2 — 2026-11-19

- Each gun now looks different: 25mm fires thin pale-yellow streaks, 40mm fat red-orange slugs with an ember tail, 105mm a white-hot shell with a thick smoke trail. Each has its own impact effect and its own sight (cyan small cross, amber cross with ring, red large cross with heavy ring).
- Testing switch: `ForceTutorial` attribute on `ReplicatedStorage.Convoy` (currently ON) runs the tutorial on every join. Turn it off before launch.
- Removed the extra helipad; the Little Bird lands on an existing pad.

## 0.2.1 — 2026-11-19

- Seven SVG-made particle textures uploaded to the group and wired into `Config.TEXTURES`: fireball, smoke, flash, dirt, spark, shockwave, flame. Explosions now use them.
- Burning wrecks use textured flame, smoke and embers instead of the default Roblox fire.

## 0.2.0 — 2026-11-19

Tutorial rework and effects.

- Tutorial is slower: two extra waves (five teaching waves before the boss) and longer pauses.
- Guns unlock one at a time (others show LOCKED); upgrade button and abilities stay hidden until taught.
- Bouncing arrow points at the next button to click instead of text hints.
- Tutorial boss now takes visible damage (cannot die until the nuke).
- The player fires the final nuke themselves.
- New ending cutscene: a part-built MH-6 style Little Bird lands on a new helipad by the bunker and lifts three survivors out.
- Boss has footfall and roar sounds while alive.
- A-10 run: wingtip vapour trails, gun and engine smoke, heavier ground impacts with scorch marks.
- Explosions throw many more and bigger blocks.
- Server plan decided: one place, missions on reserved servers.

## 0.1.0 — 2026-11-19 (prototype)

First tracked version. The game is named **AC-130 vs a Million Infected**.

- Solo loop: hangar hub, mission setup (map, mode, access), endless waves, boss every 5 waves, results screen.
- Three guns (25mm, 40mm, 105mm) with in-run tiers and permanent stat upgrades; abilities: Repair, A-10 run (drawn with two clicks), Nuke.
- Infected types: Runner, Brute, Bomber, Spitter, Armored; health bars; friendlies marked green.
- Tutorial "FIRST MISSION": cinematic cabin intro using the player's avatar, radio guide GARMIN, staged teaching waves, unwinnable horde and rescue.
- Part-built AC-130, A-10, hangar trucks and tug; rebuilt gunship cabin interior with ammo racks and military screens.
- Hangar: walking crew, driving tug and cargo truck, menu leaderboard card.
- Saving: Gems, best wave, total kills, upgrades, tutorial done.
- Plain wording: callsign "Reaper 41" (was "Spooky 41"), "First Mission" (was "First Sortie"), map "Downtown" (was "Deadzone").

Not built yet: co-op, real Create/Join lobby servers, mobile controls, monetization, analytics.
