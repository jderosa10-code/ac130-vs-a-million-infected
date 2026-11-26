-- Run in each place (execute_luau, Edit) and compare the output between places: every shared script, module and
-- UI tree should print the same line everywhere. A line that differs = that thing isn't synced yet.
-- (Map-only content - Workspace, Terrain, Lighting - is left out on purpose.)
local function hash(s: string): string
	local h1, h2 = 5381, 0
	for i = 1, #s do
		local b = string.byte(s, i)
		h1 = (h1 * 33 + b) % 4294967296
		h2 = (h2 + b * i) % 4294967296
	end
	return string.format("%08x%08x", h1, h2)
end
local roots = {
	game:GetService("ServerScriptService"),
	game:GetService("ReplicatedStorage"),
	game:GetService("StarterPlayer"),
}
local out = {}
for _, root in ipairs(roots) do
	for _, d in ipairs(root:GetDescendants()) do
		if d:IsA("LuaSourceContainer") then
			table.insert(out, d:GetFullName() .. "  " .. #d.Source .. "  " .. hash(d.Source))
		end
	end
end
-- UI: one line per ScreenGui (class + name of every descendant)
for _, g in ipairs(game:GetService("StarterGui"):GetChildren()) do
	local names = {}
	for _, d in ipairs(g:GetDescendants()) do
		table.insert(names, d.ClassName .. ":" .. d.Name)
	end
	table.sort(names)
	table.insert(out, "StarterGui." .. g.Name .. "  " .. #names .. "  " .. hash(table.concat(names, "|")))
end
table.sort(out)
table.insert(out, 1, "GameVersion " .. tostring(game:GetService("ReplicatedStorage").Convoy:GetAttribute("GameVersion")))
return table.concat(out, "\n")
