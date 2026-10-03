"""Original deterministic pixel VFX; editable geometry, no new damage areas."""
from pathlib import Path
from PIL import Image, ImageDraw
import math, random, json
ROOT=Path(__file__).resolve().parents[1]
OUT=ROOT/'game/assets/vfx/combat'

def build():
    OUT.mkdir(parents=True,exist_ok=True)
    manifest={}
    for name in ['slash','heavy_slash','impact','parry','posture_break','heal']:
        atlas=Image.new('RGBA',(96*6,96))
        for frame in range(6):
            im=Image.new('RGBA',(96,96));d=ImageDraw.Draw(im)
            fade=int(255*(1-frame/7));rng=random.Random(310+frame)
            if name in ['slash','heavy_slash']:
                radius=(31 if name=='slash' else 42)-frame
                begin=-75+frame*10;end=70+frame*10
                for r,color in [(radius,(125,172,188,fade//2)),(radius-2,(217,230,217,fade)),(radius-3,(255,242,201,fade))]:
                    d.arc((48-r,48-r,48+r,48+r),begin,end,fill=color,width=2 if name=='heavy_slash' else 1)
            elif name in ['impact','parry','posture_break']:
                color=(177,231,242,fade) if name=='parry' else (239,204,141,fade)
                arms=8 if name=='posture_break' else 6
                for i in range(arms):
                    angle=i*math.tau/arms+0.22
                    start=2+frame*2;end=start+(20 if name=='parry' else 12)*(1-frame/7)
                    p=(48+int(math.cos(angle)*start),48+int(math.sin(angle)*start),48+int(math.cos(angle)*end),48+int(math.sin(angle)*end))
                    d.line(p,fill=color,width=2 if frame<2 else 1)
                if name=='parry' and frame<3:
                    r=5+frame*5;d.polygon([(48,48-r),(48+r,48),(48,48+r),(48-r,48)],outline=color)
                if name=='posture_break':
                    for i in range(5):
                        x=32+i*8;y=50+frame*2+i%2*4
                        d.rectangle((x,y,x+2,y+3),fill=color)
            else:
                for i in range(9):
                    x=29+(i*17)%38;y=70-(frame*6+i*7)%45
                    d.line((x,y,x,y-3),fill=(156,194,153,fade))
                    d.point((x+1,y-2),fill=(227,230,179,fade))
            atlas.paste(im,(frame*96,0))
        fn='fx_'+name+'_v001.png';atlas.save(OUT/fn)
        manifest[name]=dict(file=fn,cell=[96,96],pivot=[48,48],frames=6,fps=20 if name!='heal' else 10,source='Original pixel geometry in tools/build_effects.py',status='TEMPORARY')
    (OUT/'production_manifest.json').write_text(json.dumps(manifest,indent=2),encoding='utf-8')
    print('VFX: six effects, six independently drawn stages each')

if __name__=='__main__':build()
