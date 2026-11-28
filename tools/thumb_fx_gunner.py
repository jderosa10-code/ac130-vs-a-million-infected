"""Gunner's-eye thumbnail effects (thermal look, gun in the foreground) - heavier than thumb_after_effects.py.
usage: python thumb_fx_gunner.py raw.jpg pts.json out.png [opts.json]
pts.json comes from snippets/thumb_gunner_pov.luau (0..1 screen points of the Studio viewport).
opts: {"gun": "25"|"105", "big": [i,...] which hits get the big blast, "strafe": [dx, dy] direction of the 25mm walk}"""
import cv2, numpy as np, sys, json

raw, ptsf, out = sys.argv[1:4]
opt = json.load(open(sys.argv[4])) if len(sys.argv) > 4 else {}
rng = np.random.default_rng(opt.get("seed", 3))
src = cv2.imread(raw).astype(np.float32) / 255
H0, W0 = src.shape[:2]
cw = int(round(H0 * 16 / 9)); cx0 = (W0 - cw) // 2
im = cv2.resize(src[:, cx0:cx0 + cw], (1920, 1080), interpolation=cv2.INTER_CUBIC)
H, W = im.shape[:2]
yy, xx = np.mgrid[0:H, 0:W].astype(np.float32)
pts = json.load(open(ptsf))
st = opt.get("sand", 0)
if st:  # warm the grey baseplate toward desert sand (only greyish pixels in the given mask region)
    hsv0 = cv2.cvtColor((im * 255).astype(np.uint8), cv2.COLOR_BGR2HSV).astype(np.float32)
    grey = np.clip(1 - hsv0[..., 1] / 90, 0, 1)
    if opt.get("sandMask"):
        mk = cv2.resize(cv2.imread(opt["sandMask"], 0), (W, H)).astype(np.float32) / 255
        grey = grey * mk
    grey = grey[..., None] * st
    im = im * (1 - grey) + (im.mean(2, keepdims=True) * np.array([0.62, 0.95, 1.35]) * 1.15) * grey
def P(p): return np.array([(p[0] * W0 - cx0) / cw * W, p[1] * H], np.float32)
def I(p): return (int(round(p[0])), int(round(p[1])))
ORANGE = np.array([0.1, 0.45, 1.0]); YEL = np.array([0.45, 0.92, 1.0]); WHITE = np.array([0.95, 0.98, 1.0])
SMOKE = np.array([0.13, 0.13, 0.15])
glow = np.zeros_like(im); core = np.zeros_like(im)
def screen(a, b): return 1 - (1 - a) * (1 - np.clip(b, 0, 1))

def cube(layer, c, s, ang, col, a=1.0):
    box = cv2.boxPoints(((float(c[0]), float(c[1])), (float(s), float(s)), float(ang))).astype(np.int32)
    if a >= 1:
        cv2.fillConvexPoly(layer, box, tuple(col), cv2.LINE_AA)
    else:
        tmp = layer.copy(); cv2.fillConvexPoly(tmp, box, tuple(col), cv2.LINE_AA)
        layer[:] = layer * (1 - a) + tmp * a

def light(c, r, k=1.0):
    global im
    d = np.exp(-(((xx - c[0]) / r) ** 2 + ((yy - c[1]) / (r * 0.7)) ** 2))[..., None]
    im = im + d * np.array([0.05, 0.25, 0.55]) * k

