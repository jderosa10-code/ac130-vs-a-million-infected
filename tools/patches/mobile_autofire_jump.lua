-- 0.14.14: phones get the AUTO-FIRE on/off row in Settings (GunshipUI already drives a row named AutoFire, but the
-- row was never in the UI, and GunshipClient's auto-fire ignored the setting), and no JUMP button during a run.
local out = {}
-- the Settings row: a copy of MUSIC in TUTORIAL's spot (GunshipUI moves the rows under it down on touch devices)
local body = game.StarterGui.GunshipUI.Settings.Panel.Body
if not body:FindFirstChild("AutoFire") then
	local row = body.Music:Clone()
	row.Name = "AutoFire"
	row.Label.Text = "AUTO-FIRE"
	row.Position = body.Tutorial.Position
	row.Visible = false
	row.Parent = body
	table.insert(out, "row")
end
-- auto-fire honours the setting
local gc = game.StarterPlayer.StarterPlayerScripts.GunshipClient
local s = gc.Source
local a = [[	if not r or not Aim.touch() or player:GetAttribute("Cutscene") then
		autoLock = false]]
local b = [[	if not r or not Aim.touch() or player:GetAttribute("Cutscene") or player:GetAttribute("AutoFireOff") then
		autoLock = false -- (off in Settings: the FIRE button only)]]
local i, j = s:find(a, 1, true)
if i then
	assert(not s:find(a, j + 1, true))
	gc.Source = s:sub(1, i - 1) .. b .. s:sub(j + 1)
	table.insert(out, "autofire")
end
-- no jumping in a run (it also takes the phone's JUMP button, which sat under FIRE, off the screen)
local sps = game.StarterPlayer.StarterPlayerScripts
if not sps:FindFirstChild("RunNoJump") then
	local ls = Instance.new("LocalScript")
	ls.Name = "RunNoJump"
	ls.Source = [[-- RunNoJump (client): no jumping during a run. With jump off, Roblox's touch controls hide the JUMP button too
-- (on phones it sat under the FIRE button). Put back when you're out of the run.
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local saved = nil
local function apply()
	local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
	if not hum then
		return
	end
	if player:GetAttribute("Screen") == "HUD" then
		if not saved then
			saved = { hum.JumpPower, hum.JumpHeight }
		end
		hum.JumpPower = 0
		hum.JumpHeight = 0
	elseif saved then
		hum.JumpPower, hum.JumpHeight = saved[1], saved[2]
		saved = nil
	end
end
player:GetAttributeChangedSignal("Screen"):Connect(apply)
player.CharacterAdded:Connect(function(c)
	saved = nil
	c:WaitForChild("Humanoid", 10)
	apply()
end)
apply()
]]
	ls.Parent = sps
	table.insert(out, "RunNoJump")
end
return table.concat(out, ",")
