-- Gunner's-eye shot of a staged horde (run thumb_stage_gunship first): the game's thermal look (per-kind
-- Highlights + the sensor grade), the camera where the gunship sits, and a gun in the foreground.
-- Returns the gun's muzzle points and the target as 0..1 screen points for tools/thumb_fx_gunner.py.
local HS0 = game:GetService("HttpService")
local J = HS0:JSONDecode(workspace:GetAttribute("_GunCfg"))
local function v3(t) return Vector3.new(t[1], t[2], t[3]) end
local G = { gun = J.gun, cam = v3(J.cam), look = v3(J.look), fov = J.fov, at = v3(J.at), len = J.len, target = v3(J.target), roll = J.roll or 0 }
local HS, Lighting, SS = game:GetService("HttpService"), game:GetService("Lighting"), game:GetService("ServerStorage")
local st = workspace._ThumbStage
local TG = st:GetAttribute("TG")
local T = SS.ConvoyTemplates
if st:FindFirstChild("AC130") then st.AC130:Destroy() end
local old = st:FindFirstChild("Gun")
if old then old:Destroy() end

-- thermal grade + per-kind Highlights (same numbers as GunshipClient)
local cc = Lighting:FindFirstChild("_ThumbCC") or Instance.new("ColorCorrectionEffect")
cc.Name = "_ThumbCC"
cc.Saturation, cc.Contrast, cc.Brightness = -1, 0.55, -0.08
cc.TintColor = Color3.fromRGB(225, 235, 225)
cc.Parent = Lighting
local TINT = { Normal = Color3.fromRGB(255, 40, 40), Brute = Color3.fromRGB(170, 90, 255), Bomber = Color3.fromRGB(255, 150, 30),
	Spitter = Color3.fromRGB(255, 220, 0), Armored = Color3.fromRGB(70, 170, 255) }
local groups = {}
local function group(kind)
	if groups[kind] then return groups[kind] end
	local m = st:FindFirstChild("K_" .. kind) or Instance.new("Model")
	m.Name = "K_" .. kind
	if not m:FindFirstChildOfClass("Highlight") then
		local h = Instance.new("Highlight")
		h.FillColor = Color3.new(0, 0, 0):Lerp(TINT[kind], if kind == "Normal" then 0.3 else 0.55)
		h.FillTransparency = 0
		h.OutlineColor = Color3.new(1, 1, 1):Lerp(TINT[kind], 0.45)
		h.OutlineTransparency = 0.35
		h.DepthMode = Enum.HighlightDepthMode.Occluded
		h.Parent = m
	end
	m.Parent = st
	groups[kind] = m
	return m
end
local function kindOf(name)
	for _, k in ipairs({ "Brute", "Armored", "Bomber", "Spitter" }) do
		if T.Types:FindFirstChild(k) and T.Types[k]:FindFirstChild(name) then return k end
	end
	return "Normal"
end
for _, m in ipairs(st:GetChildren()) do
	if m:IsA("Model") and string.sub(m.Name, 1, 2) ~= "K_" then
		m.Parent = group(kindOf(m.Name))
	end
end

