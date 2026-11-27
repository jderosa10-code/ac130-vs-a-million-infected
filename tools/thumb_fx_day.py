"""Daylight thumbnail after-effects (first-person / crew shots on the lobby baseplate).
usage: python thumb_fx_day.py raw.jpg pts.json out.png shot   (shot = fp | crew)
pts.json comes from snippets/thumb_stage_day.luau (screen points as 0..1 of the Studio viewport)."""
import cv2, numpy as np, sys, json

raw, ptsf, out, shot = sys.argv[1:5]
plate = sys.argv[5] if len(sys.argv) > 5 else None  # same shot with the foreground (your arms + gun) hidden
rng = np.random.default_rng(5 if shot == "fp" else 9)
src = cv2.imread(raw).astype(np.float32) / 255
pts = json.load(open(ptsf))
H0, W0 = src.shape[:2]

# crop the Studio capture (about 1.98:1) to 16:9 and scale to 1920x1080
cw = int(round(H0 * 16 / 9))
cx0 = (W0 - cw) // 2
im = cv2.resize(src[:, cx0:cx0 + cw], (1920, 1080), interpolation=cv2.INTER_CUBIC)
H, W = im.shape[:2]
yy, xx = np.mgrid[0:H, 0:W].astype(np.float32)
def P(p):  # viewport 0..1 -> output pixels
    return np.array([(p[0] * W0 - cx0) / cw * W, p[1] * H], np.float32)
def I(p): return (int(p[0]), int(p[1]))

ORANGE = np.array([0.12, 0.5, 1.0]); YEL = np.array([0.5, 0.93, 1.0]); WHITE = np.array([0.94, 0.98, 1.0])
DUST = np.array([0.55, 0.62, 0.70])  # BGR warm grey-tan
BRASS = np.array([0.25, 0.68, 0.92])
glow = np.zeros_like(im); core = np.zeros_like(im)

def screen(a, b): return 1 - (1 - a) * (1 - np.clip(b, 0, 1))
def noise(scale, seed):
    r = np.random.default_rng(seed)
    small = r.random((int(H / scale) + 3, int(W / scale) + 3)).astype(np.float32)
    return cv2.resize(small, (W + 3 * int(scale), H + 3 * int(scale)), interpolation=cv2.INTER_CUBIC)[:H, :W]

# foreground mask: where the plate without the arms/gun differs (lower part of the frame only)
FG = np.zeros((H, W, 1), np.float32)
if plate:
    pl = cv2.imread(plate).astype(np.float32) / 255
    pl = cv2.resize(pl[:, cx0:cx0 + cw], (W, H), interpolation=cv2.INTER_CUBIC)
    d = (np.abs(pl - im).sum(2) > 0.25).astype(np.uint8) * (yy > H * 0.45)
    d = cv2.morphologyEx(d.astype(np.uint8), cv2.MORPH_OPEN, np.ones((5, 5), np.uint8))
    d = cv2.morphologyEx(d, cv2.MORPH_CLOSE, np.ones((15, 15), np.uint8))
    FG = cv2.GaussianBlur(d.astype(np.float32), (0, 0), 1.5)[..., None]

# ---- warm the grey ground and the sky
hsv = cv2.cvtColor((np.clip(im, 0, 1) * 255).astype(np.uint8), cv2.COLOR_BGR2HSV).astype(np.float32)
low_sat = np.clip(1 - hsv[..., 1] / 70, 0, 1)[..., None]
hz = 0.6 * H if shot == "fp" else 0.0
ground = np.clip((yy - hz) / 30, 0, 1)[..., None] * low_sat
im = im * (1 - ground * 0.8) + im * np.array([0.86, 0.95, 1.06]) * ground * 0.8

BASE = im.copy()
def puff(layer, c, r, col, a):
    tmp = layer.copy()
    cv2.circle(tmp, I(c), int(r), tuple(col), -1, cv2.LINE_AA)
    layer[:] = layer * (1 - a) + tmp * a