def blast(c, r, bodies=0):
    """the game's voxel explosion: light pool, shockwave ring, fire cubes, white core, smoke column, debris"""
    global im
    c = np.array(c, np.float32)
    light(c, r * 2.6, opt.get('blastLight', 0.8))
    ring = np.zeros((H, W), np.float32)
    cv2.ellipse(ring, I(c), (int(r * 2.3), int(r * 1.25)), 0, 0, 360, 1.0, max(3, int(r * 0.12)), cv2.LINE_AA)
    ring = cv2.GaussianBlur(ring, (0, 0), r * 0.08)[..., None]
    im = screen(im, ring * np.array([0.6, 0.8, 1.0]) * 0.5)
    for i in range(int(r * 0.45)):  # smoke column, darker and bigger as it climbs
        h = rng.uniform(0.2, 3.0) * r
        p = (c[0] + rng.normal(0, 0.35) * r * (1 + h / r * 0.25), c[1] - h)
        cube(im, p, rng.uniform(0.35, 0.85) * r * (1 + h / r * 0.15), rng.uniform(0, 90), SMOKE * rng.uniform(0.7, 1.6), 0.55)
    for i in range(int(r * 0.9)):  # fire
        a = rng.uniform(np.pi * 1.0, np.pi * 2.0); d = abs(rng.normal(0, 0.55)) * r
        p = (c[0] + np.cos(a) * d * 1.3, c[1] + np.sin(a) * d * 0.9)
        col = [ORANGE, ORANGE, YEL, YEL, WHITE][rng.integers(0, 5)]
        s = rng.uniform(0.15, 0.45) * r
        cube(im, p, s, rng.uniform(0, 90), col)
        cube(glow, p, s * 1.8, rng.uniform(0, 90), ORANGE)
    cv2.circle(glow, I(c), int(r * 1.2), tuple(ORANGE), -1, cv2.LINE_AA)
    cv2.circle(core, I(c - np.array([0, r * 0.3])), int(r * 0.32), tuple(WHITE), -1, cv2.LINE_AA)
    for i in range(int(r * 0.4)):  # chunks and sparks flying out
        a = rng.uniform(np.pi * 1.05, np.pi * 1.95); d = rng.uniform(1.1, 3.4) * r
        p = c + np.array([np.cos(a), np.sin(a)]) * d
        cube(im, p, rng.uniform(4, 11) * r / 50, rng.uniform(0, 90), [SMOKE, ORANGE * 0.8, np.array([0.25, 0.27, 0.3])][rng.integers(0, 3)])
        q = c + np.array([np.cos(a), np.sin(a)]) * d * 0.6
        cv2.line(glow, I(q), I(q + np.array([np.cos(a), np.sin(a)]) * r * 0.35), tuple(ORANGE), 4, cv2.LINE_AA)
        cv2.line(core, I(q), I(q + np.array([np.cos(a), np.sin(a)]) * r * 0.25), tuple(YEL), 2, cv2.LINE_AA)

def flash(c, u, r):
    """big multi-cone muzzle flash out of the barrel along screen direction u, with side petals and smoke"""
    global im
    c = np.array(c, np.float32); n = np.array([-u[1], u[0]])
    for i in range(10):  # gun smoke rolling forward
        q = c + u * r * rng.uniform(0.8, 4.0) + n * rng.normal(0, r * 0.5)
        cube(im, q, rng.uniform(0.6, 1.4) * r, rng.uniform(0, 90), np.array([0.55, 0.56, 0.58]), 0.28)
    light(c, r * 3.2, 0.45)
    cv2.circle(glow, I(c), int(r * 2.6), tuple(ORANGE), -1, cv2.LINE_AA)
    for L, w, col, lay in ((5.2, 1.5, ORANGE, glow), (4.2, 0.95, YEL, core), (2.6, 0.5, WHITE, core)):
        tip = c + u * r * L
        poly = np.array([c + n * r * w * 0.5, c + u * r * L * 0.35 + n * r * w, tip, c + u * r * L * 0.35 - n * r * w, c - n * r * w * 0.5], np.int32)
        cv2.fillPoly(lay, [poly], tuple(col), cv2.LINE_AA)
    for s in (-1, 1):
        for ang in (55, 80):
            d = u * np.cos(np.radians(ang)) + n * s * np.sin(np.radians(ang))
            cv2.line(glow, I(c), I(c + d * r * 2.0), tuple(ORANGE), int(r * 0.8), cv2.LINE_AA)
            cv2.line(core, I(c), I(c + d * r * 1.5), tuple(YEL), max(2, int(r * 0.28)), cv2.LINE_AA)
    cv2.circle(core, I(c), int(r * 0.75), tuple(WHITE), -1, cv2.LINE_AA)

