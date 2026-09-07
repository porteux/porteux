import sys
sys.path.insert(0, __import__('os').path.dirname(__import__('os').path.abspath(__file__)))
from skinlib import *
from skinlib import _diff

e = load('eq_ex')
sheet = smart_up(e)
smooth_track_highlight(sheet, e)
W = (252, 252, 252)
SHADOW = (42, 42, 42)

# BALANCE uses VOLUME's letterform width: size its span so the per-glyph
# squeeze equals VOLUME's, ending at x=243
fsz = fit_font('A', 6 * R)
fnt = get_font(fsz)
wsB = sum(fnt.getbbox(c)[2] - fnt.getbbox(c)[0] for c in 'BALANCE')
wsV = sum(fnt.getbbox(c)[2] - fnt.getbbox(c)[0] for c in 'VOLUME')
sqV = min(1.0, (38 * R - 5 * R) / wsV)
spanB = (wsB * sqV + 6 * R) / R

for sy in (0, 15):
    # VOLUME starts at x=18, aligned with AUDACIOUS in the main shaded bar
    draw_label(sheet, e, (17, sy + 3, 59, sy + 11), 'VOLUME', fill=W,
               shadow=SHADOW, bg_x=16, shadow_px=1, tol=90, cap_px=6,
               center_in=(18, 56))
    # bake track extensions into the strip: left to keep the 4px text gap,
    # right to align the track end with the LCD box end (x=163.75)
    tcol = [e.getpixel((100, sy + row)) for row in range(3, 12)]
    smooth_vfill(sheet, int(59.25 * R), 62 * R, sy + 3, tcol)
    smooth_vfill(sheet, int(157.5 * R), int(163.75 * R), sy + 3, tcol)
    # ramp the highlight pair (rows +7/+8) in the baked extensions like
    # smooth_track_highlight does for the rest of the track
    pair = [tcol[4], tcol[5]]
    smooth_vfill(sheet, int(59.25 * R), 62 * R, sy + 7, pair, step_tol=999)
    smooth_vfill(sheet, int(157.5 * R), int(163.75 * R), sy + 7, pair,
                 step_tol=999)
    # ink ends at x 241 (measured: main posbar black ends at 241.4);
    # repair pad erases the track back to ~197, keeping a ~3.5px gap
    # text AA-edge ends at 241.5; track 172.25..196.75 keeps the knob
    # center (184.5) and a 4.0px gap to the text, same as the VOLUME side
    draw_label(sheet, e, (198, sy + 3, 251, sy + 11), 'BALANCE', fill=W,
               shadow=SHADOW, bg_x=206, shadow_px=1, tol=90, cap_px=6,
               span_px=spanB, center_in=(242.5 - spanB, 242.5))
    colors = [e.getpixel((206, sy + row)) for row in range(3, 12)]
    smooth_vfill(sheet, int(163.75 * R), int(172.25 * R), sy + 3, colors)
    # right glyphs: shade down-triangle (254,3) + baked close X (264,3)
    ov = Overlay(sheet)
    repair_bg(sheet, e, (252, sy + 3, 274, sy + 12), bg_x=251)
    std_tri_down(ov, 254, sy + 3, W)
    glyph_x(ov, (265, sy + 4, 271, sy + 10), W)
    ov.apply()

# shaded-EQ button sprites, all with white glyphs:
#   (1,38) shade pressed (up), (1,47) shade pressed (down),
#   (11,38) close normal (grey titlebar face), (11,47) close pressed (blue)
# The blue cells have a 1px light-blue border around a gradient face, so
# only the face is repainted -- including the border in the sample would
# pull the per-row median towards the border colour.
ov = Overlay(sheet)
for cx, cy in ((1, 38), (1, 47), (11, 47)):
    repair_bg(sheet, e, (cx + 1, cy + 1, cx + 8, cy + 8), max_lum=150)
repair_bg(sheet, e, (11, 38, 20, 47), max_lum=150)

std_tri_up(ov, 1, 38, W)
std_tri_down(ov, 1, 47, W)
glyph_x(ov, (12, 39, 18, 45), W)
glyph_x(ov, (12, 48, 18, 54), W)
ov.apply()

# the original strip lacks the bright right border column that the main
# and playlist shaded bars have (invisible at 1x, obvious at 4K)
dbr = ImageDraw.Draw(sheet)
for sy in (0, 15):
    dbr.rectangle([274 * R, sy * R, 275 * R - 1, (sy + 14) * R - 1],
                  fill=(89, 89, 89))

save(sheet, 'eq_ex')