-- camera at the gunship
local cam = workspace.CurrentCamera
local eye = TG + G.cam
local camCF = CFrame.lookAt(eye, TG + G.look) * CFrame.Angles(0, 0, math.rad(G.roll))
cam.CFrame = camCF
cam.FieldOfView = G.fov
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
-- the gun: placed in view space (at = right, up, forward in studs), pointing at the target on the ground
local base = camCF.Position + camCF.RightVector * G.at.X + camCF.UpVector * G.at.Y + camCF.LookVector * G.at.Z
local aim = CFrame.lookAt(base, TG + G.target)
local g = Instance.new("Model")
g.Name = "Gun"
local L = G.len
local ax = CFrame.Angles(0, math.rad(90), 0)
local metal, dark, light = Color3.fromRGB(84, 88, 100), Color3.fromRGB(14, 14, 16), Color3.fromRGB(200, 204, 214)
local tips = {}
if G.gun == "minigun" then
	local aimR = aim * CFrame.Angles(0, 0, math.rad(12))
	local bl, bz = L * 0.64, -L * 0.3
	for i = 0, 5 do
		local a = math.rad(60 * i)
		local off = Vector3.new(math.cos(a), math.sin(a), 0) * L * 0.075
		part(g, Enum.PartType.Cylinder, Vector3.new(bl, L * 0.05, L * 0.05), aimR * CFrame.new(off + Vector3.new(0, 0, bz)) * ax, dark)
		table.insert(tips, (aimR * CFrame.new(off + Vector3.new(0, 0, bz - bl / 2))).Position)
	end
	part(g, Enum.PartType.Cylinder, Vector3.new(bl * 0.98, L * 0.05, L * 0.05), aimR * CFrame.new(0, 0, bz) * ax, metal)
	part(g, Enum.PartType.Cylinder, Vector3.new(L * 0.035, L * 0.18, L * 0.18), aimR * CFrame.new(0, 0, -L * 0.6) * ax, light)
	part(g, Enum.PartType.Cylinder, Vector3.new(L * 0.035, L * 0.18, L * 0.18), aimR * CFrame.new(0, 0, -L * 0.34) * ax, metal)
	part(g, Enum.PartType.Cylinder, Vector3.new(L * 0.22, L * 0.22, L * 0.22), aimR * CFrame.new(0, 0, L * 0.1) * ax, metal)
	part(g, Enum.PartType.Cylinder, Vector3.new(L * 0.03, L * 0.25, L * 0.25), aimR * CFrame.new(0, 0, -L * 0.02) * ax, dark)
	part(g, nil, Vector3.new(L * 0.18, L * 0.16, L * 0.24), aimR * CFrame.new(0, -L * 0.1, L * 0.3), metal)
	part(g, Enum.PartType.Cylinder, Vector3.new(L * 0.16, L * 0.09, L * 0.09), aimR * CFrame.new(L * 0.13, L * 0.03, L * 0.22) * ax, dark)
	part(g, nil, Vector3.new(L * 0.05, L * 0.12, L * 0.3), aimR * CFrame.new(-L * 0.12, -L * 0.06, L * 0.2), dark)
else -- the 105: a long tube with a muzzle brake, recoil sleeve and breech block
	local r = L * 0.06
	part(g, Enum.PartType.Cylinder, Vector3.new(L, r * 2, r * 2), aim * CFrame.new(0, 0, -L * 0.1) * ax, metal)
	part(g, Enum.PartType.Cylinder, Vector3.new(L * 0.36, r * 3, r * 3), aim * CFrame.new(0, 0, L * 0.34) * ax, dark) -- recoil sleeve
	part(g, nil, Vector3.new(r * 4.2, r * 4.2, L * 0.16), aim * CFrame.new(0, 0, L * 0.56), metal) -- breech
	part(g, nil, Vector3.new(r * 3.2, r * 2.4, L * 0.1), aim * CFrame.new(0, 0, -L * 0.62), dark) -- muzzle brake
	part(g, nil, Vector3.new(r * 3.4, r * 0.5, L * 0.03), aim * CFrame.new(0, 0, -L * 0.58), light)
	part(g, nil, Vector3.new(r * 3.4, r * 0.5, L * 0.03), aim * CFrame.new(0, 0, -L * 0.655), light)
	part(g, Enum.PartType.Cylinder, Vector3.new(L * 0.05, r * 2.5, r * 2.5), aim * CFrame.new(0, 0, -L * 0.25) * ax, dark)
	table.insert(tips, (aim * CFrame.new(0, 0, -L * 0.67)).Position)
end
g.Parent = st
local h = Instance.new("Highlight")
h.FillColor, h.FillTransparency = Color3.fromRGB(60, 80, 190), 0.82
h.OutlineColor, h.OutlineTransparency = Color3.fromRGB(255, 255, 255), 0.1
h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
h.Parent = g

local function scr(p)
	local v = cam:WorldToViewportPoint(p)
	return { v.X / cam.ViewportSize.X, v.Y / cam.ViewportSize.Y, v.Z }
end
local out = { tips = {}, target = scr(TG + G.target), dir = scr((aim * CFrame.new(0, 0, -L * 5)).Position) }
for _, t in ipairs(tips) do
	table.insert(out.tips, scr(t))
end
out.hits = { scr(st:GetAttribute("H105")), scr(st:GetAttribute("H40")), scr(st:GetAttribute("H25")) }
return HS:JSONEncode(out)
