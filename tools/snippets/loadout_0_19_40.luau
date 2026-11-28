-- 0.19.40 part 1: every aircraft carries three weapons (slot 1 LIGHT, 2 MEDIUM, 3 HEAVY) and one slot can carry the
-- same slot's weapon from another aircraft you own (Aircraft.gunsOf, player attributes Swaps / RunSwap).
-- * AC-47 + FRAG BOMBS, UH-1 + TOW MISSILES, MQ-9 + MINI MISSILES + GBU-12 LASER BOMBS, AV-8B + MAVERICKS,
--   CH-47 + HEAVY ROCKET PODS, B-52 + M61 TAIL GUN (and its bomb bay -> slot 2, nukes -> slot 3, as strong as before).
-- * Mission: the run's guns come from Aircraft.gunsOf (c.pguns), SwapGun action, Swaps saved on the profile.
-- * GunshipUI / GunshipClient / ConvoyAudio read the swapped guns (Aircraft.playerGuns).
-- Run in a place (execute_luau, Edit) on top of 0.19.39. Idempotent.
local SES = game:GetService("ScriptEditorService")
local log = {}
local function patch(scr, list)
	local src = scr.Source
	local changed = false
	for _, p in ipairs(list) do
		if src:find(p[2], 1, true) then
			continue
		end
		local a, b = src:find(p[1], 1, true)
		assert(a, "anchor not found in " .. scr.Name .. ": " .. p[1]:sub(1, 80))
		if p.all then
			local out, i = {}, 1
			while true do
				local s, e = src:find(p[1], i, true)
				if not s then
					break
				end
				table.insert(out, src:sub(i, s - 1))
				table.insert(out, p[2])
				i = e + 1
			end
			table.insert(out, src:sub(i))
			src = table.concat(out)
		else
			assert(not src:find(p[1], b + 1, true), "anchor twice in " .. scr.Name .. ": " .. p[1]:sub(1, 80))
			src = src:sub(1, a - 1) .. p[2] .. src:sub(b + 1)
		end
		changed = true
	end
	if changed then
		SES:UpdateSourceAsync(scr, function()
			return src
		end)
	end
	table.insert(log, scr.Name .. (if changed then " patched" else " ok"))
end
local SPS = game.StarterPlayer.StarterPlayerScripts

