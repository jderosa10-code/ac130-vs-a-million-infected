-- 0.14.13: the bundle and gift developer products exist now (created Nov 23 2026)
local m = game.ReplicatedStorage.Convoy.Shop
local s = m.Source
local IDS = {
	Pack_Small = 3735303256, Pack_Medium = 3735303276, Pack_Large = 3735303295, Pack_Mega = 3735303404,
	Pass_Gems = 3735303420, Pass_Cash = 3735303439, Pass_VIP = 3735303460, Pass_HeadStart = 3735303473,
}
local n = 0
for k, id in pairs(IDS) do
	local c
	s, c = s:gsub("\t" .. k .. " = 0,", "\t" .. k .. " = " .. id .. ",")
	n += c
end
local c1, c2
s, c1 = s:gsub('key = "Bundle_Starter", name = "STARTER BUNDLE", productId = 0,', 'key = "Bundle_Starter", name = "STARTER BUNDLE", productId = 3735303112,')
s, c2 = s:gsub('key = "Bundle_Gunship", name = "GUNSHIP BUNDLE", productId = 0,', 'key = "Bundle_Gunship", name = "GUNSHIP BUNDLE", productId = 3735303229,')
assert(n == 8 and c1 == 1 and c2 == 1, "shop ids: " .. n .. " " .. c1 .. " " .. c2)
m.Source = s
return "ok"
