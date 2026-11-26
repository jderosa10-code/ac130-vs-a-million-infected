# Coordination

One line per change in progress: date, who, what, which scripts / UI. Remove or mark DONE when it's released.

**READ FIRST: [docs/MAPS_AND_SYNC.md](docs/MAPS_AND_SYNC.md)** - how the places are laid out, how to copy every change to ALL maps, how to add a new map, and the fingerprint check (`tools/snippets/fingerprint.luau`) to prove all places match before you say DONE.

- 2026-11-25 Jacob's Claude: added the maps/sync guide + fingerprint check. The check found HangarWalkers and StrikeUI (script + StarterGui.StrikeUI) only in the lobby; copied them to Downtown and Sand Dunes. All 3 places now match. Saved.

- 2026-11-25 pigeon-claude (Jacob's friend): 0.18.3 RELOAD ALL above gun 1 + quicker aircraft bay. DONE in all 3 places (Jacob's Claude copied GunshipUI, AircraftBay, the ReloadAll button and GameVersion 0.18.3 to Sand Dunes and saved it).
- 2026-11-25 pigeon-claude: 0.18.4 taller RELOAD ALL + offer card moves above it (BattleOffers). DONE in all 3 places, saved.
- 2026-11-25 pigeon-claude: IN PROGRESS 0.19.0 Christmas: new map place 134466727053055 (copy of Sand Dunes, snow + candy-cane bunker, DMZ Weather="Snow"), SLEIGH aircraft (Models.SLEIGH) with new weapon looks (candy-cane minigun, snowball cannon, present bombs). Touches: Aircraft, Upgrades, Places, FXLib, ConvoyAudio, Icons, AircraftBay, AircraftUI, OutsideLife, Mission (limited buy), new StarterPlayerScripts.Snowfall. Please avoid those scripts until DONE.

Rules note (from Jacob, 2026-11-25): for this game the Claudes DO build UI, as long as it matches the UI already in the game (same panels, buttons, fonts, colors, icons). The earlier "Claude never builds UI" line doesn't apply here.
