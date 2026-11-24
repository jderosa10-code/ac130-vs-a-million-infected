import cv2, numpy as np, sys
rng = np.random.default_rng(7)
src = cv2.imread(sys.argv[1]).astype(np.float32) / 255
out_path = sys.argv[2]
H, W = src.shape[:2]
yy, xx = np.mgrid[0:H, 0:W].astype(np.float32)

# colours are BGR
ORANGE = np.array([0.10, 0.45, 1.0]); YEL = np.array([0.45, 0.92, 1.0]); WHITE = np.array([0.92, 0.98, 1.0])
SMOKE = np.array([0.16, 0.17, 0.2])

glow = np.zeros_like(src); core = np.zeros_like(src)
im = src.copy()

def P(p): return tuple(int(v) for v in p)

def streak(p, q, dash, gap, w, phase=0):
    p = np.array(p, float); q = np.array(q, float); d = q - p; L = np.linalg.norm(d); u = d / L
    t = phase
    while t < L:
        a = p + u * t; b = p + u * min(L, t + dash)
        k = 0.55 + 0.45 * (t / L)  # rounds grow toward the camera
        cv2.line(glow, P(a), P(b), tuple(ORANGE), int(w * 4 * k), cv2.LINE_AA)
        cv2.line(core, P(a), P(b), tuple(YEL), max(1, int(w * k)), cv2.LINE_AA)
        cv2.line(core, P(a), P(b), tuple(WHITE), max(1, int(w * k * 0.45)), cv2.LINE_AA)
        t += dash + gap

def flash(c, r, ang):
    cv2.circle(glow, P(c), int(r * 1.8), tuple(ORANGE), -1, cv2.LINE_AA)
    cv2.circle(core, P(c), int(r * 0.6), tuple(WHITE), -1, cv2.LINE_AA)
    for da, l in ((0, 2.6), (-30, 1.5), (30, 1.5), (180, 0.7)):
        a = np.radians(ang + da); e = (c[0] + np.cos(a) * r * l, c[1] + np.sin(a) * r * l)
        cv2.line(core, P(c), P(e), tuple(YEL), max(2, int(r * 0.4)), cv2.LINE_AA)
        cv2.line(glow, P(c), P(e), tuple(ORANGE), int(r * 1.0), cv2.LINE_AA)

def cube(layer, c, s, ang, col, alpha=1.0):
    box = cv2.boxPoints(((float(c[0]), float(c[1])), (float(s), float(s)), float(ang))).astype(np.int32)
    if alpha >= 1:
        cv2.fillConvexPoly(layer, box, tuple(col), cv2.LINE_AA)
    else:
        tmp = layer.copy(); cv2.fillConvexPoly(tmp, box, tuple(col), cv2.LINE_AA)
        layer[:] = layer * (1 - alpha) + tmp * alpha

def blast(c, r):
    """voxel explosion like the game's: dark smoke cubes above, fire cubes, a white-hot core, light on the sand"""
    global im
    # light spill on the ground and bodies around it
    d = np.exp(-(((xx - c[0]) / (r * 3.2)) ** 2 + ((yy - c[1]) / (r * 1.6)) ** 2))[..., None]
    im = im + d * np.array([0.05, 0.22, 0.45]) * 0.9
    for i in range(int(r * 0.35)):  # smoke column
        a = rng.uniform(-0.6, 0.6); h = rng.uniform(0.3, 2.6) * r
        p = (c[0] + a * r * (0.6 + h / r * 0.25), c[1] - h)
        cube(im, p, rng.uniform(0.35, 0.8) * r, rng.uniform(0, 90), SMOKE * rng.uniform(0.8, 1.4), 0.55)
    for i in range(int(r * 0.5)):  # fire
        ang = rng.uniform(np.pi * 1.05, np.pi * 1.95); dist = rng.uniform(0, 1.1) * r
        p = (c[0] + np.cos(ang) * dist, c[1] + np.sin(ang) * dist * 0.8)
        col = [ORANGE, YEL, YEL, WHITE][rng.integers(0, 4)]
        s = rng.uniform(0.18, 0.5) * r
        cube(im, p, s, rng.uniform(0, 90), col)
        cube(glow, p, s * 1.6, rng.uniform(0, 90), ORANGE)
    cv2.circle(glow, P(c), int(r * 1.5), tuple(ORANGE), -1, cv2.LINE_AA)
    cv2.circle(core, P((c[0], c[1] - r * 0.25)), int(r * 0.35), tuple(WHITE), -1, cv2.LINE_AA)
    for i in range(14):  # flying debris chunks
        ang = rng.uniform(np.pi * 1.1, np.pi * 1.9); dist = rng.uniform(1.2, 3.2) * r
        p = (c[0] + np.cos(ang) * dist, c[1] + np.sin(ang) * dist)
        cube(im, p, rng.uniform(5, 12), rng.uniform(0, 90), [np.array([0.35, 0.55, 0.7]), np.array([0.1, 0.3, 0.9]), SMOKE][rng.integers(0, 3)])

