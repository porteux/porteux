import sys
sys.path.insert(0, __import__('os').path.dirname(__import__('os').path.abspath(__file__)))
from skinlib import *

BLUE = (35, 152, 254)

m = load('main')
sheet = smart_up(m)
repair_bg(sheet, m, (244, 85, 272, 111), bg_x=240)
logo = render_logo(21 * R)
sheet.paste(logo, (247 * R, int(87.5 * R)), logo)
d = ImageDraw.Draw(sheet)
for yy in (29, 35):
    d.rectangle([65 * R, yy * R, 67 * R - 1, (yy + 2) * R - 1], fill=m.getpixel((65, 29)))
save(sheet, 'main')

pp = load('playpaus')
sheet = smart_up(pp)
bright = pp.getpixel((5, 4))
dim = pp.getpixel((37, 6))
dimmer = pp.getpixel((40, 6))
for reg in [(2, 0, 9, 9), (10, 0, 17, 9), (18, 0, 27, 9), (36, 0, 42, 9)]:
    repair_bg(sheet, pp, reg, bg_x=30)
ov = Overlay(sheet)
ov.poly([(3.2, 0.6), (8.4, 4.5), (3.2, 8.4)], bright)
ov.rect(10.9, 1.9, 13.0, 7.1, bright)
ov.rect(14.0, 1.9, 16.1, 7.1, bright)
ov.rect(19.75, 1.9, 25.25, 7.1, bright)
ov.rect(36.0, 1.0, 39.0, 4.0, bright)
ov.rect(39.0, 1.0, 42.0, 4.0, dim)
ov.rect(36.0, 5.0, 39.0, 8.0, dim)
ov.rect(39.0, 5.0, 42.0, 8.0, dimmer)
ov.apply()
save(sheet, 'playpaus')

pb = load('posbar')
sheet = smart_up(pb)
smooth_track_highlight(sheet, pb)
# knobs at x248 (normal) and x278 (pressed): crisp 1px border, interior
# resampled bilinearly (2D gradient + inner vignette)
dpb = ImageDraw.Draw(sheet)
for x0, border in ((248, (81, 81, 81)), (278, (40, 125, 212))):
    dpb.rectangle([x0 * R, 1 * R, (x0 + 29) * R - 1, 8 * R - 1], fill=border)
    body = pb.crop((x0 + 1, 2, x0 + 28, 7))
    sheet.paste(body.resize((27 * R, 5 * R), Image.BILINEAR),
                ((x0 + 1) * R, 2 * R))
save(sheet, 'posbar')

v = load('volume')
sheet = smart_up(v)
smooth_track_highlight(sheet, v)
d = ImageDraw.Draw(sheet)
d.rectangle([0, 422 * R, 29 * R - 1, 433 * R - 1], fill=(0, 0, 0))

def vknob(x0, border, steps):
    for xx in (x0 - 1, x0 + 12):
        smooth_vfill(sheet, xx * R, (xx + 1) * R, 427,
                     [(59, 59, 59), (31, 31, 31)], step_tol=999)
    bw, ih = 12 * R, 5 * R
    grad = Image.new('RGB', (bw, ih + 2 * R), border)
    gd = ImageDraw.Draw(grad)
    # piecewise-linear through the original interior row colors
    for yy in range(ih):
        pos = yy / (ih - 1) * (len(steps) - 1)
        k = min(int(pos), len(steps) - 2)
        t = pos - k
        c = tuple(int(steps[k][i] + (steps[k + 1][i] - steps[k][i]) * t)
                  for i in range(3))
        gd.line([(R, yy + R), (bw - R - 1, yy + R)], fill=c)
    sheet.paste(grad, (x0 * R, 424 * R))

vknob(16, (81, 81, 81),
      [(63,) * 3, (56,) * 3, (52,) * 3, (12,) * 3, (0,) * 3])
vknob(1, (40, 119, 208),
      [(12, 94, 185), (12, 89, 180), (14, 79, 174), (9, 63, 154),
       (9, 62, 151)])
save(sheet, 'volume')

