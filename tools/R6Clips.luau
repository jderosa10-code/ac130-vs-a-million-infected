--!nocheck
-- R6Clips (ReplicatedStorage.Convoy): the R6 animations for people (players, soldiers, hangar staff, survivors),
-- written as poses over time. Method by fwjelaa (FWJ STUDIOS). Live servers play the uploaded Animation assets
-- (AnimIds.R6); in Studio, a clip without an upload is built and registered on the fly.
--
-- Pose language, {x, y, z[, px, py, pz]} in degrees, in the PARENT's axes (converted to each R6 joint here):
--   Torso: +x leans back, +y turns left, +z leans to the right side; px/py/pz move the body (studs, root space).
--   Arms: +x swings forward, +z swings the right arm out / the left arm in (left arm out is -z).
--   Legs: +x forward, keyed against the VERTICAL (the torso's lean is taken back out of them).
--   Head: +x looks up, +y looks left.
-- The edit-mode showcase is ServerStorage.CrewAnims. Re-upload a clip whenever it changes (tools/CrewAnims.luau).
local KSP = game:GetService("KeyframeSequenceProvider")

local M = {}
---------------------------------------------------------------------------------------------------- builder
local R = math.rad
local C0ROT = { -- the rotation part of each standard R6 joint's C0
	Torso = CFrame.fromEulerAnglesXYZ(R(-90), 0, R(-180)),
	Head = CFrame.fromEulerAnglesXYZ(R(-90), 0, R(-180)),
	["Right Arm"] = CFrame.fromEulerAnglesXYZ(0, R(90), 0),
	["Right Leg"] = CFrame.fromEulerAnglesXYZ(0, R(90), 0),
	["Left Arm"] = CFrame.fromEulerAnglesXYZ(0, R(-90), 0),
	["Left Leg"] = CFrame.fromEulerAnglesXYZ(0, R(-90), 0),
}
local NAME = { Torso = "Torso", Head = "Head", RightArm = "Right Arm", LeftArm = "Left Arm", RightLeg = "Right Leg", LeftLeg = "Left Leg" }
local LIMBS = { "Head", "RightArm", "LeftArm", "RightLeg", "LeftLeg" }
local EASE = { -- (the engine's In / Out are swapped: "in" speeds up, "out" slows down)
	linear = { "Linear", "In" },
	inout = { "CubicV2", "InOut" },
	["in"] = { "CubicV2", "Out" },
	out = { "CubicV2", "In" },
	hold = { "Constant", "Out" },
}
local function want(v)
	v = v or { 0, 0, 0 }
	return CFrame.new(v[4] or 0, v[5] or 0, v[6] or 0) * CFrame.Angles(R(v[1]), R(v[2]), R(v[3]))
end
local function joint(j, cf)
	local r = C0ROT[NAME[j]]
	return r:Inverse() * cf * r
end
local function mirror(p)
	local m = {}
	for j, v in pairs(p) do
		local o = if j:sub(1, 4) == "Left" then "Right" .. j:sub(5) elseif j:sub(1, 5) == "Right" then "Left" .. j:sub(6) else j
		m[o] = { v[1], -v[2], -v[3], -(v[4] or 0), v[5] or 0, v[6] or 0 }
	end
	return m
end
local function with(base, over)
	local p = table.clone(base)
	for j, v in pairs(over) do
		p[j] = v
	end
	return p
end
local function at(v: Vector3, p)
	local t = p or { 0, 0, 0 }
	return { t[1], t[2], t[3], v.X, v.Y, v.Z }
end

-- clip = { name, length (s), loop, priority, keys = { { t (s), pose, ease? } } }
local function build(clip)
	local kfs = Instance.new("KeyframeSequence")
	kfs.Name = clip.name
	kfs.Loop = clip.loop == true
	kfs.Priority = Enum.AnimationPriority[clip.priority or "Action"]
	local keys = table.clone(clip.keys)
	if clip.loop and keys[#keys][1] < clip.length then
		table.insert(keys, { clip.length, keys[1][2], keys[1][3] })
	end
	for _, k in ipairs(keys) do
		local kf = Instance.new("Keyframe")
		kf.Time = k[1]
		local e = EASE[k[3] or "inout"]
		local function pose(name, parent, cf)
			local p = Instance.new("Pose")
			p.Name = name
			p.CFrame = cf
			p.Weight = if name == "HumanoidRootPart" then 0 else 1
			p.EasingStyle = Enum.PoseEasingStyle[e[1]]
			p.EasingDirection = Enum.PoseEasingDirection[e[2]]
			p.Parent = parent
			return p
		end
		local root = pose("HumanoidRootPart", kf, CFrame.identity)
		local torsoCF = want(k[2].Torso)
		local torso = pose("Torso", root, joint("Torso", torsoCF))
		local torsoRot = torsoCF.Rotation
		for _, j in ipairs(LIMBS) do
			local cf = want(k[2][j])
			if j == "RightLeg" or j == "LeftLeg" then
				cf = torsoRot:Inverse() * cf -- legs hang against the vertical, not the leaning torso
			end
			pose(NAME[j], torso, joint(j, cf))
		end
		for _, name in ipairs(k.markers or {}) do
			local mk = Instance.new("KeyframeMarker")
			mk.Name = name
			mk.Parent = kf
		end
		kf.Parent = kfs
	end
	return kfs
end
M.build = build

---------------------------------------------------------------------------------------------------- poses
local STAND = { Torso = { 0, 0, 0 }, RightArm = { 2, 0, 4 }, LeftArm = { 2, 0, -4 }, RightLeg = { 0, 0, 3 }, LeftLeg = { 0, 0, -3 } }

-- running for the skid
local RUN_A = {
	Torso = { -12, 6, 0, 0, -0.1, 0 }, Head = { 8, -6, 0 },
	RightLeg = { 45, 0, 2 }, LeftLeg = { -40, 0, -2 },
	RightArm = { -50, 0, 8 }, LeftArm = { 55, 0, -8 },
}
local RUN_B = {
	Torso = { -12, 0, 0, 0, 0.12, 0 }, Head = { 8, 0, 0 },
	RightLeg = { 4, 0, 2 }, LeftLeg = { 8, 0, -2 },
	RightArm = { 4, 0, 8 }, LeftArm = { 6, 0, -8 },
}
-- hanging off the skid by the left hand
local HANG = {
	Torso = { 6, 0, 4 }, Head = { 24, -8, 0 },
	LeftArm = { 180, 0, -6 }, RightArm = { 30, 0, 20 },
	RightLeg = { 14, 0, 4 }, LeftLeg = { -6, 0, -4 },
}
-- at the AC-130's sensor console: sat, hands on the controls
local SEATED = {
	Torso = { 0, 0, 0 }, Head = { -10, 0, 0 },
	RightArm = { 68, 0, 2 }, LeftArm = { 62, 0, -4 },
	RightLeg = { 90, 0, 4 }, LeftLeg = { 90, 0, -4 },
}
-- on the Little Bird's bench, facing out, hands gripping the edge, legs hanging over
local BENCH = {
	Torso = { 4, 0, 0 }, Head = { -4, 18, 0 },
	RightArm = { -14, 0, 14 }, LeftArm = { -14, 0, -14 },
	RightLeg = { 70, 0, 6 }, LeftLeg = { 78, 0, -6 },
}
-- hangar poses
local WALK_A = {
	Torso = { -2, 4, 0, 0, -0.06, 0 }, Head = { 2, -3, 0 },
	RightLeg = { 28, 0, 1 }, LeftLeg = { -26, 0, -1 },
	RightArm = { -26, 0, 5 }, LeftArm = { 26, 0, -5 },
}
local WALK_B = {
	Torso = { -2, 0, 0, 0, 0.05, 0 }, Head = { 2, 0, 0 },
	RightLeg = { 2, 0, 1 }, LeftLeg = { 2, 0, -1 },
	RightArm = { 0, 0, 5 }, LeftArm = { 0, 0, -5 },
}
local REST = { -- parade rest: feet apart, hands behind the back
	Torso = { 2, 0, 0 }, Head = { 0, 0, 0 },
	RightArm = { -20, 0, -16 }, LeftArm = { -20, 0, 16 },
	RightLeg = { 0, 0, 8 }, LeftLeg = { 0, 0, -8 },
}
local CLIPBOARD = {
	Torso = { -4, 0, 0 }, Head = { -24, 0, 0 },
	LeftArm = { 55, 0, 22 }, RightArm = { 50, 0, -20 },
	RightLeg = { 0, 0, 4 }, LeftLeg = { 0, 0, -4 },
}
local WELD = {
	Torso = { -6, 0, 0 }, Head = { -8, 0, 0 },
	RightArm = { 82, 0, -6 }, LeftArm = { 56, 0, 16 },
	RightLeg = { 8, 0, 4 }, LeftLeg = { -6, 0, -4 },
}
local OVERHEAD = {
	Torso = { 8, 0, 0 }, Head = { 32, 0, 0 },
	RightArm = { 160, 0, 4 }, LeftArm = { 130, 0, -10 },
	RightLeg = { 0, 0, 5 }, LeftLeg = { 0, 0, -5 },
}
local CHAIR = { -- at the coffee table: sat back a touch, forearms on the table
	Torso = { 4, 0, 0 }, Head = { -4, 0, 0 },
	RightArm = { 58, 0, -4 }, LeftArm = { 54, 0, 4 },
	RightLeg = { 90, 0, 4 }, LeftLeg = { 90, 0, -4 },
}
local LEAN = { -- booth clerk leaning on the counter
	Torso = { -14, 0, 0, 0, -0.12, 0 }, Head = { 8, 0, 0 },
	RightArm = { 72, 0, 6 }, LeftArm = { 72, 0, -6 },
	RightLeg = { 0, 0, 4 }, LeftLeg = { 0, 0, -4 },
}

---------------------------------------------------------------------------------------------------- clips
local CLIPS = {}
local function add(c)
	table.insert(CLIPS, c)
	return c
end

-- running (the pads' run for the skid, survivors, anyone in a hurry); then jump, grab the skid, hang
add({ name = "R6_Run", length = 0.6, loop = true, priority = "Movement",
	keys = { { 0, RUN_A }, { 0.15, RUN_B }, { 0.3, mirror(RUN_A) }, { 0.45, mirror(RUN_B) } } })
add({ name = "R6_HeliJump", length = 0.75, loop = false,
	keys = {
		{ 0, RUN_A },
		{ 0.15, { Torso = { -28, 0, 0, 0, -0.35, 0.1 }, Head = { 24, 0, 0 }, RightLeg = { 30, 0, 6 }, LeftLeg = { 14, 0, -6 },
			RightArm = { -55, 0, 14 }, LeftArm = { -55, 0, -14 } }, "in" },
		{ 0.25, { Torso = { -2, 0, 0, 0, 0.1, 0 }, Head = { 32, 0, 0 }, RightLeg = { -12, 0, 4 }, LeftLeg = { -4, 0, -4 },
			LeftArm = { 172, 0, -8 }, RightArm = { 150, 0, 16 } }, "out" },
		{ 0.43, { Torso = { 4, 0, -3 }, Head = { 28, -6, 0 }, RightLeg = { 40, 0, 6 }, LeftLeg = { 28, 0, -6 },
			LeftArm = { 180, 0, -6 }, RightArm = { 160, 0, 16 } }, "out" },
		{ 0.75, HANG },
	} })
add({ name = "R6_HeliHang", length = 1.6, loop = true,
	keys = {
		{ 0, HANG },
		{ 0.55, with(HANG, { Torso = { -4, 0, -2 }, Head = { 16, 8, 0 }, RightArm = { 50, 0, 28 }, RightLeg = { -8, 0, 4 }, LeftLeg = { 18, 0, -4 } }) },
		{ 1.05, with(HANG, { Torso = { 8, 0, 6 }, Head = { 26, -14, 0 }, RightArm = { 16, 0, 14 }, RightLeg = { 22, 0, 4 }, LeftLeg = { -2, 0, -4 } }) },
	} })

-- AC-130: stand with your back to the seat and sit down into it. The root is placed ON THE SEAT; `start` is
-- where the standing root is, in the seated root's space (+Y up, -Z forward).
function M.sitDownClip(start: Vector3)
	return { name = "R6_GunnerSitDown", length = 1.1, loop = false,
		keys = {
			{ 0, { Torso = at(start, nil), RightArm = { 2, 0, 4 }, LeftArm = { 2, 0, -4 }, RightLeg = { 0, 0, 3 }, LeftLeg = { 0, 0, -3 } } },
			{ 0.35, { Torso = at(start + Vector3.new(0, -0.35, 0.3), { -24, 0, 0 }), Head = { 14, 0, 0 },
				RightLeg = { 30, 0, 4 }, LeftLeg = { 30, 0, -4 }, RightArm = { -25, 0, 12 }, LeftArm = { -25, 0, -12 } } },
			{ 0.75, { Torso = at(start * 0.15, { -12, 0, 0 }), Head = { 6, 0, 0 },
				RightLeg = { 84, 0, 4 }, LeftLeg = { 84, 0, -4 }, RightArm = { -8, 0, 8 }, LeftArm = { -8, 0, -8 } }, "out" },
			{ 1.1, SEATED },
		} }
end
M.GUNNER_START = Vector3.new(0, -0.1, -1.3) -- (the AC-130 cabin: seat top 2.1 above the floor)
add(M.sitDownClip(M.GUNNER_START))
add({ name = "R6_GunnerSeat", length = 4, loop = true, priority = "Idle",
	keys = {
		{ 0, SEATED },
		{ 1.2, with(SEATED, { RightArm = { 72, 0, 2 }, Head = { -9, 0, 0 } }) },
		{ 2.4, with(SEATED, { Head = { -6, 22, 0 }, Torso = { 0, 5, 0 } }) },
		{ 3.2, with(SEATED, { Head = { -10, 4, 0 } }) },
	} })

-- end of the tutorial: back up to the Little Bird's bench, hands on the edge, hop up and sit. The root is placed
-- ON THE BENCH; `start` is the standing root in the seated root's space.
function M.benchClimbClip(start: Vector3)
	local mid = start:Lerp(Vector3.zero, 0.7)
	return { name = "R6_BenchClimb", length = 1.5, loop = false,
		keys = {
			{ 0, { Torso = at(start, nil), RightArm = { 2, 0, 4 }, LeftArm = { 2, 0, -4 }, RightLeg = { 0, 0, 3 }, LeftLeg = { 0, 0, -3 } } },
			{ 0.35, { Torso = at(start + Vector3.new(0, -0.15, 0.2), { -14, 0, 0 }), Head = { 10, 0, 0 },
				RightArm = { -40, 0, 14 }, LeftArm = { -40, 0, -14 }, RightLeg = { 14, 0, 4 }, LeftLeg = { 14, 0, -4 } } },
			{ 0.7, { Torso = at(start + Vector3.new(0, -0.3, 0.35), { -22, 0, 0 }), Head = { 12, 0, 0 },
				RightArm = { -52, 0, 14 }, LeftArm = { -52, 0, -14 }, RightLeg = { 26, 0, 4 }, LeftLeg = { 26, 0, -4 } }, "in" },
			{ 1.05, { Torso = at(mid + Vector3.new(0, 0.55, 0), { -6, 0, 0 }), Head = { 2, 0, 0 },
				RightArm = { -28, 0, 14 }, LeftArm = { -28, 0, -14 }, RightLeg = { 55, 0, 6 }, LeftLeg = { 50, 0, -6 } }, "out" },
			{ 1.5, BENCH },
		} }
end
M.BENCH_START = Vector3.new(0, -0.1, -1.2)
add(M.benchClimbClip(M.BENCH_START))
add({ name = "R6_BenchRide", length = 2.8, loop = true, priority = "Idle",
	keys = {
		{ 0, BENCH },
		{ 0.7, with(BENCH, { RightLeg = { 58, 0, 6 }, LeftLeg = { 86, 0, -6 }, Head = { -8, -6, 0 }, Torso = { 4, 0, 3 } }) },
		{ 1.4, with(BENCH, { RightLeg = { 82, 0, 6 }, LeftLeg = { 62, 0, -6 }, Head = { -2, 30, 2 }, Torso = { 2, 0, -2 } }) },
		{ 2.1, with(BENCH, { RightLeg = { 62, 0, 6 }, LeftLeg = { 84, 0, -6 }, Head = { -10, 4, 0 } }) },
	} })

-- hangar: everyone
add({ name = "R6_Walk", length = 1.0, loop = true, priority = "Movement",
	keys = { { 0, WALK_A }, { 0.25, WALK_B }, { 0.5, mirror(WALK_A) }, { 0.75, mirror(WALK_B) } } })
add({ name = "R6_Idle", length = 4, loop = true, priority = "Idle",
	keys = {
		{ 0, STAND },
		{ 1.3, with(STAND, { Torso = { -1, 0, 1.5, 0, -0.02, 0 }, Head = { -3, 10, 0 }, RightArm = { 4, 0, 5 } }) },
		{ 2.6, with(STAND, { Torso = { 0, 0, -1.5 }, Head = { 2, -6, 0 }, LeftArm = { 4, 0, -5 } }) },
	} })
-- officers: parade rest, looking the floor over
add({ name = "R6_ParadeRest", length = 5, loop = true, priority = "Idle",
	keys = {
		{ 0, REST },
		{ 1.6, with(REST, { Head = { 0, 24, 0 }, Torso = { 2, 4, 0 } }) },
		{ 3.2, with(REST, { Head = { 0, -20, 0 }, Torso = { 2, -3, 0 } }) },
	} })
-- talking it over: hands out, nods
add({ name = "R6_Talk", length = 3.2, loop = true, priority = "Idle",
	keys = {
		{ 0, STAND },
		{ 0.5, with(STAND, { RightArm = { 40, 10, 24 }, Head = { 2, 8, 0 }, Torso = { 0, 4, 0 } }) },
		{ 1.0, with(STAND, { RightArm = { 30, -10, 10 }, Head = { -6, 4, 0 }, Torso = { 0, 2, 0 } }) },
		{ 1.6, STAND },
		{ 2.2, with(STAND, { LeftArm = { 38, -10, -22 }, Head = { 4, -8, 0 }, Torso = { 0, -4, 0 } }) },
		{ 2.7, with(STAND, { LeftArm = { 28, 10, -10 }, Head = { -4, -4, 0 } }) },
	} })
-- pointing out something on the aircraft (one-shot, plays over the idle)
add({ name = "R6_Point", length = 1.8, loop = false,
	keys = {
		{ 0, STAND },
		{ 0.35, with(STAND, { RightArm = { 0, 40, 90 }, Head = { 2, -18, 0 }, Torso = { 0, -8, 0 } }), "out" },
		{ 1.3, with(STAND, { RightArm = { 4, 38, 88 }, Head = { 0, -18, 0 }, Torso = { 0, -8, 0 } }) },
		{ 1.8, STAND },
	} })
-- ground crew marshalling the gunship in
local MARSH_DOWN = with(STAND, { RightArm = { 0, 0, 100 }, LeftArm = { 0, 0, -100 }, RightLeg = { 0, 0, 7 }, LeftLeg = { 0, 0, -7 } })
local MARSH_UP = with(STAND, { RightArm = { 0, 0, 172 }, LeftArm = { 0, 0, -172 }, Head = { 6, 0, 0 }, RightLeg = { 0, 0, 7 }, LeftLeg = { 0, 0, -7 } })
add({ name = "R6_Marshal", length = 1.6, loop = true,
	keys = { { 0, MARSH_DOWN }, { 0.4, MARSH_UP, "out" }, { 0.8, MARSH_DOWN }, { 1.2, MARSH_UP, "out" } } })
-- checking a clipboard, writing now and then
add({ name = "R6_Clipboard", length = 3, loop = true, priority = "Idle",
	keys = {
		{ 0, CLIPBOARD },
		{ 0.4, with(CLIPBOARD, { RightArm = { 54, 0, -24 } }) },
		{ 0.8, with(CLIPBOARD, { RightArm = { 48, 0, -18 } }) },
		{ 1.2, with(CLIPBOARD, { RightArm = { 54, 0, -24 } }) },
		{ 1.8, with(CLIPBOARD, { Head = { -4, 16, 0 }, RightArm = { 20, 0, 6 } }) }, -- looks up at the aircraft
		{ 2.5, CLIPBOARD },
	} })
-- welders
add({ name = "R6_Weld", length = 1.6, loop = true,
	keys = {
		{ 0, WELD },
		{ 0.55, with(WELD, { RightArm = { 78, 0, -2 } }) },
		{ 1.1, with(WELD, { RightArm = { 86, 0, -10 } }) },
	} })
add({ name = "R6_OverheadWeld", length = 1.8, loop = true,
	keys = {
		{ 0, OVERHEAD },
		{ 0.6, with(OVERHEAD, { RightArm = { 156, 0, 8 } }) },
		{ 1.2, with(OVERHEAD, { RightArm = { 164, 0, 0 } }) },
	} })
-- coffee table
add({ name = "R6_ChairSit", length = 4, loop = true, priority = "Idle",
	keys = {
		{ 0, CHAIR },
		{ 1.4, with(CHAIR, { Head = { -2, 18, 0 }, Torso = { 5, 4, 0 } }) },
		{ 2.8, with(CHAIR, { Head = { -6, -12, 0 }, LeftArm = { 58, 0, 6 } }) },
	} })
add({ name = "R6_Sip", length = 2.2, loop = false,
	keys = {
		{ 0, CHAIR },
		{ 0.5, with(CHAIR, { RightArm = { 128, 0, -22 }, Head = { 12, 0, 0 } }), "out" },
		{ 1.4, with(CHAIR, { RightArm = { 132, 0, -24 }, Head = { 16, 0, 0 } }) },
		{ 2.2, CHAIR },
	} })
add({ name = "R6_Laugh", length = 1.6, loop = false,
	keys = {
		{ 0, CHAIR },
		{ 0.3, with(CHAIR, { Torso = { 16, 0, 0 }, Head = { 22, 0, 0 }, LeftArm = { 30, 0, 10 } }), "out" },
		{ 0.5, with(CHAIR, { Torso = { 9, 0, 0 }, Head = { 14, 0, 0 }, LeftArm = { 34, 0, 10 } }) },
		{ 0.7, with(CHAIR, { Torso = { 16, 0, 0 }, Head = { 22, 0, 0 }, LeftArm = { 30, 0, 10 } }) },
		{ 0.9, with(CHAIR, { Torso = { 9, 0, 0 }, Head = { 14, 0, 0 }, LeftArm = { 34, 0, 10 } }) },
		{ 1.6, CHAIR },
	} })
-- booth clerks
add({ name = "R6_BoothLean", length = 4, loop = true, priority = "Idle",
	keys = {
		{ 0, LEAN },
		{ 1.5, with(LEAN, { Head = { 6, 20, 0 }, Torso = { -14, 4, 0, 0, -0.12, 0 } }) },
		{ 2.8, with(LEAN, { Head = { 10, -14, 0 }, RightArm = { 76, 0, 8 } }) },
	} })
add({ name = "R6_Wave", length = 1.8, loop = false,
	keys = {
		{ 0, STAND },
		{ 0.3, with(STAND, { RightArm = { 8, 0, 150 }, Head = { 4, -6, 0 } }), "out" },
		{ 0.6, with(STAND, { RightArm = { 8, 0, 128 }, Head = { 4, -6, 0 } }) },
		{ 0.9, with(STAND, { RightArm = { 8, 0, 158 }, Head = { 4, -6, 0 } }) },
		{ 1.2, with(STAND, { RightArm = { 8, 0, 130 }, Head = { 4, -6, 0 } }) },
		{ 1.8, STAND },
	} })

M.CLIPS = CLIPS
-- how far the body travels each second with the clip at speed 1 (play at speed / STRIDE so the feet don't slide)
M.WALK_STRIDE = 3.6
M.RUN_STRIDE = 9
M.byName = {}
for _, c in ipairs(CLIPS) do
	M.byName[c.name] = c
end

-- uploaded ids (AnimIds.R6), else built and registered (Studio only)
local okIds, Ids = pcall(require, script.Parent:WaitForChild("AnimIds", 5))
local R6IDS = (okIds and type(Ids) == "table" and Ids.R6) or {}
local cache = {}
function M.animation(name: string): Animation?
	if cache[name] then
		return cache[name]
	end
	local a = Instance.new("Animation")
	a.Name = name
	local id = R6IDS[name]
	if id then
		a.AnimationId = "rbxassetid://" .. id
	else
		local clip = M.byName[name]
		if not clip then
			return nil
		end
		local ok, res = pcall(function()
			return KSP:RegisterKeyframeSequence(build(clip))
		end)
		if not ok then
			warn("[R6Clips] no upload for", name)
			return nil
		end
		a.AnimationId = res
	end
	cache[name] = a
	return a
end
-- a track for this clip on this animator (nil if it can't load)
function M.load(animator: Animator?, name: string, looped: boolean?): AnimationTrack?
	local a = animator and M.animation(name)
	if not a then
		return nil
	end
	local ok, tr = pcall(animator.LoadAnimation, animator, a)
	if not ok then
		return nil
	end
	if looped ~= nil then
		tr.Looped = looped
	end
	return tr
end
-- put an R6 rig's joints back to the standard ones (the seated NPCs were built with their hips pre-bent in C0)
function M.standardJoints(model: Instance)
	for _, d in ipairs(model:GetDescendants()) do
		if d:IsA("Motor6D") then
			local r = d.Part1 and C0ROT[d.Part1.Name]
			if r then
				d.C0 = CFrame.new(d.C0.Position) * r
			end
		end
	end
end

return M
