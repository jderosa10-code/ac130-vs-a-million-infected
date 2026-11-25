import cv2, numpy as np, subprocess, os, sys
from PIL import Image, ImageDraw, ImageFont

W, H, FPS = 1080, 1920, 30
PX0, PY0, PW, PH = 0, 330, 1080, 1210  # panel on screen
SRC_W = 880  # source crop width at zoom 1 (source images are 1920x987)
CX, CY = 905, 520
ANTON = "/usr/share/fonts/truetype/google-fonts/ofl/anton/Anton-Regular.ttf"
rng = np.random.default_rng(4)

imgs = {k: cv2.imread(f"/tmp/vid/{k}.jpg").astype(np.float32) / 255 for k in ("day", "night", "thermal")}

def crop(img, z, cx=CX, cy=CY):
    """panel view of a source image at zoom z; also returns the src->panel mapping"""
    sw = SRC_W / z; sh = sw * PH / PW
    x0, y0 = cx - sw / 2, cy - sh / 2
    M = np.float32([[PW / sw, 0, -x0 * PW / sw], [0, PH / sh, -y0 * PH / sh]])
    out = cv2.warpAffine(img, M, (PW, PH), flags=cv2.INTER_CUBIC, borderMode=cv2.BORDER_REFLECT)
    return out, M

def to_panel(M, p):
    return np.array([M[0, 0] * p[0] + M[0, 2], M[1, 1] * p[1] + M[1, 2]])

bg_cache = {}
def background(key):
    if key not in bg_cache:
        im = imgs[key]
        s = H / im.shape[0]
        big = cv2.resize(im, (int(im.shape[1] * s), H))
        x = (big.shape[1] - W) // 2
        b = cv2.GaussianBlur(big[:, x:x + W], (0, 0), 28) * 0.38
        bg_cache[key] = b
    return bg_cache[key].copy()

def sharpen(p):
    return np.clip(p + (p - cv2.GaussianBlur(p, (0, 0), 1.4)) * 0.6, 0, 1)

# ---------------------------------------------------------------- text
font_cache = {}
def font(sz):
    if sz not in font_cache:
        font_cache[sz] = ImageFont.truetype(ANTON, sz)
    return font_cache[sz]

def text_layer(lines, y, sz, t_in, t, color=(255, 255, 255), stroke=10, pill=None):
    """RGBA layer with centered lines popping in at t_in"""
    a = np.clip((t - t_in) / 0.18, 0, 1)
    if a <= 0:
        return None
    sc = 0.82 + 0.18 * (1 - (1 - a) ** 3)
    f = font(max(10, int(sz * sc)))
    im = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    d = ImageDraw.Draw(im)
    yy = y
    for ln in lines:
        bb = d.textbbox((0, 0), ln, font=f, stroke_width=stroke)
        tw, th = bb[2] - bb[0], bb[3] - bb[1]
        x = (W - tw) / 2 - bb[0]
        if pill:
            pad = 26
            d.rounded_rectangle((x + bb[0] - pad, yy - 10, x + bb[2] + pad, yy + th + 18), radius=22, fill=pill)
            d.text((x, yy - bb[1]), ln, font=f, fill=color)
        else:
            d.text((x, yy - bb[1]), ln, font=f, fill=color, stroke_width=stroke, stroke_fill=(0, 0, 0))
        yy += th + int(sz * 0.12)
    arr = np.asarray(im).astype(np.float32) / 255
    arr[..., 3] *= a
    return arr

def over(frame, layer):
    if layer is None:
        return frame
    al = layer[..., 3:4]
    rgb = layer[..., [2, 1, 0]]
    return frame * (1 - al) + rgb * al

def label(frame, txt, t_in, t, x, y, col=(30, 30, 30), bg=(255, 214, 40)):
    a = np.clip((t - t_in) / 0.15, 0, 1)
    if a <= 0:
        return frame
    f = font(64)
    im = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    d = ImageDraw.Draw(im)
    bb = d.textbbox((0, 0), txt, font=f)
    d.rounded_rectangle((x - 22, y - 8, x + bb[2] - bb[0] + 22, y + bb[3] - bb[1] + 26), radius=16, fill=bg + (255,))
    d.text((x - bb[0], y - bb[1] + 4), txt, font=f, fill=col)
    arr = np.asarray(im).astype(np.float32) / 255
    arr[..., 3] *= a
    return over(frame, arr)

# ---------------------------------------------------------------- firing FX (in source-image coords)
th = imgs["thermal"]
hsv = cv2.cvtColor((th * 255).astype(np.uint8), cv2.COLOR_BGR2HSV)
mask = (((hsv[..., 0] < 12) | (hsv[..., 0] > 160)) & (hsv[..., 1] > 120) & (hsv[..., 2] > 60)).astype(np.uint8)
n, lab, stats, cents = cv2.connectedComponentsWithStats(mask)
targets = [tuple(cents[i]) for i in range(1, n) if stats[i, 4] > 25 and abs(cents[i][0] - CX) < 420 and abs(cents[i][1] - CY) < 470]
rng.shuffle(targets)
print("targets", len(targets))

