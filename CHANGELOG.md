# Changelog

Versions follow MAJOR.MINOR.PATCH. The current version is also in `VERSION` and on the `GameVersion` attribute of `ReplicatedStorage.Convoy` in the place.

## 0.7.1 — 2026-11-20

- Guns: in a normal run the 40mm and 105mm start LOCKED; unlock them with run cash ($1,500 / $4,000, `Upgrades.UNLOCK`). Locked cards say LOCKED, picking one says how much it costs, the server won't fire it.
- Explosions are voxel now: every puff is a tumbling cube (fireball, smoke, dust, embers, bullet trails, the bunker going up), rings are rings of cubes, the nuke cutscene's balls are blocks. No more round particle sprites in explosions.
- The black scorch / bullet-hole discs are gone.
- Sparks are streaks: new `SparkStreak` texture (art/fx/spark_streak.png) for the welders and every impact spark.
- Welders: bigger, full-bright sparks; Jacob's imported welding crack (`Sounds.Weld_Spark`) plays in bursts of 2-4 that overlap a little; the hangar ambience uses it too.
- Little Bird: departs and lands along the same line out over the runway, climbing as fast as it moves away, so it clears the hangars and the tower.
- Shop: 15,000 gems (R$999), VIP pass (+25% gems and run cash, R$299), Head Start pass ($1,500 cash at the start of every run, R$129). Four cards per row; every buy button shows the live Robux price; passes you own say OWNED.
- Gem bar + also on the armory screen.
- Lobby crew slots: headshot above a name strip (long names cut with ...); clicking an open slot's + opens Roblox's friend invite.
- Second Chance: a real mouse cursor over the panel (clicks don't fire the guns) and a GIVE UP button. The crew leader can also give up mid-run (`GiveUp` action).
- After a run, PLAY AGAIN / LOBBY first shows the gunship breaking orbit and heading home for a moment.
- A-10 gun-run cutscene only the first time per session.
- Removed: the F-15 flyby (and its jet sound) at the start of a run, the jet sound in the deploy cutscene, and the metal clank sounds on deploy and when the run ends.

## 0.7.0 — 2026-11-20

Monetization and saved settings.

- Created on Roblox (prices are editable in Creator Hub > Monetization), each with its own icon (`art/store`, made by `make_store_icons.py` in the game's icon style: white silhouette, thick black outline; store versions on the near-black panel with an accent border, `hud_*` versions transparent for the HUD):
  - Battle offers (developer products): Emergency Repair R$25, Second Chance R$49, Instant Nuke R$39, Cash Drop R$19.
  - Gem packs: 500 for R$49, 1,500 for R$129, 5,000 for R$399.
  - Game passes: 2x Gems R$199, 2x Cash R$149.
- `Convoy.Shop` now holds every product/pass ID, icon and the battle-offer text.
- `BattleOffers` (new client script), styled like the hub (square near-black panels with a coloured stroke, Roboto Heavy with dark text strokes, the hub's lip/face/inner buttons and dark red-X close button): a small card slides in from the right at the right moment (bunker under 35% -> Repair, 5 s after a boss walks in -> Nuke, every third break -> Cash Drop), stays 9 s, at most one every 50 s, never in the tutorial. When the bunker falls the run freezes for 10 s with a big Second Chance countdown any crew member can buy (once per run). Everyone sees a toast when someone buys ("JACOB CALLED IN AN INSTANT NUKE!").
- Server (`Mission`): ProcessReceipt grants gem packs and battle offers, de-duplicated by purchase ID in a DataStore; an offer that lands too late gives 150 gems instead. Passes are checked on join and on purchase; 2x Cash doubles every cash gain, 2x Gems doubles your share at the end of a run (debrief shows your own number). Studio-only `DebugGrant` BindableFunction to test products without buying.
- Settings are saved: music on/off and volume go to the server when changed and come back with the profile on every server. The ambience follows the volume setting.

## 0.6.5 — 2026-11-20

- Hangar wall dressing now uses the game's four surface textures (Plastic + Weld / Studs / Inlet / Universal surfaces) like the gunship and the set: Weld on all the metal (pipes, duct, office, stairs, lockers, chests, fans, panels, drums), Studs on stair treads, benches, desks and the pallet, Inlet on the pegboard and the office floor/roof, Universal on crates and electrical panels. Signs stay smooth so the text reads.
- Big signs (HANGAR 7, squadron banner, outbreak board) render their letters larger (TextScaled caps at 100 px, so fewer pixels per stud).

## 0.6.4 — 2026-11-20

- Welding sound: the welders' buzzy arc (Tesla Coil) is now a sparkler sizzle (Pro Sound Effects 9119380766) that sounds like a torch. The impact-wrench "drilling" bursts in the hangar ambience are gone; short welding sizzles play around the floor instead.

## 0.6.3 — 2026-11-20

- Base ambience (`BaseAmbience`, new): hangar hall bed, outdoor wind and distant traffic, plus random far-off jets, helicopters, formation rumble and range fire through a muffled group, and impact wrenches / dropped tools around the hangar floor. Fades out during missions.
- Airbase vehicles make noise: the Little Bird's rotor follows its spin, the A-10 roars on its take-off roll, every truck has a diesel loop (all 3D, heard faint from the hangar).
- Welders: bigger sparks, a white-hot arc flare at the torch tip and an arc crackle you hear up close. The wing welder now works under the right wing tip (clear of the fuel truck).
- Hub music volume 0.3 -> 0.2.
- Hangar walls dressed (`WallDressing`): pipes, brackets and an air duct round the walls, a glass control office on a mezzanine with stairs, lockers and bench, pegboard tool wall and red tool chests, exhaust fans, electrical panels with conduit, fire extinguisher stations, oil drums, safety signs, a sortie board, a "days without an outbreak" board, a squadron banner, a Zulu clock and a big HANGAR 7 stencil. Checked for overlaps with everything already in the hangar.

## 0.6.2 — 2026-11-20

- ForceTutorial is off: only new players get the tutorial.
- One welder now stands on his work stand under the right wing, behind the fuel tank, welding the flap overhead (OverheadWeld clip, `Overhead` attribute). Stand legs lengthened; checked clear of every gunship part, including the non-queryable fuel tank.
- All three welders wear the imported welding mask instead of the block mask and the soldier helmet.
- Hub music changed to a calmer, darker track: "Watching Patrol Underscore" (APM, 9038144841).

## 0.6.1 — 2026-11-20

- Mobile controls (`Convoy.Aim`): on touch the crosshair is fixed in the middle of the screen, like the mobile game; drag anywhere to slew the sensor, pinch to zoom, hold the round FIRE button (bottom right) to shoot. The A-10 run's two ends are placed with FIRE too, and the tutorial's control hint uses touch words. Mouse and keyboard are unchanged; the game switches with whatever the player last touched.
- Armory: the camera turns so the selected gun (or the A-10) sits in the middle of the gap between the two panels (`ArmoryFocusX`).
- Fire-rate number for the 105mm was infinite (it has no cyclic rate). Hand-loaded guns now show shots per minute from the reload, and their fire-rate upgrades shorten the reload on the server too.
- Welders in the hangar: three crew on rolling work stands weld the parked gunship's hull with a pose clip (AnimClips), shower sparks and flicker a blue-white arc light (HangarLife).
- AC-130 cargo ramp no longer hangs down at the back (closed flush, both the parked gunship and the in-game model). The AC-130 on the apron is now a copy of the detailed hangar gunship.
- Hangar ammo loader moved to the A-10's nose, clear of the ammo crates.

## 0.6.0 — 2026-11-20

- The hangar is above ground now. It moved from under the city terrain (y -400) to x+5100 / y+0 (floor top y=0, door facing -X, centred on z=150). The old painted sky walls, hills and clouds are in `ServerStorage.OldExterior`.
- Real airbase round it (`Hangar.Airbase`), on a terrain plain with rolling hills and mountains at ~1.5-2.7k studs and a sandy shore to the city's ocean: runway (5250, -1700..2000) with markings and edge lights, two taxiways with hold bars and blue lights, apron with the parked AC-130 and two A-10s, a heli apron with three helipads, a control tower, a radar (its dish turns), two side hangars, barracks, a fuel farm, a windsock, light poles and a ring road.
- `StarterPlayerScripts.AirbaseLife` (client): five trucks lap the ring road, three squads march and jog (feet in step with their speed), a Little Bird loads a four-man fire team (they run out and climb on with the bench-climb clip) and flies off then returns, an A-10 takes off down the runway. Paused during missions.
- Hangar door centred on the building (moved 10 studs); every face on the door frame that sat on the same plane as another one is pushed out 0.03 (no more flicker on the doors).
- Hangar floor: the painted ring, centre line, cyan guide lights, the parked gunship and its crew moved 10 studs so they line up with the door, the hazard box and the apron line (all on z=150). The hub camera and HangarLife's ring centre moved with them.
- A-10 cannon: the single GAU8 tube is replaced by a GAU-8 rotary cannon (`GAU8Detail`): shroud, seven barrels round a spindle, two clamps, muzzle rings and bore holes. It's on the hangar jet, the template in `Convoy.Models` and the parked ones. A-10 parts have surface textures on every face.
- Hangar flag: smaller and lower (y 19-54), clear of the ceiling beams and light rods.
- Airbase: the main taxiway (with its line, hold bars and lights) moved to z=150, so its yellow line runs straight into the apron line and the hangar's centre line.
- Fixed a `math.clamp` error in the cutscene caption on small screens.

## 0.5.1 — 2026-11-20

- Armory callouts: brighter (above the panel backing), each stat has its own colour (orange / cyan / green), and the cards sit round each weapon differently.
- Parked gunship guns: every part reaches slightly into the one behind it, so no two faces share a plane (no more flicker on the 105). AC-130 parts have surface textures on every side.
- Bosses: new look module `ConvoyServer.BossLook` (skin / shirt / trousers palette per boss plus props; no neon, no lights). Each boss has its own walk from the R15 animation packs (robot, elder, werewolf, ninja, vampire, knight, zombie). Every infected's walk now plays at the speed it actually moves (`e.track`, `e.stride`, `e.scale`), including charges, screams, burrowing and holding position. The tutorial boss is its own "PATIENT ZERO" instead of the Titan.
- Animation from data: `Convoy.AnimClips` builds KeyframeSequences at runtime from pose tables (method from github.com/1nird/animations-cutscenes-skill) and registers them with KeyframeSequenceProvider, so nothing is uploaded. Clips: `sitDown` (stand in front of a chair and sit), `chair` (seated loop), `benchClimb` (hands on a bench edge, push up and sit), `bench` (seated loop with legs swinging). The tutorial gunner and the rescued survivors use them, so nobody floats into a seat any more. The clips move the body from where the character stands, so the root goes on the seat and the clip starts with a cut rather than a blend.

## 0.5.0 — 2026-11-20

- Upgrade tab icons (blast, fire rate, reload, run length, firepower, call cost): SVGs in `art/icons`, uploaded to the group, wired in `GunshipUI` (`STAT_ICON`).
- Tutorial: the bunker starts damaged (62 HP) and Garmin teaches REPAIR (arrow + pulsing button). Ability buttons the arrow points at (Repair, Nuke) grow and shrink.
- Gunship rounds look like real shells (body, coloured nose, tracer glow) instead of glowing balls (`FXLib` `SHELL_LOOK`).
- Hangar: ammo crates, bomb cart, cans and a gun-ammo loader around the A-10; new outside view through the door (sunset sky, hills, runway, control tower, far hangars, parked AC-130 / A-10 / Little Bird); detailed guns on the parked gunship (GAU-12 barrels, Bofors flash hider, 105 muzzle brake).
- Armory: picking 25mm / 40mm / 105mm swings the camera to that gun on the parked gunship.
- Seven bosses, in this order, each with a special move: THE TANK (25mm bounces off, front plates take 1/4 damage, charges), THE HIVE (splits into runners at 75/50/25% and when it dies), THE SCREAMER (makes nearby infected faster), THE BURROWER (goes underground where it can't be hit, comes up ~70 studs further on), SPITTER QUEEN (shells the bunker from range, spawns spitters), SWARM LORD (a ring of bombers walks with him; bomber blasts hurt him for 12% of his health), THE TITAN (stomps buildings and survivors; the last quarter of its health only comes off to the A-10 or the nuke). After the seventh they repeat with +60% health each time round. The tutorial boss is the Titan with no moves.
- The first time each boss move happens in a run, a short cutscene plays (CutKind `BossMove|<move>`). After that you just get a banner (`BossMove`). The A-10 and the nuke now pass hit kinds `a10` / `nuke`.
- Testing switches: `DebugBossKind` (1-7) forces which boss appears.
- Armory callouts: a blueprint grid with thin lines from the gun's parts (muzzle, barrels, feed / breech; A-10 wing, cannon, engines) to cards showing the stat, its value now and after the next upgrade. Click a card to select that stat.
- Parked gunship guns: no more overlapping surfaces (the old port plates and mount are hidden), and every barrel has a bore hole. The 25mm Armory camera has its own spot so the landing-gear fairing and the propeller don't block it.
- SkipTutorial is off again. ForceTutorial is still on for testing.

## 0.4.1 — 2026-11-20

- Gem icon (purple diamond from the icon pack, uploaded to the group as decal 73641351713271, image 80144558467632) on the gem bars and shop packs (`Shop.GEM_ICON`).

## 0.4.0 — 2026-11-20

- Co-op: up to 4 gunners on one gunship. Each has their own guns, ammo, cash and tiers; bunker and waves are shared. Everyone gets the run's gems.
- Crews: CREATE makes a crew with a join code; JOIN shows open crews or takes a code. Host picks mode, PUBLIC/FRIENDS and deploys. Crew slots show each gunner's headshot.
- Servers: public servers are the hangar; each deploy gets its own reserved server, and new players get their own tutorial server (new `ConvoyServer.Lobbies` script). Studio still runs everything on one server.
- Debrief PLAY AGAIN reruns with the same crew; LOBBY takes you back to a hangar server.
- A-10 upgrades in the Armory (run length, firepower, call cost); the camera moves to the A-10 while it is selected.
- Tutorial: the sensor follows the infected, the wrong gun won't fire on a wave meant for the new gun (Garmin tells you which one), and the final horde is bigger.

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
