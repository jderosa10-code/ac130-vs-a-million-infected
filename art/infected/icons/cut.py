# Cut the white background off Jacob's Gemini infected portraits and pack them into a 1024 sheet (256 cells).
import sys, numpy as np
from PIL import Image, ImageFilter
from scipy import ndimage
SRC = {"armored": "84e5a508", "brute": "cd391528", "bomber": "a8f435f3", "runner": "9ab16fe8", "spitter": "0a1bf956"}
ORDER = ["runner", "brute", "bomber", "spitter", "armored"]
sheet = Image.new("RGBA", (1024, 1024), (0, 0, 0, 0))
for k, name in enumerate(ORDER):
    im = Image.open(f"/mnt/user-data/uploads/{SRC[name]}-image.jpg").convert("RGB")
    a = np.asarray(im).astype(np.int16)
    white = (a.min(axis=2) >= 236) & ((a.max(axis=2) - a.min(axis=2)) <= 14)
    lab, n = ndimage.label(white)
    border = set(np.unique(np.concatenate([lab[0], lab[-1], lab[:, 0], lab[:, -1]]))) - {0}
    bg = np.isin(lab, list(border))
    # keep big interior whites (eyes highlights etc.) but drop the background
    alpha = np.where(bg, 0, 255).astype(np.uint8)
    am = Image.fromarray(alpha).filter(ImageFilter.MinFilter(3)).filter(ImageFilter.GaussianBlur(0.8))
    rgba = im.convert("RGBA"); rgba.putalpha(am)
    bbox = am.getbbox()
    rgba = rgba.crop(bbox)
    s = 244 / max(rgba.size)
    rgba = rgba.resize((round(rgba.width * s), round(rgba.height * s)), Image.LANCZOS)
    tile = Image.new("RGBA", (256, 256), (0, 0, 0, 0))
    tile.paste(rgba, ((256 - rgba.width) // 2, 256 - 6 - rgba.height), rgba)  # bust sits on the cell's bottom
    tile.save(f"type_{name}.png")
    sheet.paste(tile, ((k % 4) * 256, (k // 4) * 256))
sheet.save("types_sheet.png")
prev = Image.new("RGBA", (1024, 512), (32, 34, 28, 255)); prev.alpha_composite(sheet.crop((0, 0, 1024, 512)))
prev.convert("RGB").save("preview.png")
print("ok")
