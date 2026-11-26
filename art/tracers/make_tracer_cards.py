"""Shop card art for the cosmetic tracers: a glowing round streaking diagonally with its own trail style.
python make_tracer_cards.py  -> tracer_<id>.png (512x256, transparent) next to this file."""
import math, os, random
from PIL import Image, ImageDraw, ImageFilter, ImageChops

OUT = os.path.dirname(os.path.abspath(__file__))
W, H = 512, 256
TRACERS = {
    "Crimson": ((255, 46, 46), "embers"),
    "Cobalt": ((60, 140, 255), "electric"),
    "Gold": ((255, 200, 40), "glitter"),
    "Plasma": ((0, 255, 230), "plasma"),
    "Ember": ((255, 110, 20), "flame"),
    "Void": ((150, 60, 230), "void"),
}
A = (70, 200)   # tail
B = (450, 62)   # head

def lerp(a, b, t):
    return (a[0] + (b[0] - a[0]) * t, a[1] + (b[1] - a[1]) * t)

def mix(c, w, k):
    return tuple(int(c[i] + (w[i] - c[i]) * k) for i in range(3))

def card(cid, col, style):
    rnd = random.Random(cid)
    glow = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    g = ImageDraw.Draw(glow)
    # tapered glow along the beam (thin at the tail, fat at the head)
    for i in range(60):
        t = i / 59
        p = lerp(A, B, t)
        r = 6 + 22 * t
        g.ellipse([p[0] - r, p[1] - r, p[0] + r, p[1] + r], fill=col + (int(60 + 110 * t),))
    fx = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    d = ImageDraw.Draw(fx)
    dx, dy = B[0] - A[0], B[1] - A[1]
    L = math.hypot(dx, dy); ux, uy = dx / L, dy / L; nx, ny = -uy, ux
    if style == "embers":
        for _ in range(38):
            t = rnd.random() ** 1.4; p = lerp(A, B, t); s = rnd.uniform(3, 8)
            ox, oy = nx * rnd.uniform(-24, 24), ny * rnd.uniform(-24, 24) + rnd.uniform(4, 40) * (1 - t)
            d.ellipse([p[0] + ox - s, p[1] + oy - s, p[0] + ox + s, p[1] + oy + s], fill=mix(col, (255, 230, 160), rnd.random() * 0.6) + (255,))
    elif style == "electric":
        for k in range(3):
            pts = []
            for i in range(14):
                t = i / 13; p = lerp(A, B, t); o = rnd.uniform(-26, 26) * (0.3 + t)
                pts.append((p[0] + nx * o, p[1] + ny * o))
            d.line(pts, fill=mix(col, (255, 255, 255), 0.5) + (255,), width=7 - 2 * k)
    elif style == "glitter":
        for _ in range(26):
            t = rnd.random(); p = lerp(A, B, t); s = rnd.uniform(5, 13)
            cx, cy = p[0] + nx * rnd.uniform(-40, 40), p[1] + ny * rnd.uniform(-40, 40)
            c = mix(col, (255, 255, 230), rnd.random() * 0.7) + (255,)
            d.polygon([(cx, cy - s), (cx + s * 0.28, cy - s * 0.28), (cx + s, cy), (cx + s * 0.28, cy + s * 0.28),
                       (cx, cy + s), (cx - s * 0.28, cy + s * 0.28), (cx - s, cy), (cx - s * 0.28, cy - s * 0.28)], fill=c)
    elif style == "plasma":
        for i in range(6):
            t = 0.15 + i * 0.15; p = lerp(A, B, t); r = 10 + 16 * t
            d.ellipse([p[0] - r, p[1] - r, p[0] + r, p[1] + r], outline=mix(col, (255, 255, 255), 0.4) + (230,), width=4)
    elif style == "flame":
        for _ in range(30):
            t = rnd.random() ** 1.2; p = lerp(A, B, t); s = rnd.uniform(6, 15) * (0.5 + t)
            cx, cy = p[0] + nx * rnd.uniform(-14, 14), p[1] + ny * rnd.uniform(-14, 14) - rnd.uniform(0, 26)
            c = mix(col, (255, 220, 80), rnd.random() * 0.8)
            d.polygon([(cx, cy - s * 1.6), (cx + s * 0.7, cy), (cx, cy + s * 0.5), (cx - s * 0.7, cy)], fill=c + (230,))
    elif style == "void":
        for i in range(90):
            t = i / 89; p = lerp(A, B, t); o = math.sin(t * 22) * (10 + 22 * t)
            s = 3 + 5 * t
            cx, cy = p[0] + nx * o, p[1] + ny * o
            d.ellipse([cx - s, cy - s, cx + s, cy + s], fill=(40, 10, 70, 255) if i % 2 else mix(col, (255, 255, 255), 0.3) + (255,))
    # the round: dark outline, coloured body, white-hot core
    core = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    c = ImageDraw.Draw(core)
    c.line([A, B], fill=(16, 16, 20, 255), width=26)
    c.line([A, B], fill=col + (255,), width=17)
    c.line([lerp(A, B, 0.25), B], fill=mix(col, (255, 255, 255), 0.75) + (255,), width=7)
    for e, w_ in ((B, 13),):
        c.ellipse([e[0] - w_, e[1] - w_, e[0] + w_, e[1] + w_], fill=(16, 16, 20, 255))
        c.ellipse([e[0] - 8, e[1] - 8, e[0] + 8, e[1] + 8], fill=(255, 255, 255, 255))
    out = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    out.alpha_composite(glow.filter(ImageFilter.GaussianBlur(11)))
    out.alpha_composite(fx.filter(ImageFilter.GaussianBlur(5)))
    out.alpha_composite(fx)
    out.alpha_composite(core)
    out.save(os.path.join(OUT, f"tracer_{cid.lower()}.png"))

for cid, (col, style) in TRACERS.items():
    card(cid, col, style)
print("ok")
