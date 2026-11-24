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

import json
spec = json.load(open(sys.argv[3]))
blasts = [tuple(b) for b in spec.get("blasts", [])]

# ---- thick black fog ring on the horizon (where the infected come from)
def smooth_noise(scale, seed):
    r = np.random.default_rng(seed)
    small = r.random((int(H / scale) + 3, int(W / scale) + 3)).astype(np.float32)
    big = cv2.resize(small, (W + 3 * int(scale), H + 3 * int(scale)), interpolation=cv2.INTER_CUBIC)[:H, :W]
    return big
fg = spec.get("fog")
if fg:
    gray = cv2.cvtColor((im * 255).astype(np.uint8), cv2.COLOR_BGR2GRAY).astype(np.float32) / 255
    gx = cv2.Sobel(gray, cv2.CV_32F, 1, 0, ksize=3); gy = cv2.Sobel(gray, cv2.CV_32F, 0, 1, ksize=3)
    tex = cv2.GaussianBlur(np.sqrt(gx * gx + gy * gy), (0, 0), 1.5)
    obj = (tex > fg.get("tex", 0.06)).astype(np.uint8)
    obj = cv2.morphologyEx(obj, cv2.MORPH_CLOSE, np.ones((fg.get("close", 15), fg.get("close", 15)), np.uint8))
    # fill holes inside objects
    ff = obj.copy(); msk = np.zeros((H + 2, W + 2), np.uint8); cv2.floodFill(ff, msk, (0, 0), 1)
    holes = (ff == 0).astype(np.uint8); obj = np.clip(obj + holes, 0, 1)
    hsv0 = cv2.cvtColor((np.clip(im, 0, 1) * 255).astype(np.uint8), cv2.COLOR_BGR2HSV)
    dust = ((hsv0[..., 1] < 60) & (hsv0[..., 2] > 170)).astype(np.uint8)
    dust = cv2.dilate(dust, np.ones((5, 5), np.uint8))
    obj = np.where(dust > 0, 0, obj).astype(np.uint8)
    for bx in fg.get("protect", []):  # boxes that must stay untouched (aircraft parts that read smooth)
        x0, y0, x1, y1 = bx; obj[y0:y1, x0:x1] = np.maximum(obj[y0:y1, x0:x1], 1)
    obj = cv2.erode(obj, np.ones((5, 5), np.uint8)); obj = cv2.GaussianBlur(obj.astype(np.float32), (0, 0), 1.2)
    free = 1 - np.clip(obj * 1.3, 0, 1)
    hx0, hy0, hx1, hy1 = fg["horizon"]  # horizon line (left point, right point)
    hor = hy0 + (hy1 - hy0) * (xx - hx0) / max(1, hx1 - hx0)
    up = hor - yy  # px above the horizon
    n1 = smooth_noise(90, 1); n2 = smooth_noise(35, 2); n3 = smooth_noise(14, 3)
    billow = 0.55 * n1 + 0.3 * n2 + 0.15 * n3
    top = fg.get("h", 260) * (0.55 + 0.8 * smooth_noise(120, 4))  # ragged billowing top
    band = np.clip(1 - (up - top * 0.35) / (top * 0.65), 0, 1) * np.clip(1 - (-up) / fg.get("below", 40), 0, 1)
    band = band ** 0.8 * (0.75 + 0.35 * billow)
    a = np.clip(band * fg.get("strength", 1.0), 0, 0.97) * free
    shade = 0.05 + 0.10 * billow[..., None] * np.clip(up / 300, 0, 1)[..., None]  # lighter billow tops
    fogc = np.concatenate([shade * 1.05, shade, shade * 0.95], 2)
    # existing dark blobs in the sky turn black too (they render blue through the haze)
    hsv = cv2.cvtColor((np.clip(im, 0, 1) * 255).astype(np.uint8), cv2.COLOR_BGR2HSV).astype(np.float32)
    V = hsv[..., 2] / 255; Hh = hsv[..., 0]
    skyish = ((Hh > 90) & (Hh < 125)).astype(np.float32)
    ref = cv2.GaussianBlur(np.where(skyish > 0, V, 0).astype(np.float32), (0, 0), 1)
    ref = np.maximum.accumulate(np.max(np.where(skyish > 0, V, 0), axis=1)[:, None] * np.ones((1, W), np.float32), axis=0) * 0 + np.percentile(V[skyish > 0], 92)
    dark = np.clip((ref - V) / (ref * 0.55), 0, 1) * skyish * free * np.clip(1.4 - yy / (H * 0.9), 0, 1)
    a = np.clip(np.maximum(a, dark * 0.9), 0, 0.97)
    im = im * (1 - a[..., None]) + fogc * a[..., None]
    FOG_A = a
