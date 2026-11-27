-- 0.19.21: the SUPPLY CRATE rolls a case-opening reel (StarterGui.CrateUI.Panel.Reel + CrateUI); the prize is paid as
-- the reel stops (Crate PAY_AFTER 5). Idempotent.
local SES = game:GetService("ScriptEditorService")
local log = {}
local LINE = Color3.fromRGB(74, 78, 58)
local Y = Color3.fromRGB(245, 197, 24)

-- the reel window, over the prize cards (hidden until a spin)
local panel = game.StarterGui.CrateUI.Panel
if not panel:FindFirstChild("Reel") then
	local prizes = panel.Prizes
	local reel = Instance.new("Frame")
	reel.Name = "Reel"
	reel.Size = UDim2.fromOffset(932, 220)
	reel.Position = prizes.Position
	reel.BackgroundColor3 = Color3.fromRGB(16, 18, 14)
	reel.BackgroundTransparency = 0.1
	reel.BorderSizePixel = 0
	reel.ClipsDescendants = true
	reel.Visible = false
	local edge = Instance.new("UIStroke")
	edge.Color = LINE
	edge.Thickness = 2
	edge.Parent = reel
	local strip = Instance.new("Frame")
	strip.Name = "Strip"
	strip.BackgroundTransparency = 1
	strip.Size = UDim2.fromOffset(0, 220)
	strip.Parent = reel
	local card = prizes.Prize1:Clone()
	card.Name = "CardTemplate"
	card.Visible = false
	card.Position = UDim2.new()
	if card:FindFirstChild("Pop") then
		card.Pop:Destroy()
	end
	card.Parent = reel
	for _, side in ipairs({ { "FadeL", 0, 0 }, { "FadeR", 1, 180 } }) do
		local f = Instance.new("Frame")
		f.Name = side[1]
		f.AnchorPoint = Vector2.new(side[2], 0)
		f.Position = UDim2.fromScale(side[2], 0)
		f.Size = UDim2.new(0, 150, 1, 0)
		f.BackgroundColor3 = Color3.fromRGB(16, 18, 14)
		f.BorderSizePixel = 0
		f.ZIndex = 9
		local g = Instance.new("UIGradient")
		g.Rotation = side[3]
		g.Transparency = NumberSequence.new(0, 1)
		g.Parent = f
		f.Parent = reel
	end
	local marker = Instance.new("Frame")
	marker.Name = "Marker"
	marker.AnchorPoint = Vector2.new(0.5, 0)
	marker.Position = UDim2.fromScale(0.5, 0)
	marker.Size = UDim2.new(0, 4, 1, 0)
	marker.BackgroundColor3 = Y
	marker.BorderSizePixel = 0
	marker.ZIndex = 10
	marker.Parent = reel
	for _, p in ipairs({ { "PointerTop", 0, -10 }, { "PointerBottom", 1, 10 } }) do
		local t = Instance.new("Frame")
		t.Name = p[1]
		t.AnchorPoint = Vector2.new(0.5, 0.5)
		t.Position = UDim2.new(0.5, 0, p[2], p[3])
		t.Size = UDim2.fromOffset(22, 22)
		t.Rotation = 45
		t.BackgroundColor3 = Y
		t.BorderSizePixel = 0
		t.ZIndex = 10
		t.Parent = reel
	end
	local flash = Instance.new("Frame")
	flash.Name = "Flash"
	flash.Size = UDim2.fromScale(1, 1)
	flash.BackgroundColor3 = Color3.new(1, 1, 1)
	flash.BackgroundTransparency = 1
	flash.BorderSizePixel = 0
	flash.ZIndex = 11
	flash.Parent = reel
	reel.Parent = panel
	table.insert(log, "Reel made")
end