# STEREO/MONO indicators: dark text on the bright blue face when lit,
# dim blue text on black when unlit.  The face is sampled from a clean
# column inside each panel (bg_x) -- letting row_bg pick the background
# by luminance inverts these panels, since here the ink is the dark part.
mo = load('monoster')
sheet = smart_up(mo)
LIT_INK = (7, 34, 42)
UNLIT_INK = (10, 18, 26)
# The original indicators use a fixed-width pixel font, so fitting each
# word to its own box would squeeze MONO (wide M/O) far more than STEREO.
# Both get one letter scale -- taken from STEREO, which fills its box --
# and are centred in their panel.
_f5 = get_font(fit_font('A', 5 * R))
_natw = lambda s: sum(_f5.getbbox(c)[2] - _f5.getbbox(c)[0] for c in s) / R
SCALE = 23.0 / _natw('STEREO')
# one common tracking, solved from STEREO's span, so MONO's narrower
# original span cannot pack its letters together
_advs = [_f5.getlength(c) for c in 'STEREO']
_bbs = [_f5.getbbox(c) for c in 'STEREO']
_span0 = (sum(_advs[:-1]) + _bbs[-1][2] - _bbs[0][0]) * SCALE
TRACK = (23 * R - _span0) / 5 / R
for text, tx0, tx1, facex in (('STEREO', 3, 26, 2), ('MONO', 37, 52, 35)):
    for ty, ink, tol in ((3, LIT_INK, 25), (15, UNLIT_INK, 6)):
        draw_label(sheet, mo, (tx0, ty, tx1, ty + 5), text, fill=ink,
                   bg_x=facex, tol=tol, shadow_px=0, cap_px=5,
                   glyph_scale=SCALE, center_in=(tx0, tx1), track_px=TRACK)
save(sheet, 'monoster')

# Redrawn as true 7-segment shapes (bevelled segment ends), which is the
# design the original pixel digits approximate.
n = load('nums_ex')
sheet = smart_up(n)
ink = max((n.getpixel((x, y)) for x in range(n.width) for y in range(n.height)),
          key=lambda c: c[2])
d = ImageDraw.Draw(sheet)
d.rectangle([0, 0, sheet.width - 1, sheet.height - 1], fill=(0, 0, 0))

SEGS = {'0': 'ABCDEF', '1': 'BC', '2': 'ABGED', '3': 'ABGCD', '4': 'FGBC',
        '5': 'AFGCD', '6': 'AFGEDC', '7': 'ABC', '8': 'ABCDEFG',
        '9': 'ABCFGD', '-': 'G'}

XL, XR = 1.1, 7.9      # vertical segment centres
YT, YM, YB = 0.9, 6.5, 12.1
T = 1.0                # half thickness
GAP = 0.28


def hseg(ov, x0, cy, x1, fill):
    a, b = x0 + GAP, x1 - GAP
    ov.poly([(a, cy), (a + T, cy - T), (b - T, cy - T), (b, cy),
             (b - T, cy + T), (a + T, cy + T)], fill)


def vseg(ov, cx, y0, y1, fill):
    a, b = y0 + GAP, y1 - GAP
    ov.poly([(cx, a), (cx + T, a + T), (cx + T, b - T), (cx, b),
             (cx - T, b - T), (cx - T, a + T)], fill)


ov = Overlay(sheet)
for i, ch in enumerate('0123456789 -'):
    if ch == ' ':
        continue
    ox = i * 9
    s = SEGS[ch]
    if 'A' in s: hseg(ov, ox + XL, YT, ox + XR, ink)
    if 'G' in s: hseg(ov, ox + XL, YM, ox + XR, ink)
    if 'D' in s: hseg(ov, ox + XL, YB, ox + XR, ink)
    if 'F' in s: vseg(ov, ox + XL, YT, YM, ink)
    if 'B' in s: vseg(ov, ox + XR, YT, YM, ink)
    if 'E' in s: vseg(ov, ox + XL, YM, YB, ink)
    if 'C' in s: vseg(ov, ox + XR, YM, YB, ink)
ov.apply()
save(sheet, 'nums_ex')
