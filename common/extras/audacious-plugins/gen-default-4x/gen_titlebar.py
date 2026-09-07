import sys
sys.path.insert(0, __import__('os').path.dirname(__import__('os').path.abspath(__file__)))
from skinlib import *

tb = load('titlebar')
sheet = smart_up(tb)
smooth_track_highlight(sheet, tb)

W = (252, 252, 252)
SHADOW = (42, 42, 42)
BLUE = (35, 152, 254)


# unshaded titlebars: centered in the 275px window, like PLAYLIST;
# shaded bars keep the left position (LCD box occupies the middle)
for sy in (0, 15):
    draw_label(sheet, tb, (43, sy + 3, 104, sy + 11), 'AUDACIOUS', fill=W,
               shadow=SHADOW, bg_x=41, shadow_px=1, tol=90, cap_px=6,
               center_in=(27, 27 + 275))
for sy in (29, 42):
    draw_label(sheet, tb, (43, sy + 3, 104, sy + 11), 'AUDACIOUS', fill=W,
               shadow=SHADOW, bg_x=41, shadow_px=1, tol=90, cap_px=6)


def ball(x, y):
    # cell bg is a vertical gradient; middle rows are covered by the ball,
    # so interpolate between the (clean) top and bottom row backgrounds
    top = row_bg(tb, (x, y, x + 9, y + 1), max_lum=110)[0]
    bot = row_bg(tb, (x, y + 8, x + 9, y + 9), max_lum=110)[0]
    colors = [tuple(int(top[k] + (bot[k] - top[k]) * i / 8.0) for k in range(3))
              for i in range(9)]
    smooth_vfill(sheet, x * R, (x + 9) * R, y, colors)
    logo = render_logo(9 * R - 6)
    sheet.paste(logo, (x * R + 3, y * R + 3), logo)

for x, y in ((0, 0), (0, 9)):
    ball(x, y)

ov = Overlay(sheet)
for dy in (0, 9):   # minimize bar rows 6..7
    repair_bg(sheet, tb, (10, 4 + dy, 17, 8 + dy), max_lum=150)
    ov.rect(10.0, 6.0 + dy, 17.0, 8.0 + dy, W)
for dy in (0, 9):   # close X rows 1..7, cols 19..25
    repair_bg(sheet, tb, (19, 1 + dy, 26, 8 + dy), max_lum=150)
    c = (22.5, 4.5 + dy)
    ov.line([(c[0] - 3.1, c[1] - 3.1), (c[0] + 3.1, c[1] + 3.1)], W, 1.15)
    ov.line([(c[0] - 3.1, c[1] + 3.1), (c[0] + 3.1, c[1] - 3.1)], W, 1.15)
# shade up-triangles: apex (x+4.5, 21.7), base row 26, cols x+1..x+8
for dx in (0, 9):
    repair_bg(sheet, tb, (dx + 1, 20, dx + 8, 27), max_lum=150)
    ov.poly([(dx + 4.5, 21.7), (dx + 1.0, 26.0), (dx + 8.0, 26.0)], W)
# down-triangles: base row 31, apex (x+4.5, 35.3)
for dx in (0, 9):
    repair_bg(sheet, tb, (dx + 1, 30, dx + 8, 36), max_lum=150)
    ov.poly([(dx + 1.0, 31.0), (dx + 8.0, 31.0), (dx + 4.5, 35.3)], W)
ov.apply()


def shaded(sy):
    o = sy - 29   # rows measured at sy=29
    repair_bg(sheet, tb, (195, sy + 4, 251, sy + 12), bg_x=203)
    repair_bg(sheet, tb, (271, sy + 4, 300, sy + 12), bg_x=280)
    ov = Overlay(sheet)
    # srew: bar col 196, left tri apex (197.4, 36.5), base col 201, rows 33..40
    ov.rect(196.0, 33.0 + o, 197.2, 40.0 + o, W)
    ov.poly([(197.4, 36.5 + o), (201.0, 33.0 + o), (201.0, 40.0 + o)], W)
    # splay: right tri base col 206, apex (210, 36.5)
    ov.poly([(206.0, 33.0 + o), (210.0, 36.5 + o), (206.0, 40.0 + o)], W)
    # spause
    ov.rect(215.0, 34.0 + o, 217.0, 39.0 + o, W)
    ov.rect(219.0, 34.0 + o, 221.0, 39.0 + o, W)
    # sstop
    ov.rect(225.0, 34.0 + o, 230.0, 39.0 + o, W)
    # sfwd: right tri base col 234, apex (237.8, 36.5); bar col 238
    ov.poly([(234.0, 33.0 + o), (237.8, 36.5 + o), (234.0, 40.0 + o)], W)
    ov.rect(238.0, 33.0 + o, 239.2, 40.0 + o, W)
    # seject: up tri apex (246.5, 34), base row 37.8 cols 243..250; bar row 39
    ov.poly([(246.5, 34.0 + o), (250.0, 37.8 + o), (243.0, 37.8 + o)], W)
    ov.rect(243.0, 39.0 + o, 250.0, 40.2 + o, W)
    # right side: min bar rows 38..40 cols 272..279
    ov.rect(272.0, 38.0 + o, 279.0, 40.0 + o, W)
    # shade down tri base row 36 cols 282..289, apex (285.5, 40)
    ov.poly([(282.0, 36.0 + o), (289.0, 36.0 + o), (285.5, 40.0 + o)], W)
    # close X rows 33..39 cols 292..298
    c = (295.5, 36.5 + o)
    ov.line([(c[0] - 3.1, c[1] - 3.1), (c[0] + 3.1, c[1] + 3.1)], W, 1.15)
    ov.line([(c[0] - 3.1, c[1] + 3.1), (c[0] + 3.1, c[1] - 3.1)], W, 1.15)
    ov.apply()
    # LCD colon: exact 2x1 px dots at (171..172, 35) and (171..172, 37)
    d = ImageDraw.Draw(sheet)
    for yy in (35, 37):
        d.rectangle([171 * R, (yy + o) * R, 173 * R - 1, (yy + o + 1) * R - 1],
                    fill=BLUE)

