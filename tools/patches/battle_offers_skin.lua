local script_ = game.StarterPlayer.StarterPlayerScripts.BattleOffers
local src = script_.Source
local HELPERS, NEWBODY, TOAST_OLD, TOAST_NEW = [==[-- the HUD panels' hazard strip along the top edge
local function hazard(parent)
	local hz = Instance.new("ImageLabel")
	hz.BackgroundTransparency = 1
	hz.Image = "rbxassetid://76088323012256"
	hz.ScaleType = Enum.ScaleType.Tile
	hz.TileSize = UDim2.fromOffset(12, 12)
	hz.Position = UDim2.fromOffset(0, -6)
	hz.Size = UDim2.new(1, 0, 0, 6)
	hz.Parent = parent
	return hz
end
-- the tiles' solid, saturated buy button (no pale cream inner outline)
local function solidButton(parent, str, color, pos, sz, size)
	local b, l = button(parent, str, color, pos, sz, size)
	b.Face.BackgroundColor3 = Color3.fromRGB(104, 140, 46)
	b.Lip.BackgroundColor3 = Color3.fromRGB(46, 62, 22)
	b.Lip.Position = UDim2.fromOffset(0, 6)
	b.Face.Inner:FindFirstChildOfClass("UIStroke").Color = Color3.fromRGB(150, 192, 76)
	b.Face.Inner:FindFirstChildOfClass("UIStroke").Thickness = 2
	return b, l
end
]==], [==[	local item = Shop.BATTLE[key]
	lastShown = os.clock()
	local accent = ACCENT[item.accent] or AMBER
	-- the HUD panels' skin (same as the FORTIFY / CASH DROP tiles): dark body, 1 px edge, hazard strip on
	-- top, accent strip down the left, white name, solid buy button; laid out tight, no empty space
	local c = Instance.new("Frame")
	c.Name = "Offer_" .. key
	c.AnchorPoint = Vector2.new(1, 1)
	c.Size = UDim2.fromOffset(372, 124)
	c.Position = cardSpot(600)
	c.BackgroundColor3 = Color3.fromRGB(27, 30, 22)
	c.BackgroundTransparency = 0.08
	c.BorderSizePixel = 0
	c.Parent = root
	scale:Clone().Parent = c
	stroke(c, Color3.fromRGB(74, 78, 58), 1)
	hazard(c)
	local strip = Instance.new("Frame")
	strip.BorderSizePixel = 0
	strip.BackgroundColor3 = accent
	strip.Size = UDim2.new(0, 4, 1, 0)
	strip.Parent = c
	local icon = Instance.new("ImageLabel")
	icon.BackgroundTransparency = 1
	icon.Image = item.icon
	icon.ScaleType = Enum.ScaleType.Fit
	icon.Size = UDim2.fromOffset(96, 96)
	icon.Position = UDim2.fromOffset(12, 14)
	icon.Parent = c
	local title = text(c, item.title, 26, Color3.fromRGB(236, 232, 214), UDim2.fromOffset(118, 8), UDim2.fromOffset(206, 30))
	title.TextScaled = true -- long names shrink instead of running under the X
	title.TextWrapped = false
	title:FindFirstChildOfClass("UIStroke").Thickness = 1.5
	local cap = Instance.new("UITextSizeConstraint")
	cap.MaxTextSize = 26
	cap.Parent = title
	local sub = text(c, string.upper(item.text), 14, SUB, UDim2.fromOffset(118, 38), UDim2.fromOffset(242, 34))
	sub.TextYAlignment = Enum.TextYAlignment.Top
	sub:FindFirstChildOfClass("UIStroke").Thickness = 1
	local b = solidButton(c, ROBUX .. " " .. priceOf(key), accent, UDim2.fromOffset(118, 74), UDim2.fromOffset(150, 38), 26)
	b.MouseButton1Click:Connect(function()
		buy(key)
		closeCard()
	end)
	local x = closeButton(c, UDim2.new(1, -40, 0, 6))
	x.Size = UDim2.fromOffset(34, 34)
	x.TextSize = 26
	x.MouseButton1Click:Connect(closeCard)
	-- time left
	local bar = Instance.new("Frame")
	bar.BackgroundColor3 = accent
	bar.BorderSizePixel = 0
	bar.AnchorPoint = Vector2.new(0, 1)
	bar.Position = UDim2.new(0, 0, 1, 0)
	bar.Size = UDim2.new(1, 0, 0, 3)
	bar.Parent = c
]==], [==[	t.BackgroundColor3 = PANEL
	t.BackgroundTransparency = 0.05
	t.BorderSizePixel = 0
	t.Parent = root
	scale:Clone().Parent = t
	local accent = ACCENT[Shop.BATTLE[key].accent] or LIME
	stroke(t, accent, 3)
]==], [==[	t.BackgroundColor3 = Color3.fromRGB(27, 30, 22)
	t.BackgroundTransparency = 0.08
	t.BorderSizePixel = 0
	t.Parent = root
	scale:Clone().Parent = t
	local accent = ACCENT[Shop.BATTLE[key].accent] or LIME
	stroke(t, Color3.fromRGB(74, 78, 58), 1) -- same skin as the HUD panels
	hazard(t)
	local tStrip = Instance.new("Frame")
	tStrip.BorderSizePixel = 0
	tStrip.BackgroundColor3 = accent
	tStrip.Size = UDim2.new(0, 4, 1, 0)
	tStrip.Parent = t
]==]
local function between(s, a, b)
	local i = s:find(a, 1, true)
	assert(i, "start not found")
	local j = s:find(b, i, true)
	assert(j, "end not found")
	return i, j + #b - 1
end
local anchor = "-- the hub's close button: dark square, red X"
local k = src:find(anchor, 1, true)
assert(k, "anchor")
if not src:find("local function solidButton", 1, true) then
	src = src:sub(1, k - 1) .. HELPERS .. src:sub(k)
end
local i, j = between(src, "\tlocal item = Shop.BATTLE[key]\n\tlastShown = os.clock()", "\tbar.Parent = c\n")
src = src:sub(1, i - 1) .. NEWBODY .. src:sub(j + 1)
src = src:gsub("tween%(bar, SHOW_FOR, { Size = UDim2%.new%(0, 0, 0, 4%) }", "tween(bar, SHOW_FOR, { Size = UDim2.new(0, 0, 0, 3) }")
local a = src:find(TOAST_OLD, 1, true)
assert(a, "toast")
src = src:sub(1, a - 1) .. TOAST_NEW .. src:sub(a + #TOAST_OLD)
script_.Source = src
return "ok " .. #src
