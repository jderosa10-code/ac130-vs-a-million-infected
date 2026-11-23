-- 0.14.13: the infected walk and hit the bunker with our own clips (tools/InfectedAnims.luau, uploaded to the group)
local pending, log = {}, {}
local function src(scr)
	pending[scr] = pending[scr] or scr.Source
	return pending[scr]
end
local function rep(scr, a, b)
	local s = src(scr)
	local i, j = s:find(a, 1, true)
	assert(i, scr.Name .. ": no match for: " .. a:sub(1, 70))
	assert(not s:find(a, j + 1, true), scr.Name .. ": two matches for: " .. a:sub(1, 70))
	pending[scr] = s:sub(1, i - 1) .. b .. s:sub(j + 1)
end
local en = game.ServerScriptService.ConvoyServer.Enemies
local mi = game.ServerScriptService.ConvoyServer.Mission

rep(en, [[local runAnim = Instance.new("Animation")
runAnim.AnimationId = "rbxassetid://616163682" -- Roblox Zombie pack run
]], [[local runAnim = Instance.new("Animation")
runAnim.AnimationId = "rbxassetid://616163682" -- Roblox Zombie pack run (now only a fallback)

-- our own walks (tools/InfectedAnims.luau, uploaded to the group): each infected gets one, at the speed it suits
-- (mul) and played at the rate its feet cover the ground (stride: studs per second at speed 1)
local function animOf(id: number): Animation
	local a = Instance.new("Animation")
	a.AnimationId = "rbxassetid://" .. id
	return a
end
Enemies.WALKS = {
	{ name = "Sprint", anim = animOf(101514201659049), stride = 16, mul = 1.1, weight = 55 },
	{ name = "ArmsOut", anim = animOf(88926158573711), stride = 9, mul = 0.75, weight = 20 },
	{ name = "Shamble", anim = animOf(94841122648359), stride = 7, mul = 0.6, weight = 15 },
	{ name = "Lurch", anim = animOf(125108745066690), stride = 7, mul = 0.6, weight = 10 },
}
-- at the bunker wall: pound, claw, ram (looped while they're on it)
Enemies.HITS = { animOf(139966885525473), animOf(92907026564792), animOf(105326268410805) }
local function pickWalk()
	if RS.Convoy:GetAttribute("Tutorial") then
		return Enemies.WALKS[1] -- (the tutorial's waves are timed for the usual pace)
	end
	local r = math.random() * 100
	for _, w in ipairs(Enemies.WALKS) do
		r -= w.weight
		if r <= 0 then
			return w
		end
	end
	return Enemies.WALKS[1]
end
]])
rep(en, [[	local m = (template or templates[math.random(1, #templates)]):Clone()
	local e = {]], [[	local m = (template or templates[math.random(1, #templates)]):Clone()
	local walk = if anim then nil else pickWalk()
	local e = {]])
rep(en, "		speed = Config.ENEMY_SPEED * (0.85 + math.random() * 0.3),\n		alive = true,\n		anim = anim or runAnim,\n",
	"		speed = Config.ENEMY_SPEED * (0.85 + math.random() * 0.3) * (if walk then walk.mul else 1),\n		alive = true,\n		anim = anim or (walk and walk.anim) or runAnim,\n		walkStride = walk and walk.stride,\n		walkMul = walk and walk.mul,\n")
rep(en, [[			return animator:LoadAnimation(anim or runAnim)
		end)
		if ok and track then
			track.Looped = true
			track:Play(0.1, 1, e.speed / 14)
			track.TimePosition = math.random() * 0.6
			e.track = track
			e.stride = 14 -- studs per second one play-through of the run covers at scale 1
			e.scale = 1
			e.rate = e.speed / 14]], [[			return animator:LoadAnimation(e.anim)
		end)
		if ok and track then
			local stride = e.walkStride or 14 -- studs per second one play-through of the walk covers at scale 1
			track.Looped = true
			track:Play(0.1, 1, e.speed / stride)
			track.TimePosition = math.random() * 0.6
			e.track = track
			e.stride = stride
			e.scale = 1
			e.rate = e.speed / stride]])
rep(en, "	e.stride = if r6 then 9 else 14\n", "	e.stride = if r6 then 9 else (e.walkStride or 14)\n")
rep(en, [[function Enemies.kill(e)]], [[-- reached the bunker wall: one of the hits, looped while it stays there (R15 infected; not bosses or R6 type rigs)
function Enemies.hitWall(e): boolean
	if e.hitTrack or e.boss or e.model:GetAttribute("Rig") == "R6" then
		return e.hitTrack ~= nil
	end
	local animator = e.model:FindFirstChildWhichIsA("Animator", true)
	if not animator then
		return false
	end
	local ok, tr = pcall(animator.LoadAnimation, animator, Enemies.HITS[math.random(1, #Enemies.HITS)])
	if not ok or not tr then
		return false
	end
	tr.Looped = true
	tr:Play(0.2, 1, 0.9 + math.random() * 0.25)
	tr.TimePosition = math.random() * 0.5
	e.hitTrack = tr
	if e.track then
		e.track:Stop(0.2)
	end
	return true
end

function Enemies.kill(e)]])
rep(mi, "	e.speed = speed * (0.9 + math.random() * 0.2)\n	e.wp = ",
	"	e.speed = speed * (0.9 + math.random() * 0.2) * (e.walkMul or 1) -- (each walk has its own pace)\n	e.wp = ")
rep(mi, [[						if e.track then
							e.track:AdjustSpeed(0.35) -- shuffling and clawing on the spot
						end]], [[						if not Enemies.hitWall(e) and e.track then -- pounds / claws / rams the wall
							e.track:AdjustSpeed(0.35) -- (no hit clip for this rig: shuffling and clawing on the spot)
						end]])
for scr, s in pairs(pending) do
	scr.Source = s
	table.insert(log, "patched " .. scr.Name)
end
return table.concat(log, "\n")
