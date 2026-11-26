-- North Pole (Christmas map, place 134466727053055) terrain: a snowy mountain valley, used to build it in 0.19.0.
-- Run in the command bar of the North Pole place (execute_luau). Bunker at the origin facing +Z, dug into the cliff
-- behind it (-Z). Not the Sand Dunes shape on purpose: a steep rocky cliff (Slate / Rock on slopes), forested
-- ridges down both sides (|x| > 150), a frozen river (Ice) winding across the front at z ~ 150, gentle valley floor,
-- a ring of tall mountains past the fog. Low-frequency shapes only (small sharp bumps make Roblox's far terrain LOD
-- look doubled, see 0.18.7). The cliff crest is ~62 high in the middle so the helicopters still see the bunker.
-- Afterwards re-carve the tunnel (last line) and re-seat props (every model in DMZ.Decor / Props / RouteProps:
-- bottom = lowest terrain under its footprint).
local T = workspace.Terrain
T:Clear()
local function sm(a, b, x)
	local t = math.clamp((x - a) / (b - a), 0, 1)
	return t * t * (3 - 2 * t)
end
local function riverZ(x) return 150 + 45 * math.sin(x / 105) + 20 * math.sin(x / 41 + 1.3) end
local function H(x, z)
	local r = math.sqrt(x * x + z * z)
	local ax = math.abs(x)
	local h = 2
	local crestZ = -100 + 10 * math.sin(x / 90)
	local wide = math.exp(-(x / 560) ^ 2)
	local face = if z > crestZ then (1 - sm(crestZ, crestZ + 82, z)) ^ 1.9 else 1
	local peaks = 1 + (0.45 * math.noise(x / 140, 0.5, 2.2) + 0.25 * math.noise(x / 60, 1.5, 4.4)) * sm(90, 220, ax)
	h += 62 * wide * face * peaks
	local ridge = sm(150, 330, ax) * (46 + 22 * math.noise(z / 190, ax / 190, 6.1))
	h += ridge * sm(-200, -60, z)
	h += 3 * math.noise(x / 150, z / 150, 3.3) * sm(60, 160, r)
	h += 10 * sm(260, 470, z)
	local m = sm(620, 980, r)
	if m > 0 then
		local amp = 130 + 90 * math.noise(x / 420, z / 420, 5.3) + 40 * math.noise(x / 160, z / 160, 8.1)
		h += m * math.max(amp, 30)
	end
	local dr = math.abs(z - riverZ(x))
	local rk = 1 - sm(10, 22, dr)
	h = h * (1 - rk) + (h - 3.2) * rk
	local pad = 1 - sm(36, 60, math.sqrt(x * x + (z - 38) ^ 2))
	return h * (1 - pad) + 1.0 * pad, dr
end
local SNOW, ICE, ROCK, SLATE = Enum.Material.Snow, Enum.Material.Ice, Enum.Material.Rock, Enum.Material.Slate
local function writeChunk(x0, z0)
	local N = 64
	local hs, ds, maxH = {}, {}, -1e9
	for i = 0, N + 1 do
		hs[i], ds[i] = {}, {}
		for k = 0, N + 1 do
			local h, dr = H(x0 + (i - 0.5) * 4, z0 + (k - 0.5) * 4)
			hs[i][k], ds[i][k] = h, dr
			if i >= 1 and i <= N and k >= 1 and k <= N then maxH = math.max(maxH, h) end
		end
	end
	local y0 = -16
	local ny = math.max(1, math.ceil((maxH - y0) / 4) + 1)
	local mats, occs = {}, {}
	for i = 1, N do
		mats[i], occs[i] = {}, {}
		for j = 1, ny do mats[i][j], occs[i][j] = {}, {} end
		for k = 1, N do
			local h = hs[i][k]
			local slope = math.max(math.abs(hs[i + 1][k] - hs[i - 1][k]), math.abs(hs[i][k + 1] - hs[i][k - 1])) / 8
			local mat = SNOW
			if ds[i][k] < 15 and h < 4 then mat = ICE
			elseif slope > 1.2 then mat = SLATE
			elseif slope > 0.75 then mat = ROCK end
			for j = 1, ny do
				local yb = y0 + (j - 1) * 4
				local o = math.clamp((h - yb) / 4, 0, 1)
				occs[i][j][k] = o
				local mm = mat
				if mat == ICE and (h - yb) > 6 then mm = SNOW end
				mats[i][j][k] = if o > 0 then mm else Enum.Material.Air
			end
		end
	end
	T:WriteVoxels(Region3.new(Vector3.new(x0, y0, z0), Vector3.new(x0 + N * 4, y0 + ny * 4, z0 + N * 4)), 4, mats, occs)
end
for cx = -1536, 1280, 256 do
	for cz = -1536, 1280, 256 do
		writeChunk(cx, cz)
		task.wait()
	end
end
T:SetMaterialColor(Enum.Material.Snow, Color3.fromRGB(236, 242, 252))
T:SetMaterialColor(Enum.Material.Ice, Color3.fromRGB(140, 190, 228))
T:SetMaterialColor(Enum.Material.Rock, Color3.fromRGB(122, 128, 142))
T:SetMaterialColor(Enum.Material.Slate, Color3.fromRGB(104, 110, 126))
-- the bunker's tunnel into the cliff (same as Sand Dunes)
T:FillCylinder(CFrame.new(0, 1, -57) * CFrame.Angles(math.rad(90), 0, 0), 106, 18.4, Enum.Material.Air)