def stream(a, b, n, w0, w1, spread):
    """a stream of tracer rounds, fat near the gun, thin far away"""
    a = np.array(a, np.float32); b = np.array(b, np.float32); d = b - a; L = np.linalg.norm(d); u = d / L
    nn = np.array([-u[1], u[0]])
    hot = np.zeros((H, W), np.float32)
    cv2.line(hot, I(a), I(b), 1.0, int(w0 * 1.2), cv2.LINE_AA)
    hot = cv2.GaussianBlur(hot, (0, 0), w0)[..., None] * 0.45
    global glow
    glow = glow + hot * ORANGE
    for i in range(n):
        t0 = (i + rng.uniform(0, 0.6)) / n
        t1 = min(1.0, t0 + 0.6 / n)
        w = w0 + (w1 - w0) * t0
        off = nn * rng.normal(0, spread * t0)
        p, q = a + d * t0 + off, a + d * t1 + off
        cv2.line(glow, I(p), I(q), tuple(ORANGE), max(2, int(w * 3.2)), cv2.LINE_AA)
        cv2.line(core, I(p), I(q), tuple(YEL), max(1, int(w * 1.1)), cv2.LINE_AA)
        cv2.line(core, I(p), I(q), tuple(WHITE), max(1, int(w * 0.5)), cv2.LINE_AA)

def pops(c0, c1, n, r):
    """a line of small cannon hits (the 25mm walking through the crowd)"""
    for i in range(n):
        t = i / max(1, n - 1)
        c = np.array(c0, np.float32) * (1 - t) + np.array(c1, np.float32) * t + rng.normal(0, r * 0.6, 2)
        rr = r * rng.uniform(0.6, 1.2)
        light(c, rr * 2.2, 0.5)
        cv2.circle(glow, I(c), int(rr * 1.3), tuple(ORANGE), -1, cv2.LINE_AA)
        for k in range(5):
            cube(im, c + rng.normal(0, rr * 0.5, 2), rr * rng.uniform(0.3, 0.6), rng.uniform(0, 90), [ORANGE, YEL, WHITE][rng.integers(0, 3)])
        cv2.circle(core, I(c), int(rr * 0.35), tuple(WHITE), -1, cv2.LINE_AA)
        for k in range(8):
            a = rng.uniform(np.pi, np.pi * 2); L = rr * rng.uniform(1, 2.6)
            cv2.line(core, I(c), I(c + np.array([np.cos(a), np.sin(a)]) * L), tuple(YEL), 2, cv2.LINE_AA)

hits = [P(h) for h in pts["hits"]]
for i, h in enumerate(hits):
    if i in opt.get("skip", []):
        continue
    blast(h, opt.get("sizes", [95, 55, 40])[i])
guns = pts.get("guns") or [{"tips": pts["tips"], "target": pts["target"], "kind": opt.get("gun", "25")}]
srcs = list(hits)
for gi, gdef in enumerate(guns):
    tips = [P(t) for t in gdef["tips"]]
    mz = np.mean(tips, 0)
    tgt = P(gdef["target"])
    srcs.append(tgt)
    u = (tgt - mz) / np.linalg.norm(tgt - mz)
    if gdef.get("back"):  # the barrel's own direction on screen (flash follows the barrel, not the target line)
        bk = P(gdef["back"]); ub = (mz - bk) / np.linalg.norm(mz - bk)
    else:
        ub = u
    if gdef["kind"] == "25":
        sd = np.array(opt.get("strafe", [-1, 0.2]), np.float32); sd /= np.linalg.norm(sd)
        pops(tgt, tgt + sd * opt.get("strafeLen", 260), 9, 22)
        stream(mz + u * 10, tgt, 30, gdef.get("tw", 14), 3, 5)
        flash(mz, ub, gdef.get("flash", 34))
    else:
        stream(mz + u * 20, tgt, 3, gdef.get("tw", 16), 7, 0)
        flash(mz, ub, gdef.get("flash", 60))

# ---- compose light
glow = cv2.GaussianBlur(glow, (0, 0), 11)
core = cv2.GaussianBlur(core, (0, 0), 1.0)
im = np.clip(im, 0, 1)
im = screen(im, glow * 0.95)
im = screen(im, core)

