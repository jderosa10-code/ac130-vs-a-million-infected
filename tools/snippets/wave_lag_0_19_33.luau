-- 0.19.33: lag in big waves (client). Measured at wave 30 Hardcore, 150 infected: 33 FPS, client scripts 33% of a core.
-- * TargetBoxes / GunshipUI markers read gui.AbsolutePosition inside their loops, right after moving the previous
--   box: every read re-laid-out the whole HUD (0.66 s of every 5 s). Now read once per frame.
-- * EnemyMover set each rig's root CFrame one by one; now one workspace:BulkMoveTo per frame.
-- * BattleOffers rewrote the buy tiles' prices every frame (and RobuxGlyph rewrote them again): only on change.
-- Run in a place (execute_luau, Edit) on top of 0.19.31. Idempotent.
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
		if p.all then
			-- every copy of the anchor (plain find / replace)
			local out, i = {}, 1
			while true do
				local s, e = src:find(p[1], i, true)
				if not s then
					break
				end
				table.insert(out, src:sub(i, s - 1))
				table.insert(out, p[2])
				i = e + 1
			end
			table.insert(out, src:sub(i))
			src = table.concat(out)
		else
			assert(not src:find(p[1], b + 1, true), "anchor twice in " .. scr.Name .. ": " .. p[1]:sub(1, 80))
			src = src:sub(1, a - 1) .. p[2] .. src:sub(b + 1)
		end
		changed = true
	end
	if changed then
		SES:UpdateSourceAsync(scr, function()
			return src
		end)
	end
	table.insert(log, scr.Name .. (if changed then " patched" else " ok"))
end
local SPS = game.StarterPlayer.StarterPlayerScripts

patch(SPS.TargetBoxes, {
	{ "\t\t\t\tlocal o = gui.AbsolutePosition + game:GetService(\"GuiService\"):GetGuiInset()\n", "\t\t\t\t-- (o: once per frame, above the loop)\n" },
	{ "\tlocal now = os.clock()\n\tlocal n = 0\n\tfor m, t in pairs(targets) do\n", "\t-- (0.19.33) once per frame: read after moving a box, it re-laid-out the whole HUD for every box\n\tlocal o = gui.AbsolutePosition + game:GetService(\"GuiService\"):GetGuiInset()\n\tlocal now = os.clock()\n\tlocal n = 0\n\tfor m, t in pairs(targets) do\n" },
})

patch(SPS.GunshipUI, {
	{ "\tlocal i = gui.AbsolutePosition + GuiService:GetGuiInset()\n\treturn UDim2.fromOffset(v.X - i.X, v.Y - i.Y), on and v.Z > 0\n", "\tlocal i = markers.o or (gui.AbsolutePosition + GuiService:GetGuiInset()) -- (0.19.33: markers.o = this frame's)\n\treturn UDim2.fromOffset(v.X - i.X, v.Y - i.Y), on and v.Z > 0\n" },
	{ "\tlocal m = Aim.screen() - (gui.AbsolutePosition + GuiService:GetGuiInset())\n\tCrosshair.Position = UDim2.fromOffset(m.X, m.Y)\n", "\t-- (0.19.33) once per frame: read between moving markers it re-laid-out the whole HUD each time\n\tmarkers.o = gui.AbsolutePosition + GuiService:GetGuiInset()\n\tlocal m = Aim.screen() - markers.o\n\tCrosshair.Position = UDim2.fromOffset(m.X, m.Y)\n" },
	{ "\t\tlocal o = gui.AbsolutePosition + GuiService:GetGuiInset()\n\t\tlocal mid = (lo + hi) / 2 - o\n", "\t\tlocal mid = (lo + hi) / 2 - markers.o\n" },
	{ "\tfor i = n + 1, #markers do\n\t\tmarkers[i].Visible = false\n\tend\nend)\n", "\tfor i = n + 1, #markers do\n\t\tmarkers[i].Visible = false\n\tend\n\tmarkers.o = nil\nend)\n" },
})

patch(SPS.EnemyMover, {
	-- (rigs off the screen are walked on every 4th frame only)
	{ "RunService.RenderStepped:Connect(function()\n\tlocal now = workspace:GetServerTimeNow() - DELAY\n", "local moveParts, moveCFs = {}, {} -- (0.19.33: filled each frame, moved with one BulkMoveTo)\nlocal frameNo = 0\nRunService.RenderStepped:Connect(function()\n\tlocal now = workspace:GetServerTimeNow() - DELAY\n" },
	{ "\tlocal clock = os.clock()\n\tfor id, s in pairs(track) do\n", "\tlocal clock = os.clock()\n\tlocal nMove = 0\n\tframeNo += 1\n\t-- what the camera can see: a cone round its look direction (the screen's corners, plus a margin)\n\tlocal cam = workspace.CurrentCamera\n\tlocal camPos, look = cam.CFrame.Position, cam.CFrame.LookVector\n\tlocal vp = cam.ViewportSize\n\tlocal tanV = math.tan(math.rad(cam.FieldOfView) / 2)\n\tlocal cosLim = math.cos(math.min(math.rad(85), math.atan(tanV * math.sqrt(1 + (vp.X / math.max(1, vp.Y)) ^ 2)) + math.rad(8)))\n\tfor id, s in pairs(track) do\n" },
	{ "\t\t\t\troot.CFrame = cf\n", "\t\t\t\tnMove += 1\n\t\t\t\tmoveParts[nMove], moveCFs[nMove] = root, cf\n" },
	{ "\t\t\tif root then\n\t\t\t\tlocal a, b = s.a, s.b\n", "\t\t\tif root then\n\t\t\t\t-- (0.19.33) off the screen: walked on every 4th frame only (each rig is a whole assembly to move)\n\t\t\t\ts.slot = s.slot or math.random(0, 3)\n\t\t\t\tif (frameNo + s.slot) % 4 ~= 0 and (root.Position - camPos).Unit:Dot(look) < cosLim then\n\t\t\t\t\tcontinue\n\t\t\t\tend\n\t\t\t\tlocal a, b = s.a, s.b\n" },
	{ "\t\t\ttrack[id] = nil -- packets for a rig that never arrived (or was already gone)\n\t\tend\n\tend\nend)", "\t\t\ttrack[id] = nil -- packets for a rig that never arrived (or was already gone)\n\t\tend\n\tend\n\t-- (0.19.33) all the rigs in one go (one by one was the client's second biggest cost in a big wave)\n\tfor i = nMove + 1, #moveParts do\n\t\tmoveParts[i], moveCFs[i] = nil, nil\n\tend\n\tif nMove > 0 then\n\t\tworkspace:BulkMoveTo(moveParts, moveCFs, Enum.BulkMoveMode.FireCFrameChanged)\n\tend\nend)" },
})

patch(SPS.BattleOffers, {
	{ "\t\t\tl.Text = if key == \"CrewGems\" and Shared:GetAttribute(\"CrewGems\") then \"ACTIVE\" else ROBUX .. \" \" .. priceOf(key)\n",
		"\t\t\tlocal want = if key == \"CrewGems\" and Shared:GetAttribute(\"CrewGems\") then \"ACTIVE\" else ROBUX .. \" \" .. priceOf(key)\n\t\t\tif l:GetAttribute(\"Want\") ~= want then -- (0.19.33: only on a change; every frame cost a re-layout + RobuxGlyph)\n\t\t\t\tl:SetAttribute(\"Want\", want)\n\t\t\t\tl.Text = want\n\t\t\tend\n",
		all = true },
})
return table.concat(log, ", ")