else:
    FOG_A = np.zeros((H, W), np.float32)

for b in blasts:
    blast((b[0], b[1]), b[2])

# tracer streams from each gun to an impact
STYLE = {"25": (26, 30, 4, 13), "40": (34, 48, 6, 17), "105": (90, 60, 12, 24), "30": (22, 26, 3, 11), "rocket": (0, 0, 7, 16)}
for sh in spec.get("shots", []):
    g = tuple(sh["from"]); t = tuple(sh["to"]); dash, gap, w, fr = STYLE[sh["kind"]]
    sc = sh.get("scale", 1.0)
    if sh["kind"] == "rocket":
        # a rocket: bright head, smoke trail back to the launcher
        p = np.array(g, float); q = np.array(t, float); u = (q - p) / np.linalg.norm(q - p)
        head = p + (q - p) * sh.get("at", 0.6)
        trail = np.zeros((H, W), np.float32)
        n = int(np.linalg.norm(head - p) / 6)
        for i in range(n):
            f = i / max(1, n)
            c = p + (head - p) * f + rng.normal(0, 3 * f, 2)
            cv2.circle(trail, P(c), max(2, int((5 + 9 * f) * sc)), 0.75 * (0.35 + 0.65 * f), -1, cv2.LINE_AA)
        trail = cv2.GaussianBlur(trail, (0, 0), 3)
        im = im * (1 - trail[..., None]) + np.array([0.86, 0.88, 0.9]) * trail[..., None]
        cv2.line(glow, P(head - u * 40 * sc), P(head), tuple(ORANGE), int(22 * sc), cv2.LINE_AA)
        cv2.line(core, P(head - u * 26 * sc), P(head), tuple(YEL), int(7 * sc), cv2.LINE_AA)
        cv2.circle(core, P(head - u * 30 * sc), int(6 * sc), tuple(WHITE), -1, cv2.LINE_AA)
        flash(g, fr * 0.7 * sc, np.degrees(np.arctan2(u[1], u[0])))
        continue
    streak(g, t, dash * sc, gap * sc, max(1, int(w * sc)), sh.get("phase", 8))
    flash(g, fr * sc, np.degrees(np.arctan2(t[1] - g[1], t[0] - g[0])))
for bb in spec.get("bombs", []):
    # a falling bomb: dark body, fins, a faint whistle streak above it
    x, y, sz = bb[0], bb[1], bb[2]; ang = bb[3] if len(bb) > 3 else 80
    box = cv2.boxPoints(((x, y), (sz * 2.4, sz), ang)).astype(np.int32)
    cv2.fillConvexPoly(im, box, (0.18, 0.2, 0.22), cv2.LINE_AA)
    a = np.radians(ang)
    tail = (x - np.cos(a) * sz * 1.4, y - np.sin(a) * sz * 1.4)
    fin = cv2.boxPoints((tail, (sz * 0.5, sz * 1.8), ang)).astype(np.int32)
    cv2.fillConvexPoly(im, fin, (0.14, 0.15, 0.17), cv2.LINE_AA)
    cv2.line(glow, P((x - np.cos(a) * sz * 7, y - np.sin(a) * sz * 7)), P(tail), (0.6, 0.6, 0.6), max(1, int(sz * 0.4)), cv2.LINE_AA)

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
beams = cv2.GaussianBlur(beams, (0, 0), 6) * np.clip(1.15 - yy / (H * 0.62), 0, 1) * (1 - 0.8 * FOG_A)
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

# blur the edges (sharp in the middle, soft toward the frame)
eb = spec.get("edge_blur", 1.0)
if eb > 0:
    cx, cy = spec.get("focus", [0.5, 0.5])
    m = np.clip(((((xx - W * cx) / (W * 0.5)) ** 2 + ((yy - H * cy) / (H * 0.55)) ** 2) ** 0.5 - 0.55) / 0.55, 0, 1) ** 1.4 * eb
    soft = cv2.GaussianBlur(im, (0, 0), 9)
    im = im * (1 - m[..., None]) + soft * m[..., None]

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
