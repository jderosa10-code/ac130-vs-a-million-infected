-- 0.19.15: crew boosts, SUPPLY CRATE, VIP pass, TEST FLIGHT. Run in a place (execute_luau, Edit) on top of 0.19.14.
-- Idempotent: every step skips itself when it's already there. Scripts are patched in place (anchors), new scripts
-- and UI are made from copies of what's already in the place (DailyUI, the FREE tile, a pass card, the aircraft
-- bay's RETURN TO HANGAR button, the HUD's AUTO-SKIP button).
local SES = game:GetService("ScriptEditorService")
local log = {}
local function setSource(scr, src)
	SES:UpdateSourceAsync(scr, function()
		return src
	end)
end
local function patch(scr, list)
	local src = scr.Source
	local changed = false
	for _, p in ipairs(list) do
		if src:find(p[2], 1, true) then
			continue
		end
		local a, b = src:find(p[1], 1, true)
		if not a then
			error("anchor not found in " .. scr.Name .. ": " .. p[1]:sub(1, 80))
		end
		if p[3] == "all" then
			local out, i = {}, 1
			while true do
				local x, y = src:find(p[1], i, true)
				if not x then
					break
				end
				table.insert(out, src:sub(i, x - 1))
				table.insert(out, p[2])
				i = y + 1
			end
			table.insert(out, src:sub(i))
			src = table.concat(out)
		else
			if src:find(p[1], b + 1, true) then
				error("anchor twice in " .. scr.Name .. ": " .. p[1]:sub(1, 80))
			end
			src = src:sub(1, a - 1) .. p[2] .. src:sub(b + 1)
		end
		changed = true
	end
	if changed then
		setSource(scr, src)
	end
	table.insert(log, scr.Name .. (if changed then " patched" else " ok"))
end
local function script(class, parent, name, src)
	local s = parent:FindFirstChild(name)
	if not s then
		s = Instance.new(class)
		s.Name = name
		s.Source = src
		s.Parent = parent
		table.insert(log, name .. " made")
	elseif s.Source ~= src then
		setSource(s, src)
		table.insert(log, name .. " updated")
	end
end
local RS = game.ReplicatedStorage.Convoy
local CS = game.ServerScriptService.ConvoyServer
local SPS = game.StarterPlayer.StarterPlayerScripts
local SG = game.StarterGui