# embers rising off the fires and soft out-of-focus sparks near the camera
emb = np.zeros_like(im)
for i in range(160):
    b0 = srcs[rng.integers(0, len(srcs))]
    x = b0[0] + rng.normal(0, 240); y = b0[1] - abs(rng.normal(0, 300))
    L = rng.uniform(6, 16); a = np.radians(rng.uniform(-125, -55))
    cv2.line(emb, I((x, y)), I((x + np.cos(a) * L, y + np.sin(a) * L)), tuple(ORANGE * rng.uniform(0.7, 1.0)), int(rng.integers(2, 4)), cv2.LINE_AA)
emb = cv2.GaussianBlur(emb, (0, 0), 0.8) + cv2.GaussianBlur(emb, (0, 0), 4) * 0.8
im = screen(im, emb)
bk = np.zeros_like(im)
for i in range(16):
    x = rng.choice([rng.uniform(0, W * 0.22), rng.uniform(W * 0.78, W)]); y = rng.uniform(0, H)
    cv2.circle(bk, I((x, y)), int(rng.uniform(10, 28)), tuple(ORANGE * rng.uniform(0.6, 1.0)), -1, cv2.LINE_AA)
bk = cv2.GaussianBlur(bk, (0, 0), 3) + cv2.GaussianBlur(bk, (0, 0), 12) * 0.6
im = screen(im, bk * 0.8)

# light rays from the top left
beams = np.zeros((H, W), np.float32)
for i in range(6):
    x0 = rng.uniform(-0.2, 0.5) * W; ang = np.radians(rng.uniform(20, 38)); w = rng.uniform(8, 24)
    cv2.line(beams, (int(x0), -10), (int(x0 + np.cos(ang) * W * 1.6), int(np.sin(ang) * W * 1.6)), rng.uniform(0.25, 0.5), int(w), cv2.LINE_AA)
beams = cv2.GaussianBlur(beams, (0, 0), 7) * np.clip(1.1 - yy / (H * 0.7), 0, 1)
im = screen(im, beams[..., None] * np.array([0.55, 0.8, 1.0]) * 0.45)

# bloom
bright = np.clip(im - 0.72, 0, 1) * 2.4
im = screen(im, cv2.GaussianBlur(bright, (0, 0), 16) * 0.5)

# soft focus toward the frame edges
m = np.clip(((((xx - W * 0.5) / (W * 0.5)) ** 2 + ((yy - H * 0.5) / (H * 0.55)) ** 2) ** 0.5 - 0.6) / 0.5, 0, 1) ** 1.3 * 0.8
im = im * (1 - m[..., None]) + cv2.GaussianBlur(im, (0, 0), 9) * m[..., None]

# grade: contrast, a little saturation (keeps the thermal greys), vignette, colour fringe, sharpen
hsv = cv2.cvtColor((np.clip(im, 0, 1) * 255).astype(np.uint8), cv2.COLOR_BGR2HSV).astype(np.float32)
hsv[..., 1] = np.clip(hsv[..., 1] * 1.2, 0, 255)
im = cv2.cvtColor(hsv.astype(np.uint8), cv2.COLOR_HSV2BGR).astype(np.float32) / 255
im = 0.5 + (im - 0.5) * 1.1
v = 1 - 0.36 * (((xx - W * 0.5) / (W * 0.7)) ** 2 + ((yy - H * 0.5) / (H * 0.78)) ** 2)
im = im * np.clip(v, 0.45, 1)[..., None]
b, g, r = cv2.split(im)
edge = np.clip(((xx - W / 2) / (W / 2)) ** 2 + ((yy - H / 2) / (H / 2)) ** 2, 0, 1)
im = cv2.merge([b * (1 - edge) + np.roll(b, -3, 1) * edge, g, r * (1 - edge) + np.roll(r, 3, 1) * edge])
im = im + (im - cv2.GaussianBlur(im, (0, 0), 1.2)) * 0.5
cv2.imwrite(out, np.clip(im * 255, 0, 255).astype(np.uint8))
print("wrote", out, "muzzle", mz)
