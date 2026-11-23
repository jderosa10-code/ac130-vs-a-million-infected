applyPolarity()

---------------------------------------------------------------- day and night
-- Runs swap between day and night every NightEvery waves (5: waves 1-5 day, 6-10 night, 11-15 day...), never in
-- the tutorial. The sun goes down over a few seconds; at night the sensor is NIGHT VISION (green, brighter, softer)
-- instead of the black-and-white thermal look. Lobby and hub are always day.
local NIGHT_FADE = 6 -- seconds for dusk / dawn
local dayLight = {
	clock = Lighting.ClockTime, bright = Lighting.Brightness, out = Lighting.OutdoorAmbient,
}
local atmo = Lighting:FindFirstChildOfClass("Atmosphere")
local dayAtmo = atmo and { color = atmo.Color, decay = atmo.Decay, glare = atmo.Glare }
local NIGHT_OUT = Color3.fromRGB(62, 74, 100)
local NV_TINT = Color3.fromRGB(110, 255, 125)
local TH_TINT = cc.TintColor
local nightK, nightShown = 0, 0
local function nightWanted(): boolean
	if Shared:GetAttribute("State") ~= "Running" or Shared:GetAttribute("Tutorial") then
		return false
	end
	local every = Shared:GetAttribute("NightEvery") or 5
	return ((math.max(1, Shared:GetAttribute("Wave") or 1) - 1) // every) % 2 == 1
end
RunService.RenderStepped:Connect(function(dt)
	if Shared:GetAttribute("State") ~= "Running" then
		nightK = 0
	else
		local want = if nightWanted() then 1 else 0
		nightK = if want > nightK then math.min(want, nightK + dt / NIGHT_FADE) else math.max(want, nightK - dt / NIGHT_FADE)
	end
	player:SetAttribute("NightVision", nightK > 0.5 or nil)
	if nightK == 0 and nightShown == 0 then
		return -- (plain day: leave Lighting alone)
	end
	nightShown = nightK
	local k = nightK
	-- the sun sets on through the evening to just past midnight
	Lighting.ClockTime = (dayLight.clock + (24.4 - dayLight.clock) * k) % 24
	Lighting.Brightness = dayLight.bright + (0.6 - dayLight.bright) * k
	Lighting.OutdoorAmbient = dayLight.out:Lerp(NIGHT_OUT, k)
	if atmo and dayAtmo then
		atmo.Color = dayAtmo.color:Lerp(Color3.fromRGB(28, 36, 56), k)
		atmo.Decay = dayAtmo.decay:Lerp(Color3.fromRGB(16, 20, 34), k)
		atmo.Glare = dayAtmo.glare * (1 - k)
	end
	-- through the sensor: thermal by day, night vision by night
	cc.TintColor = TH_TINT:Lerp(NV_TINT, k)
	cc.Contrast = 0.55 + (0.22 - 0.55) * k
	cc.Brightness = (if blackHot then 0.12 else -0.08) + 0.34 * k
	blur.Size = 2 + k
end)
