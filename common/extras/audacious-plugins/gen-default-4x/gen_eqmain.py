import sys
sys.path.insert(0, __import__('os').path.dirname(__import__('os').path.abspath(__file__)))
from skinlib import *

e = load('eqmain')
sheet = smart_up(e)
W = (252, 252, 252)
SHADOW = (42, 42, 42)

# slider track columns (59|31 pairs) get the same smooth cross ramp as
# the eq_ex track highlight
for x in range(e.width - 1):
    run = 0
    for y in range(e.height + 1):
        pair = (y < e.height and e.getpixel((x, y))[0] == 59
                and e.getpixel((x + 1, y))[0] == 31)
        if pair:
            run += 1
        else:
            if run >= 1:
                smooth_hfill(sheet, (y - run) * R, y * R, x,
                             [(59, 59, 59), (31, 31, 31)], step_tol=999)
            run = 0

# protect EQ graph area + spline color strip (pixel-sampled by the code)
crop = e.crop((0, 290, 120, 315)).resize((120 * R, 25 * R), Image.NEAREST)
sheet.paste(crop, (0, 290 * R))

# preamp line texture (row 314): crisp round dots instead of square pixels
d = ImageDraw.Draw(sheet)
d.rectangle([0, 314 * R, 113 * R - 1, 315 * R - 1], fill=(0, 0, 0))
ov = Overlay(sheet)
for c in range(0, 113, 2):
    ov.ellipse(c + 0.05, 314.05, c + 0.95, 314.95, (0, 96, 192))
ov.apply()

for sy in (134, 149):
    draw_label(sheet, e, (16, sy + 3, 70, sy + 11), 'EQUALIZER', fill=W,
               shadow=SHADOW, bg_x=14, shadow_px=1, tol=90, cap_px=6,
               center_in=(0, 275))

def button_label(x0, y0, w, h, text):
    draw_label(sheet, e, (x0 + 2, y0 + 2, x0 + w - 2, y0 + h - 2), text,
               bg_x=x0 + 1, shadow_px=0, tol=90, cap_px=6,
               center_in=(x0, x0 + w))

for k in range(4):
    button_label(10 + 59 * k, 119, 25, 12, 'EQ')
    button_label(35 + 59 * k, 119, 33, 12, 'AUTO')
button_label(224, 164, 44, 12, 'PRESET')
button_label(224, 176, 44, 12, 'PRESET')

ov = Overlay(sheet)
repair_bg(sheet, e, (0, 116, 9, 125), max_lum=bg_lum(e, (0, 116, 9, 125)) + 25)
glyph_x(ov, (1, 117, 7, 123), W)
repair_bg(sheet, e, (1, 126, 8, 133), max_lum=150)
glyph_x(ov, (1, 126, 7, 132), W)

# keep the glyphs strictly inside the 9x9 button rects at (254,+3) and (264,+3)
for sy in (134, 149):
    o = sy - 134
    repair_bg(sheet, e, (252, sy + 3, 273, sy + 12), bg_x=250)
    std_tri_up(ov, 254, sy + 3, W)
    glyph_x(ov, (265, 138 + o, 271, 144 + o), W)

ov.apply()

# original knobs fade horizontally from grey/blue (left) to black (right)
def knob(y0, left, right, edge_l, edge_r, edge_t, edge_b):
    d = ImageDraw.Draw(sheet)
    d.rectangle([0, y0 * R, 11 * R - 1, (y0 + 11) * R - 1], fill=(0, 0, 0))
    # slider track stub above/below the body (cols 5-6), smooth cross ramp
    smooth_hfill(sheet, y0 * R, (y0 + 11) * R, 5,
                 [(59, 59, 59), (31, 31, 31)], step_tol=999)
    # body: cols 1..10, rows +2..+8, 1px border on all sides
    bw, bh = 10 * R, 7 * R
    grad = Image.new('RGB', (bw, bh))
    gd = ImageDraw.Draw(grad)
    for x in range(bw):
        t = x / (bw - 1)
        gd.line([(x, 0), (x, bh)],
                fill=tuple(int(left[i] + (right[i] - left[i]) * t)
                           for i in range(3)))
    gd.rectangle([0, 0, bw - 1, R - 1], fill=edge_t)
    gd.rectangle([0, bh - R, bw - 1, bh - 1], fill=edge_b)
    gd.rectangle([0, 0, R - 1, bh - 1], fill=edge_l)
    gd.rectangle([bw - R, 0, bw - 1, bh - 1], fill=edge_r)
    sheet.paste(grad, (1 * R, (y0 + 2) * R))

knob(164, (78, 78, 78), (6, 6, 6), (70, 70, 70), (61, 61, 61),
     (70, 70, 70), (66, 66, 66))
B = (40, 125, 212)
knob(176, (10, 110, 202), (6, 58, 148), B, B, B, B)

save(sheet, 'eqmain', protect=[(0, 290, 120, 315)])
