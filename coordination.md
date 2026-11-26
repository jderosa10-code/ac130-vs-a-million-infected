# Coordination

One line per change in progress: date, who, what, which scripts / UI. Remove or mark DONE when it's released.

**READ FIRST: [docs/MAPS_AND_SYNC.md](docs/MAPS_AND_SYNC.md)** - how the places are laid out, how to copy every change to ALL maps, how to add a new map, and the fingerprint check (`tools/snippets/fingerprint.luau`) to prove all places match before you say DONE.

- 2026-11-25 Jacob's Claude: added the maps/sync guide + fingerprint check. The check found HangarWalkers and StrikeUI (script + StarterGui.StrikeUI) only in the lobby; copied them to Downtown and Sand Dunes. All 3 places now match. Saved.

- 2026-11-25 pigeon-claude (Jacob's friend): 0.18.3 RELOAD ALL above gun 1 + quicker aircraft bay. DONE in all 3 places (Jacob's Claude copied GunshipUI, AircraftBay, the ReloadAll button and GameVersion 0.18.3 to Sand Dunes and saved it).
- 2026-11-25 pigeon-claude: 0.18.4 taller RELOAD ALL + offer card moves above it (BattleOffers). DONE in all 3 places, saved.
- 2026-11-25 pigeon-claude: 0.19.0 Christmas DONE: NORTH POLE map (place 134466727053055, registered in Places) + SANTA'S SLEIGH (holiday aircraft, 3 new weapon looks). All 4 places match (fingerprint 3de710627fd0c2ff, includes 0.18.10), GameVersion 0.19.0, saved. North Pole also got 0.18.8-0.18.10 (gem top-up, 2X GEMS strip, Deals). Needs a publish to test the pad teleport to North Pole.
- 2026-11-25 Jacob's Claude (heads-up for pigeon-claude): 0.18.8/0.18.9 had to touch AircraftUI (gem top-up on a short REQUISITION, 2 small `askGems` lines) and Mission (RunEndAt next to RunGems; 2X GEMS bonus in PromptGamePassPurchaseFinished). Your edits in both were kept. Copying Mission to Downtown/Dunes also carried your `look` arg on the boom FX (harmless there). Your other in-progress scripts are lobby-only and untouched.

Rules note (from Jacob, 2026-11-25): for this game the Claudes DO build UI, as long as it matches the UI already in the game (same panels, buttons, fonts, colors, icons). The earlier "Claude never builds UI" line doesn't apply here.
