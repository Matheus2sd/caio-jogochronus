"""Export independent transparent parallax layers with mirrored seamless repeats."""
from pathlib import Path
import json
import random
from PIL import Image, ImageDraw, ImageOps
ROOT=Path(__file__).resolve().parents[1]
OUT=ROOT/'game/assets/environments/present'

def build():
    OUT.mkdir(parents=True,exist_ok=True)
    sky=Image.new('RGBA',(640,360));d=ImageDraw.Draw(sky)
    for y in range(360):
        t=min(y,280)/280
        d.line((0,y,639,y),fill=(int(111+76*t),int(159+39*t),int(180+5*t),255))
    rng=random.Random(101)
    for i in range(23):
        x=rng.randrange(640);y=rng.randrange(0,95);w=rng.randrange(14,65)
        d.rectangle((x,y,x+w,y+2),fill='#cedbd1')
        d.rectangle((x+7,y-3,x+w-9,y+1),fill='#dfe4d4')
    sky.save(OUT/'bg_sky_v001.png')
    source=Image.open(ROOT/'tools/art_sources/environment/parallax_source.png').convert('RGBA')
    entries=[('mountains',0,256,150,68,0.12),('far_forest',256,511,112,152,0.28),('mid_forest',511,738,114,186,0.48),('near_forest',738,1024,280,0,0.72)]
    for name,y0,y1,h,_,_ in entries:
        im=source.crop((0,y0,1536,y1))
        im.putalpha(im.getchannel('A').point(lambda a:255 if a>=170 else 0))
        im=im.resize((640,h),Image.Resampling.NEAREST)
        a=im.getchannel('A');im=im.convert('RGB').quantize(colors=48,dither=Image.Dither.NONE).convert('RGBA');im.putalpha(a)
        repeat=Image.new('RGBA',(1280,h));repeat.paste(im,(0,0));repeat.paste(ImageOps.mirror(im),(640,0))
        repeat.save(OUT/('bg_'+name+'_v001.png'))
    (OUT/'parallax.json').write_text(json.dumps(dict(layers=[dict(name=n,y=y,height=h,speed=s,repeat=1280) for n,_,_,h,y,s in entries],sky='procedural original with discrete cloud clusters',repeat='original 640px then mirrored 640px; no alpha blend/blur'),indent=2),encoding='utf-8')
    print('Parallax: sky + four independently scrolling layers')

if __name__=='__main__':build()
