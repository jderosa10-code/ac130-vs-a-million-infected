-- North Pole (Christmas map, place 134466727053055) terrain, 0.19.1: a STREET-type map (DMZ has no Map attribute,
-- like Downtown). The infected walk at one ground height (Mission GROUND, measured from the terrain at bunker+75)
-- and spawn up to ~545 studs out along the six streets (x / z = -150, 0, 150 through the bunker at the origin), so
-- the ground is dead flat (surface 4.0) out to ~600, then snowy hills and tall mountains past the blizzard.
-- Everything else on the map is Parts in DMZ: Roads (streets + the square), Bunker (Santa's Workshop, Center 0,2,0),
-- Decor (Houses, Trees, StreetLights = glowing strips on the snowbanks, Snowbanks, ChristmasTree, Rink, Snowmen,
-- Canes, Lamps, SleighDisplay). Keep the square clear within ~90 studs of the bunker: the street-map loss cutscene
-- shoots from (55, 5, 34) and orbits 70-110 out on the +Z side.
local T = workspace.Terrain
T:Clear()
local function sm(a, b, x)
	local t = math.clamp((x - a) / (b - a), 0, 1)
	return t * t * (3 - 2 * t)
end
local function H(x, z)
	local r = math.max(math.abs(x), math.abs(z)) * 0.6 + math.sqrt(x * x + z * z) * 0.4
	local h = 2
	local hill = sm(600, 760, r)
	if hill > 0 then
		h += hill * (26 + 16 * math.noise(x / 260, z / 260, 2.7))
	end
	local m = sm(700, 1050, r)
	if m > 0 then
		local amp = 140 + 90 * math.noise(x / 420, z / 420, 5.3) + 40 * math.noise(x / 160, z / 160, 8.1)
		h += m * math.max(amp, 30)
	end
	return h
end
local SNOW, ROCK, SLATE = Enum.Material.Snow, Enum.Material.Rock, Enum.Material.Slate
local function writeChunk(x0, z0)
	local N = 64
	local hs, maxH = {}, -1e9
	for i = 0, N + 1 do
		hs[i] = {}
		for k = 0, N + 1 do
			local h = H(x0 + (i - 0.5) * 4, z0 + (k - 0.5) * 4)
			hs[i][k] = h
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
			local mat = if slope > 1.2 then SLATE elseif slope > 0.75 then ROCK else SNOW
			for j = 1, ny do
				local yb = y0 + (j - 1) * 4
				local o = math.clamp((h - yb) / 4, 0, 1)
				occs[i][j][k] = o
				mats[i][j][k] = if o > 0 then mat else Enum.Material.Air
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
T:SetMaterialColor(Enum.Material.Rock, Color3.fromRGB(122, 128, 142))
T:SetMaterialColor(Enum.Material.Slate, Color3.fromRGB(104, 110, 126))
