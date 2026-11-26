# Changelog

Versions follow MAJOR.MINOR.PATCH. The current version is also in `VERSION` and on the `GameVersion` attribute of `ReplicatedStorage.Convoy` in the place.

## 0.19.15 — TEST FLIGHT, SUPPLY CRATE, crew boosts, VIP pass
- **TEST FLIGHT** (aircraft bay): a TEST FLIGHT button above BACK / EQUIP / NEXT flies the aircraft you're looking at, owned or not, straight into wave 4 (5 s countdown). EXIT TEST FLIGHT under AUTO-SKIP ends it; it also ends after that one wave or when the bunker falls. Nothing on a test flight is kept: saving is off (Mission `saveProfile` skips while Convoy attribute `TestFlight` is on), no Robux offers or quick-buy tiles, no SECOND CHANCE, no results screen. Product receipts on a test server return NotProcessedYet, so anything bought there is granted back in the hangar.
  - Live: Lobbies action "TestFlight" reserves a fresh server of the default map for that one player (teleport data `kind = "test"`, `plane`; loading screen says TEST FLIGHT) and sends them home when it ends. Studio: runs on the same server and puts your equipped aircraft back after.
  - Scripts: Lobbies, Mission (StartRun kind "test", action "ExitTest"), BattleOffers, new LocalScript TestFlightUI. UI: GunshipUI_Template Aircraft.Controls.Test (copy of RETURN TO HANGAR), HUD.Top.ExitTest (copy of AUTO-SKIP).
