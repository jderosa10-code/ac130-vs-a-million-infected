-- 0.19.31: crewmates' guns are faint. Every crew's shots go out tagged "gunship" and each client played every
-- "gunship" shot as its own gun (in your head, full volume). Now the server adds who fired (UserId) to the "shot"
-- FX, and a crewmate's shot plays from their aircraft at TEAMMATE gain (x0.3 on top of the ground mix), no tails.
-- Run in a place (execute_luau, Edit) on top of 0.19.30. Idempotent.
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

patch(game.ServerScriptService.ConvoyServer.Ballistics, {
	{ "\t\tFXU:FireAllClients(\"shot\", a.origin, dir, a.kind, a.shooter, look)\n",
		"\t\t-- (0.19.31) + who fired (UserId): the crew's other players hear it faint (ConvoyAudio)\n\t\tlocal by = (a :: any).owner\n\t\tFXU:FireAllClients(\"shot\", a.origin, dir, a.kind, a.shooter, look, if typeof(by) == \"Instance\" and by:IsA(\"Player\") then by.UserId else nil)\n" },
})

patch(game.StarterPlayer.StarterPlayerScripts.ConvoyAudio, {
	{ "local GUNSHIP_GROUND_GAIN = 0.8 -- ground sounds heard from the AC-130 (arcade mix: you should hear your hits)\n",
		"local GUNSHIP_GROUND_GAIN = 0.8 -- ground sounds heard from the AC-130 (arcade mix: you should hear your hits)\n-- (0.19.31) crewmates' guns: faint (gain), played from their aircraft; `now` is set while one of their shots plays\nlocal MATE = { gain = 0.3, now = 1 }\n" },
	{ "\tlocal dist = 0\n\tlocal vol = p.vol or 1\n", "\tlocal dist = 0\n\tlocal vol = (p.vol or 1) * MATE.now\n" },
	{ "local function onShot(origin: Vector3, _dir: Vector3?, kind: string, tag, look)\n", "local function playShot(origin: Vector3, _dir: Vector3?, kind: string, tag, look)\n" },
	{ "\t\tlocal function sub()\n\t\t\temit(\"GAU12_Shot\", pos, { prio = 1, own = own, vol = vol * 0.85, pitch = 1.05 + math.random() * 0.05, maxLen = 0.45 })\n\t\tend\n",
		"\t\tlocal gain = MATE.now -- (a crewmate's: still faint when it plays a moment later)\n\t\tlocal function sub()\n\t\t\tMATE.now = gain\n\t\t\temit(\"GAU12_Shot\", pos, { prio = 1, own = own, vol = vol * 0.85, pitch = 1.05 + math.random() * 0.05, maxLen = 0.45 })\n\t\t\tMATE.now = 1\n\t\tend\n" },
	{ "\t}\nend\n\n-- burst tails:", [[	}
end
-- (0.19.31) every crew's shots are tagged "gunship": the server adds who fired. Yours play as your own gun; a
-- crewmate's play from their aircraft, faint, without echo / brass tails.
local function onShot(origin: Vector3, dir: Vector3?, kind: string, tag, look, shooterId)
	if inGunship and tag == "gunship" and type(shooterId) == "number" and shooterId ~= player.UserId then
		local key = "gunship:" .. shooterId
		MATE.now = MATE.gain
		local ok, err = pcall(playShot, origin, dir, kind, key, look)
		MATE.now = 1
		local rec = lastShotBy[key]
		if rec then
			rec.tailed = true
		end
		if not ok then
			error(err, 0)
		end
		return
	end
	playShot(origin, dir, kind, tag, look)
end

-- burst tails:]] },
})
return table.concat(log, ", ")