def chunk(layer, c, s, ang, col, a=1.0):
    box = cv2.boxPoints(((float(c[0]), float(c[1])), (float(s), float(s * rng.uniform(0.6, 1.0))), float(ang))).astype(np.int32)
    if a >= 1:
        cv2.fillConvexPoly(layer, box, tuple(col), cv2.LINE_AA)
    else:
        tmp = layer.copy(); cv2.fillConvexPoly(tmp, box, tuple(col), cv2.LINE_AA)
        layer[:] = layer * (1 - a) + tmp * a

def dust_cloud(c, size, strength=1.0):
    """kicked-up dust: soft lumpy cloud hugging the ground, plus pebbles"""
    global im
    m = np.zeros((H, W), np.float32)
    for i in range(int(10 + size / 6)):
        p = (c[0] + rng.normal(0, size * 0.9), c[1] - abs(rng.normal(0, size * 0.35)))
        cv2.circle(m, I(p), int(rng.uniform(0.3, 0.8) * size), 1.0, -1, cv2.LINE_AA)
    m = cv2.GaussianBlur(m, (0, 0), size * 0.35) * (0.45 + 0.55 * noise(18, int(c[0]) % 97))
    a = np.clip(m * 0.55 * strength, 0, 0.7)[..., None]
    im = im * (1 - a) + DUST * a
    for i in range(int(size / 9)):
        p = (c[0] + rng.normal(0, size * 0.9), c[1] - abs(rng.normal(0, size * 0.6)))
        chunk(im, p, rng.uniform(0.08, 0.2) * size, rng.uniform(0, 90), np.array([0.22, 0.25, 0.3]) * rng.uniform(0.7, 1.3))

def flash(c, r, ang=None):
    """muzzle flash; ang = None for a gun pointing into the screen (a star)"""
    c = np.array(c, np.float32)
    cv2.circle(glow, I(c), int(r * 2.6), tuple(ORANGE), -1, cv2.LINE_AA)
    if ang is None:
        for k in range(7):
            a = np.radians(k * 360 / 7 + rng.uniform(-12, 12)); L = r * rng.uniform(1.6, 3.0)
            e = c + np.array([np.cos(a), np.sin(a)]) * L
            n = np.array([-np.sin(a), np.cos(a)]) * r * 0.28
            pts_ = np.array([c + n, e, c - n], np.int32)
            cv2.fillConvexPoly(glow, pts_, tuple(ORANGE), cv2.LINE_AA)
            pts2 = np.array([c + n * 0.5, c + (e - c) * 0.7, c - n * 0.5], np.int32)
            cv2.fillConvexPoly(core, pts2, tuple(YEL), cv2.LINE_AA)
        cv2.circle(core, I(c), int(r * 0.9), tuple(WHITE), -1, cv2.LINE_AA)
    else:
        u = np.array([np.cos(np.radians(ang)), np.sin(np.radians(ang))]); n = np.array([-u[1], u[0]])
        for L, w, col, lay in ((4.2, 1.3, ORANGE, glow), (3.4, 0.8, YEL, core), (2.0, 0.45, WHITE, core)):
            tip = c + u * r * L
            poly = np.array([c + n * r * w * 0.5, c + u * r * L * 0.35 + n * r * w, tip, c + u * r * L * 0.35 - n * r * w, c - n * r * w * 0.5], np.int32)
            cv2.fillPoly(lay, [poly], tuple(col), cv2.LINE_AA)
        cv2.circle(core, I(c), int(r * 0.6), tuple(WHITE), -1, cv2.LINE_AA)

def tracers(a, b, n, w, spread=6):
    a = np.array(a, np.float32); b = np.array(b, np.float32); d = b - a; L = np.linalg.norm(d); u = d / L
    nn = np.array([-u[1], u[0]])
    for i in range(n):
        t0 = rng.uniform(0.05, 0.85); t1 = t0 + rng.uniform(0.08, 0.16)
        off = nn * rng.normal(0, spread)
        p, q = a + d * t0 + off, a + d * min(1, t1) + off
        cv2.line(glow, I(p), I(q), tuple(ORANGE), int(w * 3.5), cv2.LINE_AA)
        cv2.line(core, I(p), I(q), tuple(YEL), max(1, int(w)), cv2.LINE_AA)
        cv2.line(core, I(p), I(q), tuple(WHITE), max(1, int(w * 0.45)), cv2.LINE_AA)

