import sys, math
from PIL import Image
import numpy as np
from scipy import ndimage
D=sys.argv[1]
src={"Crimson":"mcp-remote-devices-blob-1795672252868-t72w6x-d213bf59.jpg","Cobalt":"mcp-remote-devices-blob-1795672263153-dad7u8-6eb74833.jpg",
"Gold":"mcp-remote-devices-blob-1795672273630-duhms9-8f2e0a0c.jpg","Plasma":"mcp-remote-devices-blob-1795672280885-nicz6m-edbb2b3e.jpg",
"Ember":"mcp-remote-devices-blob-1795672288729-0p5mho-d40e1b94.jpg","Void":"mcp-remote-devices-blob-1795672296353-evzk1v-a338d254.jpg"}
OUT=512
for k,f in src.items():
    img0=Image.open(D+"/"+f).convert("RGB")
    im=np.asarray(img0).astype(np.float32)/255
    h,w,_=im.shape
    m=im.max(axis=2)>0.12
    lab,n=ndimage.label(m)
    sizes=ndimage.sum(m,lab,range(1,n+1))
    best=None
    for i in range(n):
        if sizes[i]<800: continue
        ys,xs=np.nonzero(lab==i+1)
        L=np.hypot(xs.max()-xs.min(),ys.max()-ys.min())
        cx,cy=xs.mean(),ys.mean()
        d=np.hypot(cx-w/2,cy-h/2)
        if xs.min()>200 and xs.max()<w-200 and ys.min()>150 and ys.max()<h-150 and (best is None or d<best[0]):
            best=(d,cx,cy,L,xs,ys)
    _,cx,cy,L,xs,ys=best
    # the streak's angle (principal axis)
    ang=math.degrees(math.atan2(np.cov(xs,ys)[0,1]*2,np.var(xs)-np.var(ys))/2)  # below horizontal (image y down)
    # whole round: streak + body/nose up-left of it: centre shifted toward the nose
    ux,uy=math.cos(math.radians(ang)),math.sin(math.radians(ang))
    cx-=ux*L*0.18; cy-=uy*L*0.18
    big=int(L*2.2)
    box=(int(cx-big/2),int(cy-big/2),int(cx+big/2),int(cy+big/2))
    c=img0.crop(box)
    # turn it to a 40 degree diagonal so it fills the square
    c=c.rotate(ang-40, resample=Image.BICUBIC)  # PIL rotates counter-clockwise
    s=int(L*1.05)
    cc=c.crop(((big-s)//2,(big-s)//2,(big+s)//2,(big+s)//2))
    a=np.asarray(cc).astype(np.float32)/255
    mx=a.max(axis=2,keepdims=True)
    al=np.clip((mx[...,0]-0.05)/0.4,0,1)
    rgb=np.clip(a/np.maximum(mx,1e-3),0,1)*np.clip(mx/0.75,0,1)
    out=Image.fromarray((np.dstack([rgb,al])*255).astype(np.uint8),"RGBA").resize((OUT,OUT),Image.LANCZOS)
    out.save(f"tracer_{k}.png")
    bg=Image.new("RGBA",(OUT,OUT),(28,31,24,255)); bg.alpha_composite(out); bg.convert("RGB").save(f"preview_{k}.jpg")
    print(k,round(ang,1),s)
ims=[Image.open(f'preview_{k}.jpg') for k in src]
sh=Image.new('RGB',(OUT*3,OUT*2))
for i,im2 in enumerate(ims): sh.paste(im2,((i%3)*OUT,(i//3)*OUT))
sh.save('sheet.jpg')
