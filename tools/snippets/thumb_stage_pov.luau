-- POV thumbnail staging on the lobby Baseplate (Edit mode only; undo with the unstage block, nothing is saved).
-- workspace attribute _PovCfg (JSON): plane, pos {x,y,z} rel. horde centre, mode "side" (guns on the left, AC-130 /
-- AC-47) or "nose" (pointing at aim), aim {x,y,z}, bank, cam {x,y,z} in the plane's space, look {x,y,z} rel. horde
-- centre, fov, roll, guns = list of part names whose ends are the muzzles, horde = true to (re)build the horde.
-- Returns muzzle points (0..1 of the viewport) and the aim point for tools/thumb_fx_gunner.py.
local SS, Lighting, HS = game:GetService("ServerStorage"), game:GetService("Lighting"), game:GetService("HttpService")
local T = SS.ConvoyTemplates
local C = HS:JSONDecode(workspace:GetAttribute("_PovCfg"))
local function v3(t, d) return t and Vector3.new(t[1], t[2], t[3]) or d end
local stage = workspace:FindFirstChild("_ThumbStage")
local GROUND = workspace.Baseplate.Position.Y + workspace.Baseplate.Size.Y / 2
local TG = Vector3.new(-9714, GROUND, 0)
local rng = Random.new(C.seed or 7)
if not Lighting:GetAttribute("_ThumbSaved") then
	Lighting:SetAttribute("_ThumbSaved", HS:JSONEncode({ ClockTime = Lighting.ClockTime, Brightness = Lighting.Brightness,
		ExposureCompensation = Lighting.ExposureCompensation, Density = Lighting.Atmosphere.Density, Haze = Lighting.Atmosphere.Haze }))
end
Lighting.ClockTime = C.clock or 15.6
Lighting.Brightness = 2.4
Lighting.ExposureCompensation = -0.1
Lighting.Atmosphere.Density = 0.22
Lighting.Atmosphere.Haze = 1.2

local function anchor(m)
	for _, d in ipairs(m:GetDescendants()) do
		if d:IsA("BasePart") then d.Anchored = true; d.CanCollide = false; d.CastShadow = true end
		if d:IsA("Script") or d:IsA("LocalScript") then d:Destroy() end
	end
