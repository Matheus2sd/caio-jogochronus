"""Read official DOCX text without modifying originals (Python stdlib only)."""
from pathlib import Path
import sys
import zipfile
import xml.etree.ElementTree as ET

ROOT = Path(__file__).resolve().parents[1]
for path in sorted((ROOT / 'docs').glob('*.docx')):
    if len(sys.argv) > 1 and not any(s.lower() in path.name.lower() for s in sys.argv[1:]):
        continue
    print('\n### ' + path.name)
    with zipfile.ZipFile(path) as archive:
        root = ET.fromstring(archive.read('word/document.xml'))
    ns = {'w': 'http://schemas.openxmlformats.org/wordprocessingml/2006/main'}
    for paragraph in root.findall('.//w:p', ns):
        print(''.join(t.text or '' for t in paragraph.findall('.//w:t', ns)))
