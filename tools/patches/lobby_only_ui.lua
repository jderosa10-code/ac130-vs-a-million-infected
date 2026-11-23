-- 0.14.13: the hub screens (aircraft, ranks, player card) only run in the lobby place; the mission places don't
-- have that UI (it errored on join in Downtown).
local GUARD = [[-- (lobby only: the mission places don't have the hub screens)
do
	local okP, Places = pcall(require, game:GetService("ReplicatedStorage"):WaitForChild("Convoy"):WaitForChild("Places"))
	if okP and game.PlaceId ~= 0 and game.PlaceId ~= Places.LOBBY then
		return
	end
end
]]
local out = {}
for _, n in ipairs({ "AircraftUI", "LobbyHUD", "RanksUI" }) do
	local s = game.StarterPlayer.StarterPlayerScripts[n]
	if not s.Source:find("lobby only: the mission places", 1, true) then
		s.Source = GUARD .. s.Source
		table.insert(out, n)
	end
end
return table.concat(out, ",")
