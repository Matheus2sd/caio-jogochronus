"""Rebuild provisional runtime art from approved sheets; never edit originals.
Requires Pillow and NumPy. All crop coordinates and pivots are recorded here.
"""
from pathlib import Path
from collections import deque
import json
import math
import random
import struct
import wave
import numpy as np
from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parents[1]
REF = ROOT / 'assets_referencia'
OUT = ROOT / 'game/assets'
MANIFEST = []
SOURCES = {
    'ren': '01_PERSONAGENS/REN_JOVEM/Ren_Jovem_Folha_Producao.png',
    'akio': '01_PERSONAGENS/AKIO_JOVEM/Akio_Jovem_Folha_Producao_01.png',
    'daigo': '01_PERSONAGENS/DAIGO/Daigo_Folha_Producao_VISUAL.png',
    'human': '01_PERSONAGENS/INIMIGO_HUMANO/Inimigo_Humano_Base_Folha_Producao.png',
    'world': '02_CENARIOS_TILESETS/Tileset_Capitulo1_Primavera_Referencia.png',
    'echo': '03_MUNDO_ECO_VFX/Mundo_Eco_Transformacao_Referencia.png',
}

def save(im, name, source, box, **info):
    path = OUT / name
    path.parent.mkdir(parents=True, exist_ok=True)
    im.save(path)
    MANIFEST.append(dict(file=name, source=SOURCES.get(source, source), crop=box,
                         size=im.size, status='TEMPORARY', **info))

def crop(source, box, clear=False):
    im = Image.open(REF / SOURCES[source]).convert('RGBA').crop(box)
    if not clear:
        return im
    a = np.array(im)
    rgb = a[:, :, :3].astype(float)
    if source == 'ren':
        bg = (rgb[:, :, 0] < 35) & (rgb[:, :, 1] < 45) & (rgb[:, :, 2] < 53)
    else:
        bg = (rgb[:, :, 0] > 205) & (rgb[:, :, 1] > 180) & (rgb[:, :, 2] > 135)
    # Border flood keeps enclosed costume/skin colors intact.
    h, w = bg.shape
    q = deque([(x, y) for y in range(h) for x in (0, w-1)] +
              [(x, y) for x in range(w) for y in (0, h-1)])
    seen = np.zeros((h, w), dtype=bool)
    while q:
        x, y = q.popleft()
        if x < 0 or y < 0 or x >= w or y >= h or seen[y, x] or not bg[y, x]:
            continue
        seen[y, x] = True
        q.extend(((x-1,y),(x+1,y),(x,y-1),(x,y+1)))
    a[seen, 3] = 0
    return Image.fromarray(a)

