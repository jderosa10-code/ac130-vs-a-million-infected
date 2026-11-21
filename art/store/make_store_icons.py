import math, os, subprocess
OUT = "/home/claude/ac130-vs-a-million-infected/art/store"
def bg(inner, accent="#ECBE1E", top="#2A3A66", bot="#0E1428"):
    return f'''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512" width="512" height="512">
<defs><linearGradient id="g" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="{top}"/><stop offset="1" stop-color="{bot}"/></linearGradient>
<radialGradient id="glow" cx="0.5" cy="0.45" r="0.5"><stop offset="0" stop-color="{accent}" stop-opacity="0.35"/><stop offset="1" stop-color="{accent}" stop-opacity="0"/></radialGradient></defs>
<rect x="10" y="10" width="492" height="492" rx="70" fill="url(#g)" stroke="{accent}" stroke-width="20"/>
<circle cx="256" cy="240" r="210" fill="url(#glow)"/>
<g stroke="#000" stroke-width="16" stroke-linejoin="round" stroke-linecap="round">{inner}</g></svg>'''
def text(t, x, y, size, fill="#fff", anchor="middle"):
    return f'<text x="{x}" y="{y}" font-family="Fira Sans" font-weight="900" font-size="{size}" text-anchor="{anchor}" fill="{fill}" stroke="#000" stroke-width="14" paint-order="stroke">{t}</text>'
def gem(cx, cy, s, fill="#B97BFF", shine="#E6CCFF"):
    # faceted diamond: table on top, point at bottom
    w, h = 120*s, 104*s
    pts = [(cx-w/2, cy-h*0.18), (cx-w*0.28, cy-h/2), (cx+w*0.28, cy-h/2), (cx+w/2, cy-h*0.18), (cx, cy+h/2)]
    p = " ".join(f"{a:.1f},{b:.1f}" for a, b in pts)
    facet = f"{cx-w*0.28:.1f},{cy-h*0.18:.1f} {cx:.1f},{cy+h/2:.1f} {cx+w*0.28:.1f},{cy-h*0.18:.1f}"
    top = f"{cx-w*0.28:.1f},{cy-h/2:.1f} {cx-w*0.12:.1f},{cy-h*0.18:.1f} {cx+w*0.12:.1f},{cy-h*0.18:.1f} {cx+w*0.28:.1f},{cy-h/2:.1f}"
    return (f'<polygon points="{p}" fill="{fill}"/>'
            f'<polygon points="{facet}" fill="{shine}" stroke-width="{max(6,10*s):.0f}"/>'
            f'<polygon points="{top}" fill="#fff" stroke-width="{max(6,10*s):.0f}"/>')
def wrench():
    w = ('<path d="M230,150 L230,82.9 A72,72 0 0,0 236,219.2 L236,400 A20,20 0 0,0 276,400 L276,219.2 '
         'A72,72 0 0,0 282,82.9 L282,150 Z" fill="#D8DDE4"/>')
    return (f'<g transform="translate(256 250) rotate(45) scale(1.05) translate(-256 -240)">{w}</g>'
            '<circle cx="372" cy="372" r="74" fill="#5BE36B"/>'
            '<rect x="322" y="356" width="100" height="32" rx="8" fill="#fff" stroke-width="10"/>'
            '<rect x="356" y="322" width="32" height="100" rx="8" fill="#fff" stroke-width="10"/>')
def shield():
    return ('<path d="M256 70 L400 120 C400 260 340 360 256 420 C172 360 112 260 112 120 Z" fill="#E8424A"/>'
            '<path d="M256 120 L350 154 C350 250 310 320 256 362 Z" fill="#FF8A8F" stroke-width="10"/>') + text("2ND", 256, 300, 120)
def trefoil():
    s = '<circle cx="256" cy="240" r="190" fill="#F2C318"/>'
    for a in (90, 210, 330):
        a0, a1 = math.radians(a-30), math.radians(a+30)
        r0, r1 = 50, 165
        p = (f"M{256+r0*math.cos(a0):.1f},{240-r0*math.sin(a0):.1f} L{256+r1*math.cos(a0):.1f},{240-r1*math.sin(a0):.1f} "
             f"A{r1},{r1} 0 0 0 {256+r1*math.cos(a1):.1f},{240-r1*math.sin(a1):.1f} L{256+r0*math.cos(a1):.1f},{240-r0*math.sin(a1):.1f} "
             f"A{r0},{r0} 0 0 1 {256+r0*math.cos(a0):.1f},{240-r0*math.sin(a0):.1f} Z")
        s += f'<path d="{p}" fill="#111" stroke-width="8"/>'
    s += '<circle cx="256" cy="240" r="32" fill="#111" stroke-width="8"/>'
    return s
def cash():
    s = ""
    for i, (dx, dy) in enumerate([(-30, 40), (0, 0), (30, -40)]):
        s += f'<rect x="{126+dx}" y="{190+dy}" width="260" height="130" rx="14" fill="#53C25E"/>'
        s += f'<circle cx="{256+dx}" cy="{255+dy}" r="38" fill="#8EE39A" stroke-width="10"/>'
    s += text("$", 286, 260, 110, "#fff")
    return s
def crate_cash():
    return ('<rect x="110" y="200" width="292" height="200" rx="16" fill="#9C6B3A"/>'
            '<path d="M110 200 L402 400 M402 200 L110 400" stroke-width="14" fill="none"/>'
            '<rect x="110" y="200" width="292" height="40" fill="#B9844F"/>'
            '<rect x="150" y="110" width="212" height="100" rx="12" fill="#53C25E"/>') + text("$", 256, 192, 96)
specs = {
    "repair": (wrench(), "#5BE36B"),
    "second_chance": (shield(), "#E8424A"),
    "nuke": (trefoil(), "#F2C318"),
    "cash_drop": (crate_cash(), "#53C25E"),
    "gems_small": (gem(256, 240, 2.1), "#B97BFF"),
    "gems_medium": (gem(190, 280, 1.4) + gem(322, 280, 1.4) + gem(256, 170, 1.4), "#B97BFF"),
    "gems_large": (gem(150, 300, 1.15) + gem(256, 310, 1.25) + gem(362, 300, 1.15) + gem(200, 190, 1.15) + gem(312, 190, 1.15), "#B97BFF"),
    "pass_2x_gems": (gem(220, 250, 2.0) + text("x2", 380, 420, 150, "#ECBE1E"), "#B97BFF"),
    "pass_2x_cash": (cash() + text("x2", 380, 440, 150, "#ECBE1E"), "#53C25E"),
}
for name, (inner, acc) in specs.items():
    svg = bg(inner, acc)
    open(f"{OUT}/{name}.svg", "w").write(svg)
    subprocess.run(["rsvg-convert", "-w", "512", "-h", "512", f"{OUT}/{name}.svg", "-o", f"{OUT}/{name}.png"], check=True)
print("ok")
