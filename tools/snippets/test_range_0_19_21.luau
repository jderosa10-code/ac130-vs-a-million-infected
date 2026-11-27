-- 0.19.21: TEST FLIGHT flies over the TEST RANGE (Workspace.TestRange, built by tools/test_range.luau) instead of the
-- city. Mission's test run gets its own loop; GunshipUI hides the BUNKER box on a test flight. Idempotent.
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
		assert(not src:find(p[1], b + 1, true), "anchor twice in " .. scr.Name)
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

patch(game.ServerScriptService.ConvoyServer.Mission, {
	{ [[			p:SetAttribute("Plane", def.id)
		end
		startRun({ p }, "Normal")
		if role() == "Studio" then]], [[			p:SetAttribute("Plane", def.id)
		end
		local range = workspace:FindFirstChild("TestRange")
		local rc = range and range:GetAttribute("Center")
		if rc then
			-- the TEST RANGE (0.19.21; Workspace.TestRange, tools/test_range.luau): no bunker, no waves, no civilians.
			-- Infected walk down the lanes and are topped up as they're shot or reach the firing line; unlimited ammo
			-- and $20,000 to try the tiers and abilities. Until EXIT ("ExitTest") or the pilot leaves.
			busy = true
			local ok, err = pcall(function()
				local lanes = range:GetAttribute("Lanes") or 5
				local lw = range:GetAttribute("LaneWidth") or 80
				local z0, z1 = range:GetAttribute("StartZ") or -300, range:GetAttribute("EndZ") or 250
				clearCrew()
				pilot = p
				hardcore = false
				joinCrew(p)
				for g in pairs(Upgrades.UNLOCK) do
					crew[p].tiers[g] = 1
				end
				for _, g in ipairs(Upgrades.GUNS) do
					applyGun(p, g, true)
				end
				publishCrew()
				crew[p].cash = 20000
				p:SetAttribute("Cash", 20000)
				p:SetAttribute("UnlimitedAmmo", true)
				-- the "bunker" (artillery's reach, abilities) goes behind the firing line, where nothing walks
				BUNKER = rc + Vector3.new(0, 0, z1 + 80)
				setAttr("OrbitCenter", rc)
				maxBunker, bunkerHP = Upgrades.BUNKER_HP, Upgrades.BUNKER_HP
				failReason, boss = nil, nil
				wave, elapsed = 4, 0
				for k, v in pairs({ Mode = "Normal", Phase = "Wave", Wave = 1, BunkerHP = bunkerHP, BunkerMax = maxBunker, Kills = 0, BossHP = 0, BossMax = 0, Result = "", SecondChanceLeft = 0 }) do
					setAttr(k, v)
				end
				Enemies.clear()
				Ballistics.clear()
				running = true
				setAttr("State", "Running")
				local acc = { step = 0, attr = 0, toSpawn = 0 }
				local spawnT = 0
				while not failReason and p.Parent and lead() ~= nil do
					local dt = RunService.Heartbeat:Wait()
					spawnT -= dt
					if spawnT <= 0 and zombiesAlive() < 28 then
						spawnT = 0.3
						local x = (math.random(1, lanes) - (lanes + 1) / 2) * lw + (math.random() - 0.5) * lw * 0.6
						local e = spawnActor(rc + Vector3.new(x, 0, z0 + math.random() * 40), false, 6 + math.random() * 5)
						if e then
							e.wp = { rc + Vector3.new(x + (math.random() - 0.5) * 12, 0, z1 + 20) }
							e.wi = 1
							if math.random() < 0.25 then
								local s = 1.15 + math.random() * 0.45
								e.model:ScaleTo(s)
								e.rootY *= s
								e.scale = s
							end
						end
					end
					for _, e in ipairs(table.clone(Enemies.list)) do
						if e.alive and not e.civ and e.pos and e.pos.Z - rc.Z > z1 - 10 then
							Enemies.kill(e) -- reached the firing line: gone (a fresh one starts at the far end)
						end
					end
					tickWorld(dt, acc)
				end
			end)
			if not ok then
				warn("[Gunship] test range error:", err)
			end
			running = false
			BUNKER = HOME
			setAttr("OrbitCenter", HOME)
			p:SetAttribute("UnlimitedAmmo", nil)
			clearCrew()
			setAttr("State", "Menu")
			task.wait(0.5)
			Enemies.clear()
			Ballistics.clear()
			boss, pilot = nil, nil
			busy = false
		else
			startRun({ p }, "Normal")
		end
		if role() == "Studio" then]] },
})

patch(game.StarterPlayer.StarterPlayerScripts.GunshipUI, {
	{ [[		local p, on = worldToGui(center + Vector3.new(0, 30, 0))
		HUD.BunkerMarker.Position = p
		HUD.BunkerMarker.Visible = on
	end]], [[		local p, on = worldToGui(center + Vector3.new(0, 30, 0))
		HUD.BunkerMarker.Position = p
		HUD.BunkerMarker.Visible = on and not Shared:GetAttribute("TestFlight") -- (the TEST RANGE has no bunker)
	end]] },
})
-- TestFlightUI: on the range the HUD says TEST RANGE; no NEXT BOSS strip, no bunker bar (back as soon as it's over)
do
	local scr = game.StarterPlayer.StarterPlayerScripts.TestFlightUI
	local marker = "-- on the TEST RANGE (0.19.21)"
	if not scr.Source:find(marker, 1, true) then
		local add = "\n" .. marker .. [[ the HUD says so: TEST RANGE instead of the wave, no NEXT BOSS strip, no bunker bar
local HUD = gui:WaitForChild("HUD")
local hidden = false
game:GetService("RunService").RenderStepped:Connect(function()
	local on = Shared:GetAttribute("TestFlight") == true and Shared:GetAttribute("State") == "Running"
	local top = HUD:FindFirstChild("Top")
	local bunkerBar = HUD:FindFirstChild("Bottom") and HUD.Bottom:FindFirstChild("Bunker")
	if on then
		local wave = top and top:FindFirstChild("Wave")
		local value = wave and wave:FindFirstChild("Value", true)
		if value then
			value.Text = "TEST RANGE"
		end
		if top and top:FindFirstChild("Boss") then
			top.Boss.Visible = false
		end
		if bunkerBar then
			bunkerBar.Visible = false
		end
		hidden = true
	elseif hidden then
		hidden = false
		if bunkerBar then
			bunkerBar.Visible = true
		end
	end
end)
]]
		local src = scr.Source .. add
		SES:UpdateSourceAsync(scr, function()
			return src
		end)
		table.insert(log, "TestFlightUI patched")
	end
end
return table.concat(log, ", ")
