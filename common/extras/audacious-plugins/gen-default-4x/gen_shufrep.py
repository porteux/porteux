import sys
sys.path.insert(0, __import__('os').path.dirname(__import__('os').path.abspath(__file__)))
from skinlib import *

s = load('shufrep')
sheet = smart_up(s)

LSCALE = 0.80
for y in (0, 15, 30, 45):
    draw_label(sheet, s, (5, y + 4, 20, y + 11), 'REP', bg_x=3,
               shadow_px=0, tol=90, cap_px=5, center_in=(0, 28),
               track_px=0.7)
    draw_label(sheet, s, (34, y + 4, 68, y + 11), 'RAND', bg_x=31,
               shadow_px=0, tol=90, cap_px=5, center_in=(28, 74),
               track_px=0.7)

GREY_TXT = (200, 200, 200)

def lamp_off(cx, cy):
    ov = Overlay(sheet)
    ov.ellipse(cx - 3.9, cy - 3.9, cx + 3.9, cy + 3.9, (168, 168, 168),
               outline=(55, 55, 55), ow=0.5)
    ov.apply()

def lamp_on(cx, cy):
    ov = Overlay(sheet)
    ov.ellipse(cx - 4.8, cy - 4.8, cx + 4.8, cy + 4.8, (45, 145, 250),
               outline=(10, 45, 90), ow=0.6)
    ov.apply()

for i, txt in enumerate(['EQ', 'PL', 'EQ', 'PL']):
    x0 = i * 23
    # off row (repair 1px past the sprite so smart_up's smear ring goes too)
    repair_bg(sheet, s, (x0, 61, x0 + 13, 74), bg_x=x0 + 21)
    lamp_off(x0 + 5.7, 66.8)
    draw_label(sheet, s, (x0 + 12, 64, x0 + 21, 71), txt, fill=GREY_TXT,
               shadow=(22, 22, 22), bg_x=x0 + 21, shadow_px=1, tol=70,
               cap_px=4, glyph_scale=LSCALE, track_px=0.8,
               center_in=(x0 + 11, x0 + 21))
    # on row
    repair_bg(sheet, s, (x0, 72, x0 + 13, 85), bg_x=x0 + 21)
    lamp_on(x0 + 5.5, 78.8)
    draw_label(sheet, s, (x0 + 12, 76, x0 + 21, 83), txt, fill=(235, 235, 235),
               shadow=(22, 22, 22), bg_x=x0 + 21, shadow_px=1, tol=70,
               cap_px=4, glyph_scale=LSCALE, track_px=0.8,
               center_in=(x0 + 11, x0 + 21))

save(sheet, 'shufrep')
