-- One-off Studio patch (0.14.12): the people move to the R6 clips in Convoy.R6Clips. Run in each place's command
-- bar / execute_luau. Every edit is checked before anything is written; nothing changes if one doesn't match.
local SPS = game.StarterPlayer.StarterPlayerScripts
local Convoy = game.ReplicatedStorage.Convoy
local pending, log = {}, {}
local function src(scr)
	if not pending[scr] then
		pending[scr] = scr.Source
	end
	return pending[scr]
end
local function rep(scr, a, b, optional)
	local s = src(scr)
	local i, j = s:find(a, 1, true)
	if not i then
		assert(optional, scr.Name .. ": no match for: " .. a:sub(1, 70))
		table.insert(log, scr.Name .. ": skipped (optional) " .. a:sub(1, 40))
		return
	end
	assert(not s:find(a, j + 1, true), scr.Name .. ": two matches for: " .. a:sub(1, 70))
	pending[scr] = s:sub(1, i - 1) .. b .. s:sub(j + 1)
end

---------------------------------------------------------------- R6Clips: strides
local R6 = Convoy:FindFirstChild("R6Clips")
assert(R6, "R6Clips missing")
rep(R6, "M.CLIPS = CLIPS\nM.byName = {}", "M.CLIPS = CLIPS\n-- how far the body travels each second with the clip at speed 1 (play at speed / STRIDE so the feet don't slide)\nM.WALK_STRIDE = 3.6\nM.RUN_STRIDE = 9\nM.byName = {}", true)

---------------------------------------------------------------- AnimIds: the uploaded R6 clips
local ids = Convoy.AnimIds
do
	local s = src(ids)
	if not s:find("R6 = {", 1, true) then
		local i = s:match(".*()}") -- the table's closing brace
		pending[ids] = s:sub(1, i - 1) .. [[	-- R6 people clips (Convoy.R6Clips; built by tools/build_r6_rbxmx.py into art/anim/r6, uploaded to the group)
	R6 = {
		R6_Run = 83845669665700,
		R6_HeliJump = 72650198516525,
		R6_HeliHang = 103930042570178,
		R6_GunnerSitDown = 73805238941500,
		R6_GunnerSeat = 75124647562997,
		R6_BenchClimb = 133027857649178,
		R6_BenchRide = 120866363198872,
		R6_Walk = 91898011300853,
		R6_Idle = 118471395839503,
		R6_ParadeRest = 111992430982248,
		R6_Talk = 130874079521116,
		R6_Point = 113054515865247,
		R6_Marshal = 88770557035712,
		R6_Clipboard = 132964896202473,
		R6_Weld = 93540224594418,
		R6_OverheadWeld = 125509286632915,
		R6_ChairSit = 122432536549778,
		R6_Sip = 92706723816650,
		R6_Laugh = 110296135082550,
		R6_BoothLean = 71712814365032,
		R6_Wave = 91154070477154,
	},
]] .. s:sub(i)
	end
end

---------------------------------------------------------------- Avatars: the players' display copies are R6 like the players
local av = game.ServerScriptService.ConvoyServer.Avatars
rep(av, "Players:CreateHumanoidModelFromDescription(desc, Enum.HumanoidRigType.R15)", "Players:CreateHumanoidModelFromDescription(desc, Enum.HumanoidRigType.R6)")

---------------------------------------------------------------- GunshipClient: the AC-130 gunner and the rescue survivors
local gc = SPS.GunshipClient
rep(gc, 'local AnimClips = require(Shared:WaitForChild("AnimClips")) -- sit-down / bench clips built from pose data',
	'local AnimClips = require(Shared:WaitForChild("AnimClips")) -- (old R15 clips)\nlocal R6Clips = require(Shared:WaitForChild("R6Clips")) -- the people: walk, sit down, the bench')
