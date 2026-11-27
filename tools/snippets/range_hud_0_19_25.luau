-- 0.19.25: the TEST RANGE HUD (no title flicker, title up on phones, readable ZOMBIES LEFT, AUTO-SKIP hidden,
-- EXIT TEST FLIGHT above the cash bar, an UNLIMITED AMMO switch where RELOAD ALL goes) + hold a finger down to fire.
-- Run in a place (execute_luau, Edit) on top of 0.19.24. Idempotent.
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
		assert(not src:find(p[1], b + 1, true), "anchor twice in " .. scr.Name .. ": " .. p[1]:sub(1, 80))
		src = src:sub(1, a - 1) .. p[2] .. src:sub(b + 1)
		changed = true
	end
	if changed then
		SES:UpdateSourceAsync(scr, function()
			return src
		end)
	end
	table.insert(log, scr.Name .. (if changed then " patched" else " ok"))
end
local CS = game.ServerScriptService.ConvoyServer
local SPS = game.StarterPlayer.StarterPlayerScripts
local HUD = game.StarterGui.GunshipUI_Template.HUD

---------------------------------------------------------------- template
-- ZOMBIES LEFT: a dark plate under the wave box, bigger text (it was 23 px across the whole bar: ~9 px on a phone)
do
	local rem = HUD.Top.Remaining
	if not rem:FindFirstChild("Edge") then
		rem.AnchorPoint = Vector2.new(0.5, 0)
		rem.Position = UDim2.fromOffset(450, 74)
		rem.Size = UDim2.fromOffset(300, 36)
		rem.AutomaticSize = Enum.AutomaticSize.X
		rem.BackgroundColor3 = HUD.Top.Wave.Body.BackgroundColor3
		rem.BackgroundTransparency = HUD.Top.Wave.Body.BackgroundTransparency
		rem.BorderSizePixel = 0
		rem.TextSize = 28
		local edge = Instance.new("UIStroke")
		edge.Name = "Edge"
		edge.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		edge.Color = HUD.Top.Wave.Body.Edge.Color
		edge.Thickness = 2
		edge.Parent = rem
		local pad = Instance.new("UIPadding")
		pad.PaddingLeft = UDim.new(0, 16)
		pad.PaddingRight = UDim.new(0, 16)
		pad.Parent = rem
		table.insert(log, "Remaining plate")
	end
end
-- EXIT TEST FLIGHT: out of the top bar, into the bottom bar above the cash (where the bunker bar goes; none on the range)
do
	local exit = HUD:FindFirstChild("ExitTest", true)
	if exit and exit.Parent ~= HUD.Bottom then
		exit.Parent = HUD.Bottom
		exit.Position = UDim2.fromOffset(120, 0)
		exit.Size = UDim2.fromOffset(320, 44)
		table.insert(log, "ExitTest to Bottom")
	end
end
-- UNLIMITED AMMO switch (test range only): RELOAD ALL's bar, same place, with the ammo icon
do
	local W = HUD.Weapons
	if not W:FindFirstChild("TestAmmo") then
		local b = W.ReloadAll:Clone()
		b.Name = "TestAmmo"
		b.Visible = false
		b.Face.Label.Text = "UNLIMITED AMMO: ON"
		b.Face.Label.TextSize = 30
		local icon = b.Face.Icon
		icon.Image = W.Slot_25mm.Body.GunBox.GunIcon.Image
		icon.ImageRectOffset = Vector2.new(0, 0)
		icon.ImageRectSize = Vector2.new(256, 256)
		icon.AnchorPoint = Vector2.new(0, 0.5)
		icon.Position = UDim2.new(0, 22, 0.5, 0)
		icon.Size = UDim2.fromOffset(44, 44)
		b.Parent = W
		table.insert(log, "TestAmmo made")
	end
end

