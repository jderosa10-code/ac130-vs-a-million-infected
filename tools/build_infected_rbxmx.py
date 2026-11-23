# Builds art/anim/infected/*.rbxmx from tools/InfectedAnims.luau (same math as InfectedAnims.build), to upload.
import re, math, os, sys
here = os.path.dirname(os.path.abspath(__file__))
src = open(os.path.join(here, "InfectedAnims.luau")).read()
sec = src[src.index("local CLIPS = {}"):src.index("M.CLIPS = CLIPS")]
sec = re.sub(r"--[^\n]*", "", sec)
lines = []
for l in sec.split("\n"):
    t = l.strip()
    if t in ("do", "end") or not t:
        continue
    lines.append(t)
sec = "\n".join(lines)
sec = re.sub(r"\blocal\s+", "", sec)
sec = re.sub(r"\b([A-Za-z_]\w*)\s*=(?!=)", r"\1=", sec)
sec = sec.replace("{", "T(").replace("}", ")")
sec = sec.replace("true", "True").replace("false", "False").replace("nil", "None")
sec = re.sub(r"\bwith\(", "with_(", sec)
sec = re.sub(r"\bpass\b", "pass_", sec)
def T(*a, **k):
    assert not (a and k)
    return dict(k) if k else list(a)
def mirror(p):
    m = {}
    for j, v in p.items():
        o = "Right" + j[4:] if j.startswith("Left") else ("Left" + j[5:] if j.startswith("Right") else j)
        g = lambda i: v[i] if len(v) > i else 0
        m[o] = [v[0], -v[1], -v[2], -g(3), g(4), g(5)]
    return m
def with_(base, over):
    p = dict(base); p.update(over); return p
class table:
    @staticmethod
    def insert(t, x): t.append(x)
G = dict(T=T, mirror=mirror, with_=with_, table=table, True_=True)
exec(sec, G)
CLIPS = G["CLIPS"]
PARENT = {"LowerTorso": "HumanoidRootPart", "UpperTorso": "LowerTorso", "Head": "UpperTorso",
          "LeftUpperArm": "UpperTorso", "LeftLowerArm": "LeftUpperArm", "LeftHand": "LeftLowerArm",
          "RightUpperArm": "UpperTorso", "RightLowerArm": "RightUpperArm", "RightHand": "RightLowerArm",
          "LeftUpperLeg": "LowerTorso", "LeftLowerLeg": "LeftUpperLeg", "LeftFoot": "LeftLowerLeg",
          "RightUpperLeg": "LowerTorso", "RightLowerLeg": "RightUpperLeg", "RightFoot": "RightLowerLeg"}
# (InfectedAnims' own EASE table: into = CubicV2 In, out = CubicV2 Out)
EASE = {"linear": (0, 0), "inout": (5, 2), "into": (5, 0), "out": (5, 1), "hold": (1, 1)}
PRI = {"Idle": 0, "Movement": 1, "Action": 2}
def rot(rx, ry, rz):
    cx, sx = math.cos(rx), math.sin(rx); cy, sy = math.cos(ry), math.sin(ry); cz, sz = math.cos(rz), math.sin(rz)
    def mm(a, b): return [[sum(a[i][k] * b[k][j] for k in range(3)) for j in range(3)] for i in range(3)]
    return mm(mm([[1, 0, 0], [0, cx, -sx], [0, sx, cx]], [[cy, 0, sy], [0, 1, 0], [-sy, 0, cy]]), [[cz, -sz, 0], [sz, cz, 0], [0, 0, 1]])
ref = [0]
def rid(): ref[0] += 1; return "RBX%08X" % ref[0]
def num(v):
    s = ("%.6f" % v).rstrip("0").rstrip(".")
    return "0" if s in ("", "-0") else s
def cfxml(p, m):
    return ('<CoordinateFrame name="CFrame"><X>%s</X><Y>%s</Y><Z>%s</Z>' % tuple(num(x) for x in p) +
            "".join("<R%d%d>%s</R%d%d>" % (i, j, num(m[i][j]), i, j) for i in range(3) for j in range(3)) + "</CoordinateFrame>")
def build(clip):
    frames = {}
    for k in clip["keys"]:
        frames[k[0]] = k
    L = clip["length"]
    if clip.get("loop") and 0 in frames and L not in frames:
        frames[L] = [L, frames[0][1]] + frames[0][2:3]
    markers = {}
    for f, name in clip.get("markers", []):
        markers.setdefault(f, []).append(name)
        frames.setdefault(f, [f, None])
    kfx = []
    for f in sorted(frames):
        k = frames[f]
        body = ""
        if k[1] is not None:
            es, ed = EASE[k[2] if len(k) > 2 and k[2] else "inout"]
            P = k[1]
            rootV = P.get("LowerTorso", [0, 0, 0])
            def make(j):
                v = list(P.get(j, [0, 0, 0]))
                if j in ("RightUpperLeg", "LeftUpperLeg"):
                    v = [v[0] - rootV[0], v[1], v[2] - rootV[2]]
                g = lambda i: v[i] if len(v) > i else 0
                kids = "".join(make(c) for c in PARENT if PARENT[c] == j)
                return ('<Item class="Pose" referent="%s"><Properties><string name="Name">%s</string>%s<token name="EasingDirection">%d</token>'
                        '<token name="EasingStyle">%d</token><float name="Weight">1</float></Properties>%s</Item>'
                        % (rid(), j, cfxml([g(3), g(4), g(5)], rot(*(math.radians(g(i)) for i in range(3)))), ed, es, kids))
            body = ('<Item class="Pose" referent="%s"><Properties><string name="Name">HumanoidRootPart</string>%s<token name="EasingDirection">0</token>'
                    '<token name="EasingStyle">0</token><float name="Weight">0</float></Properties>%s</Item>'
                    % (rid(), cfxml([0, 0, 0], [[1, 0, 0], [0, 1, 0], [0, 0, 1]]), make("LowerTorso")))
        for name in markers.get(f, []):
            body += ('<Item class="KeyframeMarker" referent="%s"><Properties><string name="Name">%s</string><string name="Value"></string></Properties></Item>' % (rid(), name))
        kfx.append('<Item class="Keyframe" referent="%s"><Properties><string name="Name">Keyframe</string><float name="Time">%s</float></Properties>%s</Item>' % (rid(), num(f / 60), body))
    return ('<roblox xmlns:xmime="http://www.w3.org/2005/05/xmlmime" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="http://www.roblox.com/roblox.xsd" version="4">'
            '<Item class="KeyframeSequence" referent="%s"><Properties><string name="Name">%s</string><bool name="Loop">%s</bool><token name="Priority">%d</token></Properties>%s</Item></roblox>'
            % (rid(), clip["name"], "true" if clip.get("loop") else "false", PRI[clip.get("priority", "Movement")], "".join(kfx)))
if __name__ == "__main__":
    out = sys.argv[1] if len(sys.argv) > 1 else os.path.join(here, "..", "art", "anim", "infected")
    os.makedirs(out, exist_ok=True)
    for c in CLIPS:
        open(os.path.join(out, c["name"] + ".rbxmx"), "w").write(build(c))
    print([ (c["name"], c["length"], len(c["keys"]), c.get("markers")) for c in CLIPS])
    c = CLIPS[2]; P = c["keys"][0][1]; print("Sprint key0 LowerTorso", P.get("LowerTorso"), "RightUpperLeg", P.get("RightUpperLeg"))
