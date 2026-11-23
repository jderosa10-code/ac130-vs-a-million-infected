# Product thumbnails for the Robux aircraft unlocks and the objective skip (shown in Roblox's purchase prompt).
from PIL import Image, ImageDraw, ImageFont
F = "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf"
BG, EDGE, YEL, BLK, WHITE, SUB = (27, 30, 22), (74, 78, 58), (245, 197, 24), (24, 24, 20), (236, 232, 214), (162, 175, 142)
def card(top, big, small, path):
    im = Image.new("RGB", (512, 512), BG)
    d = ImageDraw.Draw(im)
    for x in range(-512, 512, 36):  # hazard strip
        d.polygon([(x, 0), (x + 18, 0), (x + 18 + 28, 28), (x + 28, 28)], fill=YEL)
    d.rectangle([0, 28, 511, 34], fill=BLK)
    d.rectangle([6, 40, 505, 505], outline=EDGE, width=3)
    def center(text, size, y, col):
        f = ImageFont.truetype(F, size)
        while d.textlength(text, font=f) > 440 and size > 20:
            size -= 4; f = ImageFont.truetype(F, size)
        w = d.textlength(text, font=f)
        d.text(((512 - w) / 2, y), text, font=f, fill=col)
    center(top, 34, 90, YEL)
    center(big, 120, 190, WHITE)
    center(small, 30, 390, SUB)
    im.save(path)
PLANES = [("AC47", "SPOOKY"), ("UH1", "HUEY"), ("MQ9", "REAPER"), ("AV8B", "HARRIER"), ("AH64", "APACHE"), ("CH47", "CHINOOK"), ("B52", "B-52")]
for pid, short in PLANES:
    card("AIRCRAFT UNLOCK", short, "FLY IT RIGHT AWAY", f"plane_{pid}.png")
card("RANK OBJECTIVE", "SKIP", "COMPLETE IT NOW", "skip_objective.png")
print("ok")