rep(gc, [[	cabinGunner = { model = m, root = m.HumanoidRootPart, h = m:GetAttribute("RootHeight") or 3, walk = load(913402848), sit = nil, idle = load(507766388) }
	local okSit, sitTr = pcall(function()
		return animator:LoadAnimation(AnimClips.chair())
	end)
	cabinGunner.sit = if okSit then sitTr else load(2506281703)
]], [[	cabinGunner = {
		model = m, root = m.HumanoidRootPart, h = m:GetAttribute("RootHeight") or 3,
		walk = R6Clips.load(animator, "R6_Walk"), sit = R6Clips.load(animator, "R6_GunnerSeat"), idle = R6Clips.load(animator, "R6_Idle"),
	}
]])
rep(gc, "seat.Position + Vector3.new(0, seat.Size.Y / 2 + 1.25, 0)", "seat.Position + Vector3.new(0, seat.Size.Y / 2 + 1, 0)")
rep(gc, "local SPEED = 6 -- studs/s; the R15 walk cycle is built for 6.4", "local SPEED = 6 -- studs/s")
rep(gc, 'gunnerPose(g, "walk", SPEED / 6.4)', 'gunnerPose(g, "walk", SPEED / R6Clips.WALK_STRIDE)')
rep(gc, "			local front = Vector3.new(sp.X - 1.5, O.Y + g.h, sp.Z)\n",
	"			local front = (seat * CFrame.Angles(0, math.pi, 0) * CFrame.new(R6Clips.GUNNER_START)).Position -- where the sit-down clip starts\n")
rep(gc, [[					local okA, tr = pcall(function()
						return g.animator:LoadAnimation(AnimClips.sitDown(seated:PointToObjectSpace(front)))
					end)]], [[					local okA, tr = pcall(R6Clips.load, g.animator, "R6_GunnerSitDown", false)]])
