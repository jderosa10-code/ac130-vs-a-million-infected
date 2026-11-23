# 0.14.15 script edits (applied in both places)

- ServerScriptService.ConvoyServer.Avatars: RootHeight is a fixed 3 (R6) instead of a bounding-box measure.
- ServerScriptService.ConvoyServer.Mission (tutorial):
  - horde: `hordeT >= 0.4 and #Enemies.list < 260`, `pack(12, 17, 12)`, 6 packs at "Contact everywhere".
  - step 9: two `bestA10Run` / `callA10` runs (first sets CutAt + CutKind "A10|...") instead of artillery.
  - `setAttr("CeaseFire", true)` before the Rescue cutscene; reset at the end and on error. GunshipFire ignored while on.
  - `tutQuit` + Action "LeaveTutorial" (pilot only): ends the tutorial, sets TutorialDone = 1 and saves.
- StarterPlayerScripts.GunshipClient: no GunshipFire while Convoy.CeaseFire.
- StarterPlayerScripts.GunshipUI: LEAVE MATCH row shows as LEAVE TUTORIAL in the tutorial (fires LeaveTutorial);
  selected weapon card = 2 px edge, Strip hidden; `show()` pcalls rescale/slideIn so `switching` can't stick.
- StarterPlayerScripts.HangarWalkers: pass round (2.6 stud side step) instead of queueing; 0.3 s before stopping for the player; R6Clips.standardJoints.
- StarterPlayerScripts.LobbyHUD: preload Ranks.SHEET, refresh on Menu visible / ProfileLoaded.
- StarterPlayerScripts.StepPads: finds GunshipUI.OpenScreen every frame until found (was a 30 s WaitForChild).
- Downtown: Workspace.DMZ.Cabin copied from the lobby (SerializationService through a DataStore key DevTransfer/Cabin).