ORANGE = np.array([0.15, 0.5, 1.0]); YEL = np.array([0.5, 0.95, 1.0]); WHITE = np.array([0.95, 0.98, 1.0])

def make_volley(t0, t1, rate):
    shots = []
    t = t0; i = 0
    while t < t1:
        tg = targets[i % len(targets)]; i += 1
        for k in range(4):  # a short burst at each target
            jit = rng.normal(0, 6, 2)
            shots.append(dict(t=t + k * 0.06, to=np.array(tg) + jit))
        t += 1 / rate
    return shots

def draw_fx(frame, M, t, shots, z):
    glow = np.zeros_like(frame); core = np.zeros_like(frame)
    gun = np.array([PW * 1.15, -PH * 0.25])  # the gunship is up and to the right, off panel
    for s in shots:
        dt = t - s["t"]
        if dt < 0:
            continue
        to = to_panel(M, s["to"])
        fly = 0.22
        if dt < fly:
            f = dt / fly
            a = gun + (to - gun) * max(0, f - 0.35); b = gun + (to - gun) * f
            cv2.line(glow, tuple(a.astype(int)), tuple(b.astype(int)), tuple(ORANGE), 22, cv2.LINE_AA)
            cv2.line(core, tuple(a.astype(int)), tuple(b.astype(int)), tuple(YEL), 8, cv2.LINE_AA)
            cv2.line(core, tuple(a.astype(int)), tuple(b.astype(int)), tuple(WHITE), 2, cv2.LINE_AA)
        else:
            e = dt - fly
            if e < 0.55:
                k = 1 - e / 0.55
                r = int((20 + 90 * e) * z)
                cv2.circle(glow, tuple(to.astype(int)), r + 10, tuple(ORANGE * k), -1, cv2.LINE_AA)
                cv2.circle(core, tuple(to.astype(int)), max(2, int(r * 0.45 * k)), tuple(WHITE * k), -1, cv2.LINE_AA)
                rs = np.random.default_rng(int(s["t"] * 1000))
                for j in range(9):  # voxel chunks flying out
                    ang = rs.uniform(np.pi * 1.0, np.pi * 2.0); sp = rs.uniform(120, 320)
                    p = to + np.array([np.cos(ang), np.sin(ang)]) * sp * e + np.array([0, 420 * e * e])
                    sz = rs.uniform(7, 15) * k
                    col = [ORANGE, YEL, WHITE][j % 3] * k
                    box = cv2.boxPoints(((float(p[0]), float(p[1])), (sz, sz), rs.uniform(0, 90))).astype(np.int32)
                    cv2.fillConvexPoly(core, box, tuple(col), cv2.LINE_AA)
    glow = cv2.GaussianBlur(glow, (0, 0), 10)
    core = cv2.GaussianBlur(core, (0, 0), 0.8)
    frame = 1 - (1 - frame) * (1 - np.clip(glow * 0.9, 0, 1))
    frame = 1 - (1 - frame) * (1 - np.clip(core, 0, 1))
    return frame

emb = [dict(x=rng.uniform(0, PW), y=rng.uniform(0, PH), v=rng.uniform(40, 110), s=rng.uniform(2, 4), ph=rng.uniform(0, 6)) for _ in range(40)]
def embers(frame, t, k=1.0):
    lay = np.zeros_like(frame)
    for e in emb:
        y = (e["y"] - e["v"] * t) % PH; x = e["x"] + 12 * np.sin(t * 2 + e["ph"])
        cv2.line(lay, (int(x), int(y)), (int(x + 3), int(y - 9)), tuple(ORANGE * k), int(e["s"]), cv2.LINE_AA)
    lay = lay + cv2.GaussianBlur(lay, (0, 0), 4)
    return 1 - (1 - frame) * (1 - np.clip(lay, 0, 1))

def grade_thermal(p):
    return p  # the capture already has the game's thermal look

# ---------------------------------------------------------------- compose
WM = text_layer(["GUNSHIP VS A MILLION INFECTED"], PY0 + PH + 34, 54, -1, 0, color=(255, 214, 40), stroke=6)

def compose(panel, bgkey, t, texts=(), labels=(), flash=0.0):
    fr = background(bgkey)
    fr[PY0:PY0 + PH, PX0:PX0 + PW] = panel
    cv2.rectangle(fr, (0, PY0), (W - 1, PY0 + PH - 1), (1, 1, 1), 4)
    for tx in texts:
        fr = over(fr, text_layer(*tx, t))
    for lb in labels:
        fr = label(fr, lb[0], lb[1], t, lb[2], lb[3])
    fr = over(fr, WM)
    if flash > 0:
        fr = fr * (1 - flash) + flash
    return np.clip(fr, 0, 1)

def writer(path):
    return subprocess.Popen(["ffmpeg", "-y", "-loglevel", "error", "-f", "rawvideo", "-pix_fmt", "bgr24", "-s", f"{W}x{H}", "-r", str(FPS), "-i", "-",
                             "-c:v", "libx264", "-crf", "18", "-preset", "veryfast", "-pix_fmt", "yuv420p", "-r", str(FPS), path], stdin=subprocess.PIPE)

