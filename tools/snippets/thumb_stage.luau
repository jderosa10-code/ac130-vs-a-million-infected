-- Thumbnail staging (Edit mode only; removed again by thumb_unstage). Builds a thermal-look scene:
-- posed infected with the game's per-kind Highlights, the ThermalCC grade, and an optional foreground weapon.
-- CONFIG is replaced per shot.
local CONFIG = {
	seed = 1,
	cam = Vector3.new(935, 150, 440), look = Vector3.new(898, 0, 290), fov = 50,
	areas = { -- {center, size(x,z), count}
		{ Vector3.new(900, 0, 330), Vector2.new(24, 200), 30 },
	},
	specials = { -- {kind, position}
	},
	weapon = nil, -- "minigun" | "rocket"
	weaponAt = Vector3.new(0.32, -0.26, 1), -- (right, up, forward) as fractions of the view, forward in studs*10
	weaponAim = Vector3.new(900, 0, 330),
	minSpacing = 5.5,
}

local SS, Lighting = game:GetService("ServerStorage"), game:GetService("Lighting")
local T = SS.ConvoyTemplates
local old = workspace:FindFirstChild("_ThumbStage")
if old then old:Destroy() end
local stage = Instance.new("Folder")
stage.Name = "_ThumbStage"
local rng = Random.new(CONFIG.seed)

---------------------------------------------------------------- thermal grade (same numbers as GunshipClient)
local cc = Lighting:FindFirstChild("_ThumbCC") or Instance.new("ColorCorrectionEffect")
cc.Name = "_ThumbCC"
cc.Saturation, cc.Contrast, cc.Brightness = -1, 0.55, -0.08
cc.TintColor = Color3.fromRGB(225, 235, 225)
cc.Parent = Lighting

local TINT = {
	Normal = Color3.fromRGB(255, 40, 40), Runner = Color3.fromRGB(255, 110, 200), Brute = Color3.fromRGB(170, 90, 255),
	Bomber = Color3.fromRGB(255, 150, 30), Spitter = Color3.fromRGB(255, 220, 0), Armored = Color3.fromRGB(70, 170, 255),
}
local SCALE = { Normal = 1, Runner = 0.72, Brute = 1.75, Bomber = 1.1, Spitter = 1, Armored = 1.3 }
local RIG = { Brute = T.Types.Brute, Bomber = T.Types.Bomber, Spitter = T.Types.Spitter, Armored = T.Types.Armored }
local groups = {}
local function group(kind)
	if groups[kind] then return groups[kind] end
	local m = Instance.new("Model")
	m.Name = kind
	local h = Instance.new("Highlight")
	local tint = TINT[kind]
	h.FillColor = Color3.new(0, 0, 0):Lerp(tint, if kind == "Normal" then 0.3 else 0.55)
	h.FillTransparency = 0
	h.OutlineColor = Color3.new(1, 1, 1):Lerp(tint, 0.45)
	h.OutlineTransparency = 0.35
	h.DepthMode = Enum.HighlightDepthMode.Occluded
	h.Parent = m
	m.Parent = stage
	groups[kind] = m
	return m
end

---------------------------------------------------------------- posing (rigid: rotate a limb chain about its joint)
local function rot(parts, pivot: Vector3, axis: Vector3, ang: number)
	local r = CFrame.new(pivot) * CFrame.fromAxisAngle(axis, ang) * CFrame.new(-pivot)
	for _, p in ipairs(parts) do
		if p then p.CFrame = r * p.CFrame end
	end
