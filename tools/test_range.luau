-- TEST RANGE (0.19.21): the shooting range the TEST FLIGHT flies over, 5,000 studs north of the bunker (empty in every
-- map). Run in a place (execute_luau, Edit): rebuilds Workspace.TestRange. Mission reads its attributes:
-- Center (orbit point, top of the pad), Lanes, LaneWidth, StartZ (where the infected start, north), EndZ (the firing line).
-- Parts only, in the game's block style; nothing collides except the pad.
local bunker = workspace.DMZ.Bunker:GetAttribute("Center")
local C = Vector3.new(bunker.X, bunker.Y, bunker.Z - 5000)
local old = workspace:FindFirstChild("TestRange")
if old then
	old:Destroy()
end
local range = Instance.new("Model")
range.Name = "TestRange"
local LANES, LW, Z0, Z1 = 5, 80, -300, 250
range:SetAttribute("Center", C)
range:SetAttribute("Lanes", LANES)
range:SetAttribute("LaneWidth", LW)
range:SetAttribute("StartZ", Z0)
range:SetAttribute("EndZ", Z1)

local HEAVY = Font.new("rbxasset://fonts/families/Oswald.json", Enum.FontWeight.Heavy)
local count = 0
local function part(name, size, cf, color, mat, parent, shape)
	local p = Instance.new("Part")
	p.Name = name
	if shape then
		p.Shape = shape
	end
	p.Size = size
	p.CFrame = cf
	p.Color = color
	p.Material = mat or Enum.Material.SmoothPlastic
	p.Anchored = true
	p.CanCollide = false
	p.CastShadow = size.Magnitude > 12
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.Parent = parent or range
	count += 1
	return p
end
local function at(x, y, z)
	return CFrame.new(C + Vector3.new(x, y, z))
end
local function folder(name)
	local f = Instance.new("Model")
	f.Name = name
	f.Parent = range
	return f
end
local function paint(name, x, z, w, d, text, color, rot)
	-- text painted flat on the ground (seen from the aircraft)
	-- (a Top-face SurfaceGui runs along the part's Z: turned 90 so the words run along the range's X)
	local p = part(name, Vector3.new(d, 0.2, w), at(x, 0.15, z) * CFrame.Angles(0, math.rad(-90 + (rot or 0)), 0), Color3.new(1, 1, 1), nil, range)
	p.Transparency = 1
	local g = Instance.new("SurfaceGui")
	g.Face = Enum.NormalId.Top
	g.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	g.PixelsPerStud = 10
	g.LightInfluence = 0
	g.Parent = p
	local l = Instance.new("TextLabel")
	l.BackgroundTransparency = 1
	l.Size = UDim2.fromScale(1, 1)
	l.FontFace = HEAVY
	l.TextScaled = true
	l.Text = text
	l.TextColor3 = color
	l.Parent = g
	return p
end

local CONCRETE = Color3.fromRGB(96, 98, 90)
local LANE_A, LANE_B = Color3.fromRGB(106, 108, 98), Color3.fromRGB(88, 90, 82)
local WALL = Color3.fromRGB(150, 150, 140)
local YELLOW, BLACK = Color3.fromRGB(245, 197, 24), Color3.fromRGB(30, 30, 28)
local OLIVE = Color3.fromRGB(92, 104, 62)
local SAND = Color3.fromRGB(176, 158, 112)
local RED = Color3.fromRGB(196, 46, 40)
local WHITE = Color3.fromRGB(236, 232, 214)

-- the pad, studded
local pad = part("Pad", Vector3.new(780, 2, 780), at(0, -1, 0), CONCRETE, Enum.Material.Concrete)
pad.CanCollide = true
pad.TopSurface = Enum.SurfaceType.Studs

-- lanes: alternating strips, divider walls with hazard caps
local lanes = folder("Lanes")
local len = Z1 - Z0 + 40
local midZ = (Z0 + Z1) / 2
for i = 1, LANES do
	local x = (i - (LANES + 1) / 2) * LW
	part("Lane" .. i, Vector3.new(LW - 4, 0.2, len), at(x, 0.1, midZ), if i % 2 == 0 then LANE_A else LANE_B, Enum.Material.Concrete, lanes)
