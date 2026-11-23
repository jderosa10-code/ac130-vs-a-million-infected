# Cut the backgrounds off Jacob's Gemini battle-offer icons (FORTIFY on white, CASH DROP on black): 512 px PNGs.
import numpy as np
from PIL import Image, ImageFilter
from scipy import ndimage
JOBS = [("fortify", "fortify_src.jpg", "white"), ("cashdrop", "cashdrop_src.jpg", "black")]
for name, src, bgkind in JOBS:
    im = Image.open(src).convert("RGB")
    a = np.asarray(im).astype(np.int16)
    if bgkind == "white":
        bgmask = (a.min(axis=2) >= 232) & ((a.max(axis=2) - a.min(axis=2)) <= 16)
    else:
        bgmask = a.max(axis=2) <= 24
    lab, n = ndimage.label(bgmask)
    border = set(np.unique(np.concatenate([lab[0], lab[-1], lab[:, 0], lab[:, -1]]))) - {0}
    bg = np.isin(lab, list(border))
    if bgkind == "black":
        # the dark gaps between the parachute lines are closed in by the lines: drop any big, blobby dark patch too
        # (outlines are thin, so they never pass the fill test)
        for i, sl in enumerate(ndimage.find_objects(lab), start=1):
            if i in border or sl is None:
                continue
            area = (lab[sl] == i).sum()
            box = (sl[0].stop - sl[0].start) * (sl[1].stop - sl[1].start)
            if area > 600 and area / box > 0.25:
                bg |= lab == i
    alpha = np.where(bg, 0, 255).astype(np.uint8)
    am = Image.fromarray(alpha).filter(ImageFilter.MinFilter(3)).filter(ImageFilter.GaussianBlur(0.8))
    rgba = im.convert("RGBA"); rgba.putalpha(am)
    rgba = rgba.crop(am.getbbox())
    s = 492 / max(rgba.size)
    rgba = rgba.resize((round(rgba.width * s), round(rgba.height * s)), Image.LANCZOS)
    tile = Image.new("RGBA", (512, 512), (0, 0, 0, 0))
    tile.paste(rgba, ((512 - rgba.width) // 2, (512 - rgba.height) // 2), rgba)
    tile.save(f"{name}.png")
    for bgc, tag in [((27, 30, 22, 255), "dark"), ((236, 232, 214, 255), "light")]:
        p = Image.new("RGBA", (512, 512), bgc); p.alpha_composite(tile); p.convert("RGB").save(f"/tmp/prev_{name}_{tag}.png")
print("ok")