-- rescue: seats from the benches themselves, standing spots where the climb-on clip starts
rep(gc, [[	local SEATS = {
		-- seat = where the root ends up once the climb-on animation has finished (it sinks 0.86 and slides 0.6 back)
		{ seat = Vector3.new(-3.55, 3.73, -2.0), stand = Vector3.new(-4.6, 0, -2.0) },
		{ seat = Vector3.new(-3.55, 3.73, 0.3), stand = Vector3.new(-4.6, 0, 0.3) },
		{ seat = Vector3.new(3.55, 3.73, -0.8), stand = Vector3.new(4.6, 0, -0.8), via = Vector3.new(0, 0, -8.5) },
	}
]], [[	-- where each one sits (the root on the bench, in the landed helicopter's ground space), from the benches themselves
	local benchAt = {}
	for _, d in ipairs(heli:GetDescendants()) do
		if d.Name == "Bench" and d:IsA("BasePart") then
			local l = root.CFrame:PointToObjectSpace(d.Position) + Vector3.new(0, ROOT_UP, 0)
			benchAt[if l.X < 0 then -1 else 1] = { l = l, size = d.Size }
		end
	end
	local function seatOn(sx: number, z: number): Vector3
		local b = benchAt[sx]
		if not b then
			return Vector3.new(3.3 * sx, 3.1, z)
		end
		return Vector3.new(b.l.X + sx * (b.size.X / 2 - 0.35), b.l.Y + b.size.Y / 2 + 1, z)
	end
	local SEATS = {
		{ seat = seatOn(-1, -2.0) },
		{ seat = seatOn(-1, 0.3) },
		{ seat = seatOn(1, -0.8), via = Vector3.new(0, 0, -8.5) },
	}
	for _, s in ipairs(SEATS) do -- they stop right where the climb-on clip starts: back to the bench, just in front of it
		local out = if s.seat.X < 0 then math.pi / 2 else -math.pi / 2
		local stand = CFrame.new(s.seat) * CFrame.Angles(0, out, 0) * CFrame.new(R6Clips.BENCH_START)
		s.stand = Vector3.new(stand.X, 0, stand.Z)
	end
]])
rep(gc, 'local ct = Models:FindFirstChild("Civilian" .. i)', 'local ct = Models:FindFirstChild("R6Survivor" .. i)')
rep(gc, [[				run = load(913376220), sit = (function()
					local ok, tr = pcall(function()
						return animator:LoadAnimation(AnimClips.bench())
					end)
					return if ok then tr else load(2506281703)
				end)(), idle = load(507766388), board = nil, animator = animator,]],
	[[				run = R6Clips.load(animator, "R6_Run"), sit = R6Clips.load(animator, "R6_BenchRide"), idle = R6Clips.load(animator, "R6_Idle"),
				board = nil, animator = animator,]])
rep(gc, "				if name == pose then tr:Play(fade) else tr:Stop(fade) end",
	"				if name == pose then tr:Play(fade, 1, if name == \"run\" then RUN / R6Clips.RUN_STRIDE else 1) else tr:Stop(fade) end")
rep(gc, [[					local stand = c.pts[#c.pts] + Vector3.new(0, c.h, 0)
					local ok, tr = pcall(function()
						return c.animator:LoadAnimation(AnimClips.benchClimb(seatWorld:PointToObjectSpace(stand)))
					end)]], [[					local ok, tr = pcall(R6Clips.load, c.animator, "R6_BenchClimb", false)]])

---------------------------------------------------------------- PadHelis: run, jump and hang are clips now
local ph = SPS.PadHelis
rep(ph, 'local TweenService = game:GetService("TweenService")\n',
	'local TweenService = game:GetService("TweenService")\nlocal R6Clips = require(game:GetService("ReplicatedStorage"):WaitForChild("Convoy"):WaitForChild("R6Clips"))\n')
do
	local s = src(ph)
	local a = s:find("-- The grab animation is done on the joints themselves", 1, true)
	local b = s:find("local function dropRider(p: Player)", 1, true)
	assert(a and b and a < b, "PadHelis: animate block")
	pending[ph] = s:sub(1, a - 1) .. [[-- The run, the jump and the hang are R6 clips (Convoy.R6Clips), scrubbed by hand so everyone on the pad stays in
-- step with the flight; their own Animate script is off for the ride.
local RUN, JUMP = 0.85, 0.75
local HAND = CFrame.new(1.6, -1.78, 0) -- the root from the left hand on the skid (R6, arm straight up)
local function animate(r, u: number, _swing: number)
	local tracks = r.tracks
	if not tracks then
		return
	end
	local name, t
	if u < RUN then
		name, t = "run", u * 1.4
	elseif u < RUN + JUMP then
		name, t = "jump", (u - RUN) / JUMP * 0.75
	else
		name, t = "hang", u - RUN - JUMP
	end
	local track = tracks[name]
	if not track then
		return
	end
	if r.playing ~= track then
		for _, x in pairs(tracks) do
			if x ~= track then
				x:Stop(0.08)
			end
		end
		track:Play(0.08, 1, 0)
		r.playing = track
	end
	if track.Length > 0 then
		track.TimePosition = if track.Looped then t % track.Length else math.min(t, track.Length - 0.01)
	end
end
]] .. s:sub(b)
end
rep(ph, [[		for j, c0 in pairs(r.arms) do
			if j.Parent then
				j.C0 = c0
			end
		end
]], [[		for j, c0 in pairs(r.arms) do
			if j.Parent then
				j.C0 = c0
			end
		end
		for _, tr in pairs(r.tracks or {}) do
			tr:Stop(0.2)
		end
]])
rep(ph, "				r.joints = rigJoints(p.Character, r.arms)\n", "")
rep(ph, "			local lean = math.atan2(-1.5, reach)\n", "			local lean = 0 -- (the clip holds the body beside the arm)\n")
rep(ph, "CFrame.Angles(swing, 0, lean + sway) * CFrame.new(1.5, -reach, 0)", "CFrame.Angles(swing, 0, lean + sway) * HAND")
rep(ph, [[				if k < 0.35 then -- wind-up: sink and lean in
					local c = ease(k / 0.35)
					want = from * CFrame.new(0, -0.45 * c, 0) * CFrame.Angles(math.rad(-14) * c, 0, 0)
				else -- launch: fast off the ground, slowing into the catch
					local j = (k - 0.35) / 0.65
					local e = 1 - (1 - j) * (1 - j)
					local low = from * CFrame.new(0, -0.45, 0) * CFrame.Angles(math.rad(-14), 0, 0)
					want = low:Lerp(hang, e) + Vector3.new(0, math.sin(j * math.pi) * 0.9, 0)
				end]], [[				if k < 0.35 then -- wind-up: the clip crouches
					want = from
				else -- launch: fast off the ground, slowing into the catch
					local j = (k - 0.35) / 0.65
					local e = 1 - (1 - j) * (1 - j)
					want = from:Lerp(hang, e) + Vector3.new(0, math.sin(j * math.pi) * 0.9, 0)
				end]])
rep(ph, [[			if not (r.joints.R and r.joints.R:IsDescendantOf(p.Character)) then
				r.joints = rigJoints(p.Character, r.arms) -- (the avatar was rebuilt: new joints)
			end
]], [[			local an = hum and hum:FindFirstChildOfClass("Animator")
			if an and r.animator ~= an then -- (first frame, or the avatar was rebuilt)
				r.animator = an
				r.playing = nil
				r.tracks = { run = R6Clips.load(an, "R6_Run", true), jump = R6Clips.load(an, "R6_HeliJump", false), hang = R6Clips.load(an, "R6_HeliHang", true) }
				r.own = {}
				for _, t in pairs(r.tracks) do
					r.own[t] = true
				end
			end
]])
rep(ph, [[				for _, tr in ipairs(animator:GetPlayingAnimationTracks()) do
					tr:Stop(0.1)
				end]], [[				for _, tr in ipairs(animator:GetPlayingAnimationTracks()) do
					if not (r.own and r.own[tr]) then
						tr:Stop(0.1)
					end
				end]])

---------------------------------------------------------------- HangarLife: crew, staff, welders, coffee table
local hl = SPS.HangarLife
rep(hl, [[-- R6 (the game is R6 now): Roblox's classic walk, idle and point
local WALK, IDLE, POINT = anim(180426354), anim(180435571), anim(128853357)
local WALK_SPEED = 14.5 -- the classic walk cycle is timed for this speed]], [[-- R6 clips (Convoy.R6Clips)
local R6Clips = require(game:GetService("ReplicatedStorage"):WaitForChild("Convoy"):WaitForChild("R6Clips"))
local WALK, IDLE, POINT = R6Clips.animation("R6_Walk"), R6Clips.animation("R6_Idle"), R6Clips.animation("R6_Point")
local MARSHAL, CLIPBOARD = R6Clips.animation("R6_Marshal"), R6Clips.animation("R6_Clipboard")
local WALK_SPEED = R6Clips.WALK_STRIDE]])
rep(hl, "			return { walk = animator:LoadAnimation(WALK), idle = animator:LoadAnimation(IDLE), point = animator:LoadAnimation(POINT) }",
	"			return {\n				walk = animator:LoadAnimation(WALK), idle = animator:LoadAnimation(IDLE), point = animator:LoadAnimation(POINT),\n				marshal = animator:LoadAnimation(MARSHAL), clip = animator:LoadAnimation(CLIPBOARD),\n			}")
rep(hl, [[				c.tracks.point:Stop(0.2)
				c.tracks.idle:Stop(0.2)
				c.tracks.walk:Play(0.2, 1, c.speed / WALK_SPEED * 1.6)]], [[				c.tracks.point:Stop(0.2)
				c.tracks.idle:Stop(0.2)
				c.tracks.marshal:Stop(0.2)
				c.tracks.clip:Stop(0.2)
				c.tracks.walk:Play(0.2, 1, c.speed / WALK_SPEED)]])
rep(hl, [[				if math.random() < 0.5 then
					c.tracks.point:Play(0.3) -- signalling / checking something on the aircraft
				end]], [[				local r = math.random()
				if r < 0.35 then
					c.tracks.point:Play(0.3) -- signalling / checking something on the aircraft
				elseif r < 0.55 then
					c.tracks.marshal:Play(0.3) -- waving the gunship in
				elseif r < 0.8 then
					c.tracks.idle:Stop(0.3)
					c.tracks.clip:Play(0.3) -- going down the checklist
				end]])
rep(hl, [[			return { idle = animator:LoadAnimation(IDLE), point = animator:LoadAnimation(POINT) }]],
	[[			-- pilots talk it over or go down their checklist; the crew chief stands and points things out
			local base = if m.Name == "Pilot" then R6Clips.animation("R6_Talk") elseif m.Name == "Pilot2" then CLIPBOARD else IDLE
			return { idle = animator:LoadAnimation(base), point = animator:LoadAnimation(POINT) }]])
rep(hl, [[	local animator = hum and hum:FindFirstChildOfClass("Animator")
	local torch]], [[	local animator = hum and (hum:FindFirstChildOfClass("Animator") or Instance.new("Animator", hum))
	local torch]])
rep(hl, [[		-- R6: the arms are posed directly on the shoulder joints (stepWelders), no clips
		local ok, weldTr = false, nil
		local okI, idleTr = false, nil
		local pose = {
			rs = torso:FindFirstChild("Right Shoulder"), ls = torso:FindFirstChild("Left Shoulder"), neck = torso:FindFirstChild("Neck"),
			armR = 0, armL = 0, head = 0,
			upR = if overhead then 165 else 82, upL = if overhead then 130 else 55, upHead = if overhead then 30 else -8,
		}]], [[		-- R6 clips: the torch up to the work while welding, an idle between bursts
		local weldTr = R6Clips.load(animator, if overhead then "R6_OverheadWeld" else "R6_Weld", true)
		local idleTr = R6Clips.load(animator, "R6_Idle", true)
		local ok, okI = weldTr ~= nil, idleTr ~= nil
		if idleTr then
			idleTr:Play()
		end
		local pose = nil]])
rep(hl, [[				if w.on then
					w.weld:Play(0.3)]], [[				if w.on and not w.model:GetAttribute("StandDown") then
					w.weld:Play(0.3)]])
rep(hl, [[RunService.Heartbeat:Connect(function(dt)
	if player:GetAttribute("Screen") == "HUD" then]], [[---------------------------------------------------------------- the coffee table: sat with a mug, a sip now and then, a laugh
local seated = {}
local coffee = hangar:FindFirstChild("CoffeeTable")
for i = 1, 3 do
	local m = coffee and coffee:FindFirstChild("Seated" .. i)
	local hum = m and m:FindFirstChildWhichIsA("Humanoid")
	local an = hum and (hum:FindFirstChildOfClass("Animator") or Instance.new("Animator", hum))
	if an then
		R6Clips.standardJoints(m) -- (they were built with the hips bent in C0; the sitting clip bends them now)
		local sit = R6Clips.load(an, "R6_ChairSit", true)
		if sit then
			sit:Play(0, 1, 0.85 + math.random() * 0.3)
		end
		table.insert(seated, { sip = R6Clips.load(an, "R6_Sip", false), laugh = R6Clips.load(an, "R6_Laugh", false), t = 3 + math.random() * 8 })
	end
end
local function stepSeated(dt: number)
	for _, s in ipairs(seated) do
		s.t -= dt
		if s.t <= 0 then
			s.t = 7 + math.random() * 10
			local tr = if math.random() < 0.7 then s.sip else s.laugh
			if tr then
				tr:Play(0.25)
			end
		end
	end
end
_G.CoffeeLaugh = function() -- (NPCChatter: the table laughs when a story lands)
	for _, s in ipairs(seated) do
		if s.laugh and math.random() < 0.75 then
			task.delay(math.random() * 0.4, function()
				s.laugh:Play(0.2)
			end)
		end
	end
end

RunService.Heartbeat:Connect(function(dt)
	if player:GetAttribute("Screen") == "HUD" then]])
rep(hl, "	stepWelders(dt)\nend)", "	stepWelders(dt)\n	stepSeated(dt)\nend)")

---------------------------------------------------------------- NPCChatter: a laugh round the table after a story
local nc = SPS.NPCChatter
rep(nc, [[					say(who, line[2], secs)
					task.wait(secs + 0.3)
				end
			end
]], [[					say(who, line[2], secs)
					task.wait(secs + 0.3)
				end
			end
			if _G.CoffeeLaugh then
				_G.CoffeeLaugh()
			end
]])

---------------------------------------------------------------- HangarWalkers: walk, idle, talk to you, the General at parade rest
local hw = SPS.HangarWalkers
rep(hw, [[local WALK = Instance.new("Animation")
WALK.AnimationId = "rbxassetid://180426354"
local IDLE = Instance.new("Animation")
IDLE.AnimationId = "rbxassetid://180435571"
]], [[local R6Clips = require(Shared:WaitForChild("R6Clips"))
local WALK = R6Clips.animation("R6_Walk")
local IDLE = R6Clips.animation("R6_Idle")
local TALK = R6Clips.animation("R6_Talk")
local REST = R6Clips.animation("R6_ParadeRest") -- (the General)
]])
rep(hw, [[				w.idle = an:LoadAnimation(IDLE)
				w.idle.Looped = true]], [[				w.idle = an:LoadAnimation(if m.Name == "General" then REST else IDLE)
				w.idle.Looped = true
				w.talk = an:LoadAnimation(TALK)
				w.talk.Looped = true]])
rep(hw, "			w.walk:AdjustSpeed(spd / SPEED)", "			w.walk:AdjustSpeed(spd / R6Clips.WALK_STRIDE)")
rep(hw, [[				if moving then
					w.idle:Stop(0.2)
					w.walk:Play(0.2)
				else
					w.walk:Stop(0.2)
					w.idle:Play(0.2)
				end]], [[				if moving then
					w.idle:Stop(0.2)
					w.talk:Stop(0.2)
					w.walk:Play(0.2, 1, spd / R6Clips.WALK_STRIDE)
				else
					w.walk:Stop(0.2)
					-- stopped to talk to you: hands going (the General stays at parade rest)
					local talking = w.face ~= nil and w.stop > 0 and w.m.Name ~= "General"
					local tr = if talking then w.talk else w.idle
					tr:Play(0.2)
				end]])

---------------------------------------------------------------- Booths: the clerks lean on the counter and wave you over
local bo = SPS.Booths
rep(bo, [[local IDLE = Instance.new("Animation")
IDLE.AnimationId = "rbxassetid://180435571" -- R6 idle]], [[local R6Clips = require(game:GetService("ReplicatedStorage"):WaitForChild("Convoy"):WaitForChild("R6Clips"))
local IDLE = R6Clips.animation("R6_BoothLean") -- leaning on the counter
local WAVE = R6Clips.animation("R6_Wave")]])
rep(bo, [[	if animator then
		pcall(function()
			local tr = animator:LoadAnimation(IDLE)
			tr.Looped = true
			tr:Play()
		end)
	end]], [[	local wave
	if animator then
		pcall(function()
			local tr = animator:LoadAnimation(IDLE)
			tr.Looped = true
			tr:Play()
			wave = animator:LoadAnimation(WAVE)
		end)
	end]])
rep(bo, "		text = text, step = 0, neck = neck,", "		text = text, step = 0, wave = wave, waved = -99, neck = neck,")
rep(bo, [[	for _, b in ipairs(booths) do
		-- sign scrolls left and wraps (the text is the title repeated)]], [[	for _, b in ipairs(booths) do
		-- a wave when you walk up (not every time)
		local nroot = b.npc and b.npc:FindFirstChild("HumanoidRootPart")
		if b.wave and root and nroot then
			local near = (root.Position - nroot.Position).Magnitude < 18
			if near and not b.near and now - b.waved > 20 then
				b.waved = now
				b.wave:Play(0.2)
			end
			b.near = near
		end
		-- sign scrolls left and wraps (the text is the title repeated)]])

---------------------------------------------------------------- write
for scr, s in pairs(pending) do
	scr.Source = s
	table.insert(log, "patched " .. scr:GetFullName())
end
return table.concat(log, "\n")
