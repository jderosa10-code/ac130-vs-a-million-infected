# Maps and keeping every place in sync

This guide is for any Claude (or person) working on Gunship vs a Million Infected. It covers how the places fit
together, how to add a new map, and how to make sure every change reaches every place. Read it before your first
change, and read `coordination.md` before every work session.

## 1. How the game is split

One universe (10777953252, group "Hanger 9") with one place per job:

| Place | Id | What's in it |
|---|---|---|
| Lobby / hangar | 108596658459731 | The start place: the hangar, crews, shop, ranks, aircraft, mechanic. Its Workspace also has the Downtown map, so Studio's "Deploy" works here. **This is the script master.** |
| Downtown | 70728469839345 | The city map |
| Sand Dunes | 88208849422941 | The desert map (night, fog ring, terrain dunes) |

The ids live in `ReplicatedStorage.Convoy.Places`.

**Every place runs the same code.** The scripts, modules and UI are copies of each other in all places:
- ServerScriptService.ConvoyServer
- ReplicatedStorage.Convoy, including Models, Sounds and modules
- StarterPlayer.StarterPlayerScripts
- StarterGui

What differs per place is only:
- **Workspace.DMZ:** the map itself, its bunker, props and spawn.
- **Workspace.Terrain.**
- **Lighting**, including its Thermal* attributes.
- **A few one-off objects that only live in the lobby:** the hangar, Mechanic, Workbench and booths.

The code works out which job it's doing from the place it runs in (`Lobbies.role()`: Lobby, Mission or Studio).

**Map-specific behaviour** is switched by attributes on `Workspace.DMZ`, never by checking the place id:
- `Map`: `"Dunes"` turns on terrain-height ground for the infected, the fog-ring spawns, the breach cutscene, infected/civilian highlights drawn on top, and target boxes that ignore terrain. Unset means a city map like Downtown.
- `Facing`: a Vector3, the direction the bunker faces.
- `FogShape`: a string `"n,amp,phase;..."`, the wobble of the fog ring.
- `BaseLook`: where the lobby camera looks.

Search the code for `GetAttribute("Map")` to see every map switch.

## 2. The golden rule: change it everywhere

A change that's only in one place is a bug: players hit it as soon as they teleport. Every change follows this order:

1. **Edit in the lobby first.** It's the master, so the latest version of every script is always there.
2. **Test in the lobby with Studio's play button.** Use "Deploy" to start a run there.
3. **Copy every changed thing to Downtown and Sand Dunes,** and to any new map. That includes:
   - every script/module you touched (copy the whole Source, never re-type an edit by hand in another place)
   - any UI you added or changed in StarterGui
   - any model you changed in ReplicatedStorage.Convoy.Models
   - Lighting or DMZ attributes, if the change is meant for every map
4. **Bump the version:** `VERSION` file, a `CHANGELOG.md` entry at the top, and the `GameVersion` attribute on `ReplicatedStorage.Convoy` in every place.
5. **`save_place` in every place.** Never publish yourself: Jacob publishes.
6. **Commit and push the repo.** `git pull --rebase` first. Update `coordination.md` too.

If you can't reach a place (it isn't open in Studio, or the copy fails), say so in the CHANGELOG entry and in `coordination.md` (for example "STILL TO DO: Sand Dunes"). Then tell Jacob, so someone finishes it.

### How to copy

**Scripts (the normal way): the DataStore `DevSync_tmp`.**
- In the lobby: `DataStoreService:GetDataStore("DevSync_tmp"):SetAsync("<key>", script.Source)`.
- In each other place: `script.Source = ds:GetAsync("<key>")`.
- In the last place: `RemoveAsync` every key you used.
- This needs Studio access to API services, and an account with edit rights on the universe. If you get "Access forbidden", ask Jacob for those permissions, or ask Jacob's Claude to copy it for you.

**UI and models.**
- DataStores can't hold Instances. Serialize them first:
  - UI: walk the tree and save each object's class, name, parent index and its relevant properties.
  - Parts of a model: save Name, ClassName, Size, CFrame components, Color, Material, MaterialVariant, Transparency, Shape and the six surfaces.
