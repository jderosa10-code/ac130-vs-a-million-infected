-- 0.19.16: phone markers + tap to fire. Run in a place (execute_luau, Edit) on top of 0.19.15. Idempotent.
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
		if not a then
			error("anchor not found in " .. scr.Name .. ": " .. p[1]:sub(1, 80))
		end
		if p[3] == "all" then
			local out, i = {}, 1
			while true do
				local x, y = src:find(p[1], i, true)
				if not x then
					break
				end
				table.insert(out, src:sub(i, x - 1))
				table.insert(out, p[2])
				i = y + 1
			end
			table.insert(out, src:sub(i))
			src = table.concat(out)
		else
			if src:find(p[1], b + 1, true) then
				error("anchor twice in " .. scr.Name .. ": " .. p[1]:sub(1, 80))
			end
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

patch(SPS.GunshipUI, {
	{ [[local function worldToGui(pos: Vector3)
	local v, on = camera:WorldToViewportPoint(pos)
	local i = inset()
	return UDim2.fromOffset(v.X - i.X, v.Y - i.Y), on and v.Z > 0
end]], [[local function worldToGui(pos: Vector3)
	local v, on = camera:WorldToViewportPoint(pos)
	-- viewport pixels to this GUI's pixels (on notch phones its top-left sits in from the screen's: the safe area)
	local i = gui.AbsolutePosition + GuiService:GetGuiInset()
	return UDim2.fromOffset(v.X - i.X, v.Y - i.Y), on and v.Z > 0
end]] },
	{ [[Aim.screen() - inset()]], [[Aim.screen() - (gui.AbsolutePosition + GuiService:GetGuiInset())]], "all" },
	{ [[	local center = attr("OrbitCenter", Vector3.zero)
	local p, on = worldToGui(center + Vector3.new(0, 30, 0))
	HUD.BunkerMarker.Position = p
	HUD.BunkerMarker.Visible = on
]], [[	local center = attr("OrbitCenter", Vector3.zero)
	-- the bunker box hugs the bunker as it looks on screen from any angle: its bounding box's 8 corners, projected
	-- (a fixed box round a point 30 studs up floated above the bunker from low aircraft and on phones)
	local bb = markers.bunker
	if not bb or not bb.model.Parent then
		local dmz = workspace:FindFirstChild("DMZ")
		local mdl = dmz and dmz:FindFirstChild("Bunker")
		bb = nil
		if mdl and mdl:IsA("Model") then
			local cf, size = mdl:GetBoundingBox()
			bb = { model = mdl, cf = cf, half = size / 2 }
		end
		markers.bunker = bb
	end
	if bb and (Vector3.new(bb.cf.X, 0, bb.cf.Z) - Vector3.new(center.X, 0, center.Z)).Magnitude < 150 then
		local lo, hi, seen = Vector2.new(math.huge, math.huge), Vector2.new(-math.huge, -math.huge), true
		for c = 0, 7 do
			local corner = Vector3.new(if c % 2 == 0 then -1 else 1, if c % 4 < 2 then -1 else 1, if c < 4 then -1 else 1)
			local v = camera:WorldToViewportPoint(bb.cf * (bb.half * corner))
			seen = seen and v.Z > 0
			lo, hi = lo:Min(Vector2.new(v.X, v.Y)), hi:Max(Vector2.new(v.X, v.Y))
		end
		local o = gui.AbsolutePosition + GuiService:GetGuiInset()
		local mid = (lo + hi) / 2 - o
		local size = (hi - lo + Vector2.new(14, 14)):Max(Vector2.new(36, 36)):Min(Vector2.new(420, 420))
		HUD.BunkerMarker.Position = UDim2.fromOffset(mid.X, mid.Y)
		HUD.BunkerMarker.Size = UDim2.fromOffset(size.X, size.Y)
		HUD.BunkerMarker.Visible = seen
	else
		local p, on = worldToGui(center + Vector3.new(0, 30, 0))
		HUD.BunkerMarker.Position = p
		HUD.BunkerMarker.Visible = on
	end
]] },
})

patch(SPS.TargetBoxes, {
	{ [[				f.Position = UDim2.fromOffset((top.X + bot.X) / 2, (top.Y + bot.Y) / 2)]], [[				-- (viewport pixels to the GUI's: on notch phones it starts in from the screen's edge, the safe area)
				local o = gui.AbsolutePosition + game:GetService("GuiService"):GetGuiInset()
				f.Position = UDim2.fromOffset((top.X + bot.X) / 2 - o.X, (top.Y + bot.Y) / 2 - o.Y)]] },
})

patch(game.ReplicatedStorage.Convoy.Aim, {
	{ [[-- the aim point in viewport pixels (same space as UserInputService:GetMouseLocation)
function Aim.screen(): Vector2
	if lastTouch or lastPad then]], [[-- TAP TO FIRE (0.19.16, touch): a quick tap on the screen (not on a button) fires the gun at that spot for a
-- moment, and the crosshair jumps there; dragging still slews the sensor. GunshipClient fires while Aim.tapping().
local tapAt, tapUntil = Vector2.zero, 0
local downs = {} -- touch -> { at = where it went down, t = when }
UIS.InputBegan:Connect(function(input, processed)
	if input.UserInputType == Enum.UserInputType.Touch and not processed then
		downs[input] = { at = Vector2.new(input.Position.X, input.Position.Y), t = os.clock() }
	end
end)
UIS.InputEnded:Connect(function(input)
	local d = downs[input]
	downs[input] = nil
	if not d then
		return
	end
	local here = Vector2.new(input.Position.X, input.Position.Y)
	if os.clock() - d.t > 0.45 or (here - d.at).Magnitude > 14 then
		return -- a hold or a drag (that slews the sensor), not a tap
	end
	local lp = game:GetService("Players").LocalPlayer
	local cv = game:GetService("ReplicatedStorage"):FindFirstChild("Convoy")
	if not lp or not cv or lp:GetAttribute("Screen") ~= "HUD" or lp:GetAttribute("Targeting") or cv:GetAttribute("State") ~= "Running" then
		return
	end
	-- (a touch's position leaves out the top bar; viewport pixels count it, like GetMouseLocation)
	tapAt = d.at + game:GetService("GuiService"):GetGuiInset()
	tapUntil = os.clock() + 0.3
end)
function Aim.tapping(): boolean
	return os.clock() < tapUntil
end

-- the aim point in viewport pixels (same space as UserInputService:GetMouseLocation)
function Aim.screen(): Vector2
	if os.clock() < tapUntil then
		return tapAt
	end
	if lastTouch or lastPad then]] },
})

patch(SPS.GunshipClient, {
	{ [[(firing or player:GetAttribute("TouchFire") or auto)]], [[(firing or player:GetAttribute("TouchFire") or auto or Aim.tapping())]] },
})

return table.concat(log, ", ")
