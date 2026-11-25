local ds=game:GetService("DataStoreService"):GetDataStore("DevSync_tmp")
local SPS=game.StarterPlayer.StarterPlayerScripts
local CS=game.ServerScriptService.ConvoyServer
local C=game.ReplicatedStorage.Convoy
local roots={SPS=SPS,CS=CS,C=C}
local classes={["SPS/SeasonUI"]="LocalScript",["CS/Cosmetics"]="ModuleScript",["C/Tracers"]="ModuleScript",["C/Season"]="ModuleScript"}
local keys=ds:GetAsync("_keys")
local made={}
for _,k in ipairs(keys) do
 local r,n=k:match("^(%w+)/(.+)$")
 local parent=roots[r]
 local s=parent:FindFirstChild(n)
 if not s then s=Instance.new(classes[k]) s.Name=n s.Parent=parent table.insert(made,n) end
 s.Source=ds:GetAsync(k)
end
C:SetAttribute("GameVersion","0.17.0")
local SG=game.StarterGui
local Tracers=require(C.Tracers)
-- shop: tracers tab, section and cards
local panel=SG.ShopUI.Panel
local page,rail=panel.Page,panel.Rail
for _,c in ipairs(page:GetChildren()) do if c.Name:match("Tracer") then c:Destroy() end end
if rail:FindFirstChild("Tab_Tracers") then rail.Tab_Tracers:Destroy() end
local tab=rail.Tab_Passes:Clone() tab.Name="Tab_Tracers" tab.Text="TRACERS"
tab.Position=rail.Tab_Passes.Position+UDim2.fromOffset(0,84) tab.Parent=rail
local ti=tab:FindFirstChild("Icon") if ti then ti.Image=Tracers.ICON ti.ImageColor3=Color3.fromRGB(255,200,40) ti.ImageRectSize=Vector2.zero ti.ImageRectOffset=Vector2.zero end
local y0=page.Section_Passes.Position.Y.Offset+388
local sec=page.Section_Passes:Clone() sec.Name="Section_Tracers" sec.Text="T R A C E R S" sec:SetAttribute("Section","Tracers")
sec.Position=UDim2.fromOffset(sec.Position.X.Offset,y0) sec.Parent=page
local rule=page.Rule_Passes:Clone() rule.Name="Rule_Tracers" rule.Position=UDim2.fromOffset(0,y0+46) rule.Parent=page
local n=0
for _,t in ipairs(Tracers.LIST) do
 local c=page.Card_Pass_Gems:Clone() c.Name="Card_Tracer_"..t.id c:SetAttribute("Key",nil) c:SetAttribute("Tracer",t.id)
 c.Position=UDim2.fromOffset((n%4)*218,y0+58+(n//4)*312)
 c.ItemName.Text=t.name
 c.Sub.Text=if t.season then "SEASON 1 PASS ONLY" elseif t.productId then "ROBUX ONLY" else "TRACER ROUNDS"
 c.Art.Icon.Image=Tracers.ICON c.Art.Icon.ImageColor3=t.color c.Art.Icon.Size=UDim2.fromScale(0.86,0.6)
 c.Art.Icon.ImageRectSize=Vector2.zero c.Art.Icon.ImageRectOffset=Vector2.zero
 c.Gift:Destroy() c.Buy.Size=UDim2.fromOffset(178,54) c.Buy.Text="BUY" c.Parent=page
 n+=1
end
page.CanvasSize=UDim2.fromOffset(0,y0+58+math.ceil(n/4)*312+20)
-- season screen: a bigger copy of the daily panel
if SG:FindFirstChild("SeasonUI") then SG.SeasonUI:Destroy() end
local g=SG.DailyUI:Clone() g.Name="SeasonUI" g.Enabled=false
g.DisplayOrder=math.max(SG.DailyUI.DisplayOrder,SG.ShopUI.DisplayOrder)+1
local sp=g.Panel sp.Size=UDim2.fromOffset(1320,720)
local h=sp.Header h.Title.Text="SEASON 1" h.Sub.Text="3 0   T I E R S   //   P L A Y   R U N S   T O   R A N K   U P"
h.Sub.Size=UDim2.fromOffset(700,h.Sub.Size.Y.Offset)
h.Icon.Image="rbxassetid://86397412865806" h.Icon.ImageRectSize=Vector2.zero h.Icon.ImageRectOffset=Vector2.zero h.Icon.ImageColor3=Color3.fromRGB(245,197,24)
local days=sp.Days
local track=Instance.new("ScrollingFrame") track.Name="Track" track.BackgroundTransparency=1 track.BorderSizePixel=0
track.Position=UDim2.fromOffset(150,96) track.Size=UDim2.new(1,-174,0,478) track.ScrollingDirection=Enum.ScrollingDirection.X
track.ScrollBarThickness=8 track.ScrollBarImageColor3=Color3.fromRGB(245,197,24)
track.HorizontalScrollBarInset=Enum.ScrollBarInset.ScrollBar track.CanvasSize=UDim2.fromOffset(30*134-10,0) track.Parent=sp
for t=1,30 do for row,kind in ipairs({"Free","Prem"}) do
 local c=days.Day1:Clone() c.Name=kind.."_"..t c.Position=UDim2.fromOffset((t-1)*134,(row-1)*240) c.DayLabel.Text="TIER "..t c.Parent=track
end end
days:Destroy()
for _,rl in ipairs({{"FreeLabel","FREE",186},{"PremLabel","PREMIUM",426}}) do
 local l=sp.Streak:Clone() l.Name=rl[1] l.Text=rl[2] l.Size=UDim2.fromOffset(120,40) l.Position=UDim2.fromOffset(24,rl[3]) l.Parent=sp
end
sp.Streak.Text="TIER 0  //  0 / 100 XP" sp.Streak.Size=UDim2.fromOffset(520,40)
sp.Hint.Text="ENDS IN 37 DAYS" sp.Hint.Size=UDim2.fromOffset(520,26)
sp.Claim.Label.Text="UNLOCK PREMIUM" sp.Claim.Size=UDim2.fromOffset(380,92) sp.Claim.Position=UDim2.new(1,-404,1,-118)
sp.Remind:Destroy()
g.Parent=SG
-- hub: DAILY + INVITE on the right, SHOP / SEASON / FREE on the left
local menu=SG.GunshipUI_Template.Menu
local side=menu.Side
if menu:FindFirstChild("SideRight") then
 for _,c in ipairs(menu.SideRight:GetChildren()) do if not c:IsA("UIScale") then c.Parent=side end end
 menu.SideRight:Destroy()
end
if side:FindFirstChild("Season") then side.Season:Destroy() end
local right=side:Clone() right.Name="SideRight"
for _,c in ipairs(right:GetChildren()) do if not c:IsA("UIScale") then c:Destroy() end end
right.AnchorPoint=Vector2.new(1,0.5) right.Position=UDim2.new(1,-16,0.5,40) right.Size=UDim2.fromOffset(150,272) right.Parent=menu
local daily=side.Daily daily.Parent=right daily.Position=UDim2.fromOffset(0,0)
local inv=side.Invite inv.Parent=right inv.Position=UDim2.fromOffset(0,142)
local season=side.Free:Clone() season.Name="Season" season.Position=UDim2.fromOffset(0,142)
local lbl=season:FindFirstChild("Label",true) if lbl then lbl.Text="SEASON" end
local ic=season:FindFirstChild("Icon",true)
if ic then ic.Image="rbxassetid://86397412865806" ic.ImageRectOffset=Vector2.zero ic.ImageRectSize=Vector2.zero ic.ImageColor3=Color3.fromRGB(245,197,24) end
local dot=daily:FindFirstChild("Dot") if dot then local d=dot:Clone() d.Visible=false d.Parent=season end
season.Parent=side
side.Shop.Position=UDim2.fromOffset(0,0) side.Free.Position=UDim2.fromOffset(0,284) side.Size=UDim2.fromOffset(150,414)
return "made "..table.concat(made,",").." cards "..n
