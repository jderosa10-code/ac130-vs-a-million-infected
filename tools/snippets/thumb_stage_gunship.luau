-- Gunship thumbnail staging on the lobby Baseplate (Edit mode only; nothing here is saved).
-- Low camera in a huge charging horde, the AC-130 banked overhead with its left-side guns on the crowd.
-- Returns screen points (0..1 of the viewport) for tools/thumb_fx_gunship.py. Clean up with the unstage block at the end of the session.
local SS, Lighting, HS = game:GetService("ServerStorage"), game:GetService("Lighting"), game:GetService("HttpService")
local T = SS.ConvoyTemplates
local CFG = workspace:GetAttribute("_ThumbCfg") and HS:JSONDecode(workspace:GetAttribute("_ThumbCfg")) or {}
local old = workspace:FindFirstChild("_ThumbStage")
if old then old:Destroy() end
local stage = Instance.new("Folder")
stage.Name = "_ThumbStage"
stage.Parent = workspace
local rng = Random.new(CFG.seed or 7)
local GROUND = workspace.Baseplate.Position.Y + workspace.Baseplate.Size.Y / 2

if not Lighting:GetAttribute("_ThumbSaved") then
	Lighting:SetAttribute("_ThumbSaved", HS:JSONEncode({ ClockTime = Lighting.ClockTime, Brightness = Lighting.Brightness,
		ExposureCompensation = Lighting.ExposureCompensation, Density = Lighting.Atmosphere.Density, Haze = Lighting.Atmosphere.Haze }))
end
Lighting.ClockTime = CFG.clock or 15.6
Lighting.Brightness = 2.4
Lighting.ExposureCompensation = -0.15
Lighting.Atmosphere.Density = 0.22
Lighting.Atmosphere.Haze = 1.2

local function rot(parts, pivot, axis, ang)
	local r = CFrame.new(pivot) * CFrame.fromAxisAngle(axis, ang) * CFrame.new(-pivot)
	for _, p in ipairs(parts) do
		if p then p.CFrame = r * p.CFrame end
	end
end
local function anchor(m)
	for _, d in ipairs(m:GetDescendants()) do
		if d:IsA("BasePart") then d.Anchored = true; d.CanCollide = false; d.CastShadow = true end
		if d:IsA("Script") or d:IsA("LocalScript") then d:Destroy() end
	end
end
local function att(part, name)
	local a = part and part:FindFirstChild(name)
	return a and a.WorldPosition
end
local STD = { Head = 1, UpperTorso = 1, LowerTorso = 1, LeftUpperArm = 1, LeftLowerArm = 1, LeftHand = 1, RightUpperArm = 1, RightLowerArm = 1, RightHand = 1,
	LeftUpperLeg = 1, LeftLowerLeg = 1, LeftFoot = 1, RightUpperLeg = 1, RightLowerLeg = 1, RightFoot = 1, HumanoidRootPart = 1 }
local function pose(m, reach, lunge, spread)
	local ut, lt = m:FindFirstChild("UpperTorso"), m:FindFirstChild("LowerTorso")
	if not ut then return end
	-- extra parts (eyes, gear) follow the body part they sit on
	local follow = {}
	for _, d in ipairs(m:GetDescendants()) do
		if d:IsA("BasePart") and not STD[d.Name] then
			local best, bd = nil, math.huge
			for n in pairs(STD) do
				local p = m:FindFirstChild(n)
				if p and n ~= "HumanoidRootPart" and (p.Position - d.Position).Magnitude < bd then best, bd = p, (p.Position - d.Position).Magnitude end
			end
			if best then table.insert(follow, { d, best, best.CFrame:ToObjectSpace(d.CFrame) }) end
		end
	end
	local right, look = ut.CFrame.RightVector, ut.CFrame.LookVector
	for i, s in ipairs({ "Left", "Right" }) do
		local up = att(ut, s .. "ShoulderRigAttachment")
		if up then
			local arm = { m:FindFirstChild(s .. "UpperArm"), m:FindFirstChild(s .. "LowerArm"), m:FindFirstChild(s .. "Hand") }
			rot(arm, up, right, math.rad(reach + rng:NextNumber(-14, 14)))
			rot(arm, up, look, math.rad((if i == 1 then -1 else 1) * (spread or 0)))
		end
	end
	local swing = math.rad(rng:NextNumber(18, 36))
	for i, s in ipairs({ "Left", "Right" }) do
		local hip = att(lt, s .. "HipRigAttachment")
		if hip then
			rot({ m:FindFirstChild(s .. "UpperLeg"), m:FindFirstChild(s .. "LowerLeg"), m:FindFirstChild(s .. "Foot") }, hip, right, if i == 1 then swing else -swing)
		end
	end
	local waist = att(lt, "WaistRigAttachment") or ut.Position
	local upper = {}
	for _, n in ipairs({ "UpperTorso", "Head", "LeftUpperArm", "LeftLowerArm", "LeftHand", "RightUpperArm", "RightLowerArm", "RightHand" }) do
		table.insert(upper, m:FindFirstChild(n))
	end
	rot(upper, waist, right, math.rad(lunge + rng:NextNumber(-6, 6)))
	local neck = att(ut, "NeckRigAttachment")
	if neck and m:FindFirstChild("Head") then
		rot({ m.Head }, neck, right, math.rad(-lunge * 0.7))
	end
	for _, f in ipairs(follow) do
		f[1].CFrame = f[2].CFrame * f[3]
	end
