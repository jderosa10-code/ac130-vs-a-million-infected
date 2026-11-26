-- 0.19.13: REPAIR price multiplies by 1.8 each use in a run (abilities may set `growth`; others keep the linear raise)
local up = game.ReplicatedStorage.Convoy.Upgrades
local s = up.Source
local function rep(a, b) local i, j = s:find(a, 1, true) assert(i, "no match: " .. a:sub(1, 60)) s = s:sub(1, i - 1) .. b .. s:sub(j + 1) end
rep([[	return math.floor(base * (1 + Upgrades.ABILITY_RAISE * (uses or 0)) / 10 + 0.5) * 10]],
[[	local mult = if a.growth then a.growth ^ (uses or 0) else 1 + Upgrades.ABILITY_RAISE * (uses or 0)
	return math.floor(base * mult / 10 + 0.5) * 10]])
rep([[key = "C", cost = 250, amount = 35 }]], [[key = "C", cost = 250, amount = 35, growth = 1.8 }]])
up.Source = s