end
for i = 0, LANES do
	local x = (i - LANES / 2) * LW
	local w = part("Divider", Vector3.new(2.5, 3, len), at(x, 1.5, midZ), WALL, Enum.Material.Concrete, lanes)
	w.LeftSurface, w.RightSurface = Enum.SurfaceType.Universal, Enum.SurfaceType.Universal
	for z = Z0 - 10, Z1 + 10, 40 do
		part("Cap", Vector3.new(2.7, 0.6, 20), at(x, 3.3, z), if (z // 40) % 2 == 0 then YELLOW else BLACK, nil, lanes)
	end
end

-- distance lines across the lanes (from the firing line), lane numbers at the far end
local marks = folder("Marks")
for d = 100, 500, 100 do
	local z = Z1 - d
	part("Line" .. d, Vector3.new(LANES * LW, 0.25, 2), at(0, 0.2, z), WHITE, nil, marks)
	for i = 1, LANES, 2 do
		local x = (i - (LANES + 1) / 2) * LW
		paint("Dist" .. d, x, z + 9, 34, 12, d .. "M", WHITE).Parent = marks
	end
end
for i = 1, LANES do
	local x = (i - (LANES + 1) / 2) * LW
	paint("LaneNo" .. i, x, Z0 - 14, 26, 26, tostring(i), YELLOW).Parent = marks
end

-- the firing line: a red line, sandbags, TEST RANGE painted, a control tower
local line = folder("FiringLine")
part("RedLine", Vector3.new(LANES * LW + 20, 0.3, 4), at(0, 0.25, Z1), RED, Enum.Material.SmoothPlastic, line)
for row = 0, 1 do
	for x = -LANES * LW / 2 - 10 + row * 6, LANES * LW / 2 + 10, 12 do
		local b = part("Sandbag", Vector3.new(11.5, 3, 4), at(x, 1.5 + row * 3, Z1 + 24 + row * 0.5), SAND, Enum.Material.Fabric, line)
		b.TopSurface = Enum.SurfaceType.Studs
	end
end
paint("Title", 0, Z1 + 52, 170, 34, "TEST RANGE", YELLOW).Parent = line
local tower = folder("Tower")
local tx, tz = 150, Z1 + 70
local base = part("Base", Vector3.new(24, 18, 24), at(tx, 9, tz), OLIVE, Enum.Material.Concrete, tower)
base.TopSurface = Enum.SurfaceType.Studs
base.FrontSurface, base.BackSurface = Enum.SurfaceType.Universal, Enum.SurfaceType.Universal
part("Windows", Vector3.new(25, 5, 25), at(tx, 20.5, tz), Color3.fromRGB(40, 52, 58), Enum.Material.Glass, tower)
part("Roof", Vector3.new(29, 1.6, 29), at(tx, 23.8, tz), BLACK, nil, tower).TopSurface = Enum.SurfaceType.Studs
part("Mast", Vector3.new(0.6, 12, 0.6), at(tx + 8, 30, tz - 8), WALL, Enum.Material.Metal, tower)
part("Beacon", Vector3.new(1.4, 1.4, 1.4), at(tx + 8, 36.5, tz - 8), RED, Enum.Material.Neon, tower)
for i, x in ipairs({ -150, -130, -110 }) do
	part("FlagPole", Vector3.new(0.6, 22, 0.6), at(x, 11, Z1 + 60), WALL, Enum.Material.Metal, tower)
	part("Flag", Vector3.new(0.3, 5, 8), at(x, 19.5, Z1 + 60 + 4), if i == 2 then YELLOW else RED, Enum.Material.Fabric, tower)
end

-- targets: ring boards on posts, facing the firing line
local targets = folder("Targets")
local function target(x, z)
	local m = Instance.new("Model")
	m.Name = "Target"
	m.Parent = targets
	part("PostL", Vector3.new(1, 10, 1), at(x - 5.5, 5, z), Color3.fromRGB(98, 74, 50), Enum.Material.Wood, m)
	part("PostR", Vector3.new(1, 10, 1), at(x + 5.5, 5, z), Color3.fromRGB(98, 74, 50), Enum.Material.Wood, m)
	part("Board", Vector3.new(13, 11, 1), at(x, 9.5, z), Color3.fromRGB(196, 168, 120), Enum.Material.Wood, m)
	for k, r in ipairs({ { 10, WHITE }, { 7.5, RED }, { 5, WHITE }, { 2.5, RED } }) do
		part("Ring", Vector3.new(0.3, r[1], r[1]), at(x, 9.5, z + 0.5 + k * 0.08) * CFrame.Angles(0, math.rad(90), 0), r[2], nil, m, Enum.PartType.Cylinder)
	end
end
for i = 1, LANES do
	local x = (i - (LANES + 1) / 2) * LW
	for k, z in ipairs({ -230, -120, -10, 110 }) do
		target(x + (if (i + k) % 2 == 0 then -18 else 18), z)
	end
end

-- wrecked trucks and barrels (something to blow up near)
local junk = folder("Junk")
local function truck(x, z, yaw)
	local m = Instance.new("Model")
	m.Name = "Truck"
	m.Parent = junk
	local base = at(x, 0, z) * CFrame.Angles(0, math.rad(yaw), 0)
	local function p(name, size, off, color, mat)
		local q = part(name, size, base * CFrame.new(off), color, mat, m)
		q.TopSurface = Enum.SurfaceType.Studs
		return q
	end
	p("Chassis", Vector3.new(9, 2.5, 22), Vector3.new(0, 3, 0), Color3.fromRGB(58, 56, 50), Enum.Material.Metal)
	p("Cab", Vector3.new(8.5, 6, 7), Vector3.new(0, 7, -7), Color3.fromRGB(84, 92, 60), Enum.Material.Metal)
	p("Glass", Vector3.new(7.6, 2.4, 0.4), Vector3.new(0, 8.5, -10.6), Color3.fromRGB(30, 34, 36), Enum.Material.Glass)
	p("Bed", Vector3.new(9, 4, 13), Vector3.new(0, 6.2, 3.5), Color3.fromRGB(72, 80, 52), Enum.Material.Metal)
	for _, w in ipairs({ { -4.6, -7 }, { 4.6, -7 }, { -4.6, 5 }, { 4.6, 5 } }) do
		part("Wheel", Vector3.new(1.6, 4, 4), base * CFrame.new(w[1], 2, w[2]), BLACK, Enum.Material.SmoothPlastic, m, Enum.PartType.Cylinder)
	end
end
truck(-LW, -70, 25)
truck(LW, 40, -160)
truck(0, -190, 95)
local function barrels(x, z)
	for k = 0, 2 do
		local b = part("Barrel", Vector3.new(4, 3, 3), at(x + (k % 2) * 3.2, 2, z + k * 2.6) * CFrame.Angles(0, 0, math.rad(90)), if k == 1 then YELLOW else RED, Enum.Material.Metal, junk, Enum.PartType.Cylinder)
		b.CastShadow = false
	end
end
local rng = Random.new(7)
for i = 1, 12 do
	local lane = (i - 1) % LANES + 1
	barrels((lane - (LANES + 1) / 2) * LW + rng:NextNumber(-25, 25), rng:NextNumber(Z0 + 30, Z1 - 40))
end

-- berms round the pad, light masts at the corners
local edge = folder("Edge")
for _, s in ipairs({ { 0, -400, 800, 40 }, { 0, 400, 800, 40 }, { -400, 0, 40, 800 }, { 400, 0, 40, 800 } }) do
	local b = part("Berm", Vector3.new(s[3], 12, s[4]), at(s[1], 4, s[2]), Color3.fromRGB(110, 100, 78), Enum.Material.Ground, edge)
	b.TopSurface = Enum.SurfaceType.Studs
end
for _, c in ipairs({ { -360, -360 }, { 360, -360 }, { -360, 360 }, { 360, 360 } }) do
	part("LightPole", Vector3.new(2, 46, 2), at(c[1], 23, c[2]), WALL, Enum.Material.Metal, edge)
	part("Lamp", Vector3.new(10, 2.5, 5), at(c[1], 46, c[2]), Color3.fromRGB(255, 232, 170), Enum.Material.Neon, edge)
end

range.Parent = workspace
return "TestRange built at " .. tostring(C) .. ", " .. count .. " parts"
