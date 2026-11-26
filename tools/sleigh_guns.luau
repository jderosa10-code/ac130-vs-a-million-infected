-- 0.19.12 Santa's sleigh guns, rebuilt in detail. buildGuns(sleighModel) replaces the children of sleighModel.Guns.
-- Positions are relative to the sleigh's Root (front = -Z). Every part gets attribute GunSlot (25mm / 40mm / 105mm)
-- so GunSwap swaps just that gun. Muzzles stay where Aircraft SLEIGH mounts fire from.
local function buildGuns(sleigh)
	local root = sleigh.Root.CFrame
	local guns = sleigh.Guns
	local ref = guns:FindFirstChildWhichIsA("BasePart")
	local props = {
		Anchored = if ref then ref.Anchored else true,
		CanCollide = if ref then ref.CanCollide else false,
		CanQuery = if ref then ref.CanQuery else false,
		CanTouch = if ref then ref.CanTouch else false,
		Massless = if ref then ref.Massless else false,
	}
	guns:ClearAllChildren()
	local GOLD = Color3.fromRGB(236, 180, 52)
	local RED = Color3.fromRGB(196, 30, 36)
	local WHITE = Color3.fromRGB(246, 246, 248)
	local DARK = Color3.fromRGB(36, 38, 44)
	local GREEN = Color3.fromRGB(32, 110, 60)
	local LEAF = Color3.fromRGB(26, 120, 52)
	local ICE = Color3.fromRGB(120, 220, 255)
	local ALONG_Z = CFrame.Angles(0, math.rad(90), 0) -- cylinder axis (local X) along Z
	local UPRIGHT = CFrame.Angles(0, 0, math.rad(90)) -- cylinder axis along Y
	local slot = "25mm"
	local function P(name, shape, size, rel, color, studs, mat)
		local p = Instance.new("Part")
		p.Name = name
		p.Shape = shape or Enum.PartType.Block
		p.Size = size
		p.CFrame = root * rel
		p.Color = color
		p.Material = mat or Enum.Material.Plastic
		for k, v in pairs(props) do
			p[k] = v
		end
		local surf = if studs then Enum.SurfaceType.Studs else Enum.SurfaceType.Smooth
		p.TopSurface, p.BottomSurface = surf, surf
		p.FrontSurface, p.BackSurface, p.LeftSurface, p.RightSurface = surf, surf, surf, surf
		p:SetAttribute("GunSlot", slot)
		p.Parent = guns
		return p
	end
	local CYL, BALL = Enum.PartType.Cylinder, Enum.PartType.Ball
	local function cylZ(name, d, len, pos, color, studs) -- cylinder along Z
		return P(name, CYL, Vector3.new(len, d, d), CFrame.new(pos) * ALONG_Z, color, studs)
	end

	---------------------------------------------------------------- candy-cane miniguns (25mm), one each side
	slot = "25mm"
	for _, s in ipairs({ -1, 1 }) do
		local X, Y = s * 5.1, 1.1
		-- six barrels round a spindle, red / white segments offset barrel to barrel: a candy-cane twist
		local Z0, Z1, SEG = 3.25, 7.95, 7
		local segL = (Z1 - Z0) / SEG
		for k = 0, 5 do
			local a = math.rad(k * 60 + 30)
			local bx, by = X + math.cos(a) * 0.42, Y + math.sin(a) * 0.42
			for j = 0, SEG - 1 do
				cylZ("Barrel", 0.27, segL, Vector3.new(bx, by, Z0 + segL * (j + 0.5)), if (j + k) % 2 == 0 then RED else WHITE)
			end
			cylZ("Bore", 0.17, 0.06, Vector3.new(bx, by, Z0 - 0.02), DARK)
		end
		cylZ("Spindle", 0.36, 4.7, Vector3.new(X, Y, 5.65), DARK)
		cylZ("Muzzle", 1.32, 0.26, Vector3.new(X, Y, 3.6), GOLD)
		cylZ("Clamp", 1.32, 0.3, Vector3.new(X, Y, 5.7), GOLD)
		cylZ("Rotor", 1.45, 0.7, Vector3.new(X, Y, 8.3), WHITE, true)
		cylZ("RotorBand", 1.53, 0.18, Vector3.new(X, Y, 8.3), RED)
		-- receiver, motor, back plate and spade grips
		P("Housing", nil, Vector3.new(1.3, 1.45, 2.0), CFrame.new(X, Y, 9.65), Color3.fromRGB(58, 62, 72), true)
		P("HousingTrim", nil, Vector3.new(0.9, 0.16, 1.9), CFrame.new(X, Y + 0.8, 9.65), GOLD)
		cylZ("Motor", 0.85, 1.5, Vector3.new(X, Y - 0.95, 9.5), RED)
		cylZ("MotorCap", 0.92, 0.16, Vector3.new(X, Y - 0.95, 10.3), GOLD)
		P("Backplate", nil, Vector3.new(1.2, 1.1, 0.2), CFrame.new(X, Y, 10.75), DARK)
		for _, g in ipairs({ -1, 1 }) do
			P("Grip", nil, Vector3.new(0.22, 0.22, 0.7), CFrame.new(X + g * 0.4, Y + 0.15, 11.15), DARK)
			P("GripKnob", BALL, Vector3.new(0.3, 0.3, 0.3), CFrame.new(X + g * 0.4, Y + 0.15, 11.5), RED)
		end
		P("Trigger", nil, Vector3.new(0.6, 0.14, 0.14), CFrame.new(X, Y - 0.1, 11.2), GOLD)
		-- mount plate on the sleigh's side
		P("Mount", nil, Vector3.new(0.3, 1.9, 3.0), CFrame.new(s * 4.72, 0.75, 9.6), GOLD, true)
		P("MountBolt", BALL, Vector3.new(0.32, 0.32, 0.32), CFrame.new(s * 4.9, 1.55, 8.4), DARK)
		P("MountBolt", BALL, Vector3.new(0.32, 0.32, 0.32), CFrame.new(s * 4.9, 1.55, 10.8), DARK)
		P("MountBolt", BALL, Vector3.new(0.32, 0.32, 0.32), CFrame.new(s * 4.9, -0.05, 8.4), DARK)
		P("MountBolt", BALL, Vector3.new(0.32, 0.32, 0.32), CFrame.new(s * 4.9, -0.05, 10.8), DARK)
		-- ammo: a present on the side rail, fed through a chute with a candy-cane belt
		local box = Vector3.new(s * 4.15, 3.85, 11.7)
		P("AmmoBox", nil, Vector3.new(1.45, 1.3, 1.6), CFrame.new(box), GREEN, true)
		P("AmmoRibbon", nil, Vector3.new(1.5, 1.34, 0.3), CFrame.new(box), GOLD)
		P("AmmoRibbon", nil, Vector3.new(0.3, 1.34, 1.65), CFrame.new(box), GOLD)
		P("AmmoBow", BALL, Vector3.new(0.55, 0.4, 0.55), CFrame.new(box + Vector3.new(-0.22, 0.75, 0)), RED)
		P("AmmoBow", BALL, Vector3.new(0.55, 0.4, 0.55), CFrame.new(box + Vector3.new(0.22, 0.75, 0)), RED)
		local A = Vector3.new(X - s * 0.1, Y + 0.85, 10.0)
		local C = Vector3.new(X - s * 0.2, Y + 2.2, 10.9)
		local B = Vector3.new(s * 4.6, 3.35, 11.1)
		local function bez(t)
			return A:Lerp(C, t):Lerp(C:Lerp(B, t), t)
		end
		local N = 4
		for i = 0, N - 1 do
			local p0, p1 = bez(i / N), bez((i + 1) / N)
			local mid, len = (p0 + p1) / 2, (p1 - p0).Magnitude
			local cf = CFrame.lookAt(mid, p1)
			P("Chute", nil, Vector3.new(0.55, 0.3, len + 0.05), cf, DARK)
			for b = 0, 1 do
				P("Belt", nil, Vector3.new(0.4, 0.16, 0.16), cf * CFrame.new(0, 0.2, len * (b - 0.5) * 0.5), if (i * 2 + b) % 2 == 0 then RED else WHITE)
			end
		end
		-- festive bits: holly on the receiver, a jingle bell under the barrels
		for _, l in ipairs({ -1, 1 }) do
			P("Holly", nil, Vector3.new(0.5, 0.08, 0.26), CFrame.new(X + l * 0.22, Y + 0.92, 9.2) * CFrame.Angles(0, math.rad(l * 30), math.rad(l * -12)), LEAF)
		end
		for _, o in ipairs({ Vector3.new(0, 0, 0), Vector3.new(0.13, 0.02, 0.14), Vector3.new(-0.13, 0.02, 0.14) }) do
			P("Berry", BALL, Vector3.new(0.2, 0.2, 0.2), CFrame.new(Vector3.new(X, Y + 1.0, 9.05) + o), RED)
		end
		P("BellRod", nil, Vector3.new(0.08, 0.42, 0.08), CFrame.new(X, Y - 0.85, 5.7), DARK)
		P("Bell", BALL, Vector3.new(0.52, 0.52, 0.52), CFrame.new(X, Y - 1.28, 5.7), GOLD)
		P("BellSlit", nil, Vector3.new(0.4, 0.06, 0.08), CFrame.new(X, Y - 1.42, 5.7), DARK)
	end

	---------------------------------------------------------------- candy-cane rocket pods (40mm), one each side
	slot = "40mm"
	for _, s in ipairs({ -1, 1 }) do
		local X, Y = s * 5.25, -1.6
		cylZ("RocketPod", 2.0, 5.0, Vector3.new(X, Y, 16.1), WHITE, true)
		for _, z in ipairs({ 14.3, 15.5, 16.7, 17.9 }) do
			P("PodBand", CYL, Vector3.new(0.34, 2.28, 2.28), CFrame.new(X, Y, z) * CFrame.Angles(math.rad(25), 0, 0) * ALONG_Z, RED)
		end
		cylZ("PodRim", 2.12, 0.3, Vector3.new(X, Y, 13.6), GOLD)
		cylZ("PodFace", 1.86, 0.14, Vector3.new(X, Y, 13.44), DARK)
		local holes = { Vector3.new(0, 0, 0) }
		for k = 0, 5 do
			local a = math.rad(k * 60)
			table.insert(holes, Vector3.new(math.cos(a) * 0.56, math.sin(a) * 0.56, 0))
		end
		for i, h in ipairs(holes) do
			cylZ("PodTube", 0.48, 0.12, Vector3.new(X, Y, 13.36) + h, Color3.fromRGB(18, 18, 22))
			P("RocketTip", BALL, Vector3.new(0.34, 0.34, 0.34), CFrame.new(Vector3.new(X, Y, 13.42) + h), if i % 2 == 0 then RED else WHITE)
		end
		cylZ("PodTail", 1.5, 0.8, Vector3.new(X, Y, 19.0), WHITE)
		cylZ("PodTail", 1.0, 0.25, Vector3.new(X, Y, 19.5), GOLD)
		P("Pylon", nil, Vector3.new(0.7, 0.6, 3.2), CFrame.new(s * 4.95, -0.35, 16.1), GOLD, true)
		for _, z in ipairs({ 14.9, 17.3 }) do
			P("PylonLug", CYL, Vector3.new(0.3, 0.4, 0.4), CFrame.new(s * 5.05, -0.62, z) * UPRIGHT, DARK)
		end
	end

	---------------------------------------------------------------- present cannon (105mm), on the back of the sleigh
	slot = "105mm"
	local P0 = Vector3.new(0, 8.1, 19.1)
	local fwd = (Vector3.new(0, 7.57, 15.34) - P0).Unit
	local AX = CFrame.lookAt(P0, P0 + fwd) -- local -Z = out of the muzzle
	local function at(t, x, y)
		return AX * CFrame.new(x or 0, y or 0, -t)
	end
	local function cylA(name, d, len, t, color, studs, x, y)
		return P(name, CYL, Vector3.new(len, d, d), at(t, x, y) * ALONG_Z, color, studs)
	end
	cylA("CannonBarrel", 3.1, 2.6, -2.2, RED, true) -- jacket
	cylA("CannonBarrel", 2.5, 4.4, 1.3, WHITE) -- tube
	for _, t in ipairs({ 0.0, 1.3, 2.6 }) do
		P("CannonStripe", CYL, Vector3.new(0.42, 2.8, 2.8), at(t) * CFrame.Angles(math.rad(25), 0, 0) * ALONG_Z, RED)
	end
	cylA("CannonBand", 3.35, 0.35, -3.45, GOLD)
	cylA("CannonBand", 3.35, 0.35, -0.95, GOLD)
	cylA("CannonMuzzle", 3.0, 1.1, 4.0, GOLD, true)
	for _, x in ipairs({ -1.46, 1.46 }) do
		for _, t in ipairs({ 3.78, 4.22 }) do
			P("MuzzleVent", nil, Vector3.new(0.12, 1.1, 0.26), at(t, x), DARK)
		end
	end
	cylA("CannonBore", 2.0, 0.12, 4.58, DARK)
	-- a present loaded in the muzzle
	local pc = at(4.72) * CFrame.Angles(0, 0, math.rad(45))
	P("LoadedPresent", nil, Vector3.new(1.6, 1.6, 1.2), pc, GREEN, true)
	P("LoadedRibbon", nil, Vector3.new(1.66, 0.4, 1.26), pc, WHITE)
	P("LoadedRibbon", nil, Vector3.new(0.4, 1.66, 1.26), pc, WHITE)
	P("LoadedBow", BALL, Vector3.new(0.5, 0.5, 0.5), pc * CFrame.new(0, 0, -0.65), RED)
	-- breech
	P("CannonBreech", nil, Vector3.new(3.0, 3.0, 1.0), at(-4.0), GOLD, true)
	P("CannonCap", BALL, Vector3.new(2.2, 2.2, 1.4), at(-4.55), RED)
	P("BreechLever", CYL, Vector3.new(1.0, 0.32, 0.32), at(-4.0, 1.9, 0.7), DARK)
	P("BreechKnob", BALL, Vector3.new(0.5, 0.5, 0.5), at(-4.0, 2.45, 0.7), RED)
	-- recoil buffers under the barrel
	for _, x in ipairs({ -0.75, 0.75 }) do
		cylA("Recoil", 0.65, 3.2, -1.6, WHITE, false, x, -1.5)
		cylA("RecoilCap", 0.76, 0.2, 0.0, GOLD, false, x, -1.5)
	end
	-- a bow on the jacket
	P("CannonBow", BALL, Vector3.new(0.9, 0.5, 0.6), at(-2.2, -0.45, 1.65) * CFrame.Angles(0, 0, math.rad(20)), RED)
	P("CannonBow", BALL, Vector3.new(0.9, 0.5, 0.6), at(-2.2, 0.45, 1.65) * CFrame.Angles(0, 0, math.rad(-20)), RED)
	P("CannonBow", BALL, Vector3.new(0.42, 0.42, 0.42), at(-2.2, 0, 1.7), GOLD)
	-- trunnion, yoke and turntable
	local T = (at(-2.6)).Position
	P("Trunnion", CYL, Vector3.new(4.4, 1.0, 1.0), at(-2.6), DARK)
	for _, x in ipairs({ -2.0, 2.0 }) do
		local top, bottom = T.Y + 0.5, 5.85
		P("CannonYoke", nil, Vector3.new(0.4, top - bottom, 2.6), CFrame.new(x, (top + bottom) / 2, T.Z), GOLD, true)
		P("YokeBolt", CYL, Vector3.new(0.2, 0.7, 0.7), CFrame.new(x + (if x < 0 then -0.25 else 0.25), T.Y, T.Z), DARK)
	end
	P("CannonBase", CYL, Vector3.new(0.5, 4.4, 4.4), CFrame.new(0, 5.6, T.Z) * UPRIGHT, GOLD, true)
	P("CannonRing", CYL, Vector3.new(0.18, 4.7, 4.7), CFrame.new(0, 5.36, T.Z) * UPRIGHT, DARK)
	-- sight on the left side
	cylA("CannonSight", 0.55, 1.8, -1.8, DARK, false, -2.1, 1.25)
	cylA("SightLens", 0.42, 0.06, -0.88, ICE, false, -2.1, 1.25).Material = Enum.Material.Neon
	P("SightBracket", nil, Vector3.new(0.3, 0.7, 0.5), at(-2.0, -2.1, 0.75), DARK)
	local n = 0
	for _, d in ipairs(guns:GetChildren()) do
		n += 1
	end
	return n
end

-- run it on the template and on the lobby stand's copy (every place has the template; only the lobby has the stand)
local out = { "model guns " .. buildGuns(game.ReplicatedStorage.Convoy.Models.SLEIGH) }
local dmz = workspace:FindFirstChild("DMZ")
local st = dmz and dmz:FindFirstChild("Hangar") and dmz.Hangar:FindFirstChild("SleighStand")
if st and st:FindFirstChild("Sleigh") then
	table.insert(out, "stand guns " .. buildGuns(st.Sleigh))
end
return table.concat(out, ", ")
