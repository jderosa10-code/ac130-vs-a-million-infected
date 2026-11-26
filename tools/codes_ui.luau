-- Builds StarterGui.CodesUI (the CODES panel) from a copy of StarterGui.FreeRewardUI, so it has the game's
-- panel skin: hazard strip, header with icon / title / X, the yellow button. Run in each place (Studio command bar
-- or execute_luau). Client logic: StarterPlayerScripts.CodesUI. Server: ConvoyServer.Codes.
local SG = game:GetService("StarterGui")
local old = SG:FindFirstChild("CodesUI")
if old then
	old:Destroy()
end
local src = SG:FindFirstChild("FreeRewardUI")
assert(src, "needs StarterGui.FreeRewardUI to copy")
local g = src:Clone()
g.Name = "CodesUI"
g.Enabled = false
local panel = g.Panel
panel.Size = UDim2.fromOffset(640, 350)
local H = panel.Header
H.Title.Text = "CODES"
H.Sub.Text = "E N T E R   A   C O D E"
local Icons = require(game:GetService("ReplicatedStorage").Convoy.Icons)
Icons.set(H.Icon, "gift")

-- the input row: one of the step rows, emptied, with a text box in it
local row = panel.Step_Like
row.Name = "InputRow"
for _, c in ipairs(row:GetChildren()) do
	if not c:IsA("UIStroke") then
		c:Destroy()
	end
end
row.Position = UDim2.fromOffset(24, 100)
row.Size = UDim2.new(1, -48, 0, 92)
local box = Instance.new("TextBox")
box.Name = "Box"
box.BackgroundTransparency = 1
box.Position = UDim2.fromOffset(20, 0)
box.Size = UDim2.new(1, -40, 1, 0)
box.ClearTextOnFocus = false
box.Text = ""
box.PlaceholderText = "TYPE A CODE HERE"
box.PlaceholderColor3 = Color3.fromRGB(127, 138, 112)
box.TextColor3 = Color3.fromRGB(236, 232, 214)
box.FontFace = Font.new("rbxasset://fonts/families/Oswald.json", Enum.FontWeight.Bold)
box.TextSize = 40
box.TextXAlignment = Enum.TextXAlignment.Left
box.ZIndex = 3
box.Parent = row
for _, n in ipairs({ "Step_Favorite", "Step_Group", "Reward" }) do
	local c = panel:FindFirstChild(n)
	if c then
		c:Destroy()
	end
end
local claim = panel.Claim
claim.Name = "Redeem"
claim.Label.Text = "REDEEM"
claim.AnchorPoint = Vector2.new(0.5, 0)
claim.Position = UDim2.new(0.5, 0, 0, 214)
panel.Status.Position = UDim2.new(0, 24, 1, -36)
panel.Status.Size = UDim2.new(1, -48, 0, 26)
panel.Status.TextSize = 24
panel.Status.TextXAlignment = Enum.TextXAlignment.Center
panel.Status.Text = ""
g.Parent = SG
return "CodesUI built"