shaded(29)
shaded(42)

# extend the mini posbar by 1px baked into the strip (widget is 17px wide
# ending at window x 242; playlist/EQ content ends at 243)
for sy in (29, 42):
    colors = [tb.getpixel((16, 36 + row)) for row in range(7)]
    smooth_vfill(sheet, 270 * R, 271 * R, sy + 4, colors)

# The original letters are square pixel forms (serifed I, squared V), so
# they are drawn geometrically rather than with the font; each pressed
# tile is a diagonally-lit bevel reconstructed with smooth ramps.
CB_BLUE = (26, 132, 225)
CB_BG = (45, 45, 45)
dcb = ImageDraw.Draw(sheet)
starts = [3, 11, 19, 27, 34]


def cb_letter(ov, ch, lx, ly, c, bg):
    if ch == 'O':
        ov.rrect(lx, ly, lx + 4, ly + 6, 1.4, None, outline=c, ow=1.0)
    elif ch == 'A':
        # arch whose bottom bar is the crossbar, straight legs below
        ov.rrect(lx, ly, lx + 4, ly + 4, 1.4, None, outline=c, ow=1.0)
        ov.rect(lx, ly + 2, lx + 1, ly + 6, c)
        ov.rect(lx + 3, ly + 2, lx + 4, ly + 6, c)
    elif ch == 'I':
        ov.rect(lx + 0.5, ly, lx + 3.5, ly + 1, c)
        ov.rect(lx + 1.5, ly + 0.5, lx + 2.5, ly + 5.5, c)
        ov.rect(lx + 0.5, ly + 5, lx + 3.5, ly + 6, c)
    elif ch == 'D':
        ov.rrect(lx, ly, lx + 4, ly + 6, 1.2, None, outline=c, ow=1.0)
        ov.rect(lx, ly, lx + 1, ly + 6, c)
    elif ch == 'V':
        ov.poly([(lx, ly), (lx + 1, ly), (lx + 2.5, ly + 6),
                 (lx + 1.5, ly + 6)], c)
        ov.poly([(lx + 3, ly), (lx + 4, ly), (lx + 2.5, ly + 6),
                 (lx + 1.5, ly + 6)], c)


ovcb = Overlay(sheet)
# normal column (304,0,8x43): flat black, blue letters
dcb.rectangle([304 * R, 0, 312 * R - 1, 43 * R - 1], fill=(8, 8, 8))
for i, ch in enumerate('OAIDV'):
    cb_letter(ovcb, ch, 306, starts[i], CB_BLUE, (8, 8, 8))
# pressed tiles (304+8k,44,8x43)
for k in range(5):
    x0 = 304 + 8 * k
    dcb.rectangle([(x0 + 1) * R, 45 * R, (x0 + 7) * R - 1, 85 * R - 1],
                  fill=CB_BG)
    smooth_vfill(sheet, x0 * R, (x0 + 1) * R, 44,
                 [tb.getpixel((x0, y)) for y in range(44, 87)], step_tol=999)
    smooth_vfill(sheet, (x0 + 7) * R, (x0 + 8) * R, 44,
                 [tb.getpixel((x0 + 7, y)) for y in range(44, 87)],
                 step_tol=999)
    smooth_hfill(sheet, 44 * R, 45 * R, x0,
                 [tb.getpixel((x, 44)) for x in range(x0, x0 + 8)],
                 step_tol=999)
    for ry in (85, 86):
        smooth_hfill(sheet, ry * R, (ry + 1) * R, x0,
                     [tb.getpixel((x, ry)) for x in range(x0, x0 + 8)],
                     step_tol=999)
    for i, ch in enumerate('OAIDV'):
        col = (255, 255, 255) if i == k else CB_BLUE
        cb_letter(ovcb, ch, x0 + 2, 44 + starts[i], col, CB_BG)
ovcb.apply()

save(sheet, 'titlebar')