def characters():
    # Eight true reference poses; duplicated animation states remain documented.
    specs = {
        'ren': (52, [(433,171,535,302),(749,186,893,302),(910,161,1055,302),
                       (559,191,728,302),(429,348,638,482),(683,348,838,482),
                       (879,355,1041,482),(559,191,728,302)]),
        'akio': (52, [(442,174,531,263),(744,186,831,263),(840,171,965,263),
                        (554,313,693,400),(683,306,830,400),(1043,306,1165,400),
                        (609,450,716,529),(1068,479,1255,530)]),
        'daigo': (58, [(17,459,90,534),(182,461,269,534),(285,460,380,534),
                         (822,460,932,534),(1134,459,1251,534),(1406,458,1518,534),
                         (13,739,115,813),(92,611,154,680)]),
        'human': (48, [(446,194,505,278),(687,193,746,278),(758,193,815,278),
                         (884,194,965,278),(1194,193,1324,278),(510,327,592,424),
                         (603,341,703,424),(1254,388,1417,424)]),
    }
    for name, (height, boxes) in specs.items():
        atlas = Image.new('RGBA', (96 * 8, 96))
        # Uniform sheet scale preserves body proportions between attack poses.
        factor = height / (boxes[0][3] - boxes[0][1])
        for i, box in enumerate(boxes):
            im = crop(name, box, True)
            im = im.resize((max(1,round(im.width*factor)), max(1,round(im.height*factor))), Image.Resampling.NEAREST)
            atlas.alpha_composite(im, (96*i+48-im.width//2, 80-im.height))
        folder = 'enemies/human_base' if name == 'human' else 'characters/' + name
        save(atlas, folder+'/TEMP_poses.png', name, boxes, pivot=[48,80], cell=[96,96],
             poses=['idle','run','jump','light','heavy','guard','hurt','down'])

def environments():
    for source, box, name in [
        ('world',(482,421,1437,649),'present/TEMP_background.png'),
        ('echo',(1094,435,1429,599),'echo/TEMP_background.png'),
        ('daigo',(14,872,575,1005),'backgrounds/TEMP_arena.png'),
    ]:
        save(crop(source,box).resize((640,220),Image.Resampling.NEAREST),'environments/'+name,source,box)
    # Individual reference texture samples on an explicit 16x16 grid.
    boxes=[(26,172,51,198),(120,173,146,198),(368,175,393,200),
           (120,279,144,305),(120,386,144,412),(286,600,314,627),
           (264,176,286,199),(25,278,51,304)]
    sheet=Image.new('RGBA',(128,16))
    for i,b in enumerate(boxes):
        sheet.paste(crop('world',b).resize((16,16),Image.Resampling.NEAREST),(i*16,0))
    save(sheet,'environments/tilesets/TEMP_tiles.png','world',boxes,cell=[16,16])
    for name,box,size in [('tree',(480,160,654,337),(122,125)),
                          ('pine',(649,160,754,337),(78,130)),
                          ('gate',(750,210,860,340),(85,105)),
                          ('lantern',(856,233,908,337),(26,52)),
                          ('house',(959,162,1149,340),(170,156)),
                          ('fence',(1148,292,1293,340),(110,36))]:
        save(crop('world',box,True).resize(size,Image.Resampling.NEAREST),
             'environments/props/TEMP_'+name+'.png','world',box)

def audio():
    rng=random.Random(421)
    rate=22050
    specs={'slash':(.15,320),'heavy':(.28,140),'impact':(.13,85),
           'parry':(.38,1250),'guard':(.18,480),'heal':(.8,660),
           'echo':(1.2,220),'break':(.4,110),'step':(.06,90)}
    for name,(length,freq) in specs.items():
        samples=[]
        for i in range(int(rate*length)):
            t=i/rate
            env=(1-t/length)**2*min(1,t/.005)
            noise=rng.uniform(-1,1)
            tone=math.sin(math.tau*(freq*t+freq*.1*t*t))
            value=(noise*.65+tone*.35) if name in ['slash','heavy','impact','step','break'] else tone*.7+math.sin(math.tau*freq*1.5*t)*.3
            samples.append(int(value*env*10000))
        write_wave('sfx/TEMP_'+name+'.wav',samples,rate)
    for category in ['ambient','music']:
        samples=[]
        length=8
        for i in range(rate*length):
            t=i/rate
            if category=='ambient':
                v=rng.uniform(-1,1)*.06+math.sin(t*math.tau*110)*.02
            else:
                note=[146.83,174.61,196,220][min(3,int(t/2))]
                e=math.sin(math.pi*(t%2)/2)**2
                v=(math.sin(math.tau*note*t)+.3*math.sin(math.tau*note*2*t))*e*.045
            # Short fades avoid loop boundary clicks.
            samples.append(int(v*min(1,t/.1,(length-t)/.1)*32767))
        write_wave(category+'/TEMP_'+category+'.wav',samples,rate)

def write_wave(name,samples,rate):
    path=OUT/'audio'/name
    path.parent.mkdir(parents=True,exist_ok=True)
    with wave.open(str(path),'wb') as f:
        f.setnchannels(1); f.setsampwidth(2); f.setframerate(rate)
        f.writeframes(struct.pack('<'+'h'*len(samples),*samples))

if __name__=='__main__':
    characters(); environments(); audio()
    for folder in ['vfx/combat','vfx/echo','ui/hud','ui/icons','ui/dialogue','ui/menus']:
        p=OUT/folder; p.mkdir(parents=True,exist_ok=True)
        (p/'README.txt').write_text('TEMPORARY: desenhado proceduralmente pelos scripts Godot. Ver TODO_ASSETS.md.\n',encoding='utf-8')
    (OUT/'manifest.json').write_text(json.dumps(MANIFEST,ensure_ascii=False,indent=2),encoding='utf-8')
    print(f'Built {len(MANIFEST)} image assets and original temporary WAV audio.')
