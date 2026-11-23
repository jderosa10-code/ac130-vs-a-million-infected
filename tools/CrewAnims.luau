--!nocheck
-- CrewAnims (ServerStorage): the Edit-mode showcase for the R6 people clips (ReplicatedStorage.Convoy.R6Clips).
-- Command bar (Edit mode, nothing to publish):
--   require(game.ServerStorage.CrewAnims).showcase() / .stop() / .clear() / .build()
local RunService = game:GetService("RunService")
local AnimationClipProvider = game:GetService("AnimationClipProvider")
local ServerStorage = game:GetService("ServerStorage")
local R6 = require(game:GetService("ReplicatedStorage"):WaitForChild("Convoy"):WaitForChild("R6Clips"))
local build = R6.build
local CLIPS = R6.CLIPS
local R = math.rad

local M = {}
M.GUNNER_START = R6.GUNNER_START
M.BENCH_START = R6.BENCH_START

function M.build()
	local folder = ServerStorage:FindFirstChild("Animations") or Instance.new("Folder")
	folder.Name = "Animations"
	folder.Parent = ServerStorage
	for _, k in ipairs(folder:GetChildren()) do -- the old R15 crew clips are gone
		if k.Name:match("^R15_Heli") or k.Name == "R15_GunnerSeat" then
			k:Destroy()
		end
	end
	local out = {}
	for _, clip in ipairs(CLIPS) do
		local old = folder:FindFirstChild(clip.name)
		if old then
			old:Destroy()
		end
		local kfs = build(clip)
		kfs.Parent = folder
		out[clip.name] = kfs
	end
	return out
end

---------------------------------------------------------------------------------------------------- showcase
M.ORIGIN = CFrame.new(-2400, 400, 150)
local conn = nil
function M.stop()
	if conn then
		conn:Disconnect()
		conn = nil
	end
end
function M.clear()
	M.stop()
	local old = workspace:FindFirstChild("CrewAnimShowcase")
	if old then
		old:Destroy()
	end
end
local GREY, DARK, MID = Color3.fromHex("969080"), Color3.fromHex("1e1e1c"), Color3.fromHex("363632")
local function part(parent, size, cf, color, name)
	local p = Instance.new("Part")
	p.Name = name or "Part"
	p.Anchored = true
	p.Size = size
	p.CFrame = cf
	p.Color = color
	p.TopSurface = Enum.SurfaceType.Studs
	p.BottomSurface = Enum.SurfaceType.Inlet
	p.Parent = parent
	return p
end
local function sign(parent, pos, text)
	local p = part(parent, Vector3.new(9, 1.6, 0.4), CFrame.lookAt(pos, pos + Vector3.new(0, 0, 1)), DARK, "Sign")
	p.TopSurface = Enum.SurfaceType.Smooth
	local g = Instance.new("SurfaceGui")
	g.Face = Enum.NormalId.Front
	g.CanvasSize = Vector2.new(560, 100)
	g.Parent = p
	local t = Instance.new("TextLabel")
	t.Size = UDim2.fromScale(1, 1)
	t.BackgroundTransparency = 1
	t.FontFace = Font.new("rbxasset://fonts/families/Oswald.json", Enum.FontWeight.Bold)
	t.TextScaled = true
	t.TextColor3 = Color3.fromHex("f5c518")
	t.Text = text
	t.Parent = g
end
local function prep(src, name, parent)
	local m = src:Clone()
	m.Name = name
	for _, d in ipairs(m:GetDescendants()) do
		if d:IsA("BaseScript") or d:IsA("Sound") or d:IsA("BillboardGui") then
			d:Destroy()
		elseif d:IsA("BasePart") then
			d.Anchored = d.Name == "HumanoidRootPart"
			d.CanCollide = false
		elseif d:IsA("Motor6D") then
			d.Transform = CFrame.identity
		end
	end
	R6.standardJoints(m) -- (the seated NPCs have their hips pre-bent in C0; the clips need the standard joints)
	m.Parent = parent
	return m
end
local function animatorOf(m)
	local a = m:FindFirstChildWhichIsA("Animator", true)
	if not a then
		a = Instance.new("Animator")
		a.Parent = m:FindFirstChildWhichIsA("Humanoid", true)
	end
	return a
end
local function ease(x)
	x = math.clamp(x, 0, 1)
	return x * x * (3 - 2 * x)
end