---------------------------------------------------------------- server: the switch
patch(CS.Mission, {
	{ [[	elseif kind == "ExitTest" then
		-- TEST FLIGHT's EXIT button: end it now
		if Shared:GetAttribute("TestFlight") and running and crew[player] then
			failReason = failReason or "TEST FLIGHT OVER"
		end
]], [[	elseif kind == "ExitTest" then
		-- TEST FLIGHT's EXIT button: end it now
		if Shared:GetAttribute("TestFlight") and running and crew[player] then
			failReason = failReason or "TEST FLIGHT OVER"
		end
	elseif kind == "TestAmmo" then
		-- (0.19.25) the TEST RANGE's UNLIMITED AMMO switch (TestFlightUI): on a test flight only
		if Shared:GetAttribute("TestFlight") and running and crew[player] then
			player:SetAttribute("UnlimitedAmmo", if player:GetAttribute("UnlimitedAmmo") then nil else true)
		end
]] },
})

---------------------------------------------------------------- GunshipUI: one writer for the top bar
patch(SPS.GunshipUI, {
	{ [[	Top.Wave.Body.Value.Text = if attr("OpName", nil) then]], [[	Top.Wave.Body.Value.Text = if attr("TestFlight", false) then "TEST RANGE" elseif attr("OpName", nil) then]] },
	{ "\tTop.Boss.Visible = not inOp\n\tTop.Auto.Visible = not inOp\n", "\tTop.Boss.Visible = not inOp and not attr(\"TestFlight\", false)\n\tTop.Auto.Visible = not inOp and not attr(\"TestFlight\", false) -- (the TEST RANGE: no waves to skip, no bosses)\n" },
	{ "player:GetAttributeChangedSignal(\"AutoSkip\"):Connect(refreshTop)\n", "player:GetAttributeChangedSignal(\"AutoSkip\"):Connect(refreshTop)\nShared:GetAttributeChangedSignal(\"TestFlight\"):Connect(refreshTop)\n" },
	-- phones: the whole wave bar is small (about 0.4), so ZOMBIES LEFT gets bigger text there; the boss strip moves down
	{ "\t\t\t\t\t\tf.Position = UDim2.fromOffset(vp.X / 2, below + 4)\n", "\t\t\t\t\t\tf.Position = UDim2.fromOffset(vp.X / 2, below + 4)\n"
		.. "\t\t\t\t\t\t-- (0.19.25) phones: ZOMBIES LEFT bigger (it was unreadable at the bar's small size), the boss strip under it\n"
		.. "\t\t\t\t\t\tlocal rem = f:FindFirstChild(\"Remaining\")\n"
		.. "\t\t\t\t\t\tif rem and f:FindFirstChild(\"Boss\") then\n"
		.. "\t\t\t\t\t\t\trem.TextSize = if phone then 44 else 28\n"
		.. "\t\t\t\t\t\t\trem.Size = UDim2.fromOffset(300, if phone then 54 else 36)\n"
		.. "\t\t\t\t\t\t\tf.Boss.Position = UDim2.fromOffset(f.Boss.Position.X.Offset, if phone then 134 else 114)\n"
		.. "\t\t\t\t\t\tend\n" },
})