end
local function rot(parts, pivot, axis, ang)
	local r = CFrame.new(pivot) * CFrame.fromAxisAngle(axis, ang) * CFrame.new(-pivot)
	for _, p in ipairs(parts) do
		if p then p.CFrame = r * p.CFrame end
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
			rot(arm, up, look, math.rad((if i == 1 then -1 else 1) * spread))
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
local function zombie(parent, kind, at, face)
	local src
	if kind ~= "Normal" and T.Types:FindFirstChild(kind) then
		local kids = T.Types[kind]:GetChildren()
		src = kids[rng:NextInteger(1, #kids)]
	else
		local kids = T.Infected:GetChildren()
		src = kids[rng:NextInteger(1, #kids)]
	end
	local m = src:Clone()
	m:ScaleTo(m:GetScale() * (SCALE[kind] or 1))
	local dir = ((face - at) * Vector3.new(1, 0, 1)).Unit
	local yaw = CFrame.fromAxisAngle(Vector3.yAxis, math.rad(rng:NextNumber(-25, 25)))
	m:PivotTo(CFrame.lookAt(at, at + yaw:VectorToWorldSpace(dir)))
	m.Parent = parent
	anchor(m)
	pose(m, rng:NextNumber(62, 95), rng:NextNumber(14, 30), rng:NextNumber(5, 25))
	local cf, size = m:GetBoundingBox()
	m:PivotTo(m:GetPivot() + Vector3.new(0, GROUND - (cf.Position.Y - size.Y / 2), 0))
end

if C.horde or not stage then
	if stage then stage:Destroy() end
	stage = Instance.new("Folder")
	stage.Name = "_ThumbStage"
	stage.Parent = workspace
	local horde = Instance.new("Folder")
	horde.Name = "Horde"
	horde.Parent = stage
	local cell = 3.1 -- spatial hash for spacing
	local grid = {}
	local function key(x, z) return math.floor(x / cell) .. "," .. math.floor(z / cell) end
	local function free(p)
		local gx, gz = math.floor(p.X / cell), math.floor(p.Z / cell)
		for dx = -1, 1 do
			for dz = -1, 1 do
				local q = grid[(gx + dx) .. "," .. (gz + dz)]
				if q and (q - p).Magnitude < cell then return false end
			end
		end
		return true
	end
	local made, tries, N, R = 0, 0, C.count or 1800, C.radius or 110
	while made < N and tries < N * 20 do
		tries += 1
		local a = rng:NextNumber(0, math.pi * 2)
		local rr = R * math.sqrt(rng:NextNumber())
		local p = TG + Vector3.new(math.cos(a) * rr * 1.4, 0, math.sin(a) * rr)
		if free(p) then
			grid[key(p.X, p.Z)] = p
			local r = rng:NextNumber()
			local kind = if r < 0.04 then "Brute" elseif r < 0.08 then "Armored" elseif r < 0.1 then "Bomber" elseif r < 0.12 then "Spitter" else "Normal"
			zombie(horde, kind, p, TG + Vector3.new(rng:NextNumber(-200, 200), 0, rng:NextNumber(-200, 200)))
			made += 1
		end
	end
	for _, d in ipairs(horde:GetDescendants()) do
		if d:IsA("Motor6D") or d:IsA("Attachment") or d:IsA("Bone") or d:IsA("Weld") or d:IsA("WeldConstraint")
			or d:IsA("NoCollisionConstraint") or d:IsA("WrapTarget") then
			d:Destroy()
		end
	end
end

-- the aircraft
local oldp = stage:FindFirstChild("Plane")
if oldp then oldp:Destroy() end
local plane = game.ReplicatedStorage.Convoy.Models[C.plane]:Clone()
plane.Name = "Plane"
plane.Parent = stage
anchor(plane)
local pos = TG + v3(C.pos)
local aim = TG + v3(C.aim, Vector3.zero)
local cf
if C.mode == "side" then -- AC-130 style: guns down local -X onto aim, nose along C.nose
	local xAxis = (pos - aim).Unit
	local nose = v3(C.nose, Vector3.new(0, 0, -1))
	local zAxis = -(nose - xAxis * xAxis:Dot(nose)).Unit
	cf = CFrame.fromMatrix(pos, xAxis, zAxis:Cross(xAxis), zAxis)
else
	local flat = ((aim - pos) * Vector3.new(1, 0, 1)).Unit
	cf = CFrame.lookAt(pos, pos + flat) * CFrame.Angles(math.rad(C.pitch or -12), 0, 0)
end
cf = cf * CFrame.Angles(0, 0, math.rad(C.bank or 0))
plane:PivotTo(cf)
for _, d in ipairs(plane:GetDescendants()) do
	if d:IsA("Motor6D") or d:IsA("Attachment") or d:IsA("Bone") or d:IsA("Weld") or d:IsA("WeldConstraint") then d:Destroy() end
end
local pv = plane:GetPivot()
local cam = workspace.CurrentCamera
local eye = pv * v3(C.cam)
local look = if C.lookLocal then pv * v3(C.lookLocal) else TG + v3(C.look, Vector3.zero)
local up = if C.worldUp then Vector3.yAxis else pv.UpVector
cam.CFrame = CFrame.lookAt(eye, look, up) * CFrame.Angles(0, 0, math.rad(C.roll or 0))
cam.FieldOfView = C.fov or 70

local function scr(p)
	local v = cam:WorldToViewportPoint(p)
	return { v.X / cam.ViewportSize.X, v.Y / cam.ViewportSize.Y, v.Z }
end
local out = { guns = {}, aim = scr(aim) }
for _, gname in ipairs(C.guns or {}) do
	local tips, backs = {}, {}
	for _, d in ipairs(plane:GetDescendants()) do
		if d:IsA("BasePart") and d.Name == gname then
			local ax = if d.Size.X >= d.Size.Y and d.Size.X >= d.Size.Z then Vector3.xAxis elseif d.Size.Y >= d.Size.Z then Vector3.yAxis else Vector3.zAxis
			local half = (d.Size * ax).Magnitude / 2
			local a, b = d.CFrame * (ax * half), d.CFrame * (-ax * half)
			if (a - d.Position):Dot(aim - d.Position) < (b - d.Position):Dot(aim - d.Position) then a, b = b, a end
			table.insert(tips, scr(a))
			table.insert(backs, scr(b))
		end
	end
	table.insert(out.guns, { name = gname, tips = tips, backs = backs })
end
return HS:JSONEncode(out)
