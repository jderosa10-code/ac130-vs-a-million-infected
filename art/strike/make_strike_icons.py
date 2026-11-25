"""Strike card icons: Studio photos of the models on a magenta floor -> cut out, outlined, 512x512 PNG.
usage: python make_strike_icons.py name=photo.jpg ...  (writes strike_<name>.png next to this file)"""
import sys, os
import numpy as np
from PIL import Image, ImageFilter
from scipy import ndimage

OUT = os.path.dirname(os.path.abspath(__file__))
STROKE = 10          # outline width at 512 px
INK = (236, 232, 214)  # light stroke, like the aircraft photo icons

def cut(path):
    im = np.asarray(Image.open(path).convert("RGB")).astype(np.float32)
    r, g, b = im[..., 0], im[..., 1], im[..., 2]
    mag = np.minimum(r, b) - g                    # how magenta a pixel is
    alpha = np.clip(1 - (mag - 60) / 90, 0, 1)    # 1 = subject, 0 = floor
    solid = alpha > 0.5
    # the subject: the biggest blob that doesn't touch the top (the sky is the other big one)
    lab, n = ndimage.label(solid)
    best, size = 0, 0
    for i in range(1, n + 1):
        ys, xs = np.nonzero(lab == i)
        if ys.min() == 0:
            continue
        if len(ys) > size:
            best, size = i, len(ys)
    keep = ndimage.binary_dilation(lab == best, iterations=2)
    alpha = alpha * keep
    # despill: pull the magenta out of the edge pixels
    spill = np.clip(np.minimum(r, b) - g, 0, None) * (1 - alpha) 
    rgb = im.copy()
    rgb[..., 0] -= spill * 0.8
    rgb[..., 2] -= spill * 0.8
    rgb = np.clip(rgb, 0, 255)
    ys, xs = np.nonzero(alpha > 0.05)
    y0, y1, x0, x1 = ys.min(), ys.max() + 1, xs.min(), xs.max() + 1
    rgba = np.dstack([rgb, alpha * 255]).astype(np.uint8)[y0:y1, x0:x1]
    return Image.fromarray(rgba, "RGBA")

def icon(subject):
    size = 512
    inner = size - 2 * (STROKE + 10)
    w, h = subject.size
    k = inner / max(w, h)
    subject = subject.resize((max(1, round(w * k)), max(1, round(h * k))), Image.LANCZOS)
    canvas = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    ox, oy = (size - subject.width) // 2, (size - subject.height) // 2
    canvas.paste(subject, (ox, oy), subject)
    a = np.asarray(canvas.split()[3]) > 100
    grown = ndimage.binary_dilation(a, structure=np.ones((3, 3)), iterations=STROKE)
    stroke = Image.fromarray((grown * 255).astype(np.uint8)).filter(ImageFilter.GaussianBlur(0.8))
    out = Image.new("RGBA", (size, size), INK + (0,))
    out.putalpha(stroke)
    out.alpha_composite(canvas)
    return out

for arg in sys.argv[1:]:
    name, path = arg.split("=", 1)
    p = os.path.join(OUT, f"strike_{name}.png")
    icon(cut(path)).save(p)
    print(p)
