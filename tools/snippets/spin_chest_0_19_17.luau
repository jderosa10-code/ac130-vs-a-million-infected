-- 0.19.17: the SUPPLY CRATE's SPIN tile moves off the hub's side column to a small chest button on the right end of
-- the gem bar (Menu.Top.Crate): less on a phone's screen, and everyone looks at their gems. Idempotent.
local SES = game:GetService("ScriptEditorService")
local log = {}
local T = game.StarterGui.GunshipUI_Template
local side, top = T.Menu.Side, T.Menu.Top
local tile = side:FindFirstChild("Crate")
if tile and not top:FindFirstChild("Crate") then
	tile.Parent = top
	tile.Size = UDim2.fromOffset(64, 64)
	tile.Position = UDim2.fromOffset(top.GemBar.Position.X.Offset + top.GemBar.Size.X.Offset + 10, 4)
	local face = tile.Face
	if face:FindFirstChild("LabelBar") then
		face.LabelBar:Destroy()
	end
	face.Icon.AnchorPoint = Vector2.new(0.5, 0.5)
	face.Icon.Position = UDim2.fromScale(0.5, 0.5)
	face.Icon.Size = UDim2.new(1, -8, 1, -8)
	if tile:FindFirstChild("Dot") then
		tile.Dot.Size = UDim2.fromOffset(26, 26)
		tile.Dot.Position = UDim2.new(1, -2, 0, 2)
		tile.Dot.Text.TextSize = 20
	end
	top.Size = UDim2.fromOffset(tile.Position.X.Offset + 64, top.Size.Y.Offset)
	-- the side column goes back to SHOP / SEASON / FREE
	local free = side.Free
	side.Size = UDim2.fromOffset(side.Size.X.Offset, free.Position.Y.Offset + free.Size.Y.Offset)
	table.insert(log, "chest moved to the gem bar")
end

local scr = game.StarterPlayer.StarterPlayerScripts.CrateUI
local src = scr.Source
local reps = {
	{ [[local tile = pgui:WaitForChild("GunshipUI"):WaitForChild("Menu"):WaitForChild("Side"):WaitForChild("Crate")]],
		[[local tile = pgui:WaitForChild("GunshipUI"):WaitForChild("Menu"):WaitForChild("Top"):WaitForChild("Crate") -- (the chest on the gem bar)]] },
	{ [[-- CrateUI (0.19.15): the SUPPLY CRATE (StarterGui.CrateUI, a copy of the daily drop panel). Opens from the SPIN
-- tile on the hub (red dot when a free spin is ready or spins are saved).]], [[-- CrateUI (0.19.15): the SUPPLY CRATE (StarterGui.CrateUI, a copy of the daily drop panel). Opens from the chest
-- on the hub's gem bar (0.19.17; red dot and a little shake when a free spin is ready or spins are saved).]] },
	{ [[RunService.Heartbeat:Connect(function()
	if gui.Enabled and player:GetAttribute("Screen") ~= "Menu" then]], [[RunService.Heartbeat:Connect(function()
	-- a spin waiting: the chest gives a little shake every few seconds
	local w = os.clock() % 3
	tile.Rotation = if tile.Dot.Visible and w < 0.6 then math.sin(w * 30) * 9 * (1 - w / 0.6) else 0
	if gui.Enabled and player:GetAttribute("Screen") ~= "Menu" then]] },
}
local changed = false
for _, r in ipairs(reps) do
	if not src:find(r[2], 1, true) then
		local i, j = src:find(r[1], 1, true)
		assert(i, "missing " .. r[1]:sub(1, 60))
		src = src:sub(1, i - 1) .. r[2] .. src:sub(j + 1)
		changed = true
	end
end
if changed then
	SES:UpdateSourceAsync(scr, function()
		return src
	end)
	table.insert(log, "CrateUI patched")
end
return table.concat(log, ", ")
