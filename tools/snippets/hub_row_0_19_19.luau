-- 0.19.19: phones' SHOP / SEASON / FREE row exactly as wide as the rank card; the chest's "!" always shows. Idempotent.
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
local SPS = game.StarterPlayer.StarterPlayerScripts
patch(SPS.GunshipUI, {
	{ "\t\t\t\t\t\t\t\tf.AnchorPoint = Vector2.new(baseAnchor[f].X, 0)\n\t\t\t\t\t\t\t\tbp = UDim2.new(bp.X.Scale, bp.X.Offset, 0, math.floor(top))\n",
		"\t\t\t\t\t\t\t\tf.AnchorPoint = Vector2.new(baseAnchor[f].X, 0)\n\t\t\t\t\t\t\t\tbp = UDim2.new(bp.X.Scale, bp.X.Offset, 0, math.floor(top))\n"
		.. "\t\t\t\t\t\t\t\tif phone and f.Name == \"Side\" then\n"
		.. "\t\t\t\t\t\t\t\t\t-- phones: the row is exactly as wide as the rank card above it, lined up with it (narrower looked odd)\n"
		.. "\t\t\t\t\t\t\t\t\tk = rc.Size.X.Offset * rk / f.Size.X.Offset\n"
		.. "\t\t\t\t\t\t\t\t\tbp = UDim2.new(0, rc.Position.X.Offset, 0, math.floor(top))\n"
		.. "\t\t\t\t\t\t\t\tend\n" },
})
patch(SPS.CrateUI, {
	{ "\ttile.Dot.Visible = free or spins > 0\n", "\ttile.Dot.Visible = true -- (the \"!\" always shows on the chest; it shakes when a spin is ready)\n" },
	{ "\ttile.Rotation = if tile.Dot.Visible and w < 0.6 then", "\ttile.Rotation = if (freeIn() <= 0 or a(\"CrateSpins\", 0) > 0) and w < 0.6 then" },
})
return table.concat(log, ", ")