local scr = game.StarterPlayer.StarterPlayerScripts.CrateUI
local src = scr.Source
local NEW = [==[-- the REEL (0.19.21): a strip of prize cards races past the gold marker and slows down onto the prize (case-opening
-- style), ticking as each card passes. The win pops in its rarity's colour; rare ones flash, the jackpot rains
-- confetti. (Cards that fly past are rolled by the same odds; only the one under the marker is the real prize.)
local reel = panel:WaitForChild("Reel")
local strip = reel:WaitForChild("Strip")
local cardT = reel:WaitForChild("CardTemplate")
local RARITY = {
	Color3.fromRGB(176, 182, 166), Color3.fromRGB(176, 182, 166), -- gems
	Color3.fromRGB(92, 172, 255), Color3.fromRGB(92, 172, 255), -- 2X boosts
	Color3.fromRGB(196, 112, 255), Color3.fromRGB(196, 112, 255), -- free nuke, unlimited ammo
	Y, -- the jackpot
}
local function fillCard(card: Frame, i: number)
	local amount, unit, icon = Shop.dailyLook(C.PRIZES[i])
	card.Amount.Text = amount
	card.Unit.Text = unit
	if string.sub(icon, 1, 13) == "rbxassetid://" then
		card.Icon.Image, card.Icon.ImageRectOffset, card.Icon.ImageRectSize = icon, Vector2.zero, Vector2.zero
	else
		Icons.set(card.Icon, icon)
	end
	card.DayLabel.Text = ""
	card.Edge.Color = RARITY[i] or LINE
	card.Edge.Thickness = 2
	card.BackgroundColor3 = DARK
end
local function rollIndex(): number
	local total = 0
	for _, r in ipairs(C.PRIZES) do
		total += r.w
	end
	local x = math.random() * total
	for i, r in ipairs(C.PRIZES) do
		x -= r.w
		if x <= 0 then
			return i
		end
	end
	return 1
end
local function confetti()
	for _ = 1, 46 do
		local f = Instance.new("Frame")
		f.BorderSizePixel = 0
		f.BackgroundColor3 = ({ Y, Color3.fromRGB(255, 90, 80), Color3.fromRGB(92, 172, 255), Color3.fromRGB(140, 220, 90), Color3.new(1, 1, 1) })[math.random(1, 5)]
		f.Size = UDim2.fromOffset(math.random(6, 11), math.random(10, 16))
		f.Position = UDim2.fromOffset(math.random(0, 980), math.random(-60, 0))
		f.Rotation = math.random(0, 180)
		f.ZIndex = 20
		f.Parent = panel
		local t = 1.1 + math.random() * 0.9
		TweenService:Create(f, TweenInfo.new(t, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Position = UDim2.fromOffset(f.Position.X.Offset + math.random(-120, 120), 520),
			Rotation = f.Rotation + math.random(-360, 360),
		}):Play()
		task.delay(t, function()
			f:Destroy()
		end)
	end
end

local wantSpin = false -- one spin bought with Robux: spin as soon as it lands
local function spin()
	if spinning then
		return
	end
	if freeIn() > 0 and a("CrateSpins", 0) <= 0 then
		local pack = C.PACKS[1]
		if pack.productId > 0 then
			SFX.play("Click", { vol = 0.6 })
			wantSpin = true
			MarketplaceService:PromptProductPurchase(player, pack.productId)
		else
			SFX.play("Click", { vol = 0.5, pitch = 0.7 })
		end
		return
	end
	spinning = true
	SFX.play("Click", { vol = 0.6 })
	local before = player:GetAttribute("CrateResult")
	Action:FireServer("SpinCrate")
	panel.Status.Text = "SPINNING..."
	task.spawn(function()
		local t0 = os.clock()
		local result = nil
		while not result and os.clock() - t0 < 5 do
			task.wait(0.03)
			local r = player:GetAttribute("CrateResult")
			if r ~= before then
				result = tonumber(string.match(r or "", "^(%d+)|"))
			end
		end
		if not result then
			spinning = false
			refresh()
			return
		end
		-- the strip: 46 cards, the prize at 40
		for _, c in ipairs(strip:GetChildren()) do
			c:Destroy()
		end
		local W, GAP, WIN = cardT.Size.X.Offset, 10, 40
		for k = 1, 46 do
			local c = cardT:Clone()
			c.Name = "C" .. k
			c.Visible = true
			c.Position = UDim2.fromOffset((k - 1) * (W + GAP), 0)
			fillCard(c, if k == WIN then result else rollIndex())
			c.Parent = strip
		end
		local mid = reel.Size.X.Offset / 2
		strip.Position = UDim2.fromOffset(mid - W / 2, 0)
		local stopX = mid - ((WIN - 1) * (W + GAP) + W / 2) + (math.random() - 0.5) * W * 0.7
		cards.Visible = false
		reel.Visible = true
		local tw = TweenService:Create(strip, TweenInfo.new(4.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Position = UDim2.fromOffset(stopX, 0) })
		local lastCard = -1
		local tick = RunService.RenderStepped:Connect(function()
			local n = math.floor((mid - strip.Position.X.Offset) / (W + GAP))
			if n ~= lastCard then
				lastCard = n
				SFX.play("Click", { vol = 0.28, pitch = 1.5 })
			end
		end)
		tw:Play()
		tw.Completed:Wait()
		tick:Disconnect()
		-- the win
		local win = strip:FindFirstChild("C" .. WIN)
		local col = RARITY[result] or Y
		if win then
			win.Edge.Color = col
			win.Edge.Thickness = 5
			win.BackgroundColor3 = LIT
			pop(win)
		end
		local flash = reel:FindFirstChild("Flash")
		if flash and result >= 3 then
			flash.BackgroundColor3 = col
			flash.BackgroundTransparency = 0.35
			TweenService:Create(flash, TweenInfo.new(0.6), { BackgroundTransparency = 1 }):Play()
		end
		if result == N then
			confetti()
			SFX.play("Buy", { pitch = 0.75 })
			task.delay(0.25, function()
				SFX.play("Buy", { pitch = 1.0 })
			end)
		else
			SFX.play("Buy", { pitch = if result >= 5 then 0.9 else 1.1 })
		end
		local amount, unit = Shop.dailyLook(C.PRIZES[result])
		panel.Status.Text = (if result == N then "JACKPOT! " else "YOU GOT ") .. amount .. " " .. unit .. "!"
		task.wait(2.6)
		reel.Visible = false
		cards.Visible = true
		lit = result
		spinning = false
		refresh()
	end)
end
spinB.Activated:Connect(spin)]==]
if not src:find("-- the REEL (0.19.21)", 1, true) then
	local a = src:find("-- the light runs round the cards while the server rolls, then slows down onto the prize", 1, true)
	local b1, b2 = src:find("spinB.Activated:Connect(spin)", 1, true)
	assert(a and b1 and b1 > a, "CrateUI spin block not found")
	src = src:sub(1, a - 1) .. NEW .. src:sub(b2 + 1)
	SES:UpdateSourceAsync(scr, function()
		return src
	end)
	table.insert(log, "CrateUI reel")
end

-- pay as the reel stops (it rolls about 4.5 s)
local crate = game.ServerScriptService.ConvoyServer.Crate
local cs = crate.Source
if cs:find("local PAY_AFTER = 3\n", 1, true) then
	cs = cs:gsub("local PAY_AFTER = 3\n", "local PAY_AFTER = 5 -- (CrateUI's reel stops after about 4.5 s)\n")
	SES:UpdateSourceAsync(crate, function()
		return cs
	end)
	table.insert(log, "Crate PAY_AFTER 5")
end
return table.concat(log, ", ")