---------------------------------------------------------------- TestFlightUI
do
	local scr = SPS.TestFlightUI
	local src = scr.Source
	local changed = false
	local oldExit = [[local exit = gui:WaitForChild("HUD"):WaitForChild("Top"):WaitForChild("ExitTest", 15)]]
	if src:find(oldExit, 1, true) then
		src = src:gsub(oldExit:gsub("%p", "%%%0"), [[local exit = gui:WaitForChild("HUD"):WaitForChild("Bottom"):WaitForChild("ExitTest", 15) -- (0.19.25: above the cash bar)]])
		changed = true
	end
	local a = src:find("-- on the TEST RANGE (0.19.21)", 1, true)
	if a then
		src = src:sub(1, a - 1) .. [==[-- on the TEST RANGE (0.19.21, 0.19.25): GunshipUI's refreshTop writes TEST RANGE and hides AUTO-SKIP / NEXT BOSS.
-- Here: no bunker bar, the title up level with the cash bar on phones (nothing beside it there now), and the
-- UNLIMITED AMMO switch where RELOAD ALL goes (HUD.Weapons.TestAmmo; server Mission "TestAmmo").
local HUD = gui:WaitForChild("HUD")
local Top = HUD:WaitForChild("Top")
local Bottom = HUD:WaitForChild("Bottom")
local ammo = HUD:WaitForChild("Weapons"):WaitForChild("TestAmmo", 15)
local AMBER, DARK = Color3.fromRGB(255, 176, 0), Color3.fromRGB(27, 30, 22)
local baseWaveY, baseRemY = Top.Wave.Position.Y.Offset, Top.Remaining.Position.Y.Offset
local hidBunker = false
local function onRange(): boolean
	return Shared:GetAttribute("TestFlight") == true and Shared:GetAttribute("State") == "Running"
end
local function refresh()
	local on = onRange()
	local bunkerBar = Bottom:FindFirstChild("Bunker")
	if on and bunkerBar then
		bunkerBar.Visible = false
		hidBunker = true
	elseif hidBunker then
		hidBunker = false
		if bunkerBar then
			bunkerBar.Visible = true
		end
	end
	-- phones carry the cash bar up top: the title goes up level with it
	local shift = 0
	local cash = Bottom:FindFirstChild("Cash")
	local k = Top.AbsoluteSize.Y / 150
	if on and cash and k > 0 and cash.AbsolutePosition.Y < Top.AbsolutePosition.Y then
		shift = math.max(0, math.floor((Top.AbsolutePosition.Y + baseWaveY * k - cash.AbsolutePosition.Y) / k))
	end
	if Top.Wave.Position.Y.Offset ~= baseWaveY - shift then
		Top.Wave.Position = UDim2.new(Top.Wave.Position.X, UDim.new(0, baseWaveY - shift))
		Top.Remaining.Position = UDim2.new(Top.Remaining.Position.X, UDim.new(0, baseRemY - shift))
	end
	if ammo then
		ammo.Visible = on
		local unl = player:GetAttribute("UnlimitedAmmo") == true
		local face = ammo:FindFirstChild("Face")
		if face then
			face.BackgroundColor3 = if unl then AMBER else DARK
			face.BackgroundTransparency = if unl then 0 else 0.12
			local l = face:FindFirstChild("Label")
			if l then
				l.Text = "UNLIMITED AMMO: " .. (if unl then "ON" else "OFF")
			end
		end
		-- the gun cards stack from the bottom: sit just above weapon 1, like RELOAD ALL
		local ok, order = pcall(Aircraft.gunOrder, player:GetAttribute("RunPlane") or "")
		local n = if ok and type(order) == "table" then #order else 3
		ammo.Position = UDim2.fromOffset(4, (3 - math.max(n, 1)) * 142 - 18)
	end
end
if ammo then
	pressy(ammo)
	ammo.Activated:Connect(function()
		if onRange() then
			SFX.play("Click", { vol = 0.6 })
			Action:FireServer("TestAmmo")
		end
	end)
end
for _, k in ipairs({ "TestFlight", "State" }) do
	Shared:GetAttributeChangedSignal(k):Connect(refresh)
end
for _, k in ipairs({ "UnlimitedAmmo", "RunPlane" }) do
	player:GetAttributeChangedSignal(k):Connect(refresh)
end
task.spawn(function()
	while true do
		task.wait(0.5) -- (the HUD re-fits to the screen now and then: keep the title where it belongs)
		refresh()
	end
end)
refresh()
]==]
		changed = true
	end
	if changed and not scr.Source:find("(0.19.21, 0.19.25)", 1, true) then
		SES:UpdateSourceAsync(scr, function()
			return src
		end)
		table.insert(log, "TestFlightUI patched")
	end
end