end
local function pose(m)
	for _, d in ipairs(m:GetDescendants()) do
		if d:IsA("BasePart") then d.Anchored = true; d.CanCollide = false; d.CastShadow = true end
	end
	local ut, lt = m:FindFirstChild("UpperTorso"), m:FindFirstChild("LowerTorso")
	if not ut then return end
	local right = ut.CFrame.RightVector
	local function att(part, name)
		local a = part and part:FindFirstChild(name)
		return a and a.WorldPosition
	end
	-- arms reaching forward (zombie), a little uneven
	for _, s in ipairs({ "Left", "Right" }) do
		local up = att(ut, s .. "ShoulderRigAttachment")
		if up then
			rot({ m:FindFirstChild(s .. "UpperArm"), m:FindFirstChild(s .. "LowerArm"), m:FindFirstChild(s .. "Hand") }, up, right,
				math.rad(rng:NextNumber(62, 92)))
		end
	end
	-- mid-stride legs
	local swing = math.rad(rng:NextNumber(14, 26))
	for i, s in ipairs({ "Left", "Right" }) do
		local hip = att(lt, s .. "HipRigAttachment")
		if hip then
			rot({ m:FindFirstChild(s .. "UpperLeg"), m:FindFirstChild(s .. "LowerLeg"), m:FindFirstChild(s .. "Foot") }, hip, right,
				if i == 1 then swing else -swing)
		end
	end
	-- hunched forward
	local waist = att(lt, "WaistRigAttachment") or ut.Position
	local upper = {}
	for _, n in ipairs({ "UpperTorso", "Head", "LeftUpperArm", "LeftLowerArm", "LeftHand", "RightUpperArm", "RightLowerArm", "RightHand" }) do
		table.insert(upper, m:FindFirstChild(n))
	end
	for _, d in ipairs(m:GetChildren()) do
		if d:IsA("Accessory") then
			local h = d:FindFirstChild("Handle")
			if h then table.insert(upper, h) end
		end
	end
	rot(upper, waist, right, math.rad(rng:NextNumber(10, 22)))
end

local params = RaycastParams.new()
params.FilterType = Enum.RaycastFilterType.Exclude
params.FilterDescendantsInstances = { stage }
local function ground(p: Vector3): number
	local r = workspace:Raycast(Vector3.new(p.X, 300, p.Z), Vector3.new(0, -600, 0), params)
	return if r then r.Position.Y else 0
end