def sparks(c, n, reach, up=True):
    c = np.array(c, np.float32)
    for i in range(n):
        a = rng.uniform(np.pi * 1.0, np.pi * 2.0) if up else rng.uniform(0, np.pi * 2)
        L = reach * rng.uniform(0.2, 1.0)
        p = c + np.array([np.cos(a), np.sin(a)]) * L * rng.uniform(0, 0.4)
        q = p + np.array([np.cos(a), np.sin(a)]) * L * rng.uniform(0.15, 0.35)
        cv2.line(glow, I(p), I(q), tuple(ORANGE), 5, cv2.LINE_AA)
        cv2.line(core, I(p), I(q), tuple(YEL), 2, cv2.LINE_AA)

def casings(c, n, dirx, size):
    for i in range(n):
        t = i / max(1, n - 1)
        p = (c[0] + dirx * (30 + t * 260 + rng.normal(0, 25)), c[1] - 60 * np.sin(t * 2.6) - t * 40 + rng.normal(0, 20))
        s = size * (1 + t * 0.9)
        box = cv2.boxPoints(((p[0], p[1]), (s * 2.2, s), rng.uniform(0, 180))).astype(np.int32)
        cv2.fillConvexPoly(im, box, tuple(BRASS * rng.uniform(0.8, 1.15)), cv2.LINE_AA)
        cv2.circle(core, (int(p[0]), int(p[1])), max(1, int(s * 0.35)), tuple(WHITE * 0.7), -1, cv2.LINE_AA)

def blast(c, r):
    """a voxel explosion like the game's (far off, under the AC-130's fire)"""
    global im
    d = np.exp(-(((xx - c[0]) / (r * 3)) ** 2 + ((yy - c[1]) / (r * 1.5)) ** 2))[..., None]
    im = im + d * np.array([0.05, 0.22, 0.45]) * 0.8
    for i in range(int(r * 0.35)):
        h = rng.uniform(0.3, 2.4) * r
        p = (c[0] + rng.uniform(-0.6, 0.6) * r, c[1] - h)
        chunk(im, p, rng.uniform(0.35, 0.8) * r, rng.uniform(0, 90), np.array([0.2, 0.21, 0.24]) * rng.uniform(0.8, 1.4), 0.6)
    for i in range(int(r * 0.5)):
        a = rng.uniform(np.pi * 1.05, np.pi * 1.95); dd = rng.uniform(0, 1.1) * r
        p = (c[0] + np.cos(a) * dd, c[1] + np.sin(a) * dd * 0.8)
        col = [ORANGE, YEL, YEL, WHITE][rng.integers(0, 4)]
        s = rng.uniform(0.18, 0.5) * r
        chunk(im, p, s, rng.uniform(0, 90), col)
        chunk(glow, p, s * 1.6, rng.uniform(0, 90), ORANGE)
    cv2.circle(glow, I(c), int(r * 1.4), tuple(ORANGE), -1, cv2.LINE_AA)

sun = P(pts["sun"])

