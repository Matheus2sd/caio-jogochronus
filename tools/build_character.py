"""Export reviewed generated key poses; Pillow only, no network, no official crops."""
from pathlib import Path
import argparse
import json
import hashlib
from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parents[1]

def isolated_poses(source, spec):
    """Find complete connected silhouettes, including swords outside grid cells."""
    width, height = source.size
    pixels = bytearray(source.getchannel('A').point(lambda v: 1 if v >= 160 else 0).tobytes())
    found = []
    for start in range(len(pixels)):
        if not pixels[start]: continue
        stack = [start]; pixels[start] = 0; component = []
        while stack:
            position = stack.pop(); x = position % width
            component.append(position)
            for neighbor in (position-width, position+width, position-1 if x else -1, position+1 if x<width-1 else -1):
                if 0 <= neighbor < len(pixels) and pixels[neighbor]:
                    pixels[neighbor] = 0; stack.append(neighbor)
        if len(component) < 500: continue
        xs = [p % width for p in component]; ys = [p // width for p in component]
        box = (min(xs), min(ys), max(xs)+1, max(ys)+1)
        mask = Image.new('L',(box[2]-box[0],box[3]-box[1]))
        for p in component: mask.putpixel((p%width-box[0],p//width-box[1]),255)
        im = source.crop(box).convert('RGBA'); im.putalpha(mask)
        row = min(range(len(spec['foot_rows'])),key=lambda r:abs(spec['foot_rows'][r]-box[3]))
        found.append((row,box[0],im,box,len(component)))
    minimum = spec.get('minimum_pose_area',500)
    extras = [entry for entry in found if entry[4]<minimum]
    found = [entry for entry in found if entry[4]>=minimum]
    for part in extras:
        # A disconnected blade in a prone pose belongs to the nearest body in its row.
        candidates = [i for i,entry in enumerate(found) if entry[0]==part[0]]
        i = min(candidates,key=lambda j:abs(sum(found[j][3][::2])-sum(part[3][::2])))
        body = found[i]; a=body[3]; b=part[3]
        box=(min(a[0],b[0]),min(a[1],b[1]),max(a[2],b[2]),max(a[3],b[3]))
        im=Image.new('RGBA',(box[2]-box[0],box[3]-box[1]))
        im.alpha_composite(body[2],(a[0]-box[0],a[1]-box[1]))
        im.alpha_composite(part[2],(b[0]-box[0],b[1]-box[1]))
        found[i]=(body[0],box[0],im,box,body[4]+part[4])
    found.sort(key=lambda entry:entry[:2])
    assert len(found) == spec['grid'][0]*spec['grid'][1], 'Unexpected connected pose count'
    return [entry[2] for entry in found]

def extract(source, spec, index, height, cell_width=96, components=None):
    cols, rows = spec['grid']
    x, y = index % cols, index // cols
    xs = spec.get('x_edges', [round(i*source.width/cols) for i in range(cols+1)])
    ys = spec.get('y_edges', [round(i*source.height/rows) for i in range(rows+1)])
    box = spec.get('boxes', {}).get(str(index), [xs[x], ys[y], xs[x+1], ys[y+1]])
    im = components[index].copy() if components else source.crop(box).convert('RGBA')
    im.putalpha(im.getchannel('A').point(lambda a: 255 if a >= 160 else 0))
    bbox = im.getbbox()
    if not bbox:
        raise ValueError('Empty source cell: %s' % index)
    factor = height / spec['upright_height']
    # Alignment uses reviewed foot center, never weapon-inclusive bbox center.
    bottom = bbox[3]
    band = im.getchannel('A').crop((0,max(0,bottom-5),im.width,bottom)).getbbox()
    foot_x = (band[0]+band[2])/2 if band else im.width/2
    anchor = spec.get('anchors', {}).get(str(index), [foot_x,bottom])
    im = im.resize((round(im.width*factor),round(im.height*factor)),Image.Resampling.NEAREST)
    cell = Image.new('RGBA',(cell_width,96))
    cell.alpha_composite(im,(round(cell_width/2-anchor[0]*factor),round(80-anchor[1]*factor)))
    return cell

def build(name):
    folder = ROOT/'tools/art_sources'/name
    spec = json.loads((folder/'character.json').read_text(encoding='utf-8'))
    target = ROOT/'game/assets'/spec['folder']
    target.mkdir(parents=True,exist_ok=True)
    sources = {k: Image.open(folder/v['file']) for k,v in spec['sources'].items()}
    components = {k: isolated_poses(sources[k],v) for k,v in spec['sources'].items() if v.get('isolated_components')}
    cell_width = spec.get('cell_width',96)
    cells = {}
    for animation in spec['animations'].values():
        for code in animation['poses']:
            key,index=code.split(':'); index=int(index)
            if code not in cells:
                cells[code]=extract(sources[key],spec['sources'][key],index,spec['height'],cell_width,components.get(key))
    # Shared palette preserves identity across all exported poses.
    sample=Image.new('RGBA',(cell_width*len(cells),96))
    for i,cell in enumerate(cells.values()): sample.paste(cell,(cell_width*i,0))
    palette=sample.convert('RGB').quantize(colors=24,method=Image.Quantize.MEDIANCUT)
    for code,cell in cells.items():
        alpha=cell.getchannel('A')
        cell=cell.convert('RGB').quantize(palette=palette,dither=Image.Dither.NONE).convert('RGBA')
        cell.putalpha(alpha); cells[code]=cell
    ext=[]; sub=[]; animations=[]
    manifest=dict(character=name,status='TEMPORARY',height=spec['height'],cell=[cell_width,96],pivot=[cell_width//2,80],
                  provenance='New image_gen drawings; approved references used for identity only',
                  notes=spec.get('notes',[]),sources={},animations={})
    for key,s in spec['sources'].items():
        manifest['sources'][key]=dict(file=s['file'],sha256=hashlib.sha256((folder/s['file']).read_bytes()).hexdigest())
    preview=Image.new('RGB',(cell_width*8,116*len(spec['animations'])),'#677677')
    d=ImageDraw.Draw(preview)
    for n,(anim,data) in enumerate(spec['animations'].items()):
        frames=data['poses']; fn='chr_%s_%s_v001.png'%(name,anim)
        sheet=Image.new('RGBA',(cell_width*len(frames),96))
        for i,code in enumerate(frames):
            sheet.paste(cells[code],(i*cell_width,0))
            if i<8: preview.paste(cells[code],(i*cell_width,n*116+20),cells[code])
        d.text((4,n*116+3),anim,fill='white')
        sheet.save(target/fn)
        ext.append('[ext_resource type="Texture2D" path="res://assets/%s/%s" id="%s"]'%(spec['folder'],fn,anim))
        frame_strings=[]
        for i in range(len(frames)):
            ident='%s_%d'%(anim,i)
            sub.append('[sub_resource type="AtlasTexture" id="%s"]\natlas = ExtResource("%s")\nregion = Rect2(%d, 0, %d, 96)'%(ident,anim,cell_width*i,cell_width))
            frame_strings.append('{"duration": 1.0, "texture": SubResource("%s")}'%ident)
        animations.append('{"frames": [%s], "loop": %s, "name": &"%s", "speed": %s}'%(', '.join(frame_strings),str(data.get('loop',False)).lower(),anim,float(data['fps'])))
        manifest['animations'][anim]=dict(file=fn,**data)
    resource='[gd_resource type="SpriteFrames" load_steps=%d format=3]\n\n'%(len(ext)+len(sub)+1)
    resource+='\n\n'.join(ext+sub)+'\n\n[resource]\nanimations = [\n'+',\n'.join(animations)+'\n]\n'
    (target/(name+'_frames.tres')).write_text(resource,encoding='utf-8')
    (target/'production_manifest.json').write_text(json.dumps(manifest,indent=2,ensure_ascii=False),encoding='utf-8')
    local=ROOT/'tools/local';local.mkdir(exist_ok=True)
    preview.save(local/(name+'-production-contact.png'))
    print('%s: %d clips, %d unique selected key poses'%(name,len(animations),len(cells)))

if __name__=='__main__':
    parser=argparse.ArgumentParser();parser.add_argument('character');args=parser.parse_args()
    build(args.character)