patch(game.ReplicatedStorage.Convoy.Aircraft, {
	-- AC-47: frag bombs (slot 3)
	{ [[		weapons = { "3X 7.62MM MINIGUNS (NO RELOAD)", "NAPALM FLARES: THE GROUND BURNS" },]],
		[[		weapons = { "3X 7.62MM MINIGUNS (NO RELOAD)", "NAPALM FLARES: THE GROUND BURNS", "FRAG BOMBS: TWO A LOAD" },]] },
	{ "\t\t\t\tflare = { fall = 1.6, burn = 7, radius = 18, tick = 0.5, dmg = 1 } },\n",
		"\t\t\t\tflare = { fall = 1.6, burn = 7, radius = 18, tick = 0.5, dmg = 1 } },\n"
			.. "\t\t\t-- (0.19.40) a heavy weapon: two light bombs from under the wings\n"
			.. "\t\t\t[\"105mm\"] = { label = \"FRAG BOMBS\", look = \"bomb\", icon = \"ammo_mk82\", sound = \"Bomb_Drop\", free = true, Interval = 0.5, Magazine = 2, ReloadTime = 7,\n"
			.. "\t\t\t\tDispersionMils = 2, radius = 0.8, mounts = pair(14, -1.5, 2) },\n" },
	-- UH-1: TOW missiles (slot 3)
	{ [[		weapons = { "M134 DOOR MINIGUN", "70MM ROCKETS" },]], [[		weapons = { "M134 DOOR MINIGUN", "70MM ROCKETS", "TOW MISSILES" },]] },
	{ "\t\t\t\tmounts = pair(5, -0.7, -2) },\n",
		"\t\t\t\tmounts = pair(5, -0.7, -2) },\n"
			.. "\t\t\t-- (0.19.40) a heavy weapon: two wire-guided TOWs off the pods\n"
			.. "\t\t\t[\"105mm\"] = { label = \"TOW MISSILES\", look = \"missile\", icon = \"ammo_hellfire\", free = true, Interval = 0.8, Magazine = 2, ReloadTime = 7, DispersionMils = 0.8, radius = 0.9,\n"
			.. "\t\t\t\tmounts = pair(5, -0.7, -1) },\n" },
	-- MQ-9: mini missiles (slot 1) + GBU-12 laser bombs (slot 2), the Hellfires stay slot 3
	{ [[		weapons = { "4X AGM-114 MISSILES" },]], [[		weapons = { "MINI MISSILES: FAST AND PRECISE", "GBU-12 LASER BOMBS", "4X AGM-114 MISSILES" },]] },
	{ "\t\tguns = { [\"105mm\"] = { label = \"AGM-114\", look = \"missile\", icon = \"ammo_hellfire\", free = true, Interval = 0.7, Magazine = 4, ReloadTime = 7, DispersionMils = 0.6, radius = 1.1,\n\t\t\tmounts = pair(5.6, -1.9, -0.7) } },\n",
		"\t\tguns = {\n"
			.. "\t\t\t-- (0.19.40) light: a rack of small precise missiles; medium: the laser bombs on the outer pylons\n"
			.. "\t\t\t[\"25mm\"] = { label = \"MINI MISSILES\", look = \"missile\", icon = \"ammo_hellfire\", free = true, Interval = 0.18, Magazine = 24, ReloadTime = 3.5,\n"
			.. "\t\t\t\tHeatPerShot = 0.01, JamChance = 0, DispersionMils = 1, radius = 1.8, damage = 1.6, mounts = pair(5.6, -1.9, -0.7) },\n"
			.. "\t\t\t[\"40mm\"] = { label = \"GBU-12 LASER BOMBS\", look = \"bomb\", icon = \"ammo_mk82\", sound = \"Bomb_Drop\", free = true, Interval = 0.45, Magazine = 6, ReloadTime = 6,\n"
			.. "\t\t\t\tHeatPerShot = 0, JamChance = 0, DispersionMils = 0.8, radius = 1.5, damage = 1.25, mounts = pair(10.4, -1.7, -0.2) },\n"
			.. "\t\t\t[\"105mm\"] = { label = \"AGM-114\", look = \"missile\", icon = \"ammo_hellfire\", free = true, Interval = 0.7, Magazine = 4, ReloadTime = 7, DispersionMils = 0.6, radius = 1.1,\n"
			.. "\t\t\t\tmounts = pair(5.6, -1.9, -0.7) },\n"
			.. "\t\t},\n" },
	-- AV-8B: Mavericks (slot 2)
	{ [[		weapons = { "25MM GAU-12 CANNON", "MK-82 BOMBS" },]], [[		weapons = { "25MM GAU-12 CANNON", "AGM-65 MAVERICKS", "MK-82 BOMBS" },]] },
	{ "\t\t\t\tmounts = pair(5, -0.3, 1.2) },\n",
		"\t\t\t\tmounts = pair(5, -0.3, 1.2) },\n"
			.. "\t\t\t-- (0.19.40) a medium weapon: the Mavericks on the outer pylons\n"
			.. "\t\t\t[\"40mm\"] = { label = \"AGM-65 MAVERICKS\", look = \"missile\", icon = \"ammo_hellfire\", free = true, Interval = 0.5, Magazine = 4, ReloadTime = 6,\n"
			.. "\t\t\t\tHeatPerShot = 0, JamChance = 0, DispersionMils = 0.8, radius = 1.6, damage = 1.3, mounts = pair(8, -0.3, 2.8) },\n" },
	-- CH-47: heavy rocket pods (slot 3)
	{ [[		weapons = { "TWIN MINIGUNS", "40MM GRENADE LAUNCHER" },]], [[		weapons = { "TWIN MINIGUNS", "40MM GRENADE LAUNCHER", "HEAVY ROCKET PODS" },]] },
	{ "\t\t\t\tHeatPerShot = 0.018, CoolTau = 3, JamChance = 0 }, -- (the Bofors' heat per shot made it overheat in ~17 grenades)\n",
		"\t\t\t\tHeatPerShot = 0.018, CoolTau = 3, JamChance = 0 }, -- (the Bofors' heat per shot made it overheat in ~17 grenades)\n"
			.. "\t\t\t-- (0.19.40) a heavy weapon: big rockets from the side pods, a dozen a load\n"
			.. "\t\t\t[\"105mm\"] = { label = \"HEAVY ROCKET PODS\", look = \"rocket\", icon = \"ammo_hydra\", free = true, Interval = 0.18, Magazine = 12, ReloadTime = 8,\n"
			.. "\t\t\t\tHeatPerShot = 0, JamChance = 0, DispersionMils = 4, radius = 0.6, mounts = pair(6.6, -1.6, -7) },\n" },
	-- B-52: tail gun (slot 1), bomb bay -> slot 2 (damage x3 and a bigger radius: the same as it was in the 105 slot),
	-- nukes -> slot 3
	{ [[		weapons = { "BOMB BAY: 12 BOMBS A LOAD", "B61 NUKES: 2 A LOAD, SLOW RELOAD" },]],
		[[		weapons = { "M61 TAIL GUN (NO RELOAD)", "BOMB BAY: 12 BOMBS A LOAD", "B61 NUKES: 2 A LOAD, SLOW RELOAD" },]] },
	{ "\t\tgunOrder = { \"105mm\", \"40mm\" }, -- slot 1 bombs, slot 2 nukes\n", "\t\t-- (0.19.40) slot 1 tail gun, 2 bombs, 3 nukes (the standard order: no gunOrder)\n" },
	{ "\t\t\t[\"105mm\"] = { label = \"BOMB BAY\", look = \"bomb\", icon = \"ammo_bombbay\", sound = \"Bomb_Drop\", free = true, Interval = 0.3, Magazine = 12, ReloadTime = 9,\n\t\t\t\tHeatPerShot = 0.02, CoolTau = 4, DispersionMils = 3, radius = 1.3,\n",
		"\t\t\t[\"25mm\"] = with(MINIGUN, { label = \"M61 TAIL GUN\", look = \"cannon\", icon = \"ammo_cannon\", Interval = 0.035, HeatPerShot = 0.006, DispersionMils = 4,\n"
			.. "\t\t\t\tradius = 1.6, damage = 1.6, mounts = { V(0, 4, 56) } }),\n"
			.. "\t\t\t[\"40mm\"] = { label = \"BOMB BAY\", look = \"bomb\", icon = \"ammo_bombbay\", sound = \"Bomb_Drop\", free = true, Interval = 0.3, Magazine = 12, ReloadTime = 9,\n"
			.. "\t\t\t\tHeatPerShot = 0.02, CoolTau = 4, DispersionMils = 3, radius = 2.8, damage = 3, -- (x3 / 2.8: as it hit in the 105 slot)\n" },
	{ "\t\t\t[\"40mm\"] = { label = \"B61 NUKES\",", "\t\t\t[\"105mm\"] = { label = \"B61 NUKES\"," },
	-- the swap helpers
	{ "-- owned list <-> attribute string (\",AC130H,AC47,\")\n", [[-- (0.19.40) WEAPON SWAPS: one slot of an aircraft you own can carry the same slot's weapon from another aircraft you
-- own (slot 1 LIGHT, 2 MEDIUM, 3 HEAVY: a nuke can only take the place of a heavy weapon). Saved per aircraft in the
-- player attribute Swaps (",AC130H=105mm:B52,UH1=40mm:AH64,"); a run's own is RunSwap ("105mm:B52", Mission).
A.SLOT_NAME = { ["25mm"] = "LIGHT", ["40mm"] = "MEDIUM", ["105mm"] = "HEAVY" }
-- the AC-130's own guns as entries: an empty entry fires the standard gun (Mission applyGun / fireGunship)
A.STD_GUNS = { ["25mm"] = {}, ["40mm"] = {}, ["105mm"] = {} }
A.STD_NAME = { ["25mm"] = "25MM GAU-12", ["40mm"] = "40MM BOFORS", ["105mm"] = "105MM HOWITZER" }
function A.gunName(entry, slot: string): string
	return if entry and entry.label then entry.label else (A.STD_NAME[slot] or slot)
end
function A.swapOf(swaps: string?, planeId: string?): string?
	for id, s in string.gmatch(swaps or "", "(%w+)=([%w:]+)") do
		if id == planeId then
			return s
		end
	end
	return nil
end
function A.setSwap(swaps: string?, planeId: string, swap: string?): string
	local list = {}
	for id, s in string.gmatch(swaps or "", "(%w+)=([%w:]+)") do
		if id ~= planeId and A.BY_ID[id] then
			table.insert(list, id .. "=" .. s)
		end
	end
	if swap then
		table.insert(list, planeId .. "=" .. swap)
	end
	return if #list > 0 then "," .. table.concat(list, ",") .. "," else ""
end
-- an aircraft's guns with its swap ("slot:fromId", or nil): its own guns table (nil = the AC-130's standard three)
-- when there's no swap, else a table of all three with that slot's weapon from the other aircraft (fired from
-- this aircraft's own mount for the slot, if it has one)
local swapCache = {}
function A.gunsOf(planeId: string?, swap: string?)
	local def = A.BY_ID[planeId or ""] or A.BY_ID[A.DEFAULT]
	local slot, from = string.match(swap or "", "^(%w+):(%w+)$")
	local src = from and A.BY_ID[from]
	if not src or src == def or not table.find(STANDARD, slot) then
		return def.guns
	end
	local key = def.id .. "|" .. slot .. ":" .. from
	if swapCache[key] then
		return swapCache[key]
	end
	local t = {}
	for _, g in ipairs(STANDARD) do
		t[g] = if def.guns then def.guns[g] else A.STD_GUNS[g]
	end
	local w = if src.guns then src.guns[slot] else A.STD_GUNS[slot]
	if not w then
		return def.guns
	end
	w = table.clone(w)
	local own = t[slot]
	w.mounts = if own then own.mounts else nil
	w.from = src.id
	t[slot] = w
	swapCache[key] = t
	return t
end
-- a player's guns: this run's (RunPlane / RunSwap) or the hangar's (Plane / Swaps)
function A.playerGuns(p: Player, run: boolean?)
	if run then
		return A.gunsOf(p:GetAttribute("RunPlane"), p:GetAttribute("RunSwap"))
	end
	local id = p:GetAttribute("Plane")
	if not A.BY_ID[id or ""] then
		id = A.DEFAULT
	end
	return A.gunsOf(id, A.swapOf(p:GetAttribute("Swaps"), id))
end

-- owned list <-> attribute string (",AC130H,AC47,")
]] },
})

