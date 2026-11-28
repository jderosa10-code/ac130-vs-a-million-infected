-- 0.19.41: the RANK GOALS panel (PC / console) is hidden until a goal moves on: then it shows for 4 seconds, and
-- not again for 6 seconds after that (a goal done always shows). A goal moves on every twentieth of the way (each
-- kill for goals up to 20, every 13 kills for 250). Not when the goals first load or change after a promotion. Patches StarterPlayerScripts.RankGoalsHUD
-- (0.19.40). Run in a place (execute_luau, Edit). Idempotent.
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

patch(game.StarterPlayer.StarterPlayerScripts.RankGoalsHUD, {
	{ "local TXT = Color3.fromRGB(236, 232, 214)\n", [[local TXT = Color3.fromRGB(236, 232, 214)
-- (0.19.41) hidden until a goal moves on, then shown for POP_TIME seconds, and not again until POP_GAP seconds
-- after that (a goal done always shows): each goal's last step seen (a twentieth of the way, so every kill of a
-- small goal)
local POP_TIME, POP_GAP = 4, 6
local lastStep, popUntil, nextPop = {}, 0, 0
]] },
	{ "\t\t\t\tlocal p = math.clamp(tonumber(o.p) or 0, 0, n)\n", [[				local p = math.clamp(tonumber(o.p) or 0, 0, n)
				local step = if o.done then math.huge else p // math.max(1, math.ceil(n / 20))
				local mark = tostring(o.k) .. "|" .. tostring(o.g) .. "|" .. n
				local seen = lastStep[i]
				if seen and seen.mark == mark and step > seen.step and (o.done or os.clock() >= nextPop) then
					popUntil = os.clock() + POP_TIME -- (moved on: show the panel)
					nextPop = popUntil + POP_GAP
				end
				lastStep[i] = { mark = mark, step = step }
]] },
	{ "-- not on touch screens, not in the tutorial (it doesn't count toward them), only with objectives to show\nlocal function vis()\n\tlocal want = player:GetAttribute(\"RankObj\") ~= nil and not Aim.touch() and not Shared:GetAttribute(\"Tutorial\")\n\tif panel.Visible ~= want then\n\t\tpanel.Visible = want\n\tend\nend\n",
		[[-- only for a few seconds after a goal moves on; not on touch screens, not in the tutorial (it doesn't count)
local function vis()
	local left = popUntil - os.clock()
	local want = left > 0 and player:GetAttribute("RankObj") ~= nil and not Aim.touch() and not Shared:GetAttribute("Tutorial")
	if panel.Visible ~= want then
		panel.Visible = want
	end
	if left > 0 then
		task.delay(left + 0.05, vis)
	end
end
]] },
})
return table.concat(log, ", ")
