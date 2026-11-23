local CHS = game:GetService("ChangeHistoryService")
local rec = CHS:TryBeginRecording("Rebuild bunker compound")
local detail = workspace.DMZ.CityDetail
local old = detail:FindFirstChild("Compound")
if old then old:Destroy() end
local M = Instance.new("Model")
M.Name = "Compound"
local C = Vector3.new(900, 2, 150)
local hex = Color3.fromHex
local DARK, OLIVE, OLIVE2, CONC, SAND, YEL, SLAB = hex("1e1e1c"), hex("4a523a"), hex("383e2c"), hex("969080"), hex("7c7052"), hex("f5c518"), hex("363632")
local function P(name, size, pos, col, studs, parent)
	local p = Instance.new("Part")
	p.Name, p.Size, p.Position, p.Color = name, size, pos, col
	p.Anchored, p.Material = true, Enum.Material.Plastic
	p.TopSurface = if studs then Enum.SurfaceType.Studs else Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.CastShadow = size.Y > 1
	p.Parent = parent or M
	return p
end
local function at(dx, y, dz) return Vector3.new(C.X + dx, C.Y + y, C.Z + dz) end
for _, sx in ipairs({ -1, 1 }) do
	for _, sz in ipairs({ -1, 1 }) do
		local q = Instance.new("Model"); q.Name = "Corner"; q.Parent = M
		-- walls: concrete with an olive base and a dark cap (two per corner, gates left open on the roads)
		for _, w in ipairs({ { 31, 46, 30, 3 }, { 46, 31, 3, 30 } }) do
			local dx, dz, lx, lz = sx * w[1], sz * w[2], w[3], w[4]
			P("Wall", Vector3.new(lx, 6, lz), at(dx, 3, dz), CONC, false, q)
			P("WallBase", Vector3.new(lx + 0.6, 1.6, lz + 0.6), at(dx, 0.8, dz), OLIVE2, false, q)
			P("WallCap", Vector3.new(lx + 0.4, 0.5, lz + 0.4), at(dx, 6.25, dz), DARK, true, q)
		end
		-- gate posts with a hazard band
		for _, g in ipairs({ { 16, 46 }, { 46, 16 } }) do
			local dx, dz = sx * g[1], sz * g[2]
			P("GatePost", Vector3.new(4, 8, 4), at(dx, 4, dz), DARK, true, q)
			P("GateStripe", Vector3.new(4.2, 0.6, 4.2), at(dx, 6.6, dz), YEL, false, q)
			-- sandbags inside the gate
			local ix, iz = dx - sx * (g[1] == 46 and 4 or 0), dz - sz * (g[2] == 46 and 4 or 0)
			local along = g[2] == 46 -- gate on a north/south road: bags run along x
			local s = if along then Vector3.new(6, 2.2, 2.4) else Vector3.new(2.4, 2.2, 6)
			P("Sandbags", s, at(ix + (along and sx * 2 or 0), 1.1, iz + (along and 0 or sz * 2)), SAND, true, q)
			P("Sandbags", if along then Vector3.new(4, 1.8, 2.2) else Vector3.new(2.2, 1.8, 4), at(ix + (along and sx * 2 or 0), 3.1, iz + (along and 0 or sz * 2)), SAND, true, q)
		end
		-- corner watchtower
		local tx, tz = sx * 46, sz * 46
		P("TowerBase", Vector3.new(7, 14, 7), at(tx, 7, tz), OLIVE, false, q)
		P("TowerFoot", Vector3.new(8, 2, 8), at(tx, 1, tz), OLIVE2, false, q)
		P("TowerDeck", Vector3.new(11, 1, 11), at(tx, 14.5, tz), SLAB, true, q)
		for _, r in ipairs({ { 0, 5.2, 11, 0.6 }, { 0, -5.2, 11, 0.6 }, { 5.2, 0, 0.6, 11 }, { -5.2, 0, 0.6, 11 } }) do
			P("TowerRail", Vector3.new(r[3], 2.6, r[4]), at(tx + r[1], 16.3, tz + r[2]), OLIVE2, false, q)
		end
		for _, a in ipairs({ -1, 1 }) do
			for _, b in ipairs({ -1, 1 }) do
				P("TowerPost", Vector3.new(0.8, 6, 0.8), at(tx + a * 5, 18, tz + b * 5), DARK, false, q)
			end
		end
		P("TowerRoof", Vector3.new(12, 1, 12), at(tx, 21.5, tz), OLIVE, true, q)
		P("TowerRoofLip", Vector3.new(12.6, 0.4, 12.6), at(tx, 20.9, tz), DARK, false, q)
		local lamp = P("Searchlight", Vector3.new(1.6, 1.6, 1.6), at(tx - sx * 4.6, 19.6, tz - sz * 4.6), hex("fff2c8"), false, q)
		lamp.Material = Enum.Material.Neon
		-- yard: helipad on two corners, supplies on the other two
		local yx, yz = sx * 28, sz * 28
		if sx ~= sz then
			P("Pad", Vector3.new(24, 0.6, 24), at(yx, 0.3, yz), SLAB, true, q)
			for _, e in ipairs({ { 0, 11.5, 24, 1 }, { 0, -11.5, 24, 1 }, { 11.5, 0, 1, 24 }, { -11.5, 0, 1, 24 } }) do
				P("PadEdge", Vector3.new(e[3], 0.2, e[4]), at(yx + e[1], 0.7, yz + e[2]), YEL, false, q)
			end
			P("PadH", Vector3.new(2, 0.2, 12), at(yx - 4, 0.7, yz), YEL, false, q)
			P("PadH", Vector3.new(2, 0.2, 12), at(yx + 4, 0.7, yz), YEL, false, q)
			P("PadH", Vector3.new(6, 0.2, 2), at(yx, 0.7, yz), YEL, false, q)
			for _, a in ipairs({ -1, 1 }) do
				for _, b in ipairs({ -1, 1 }) do
					local l = P("PadLight", Vector3.new(0.8, 0.5, 0.8), at(yx + a * 13, 0.25, yz + b * 13), hex("4b974b"), false, q)
					l.Material = Enum.Material.Neon
				end
			end
		else
			-- a tidy supply dump: crates and a sandbag wall
			P("Crate", Vector3.new(5, 4, 5), at(yx + sx * 6, 2, yz + sz * 6), OLIVE, true, q)
			P("Crate", Vector3.new(5, 4, 5), at(yx + sx * 0.5, 2, yz + sz * 6), OLIVE2, true, q)
			P("Crate", Vector3.new(4, 3, 4), at(yx + sx * 3.5, 5.5, yz + sz * 6), CONC, true, q)
			P("Crate", Vector3.new(4, 3, 6), at(yx + sx * 6.5, 1.5, yz - sz * 1), CONC, true, q)
			P("Sandbags", Vector3.new(12, 2.2, 2.4), at(yx, 1.1, yz - sz * 8), SAND, true, q)
			P("Sandbags", Vector3.new(8, 1.8, 2.2), at(yx, 3.1, yz - sz * 8), SAND, true, q)
			P("Sandbags", Vector3.new(2.4, 2.2, 10), at(yx - sx * 8, 1.1, yz - sz * 2), SAND, true, q)
		end
	end
end
M.Parent = detail
if rec then CHS:FinishRecording(rec, Enum.FinishRecordingOperation.Commit) end
return #M:GetDescendants()