def scene(name, dur, fn):
    tmp = f"/tmp/vid/{name}.part.mp4"
    p = writer(tmp)
    for i in range(int(round(dur * FPS))):
        t = i / FPS
        fr = fn(t)
        p.stdin.write((fr * 255).astype(np.uint8).tobytes())
    p.stdin.close()
    if p.wait() == 0:
        os.replace(tmp, f"/tmp/vid/{name}.mp4")
    return f"/tmp/vid/{name}.mp4"

TOP = 70  # caption y
shots1 = make_volley(0.05, 2.7, 7)
def s1(t):  # hook: thermal, gunship firing
    z = 1.18 + 0.05 * t / 2.8
    pan, M = crop(imgs["thermal"], z, CX + 20, CY + 60)
    pan = draw_fx(sharpen(pan), M, t, shots1, z)
    pan = embers(pan, t, 0.6)
    return compose(pan, "thermal", t, texts=[(["I ADDED A", "NIGHT MAP"], TOP, 120, 0.0)])

def s2(t):  # before: day
    z = 1.0 + 0.04 * t / 2.6
    pan, M = crop(imgs["day"], z)
    return compose(sharpen(pan), "day", t, texts=[(["IT USED TO", "BE DAYTIME"], TOP, 120, 0.05)], labels=[("BEFORE", 0.1, 40, PY0 + 34)],
                   flash=max(0, 1 - t / 0.12) * 0.7)

def s3(t):  # wipe to night
    z = 1.04 + 0.05 * t / 3.4
    d, M = crop(imgs["day"], z); nt, _ = crop(imgs["night"], z)
    f = np.clip((t - 0.25) / 1.0, 0, 1); f = f * f * (3 - 2 * f)
    xcut = int(PW * f)
    pan = d.copy(); pan[:, :xcut] = nt[:, :xcut]
    pan = sharpen(pan)
    if 0 < xcut < PW:
        cv2.line(pan, (xcut, 0), (xcut, PH), (1, 1, 1), 6)
    lbls = [("BEFORE", 0, 40, PY0 + 34)] if f < 0.5 else [("AFTER", 0, 40, PY0 + 34)]
    return compose(pan, "night" if f > 0.5 else "day", t, texts=[(["NOW IT'S", "NIGHT TIME"], TOP, 120, 1.0)], labels=lbls)

def s4(t):  # night, slow push: you can barely see them
    z = 1.09 + 0.12 * t / 2.4
    pan, M = crop(imgs["night"], z)
    return compose(sharpen(pan), "night", t, texts=[(["GOOD LUCK", "SPOTTING THEM"], TOP, 120, 0.0)], labels=[("AFTER", 0, 40, PY0 + 34)])

shots5 = make_volley(0.5, 4.6, 7)
def s5(t):  # thermal reveal + firing
    z = 1.21 - 0.12 * min(1, t / 0.6) + 0.06 * t / 4.8
    pan, M = crop(imgs["thermal"], z)
    pan = draw_fx(sharpen(pan), M, t, shots5, z)
    pan = embers(pan, t, 0.5)
    return compose(pan, "thermal", t, texts=[(["THE GUNSHIP", "SEES THEIR HEAT"], TOP, 116, 0.15)], flash=max(0, 1 - t / 0.25))

def s6(t):  # end card
    fr = background("thermal") * 0.9
    pan, M = crop(imgs["thermal"], 1.0 + 0.03 * t)
    pan = cv2.GaussianBlur(pan, (0, 0), 6) * 0.45
    fr[PY0:PY0 + PH] = pan
    fr = over(fr, text_layer(["GUNSHIP VS A", "MILLION INFECTED"], 640, 140, 0.0, t))
    fr = over(fr, text_layer(["PLAY FREE ON ROBLOX"], 1020, 84, 0.45, t, color=(20, 20, 20), stroke=0, pill=(255, 214, 40, 255)))
    fr = over(fr, text_layer(["link in bio"], 1180, 64, 0.8, t, stroke=6))
    return np.clip(fr, 0, 1)

SC = [("s1", 2.8, s1), ("s2", 2.6, s2), ("s3", 3.4, s3), ("s4", 2.4, s4), ("s5", 4.8, s5), ("s6", 3.2, s6)]
if len(sys.argv) > 1 and sys.argv[1] == "stills":
    for name, dur, fn in SC:
        for tt in (dur * 0.35, dur * 0.85):
            cv2.imwrite(f"/tmp/vid/still_{name}_{tt:.1f}.jpg", (fn(tt) * 255).astype(np.uint8), [cv2.IMWRITE_JPEG_QUALITY, 85])
    sys.exit()
files = [scene(n, d, f) for n, d, f in SC]
open("/tmp/vid/list.txt", "w").write("".join(f"file '{f}'\n" for f in files))
print("durations", [d for _, d, _ in SC], sum(d for _, d, _ in SC))