- Store that table under a key, then rebuild it in the other place.
- Look in the CHANGELOG for "serialized" to see where this was done before.
- Simpler option for big one-off UI: ask Jacob to copy-paste it in Studio.

**Check it worked.**
- Run `tools/snippets/fingerprint.luau` in every place and compare the output.
- Any line that differs means that script isn't in sync.

## 3. Adding a new map

1. **Make the place.** Jacob does this: Asset Manager > Places > Add New Place in the universe. Get its place id. Never publish over an existing place.
2. **Start from a copy of a map place.** Downtown for a city-type map, Sand Dunes for an open or terrain map. That way it already has every script, all the UI and the right ServerScriptService. Sand Dunes was made from a copy of Downtown with the city removed.
3. **Build the map in Workspace.DMZ.**
   - Keep these children, which the code looks for:
     - `Bunker`, the thing the infected attack
     - `MapSpawn` and the invisible `SpawnFloor` under it, so players don't fall and respawn
     - `Helipad`, `Cabin`, and the `Path` / `Start` / `Exit` / `RouteProps` folders
     - for city maps: `EnemySpawns`, `Buildings`, `Destructible`, `Roads`
   - Set the DMZ attributes from section 1. Add a new `Map` value only if the map needs new behaviour. Then handle that value everywhere `GetAttribute("Map")` is read.
   - Use only the team's textures: stud, inlet, weld and universal surfaces, their MaterialVariants, and Roblox terrain for sand, grass and the like. No barcode-, QR- or URL-like patterns in any texture.
   - Keep terrain smooth. Small sharp bumps make Roblox's far-away low-detail terrain look like a second layer on top (fixed on Sand Dunes in 0.18.7).
   - Make sure nothing floats and nothing overlaps flush. Flush overlap causes z-fighting.
4. **Lighting.** Set the look, plus the Thermal* attributes the thermal sensor uses: `ThermalClock`, `ThermalBrightness`, `ThermalOutdoor`, `ThermalAtmColor`, `ThermalAtmDecay`, `ThermalAtmOffset`, `ThermalAtmHaze`.
5. **Register the map in `ReplicatedStorage.Convoy.Places`**, in every place, because Places is shared code:
   - add it to `Places.MAPS` (name = place id)
   - add it to `Places.ORDER`, which is the lobby pad's map card order
   - add it to `Places.INFO`: title, sub line and the card `image`. Upload the card picture: Studio's `upload_image` only takes http URLs, so serve the file from a temporary local `http.server` (for example in Jacob's Blender Python), then shut the server down.
6. **Test.**
   - In the new place: press play and use Deploy. Play through a wave and a boss wave. Check the cutscenes, the fog, spawns, ground height, target boxes, strikes (artillery, A-10, F-15) and the bunker breach.
   - In the lobby: pick the new map on the pad's map card, and check the card picture and the "DEPLOYING TO ..." loading text.
   - The real teleport only works once Jacob publishes, so say it's untested until then.
7. **Release it** with the steps in section 2. Put the new place id in the CHANGELOG entry and in this file's table.

## 4. Rules everyone follows

- Studio playtests save to the **real** DataStore. Never change saved player data in a playtest. Use client-only previews, or the Studio-only debug attributes: `DebugPad` on the player, `DebugStrikeTier` on workspace.
- UI: for this game Claude builds UI, but it must match the UI already in the game: same panels, buttons, fonts, colours and icons. Reuse or clone existing UI where you can.
- Don't make your own character rigs. Use rigs Jacob adds, or toolbox ones.
- Never use Roblox's default sparkle particle texture. Never put "Nzo" in a name.
- Luau has a 200-local limit, and GunshipUI's main chunk is at it. Put new code in `do ... end` blocks or tables.
- Don't create API keys or type secrets into anything. Never commit secrets.
- Ask before taking control of anyone's computer.
- Keep replies to Jacob short.
