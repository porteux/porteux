import sys
sys.path.insert(0, __import__('os').path.dirname(__import__('os').path.abspath(__file__)))
from skinlib import *
from skinlib import _diff

p = load('pledit')
sheet = smart_up(p)
W = (252, 252, 252)
SHADOW = (42, 42, 42)
BLUE = p.getpixel((20, 88))

for sy in (0, 21):
    draw_label(sheet, p, (30, sy + 3, 120, sy + 11), 'PLAYLIST', fill=W,
               shadow=SHADOW, bg_x=29, shadow_px=1, tol=90, cap_px=6,
               optical=True, gap_px=1.0)

def cell(x0, y0, kind, color=W, border=False):
    """border cells (pressed blue) keep their 1px light frame: repair and
    draw inside it only, X inset 1px like the original"""
    if border:
        # interior is two flat blue shades in symmetric halves; sample each
        # shade away from the white glyph
        def face_med(rows):
            px = [p.getpixel((x, row)) for row in rows
                  for x in range(x0 + 1, x0 + 8)]
            face = sorted(c for c in px if sum(c) / 3 < 150)
            return face[len(face) // 2]
        light = face_med(range(y0 + 1, y0 + 4))
        dark = face_med(range(y0 + 5, y0 + 8))
        db = ImageDraw.Draw(sheet)
        mid = int((y0 + 4.5) * R)
        db.rectangle([(x0 + 1) * R, (y0 + 1) * R, (x0 + 8) * R - 1,
                      mid - 1], fill=light)
        db.rectangle([(x0 + 1) * R, mid, (x0 + 8) * R - 1,
                      (y0 + 8) * R - 1], fill=dark)
        bbox = (x0 + 1, y0 + 1, x0 + 7, y0 + 7)
    else:
        reg = (x0, y0, x0 + 9, y0 + 9)
        bbox, ink = find_ink(p, reg, tol=90)
        repair_bg(sheet, p, reg, max_lum=150)
        if not bbox:
            return
    ov = Overlay(sheet)
    if kind == 'x':
        glyph_x(ov, bbox, color)
    elif kind == 'up':
        if border:
            ov.poly([(x0 + 4.5, y0 + 4.5), (x0 + 1.0, y0 + 8.0),
                     (x0 + 8.0, y0 + 8.0)], color)
        else:
            std_tri_up(ov, x0, y0, color)
    else:
        if border:
            ov.poly([(x0 + 1.0, y0 + 4.5), (x0 + 8.0, y0 + 4.5),
                     (x0 + 4.5, y0 + 8.0)], color)
        else:
            std_tri_down(ov, x0, y0, color)
    ov.apply()

cell(157, 3, 'up')        # shade normal
cell(167, 3, 'x')         # close normal
cell(157, 24, 'up')       # unfocused title baked glyphs
cell(167, 24, 'x')
cell(52, 42, 'x', border=True)    # close pressed (blue)
cell(62, 42, 'up', border=True)   # shade pressed
cell(150, 42, 'down', border=True)   # shaded-mode shade pressed
cell(128, 45, 'down')     # shaded-mode shade normal (baked in corner)
cell(138, 45, 'x')        # shaded-mode close normal
# unfocused right corner baked glyphs (same relative spots, +15 rows)
cell(128, 60, 'down')
cell(138, 60, 'x')

# shade bar: panel end at sprite col 116 = window x 242, flush with the
# shaded title textbox (patched width w-37 at x=4, black bg through x 241,
# matching the main window posbar's black end)
dgrey = ImageDraw.Draw(sheet)
for cy in (42, 57):
    colors = [p.getpixel((126, cy + row)) for row in range(1, 13)]
    smooth_vfill(sheet, 116 * R, 126 * R, cy + 1, colors)
    dgrey.rectangle([115 * R, (cy + 1) * R, 116 * R - 1,
                     (cy + 13) * R - 1], fill=(0, 0, 0))

dth = ImageDraw.Draw(sheet)
dth.rectangle([53 * R, 54 * R, 58 * R - 1, 70 * R - 1], fill=(83, 83, 83))
dth.rectangle([54 * R, 54 * R, 57 * R - 1, 55 * R - 1], fill=(81, 81, 81))
dth.rectangle([54 * R, 69 * R, 57 * R - 1, 70 * R - 1], fill=(81, 81, 81))
smooth_hfill(sheet, 55 * R, 69 * R, 54,
             [(63, 63, 63), (56, 56, 56), (52, 52, 52)])
dth.rectangle([62 * R, 54 * R, 67 * R - 1, 70 * R - 1], fill=(40, 125, 212))
smooth_vfill(sheet, 63 * R, 66 * R, 55,
             [p.getpixel((64, y)) for y in range(55, 69)])
# mini-slider knob at (177,52): one continuous highlight-to-shadow ramp
# (a flat 4x-wide 93 edge column reads as a low-res stripe)
smooth_hfill(sheet, 53 * R, 58 * R, 177,
             [(93,) * 3, (75,) * 3, (69,) * 3, (63,) * 3, (61,) * 3],
             step_tol=61)
smooth_hfill(sheet, 52 * R, 53 * R, 177,
             [(72,) * 3, (80,) * 3, (75,) * 3, (70,) * 3, (61,) * 3],
             step_tol=61)
dth.rectangle([177 * R, 58 * R, 182 * R - 1, 59 * R - 1], fill=(66, 66, 66))

# grid-area divider bars (122|78|42 cylinders with lit top cap and fading
# bottom): resample the whole 3px bar bilinearly so caps smooth too
for bx0 in (48, 100, 250):
    y1 = 111
    while y1 < p.height and p.getpixel((bx0, y1))[0] != 255:
        y1 += 1
    bar = p.crop((bx0, 111, bx0 + 3, y1))
    sheet.paste(bar.resize((3 * R, (y1 - 111) * R), Image.BILINEAR),
                (bx0 * R, 111 * R))

B = (40, 125, 212)
M = (12, 94, 185)
DK = (9, 63, 154)
GREY = (192, 192, 192)
dd = ImageDraw.Draw(sheet)

def rect4(x0, y0, x1, y1, c):
    dd.rectangle([int(x0 * R), int(y0 * R), int(x1 * R) - 1, int(y1 * R) - 1],
                 fill=c)

def grad4(x0, y0, x1, y1, horiz=False):
    """m->d gradient interior at 4x."""
    px0, py0, px1, py1 = int(x0 * R), int(y0 * R), int(x1 * R), int(y1 * R)
    n = (px1 - px0) if horiz else (py1 - py0)
    for i in range(n):
        t = i / max(1, n - 1)
        c = tuple(int(M[k] + (DK[k] - M[k]) * t) for k in range(3))
        if horiz:
            dd.rectangle([px0 + i, py0, px0 + i, py1 - 1], fill=c)
        else:
            dd.rectangle([px0, py0 + i, px1 - 1, py0 + i], fill=c)

# add (+): 1px B border, m interior with d inner-shadow (original bevel)
repair_bg(sheet, p, (17, 82, 33, 96), bg_x=16)
rect4(23, 83, 27, 95, B)
rect4(19, 87, 31, 91, B)
rect4(24, 84, 26, 94, M)
rect4(20, 88, 30, 90, M)
rect4(25, 84, 26, 94, DK)
rect4(20, 89, 30, 90, DK)
rect4(25, 88, 26, 89, M)
rect4(24, 89, 25, 90, M)
# sub (-): m top half, d bottom half
repair_bg(sheet, p, (45, 84, 61, 94), bg_x=44)
rect4(47, 87, 59, 91, B)
rect4(48, 88, 58, 89, M)
rect4(48, 89, 58, 90, DK)
# sel: white window icon, symmetric bands, wide blue rectangle
repair_bg(sheet, p, (75, 82, 92, 96), bg_x=74)
rect4(77, 83, 89, 95, (250, 250, 250))
rect4(78, 84, 88, 85, GREY)
rect4(78, 93, 88, 94, GREY)
rect4(78, 86, 88, 92, B)
rect4(79, 87, 87, 89, M)
rect4(79, 89, 87, 91, DK)
# misc: white box, four grey lines, blue down arrow from the 2nd line
repair_bg(sheet, p, (104, 82, 120, 96), bg_x=103)
rect4(106, 83, 118, 95, (250, 250, 250))
for gy_ in (84, 86, 88, 90):
    rect4(107, gy_, 117, gy_ + 1, GREY)
rect4(111, 86, 115, 90, B)
def bluex(x):
    t = min(1.0, max(0.0, (x - 112.0) / 2.0))
    return tuple(int(M[k] + (DK[k] - M[k]) * t) for k in range(3))
for i in range(112 * R, 114 * R):
    dd.rectangle([i, 87 * R, i, 90 * R - 1], fill=bluex((i + 0.5) / R))
# head: B-outlined triangle (109,90)-(117,90)-(113,94); interior is a
# smooth m->d ramp masked to the inner triangle
ovh = Overlay(sheet)
ovh.poly([(109.0, 90.0), (117.0, 90.0), (113.0, 94.0)], B)
ovh.apply()
w4, h4, SSk = 8 * R, 4 * R, 4
hm = Image.new('L', (w4 * SSk, h4 * SSk), 0)
hmd = ImageDraw.Draw(hm)
HP = lambda x, y: ((x - 109) * R * SSk, (y - 90) * R * SSk)
# uniform-width border: inset the 45-degree slants perpendicular by bw
bw = 0.8
sh = bw * 1.414
iy = 90.0 + bw
ax = 109.0 + (iy - 90.0) + sh
bx2 = 117.0 - (iy - 90.0) - sh
apy = 90.0 + (117.0 - 109.0 - 2 * sh) / 2
hmd.polygon([HP(ax, iy), HP(bx2, iy), HP(113.0, apy)], fill=255)
hmd.polygon([HP(112.0, 90.0), HP(114.0, 90.0), HP(114.0, iy + 0.2),
             HP(112.0, iy + 0.2)], fill=255)
hm = hm.resize((w4, h4), Image.LANCZOS)
hg = Image.new('RGB', (w4, h4))
hgd = ImageDraw.Draw(hg)
for i in range(w4):
    hgd.line([(i, 0), (i, h4)], fill=bluex(109 + (i + 0.5) / R))
sheet.paste(hg, (109 * R, 90 * R), hm)

o = 126
ov = Overlay(sheet)
repair_bg(sheet, p, (o + 5, 93, o + 60, 101), bg_x=o + 4)
gy = 94.0
cy = gy + 3.5
# geometry measured from the original ink columns (x absolute):
# prev: bar x132, left triangle base x137 apex x133; play: base x142
# apex x146; pause bars x151/x155 rows 95-99; stop x161-165 rows 95-99;
# next: base x170 apex x174, bar x174; eject: apex x182.5 rows 95-98,
# bar row 100 x179-185 (all inside the playlistwin button hit-boxes)
ov.rect(132.0, gy, 133.0, gy + 7.0, W)
ov.poly([(133.0, cy), (137.0, gy), (137.0, gy + 7.0)], W)
ov.poly([(142.0, gy), (146.0, cy), (142.0, gy + 7.0)], W)
ov.rect(151.0, gy + 1.0, 153.0, gy + 6.0, W)
ov.rect(155.0, gy + 1.0, 157.0, gy + 6.0, W)
ov.rect(161.0, gy + 1.0, 166.0, gy + 6.0, W)
ov.poly([(170.0, gy), (174.0, cy), (170.0, gy + 7.0)], W)
ov.rect(174.0, gy, 175.0, gy + 7.0, W)
ov.poly([(182.5, gy + 0.7), (186.0, gy + 5.0), (179.0, gy + 5.0)], W)
ov.rect(179.0, gy + 6.0, 186.0, gy + 7.0, W)
# time colon dots (blue 2x1 at rows 96 and 99, x209..210)
d = ImageDraw.Draw(sheet)
for yy in (96, 99):
    d.rectangle([209 * R, yy * R, 211 * R - 1, (yy + 1) * R - 1],
                fill=p.getpixel((209, 96)))
# list button '...' dots (face keeps its mid transition; bg from face col)
repair_bg(sheet, p, (o + 108, 84, o + 126, 94), bg_x=o + 108)
for k in range(3):
    x0 = o + 109 + k * 6
    rect4(x0, 87, x0 + 4, 91, B)
    rect4(x0 + 1, 88, x0 + 3, 89, M)
    rect4(x0 + 1, 89, x0 + 3, 90, DK)
# resize grip: 45-degree hatch, 4px pitch, clipped to x<=274, y<=108
repair_bg(sheet, p, (o + 132, 95, o + 149, 109), bg_x=o + 131)
GRIP = (153, 153, 152)
for c in (370, 374, 378):
    ax, ay = 274.5, c - 274 + 0.5        # topmost pixel center (x clamped)
    bx, by = c - 108 + 0.5, 108.5        # bottom-left pixel center
    e, h = 0.32, 0.45                    # cap extension, half thickness
    ax, ay, bx, by = ax + e, ay - e, bx - e, by + e
    ov.poly([(ax + h, ay + h), (bx + h, by + h),
             (bx - h, by - h), (ax - h, ay - h)], GRIP)
ov.rect(274.0, 108.0, 275.0, 109.0, GRIP)
ov.apply()

GROUPS = [
    [('+', 'URL'), ('+', 'DIR'), ('+', 'FILE'), None],
    [('-', 'ALL'), ('-', 'CROP'), ('-', 'FILE'), ('-', 'MiSC')],
    [('INV', 'SEL'), ('SEL', 'ZERO'), ('SEL', 'ALL'), None],
    [('SORT', 'LIST'), ('FILE', 'INF'), ('MiSC', 'OPT.'), None],
    [('NEW', 'LIST'), ('SAVE', 'LIST'), ('LOAD', 'LIST'), None],
]

from statistics import median as _median

def strict_ink(reg):
    """label bbox: threshold at face+28, then keep only connected blobs
    whose peak is near the region max -- drops the button bevel pixels,
    which are brighter than the face but dimmer than the ink"""
    x0, y0, x1, y1 = reg
    lums = {}
    for x in range(x0, x1):
        for y in range(y0, y1):
            c = p.getpixel((x, y))
            lums[(x, y)] = (c[0] + c[1] + c[2]) / 3
    face = _median(lums.values())
    maxl = max(lums.values())
    pts = {q for q, l in lums.items() if l > face + 28}
    if not pts:
        return None
    strong = face + 0.7 * (maxl - face)
    seen, keep = set(), []
    for start in pts:
        if start in seen:
            continue
        comp, stack = [], [start]
        seen.add(start)
        while stack:
            q = stack.pop()
            comp.append(q)
            for nb in ((q[0]+1,q[1]),(q[0]-1,q[1]),(q[0],q[1]+1),(q[0],q[1]-1)):
                if nb in pts and nb not in seen:
                    seen.add(nb)
                    stack.append(nb)
        if max(lums[q] for q in comp) >= strong:
            keep += comp
    if not keep:
        return None
    xs = [q[0] for q in keep]
    ys = [q[1] for q in keep]
    return (min(xs), min(ys), max(xs), max(ys))

def icon_or_label(reg, txt, tol):
    b = strict_ink(reg)
    if txt in ('+', '-'):
        _, ink = find_ink(p, reg, tol=tol)
        repair_bg(sheet, p, reg, max_lum=bg_lum(p, reg) + 25)
        if not b:
            return
        ovi = Overlay(sheet)
        cx, cy = (b[0] + b[2] + 1) / 2, (b[1] + b[3] + 1) / 2
        ovi.rect(cx - 2.5, cy - 0.5, cx + 2.5, cy + 0.5, ink)
        if txt == '+':
            ovi.rect(cx - 0.5, cy - 2.5, cx + 0.5, cy + 2.5, ink)
        ovi.apply()
    else:
        if not b:
            return
        span = b[2] - b[0] + 1
        f = get_font(fit_font('A', 5 * R))
        ws = sum(f.getbbox(c)[2] - f.getbbox(c)[0] for c in txt)
        sq = (span - (len(txt) - 1)) * R / ws
        draw_label(sheet, p, reg, txt, tol=tol, shadow_px=0, cap_px=5,
                   glyph_scale=min(sq, 1.0), span_px=span,
                   center_in=(b[0], b[2] + 1), cap_top=b[1])

BXS = [0, 24, 51, 78, 103, 128, 153, 178, 203, 228]
for i, bx in enumerate(BXS):
    rows = GROUPS[i // 2]
    pressed = i % 2 == 1
    tol = 40 if pressed else 60
    x1 = bx + 20 if pressed else bx + 22
    for band, content in enumerate(rows):
        if content is None:
            continue
        by = 111 + band * 19
        icon_or_label((bx + 3, by + 3, x1, by + 9), content[0], tol)
        icon_or_label((bx + 3, by + 9, x1, by + 15), content[1], tol)

save(sheet, 'pledit')
