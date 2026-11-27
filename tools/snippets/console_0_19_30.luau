-- 0.19.30: console (controller) gaps. Run in a place (execute_luau, Edit) on top of 0.19.29. Idempotent.
-- * SECOND CHANCE (bunker fell): KEEP GOING is selected, A buys it (ConsoleNav extraPanel).
-- * View during a run: picks the HUD's buttons without leaving the fight: a battle offer's buy button first, then
--   the test range's UNLIMITED AMMO / EXIT TEST FLIGHT, the always-on buy tiles, RELOAD ALL. View again / B: back.
-- * Y on a lobby pad: the crew bar (LAUNCH NOW for the host, else LEAVE).
-- * BattleOffers buttons use Activated (fires for a controller's A too), the offer card shows [VIEW] on a pad.
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
		assert(not src:find(p[1], b + 1, true), "anchor twice in " .. scr.Name .. ": " .. p[1]:sub(1, 80))
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

patch(SPS.ConsoleNav, {
	{ "-- * D-pad down, in the hangar and between waves:", "-- * View in a run (0.19.30): picks the HUD's buttons without leaving the fight (a battle offer first, the test\n--   range's switches, the buy tiles, RELOAD ALL); View again or B: back to the guns. Y on a lobby pad: LAUNCH NOW.\n-- * D-pad down, in the hangar and between waves:" },
	{ "local function extraPanel(): Instance?\n", [[local function extraPanel(): Instance?
	-- (0.19.30) the SECOND CHANCE popup (BattleOffers): KEEP GOING selected, so A buys it
	local bo = pgui:FindFirstChild("BattleOffers")
	local scp = bo and bo:FindFirstChild("SecondChance", true)
	if scp and scp:IsA("GuiObject") and onScreen(scp) then
		return scp
	end
]] },
	{ "-- Y in the hangar: pick the hub's buttons (PLAY first); Y again or B: back to walking\n", [[-- (0.19.30) View in a run: the HUD's buttons without leaving the fight
local function inWave(): boolean
	return player:GetAttribute("Screen") == "HUD" and Shared2:GetAttribute("State") == "Running"
		and not inBreak() and not player:GetAttribute("Cutscene") and not player:GetAttribute("Targeting")
end
local function waveFirst(): GuiButton?
	local bo = pgui:FindFirstChild("BattleOffers")
	if bo then
		for _, d in ipairs(bo:GetDescendants()) do
			if d:IsA("GuiButton") and d:GetAttribute("PadFirst") and onScreen(d) then
				return d -- a battle offer's buy button
			end
		end
	end
	local g = gunshipUI()
	local hud = g and g:FindFirstChild("HUD")
	local function at(a: string, b: string): GuiButton?
		local x = hud and hud:FindFirstChild(a)
		x = x and x:FindFirstChild(b)
		return if x and x:IsA("GuiButton") and onScreen(x) then x else nil
	end
	local q = bo and bo:FindFirstChild("QuickBuy", true)
	local qb = if q and q:IsA("GuiObject") and onScreen(q) then firstButton(q, nil) else nil
	local w = hud and hud:FindFirstChild("Weapons")
	return at("Weapons", "TestAmmo") or at("Bottom", "ExitTest") or qb or at("Weapons", "ReloadAll")
		or (if w then firstButton(w, nil) else nil)
end
local wavePicking = false
-- (an input listener, not a bound action: Roblox takes View's press itself before bound actions see it)
game:GetService("UserInputService").InputBegan:Connect(function(input)
	if input.KeyCode ~= Enum.KeyCode.ButtonSelect or not Aim.pad() or not (inWave() or inBreak()) or frontBack() or extraPanel() then
		return
	end
	local sel = GuiService.SelectedObject
	if wavePicking and not (sel and sel.Parent and onScreen(sel)) then
		wavePicking = false -- (what it picked went away)
	end
	-- on: the first HUD button; again: off (between waves the selection then goes back to START)
	local b = if wavePicking then nil else waveFirst()
	wavePicking = b ~= nil
	task.delay(0.05, function() -- (after Roblox's own View selection, which may pick or drop something)
		if wavePicking and b and b.Parent and onScreen(b) then
			GuiService.SelectedObject = b
		elseif not wavePicking then
			GuiService.SelectedObject = nil
		end
	end)
end)

-- mid-wave only View's own pick holds a selection: Roblox moves the selection to a neighbour when the selected
-- button goes away (an offer bought, SECOND CHANCE closed), which would hand the sticks and A to the HUD
local lastWaveSel = nil
RunService.Heartbeat:Connect(function()
	if not Aim.pad() or not inWave() or frontBack() or extraPanel() or cursorActive() then
		lastWaveSel = nil
		return
	end
	local sel = GuiService.SelectedObject
	if sel and (not wavePicking or (lastWaveSel and lastWaveSel ~= sel and not (lastWaveSel.Parent and onScreen(lastWaveSel)))) then
		wavePicking = false
		GuiService.SelectedObject = nil
		sel = nil
	end
	lastWaveSel = sel
end)

-- Y in the hangar: pick the hub's buttons (PLAY first); Y again or B: back to walking
]] },
	{ [[	local g = gunshipUI()
	local menu = g and g:FindFirstChild("Menu")
	local play = menu and menu:FindFirstChild("Play", true)]], [[	-- (0.19.30) standing on a lobby pad: Y picks the crew bar (LAUNCH NOW for the host, else LEAVE)
	local ph = pgui:FindFirstChild("PadHUD")
	local pbar = ph and ph:IsA("ScreenGui") and ph.Enabled and ph:FindFirstChild("Bar")
	if pbar then
		local pick = pbar:FindFirstChild("Launch")
		if not (pick and pick:IsA("GuiButton") and onScreen(pick)) then
			pick = pbar:FindFirstChild("Leave")
		end
		if pick and pick:IsA("GuiButton") and onScreen(pick) then
			hubPicking = true
			GuiService.SelectedObject = pick
			return Enum.ContextActionResult.Sink
		end
	end
	local g = gunshipUI()
	local menu = g and g:FindFirstChild("Menu")
	local play = menu and menu:FindFirstChild("Play", true)]] },
	{ [[	if hubPicking then
		hubPicking = false
		GuiService.SelectedObject = nil
		return Enum.ContextActionResult.Sink
	end
	return Enum.ContextActionResult.Pass
end, false, Enum.ContextActionPriority.High.Value + 100, Enum.KeyCode.ButtonB)]], [[	if hubPicking then
		hubPicking = false
		GuiService.SelectedObject = nil
		return Enum.ContextActionResult.Sink
	end
	if inWave() and GuiService.SelectedObject then
		wavePicking = false
		GuiService.SelectedObject = nil -- (0.19.30) out of View's HUD pick: back to the guns (no gun upgrade)
		return Enum.ContextActionResult.Sink
	end
	return Enum.ContextActionResult.Pass
end, false, Enum.ContextActionPriority.High.Value + 100, Enum.KeyCode.ButtonB)]] },
})

patch(SPS.BattleOffers, {
	{ [[	b.MouseButton1Click:Connect(function()
		buy(key)
		closeCard()
	end)
	local x = closeButton(c, UDim2.new(1, -40, 0, 6))
	x.Size = UDim2.fromOffset(34, 34)
	x.TextSize = 26
	x.MouseButton1Click:Connect(closeCard)]], [[	b:SetAttribute("PadFirst", true) -- (0.19.30: a controller's View selects it, ConsoleNav)
	b.Activated:Connect(function()
		buy(key)
		closeCard()
	end)
	local x = closeButton(c, UDim2.new(1, -40, 0, 6))
	x.Size = UDim2.fromOffset(34, 34)
	x.TextSize = 26
	x.Activated:Connect(closeCard)
	if Aim.pad() then
		-- a controller: View picks it (beside the buy button)
		local tag = text(c, "[VIEW]", 18, SUB, UDim2.fromOffset(276, 80), UDim2.fromOffset(88, 30), Enum.TextXAlignment.Center)
		tag.Name = "PadTag"
	end]] },
	{ "\tlocal dim = Instance.new(\"Frame\")\n\tdim.BackgroundColor3 = PANEL\n", "\tlocal dim = Instance.new(\"Frame\")\n\tdim.Name = \"SecondChance\" -- (0.19.30: ConsoleNav selects KEEP GOING in it)\n\tdim.BackgroundColor3 = PANEL\n" },
	{ [[	b.MouseButton1Click:Connect(function()
		buy("SecondChance")
	end)]], [[	b:SetAttribute("PadFirst", true)
	b.Activated:Connect(function()
		buy("SecondChance")
	end)]] },
	{ "\tgive.MouseButton1Click:Connect(function()", "\tgive.Activated:Connect(function()" },
	{ "\tb.MouseButton1Click:Connect(tap)\n\tt.MouseButton1Click:Connect(tap)", "\tb.Activated:Connect(tap)\n\tt.Activated:Connect(tap)" },
})

-- gamepad B upgrades the gun; with a HUD button picked mid-wave (View) it only lets go of it (no upgrade)
patch(SPS.GunshipUI, {
	{ "\tif gp and not (sel and sel:IsDescendantOf(HUD)) then\n", "\tif gp and not (sel and sel:IsDescendantOf(HUD) and attr(\"Phase\", \"\") == \"Break\") then -- (0.19.30: not mid-wave)\n" },
})

-- the range's two buttons: the D-pad goes straight between them
patch(SPS.TestFlightUI, {
	{ "for _, k in ipairs({ \"TestFlight\", \"State\" }) do\n\tShared:GetAttributeChangedSignal(k):Connect(refresh)\nend\n", "for _, k in ipairs({ \"TestFlight\", \"State\" }) do\n\tShared:GetAttributeChangedSignal(k):Connect(refresh)\nend\nif ammo and exit then\n\tammo.NextSelectionLeft = exit -- (0.19.30: controller D-pad)\n\texit.NextSelectionRight, exit.NextSelectionUp = ammo, ammo\nend\n" },
})

patch(SPS.ControlHints, {
	{ [[{ "D-PAD DOWN", "CURSOR (HANGAR / BREAK)" },
]], [[{ "D-PAD DOWN", "CURSOR (HANGAR / BREAK)" },
		{ "VIEW", "HUD BUTTONS IN A RUN" }, -- (0.19.30: offers, test range switches; ConsoleNav)
]] },
})
return table.concat(log, ", ")
