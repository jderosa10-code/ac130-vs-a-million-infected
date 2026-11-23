# Ammo photo icons: difference-matte two screen captures (black / white backdrop), crop each cell,
# add a light stroke like the aircraft photo icons, pack into a 1024 sheet of 256 cells.
import numpy as np
from PIL import Image, ImageFilter
from scipy import ndimage

B = np.asarray(Image.open("black.jpg").convert("RGB")).astype(np.float32)
W = np.asarray(Image.open("white.jpg").convert("RGB")).astype(np.float32)
# white backdrop isn't pure 255 everywhere: measure it
bgW = np.median(W[5:60, 5:300].reshape(-1, 3), axis=0)
bgB = np.median(B[5:60, 5:300].reshape(-1, 3), axis=0)
diff = ((W - B) / np.maximum(bgW - bgB, 1)).mean(axis=2)
alpha = np.clip(1 - diff, 0, 1)
# solid interior: fill holes where metal picked up the backdrop
solid = alpha > 0.35
solid = ndimage.binary_fill_holes(ndimage.binary_closing(solid, iterations=2))
core = ndimage.binary_erosion(solid, iterations=2)
alpha = np.where(core, 1.0, np.where(solid, np.maximum(alpha, 0.6), alpha))
alpha[alpha < 0.06] = 0
color = np.clip((B - (1 - alpha[..., None]) * bgB) / np.maximum(alpha[..., None], 1e-3), 0, 255)

ORDER = ["ammo_25mm", "ammo_40mm", "ammo_105mm", "ammo_cannon",
         "ammo_762", "ammo_30mm", "ammo_hydra", "ammo_hellfire",
         "ammo_mk82", "ammo_gren40", "ammo_bombbay", "ammo_b61"]
H, Wd = alpha.shape
cols = [int(Wd * f) for f in (0.0, 0.30, 0.50, 0.70, 1.0)]
# split the frame into a 4x3 grid by gaps in the alpha mask
colmask = (alpha > 0.1).any(axis=0)
rowmask = (alpha > 0.1).any(axis=1)
def runs(mask):
    out, start = [], None
    for i, v in enumerate(mask):
        if v and start is None: start = i
        if not v and start is not None: out.append((start, i)); start = None
    if start is not None: out.append((start, len(mask)))
    return out
lab, n = ndimage.label(alpha > 0.1)
objs = ndimage.find_objects(lab)
# group blobs by grid cell using their centres
cells = {}
xs = [380, 760, 1145, 1530]; ys = [230, 510, 790]
for i, sl in enumerate(objs):
    cy = (sl[0].start + sl[0].stop) / 2; cx = (sl[1].start + sl[1].stop) / 2
    if (sl[0].stop - sl[0].start) * (sl[1].stop - sl[1].start) < 30: continue
    c = int(np.argmin([abs(cx - x) for x in xs])); r = int(np.argmin([abs(cy - y) for y in ys]))
    k = r * 4 + c
    y0, y1, x0, x1 = cells.get(k, (10**9, 0, 10**9, 0))
    cells[k] = (min(y0, sl[0].start), max(y1, sl[0].stop), min(x0, sl[1].start), max(x1, sl[1].stop))

CELL, PAD, STROKE = 256, 22, 7
sheet = Image.new("RGBA", (1024, 1024), (0, 0, 0, 0))
rgba = np.dstack([color, alpha * 255]).astype(np.uint8)
full = Image.fromarray(rgba, "RGBA")
for k, name in enumerate(ORDER):
    y0, y1, x0, x1 = cells[k]
    crop = full.crop((x0 - 4, y0 - 4, x1 + 4, y1 + 4))
    w, h = crop.size
    s = (CELL - 2 * PAD) / max(w, h)
    crop = crop.resize((max(1, round(w * s)), max(1, round(h * s))), Image.LANCZOS)
    tile = Image.new("RGBA", (CELL, CELL), (0, 0, 0, 0))
    tile.paste(crop, ((CELL - crop.width) // 2, (CELL - crop.height) // 2), crop)
    a = tile.getchannel("A")
    grown = a.filter(ImageFilter.MaxFilter(STROKE * 2 + 1)).filter(ImageFilter.GaussianBlur(1.2))
    stroke = Image.new("RGBA", (CELL, CELL), (238, 232, 212, 0))
    stroke.putalpha(grown)
    out = Image.alpha_composite(stroke, tile)
    out.save(f"{name}.png")
    sheet.paste(out, ((k % 4) * CELL, (k // 4) * CELL))
sheet.save("ammo_sheet.png")
prev = Image.new("RGBA", sheet.size, (32, 34, 28, 255))
prev.alpha_composite(sheet)
prev.convert("RGB").save("preview.png")
print("ok", len(cells))
