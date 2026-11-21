# Rank insignia for the RANKS screen, in the game's icon style: flat white silhouettes with a thick black
# outline (gold ranks are tinted in the UI). Writes rank_00..rank_18 (.svg/.png, 256px) and ranks_sheet.png:
# 5 columns x 4 rows of 200px cells (Roblox caps images at 1024px), rank n at cell n (Convoy.Ranks.cell).
import math, os, subprocess
from PIL import Image
OUT = os.path.dirname(os.path.abspath(__file__))
OUTLINE = 13  # half the black edge, in svg units (256 box)

def wrap(shapes, extra=""):
    # union look: every shape's black edge first, then all the white fills over it, then black detail lines
    edge = f'<g fill="#000" stroke="#000" stroke-width="{OUTLINE*2}" stroke-linejoin="round" stroke-linecap="round">{shapes}</g>'
    fill = f'<g fill="#fff" stroke="none">{shapes}</g>'
    return (f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 256 256" width="256" height="256">'
            f'{edge}{fill}{extra}</svg>')

def fit(shapes, h, w=220):
    # scale a stack that is `h` tall (and w wide, centred on x=128, starting at y=0) into the 256 box
    s = min(1.0, 212 / h, 212 / w)
    ty = 128 - h * s / 2
    return f'<g transform="translate({128 - 128*s:.1f} {ty:.1f}) scale({s:.3f})">{shapes}</g>'

def chevron(y):
    return f'<path d="M30,{y+60} L128,{y} L226,{y+60} L226,{y+92} L128,{y+32} L30,{y+92} Z"/>'
def rocker(y):
    return f'<path d="M30,{y} Q128,{y+60} 226,{y} L226,{y+30} Q128,{y+90} 30,{y+30} Z"/>'
def star(cx, cy, r):
    pts = []
    for i in range(10):
        a = math.radians(-90 + i * 36)
        rr = r if i % 2 == 0 else r * 0.45
        pts.append(f"{cx + rr*math.cos(a):.1f},{cy + rr*math.sin(a):.1f}")
    return f'<polygon points="{" ".join(pts)}"/>'

def enlisted(n_chev, n_rock, mid_star=False):
    s, y = "", 0
    for i in range(n_chev):
        s += chevron(y)
        y += 42
    y += 50  # the last chevron's height below its top
    if mid_star:
        s += star(128, y + 28, 30)
        y += 64
    elif n_rock:
        y += 4
    for i in range(n_rock):
        s += rocker(y - (0 if mid_star else 30))
        y += 40
    h = y + (60 if n_rock else 0) - (0 if mid_star or not n_rock else 30)
    return wrap(fit(s, max(h, 92)))

def bars(n):
    w, gap = 46, 22
    total = n * w + (n - 1) * gap
    x0 = 128 - total / 2
    s = "".join(f'<rect x="{x0 + i*(w+gap):.1f}" y="42" width="{w}" height="172" rx="8"/>' for i in range(n))
    extra = "".join(f'<rect x="{x0 + i*(w+gap) + 10:.1f}" y="60" width="{w-20}" height="136" rx="4" fill="none" stroke="#000" stroke-width="6"/>' for i in range(n))
    return wrap(s, extra)

def oak_leaf():
    # a lobed leaf: overlapping ellipses down a centre line, plus the stem
    s = '<rect x="120" y="196" width="16" height="40" rx="6"/>'
    s += '<ellipse cx="128" cy="44" rx="34" ry="30"/>'
    for i, (dy, rx) in enumerate(((78, 62), (116, 72), (154, 66), (188, 44))):
        s += f'<ellipse cx="{128 - rx*0.55:.0f}" cy="{dy}" rx="{rx*0.62:.0f}" ry="26"/>'
        s += f'<ellipse cx="{128 + rx*0.55:.0f}" cy="{dy}" rx="{rx*0.62:.0f}" ry="26"/>'
    s += '<ellipse cx="128" cy="124" rx="44" ry="92"/>'
    extra = ('<path d="M128,50 L128,206" stroke="#000" stroke-width="7" fill="none" stroke-linecap="round"/>'
             + "".join(f'<path d="M128,{y} L{128+dx},{y-18}" stroke="#000" stroke-width="6" fill="none" stroke-linecap="round"/>'
                       for y, dx in ((96, -44), (96, 44), (134, -50), (134, 50), (170, -42), (170, 42))))
    return wrap(s, extra)

