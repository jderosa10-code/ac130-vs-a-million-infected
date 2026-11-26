-- 0.19.11 UI: builds StarterGui.PresentsHUD (a one-row copy of the kills tally) and StarterGui.PresentsUI (a copy
-- of the gem top-up panel) in any place that has GunshipUI_Template and GemTopUpUI. Re-runnable.
local SG = game.StarterGui
-- HUD chip
local old = SG:FindFirstChild("PresentsHUD") if old then old:Destroy() end
local sg = Instance.new("ScreenGui")
sg.Name = "PresentsHUD"; sg.ResetOnSpawn = false; sg.DisplayOrder = 2; sg.Enabled = false
sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
local t = SG.GunshipUI_Template.HUD.Tally:Clone()
t.Name = "Presents"; t.Position = UDim2.fromOffset(26, 186); t.Size = UDim2.fromOffset(250, 52); t.Parent = sg
local panel = t.Panel
panel.Size = UDim2.fromOffset(240, 42)
local body = panel.Body
for _, n in ipairs({ "Rescued", "RescuedLabel", "Strikes", "StrikesLabel" }) do body[n]:Destroy() end
body.KillsLabel.Name = "Label"; body.Kills.Name = "Count"
body.Label.Text = "PRESENTS"; body.Label.Position = UDim2.fromOffset(46, 8); body.Label.Size = UDim2.fromOffset(100, 26)
body.Count.Position = UDim2.fromOffset(136, 8); body.Count.Text = "0"; body.Count.TextColor3 = Color3.fromRGB(255, 214, 60)
local icon = Instance.new("ImageLabel")
icon.Name = "Icon"; icon.BackgroundTransparency = 1; icon.Size = UDim2.fromOffset(26, 34); icon.Position = UDim2.fromOffset(12, 4)
icon.ScaleType = Enum.ScaleType.Fit; icon.Parent = body
local gain = body.Count:Clone()
gain.Name = "Gain"; gain.Text = ""; gain.Position = UDim2.fromOffset(244, 8); gain.Size = UDim2.fromOffset(80, 26)
gain.TextXAlignment = Enum.TextXAlignment.Left; gain.TextColor3 = Color3.fromRGB(120, 230, 120); gain.Parent = body
sg.Parent = SG
-- booth panel
local old2 = SG:FindFirstChild("PresentsUI") if old2 then old2:Destroy() end
local g = SG.GemTopUpUI:Clone()
g.Name = "PresentsUI"
local p = g.Panel
p.Header.Title.Text = "SANTA'S SLEIGH"
p.Header.Sub.Text = "C O L L E C T   2 5 0   P R E S E N T S"
p.Pack.DayLabel.Text = "HOLIDAY GUNSHIP"; p.Pack.Amount.Text = "+50% GEMS"; p.Pack.Unit.Text = "ENDS DEC 31"
p.For.Text = "PRESENTS: 0 / 250"
local have = p.Have
local bar = Instance.new("Frame")
bar.Name = "Bar"; bar.Position = have.Position + UDim2.fromOffset(0, 2); bar.Size = UDim2.fromOffset(304, 22)
bar.BackgroundColor3 = Color3.fromRGB(22, 25, 18); bar.BorderSizePixel = 0
local st = Instance.new("UIStroke"); st.Color = Color3.fromRGB(74, 78, 58); st.Thickness = 1; st.Parent = bar
local fill = Instance.new("Frame"); fill.Name = "Fill"; fill.BorderSizePixel = 0
fill.BackgroundColor3 = Color3.fromRGB(214, 40, 40); fill.Size = UDim2.fromScale(0.3, 1); fill.Parent = bar
local gr = Instance.new("UIGradient"); gr.Rotation = 90
gr.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(170, 170, 170)); gr.Parent = fill
local pct = have:Clone(); pct.Name = "Pct"; pct.Position = UDim2.fromScale(0, 0); pct.Size = UDim2.fromScale(1, 1)
pct.TextXAlignment = Enum.TextXAlignment.Center; pct.Text = "30%"; pct.TextColor3 = Color3.fromRGB(236, 232, 214); pct.ZIndex = 3; pct.Parent = bar
bar.Parent = p
have:Destroy()
p.Spare.Text = "SHOOT PRESENTS ON THE GROUND IN RUNS"
p.Buy.Label.Text = "NEED 175 MORE"
p.More.Label.Text = "GET IT NOW  " .. utf8.char(0xE002) .. " 599"
g.Parent = SG
return "ui ok"
