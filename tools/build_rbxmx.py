import json, math, copy
specs = json.load(open("specs.json"))
# SitDown variants (same poses, root offsets from the start point; see AnimClips.sitDown)
SIT_POSES = [
 {},
 {"UpperTorso":[-22,0,0],"Head":[10,0,0],"LeftUpperArm":[-28,0,-10],"LeftLowerArm":[18,0,0],"RightUpperArm":[-28,0,10],"RightLowerArm":[18,0,0],"LeftUpperLeg":[46,0,-2],"LeftLowerLeg":[-56,0,0],"LeftFoot":[10,0,0],"RightUpperLeg":[46,0,2],"RightLowerLeg":[-56,0,0],"RightFoot":[10,0,0]},
 {"UpperTorso":[-14,0,0],"Head":[6,0,0],"LeftUpperArm":[-10,0,-6],"LeftLowerArm":[12,0,0],"RightUpperArm":[-10,0,6],"RightLowerArm":[12,0,0],"LeftUpperLeg":[86,0,-3],"LeftLowerLeg":[-84,0,0],"LeftFoot":[0,0,0],"RightUpperLeg":[86,0,3],"RightLowerLeg":[-84,0,0],"RightFoot":[0,0,0]},
 {"UpperTorso":[3,0,0],"Head":[-2,0,0],"LeftUpperArm":[30,0,-4],"LeftLowerArm":[46,0,0],"RightUpperArm":[30,0,4],"RightLowerArm":[46,0,0],"LeftUpperLeg":[90,0,-3],"LeftLowerLeg":[-88,0,0],"LeftFoot":[-2,0,0],"RightUpperLeg":[90,0,3],"RightLowerLeg":[-88,0,0],"RightFoot":[-2,0,0]},
]
for y in (-0.95,-0.75,-0.55,-0.35,-0.15,0.05,0.25):
    s=[0,y,-1.5]
    specs.append({"name":"SitDown_%.2f"%y,"loop":False,"priority":2,"variant":{"kind":"SitDown","v":s},"keys":[
        {"t":0,"ease":"inout","root":s,"pose":SIT_POSES[0]},
        {"t":0.32,"ease":"inout","root":[0,y-0.45,-1.25],"pose":SIT_POSES[1]},
        {"t":0.72,"ease":"out","root":[0,y*0.1,-0.15],"pose":SIT_POSES[2]},
        {"t":1.05,"ease":"inout","root":[0,0,0],"pose":SIT_POSES[3]}]})

PARENT = {"LowerTorso":"HumanoidRootPart","UpperTorso":"LowerTorso","Head":"UpperTorso","LeftUpperArm":"UpperTorso","LeftLowerArm":"LeftUpperArm","LeftHand":"LeftLowerArm","RightUpperArm":"UpperTorso","RightLowerArm":"RightUpperArm","RightHand":"RightLowerArm","LeftUpperLeg":"LowerTorso","LeftLowerLeg":"LeftUpperLeg","LeftFoot":"LeftLowerLeg","RightUpperLeg":"LowerTorso","RightLowerLeg":"RightUpperLeg","RightFoot":"RightLowerLeg"}
ORDER = ["LowerTorso","UpperTorso","Head","LeftUpperArm","LeftLowerArm","LeftHand","RightUpperArm","RightLowerArm","RightHand","LeftUpperLeg","LeftLowerLeg","LeftFoot","RightUpperLeg","RightLowerLeg","RightFoot"]
EASE = {"linear":(0,0),"inout":(5,2),"in":(5,1),"out":(5,0)}
def mat(rx,ry,rz):
    # CFrame.Angles(rx, ry, rz) = Rx * Ry * Rz
    cx,sx=math.cos(rx),math.sin(rx); cy,sy=math.cos(ry),math.sin(ry); cz,sz=math.cos(rz),math.sin(rz)
    Rx=[[1,0,0],[0,cx,-sx],[0,sx,cx]]; Ry=[[cy,0,sy],[0,1,0],[-sy,0,cy]]; Rz=[[cz,-sz,0],[sz,cz,0],[0,0,1]]
    def mm(a,b): return [[sum(a[i][k]*b[k][j] for k in range(3)) for j in range(3)] for i in range(3)]
    return mm(mm(Rx,Ry),Rz)
assert abs(mat(math.radians(10),math.radians(20),math.radians(30))[0][1]+0.4698)<1e-3
ref=[0]
def r():
    ref[0]+=1; return "RBX%08X"%ref[0]
def cfxml(pos,m):
    f=lambda v:("%.6f"%v).rstrip("0").rstrip(".") if v!=0 else "0"
    return ('<CoordinateFrame name="CFrame"><X>%s</X><Y>%s</Y><Z>%s</Z>'%(f(pos[0]),f(pos[1]),f(pos[2]))+
            "".join("<R%d%d>%s</R%d%d>"%(i,j,f(m[i][j]),i,j) for i in range(3) for j in range(3))+"</CoordinateFrame>")
def pose_xml(name,pos,m,es,ed,weight,children):
    return ('<Item class="Pose" referent="%s"><Properties><string name="Name">%s</string>%s'
            '<token name="EasingDirection">%d</token><token name="EasingStyle">%d</token><float name="Weight">%s</float></Properties>%s</Item>'
            %(r(),name,cfxml(pos,m),ed,es,weight,children))
def build(spec):
    kfs=[]
    for k in spec["keys"]:
        es,ed=EASE[k.get("ease","inout")]
        built={}
        # children first: build bottom-up in reverse ORDER
        xml={}
        def make(j):
            ang=k["pose"].get(j,[0,0,0])
            m=mat(*(math.radians(a) for a in ang))
            pos=k["root"] if (j=="LowerTorso" and k.get("root")) else [0,0,0]
            kids="".join(make(c) for c in ORDER if PARENT[c]==j)
            return pose_xml(j,pos,m,es,ed,1,kids)
        root=pose_xml("HumanoidRootPart",[0,0,0],[[1,0,0],[0,1,0],[0,0,1]],0,0,0,make("LowerTorso"))
        kfs.append('<Item class="Keyframe" referent="%s"><Properties><string name="Name">Keyframe</string><float name="Time">%s</float></Properties>%s</Item>'%(r(),k["t"],root))
    return ('<roblox xmlns:xmime="http://www.w3.org/2005/05/xmlmime" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="http://www.roblox.com/roblox.xsd" version="4">'
            '<Item class="KeyframeSequence" referent="%s"><Properties><string name="Name">%s</string><bool name="Loop">%s</bool><token name="Priority">%d</token></Properties>%s</Item></roblox>'
            %(r(),spec["name"],"true" if spec["loop"] else "false",spec["priority"],"".join(kfs)))
import os
os.makedirs("out",exist_ok=True)
index=[]
for sp in specs:
    fn="anim_%s.rbxmx"%sp["name"].replace(".","p").replace("-","m")
    open("out/"+fn,"w").write(build(sp))
    index.append({"name":sp["name"],"file":fn,"variant":sp.get("variant")})
json.dump(index,open("out/index.json","w"),indent=1)
print(len(index), [i["file"] for i in index])
