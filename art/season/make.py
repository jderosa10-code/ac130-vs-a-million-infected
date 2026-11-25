# Season pass + tracer art: in-game icons (white, thick black outline, transparent: tinted in game) and the
# purchase-prompt thumbnails in the same card style as art/products.
import math
from PIL import Image, ImageDraw, ImageFont, ImageFilter
F = "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf"
BG, EDGE, YEL, BLK, WHITE, SUB = (27, 30, 22), (74, 78, 58), (245, 197, 24), (24, 24, 20), (236, 232, 214), (162, 175, 142)

def streak(size, col, glow=True):
    """a tracer round flying up-right: glow, hot core, short tail"""
    W, H = size
    im = Image.new("RGBA", size, (0, 0, 0, 0))
    a, b = (W * 0.12, H * 0.82), (W * 0.88, H * 0.18)
    def line(img, w, c):
        d = ImageDraw.Draw(img)
        d.line([a, b], fill=c, width=int(w))
        r = w / 2
        d.ellipse([b[0] - r, b[1] - r, b[0] + r, b[1] + r], fill=c)
    if glow:
        g = Image.new("RGBA", size, (0, 0, 0, 0))
        line(g, H * 0.34, col + (170,))
        g = g.filter(ImageFilter.GaussianBlur(H * 0.07))
        im.alpha_composite(g)
    o = Image.new("RGBA", size, (0, 0, 0, 0))
    line(o, H * 0.17, (0, 0, 0, 255))
    im.alpha_composite(o)
    c = Image.new("RGBA", size, (0, 0, 0, 0))
    line(c, H * 0.11, col + (255,))
    im.alpha_composite(c)
    return im

# in-game: white streak (tinted per tracer with ImageColor3)
streak((512, 256), (255, 255, 255), glow=False).save("icon_tracer.png")

# in-game: season badge, a chevron shield with a star (white, black outline)
def badge(path):
    S = 512
    im = Image.new("RGBA", (S, S), (0, 0, 0, 0))
    d = ImageDraw.Draw(im)
    shield = [(256, 40), (440, 110), (420, 300), (256, 470), (92, 300), (72, 110)]
    d.polygon(shield, fill=(0, 0, 0, 255))
    inner = [(256, 72), (410, 130), (392, 290), (256, 430), (120, 290), (102, 130)]
    d.polygon(inner, fill=(255, 255, 255, 255))
    # star
    cx, cy, R, r = 256, 200, 92, 38
    pts = []
    for i in range(10):
        ang = -math.pi / 2 + i * math.pi / 5
        rr = R if i % 2 == 0 else r
        pts.append((cx + rr * math.cos(ang), cy + rr * math.sin(ang)))
    d.polygon(pts, fill=(0, 0, 0, 255))
    # chevrons under it
    for k in range(2):
        y = 318 + k * 44
        d.polygon([(150, y), (256, y + 40), (362, y), (362, y + 26), (256, y + 66), (150, y + 26)], fill=(0, 0, 0, 255))
    im.save(path)
badge("icon_season.png")

def card(top, big, small, path, art=None):
    im = Image.new("RGB", (512, 512), BG)
    d = ImageDraw.Draw(im)
    for x in range(-512, 512, 36):
        d.polygon([(x, 0), (x + 18, 0), (x + 18 + 28, 28), (x + 28, 28)], fill=YEL)
    d.rectangle([0, 28, 511, 34], fill=BLK)
    d.rectangle([6, 40, 505, 505], outline=EDGE, width=3)
    def center(text, size, y, col):
        f = ImageFont.truetype(F, size)
        while d.textlength(text, font=f) > 440 and size > 20:
            size -= 4; f = ImageFont.truetype(F, size)
        w = d.textlength(text, font=f)
        d.text(((512 - w) / 2, y), text, font=f, fill=col)
    center(top, 34, 70, YEL)
    if art is not None:
        im.paste(art, ((512 - art.width) // 2, 130), art)
    center(big, 72, 330, WHITE)
    center(small, 28, 420, SUB)
    im.save(path)

for tid, name, col in [("Gold", "GOLD", (255, 200, 40)), ("Plasma", "PLASMA", (0, 255, 230)), ("Rainbow", "RAINBOW", None)]:
    if col is None:
        # one streak whose colour runs through the rainbow along its length
        base = streak((400, 190), (255, 255, 255))
        grad = Image.new("RGBA", base.size)
        gd = ImageDraw.Draw(grad)
        import colorsys
        for x in range(base.width):
            r, g, b2 = colorsys.hsv_to_rgb(x / base.width * 0.8, 0.85, 1)
            gd.line([(x, 0), (x, base.height)], fill=(int(r * 255), int(g * 255), int(b2 * 255), 255))
        from PIL import ImageChops
        art = ImageChops.multiply(base, grad)
        art.putalpha(base.getchannel("A"))
    else:
        art = streak((400, 190), col)
    card("TRACER ROUNDS", name, "EVERY GUN, EVERY AIRCRAFT", f"product_tracer_{tid}.png", art)

b = Image.open("icon_season.png").resize((190, 190))
card("SEASON 1", "PREMIUM", "30 TIERS OF REWARDS", "product_season_S1.png", b)
print("ok")
