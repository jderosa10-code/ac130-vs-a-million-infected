# Changelog

Versions follow MAJOR.MINOR.PATCH. The current version is also in `VERSION` and on the `GameVersion` attribute of `ReplicatedStorage.Convoy` in the place.

## 0.13.51
- Weapon tiers hold more ammo and reload faster: every tier adds 25% to the magazine (at least +1 round; a Reaper's 4 Hellfires are 6 at tier 3 and 11 at tier 8), and the new rounds are loaded as soon as you buy the tier. Reload time per tier x0.86 (was x0.9). Hand-loaded guns (one round, then reload) stay one round. Applies to every aircraft's guns. `Weapons.publish` re-sends ammo after a change.
- REPAIR with a full bunker: no more buy sound and green flash for a repair that doesn't happen; it buzzes and says BUNKER IS ALREADY FULL.
- The red (hit) and green (repair) screen flashes are bigger than the screen, so they reach past the safe-area edges on notch phones.

## 0.13.50
- Music in a run. Three APM tracks play in turn under the guns (`Convoy.SoundsUI.BattleMusic1-3`: Mission Danger (underscore) 9045941477, Battleground 9048541013, Push To The Limit 131200017582350; volume 0.22, swap the SoundId to change one). Starts on a random track and fades in over 3 s when the HUD comes up, fades out on the debrief and back in the hangar (hub music takes over). Follows the MUSIC setting and SOUND VOLUME.
- `SFX.playlist(names)`: tracks in turn, faded as one; a pause resumes where it left off.

## 0.13.49
- Aircraft bay lighting: the stage spotlight's light cone (StageSpot beams) is back on and the spot is a bit softer (brightness 5 -> 4). The room is darker than the stage: wall panels, insets, wainscot, bands and side walls at half their colour, the four corner ceiling lights 3.2 -> 1.4 and the fill lights 1.6 -> 1.0.

## 0.13.48
- Aircraft bay: the edge vignette (Aircraft.Vignette / VignetteV) also darkened the middle of the screen over the plane; both removed. (The 0.13.47 extra key light is undone; lights are as before.)

## 0.13.46
- Aircraft bay on phones: the BACK / EQUIP / NEXT bar sat in the middle of the screen over the plane (a fixed 200 px offset). It now sits just above RETURN TO HANGAR at that button's fitted size (10 px gap on phones; PC looks the same as before). Done in GunshipUI's fitScreens.

## 0.13.45
- Old maps deleted for good. The terrain of the eight parked mission maps (z 3,900 to 29,500: hills, lake, valleys) is cleared to air; the hangar/airfield and downtown terrain is untouched.
- Removed from ServerStorage: OpsParked (the mission maps), AirbaseOld_v013, HangarOld_v013, OldExterior, OldBackdrop, CabinOld, BunkerZone_Removed, OceanRemoved, FarBuildings_Parked, ToolboxBuildings_Old, HangarBoards_Old, HangarProps_Old. No script used them. The mission code (Convoy.Missions, ConvoyServer.Ops) is still in the place but has no maps now.
- A stray part out in the old map area removed from Workspace.

## 0.13.44
- Rank objectives that ask for an infected type (SPITTER HUNT, BRUTE HUNT...) show that infected's portrait instead of the generic firepower icon. Portraits made in Gemini by Jacob, background cut out (art/infected/icons/cut.py), sheet image 121219509791332; Icons type_runner / type_brute / type_bomber / type_spitter / type_armored.

## 0.13.43
- Special infected use toolbox models now (picked by Jacob), cleaned (scripts, sounds, values, effects removed), rigged and sized in Studio. They live in ServerStorage.ConvoyTemplates.Types.<Type> (attributes Rig = R6/R15, RootHeight):
  - Bomber: soldier zombie with a bomb vest and welding mask (R15).
  - Brute: muscular hulk zombie (R6).
  - Armored: three riot-police zombies (R6, R6 rebuilt from loose parts, and an R15 built from a riot morph).
  - Spitter: irradiated zombie with a biohazard face (R6; old Motor joints rebuilt as Motor6Ds).
- Enemies.typeTemplate / Enemies.swapRig: applyType swaps the just-spawned rig for the type's model (same NetId and place; hitbox re-sized; R6 rigs run on the classic R6 walk, played fast). Runner has no model yet and keeps the Blender gear look (InfectedLook).

## 0.13.42
- The special infected are redressed with gear modelled in Blender (art/infected/InfectedGear.blend, uploaded as model 128181642246806; the MeshParts live in ServerStorage.InfectedGear) instead of plain blocks. New module ConvoyServer.InfectedLook (clothes palette per type + welded gear), called from Mission.applyType:
  - Runner: torn pink hoodie with the hood flopped back, exposed ribs, white sneakers.
  - Brute: muscle hump, swollen shoulders, huge fists, bone spurs down the back, broken shackles.
  - Bomber: vest, a row of dynamite with tape, a timer with red/blue wires and a blinking light, a gas tank on the back.
  - Spitter: glowing throat sac, acid drool, a swollen belly and blisters on the back, arm and head.
  - Armored: riot helmet with visor, chest armour, shoulder and shin guards, a riot shield on the left arm.

## 0.13.41
- Trucks on the roads outside drove in reverse (the models face their local +Z); turned round (OutsideLife).
- Hangar walkers no longer bunch into a group: each keeps its own place on the loop, and whoever fell behind (stopped to talk, queued, blocked by you) walks a bit faster until back in place (HangarWalkers).
- New: every 20-45 s a squad of 15 trainees runs down one of the service roads in step, three files, with a drill sergeant (campaign hat) beside them calling cadence and the squad answering. Trucks keep off that road while they run (OutsideLife formationRun; rigs cloned from the hangar walkers).
- Rank objectives: FIRE SUPPORT (artillery strikes) shows the howitzer instead of the A-10.

## 0.13.40
- Every aircraft's weapons are their own now:
  - Looks: AV-8B 25mm cannon gets its own pale-orange streaks (FXLib CAL "cannon"); the rest already had theirs (minigun, chain gun, rocket, missile, grenade, bomb).
  - Sounds (ConvoyAudio LOOK_SOUND, by the gun's look): miniguns a fast high buzz, the Apache's 30mm a slow heavy thump, Hydras a rocket launch, Hellfires a missile launch, CH-47 grenades a grenade-launcher thunk, MK-82s the bomb drop. New templates in Convoy.Sounds: Rocket_Launch (509177476), Missile_Launch (717392973), Grenade_Launch (124807383431117).
- Weapon pictures are now photos of each gun's ammo, built from parts and shot in Studio (art/ammo, make_sheet.py: black/white backdrop matte, light stroke; sheet image 108330527658903). One per weapon: 25mm, 40mm Bofors clip, 105mm shell, AV-8B 25mm belt, 7.62 belt, 30mm belt, Hydra rockets, Hellfire, MK-82s, 40mm grenades, B-52 bomb load, B61 nuke. Used on the HUD weapon slots, the armory and the rank objectives (Aircraft guns[g].icon; wpn_25mm/40mm/105mm/bombs point at the photos).

## 0.13.39
- Weapons look like what they are on every aircraft, not like the AC-130's shells: miniguns fire thin red streaks, the Apache's 30mm chain gun orange streaks, Hydra rockets and Hellfires a rocket body with a white smoke trail and flame, grenades short glowing slugs, bombs dark falling bombs (Aircraft guns[g].look -> Ballistics -> FXLib CAL / SHELL_LOOK).
- Results / fly-home screens: helicopter rotors spin (main and tail; the CH-47's two rotors turn opposite ways).
- The battle offer card (e.g. CASH DROP) sits above the top weapon card and follows it, so it no longer overlaps it.

## 0.13.38
- Overhead tag: the aircraft badge was a 45-degree diamond with the icon turned back -45, made for the old flat icons; with the in-game photos (already at a 3/4 angle) it looked crooked. Badge and icon are both level now (Convoy.OverheadTag.Root.Top.Badge).

## 0.13.37
- Aircraft screen: the grey haze down the middle was the stage spotlight's light cone (AircraftBay.StageSpot beams, in front of the plane); turned off. The lamp itself still lights the stage.
- Hangar walkers no longer walk into each other: one waits behind whoever is just ahead on the loop (e.g. a talker who stopped to talk).

## 0.13.36
- Daily drop reminders (ServerScriptService.DailyReminders): claiming the daily drop queues a Roblox notification for the next day ("Your daily supply drop is ready. Day {day} gems are waiting!", notification string 8ca2920a-c101-5d48-917b-fd34d9894941, made on the Creator Dashboard). Due at the next UTC day and at least 20 h after the claim; every running server sweeps the queue (OrderedDataStore DailyReminder_v1) every 2 minutes and sends through Open Cloud /cloud/v2/users/{id}/notifications. Only players who turned notifications on get it.
- HttpService.HttpEnabled turned on.
- STILL NEEDED (dashboard, by Jacob): an Open Cloud API key with user.user-notification:write for this experience, saved as an experience Secret named NotifyKey (domain apis.roblox.com). Until then the sweep logs "no NotifyKey secret" and sends nothing.

## 0.13.35
- After a run, PLAY AGAIN / LOBBY flew a second copy of your plane home while the results formation stayed put. The fly-home shot now moves the results formation itself (your plane in the lead, the crew on your wing); GunshipClient poseFleet.

## 0.13.34
Multiplayer lag:
- The server no longer moves the infected / civilian rigs (100+ roots, 20 times a second, sent to every client). Each rig has a NetId; the server moves an invisible hitbox per rig in a folder under its own Camera (not replicated) for rounds to hit, and sends packed positions (14 bytes a rig, ~12 a second, UnreliableRemoteEvent Remotes.EnemyPos). New LocalScript EnemyMover moves each client's copy of the rigs, walking them on from the last two positions. Mission's gun raycasts exclude the rigs (they hit the hitboxes).
- Rig templates (Infected, Civilians) are stripped at server start of instances nothing uses (ragdoll sockets, no-collision pairs, wrap targets, 69 size values, face controls, body colours): ~210 -> ~90 instances to send per spawn.
- Building destruction: chunks are thrown on each client (FX "debris") instead of being unanchored server parts, and between runs only the buildings that were hit are rebuilt (it used to delete and resend all ~7,800 parts).
- Shots, rounds, impacts and ricochets go on a new UnreliableRemoteEvent (Remotes.FXU), so a burst of them never holds up the rest.
- The plane showcase (_Showcase, ~3,400 parts) and a stray AC47 model at the map origin were still in Workspace; moved to ServerStorage.Parked_NotInGame.

Other:
- Weapon slots follow the aircraft: B-52 = 1 BOMB BAY, 2 B61 NUKES (keys 1 / 2, slots stacked from the bottom); every run starts on slot 1. Aircraft.gunOrder.
- The selected weapon slot's edge no longer gets thicker (colour only).
- Proximity prompts are sized in studs (3.6 wide), so they shrink when you zoom out; capped at 20% of the screen up close.
- Tutorial cleaned of removed things: the A-10 "Hawg flight" runs and their street cutscene are now artillery barrages; the fallback nuke no longer plays the cutscene; the first hint is the touch one on phones. The inert FreeNukes price override is gone.
- OverheadTags no longer errors on a tiny viewport.

## 0.13.33
Settings checked (music, volume, replay tutorial, leave match, close):
- Music toggle, volume -/+ (0-100%), close, LEAVE MATCH (ends the run, "CREW LEFT THE MATCH") and REPLAY TUTORIAL all work; music and volume reach the server to be saved.
- REPLAY TUTORIAL is hidden mid-run (it used to drop you on the hub screen with the run still going); LEAVE MATCH takes its place.
- Controls list is a 3-column grid with the keys in amber (spacing in one text line couldn't line up), plus G / SPACE start the wave; V is labelled NUKE ALL.
- Sounds a script makes without a SoundGroup (aircraft bay turntable) are put in the GunshipUI group, so SOUND VOLUME reaches them.
- New server script GunshipUICopyGuard: removes the disabled copy of StarterGui.GunshipUI that Roblox drops into PlayerGui on spawn, so scripts that WaitForChild("GunshipUI") can't grab the dead copy.

## 0.13.32
- Booth NPC name tags (SGT. HAYES, LT. REED) are sized in studs (5 x 1) instead of pixels, so they shrink with distance like the lobby signs instead of looking bigger as you back away.

## 0.13.31
Phone pass (tested in Studio's iPhone XR emulator, 801x413):
- Phones get a bigger UI scale (screen height / 1080 x 1.6 instead of ~0.44); fitScreens still shrinks only what collides. Minimum phone text is 14 pt.
- Hidden panels no longer take room from the visible ones, and a screen re-fits when a panel shows or hides (the aircraft screen's info panels were stuck at 0.37).
- Aircraft screen: arrows start at 0.62 of the scale on phones; info rows' label and value no longer overlap ("RANK NEEDED" / "BRIGADIER GENERAL").
- HUD on phones: the wave bar sits under the top bar (it was under the settings gear), bigger; bunker bar top-right; the tally is smaller; the abilities column stays in its touch spot (it was sliding back to the desktop one and shrinking).
- The settings gear (TopbarPlus) counts as part of Roblox's top-left buttons.
- Shop, daily drop and free reward panels sit below the top bar.
- Overhead tags: the template's fixed UIScale was overriding the distance scale (only one UIScale per frame works), so tags never shrank. Removed; tags are now ~6 studs wide, capped at 20% of the screen. Your own tag only shows on the hangar's main screen.
- Proximity prompts are scaled to the screen (they were popping to full size on phones).
- Device emulator in Studio always uses the touch layout.
- New photo icons for the B-52's bombs and nuke (rbxassetid://80028457490291; the old cells were empty).
- Studio only: the DebugShow player attribute opens a GunshipUI screen, for testing layouts.

## 0.13.30
- B-52:
  - its two B61 nukes are a weapon slot (B61 NUKES, 2 a load, hand-loaded, slow reload); the free-nuke ability is gone;
  - each nuke drops out of the bomber (keeps its speed, then noses over onto the target) and goes off with the full nuke effect (fireball, mushroom, shock ring), sized to its 85-stud radius;
  - main gun is now the BOMB BAY (12 bombs a load, falling-bomb sound, much less heat);
  - bombs/nuke icons on the HUD and the weapons screen.
- NUKE ALL: no cutscene any more; you watch the full blast from your plane.
- Hangar: aircraft other than the AC-130 are shrunk until they clear the hangar props (B-52 ~0.74, AC-47 ~0.92), and the welders stand down for them. Hidden models no longer block players.
- After a game, the menu/fly-home plane is the one you flew, not always the AC-130.
- Gem bar "+" opens the shop scrolled to the gems.
- Overhead tags keep the same size on screen at any zoom (like the lobby panels); proximity prompts sit at chest height.
- Hub side buttons no longer slide off screen after the free reward goes.

## 0.13.29
- Aircraft bay: the two stage spotlights hung in mid-air. They now have a yoke and a drop rod up to a ceiling plate (Lights.SpotMount).
- Aircraft bay back wall (the side with the door to the hangar) is dressed to match the far wall:
  - columns with hazard bands, panels, insets, wainscot, and the top band with its light strip (AircraftBay.WestWall);
  - a hazard-striped door frame with a light strip, a lit "HANGAR" sign over the door, and a hazard strip along the floor.

## 0.13.28
- TESTING: every aircraft is unlocked for anyone in Studio, the group owner, and user ids in the AllPlanesUsers attribute on ReplicatedStorage.Convoy (currently 4263620304). Remove before release if testers shouldn't keep them.
- Daily drop: REMIND ME button (left of the claim button) opens Roblox's notification opt-in prompt (ExperienceNotificationService:PromptOptIn). It only shows when the prompt is available. Sending the actual notifications is not set up yet.
- Hub side tiles: Shop / Invite / Daily are centred once the free reward tile is gone.
- Aircraft screen: the full-screen dim is removed; only the edges are darkened (Vignette + VignetteV).

## 0.13.27
- Weapons screen follows the equipped aircraft: only the guns it carries are listed, under that aircraft's names (e.g. AC-47 shows just 7.62 MINIGUNS).
- Air support (155mm artillery) card removed from the weapons screen, so it can no longer be upgraded.
- The gun callout cards only show for the AC-130 (they point at its guns).

## 0.13.26
- Aircraft icons are now photos of the in-game models with a light stroke (new sheet rbxassetid://130111932978781; Icons ac_* entries point at it).
- New 40mm Bofors and 105mm M102 icons on the same sheet (wpn_40mm, wpn_105mm).

## 0.13.25
- Ride out plays at 0.65 speed (Lobbies.RIDE_LEN 11.3 s). New jump: wind-up crouch with arms back, then the left arm throws up to the skid.
- After the ride the rider is put back on the pad and the loading screen stays up until the teleport (or 1.5 s after the mission starts in Studio).
- Leaving a match from Settings skips the bunker-lost cutscene.
- Overhead tags are sized in studs (BillboardGui scale size) so they shrink when you zoom out.
- Proximity prompt cards are offset toward the camera so the NPC doesn't cover them.

## 0.13.24
- Ride out:
  - Cinema bars top and bottom.
  - Each rider's camera sits behind their own character: it chases them while they run and jump, then sits behind and below while they hang, looking up past them at the heli.
  - Hang pose (R6 joints): left hand on the skid with the body hanging under it, right arm loose, legs dangling and swaying, a pendulum swing after the catch.
  - The normal Animate tracks are stopped during the ride, because hanging in the air played the fall animation.
  - Flight: a little bob in the hover, then it tips back 20 degrees and pulls up and away, picking up speed, with a slight yaw and bank.

## 0.13.23
- Ride out reworked:
  - It opens with a hard cut to black (0.35 s), then the heli lifts and backs away while the crew run in one after another, jump and grab the skids.
  - It then climbs up and back, nose a little high.
  - The grab is a joint animation (shoulders and hips, R6 or R15): running, a crouch-and-leap with the arms reaching up, then hanging with the legs kicking and swinging after the catch.
  - The joints are re-found if the avatar is rebuilt.
- PadHUD's lobby setup panel stays closed during the ride.

## 0.13.22
- Ride out: when a pad's countdown ends, the crew (up to 4) run in and grab the Huey's skids (2 per skid, arms up). The helicopter lifts, turns away, noses down and flies off, then the screen fades to "Loading..." and they're deployed.
  - Server (Lobbies.startRide) anchors the riders, sets player RideHeli/RideSlot and pad RideAt, and deploys after 7.3 s.
  - Client (PadHelis) flies the heli and its rotors, places the riders, runs the camera, hides the UI and name tags, and shows the fade.
  - Other players in the lobby see it too.
  - The heli comes back 12 s later. A failed launch (or Studio) puts everyone back on the ground.
- PadHUD skips the pad clamp and its panel while riding.

## 0.13.21
- B-52: FinBridge fills the gap between the dorsal fillet and the tail fin.
- NPC lines use Roblox's own chat bubbles (TextChatService:DisplayBubble) instead of the custom SpeechBubble.
- Overhead player tags shrink with camera distance (UIScale on Root, full size at 16 studs) instead of staying the same size on screen.
- Robux symbol fixed everywhere: the new RobuxGlyph script switches U+E002 to Builder Sans, because Oswald has no Robux glyph.
- Old hub shop panel hidden in the StarterGui template and kept hidden.
- Settings > LEAVE MATCH (mid-run only): every gunner has to vote (LeaveVote action; Shared LeaveVotes "n/m"), then the run ends with reason CREW LEFT THE MATCH. Solo ends it straight away; pressing again cancels your vote.
- AH-64: removed the stray canopy frame bars across the cockpit.

## 0.13.20
- Aircraft screen: the old List / Center / Detail panels are now hidden in the StarterGui template too, not only by AircraftUI at runtime.
- New ServerStorage.GunKit (edit-time builder). It makes miniguns with spade grips, pintle mounts with yokes, ammo feeds, and the hull Weld pattern as a scalable Texture (rbxassetid://116225523969641, captured from the built-in surface).
- Chinook: door miniguns on pintle mounts, a chin turret with a grenade launcher, and rocket pods hung on pylons with sway braces.
- AC-47 (3 guns) and UH-1: miniguns rebuilt on pintle mounts. The black gun-port panels and frames are gone; the doors now match the hull.
- AH-64: new chin turret (fairing, ring, yoke, receiver, shroud, barrel, ammo chute).
- Guns, missiles, bombs, pods and the B-52 nukes now carry the Weld texture, scaled to each face.

## 0.13.19
- B-52: carries 2 nukes as its normal load (Aircraft.freeNukes; player attribute FreeNukes). The NUKE ability is free while any are left and the card shows FREE xN.
- B-52 model: new open bomb bay. The belly is cut open with a dark lined bay, ribs, red bay lights and a rack, and two scaled nukes hang in tandem. Hinged doors swing open with hazard-yellow edges and ribs.
- AC-130: Models.AC130 and the airfield ParkedAC130 replaced with the lobby's ParkedGunship (with GunDetail guns). The old parts model was deleted.

## 0.13.18
- Artillery lowered onto the floor (wheels, trails, pallet and crates were 1 stud up); charge crates moved off the trail.
- A-10 crate stack moved out of the north wall to open floor; ammo loader drum seated on its base.
- Mailbox: studs are now a texture copied from Roblox's own Studs surface (rbxassetid://77665526481438), tinted per part, at half scale (StudsPerTile 0.5).

## 0.13.17 — 2026-11-22

The outside.
- Hangar exterior (`Hangar.Exterior`): olive cladding with dark ribs every 16 studs, dark base band with a hazard stripe, tan fascia, a row of lit clerestory windows down both long sides, a pitched roof with gables, ridge, roof vents and blinking red corner beacons, and a big lit HANGAR 07 // GUNSHIP WING sign over the door.
- Heli pads (`Airfield.HeliPads`): one raised pad per lobby heli: hazard border, painted yellow circle and white H, number, blinking blue edge lights. The old painted lines and numbers are gone; the helis sit on the pads.
- Service roads north and south of the base (`Airfield.Roads`) with lane lines and street lamps; cargo, fuel and gun trucks drive them both ways (`OutsideLife`, templates in `Convoy.RoadVehicles`).
- Flyovers (`OutsideLife`): every 10-25 s an aircraft crosses the sky (AC-130, A-10, F-15, B-52, CH-47, UH-1, AH-64, AC-47) at its own height and speed, with smoke trails and engine sound; one in five limps by on fire trailing black smoke.
- Blinking beacons and pad lights (any part with a Blink attribute).
- Officers' Mess: the three brass were sunk into their chairs; now seated on top (placed by the root part, not the model's box centre); chairs moved back so their feet stop at the table edge. The walkers' Studio start spots were half under the floor; fixed.

## 0.13.16 — 2026-11-22

A livelier hangar.
- Overhead tags on every player (template `Convoy.OverheadTag`, `OverheadTags` client): the aircraft they fly in a yellow diamond + name, their rank badge + rank number (tier colour), a trophy + best wave. Roblox's own name tag is off.
- Officers' Mess: deck with hazard edge, trestle table with mugs (steam), a map and papers, four chairs, coffee cart with a machine, hanging lamp, OFFICERS' MESS sign; three brass sit at it (Col. Hart, Maj. Brooks, Gen. Vance) near the leaderboards.
- Speech bubbles (`Convoy.SpeechBubble`, `NPCChatter`): the brass run little conversations, crew/staff/booth soldiers say a line now and then while you're close. `_G.NPCSay(model, text, secs)` for other scripts.
- Walkers (`Hangar.Walkers`, `HangarWalkers`): Gen. Sterling, General of the Air Force (five stars) and three soldiers walk a loop round the hangar and wait if you stand in their way. The general's prompt: "Favorite the game" (Roblox favorite prompt), or "Join event" while `Convoy.EventOn` + `EventName` are set (sends you to the lobby pads). Soldiers: "Talk" - they stop, face you and say something silly.
- Mailbox by the artillery corner (Jacob's own model, stud texture on every face; the built one is in ServerStorage.OldUI): "Send feedback" opens Roblox's feedback window (`SocialService:PromptFeedbackSubmissionAsync`).
- FREE REWARD (hub tile FREE, `FreeRewardUI`): like + favorite + join the group, then CLAIM for 250 gems once; the server checks the group (`Mission` "ClaimFree", saved as `FreeClaimed`). Tile hides once claimed.

## 0.13.15 — 2026-11-22

Daily supply drop, results screen restyle.
- Daily login reward: 25 / 40 / 60 / 80 / 100 / 150 / 300 gems for days 1-7 in a row (`Shop.DAILY`). Miss a day and it starts again at day 1; after day 7 it goes round. Server checks it once per UTC day (`Mission` "ClaimDaily"), saved on the profile (`Daily = {last, streak}`). Panel is real UI (StarterGui.DailyUI): seven day cards, today's in yellow, claimed ones checked, streak line, slanted yellow CLAIM. Opens by itself in the hangar when a drop is waiting; a DAILY tile on the hub (red ! when ready) opens it too.
- Results screen: pale headline with a tilted red reason tag, flat stat cards with hazard strips and icons, yellow NEW BEST tags, yellow PLAY AGAIN, dark LOBBY.

## 0.13.14 — 2026-11-22

Weapons, Ranks and the in-run HUD in the new style.
- Weapons: flat dark cards with the new weapon pictures (25mm, 40mm, 105mm, 155mm); the picked gun gets a yellow edge and strip. Upgrade tabs turn yellow when picked; the big button is yellow when you can afford it, dark when you can't. Gem counter matches the hub. Mono fonts swapped for Oswald.
- Ranks: objective cards show a picture for what they ask (gun, timer, skull, crew, A-10...), yellow class and progress bar, green when done; yellow SKIP; spaced yellow headings; next-rank and reward rows on dark strips.
- HUD: flat dark panels with hazard strips (wave, tally, cash), yellow START, ability cards with icons (repair, nuke, artillery) and yellow key tags, weapon cards wider with the gun picture; the gun in hand gets a yellow edge, strip and key.
- Aircraft / Ranks / Weapons gem counters match the hub's.

## 0.13.13 — 2026-11-22

New icon set (48 Gemini icons in three 1024 sheets; `Convoy.Icons` updated, old shop-tab/gem-pack icons kept).
- Hub: crate (shop), helmets (invite), AC-130 top view on AIRCRAFT. Shop: real icons for VIP, 2x gems/cash, head start, both bundles, and a gift crate on every GIFT button and the gift toast.
- Aircraft screen: the selected aircraft's own picture beside its name (all 8), stat icons, length/wingspan/rotor/lock rows.
- Lobby: shield/skull mode icons, globe/handshake access, exit icon on LEAVE.
- Also in the set for later: weapons (25/40/105/155mm), A-10, nuke, repair, missile, trophy, daily, skip, crew, map, timer, dog tags.

## 0.13.12 — 2026-11-22

Step-on pads, settings in the top bar, hangar fixes.
- Settings: a gear icon in Roblox's top bar (TopbarPlus v3.5, ReplicatedStorage.TopbarPlus; `TopbarIcons` client). There all the time: in the hangar it opens the Settings screen, anywhere else (a run included) the panel opens on top of what you're doing. The SETTINGS tile on the hub is gone.
- No more E prompts at the booths or the aircraft-bay desk: step onto the glowing half-ring pad and the screen opens (`StepPads` client; pads are parts named RingAnchor with Screen/Radius attributes). New pads in front of the desk's AIRCRAFT and WEAPONS consoles. Step off and back on to open again.
- Lobby pads: once you're in a crew you can't walk off the pad; press LEAVE (`PadHUD`).
- Tug + bomb trolley: new loop round the parked gunship, clear of the lobby pads, booths and A-10 corner (it used to stop on a pad).
- Pilots were half under the floor: lifted.
- Shop: tags sit inside the card, descriptions shrink to fit instead of being cut off.
- Gem counter: smaller box, gem badge over the left edge, big number, yellow GEMS caption and a small yellow +. Hub SHOP / INVITE tiles bigger.

## 0.13.11 — 2026-11-22

New UI style (flat military, after Tiny Skies' look; our own layout).
- Flat dark olive panels with a yellow/black hazard strip on top, thin lines instead of thick glowing edges, no outlines on text, bright yellow for whatever is active or buyable, spaced-out yellow sub-headings. New assets: hazard tile and a slanted button image (filled + outline halves).
- Hub: same layout as before, restyled: gems top-centre, player card top-left (avatar, name, rank tag, rank + tier, objective bars), SHOP / INVITE / SETTINGS tiles on the left, slanted AIRCRAFT | PLAY (yellow, arrows nudge) | RANKS (your badge) at the bottom.
- Shop: yellow price buttons and active tab, red tilted tags, flat cards. Create Lobby: slanted yellow CREATE, yellow crew-size pick. Crew bar: yellow LAUNCH NOW.
- Aircraft screen: name block straight on the scene (yellow role, big name), dark strips for size/rank/price, AIRCRAFT SPECIFICATIONS panel with thin yellow bars, action button yellow when it can buy/equip.
- Armory / Ranks / Settings recoloured to the same palette (glows and text outlines removed).
- Booth floor rings: dashed neon bars, each with a soft blurred glow (decal on an invisible part, no hard outline), over a see-through yellow neon floor; the light curtain beam is off.

## 0.13.10 — 2026-11-22

Real UI and new icons.
- The shop, the lobby-pad screens and the aircraft control bar are real UI in StarterGui now (ShopUI, GiftToast, PadHUD, PadSetup, GunshipUI.Aircraft.Controls/Info/Specs/Vignette), editable in Studio. ShopUI, PadHUD and AircraftUI only find them and run them (shop cards carry a `Key` attribute; the gift list copies `RowTemplate`).
- New icon art (made in Gemini, cut out, packed into two 1024 sheets): `Convoy.Icons` with `Icons.set(image, name)`. Used on the hub tiles (shop, invite, settings), shop tabs, gem packs, the aircraft stats and size rows, and the lobby mode/access buttons.

## 0.13.9 — 2026-11-22

Loading screen, hub fixes, aircraft info on screen.
- Loading screen (`ReplicatedFirst.LoadingScreen`): black with "Loading..." (dots 1-3) on join until your profile is in, and carried across every teleport (TeleportGui), shown as soon as a teleport starts.
- Hub: RANKS takes you to the ranks booth, AIRCRAFT to the aircraft bay desk (quick fade), then opens the screen. Rank card bigger and no longer cut off (the button sits inside it so the fit code doesn't move it). Bottom-bar art no longer clipped; idle bob fixed (was erroring).
- Create Lobby panel bigger.
- Aircraft screen: the plane's info is on screen again (left: name, role, description, real length and wingspan/rotor, rank, price; right: performance bars and weapons). Hanging bay screens removed. Vignette much lighter; bay lamps brighter plus warm fill lights.
- Aircraft bay swap: no more wrong plane rolling in first (screen/selection changes are settled before a swap, and a newer pick replaces the one waiting).
- Lobby helis: new turbine start, rotor loop that speeds up with the blades, and a wind-down sound; heard from further away.
- Dust in the lamp light now drifts.
- New soldiers wear the crew's patrol cap, recoloured (officer, general with a gold badge, pilot, crew chief).

## 0.13.8 — 2026-11-22

New hub HUD, booth fixes, officers, dust.
- New hub screen (Menu): gem bar top-centre; rank card top-left (badge, rank name in its tier colour, three objective segments, click opens Ranks); left column SHOP / INVITE (game invite) / SETTINGS with our own icons; bottom bar AIRCRAFT | PLAY | RANKS with floating art (plane, your badge). WEAPONS left the hub (it's at the aircraft bay desk). Old title block hidden. Rank card is filled by `LobbyHUD` (client).
- PLAY now fades and stands you in front of the four lobby pads instead of the old play menu. Before the first weapon upgrade it opens Weapons instead.
- Rank badges redrawn: bronze (RCT-CPL), silver (SGT-SGM), gold with wings (2LT-MAJ), platinum with wings (LTC-COL), onyx with spikes (BG-GEN). Tiers in `Ranks` (`R.tier`, `R.TIERS`, `R.TIER_COLOR`). The ranks booth board shows a badge strip.
- Booths: one continuous half-circle light curtain (no black centre), bigger and closer to the counter; floor tape cut round the decks; rebuilt posts/roof so nothing floats or z-fights; flag and lamps attached.
- New R6 soldiers with their own uniforms: Officer, General, Pilot, Crew Chief (`Convoy.Models`), placed round the hangar; LT. REED at the ranks booth is an officer now.
- Slow floating dust in the lamp light cones.

## 0.13.7 — 2026-11-22

Booths, a better aircraft bay, real UI glow.
- SHOP and RANKS booths flank the walk from the spawn to the gunship: deck, corrugated olive back wall and canopy with a hazard-striped edge, multi-piece steel posts, an ammo-crate counter with a glowing edge, a hanging amber sign whose text scrolls, a hanging lamp, props (gem crate, supply shelves / rank board, flag, medal), an R6 soldier behind the counter (SGT. HAYES / LT. REED) who idles and turns his head to you, and a breathing amber floor ring with a short light curtain. Walk into the ring: our prompt opens the Shop or Ranks (`Booths`, client). Ground crew walk a tighter loop round the gunship so they stay clear.
- Aircraft bay, rebuilt as a show (`AircraftBay`): a turntable in the stage slowly turns the parked plane; on a change it swings back to straight, roll-up shutter doors open with a motor sound, alarm and spinning amber beacons, the old plane pulls away and squats as it accelerates while the new one rolls in, brakes (nose dips, rocks, settles) with rail-joint bob and sway, then the doors roll down and the turntable starts again. A spotlight hangs over the stage with a visible cone; the camera follows the plane a little.
- Plane info moved into the world: two hanging screens in the bay show name, role, rank, price, stats and weapons (big type). On screen only a small bar (BACK / EQUIP-BUY / NEXT, also A / D), RETURN TO HANGAR, and a dark vignette round the edges. The camera cuts into the bay instead of gliding through the wall.
- Bay doorway: overlapping header/jamb parts removed (no more z-fighting), new sign in Sarpanch on brackets clear of the pillar.
- UI glow is real now (`UIShadow`) on the shop, the pad screens, the prompts and the bay controls; shop/pad colours made military (olive drab buttons, tan type, amber edges, muted red close).

## 0.13.6 — 2026-11-22

Shop rework, light beams, R6.
- New shop screen (`ShopUI`, replaces the old shop panel): tab rail FEATURED / BUNDLES / GEMS / PASSES beside one scrolling page; the tab lights up for the section you've scrolled to and clicking a tab scrolls there. Cards use the store icons, live Robux prices, a tag ribbon (BEST VALUE, POPULAR, ...), OWNED for passes you have, glowing green price buttons, a red glowing X, a gem counter in the header.
- GIFT button beside every price: pick someone in the server, then buy the gift for them. The server (`Mission`) sends it (gems, or a pass saved on their profile); if they've left it waits in `GunshipGifts_v1` for their next join. Both get a toast. Gift product ids are 0 (SOON) until the products are made.
- BUNDLES: Starter (1,000 gems + Head Start, one time) and Gunship (4,000 gems + 2x Gems). Passes from bundles/gifts are saved on the profile (`ProfilePasses`). Product ids are 0 (SOON) until made.
- Roof lamps in the hangar and aircraft bay: warm light-cone beams off all four edges of each lamp, short, soft warm tint.
- R6: the 8 ground crew and 3 welders rebuilt as R6 (same uniforms, vests, helmets, torches); old R15 copies in `ServerStorage.HangarOld_v013`. Crew use the classic R6 walk/idle/point; welders raise their arms on the shoulder joints. Players are R6 (set in Game Settings). Enemies unchanged.

## 0.13.5 — 2026-11-22

Walkable hangar lobby, step 4 (aircraft bay).
- A 24-tall doorway in the hangar's east wall (hazard-striped jambs and header, AIRCRAFT BAY sign) opens into a new aircraft bay: multi-piece pillars, panelled walls with an amber glow band, a raised display stage with a glowing edge, a track with glowing rails running through big doors on the left and right into dark tunnels, ceiling lamps and two stage spots, an AIRCRAFT BAY sign on the back wall.
- A glowing railing keeps you off the stage. At the railing, a control desk with two consoles: AIRCRAFT and WEAPONS. Walking up shows our own prompt (key box + small label + big action word on a dark plate with a pulsing amber edge, `PromptStyle`, used by any prompt set to Custom style); using it opens the Aircraft or Weapons screen.
- The plane on the stage is the one you fly, or the one picked on the Aircraft screen (`AircraftBay`, client): when the pick changes, the old plane rolls off on the track through the right-hand door while the new one rolls in from the left. Planes are scaled to fit the stage.
- Aircraft screen: BACK / NEXT arrows either side of the plane name step through the list; the camera now looks at the bay stage (old outside hangar row is gone). Weapons opened from the bay desk keeps the bay camera.
- Hangar screens can be opened from other client scripts (`GunshipUI.OpenScreen`).

## 0.13.4 — 2026-11-21

Walkable hangar lobby, step 3 (leaderboard wall) + a smaller hangar.
- Hangar shrunk about 22% each way (now ~260 x 200 inside, door end fixed): walls, pillars, roof trusses (diagonals rebuilt end to end), lamps, curb, floor tape and the door frame all squashed together; the gunship, welders, crew, tug and nuke cart moved with it; trucks, A-10, spawn, pads and camera points moved to match. Curb and tape blocks resized so the black/yellow pieces don't overlap. Pads now 25 apart; the four Hueys and their LZ slots moved to line up. Terrain round the old footprint set back to grass.
- Leaderboard wall on the south wall: two small glowing boards, HIGHEST WAVE (amber) and MOST KILLS (red), each with ALL TIME / WEEKLY / DAILY tabs, ranks 1-100 in a scrolling list with big text, gold/silver/bronze for the top 3, your own row lit up, a reset countdown on weekly/daily, and tabs that flip by themselves when nobody's using them (`LeaderWall`, client).
- Daily/weekly stats: each player's best wave and kills for the current UTC day and Monday-start week ride in the profile (`Periods`) and go to their own ordered stores (`GunshipWaveD_<day>`, `GunshipKillsW_<week>`, ...). Boards fetch 100 entries with names looked up in one batch, and refresh every 2 minutes.
- The on-screen TOP GUNNERS panel and the hub key-hint line are gone (panel kept in `ServerStorage.OldUI`).

## 0.13.3 — 2026-11-21

- Walking onto an empty lobby pad now opens its own CREATE LOBBY panel instead of the old crew screen: map card (DOWNTOWN), MODE dropdown (Normal / Hardcore, locked until the unlock wave), ACCESS (public / friends only), CREW SIZE 1-4, glowing CREATE and red X. You stand still while it's open; the camera stays on you.
- Crew size is real: the pad shows n/size, it's full (amber, 5 s launch) at that size, and nobody else can step in past it.
- Pad crews never open the old crew screen.

## 0.13.2 — 2026-11-21

Walkable hangar lobby, step 2 (lobby pads + new airfield).
- Four lobby pads in the hangar door: a dark plate, a neon green rim and a beam light curtain that fades upward, with a CREATE LOBBY sign. Walk onto an empty pad and the crew screen opens (mode, access, CREATE). After CREATE you're back on foot, the pad shows HOST'S CREW n/4 and a 15 s countdown, and anyone who walks onto it joins; stepping off leaves. A full crew launches in 5 s. The pad turns amber when it's full or friends-only.
- Crew bar while you stand in a pad (`PadHUD`): crew name, count, mode/access, countdown, LEAVE and (host) LAUNCH NOW.
- Behind each pad a Huey parked on its own numbered slot. When a crew forms on that pad it beeps twice, plays the turbine start, settles into idle and the main and tail rotors spool up (`PadHelis`, client only); it winds down when the pad empties.
- Pad logic lives in `Lobbies` (create/join/leave on the existing party system, `PadReady`/`PadLeave` remote calls).
- Outside rebuilt: the old airbase (aircraft row hangars, parked planes, buildings, road ring, lights, helipads) moved to `ServerStorage.AirbaseOld_v013`, `AirbaseLife` disabled. New airfield: concrete apron with joints and grime, the helicopter line, T-wall blast walls with hazard bands framing the apron, four light masts, a taxiway out to a new runway (centre line, piano keys, edge lights), a control tower, a windsock, a parked AC-130 on a side ramp and drum/crate clutter. Terrain under paving set to Ground so grass doesn't poke through.
- Spawn moved to face the pads. The on-foot controls toggle no longer yields in the render step.

## 0.13.1 — 2026-11-21

Walkable hangar lobby, step 1 (the shell).
- You spawn in the hangar as your avatar (`CharacterAutoLoads` on, `LobbySpawn` inside the door, walk speed 22) and walk around it with the normal follow camera. Opening the lobby/aircraft/armory screens or going into a run takes the camera back and parks your controls (`GunshipClient`).
- Hangar rebuilt at player scale: multi-piece pillars (plinth, three stacked shaft blocks with collars, hazard foot, capital, upper post, knee brace, lamp), wall bays with olive wainscot, studded tan panels with raised insets, a steel band with an amber neon strip and louvres above, two pipes along each wall; roof trusses and purlins with 20 hanging high-bay lamps; amber/black hazard curb round the walls; a generated grime overlay on the floor (asset 139306833765196, two offset layers).
- The big door is roped off (bollards, chain, invisible wall): the airfield is for looking at. The cargo truck is parked in the south-west corner instead of driving out of the door.
- Old wall dressing, decor, light rig, flag and loose set pieces moved to `ServerStorage.HangarOld_v013` (nothing deleted).

## 0.13.0 — 2026-11-21

Back to waves only: MISSIONS mode parked.
- The mission picker is gone from the crew lobby (`MissionsUI` disabled) and the second map card is hidden; DOWNTOWN endless waves is the game.
- `Lobbies.cleanMode` only accepts Normal / Hardcore.
- The eight mission maps (Convoy, Hospital, Crew, Supply, Prison, Train, Bridge, VIP) moved out of the world into `ServerStorage.OpsParked` — nothing deleted. `Convoy.Missions`, `ConvoyServer.Ops` and `Mission.runOp` stay in the place unused, so the missions (or pieces of them as wave events) can come back.

## 0.12.8 — 2026-11-21

VIP EXTRACT mission (playable).
- A Huey drops a four-man squad in a city park. They walk through the streets to the embassy (anything in the street ahead pins them), go in for 25 s, come back out with the VIP (dark suit) and walk him back to the park; the Huey is called in on the way back, lands, everyone boards and it lifts off. Infected come out of the side streets, mostly ahead of the squad. SQUAD 170 HP, reward 400, about 5-6 minutes.
- Map `workspace.Ops.VIP` (centre 800, 27600): a full grid city (8 x 5 streets, ~240 buildings, some with blown-out tops; kept low along the squad's route so the streets read from the gunship), a park with paths, a fountain, trees and an LZ panel with green smoke, a walled embassy (columned portico, steps, flag, blown gate, burnt SUV, planters, guard booth, sandbag walls), burnt cars on the side streets, trees round the city, mountains all round.

## 0.12.7 — 2026-11-21

BRIDGE DEMO mission (playable).
- Four army engineers walk out onto an arch bridge over a gorge and plant a charge on each of its three piers (12 s each; any infected within 18 studs of the charge stops the work). Then they run back to the army line, the charges go off one after another, the two middle spans and the centre pier drop into the gorge and everything on them dies. The horde comes across the bridge from the town on the far side and round the flanks on the near side. ENGINEERS 170 HP, reward 350, about 4-5 minutes. The bridge is put back after the mission.
- Map `workspace.Ops.Bridge` (centre 800, 24600): a deep stepped rock gorge with a river, a concrete bridge on three piers with twin red steel arches, an army line on the near rim (sandbag walls, Jersey chicane, tents, Humvees, trucks, ambulance, cable drums and the detonator, watchtower, mast, flag), a ruined town on the far side (two rows of 2-7 storey buildings, some with blown-out tops, cross streets, burnt wrecks), ~500 trees, mountains all round with the gorge cut through them, and the road running into tunnels at both ends.

## 0.12.6 — 2026-11-21

TRAIN RUN mission (playable); Prison Bus bridge fixed.
- TRAIN RUN: an armoured train (locomotive, two gun flatcars, two refugee coaches) runs from a station through a town, a rock cutting and over a river girder bridge to an army railhead. It can't steer: anything on the line ahead stops it. Every 40-50 s a horde drags wrecks onto the line ahead (PILE-UP); the train stops short of it until the horde on it is dead. TRAIN 220 HP, reward 350, about 4-5 minutes.
- Map `workspace.Ops.Train` (centre 800, 21600): the line runs out of a tunnel in the west mountains and into one in the east; station with platforms, canopy, station house and an old train on the siding, yard with water tower, signal box and signals, a town on both sides of the line with a level crossing (gates, stalled cars), a ridge with a stepped rock cutting, a river with a girder bridge, the railhead (platform, buffer stop, sandbag lines, tents, Humvees, trucks, ambulance, mast), ~700 trees, mountains all round with the river cut through them.
- New props `MapProps.Loco`, `GunCar`, `Coach`.
- Fixes: level crossing moved off the bend onto a straight and rebuilt flush with the rails (panels between the rails, barrier booms, crossbucks); houses, trees and power poles that stood on or over the line, the bridge and the railhead pad removed; the track bed no longer dams the river under the girder bridge and the track there is laid cleanly up to each abutment; ballast and the railhead pad are thick enough that grass doesn't grow through them; the railhead platform moved alongside the line instead of onto it.
- PRISON BUS: the river bridge now spans just the river, on abutments at each bank, with the road running up to it and the truss properly joined.

## 0.12.5 — 2026-11-21

PRISON BUS mission (playable) and mission lengths.
- PRISON BUS: survivors come out of the cell block in three groups (13 in all, orange jumpsuits) and run across the yard to the prison bus; infected that catch a runner kill it (-12 BUS). Then the bus drives out of the gate, through a small town and over a steel truss bridge to an army checkpoint. Anything in the road stops it; infected that reach it hurt it. BUS 180 HP, reward 350, about 3-4 minutes.
- Map `workspace.Ops.Prison` (centre 800, 18400): walled prison (razor wire, four guard towers with searchlights, gatehouse, three-storey cell block with a blown door, admin block, mess hall, court, floodlights, guard cars outside), country road with power poles, a main street of shops with sidewalks and street lamps, water tower, wrecks and a bus on its side, a river through the valley with a truss bridge, the checkpoint (sandbag walls, Jersey chicane, boom gate, booth, tower, tents, Humvees, truck). Mountains all the way round, the river cut through them.
- New prop `MapProps.PrisonBus` (barred windows, light bar).
- Mission list and mission description show roughly how long each mission takes.

## 0.12.4 — 2026-11-21

SUPPLY DROP mission (playable) and crew results screen.
- SUPPLY DROP: a cargo plane makes three passes over a port and drops 10 crates on parachutes into six drop zones. The infected go for the crates and drag them toward the edge of the map (a pack drags faster); a crate dragged too far is lost (-22 SUPPLIES). Two army trucks drive out along the roads to each landed crate, load it only when nothing is standing on it, and bring it back to the supply base. Win when every crate is home or lost. SUPPLIES 160 HP, reward 350.
- Trucks drive like vehicles: limited turn rate, easing speed, slow through corners, keep to the right-hand lane, keep a gap behind each other and give way, and park in their bays without snapping round.
- Map `workspace.Ops.Supply` (centre 800, 15040): port on an enclosed bay with mountains all the way round; army supply base (Jersey perimeter, sandbagged gate, camo-netted supply pile, tents, comms mast, generator), quay with bollards, two gantry cranes, a moored container ship, container yards, three warehouses with docks and forklifts, a tank farm with a pipe rack, a truck park with semis, a rail yard with freight cars, street lamps. The main road, the north road and both railway lines run into concrete tunnel portals in the mountains.
- Results screen: the backdrop now flies the aircraft you actually flew; in a crew, every gunner's aircraft (up to four) flies in formation, yours in the lead.
- Studio test hook `DebugKillAll` (Studio only).

## 0.12.3 — 2026-11-21

DOWNED CREW mission (playable).
- A helicopter is down in farm country. Its four crew walk ~1.1 km from the wreck to an LZ held by a QRF: through pine woods, past a farm, over a creek footbridge and across a crossroads hamlet. Anything on the trail ahead pins them (they stop until you clear it); infected that reach them hurt the CREW (160 HP). Near the end the rescue bird is called in; it lands at the LZ, the crew runs to it and it lifts off. Reward 350 gems.
- Map `workspace.Ops.Crew` (centre 800, 12200): grass valley ringed by mountains, creek, crashed Huey (snapped tail, bent blades, fire and smoke, scorched furrow), ~600 stud-style pines and leafy trees, farm (barn, silo, farmhouse, tractor, crop field, hay bales, fences), country road with power poles and abandoned cars, abandoned army checkpoint with a pallet tower and a burnt truck, gas stop, church, houses, water tower, LZ with marker panel, cones, green smoke, Humvees and a truck.
- Night missions keep enough ambient light that the thermal picture still reads (was nearly black).
- Creek footbridge rebuilt so it actually spans the creek (it ran along it), with a slight hump, rails and ramps onto the banks.
- Fixed a Lua syntax error introduced with the hospital roof-guard fix in 0.12.2 (it stopped the server scripts loading).

## 0.12.2 — 2026-11-21

HOSPITAL EVAC mission (playable) and our own map props.
- HOSPITAL EVAC: a helicopter lands on the hospital roof, four operators run into the stairwell, it pulls out; after ~38 s they come back up with survivors and it returns for them. Three trips. Infected pour out of the city streets and climb the walls onto the roof; reaching the pad hurts the ROOF (200 HP). Reward 400 gems.
- Map `workspace.Ops.Hospital`: 6-floor hospital with helipad and roof sandbag nests, a plaza with field-hospital tents, parking lots, Jersey-barrier perimeter with sandbagged gates, a full city of blocks and side streets, and a mountain ring at the edges.
- `OpClient` draws the helicopter on each client from the server's `OpHeli` marker (smoothed, rotors turning), outlines the operators/survivors, and gives the hospital a light thermal outline so the roof reads from the gunship.
- New props in `ServerStorage.MapProps`, built in the lobby-truck style (Plastic, Studs tops, Weld/Universal/Inlet sides): Sedan, Pickup, Police, Ambulance, Humvee (turret), military Truck (the lobby cargo truck), Jersey barrier with a sloped profile, stacked sandbag wall. All toolbox cars and barriers in both mission maps were swapped for these and spaced out; roadside wrecks are burnt and sit crooked.
- Roof sandbag nests moved to clear spots (no longer through the AC units / pad / mast) and the roof guards stand in them; any map prop clipping into something was snapped to the ground or nudged clear.
- Field-hospital tents rebuilt with peaked roofs, poles, guy lines and roof crosses.

## 0.12.1 — 2026-11-21

CONVOY OUT map rebuilt, about 3x longer (4.5 km of road, roughly 5-6 minutes if never stopped).
- Sand terrain (dunes, rock outcrops) instead of block wedges; the road sits on a gravel bed so the sand never covers it.
- Seven stretches: city outskirts (ruined apartments, shops, hotels, a Hesco gate), gas station, overpass with a collapsed ramp, billboard and an abandoned roadblock, a low red-rock canyon (rockfalls, burnt tanker; kept low so the gunship can see into it), an adobe village with a minaret and palms, a rail yard (tracks across the road, freight cars, a derailed car, water tower, depot), an oil field (pump jacks, storage tanks, a pipeline, a flare stack), and the army base (Hesco walls, gate, four towers, tents, command post, Humvees, helipad).
- Burnt-out cars along the whole road and an overturned bus.
- Infected come from narrower sides in the canyon (route points carry a `Wide` value); convoy cruise 14 studs/s; convoy 220 HP; reward 400 gems.

## 0.12.0 — 2026-11-21

MISSIONS mode (first mission: CONVOY OUT).
- Two modes in the crew lobby: DOWNTOWN = endless waves (as before), MISSIONS = get something out while you cover it from above. The second map card is MISSIONS; it swaps the map preview for the mission list (`MissionsUI`).
- `Convoy.Missions`: the 9 missions (Convoy Out, Downed Crew, Supply Drop, Hospital Evac, Prison Bus, Train Run, Bridge Demo, VIP Extract, Fuel Depot) with reward, best class and description. Only Convoy Out is playable; the rest say COMING SOON until their maps exist. Any mission can be played any time; today's DAILY picks pay x2 and this week's WEEKLY pick x4, once each (profile `OpsDone`). About a third of missions run at NIGHT on a given day (seeded, same for everyone).
- `ConvoyServer.Ops` runs a mission's objective; `Mission.runOp` runs the mission (no waves, no bosses). The objective moves `BUNKER`, so the infected go for it, it is what they hurt, and the gunship circles it. Fail pays a share of the reward by how far you got.
- CONVOY OUT: three trucks drive a 1.6 km highway from a town to an army checkpoint. Anything standing in the road ahead stops them; infected that reach them hurt the convoy (150 HP). Map `workspace.Ops.Convoy` (built at z = 6000): town, highway with median and power lines, wrecks, overturned bus, gas station, overpass with a collapsed ramp, farm, abandoned roadblock, billboard, checkpoint with Hesco walls, tower, tents and helipad.
- HUD in a mission: the top box shows the mission name and `progress% // status`, the health bar is named after the objective (CONVOY), no boss bar or auto-skip; the convoy glows in thermal (`OpClient`). Results say MISSION COMPLETE / FAILED. Missions skip the takeoff cutscene; a won mission's ending cutscene has no explosions.
- Lobbies accepts a party mode of `Op_<id>` for a mission that's ready.
- Studio test hook: `DebugOpSkip` attribute jumps the convoy 600 studs.

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
