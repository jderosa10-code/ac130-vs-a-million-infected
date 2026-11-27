-- 0.19.22: range shots from the aircraft, ground round the range, civilians kept clear of hordes, one free crate spin,
-- gem bar sizes. Run in a place (execute_luau, Edit) on top of 0.19.21. Idempotent.
local SES = game:GetService("ScriptEditorService")
local log = {}
local function patch(scr, list)
	local src = scr.Source
	local changed = false
	for _, p in ipairs(list) do
		if src:find(p[2], 1, true) then
			continue
		end
		local a, b = src:find(p[1], 1, true)
		assert(a, "anchor not found in " .. scr.Name .. ": " .. p[1]:sub(1, 80))
		assert(not src:find(p[1], b + 1, true), "anchor twice in " .. scr.Name .. ": " .. p[1]:sub(1, 80))
		src = src:sub(1, a - 1) .. p[2] .. src:sub(b + 1)
		changed = true
	end
	if changed then
		SES:UpdateSourceAsync(scr, function()
			return src
		end)
	end
	table.insert(log, scr.Name .. (if changed then " patched" else " ok"))
end
local CS = game.ServerScriptService.ConvoyServer
local SPS = game.StarterPlayer.StarterPlayerScripts

patch(CS.Mission, {
	-- the range: the aircraft orbits the "bunker" point, so it has to be the range's middle (shots left from 330 studs off)
	{ [[				-- the "bunker" (artillery's reach, abilities) goes behind the firing line, where nothing walks
				BUNKER = rc + Vector3.new(0, 0, z1 + 80)]], [[				-- the aircraft orbits the "bunker" point (Orbit.position, where shots leave from): the range's middle.
				-- Nothing arrives at it there (ARRIVE_RADIUS 0), so the lanes walk straight through.
				BUNKER = rc
				ARRIVE_RADIUS = 0]] },
	{ [[			running = false
			BUNKER = HOME
			setAttr("OrbitCenter", HOME)]], [[			running = false
			BUNKER = HOME
			ARRIVE_RADIUS = 18.5
			setAttr("OrbitCenter", HOME)]] },
	-- civilians: spawn only well clear of the infected (more tries, at least CIV_CLEAR studs), else wait
	{ [[local function spawnPointAwayFrom(civ: boolean): Vector3
	local best, bestD = spawnPoints[math.random(1, #spawnPoints)], -1
	for _ = 1, 8 do]], [[local function spawnPointAwayFrom(civ: boolean): Vector3?
	local best, bestD = spawnPoints[math.random(1, #spawnPoints)], -1
	for _ = 1, (if civ then 16 else 8) do]] },
	{ [[		if d > 140 then
			break
		end
	end
	return best
end]], [[		if d > 140 then
			break
		end
	end
	-- (0.19.22) civilians never start inside a horde: nowhere 120 studs clear of the infected means not yet
	if civ and bestD < 120 and not Shared:GetAttribute("Tutorial") then
		return nil
	end
	return best
end]] },
	{ "\tlocal p = if around then spawnPoints[math.random(1, #spawnPoints)] else spawnPointAwayFrom(civ)\n",
		"\tlocal p = if around then spawnPoints[math.random(1, #spawnPoints)] else spawnPointAwayFrom(civ)\n\tif not p then\n\t\treturn 0 -- civilians: nowhere clear of the infected right now (the wave tries again shortly)\n\tend\n" },
	-- a boss's escort doesn't spawn on top of civilians
	{ [[			at = around.pos + Vector3.new(math.cos(ringA), 0, math.sin(ringA)) * ringR
		end
		local e = spawnActor(at, civ, speed)]], [[			at = around.pos + Vector3.new(math.cos(ringA), 0, math.sin(ringA)) * ringR
			for _, o in ipairs(Enemies.list) do
				if o.alive and o.civ and o.pos and Vector3.new(o.pos.X - at.X, 0, o.pos.Z - at.Z).Magnitude < 25 then
					at = nil -- (0.19.22) a civilian there: this one stays out
					break
				end
			end
		end
		local e = if at then spawnActor(at, civ, speed) else nil]] },
	{ "\t\t\tif civGroups > 0 and civTimer <= 0 then\n\t\t\t\tcivGroups -= 1\n\t\t\t\tcivTimer = waveLen / (2 + wave // 3)\n\t\t\t\tspawnGroup(true, math.random(1, 3), CIV_SPEED)\n\t\t\tend",
		"\t\t\tif civGroups > 0 and civTimer <= 0 then\n\t\t\t\tif spawnGroup(true, math.random(1, 3), CIV_SPEED) > 0 then\n\t\t\t\t\tcivGroups -= 1\n\t\t\t\t\tcivTimer = waveLen / (2 + wave // 3)\n\t\t\t\telse\n\t\t\t\t\tcivTimer = 2 -- nowhere clear of the infected: try again in 2 s\n\t\t\t\tend\n\t\t\tend" },
	-- civilians back off from a horde that comes close (along the road they came by), then find a new way
	{ "\tlocal civs = {}\n\tfor _, e in ipairs(list) do\n\t\tif e.alive and e.civ then\n\t\t\ttable.insert(civs, e)\n\t\tend\n\tend",
		"\tlocal civs, zs = {}, {}\n\tfor _, e in ipairs(list) do\n\t\tif e.alive and e.civ then\n\t\t\ttable.insert(civs, e)\n\t\telseif e.alive then\n\t\t\ttable.insert(zs, e)\n\t\tend\n\tend" },
	{ "\t\tlocal target: Vector3 = (e.goal or e.wp[e.wi] or BUNKER) + e.off", [[		-- (0.19.22) civilians: infected within 45 studs and they back off along the road they came by for a moment,
		-- then take a fresh route (so they don't walk into the crowd you're shooting)
		if e.civ and not opMode and not Shared:GetAttribute("Tutorial") then
			if e.fleeUntil then
				if elapsed >= e.fleeUntil then
					e.fleeUntil, e.goal = nil, nil
					e.wp = route(e.pos)
					e.wi = 1
				end
			else
				for _, z in ipairs(zs) do
					if z.pos and Vector3.new(z.pos.X - e.pos.X, 0, z.pos.Z - e.pos.Z).Magnitude < 45 then
						local back = e.wp[e.wi - 1]
						if not back then
							local ahead = e.wp[e.wi] or BUNKER
							local d = Vector3.new(e.pos.X - ahead.X, 0, e.pos.Z - ahead.Z)
							back = e.pos + (if d.Magnitude > 0.1 then d.Unit else Vector3.zAxis) * 25
						end
						e.goal = Vector3.new(back.X, 0, back.Z)
						e.fleeUntil = elapsed + 2.5
						break
					end
				end
			end
		end
		local target: Vector3 = (e.goal or e.wp[e.wi] or BUNKER) + e.off]] },
})

-- the crate: one free spin per player, the rest are Robux
patch(game.ReplicatedStorage.Convoy.Shop, {
	{ "\tFREE_EVERY = 8 * 3600,\n", "\tFREE_EVERY = 8 * 3600, -- (unused since 0.19.22: one free spin per player, ConvoyServer.Crate CrateFreeUsed)\n" },
})
patch(CS.Crate, {
	{ [[	p:SetAttribute("CrateFreeAt", tonumber(c.f) or 0)
]], [[	p:SetAttribute("CrateFreeAt", tonumber(c.f) or 0)
	-- (0.19.22) one free spin per player, then Robux: anyone who already spun (the old 8-hour timer) has had theirs
	p:SetAttribute("CrateFreeUsed", c.u == true or (tonumber(c.f) or 0) > 0)
]] },
	{ [[	data.Crate = { s = p:GetAttribute("CrateSpins") or 0, f = p:GetAttribute("CrateFreeAt") or 0, p = p:GetAttribute("CratePending") }]],
		[[	data.Crate = { s = p:GetAttribute("CrateSpins") or 0, f = p:GetAttribute("CrateFreeAt") or 0, p = p:GetAttribute("CratePending"), u = p:GetAttribute("CrateFreeUsed") == true }]] },
	{ [[	local free = now >= (p:GetAttribute("CrateFreeAt") or 0)]], [[	local free = not p:GetAttribute("CrateFreeUsed") -- (0.19.22: one free spin, ever)]] },
	{ [[		p:SetAttribute("CrateFreeAt", now + Shop.CRATE.FREE_EVERY)]], [[		p:SetAttribute("CrateFreeUsed", true)]] },
})
patch(SPS.CrateUI, {
	{ [[	return math.max(0, a("CrateFreeAt", 0) - workspace:GetServerTimeNow())]], [[	return if a("CrateFreeUsed", false) then math.huge else 0 -- (0.19.22: one free spin per player)]] },
	{ [[	panel.Odds.Text = if free then "YOUR FREE SPIN IS READY. ODDS ARE ON EVERY CARD." else "NEXT FREE SPIN IN " .. hms(freeIn()) .. ". ODDS ARE ON EVERY CARD."]],
		[[	panel.Odds.Text = if free then "YOUR FREE SPIN IS READY. ODDS ARE ON EVERY CARD." else "MORE SPINS WITH ROBUX. ODDS ARE ON EVERY CARD."]] },
	{ [[for _, k in ipairs({ "CrateSpins", "CrateFreeAt" }) do]], [[for _, k in ipairs({ "CrateSpins", "CrateFreeAt", "CrateFreeUsed" }) do]] },
	{ [[		panel.Status.Text = if spins > 0 then string.format("SPINS: %d", spins) elseif free then "FREE SPIN READY" else "NO SPINS LEFT"]],
		[[		panel.Status.Text = if spins > 0 then string.format("SPINS: %d", spins) elseif free then "1 FREE SPIN" else "NO SPINS LEFT"]] },
})

-- the gem bar: phones a bit bigger again (1.35), the big gem image a bit smaller (48, was 60)
patch(SPS.GunshipUI, {
	{ "Side = 0.7, SideRight = 0.85, Top = 1.2 }", "Side = 0.7, SideRight = 0.85, Top = 1.35 }" },
})
local gem = game.StarterGui.GunshipUI_Template.Menu.Top.Gem
if gem.Size.X.Offset ~= 48 then
	gem.Size = UDim2.fromOffset(48, 48)
	table.insert(log, "gem image 48")
end
return table.concat(log, ", ")
