--!nocheck
-- InfectedAnims (ServerStorage): the infected's walks and bunker hits, written as poses over time and built into
-- KeyframeSequences in Studio. Method by fwjelaa (FWJ STUDIOS): pose language, timing and craft rules from the
-- make-anim pack (same conventions as its AnimKit).
--
-- Legs are keyed against the vertical: the LowerTorso's lean and roll are taken out of the UpperLegs when built.
-- Pose language (R15, every joint's C0 has no rotation on our rigs): {x, y, z} degrees like CFrame.Angles, in the
-- parent part's axes; {x, y, z, px, py, pz} also moves the joint in studs (root only: LowerTorso).
--   +x  arm/leg swings FORWARD, forearm bends forward (LowerArm), head looks UP, torso leans BACK
--   -x  on a LowerLeg bends the knee (shin back)
--   +y  turns to the character's LEFT
--   +z  right arm/leg OUT; left arm/leg ACROSS (left out is -z)
--
-- Use from the command bar (Edit mode, nothing to publish):
--   require(game.ServerStorage.InfectedAnims).showcase()     -- builds the showcase and plays every clip on a loop
--   require(game.ServerStorage.InfectedAnims).stop()         -- stops it (the showcase stays where it is)
--   require(game.ServerStorage.InfectedAnims).clear()        -- removes the showcase
--   require(game.ServerStorage.InfectedAnims).build()        -- rebuilds every KeyframeSequence (ServerStorage.Animations)
local RunService = game:GetService("RunService")
local AnimationClipProvider = game:GetService("AnimationClipProvider")
local ServerStorage = game:GetService("ServerStorage")

local M = {}

local PARENT = {
	LowerTorso = "HumanoidRootPart", UpperTorso = "LowerTorso", Head = "UpperTorso",
	LeftUpperArm = "UpperTorso", LeftLowerArm = "LeftUpperArm", LeftHand = "LeftLowerArm",
	RightUpperArm = "UpperTorso", RightLowerArm = "RightUpperArm", RightHand = "RightLowerArm",
	LeftUpperLeg = "LowerTorso", LeftLowerLeg = "LeftUpperLeg", LeftFoot = "LeftLowerLeg",
	RightUpperLeg = "LowerTorso", RightLowerLeg = "RightUpperLeg", RightFoot = "RightLowerLeg",
}
local JOINTS = {}
for j in pairs(PARENT) do
	table.insert(JOINTS, j)
end
local EASE = {
	linear = { "Linear", "In" },
	inout = { "CubicV2", "InOut" },
	into = { "CubicV2", "In" }, -- accelerates into the next key (wind-up into a strike)
	out = { "CubicV2", "Out" }, -- eases out of a key (recovery)
	hold = { "Constant", "Out" },
}

local function cf(v)
	return CFrame.new(v[4] or 0, v[5] or 0, v[6] or 0) * CFrame.Angles(math.rad(v[1]), math.rad(v[2]), math.rad(v[3]))
end

-- mirror a pose left <-> right (for the second half of a cycle)
local function mirror(p)
	local m = {}
	for j, v in pairs(p) do
		local o = if j:sub(1, 4) == "Left" then "Right" .. j:sub(5) elseif j:sub(1, 5) == "Right" then "Left" .. j:sub(6) else j
		m[o] = { v[1], -v[2], -v[3], -(v[4] or 0), v[5] or 0, v[6] or 0 }
	end
	return m
end
-- every joint not given keeps the base pose
local function with(base, over)
	local p = table.clone(base)
	for j, v in pairs(over) do
		p[j] = v
	end
	return p
end

-- clip = { name, length, loop, priority, keys = { {frame, pose, ease}, ... }, markers = { {frame, name} } }
local function build(clip)
	local kfs = Instance.new("KeyframeSequence")
	kfs.Name = clip.name
	kfs.Loop = clip.loop
	kfs.Priority = Enum.AnimationPriority[clip.priority or "Movement"]
	local frames = {}
	for _, k in ipairs(clip.keys) do
		frames[k[1]] = k
	end
	if clip.loop and frames[0] and not frames[clip.length] then -- close the loop on the first pose
		frames[clip.length] = { clip.length, frames[0][2], frames[0][3] }
	end
	local markers = {}
	for _, m in ipairs(clip.markers or {}) do
		markers[m[1]] = markers[m[1]] or {}
		table.insert(markers[m[1]], m[2])
		frames[m[1]] = frames[m[1]] or { m[1], nil }
	end
	local order = {}
	for f in pairs(frames) do
		table.insert(order, f)
	end
	table.sort(order)
	for _, f in ipairs(order) do
		local k = frames[f]
		local kf = Instance.new("Keyframe")
		kf.Time = f / 60
		if k[2] then
			local made = {}
			local function poseFor(part)
				if made[part] then
					return made[part]
				end
				local p = Instance.new("Pose")
				p.Name = part
				p.Weight = 0
				local parent = PARENT[part]
				p.Parent = if parent and parent ~= "HumanoidRootPart" then poseFor(parent) elseif parent then poseFor(parent) else kf
				made[part] = p
				return p
			end
			local e = EASE[k[3] or "inout"]
			-- legs hang off the LowerTorso, so leaning or rolling it would swing the legs with it: leg angles are
			-- written against the vertical, and the hips' lean and roll are taken back out of them here
			local rootV = k[2].LowerTorso or { 0, 0, 0 }
			for _, j in ipairs(JOINTS) do
				local p = poseFor(j)
				local v = k[2][j] or { 0, 0, 0 }
				if j == "RightUpperLeg" or j == "LeftUpperLeg" then
					v = { v[1] - rootV[1], v[2], v[3] - rootV[3] }
				end
				p.CFrame = cf(v)
				p.EasingStyle = Enum.PoseEasingStyle[e[1]]
				p.EasingDirection = Enum.PoseEasingDirection[e[2]]
				p.Weight = 1
			end
		end
		for _, name in ipairs(markers[f] or {}) do
			local mk = Instance.new("KeyframeMarker")
			mk.Name = name
			mk.Parent = kf
		end
		kf.Parent = kfs
	end
	return kfs
end

---------------------------------------------------------------------------------------------------- the clips
local CLIPS = {}

-- WALKS (loops, in place: the game moves the rig)

-- Shamble: slow, limping on the left leg, head lolled to one side, arms hanging dead and swinging late
do
	local base = {
		LowerTorso = { -12, 0, 0 }, UpperTorso = { -14, 0, 4 }, Head = { -8, 6, 18 },
		RightUpperArm = { 18, 0, 6 }, RightLowerArm = { 24, 0, 0 }, RightHand = { -10, 0, 0 },
		LeftUpperArm = { 10, 0, -4 }, LeftLowerArm = { 30, 0, 0 }, LeftHand = { -14, 0, 0 },
	}
	table.insert(CLIPS, {
		name = "R15_InfectedShamble", length = 96, loop = true, label = "SHAMBLE",
		keys = {
			{ 0, with(base, { -- right foot lands
				LowerTorso = { -12, 6, 3, 0, -0.1, 0 }, UpperTorso = { -14, -8, 2 },
				RightUpperLeg = { 24, 0, 2 }, RightLowerLeg = { -10, 0, 0 }, RightFoot = { 8, 0, 0 },
				LeftUpperLeg = { -14, 0, -2 }, LeftLowerLeg = { -14, 0, 0 }, LeftFoot = { 4, 0, 0 },
				RightUpperArm = { -4, 0, 8 }, LeftUpperArm = { 26, 0, -4 }, Head = { -6, 4, 22 },
			}) },
			{ 28, with(base, { -- the bad leg drags through, barely lifted
				LowerTorso = { -10, 0, -2, 0, 0.04, 0 }, UpperTorso = { -14, 0, 6 },
				RightUpperLeg = { -2, 0, 2 }, RightLowerLeg = { -4, 0, 0 },
				LeftUpperLeg = { 4, 0, -6 }, LeftLowerLeg = { -26, 0, 0 }, LeftFoot = { 14, 0, 0 },
				RightUpperArm = { 8, 0, 6 }, LeftUpperArm = { 14, 0, -6 }, Head = { -10, 2, 14 },
			}) },
			{ 52, with(base, { -- the bad leg lands short; the body dips onto it
				LowerTorso = { -14, -5, -6, 0, -0.22, 0 }, UpperTorso = { -16, 8, 8 },
				RightUpperLeg = { -18, 0, 2 }, RightLowerLeg = { -16, 0, 0 }, RightFoot = { 6, 0, 0 },
				LeftUpperLeg = { 14, 0, -4 }, LeftLowerLeg = { -18, 0, 0 }, LeftFoot = { 4, 0, 0 },
				RightUpperArm = { 28, 0, 10 }, LeftUpperArm = { -2, 0, -2 }, Head = { -14, -2, 26 },
			}) },
			{ 76, with(base, { -- push off it, the good leg swings through
				LowerTorso = { -11, 2, 1, 0, 0.06, 0 }, UpperTorso = { -13, 2, 3 },
				RightUpperLeg = { 8, 0, 2 }, RightLowerLeg = { -48, 0, 0 }, RightFoot = { 16, 0, 0 },
				LeftUpperLeg = { -6, 0, -2 }, LeftLowerLeg = { -8, 0, 0 },
				RightUpperArm = { 12, 0, 8 }, LeftUpperArm = { 16, 0, -4 }, Head = { -8, 6, 18 },
			}) },
		},
	})
end

-- Arms Out: the classic stiff zombie walk, arms straight out in front, short stiff steps, rocking side to side
do
	local arms = {
		RightUpperArm = { 82, -6, -4 }, RightLowerArm = { 8, 0, 0 }, RightHand = { -6, 0, 0 },
		LeftUpperArm = { 86, 6, 4 }, LeftLowerArm = { 6, 0, 0 }, LeftHand = { -6, 0, 0 },
		UpperTorso = { -6, 0, 0 }, Head = { -10, 0, 0 },
	}
	local step = with(arms, {
		LowerTorso = { -4, 6, 7, 0.1, -0.06, 0 }, UpperTorso = { -6, -4, -5 },
		RightUpperLeg = { 18, 0, 0 }, RightLowerLeg = { -4, 0, 0 }, RightFoot = { 4, 0, 0 },
		LeftUpperLeg = { -16, 0, 0 }, LeftLowerLeg = { -8, 0, 0 }, LeftFoot = { 6, 0, 0 },
		RightUpperArm = { 78, -6, -4 }, LeftUpperArm = { 90, 6, 4 }, Head = { -10, 4, -6 },
	})
	local pass = with(arms, {
		LowerTorso = { -4, 0, 0, 0, 0.05, 0 },
		RightUpperLeg = { 0, 0, 0 }, RightLowerLeg = { -2, 0, 0 },
		LeftUpperLeg = { 6, 0, 0 }, LeftLowerLeg = { -28, 0, 0 }, LeftFoot = { 10, 0, 0 },
	})
	table.insert(CLIPS, {
		name = "R15_InfectedArmsOut", length = 72, loop = true, label = "ARMS OUT",
		keys = { { 0, step }, { 18, pass }, { 36, mirror(step) }, { 54, mirror(pass) } },
	})
end

-- Sprint: a runner, bent far forward, arms flailing wide and out of time, head jerking
do
	local contact = {
		LowerTorso = { -24, 8, 2, 0, -0.18, 0 }, UpperTorso = { -14, -10, 0 }, Head = { 18, 6, 6 },
		RightUpperLeg = { 46, 0, 2 }, RightLowerLeg = { -14, 0, 0 }, RightFoot = { -4, 0, 0 },
		LeftUpperLeg = { -40, 0, -2 }, LeftLowerLeg = { -52, 0, 0 }, LeftFoot = { 12, 0, 0 },
		RightUpperArm = { -50, 0, 34 }, RightLowerArm = { 40, 0, 0 }, RightHand = { -20, 0, 0 },
		LeftUpperArm = { 64, 0, -40 }, LeftLowerArm = { 56, 0, 0 }, LeftHand = { -20, 0, 0 },
	}
	local flight = {
		LowerTorso = { -22, 0, 0, 0, 0.14, 0 }, UpperTorso = { -16, 0, 0 }, Head = { 24, -4, -8 },
		RightUpperLeg = { 8, 0, 2 }, RightLowerLeg = { -30, 0, 0 },
		LeftUpperLeg = { 30, 0, -2 }, LeftLowerLeg = { -96, 0, 0 }, LeftFoot = { 24, 0, 0 },
		RightUpperArm = { 20, 0, 50 }, RightLowerArm = { 30, 0, 0 }, RightHand = { -10, 0, 0 },
		LeftUpperArm = { 10, 0, -56 }, LeftLowerArm = { 30, 0, 0 }, LeftHand = { -10, 0, 0 },
	}
	table.insert(CLIPS, {
		name = "R15_InfectedSprint", length = 28, loop = true, label = "SPRINT",
		keys = { { 0, contact }, { 7, flight }, { 14, mirror(contact) }, { 21, mirror(flight) } },
	})
end

-- Lurch: twisted to one side, one arm dangling loose, dragging the right foot sideways behind
do
	local a = {
		LowerTorso = { -16, -14, 6, 0, -0.12, 0 }, UpperTorso = { -10, -18, 12 }, Head = { -14, 20, 24 },
		RightUpperArm = { 4, 0, 4 }, RightLowerArm = { 6, 0, 0 }, RightHand = { -6, 0, 0 },
		LeftUpperArm = { 56, 10, -20 }, LeftLowerArm = { 70, 0, 0 }, LeftHand = { -24, 0, 0 },
		LeftUpperLeg = { 26, 10, -6 }, LeftLowerLeg = { -22, 0, 0 }, LeftFoot = { 8, 0, 0 },
		RightUpperLeg = { -20, -10, 18 }, RightLowerLeg = { -12, 0, 0 }, RightFoot = { 30, 0, 0 },
	}
	local b = with(a, { -- weight onto the left, the dead foot scrapes up behind
		LowerTorso = { -14, -6, -2, 0, 0.02, 0 }, UpperTorso = { -12, -10, 6 }, Head = { -10, 16, 16 },
		LeftUpperLeg = { -6, 10, -6 }, LeftLowerLeg = { -10, 0, 0 },
		RightUpperLeg = { -4, -14, 22 }, RightLowerLeg = { -20, 0, 0 }, RightFoot = { 36, 0, 0 },
		RightUpperArm = { 18, 0, 8 }, LeftUpperArm = { 48, 10, -24 },
	})
	local c = with(b, { -- the left leg reaches again; the body jerks round
		LowerTorso = { -18, -18, 8, 0, -0.16, 0 }, UpperTorso = { -8, -22, 14 }, Head = { -18, 24, 28 },
		LeftUpperLeg = { 30, 10, -6 }, LeftLowerLeg = { -30, 0, 0 },
		RightUpperLeg = { -14, -10, 20 }, RightLowerLeg = { -8, 0, 0 },
		RightUpperArm = { -6, 0, 2 }, LeftUpperArm = { 62, 12, -18 },
	})
	table.insert(CLIPS, {
		name = "R15_InfectedLurch", length = 80, loop = true, label = "LURCH",
		keys = { { 0, a }, { 30, b, "into" }, { 46, c, "out" }, { 66, b } },
	})
end

-- HITS ON THE BUNKER (one-shot Action clips; Hit marker on contact. Looped here for the showcase)
local STAND = {
	LowerTorso = { -8, 0, 0, 0, -0.08, 0 }, UpperTorso = { -8, 0, 0 }, Head = { -6, 0, 0 },
	RightUpperArm = { 24, 0, 8 }, RightLowerArm = { 30, 0, 0 }, LeftUpperArm = { 24, 0, -8 }, LeftLowerArm = { 30, 0, 0 },
	RightUpperLeg = { 14, 0, 2 }, RightLowerLeg = { -18, 0, 0 }, RightFoot = { 4, 0, 0 },
	LeftUpperLeg = { -10, 0, -2 }, LeftLowerLeg = { -12, 0, 0 }, LeftFoot = { 4, 0, 0 },
}

-- Pound: both fists up overhead, hold, hammer down into the wall
table.insert(CLIPS, {
	name = "R15_InfectedPound", length = 54, loop = true, label = "POUND", priority = "Action", wall = true,
	keys = {
		{ 0, STAND },
		{ 14, with(STAND, { -- wind-up: lean back, fists high
			LowerTorso = { 6, 0, 0, 0, 0.04, 0.1 }, UpperTorso = { 10, 0, 0 }, Head = { 12, 0, 0 },
			RightUpperArm = { 168, 0, 14 }, RightLowerArm = { 50, 0, 0 }, LeftUpperArm = { 168, 0, -14 }, LeftLowerArm = { 50, 0, 0 },
		}), "hold" },
		{ 18, with(STAND, { -- held at the top for a beat, then thrown down
			LowerTorso = { 8, 0, 0, 0, 0.06, 0.12 }, UpperTorso = { 12, 0, 0 }, Head = { 14, 0, 0 },
			RightUpperArm = { 176, 0, 12 }, RightLowerArm = { 54, 0, 0 }, LeftUpperArm = { 176, 0, -12 }, LeftLowerArm = { 54, 0, 0 },
		}), "into" },
		{ 22, with(STAND, { -- contact
			LowerTorso = { -26, 0, 0, 0, -0.32, -0.25 }, UpperTorso = { -22, 0, 0 }, Head = { -2, 0, 0 },
			RightUpperArm = { 74, 0, 4 }, RightLowerArm = { 10, 0, 0 }, LeftUpperArm = { 74, 0, -4 }, LeftLowerArm = { 10, 0, 0 },
			RightUpperLeg = { 24, 0, 2 }, RightLowerLeg = { -30, 0, 0 },
		}), "linear" },
		{ 25, with(STAND, { -- overshoot: the jolt
			LowerTorso = { -30, 0, 0, 0, -0.36, -0.28 }, UpperTorso = { -24, 0, 0 }, Head = { -8, 0, 0 },
			RightUpperArm = { 62, 0, 6 }, RightLowerArm = { 16, 0, 0 }, LeftUpperArm = { 62, 0, -6 }, LeftLowerArm = { 16, 0, 0 },
			RightUpperLeg = { 24, 0, 2 }, RightLowerLeg = { -32, 0, 0 },
		}), "out" },
	},
	markers = { { 22, "Hit" } },
})

-- Claw: right swipe, then left swipe across the wall
do
	local windR = with(STAND, {
		LowerTorso = { -10, -20, 0, 0, -0.06, 0 }, UpperTorso = { -6, -22, 0 }, Head = { -4, 26, 0 },
		RightUpperArm = { 110, 0, 70 }, RightLowerArm = { 60, 0, 0 }, RightHand = { 20, 0, 0 },
		LeftUpperArm = { 40, 0, -20 }, LeftLowerArm = { 40, 0, 0 },
	})
	local hitR = with(STAND, {
		LowerTorso = { -16, 22, 0, 0, -0.14, -0.12 }, UpperTorso = { -14, 26, 0 }, Head = { -8, -22, 0 },
		RightUpperArm = { 80, -40, -20 }, RightLowerArm = { 20, 0, 0 }, RightHand = { -20, 0, 0 },
		LeftUpperArm = { 20, 0, -30 }, LeftLowerArm = { 50, 0, 0 },
	})
	table.insert(CLIPS, {
		name = "R15_InfectedClaw", length = 48, loop = true, label = "CLAW", priority = "Action", wall = true,
		keys = {
			{ 0, STAND },
			{ 8, windR, "into" }, { 12, hitR, "linear" }, { 15, with(hitR, { RightUpperArm = { 70, -48, -26 } }), "out" },
			{ 24, mirror(windR), "into" }, { 28, mirror(hitR), "linear" },
			{ 31, mirror(with(hitR, { RightUpperArm = { 70, -48, -26 } })), "out" },
		},
		markers = { { 12, "Hit" }, { 28, "Hit" } },
	})
end

-- Ram: rears back, then throws its whole shoulder and head into the wall
table.insert(CLIPS, {
	name = "R15_InfectedRam", length = 60, loop = true, label = "RAM", priority = "Action", wall = true,
	keys = {
		{ 0, STAND },
		{ 18, with(STAND, { -- rear back and turn the shoulder in
			LowerTorso = { 4, -26, 0, 0, -0.02, 0.35 }, UpperTorso = { 6, -24, 0 }, Head = { 8, 30, 0 },
			RightUpperArm = { 10, 0, 20 }, RightLowerArm = { 40, 0, 0 }, LeftUpperArm = { 50, 0, -30 }, LeftLowerArm = { 60, 0, 0 },
			RightUpperLeg = { -6, 0, 2 }, RightLowerLeg = { -30, 0, 0 }, LeftUpperLeg = { 20, 0, -2 }, LeftLowerLeg = { -36, 0, 0 },
		}), "into" },
		{ 23, with(STAND, { -- slam
			LowerTorso = { -34, 30, 0, 0, -0.3, -0.55 }, UpperTorso = { -26, 20, -10 }, Head = { -14, -24, 0 },
			RightUpperArm = { 40, 0, 40 }, RightLowerArm = { 30, 0, 0 }, LeftUpperArm = { 10, 0, -20 }, LeftLowerArm = { 40, 0, 0 },
			RightUpperLeg = { -30, 0, 2 }, RightLowerLeg = { -10, 0, 0 }, LeftUpperLeg = { 40, 0, -2 }, LeftLowerLeg = { -40, 0, 0 },
		}), "linear" },
		{ 27, with(STAND, { -- bounces off
			LowerTorso = { -28, 26, 0, 0, -0.26, -0.42 }, UpperTorso = { -20, 18, -8 }, Head = { -4, -18, 0 },
			RightUpperArm = { 46, 0, 44 }, RightLowerArm = { 34, 0, 0 }, LeftUpperArm = { 14, 0, -24 }, LeftLowerArm = { 44, 0, 0 },
			RightUpperLeg = { -26, 0, 2 }, RightLowerLeg = { -12, 0, 0 }, LeftUpperLeg = { 36, 0, -2 }, LeftLowerLeg = { -38, 0, 0 },
		}), "out" },
	},
	markers = { { 23, "Hit" } },
})

M.CLIPS = CLIPS

function M.build()
	local folder = ServerStorage:FindFirstChild("Animations") or Instance.new("Folder")
	folder.Name = "Animations"
	folder.Parent = ServerStorage
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
-- Somewhere nobody looks: a floor out past the far side of the map. Each clip on its own infected (our real
-- rigs), named on a sign; the walks stride down a lane, the hits pound a slab of bunker wall.
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
	local old = workspace:FindFirstChild("InfectedAnimShowcase")
	if old then
		old:Destroy()
	end
end

local function part(parent, size, at, color, name)
	local p = Instance.new("Part")
	p.Name = name or "Part"
	p.Anchored = true
	p.Size = size
	p.CFrame = at
	p.Color = color
	p.TopSurface = Enum.SurfaceType.Studs
	p.BottomSurface = Enum.SurfaceType.Inlet
	p.Parent = parent
	return p
end

local function sign(parent, at, text)
	local p = part(parent, Vector3.new(10, 2.2, 0.4), at, Color3.fromHex("1e1e1c"), "Sign")
	p.TopSurface = Enum.SurfaceType.Smooth
	local g = Instance.new("SurfaceGui")
	g.Face = Enum.NormalId.Front
	g.CanvasSize = Vector2.new(500, 110)
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

function M.showcase()
	M.clear()
	local kfsList = M.build()
	local root = Instance.new("Model")
	root.Name = "InfectedAnimShowcase"
	root.Parent = workspace
	local templates = {}
	for _, m in ipairs(ServerStorage.ConvoyTemplates.Infected:GetChildren()) do
		if m:IsA("Model") and m:FindFirstChild("UpperTorso") then
			table.insert(templates, m)
		end
	end
	local P = M.ORIGIN.Position
	local floor = part(root, Vector3.new(150, 1, 90), CFrame.new(P - Vector3.new(0, 0.5, 0)), Color3.fromHex("969080"), "Floor")
	floor.Material = Enum.Material.Plastic
	local function facing(pos, dir)
		return CFrame.lookAt(pos, pos + dir)
	end
	local actors = {}
	local walkI, hitI = 0, 0
	for i, clip in ipairs(CLIPS) do
		local spot
		if clip.wall then
			-- the hits: side on to the camera (camera looks toward -Z), hitting a slab of bunker wall
			hitI += 1
			local at = P + Vector3.new(-36 + (hitI - 1) * 34, 0, -20)
			spot = facing(at, Vector3.xAxis)
			local wallAt = at + Vector3.new(4.4, 5, 0)
			local wall = part(root, Vector3.new(14, 10, 3), facing(wallAt, Vector3.xAxis), Color3.fromHex("4a523a"), "BunkerWall")
			wall.FrontSurface, wall.BackSurface = Enum.SurfaceType.Weld, Enum.SurfaceType.Weld
			wall.LeftSurface, wall.RightSurface = Enum.SurfaceType.Weld, Enum.SurfaceType.Weld
			part(root, Vector3.new(14.4, 0.6, 3.4), facing(wallAt + Vector3.new(0, 5.3, 0), Vector3.xAxis), Color3.fromHex("f5c518"), "Hazard")
			sign(root, facing(at + Vector3.new(0, 1.2, 8), Vector3.zAxis), clip.label)
		else
			-- the walks: each down its own lane, toward the camera
			walkI += 1
			local at = P + Vector3.new(-48 + (walkI - 1) * 32, 0, 4)
			spot = facing(at, Vector3.zAxis)
			part(root, Vector3.new(7, 0.2, 24), CFrame.new(at + Vector3.new(0, 0.1, 11)), Color3.fromHex("363632"), "Lane")
			sign(root, facing(at + Vector3.new(0, 1.2, 25), Vector3.zAxis), clip.label)
		end
		local t = templates[(i - 1) % #templates + 1]
		local m = t:Clone()
		m.Name = clip.label
		for _, d in ipairs(m:GetDescendants()) do
			if d:IsA("BaseScript") then
				d:Destroy()
			elseif d:IsA("BasePart") then
				d.Anchored = d.Name == "HumanoidRootPart"
				d.CanCollide = false
			end
		end
		local rh = m:GetAttribute("RootHeight") or 3
		m:PivotTo(spot * CFrame.new(0, rh, 0))
		m.Parent = root
		-- (our infected run on an AnimationController with AnimationConstraints; older rigs on a Humanoid)
		local animator = m:FindFirstChildWhichIsA("Animator", true)
		if not animator then
			local host = m:FindFirstChildWhichIsA("Humanoid", true) or m:FindFirstChildWhichIsA("AnimationController", true)
			animator = Instance.new("Animator")
			animator.Parent = host
		end
		local anim = Instance.new("Animation")
		anim.AnimationId = AnimationClipProvider:RegisterAnimationClip(kfsList[clip.name])
		local track = animator:LoadAnimation(anim)
		track.Looped = true
		track:Play(0, 1, 0)
		table.insert(actors, {
			model = m, root = m:FindFirstChild("HumanoidRootPart"), track = track, animator = animator,
			length = clip.length / 60, spot = spot * CFrame.new(0, rh, 0), walk = not clip.wall,
			speed = ({ R15_InfectedShamble = 3.5, R15_InfectedArmsOut = 4, R15_InfectedSprint = 18, R15_InfectedLurch = 3 })[clip.name] or 0,
		})
	end
	-- a camera spot for looking at it: the Studio camera jumps there once
	local cam = workspace.CurrentCamera
	if cam then
		cam.CFrame = CFrame.lookAt(P + Vector3.new(0, 16, 66), P + Vector3.new(0, 3, -6))
	end
	M.actors = actors
	local t0 = os.clock()
	conn = RunService.Heartbeat:Connect(function()
		if not root.Parent then
			M.stop()
			return
		end
		local t = os.clock() - t0
		for _, a in ipairs(actors) do
			if a.model.Parent and a.root then
				if a.walk then -- down the lane, then back to the start
					local d = (t * a.speed) % 20
					a.root.CFrame = a.spot * CFrame.new(0, 0, -d)
				end
				a.track.TimePosition = t % a.length
				a.animator:StepAnimations(0)
			end
		end
	end)
	return #actors
end

-- freeze every actor at time t (seconds) for a still: the walks back at the start of their lane
function M.at(t)
	M.stop()
	for _, a in ipairs(M.actors or {}) do
		if a.walk then
			a.root.CFrame = a.spot * CFrame.new(0, 0, -6)
		end
		a.track.TimePosition = t % a.length
		a.animator:StepAnimations(0)
	end
end

return M