if shot == "fp":
    muz = P(pts["muzzle"]) + np.array([0, -18])
    lead = P(pts["lead"])
    # dust kicked up by every runner close to the camera
    for f in sorted(pts["feet"], key=lambda f: -f[2]):
        if f[2] < 30 and f[1] < 0.93:
            c = P(f)
            dust_cloud(c, 900 / f[2], 1.2 if f[2] < 12 else 0.9)
    im = im * (1 - FG) + BASE * FG  # the arms and gun stay in front of the dust
    # the AC-130 firing down into the far horde: tracer stream and a blast
    ac = P(pts["ac"])
    gun = ac + np.array([-30, 55])
    hit = np.array([W * 0.79, H * 0.6])
    blast(hit, 46)
    tracers(gun, hit, 7, 3, 4)
    flash(gun, 16, np.degrees(np.arctan2(hit[1] - gun[1], hit[0] - gun[0])))
    # your minigun: flash, tracers into the lead, sparks off it, brass flying right
    tracers(muz, lead + np.array([0, 40]), 10, 7, 14)
    flash(muz, 34)
    sparks(lead + np.array([0, 60]), 40, 160)
    casings(muz + np.array([70, 40]), 9, 1, 11)
    # debris chunks flying past the camera (motion-blurred later)
    near = np.zeros_like(im); nmask = np.zeros((H, W), np.float32)
    for i in range(12):
        side = rng.choice([-1, 1])
        p = (W * 0.5 + side * rng.uniform(0.25, 0.5) * W, rng.uniform(0.55, 0.85) * H)
        s = rng.uniform(14, 46)
        col = np.array([0.2, 0.23, 0.27]) * rng.uniform(0.7, 1.4)
        box = cv2.boxPoints((p, (s, s * rng.uniform(0.6, 1)), rng.uniform(0, 90))).astype(np.int32)
        cv2.fillConvexPoly(near, box, tuple(col), cv2.LINE_AA); cv2.fillConvexPoly(nmask, box, 1.0, cv2.LINE_AA)
    k = np.zeros((1, 31), np.float32); k[0, :] = 1 / 31
    near = cv2.filter2D(near, -1, k); nmask = cv2.filter2D(nmask, -1, k)[..., None]
    im = im * (1 - nmask) + near * np.where(nmask > 0, 1 / np.maximum(nmask, 1e-3), 0) * nmask
else:
    muz = P(pts["muzzle"]); tgt = P(pts["target"])
    back = P(pts["back"]); front = P(pts["front"]); rtgt = P(pts["rtarget"])
    ej = P(pts["eject"])
    ang = np.degrees(np.arctan2(tgt[1] - muz[1], tgt[0] - muz[0]))
    # warm light pool around the gunner (from the flash)
    d = np.exp(-(((xx - muz[0]) / 260) ** 2 + ((yy - muz[1]) / 170) ** 2))[..., None]
    im = im + d * np.array([0.04, 0.2, 0.42])
    tracers(muz, tgt, 14, 5, 16)
    flash(muz, 30, ang)
    sparks(muz, 60, 200, up=False)
    casings(ej, 10, 1, 9)
    # rocket just leaving the launcher: smoke trail back past the shooter, bright motor, blast at the target
    u = (front - back) / np.linalg.norm(front - back)
    head = front + u * 230
    tr = np.zeros((H, W), np.float32)
    for i in range(40):
        f = i / 39
        c = front + (head - front) * f + rng.normal(0, 4 * f, 2)
        cv2.circle(tr, I(c), int(6 + 12 * f), 0.8, -1, cv2.LINE_AA)
    for i in range(12):  # back-blast smoke
        c = back - u * rng.uniform(10, 120) + rng.normal(0, 18, 2)
        cv2.circle(tr, I(c), int(rng.uniform(12, 30)), 0.6, -1, cv2.LINE_AA)
    tr = cv2.GaussianBlur(tr, (0, 0), 5)[..., None]
    im = im * (1 - tr * 0.8) + np.array([0.88, 0.9, 0.92]) * tr * 0.8
    cv2.line(glow, I(head - u * 50), I(head), tuple(ORANGE), 26, cv2.LINE_AA)
    cv2.circle(core, I(head - u * 34), 9, tuple(WHITE), -1, cv2.LINE_AA)
    flash(back, 9, np.degrees(np.arctan2(-u[1], -u[0])))
    blast(rtgt, 60)
    # sparks and embers all over the floor near the fight
    for i in range(70):
        p = np.array([rng.uniform(0.2, 0.8) * W, rng.uniform(0.35, 0.95) * H])
        a = rng.uniform(0, np.pi * 2); L = rng.uniform(8, 22)
        q = p + np.array([np.cos(a), np.sin(a)]) * L
        cv2.line(glow, I(p), I(q), tuple(ORANGE), 4, cv2.LINE_AA)
        cv2.line(core, I(p), I(q), tuple(YEL), 2, cv2.LINE_AA)

# ---- compose the light layers
glow = cv2.GaussianBlur(glow, (0, 0), 10)
core = cv2.GaussianBlur(core, (0, 0), 1.0)
im = np.clip(im, 0, 1)
im = screen(im, glow * 0.9)
im = screen(im, core)