local function place(kind: string, at: Vector3, face: Vector3)
	local src
	if RIG[kind] then
		local kids = RIG[kind]:GetChildren()
		src = kids[rng:NextInteger(1, #kids)]
	else
		local kids = T.Infected:GetChildren()
		src = kids[rng:NextInteger(1, #kids)]
	end
	local m = src:Clone()
	m:ScaleTo(m:GetScale() * SCALE[kind])
	local dir = (face - at) * Vector3.new(1, 0, 1)
	dir = if dir.Magnitude > 0.1 then dir.Unit else Vector3.new(0, 0, -1)
	local yaw = CFrame.fromAxisAngle(Vector3.yAxis, math.rad(rng:NextNumber(-28, 28)))
	local cf, size = m:GetBoundingBox()
	m:PivotTo(CFrame.lookAt(at, at + yaw:VectorToWorldSpace(dir)) * m:GetPivot().Rotation:Inverse() * m:GetPivot().Rotation)
	m.Parent = stage -- (raycasts ignore the stage)
	pose(m)
	cf, size = m:GetBoundingBox()
	local bottom = cf.Position.Y - size.Y / 2
	m:PivotTo(m:GetPivot() + Vector3.new(0, ground(at) - bottom, 0))
	m.Parent = group(kind)
	return m
end

---------------------------------------------------------------- the crowd
local placed = {}
local function free(p, r)
	for _, q in ipairs(placed) do
		if (q - p).Magnitude < r then return false end
	end
	return true
end
for _, s in ipairs(CONFIG.specials) do
	place(s[1], s[2], s[3] or CONFIG.face or CONFIG.look)
	table.insert(placed, s[2])
end
for _, a in ipairs(CONFIG.areas) do
	local c, sz, n = a[1], a[2], a[3]
	local made, tries = 0, 0
	while made < n and tries < n * 60 do
		tries += 1
		local p = c + Vector3.new(rng:NextNumber(-sz.X / 2, sz.X / 2), 0, rng:NextNumber(-sz.Y / 2, sz.Y / 2))
		if free(p, CONFIG.minSpacing) then
			table.insert(placed, p)
			place(a[4] or "Normal", p, a[5] or CONFIG.face or CONFIG.look)
			made += 1
		end
	end
end

---------------------------------------------------------------- foreground weapon
local cam = workspace.CurrentCamera
cam.FieldOfView = CONFIG.fov
local camCF = CFrame.lookAt(CONFIG.cam, CONFIG.look)
local function hl(model, fill, fillT, outline, outT)
	local h = Instance.new("Highlight")
	h.FillColor, h.FillTransparency = fill, fillT
	h.OutlineColor, h.OutlineTransparency = outline, outT
	h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	h.Parent = model
end
local function part(parent, shape, size, cf, color, mat)
	local p = Instance.new("Part")
	p.Shape = shape or Enum.PartType.Block
	p.Size, p.CFrame, p.Color = size, cf, color
	p.Material = mat or Enum.Material.SmoothPlastic
	p.Anchored, p.CanCollide, p.CastShadow = true, false, false
	p.TopSurface, p.BottomSurface = Enum.SurfaceType.Smooth, Enum.SurfaceType.Smooth
	p.Parent = parent
	return p
end
local w = CONFIG.weapon
if w then
	local f = CONFIG.weaponAt
	local dist = f.Z * 10
	local halfH = math.tan(math.rad(CONFIG.fov / 2)) * dist
	local halfW = halfH * (cam.ViewportSize.X / cam.ViewportSize.Y)
	local at = camCF.Position + camCF.LookVector * dist + camCF.RightVector * (f.X * 2 * halfW) + camCF.UpVector * (f.Y * 2 * halfH)
	local aim = CFrame.lookAt(at, CONFIG.weaponAim)
	if CONFIG.sideOn then -- point along the on-screen line to the target, tilted only part-way into the screen (seen from the side)
		cam.CFrame = camCF
		local a2, t2 = cam:WorldToViewportPoint(at), cam:WorldToViewportPoint(CONFIG.weaponAim)
		local d = Vector2.new(t2.X - a2.X, t2.Y - a2.Y).Unit
		local flat = (camCF.RightVector * d.X - camCF.UpVector * d.Y).Unit
		local tilt = math.rad(CONFIG.sideOn)
		aim = CFrame.lookAt(at, at + flat * math.cos(tilt) + camCF.LookVector * math.sin(tilt))
	end
	if w == "minigun" then
		-- built from parts: six long barrels, rings, a short housing and motor. Dark metal under a light,
		-- mostly see-through navy Highlight with a white rim, so the grey/black shading still shows.
		local g = Instance.new("Model")
		g.Name = "Gun"
		local L = CONFIG.weaponLen or 7
		local aimR = aim * CFrame.Angles(0, 0, math.rad(CONFIG.weaponRoll or 12))
		local ax = CFrame.Angles(0, math.rad(90), 0)
		local metal, dark, light = Color3.fromRGB(84, 88, 100), Color3.fromRGB(12, 12, 14), Color3.fromRGB(200, 204, 214)
		local bl, bz = L * 0.64, -L * 0.3 -- barrel length / centre: the tip is at -0.76 L
		for i = 0, 5 do
			local a = math.rad(60 * i)
			local off = Vector3.new(math.cos(a), math.sin(a), 0) * L * 0.075
			part(g, Enum.PartType.Cylinder, Vector3.new(bl, L * 0.05, L * 0.05), aimR * CFrame.new(off + Vector3.new(0, 0, bz)) * ax, dark)
		end
		part(g, Enum.PartType.Cylinder, Vector3.new(bl * 0.98, L * 0.05, L * 0.05), aimR * CFrame.new(0, 0, bz) * ax, metal) -- spindle
		part(g, Enum.PartType.Cylinder, Vector3.new(L * 0.035, L * 0.18, L * 0.18), aimR * CFrame.new(0, 0, -L * 0.6) * ax, light) -- muzzle clamp
		part(g, Enum.PartType.Cylinder, Vector3.new(L * 0.035, L * 0.18, L * 0.18), aimR * CFrame.new(0, 0, -L * 0.34) * ax, metal) -- mid clamp
		part(g, Enum.PartType.Cylinder, Vector3.new(L * 0.22, L * 0.22, L * 0.22), aimR * CFrame.new(0, 0, L * 0.1) * ax, metal) -- rotor housing
		part(g, Enum.PartType.Cylinder, Vector3.new(L * 0.03, L * 0.25, L * 0.25), aimR * CFrame.new(0, 0, -L * 0.02) * ax, dark)
		part(g, nil, Vector3.new(L * 0.18, L * 0.16, L * 0.24), aimR * CFrame.new(0, -L * 0.1, L * 0.3), metal) -- receiver
		part(g, Enum.PartType.Cylinder, Vector3.new(L * 0.16, L * 0.09, L * 0.09), aimR * CFrame.new(L * 0.13, L * 0.03, L * 0.22) * ax, dark) -- motor
		part(g, nil, Vector3.new(L * 0.05, L * 0.12, L * 0.3), aimR * CFrame.new(-L * 0.12, -L * 0.06, L * 0.2), dark) -- feed chute
		g.Parent = stage
		hl(g, Color3.fromRGB(60, 80, 190), CONFIG.gunFill or 0.82, Color3.fromRGB(255, 255, 255), 0.1)
		cam.CFrame = camCF
		local v = cam:WorldToViewportPoint((aimR * CFrame.new(0, 0, -L * 0.66)).Position)
		stage:SetAttribute("Muzzle", Vector2.new(v.X / cam.ViewportSize.X * 2061 - 70, v.Y / cam.ViewportSize.Y * 1080))
	elseif w == "rocket" then
		local r = Instance.new("Model")
		r.Name = "Rocket"
		local L = CONFIG.weaponLen or 7
		local d = L * 0.16
		local axisCF = aim * CFrame.Angles(0, math.rad(90), 0) -- part X axis along the aim
		part(r, Enum.PartType.Cylinder, Vector3.new(L, d, d), axisCF, Color3.fromRGB(168, 150, 104))
		part(r, Enum.PartType.Ball, Vector3.new(d, d, d), aim * CFrame.new(0, 0, -L / 2), Color3.fromRGB(168, 150, 104))
		part(r, Enum.PartType.Cylinder, Vector3.new(d * 0.6, d * 0.7, d * 0.7), axisCF * CFrame.new(-L * 0.52, 0, 0), Color3.fromRGB(60, 60, 60))
		for i = 0, 3 do -- big mid wings and small tail fins, a cross like the game's
			local roll = CFrame.Angles(0, 0, math.rad(45 + 90 * i))
			part(r, nil, Vector3.new(d * 0.12, d * 2.4, L * 0.22), aim * roll * CFrame.new(0, d * 1.1, -L * 0.05), Color3.fromRGB(150, 132, 90))
			part(r, nil, Vector3.new(d * 0.12, d * 1.3, L * 0.12), aim * roll * CFrame.new(0, d * 0.7, L * 0.42), Color3.fromRGB(150, 132, 90))
		end
		r.Parent = stage
		hl(r, Color3.fromRGB(190, 160, 96), 0.35, Color3.fromRGB(255, 238, 190), 0.4)
		-- motor flame and a white smoke trail back toward the launcher
		local fl = Instance.new("Model")
		fl.Name = "Flame"
		part(fl, Enum.PartType.Ball, Vector3.new(d * 1.5, d * 1.5, d * 1.5), aim * CFrame.new(0, 0, L * 0.62), Color3.new(1, 1, 1), Enum.Material.Neon)
		part(fl, Enum.PartType.Cylinder, Vector3.new(d * 2.2, d * 1.1, d * 1.1), axisCF * CFrame.new(-L * 0.78, 0, 0), Color3.new(1, 1, 1), Enum.Material.Neon)
		fl.Parent = stage
		hl(fl, Color3.fromRGB(255, 214, 40), 0.05, Color3.fromRGB(255, 255, 200), 0.2)
		local sm = Instance.new("Model")
		sm.Name = "Smoke"
		local back = -aim.LookVector
		local trail = CONFIG.trailDir and CONFIG.trailDir.Unit or back
		for i = 1, 14 do
			local s = d * (1.6 + i * 0.32)
			local p = at + back * L * 0.7 + trail * (d * 1.2) * (i ^ 1.15) + Vector3.new(rng:NextNumber(-0.1, 0.1), rng:NextNumber(-0.1, 0.1), 0) * d * i
			part(sm, Enum.PartType.Ball, Vector3.new(s, s, s), CFrame.new(p), Color3.new(1, 1, 1))
		end
		sm.Parent = stage
		hl(sm, Color3.fromRGB(235, 238, 240), 0.15, Color3.fromRGB(255, 255, 255), 0.6)
	end
end
stage.Parent = workspace
local n = 0
for _, g in pairs(groups) do n += #g:GetChildren() - 1 end
return "staged " .. n .. " bodies"
