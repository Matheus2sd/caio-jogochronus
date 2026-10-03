"""Original pixel UI primitives matching the approved dark slate / aged gold kit."""
from pathlib import Path
from PIL import Image, ImageDraw
import json
ROOT=Path(__file__).resolve().parents[1]
OUT=ROOT/'game/assets/ui/production'

def build():
    OUT.mkdir(parents=True,exist_ok=True)
    outputs={}
    def save(name,im):
        im.save(OUT/(name+'.png'));outputs[name]=list(im.size)
    for name,edge in [('panel',(115,115,99,255)),('focus',(220,192,128,255))]:
        im=Image.new('RGBA',(32,32));d=ImageDraw.Draw(im)
        d.polygon([(4,0),(27,0),(31,4),(31,27),(27,31),(4,31),(0,27),(0,4)],fill=(13,24,29,236),outline=edge)
        d.line([(4,2),(27,2),(29,4)],fill=(61,72,70,255))
        for x,y,sx,sy in [(3,3,1,1),(28,3,-1,1),(3,28,1,-1),(28,28,-1,-1)]:
            d.line((x,y,x+sx*5,y),fill=(184,156,100,255));d.line((x,y,x,y+sy*5),fill=(184,156,100,255))
        save(name,im)
    for name,color,height in [('health_bar','#b86660',10),('stamina_bar','#78a996',8),('posture_bar','#c4a66c',6),('enemy_posture','#c4a66c',5),('boss_bar','#b86660',10)]:
        im=Image.new('RGBA',(32,height));d=ImageDraw.Draw(im)
        d.rectangle((0,0,31,height-1),fill='#17252b',outline='#777766')
        d.line((2,1,29,1),fill='#626859')
        save(name,im)
    for name in ['heal_icon','talisman_slot','echo_memory','interaction_prompt','progression']:
        im=Image.new('RGBA',(16,16));d=ImageDraw.Draw(im)
        if name=='heal_icon':
            d.polygon([(4,2),(12,4),(11,13),(2,11)],fill='#d5c7a5',outline='#796c52')
            d.line((4,5,11,7),fill='#9f967b');d.line((3,8,11,10),fill='#9f967b')
        elif name=='talisman_slot':
            d.polygon([(8,0),(15,8),(8,15),(0,8)],outline='#b49963',fill='#14242b')
            d.line([(4,9),(8,5),(11,7),(8,7),(8,12)],fill='#d7d4bd')
        elif name=='echo_memory':
            d.polygon([(8,1),(12,7),(8,14),(4,7)],fill='#456882',outline='#a1d7de')
            d.line((8,3,8,11),fill='#c3e5e7')
        elif name=='interaction_prompt':
            d.rectangle((1,2,14,13),fill='#14242b',outline='#b49963')
            d.line([(8,5),(8,10),(5,8)],fill='#ede2c7')
        else:
            d.line([(4,12),(8,8),(12,4)],fill='#b49963')
            for x,y in [(4,12),(8,8),(12,4)]:d.rectangle((x-1,y-1,x+1,y+1),fill='#dfcc96')
        save(name,im)
    (OUT/'production_manifest.json').write_text(json.dumps({'status':'TEMPORARY','source':'Original pixel geometry in tools/build_ui.py','assets':outputs},indent=2),encoding='utf-8')
    print('UI: separate frames, five bar strips and five icons')

if __name__=='__main__':build()
