-- HoverAnchor: let a GUI object grow from its middle for a moment (hover, press, pop, tutorial pulse) without
-- breaking scripts that place it. A UIScale grows from the AnchorPoint, so while an effect runs the anchor sits
-- in the middle (same spot on screen). When the last effect ends the anchor goes back. If anything else moves,
-- re-anchors or resizes the object meanwhile, it is handed straight back as that script meant it.
--   HoverAnchor.begin(obj, "feel")  ...  HoverAnchor.finish(obj, "feel")
local HoverAnchor = {}
local CENTRE = Vector2.new(0.5, 0.5)
local active = setmetatable({}, { __mode = "k" })

local function drop(o: GuiObject, rec, putBack: boolean)
	if active[o] ~= rec then
		return
	end
	active[o] = nil
	for _, c in ipairs(rec.conns) do
		c:Disconnect()
	end
	if putBack then
		o.Position -= rec.delta
		o.AnchorPoint = rec.ap
	elseif o.AnchorPoint == CENTRE then
		o.AnchorPoint = rec.ap -- they placed it for its own anchor
	end
end

function HoverAnchor.begin(o: GuiObject, key: string)
	local rec = active[o]
	if rec then
		rec.keys[key] = true
		return
	end
	if o.Parent and o.Parent:FindFirstChildWhichIsA("UIGridStyleLayout") then
		return -- a layout places it
	end
	local ap, s = o.AnchorPoint, o.Size
	local dx, dy = 0.5 - ap.X, 0.5 - ap.Y
	if math.abs(dx) < 1e-3 and math.abs(dy) < 1e-3 then
		return
	end
	rec = { ap = ap, size = s, keys = { [key] = true }, conns = {} }
	rec.delta = UDim2.new(s.X.Scale * dx, s.X.Offset * dx, s.Y.Scale * dy, s.Y.Offset * dy)
	o.Position += rec.delta
	o.AnchorPoint = CENTRE
	rec.pos = o.Position
	active[o] = rec
	local function check()
		if active[o] ~= rec then
			return
		end
		local ours = o.Position == rec.pos and o.AnchorPoint == CENTRE
		if ours and o.Size == rec.size then
			return -- (our own change, arriving late)
		end
		drop(o, rec, ours) -- resized: put it back first; moved or re-anchored by someone else: theirs now
	end
	table.insert(rec.conns, o:GetPropertyChangedSignal("Position"):Connect(check))
	table.insert(rec.conns, o:GetPropertyChangedSignal("AnchorPoint"):Connect(check))
	table.insert(rec.conns, o:GetPropertyChangedSignal("Size"):Connect(check))
end

function HoverAnchor.finish(o: GuiObject, key: string)
	local rec = active[o]
	if not rec then
		return
	end
	rec.keys[key] = nil
	if next(rec.keys) == nil then
		drop(o, rec, true)
	end
end

return HoverAnchor
