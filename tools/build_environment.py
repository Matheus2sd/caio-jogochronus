"""Original pixel tiles and export of newly generated props; never crops references."""
from pathlib import Path
import json
import random
from PIL import Image, ImageDraw

ROOT=Path(__file__).resolve().parents[1]
OUT=ROOT/'game/assets/environments'
SOURCE=ROOT/'tools/art_sources/environment'

def props():
    source=Image.open(SOURCE/'props_source.png').convert('RGBA')
    entries={
        'tree':([0,0,632,427],[192,130]),'pine':([598,10,1080,427],[132,145]),
        'gate':([1098,50,1508,427],[88,90]),'house':([40,433,566,750],[184,112]),
        'fence':([620,526,1064,733],[104,44]),'lantern':([1196,437,1404,754],[32,50]),
        'bush':([50,770,500,1012],[52,28]),'well':([658,744,940,1010],[56,52]),
        'rocks':([1100,772,1475,1010],[52,34])}
    (OUT/'props').mkdir(parents=True,exist_ok=True)
    for name,(box,size) in entries.items():
        im=source.crop(box)
        im.putalpha(im.getchannel('A').point(lambda a:255 if a>=170 else 0))
        im=im.crop(im.getbbox()).resize(size,Image.Resampling.NEAREST)
        alpha=im.getchannel('A')
        im=im.convert('RGB').quantize(colors=40,dither=Image.Dither.NONE).convert('RGBA')
        im.putalpha(alpha);im.save(OUT/'props'/('env_'+name+'_v001.png'))
    (SOURCE/'props.json').write_text(json.dumps(entries,indent=2),encoding='utf-8')

def tiles():
    rng=random.Random(101)
    atlas=Image.new('RGBA',(256,128))
    for row in range(8):
        for col in range(16):
            im=Image.new('RGBA',(16,16));d=ImageDraw.Draw(im)
            if row in (0,1):
                d.rectangle((0,0,15,15),fill='#92764f' if row==0 else '#695445')
                colors=['#ab8c61','#bc9d6e','#816444'] if row==0 else ['#765b42','#594536','#896749']
                for i in range(17):
                    x,y=rng.randrange(16),rng.randrange(16)
                    d.line((x,y,x+rng.randrange(1,3),y),fill=rng.choice(colors))
                if row==0:
                    d.line((0,0,15,0),fill='#e0d3a1')
                    if col<8:
                        for x in range(16):
                            h=rng.randrange(1,5)
                            d.line((x,0,x,h),fill=rng.choice(['#61725b','#8e984e','#b3ae6b']))
                else:
                    for i in range(2):
                        x,y=rng.randrange(13),rng.randrange(13)
                        d.rectangle((x,y,x+2,y+1),fill='#3f3b35')
            elif row in (2,6):
                d.rectangle((0,0,15,15),fill='#443d36')
                for y in (0,8):
                    d.rectangle((0,y,15,y+6),fill='#806244')
                    d.line((0,y,15,y),fill='#ba9864')
                    for i in range(3):
                        x=rng.randrange(12); yy=y+rng.randrange(1,6)
                        d.line((x,yy,x+3,yy),fill='#634b36')
                    d.point((2,y+2),fill='#262d31')
                if row==6:
                    d.rectangle((0,10,15,15),fill=(0,0,0,0))
            elif row==3:
                d.rectangle((0,0,15,15),fill='#303b42')
                for y in (0,8):
                    offset=0 if y==0 else -4
                    for x in range(offset,16,8):
                        d.rectangle((x+1,y+1,x+7,y+6),fill=rng.choice(['#747d80','#69777b','#84908e']))
                        d.line((x+1,y+1,x+6,y+1),fill='#a1a89e')
                        d.line((x+7,y+2,x+7,y+6),fill='#4e5d64')
            elif row==4:
                for i in range(7):
                    x=rng.randrange(16);h=rng.randrange(4,15)
                    d.line((x,15,x-2,15-h),fill=rng.choice(['#61725b','#8b975a','#445e4a']))
                    if col>=8:
                        d.rectangle((x-2,14-h,x,15-h),fill=rng.choice(['#d9a6a5','#e0d3b7','#c5b374']))
            elif row==5:
                d.rectangle((0,0,15,15),fill='#416b7b')
                for i in range(4):
                    x,y=rng.randrange(16),rng.randrange(16)
                    d.line((x,y,x+rng.randrange(2,7),y),fill=rng.choice(['#6a9aa5','#9cc7c6','#31546d']))
            else:
                d.rectangle((0,0,15,15),fill='#303b48')
                for x in range(0,16,4):
                    d.rectangle((x,0,x+2,14),fill='#536574')
                    d.line((x,1,x,13),fill='#899599')
                d.line((0,15,15,15),fill='#1f303d')
            atlas.paste(im,(col*16,row*16))
    (OUT/'tilesets').mkdir(parents=True,exist_ok=True)
    atlas.save(OUT/'tilesets/env_spring_v001.png')
    resource='''[gd_resource type="TileSet" load_steps=3 format=3]

[ext_resource type="Texture2D" path="res://assets/environments/tilesets/env_spring_v001.png" id="1"]

[sub_resource type="TileSetAtlasSource" id="Atlas"]
texture = ExtResource("1")
texture_region_size = Vector2i(16,16)
'''
    for y in range(8):
        for x in range(16):
            resource+='%d:%d/0 = 0\n'%(x,y)
            if y in [0,1,2,3]:
                resource+='%d:%d/0/physics_layer_0/polygon_0/points = PackedVector2Array(-8,-8,8,-8,8,8,-8,8)\n'%(x,y)
    resource+='\n[resource]\ntile_size = Vector2i(16,16)\nphysics_layer_0/collision_layer = 1\nsources/0 = SubResource("Atlas")\n'
    (OUT/'tilesets/chapter1_tileset.tres').write_text(resource,encoding='utf-8')
    (SOURCE/'tiles.json').write_text(json.dumps(dict(seed=101,cell=[16,16],rows=['grass_path','earth','wood','stone_steps','grass_flowers','water','bridge','roof'],source='Original procedural pixel clusters, palette from AR02/V03'),indent=2),encoding='utf-8')

if __name__=='__main__':
    props();tiles();print('Environment: 9 new props, 128 original tiles and Godot TileSet')
