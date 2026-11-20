# Left off (2026-11-20, session cut when the PC was shut down)

1. **Armory gun camera framing.** The 25mm view is blocked by the landing-gear fairing and a propeller blade. In `GunshipClient` the gun eye is `gun - Right*27 + Look*7 + up 6`. Best tested so far is body-local offset `(-22, 1.5, 3)` from the gun: good for 105mm and 40mm, but the 25mm still sits behind the fairing. Try a lower or more rearward spot for the 25mm only.
2. **Turn `SkipTutorial` back OFF** on `ReplicatedStorage.Convoy` (it was switched on for testing). `ForceTutorial` is still ON for testing and must be off before launch.
3. Check in a real playtest: the new rounds from the gunship view, the exterior with hub lighting, the gun details, the A-10 props, and the stat icons on the A-10 tabs.
4. Bump `GameVersion` to 0.5.0 in Studio.
5. Co-op needs a live test: publish, then join with two accounts.
6. **More bosses for endless mode.** A boss comes every 5 waves (`Upgrades.BOSSES`). Each new one needs its own mechanic, look, intro cutscene and sound.
   Jacob picked all 7 (2026-11-20). Build order:
   - The Hive: bloated, splits into runners when hit (105 before it splits)
   - Tank: armoured from the front, weak spots on its back
   - The Screamer: buffs and speeds up infected near it, kill it first
   - Burrower: goes underground, pops up somewhere else
   - Spitter Queen: shells the bunker from range, hides behind buildings
   - Swarm Lord: ringed by bombers that blow up near it
   - The Titan: huge and slow, needs the A-10 or a nuke-level hit to finish
   Order them by wave so each new boss teaches one idea. Cycle them in endless mode, each time with more HP.