def eagle():
    # spread eagle facing right: two swept wings with three feather fingers each, body, head and beak, tail fan
    def wing(side):
        m = lambda x: 128 + side * (x - 128)
        pts = [(128, 118), (m(112), 96), (m(84), 70), (m(52), 48), (m(18), 40),
               (m(34), 62), (m(14), 70), (m(36), 88), (m(18), 100), (m(46), 112), (m(40), 126),
               (m(84), 138), (128, 150)]
        return '<path d="M' + " L".join(f"{x:.0f},{y:.0f}" for x, y in pts) + ' Z"/>'
    s = wing(-1) + wing(1)
    s += '<ellipse cx="128" cy="142" rx="28" ry="48"/>'           # body
    s += '<path d="M106,178 L94,226 L118,214 L128,232 L138,214 L162,226 L150,178 Z"/>'  # tail fan
    s += '<circle cx="132" cy="84" r="22"/>'                      # head
    s += '<path d="M150,76 L176,88 L150,98 Z"/>'                  # beak
    extra = ('<circle cx="140" cy="80" r="5" fill="#000"/>'
             '<path d="M128,124 L128,170 M116,132 L116,160 M140,132 L140,160" stroke="#000" stroke-width="5" fill="none" stroke-linecap="round"/>')
    return wrap(s, extra)

def stars(n):
    r = 46 if n == 1 else 38 if n == 2 else 32 if n == 3 else 27
    gap = r * 2.05
    x0 = 128 - gap * (n - 1) / 2
    return wrap("".join(star(x0 + i * gap, 130, r) for i in range(n)))

def dog_tag():
    s = '<rect x="70" y="40" width="116" height="176" rx="40"/>'
    extra = ('<circle cx="128" cy="72" r="11" fill="#000"/>'
             + "".join(f'<rect x="94" y="{y}" width="68" height="10" rx="4" fill="#000"/>' for y in (112, 138, 164)))
    return wrap(s, extra)

ICONS = [
    dog_tag(),                 # 0 recruit
    enlisted(1, 0),            # 1 private
    enlisted(1, 1),            # 2 private 1st class
    enlisted(2, 0),            # 3 corporal
    enlisted(3, 0),            # 4 sergeant
    enlisted(3, 1),            # 5 staff sergeant
    enlisted(3, 2),            # 6 sergeant 1st class
    enlisted(3, 3),            # 7 master sergeant
    enlisted(3, 3, True),      # 8 sergeant major
    bars(1),                   # 9 2nd lieutenant (gold)
    bars(1),                   # 10 1st lieutenant (silver)
    bars(2),                   # 11 captain
    oak_leaf(),                # 12 major (gold)
    oak_leaf(),                # 13 lieutenant colonel
    eagle(),                   # 14 colonel
    stars(1), stars(2), stars(3), stars(4),  # 15-18 generals
]
CELL = 200
sheet = Image.new("RGBA", (5 * CELL, 4 * CELL), (0, 0, 0, 0))
for i, svg in enumerate(ICONS):
    p = f"{OUT}/rank_{i:02d}"
    open(p + ".svg", "w").write(svg)
    subprocess.run(["rsvg-convert", "-w", "256", "-h", "256", p + ".svg", "-o", p + ".png"], check=True)
    sheet.paste(Image.open(p + ".png").convert("RGBA").resize((CELL, CELL), Image.LANCZOS), ((i % 5) * CELL, (i // 5) * CELL))
sheet.save(f"{OUT}/ranks_sheet.png")
# preview on the UI's panel colour, gold ranks tinted
prev = Image.new("RGBA", sheet.size, (6, 8, 10, 255))
prev.alpha_composite(sheet)
prev.save(f"{OUT}/ranks_preview.png")
print("ok")