local M = game.ServerScriptService.ConvoyServer.Mission
patch(M, {
	-- profile
	{ "\tplayer:SetAttribute(\"Plane\", plane)\n", "\tplayer:SetAttribute(\"Plane\", plane)\n\tplayer:SetAttribute(\"Swaps\", type(data.Swaps) == \"string\" and data.Swaps or \"\") -- (0.19.40: weapon swaps, Aircraft)\n" },
	{ "\tdata.Plane = player:GetAttribute(\"Plane\") or Aircraft.DEFAULT\n", "\tdata.Plane = player:GetAttribute(\"Plane\") or Aircraft.DEFAULT\n\tdata.Swaps = player:GetAttribute(\"Swaps\") or \"\"\n" },
	-- the run's guns
	{ "\tp:SetAttribute(\"RunPlane\", if c.plane then c.plane.id else Aircraft.DEFAULT)\n", [[	p:SetAttribute("RunPlane", if c.plane then c.plane.id else Aircraft.DEFAULT)
	-- (0.19.40) this run's weapon swap, only from an aircraft they own (not in the tutorial); c.pguns = its guns
	local swap = Aircraft.swapOf(p:GetAttribute("Swaps"), p:GetAttribute("RunPlane"))
	local swapFrom = swap and string.match(swap, ":(%w+)$")
	if Shared:GetAttribute("Tutorial") or not (swapFrom and Aircraft.parse(p:GetAttribute("Planes"))[swapFrom]) then
		swap = nil
	end
	p:SetAttribute("RunSwap", swap)
	c.pguns = Aircraft.gunsOf(p:GetAttribute("RunPlane"), swap)
]] },
	{ "\tplayer:SetAttribute(\"RunPlane\", Aircraft.DEFAULT)\n", "\tplayer:SetAttribute(\"RunPlane\", Aircraft.DEFAULT)\n\tplayer:SetAttribute(\"RunSwap\", nil)\n" },
	-- (missiles in the light slot, the MQ-9's: their full blast on screen, not the bullets' small pop)
	{ "FX:FireAllClients(\"boom\", pos, if kind == \"25mm\" then math.min(", "FX:FireAllClients(\"boom\", pos, if kind == \"25mm\" and look ~= \"missile\" then math.min(" },
	-- (an explosive in the light slot, the MQ-9's mini missiles: armor doesn't bounce it like a bullet)
	{ "\tif e.armored and kind == \"25mm\" then\n", "\tif e.armored and kind == \"25mm\" and Upgrades.weaponClass(cw and cw.pguns and cw.pguns[\"25mm\"] or nil, \"25mm\") == \"GUN\" then\n" },
	{ "\t\tlocal g40 = cw and cw.plane and cw.plane.guns and cw.plane.guns[\"40mm\"]\n\t\tlocal onlySmall = cw and cw.plane and cw.plane.guns and (not g40 or g40.flare) and not cw.plane.guns[\"105mm\"]\n",
		"\t\tlocal g40 = cw and cw.pguns and cw.pguns[\"40mm\"]\n\t\tlocal onlySmall = cw and cw.pguns and (not g40 or g40.flare) and not cw.pguns[\"105mm\"]\n" },
	{ "\t\tlocal pdef = Aircraft.BY_ID[who:GetAttribute(\"RunPlane\") or \"\"]\n\t\tlocal g = pdef and pdef.guns and pdef.guns[kind]\n",
		"\t\tlocal pg = Aircraft.gunsOf(who:GetAttribute(\"RunPlane\"), who:GetAttribute(\"RunSwap\")) -- (0.19.40: with its swap)\n\t\tlocal g = pg and pg[kind]\n" },
	{ "\tif c.plane and c.plane.guns then\n\t\tov = c.plane.guns[g] or false\n\tend\n", "\tif c.pguns then\n\t\tov = c.pguns[g] or false -- (0.19.40: with its weapon swap)\n\tend\n" },
	{ "\tlocal gdef = c.plane and c.plane.guns and c.plane.guns[kind]\n", "\tlocal gdef = c.pguns and c.pguns[kind] -- (0.19.40: with its weapon swap)\n" },
	-- (a swapped-in nuke or flare on the AC-130: it has no c.plane)
	{ "local orb = Orbit.withSlot(c.plane.orbit or Config.ORBIT, c.slot)", "local orb = Orbit.withSlot(c.plane and c.plane.orbit or Config.ORBIT, c.slot)", all = true },
	{ "\t\t\t\tlocal gd = c.plane and c.plane.guns and c.plane.guns[g]\n", "\t\t\t\tlocal gd = c.pguns and c.pguns[g]\n" },
	{ "and not (c.plane and c.plane.guns and not c.plane.guns[a]) then", "and not (c.pguns and not c.pguns[a]) then" },
	-- the AIRCRAFT screen's swap buttons
	{ "\telseif kind == \"BuyPlane\" or kind == \"EquipPlane\" then\n", [[	elseif kind == "SwapGun" then
		-- (0.19.40) AIRCRAFT screen: a = the aircraft, b = "<slot>:<other aircraft>" or "" (back to its own weapons).
		-- Both owned, the same slot (Aircraft.gunsOf), one swap per aircraft. In the hangar only.
		local def = type(a) == "string" and Aircraft.BY_ID[a]
		if not def or (running and crew[player]) or not player:GetAttribute("ProfileLoaded") then
			return
		end
		local owned = Aircraft.parse(player:GetAttribute("Planes"))
		if not owned[a] then
			return
		end
		local swap = nil
		if type(b) == "string" and b ~= "" then
			local slot, from = string.match(b, "^(%w+):(%w+)$")
			if not slot or not table.find(Upgrades.GUNS, slot) or not owned[from] or from == a or not Aircraft.BY_ID[from] then
				return
			end
			swap = slot .. ":" .. from
		end
		player:SetAttribute("Swaps", Aircraft.setSwap(player:GetAttribute("Swaps"), a, swap))
		task.spawn(saveProfile, player)
	elseif kind == "BuyPlane" or kind == "EquipPlane" then
]] },
})

