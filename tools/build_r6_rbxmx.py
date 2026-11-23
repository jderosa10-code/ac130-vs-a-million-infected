# Builds art/anim/r6/*.rbxmx from tools/R6Clips.luau (same math as R6Clips.build), for uploading as Animation assets.
import re, math, os, json, sys
from types import SimpleNamespace
src = open(os.path.join(os.path.dirname(__file__), "R6Clips.luau")).read()
sec = src[src.index("-- poses"):src.index("M.CLIPS = CLIPS")]
sec = re.sub(r"--[^\n]*", "", sec)
sec = sec.replace("local CLIPS = {}", "")
sec = re.sub(r"local function add\(c\).*?\nend\n", "", sec, flags=re.S)
sec = re.sub(r"function M\.(sitDownClip|benchClimbClip)\(start: Vector3\).*?\nend\n", "", sec, flags=re.S)
sec = re.sub(r"\blocal\s+", "", sec)
sec = sec.replace("Vector3.new(", "V(").replace("Vector3.zero", "V(0,0,0)")
sec = re.sub(r"\b(\w+)\s*=\s*(?==)", r"\1==", sec)  # (none expected)
sec = re.sub(r"(?<![=<>~])\b([A-Za-z_]\w*)\s*=(?!=)", r"\1=", sec)
sec = sec.replace("{", "T(").replace("}", ")")
sec = sec.replace("true", "True").replace("false", "False").replace("nil", "None")
class V:
    def __init__(s, x, y, z): s.x, s.y, s.z = x, y, z
    def __add__(s, o): return V(s.x + o.x, s.y + o.y, s.z + o.z)
    def __mul__(s, k): return V(s.x * k, s.y * k, s.z * k)
    def Lerp(s, o, k): return V(s.x + (o.x - s.x) * k, s.y + (o.y - s.y) * k, s.z + (o.z - s.z) * k)
def T(*a, **k):
    assert not (a and k)
    return dict(k) if k else list(a)
def mirror(p):
    m = {}
    for j, v in p.items():
        o = "Right" + j[4:] if j.startswith("Left") else ("Left" + j[5:] if j.startswith("Right") else j)
        v = list(v) + [0, 0, 0][len(v) - 3:] if len(v) < 6 else v
        m[o] = [v[0], -v[1], -v[2], -(v[3] if len(v) > 3 else 0), v[4] if len(v) > 4 else 0, v[5] if len(v) > 5 else 0]
    return m
def with_(base, over):
    p = dict(base); p.update(over); return p
def at(v, p):
    t = p or [0, 0, 0]
    return [t[0], t[1], t[2], v.x, v.y, v.z]
CLIPS = []
def add(c): CLIPS.append(c); return c
STANDP = lambda: {"RightArm": [2, 0, 4], "LeftArm": [2, 0, -4], "RightLeg": [0, 0, 3], "LeftLeg": [0, 0, -3]}
M = SimpleNamespace()
def sitDownClip(start):
    SEATED_ = G["SEATED"]
    return {"name": "R6_GunnerSitDown", "length": 1.1, "loop": False, "keys": [
        [0, dict(Torso=at(start, None), **STANDP())],
        [0.35, {"Torso": at(start + V(0, -0.35, 0.3), [-24, 0, 0]), "Head": [14, 0, 0], "RightLeg": [30, 0, 4], "LeftLeg": [30, 0, -4], "RightArm": [-25, 0, 12], "LeftArm": [-25, 0, -12]}],
        [0.75, {"Torso": at(start * 0.15, [-12, 0, 0]), "Head": [6, 0, 0], "RightLeg": [84, 0, 4], "LeftLeg": [84, 0, -4], "RightArm": [-8, 0, 8], "LeftArm": [-8, 0, -8]}, "out"],
        [1.1, SEATED_]]}
def benchClimbClip(start):
    mid = start.Lerp(V(0, 0, 0), 0.7)
    return {"name": "R6_BenchClimb", "length": 1.5, "loop": False, "keys": [
        [0, dict(Torso=at(start, None), **STANDP())],
        [0.35, {"Torso": at(start + V(0, -0.15, 0.2), [-14, 0, 0]), "Head": [10, 0, 0], "RightArm": [-40, 0, 14], "LeftArm": [-40, 0, -14], "RightLeg": [14, 0, 4], "LeftLeg": [14, 0, -4]}],
        [0.7, {"Torso": at(start + V(0, -0.3, 0.35), [-22, 0, 0]), "Head": [12, 0, 0], "RightArm": [-52, 0, 14], "LeftArm": [-52, 0, -14], "RightLeg": [26, 0, 4], "LeftLeg": [26, 0, -4]}, "in"],
        [1.05, {"Torso": at(mid + V(0, 0.55, 0), [-6, 0, 0]), "Head": [2, 0, 0], "RightArm": [-28, 0, 14], "LeftArm": [-28, 0, -14], "RightLeg": [55, 0, 6], "LeftLeg": [50, 0, -6]}, "out"],
        [1.5, G["BENCH"]]]}
M.sitDownClip, M.benchClimbClip = sitDownClip, benchClimbClip
sec = re.sub(r"\bwith\(", "with_(", sec)
G = dict(V=V, T=T, mirror=mirror, with_=with_, at=at, add=add, M=M, CLIPS=CLIPS)
exec(sec, G)
# ---- math (CFrame as 3x4)
def mm(a, b): return [[sum(a[i][k] * b[k][j] for k in range(3)) for j in range(3)] for i in range(3)]
def mv(a, v): return [sum(a[i][k] * v[k] for k in range(3)) for i in range(3)]
def tr(a): return [[a[j][i] for j in range(3)] for i in range(3)]
def rot(rx, ry, rz):
    cx, sx = math.cos(rx), math.sin(rx); cy, sy = math.cos(ry), math.sin(ry); cz, sz = math.cos(rz), math.sin(rz)
    Rx = [[1, 0, 0], [0, cx, -sx], [0, sx, cx]]; Ry = [[cy, 0, sy], [0, 1, 0], [-sy, 0, cy]]; Rz = [[cz, -sz, 0], [sz, cz, 0], [0, 0, 1]]
    return mm(mm(Rx, Ry), Rz)
