-- ButtonFeel (client): every button in our GUIs grows a little on hover, dips on press and ticks on hover, like the hub's (each screen plays its own click).
-- Buttons that already do it (a "Press" UIScale, GunshipUI's hook) only get the grow-from-the-middle; overlay "Hit"
-- buttons that cover a card make the card move instead. Hover tick only where the button doesn't play its own (FeelSound).
-- Growing from the middle uses HoverAnchor: only while the effect runs, so scripts that place buttons never fight it.
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local Convoy = game:GetService("ReplicatedStorage"):WaitForChild("Convoy")
local SFX = require(Convoy:WaitForChild("SFX"))
local HoverAnchor = require(Convoy:WaitForChild("HoverAnchor"))
local SKIP_GUIS = { TopbarStandard = true, TopbarCentered = true, LoadingScreen = true }
local done = setmetatable({}, { __mode = "k" })

local function scaleOf(target: GuiObject): UIScale?
	local own = target:FindFirstChild("Press") or target:FindFirstChild("Feel")
	if own and own:IsA("UIScale") then
		return own
	end
	if target:FindFirstChildWhichIsA("UIScale") then
		return nil -- (it already has a scale for something else; two UIScales don't mix)
	end
	local s = Instance.new("UIScale")
	s.Name = "Feel"
	s.Parent = target
	return s
end
local function tw(s: UIScale?, v: number, t: number)
	if s then
		TweenService:Create(s, TweenInfo.new(t, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Scale = v }):Play()
	end
end
local function wire(btn: GuiButton)
	if done[btn] then
		return
	end
	local sg = btn:FindFirstAncestorWhichIsA("LayerCollector")
	if not sg or SKIP_GUIS[sg.Name] then
		return
	end
	done[btn] = true
	-- a see-through button laid over a card: move the card
	local target = btn
	if btn.Name == "Hit" and btn.Parent and btn.Parent:IsA("GuiObject") then
		target = btn.Parent
	end
	local ownFeel = btn:FindFirstChild("Press") ~= nil -- (its own script tweens the scale)
	local over, down = false, false
	local function release()
		task.delay(0.15, function() -- once it has shrunk back
			if not over and not down then
				HoverAnchor.finish(target, "feel")
			end
		end)
	end
	local s
	local function get()
		HoverAnchor.begin(target, "feel")
		if not s and not ownFeel then
			s = scaleOf(target)
		end
		return s
	end
	btn.MouseEnter:Connect(function()
		if not btn.Active and btn.AutoButtonColor == false and btn.Selectable == false then
			return
		end
		local vp = workspace.CurrentCamera.ViewportSize
		if target.AbsoluteSize.X > vp.X * 0.6 or target.AbsoluteSize.Y > vp.Y * 0.6 then
			return -- a full-screen catcher, not a button
		end
		over = true
		tw(get(), 1.05, 0.08)
		if not btn:GetAttribute("FeelSound") then
			SFX.play("Click", { vol = 0.35, pitch = 1.7, gap = 0.04 })
		end
	end)
	btn.MouseLeave:Connect(function()
		over, down = false, false
		tw(s, 1, 0.1)
		release()
	end)
	btn.MouseButton1Down:Connect(function()
		down = true
		tw(get(), 0.94, 0.05)
	end)
	btn.MouseButton1Up:Connect(function()
		down = false
		tw(s, 1.03, 0.08)
		if not over then
			release()
		end
	end)
end
local function scan(root: Instance)
	for _, d in ipairs(root:GetDescendants()) do
		if d:IsA("GuiButton") then
			task.defer(wire, d)
		end
	end
end
-- (deferred: GunshipUI and the rest tag their own buttons first)
task.delay(1, function()
	scan(playerGui)
	playerGui.DescendantAdded:Connect(function(d)
		if d:IsA("GuiButton") then
			task.delay(0.1, wire, d)
		end
	end)
end)