patch(SPS.GunshipUI, {
	{ "\tlocal defs = require(Shared:WaitForChild(\"Aircraft\"))\n\tlocal def = defs.BY_ID[player:GetAttribute(\"Plane\") or \"\"] or defs.BY_ID[defs.DEFAULT]\n\treturn def and def.guns and def.guns[g] or nil\n",
		"\tlocal gs = require(Shared:WaitForChild(\"Aircraft\")).playerGuns(player, false) -- (0.19.40: with its weapon swap)\n\treturn gs and gs[g] or nil\n" },
	{ "\tlocal defs = require(Shared:WaitForChild(\"Aircraft\"))\n\tlocal def = defs.BY_ID[player:GetAttribute(\"Plane\") or \"\"] or defs.BY_ID[defs.DEFAULT]\n\treturn def and def.guns\n",
		"\treturn require(Shared:WaitForChild(\"Aircraft\")).playerGuns(player, false) -- (0.19.40: with its weapon swap)\n" },
	{ "\t\tlocal planeDef = AircraftData.BY_ID[pattr(\"RunPlane\", \"\") or \"\"]\n\t\tlocal pg = planeDef and planeDef.guns\n",
		"\t\tlocal pg = AircraftData.playerGuns(player, true) -- (0.19.40: with its weapon swap)\n" },
})

patch(SPS.GunshipClient, {
	{ "\t\t\tlocal pg = def.guns and def.guns[gun()]\n", "\t\t\tlocal pgs = Aircraft.playerGuns(player, true) -- (0.19.40: with its weapon swap)\n\t\t\tlocal pg = pgs and pgs[gun()]\n" },
})

patch(SPS.ConvoyAudio, {
	{ "\t\tlocal def = AircraftDefs.BY_ID[game:GetService(\"Players\").LocalPlayer:GetAttribute(\"RunPlane\") or \"\"]\n\t\tlocal g = def and def.guns and def.guns[kind]\n",
		"\t\tlocal gs = AircraftDefs.playerGuns(game:GetService(\"Players\").LocalPlayer, true) -- (0.19.40: with its weapon swap)\n\t\tlocal g = gs and gs[kind]\n" },
})
return table.concat(log, ", ")
