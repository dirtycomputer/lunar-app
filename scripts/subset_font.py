"""Build the offline chart font from upstream Noto Sans SC (OFL-1.1).
Usage: PYTHONPATH=/path/to/fonttools python3 scripts/subset_font.py upstream.ttf lunar_package_dir
Includes Chinese characters from app and pinned calculation-engine sources.
"""
import pathlib
import sys
from fontTools.ttLib import TTFont
from fontTools.varLib.instancer import instantiateVariableFont
from fontTools.subset import Options, Subsetter
root = pathlib.Path(__file__).resolve().parent.parent
paths = (list((root / 'lib').rglob('*.dart')) +
         list((root / 'lib' / 'l10n').glob('*.arb')) +
         list(pathlib.Path(sys.argv[2]).rglob('*.dart')))
characters = set(''.join(p.read_text() for p in paths))
characters.update(chr(i) for i in range(32, 127))
font = instantiateVariableFont(TTFont(sys.argv[1]), {'wght': 400}, inplace=True)
options = Options()
options.name_IDs = ['*']
subsetter = Subsetter(options=options)
subsetter.populate(text=''.join(characters))
subsetter.subset(font)
font.save(root / 'assets/fonts/NotoSansSC-Chart.ttf')
print(f'Chart font written with {len(characters)} requested characters.')