---------------------------------------------------------------- Aim: hold a finger down to fire
do
	local scr = game.ReplicatedStorage.Convoy.Aim
	local src = scr.Source
	if not src:find("TAP / HOLD TO FIRE (0.19.25", 1, true) then
		local a = src:find("-- TAP TO FIRE (0.19.16, touch)", 1, true)
		local b1, b2 = src:find("function Aim.screen(): Vector2\n\tif os.clock() < tapUntil then\n\t\treturn tapAt\n\tend\n", 1, true)
		assert(a and b1 and b1 > a, "Aim tap block not found")
		local NEW = [==[-- TAP / HOLD TO FIRE (0.19.25, touch; taps since 0.19.16): a finger put down on the screen (not on a button) fires
-- at that spot straight away and keeps firing while it's held, the crosshair on the finger: just like holding FIRE
-- (each gun at its own rate; one that can't be held fires as it's ready). Moving it more than a few pixels makes it a
-- drag that slews the sensor (firing stops); two fingers are a pinch; a flown aircraft's stick (left of the screen)
-- never fires. A quick tap still fires a moment after it lifts. GunshipClient fires while Aim.tapping().
local GuiService = game:GetService("GuiService")
local tapAt, tapUntil = Vector2.zero, 0
local downs = {} -- touch -> { at = where it went down, t = when, input, drag = slewing (not firing), stick = flying }
local function canFire(): boolean
	local lp = game:GetService("Players").LocalPlayer
	local cv = game:GetService("ReplicatedStorage"):FindFirstChild("Convoy")
	return lp ~= nil and cv ~= nil and lp:GetAttribute("Screen") == "HUD" and not lp:GetAttribute("Targeting") and cv:GetAttribute("State") == "Running"
end
local function flying(): boolean
	local lp = game:GetService("Players").LocalPlayer
	local ok, A = pcall(require, script.Parent:FindFirstChild("Aircraft"))
	local def = ok and A and A.BY_ID and lp and A.BY_ID[lp:GetAttribute("RunPlane") or ""]
	return def ~= nil and def.fly ~= nil
end
local function held()
	local n, h = 0, nil
	for _, d in pairs(downs) do
		if not d.stick then
			n += 1
			if not d.drag then
				h = d
			end
		end
	end
	return if n == 1 then h else nil -- (none, or a pinch)
end
UIS.InputBegan:Connect(function(input, processed)
	if input.UserInputType == Enum.UserInputType.Touch and not processed then
		local at = Vector2.new(input.Position.X, input.Position.Y)
		local stick = at.X < workspace.CurrentCamera.ViewportSize.X * 0.45 and flying()
		downs[input] = { at = at, t = os.clock(), input = input, drag = not canFire(), stick = stick }
	end
end)
UIS.InputChanged:Connect(function(input)
	local d = downs[input]
	if d and not d.drag and (Vector2.new(input.Position.X, input.Position.Y) - d.at).Magnitude > 14 then
		d.drag = true -- moved: a drag that slews the sensor
	end
end)
UIS.InputEnded:Connect(function(input)
	local d = downs[input]
	downs[input] = nil
	if not d or d.drag or d.stick then
		return
	end
	local here = Vector2.new(input.Position.X, input.Position.Y)
	if os.clock() - d.t > 0.45 or (here - d.at).Magnitude > 14 or not canFire() then
		return -- held a while (it fired the whole time) or moved off
	end
	-- (a touch's position leaves out the top bar; viewport pixels count it, like GetMouseLocation)
	tapAt = d.at + GuiService:GetGuiInset()
	tapUntil = os.clock() + 0.3
end)
function Aim.tapping(): boolean
	return held() ~= nil or os.clock() < tapUntil
end

-- the aim point in viewport pixels (same space as UserInputService:GetMouseLocation)
function Aim.screen(): Vector2
	local h = held()
	if h then
		return Vector2.new(h.input.Position.X, h.input.Position.Y) + GuiService:GetGuiInset()
	end
	if os.clock() < tapUntil then
		return tapAt
	end
]==]
		src = src:sub(1, a - 1) .. NEW .. src:sub(b2 + 1)
		SES:UpdateSourceAsync(scr, function()
			return src
		end)
		table.insert(log, "Aim hold to fire")
	end
end
return table.concat(log, ", ")
