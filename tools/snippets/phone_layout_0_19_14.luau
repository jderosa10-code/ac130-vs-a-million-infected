-- 0.19.14 phone layout patch, final form (from 0.19.13 sources). Idempotent.
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
			error("anchor not found in " .. scr.Name .. ": " .. p[1]:sub(1, 70))
		end
		if src:find(p[1], b + 1, true) then
			error("anchor twice in " .. scr.Name)
		end
		src = src:sub(1, a - 1) .. p[2] .. src:sub(b + 1)
		changed = true
	end
	if changed then
		SES:UpdateSourceAsync(scr, function()
			return src
		end)
	end
	table.insert(log, scr.Name .. (if changed then " patched" else " already"))
end
local SPS = game.StarterPlayer.StarterPlayerScripts

patch(SPS.GunshipUI, {
	{ [[local TABLET_HUD_K = 1.35 -- tablets (iPad): the in-game HUD this much bigger than the screen's scale (the menus are fine)]],
		[[local TABLET_HUD_K = 1.35 -- tablets (iPad): the in-game HUD this much bigger than the screen's scale (menus: 1.25, fitScreens)]] },
	{ [[					local hk = if touch and not phone and screen.Name == "HUD" then TABLET_HUD_K else 1]],
		[[					-- tablets (iPad): the HUD TABLET_HUD_K bigger, the hangar screens 1.25 (they looked small on an iPad),
					-- except the hub's AIRCRAFT / PLAY / RANKS bar (any bigger and it runs into the move stick)
					local hk = if touch and not phone
						then (if screen.Name == "HUD" then TABLET_HUD_K elseif screen.Name == "Menu" and f.Name == "Bottom" then 1 else 1.25)
						else 1]] },
	{ [[								local top = rc.Position.Y.Scale * vp.Y + rc.Position.Y.Offset + rc.Size.Y.Offset * rk + 10]],
		[[								-- (tablets: SHOP / SEASON / FREE sit a little further down from the rank card)
								local gap = if not phone and f.Name == "Side" then 50 else 10
								local top = rc.Position.Y.Scale * vp.Y + rc.Position.Y.Offset + rc.Size.Y.Offset * rk + gap]] },
	{ [[local PHONE_K = { Controls = 0.62, Tally = 0.75, Weapons = PHONE_WEAPONS_K } -- phones: pieces that start smaller]],
		[[local PHONE_K = { Controls = 0.85, Tally = 0.75, Weapons = PHONE_WEAPONS_K, Side = 0.7, SideRight = 0.85 } -- phones: pieces that start smaller]] },
	{ [[local function fitScreens(vp: Vector2, s: number)
	local pad = 6
	local rbW, rbH = robloxButtons()
]], [[local function fitScreens(vp: Vector2, s: number)
	local pad = 6
	local rbW, rbH = robloxButtons()
	gui:SetAttribute("FitRbW", rbW) -- the top-bar width this fit used (fit again when it changes: below rescale)
	-- the hub's side tiles (SHOP / SEASON / FREE, DAILY / INVITE / DEAL): a column (as built), or on phones one row
	local function rowTiles(f: GuiObject, row: boolean)
		if not f:GetAttribute("ColSize") then
			f:SetAttribute("ColSize", f.Size)
			for _, b in ipairs(f:GetChildren()) do
				if b:IsA("GuiButton") then
					b:SetAttribute("ColPos", b.Position)
				end
			end
		end
		local tiles = {}
		for _, b in ipairs(f:GetChildren()) do
			if b:IsA("GuiButton") and b:GetAttribute("ColPos") then
				table.insert(tiles, b)
			end
		end
		table.sort(tiles, function(a, b)
			return a:GetAttribute("ColPos").Y.Offset < b:GetAttribute("ColPos").Y.Offset
		end)
		if row and #tiles > 0 then
			local w, h, gap = tiles[1].Size.X.Offset, tiles[1].Size.Y.Offset, 12
			f.Size = UDim2.fromOffset(#tiles * w + (#tiles - 1) * gap, h)
			for i, b in ipairs(tiles) do
				b.Position = UDim2.fromOffset((i - 1) * (w + gap), 0)
			end
		else
			f.Size = f:GetAttribute("ColSize")
			for _, b in ipairs(tiles) do
				b.Position = b:GetAttribute("ColPos")
			end
		end
	end

]] },
	{ [[						if screen.Name == "Menu" and (f.Name == "Side" or f.Name == "SideRight") then
							-- phones / tablets: the side tiles (SHOP, SEASON, DAILY, INVITE, DEAL) hang from just under the rank
							-- card instead of being centred low by the PLAY bar; if they shrink, they shrink from the bottom
							baseAnchor[f] = baseAnchor[f] or f.AnchorPoint
							local rc = screen:FindFirstChild("RankCard")
							if touch and rc then]], [[						if screen.Name == "Menu" and (f.Name == "Side" or f.Name == "SideRight") then
							-- phones / tablets: the side tiles (SHOP, SEASON, DAILY, INVITE, DEAL) hang from just under the rank
							-- card instead of being centred low by the PLAY bar; if they shrink, they shrink from the bottom.
							-- Phones: SHOP / SEASON / FREE are one row under the rank card (off the move stick), DAILY / INVITE /
							-- DEAL a column from just under the gear / CODES (above the jump button)
							baseAnchor[f] = baseAnchor[f] or f.AnchorPoint
							rowTiles(f, phone and f.Name == "Side")
							local rc = screen:FindFirstChild("RankCard")
							if phone and f.Name == "SideRight" then
								f.AnchorPoint = Vector2.new(1, 0)
								bp = UDim2.new(1, bp.X.Offset, 0, rbH + pad + 4)
							elseif touch and rc then]] },
	{ [[							else
								f.AnchorPoint = baseAnchor[f]
							end
						end
						for _ = 1, 16 do]], [[							else
								f.AnchorPoint = baseAnchor[f]
							end
						end
						if screen.Name == "Menu" and f.Name == "Bottom" then
							-- phones: AIRCRAFT / PLAY / RANKS stay centred, a bit narrower, so AIRCRAFT clears the move stick
							-- (and RANKS the jump button)
							baseAnchor[f] = baseAnchor[f] or f.AnchorPoint
							f.AnchorPoint = baseAnchor[f]
							if phone then
								k = math.min(k, (vp.X - 240) / f.Size.X.Offset)
							end
						end
						for _ = 1, 16 do]] },
	{ [[task.delay(1, rescale)
task.delay(3, rescale)]], [[task.delay(1, rescale)
task.delay(3, rescale)
-- our top-bar icons (TopbarPlus: the gear, CODES) load after this script and come and go (CODES hides in the
-- aircraft): when the room they take changes, fit again, or the gem bar sat under CODES on phones
task.spawn(function()
	while true do
		task.wait(0.5)
		if math.abs(robloxButtons() - (gui:GetAttribute("FitRbW") or -1)) > 1 then
			rescale()
		end
	end
end)]] },
})

local function append(scr, marker, body)
	local s = scr.Source
	if s:find(marker, 1, true) then
		table.insert(log, scr.Name .. " already")
		return
	end
	s ..= "\n" .. marker .. body
	SES:UpdateSourceAsync(scr, function()
		return s
	end)
	table.insert(log, scr.Name .. " patched")
end
append(SPS.TopbarIcons, "-- phones: top right (settings)", [[, out of the way of Roblox's buttons and the gem bar. Only in the hangar: in the
-- aircraft it stays on the left, where the HUD's layout keeps room for it (the bunker bar is in the top right)
do
	local UIS = game:GetService("UserInputService")
	local side = nil
	local function place()
		local cam = workspace.CurrentCamera
		local vp = cam and cam.ViewportSize or Vector2.new(1920, 1080)
		local phone = UIS.TouchEnabled and vp.Y > 200 and vp.Y < 600
		local want = if phone and player:GetAttribute("Screen") ~= "HUD" then "Right" else "Left"
		if want ~= side then
			side = want
			settings:align(want)
		end
	end
	place()
	workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(place)
	player:GetAttributeChangedSignal("Screen"):Connect(place)
end
]])
append(SPS.CodesUI, "-- phones: top right (icon)", [[, out of the way of Roblox's buttons and the gem bar
do
	local UIS = game:GetService("UserInputService")
	local side = nil
	local function place()
		local cam = workspace.CurrentCamera
		local vp = cam and cam.ViewportSize or Vector2.new(1920, 1080)
		local want = if UIS.TouchEnabled and vp.Y > 200 and vp.Y < 600 then "Right" else "Left"
		if want ~= side then
			side = want
			icon:align(want)
		end
	end
	place()
	workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(place)
end
]])

patch(SPS.PadHUD, {
	{ [[		sScale.Scale = math.clamp(workspace.CurrentCamera.ViewportSize.Y / math.max(640, panelSize.Y.Offset + 80), 0.7, 1.4) -- big: it's the main thing on screen]],
		[[		local vp = workspace.CurrentCamera.ViewportSize
		if UIS.TouchEnabled and vp.Y < 600 then
			-- phones: still big, but it fits under the top bar (at 0.7 it ran up under Roblox's buttons)
			local top = 58
			pcall(function()
				top = game:GetService("GuiService").TopbarInset.Max.Y
			end)
			local k = math.clamp((vp.Y - top - 28) / panelSize.Y.Offset, 0.4, 0.7)
			sScale.Scale = k
			panel.Position = UDim2.new(0.5, 0, 0.5, top / 2 / k)
		else
			sScale.Scale = math.clamp(vp.Y / math.max(640, panelSize.Y.Offset + 80), 0.7, 1.4) -- big: it's the main thing on screen
			panel.Position = UDim2.fromScale(0.5, 0.5)
		end]] },
})
game.ReplicatedStorage.Convoy:SetAttribute("GameVersion", "0.19.14")

-- hash the 4 scripts so the places can be compared
local function h(s)
	local x = 5381
	for i = 1, #s do
		x = (x * 33 + string.byte(s, i)) % 4294967296
	end
	return string.format("%08x", x)
end
local hs = {}
for _, n in ipairs({ "GunshipUI", "TopbarIcons", "CodesUI", "PadHUD" }) do
	table.insert(hs, n .. "=" .. h(SPS[n].Source))
end
return table.concat(log, ", ") .. " | " .. table.concat(hs, " ")
