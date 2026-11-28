-- 0.19.40 part 2: the AIRCRAFT screen's WEAPONS block becomes three slot rows (StarterGui GunshipUI_Template.Aircraft
-- .Specs.Loadout: Row1-3 with Key, Weapon, From, Swap) and AircraftUI fills them; SWAP cycles that slot through the
-- same slot's weapon on every other aircraft you own, then back (Mission action SwapGun). One swap per aircraft.
-- Run in a place (execute_luau, Edit) after part 1. Idempotent (rebuilds Loadout).
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

-- the GUI (real instances in StarterGui)
local sp = game.StarterGui.GunshipUI_Template.Aircraft.Specs
local FONT = sp.Weapons.FontFace
local YEL = Color3.fromRGB(245, 197, 24)
local TXT = Color3.fromRGB(236, 232, 214)
local SUB = Color3.fromRGB(150, 156, 140)
local old = sp:FindFirstChild("Loadout")
if old then
	old:Destroy()
end
local hint = sp:FindFirstChild("SwapHint")
if hint then
	hint:Destroy()
end
sp.Weapons.Visible = false -- (the old text list; AircraftUI still fills it)
local function label(parent, name, text, x, y, w, h, size, col, align)
	local l = Instance.new("TextLabel")
	l.Name = name
	l.BackgroundTransparency = 1
	l.Position = UDim2.fromOffset(x, y)
	l.Size = UDim2.fromOffset(w, h)
	l.FontFace = FONT
	l.TextSize = size
	l.TextColor3 = col
	l.TextXAlignment = align or Enum.TextXAlignment.Left
	l.TextYAlignment = Enum.TextYAlignment.Center
	l.TextTruncate = Enum.TextTruncate.AtEnd
	l.Text = text
	l.Parent = parent
	return l
end
hint = label(sp, "SwapHint", "1 SWAP FROM YOUR OTHER AIRCRAFT", 150, 288, 266, 32, 13, SUB, Enum.TextXAlignment.Right)
local lo = Instance.new("Frame")
lo.Name = "Loadout"
lo.BackgroundTransparency = 1
lo.Position = UDim2.fromOffset(24, 324)
lo.Size = UDim2.new(1, -48, 0, 104)
lo.Parent = sp
for i = 1, 3 do
	local row = Instance.new("Frame")
	row.Name = "Row" .. i
	row.BackgroundTransparency = 1
	row.Position = UDim2.fromOffset(0, (i - 1) * 35)
	row.Size = UDim2.new(1, 0, 0, 32)
	row.Parent = lo
	local key = label(row, "Key", tostring(i), 0, 3, 26, 26, 18, Color3.fromRGB(22, 22, 16), Enum.TextXAlignment.Center)
	key.BackgroundTransparency = 0
	key.BackgroundColor3 = YEL
	key.BorderSizePixel = 0
	-- the weapon's name (one tall line: phones boost text up to the label's height), "// B-52" when swapped in
	local w = label(row, "Weapon", "", 34, 0, 250, 32, 20, TXT)
	w.RichText = true
	local b = Instance.new("TextButton")
	b.Name = "Swap"
	b.AutoButtonColor = true
	b.BackgroundColor3 = Color3.fromRGB(42, 46, 33)
	b.BorderSizePixel = 0
	b.AnchorPoint = Vector2.new(1, 0)
	b.Position = UDim2.new(1, 0, 0, 3)
	b.Size = UDim2.fromOffset(84, 26)
	b.FontFace = FONT
	b.TextSize = 16
	b.TextColor3 = TXT
	b.Text = "SWAP"
	b.Parent = row
	local st = Instance.new("UIStroke")
	st.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	st.Color = YEL
	st.Thickness = 1.5
	st.Parent = b
end
table.insert(log, "Specs.Loadout built")

patch(game.StarterPlayer.StarterPlayerScripts.AircraftUI, {
	{ "for _, a in ipairs({ \"Planes\", \"Plane\", \"Rank\", \"Gems\" }) do\n", "for _, a in ipairs({ \"Planes\", \"Plane\", \"Rank\", \"Gems\", \"Swaps\" }) do\n" },
	{ "\tfunction boardsDraw()\n", [[	-- (0.19.40) WEAPONS: the three slots (Specs.Loadout, built in StarterGui). SWAP (aircraft you own) cycles that
	-- slot through the same slot's weapon on every other aircraft you own, then back to its own: one swap per
	-- aircraft, so swapping another slot puts the first one back (Mission SwapGun, Aircraft.gunsOf).
	local Loadout = Specs:WaitForChild("Loadout")
	local SLOTS = { "25mm", "40mm", "105mm" }
	local function swapChoices(def, slot: string): { string }
		local own = owned()
		local list = { "" }
		if own[def.id] then
			for _, d in ipairs(Aircraft.LIST) do
				if d.id ~= def.id and own[d.id] and d.ready then
					table.insert(list, slot .. ":" .. d.id)
				end
			end
		end
		return list
	end
	local function drawLoadout(def)
		local guns = Aircraft.gunsOf(def.id, Aircraft.swapOf(player:GetAttribute("Swaps"), def.id))
		for i, slot in ipairs(SLOTS) do
			local row = Loadout:FindFirstChild("Row" .. i)
			if row then
				local e = if guns then guns[slot] else nil
				local from = e and e.from and Aircraft.BY_ID[e.from]
				row.Weapon.Text = Aircraft.gunName(e, slot) .. (if from then "  <font color=\"#F5C518\">// " .. from.short .. "</font>" else "")
				row.Swap.Visible = #swapChoices(def, slot) > 1
				row.Swap.Text = if from then "NEXT" else "SWAP"
			end
		end
	end
	for i, slot in ipairs(SLOTS) do
		local row = Loadout:FindFirstChild("Row" .. i)
		if row then
			row.Swap.Activated:Connect(function()
				local def = Aircraft.BY_ID[sel]
				if not def then
					return
				end
				local list = swapChoices(def, slot)
				local cur = Aircraft.swapOf(player:GetAttribute("Swaps"), def.id) or ""
				local k = table.find(list, cur) or 1
				SFX.play("Click", { vol = 0.6, pitch = 1.1 })
				Action:FireServer("SwapGun", def.id, list[k % #list + 1])
			end)
		end
	end

	function boardsDraw()
]] },
	{ "\t\t\tSpecs.Weapons.Text = table.concat(def.weapons, \"\\n\")\n", "\t\t\tSpecs.Weapons.Text = table.concat(def.weapons, \"\\n\")\n\t\t\tdrawLoadout(def)\n" },
})
return table.concat(log, ", ")
