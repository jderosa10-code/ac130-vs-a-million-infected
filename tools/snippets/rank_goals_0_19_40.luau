-- 0.19.40 part 3: RANK GOALS in a run (PC and console; not on touch screens): the three rank objectives with their
-- progress, bottom left of the HUD. StarterGui GunshipUI_Template.HUD.RankGoals (real instances, AutoScale like the
-- other HUD panels) + LocalScript StarterPlayerScripts.RankGoalsHUD. Weapon goals name the weapon in that slot of
-- the aircraft you fly ("KILL 60 WITH 3 B61 NUKES" instead of "WITH THE 105MM").
-- Run in a place (execute_luau, Edit). Idempotent (rebuilds both).
local HUD = game.StarterGui.GunshipUI_Template.HUD
local FONT = HUD.Tally.Panel.Body.Kills.FontFace
local old = HUD:FindFirstChild("RankGoals")
if old then
	old:Destroy()
end
local INK = Color3.fromRGB(19, 24, 22)
local function label(parent, name, text, x, y, w, h, size, col, align)
	local l = Instance.new("TextLabel")
	l.Name = name
	l.BackgroundTransparency = 1
	l.Position = UDim2.fromOffset(x, y)
	l.Size = UDim2.fromOffset(w, h)
	l.FontFace = FONT
	l.TextSize = size
	l.TextColor3 = col
	l.TextXAlignment = align or Enum.TextXAlignment.Left
	l.TextYAlignment = Enum.TextYAlignment.Center
	l.TextTruncate = Enum.TextTruncate.AtEnd
	l.Text = text
	local st = Instance.new("UIStroke")
	st.Color = INK
	st.Thickness = 1.5
	st.Parent = l
	l.Parent = parent
	return l
end
local f = Instance.new("Frame")
f.Name = "RankGoals"
f.BackgroundTransparency = 1
f.AnchorPoint = Vector2.new(0, 1)
f.Position = UDim2.new(0, 26, 1, -26)
f.Size = UDim2.fromOffset(310, 124)
f.Visible = false
local sc = Instance.new("UIScale")
sc.Name = "AutoScale"
sc.Parent = f
local body = Instance.new("Frame")
body.Name = "Body"
body.BackgroundColor3 = Color3.fromRGB(27, 30, 22)
body.BackgroundTransparency = 0.12
body.BorderSizePixel = 0
body.Size = UDim2.fromScale(1, 1)
body.Parent = f
local edge = Instance.new("UIStroke")
edge.Name = "Edge"
edge.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
edge.Color = Color3.fromRGB(74, 78, 58)
edge.Thickness = 1
edge.Parent = body
label(body, "Head", "RANK GOALS", 12, 4, 150, 24, 17, Color3.fromRGB(245, 197, 24))
label(body, "Rank", "", 150, 4, 148, 24, 15, Color3.fromRGB(150, 150, 128), Enum.TextXAlignment.Right)
for i = 1, 3 do
	local row = Instance.new("Frame")
	row.Name = "Goal" .. i
	row.BackgroundTransparency = 1
	row.Position = UDim2.fromOffset(12, 30 + (i - 1) * 30)
	row.Size = UDim2.fromOffset(286, 28)
	row.Parent = body
	label(row, "Text", "", 0, 0, 220, 20, 14, Color3.fromRGB(236, 232, 214))
	label(row, "Count", "", 220, 0, 66, 20, 14, Color3.fromRGB(222, 212, 176), Enum.TextXAlignment.Right)
	local bar = Instance.new("Frame")
	bar.Name = "Bar"
	bar.BackgroundColor3 = Color3.fromRGB(56, 61, 44)
	bar.BorderSizePixel = 0
	bar.Position = UDim2.fromOffset(0, 21)
	bar.Size = UDim2.new(1, 0, 0, 4)
	bar.Parent = row
	local fill = Instance.new("Frame")
	fill.Name = "Fill"
	fill.BackgroundColor3 = Color3.fromRGB(245, 197, 24)
	fill.BorderSizePixel = 0
	fill.Size = UDim2.fromScale(0, 1)
	fill.Parent = bar
