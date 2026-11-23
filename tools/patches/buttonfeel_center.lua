-- 0.14.13: every button grows from its middle. Screens tween their own "Press" UIScale on hover; ButtonFeel only
-- re-anchored them from its own MouseEnter (skipped for some buttons, e.g. Active = false), so they could grow from
-- the top-left. Now it watches every UIScale on a button: whenever it isn't 1, the button is held at its middle.
local m = game.StarterPlayer.StarterPlayerScripts.ButtonFeel
local s = m.Source
local a = [[	local ownFeel = btn:FindFirstChild("Press") ~= nil -- (its own script tweens the scale)]]
local b = [[	local ownFeel = btn:FindFirstChild("Press") ~= nil -- (its own script tweens the scale)
	-- any scale a screen tweens on this button itself (its "Press", a plain UIScale): grow from the middle while
	-- it's off 1, whoever tweens it and whenever
	local function watch(sc: Instance)
		if not sc:IsA("UIScale") or sc.Name == "Feel" then
			return
		end
		local holder = sc.Parent :: GuiObject
		local key = "scale" .. tostring(sc)
		sc:GetPropertyChangedSignal("Scale"):Connect(function()
			if math.abs(sc.Scale - 1) > 0.002 then
				HoverAnchor.begin(holder, key)
			else
				HoverAnchor.finish(holder, key)
			end
		end)
	end
	for _, c in ipairs(btn:GetChildren()) do
		watch(c)
	end
	btn.ChildAdded:Connect(watch)]]
local i, j = s:find(a, 1, true)
assert(i and not s:find(a, j + 1, true), "ButtonFeel: ownFeel line")
m.Source = s:sub(1, i - 1) .. b .. s:sub(j + 1)
return "ok"
