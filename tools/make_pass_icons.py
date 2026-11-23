from PIL import Image, ImageDraw, ImageFont, ImageFilter
import numpy as np
S='/mnt/user-data/uploads/BlenderExports/fx/'
s1=Image.open(S+'ui_icons_v2_1.png').convert('RGBA'); s2=Image.open(S+'ui_icons_v2_2.png').convert('RGBA')
def cell(sh,r,c):
    im=sh.crop((c*256,r*256,c*256+256,r*256+256)); return im.crop(im.getbbox())
font=ImageFont.truetype('/usr/share/fonts/opentype/noto/NotoSansCJK-Black.ttc',112)
def make(icon,ring,name,x2=False,fill=0.62):
    N=512
    bg=Image.new('RGBA',(N,N),ring+(255,))
    t=np.linspace(0,1,N)[:,None]
    g=(np.array([46,52,38])*(1-t)+np.array([18,20,15])*t)
    g=np.repeat(g[:,None,:],N,1)
    inner=Image.fromarray(np.dstack([g,np.full((N,N),255)]).astype('uint8'),'RGBA')
    m=Image.new('L',(N,N),0); ImageDraw.Draw(m).rectangle((18,18,N-19,N-19),fill=255)
    bg.paste(inner,(0,0),m)
    w,h=icon.size; k=N*fill/max(w,h)
    ic=icon.resize((int(w*k),int(h*k)),Image.LANCZOS)
    off=((N-ic.width)//2-(15 if x2 else 0),(N-ic.height)//2-(25 if x2 else 0))
    ol=Image.new('L',(N,N),0); ol.paste(ic.split()[3],off); ol=ol.filter(ImageFilter.MaxFilter(13))
    bg.paste((5,5,5,255),(0,0),ol); bg.alpha_composite(ic,off)
    if x2:
        ImageDraw.Draw(bg).text((N-105,N-95),'x2',font=font,fill='white',anchor='rs',stroke_width=12,stroke_fill='black')
    bg.convert('RGB').save(name)
make(cell(s2,3,1),(255,190,40),'pass_free_nuke.png')
make(cell(s1,2,0),(160,255,70),'pass_head_start.png')
make(cell(s1,1,2),(160,255,70),'pass_2x_cash.png',True,0.56)
make(cell(s1,1,1),(175,120,255),'pass_2x_gems.png',True,0.56)
c=Image.new('RGB',(2048,512),'white')
for i,f in enumerate(['pass_free_nuke.png','pass_head_start.png','pass_2x_cash.png','pass_2x_gems.png']):
    mk=Image.new('L',(512,512),0); ImageDraw.Draw(mk).ellipse((0,0,511,511),fill=255)
    c.paste(Image.open(f),(i*512,0),mk)
c.save('preview.png')