# ---- sun: hot glow, god rays, and a small lens flare across the frame
if -0.2 * W < sun[0] < 1.2 * W and sun[1] < 0.5 * H:
    sg = np.exp(-(((xx - sun[0]) ** 2 + (yy - sun[1]) ** 2) / (2 * 260 ** 2)))[..., None]
    im = screen(im, sg * np.array([0.55, 0.85, 1.0]) * 0.75)
    rays = np.zeros((H, W), np.float32)
    for i in range(14):
        a = np.radians(rng.uniform(15, 165)); L = W * 1.4; w = rng.uniform(10, 40)
        cv2.line(rays, I(sun), I(sun + np.array([np.cos(a), np.sin(a)]) * L), rng.uniform(0.15, 0.4), int(w), cv2.LINE_AA)
    rays = cv2.GaussianBlur(rays, (0, 0), 14) * np.clip(1.2 - np.hypot(xx - sun[0], yy - sun[1]) / (W * 0.9), 0, 1)
    im = screen(im, rays[..., None] * np.array([0.6, 0.85, 1.0]) * 0.55)
    ctr = np.array([W / 2, H / 2])
    fl = np.zeros_like(im)
    for t, r, col in ((0.5, 40, (0.4, 0.8, 1.0)), (0.9, 22, (1.0, 0.7, 0.4)), (1.3, 70, (0.5, 1.0, 0.6)), (1.6, 30, (0.9, 0.6, 1.0))):
        p = sun + (ctr - sun) * t
        cv2.circle(fl, I(p), r, col, -1, cv2.LINE_AA)
    im = screen(im, cv2.GaussianBlur(fl, (0, 0), 6) * 0.12)

# ---- bloom
bright = np.clip(im - 0.75, 0, 1) * 2.4
im = screen(im, cv2.GaussianBlur(bright, (0, 0), 16) * 0.5)

# ---- radial zoom blur toward the edges (speed), sharp in the middle
cx, cy = (W * 0.53, H * 0.5)
acc = np.zeros_like(im); n = 8
for i in range(n):
    s = 1 + 0.006 * i
    M = np.float32([[s, 0, cx * (1 - s)], [0, s, cy * (1 - s)]])
    acc += cv2.warpAffine(im, M, (W, H), borderMode=cv2.BORDER_REFLECT)
zoom = acc / n
m = np.clip((np.hypot((xx - cx) / (W * 0.5), (yy - cy) / (H * 0.5)) - 0.6) / 0.6, 0, 1)[..., None]
if shot == "crew":  # the near infected along the bottom are out of focus instead
    m = np.maximum(m * 0.6, np.clip((yy - H * 0.78) / (H * 0.12), 0, 1)[..., None])
    soft = cv2.GaussianBlur(im, (0, 0), 7)
    im = im * (1 - m) + soft * m
else:
    im = im * (1 - m) + zoom * m

# ---- grade: saturation, contrast, warm highlights / cool shadows, vignette
hsv = cv2.cvtColor((np.clip(im, 0, 1) * 255).astype(np.uint8), cv2.COLOR_BGR2HSV).astype(np.float32)
hsv[..., 1] = np.clip(hsv[..., 1] * 1.3, 0, 255)
im = cv2.cvtColor(hsv.astype(np.uint8), cv2.COLOR_HSV2BGR).astype(np.float32) / 255
im = 0.5 + (im - 0.5) * 1.12
lum = im.mean(2, keepdims=True)
im = im + (lum - 0.5) * np.array([-0.05, 0.0, 0.06]) * 0.8
v = 1 - 0.38 * (((xx - W * 0.5) / (W * 0.7)) ** 2 + ((yy - H * 0.5) / (H * 0.75)) ** 2)
im = im * np.clip(v, 0.45, 1)[..., None]
blur = cv2.GaussianBlur(im, (0, 0), 1.2)
im = im + (im - blur) * 0.55
cv2.imwrite(out, np.clip(im * 255, 0, 255).astype(np.uint8))
print("wrote", out)
