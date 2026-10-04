"""Technical checks of production exports, not an artistic approval."""
from pathlib import Path
from PIL import Image
import json
ROOT=Path(__file__).resolve().parents[1]

def main():
    report={'scope':'Character runtime exports','status':'COMPLETE technical only','characters':{}}
    for name,folder in [('ren','characters/ren'),('human','enemies/human_base'),('akio','characters/akio'),('daigo','characters/daigo')]:
        location=ROOT/'game/assets'/folder
        manifest=json.loads((location/'production_manifest.json').read_text(encoding='utf-8'))
        width,height=manifest['cell'];count=0
        for animation,clip in manifest['animations'].items():
            image=Image.open(location/clip['file'])
            assert image.size==(width*len(clip['poses']),height),(name,animation,'sheet size')
            assert set(image.getchannel('A').getdata())=={0,255},(name,animation,'binary alpha')
            for frame in range(len(clip['poses'])):
                box=image.crop((frame*width,0,(frame+1)*width,height)).getbbox()
                assert box and 0<box[0]<box[2]<width and 0<box[1]<box[3]<height,(name,animation,frame,'empty or clipped',box)
                assert box[3]<=manifest['pivot'][1]+1,(name,animation,frame,'foot baseline')
                count+=1
        report['characters'][name]={'clips':len(manifest['animations']),'frames':count,'cell':[width,height],'pivot':manifest['pivot']}
    destination=ROOT/'docs/screenshots/chapter1/production_asset_validation.json'
    destination.write_text(json.dumps(report,indent=2),encoding='utf-8')
    print('PRODUCTION ASSETS PASS: sheet dimensions, nonempty frames, binary alpha, complete cell margins and foot baseline')

if __name__=='__main__':main()
