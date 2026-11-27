"""Adds a small yellow "YOU" with a curved arrow pointing at the player's aircraft (1920x1080 thumbnails).
usage: python thumb_you_label.py in.png out.png text_x text_y arrow_tip_x arrow_tip_y [bend] [colour]
Positions are in 1920x1080 pixels (the image is scaled to that first). bend: + curves one way, - the other."""
import sys
from PIL import Image, ImageDraw, ImageFont, ImageFilter

FONT = "/tmp/fonts/LilitaOne-Regular.ttf"
COLS = {"yellow": (255, 204, 26), "red": (255, 52, 40)}
src, out, tx, ty, ax, ay = sys.argv[1], sys.argv[2], *map(float, sys.argv[3:7])
bend = float(sys.argv[7]) if len(sys.argv) > 7 else 0.35
col = COLS[sys.argv[8]] if len(sys.argv) > 8 else COLS["yellow"]

im = Image.open(src).convert("RGB").resize((1920, 1080), Image.LANCZOS)
S = 3  # draw at 3x and scale down for smooth edges
layer = Image.new("RGBA", (1920 * S, 1080 * S), (0, 0, 0, 0))
d = ImageDraw.Draw(layer)
size = 92
f = ImageFont.truetype(FONT, size * S)
text = "YOU"
tw = f.getlength(text)
asc, desc = f.getmetrics()
x0, y0 = tx * S - tw / 2, ty * S - (asc + desc) / 2
stroke = 9 * S

# arrow: quadratic curve from just outside the text toward the aircraft, ending in a head
import math
cx, cy = tx * S, ty * S
ex, ey = ax * S, ay * S
dx, dy = ex - cx, ey - cy
L = math.hypot(dx, dy)
ux, uy = dx / L, dy / L
start_gap = max(tw / 2, (asc + desc) / 2) * 0.95 + 14 * S
sx, sy = cx + ux * start_gap, cy + uy * start_gap
mx, my = (sx + ex) / 2 - uy * L * bend * 0.5, (sy + ey) / 2 + ux * L * bend * 0.5
pts = []
for i in range(41):
    t = i / 40
    pts.append(((1 - t) ** 2 * sx + 2 * (1 - t) * t * mx + t * t * ex, (1 - t) ** 2 * sy + 2 * (1 - t) * t * my + t * t * ey))
# head direction from the curve's last segment
hx, hy = pts[-1][0] - pts[-4][0], pts[-1][1] - pts[-4][1]
hl = math.hypot(hx, hy); hx, hy = hx / hl, hy / hl
head = 34 * S
shaft_end = (ex - hx * head * 0.7, ey - hy * head * 0.7)
body = [p for p in pts if (p[0] - sx) * hx + (p[1] - sy) * hy < (shaft_end[0] - sx) * hx + (shaft_end[1] - sy) * hy] + [shaft_end]
tri = [(ex, ey), (ex - hx * head - hy * head * 0.62, ey - hy * head + hx * head * 0.62), (ex - hx * head + hy * head * 0.62, ey - hy * head - hx * head * 0.62)]
w = 13 * S
for c, extra in (((0, 0, 0, 255), 2 * stroke), (col + (255,), 0)):
    d.line(body, fill=c, width=int(w + extra), joint="curve")
    r = (w + extra) / 2
    d.ellipse([body[0][0] - r, body[0][1] - r, body[0][0] + r, body[0][1] + r], fill=c)
    if extra:
        # grow the head outline by pushing each corner away from the centre
        gx, gy = sum(p[0] for p in tri) / 3, sum(p[1] for p in tri) / 3
        big = []
        for p in tri:
            vx, vy = p[0] - gx, p[1] - gy
            vl = math.hypot(vx, vy)
            big.append((p[0] + vx / vl * stroke * 1.9, p[1] + vy / vl * stroke * 1.9))
        d.polygon(big, fill=c)
    else:
        d.polygon(tri, fill=c)
d.text((x0, y0), text, font=f, fill=col, stroke_width=stroke, stroke_fill=(0, 0, 0))

small = layer.resize((1920, 1080), Image.LANCZOS)
# soft drop shadow
shadow = Image.new("RGBA", small.size, (0, 0, 0, 0))
shadow.paste((0, 0, 0, 150), (0, 0), small.split()[3])
shadow = shadow.filter(ImageFilter.GaussianBlur(6))
base = im.convert("RGBA")
base.alpha_composite(shadow, (5, 7))
base.alpha_composite(small)
base.convert("RGB").save(out)
print("wrote", out)
