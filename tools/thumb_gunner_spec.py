"""Turns a Studio capture + thumb_gunner_pov.luau points into a 1920x1080 plate and a spec for thumb_after_effects.py.
usage: python thumb_gunner_spec.py raw.jpg pts.json plate.png spec.json [extra.json]"""
import cv2, json, sys
raw, ptsf, plate, specf = sys.argv[1:5]
extra = json.load(open(sys.argv[5])) if len(sys.argv) > 5 else {}
im = cv2.imread(raw); H0, W0 = im.shape[:2]
cw = int(round(H0 * 16 / 9)); x0 = (W0 - cw) // 2
cv2.imwrite(plate, cv2.resize(im[:, x0:x0 + cw], (1920, 1080), interpolation=cv2.INTER_CUBIC))
P = lambda p: [round((p[0] * W0 - x0) / cw * 1920, 1), round(p[1] * 1080, 1)]
pts = json.load(open(ptsf))
tips = [P(t) for t in pts["tips"]]
mz = [sum(t[0] for t in tips) / len(tips), sum(t[1] for t in tips) / len(tips)]
spec = {"edge_blur": 0.8, "focus": [0.5, 0.5], "beams": 1.6, "bokeh": 14, "muzzle": mz,
        "blasts": [P(h) + [r] for h, r in zip(pts["hits"], (62, 40, 30))],
        "shots": [{"from": mz, "to": P(pts["target"]), "kind": "25", "scale": 1.5, "phase": 2, "flash": 1.5}]}
spec.update(extra)
json.dump(spec, open(specf, "w"))
print(json.dumps(spec))