G = [float(v) for v in sys.argv[3].split(",")]  # gun muzzles x,y pairs: 25mm, 40mm, 105mm
g25, g40, g105 = (G[0], G[1]), (G[2], G[3]), (G[4], G[5])
B = [float(v) for v in sys.argv[4].split(",")]  # blasts x,y,r triples
blasts = [(B[i], B[i + 1], B[i + 2]) for i in range(0, len(B), 3)]

for b in blasts:
    blast((b[0], b[1]), b[2])

# tracer streams from each gun to an impact
streak(g25, (blasts[0][0] + 14, blasts[0][1] - 10), 26, 30, 4, 8)
streak((g25[0] + 6, g25[1] + 3), (blasts[0][0] - 30, blasts[0][1] + 6), 26, 30, 4, 24)
streak(g40, (blasts[1][0], blasts[1][1] - 6), 34, 48, 6, 12)
streak(g105, (blasts[2][0], blasts[2][1] - 10), 90, 60, 12, 30)
for g, r, t in ((g25, 13, blasts[0]), (g40, 17, blasts[1]), (g105, 24, blasts[2])):
    flash(g, r, np.degrees(np.arctan2(t[1] - g[1], t[0] - g[0])))

glow = cv2.GaussianBlur(glow, (0, 0), 9)
core = cv2.GaussianBlur(core, (0, 0), 0.9)
im = np.clip(im, 0, 1)
im = 1 - (1 - im) * (1 - np.clip(glow * 0.85, 0, 1))
im = 1 - (1 - im) * (1 - np.clip(core, 0, 1))

# light streaks from the sun (top-left) across the sky
beams = np.zeros((H, W), np.float32)
for i in range(6):
    x0 = rng.uniform(-0.2, 0.5) * W; ang = np.radians(rng.uniform(20, 38)); w = rng.uniform(6, 22)
    x1 = x0 + np.cos(ang) * W * 1.6; y1 = np.sin(ang) * W * 1.6
    cv2.line(beams, (int(x0), -10), (int(x1), int(y1)), rng.uniform(0.25, 0.55), int(w), cv2.LINE_AA)
beams = cv2.GaussianBlur(beams, (0, 0), 6) * np.clip(1.15 - yy / (H * 0.62), 0, 1)
im = 1 - (1 - im) * (1 - beams[..., None] * np.array([0.85, 0.92, 1.0]) * 0.55)

# embers drifting up
emb = np.zeros_like(im)
for i in range(90):
    b0 = blasts[rng.integers(0, len(blasts))]
    x = b0[0] + rng.normal(0, 260); y = b0[1] - abs(rng.normal(0, 320))
    L = rng.uniform(5, 14); a = np.radians(rng.uniform(-120, -60))
    cv2.line(emb, (int(x), int(y)), (int(x + np.cos(a) * L), int(y + np.sin(a) * L)), tuple(ORANGE * rng.uniform(0.7, 1.0)), rng.integers(2, 4), cv2.LINE_AA)
emb = cv2.GaussianBlur(emb, (0, 0), 0.8) + cv2.GaussianBlur(emb, (0, 0), 4) * 0.8
im = 1 - (1 - im) * (1 - np.clip(emb, 0, 1))

# bloom
bright = np.clip(im - 0.72, 0, 1) * 2.2
im = 1 - (1 - im) * (1 - np.clip(cv2.GaussianBlur(bright, (0, 0), 14) * 0.45, 0, 1))

# grade: saturation, warm sand / deep blue sky, contrast, vignette
hsv = cv2.cvtColor((np.clip(im, 0, 1) * 255).astype(np.uint8), cv2.COLOR_BGR2HSV).astype(np.float32)
hsv[..., 1] = np.clip(hsv[..., 1] * 1.28, 0, 255)
im = cv2.cvtColor(hsv.astype(np.uint8), cv2.COLOR_HSV2BGR).astype(np.float32) / 255
im = 0.5 + (im - 0.5) * 1.1
sky = np.clip(1 - yy / (H * 0.45), 0, 1)[..., None]
im = im * (1 - sky * 0.12) + sky * 0.12 * im * np.array([1.12, 0.92, 0.75])
v = 1 - 0.32 * (((xx - W * 0.52) / (W * 0.72)) ** 2 + ((yy - H * 0.48) / (H * 0.8)) ** 2)
im = im * np.clip(v, 0.5, 1)[..., None]
# slight colour fringe at the edges
shift = 3
b, g, r = cv2.split(im)
edge = np.clip(((xx - W / 2) / (W / 2)) ** 2 + ((yy - H / 2) / (H / 2)) ** 2, 0, 1)
r2 = np.roll(r, shift, 1); b2 = np.roll(b, -shift, 1)
im = cv2.merge([b * (1 - edge) + b2 * edge, g, r * (1 - edge) + r2 * edge])
# sharpen
blur = cv2.GaussianBlur(im, (0, 0), 1.2)
im = im + (im - blur) * 0.5
cv2.imwrite(out_path, np.clip(im * 255, 0, 255).astype(np.uint8))
