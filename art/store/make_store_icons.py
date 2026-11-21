# Store + battle-offer icons in the game's icon style: flat white silhouettes, thick black outline,
# black cut-in details (same as art/icons). Store versions sit on the UI's near-black panel with an accent border.
import math, subprocess, os
OUT = os.path.dirname(os.path.abspath(__file__))
G = '<g stroke="#000000" stroke-width="12" stroke-linejoin="round" stroke-linecap="round">'
def svg(body):
    return f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 256 256" width="256" height="256">{G}{body}</g></svg>'
def txt(t, x, y, size):
    return (f'<text x="{x}" y="{y}" font-family="Fira Sans" font-weight="900" font-size="{size}" text-anchor="middle" '
            f'fill="#ffffff" stroke="#000000" stroke-width="12" paint-order="stroke">{t}</text>')
def wrench():
    w = ('<path fill="#ffffff" d="M230,150 L230,82.9 A72,72 0 0,0 236,219.2 L236,400 A20,20 0 0,0 276,400 L276,219.2 '
         'A72,72 0 0,0 282,82.9 L282,150 Z"/>')
    return (f'<g transform="translate(112 118) rotate(45) scale(0.66) translate(-256 -245)">{w}</g>'
            '<path fill="#ffffff" d="M180,148 h28 v30 h30 v28 h-30 v30 h-28 v-30 h-30 v-28 h30 Z"/>')
def heart():
    return ('<path fill="#ffffff" d="M128,214 C60,166 30,132 30,94 C30,62 54,40 82,40 C102,40 118,52 128,68 '
            'C138,52 154,40 174,40 C202,40 226,62 226,94 C226,132 196,166 128,214 Z"/>'
            '<path fill="#000000" stroke="none" d="M116,84 h24 v28 h28 v24 h-28 v28 h-24 v-28 h-28 v-24 h28 Z"/>')
def bomb():
    return ('<g transform="rotate(-35 128 128)">'
            '<path fill="#ffffff" d="M178,100 L244,66 L244,190 L178,156 Z"/>'
            '<ellipse cx="108" cy="128" rx="98" ry="60" fill="#ffffff"/>'
            '<path fill="none" d="M160,74 Q176,128 160,182"/>'
            '</g>'
            + ''.join(f'<path fill="#000000" stroke="none" d="{p}"/>' for p in tri_blades(98, 144, 40, 13)))
def tri_blades(cx, cy, r1, r0):
    out = []
    for a in (90, 210, 330):
        a0, a1 = math.radians(a - 30), math.radians(a + 30)
        out.append(f"M{cx+r0*math.cos(a0):.1f},{cy-r0*math.sin(a0):.1f} L{cx+r1*math.cos(a0):.1f},{cy-r1*math.sin(a0):.1f} "
                   f"A{r1},{r1} 0 0 0 {cx+r1*math.cos(a1):.1f},{cy-r1*math.sin(a1):.1f} L{cx+r0*math.cos(a1):.1f},{cy-r0*math.sin(a1):.1f} "
                   f"A{r0},{r0} 0 0 1 {cx+r0*math.cos(a0):.1f},{cy-r0*math.sin(a0):.1f} Z")
    return out
def bills():
    s = ''
    for dx, dy in ((-18, 34), (0, 0), (18, -34)):
        s += f'<rect x="{46+dx}" y="{94+dy}" width="164" height="84" rx="8" fill="#ffffff"/>'
    s += '<circle cx="146" cy="102" r="26" fill="none" stroke-width="10"/>'
    s += txt("$", 146, 120, 52).replace('stroke-width="12"', 'stroke-width="0"').replace('fill="#ffffff"', 'fill="#000000"')
    return s
def gem(cx, cy, s):
    w, h = 120 * s, 104 * s
    pts = [(cx - w/2, cy - h*0.18), (cx - w*0.28, cy - h/2), (cx + w*0.28, cy - h/2), (cx + w/2, cy - h*0.18), (cx, cy + h/2)]
    p = " ".join(f"{a:.1f},{b:.1f}" for a, b in pts)
    lw = max(5, 8 * s)
    return (f'<polygon points="{p}" fill="#ffffff"/>'
            f'<polyline fill="none" stroke-width="{lw:.0f}" points="{cx-w/2:.1f},{cy-h*0.18:.1f} {cx+w/2:.1f},{cy-h*0.18:.1f}"/>'
            f'<polyline fill="none" stroke-width="{lw:.0f}" points="{cx-w*0.14:.1f},{cy-h*0.18:.1f} {cx:.1f},{cy+h/2:.1f} {cx+w*0.14:.1f},{cy-h*0.18:.1f}"/>')
def crown():
    return ('<path fill="#ffffff" d="M40,196 L28,84 L84,130 L128,56 L172,130 L228,84 L216,196 Z"/>'
            '<rect x="40" y="196" width="176" height="26" rx="4" fill="#ffffff"/>'
            '<circle cx="128" cy="150" r="14" fill="#000000" stroke="none"/>'
            '<circle cx="84" cy="164" r="9" fill="#000000" stroke="none"/><circle cx="172" cy="164" r="9" fill="#000000" stroke="none"/>')
def head_start():
    return (bills().replace('x="28"','x="20"')
            + '<path fill="#ffffff" d="M188,40 L236,92 L208,92 L208,150 L168,150 L168,92 L140,92 Z"/>')
ICONS = {
    "repair":        (wrench(), "#A6FF4D"),
    "second_chance": (heart(), "#FF5046"),
    "nuke":          (bomb(), "#FFC22E"),
    "cash_drop":     (bills(), "#A6FF4D"),
    "gems_small":    (gem(128, 128, 1.45), "#B07CFF"),
    "gems_medium":   (gem(84, 150, 0.95) + gem(172, 150, 0.95) + gem(128, 88, 0.95), "#B07CFF"),
    "gems_large":    (gem(62, 168, 0.8) + gem(128, 172, 0.85) + gem(194, 168, 0.8) + gem(95, 100, 0.8) + gem(161, 100, 0.8), "#B07CFF"),
    "gems_mega":     (gem(52, 184, 0.7) + gem(108, 188, 0.75) + gem(164, 188, 0.75) + gem(214, 184, 0.7) + gem(80, 124, 0.7) + gem(136, 124, 0.75) + gem(190, 124, 0.7) + gem(108, 66, 0.7) + gem(160, 66, 0.7), "#B07CFF"),
    "pass_vip":      (crown(), "#FFC22E"),
    "pass_head_start": (head_start(), "#A6FF4D"),
    "pass_2x_gems":  (gem(108, 112, 1.25) + txt("x2", 188, 222, 76), "#B07CFF"),
    "pass_2x_cash":  (bills() + txt("x2", 196, 236, 70), "#A6FF4D"),
}
def store(body, accent):
    # same look as the in-game panels: near-black, square corners, accent border
    return (f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512" width="512" height="512">'
            f'<rect x="0" y="0" width="512" height="512" fill="{accent}"/>'
            f'<rect x="18" y="18" width="476" height="476" fill="#06080A"/>'
            f'<g transform="translate(76 76) scale(1.40625)">{G}{body}</g></g></svg>')
for name, (body, accent) in ICONS.items():
    for kind, s, size in (("hud", svg(body), 256), ("store", store(body, accent), 512)):
        path = f"{OUT}/{kind}_{name}"
        open(path + ".svg", "w").write(s)
        subprocess.run(["rsvg-convert", "-w", str(size), "-h", str(size), path + ".svg", "-o", path + ".png"], check=True)
print("ok")