---------------------------------------------------------------- Shop
patch(RS.Shop, {
	{ "\nreturn Shop", [[

-- CREW BOOSTS (0.19.15): one gunner buys it in a run, the whole crew gets it for the rest of that run (Mission
-- applyBattle; Convoy attributes CrewGems / CrewCash while it's on). productId 0 = not made on Roblox yet: no tile,
-- no offer. CrewGems is a tile next to FORTIFY / UNLIMITED AMMO; CrewCash an offer at the break after wave 1.
Shop.BATTLE.CrewGems = { productId = 0, icon = "rbxassetid://123347650772280", accent = "AMBER", price = 99,
	title = "2X GEMS FOR THE CREW", text = "Everyone in your crew gets double gems from this run" }
Shop.BATTLE.CrewCash = { productId = 0, icon = "rbxassetid://98297140331734", accent = "LIME", price = 49,
	title = "2X CASH FOR THE CREW", text = "Everyone in your crew gets double cash for the rest of this run" }

-- VIP pass (0.19.15): a gold name over your head, [VIP] in the chat, +10% gems from every run (Mission). passId 0 =
-- not made on Roblox yet (the shop card says SOON). Key isn't Pass_VIP: that one is the Free Nuke pass's old key.
table.insert(Shop.PASSES, { key = "Pass_VIPGold", passId = 0, name = "VIP", icon = "rbxassetid://123054708154085",
	sub = "GOLD NAME, VIP CHAT TAG, +10% GEMS", price = 249 })

-- SUPPLY CRATE (0.19.15): spin for a prize. A free spin every FREE_EVERY seconds, more with Robux (PACKS, developer
-- products; productId 0 = not made yet, shows SOON). Saved spins never run out. Prizes use the daily drop's format
-- (Shop.dailyLook): gems, or runs of a boost. w = weight; every card shows its odds (Shop.crateOdds).
-- Server: ConvoyServer.Crate. Client: CrateUI (the SPIN tile on the hub).
Shop.CRATE = {
	FREE_EVERY = 8 * 3600,
	PACKS = {
		{ key = "Crate_1", spins = 1, productId = 0, price = 25 },
		{ key = "Crate_5", spins = 5, productId = 0, price = 99 },
	},
	PRIZES = {
		{ gems = 100, w = 34 },
		{ gems = 300, w = 20 },
		{ boost = "Cash", n = 1, w = 14 },
		{ boost = "Gems", n = 1, w = 13 },
		{ boost = "Nuke", n = 1, w = 9 },
		{ boost = "Ammo", n = 1, w = 7 },
		{ gems = 2500, w = 3 },
	},
}
-- the chance of prize i, in percent
function Shop.crateOdds(i: number): number
	local total = 0
	for _, r in ipairs(Shop.CRATE.PRIZES) do
		total += r.w
	end
	return Shop.CRATE.PRIZES[i].w / total * 100
end

return Shop]] },
})

---------------------------------------------------------------- Mission
patch(CS.Mission, {
	{ [[	if Shared:GetAttribute("DebugNoSave") and game:GetService("RunService"):IsStudio() then
		return -- (Studio test runs that must not touch the real save: set DebugNoSave on Convoy in the play session)
	end
]], [[	if Shared:GetAttribute("DebugNoSave") and game:GetService("RunService"):IsStudio() then
		return -- (Studio test runs that must not touch the real save: set DebugNoSave on Convoy in the play session)
	end
	if Shared:GetAttribute("TestFlight") then
		return -- TEST FLIGHT (0.19.15): nothing on a test flight is kept (Lobbies sets it on a test server)
	end
]] },
	{ [[				if c.boostCash then
					gain *= 2 -- season reward: 2x cash this run
				end
]], [[				if c.boostCash then
					gain *= 2 -- season reward: 2x cash this run
				end
				if Shared:GetAttribute("CrewCash") then
					gain *= 2 -- CREW 2X CASH (Robux: one gunner bought it for the whole crew)
				end
]] },
	{ [[	running = true
	setAttr("State", "Running")
	Ranks.runStart(crewList())

	-- set the DebugStartWave attribute on ReplicatedStorage.Convoy in Studio to jump ahead (e.g. 8 to see every type)
	wave = math.max(0, (Shared:GetAttribute("DebugStartWave") or 1) - 1)]], [[	setAttr("CrewGems", nil) -- (crew boosts last one run)
	setAttr("CrewCash", nil)
	running = true
	setAttr("State", "Running")
	Ranks.runStart(crewList())

	-- set the DebugStartWave attribute on ReplicatedStorage.Convoy in Studio to jump ahead (e.g. 8 to see every type)
	-- (TEST FLIGHT: straight into wave 4, plenty to shoot at)
	wave = math.max(0, (Shared:GetAttribute("DebugStartWave") or (if Shared:GetAttribute("TestFlight") then 4 else 1)) - 1)]] },
	{ [[		local left = if wave == 0 then 10 elseif leader and leader:GetAttribute("AutoSkip") then 2.5 else BREAK_TIME]],
		[[		local left = if Shared:GetAttribute("TestFlight") then 5 elseif wave == 0 then 10 elseif leader and leader:GetAttribute("AutoSkip") then 2.5 else BREAK_TIME]] },
	{ [[		acc.toSpawn = 0
		if alive() then
			addCash(100 + wave * 20) -- wave clear bonus]], [[		acc.toSpawn = 0
		if Shared:GetAttribute("TestFlight") and alive() then
			-- TEST FLIGHT: one wave, then back to the hangar
			setAttr("Result", "TEST FLIGHT OVER")
			task.wait(2)
			failReason = "TEST FLIGHT OVER"
			break
		end
		if alive() then
			addCash(100 + wave * 20) -- wave clear bonus]] },
	{ [[	running = false
	local cleared = math.max(0, wave - 1)
	local gems = cleared * Upgrades.GEMS_PER_WAVE]], [[	running = false
	if Shared:GetAttribute("TestFlight") then
		-- TEST FLIGHT: nothing earned and no results screen, straight back to the hangar (a test server's Lobbies
		-- sends the pilot home when State goes back to Menu)
		setAttr("Result", failReason or "TEST FLIGHT OVER")
		clearCrew()
		setAttr("State", "Menu")
		task.wait(0.5)
		Enemies.clear()
		Ballistics.clear()
		boss = nil
		pilot = nil
		return
	end
	local cleared = math.max(0, wave - 1)
	local gems = cleared * Upgrades.GEMS_PER_WAVE]] },
	{ [[			mine = math.floor(mine * Ranks.mult(p)) -- rank bonus
			if c.plane and c.plane.perk and c.plane.perk.gemMul then]], [[			mine = math.floor(mine * Ranks.mult(p)) -- rank bonus
			if Shared:GetAttribute("CrewGems") then
				mine *= 2 -- CREW 2X GEMS (Robux: one gunner bought it for the whole crew)
			end
			if p:GetAttribute("Pass_VIPGold") then
				mine = math.floor(mine * 1.1) -- VIP pass: +10% gems
			end
			if c.plane and c.plane.perk and c.plane.perk.gemMul then]] },
	{ [[	if secondChanceUsed or Shared:GetAttribute("Tutorial") then
		return false
	end
	secondChanceUsed, secondChanceBought = true, false]], [[	if secondChanceUsed or Shared:GetAttribute("Tutorial") or Shared:GetAttribute("TestFlight") then
		return false -- (no SECOND CHANCE on a test flight: it just ends)
	end
	secondChanceUsed, secondChanceBought = true, false]] },
	{ [[StartRun.Event:Connect(function(players, mode, kind)
	lastMode = mode or "Normal"
	if kind == "tutorial" then
		if players[1] then
			startTutorial(players[1])
		end
	else]], [[StartRun.Event:Connect(function(players, mode, kind, plane)
	lastMode = mode or "Normal"
	if kind == "tutorial" then
		if players[1] then
			startTutorial(players[1])
		end
	elseif kind == "test" then
		-- TEST FLIGHT (0.19.15): the aircraft bay's TEST FLIGHT button. One pilot, the aircraft they picked (owned or
		-- not), straight into a wave. Nothing is saved (saveProfile), no Robux offers, no second chance, no results:
		-- it ends after one wave, when the bunker falls, or on EXIT ("ExitTest"). A test server's Lobbies sends them home.
		local p = players[1]
		if not p or busy or running then
			return
		end
		local old = p:GetAttribute("Plane")
		local def = Aircraft.BY_ID[plane or ""]
		setAttr("TestFlight", true)
		if def and def.ready and Aircraft.shown(def.id) then
			p:SetAttribute("Plane", def.id)
		end
		startRun({ p }, "Normal")
		if role() == "Studio" then
			p:SetAttribute("Plane", old) -- (Studio: the same server carries on as the hangar)
			setAttr("TestFlight", nil)
		end
	else]] },
	{ [[	elseif kind == "GiveUp" then
		-- end the run: from the Second Chance countdown]], [[	elseif kind == "ExitTest" then
		-- TEST FLIGHT's EXIT button: end it now
		if Shared:GetAttribute("TestFlight") and running and crew[player] then
			failReason = failReason or "TEST FLIGHT OVER"
		end
	elseif kind == "GiveUp" then
		-- end the run: from the Second Chance countdown]] },
	{ [[			addCash(ShopCfg.cashDrop(wave), p)
			return true
		end
		return false
	end]], [[			addCash(ShopCfg.cashDrop(wave), p)
			return true
		elseif key == "CrewGems" or key == "CrewCash" then
			-- CREW BOOST (0.19.15): the whole crew, the rest of this run (read where gems / cash are paid)
			if Shared:GetAttribute(key) then
				return false -- already on: gems back
			end
			setAttr(key, true)
			return true
		end
		return false
	end]] },
	{ [[	MarketplaceService.ProcessReceipt = function(info)
		local player = Players:GetPlayerByUserId(info.PlayerId)]], [[	MarketplaceService.ProcessReceipt = function(info)
		if Shared:GetAttribute("TestFlight") then
			return Enum.ProductPurchaseDecision.NotProcessedYet -- TEST FLIGHT: nothing is saved here; Roblox asks again back in the hangar
		end
		local player = Players:GetPlayerByUserId(info.PlayerId)]] },
})

---------------------------------------------------------------- Lobbies
patch(CS.Lobbies, {
	{ [[	if type(data) == "table" and data.kind == "tutorial" then
		dest = "TRAINING"
	end]], [[	if type(data) == "table" and data.kind == "tutorial" then
		dest = "TRAINING"
	elseif type(data) == "table" and data.kind == "test" then
		dest = "TEST FLIGHT"
	end]] },
	{ [[		StartRun:Fire(present, plan.mode or "Normal", plan.kind)]], [[		StartRun:Fire(present, plan.mode or "Normal", plan.kind, plan.plane)]] },
	{ [[		if not plan and data.kind then
			plan = data
]], [[		if not plan and data.kind then
			plan = data
			if plan.kind == "test" then
				Shared:SetAttribute("TestFlight", true) -- (nothing on this server is saved: Mission saveProfile)
			end
]] },
	{ [[		if plan and plan.kind == "tutorial" and Shared:GetAttribute("State") == "Menu" and started then]],
		[[		if plan and (plan.kind == "tutorial" or plan.kind == "test") and Shared:GetAttribute("State") == "Menu" and started then]] },
	{ [[-- Settings > REPLAY TUTORIAL on a live server:]], [[-- TEST FLIGHT (0.19.15): the aircraft bay's TEST FLIGHT button. Studio: it runs right here. A hangar server: a fresh
-- server of the default map of your own (kind "test"; nothing is saved there, see Mission). Not from a run.
do
	local Aircraft = require(Shared:WaitForChild("Aircraft"))
	local asked = {}
	Action.OnServerEvent:Connect(function(p, kind, id)
		if kind ~= "TestFlight" or asked[p] or role == "Mission" then
			return
		end
		local def = type(id) == "string" and Aircraft.BY_ID[id]
		if not def or not def.ready or not Aircraft.shown(id) or not p:GetAttribute("ProfileLoaded") then
			return
		end
		if Shared:GetAttribute("State") == "Running" then
			return
		end
		asked[p] = true
		task.delay(10, function()
			asked[p] = nil
		end)
		if role == "Studio" then
			StartRun:Fire({ p }, "Normal", "test", id)
		else
			if partyOf[p] then
				leave(p)
			end
			p:SetAttribute("LobbyNotice", "LOADING YOUR TEST FLIGHT...")
			local ok, msg = toNewServer({ p }, { kind = "test", plane = id, crew = { p.UserId }, lobby = homeJob() })
			if not ok then
				p:SetAttribute("LobbyNotice", msg)
			end
		end
	end)
end

-- Settings > REPLAY TUTORIAL on a live server:]] },
})

---------------------------------------------------------------- Cosmetics (crate save hooks)
patch(CS.Cosmetics, {
	{ [[	require(script.Parent.Codes).load(p, data)
]], [[	require(script.Parent.Codes).load(p, data)
	require(script.Parent.Crate).load(p, data)
]] },
	{ [[	require(script.Parent.Codes).save(p, data)
]], [[	require(script.Parent.Codes).save(p, data)
	require(script.Parent.Crate).save(p, data)
]] },
	{ [[function Cosmetics.grantProduct(p: Player, productId: number): boolean
]], [[function Cosmetics.grantProduct(p: Player, productId: number): boolean
	if require(script.Parent.Crate).grantProduct(p, productId) then -- SUPPLY CRATE spins
		return true
	end
]] },
})

script("ModuleScript", CS, "Crate", [==[-- SUPPLY CRATE (0.19.15): spin for a prize (Convoy.Shop.CRATE). A free spin every CRATE.FREE_EVERY seconds, more
-- spins bought with Robux (CRATE.PACKS). Saved on the profile as data.Crate = { s = spins, f = free spin time,
-- p = a prize not paid out yet } (Cosmetics load / save hooks). Action "SpinCrate": uses the free spin if it's ready,
-- else a saved one, and tells the client the prize at once (CrateResult = "prize index|clock") so its light can
-- land on it. The prize itself (gems, or runs of a boost) is paid PAY_AFTER seconds later, as the light lands: it's
-- saved as pending first, so leaving mid-spin can't lose it (paid on the next join).
local Players = game:GetService("Players")
local Shared = game:GetService("ReplicatedStorage"):WaitForChild("Convoy")
local Shop = require(Shared:WaitForChild("Shop"))
local Action = Shared:WaitForChild("Remotes"):WaitForChild("Action")

local Crate = {}
local rng = Random.new()
local PAY_AFTER = 3

local function pay(p: Player, i: number)
	local r = Shop.CRATE.PRIZES[i]
	if not r then
		return
	end
	if r.gems then
		p:SetAttribute("Gems", (p:GetAttribute("Gems") or 0) + r.gems)
	end
	if r.boost then
		local k = "Boost_" .. r.boost
		p:SetAttribute(k, (p:GetAttribute(k) or 0) + (r.n or 1))
	end
end

function Crate.load(p: Player, data)
	local c = type(data) == "table" and type(data.Crate) == "table" and data.Crate or {}
	p:SetAttribute("CrateSpins", math.max(0, math.floor(tonumber(c.s) or 0)))
	p:SetAttribute("CrateFreeAt", tonumber(c.f) or 0)
	p:SetAttribute("CratePending", nil)
	if tonumber(c.p) then
		pay(p, tonumber(c.p)) -- spun, then left before it was paid
	end
end

function Crate.save(p: Player, data)
	data.Crate = { s = p:GetAttribute("CrateSpins") or 0, f = p:GetAttribute("CrateFreeAt") or 0, p = p:GetAttribute("CratePending") }
end

local function save(p: Player)
	local sn = script.Parent:FindFirstChild("SaveNow")
	if sn then
		task.spawn(function()
			pcall(sn.Invoke, sn, p)
		end)
	end
end

-- Robux spins (from Cosmetics.grantProduct)
function Crate.grantProduct(p: Player, productId: number): boolean
	for _, pack in ipairs(Shop.CRATE.PACKS) do
		if pack.productId > 0 and pack.productId == productId then
			p:SetAttribute("CrateSpins", (p:GetAttribute("CrateSpins") or 0) + pack.spins)
			save(p)
			return true
		end
	end
	return false
end

local function roll(): number
	local total = 0
	for _, r in ipairs(Shop.CRATE.PRIZES) do
		total += r.w
	end
	local x = rng:NextNumber() * total
	for i, r in ipairs(Shop.CRATE.PRIZES) do
		x -= r.w
		if x <= 0 then
			return i
		end
	end
	return 1
end

Action.OnServerEvent:Connect(function(p: Player, kind)
	if kind ~= "SpinCrate" or p:GetAttribute("CratePending") or not p:GetAttribute("ProfileLoaded") or Shared:GetAttribute("TestFlight") then
		return
	end
	local now = os.time()
	local free = now >= (p:GetAttribute("CrateFreeAt") or 0)
	local spins = p:GetAttribute("CrateSpins") or 0
	if not free and spins <= 0 then
		return
	end
	if free then
		p:SetAttribute("CrateFreeAt", now + Shop.CRATE.FREE_EVERY)
	else
		p:SetAttribute("CrateSpins", spins - 1)
	end
	local i = roll()
	p:SetAttribute("CratePending", i)
	p:SetAttribute("CrateResult", i .. "|" .. os.clock())
	save(p)
	task.delay(PAY_AFTER, function()
		if p.Parent and p:GetAttribute("CratePending") == i then
			p:SetAttribute("CratePending", nil)
			pay(p, i)
			save(p)
		end
	end)
end)

return Crate
]==])

---------------------------------------------------------------- BattleOffers (crew boosts; nothing on a test flight)
patch(SPS.BattleOffers, {
	{ [[	return Shared:GetAttribute("State") == "Running" and not Shared:GetAttribute("Tutorial")
		and player:GetAttribute("Screen") == "HUD" and (Shared:GetAttribute("SecondChanceLeft") or 0) == 0
end]], [[	return Shared:GetAttribute("State") == "Running" and not Shared:GetAttribute("Tutorial")
		and player:GetAttribute("Screen") == "HUD" and (Shared:GetAttribute("SecondChanceLeft") or 0) == 0
		and not Shared:GetAttribute("TestFlight")
end]] },
	{ [[	local want = Shared:GetAttribute("State") == "Running" and not Shared:GetAttribute("Tutorial")
		and player:GetAttribute("Screen") == "HUD"]], [[	local want = Shared:GetAttribute("State") == "Running" and not Shared:GetAttribute("Tutorial")
		and not Shared:GetAttribute("TestFlight") and player:GetAttribute("Screen") == "HUD"]] },
	{ [[local NAMES = { Repair = "a FORTIFY",]], [[local NAMES = { CrewGems = "2X GEMS FOR THE CREW", CrewCash = "2X CASH FOR THE CREW", Repair = "a FORTIFY",]] },
	{ [[local QUICK = { "Repair", "Ammo" }
]], [[local QUICK = { "Repair", "Ammo" }
-- CREW 2X GEMS (0.19.15) gets a tile once its product is made (Shop.BATTLE.CrewGems.productId)
if (Shop.BATTLE.CrewGems and Shop.BATTLE.CrewGems.productId or 0) > 0 then
	table.insert(QUICK, "CrewGems")
end
-- CREW 2X CASH: offered once a run, at the break after wave 1 (once its product is made)
Shared:GetAttributeChangedSignal("Phase"):Connect(function()
	if Shared:GetAttribute("Phase") == "Break" and (Shared:GetAttribute("Wave") or 0) == 1
		and (Shop.BATTLE.CrewCash and Shop.BATTLE.CrewCash.productId or 0) > 0 then
		task.delay(3, function()
			if inRun() and not Shared:GetAttribute("CrewCash") then
				once("CrewCash", 99)
			end
		end)
	end
end)
]] },
	{ [[local QUICK_INFO = { Repair = "FULL REPAIR + 25 MAX HEALTH",]], [[local QUICK_INFO = { CrewGems = "DOUBLE GEMS FOR YOUR WHOLE CREW THIS RUN", Repair = "FULL REPAIR + 25 MAX HEALTH",]] },
	{ [[if key == "Ammo" then "UNLIMITED\nAMMO" else "FORTIFY"]], [[if key == "Ammo" then "UNLIMITED\nAMMO" elseif key == "CrewGems" then "CREW\n2X GEMS" else "FORTIFY"]] },
	{ [[		if key == "Ammo" and player:GetAttribute("UnlimitedAmmo") then
			return -- already on for this run
		end]], [[		if key == "Ammo" and player:GetAttribute("UnlimitedAmmo") then
			return -- already on for this run
		end
		if key == "CrewGems" and Shared:GetAttribute("CrewGems") then
			return -- someone in the crew already bought it
		end]] },
	{ [[			l.Text = ROBUX .. " " .. priceOf(key)]], [[			l.Text = if key == "CrewGems" and Shared:GetAttribute("CrewGems") then "ACTIVE" else ROBUX .. " " .. priceOf(key)]], "all" },
})

---------------------------------------------------------------- OverheadTags (VIP: gold name)
patch(SPS.OverheadTags, {
	{ [[	root.Top.PlayerName.Text = p.DisplayName
]], [[	root.Top.PlayerName.Text = p.DisplayName
	-- VIP pass (0.19.15): a gold name
	root.Top.PlayerName.TextColor3 = if p:GetAttribute("Pass_VIPGold") then Color3.fromRGB(255, 200, 40) else Color3.new(1, 1, 1)
]] },
	{ [[	for _, k in ipairs({ "Plane", "Rank", "BestWave" }) do]], [[	for _, k in ipairs({ "Plane", "Rank", "BestWave", "Pass_VIPGold" }) do]] },
})

script("LocalScript", SPS, "VipChat", [==[-- VIP pass (0.19.15, Convoy.Shop.PASSES Pass_VIPGold): [VIP] in gold before a VIP's name in the chat.
local Players = game:GetService("Players")
local TextChatService = game:GetService("TextChatService")
TextChatService.OnIncomingMessage = function(msg: TextChatMessage)
	local props = Instance.new("TextChatMessageProperties")
	local src = msg.TextSource
	local p = src and Players:GetPlayerByUserId(src.UserId)
	if p and p:GetAttribute("Pass_VIPGold") then
		props.PrefixText = '<font color="#FFC828">[VIP]</font> ' .. msg.PrefixText
	end
	return props
end
]==])

---------------------------------------------------------------- UI (copies of what's there)
local T = SG.GunshipUI_Template
-- hub: SPIN tile under FREE (copy of FREE, with SEASON's red dot)
local side = T.Menu.Side
if not side:FindFirstChild("Crate") then
	local tile = side.Free:Clone()
	tile.Name = "Crate"
	tile.Position = UDim2.fromOffset(0, side.Free.Position.Y.Offset + (side.Free.Position.Y.Offset - side.Season.Position.Y.Offset))
	tile.Face.LabelBar.Label.Text = "SPIN"
	local dot = side.Season:FindFirstChild("Dot")
	if dot and not tile:FindFirstChild("Dot") then
		dot:Clone().Parent = tile
	end
	tile.Parent = side
	side.Size = UDim2.fromOffset(side.Size.X.Offset, tile.Position.Y.Offset + tile.Size.Y.Offset)
	table.insert(log, "Crate tile made")
end
-- aircraft bay: TEST FLIGHT above the BACK / EQUIP / NEXT bar (copy of RETURN TO HANGAR)
local controls = T.Aircraft.Controls
if not controls:FindFirstChild("Test") then
	local b = T.Aircraft.Bottom.Exit:Clone()
	b.Name = "Test"
	b.AnchorPoint = Vector2.new(0.5, 1)
	b.Size = UDim2.fromOffset(340, 76)
	b.Position = UDim2.new(0.5, 0, 0, -14)
	b.Face.Label.Text = "TEST FLIGHT"
	b.Face.Label.TextSize = 44
	b.Parent = controls
	table.insert(log, "Test button made")
end
-- HUD: EXIT TEST FLIGHT under AUTO-SKIP (copy of it), only shown on a test flight
local top = T.HUD.Top
if not top:FindFirstChild("ExitTest") then
	local b = top.Auto:Clone()
	b.Name = "ExitTest"
	b.Size = UDim2.fromOffset(250, 44)
	b.Position = UDim2.fromOffset(top.Auto.Position.X.Offset, top.Auto.Position.Y.Offset + top.Auto.Size.Y.Offset + 6)
	b.Face.Label.Text = "EXIT TEST FLIGHT"
	b.Visible = false
	b.Parent = top
	table.insert(log, "ExitTest button made")
end
-- shop: VIP card in PASSES, next to UNLIMITED AMMO (copy of NO CIV HITS)
local page = SG.ShopUI.Panel.Page
if not page:FindFirstChild("Card_Pass_VIPGold") then
	local src = page.Card_Pass_NoCiv
	local c = src:Clone()
	c.Name = "Card_Pass_VIPGold"
	c:SetAttribute("Key", "Pass_VIPGold")
	c.Position = UDim2.fromOffset(page.Card_Boost_Ammo.Position.X.Offset + (page.Card_Boost_Ammo.Position.X.Offset - src.Position.X.Offset), src.Position.Y.Offset)
	c.ItemName.Text = "VIP"
	c.Sub.Text = "GOLD NAME, VIP CHAT TAG, +10% GEMS"
	local icon = c.Art:FindFirstChild("Icon")
	if icon then
		icon.Image = "rbxassetid://123054708154085"
		icon.ImageRectOffset, icon.ImageRectSize = Vector2.zero, Vector2.zero
	end
	c.Parent = page
	table.insert(log, "VIP card made")
end
-- SUPPLY CRATE panel (copy of the daily drop panel)
if not SG:FindFirstChild("CrateUI") then
	local g = SG.DailyUI:Clone()
	g.Name = "CrateUI"
	g.Enabled = false
	local p = g.Panel
	p.Header.Title.Text = "SUPPLY CRATE"
	p.Header.Sub.Text = "S P I N   F O R   L O O T"
	p.Days.Name = "Prizes"
	for d = 1, 7 do
		local card = p.Prizes:FindFirstChild("Day" .. d)
		card.Name = "Prize" .. d
		card.DayLabel.Text = ""
		if card:FindFirstChild("Done") then
			card.Done:Destroy()
		end
	end
	p.Streak.Name = "Status"
	p.Status.Text = "FREE SPIN READY"
	p.Hint.Name = "Odds"
	p.Odds.Text = "ODDS ARE ON EVERY CARD. SAVED SPINS NEVER RUN OUT."
	p.Claim.Name = "Spin"
	p.Spin.Label.Text = "SPIN"
	p.Remind.Name = "Buy5"
	p.Buy5.Label.Text = "5 SPINS"
	g.Parent = SG
	table.insert(log, "CrateUI made")
end

script("LocalScript", SPS, "CrateUI", [==[-- CrateUI (0.19.15): the SUPPLY CRATE (StarterGui.CrateUI, a copy of the daily drop panel). Opens from the SPIN
-- tile on the hub (red dot when a free spin is ready or spins are saved). Seven prize cards, each with its odds
-- (Shop.CRATE.PRIZES, Shop.crateOdds). SPIN uses the free spin (every CRATE.FREE_EVERY), else a saved one, else
-- asks to buy one with Robux and spins when it lands; 5 SPINS buys five. A light runs round the cards and stops on
-- the prize. Server: ConvoyServer.Crate ("SpinCrate"; attributes CrateSpins, CrateFreeAt, CrateResult).
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local MarketplaceService = game:GetService("MarketplaceService")

local player = Players.LocalPlayer
local Shared = game:GetService("ReplicatedStorage"):WaitForChild("Convoy")
local Shop = require(Shared:WaitForChild("Shop"))
local SFX = require(Shared:WaitForChild("SFX"))
local Icons = require(Shared:WaitForChild("Icons"))
local Action = Shared:WaitForChild("Remotes"):WaitForChild("Action")
local pgui = player:WaitForChild("PlayerGui")
local gui = pgui:WaitForChild("CrateUI")
local panel = gui:WaitForChild("Panel")
local cards = panel:WaitForChild("Prizes")
local spinB = panel:WaitForChild("Spin")
local buy5 = panel:WaitForChild("Buy5")
local close = panel:WaitForChild("Header"):WaitForChild("Close")
local tile = pgui:WaitForChild("GunshipUI"):WaitForChild("Menu"):WaitForChild("Side"):WaitForChild("Crate")
local C = Shop.CRATE
local N = #C.PRIZES

local ROBUX = utf8.char(0xE002)
local Y = Color3.fromRGB(245, 197, 24)
local LINE = Color3.fromRGB(74, 78, 58)
local DARK = Color3.fromRGB(42, 46, 33)
local LIT = Color3.fromRGB(70, 62, 24)
local INK = Color3.fromRGB(22, 22, 16)
local TXT = Color3.fromRGB(236, 232, 214)

pcall(Icons.set, tile.Face.Icon, "gems_xl")
pcall(Icons.set, panel.Header.Icon, "gems_xl")

local function a(k, d)
	local v = player:GetAttribute(k)
	return if v == nil then d else v
end
local function freeIn(): number
	return math.max(0, a("CrateFreeAt", 0) - workspace:GetServerTimeNow())
end
local function hms(s: number): string
	s = math.ceil(s)
	local h, m = s // 3600, (s % 3600) // 60
	return if h > 0 then string.format("%dH %02dM", h, m) else string.format("%dM %02dS", m, s % 60)
end
local livePrice = {}
local function price(pack): string?
	if pack.productId <= 0 then
		return nil
	end
	if livePrice[pack.key] == nil then
		livePrice[pack.key] = pack.price
		task.spawn(function()
			local ok, info = pcall(MarketplaceService.GetProductInfo, MarketplaceService, pack.productId, Enum.InfoType.Product)
			if ok and info and info.PriceInRobux then
				livePrice[pack.key] = info.PriceInRobux
			end
		end)
	end
	return ROBUX .. " " .. livePrice[pack.key]
end

local lit = 0 -- the card the light is on (0 = none)
local spinning = false
local function paintCards()
	for i, r in ipairs(C.PRIZES) do
		local card = cards:FindFirstChild("Prize" .. i)
		if card then
			local amount, unit, icon = Shop.dailyLook(r)
			card.Amount.Text = amount
			card.Unit.Text = unit
			if string.sub(icon, 1, 13) == "rbxassetid://" then
				card.Icon.Image, card.Icon.ImageRectOffset, card.Icon.ImageRectSize = icon, Vector2.zero, Vector2.zero
			else
				Icons.set(card.Icon, icon)
			end
			local odds = Shop.crateOdds(i)
			card.DayLabel.Text = if odds < 1 then string.format("%.1f%%", odds) else string.format("%d%%", math.floor(odds + 0.5))
			local on = i == lit
			local jackpot = i == N
			card.Edge.Color = if on or jackpot then Y else LINE
			card.Edge.Thickness = if on then 3 else (if jackpot then 2 else 1)
			card.BackgroundColor3 = if on then LIT else DARK
		end
	end
end
local function setButton(b, text, on: boolean, size: number)
	b.ImageColor3 = if on then Y else DARK
	b.Edge.ImageColor3 = if on then Color3.fromRGB(255, 226, 120) else LINE
	b.Label.Text = text
	b.Label.TextColor3 = if on then INK else TXT
	b.Label.TextSize = size
end
local function refresh()
	paintCards()
	local free = freeIn() <= 0
	local spins = a("CrateSpins", 0)
	if not spinning then
		panel.Status.Text = if spins > 0 then string.format("SPINS: %d", spins) elseif free then "FREE SPIN READY" else "NO SPINS LEFT"
	end
	panel.Odds.Text = if free then "YOUR FREE SPIN IS READY. ODDS ARE ON EVERY CARD." else "NEXT FREE SPIN IN " .. hms(freeIn()) .. ". ODDS ARE ON EVERY CARD."
	local one = price(C.PACKS[1])
	if free then
		setButton(spinB, "FREE SPIN", true, 40)
	elseif spins > 0 then
		setButton(spinB, "SPIN", true, 44)
	else
		setButton(spinB, if one then "SPIN  " .. one else "SPIN  (SOON)", one ~= nil, 34)
	end
	local five = price(C.PACKS[2])
	setButton(buy5, if five then "5 SPINS  " .. five else "5 SPINS  (SOON)", false, 26)
	tile.Dot.Visible = free or spins > 0
end
for _, k in ipairs({ "CrateSpins", "CrateFreeAt" }) do
	player:GetAttributeChangedSignal(k):Connect(refresh)
end
refresh()

local function open(on: boolean)
	if on == gui.Enabled then
		return
	end
	gui.Enabled = on
	if on then
		refresh()
		local s = panel:FindFirstChild("FitScale")
		if s then
			local vp = workspace.CurrentCamera.ViewportSize
			-- kept below the top bar (settings gear, Roblox's buttons)
			local ok, r = pcall(function()
				return game:GetService("GuiService").TopbarInset
			end)
			local gap = if ok and r then r.Max.Y else 0
			panel.Position = UDim2.new(panel.Position.X.Scale, panel.Position.X.Offset, 0.5, gap / 2)
			local k = math.min(vp.X / 1060, (vp.Y - gap - 12) / 560, 1.25)
			s.Scale = k * 0.85
			TweenService:Create(s, TweenInfo.new(0.3, Enum.EasingStyle.Back), { Scale = k }):Play()
		end
	end
end

local function pressy(b: GuiButton)
	local sc = b:FindFirstChild("Press")
	if not sc then
		return
	end
	b.MouseEnter:Connect(function() TweenService:Create(sc, TweenInfo.new(0.1), { Scale = 1.05 }):Play() end)
	b.MouseLeave:Connect(function() TweenService:Create(sc, TweenInfo.new(0.1), { Scale = 1 }):Play() end)
	b.MouseButton1Down:Connect(function() TweenService:Create(sc, TweenInfo.new(0.06), { Scale = 0.94 }):Play() end)
	b.MouseButton1Up:Connect(function() TweenService:Create(sc, TweenInfo.new(0.1), { Scale = 1.05 }):Play() end)
end
pressy(spinB)
pressy(buy5)
pressy(close)
pressy(tile)

local function pop(card: GuiObject)
	local sc = card:FindFirstChild("Pop") or Instance.new("UIScale")
	sc.Name = "Pop"
	sc.Parent = card
	sc.Scale = 1.25
	TweenService:Create(sc, TweenInfo.new(0.4, Enum.EasingStyle.Back), { Scale = 1 }):Play()
end

-- the light runs round the cards while the server rolls, then slows down onto the prize
local wantSpin = false -- one spin bought with Robux: spin as soon as it lands
local function spin()
	if spinning then
		return
	end
	if freeIn() > 0 and a("CrateSpins", 0) <= 0 then
		local pack = C.PACKS[1]
		if pack.productId > 0 then
			SFX.play("Click", { vol = 0.6 })
			wantSpin = true
			MarketplaceService:PromptProductPurchase(player, pack.productId)
		else
			SFX.play("Click", { vol = 0.5, pitch = 0.7 })
		end
		return
	end
	spinning = true
	SFX.play("Click", { vol = 0.6 })
	local before = player:GetAttribute("CrateResult")
	Action:FireServer("SpinCrate")
	panel.Status.Text = "SPINNING..."
	task.spawn(function()
		local t0 = os.clock()
		local idx = if lit > 0 then lit else 1
		local result = nil
		while not result and os.clock() - t0 < 5 do
			idx = idx % N + 1
			lit = idx
			paintCards()
			SFX.play("Click", { vol = 0.25, pitch = 1.4 })
			task.wait(0.06)
			local r = player:GetAttribute("CrateResult")
			if r ~= before then
				result = tonumber(string.match(r or "", "^(%d+)|"))
			end
		end
		if not result then
			spinning, lit = false, 0
			refresh()
			return
		end
		-- two more laps, slowing down, landing on the prize
		local steps = 2 * N + (result - idx) % N
		for s = 1, steps do
			idx = idx % N + 1
			lit = idx
			paintCards()
			SFX.play("Click", { vol = 0.3, pitch = 1.2 + 0.4 * (1 - s / steps) })
			task.wait(0.05 + 0.3 * (s / steps) ^ 2.2)
		end
		local card = cards:FindFirstChild("Prize" .. result)
		if card then
			pop(card)
		end
		SFX.play("Buy", { pitch = if result == N then 0.8 else 1.1 })
		local amount, unit = Shop.dailyLook(C.PRIZES[result])
		panel.Status.Text = "YOU GOT " .. amount .. " " .. unit .. "!"
		task.wait(2.2)
		spinning = false
		refresh()
	end)
end
spinB.Activated:Connect(spin)
buy5.Activated:Connect(function()
	local pack = C.PACKS[2]
	if pack.productId > 0 then
		SFX.play("Click", { vol = 0.6 })
		MarketplaceService:PromptProductPurchase(player, pack.productId)
	else
		SFX.play("Click", { vol = 0.5, pitch = 0.7 })
	end
end)
MarketplaceService.PromptProductPurchaseFinished:Connect(function(_, id, bought)
	if id == C.PACKS[1].productId and not bought then
		wantSpin = false
	end
end)
player:GetAttributeChangedSignal("CrateSpins"):Connect(function()
	if wantSpin and a("CrateSpins", 0) > 0 and gui.Enabled then
		wantSpin = false
		task.delay(0.3, spin)
	end
end)
require(Shared:WaitForChild("PadNav")).on(close, function()
	SFX.play("Click", { vol = 0.5 })
	open(false)
end)
tile.Activated:Connect(function()
	if player:GetAttribute("Screen") == "Menu" then
		SFX.play("Click", { vol = 0.6 })
		open(true)
	end
end)

-- shut outside the hangar's main screen; the free-spin timer ticks while it's open
local nextTick = 0
RunService.Heartbeat:Connect(function()
	if gui.Enabled and player:GetAttribute("Screen") ~= "Menu" then
		open(false)
	end
	if os.clock() >= nextTick then
		nextTick = os.clock() + (if gui.Enabled then 1 else 10)
		if not spinning then
			refresh()
		end
	end
end)
]==])

script("LocalScript", SPS, "TestFlightUI", [==[-- TEST FLIGHT (0.19.15): the aircraft bay's TEST FLIGHT button (Aircraft.Controls.Test) flies the aircraft you're
-- looking at (owned or not) into one wave; the HUD's EXIT TEST FLIGHT button (HUD.Top.ExitTest) ends it early.
-- Nothing on a test flight is saved. Server: Lobbies "TestFlight" (a test server of your own; Studio: right here),
-- Mission (run kind "test"), "ExitTest". Convoy attribute TestFlight is on during one.
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local Shared = game:GetService("ReplicatedStorage"):WaitForChild("Convoy")
local Action = Shared:WaitForChild("Remotes"):WaitForChild("Action")
local Aircraft = require(Shared:WaitForChild("Aircraft"))
local SFX = require(Shared:WaitForChild("SFX"))
local gui = player:WaitForChild("PlayerGui"):WaitForChild("GunshipUI")
local test = gui:WaitForChild("Aircraft"):WaitForChild("Controls"):WaitForChild("Test", 15)
local exit = gui:WaitForChild("HUD"):WaitForChild("Top"):WaitForChild("ExitTest", 15)

local function pressy(b: GuiButton)
	local sc = b:FindFirstChild("Press")
	if not sc then
		return
	end
	b.MouseEnter:Connect(function() TweenService:Create(sc, TweenInfo.new(0.1), { Scale = 1.05 }):Play() end)
	b.MouseLeave:Connect(function() TweenService:Create(sc, TweenInfo.new(0.1), { Scale = 1 }):Play() end)
	b.MouseButton1Down:Connect(function() TweenService:Create(sc, TweenInfo.new(0.06), { Scale = 0.94 }):Play() end)
	b.MouseButton1Up:Connect(function() TweenService:Create(sc, TweenInfo.new(0.1), { Scale = 1.05 }):Play() end)
end
local function label(b: GuiObject, text: string)
	local face = b:FindFirstChild("Face")
	local l = face and face:FindFirstChild("Label")
	if l then
		l.Text = text
	end
end

if test then
	pressy(test)
	local busy = false
	test.Activated:Connect(function()
		if busy then
			return
		end
		busy = true
		SFX.play("Click", { vol = 0.6 })
		label(test, "LOADING...")
		Action:FireServer("TestFlight", player:GetAttribute("AircraftSel") or Aircraft.DEFAULT)
		task.delay(8, function()
			busy = false
			label(test, "TEST FLIGHT")
		end)
	end)
end

if exit then
	pressy(exit)
	exit.Activated:Connect(function()
		SFX.play("Click", { vol = 0.6 })
		label(exit, "LEAVING...")
		Action:FireServer("ExitTest")
	end)
	local function show()
		exit.Visible = Shared:GetAttribute("TestFlight") == true and Shared:GetAttribute("State") == "Running"
		if not exit.Visible then
			label(exit, "EXIT TEST FLIGHT")
		end
	end
	Shared:GetAttributeChangedSignal("TestFlight"):Connect(show)
	Shared:GetAttributeChangedSignal("State"):Connect(show)
	show()
end
]==])

return table.concat(log, ", ")