def want(v):
    v = v or [0, 0, 0]
    r = rot(*(math.radians(a) for a in v[:3]))
    p = [v[3] if len(v) > 3 else 0, v[4] if len(v) > 4 else 0, v[5] if len(v) > 5 else 0]
    return (p, r)
def mul(a, b):  # a*b
    return ([a[0][i] + mv(a[1], b[0])[i] for i in range(3)], mm(a[1], b[1]))
def inv(a):
    rt = tr(a[1]); return ([-x for x in mv(rt, a[0])], rt)
D = math.radians
C0ROT = {"Torso": rot(D(-90), 0, D(-180)), "Head": rot(D(-90), 0, D(-180)),
         "Right Arm": rot(0, D(90), 0), "Right Leg": rot(0, D(90), 0), "Left Arm": rot(0, D(-90), 0), "Left Leg": rot(0, D(-90), 0)}
NAME = {"Torso": "Torso", "Head": "Head", "RightArm": "Right Arm", "LeftArm": "Left Arm", "RightLeg": "Right Leg", "LeftLeg": "Left Leg"}
LIMBS = ["Head", "RightArm", "LeftArm", "RightLeg", "LeftLeg"]
EASE = {"linear": (0, 0), "inout": (5, 2), "in": (5, 1), "out": (5, 0), "hold": (1, 1)}
PRI = {"Idle": 0, "Movement": 1, "Action": 2}
def joint(j, cf):
    r = ([0, 0, 0], C0ROT[NAME[j]])
    return mul(mul(inv(r), cf), r)
ref = [0]
def rid(): ref[0] += 1; return "RBX%08X" % ref[0]
def num(v):
    s = ("%.6f" % v).rstrip("0").rstrip(".")
    return "0" if s in ("", "-0") else s
def cfxml(cf):
    p, m = cf
    return ('<CoordinateFrame name="CFrame"><X>%s</X><Y>%s</Y><Z>%s</Z>' % tuple(num(x) for x in p) +
            "".join("<R%d%d>%s</R%d%d>" % (i, j, num(m[i][j]), i, j) for i in range(3) for j in range(3)) + "</CoordinateFrame>")
def pose(name, cf, es, ed, w, kids=""):
    return ('<Item class="Pose" referent="%s"><Properties><string name="Name">%s</string>%s<token name="EasingDirection">%d</token>'
            '<token name="EasingStyle">%d</token><float name="Weight">%s</float></Properties>%s</Item>' % (rid(), name, cfxml(cf), ed, es, w, kids))
def build(clip):
    keys = list(clip["keys"])
    if clip.get("loop") and keys[-1][0] < clip["length"]:
        keys.append([clip["length"], keys[0][1]] + keys[0][2:3])
    kfx = []
    for k in keys:
        es, ed = EASE[k[2] if len(k) > 2 else "inout"]
        P = k[1]
        tcf = want(P.get("Torso"))
        tR = ([0, 0, 0], tcf[1])
        kids = ""
        for j in LIMBS:
            cf = want(P.get(j))
            if j in ("RightLeg", "LeftLeg"):
                cf = mul(inv(tR), cf)
            kids += pose(NAME[j], joint(j, cf), es, ed, 1)
        torso = pose("Torso", joint("Torso", tcf), es, ed, 1, kids)
        root = pose("HumanoidRootPart", ([0, 0, 0], [[1, 0, 0], [0, 1, 0], [0, 0, 1]]), es, ed, 0, torso)
        kfx.append('<Item class="Keyframe" referent="%s"><Properties><string name="Name">Keyframe</string><float name="Time">%s</float></Properties>%s</Item>' % (rid(), num(k[0]), root))
    return ('<roblox xmlns:xmime="http://www.w3.org/2005/05/xmlmime" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="http://www.roblox.com/roblox.xsd" version="4">'
            '<Item class="KeyframeSequence" referent="%s"><Properties><string name="Name">%s</string><bool name="Loop">%s</bool><token name="Priority">%d</token></Properties>%s</Item></roblox>'
            % (rid(), clip["name"], "true" if clip.get("loop") else "false", PRI[clip.get("priority", "Action")], "".join(kfx)))
def euler(m):  # ToEulerAnglesXYZ of Rx*Ry*Rz
    y = math.asin(max(-1, min(1, m[0][2]))); x = math.atan2(-m[1][2], m[2][2]); z = math.atan2(-m[0][1], m[0][0]); return x, y, z
if __name__ == "__main__":
    out = sys.argv[1] if len(sys.argv) > 1 else os.path.join(os.path.dirname(__file__), "..", "art", "anim", "r6")
    os.makedirs(out, exist_ok=True)
    for c in CLIPS:
        open(os.path.join(out, c["name"] + ".rbxmx"), "w").write(build(c))
    # spot check: R6_Run key 0, Right Arm
    c = CLIPS[0]; ra = joint("RightArm", want(c["keys"][0][1]["RightArm"]))
    print(len(CLIPS), [c["name"] for c in CLIPS], [round(a, 5) for a in euler(ra[1])])
