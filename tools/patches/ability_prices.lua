-- 0.14.13: repair, artillery and the nuke cost more every time you use one in a run (+50% of the base each time)
local pending, log = {}, {}
local function src(scr)
	pending[scr] = pending[scr] or scr.Source
	return pending[scr]
end
local function rep(scr, a, b)
	local s = src(scr)
	local i, j = s:find(a, 1, true)
	assert(i, scr.Name .. ": no match for: " .. a:sub(1, 70))
	assert(not s:find(a, j + 1, true), scr.Name .. ": two matches for: " .. a:sub(1, 70))
	pending[scr] = s:sub(1, i - 1) .. b .. s:sub(j + 1)
end
local up = game.ReplicatedStorage.Convoy.Upgrades
local mi = game.ServerScriptService.ConvoyServer.Mission
local ui = game.StarterPlayer.StarterPlayerScripts.GunshipUI

rep(up, [[-- cash price of an ability for someone with the given A-10 "Cost" level
function Upgrades.abilityCost(name: string, a10CostLevel: number?): number
	local a = Upgrades.ABILITIES[name]
	if name == "A10" then
		return math.floor(a.cost * 0.9 ^ (a10CostLevel or 0) / 10 + 0.5) * 10
	end
	return a.cost
end]], [[-- cash price of an ability for someone with the given A-10 "Cost" level, after `uses` of it this run: each use
-- puts the price up by ABILITY_RAISE of its base (player attribute "Uses_<name>", reset every run)
Upgrades.ABILITY_RAISE = 0.5
function Upgrades.abilityCost(name: string, a10CostLevel: number?, uses: number?): number
	local a = Upgrades.ABILITIES[name]
	local base = if name == "A10" then a.cost * 0.9 ^ (a10CostLevel or 0) else a.cost
	return math.floor(base * (1 + Upgrades.ABILITY_RAISE * (uses or 0)) / 10 + 0.5) * 10
end]])

rep(mi, [[	p:SetAttribute("FreeNukes", nil)
	for _, g in ipairs(Upgrades.GUNS) do]], [[	p:SetAttribute("FreeNukes", nil)
	for an in pairs(Upgrades.ABILITIES) do
		p:SetAttribute("Uses_" .. an, nil) -- (ability prices start back at the bottom every run)
	end
	for _, g in ipairs(Upgrades.GUNS) do]])
rep(mi, [[	local price = a and Upgrades.abilityCost(name, a10Level("Cost", who))]],
	[[	local price = a and Upgrades.abilityCost(name, a10Level("Cost", who), who:GetAttribute("Uses_" .. name) or 0)]])
rep(mi, [[					local cost = Upgrades.abilityCost("A10", a10Level("Cost", who))
					if cashOf(who) >= cost then
						fireBarrage(from, radius, who)
						Ranks.a10(who)
						addCash(-cost, who)]], [[					local cost = Upgrades.abilityCost("A10", a10Level("Cost", who), who:GetAttribute("Uses_A10") or 0)
					if cashOf(who) >= cost then
						fireBarrage(from, radius, who)
						Ranks.a10(who)
						addCash(-cost, who)
						who:SetAttribute("Uses_A10", (who:GetAttribute("Uses_A10") or 0) + 1)]])
rep(mi, [[	addCash(-price, who)
	abilityLog[name] = (abilityLog[name] or 0) + 1
end]], [[	addCash(-price, who)
	who:SetAttribute("Uses_" .. name, (who:GetAttribute("Uses_" .. name) or 0) + 1) -- the next one costs more
	abilityLog[name] = (abilityLog[name] or 0) + 1
end]])

rep(ui, [[			local price = Upgrades.abilityCost(name, pattr(Upgrades.attr("A10", "Cost"), 0))
			local free = if name == "Nuke" then pattr("FreeNukes", 0) else 0]], [[			local price = Upgrades.abilityCost(name, pattr(Upgrades.attr("A10", "Cost"), 0), pattr("Uses_" .. name, 0))
			local free = if name == "Nuke" then pattr("FreeNukes", 0) else 0]])
rep(ui, [[	local price = Upgrades.abilityCost(name, pattr(Upgrades.attr("A10", "Cost"), 0))
	if name == "Nuke" and pattr("FreeNukes", 0) > 0 then]], [[	local price = Upgrades.abilityCost(name, pattr(Upgrades.attr("A10", "Cost"), 0), pattr("Uses_" .. name, 0))
	if name == "Nuke" and pattr("FreeNukes", 0) > 0 then]])
rep(ui, [[		if attr("Cash", 0) < Upgrades.abilityCost("A10", pattr(Upgrades.attr("A10", "Cost"), 0)) then]],
	[[		if attr("Cash", 0) < Upgrades.abilityCost("A10", pattr(Upgrades.attr("A10", "Cost"), 0), pattr("Uses_A10", 0)) then]])
do -- (GunshipUI has this handler twice: both get it)
	local a = [[	elseif k:sub(1, 8) == "Gunship_" or k:sub(1, 5) == "Tier_" then
		refreshSlots()]]
	local b = [[	elseif k:sub(1, 8) == "Gunship_" or k:sub(1, 5) == "Tier_" or k:sub(1, 5) == "Uses_" or k == "FreeNukes" then
		refreshSlots() -- (ability prices go up with use)]]
	local s, n, at = src(ui), 0, 1
	while true do
		local i, j = s:find(a, at, true)
		if not i then
			break
		end
		s = s:sub(1, i - 1) .. b .. s:sub(j + 1)
		at = i + #b
		n += 1
	end
	assert(n >= 1, "GunshipUI: refreshSlots handler")
	pending[ui] = s
end
for scr, s in pairs(pending) do
	scr.Source = s
	table.insert(log, "patched " .. scr.Name)
end
return table.concat(log, "\n")