- **SUPPLY CRATE**: a SPIN tile under FREE on the hub (red dot when a spin is ready) opens a SUPPLY CRATE panel (new StarterGui.CrateUI, a copy of the daily drop panel). Seven prize cards with their odds on each: 100 gems 34%, 300 gems 20%, 2X CASH run 14%, 2X GEMS run 13%, FREE NUKE run 9%, UNLIMITED AMMO run 7%, 2,500 gems 3% (`Shop.CRATE`, `Shop.crateOdds`; prizes use the daily drop's format). A free spin every 8 hours; more spins for Robux (1 for 25, 5 for 99: `Shop.CRATE.PACKS`, product ids still 0 = SOON). A light runs round the cards and slows down onto the prize. Server: new ModuleScript ConvoyServer.Crate (action "SpinCrate", saved as data.Crate via Cosmetics load / save / grantProduct). The prize is saved as pending and paid 3 s later as the light lands, so leaving mid-spin can't lose it.
- **Crew boosts**: CREW 2X GEMS (99 R$, a quick-buy tile next to FORTIFY / UNLIMITED AMMO) and CREW 2X CASH (49 R$, offered once at the break after wave 1). One gunner buys it, the whole crew gets it for the rest of the run (Convoy attributes CrewGems / CrewCash, read where Mission pays gems / cash; toast "X CALLED IN 2X GEMS FOR THE CREW"). `Shop.BATTLE.CrewGems / CrewCash`, product ids still 0: no tile and no offer until they're made.
- **VIP pass** (`Pass_VIPGold`, 249 R$, pass id still 0 = SOON): gold name over your head (OverheadTags), [VIP] in gold in the chat (new LocalScript VipChat, TextChatService.OnIncomingMessage), +10% gems from every run (Mission). Shop card in PASSES next to UNLIMITED AMMO (copy of NO CIV HITS); crown art uploaded (rbxassetid://123054708154085, art/store/store_pass_vip.png), a stand-in until real pass art is made.
- **Still to make on Roblox** (the Studio assistant has no `developer-product:write` / `game-pass:write` scope): developer products "Crew 2X Gems" 99, "Crew 2X Cash" 49, "Supply Crate: 1 Spin" 25, "Supply Crate: 5 Spins" 99, and game pass "VIP" 249. Icons are in Desktop\ROBLOX IMPORT (crew_gems.png, crew_cash.png, crate_spins.png, vip_pass.png). Then put the ids in Shop (`BATTLE.CrewGems.productId`, `BATTLE.CrewCash.productId`, `CRATE.PACKS[1/2].productId`, the Pass_VIPGold entry's passId) in all 4 places.
- Tested in Studio (DebugNoSave on), PC and iPhone 13 emulator: hub SPIN tile, crate panel, two free spins (prize paid 3 s after the result, light lands on it), test flight in the AH-64 and AC-47 (EXIT, and the bunker falling: no second chance, back to the hangar, equipped aircraft, gems and best wave unchanged), VIP shop card. No script errors. Not tested: a real test-flight teleport (needs a publish), real purchases.
- Patch: tools/snippets/money_0_19_15.luau. All 4 places match (fingerprint 12395cd0dd1cf407), GameVersion 0.19.15, saved.

## 0.19.14 — Phone and iPad hub layout
- Phones, hangar hub: less cluttered and the move stick is free.
  - The settings gear and CODES sit in the top right instead of next to Roblox's buttons (CODES covered the gem counter). In a run the gear goes back to the left, where the HUD keeps room for it (TopbarIcons, CodesUI: TopbarPlus `align`).
  - SHOP / SEASON / FREE are one smaller row under the rank card; DAILY / INVITE / DEAL a column from just under the gear and CODES, above Roblox's jump button (GunshipUI fitScreens `rowTiles`; PHONE_K Side 0.7, SideRight 0.85).
  - AIRCRAFT / PLAY / RANKS stay centred, a bit narrower, so AIRCRAFT clears the move stick and RANKS the jump button.
  - The hub fits itself again whenever our top-bar icons change size (they load after GunshipUI, and CODES hides in the aircraft). Before, the gem counter sat under CODES until something else made it re-fit.
- Phones: the aircraft bay's BACK / EQUIP / NEXT bar is bigger (PHONE_K Controls 0.62 to 0.85; EQUIP was hard to read).
- Phones: the CREATE LOBBY panel (pads) is smaller and sits under the top bar (PadHUD; it was at least 0.7 scale and ran up under Roblox's buttons). Still the main thing on screen.
- iPad / tablets: the hangar screens are 25% bigger (the HUD keeps its own TABLET_HUD_K), except the hub's AIRCRAFT / PLAY / RANKS bar (bigger ran into the move stick). SHOP / SEASON / FREE sit a little further down from the rank card.
- PC unchanged.
- Heads-up: GunshipUI's main chunk is at Luau's 200-locals limit. Two new top-level locals broke it ("Out of local registers") during this work; new helpers have to go inside functions (or use attributes).
- Tested in Studio's device emulator (DebugNoSave on): iPhone 13, iPhone 7, iPad 9th gen. Hub, daily panel, free reward, CREATE LOBBY on a pad, aircraft bay, a solo run's HUD (stopped before the end). No script errors. Not tested on a real phone.
- All 4 places match (fingerprint 78a4aea0cedcc5e9, includes Jacob's price changes), GameVersion 0.19.14, saved.

## 0.19.13 — Daily drop every join, Unlimited Ammo, Max Out, No Civ Hits, Christmas held back
- **Christmas switch** (new `Convoy.Presents.LIVE`, now **false**): the Christmas update is held back for launch. While off: no presents (drops, HUD chip, daily rewards: `Presents.active()`); the NORTH POLE card on the CREATE LOBBY panel says COMING SOON and can't be picked, and `Places.mapPlace` sends a North Pole crew to Downtown (`Places.soon`); Santa's sleigh is out of the aircraft bay, the free picks and the flyovers (`Aircraft.LIST` filters `christmas = true` aircraft; new `Aircraft.ALL` keeps them for saves via `A.join`, `Aircraft.shown(id)`; Mission won't equip / buy a hidden one and resets an equipped one to the AC-130); the lobby hangar's SleighStand and SANTA'S WORKSHOP booth are moved to ServerStorage.ChristmasHeldBack as the server starts (new Script `ConvoyServer.ChristmasSwitch`). Set `LIVE = true` to launch it. The sleigh's game pass (2101997395) is still on sale on the store page.
- **Daily supply drop**: opens every time you join the hangar (not on a new player's tutorial visit; back from a run only when a drop is waiting). New rewards: two weeks that take turns (`Shop.DAILY_WEEKS`, by UTC week) of gems, run boosts (2X CASH, 2X GEMS, FREE NUKE, UNLIMITED AMMO: `Boost_<id>`), and presents during the Christmas event (gems otherwise). `Shop.dailyFor` / `Shop.dailyLook`; Mission ClaimDaily grants them; DailyUI cards show each day's icon, amount and unit.
- **UNLIMITED AMMO** replaces CASH DROP (dev product 3736617520, 49 R$): in a run no reloads and no overheating for the rest of the run (player attribute UnlimitedAmmo, read by `Weapons.tryFire`); bought in the hangar it's saved as Boost_Ammo for the next run (Cosmetics.runStart). In the run's quick-buy tiles and the battle offers (tough-streak offer, every third break) instead of CASH DROP; shows ACTIVE once on. Also a card in the shop's Passes section. CashDrop is retired (old purchases still granted).
- **NO CIV HITS** game pass (2100450597, 199 R$): your shots never hit civilians (Mission `hit()`). Shop card next to it.
- **MAX OUT** button in the armory, right of the picked gun's card (new LocalScript MaxOutUI): maxes every upgrade level of that gun for Robux. Price by what the levels left cost in gems (`Shop.MAX_OUT` / `maxOutTier`: 99 / 199 / 399 / 699 R$, products 3736617634 / 642 / 661 / 673). Action "MaxOutPick" then the product; Cosmetics.grantProduct maxes it (refunds gems if it was already maxed). Hidden when the gun is maxed.
- Icons: Unlimited Ammo and No Civ Hits art from Jacob (art/battle/icon_*.png; images 90607456017369 / 109083952221579, also set on the store items). CANDY CANE ROCKETS got its own icon, a photo of the real rocket shot in Studio (art/ammo/ammo_candyrocket.png, image 101122777142489; was the minigun's). `Icons.set` takes whole-image entries (one id, no sheet cell); BattleOffers items can name an Icons entry (`iconName`).
- Presents (when the event is on) only drop on the North Pole map (PresentDrops sets Convoy attribute PresentsHere; Studio test override: PresentsAnyMap). The HUD chip only shows there.
- Mobile: the presents chip sits under the kills tally at the tally's scale (was a fixed big size); the present markers scale with the screen (about half on a phone). The hub's side tiles (SHOP, SEASON, DAILY, INVITE, DEAL) hang from just under the rank card on touch screens instead of being centred low by PLAY (GunshipUI fitScreens).
- NORTH POLE map card decorated (new LocalScript NorthPoleCard): candy-cane border, snow cap, a string of lights that twinkle when it's picked, falling snow, EVENT tag (COMING SOON while Christmas is held back).
- Tested in Studio (DebugNoSave on): daily panel on join, shop cards, MAX OUT button, map card, COMING SOON, aircraft bay without the sleigh, hangar without the stand/booth, a lobby test run with the UNLIMITED AMMO tile, Weapons.tryFire with and without UnlimitedAmmo (300->300 vs 300->280). No script errors. Not tested on a phone.
- Fix: after PLAY AGAIN, a copy of your aircraft stayed in the sky for the whole next run. The fly-home shot was still posing the results formation when the next run started, so it was rebuilt after it had been cleared. GunshipClient `poseFleet` now does nothing once the results are over (State isn't Debrief). Tested: give up, PLAY AGAIN, no leftover plane.
- Aircraft camera goes all the way round (360). The guard that stopped the aim crossing under the aircraft kept it on the bunker's side of the aircraft, so the hovering Apache couldn't look behind itself. Now it only keeps the aim out of a small circle under the aircraft, on any side, and steering into that circle slides round it (GunshipClient). Tested on the Apache: holding A turned the view 690° in 16 s, no flip.
- **CODES**: a CODES button on Roblox's top bar (TopbarPlus, left, next to the settings gear; hidden in the aircraft) opens a CODES panel (new StarterGui.CodesUI, a copy of the FREE REWARD panel, built by tools/codes_ui.luau; new LocalScript CodesUI). Type a code, REDEEM (or Enter). Server: new ModuleScript ConvoyServer.Codes (`Codes.CODES`, once per player, saved as data.CodesUsed; hooked into Cosmetics load / save / init; action "RedeemCode", reply attribute CodeResult). First code: **ZOMBIES = 1,000 gems** (was LAUNCH). Tested: wrong code, case / spaces, used twice.
- Sand Dunes: part of the ground looked raised on live servers (low graphics), with straight edges and a dark crease in front of the bunker. The apron sat in a 1-stud-deep rectangular notch in the sand; Roblox's simplified far-away terrain doesn't draw a thin notch the same way, so its edge showed as a raised plate. The notch is filled to the sand around it (170 voxels, x -36..36, z -4..36; the tunnel trench untouched) and the apron (Apron, ApronLine, ApronStripe) lifted 0.5 so it sits on the sand.
- (Badges were started and dropped: no Badges script.)
- **The game is now "Gunship vs a Million Zombies"**: every player-facing "infected" is now "zombies" (loading screen title, hub title, ZOMBIES LEFT, ZOMBIES INBOUND, THE ZOMBIES BROKE THROUGH, ZOMBIES KILLED, rank objectives, upgrade and boss texts, mission descriptions, tutorial and NPC lines). Only text inside strings / UI Text changed; names in code (folders, InfectedLook, attributes) are untouched. 32 strings in 10 scripts (incl. ReplicatedFirst.LoadingScreen) + 5 GunshipUI_Template labels, in all 4 places. The "THE ZOMBIES BROKE THROUGH" result is matched the same everywhere (Mission, GunshipClient cutscenes). Jacob renames the experience.
- **No trademarked aircraft / weapon nicknames** (manufacturers treat them as trademarks): aircraft go by their military designation. AC-130H GUNSHIP (was SPECTRE), AC-47 GUNSHIP (SPOOKY), UH-1 GUNSHIP (HUEY), MQ-9 DRONE (REAPER), AV-8B JUMP JET (HARRIER), AH-64 ATTACK HELI (APACHE), CH-47 GUNSHIP (CHINOOK), B-52 BOMBER (STRATOFORTRESS); short names are the designations (AC-47, UH-1, MQ-9, AV-8B, AH-64, CH-47). Weapons: 70MM ROCKETS (HYDRA), AGM-114 / AGM-114 MISSILES (HELLFIRE), 40MM CANNON / 40MM AUTOCANNON (BOFORS). Also mission "BEST:" tips, the CH-47 resupply speaker, two NPC lines, and the matching UI labels (armory, HUD weapon slot, aircraft bay, Deal panel) in all 4 places. Only display text changed (aircraft ids, model names like "Bofors", icon names like ammo_hydra untouched). The REAPER 41 callsign stays (a callsign, not a product).
- **REPAIR scales harder**: its price now multiplies by 1.8 every use in a run (250, 450, 810, 1,460, 2,620, 4,720...; was +125 each: 250, 375, 500, 625). New optional `growth` field on `Upgrades.ABILITIES` entries; `abilityCost` uses `base * growth ^ uses` when it is set, otherwise the old +50%-of-base raise (NUKE and A-10 unchanged). Resets every run as before. Synced to all 4 places (every script source identical), saved.
- **Gun upgrades 30% cheaper in gems**: new `Upgrades.GEM_COST_SCALE = 0.7` multiplies every gun's base in `Upgrades.cost` (25mm now 110 / 320 / 610 / 960 / 1,380; 105mm 280 / 850 / 1,620 / 2,570 / 3,680). Used everywhere the gem price is read (GunshipUI, Mission, MaxOutUI, Cosmetics refund, DailyUI).
- **MAX OUT a bit cheaper**: 79 / 149 / 299 / 499 R$ (was 99 / 199 / 399 / 699) and the gem bands scaled with the new prices (`upTo` 2,100 / 4,900 / 10,500). The four dev products' prices have to be changed on the Creator Hub to match (Open Cloud only takes form uploads for products).
- Fix: the MAX OUT button twitched when hovered near its edge (it grew 5%, the mouse fell inside / outside the grown edge, it shrank, repeat). MaxOutUI now works out hover from the button's normal-size spot each frame and eases the grow. Tested in Downtown: hovered 1.236 -> 1.298 steady; 13 px below the normal bottom edge stays 1.236.
- All 4 places match (scripts incl. ReplicatedFirst b7b5df9a2785860b), GameVersion 0.19.13, saved. Shop cards copied to all 4 StarterGui.ShopUI.

## 0.19.12 — Santa's sleigh guns rebuilt in detail
- The sleigh's guns (`Models.SLEIGH.Guns`, and the copy on the lobby SleighStand) are rebuilt part by part, at the Apache's level of detail, in the sleigh's red / white / gold toy style. 276 parts (was 70). Same places and muzzle points, so rounds still leave the barrels.
  - CANDY CANE MINIGUNS: a real six-barrel cluster round a spindle, every barrel red / white with the stripes offset barrel to barrel (a candy-cane twist), dark bores, gold muzzle and mid clamps, a rotor, a gunmetal receiver with gold trim, a red drive motor, back plate with spade grips and trigger, a gold mount plate bolted to the sleigh's side, a feed chute with a red / white ammo belt up to a present ammo box on the side rail, holly and berries on the receiver and a jingle bell under the barrels.
  - CANDY CANE ROCKETS: Apache-style pods (same part names: RocketPod, PodRim, PodFace, PodTube, PodTail) with spiral red stripes, a gold rim, a dark face with seven launch tubes and red / white rocket noses in them, a tail cone with a gold cap and a gold pylon.
  - PRESENT CANNON: a red jacket and white tube with spiral red stripes, gold bands, a gold muzzle brake with vents, a present loaded in the bore, a breech block with lever, twin recoil buffers, a trunnion in a gold yoke on a turntable, a side sight with an icy lens, and a bow on top.
- Every gun part carries attribute `GunSlot` (25mm / 40mm / 105mm). GunSwap now swaps only the parts tagged with the gun being upgraded (before, any sleigh upgrade swapped all three guns at once). Other aircraft are unchanged.
- Builder script kept in `tools/sleigh_guns.luau` (run it in a place to rebuild the guns on the template and on the lobby stand).
- All 4 places match (scripts 8a8a9f71b7b1498a, sleigh guns 5c431cc1b479dd6c, on top of Jacob's 0.19.11), GameVersion 0.19.12, saved.

## 0.19.11 — Christmas presents event: shoot presents, unlock Santa's sleigh
- In runs (not the tutorial) gift boxes drop on open ground around the bunker: one every 8 s, up to 4 at a time, each lasts 25 s. Small = 1 present, Big = 3, Gold = 10 (rare). Shoot one (any blast that lands on it) and it's yours: confetti pop and "+N PRESENTS" over the spot. Config: new `Convoy.Presents` (COST 250, ENDS 31 Dec 2026). Server: new `ConvoyServer.PresentDrops` (spawns, hits, unlock). Mission's `explode` calls `PresentDrops.hit`; Cosmetics loads / saves `data.Presents` (player attribute Presents) and inits it.
- New LocalScript PresentsClient: each present gets a see-through-walls glow, a coloured light beam to the sky, a present icon over it, bobs and spins, blinks before it vanishes. HUD chip PRESENTS (new StarterGui.PresentsHUD, a one-row copy of the kills tally) under the tally during runs, with a +N pop.
- Lobby: SANTA'S WORKSHOP booth (copy of the RANKS booth, smaller, red / green / white, snowy roof with icicles, block Christmas tree and gifts, board with the sleigh) in front of the sleigh stage, with SGT. KRINGLE in a Santa hat. Its pad opens new StarterGui.PresentsUI (copy of the gem top-up panel): presents x / 250 with a bar, UNLOCK IT FREE when you have 250 (action "UnlockSleigh": takes 250, gives and equips the sleigh, saves), or GET IT NOW for 599 Robux (the sleigh's game pass). Owners get EQUIP. New LocalScript PresentsUI.
- Sleigh stand: the UNLOCK NOW kiosk is gone (the booth sells it now); the dust sparkle emitter under the sleigh removed. New show FX, all blocks, no textures: stardust streaming off the runners, speed streaks rushing past, snow falling over the stage, Rudolph's nose pulsing (SleighStand).
- Snow piles (blocky, studded) round the sleigh stage and the booth (SleighStand.SnowPiles, lobby). Nobody walks through the stage or the booth any more: HangarLife keeps the ground crew's arcs out of a box round both (they turn back instead), the tug runs straight along in front of them, and the walkers' loop (Walkers.Path, now P1-P9) goes round the front of the booth.
- Santa's sleigh parked in the hangar: no welders on it. Instead a crewman on a hay bale holds carrots up to Rudolph (his arm follows the reindeer's head); each bite shortens the carrot and drops crumbs, and after the last bite he takes another from the bucket. New LocalScript CarrotFeeder (copy of Welder1's man); HangarPlane stands the welders down for the sleigh.
- Fix (lobby pads): stepping onto an empty CREATE LOBBY pad did nothing if you were already in a crew that wasn't on a pad (made from the hub's lobby screen, or left over). Lobbies now drops that crew when you step on a pad and opens CREATE LOBBY. If your save is still loading it says "LOADING YOUR SAVE... ONE SEC" instead of nothing.
- Flyovers: the AC-47's propellers spin (its blades sit straight under the model, which the spin code skipped; OutsideLife).
- Studio only: TracerShowcase, a firing range in the sky where every tracer shoots the real in-game rounds (25mm bursts + a 40mm shell, plus STANDARD for comparison). Button "TRACER SHOWCASE (STUDIO)" at the top of the screen in Studio play; nothing on live servers.
- Tracer shop art: each tracer's card picture (Tracers `image`) is now a real in-game round shot in Studio (TracerShowcase capture mode: player attribute TracerCap fires a stream across a black backdrop; screenshots keyed to transparent by tools/tracer_shop_art.py; PNGs in art/tracer_shop). New ids: Crimson 122559709823208, Cobalt 90336100669924, Gold 81186726550988, Plasma 92051259905555, Ember 130975442322445, Void 106502327337958.
- Bug scan (test runs in Lobby, North Pole and Sand Dunes, plus every hub screen): no script errors. Fixed what it found:
  - Presents were hard to spot from the aircraft: their floating icon is a BillboardGui, which doesn't show through the thermal sensor. Now each present gets a flat gold-boxed icon in the HUD (GunshipUI HUD.Markers, like TargetBoxes) while you fly; the billboard is only used in the hangar view. Presents are bigger too (5 / 6.5 / 5.5 studs).
  - CarrotFeeder and PresentsUI waited forever for the hangar in the map places ("Infinite yield" warnings); they now give up after 10 s.
  - The Studio-only TRACER SHOWCASE button showed during runs; hangar only now.
  - Tested: collecting presents in runs on all 3 maps, UNLOCK IT FREE at the booth (takes 250, gives + equips the sleigh), back to the lobby after a run.
- New Studio test switch: attribute DebugNoSave on ReplicatedStorage.Convoy (set it in a play session) makes saveProfile skip saving, so test runs never touch the real save. Studio only.
- All 4 places match (fingerprint b81115f4bdc86c3b), GameVersion 0.19.11, saved. UI rebuild snippet: tools/snippets/sync_0_19_11_ui.luau. Untested live: real drops in a run on a live server, the unlock with real presents, the pass buy.

## 0.19.10 — Sleigh display rebuilt: flying, in our style
- Hangar SleighStand (lobby) rebuilt in the game's own look, modelled on Survive a Million Monkeys' weapon displays: three stepped tiers (weld-plate base with a hazard band, studded middle, glossy black deck) with glowing red neon edges, red / green / white base lights (the twinkling Bulbs), two deck spotlights, a red glow under the sleigh, and a dark weld backboard with a red neon frame and light strips; the SANTA'S SLEIGH sign sits on the board in Oswald. Removed: the cloud, its snow and sparkle emitters, the presents, candy-cane lamps and chains. Old stand kept in ServerStorage.SleighStand_Backup_0198.
- The sleigh flies free (no podium): a wave rolls back through the reindeer team (each deer rises a beat ahead of the one behind, nose up on the way up; traces and reins follow) and the sleigh rides it, banking and drifting. ReindeerGallop: sleigh attributes WaveA / WaveW / WaveK switch the wave on (only this stand has them; every other sleigh is unchanged). SleighStand moves the sleigh with the same wave.
- All 4 places (scripts), GameVersion 0.19.10.

## 0.19.9 — Santa's sleigh stand in the lobby, sleigh is a 599 Robux game pass, aircraft camera can't get stuck
- The sleigh is now sold as GAME PASS 2101997395 (599 Robux) instead of a developer product: new `Shop.PLANE_PASSES` (`SLEIGH = { passId, price }`). Mission grants it when the profile loads (UserOwnsGamePassAsync) and the moment it's bought (PromptGamePassPurchaseFinished: owned, equipped, saved). In the aircraft bay a Robux-only aircraft now shows UNLOCK WITH ROBUX on the big button (was a dead grey "ROBUX ONLY") and both it and UNLOCK NOW prompt the pass with its live price; its list row reads ROBUX.
- Lobby: SANTA'S SLEIGH promo stand right behind the spawn, between the SHOP and RANKS booths (`Workspace.DMZ.Hangar.SleighStand`, lobby only). Red stadium stage with a gold neon band, a snowy studded top and twinkling coloured bulbs, piles of the sleigh's own present rounds, four candy-cane lamp posts spotlighting the sleigh, the full sleigh hovering and swaying over it (reindeer galloping, gold sparkles off the runners), a little snow cloud that snows only over the sleigh, a hanging SANTA'S SLEIGH banner (both sides) and a kiosk at the front with the price and a prompt: UNLOCK (prompts the pass) / EQUIP / EQUIPPED. New LocalScript StarterPlayerScripts.SleighStand drives it (does nothing in places without the stand).
- Fix: the aircraft camera could get stuck so only side to side worked (reported after switching aircraft, cleared up a while later). Panning the sensor past the point under your own aircraft spun the view round 180 and swapped forward / back, so the aim bounced under the aircraft until the orbit carried it away; the low fliers (AC-47, Huey, Apache, Chinook, Harrier) hit it easily. GunshipClient now keeps the aim point at least a steep look-down in front of the aircraft. All aircraft, keys, sticks and touch drag.
- All 4 places match (fingerprint cf8fe5bea83fa66d, includes Jacob's 0.19.8), GameVersion 0.19.9, saved.

## 0.19.8 — Better alert badges on the hub tiles
- The red "!" dots on SEASON and DAILY are now square badges in the game's style (like the shop / DEAL ribbons): red plate, dark miter edge, lit top half, stroked text. They pop in when they turn on, breathe, and give a small shake every few seconds (new LocalScript BadgePulse).
- The SEASON badge shows how many rewards are waiting to claim (1-9, then 9+) instead of "!".
- All 4 places, GameVersion 0.19.8.

## 0.19.7 — Season rewards are claimed
- Season pass rewards no longer arrive by themselves: reaching a tier (or buying premium) makes them wait. Waiting cards glow green with "TAP TO CLAIM"; tapping one, or the new green CLAIM ALL (n) button left of UNLOCK PREMIUM, claims everything waiting (action "ClaimSeason", Cosmetics). The toast says what was claimed. Reaching a tier says "SEASON TIER n! CLAIM IT IN THE SEASON PASS".
- A locked premium card now opens the premium purchase when tapped.
- The hub's SEASON tile red dot now means "rewards waiting to claim".
- SeasonFree / SeasonPrem are now "tiers claimed"; old saves already had everything reached handed out, so nothing is lost. CLAIM ALL is built in code from the premium button (SeasonUI).
- All 4 places, GameVersion 0.19.7.

## 0.19.7 — Santa's sleigh barely overheats
- Two of its guns had no heat settings of their own and took the AC-130 slot's: the CANDY CANE ROCKETS the Bofors' 0.06 a shot (overheated ~16 rockets into a 32 load), the PRESENT CANNON the howitzer's 0.18 a shot with a 25 s cool-down (overheated after ~5). Now: candy-cane miniguns 0.003 a shot, CoolTau 2 (about 15 s of nonstop fire, was ~6); rockets 0.012, CoolTau 2.5, no jams (a full load never overheats); present cannon 0.04, CoolTau 4.
- All 4 places match (fingerprint cde621f288c7a0f9), GameVersion 0.19.7, saved.

## 0.19.6 — Your own kill count; B-52 nukes clear the map
- The HUD's KILLS tally, the kill-streak callouts and the debrief's INFECTED KILLED now show each gunner's own kills, not the crew's total (Mission sets player attribute LiveKills in onKills, reset on joinCrew; GunshipUI reads it; the debrief uses RunKills). Shared Kills is still the crew total for everything else.
- B-52 B61 nukes now kill every infected on the map, wherever they're aimed (was: an 85-stud circle). Bosses still take a quarter of their health and burrowed infected are still safe underground, same as the NUKE ability. Card text: "EACH ONE CLEARS THE WHOLE MAP".
- All 4 places (incl. Christmas Town), GameVersion 0.19.6 (built on 0.19.5: its sleigh, sound and Chinook changes are kept).

## 0.19.6 — Sleigh minigun back to red and white candy-cane rounds
- pigeon liked the red / white rounds: the sleigh's 25mm is CANDY CANE MINIGUNS again (look `candycane`: every round red or white, tinted so it stays coloured through the thermal sensor, glitter sparks), icon ammo_candycane. It keeps 0.19.5's numbers (x2.2 blast growing with upgrades, x2.0 damage) and the sleigh-bell / jingle sounds (ConvoyAudio `candycane`); its hits get a red and white ring (FXLib boom) and draw up to 12 studs.
- All 4 places match (fingerprint 6381811888c7bb0c), GameVersion 0.19.6, saved.

## 0.19.5 — Sleigh even stronger with Christmas sounds, galloping team, minigun / Chinook splash, darker North Pole
- **Santa's sleigh, more OP** (Aircraft): SNOWBALL MINIGUNS blast x2.2 (was 1.3) and the blast now grows with upgrades (`splashUp` 0.12: +12% per upgrade level, +6% per run tier; Mission applyGun) and x2.0 damage; CANDY CANE ROCKETS x1.8 blast, x1.8 damage, 32 a load, 0.12 s, 3.5 s reload; PRESENT CANNON x2.0 blast, x2.2 damage, 8 a load, 0.4 s, 4 s reload. Perk now +50% vs Brutes and bosses and 25% faster reloads (plus +50% gems, +30% cash). The snowball minigun's blasts are drawn up to 12 studs (other guns' 25mm pops stay capped at 5).
- **Christmas sounds** (new Convoy.Sounds Xmas_SleighBells 6974173557, Xmas_Jingle 116968929570638, Xmas_HoHoHo 138079767, Xmas_Chime 99980076888596; free Creator Store audio, all load in Studio): the snowball minigun opens with sleigh bells and jingles now and then over a soft buzz; the present cannon fires with a bright chime and a soft thump, and Santa's "Ho Ho Ho!" at the start of a salvo (at most every 6 s).
- **Reindeer gallop rewritten** (ReindeerGallop): the team runs nearly in step (small ripple back to front) instead of each deer at random; legs gallop in pairs (back, then front, left / right a touch apart), every reindeer bobs and rocks and its head nods. Rest poses are captured the first time a sleigh appears, relative to the sleigh's Root. Checked on video.
- North Pole: the parked SleighDisplay is gone. Darker: Brightness 2.0 (2.6), ambient down, bloom 0.35 / threshold 1.7, snow and snow-white parts a touch greyer; through the thermal sensor ThermalBrightness 0.35 (1.2) and ThermalOutdoor 52,55,64, so the snow reads mid grey and the lit windows / street lights stand out.
- **Miniguns / Chinook**: miniguns had the 25mm's small pop (x0.75); now by how fast they fire: Huey door minigun x1.2, AC-47 x1.05, Chinook twin miniguns x1.0. Chinook 40MM GRENADES x1.7 blast (1.25) and they stop overheating: they used the Bofors' 0.06 heat a shot at 0.2 s apart (overheated after ~17); now 0.018 a shot, CoolTau 3, no jams.
- Robux product still not created: Open Cloud still says `developer-product:write` isn't granted to the Studio assistant.
- All 4 places match (fingerprint bec63d1b88c7cd8d), GameVersion 0.19.5, saved.

## 0.19.4 — The sleigh free for the devs, product thumbnail ready
- Aircraft `giftTo`: user ids that own an aircraft for free, added on every profile load (Mission, next to the Studio / group-owner grant). SLEIGH: pigeon (bmasterdevil, 89199750) and Jacob (BING_CHILLING2525, 4263620304), so both can test the Robux sleigh in the live game once this is published. Done in code, not by editing saves: the live game's old code doesn't know SLEIGH and would drop it from a save the next time either of them plays.
- Robux product NOT created yet: the Studio assistant doesn't have the `developer-product:write` Open Cloud scope (Assistant MCP Permissions). Thumbnail ready: art/products/plane_SLEIGH.png (same card style as the others). Plan: "Aircraft: Santa's Sleigh", 799 R$, then `SLEIGH = { productId = <id>, price = 799 }` in Shop.PLANE_PRODUCTS in all 4 places.
- All 4 places match (fingerprint bc166a8888bc9f28), GameVersion 0.19.4, saved.

## 0.19.3 — SANTA'S SLEIGH reworked: present cannon, galloping reindeer, Robux-only and OP
- **Back of the sleigh rebuilt** (Models.SLEIGH): the ball sack, the loose gift cubes, the snowball cannon and the present rack under the floor are gone. Now a fat red PRESENT CANNON with gold bands on a gold swivel sits on the back (a wrapped present peeking out of the muzzle), CANDY CANE ROCKET pods hang low on both sides, a neat stack of five wrapped presents with ribbons and bows sits in front of the seat, and the side miniguns have icy snowball barrels.
- **The reindeer gallop**: new LocalScript StarterPlayerScripts.ReindeerGallop. Every leg / hoof of the sleigh is tagged `ReindeerLeg` with its rest pose and hip point (attributes); wherever a sleigh is in the workspace (aircraft bay, hangar, lobby flyover, wingmen, results backdrop, the parked one on North Pole) the legs swing about their hips, front and back pairs opposite, each reindeer a little out of step. Works on scaled copies. Skipped beyond 900 studs from the camera.
- **New weapons, with real models**: new folder ReplicatedStorage.Convoy.Projectiles (Present_1..4 in four wrappings, CandyRocket). FXLib can now draw a round as a pooled model (SHELL_LOOK `model`, scaled up with distance like the other rounds, presents tumble, rockets roll).
  - 1 SNOWBALL MINIGUNS (25mm, look `snowball`, GUN class): a fast hose of snowballs (0.035 s), x1.3 blast, x1.5 damage, snow bursts on impact.
  - 2 CANDY CANE ROCKETS (40mm, look `candyrocket`, ROCKET class): candy-cane rockets with a red / white sparkle trail, 24 a load, x1.4 damage, red and white rings in the blast.
  - 3 PRESENT CANNON (105mm, look `present`, BOMB class): tumbling wrapped presents with a glitter trail, 6 a load, 5 s reload, x1.5 blast, x1.6 damage, confetti and a gold ring when they go off; fires with a cannon thump.
- **OP, for a Robux aircraft**: Aircraft guns can now carry `damage` (an extra damage multiplier, Mission applyGun). Perk SANTA'S MAGIC: +50% gems, +30% kill cash, +25% vs Brutes and bosses, 20% faster reloads. Stats 5 / 4 / 4 / 4.
- **Robux only** (`robuxOnly`): never sold for gems (Aircraft.onSale is false, so BuyPlane / free picks / FreePlaneUI refuse it; Deals already skips it), the bay says ROBUX ONLY and the price reads ROBUX. It's unlocked by `Shop.PLANE_PRODUCTS.SLEIGH` (the bay's UNLOCK NOW), which needs a developer product first: **no product exists yet, so for now nobody can buy it** (Studio / the group owner still get it to test). The old gem price and New Year end date are gone.
- North Pole's parked SleighDisplay swapped for the new model; North Pole also got Jacob's Claude's analytics (Funnels, Analytics, AnalyticsClient, Remotes.Track) and the latest GemTopUp.
- Tested in Studio on North Pole: legs swing (0.4-0.5 rad in 0.12 s), all three weapons fire from the run (HUD counts down), presents / candy rockets / snowballs drawn as models with their trails (shot close up from a fixed camera with FX sent from the server). One test run was lost by mistake and ended (a few gems to pigeon's save).
- All 4 places match (fingerprint 4f0b875f88bbc257, includes 0.19.2 analytics), GameVersion 0.19.3, saved.
- Studs on every face of the sleigh (another of pigeon's sessions): all 6 surfaces of every Models.SLEIGH part are Studs except the 2 Neon parts and the invisible Root (298 of 301), in all 4 places and on North Pole's SleighDisplay; re-applied in Downtown / Sand Dunes after the 0.19.3 copy. Copy the sleigh from the lobby from now on so the studs stay. (Models aren't in the fingerprint, so it's unchanged.)

## 0.19.2 — Analytics: funnels, economy, progression
- 16 funnels (Onboarding + Run, Shop, FirstBuy, GemTopUp, DebriefPass, DailyDeal, BattleOffer, StreakOffer, SecondChance, Season, Ranks, Aircraft, Armory, Mechanic, Daily), gem economy sources/sinks with reasons, progression (Rank, BestWave, Strike) and custom events (RunEnded, RunGems, RobuxPurchase, PurchaseCancelled...). Custom fields on everything: place, detail, rank band.
- New: ReplicatedStorage.Convoy.Funnels, Remotes.Track, ServerScriptService.Analytics, StarterPlayerScripts.AnalyticsClient. They only watch (attributes, purchase prompts, existing UI); no other script calls them. GemTopUp sets PackId/PackKey on its gui for them.
- Guide: docs/ANALYTICS.md. Studio check: workspace attribute DebugAnalytics = true prints every event.

## 0.19.1 — NORTH POLE is a different kind of map: a Christmas village
- Was still the Sand Dunes shape (a bunker dug into a hill, infected coming over open ground). Now it's a **street-type map** like Downtown (DMZ has no `Map` attribute any more; `Weather = "Snow"` stays): a small snowy village on the street grid the infected walk (streets at -150 / 0 / 150 both ways through the bunker), flat snow (ground 4.0) out to ~600, then hills and tall mountains past the blizzard (tools/north_pole_terrain.luau).
- The bunker is **Santa's Workshop** in the town square (Bunker, Center 0,2,0, 38 x 38 like Downtown's): red hall with white bands, a big double door with a wreath on each of the 4 sides, candy-cane corner posts, glowing windows, a stepped snowy roof with a glowing strip round every tier, smoking chimney, big star, "SANTA'S WORKSHOP" sign. The infected walk in down the streets and crowd round it; losing plays the street-map cutscene (the workshop blows up, the camera orbits over the lit village).
- Built to read from the aircraft: Roblox stops drawing small parts far away, so the street lights are 13-stud glowing strips on the snowbanks (500 of them, alternating red / green / gold / blue) and every house has glowing eave and ridge strips and big glowing windows. In the thermal view they show as bright dashed lines; they are not tinted with Highlights on purpose, so they never look like the red / green / blue target colours.
- DMZ.Roads: dark packed-snow streets (the N-S ones a hair higher so crossings don't z-fight) and a paved square ringed in red. DMZ.Decor: 64 houses facing the streets (6 colours, snowy gabled roofs, chimneys, wreaths), ~390 pines (yards + a forest belt round town), a Christmas tree with glowing garlands and a star in the square, an ice rink with glowing boards, 10 snowmen, candy canes on every crossing's corners, 4 tall lamp posts, snowbanks along the streets. Helipad, barriers, barrels and the 12 wrecks (still explode when shot) re-placed for the streets. The square stays open (~90 studs) for the loss cutscene's camera.
- **SleighDisplay**: a parked copy of SANTA'S SLEIGH in the square (DMZ.Decor.SleighDisplay), so it can be looked at in Studio. Delete it if it shouldn't stay in the map.
- Map card: new picture of the village (rbxassetid://79275825893531, art/map_northpole.png), sub line "SNOWY VILLAGE // NIGHT // ENDLESS WAVES" (Places, all 4 places).
- Tested in Studio on North Pole: infected spawn ~320-370 out on the streets and walk in (158 samples: all animating, feet on the ground, worst 0.6 studs), the boss intro (THE TANK, wave 5) and the loss cutscene (previewed client-only) play with clear shots, no errors. All 4 places match (fingerprint d017ed257fd1b6c9), GameVersion 0.19.1, saved.

## 0.19.0 — Christmas: NORTH POLE map and SANTA'S SLEIGH
**New map: NORTH POLE** (place 134466727053055, made from a copy of Sand Dunes, so it has every script, all the UI and the open-map "Dunes" behaviour: terrain ground, fog-ring spawns, the tunnel and the BREACH cutscene).
- A snowy mountain valley at night (tools/north_pole_terrain.luau): the bunker's tunnel goes into a steep rocky cliff (~62 high in the middle so helicopters still see it), forested ridges down both sides, a frozen river winding across the front, a ring of tall mountains past the fog. Low-frequency shapes only (no LOD doubling).
- The bunker is a candy-cane tunnel: red / white ribs on green, red / white hazard stripes, a wooden door with gold, a wreath with a bow over the mouth and a string of Christmas lights along the top (Bunker.Xmas).
- DMZ.Decor (all Parts, stud / inlet / weld / universal surfaces; CanCollide and CanQuery off so rounds and target boxes go straight through): ~100 blocky snow-capped pines on the ridges and the mountain, an 87-stud Christmas tree with ornaments, a star and presents beside the bunker, 4 log cabins with lit windows, eave lights and wreaths, 7 snowmen, 8 candy canes lining the approach, 4 lamp posts round the apron, ~55 snow-capped boulders, present piles where the crate stacks were. The wrecks, barriers and barrels were re-seated on the new ground; nothing sits in the river.
- Night: moonlit blue (ClockTime 0.3), brighter ambient so the boss / infected read in cutscenes, bloom for the lights; Thermal* attributes as Sand Dunes. The fog ring is a cold blue-grey blizzard (was brown-black smoke).
- Falling snow: new LocalScript StarterPlayerScripts.Snowfall, only where DMZ has `Weather = "Snow"` (does nothing on the other maps). Flakes follow the camera near the ground (cutscenes, results) and switch off above 160 studs so the sights never look through them.
- FXLib: hits on Snow throw up snow (new "snow" material category) and on a snow map the blast dust ring / chips are white instead of sand and dirt (`snowyMap()`).
- Boss / breach cutscene cameras now also avoid DMZ.Decor (GunshipClient `decorBlocked`: the decorations don't take raycasts, so clearSpot checks their bounding boxes). Breach shot 1 has a clear path (canes and a lamp moved).
- Registered in Places (MAPS / ORDER / INFO: "NORTH POLE", "SNOW // NIGHT // ENDLESS WAVES", card picture rbxassetid://124863050232856, art/map_northpole.png).
- Tested in Studio (Deploy in the new place): infected spawn at the fog in the front arc, walk the valley and run into the tunnel; 282 of 285 foot checks on the ground (3 at 1.5-1.7 studs), every infected / civilian animating; the boss intro (THE TANK, wave 5) and the BREACH cutscene (previewed client-only) play with clear shots. No errors. The real teleport from the lobby pad needs a publish to test.

**New aircraft: SANTA'S SLEIGH** (`SLEIGH`, Models.SLEIGH, part-built like the others: red / gold sleigh on curled runners, a sack of presents, Rudolph and four reindeer in a flying gallop; 49 studs = true scale in the bay).
- Holiday only: rank NONE, 2,500 gems, on sale until 2027-01-01 00:00 UTC (`saleEnds`, `Aircraft.onSale`). After that BuyPlane / ClaimFreePlane refuse it, the bay says HOLIDAY OVER and free picks don't list it; owners keep it forever (never remove it from LIST).
- Perk: SANTA'S BONUS +30% gems at the end of a run. Orbit 280 radius / 285 up.
- Three new weapons (new `look`s): CANDY CANE MINIGUNS (25mm slot, minigun class: red and white tracers that stay coloured through the thermal sensor, with a glitter trail), SNOWBALL CANNON (40mm, free: big white snowballs with a snow trail that burst into snow instead of fire), PRESENT BOMBS (105mm, free, 3 a load: tumbling wrapped boxes in random paper with a gold ribbon and a glitter trail; the bang throws confetti and a gold ring). Server sends the weapon's look with each boom (Mission `explode`). Upgrades: candycane = GUN, present = BOMB, snowball = SHELL. ConvoyAudio sounds for all three.
- Icons: new row on the ammo sheet (rbxassetid://93537523450515, was 108330527658903): ammo_candycane, ammo_snowball, ammo_present, ac_SLEIGH (art/ammo, photographed in Studio, cut out with art/ammo/make_xmas_icons_blender.py).
- Bay TRUE_FT, AircraftUI size (55 FT 8 IN / 13 FT 5 IN WIDTH), FreePlaneUI falls back to the ac_ icon when there's no Robux product, and Santa now flies over the lobby now and then (OutsideLife).
- Tested in Studio on North Pole: all three weapons fire, kill and draw; HUD cards show the new names and icons. No Robux product for it (Jacob can add one to Shop.PLANE_PRODUCTS if wanted).

All 4 places (lobby, Downtown, Sand Dunes, North Pole), saved. Copied with SerializationService + a localhost relay through Ropilot (DevSync_tmp is still forbidden from pigeon's Studio); fingerprints match.
## 0.18.10 — First-buy bonus, losing-streak offer, daily deal
- FIRST BUY 2X: the 1,500 and 5,000 gem packs (`firstBonus` in Convoy.Shop) give double gems the first time each player buys them. Shop cards show "3,000 GEMS / 1,500 + 1,500 FIRST-BUY BONUS" with a green 2X FIRST BUY ribbon until used; the gem top-up popup counts the bonus too. Server: Cosmetics.grantProduct (runs before Mission's normal pack grant); saved as FirstBuys.
- LOSING STREAK: a run that ends before wave 3, or before half your best wave, counts as rough (Cosmetics.runEnd, RoughRuns, session only). After 2 in a row, the next run offers CASH DROP at the first break as "TOUGH STREAK? START STRONG" (BattleOffers; once per streak).
- DAILY DEAL: a DEAL tile under INVITE in the hangar (red -30% ribbon) opens a panel with today's item at 30% off in gems: a gem tracer, an aircraft your rank has reached, or your next strike, picked per player per day (Convoy.Deals, changes at 00:00 UTC = 6 PM Central). One buy per day (DealDay, saved). Short on gems opens the top-up popup. Server: Cosmetics action BuyDeal. UI: StarterGui.DealUI + LocalScript DealUI.

## 0.18.9 — 2X GEMS offer on the debrief
- Players without 2X GEMS see a strip above GEMS EARNED on the debrief: "2X GEMS PASS // COUNTS THIS RUN TOO  +170 MORE GEMS" with the live price. Tapping it prompts the pass.
- Buy it within 5 minutes of the run ending (Shop.PASS_BONUS_WINDOW) and the server doubles that run's gems too (Mission, PromptGamePassPurchaseFinished; once per run via RunBonusAt). The strip turns green: "+170 BONUS GEMS ADDED" and the GEMS EARNED card updates.
- New: LocalScript GemsUpsell (builds the strip in code from the debrief card style). Mission now sets RunEndAt next to RunGems.

## 0.18.8 — Gem top-up popup
- When a gem buy comes up short (armory upgrade, aircraft, tracer, A-10 / F-15 strike), a NEED MORE GEMS popup now shows the smallest gem pack that covers the gap ("COVERS IT, WITH 260 TO SPARE"), with a GET IT Robux button and SEE ALL GEM PACKS (opens the shop on the gem packs from any screen). It closes by itself once you have enough. Never shows during a run.
- New: LocalScript GemTopUp + StarterGui.GemTopUpUI (copy of the Mechanic's panel). `Shop.bestPack(short)` and `Shop.askGems(need, what)` in Convoy.Shop; call `askGems` from any new gem purchase. GunshipUI's OpenScreen can now open the Shop from any screen. Uses the existing gem pack products (no new products).

## 0.18.7 — Sand Dunes: no more doubled ground
- The sand looked like a second copy of the map lying on top and shifting as the helicopter moved: Roblox swaps far terrain for lower-detail versions, and with sharp little bumps the versions don't line up. The terrain heightfield is smoothed (Gaussian, 12 studs in the play area, 36 studs out past the fog; the bunker, its dune face and the tunnel untouched), so the detail levels match. Largest change 10 studs; 13 props re-seated. Checked at graphics level 3 from the Apache.
- Backup of the old terrain: ServerStorage.DunesTerrain_Backup_0186 (a TerrainRegion; PasteRegion it back at cell -256,-64,-256 to undo).

## 0.18.6 — Cooler tracers
- Each tracer now has its own trail in a run (Tracers `fx`, drawn by FXLib in the tracer's colour so it shows through the thermal sensor, capped at 260 sparks): CRIMSON hot embers falling off, COBALT electric crackle, GOLD glitter that hangs in the air, PLASMA fat pulsing blobs and a pulsing beam, EMBER rising licks of fire, VOID dark motes spiralling round the line.
- New shop / season art for each (art/tracers/make_tracer_cards.py): a glowing round with a white-hot core and its trail style (`image` on each tracer; the old tinted line is the fallback). Tracer card art is a bit bigger.

## 0.18.5 — Pick your strike, Mechanic idle, visible strikes, target boxes
- Mechanic panel: no more ticks. Every strike you own says EQUIP (tap the card to use it); the one in use says EQUIPPED; the next one's card buys it (same as the button). Player attribute `StrikeEquip` (saved), action `EquipStrike` (Cosmetics, checked against StrikeTier); buying a new one equips it. Mission flies the equipped one; the bay, the F card's name and photo follow it.
- HUD F card photo fixed: the photos are whole images, so the icon-sheet crop (ImageRectSize) is cleared for them and put back for artillery.
- The Mechanic idles (Roblox's R15 idle, client side; accessories welded on).
- F-15 bombs are drawn: each leaves the jet and falls onto its spot with a nose-down tilt and a white smoke trail, landing on the damage beat (FX `f15bombs`, sent by Strike.f15).
- A-10 rounds are easy to see: thick, long tracers (w 1.0, len 30) and slower (650 / 600 studs/s) so the burst reads as a rope of fire from the gunship's height.
- Red target boxes: an infected is boxed if its torso OR head is in view (one ray to the torso hid ones half behind walls / cars); ones that arrive before their torso get boxed when it does; on Sand Dunes the terrain never hides them.
- All 3 places.

## 0.18.4 — Taller RELOAD ALL, offers stay clear of it
- `HUD.Weapons.ReloadAll` is 68 tall (was 52, looked stretched at 370 wide); label 32, icon 38.
- BattleOffers `cardSpot`: the small offer card (e.g. the CASH DROP offer on every 3rd break, which is when RELOAD ALL shows) now sits above RELOAD ALL as well as the weapon cards; with 3 guns it used to land on top of the button. If there's no room above it (short screen), the card goes just left of the weapon cards, level with the top one. Checked in Studio with a faked wave-3 break on the AC-130 (1920x900): the card is above the button and fully on screen.
- All 3 places, saved.

## 0.18.4 — Lobby flyovers
- Low flyovers (helicopters, the A-10 below 140 up) no longer fly through the hangar: they pass 260-450 studs to one side of the building (the closest one in a 75 s test was 220 studs clear of the walls). High ones still cross over the roof.
- Flyovers no longer all trail smoke: the white wing trails are gone, and only about one in ten is hit and trails smoke and fire (was one in five, and every other one had white trails that read as damage). OutsideLife, lobby only.

## 0.18.3 — RELOAD ALL above the guns, quicker aircraft bay
- RELOAD ALL (between waves) is now a real button in the template, `HUD.Weapons.ReloadAll`: a full-width bar just above weapon 1 (follows how many guns the aircraft has), in the gun cards' button style (amber face, so MilitarySkin draws it as a dark amber plate with an amber border like their ▲ upgrade buttons), with the reload icon. It was a yellow copy of START floating left of the cards. GunshipUI only hooks it, shows it and places it.
- Aircraft bay (`AircraftBay`): flicking through planes on the AIRCRAFT screen keeps up. One pick still runs the full show at normal speed. A pick made while a show is running speeds it up (`pace`, +0.9 a pick, up to 3x; a pick within 2 s of the last show ending starts at 2x). A plane still rolling in carries on out the far door while the newest one follows it in (the doors stay open), and a plane that hasn't started rolling yet is dropped. The next plane stays hidden until it has room behind the one ahead. Tested in Studio: picking all 8 at 0.25 s apart, the B-52 is parked 3.2 s after the last pick. Picking three times mid roll-in, the last one is parked 2.2 s after its pick. Planes never overlap (8 studs minimum gap).
- All 3 places. (Sand Dunes was copied over by Jacob's Claude: the two scripts through DevSync_tmp, the ReloadAll button serialized property by property.)

## 0.18.2 — F-15 rebuilt, with bombs
- `Models.F15` rebuilt (all 3 places): every part overlaps its neighbour (wing roots sunk into the body, stepped wing / stabilator / tail blocks overlapping, gear struts start inside the body, wingtips on the wing). Checked with a GetPartsInPart flood fill from the fuselage: 0 floating parts.
- Six Mk-82 bombs on pylons (four under the wings, two under the intakes): olive body, nose, yellow band, cross tail fins. The AIM missiles are gone.
- Strike card photo retaken (rbxassetid://115198505980368).
- Hangar talkers: if you have the gems for the next strike, talking to a soldier sends you to the Mechanic ("You've got the gems for an A-10, soldier. / Go see the Mechanic by the artillery. BRRRT!", or the F-15 version) instead of a joke, at most once a minute (HangarWalkers).
- Hangar: a workbench in front of the Mechanic (`Hangar.Workbench`, his textures): wood top, olive frame and drawers, a shelf with an ammo can and a tire, a vise, red toolbox, wrench, hammer and clipboard.
- `Models.F15` is now Jacob's edited copy (lobby Workspace.F15), copied to all 3 places.
- Z-fighting fixed: overlapping wing / stabilator steps alternate thickness (0.6 / 0.74, 0.4 / 0.52), the middle tail block is thicker, the red wingtips are taller than the wing, and the intakes overlap the fuselage side instead of sharing its face.

## 0.18.1 — Mechanic panel, new F-15
- The Mechanic's prompt uses our custom prompt style (Kind = "Strike", no hold) and opens a STRIKE UPGRADES panel (StarterGui.StrikeUI, a copy of the season panel; script StrikeUI): three cards ARTILLERY / A-10 STRIKE / F-15 STRIKE with photos of the real models (outlined; art/strike, rbxassetid 84573117546235 / 99792664342161 / 124753424927721), the one you have marked EQUIPPED, and an UPGRADE button with the game's gem icon. Buying only through the BuyStrike action now. Header icon: the repair tools, not the season badge.
- The HUD's F card shows the A-10 / F-15 photo once you have it.
- New F-15 (`Models.F15`) built from parts in the A-10's style: stud/weld/universal plastic, stepped swept wings, twin canted tails, boxy intakes, twin nozzles, canopy, missiles, gear. Used for the strike, the bay and flybys (the old mesh is ServerStorage.F15_OldMesh). All 3 places.
- Notifications (GiftToast) drop in under the gem counter instead of on top of it.
- Icons uploaded through a temporary localhost server in Jacob's Blender (Studio's upload_image only takes http URLs).

## 0.18.0 — Strike upgrades: artillery -> A-10 -> F-15
- A Mechanic stands at the front corner of the artillery bay in the hangar (Jacob's R15 mechanic in grey coveralls and cap, anchored, facing the hangar; the first toolbox one was pitch black and is gone). Hold E / X on his prompt to upgrade the F ability with gems: A-10 STRIKE 2,500, then F-15 STRIKE 6,000 (`Upgrades.STRIKES`, player attribute `StrikeTier`, saved as `Strike`; `Cosmetics` buys it, also action `BuyStrike`). Not enough gems: a "NEED X MORE GEMS" notice.
- In a run the F ability is then: artillery barrage (as before) / an A-10 30mm gun run (`callA10`) / an F-15 that comes in low and drops a stick of 6 bombs (`Strike.f15`, 2.2x artillery damage, 18-stud blasts). The jets fly along the line through your point that catches the most infected (8 headings, civilians count against it); on-station calls use the best run. Call price and the armory's 3 strike upgrades are shared. The A-10's 30mm no longer hurts civilians.
- `StrikeHangar` (client): the prompt says what's next and its price; once bought, the A-10 / F-15 stands in the bay instead of the howitzer (only on your screen); the ability card and the armory card say ARTILLERY / A-10 STRIKE / F-15 STRIKE.
- Studio only: workspace attribute `DebugStrikeTier` forces a tier in Mission (for testing without touching saves). Tested in Studio: both jets fire, cost and bay swap work.
- The bay's F-15 currently uses `Models.F15` (the flyby model); the part-built F15E was deleted on 0.11.0.

## 0.17.10 — Sand Dunes: infected under the sand
- Roblox draws far-away terrain simplified (more so on low graphics), so from a low aircraft (Apache) looking across the dunes, the infected and civilians were hidden inside the blocky far sand. On the dunes (DMZ Map = "Dunes") their highlights now draw on top (AlwaysOnTop); Downtown keeps buildings hiding them. Reproduced and checked in Studio at graphics level 1.
- Season / controller changes from 0.17.8-0.17.9 synced to Downtown and Sand Dunes (incl. the season track's 4 px inset).

## 0.17.9 — Controller cursor
- D-pad down, in the hangar and between waves: turns on Roblox's gamepad cursor (left stick moves it, A clicks); D-pad down again turns it off. It goes off by itself when the wave starts or you leave the hangar; ConsoleNav doesn't auto-select buttons under it. Control hints: "[D-PAD DOWN] CURSOR" (replaces the VIEW entry in the list).

## 0.17.8 — Better season rewards
- SEASON 1 rewards roughly doubled. Free: 100-1,000 gems a tier (was 50-500), more 2x cash / 2x gems / free nuke tiers, Ember still at 10. Premium: 300-1,000 gems, boosts up to 15 runs, nukes up to 8 runs, Void at 25, aircraft at 30.
- A FREE NUKE card for 2 or more runs shows that many nukes, stacked (up to 3); Season.count(r).
- Season track: cards moved in 4 px so the highlighted tier's outline isn't cut off at the top / left.

## 0.17.7 — Controller: upgrade the selected gun
- B upgrades the gun you have selected (same as its card's ▲: cost check, "NEED $... MORE" when short). Works during a wave and in the break; while placing artillery B still cancels. Control hints list "[B] UPGRADE GUN".

## 0.17.6 — Controller: reaching the on-screen buttons
- Between waves (the break) a controller gets the HUD's buttons selected straight away: START first (A still starts the wave), the D-pad moves to RELOAD ALL, the gun upgrades, FORTIFY, CASH DROP...; when the wave starts the selection goes and the sticks / triggers are the guns' again. (During a wave the upgrades are on the View button.)
- In the hangar, Y picks the hub's buttons (PLAY first, then SHOP / SEASON / DAILY / AIRCRAFT / RANKS with the D-pad), Y again or B goes back to walking. The hub hint line says "[Y] HUB BUTTONS" on a controller.

## 0.17.5 — Season boosts, tracers with perks
- SEASON rewards: besides gems, tiers now give 2X CASH for n runs, 2X GEMS for n runs and FREE NUKE for n runs (Season helpers cash2x / gems2x / nuke). Stored as Boost_Cash / Boost_Gems / Boost_Nuke on the profile (data.Boosts); Cosmetics.runStart uses one run of each when a run or op starts (not the tutorial), RunBoosts tells the HUD ("BOOST ACTIVE" banner). Mission doubles cash / end-of-run gems and adds a free nuke. Premium: Arctic and Inferno tiers replaced by boosts; Void stays at 25, the aircraft at 30. Free: Ember stays at 10.
- Season cards use the real icons (Season.icon): gem piles that grow with the amount (gems_s/m/l/xl), the 2x cash / 2x gems pass art, the nuke, an aircraft.
- TRACERS: 6 instead of 11, and each does something while equipped (Tracers perk, applied when a run starts): CRIMSON 1,500 gems +10% cash from kills; COBALT 3,000 gems +10% reload speed; GOLD R$99 +10% gems from runs; PLASMA R$149 +15% damage to brutes and bosses; EMBER (season free) +10% damage to brutes and bosses; VOID (season premium) +15% cash, +10% reload. Violet, Frost, Rainbow, Arctic and Inferno are retired: not sold or shown, anyone who has one keeps it. Shop cards say the perk; the hidden ones' gaps close.
- Hangar welders: turned from the torso (the model pivot is the work stand), torch held level, and only placed where the torch tip really touches the aircraft; with no such spot they stand down (they were welding the air next to the Apache).

## 0.17.4
- Sand Dunes through the thermal sensor: dark sky (Lighting attributes ThermalAtmColor 28,30,34 / ThermalAtmDecay 14,15,18 / ThermalAtmOffset 1 / ThermalAtmHaze 2.6; GunshipClient's sensorLight now also swaps Atmosphere Offset and Haze). The smoke ring blends into the sky instead of reading as a black wall under a pale sky.
- Cutscenes keep the camera at least 4 studs above the terrain under it (boss shots on the dunes were inside the sand).
- Controller detection is stricter (Aim): only a button, a trigger or a stick pushed past half way switches to the controller layout; any mouse movement switches straight back; a console (no keyboard) starts on it. A drifting stick or a pad left plugged into a PC no longer takes over. ConsoleNav drops its button selection when the mouse takes over.

## 0.17.3 — Console / controller support
- Gamepad in the aircraft (Aim.pad(): the crosshair stays in the middle, like touch): RT fire, left or right stick move the sensor (left stick flies helicopters, L3 boosts), LT zooms in while held, D-pad up / down zoom, RB / LB next / previous gun, X reload, R3 thermal polarity, A start the wave, Y nuke, D-pad left repair, D-pad right artillery (RT places it, B cancels). Ability cards show < / Y / > on a controller.
- Menus on a controller (StarterPlayerScripts.ConsoleNav + Convoy.PadNav): a panel that opens gets a button selected inside it (D-pad / stick move, A press), B does the panel's close / exit / back button, the end-of-run debrief is selected too. The hub and HUD stay free for the character and guns; the View button selects their buttons (Roblox's own navigation). Close buttons register with PadNav.on / PadNav.back (GunshipUI hook() does it for Close / Exit / Back).
- Controller words: hub hint line, Settings controls list, wave-cleared / flying / artillery banners, tutorial hints ("HOLD RT TO FIRE", "PRESS RB FOR THE 40MM").
- Studio: the DebugPad attribute on the local player turns the controller layout on with a keyboard (Studio's input tools send controller buttons as keyboard input).

## 0.17.2
- B-52 bombs drop from the wing racks in turn: left, right, working back along the three rows (6 mounts). Nukes still come from the bay.

## 0.17.1
- Weapons on both sides fire left, right, left...: each shot leaves from the next mount (Aircraft guns[slot].mounts, studs from the model's pivot) instead of the aircraft's centre. Huey rockets, Reaper Hellfires, Harrier cannon pods and bombs, Apache rocket pods and Hellfire rails, Chinook twin miniguns. Single guns (AC-130 side guns, Apache chin gun, Chinook grenade launcher, B-52 bay) are unchanged.

## 0.17.0 — Season pass, tracers, hub buttons

- SEASON PASS (Convoy.Season): Season 1 runs 2026-11-25 to 2027-01-01 UTC, 30 tiers of 100 XP. XP from runs: 10 per wave cleared, 1 per 5 kills, 25 per boss. Every tier has a FREE reward (gems; EMBER tracers at 10; 500 gems at 30) and a PREMIUM one (more gems; ARCTIC 5, INFERNO 15, VOID 25 tracers; a free aircraft pick at 30). Premium = developer product 3735965747, R$399; rewards are given as tiers are reached, and every premium one already reached when it's bought. A new season resets everyone to tier 0.
- Server: ServerScriptService.ConvoyServer.Cosmetics (load/save on the profile: Tracers, Tracer, Season {id,xp,f,p,prem}; runEnd after each run; grantProduct from ProcessReceipt; actions BuyTracer / EquipTracer). Tier-ups and unlocks use the GiftNotice toast.
- SEASON screen (StarterGui.SeasonUI): a bigger copy of the daily drop panel. FREE row over PREMIUM row, a column per tier, scrolls sideways to your next tier; tier, XP and days left at the bottom; UNLOCK PREMIUM (live Robux price) / PREMIUM ACTIVE. Script: StarterPlayerScripts.SeasonUI.
- TRACERS (Convoy.Tracers): your rounds' tracer glow in a colour of your choice, on every gun of every aircraft; the whole crew sees it. Gems: CRIMSON 1,500, COBALT 2,500, VIOLET 3,500, FROST 5,000. Robux: GOLD 99 (3735965809), PLASMA 149 (3735965821, wider), RAINBOW 199 (3735965832, cycles colours). Season 1 only: EMBER, ARCTIC, INFERNO, VOID. No greens (civilians).
  - Ballistics sends the shooter's tracer with each round; FXLib colours it and puts it in a per-tracer model with a Highlight so the colour shows through the black-and-white thermal sensor.
- Shop: TRACERS tab and section (copies of the pass cards): price in gems or Robux, EQUIP / EQUIPPED (tap again for the guns' own colour), season ones say SEASON PASS and open the season screen.
- Hub: DAILY and INVITE moved to a right-hand column (Menu.SideRight); the left column is SHOP, SEASON (copy of the FREE tile, season badge), FREE.
- Art: art/season (icons + purchase thumbnails, make.py). In-game icons: tracer streak 74496714171970, season badge 86397412865806.
- tools/snippets/sync_0_17_ui.luau rebuilds the UI changes in a place (used for Downtown and Sand Dunes).

## 0.16.6
- Sand Dunes is night: moonlit (ClockTime 0.3, default night sky with stars, blue ambient and haze, cool colour grade). The day look is kept in ServerStorage.DunesDayLighting.
- Sand Dunes: the tall black FogWall around the map is gone (kept in ServerStorage as DunesFogWall_Removed); the smoke bands and dark fill stay.
- Night maps through the thermal sensor: GunshipClient swaps in the Lighting attributes ThermalClock / ThermalBrightness / ThermalOutdoor / ThermalAtmColor / ThermalAtmDecay while the sensor is on (a bit darker than day, still readable), and puts the night back for cutscenes and the plain camera.

## 0.16.5
- Spitters are yellow now (thermal tint, name tag, acid sacs and clothes, spit globs, new-type banner, ranks colour): lime green read as a civilian.
- Civilians spawn at a spawn point away from live infected (best of up to 8 tries, stops at 140+ studs), and infected groups likewise away from live civilians.
- CIVILIAN KILLED banner on every civilian hit: strike n/3 and the fine, who did it in co-op (Shared CivHitBy), "TOO MANY CIVILIANS HIT" on the last one.

## 0.16.4
- Sand Dunes terrain: smoothed the sand inside the play area (heightfield blurred over ~16 studs; the bunker and its dune left alone) so there are no flat raised plates or hard creases, and the dark Ground/Basalt patches near the edge are now sand. Props were set back down on the new surface.
- Sand Dunes: infected sank into the tunnel mouth. The tunnel's floor height now covers the whole Bunker.Floor part (it stopped ~35 studs short, where a raycast falls into the carved sand). Ground height also takes the highest of three samples so nobody stands inside a dune face.
- 105mm (hand-loaded, one round): the tier tooltip and banner no longer promise "+25% MAGAZINE"; they say faster reload + bigger blast (Upgrades.tierText oneRound).
- RELOAD ALL between waves: a copy of the break's START button just left of the weapon cards (Mission action "ReloadAll": every unlocked gun that isn't full starts reloading).

## 0.16.3
- Weapons screen: the gun cards slid around when hovered. ButtonFeel re-anchored them to the middle for a hover grow they don't have (they carry their own "Sel" UIScale), so the shrink pivoted from the middle. It now leaves cards with their own scale alone, and refreshArmory resets their anchor.
- Leaving a match (debrief LOBBY, LEAVE MATCH, tutorial end) takes you back to the same hangar server you deployed from (TeleportData.lobby = that server's JobId). If it's gone or full you go to any hangar.
- Wingmen: in a run you see your crew's aircraft flying their own places on the orbit, with a blue outline so they read in thermal. (Studio: DebugWingmen on ReplicatedStorage.Convoy shows a copy of your own plane.)
- Sand Dunes: the black fog sat so close that low aircraft (Apache, Huey, Chinook) lost most of the map. The smoke bands, puffs and dark fill moved out (smoke 243-533 -> 360-560, fill 347-764 -> 540-790); the wall is unchanged, so you still can't see past it. The infected spawn points moved out with the smoke, and their sand slowdown is mostly gone so the walk in takes about as long.
- Crew scaling: each gunner after the first adds +70% infected per wave, +40% health on tough types, +60% boss health and a higher on-map cap. With 3+ gunners ordinary infected take two hits.

## 0.16.2
- Lobby pad: tapping a map card errored (PadHUD:244, `refresh` was used before it was declared), so the map couldn't be changed. Fixed and tested in Studio (Sand Dunes selects).
- New-player tutorial (live): a player sent home from a reserved server was landing on a reserved hangar server with no run and sat there doing nothing (error report: "home teleport landed on a Mission server again"). A reserved hangar server now decides its role from its first arrival: tutorial data -> tutorial server; sent home / joining a crew -> works as a normal hangar; no data at all -> a new player gets the tutorial right there instead of a bounce.
- More warnings in the live error report to trace it: "no run here" bounces, tutorial not started (and why), profile not loaded after 30 s.

## 0.16.1
- Settings: INVERT CAMERA (every device), a copy of the AUTO-FIRE row under it. Flips the drag-to-aim direction; saved with the profile (Settings.InvertCam, Mission "Settings" 5th arg).
- iPad / phones: the sensor could stop moving for good after tapping things. A touch whose end the game never saw counted as a second finger forever, so one-finger drag was ignored; stale touches are now dropped. Also a leftover Cutscene attribute with nothing playing is cleared, so a cutscene can never keep the camera.
- Checked the lobby map picker in Studio: selecting Sand Dunes works (needs this version published).

## 0.16.0
- Sand Dunes map card picture: rbxassetid://109331821964301 (the horde streaming in from every side).
- Map places: players kept dying and respawning (red flash) because MapSpawn floats in the air with nothing under it; an invisible SpawnFloor now catches them (Sand Dunes and Downtown).
- Sand Dunes: the infected no longer stand at the bunker hitting it. They run through the mouth into the tunnel, each does its whole damage once (8 for a normal one, x1.5 on Hardcore) and disappears inside. Bosses, bombers and spitters keep their old behaviour. Their ground inside the tunnel is the tunnel floor.
- Sand Dunes: losing plays a new BREACH cutscene (letterboxed): low beside the apron as the horde pours past into the mouth, inside the tunnel looking out as they flood in, then up and back over the sand. The server sends everyone left plus ~140 more running in for 8 s while it plays (no bunker explosion on this map).
- Sand Dunes fog: you can't see past it from any aircraft. The black wall moved out past the B-52's orbit (575-745 studs) and the gap between the smoke and the wall is filled with solid dark smoke; the inner bands are see-through textured smoke and the drifting puffs are a lighter grey so they read against the black (also in thermal).
- Lobby pad: the map row shows one card per map side by side with a bigger picture; tap one to select it (yellow edge and name), the other is dimmed. "SELECT MAP" label; the panel is taller and scales to fit.
- Target boxes on the infected are bigger (min 18x24, ~1.3x the body) with a thicker outline.

## 0.15.5
- Gunship Bundle now also gives a free aircraft of your choice (any rank). The pick is saved on the profile (FreePlanePicks) until used; FreePlaneUI opens a copy of the shop's gift picker in the hangar listing every aircraft you don't own (icons from the plane products), PICK -> Mission "ClaimFreePlane" (unlocks + equips). Owning them all turns the pick into 2,500 gems (Shop.FREE_PLANE_GEMS). X hides it until next time.
- Daily supply drop pays more and climbs harder: 50 / 75 / 125 / 200 / 300 / 450 / 1000 gems (was 25-300; 2200 a full week instead of 755).
- Lobby pad map card: tapping the card cycles Downtown / Sand Dunes (it always did) and now also swaps the picture (Places.INFO[map].image). Sand Dunes' image id is empty until the card picture is uploaded.
- Lobby: the 4 helicopters on the airfield pads are now the current UH-1 Huey model (door gun with yoke, grips, ammo can and feed chutes, door openings) instead of the older copy; same spot, same rotor/skid part names, so the pad spin-up and ride-out still work. The old ones are parked in ServerStorage.Parked_NotInGame.
- Sand Dunes: you can't see over the black fog from any aircraft any more. A 1000-stud-tall black wall (non-colliding, non-query Plastic parts) stands ~520-640 studs out, outside even the B-52's 520-stud orbit, following the same wobbly fog shape, and all the terrain beyond the fog band is now near-black basalt, so from up high the land past the smoke reads as darkness.

## 0.15.4
- Sand Dunes: the black fog ring is no longer a circle. Its radius wobbles from 0.8x to 1.13x around the map (DMZ attribute FogShape = "n,amp,phase;..."), and Mission spawns the infected at the fog's inner edge using the same shape (all 3 places). The permanent fog bands are now plain near-black ribbons (the smoke texture made spikes from above), with fewer, longer-lived puffs on top so they stay under the particle budget and don't pop.
- Sand Dunes: seven dunes inside the basin (8-16 studs, steep slip faces), kept clear of the bunker, helipad and props; a few props moved off them. Crates are 62% and barrel groups 80% of their old size (they looked huge next to the infected), and everything was set back on the sand.

## 0.15.3
- Sand Dunes bunker: no more flickering (z-fighting). 894 places where two parts shared the same face were fixed (the arched ribs, lips, legs, door frame and skin slats overlapped flush); neighbouring segments are now a hair thinner in turn. The concrete apron sits 0.45 higher so the sand no longer pokes through it.
- Sand Dunes fog: the black fog ring is now always there. Twelve rings of camera-facing smoke beams (his smoke texture, near-black) make a solid wall at ~334-444 studs, and the drifting puffs now live 18-20 s and fade in/out quickly, so the ring never thins out or pops.

## 0.15.2
- Sand Dunes: fog ring moved back out between the two earlier distances (bands at ~340 / 382 / 428 studs, up to 170 tall); the infected walk out of it at ~352 and wade through sand at 80% speed.
- Nothing floats: the bunker sits on the sand, every barrel, crate and barrier is set on the ground part by part, and vehicles/prop groups that were on slopes were moved to flat sand.
- The lights inside the bunker door are dimmer (the orange ring looked like a shape in the tunnel).

## 0.15.1
- Sand Dunes: the black fog ring is closer and much taller (bands at ~285 / 325 / 370 studs, up to 170 tall) and the infected now walk out of it at ~300. They wade through the sand at 70% speed, so the walk in takes about as long as Downtown's streets.
- The big dune is lower (54 instead of 98) with its crest a little further back: from behind, its top was right on the gunship's line of sight and hid the bunker (helicopters were worse). The tunnel now shows ~40 studs before it goes into the dune. Outcrops, sand patches, props and fog re-seated on the new ground.

## 0.15.0
- New map: **Sand Dunes** (place 88208849422941, built from a copy of Downtown with the city removed). Modeled on Zombie Gunship's first map:
  - A flat sand basin with one giant dune behind the bunker (98 studs, steep slip face) and rolling dunes to the horizon; Roblox terrain (sand, soft hard-ground patches, sandstone/rock outcrops). Generator: tools/sand_dunes_terrain.luau.
  - The bunker is a ribbed steel tunnel coming out of the dune face, with two curved support legs, a hooded mouth with a hazard lip, a blast door with red lights inside, floodlights, sandbags and a concrete apron. All parts Plastic with stud/inlet/weld/universal surfaces (Neon for lights, Fabric sandbags).
  - A ring of black fog round the bunker (DMZ.FogRing, three bands at ~395/440/490 studs, the game's own smoke texture); the infected walk out of it, in an arc in front of the bunker (nothing comes over the dune).
  - Wrecked jeeps and trucks (RouteProps "Car_" models, so they blow up when shot), barrels, crate stacks and a line of concrete barriers in front of the bunker. Desert daylight with a sandy haze.
- Map-aware run code (shared by all places): DMZ attribute Map = "Dunes" switches on terrain-height ground for the infected (raycast, cached on a 3-stud grid), straight-across-the-sand routes and the fog-ring spawn arc (DMZ Facing). Downtown is unchanged.
- Boss feet lift (EnemyMover) also reads the terrain.
- Lobby map pick: the CREATE LOBBY panel's map card steps through the maps when tapped (Places.ORDER / Places.INFO); the party keeps its map and the run reserves a server of that map's place. Loading screen says "DEPLOYING TO SAND DUNES".

## 0.14.32
- AC-130 intro: no more sit-down move (the body floated into the chair, and the step-in spot put his feet in the chair base). He turns to his station, cut to black, and he's sitting in the chair facing the screens.
- Lobby heli ride: the hang is posed in code (PadHelis, Motor6D Transforms after the animation step) instead of the old one-hand clip that came out arms-spread: both arms straight up with the hands together on the skid, facing the fuselage, legs dangling and kicking, a small swing about the skid. The root is placed from where the hands actually are each frame, so they stay on the tube for any avatar.

## 0.14.31
- Crew orbit slots: every gunner flies their own place on the path (Orbit.withSlot / OrbitSlot; lead = slot 0, the rest a quarter turn apart, or one hover station further round). Two AC-130s no longer sit on top of each other. Server fire origins and nukes use the gunner's slot.
- Dead infected never stand there outlined: the death hook now tells rigs from sub-folders by NetId (HumanoidRootPart could arrive after the model, so those rigs were missed), and a rig that arrives already dead still falls.
- Hangar soldiers step round a player standing on their loop instead of stopping behind them (all four used to pile up at spawn with their prompts stacked).
- Bosses' feet stay on the street (EnemyMover lifts a boss so its lowest foot is on the ground; their walk clips dipped them 0.3-2 studs in).
- No more boss roar ("screaming") in the boss intro and boss-move cutscenes: a deep thud instead. The tutorial boss fight's random distant blasts are gone (red flares stay).
- iPad / tablets: the in-game HUD is 35% bigger (weapon cards, abilities, tally, wave bar, bunker bar); the menus are unchanged. Tutorial LOCKED label centred on its card.

## 0.14.30
- Tracking the live "RETURNING TO BASE" bounce on join: every server teleport now logs (server F9) and shows in small print at the bottom of the loading screen which server sent you (role, job id, reserved/public) and why ("no run here", "menu button", "tutorial over", "tutorial", "mission", "join crew").
- Guard: a player who was just sent home and lands on a run server again stays there instead of being bounced again.

## 0.14.29
- Aircraft bonuses (Aircraft.LIST `perk`), shown as a BONUS line on the aircraft bay's spec panel:
  - AC-47 Spooky: +25% cash from kills. UH-1 Huey: +20% gems at the end of a run. AV-8B Harrier: +30% reload speed. AH-64 Apache: +40% damage to Brutes and bosses.
  - MQ-9 Reaper, Mark Target: keeps the boss (or the Brute nearest the bunker) marked with a red diamond; the whole crew does +50% to it.
  - CH-47 Chinook, Resupply: once a wave, 15 s in, every crew gun reloads (not the B-52's nukes) and the bunker gets 10% back; the radio calls it.
- Hangar crew and Capt. Reyes hold a real clipboard (board, sheet, clip) when they play the clipboard animation.
- Airfield trucks follow routes with rounded turns: road to road across the tarmac, or out through the taxiway gap and down the runway (and back). They no longer drive through the blast walls at the end of the roads. The trainee formation run turns across the tarmac too, and trucks wait while it runs.

## 0.14.28
- Spitters animate when they stop to spit: the Toxic rig is R6 and the spit idle / lunge were R15 clips (they never loaded, so it stood frozen). R6 rigs now use Roblox's R6 idle (180435571) and lunge (129967478).

## 0.14.27
- All three guns are ready from the start of every run (40mm and 105mm were locked behind run cash). Only the tutorial still hands them out one by one.
- Red target boxes around the infected on every device, not just phones.
- Infected hitboxes 30% wider and 12% taller than the body: a bit easier to hit.
- In-run FORTIFY / CASH DROP tiles say what they do under their names ("FULL REPAIR + 25 MAX HEALTH", "A CRATE OF CASH FOR GUNS + ABILITIES"); tiles a little taller.

## 0.14.26
- Daily supply drop waits until the upgrade tutorial is done too (not just the mission tutorial), plus a few seconds for Garmin's last line.
- Hangar radio box: low and centred just above the bottom buttons (72% size) instead of the middle of the screen.
- Tutorial arrow: straight (down onto a button, or across from its side), never tilted, 1.4x bigger; on the weapons desk it points at UPGRADE from the left so it no longer sits on the price.
- Lobby pads: the CREATE LOBBY panel gives the host 15 s (countdown in its title, red for the last 5) and then puts them back off the pad with a notice, so a pad can't be held forever.
- Crew bar (PadHUD) sits under the hub's gem bar on desktop instead of at a fixed offset that overlapped it.

## 0.14.25
- Brutes dismember: their R6 limbs are invisible with the muscle parts welded on, so the old code flung invisible limbs. A severed limb now takes every part welded to it (not through the torso/root/other limbs), led by its biggest visible part; cloned pieces drop child models/welds (the Brute's whole body hangs under its Head).
- Tutorial boss fight: a tense boss track (`SoundsUI.BossMusic`, APM "Code Black", 9039723734) crossfades in for the boss and out after; sirens and a slow red edge pulse; distant blasts across the city (105mm-style, fires left burning) and red flares climbing off the skyline.

## 0.14.24
- Tutorial: the nuke is free (a FreeNukes charge instead of topping up cash), and once it has gone off the nuke locks again for the rest of the tutorial.
- Abilities (nuke, repair, A-10...) can't be used once the guns are cold or the run isn't running: at the end of the tutorial you could still nuke from the plane.
- Upgrade tutorial: `NeedFirstUpgrade` is now saved with the profile, so it carries from the tutorial server to the hangar (it was lost on the teleport), and it no longer shows on the tutorial's own server.

## 0.14.23
- Radio box in a run now sits just above the bunker bar (placed from the HUD's Bottom panel each frame) instead of a fixed 200 px up, which covered the bar on some screen sizes.

## 0.14.22
- Tutorial intro cutscene ("FIRST MISSION": the cabin walk into the gunner's seat) plays again on live servers. The tutorial server starts its run the moment you arrive, before GunshipClient is listening, so the State change that triggered it was missed. GunshipClient now also checks on start: in a running tutorial at wave 1 with no kills, it plays the intro once the loading screen lifts (once per join).
- Leaving the tutorial (Settings > LEAVE TUTORIAL) no longer counts it as done: you go back to the hangar for now, and the next time you join the game the tutorial starts again from the beginning (same as disconnecting mid-tutorial).

## 0.14.21
- Gem bar: the + button is bigger and heavier (TextSize 54, was 34) on every gem bar.
- Hangar welders no longer stand inside the aircraft: `HangarPlane` checks that a welder's head, torso and legs are clear of the aircraft (skids, pylons, stub wings stick out past the hull at torch height), backs him off up to 1.5 studs, then tries the next spot (four more spots near nose and tail). Every aircraft still gets its welder(s).
- Hangar: Welder1 re-placed on his stand beside the gunship's hull (mirror of Welder2, other side).

## 0.14.20
- Loading screen: the tip box is taller and the tip text is bigger (up to 28 px, was 16; the TIP label up to 20).
- Downtown: removed the `ThumbScene` thumbnail set and `ServerStorage.ThumbKit`.

## 0.14.19
- Boss animations are live: the 14 boss clips (a walk and a bunker hit for each boss, the Queen's spit) are uploaded to the group and their ids are in `Convoy.AnimIds.Boss`, so live servers play them instead of the animation-pack walks.
- Removed the `AllPlanesUsers` test list (attribute and the check in Mission). Only Studio and the group owner still get every aircraft.
- Downtown: removed the `GFXScene` thumbnail set (city copy, horde and gunship).

## 0.14.18
- Hangar NPC lines no longer stack up: Roblox's DisplayBubble kept every line for 15 s, so one talk showed three bubbles on top of each other. NPCChatter now draws one bubble per person (same white Roblox-chat look); a new line replaces the last one and it disappears when the line is over.
- Upgrade tutorial (after the first mission, in the hangar): Garmin's radio now works in the hangar. "Spend those gems. Hit AIRCRAFT." with the arrow on AIRCRAFT (PLAY also takes you there) -> walks you to the weapons ring at the aircraft bay desk -> "Pick a gun and a stat, then hit UPGRADE" with the arrow on UPGRADE -> after the buy, "That upgrade is yours for every run" and the arrow goes to EXIT, then PLAY ("READY  PLAY"). Same rule as before for who gets it (NeedFirstUpgrade, no upgrades yet, can afford one).
- Bosses: `BossLook.shape` (per-boss body proportions on the same rig) and extra boss pieces are in the code but parked (`NEW_LOOK = false`); bosses look as before. Props now use Welds instead of WeldConstraints.

## 0.14.17
- Map ground (both places): the roads were painted into the terrain, so where a road met the sand the two materials blended into blotchy patches (worse in the thermal view). The whole city floor is now one terrain material (Sand; the road, mud and grass patches were repainted) and the roads are crisp slabs on top: 129 parts in `Workspace.DMZ.Roads`, 30 studs wide on the 150-stud street grid, top at 2.15 (terrain 2.0, road marks 2.22). The 75 `*_DirtRoad` ground meshes under the buildings were removed (they showed through the sand in a checker pattern).
- Hardcore is much harder: 2.2x as many infected per wave (was 1.5x), 1.3x speed with a higher cap (26, was 1.15x / 22), waves arrive in 75% of the time, up to 190 infected at once (135), special types 2.2x as likely (1.4x), specials 1.5x HP, bosses 2.5x HP (1.6x), 1.5x damage to the bunker, and the bunker starts at 50 HP (60). Gems stay 2x.
- Bosses get their own animations (tools/InfectedAnims.luau, BOSSES; rbxmx in art/anim/infected): a walk each (TANK stomp, HIVE waddle, SCREAMER feral sprint, BURROWER crouched scuttle, QUEEN regal glide, LORD march with a pointing arm, TITAN hunched lumber) and a hit on the bunker wall each (TANK stamp-and-hammer, HIVE belly slam, SCREAMER claw frenzy, BURROWER uppercut from below, LORD overhead chop, TITAN two-handed crash); the Spitter Queen spits with her own clip. Bosses used to shuffle at the wall with no hit at all. `BossLook.CLIP` lists them with their strides (played near 1x instead of the pack walks at ~0.36x). Until the clips are uploaded and their ids put in `Convoy.AnimIds.Boss`, Studio plays them from `ServerStorage.Animations` and live servers keep the pack walks.
- Hangar welders: every aircraft gets one welder (two on the AC-47, B-52 and CH-47), standing on the floor (his stand stays behind), on the side you're looking from, torch on the hull; a height scan finds the hull. Sparks and sound only run for a welder who is out.

## 0.14.16
- PROMOTED! pop-up is compact, in the HUD panel skin: badge on the left; PROMOTED!, rank name, bonus and gems beside it (was a tall card with lots of empty space).
- Daily supply drop: a new player gets it when they're back in the hangar after the tutorial (never before it, not on the tutorial's own server), after the loading screen is gone.
- Bosses: no more cutscene the first time a boss uses a move (charging...); every move just shows its banner.
- Phones, lobby pads: the crew bar (name, timer, LEAVE / LAUNCH NOW) is smaller and sits just above the bottom row instead of over the player card and gems; the big sign over the pad you're standing in is hidden while you're in it.
- Phones: the cutscene bars and the helicopter ride's black fade reach the screen edges (GunshipUI no longer clips to the safe area; RideFade ignores the insets).
- Settings sizes itself like the shop: the whole panel scales to fit under the top bar (min(width / (W + 60), (height - top bar - 16) / H, 1.25)), no per-piece fitting or text boost. Set when it opens, on a screen-size change or when the panel grows a row (a first version set it every frame and fought the open animation and the buttons); the general rescale leaves Settings alone.
- New loading screen laid out like Tiny Skies' on black: game name, "RETURNING TO BASE ... 71%" status, a thin cream bar, what it's loading (world / assets / profile), and a TIP box with one of 7 tips.

## 0.14.15
- Store: the 4 game pass icons (Free Nuke, Head Start, 2x Cash, 2x Gems) are the Gemini art now (bomb, cash with arrow, cash stack x2, gems x2) on a dark military tile with the old colored edge; uploaded through the Game Passes API. Files: BlenderExports/StoreIcons/gemini_pass_*.png.
- Tutorial camera fixed: the cabin shots looked up at the roof because the player's cutscene copy (Avatars) had RootHeight 18 (measured from a bounding box before its limbs were placed). R6 RootHeight is always 3 now.
- Downtown has the AC-130 cabin too (copied from the lobby), so the cabin reaction shots in runs work there.
- Tutorial end: the "contact everywhere" horde is much bigger (6 packs at once, then a pack of 12 every 0.4 s, up to 260 infected); the two A-10 gun runs are back (the first with its street cutscene) in place of the artillery; once the Little Bird comes for the survivors your guns are cold (CeaseFire, checked on the client and the server).
- Settings: LEAVE TUTORIAL during the tutorial (the LEAVE MATCH row, relabelled). It ends the tutorial, counts it as done, and takes you back to the hangar.
- Weapon cards: the gun in hand has one even 2 px yellow frame; the thick left strip is gone.
- Hangar walkers walk round someone who stopped instead of queueing behind them (the queue bunched them into one line that never spread out), wait a beat before stopping for you (no stop-start twitch), and get standard R6 joints.
- RANKS button: the insignia sheet is preloaded and the badges are re-applied whenever the hub shows.
- FORTIFY and CASH DROP (HUD tiles and pop-up offers) use the Gemini art again: images 124142059269349 and 129069834896307 (Shop.BATTLE).
- Pop-up offers (CASH DROP, FORTIFY, INSTANT NUKE) and the "X called in..." toast use the HUD panel skin like the FORTIFY / CASH DROP tiles: dark body, 1 px edge, hazard strip, accent strip on the left, white name, solid green buy button, tighter layout (tools/patches/battle_offers_skin.lua). The Second Chance panel is unchanged.
- Cleanup (both places, about 4,200 instances each): removed old backups and dead code. ServerStorage: AC130_MeshOld, A10_MeshOld, MeshCars_Old, OldUI, OldModels, Dummy_Original, RBX_ASSISTANT_ANIMGEN, Welding Mask, SurfaceTexturePack, BlenderImports, GunKit. StarterGui: ConvoyHUD, GunshipUI_MilitaryOld. Disabled scripts: ConvoyClient_OldConvoyMode, ConvoyHUD, GunshipUI_MilitaryOld, AirbaseLife, ConvoyServer.Main, Mission_Endless_Old. Kept: CityKit, BuildingKit, Parked_NotInGame + the parked Missions code, ConvoyTemplates, MapProps, the animation showcases.
- The real cause of the shop / RANKS icon / aircraft screen breaking now and then: the hub template was StarterGui.GunshipUI, and Roblox's copy of it on spawn had the same name, so a script's WaitForChild("GunshipUI") could grab that copy, which the server deletes a moment later (errors like "Badge is not a valid member of Plate"). The template is now StarterGui.GunshipUI_Template; GunshipUI clones it in as "GunshipUI" and the copy guard removes the template copy.
- Map ground flicker: the 75 building foundation slabs (`*_DirtRoad`, 0.4 thick) had their tops at 1.5-2.05, right where the terrain surface is (2.0), so slab and terrain fought. They sit at top 1.2 now, under the terrain (both places).
- Step pads (SHOP, RANKS, AIRCRAFT, WEAPONS) find the screen opener whenever it's ready instead of giving up after 30 s; a failed layout pass can no longer lock every screen change.

## 0.14.14
- Phones: AUTO-FIRE ON/OFF in Settings. GunshipUI already handled a row named AutoFire (touch devices only, saved with the profile), but the row was never in the UI and GunshipClient's auto-fire ignored the setting: the row is now in Settings (a copy of MUSIC) and auto-fire stops when it's OFF (the FIRE button still shoots).
- No JUMP button in a run: new RunNoJump turns jumping off while you're on the HUD (Roblox's touch controls hide the button with it; it sat under FIRE on phones) and back on after.

## 0.14.13
- Shop: the bundles and gifts are real products now (they all said SOON: their product ids were 0). Starter Bundle R$99 (3735303112), Gunship Bundle R$399 (3735303229), and a gift product per gem pack and pass at the item's own price (500/1,500/5,000/15,000 gems, 2x Gems, 2x Cash, Free Nuke, Head Start). Ids in Convoy.Shop.
- LAUNCH NOW on a lobby pad goes out on the helicopter too (run, jump, hang, fly off), and the teleport comes when the ride is over; before, it teleported straight away.
- Downtown: no more errors on join from the hub screens (AircraftUI, LobbyHUD, RanksUI): they only run in the lobby place.
- Infected use our animations in the game: each one walks with SPRINT (55%), ARMS OUT (20%), SHAMBLE (15%) or LURCH (10%), at a pace that suits it (x1.1 / 0.75 / 0.6 / 0.6 of the base speed) and with the clip played at the rate its feet cover the ground. At the bunker wall they POUND, CLAW or RAM it (looped) instead of shuffling. 7 R15 clips uploaded to the group (tools/build_infected_rbxmx.py -> art/anim/infected). Tutorial infected all sprint.
- Buttons always grow from the middle: ButtonFeel now watches every scale a screen tweens on a button (its "Press" or a plain UIScale) and holds the button at its middle while it's off 1, whatever script tweens it.
- Repair, artillery and the nuke cost more each time you use one in a run: +50% of the base price per use (Repair 250 > 380 > 500...). Uses are player attributes (Uses_<name>), reset every run; the HUD cards show the current price.

## 0.14.12
- People are R6 with their own animations (fwjelaa's method). New `Convoy.R6Clips` (source tools/R6Clips.luau): 21 R6 clips written as poses, converted to each R6 joint, uploaded to the group as Animation assets (ids in `AnimIds.R6`; rbxmx built by tools/build_r6_rbxmx.py into art/anim/r6). In Studio a clip without an upload is built on the fly.
- Lobby pads: the run for the helicopter, the jump and the hang off the skid by one hand are clips now (R6_Run, R6_HeliJump, R6_HeliHang) instead of posing the shoulders and hips; the hand stays on the skid.
- AC-130 cabin: the gunner walks up, turns his back to the seat and sits down into it (R6_GunnerSitDown), then works the console (R6_GunnerSeat). The players' cutscene copies (Avatars) are built R6 like the players.
- End of the tutorial: the three survivors are R6 (new Models.R6Survivor1-3, the civilians' colors), run to the Little Bird, back up to the bench, push up and sit (R6_BenchClimb), then ride with their legs swinging (R6_BenchRide). Seats come from the benches themselves.
- Hangar: crew walk (R6_Walk), idle, point, marshal the gunship in, go down a checklist; pilots talk / check their list; the General stands at parade rest; walkers talk with their hands when they stop for you; welders weld / weld overhead with the clips (no more hand-posed shoulders); the coffee table sits properly (their pre-bent hips are reset), sips and laughs (and laughs after a story); booth clerks lean on the counter and wave when you walk up.
- Models.Soldier is now an R6 hangar crewman (the old R15 one is in ServerStorage.OldModels).
- Showcase: `ServerStorage.CrewAnims` (lobby) shows every R6 clip looping in Edit mode: `require(game.ServerStorage.CrewAnims).showcase()` / `.clear()`. Both showcases are cleared.
- Still R15: infected (as asked), the tutorial's ground civilians, the Garmin portrait and the parked Missions operators.

## 0.14.11
- Infected animations, made with fwjelaa's method (FWJ STUDIOS, make-anim pack): `ServerStorage.InfectedAnims` (source in tools/InfectedAnims.luau) writes 7 R15 clips as poses over time and builds them into KeyframeSequences in `ServerStorage.Animations`. Walks (loops): SHAMBLE (limping, head lolled), ARMS OUT (classic stiff zombie), SPRINT (bent forward, flailing), LURCH (twisted, dragging a foot). Bunker hits (Action, Hit markers on contact): POUND (two-fist hammer), CLAW (right then left swipe), RAM (shoulder slam). Legs are keyed against the vertical (the hips' lean/roll is taken out of them).
- Showcase in Downtown's Workspace (`InfectedAnimShowcase`, floating at -2400, 400, 150): each clip on one of our real infected rigs, looping in Edit mode with no Play (AnimationClipProvider + Animator:StepAnimations). Command bar: `require(game.ServerStorage.InfectedAnims).showcase()` / `.stop()` / `.clear()`. Not wired into the game yet; clear the showcase before publishing.

## 0.14.10
- Hub SHOP / RANKS / AIRCRAFT buttons walk you to the yellow ring and let the ring open the screen; the button only opens it itself if the ring didn't and you're still standing there. Walking straight back out no longer leaves a screen opening behind you (no more empty dimmed screen with the UI gone).
- NPC chatter cut way down: one line every 12-20 s from someone near you, then that person is quiet for 40 s, and no line repeats until 6 others have been said (no more the same line twice back to back). The coffee table talks every 35-60 s.
- Downtown synced with everything since 0.14.6 (LoadingScreen, Lobbies, GunshipClient, AircraftBay, GunshipUI, NPCChatter): both places' scripts match again.

## 0.14.9
- Aircraft bay shows planes at true size next to a player: each is scaled to its real length (rotors included) at 0.88 studs a foot (the AC-130 / Apache build scale), then shrunk only if wider or longer than 70 studs (FIT, was 52; the shutter doors are 73 wide). True size now: Apache, Harrier, Reaper, Huey (+21%). Still shrunk to fit: Chinook (81%), Spooky (82%), AC-130 (64%), B-52 (44%). Lobby place only (the bay isn't in Downtown).

## 0.14.8
- The loading screen waits for the lighting before it lifts: the sky (everything under Lighting) is preloaded with the rest, GunshipClient sets HubReady after 30 frames with your character in and our camera / hub lighting in place, then 1.2 s more for lights and shadows to build. (Capped at 10 s of waiting.) Lobby place; sync LoadingScreen + GunshipClient to Downtown.

## 0.14.7
- New players go into the tutorial in one load: the hangar server sends them on as soon as their profile is in (no 2 s wait), and their loading screen stays up ("STARTING TRAINING", 100%) until the teleport takes them, so they never see the hangar flash by in between. Held for 25 s at most if the teleport fails. (LoadingScreen, Lobbies; lobby place. Sync both scripts to Downtown next time it's open.)

## 0.14.6
- Buttons no longer go "whacky" on hover (armory list, LEAVE / LAUNCH NOW, weapon cards...). New `Convoy.HoverAnchor`: the grow-from-the-middle anchor move only lasts while a hover / press / pop / tutorial pulse runs, and if any script moves, re-anchors or resizes the object meanwhile, it is handed straight back as that script meant it. ButtonFeel and GunshipUI (hook, pop, tutorial pulse) use it; nothing is re-anchored for good any more. Weapon card placement back to the plain version.
- Artillery: you can see the shells come in. The server picks every landing spot up front and sends them with the "arty" FX; FXLib flies a glowing shell with a fiery trail in from far off (steep, from the base's side) onto each spot, landing on the beat of its blast (ARTY_LEAD, then every 0.28 s).
- Artillery call-in mark: red rings drawn on the screen (so the black-and-white thermal view can't grey them): a pulsing red ring at the edge of the barrage and two red rings pulsing out from the middle, fading at the end. Replaces the grey neon disc.
- Tutorial nuke plays the full NUKE AWAY cutscene (ride the bomb down, the blast across the city), both when you press it and when it goes on its own; the tutorial waits 9 s after it. Runs still show just the blast from the gunship.
- CIV HITS reset every 10 waves (at the start of waves 11, 21, 31...).
- Battle offer cards never sit lower than the weapon panel's own top (they could cover the top weapon card).
- Aircraft flying over the base spin their rotors, tail rotors and props (OutsideLife; same rig rules as the results flyby).

## 0.14.5
- Tutorial pointer is now a plain yellow ">" with a black stroke, tilted to point down at the thing to press (sits up-left of the weapon cards, up-right of the abilities, above PLAY / UPGRADE), bouncing along the way it points. Replaces the arrow image.
- Bunker compound rebuilt to match the new bunker (CityDetail.Compound, both places; tools/build_compound.luau): concrete walls with an olive base and dark cap, hazard-banded gate posts with sandbags, four olive watchtowers (no more red roofs or yellow wall tops), two dark helipads with a yellow edge, H and green corner lights, and two small supply dumps. Same footprint, roads still open. Every main part has the surface textures on all sides (studs on top, inlets under, weld or universal on the sides), like the bunker.

## 0.14.4
- Gem packs cheaper (Roblox prices): 500 = 25, 1,500 = 69, 5,000 = 199, 15,000 = 499 R$ (were 49 / 129 / 399 / 999).
- VIP is now FREE NUKE: same game pass (2094034947) and key (Pass_VIP), so owners keep it. Every run starts with one free NUKE ALL (FreeNukes = 1; the server now honours FreeNukes). The +25% gems / cash is gone. Pass renamed, new description and icon (art/store/pass_free_nuke.png); shop cards and base chatter updated.
- Weapon cards no longer jump left when you pick a gun: the hover feel moves a card's anchor to its middle, and refreshSlots now places them by their anchor.
- NEW: <type> banners show the infected's portrait (type_runner, type_bomber...) left of the title instead of a text glyph.
- WHEELS UP takeoff cutscene removed (the helicopter ride replaced it). RETURNING TO BASE aims at workspace.DMZ's BaseLook when there's no hangar.
- Downtown trimmed: hangar and tutorial cabin deleted (23.9k -> 13.5k instances), the spawn kept as DMZ.MapSpawn, hangar-only client scripts disabled there. Lobbies no longer waits forever for a hangar.
- Downtown: the airbase land east of the city's hills is gone too (terrain x 3980-9984, z -3328-4096 cleared); MapSpawn moved onto the back of the east hills (3820, -75, 150).

## 0.14.3
- The tutorial runs on a reserved server of the lobby place (the hangar), not Downtown; Lobbies treats a reserved lobby server as a "Mission" server. Loading title says TRAINING.
- From now on every edit goes into both places (lobby + Downtown) directly; no more re-copying.

## 0.14.2
- FORTIFY and CASH DROP tiles back on the original flat icons (the Gemini ones didn't match the rest).
- Cutscenes clear the screen: while one plays (RETURNING TO BASE, takeoff, boss intros...) every other screen of ours (results...) and our other GUIs (offers, toasts, alerts) are hidden, and come back as they were after.

## 0.14.1
- Loading screen says where you're going and how far along it is: "DEPLOYING TO DOWNTOWN", "RETURNING TO BASE" or "LOADING", a yellow bar and a percentage (0-80% instances received out of the server's count, a Workspace attribute set by Lobbies; 80-95% assets downloaded; 95-100% your save). The server sets the player's TeleportTo before each teleport so the screen carried across already has the right title.
- Infected lose a limb or two when they die (sometimes the head, with its hats): copies fly off, tumble, land and fade with the body; a dark stump cap and a few dark bits. Civilians and bosses stay whole (GunshipClient corpses).
- Brutes walk like brutes: 1.7x longer strides (slower legs) on the server, and on the client a heavy lurch (hunched, rolling onto each leg, sinking on every step; EnemyMover).
- In-run gun tiers cost 30% more (TIER_BASE 400 / 650 / 1050, was 300 / 500 / 800).
- ButtonFeel: buttons grow from their middle, not the top-left corner (anchor moved to the centre, same spot on screen; not inside layouts).

## 0.14.0
Lobby and maps are separate places (step 1: the code).
- `Convoy.Places`: LOBBY = 108596658459731 (start place, the hangar), MAPS = { Downtown = 70728469839345 }, DEFAULT_MAP.
- Lobbies: a server of a map place is always a "Mission" server; the lobby place is always "Lobby". PLAY (and the tutorial) reserve a server of the crew's map place; LOBBY / the tutorial's end / joining a crew on another hangar server go to the lobby place. Someone on a map server with no run to play is sent back to the hangar after 12 s.
- Favourite prompts favourite the lobby place.
- Both places run the same code for now (Downtown starts as a copy of this place); trimming each place (no city in the lobby, no hangar in Downtown) comes next.

## 0.13.60
- Faster loading: the terrain's unseen underground (solid down to y = -1024 under every hill and mountain) is hollowed out. Each 128-stud square keeps 28 studs of ground under the lowest surface of itself and its 8 neighbours (so no cliff face opens up), and the AC-130 cabin set underground is left alone. 247M -> 80M terrain cells; every join and every run (a teleport to a new server) loads that much less.
- The whole Hangar model had been moved by accident (+83.85, +3.41, -2): moved back. That's why PLAY sent you outside, players got pushed out, and the walkers looked sunk into the floor.
- Hangar NPCs can't push players: new "NPC" collision group (doesn't collide with Default or itself), set on every character model in the world and by `NpcNoPush` (client) on the ones scripts clone in.
- `ButtonFeel` (client): every GUI button grows on hover, dips on press and ticks on hover like the hub's (Shop, Daily, offers...). Buttons with their own feel are left alone; "Hit" overlay buttons move their card. GunshipUI's hook tags its buttons (FeelSound) so nothing ticks twice.

## 0.13.59
- Aircraft Robux unlocks are live: products created (AC-47 3735039493 125 R$, Huey 3735039651 175, Reaper 3735039761 249, Harrier 3735039873 299, Apache 3735039978 379, Chinook 3735040075 499, B-52 3735040151 659; managed pricing off) and set in `Shop.PLANE_PRODUCTS`. The aircraft bay shows UNLOCK NOW for any aircraft you don't own (same font as the EQUIP button).
- Dashboard: Emergency Repair renamed FORTIFY with a new description; Fortify and Cash Drop use the new Gemini icons.

## 0.13.58
- SKIP on a rank objective now completes it (toast, and the promotion if it was the last one) instead of rolling a new one. The Skip Objective product (3734067874) is 10 R$ now (was 25), with a new thumbnail and description (art/products).
- Aircraft can be unlocked with Robux in the aircraft bay: a green UNLOCK NOW button above the bar for any aircraft you don't own, no rank or gems needed (`Shop.PLANE_PRODUCTS`: AC-47 125, Huey 175, Reaper 249, Harrier 299, Apache 379, Chinook 499, B-52 659). The server grants it on purchase (owned, equipped, saved). The buttons stay hidden until the product ids are filled in: the products still have to be created (thumbnails ready in art/products).
- SHOP button walks you to the shop stand first (like RANKS and AIRCRAFT).

## 0.13.57
Weapon upgrades fit what the weapon fires (`Upgrades.weaponClass`, `statText`, `tierText`; same saved stats Up_<slot>_Radius/Rate/Reload):
- GUN (7.62 miniguns, 25mm GAU-12 and Harrier cannon, 30mm chain gun): bullets, so no growing blast (each round keeps its small one). Radius is now ROUND DAMAGE (+20% damage per level), Rate is FIRE RATE, Reload is RELOAD SPEED or, on belt-fed miniguns, COOLING (-12% heat per round). In-run tiers: fire rate, magazine, reload and +8% damage; tier 3 AP, tier 5 API (+25% damage) instead of HE, tier 7 incendiary.
- SHELL (40mm Bofors, 105mm, 40mm grenades): BLAST RADIUS / FIRE RATE / RELOAD SPEED as before.
- ROCKET (Hydra): BLAST RADIUS / SALVO RATE / RELOAD SPEED.
- MISSILE (Hellfire): WARHEAD (+12% blast and +15% damage per level) / LAUNCH RATE / RELOAD SPEED.
- BOMB (Mk-82, B-52 bay): BLAST RADIUS / DROP RATE / RELOAD SPEED.
- Server: per-player damage multiplier per gun (`crew.dmgMul`) used for round hits and blasts. Armory tabs, titles, descriptions, values and icons (damage icon for ROUND DAMAGE) follow the class of the gun on the aircraft you fly; the HUD tier label, tier banner and tier tooltip too. The Armory's values now read the aircraft's own gun numbers.
- GunSwap on other aircraft swaps the right weapon: rocket pods, missiles or bombs (their loose parts), the Harrier's cannon pod, otherwise the Guns group. (Upgrading Hydras swapped the chain gun before.)

## 0.13.56
- New icons for the in-run Robux offers, made in Gemini by Jacob, background cut out (art/battle/cut.py): FORTIFY (wall, wrench, green plus, sandbags) image 124142059269349, CASH DROP (crate of cash on a parachute) image 129069834896307. Used by the quick-buy tiles and the offer popups (Shop.BATTLE icons).

## 0.13.55
- Weapon upgrades in the Armory swap the gun on the parked aircraft, VTOL VR style (`StarterPlayerScripts.GunSwap`, client): impact-wrench unscrew + spark bursts, the old gun drops off the side tumbling, clanks on the floor and fades, the new one slides in from outside, clunks home and is screwed on (wrench, three spark bursts with the welders' crack). AC-130: that gun (GAU12 / Bofors / Howitzer); any other aircraft: its Guns group. New sounds SoundsUI.Unscrew (9117706213) and Screw (9117707273).
- Infected that reach the bunker stay at the wall hitting it until they're shot (a fifth of their old arrival damage every ~2 s; the wave isn't over while they're there). Bombers still go off at once. They stop just outside the bunker's plinth (ARRIVE_RADIUS 13 -> 18.5).
- TOO MANY CIVILIANS HIT ends the run 2.5 s after the third hit, so you see the round land first.
- `PassesOffUsers` on Convoy ("4263620304" = Jacob): those players play without their passes (2x cash, 2x gems, VIP, head start); remove the id to get them back. Ownership isn't touched.
- Stepping back out of a hangar pad's yellow ring closes the screen it opened (Shop, Ranks, Aircraft, Weapons).

## 0.13.54
- Helicopters fly like themselves (`Orbit` cfg.Style): the Huey flies a slow, low pedal turn round the target with its door side facing in (no more station hops); the Apache hovers nose-on and sinks 26 studs behind cover to move between five stations, popping back up to shoot; the Chinook sits broadside (side guns), moves slowly and sways. Every hovering aircraft leans into its motion (nose down accelerating, banking into a slide) with a little idle wobble.
- 30mm chain gun (and every gun in the small-gun slot): each round only shows a small pop now. Its blast radius had grown with tiers and BLAST RADIUS upgrades and the server sent a fireball per round. Damage radius unchanged.

## 0.13.53
- SECOND CHANCE also comes up when a run ends on TOO MANY CIVILIANS HIT (not only when the bunker falls): buying it puts the civilian hits back to zero and the run goes on. The panel says which (`SecondChanceWhy` = CIV / BUNKER).
- The Robux repair is now FORTIFY (same product 3734051090, 25 R$): full health, +25 max bunker health for the rest of the run (up to double) and a blast that clears the infected at the walls. The $250 REPAIR ability is unchanged.
- In-run Robux tiles (FORTIFY, CASH DROP) in the HUD panel skin: dark body, 1 px edge, hazard strip, accent strip on the left, white names, a solid green price button (no pale cream inner outline).
- Main-action buttons (UPGRADE, PLAY AGAIN, BUY...) keep a solid face: MilitarySkin no longer turns a button with dark text into a dark plate (it looked disabled); only its border goes a shade darker.

## 0.13.52
- Bunker rebuilt in the hangar's style (`DMZ.Bunker`, same Center/pivot): steel plinth with a hazard edge, olive block with tan inset panels and an olive wainscot, dark corner posts with yellow/black collars and green beacons, a blast door on each side (hazard frame, ribs, yellow light strip), sandbags, and a roof with a hazard edge, a yellow light line under the lip, a hatch, AC units, radio mast and dish, and a sandbag nest. Studs/Weld/Universal/Inlet surfaces. The old one is in ServerStorage.Parked_NotInGame.Bunker_Old_v013.
- Selected weapon key: the dark outline on the dark number (yellow box) is off, so the number reads instead of a blob.
- Special infected sized from their rig's own scale: the Brute template is at 0.4, so ScaleTo(1.75) made it about 4x too big and half in the ground. Now 1.75x the rig.
- Objective / promotion toasts use the HUD panel skin: dark body, 1 px edge, hazard strip on top, a lime tick block (amber bar for a promotion), thinner text outlines; no thick coloured border.

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
