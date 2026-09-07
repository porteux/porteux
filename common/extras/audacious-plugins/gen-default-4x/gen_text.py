import sys
sys.path.insert(0, __import__('os').path.dirname(__import__('os').path.abspath(__file__)))
from skinlib import *

# Bitmap font sheet used for the song title.  The original is hand-drawn
# 4x6 pixel art; upscaling those letterforms looks crude at 4K, so the
# glyphs are re-rendered from the font at the original cap height and
# baseline, one per 5x6 cell.
t = load('text')
ink = max((t.getpixel((x, y)) for x in range(t.width) for y in range(6)),
          key=lambda c: c[2])
CW, CH = 5 * R, 6 * R
sheet = Image.new('RGB', (155 * R, 18 * R), (0, 0, 0))

ROWS = [
    [(i, ch) for i, ch in enumerate('ABCDEFGHIJKLMNOPQRSTUVWXYZ')] +
    [(26, '"'), (27, '@')],
    [(i, ch) for i, ch in enumerate('0123456789')] +
    [(10, '…'), (11, '.'),
     (12, ':'), (13, '('), (14, ')'), (15, '-'), (16, "'"), (17, '!'),
     (18, '_'), (19, '+'), (20, '\\'), (21, '/'), (22, '['), (23, ']'),
     (24, '^'), (25, '&'), (26, '%'), (27, '.'), (28, '='), (29, '$'),
     (30, '#')],
    [(0, 'å'), (1, 'ö'), (2, 'ä'), (3, '?'), (4, '*')],
]

# cap box of the original 'A' fixes the size and baseline
abox, _ = find_ink(t, (0, 0, 5, 6), tol=60)
cap_top = abox[1] if abox else 0
cap_h = (abox[3] - abox[1] + 1) if abox else 5
size = fit_font('A', cap_h * R)
f = get_font(size)
bA = f.getbbox('A')

for row, cells in enumerate(ROWS):
    for col, ch in cells:
        b = f.getbbox(ch)
        gw = b[2] - b[0]
        sq = min(1.0, (CW - R) / gw) if gw else 1.0
        tile, padx, pady = render_char(ch, size, sq)
        # keep descenders and tall punctuation inside the cell
        ink_h = b[3] - bA[1]
        allowed = CH - cap_top * R - 2
        vf = 1.0
        if ink_h > allowed:
            vf = allowed / ink_h
            tile = tile.resize((tile.width, max(1, int(tile.height * vf))),
                               Image.LANCZOS)
        cell = Image.new('L', (CW, CH), 0)
        cell.paste(tile, (int(CW / 2 - tile.width / 2),
                          int(cap_top * R - pady * vf)))
        sheet.paste(Image.new('RGB', (CW, CH), ink), (col * CW, row * CH),
                    cell)

save(sheet, 'text')