end
local SCALE = { Normal = 1, Brute = 1.9, Bomber = 1.1, Armored = 1.3, Spitter = 1 }
local function zombie(kind, at, face, o)
	o = o or {}
	local src
	if kind ~= "Normal" and T.Types:FindFirstChild(kind) then
		local kids = T.Types[kind]:GetChildren()
		src = kids[rng:NextInteger(1, #kids)]
	else
		local kids = T.Infected:GetChildren()
		src = kids[rng:NextInteger(1, #kids)]
	end
	local m = src:Clone()
	m:ScaleTo(m:GetScale() * (SCALE[kind] or 1) * (o.scale or 1))
	local dir = ((face - at) * Vector3.new(1, 0, 1)).Unit
	local yaw = CFrame.fromAxisAngle(Vector3.yAxis, math.rad(o.yaw or rng:NextNumber(-22, 22)))
	m:PivotTo(CFrame.lookAt(at, at + yaw:VectorToWorldSpace(dir)))
	m.Parent = stage
	anchor(m)
	pose(m, o.reach or 80, o.lunge or 18, o.spread or rng:NextNumber(5, 25))
	if o.tumble then -- thrown by a blast: spun and lifted
		m:PivotTo(CFrame.new(m:GetPivot().Position) * CFrame.Angles(rng:NextNumber(-3, 3), rng:NextNumber(-3, 3), rng:NextNumber(-3, 3)))
	end
	local cf, size = m:GetBoundingBox()
	m:PivotTo(m:GetPivot() + Vector3.new(0, GROUND + (o.air or 0) - (cf.Position.Y - size.Y / 2), 0))
	return m
end

---------------------------------------------------------------- the gunner's view
-- the AC-130 banked over the horde (guns down local -X on the horde), the camera at the gun door
local cam = workspace.CurrentCamera
local TG = Vector3.new(CFG.x or -9714, GROUND, CFG.z or 0) -- middle of the horde
local ac = game.ReplicatedStorage.Convoy.Models.AC130:Clone()
ac.Name = "AC130"
ac.Parent = stage
anchor(ac)
local acPos = TG + Vector3.new(CFG.acX or 95, CFG.acH or 78, CFG.acZ or -40)
local xAxis = (acPos - TG).Unit
local nose = Vector3.new(0, 0, 1)
local zAxis = -(nose - xAxis * xAxis:Dot(nose)).Unit
local yAxis = zAxis:Cross(xAxis)
ac:PivotTo(CFrame.fromMatrix(acPos, xAxis, yAxis, zAxis))
local pv = ac:GetPivot()
local eye = pv * Vector3.new(CFG.camX or -12, CFG.camY or -4.6, CFG.camZ or 19.5)
local lookAt = TG + Vector3.new(CFG.lookX or 0, 0, CFG.lookZ or 0)
local camCF = CFrame.lookAt(eye, lookAt) * CFrame.Angles(0, 0, math.rad(CFG.roll or -12))
cam.FieldOfView = CFG.fov or 55
cam.CFrame = camCF
local function ahead(dx, dz) return TG + Vector3.new(dx, 0, dz) end

---------------------------------------------------------------- the horde
local placed = {}
local function free(p, r)
	for _, q in ipairs(placed) do
		if (q - p).Magnitude < r then return false end
	end
	return true
end
local made, tries = 0, 0
local N = CFG.count or 1000
local R = CFG.radius or 100
while made < N and tries < N * 30 do
	tries += 1
	local a = rng:NextNumber(0, math.pi * 2)
	local rr = R * math.sqrt(rng:NextNumber())
	local p = TG + Vector3.new(math.cos(a) * rr * 1.5, 0, math.sin(a) * rr)
	if free(p, 3.0) then
		table.insert(placed, p)
		local r = rng:NextNumber()
		local kind = if r < 0.04 then "Brute" elseif r < 0.08 then "Armored" elseif r < 0.1 then "Bomber" else "Normal"
		zombie(kind, p, TG + Vector3.new(-160, 0, rng:NextNumber(-40, 40)), { reach = rng:NextNumber(62, 92), lunge = rng:NextNumber(14, 30) })
		made += 1
	end
end
local hit105 = ahead(CFG.h105x or 0, CFG.h105z or 0)
local hit40 = ahead(CFG.h40x or -30, CFG.h40z or -18)
local hit25 = ahead(CFG.h25x or 22, CFG.h25z or -26)
for i = 1, 6 do
	zombie("Normal", hit105 + Vector3.new(rng:NextNumber(-7, 7), 0, rng:NextNumber(-7, 7)), TG, { tumble = true, air = rng:NextNumber(3, 14) })
end

local function scr(p)
	local v = cam:WorldToViewportPoint(p)
	return { v.X / cam.ViewportSize.X, v.Y / cam.ViewportSize.Y, v.Z }
end
local pts = { guns = {} }
local gd = ac:FindFirstChild("GunDetail")
local function tipOf(part)
	-- the barrel's long axis is its X: the end further toward the plane's -X side is the muzzle
	local a = part.CFrame * Vector3.new(part.Size.X / 2, 0, 0)
	local b = part.CFrame * Vector3.new(-part.Size.X / 2, 0, 0)
	local pv = ac:GetPivot()
	if pv:PointToObjectSpace(a).X < pv:PointToObjectSpace(b).X then return a, b end
	return b, a
end
local function gun(name, model, hit, size)
	local tips = {}
	for _, p in ipairs(model:GetChildren()) do
		if p:IsA("BasePart") and p.Name == "Barrel" then
			local tip, back = tipOf(p)
			table.insert(tips, { scr(tip), scr(tip + (tip - back).Unit * 3), p.Size.Y })
		end
	end
	table.insert(pts.guns, { name = name, tips = tips, hit = scr(hit), size = size })
end
if gd then
	gun("25", gd.GAU12, hit25, 1)
	gun("40", gd.Bofors, hit40, 1.6)
	gun("105", gd.Howitzer, hit105, 2.6)
end
pts.sun = scr(eye + Lighting:GetSunDirection() * 1000)
pts.ac = scr(acPos)
local feet = {}
for _, m in ipairs(stage:GetChildren()) do
	if m:IsA("Model") and m ~= ac then
		local p = m:GetPivot().Position
		local v = cam:WorldToViewportPoint(Vector3.new(p.X, GROUND, p.Z))
		if v.Z > 0 and rng:NextNumber() < 0.2 then table.insert(feet, { v.X / cam.ViewportSize.X, v.Y / cam.ViewportSize.Y, v.Z }) end
	end
end
pts.feet = feet
pts.count = made
-- no joint / attachment gizmos in the shot
for _, d in ipairs(stage:GetDescendants()) do
	if d:IsA("Motor6D") or d:IsA("Attachment") or d:IsA("Bone") or d:IsA("Weld") or d:IsA("WeldConstraint") or d:IsA("Constraint")
		or d:IsA("NoCollisionConstraint") or d:IsA("WrapTarget") then
		d:Destroy()
	end
end
stage:SetAttribute("TG", TG)
stage:SetAttribute("H105", hit105)
stage:SetAttribute("H40", hit40)
stage:SetAttribute("H25", hit25)
return HS:JSONEncode(pts)
