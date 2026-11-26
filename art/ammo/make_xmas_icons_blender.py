import bpy, numpy as np, sys, os
T = sys.argv[sys.argv.index("--") + 3]  # folder holding the 8 Studio captures (black / white backdrop per icon)
PAIRS = [
  ("ammo_candycane", "mcp-roblox-studio-blob-1795656896569-xv1op4.jpg", "mcp-roblox-studio-blob-1795657224360-xvq9qw.jpg"),
  ("ammo_snowball",  "mcp-roblox-studio-blob-1795657201522-rb8ed9.jpg", "mcp-roblox-studio-blob-1795657227192-uv9ym8.jpg"),
  ("ammo_present",   "mcp-roblox-studio-blob-1795657216152-hiy1yv.jpg", "mcp-roblox-studio-blob-1795657229776-6x5522.jpg"),
  ("ac_SLEIGH",      "mcp-roblox-studio-blob-1795657219098-z8cy7n.jpg", "mcp-roblox-studio-blob-1795657232467-4ifinq.jpg"),
]
OUT = sys.argv[sys.argv.index("--") + 1]
SHEET = sys.argv[sys.argv.index("--") + 2]
def load(path):
    im = bpy.data.images.load(path)
    im.colorspace_settings.name = "Non-Color"
    w, h = im.size
    a = np.array(im.pixels[:], dtype=np.float32).reshape(h, w, 4)
    return np.flipud(a)[..., :3] * 255.0
def to_image(name, arr):  # arr: h,w,4 in 0..1, top-down
    h, w = arr.shape[:2]
    im = bpy.data.images.new(name, w, h, alpha=True)
    im.colorspace_settings.name = "Non-Color"
    im.pixels[:] = np.flipud(arr).ravel()
    return im
def from_image(im):
    w, h = im.size
    return np.flipud(np.array(im.pixels[:], dtype=np.float32).reshape(h, w, 4))
def shift_max(m, r):
    out = m.copy()
    for dy in range(-r, r + 1):
        for dx in range(-r, r + 1):
            if dx * dx + dy * dy > r * r: continue
            out = np.maximum(out, np.roll(np.roll(m, dy, 0), dx, 1))
    return out
def box_blur(m, r):
    acc = np.zeros_like(m); n = 0
    for dy in range(-r, r + 1):
        for dx in range(-r, r + 1):
            acc += np.roll(np.roll(m, dy, 0), dx, 1); n += 1
    return acc / n
CELL, PAD, STROKE = 256, 22, 7
tiles = {}
for name, bf, wf in PAIRS:
    B = load(os.path.join(T, bf)); W = load(os.path.join(T, wf))
    bgB = np.median(B[5:60, 5:300].reshape(-1, 3), axis=0)
    bgW = np.median(W[5:60, 5:300].reshape(-1, 3), axis=0)
    diff = ((W - B) / np.maximum(bgW - bgB, 1)).mean(axis=2)
    alpha = np.clip(1 - diff, 0, 1)
    solid = alpha > 0.35
    # fill holes: background = what's reachable from the border without crossing solid
    bg = np.zeros_like(solid); bg[0, :] = bg[-1, :] = bg[:, 0] = bg[:, -1] = True
    bg &= ~solid
    for _ in range(2000):
        nb = bg | np.roll(bg, 1, 0) | np.roll(bg, -1, 0) | np.roll(bg, 1, 1) | np.roll(bg, -1, 1)
        nb &= ~solid
        if (nb == bg).all(): break
        bg = nb
    solid = ~bg
    core = ~shift_max((~solid).astype(np.float32), 2).astype(bool)
    alpha = np.where(core, 1.0, np.where(solid, np.maximum(alpha, 0.6), alpha))
    alpha[alpha < 0.06] = 0
    color = np.clip((B - (1 - alpha[..., None]) * bgB) / np.maximum(alpha[..., None], 1e-3), 0, 255)
    ys, xs = np.where(alpha > 0.1)
    y0, y1, x0, x1 = ys.min() - 4, ys.max() + 5, xs.min() - 4, xs.max() + 5
    crop = np.dstack([color[y0:y1, x0:x1] / 255.0, alpha[y0:y1, x0:x1]])
    h, w = crop.shape[:2]
    s = (CELL - 2 * PAD) / max(w, h)
    nw, nh = max(1, round(w * s)), max(1, round(h * s))
    # premultiply before scaling so edges don't pick up the backdrop
    pm = crop.copy(); pm[..., :3] *= pm[..., 3:4]
    im = to_image(name + "_c", pm); im.scale(nw, nh); pm = from_image(im)
    a = pm[..., 3:4]
    rgb = np.where(a > 1e-3, pm[..., :3] / np.maximum(a, 1e-3), 0)
    tile = np.zeros((CELL, CELL, 4), np.float32)
    oy, ox = (CELL - nh) // 2, (CELL - nw) // 2
    tile[oy:oy + nh, ox:ox + nw, :3] = rgb
    tile[oy:oy + nh, ox:ox + nw, 3] = a[..., 0]
    grown = box_blur(shift_max(tile[..., 3], STROKE), 1)
    stroke_rgb = np.array([238, 232, 212], np.float32) / 255
    ta = tile[..., 3:4]; sa = grown[..., None]
    out_a = ta + sa * (1 - ta)
    out_rgb = (tile[..., :3] * ta + stroke_rgb * sa * (1 - ta)) / np.maximum(out_a, 1e-4)
    out = np.dstack([out_rgb, out_a]).clip(0, 1)
    tiles[name] = out
    img = to_image(name, out); img.filepath_raw = os.path.join(OUT, name + ".png"); img.file_format = "PNG"; img.save()
sheet_im = bpy.data.images.load(SHEET); sheet_im.colorspace_settings.name = "Non-Color"
sheet = from_image(sheet_im)
for i, name in enumerate(["ammo_candycane", "ammo_snowball", "ammo_present", "ac_SLEIGH"]):
    sheet[768:1024, i * 256:(i + 1) * 256] = tiles[name]
img = to_image("sheet", sheet); img.filepath_raw = os.path.join(OUT, "ammo_sheet.png"); img.file_format = "PNG"; img.save()
prev = sheet.copy(); bgc = np.array([32, 34, 28], np.float32) / 255
prev[..., :3] = sheet[..., :3] * sheet[..., 3:4] + bgc * (1 - sheet[..., 3:4]); prev[..., 3] = 1
img = to_image("prev", prev); img.filepath_raw = os.path.join(OUT, "preview.png"); img.file_format = "PNG"; img.save()
print("ICONS OK")
