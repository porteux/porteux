import sys
sys.path.insert(0, __import__('os').path.dirname(__import__('os').path.abspath(__file__)))
from skinlib import *

cb = load('cbuttons')
sheet = smart_up(cb)

INK = (238, 238, 237)


def tri(ov, apex_x, base_x, cy, h, fill=INK):
    ov.poly([(apex_x, cy), (base_x, cy - h / 2), (base_x, cy + h / 2)], fill)


def glyphs(ov, dy):
    cy = 9.5 + dy
    tri(ov, 7.0, 11.6, cy, 6.4)    # prev «
    tri(ov, 11.6, 16.2, cy, 6.4)
    tri(ov, 38.6, 32.0, cy, 7.4)
    ov.rect(55.0, cy - 3.2, 57.4, cy + 3.2, INK)
    ov.rect(58.6, cy - 3.2, 61.0, cy + 3.2, INK)
    ov.rect(78.2, cy - 3.1, 84.4, cy + 3.1, INK)
    tri(ov, 102.6, 98.0, cy, 6.4)  # next »
    tri(ov, 107.2, 102.6, cy, 6.4)


def eject(ov, dy):
    ov.poly([(124.8, 3.6 + dy), (128.8, 9.0 + dy), (120.8, 9.0 + dy)], INK)
    ov.rect(121.0, 10.2 + dy, 128.6, 11.6 + dy, INK)


for x0, x1, bgx in [(6, 18, 3), (31, 39, 27), (54, 62, 50), (77, 85, 73),
                    (97, 108, 93)]:
    for dy in (0, 18):
        repair_bg(sheet, cb, (x0, 4 + dy, x1, 14 + dy), bg_x=bgx)
for dy in (0, 16):
    repair_bg(sheet, cb, (119, 3 + dy, 131, 13 + dy), bg_x=116)

ov = Overlay(sheet)
glyphs(ov, 0)
glyphs(ov, 18)
eject(ov, 0)
eject(ov, 16)
ov.apply()

save(sheet, 'cbuttons')
