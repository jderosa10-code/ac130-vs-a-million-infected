-- Places the camera for a staged gunship shot and returns the screen points for the post effects.
local C = { camX = -12, camY = -4.6, camZ = 19.5, lookX = 0, lookZ = 0, roll = -12, fov = 55 }
local HS = game:GetService("HttpService")
local st = workspace._ThumbStage
local ac = st.AC130
local pv = ac:GetPivot()
local TG = st:GetAttribute("TG")
local cam = workspace.CurrentCamera
local eye = pv * Vector3.new(C.camX, C.camY, C.camZ)
cam.CFrame = CFrame.lookAt(eye, TG + Vector3.new(C.lookX, 0, C.lookZ)) * CFrame.Angles(0, 0, math.rad(C.roll))
cam.FieldOfView = C.fov
local function scr(p)
	local v = cam:WorldToViewportPoint(p)
	return { v.X / cam.ViewportSize.X, v.Y / cam.ViewportSize.Y, v.Z }
end
local pts = { guns = {} }
local function tipOf(part)
	local a = part.CFrame * Vector3.new(part.Size.X / 2, 0, 0)
	local b = part.CFrame * Vector3.new(-part.Size.X / 2, 0, 0)
	if pv:PointToObjectSpace(a).X < pv:PointToObjectSpace(b).X then return a, b end
	return b, a
end
local gd = ac.GunDetail
for _, g in ipairs({ { "25", gd.GAU12, "H25" }, { "40", gd.Bofors, "H40" }, { "105", gd.Howitzer, "H105" } }) do
	local tips = {}
	for _, p in ipairs(g[2]:GetChildren()) do
		if p:IsA("BasePart") and p.Name == "Barrel" then
			local tip, back = tipOf(p)
			table.insert(tips, { scr(tip), scr(tip + (tip - back).Unit * 3), p.Size.Y, scr(tip + cam.CFrame.UpVector * p.Size.Y / 2) })
		end
	end
	table.insert(pts.guns, { name = g[1], tips = tips, hit = scr(st:GetAttribute(g[3])) })
end
pts.sun = scr(eye + game.Lighting:GetSunDirection() * 1000)
return HS:JSONEncode(pts)
