# Changelog

Versions follow MAJOR.MINOR.PATCH. The current version is also in `VERSION` and on the `GameVersion` attribute of `ReplicatedStorage.Convoy` in the place.

## 0.11.3 — 2026-11-21

- Title on the hub is now GUNSHIP vs a Million Infected.
- AC-47 Spooky model: the three miniguns sit in framed gun ports / the open cargo door on cradles and a pedestal (were barrels poking through the skin next to a black slab).
- Ammunition comes with the weapon tier (`Upgrades.AMMO`, nothing to switch): tier 3 ARMOR PIERCING (the small gun hurts armored infected at 60%, every gun does 60% instead of 25% through the Tank's front plates), tier 5 HIGH EXPLOSIVE (+25% blast), tier 7 INCENDIARY (+50% to bosses, small gun full damage to armor). The HUD shows it next to the tier and announces it on the upgrade.
- An aircraft that carries only the small gun (the Spooky) does 35% to armor from tier 1, so it can always hurt armored infected and the Tank.
- Bosses: more health on the Hive, Screamer, Burrower, Spitter Queen and Swarm Lord. Each moves its own way: Screamer stalks then sprints, Titan takes three strides and stops, Hive lurches, Burrower darts, Swarm Lord weaves, Queen glides, Tank marches.
- Boss sounds: the roar is a creature roar (was a pitched jet fly-by); the roar-on-a-timer and the extra unsynced thud are gone (footsteps come only from `GiantSteps`).
- Fix: cutscene captions threw an error on very short screens (could leave the HUD up during a cutscene).

## 0.11.2 — 2026-11-21

Hub and HUD
- PLAY sits in the centre of the screen. REPLAY TUTORIAL is off the hub (still in Settings).
- Map select: DOWNTOWN shows a photo of the map (`art/map_downtown.png`).
- The crosshair has its own top layer (`CrosshairTop`), so it draws over the Robux buttons and the toasts.
- PROMOTED during a run is a small strip under the wave bar instead of a panel over the fight.
- After LOBBY on the results screen, a RETURNING TO BASE card holds until the lobby loads.
- AIRCRAFT prices use the gem picture.
- Enemy tags and health bars are hidden while a cutscene plays.

Tutorial and cutscenes
- The radio uses the player's name where it said "gunner".
- A-10 flyover: the street-level shot picks a spot with a clear view of the strike (no more wall in the lens).
- Extraction: survivors sit on the Little Bird's benches (were 0.5 above them). Civilian faces are decals.
- Failing for civilian hits no longer blows up the bunker.

Enemies and weapons
- Fixed infected sliding with frozen legs after a cutscene (the walk speed was never restored); a run clip that failed to load is retried; a stuck cutscene freeze clears after 12 s (was 25).
- Spitters: stand in an idle stance, lunge when they spit, and a green glob arcs to the bunker and bursts (`SpitFX`). Damage lands with the glob.
- Weapon tiers go to 8 (was 4), same formulas.
- Bosses have 2.2x health (not the tutorial boss).

## 0.11.1 — 2026-11-21

Rework of the seven new aircraft models (no gameplay change).
- Stray parts removed from every model: nav lights, beacons, antennas and wires, probes, loose panels (the black lines on top of the B-52). A stricter floating-part check (real geometry, not bounding boxes) now passes on all seven.
- Things that did not touch the body are now joined to it: Huey skids, Harrier nose/main gear, Apache engines, Chinook engines.
- Guns rebuilt: six-barrel miniguns with motor, clamps and ammo box (Spooky, Huey, Chinook), Apache chain gun on a turret, Chinook nose grenade launcher, Harrier cannon pods, rocket pods with tube faces.
- Engines: intake faces follow the shape of the intake (Harrier, Apache) instead of a black box; Harrier nozzles are ducts with vanes; exhausts are dark steel, not brown.
- All aircraft stand on their wheels/skids on the apron (the hidden root part no longer lifts them).
- Bay 01 outside now shows the same AC-130 as the main lobby (`Hangar.ParkedGunship`).

## 0.11.0 — 2026-11-21

No aircraft is flown by hand any more: every one is flown for you and you run its weapons. All eight can now be used in a run (and bought: rank reached + gems).
- Line-up: AC-130H (start), AC-47 Spooky (2), UH-1 Huey (4), MQ-9 Reaper (6), AV-8B Harrier (7), AH-64 Apache (9), CH-47 Chinook gunship (12), B-52 (15). The Little Bird, A-10 and F-15E are out of the list. New models: UH1, AV8B, CH47.
- Hovering aircraft (Huey, Harrier, Apache, Chinook): `Convoy.Orbit` has a hover path. A bot pilot holds over one of 3-4 stations round the bunker, then slides to the next, drifting slightly. Stations rotate on a timer; they do not yet chase the infected.
- Weapons per aircraft (the three weapon slots, renamed and retuned in `Convoy.Aircraft`): Huey door minigun + rockets; Reaper 4 Hellfires; Harrier 25mm + 2 bombs; Apache chain gun + rockets + Hellfires; Chinook twin miniguns + 40mm grenades; B-52 a 12-bomb bay.
- B-52 circles high the whole time (no gaps between passes) and drops wherever you aim.
- Each run starts on the first weapon the aircraft carries.
- Not built yet: lock-on for Hellfires, damage to low-flying aircraft, takeoff cutscenes for the new aircraft, and seeing crewmates' aircraft. The hand-flown helicopter code is left in `GunshipClient` unused.

## 0.10.0 — 2026-11-21

Two more aircraft can be flown (and so bought: rank reached + gems):
- AC-47 Spooky (gunner): its own lower, tighter orbit (`orbit` in `Convoy.Aircraft`). One weapon, the miniguns: 22 rounds a second, no reload, small blast, limited by heat. No 40mm / 105mm.
- AH-6 Little Bird (flown by the player, `fly = "heli"`): WASD or a floating left-thumb stick moves it in screen directions with momentum; Shift boosts. The nose swings to the aim point (to the direction of travel on touch), the body leans into acceleration, the rotors spin, height is automatic and a soft wall keeps it over the map. The camera trails on a spring and leads the direction of travel; scroll / pinch pulls back. Weapons: minigun (heat) and 14 Hydra rockets (reload), both free with the aircraft.
- Server: each crew member's aircraft is fixed at run start (`RunPlane`). Guns take per-aircraft overrides in `applyGun`. Flown aircraft report position with Action "Fly" (clamped to the map and a height band) and shots originate there.
- HUD: weapon cards show the aircraft's own gun names and only the guns it carries; belt-fed guns show "---" for ammo. A banner explains the flight controls at the start of a run.
- The tutorial always uses the AC-130. The hangar roll-out cutscene plays for the AC-130 only.
- Not done yet for the Little Bird: taking damage (it has no health bar yet), and other players cannot see your helicopter.

## 0.9.2 — 2026-11-21

- Artillery is aimed by the player. Pressing it shows a red ring the size of the barrage at the aim point; click (or tap the screen on touch) to send it there, press again or right-click to cancel. The server fires at that spot (within 700 studs of the bunker) and charges on firing.
- HUD banner: the sub line is a dark plate that hugs its text (tan mono type, olive border) instead of a fixed amber bar with outlined text.
- Objective toast is as wide as its words (260-660) and 76 tall, and drops in just under the wave bar instead of on top of it.

## 0.9.1 — 2026-11-21

- Military look across the whole GUI. Every screen uses an olive / tan / amber / muted palette, Oswald for headings, square corners and thinner outlines. Colours set by `GunshipUI`, `RanksUI` and `BattleOffers` were remapped to the same palette. New `MilitarySkin` client script draws every button face as a flat plate (dark fill, state colour on the border).
- Hangar row: fixed overlapping faces (back wall / side walls, fascia / roof, sill / floor, apron / old apron) that flickered.
- Life on the hangar row (`AirbaseLife`): two crew chiefs at every aircraft's nose, a mechanic at each door, a two-man inspection patrol walking nose to nose, three trucks running along the front of the apron and three parked between the smaller aircraft. The old squad route no longer cuts through the B-52.
- The main hangar shows the aircraft you fly (`HangarPlane`, client side, so each player sees their own). Any aircraft other than the AC-130 hides the built-in gunship and parks its own model on the same spot. Welders move to that aircraft's hull where they can reach it from the floor, and stand down otherwise. Studio test: player attribute `HangarPlaneTest`.
- The armory's A-10 is replaced by a 155mm howitzer (`Set.Artillery`) with ready shells and charge crates; the armory camera frames it.

## 0.9.0 — 2026-11-21

Aircraft (first stage: the hangar row, the tab and unlocking; only the AC-130H can be flown so far):
- New `Convoy.Aircraft` module with 8 aircraft, each with a rank, a gem price, specs and weapons: AC-130H (start), AC-47 Spooky (rank 2), AH-6 Little Bird (4), MQ-9 Reaper (6), A-10 Warthog (7), AH-64 Apache (9), F-15E Strike Eagle (12), B-52 (15). `ready = false` marks the ones that can't be flown yet (shown as COMING SOON).
- Profile saves `Planes` (owned) and `Plane` (equipped). Actions `BuyPlane` (rank reached and gems) and `EquipPlane` are checked on the server.
- New models in `Convoy.Models`: AC47, MQ9, AH64, F15E, B52. They are built from tapered skin panels and long wing strips (rounded bodies, swept wings, real engines, gear and stores). Cockpit glass is part of the hull panels.
- Outside base: the two old side hangars are replaced by `Airbase.AircraftRow`, eight open-door hangars sized to their aircraft with each aircraft parked out front. Each bay has hazard posts, lamps, a bay sign and a camera spot (`CamPos` / `CamLook` attributes).
- AIRCRAFT hub button and screen (`AircraftUI`): list on the left, specs, weapons, rank needed, price and EQUIP / REQUISITION on the right. The camera flies to the selected aircraft's hangar. The screen uses a military look: olive, tan and amber, condensed type, flat plates.
- The hub bottom row is now AIRCRAFT / WEAPONS / PLAY / RANKS.

Artillery replaces the A-10 ability (the A-10 is becoming an aircraft):
- F / the ability card calls a 155mm barrage on the biggest group of infected, avoiding civilians. It wants a group of 4, and after 8 s of waiting it settles for any pair. It is paid for only when it fires; pressing again cancels.
- A red ring marks the impact area. Saved A-10 upgrades carry over (SHELLS / FIREPOWER / CALL COST).
- New icon: `art/hud/hud_artillery.png`.

## 0.8.15 — 2026-11-21

Bosses bring their own horde:
- On a boss wave, the whole wave spawns as the boss's escort, in a loose ring around it (8-22 studs, wider for bigger bosses), not on other roads. Escorts circle the boss slowly as it walks, then head for the bunker on their own once it dies. They walk during the boss's own cutscenes too, since they are in the shot.
- Every boss calls in more infected around itself every 9 s (first call 16 s in). The call is 6 infected, fewer for a phone crew, and only while it has fewer than 10 escorts and fewer than 120 infected are out. It shows a burst at the boss and no banner. Each boss's own special move is unchanged.
- Playtest (THE TANK): escorts 0-30 studs from the boss 26 s in, versus 32-98 before the freeze exemption.

## 0.8.14 — 2026-11-21

Phones:
- A small FIRE button is back in the bottom-right corner (56-72 px, the word scales to fit). Auto-fire stays on. The weapon cards sit just above the button.
- The bunker bar and the money under it stay small in the top-right in real runs too. The tutorial still hides the money. Quick-buy tiles size to the gap between the abilities and the weapon cards.
- Red target boxes were rewritten. They now draw inside GunshipUI's `HUD.Markers`, using the same screen maths as the green friendly markers, and are centred on the torso with the body's measured extent (1.9 up, 2.8 down per unit of scale). They are tighter (+3 px, thinner stroke).
- Fixed a scoping bug where `enemiesRoot` was read before it was declared, so the "not a civilian" check never ran. Civilians are never boxed now, and the check runs every frame too.
- Green friendly markers hug the body on phones instead of a fixed 22 px square.

All devices:
- Cutscenes freeze the fight. While a gunner is in a cutscene (the client reports it with Action "Cut"), every infected and civilian stands still and stops animating, except the boss the cutscene is about. Reports time out after 25 s. Checked in a playtest: 0/5 infected moved during a boss intro while the boss walked 14 studs, and all of them moved again after it.
- Tutorial: the impossible wave is endless. From "contact everywhere" until the nuke, a pack of 8 arrives every 0.6 s, up to 130 alive. It no longer runs dry before the A-10s and the nuke.

## 0.8.13 — 2026-11-21

- Phone target boxes: camera (viewport) pixels are now converted to the boxes' ScreenGui pixels as `viewport point - GuiService:GetGuiInset() - gui.AbsolutePosition`. On PC this is zero, so nothing changes there. On phones the GUI's origin can sit away from the viewport's, because of the top bar or the notch safe area, which shifted every box off its infected.

## 0.8.12 — 2026-11-20

Phone target boxes:
- They no longer trail behind the infected. They are now drawn right after the gunship camera moves each frame (`BindToRenderStep` at Camera + 2, just after GunshipCamera), not before it. In a playtest, box centres land within about 2 px of the model's centre.
- Civilians no longer get a red box. The server spawns them with the infected and then moves them to `DMZ_Civilians`, and their box now goes away when they move.
- Box size follows the model's live scale.

## 0.8.11 — 2026-11-20

Phones:
- The wave bar is centred at the top, as big as it can be without reaching Roblox's buttons.
- Tutorial: Garmin's radio box sits along the bottom between the ability cards and the weapon cards, scaled to fit. It used to sit 200 px up the screen, which covered the middle on a phone. There is no money box, and the bunker bar goes small in the top-right corner. Layout re-fits when the tutorial starts or ends.

## 0.8.10 — 2026-11-20

- Fix: Settings > REPLAY TUTORIAL did nothing on live servers. `Mission` only starts the tutorial in Studio. Now `Lobbies` handles it on lobby and mission servers (not mid-run): it takes you out of your crew and sends you to a fresh server of your own with the tutorial plan, the same way a new player gets it. While that happens, the notice reads "LOADING THE TUTORIAL...".

## 0.8.9 — 2026-11-20

- A-10 picks its own target on every device; no more drawing the run. The server finds the line through the biggest group of infected, using where they will be when the guns open up (each one's route is walked forward). Civilians count against a line.
- With fewer than 6 infected in the best line, the A-10 waits on station ("A-10 ON STATION // WAITING FOR A BIG GROUP"). It is paid for only when it flies. Pressing A-10 again (tap, or F on PC) calls it off for free.
- Banners show "A-10 INBOUND" when it commits.
- No A-10 cutscene in a run; you watch it come in from the gunship.
- The tutorial's A-10 cutscene now shows the jet. It is a chase cam on the same flight path, now including the pull-up the camera was missing, so the jet no longer climbs out of frame. The street shot is aimed where the rounds actually land.
- Phones: the weapon cards move to the bottom-right corner (no FIRE button there now), and the wave bar uses the full top width.

## 0.8.8 — 2026-11-20

- Phones are full auto-fire. The FIRE button is gone, and every gun fires on its own while an infected is under the crosshair: within 6 studs for the 25mm, 9 for the 40mm and 12 for the 105mm. Guns still hold fire when a civilian is within that radius. The AUTO-FIRE setting is removed, since there is nothing to turn back on.
- A-10 on touch: tap the screen (a quick tap, not a drag) to place the start and end of the run.
- Touch hints and the tutorial line say the gun fires by itself.

## 0.8.7 — 2026-11-20

- AUTO-FIRE on touch devices. The 25mm and 40mm fire on their own while an infected is under the crosshair: within 6 studs for the 25mm and 9 for the 40mm, more for big ones. They don't fire if a civilian is within that radius too. The 105mm and the FIRE button stay manual.
- The FIRE button shows an AUTO tag, which turns red while auto-fire is shooting.
- Settings has an AUTO-FIRE row on touch devices, on by default and saved with the profile (`Settings.AutoFireOff`). The panel grows to fit the row only on touch.
- Touch control hints mention auto-fire.

## 0.8.6 — 2026-11-20

- Easier on phones. Each client tells the server its device (Action "Device" → Player attribute `Touch`). A crew that is all on touch gets 35% fewer infected per wave and tough types with 35% less health (bosses 30% less). Mixed crews get a share of that.
- Infected walk 15% slower in every mode, so they take a bit longer to reach the bunker.
- Phone target boxes are really red now. They are flat screen frames (`TargetBoxes` ScreenGui) instead of BillboardGuis, because the thermal camera's colour grading had turned them green. They are still hidden behind buildings (raycast).
- New `EdgeAlert` (PC and phones): when 10 or fewer infected are left in a wave, the screen edge on the side where off-screen infected are glows and pulses red.

## 0.8.5 — 2026-11-20

Phone fixes, round three (Jacob's iPhone):
- Cutscene bars and the black wipe now reach the real screen edges. `GunshipUI.ClipToDeviceSafeArea` is off (Roblox was clipping them at the notch safe area), and the bars reach past the bottom home-bar strip.
- Text fits its box. Labels are measured with `TextService:GetTextBoundsAsync` (the old check read `TextBounds`, which lags behind a size change, so every size passed). Text that doesn't fit gets smaller, on every device. Labels are re-fitted whenever their text changes or new ones appear.
- The wave-cleared banner says "TAP START" on touch instead of "[SPACE] START".
- Armory: no upgrade callout cards on phones.
- No pop-up purchase offers and no "X called in…" toasts on phones. The Repair and Cash tiles stay.

## 0.8.4 — 2026-11-20

- Pinch zoom on phones is calm now. Roblox reports a pinch as its total size change since the fingers went down, and the old code applied that total again on every frame, so a small pinch zoomed hugely. The zoom is now worked out from where the pinch started, so the view follows your fingers.

## 0.8.3 — 2026-11-20

Phone fixes, round two (Jacob's iPhone):
- The wave bar (AUTO-SKIP / WAVE / START / next boss) stays at the top on phones, in the gap between Roblox's buttons and the weapon cards, a bit smaller if it has to be. (0.8.2 pushed it down to the bottom.)
- Panels are no longer moved to the right to dodge Roblox's buttons: they stay centred and only their title steps out from under the buttons.
- Only the wave banner may slide down under something; everything else just gets smaller where it must.
- Text stays big on phones: after fitting, any label that would draw under 12 points on screen is made bigger where its box has room (`boostText`).
- Fitting now uses the GUI's real area (the safe area on notch phones), not the camera's full width.

## 0.8.2 — 2026-11-20

From Jacob's iPhone screenshots:
- Nothing sits under Roblox's own buttons (top-left menu / chat / voice) any more: the fit pass reads `GuiService.TopbarInset` and slides anything in that corner down (or, for centred panels, to the right, which keeps them bigger). Pieces that land on top of a more important one slide down under it before they shrink (the wave banner now sits under the boss bar on phones).
- Cutscene letterbox bars and the black fade reach the real screen edges on notch phones (they were stopping at the safe area).
- Armory on phones: only the stat you picked gets a callout card, at 60% size, and no callout goes above the gun's name.
- Repair / Cash tiles on phones size themselves to the gap between the abilities and the bunker bar. FIRE is a little smaller (100-150).
- Phones: holding FIRE while dragging to aim no longer zooms the camera in and out (a pinch now needs two fingers both on the view).
- Phones: a red box around every infected (`TargetBoxes`), at least a few pixels across at any zoom, hidden behind buildings like the heat glow.

## 0.8.1 — 2026-11-20

- Phones: every screen fits now. After the usual scale, any top-level piece that would run off the screen or into a more important piece shrinks a little (down to 60%) until it fits (`FIT_ORDER` in GunshipUI; tween targets use each frame's `FitScale`). The hub leaderboard steps aside when there is no room for it. Checked at 844x390 (iPhone landscape): hub, HUD, lobby, armory, ranks.
- Phones, in a run: the weapon cards go top-right so the FIRE button has the bottom-right corner (FIRE sized to the screen), the abilities sit under the tally, Repair / Cash tiles sit bottom-left, and offers drop in under the wave bar.
- PC: the mission screen no longer pokes past the bottom on 1080p-ish windows; the Armory / Ranks centre blocks are narrower (no change in look).
- Control hints match the device (new `ControlHints` script): the hub's hint line and the Settings controls list say HOLD FIRE / DRAG TO AIM / PINCH TO ZOOM / TAP A GUN on touch, keys on PC; the C / V / F key tags on the ability cards hide on touch; Garmin's "Press 2." becomes "Tap the 40mm." on touch. The hub hint line shrinks to fit any width.

## 0.8.0 — 2026-11-20

- New: RANKS, the core hook from the original Zombie Gunship. The hub's CLASSES button is now RANKS.
  - Three objectives at a time (kill N with a gun, kill N of a type, N kills with one 40mm/105mm shot, reach wave N, reach wave N with no civilian hit, defeat bosses, rescue civilians, call in A-10s, N kills in one run). Targets grow with your rank.
  - Finish all three and you're promoted: 19 ranks from RECRUIT to GENERAL. Every rank is +10% cash and gems for good, and a promotion pays 100 + 50 x rank gems.
  - Any objective can be swapped for a new one for Robux: SKIP buttons sell the Skip Objective developer product (R$25, `Shop.SKIP_OBJECTIVE` 3734067874, icon art/store/store_skip_objective.png). The client picks the slot (`SkipObjective` action), the receipt does the swap; nothing left to skip refunds gems.
  - RANKS screen laid out like the WEAPONS screen: insignia and rank name in the middle (clear of the gem bar), an OBJECTIVES list on the left (each card in the colour of what it asks for, lime when done), a RANK BONUS panel on the right (bonus, next rank, promotion reward, 3 pips), gem bar on top, EXIT at the bottom.
  - "Objective complete" strip and a "PROMOTED!" card with the new insignia, in runs and in the hub. The rank short code (SGT, CPT...) shows on the RANKS button and on every lobby crew slot.
  - Rank insignia (art/ranks, `make_rank_icons.py`): white silhouettes with a thick black outline, one 5x4 sprite sheet of 200px cells on a 1024x1024 canvas (Roblox stretches non-square sheets, which threw the cells off centre).
  - Code: rules + text `ReplicatedStorage.Convoy.Ranks`, state + progress `ConvoyServer.Ranks` (hooked from Mission: kills, shots, waves, rescues, A-10, bosses), UI `StarterPlayerScripts.RanksUI`, screen `StarterGui.GunshipUI.Ranks`. Saved in the profile (`Rank`, `RankObj`). Studio test hook: `ServerScriptService.DebugRanks`.

## 0.7.4 — 2026-11-20

- Lobby: MODE / ACCESS buttons moved up so they no longer sit on the line of text under them; the mode you didn't pick (or LOCKED Hardcore) is solid dark grey instead of see-through. The crew code is bigger and amber.
- Lobby: the host can kick crew members (red X on their slot, press twice). Kicked players can't rejoin that crew with the code.
- Guns: picking a locked gun (click, 2/3, or Q) shows the unlock price and keeps you on the gun you had; Q skips locked guns.
- Infected: in the thermal view each kind has its own colour (normal red, runner pink, brute purple, bomber orange, spitter yellow-green, armored blue); the server keeps each kind in its own sub-model of `DMZ_Enemies` (Normal, Boss, Runner, ...). About 30% of the plain infected are a bit bigger (1.1-1.35x).
- Offers pop up above the weapon cards instead of on top of them. Repair and Cash Drop are always on screen during a run, bottom right under the weapons.
- Boss intro cutscene: framed by the boss's real size, and every camera angle is checked for a clear view (no more houses in the way). A boss's first special move waits until after its intro, so two cutscenes don't play back to back.
- New `GiantSteps` client script: heavy footsteps (Giant_Step + Giant_Impact) for bosses and the nearest brutes, one per stride; you hear them in the cutscenes.
- Welder sparks are real now: small neon cubes with trails that fall, bounce off the floor and cool from white to orange to red, plus slag drips and little cube smoke puffs.

## 0.7.3 — 2026-11-20

- Lobby: a nuke loading area behind the parked AC-130 (`Hangar.NukeLoading`). One nuke strapped to a yellow weapons trailer inside a chain barrier with a DANGER / LIVE NUCLEAR ORDNANCE sign, a second nuke on a loader lined up with the rear ramp, and pallets of 105mm shells, 40mm crates and 25mm cans. Placed clear of the plane, the Set props and the crew (checked part by part).

## 0.7.2 — 2026-11-20

- Fix: the hand-made animations (gunner sitting down / chair, survivors climbing onto and sitting on the helicopter benches, the welders) didn't play in the published game: `KeyframeSequenceProvider:RegisterKeyframeSequence` only works in Studio. Every clip is now also an uploaded Animation asset owned by the group, listed in `Convoy.AnimIds`; `AnimClips.animation` uses the uploaded id (and the nearest start point for the sit-down / bench-climb clips). Clips are exported from their specs (`art/anim/specs.json`) to .rbxmx by `tools/build_rbxmx.py`; re-run and re-upload when a clip changes.

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
