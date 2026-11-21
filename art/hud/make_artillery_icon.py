# HUD ability icon: towed howitzer, white silhouette with a thick black outline (hub icon style)
from PIL import Image, ImageDraw, ImageFilter
import math
S = 4; W, H = 512*S, 320*S
m = Image.new("L", (W, H), 0); d = ImageDraw.Draw(m)
def P(pts): d.polygon([(x*S, y*S) for x, y in pts], fill=255)
def rot(cx, cy, pts, deg):
    a = math.radians(deg); c, s = math.cos(a), math.sin(a)
    return [(cx + x*c - y*s, cy + x*s + y*c) for x, y in pts]
bx, by, ang = 250, 196, -24          # trunnion, barrel elevation
P(rot(bx, by, [(-70,-13),(215,-9),(215,9),(-70,13)], ang))          # barrel
P(rot(bx, by, [(-80,-22),(60,-20),(60,20),(-80,22)], ang))          # cradle / recoil
P(rot(bx, by, [(205,-17),(240,-17),(240,17),(205,17)], ang))        # muzzle brake
P(rot(bx, by, [(120,-13),(132,-13),(132,13),(120,13)], ang))        # barrel band
P([(205,150),(262,120),(272,232),(215,240)])                         # shield
P([(240,215),(90,268),(60,268),(52,286),(96,286),(262,240)])        # trail
P([(56,262),(34,296),(74,296)])                                      # spade
d.ellipse([ (238-50)*S,(238-50)*S,(238+50)*S,(238+50)*S ], fill=255) # wheel
hole = Image.new("L", (W, H), 0); hd = ImageDraw.Draw(hole)
hd.ellipse([ (238-30)*S,(238-30)*S,(238+30)*S,(238+30)*S ], fill=255)
hd.ellipse([ (238-12)*S,(238-12)*S,(238+12)*S,(238+12)*S ], fill=0)
from PIL import ImageChops
m = ImageChops.subtract(m, hole)
out = m.filter(ImageFilter.MaxFilter(13*S//2*2+1)).filter(ImageFilter.MaxFilter(9))
img = Image.new("RGBA", (W, H), (0,0,0,0))
img.paste((0,0,0,255), mask=out); img.paste((255,255,255,255), mask=m)
img = img.resize((512, 320), Image.LANCZOS)
img.save("hud_artillery.png")