end
f.Parent = HUD

local SPS = game.StarterPlayer.StarterPlayerScripts
local scr = SPS:FindFirstChild("RankGoalsHUD")
if not scr then
	scr = Instance.new("LocalScript")
	scr.Name = "RankGoalsHUD"
	scr.Parent = SPS
end
local SRC = [[
-- (0.19.40) RANK GOALS in a run: the three rank objectives (player attribute RankObj, ConvoyServer.Ranks) with their
-- progress, bottom left of the HUD (GunshipUI.HUD.RankGoals, built in StarterGui). PC and console only: a touch
-- screen's HUD is full already. Weapon goals name the weapon that slot carries on the aircraft you fly.
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local UIS = game:GetService("UserInputService")
local player = Players.LocalPlayer
local Shared = game:GetService("ReplicatedStorage"):WaitForChild("Convoy")
local R = require(Shared:WaitForChild("Ranks"))
local Aircraft = require(Shared:WaitForChild("Aircraft"))
local Aim = require(Shared:WaitForChild("Aim"))
local gui = player:WaitForChild("PlayerGui"):WaitForChild("GunshipUI")
local panel = gui:WaitForChild("HUD"):WaitForChild("RankGoals")
local body = panel:WaitForChild("Body")
local GREEN = Color3.fromRGB(150, 220, 90)
local YEL = Color3.fromRGB(245, 197, 24)
local TXT = Color3.fromRGB(236, 232, 214)

local function goalText(o): string
	if (o.k == "gun" or o.k == "multi") and type(o.g) == "string" then
		local order = Aircraft.gunOrder(player:GetAttribute("RunPlane"))
		local i = table.find(order, o.g)
		local guns = Aircraft.playerGuns(player, true)
		if i then
			local w = i .. " " .. Aircraft.gunName(guns and guns[o.g], o.g)
			return if o.k == "gun" then "KILL " .. o.n .. " WITH " .. w else "KILL " .. o.n .. " IN ONE SHOT OF " .. w
		end
	end
	return o.text or R.text(o)
end
local function draw()
	local ok, list = pcall(HttpService.JSONDecode, HttpService, player:GetAttribute("RankObj") or "[]")
	if not ok or type(list) ~= "table" then
		list = {}
	end
	local rank = player:GetAttribute("Rank") or 0
	body.Rank.Text = if rank < R.MAX then R.short(rank) .. "  >  " .. R.short(rank + 1) else R.short(rank)
	for i = 1, 3 do
		local row = body:FindFirstChild("Goal" .. i)
		local o = list[i]
		if row then
			row.Visible = o ~= nil
			if o then
				local n = math.max(1, tonumber(o.n) or 1)
				local p = math.clamp(tonumber(o.p) or 0, 0, n)
				row.Text.Text = goalText(o)
				row.Text.TextColor3 = if o.done then GREEN else TXT
				row.Count.Text = if o.done then "DONE" else (p .. " / " .. n)
				row.Count.TextColor3 = if o.done then GREEN else TXT
				row.Bar.Fill.Size = UDim2.fromScale(if o.done then 1 else p / n, 1)
				row.Bar.Fill.BackgroundColor3 = if o.done then GREEN else YEL
			end
		end
	end
end
-- not on touch screens, not in the tutorial (it doesn't count toward them), only with objectives to show
local function vis()
	local want = player:GetAttribute("RankObj") ~= nil and not Aim.touch() and not Shared:GetAttribute("Tutorial")
	if panel.Visible ~= want then
		panel.Visible = want
	end
end
for _, a in ipairs({ "RankObj", "Rank", "RunPlane", "RunSwap" }) do
	player:GetAttributeChangedSignal(a):Connect(function()
		draw()
		vis()
	end)
end
Shared:GetAttributeChangedSignal("Tutorial"):Connect(vis)
UIS.LastInputTypeChanged:Connect(vis)
draw()
vis()
]]
game:GetService("ScriptEditorService"):UpdateSourceAsync(scr, function()
	return SRC
end)
return "RankGoals built, RankGoalsHUD " .. #SRC
