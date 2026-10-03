"""Export Echo architecture from the retained original generated atlas."""
from pathlib import Path
from PIL import Image
import json, hashlib
ROOT=Path(__file__).resolve().parents[1]
SOURCE=ROOT/'tools/art_sources/echo/echo_source.png'
OUT=ROOT/'game/assets/environments/echo'
SPECS={
    'gate': ((25,40,615,520),(112,96)),
    'lantern': ((733,30,1004,525),(39,75)),
    'fragments': ((1110,80,1529,490),(94,92)),
    'bridge': ((15,650,652,982),(296,140)),
    'tree': ((650,520,1220,1010),(164,140)),
    'memory': ((1218,551,1530,1004),(36,52)),
}

def build():
    source=Image.open(SOURCE).convert('RGBA');OUT.mkdir(parents=True,exist_ok=True)
    manifest={'status':'TEMPORARY','source_sha256':hashlib.sha256(SOURCE.read_bytes()).hexdigest(),'assets':{}}
    for name,(box,size) in SPECS.items():
        im=source.crop(box)
        im.putalpha(im.getchannel('A').point(lambda a:255 if a>=170 else 0))
        im=im.crop(im.getbbox()).resize(size,Image.Resampling.NEAREST)
        alpha=im.getchannel('A')
        im=im.convert('RGB').quantize(colors=32,dither=Image.Dither.NONE).convert('RGBA');im.putalpha(alpha)
        filename='echo_'+name+'_v001.png';im.save(OUT/filename)
        manifest['assets'][name]={'file':filename,'size':size,'box':box,'deck_y':40 if name=='bridge' else None}
    (OUT/'production_manifest.json').write_text(json.dumps(manifest,indent=2),encoding='utf-8')
    print('Echo: six isolated architectural objects, binary alpha, nearest, 32 colors per object')

if __name__=='__main__':build()
