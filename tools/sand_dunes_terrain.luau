-- Sand Dunes height field + terrain writer (used to build the Sand Dunes place, 0.15.0).
-- Put in ServerStorage as a ModuleScript, then in the command bar:
--   workspace.Terrain:Clear(); local G = require(game.ServerStorage.DuneGen)
--   for cx = -1664, 1408, 256 do for cz = -1664, 1408, 256 do G.writeChunk(cx, cz) task.wait() end end
-- Then re-carve the bunker tunnel (FillCylinder Air, radius 18.4, along Z from z=-4 to -110 at y=1) and the apron.
-- Bunker at the origin facing +Z; the giant dune behind it (-Z).
local G = {}
local function sm(a, b, x)
	local t = math.clamp((x - a) / (b - a), 0, 1)
	return t * t * (3 - 2 * t)
end
function G.H(x: number, z: number): number
	local r = math.sqrt(x * x + z * z)
	local h = 1.0 -- flat basin (low ripples came out as blotchy contour bands at 4-stud voxels)
	local crestZ = -92 + 18 * math.sin(x / 240)
	local along = math.exp(-(x / 560) ^ 2)
	local d
	if z > crestZ then
		d = (1 - sm(crestZ, crestZ + 88, z)) ^ 1.35 -- slip face down to the bunker
	else
		d = sm(crestZ - 480, crestZ, z) -- long back
	end
	h += 98 * along * d
	local w = sm(470, 800, r) -- rolling transverse dunes to the horizon
	if w > 0 then
		local dz = z + 110 * math.noise(x / 420, z / 420, 3.1)
		local band = (0.5 + 0.5 * math.sin(dz / 92)) ^ 2
		local amp = 34 + 30 * math.noise(x / 330, z / 330, 9.3)
		h = h * (1 - w * 0.25) + w * band * amp + w * 6
	end
	h += 10 * sm(330, 520, r) * (1 - math.exp(-(x / 900) ^ 2) * 0.3)
	local pad = 1 - sm(34, 54, math.sqrt(x * x + (z - 38) ^ 2)) -- flat in front of the bunker
	return h * (1 - pad) + 1.0 * pad
end
local SAND = Enum.Material.Sand
function G.writeChunk(x0: number, z0: number)
	local N = 64
	local hs, maxH = {}, -1e9
	for i = 1, N do
		hs[i] = {}
		for k = 1, N do
			local h = G.H(x0 + (i - 0.5) * 4, z0 + (k - 0.5) * 4)
			hs[i][k] = h
			maxH = math.max(maxH, h)
		end
	end
	local y0 = -16
	local ny = math.max(1, math.ceil((maxH - y0) / 4) + 1)
	local mats, occs = {}, {}
	for i = 1, N do
		mats[i], occs[i] = {}, {}
		for j = 1, ny do
			local mrow, orow = {}, {}
			local yb = y0 + (j - 1) * 4
			for k = 1, N do
				local o = math.clamp((hs[i][k] - yb) / 4, 0, 1)
				orow[k] = o
				mrow[k] = if o > 0 then SAND else Enum.Material.Air
			end
			mats[i][j], occs[i][j] = mrow, orow
		end
	end
	workspace.Terrain:WriteVoxels(Region3.new(Vector3.new(x0, y0, z0), Vector3.new(x0 + N * 4, y0 + ny * 4, z0 + N * 4)), 4, mats, occs)
end
return G