-- an actor running through a list of { clip, seconds } on a loop
local function actor(m, kfsList, list)
	local a = animatorOf(m)
	local tr = {}
	local total = 0
	for _, s in ipairs(list) do
		total += s[2]
		if not tr[s[1]] then
			local anim = Instance.new("Animation")
			anim.AnimationId = AnimationClipProvider:RegisterAnimationClip(kfsList[s[1]])
			local t = a:LoadAnimation(anim)
			t.Looped = kfsList[s[1]].Loop
			tr[s[1]] = t
		end
	end
	local current
	local function show(name, c)
		local track = tr[name]
		if current ~= track then
			for _, x in pairs(tr) do
				if x ~= track then
					x:Stop(0)
				end
			end
			track:Play(0, 1, 0)
			current = track
		end
		track.TimePosition = if track.Looped then c % track.Length else math.min(c, track.Length - 1e-3)
	end
	return {
		total = total,
		animator = a,
		show = show,
		-- shows the right clip for time t; returns the clip name and its local time
		step = function(t)
			local c = t % total
			for _, s in ipairs(list) do
				if c < s[2] then
					show(s[1], c)
					a:StepAnimations(0)
					return s[1], c
				end
				c -= s[2]
			end
		end,
	}
end

function M.showcase()
	M.clear()
	local Convoy = game:GetService("ReplicatedStorage"):WaitForChild("Convoy")
	local Models = Convoy:WaitForChild("Models")
	local H = workspace:WaitForChild("DMZ"):WaitForChild("Hangar")
	local kfsList = M.build()
	local root = Instance.new("Model")
	root.Name = "CrewAnimShowcase"
	root.Parent = workspace
	local P = M.ORIGIN.Position
	local F = P.Y
	local floor = part(root, Vector3.new(160, 1, 100), CFrame.new(P + Vector3.new(0, -0.5, 18)), GREY, "Floor")
	floor.Material = Enum.Material.Plastic
	local steps = {}
	local FACE = Vector3.new(0, 0, 1) -- the people face the camera (+Z) unless they're at something

	------------------------------------------------ row 1: aircraft
	-- A. lobby pad: run, jump, hang off the left skid of a hovering Little Bird
	do
		local heliAt = CFrame.lookAt(P + Vector3.new(-45, 9.6, 0), P + Vector3.new(-45, 9.6, -10))
		local heli = prep(Models.LittleBird, "PadHeli", root)
		heli:PivotTo(heliAt)
		local skid
		for _, d in ipairs(heli:GetDescendants()) do
			if d.Name == "Skid" and heliAt:PointToObjectSpace(d.Position).X < 0 then
				skid = d
			end
		end
		local grip = skid.Position + Vector3.new(0, skid.Size.Y / 2, 0)
		local man = prep(H.Crew:GetChildren()[1], "Jumper", root)
		local act = actor(man, kfsList, { { "R6_Run", 1 }, { "R6_HeliJump", 0.75 }, { "R6_HeliHang", 3.6 }, { "R6_Run", 0.6 } })
		local hrp = man.HumanoidRootPart
		local side = heliAt.RightVector -- he runs in from the left, toward the aircraft's centre
		local turn = CFrame.lookAt(Vector3.zero, side).Rotation
		-- the root from the left hand (arm straight up); re-measured live off the pose while he hangs
		local arm = man["Left Arm"]
		local HANG_OFF = CFrame.new(1.6, -1.78, 0)
		local hangRoot = (CFrame.new(grip) * turn * HANG_OFF).Position
		local under = Vector3.new(hangRoot.X, F + 3, hangRoot.Z)
		local start = under - side * 12
		sign(root, P + Vector3.new(-45, 0.8, 14), "PAD HELI: RUN, JUMP, HANG")
		table.insert(steps, function(t)
			act.step(t)
			local c = t % act.total
			if c < 1 then
				hrp.CFrame = CFrame.new(start:Lerp(under, c)) * turn
			elseif c < 1.75 then
				local k = (c - 1) / 0.75
				local lift = math.sin(k * math.pi) * 0.8
				hrp.CFrame = CFrame.new(under:Lerp(hangRoot, ease(k)) + Vector3.new(0, lift * (1 - k), 0)) * turn
			elseif c < 5.35 then
				local h = c - 1.75
				local swing = 0.16 * math.exp(-h * 0.7) * math.sin(h * 4.4) + 0.05 * math.sin(h * 1.7)
				local hand = hrp.CFrame:PointToObjectSpace((arm.CFrame * CFrame.new(0, -arm.Size.Y / 2, 0)).Position)
				HANG_OFF = CFrame.new(-hand) -- keeps the hand pinned to the skid
				hrp.CFrame = CFrame.new(grip) * turn * CFrame.Angles(swing, 0, 0) * HANG_OFF
			else
				hrp.CFrame = CFrame.new(start) * turn
			end
		end)
	end

	-- B. AC-130 sensor station: walks up to the seat, turns, sits down, works the console
	do
		local at0 = P + Vector3.new(-12, 0, 0)
		local seatTop = 2.1
		part(root, Vector3.new(2.2, 0.5, 2.2), CFrame.new(at0 + Vector3.new(0, seatTop - 0.25, 0)), MID, "Seat")
		part(root, Vector3.new(0.6, seatTop - 0.5, 0.6), CFrame.new(at0 + Vector3.new(0, (seatTop - 0.5) / 2, 0)), DARK, "SeatPost")
		part(root, Vector3.new(2.2, 2.6, 0.4), CFrame.new(at0 + Vector3.new(0, seatTop + 1.3, 1.15)), MID, "SeatBack")
		part(root, Vector3.new(4.5, 2.6, 1.6), CFrame.new(at0 + Vector3.new(0, 1.3, -2.9)), Color3.fromHex("4a523a"), "Console")
		local screen = part(root, Vector3.new(3.6, 2.2, 0.3), CFrame.new(at0 + Vector3.new(0, 3.8, -3.4)) * CFrame.Angles(R(-12), 0, 0), Color3.fromHex("8cff9a"), "Screen")
		screen.Material = Enum.Material.Neon
		sign(root, P + Vector3.new(-12, 0.8, 14), "AC-130: SIT DOWN AT THE CONSOLE")
		local man = prep(H.Walkers.Talker1, "Gunner", root)
		local act = actor(man, kfsList, { { "R6_Walk", 1.4 }, { "R6_Idle", 0.4 }, { "R6_GunnerSitDown", 1.1 }, { "R6_GunnerSeat", 3.5 } })
		local hrp = man.HumanoidRootPart
		local seated = CFrame.lookAt(at0 + Vector3.new(0, seatTop + 1, 0.1), at0 + Vector3.new(0, seatTop + 1, -10))
		local front = (seated * CFrame.new(M.GUNNER_START)).Position -- where he stands, back to the seat
		local from = front + Vector3.new(7, 0, 2)
		table.insert(steps, function(t)
			local name, c = act.step(t)
			if name == "R6_Walk" then
				local pos = from:Lerp(front, c / 1.4)
				hrp.CFrame = CFrame.lookAt(pos, pos + (front - from))
			elseif name == "R6_Idle" then
				hrp.CFrame = CFrame.new(front) * seated.Rotation -- turned round, back to the seat
			else
				hrp.CFrame = seated -- the clip carries the body from where he stood onto the seat
			end
			act.animator:StepAnimations(0)
		end)
	end

	-- C. end of the tutorial: three survivors back up to the Little Bird's benches, hop up and sit
	do
		local heliAt = CFrame.lookAt(P + Vector3.new(22, 3.0, 0), P + Vector3.new(22, 3.0, -10))
		local heli = prep(Models.LittleBird, "RescueHeli", root)
		heli:PivotTo(heliAt)
		local benches = {}
		for _, d in ipairs(heli:GetDescendants()) do
			if d.Name == "Bench" then
				benches[if heliAt:PointToObjectSpace(d.Position).X < 0 then -1 else 1] = d
			end
		end
		sign(root, P + Vector3.new(22, 0.8, 14), "TUTORIAL END: CLIMB ON THE BENCH")
		local who = { H.Walkers.Talker2, H.Walkers.Talker3, H.Crew:GetChildren()[2] }
		for i, s in ipairs({ { -1, -1.0 }, { -1, 0.9 }, { 1, -0.2 } }) do
			local bench, z = benches[s[1]], s[2]
			local out = heliAt.RightVector * s[1]
			local seatPos = bench.Position + Vector3.new(0, bench.Size.Y / 2 + 1, 0) + heliAt.LookVector * -z + out * (bench.Size.X / 2 - 0.35)
			local seated = CFrame.lookAt(seatPos, seatPos + out)
			local front = (seated * CFrame.new(M.BENCH_START)).Position
			local from = front + out * 6
			local man = prep(who[i], "Survivor" .. i, root)
			local wait = i * 0.35
			local act = actor(man, kfsList, { { "R6_Idle", wait + 0.01 }, { "R6_Run", 1.0 }, { "R6_Idle", 0.3 }, { "R6_BenchClimb", 1.5 }, { "R6_BenchRide", 4.2 - wait } })
			local hrp = man.HumanoidRootPart
			table.insert(steps, function(t)
				local c = t % act.total
				local name, lc = act.step(t)
				if c < wait + 0.01 then
					hrp.CFrame = CFrame.lookAt(from, from - out)
				elseif name == "R6_Run" then
					local pos = from:Lerp(front, math.clamp(lc, 0, 1))
					hrp.CFrame = CFrame.lookAt(pos, pos - out)
				elseif name == "R6_Idle" then
					hrp.CFrame = CFrame.new(front) * seated.Rotation
				else
					hrp.CFrame = seated
				end
				act.animator:StepAnimations(0)
			end)
		end
	end

	------------------------------------------------ row 2: the hangar
	local Z2 = 34
	local stations = {
		{ "WALK", H.Walkers.General, { { "R6_Walk", 4 } }, "walk" },
		{ "IDLE", H.Crew:GetChildren()[3], { { "R6_Idle", 8 } } },
		{ "PARADE REST", H.Walkers.General, { { "R6_ParadeRest", 10 } } },
		{ "TALK", H.Walkers.Talker2, { { "R6_Talk", 6.4 } } },
		{ "POINT", H.Staff.CrewChief, { { "R6_Idle", 2.4 }, { "R6_Point", 1.8 } } },
		{ "MARSHAL", H.Crew:GetChildren()[4], { { "R6_Marshal", 3.2 } } },
		{ "CLIPBOARD", H.Staff.Pilot, { { "R6_Clipboard", 6 } } },
		{ "WELD", H.Welders.Welder1.Man, { { "R6_Weld", 3.2 } }, "weld" },
		{ "OVERHEAD WELD", H.Welders.Welder3.Man, { { "R6_OverheadWeld", 3.6 } }, "weld" },
		{ "COFFEE TABLE", H.CoffeeTable.Seated1, { { "R6_ChairSit", 2.5 }, { "R6_Sip", 2.2 }, { "R6_ChairSit", 1.5 }, { "R6_Laugh", 1.6 } }, "chair" },
		{ "BOOTH CLERK", H.Booths.ShopBooth.NPC, { { "R6_BoothLean", 4 }, { "R6_Wave", 1.8 } }, "booth" },
	}
	local gap = 13
	local x0 = -((#stations - 1) * gap) / 2
	for i, st in ipairs(stations) do
		local x = x0 + (i - 1) * gap
		local base = P + Vector3.new(x, 0, Z2)
		sign(root, base + Vector3.new(0, 0.8, 8), st[1])
		local man = prep(st[2], "Station" .. i, root)
		local act = actor(man, kfsList, st[3])
		local hrp = man.HumanoidRootPart
		local kind = st[4]
		local stand = CFrame.lookAt(base + Vector3.new(0, 3, 0), base + Vector3.new(0, 3, 0) + FACE)
		if kind == "chair" then
			part(root, Vector3.new(2.2, 0.4, 2.2), CFrame.new(base + Vector3.new(0, 1.4, 0)), MID, "Chair")
			part(root, Vector3.new(2.2, 2.2, 0.3), CFrame.new(base + Vector3.new(0, 2.6, -1.1)), MID, "ChairBack")
			part(root, Vector3.new(4, 0.3, 2.6), CFrame.new(base + Vector3.new(0, 2.5, 2.6)), Color3.fromHex("6b5a45"), "Table")
			part(root, Vector3.new(0.4, 2.35, 0.4), CFrame.new(base + Vector3.new(0, 1.175, 2.6)), DARK, "TableLeg")
			stand = CFrame.lookAt(base + Vector3.new(0, 2.6, 0), base + Vector3.new(0, 2.6, 0) + FACE)
		elseif kind == "booth" then
			part(root, Vector3.new(4, 3.2, 1.2), CFrame.new(base + Vector3.new(0, 1.6, 2.2)), Color3.fromHex("6b5a45"), "Counter")
		elseif kind == "weld" then
			stand = CFrame.lookAt(base + Vector3.new(0, 3, 0), base + Vector3.new(0, 3, 0) - FACE) -- facing the work, away
			part(root, Vector3.new(4, 7, 0.6), CFrame.new(base + Vector3.new(0, 3.5, -2.4)), Color3.fromHex("3c4048"), "Hull")
		end
		if kind == "walk" then
			table.insert(steps, function(t)
				act.step(t)
				local c = t % 8
				local k = if c < 4 then c / 4 else 1 - (c - 4) / 4
				local dir = if c < 4 then 1 else -1
				local pos = base + Vector3.new(0, 3, -4 + 8 * k)
				hrp.CFrame = CFrame.lookAt(pos, pos + Vector3.new(0, 0, dir))
				act.animator:StepAnimations(0)
			end)
		else
			hrp.CFrame = stand
			table.insert(steps, function(t)
				act.step(t + i * 0.37)
			end)
		end
	end

	local cam = workspace.CurrentCamera
	if cam then
		cam.CFrame = CFrame.lookAt(P + Vector3.new(0, 34, 110), P + Vector3.new(0, 2, 16))
	end
	local t0 = os.clock()
	conn = RunService.Heartbeat:Connect(function()
		if not root.Parent then
			M.stop()
			return
		end
		local t = os.clock() - t0
		for _, s in ipairs(steps) do
			s(t)
		end
	end)
	M.steps = steps
	return #steps
end

-- freeze at time t for a still
function M.at(t)
	M.stop()
	for _, s in ipairs(M.steps or {}) do
		s(t)
	end
end

return M
