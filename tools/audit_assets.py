"""Inventory runtime assets without changing them. Run from any directory."""
from pathlib import Path
import hashlib
import json
import wave
from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parents[1]
ASSETS = ROOT / 'game/assets'

def main():
    records = []
    images = []
    for path in sorted(ASSETS.rglob('*')):
        if not path.is_file() or path.suffix == '.import':
            continue
        item = dict(file=path.relative_to(ASSETS).as_posix(), bytes=path.stat().st_size,
                    sha256=hashlib.sha256(path.read_bytes()).hexdigest())
        if path.suffix == '.png':
            im = Image.open(path).convert('RGBA')
            alpha = im.getchannel('A')
            item.update(size=list(im.size), alpha_range=list(alpha.getextrema()),
                        transparent_pixels=alpha.histogram()[0], colors=len(set(im.getdata())))
            images.append((item['file'], im.copy()))
        elif path.suffix == '.wav':
            with wave.open(str(path)) as wav:
                item.update(rate=wav.getframerate(), channels=wav.getnchannels(),
                            bits=wav.getsampwidth()*8, seconds=round(wav.getnframes()/wav.getframerate(),3))
        records.append(item)
    out = ROOT / 'tools/local'
    out.mkdir(parents=True, exist_ok=True)
    (out/'asset-inventory.json').write_text(json.dumps(records, indent=2), encoding='utf-8')
    sheet = Image.new('RGB', (960, len(images)*132), '#66716c')
    d = ImageDraw.Draw(sheet)
    for i, (name, im) in enumerate(images):
        d.text((8, i*132+4), name, fill='white')
        im.thumbnail((944,104), Image.Resampling.NEAREST)
        sheet.paste(im,(8,i*132+24),im)
    sheet.save(out/'asset-contact.png')
    print(json.dumps(records, indent=2))

if __name__ == '__main__':
    main()
