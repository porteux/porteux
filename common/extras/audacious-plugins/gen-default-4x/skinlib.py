import os
import numpy as np
from PIL import Image, ImageDraw, ImageFont

R = 4
SS = 4
_HERE = os.path.dirname(os.path.abspath(__file__))
SRC = os.environ.get('SKIN_SRC', '')
OUT = os.environ.get('SKIN_OUT', os.path.join(_HERE, 'Default'))

FONT_BOLD = os.environ.get('SKIN_FONT',
                           '/usr/share/fonts/TTF/DejaVuSans-Bold.ttf')


def load(name):
    if not SRC or not os.path.isdir(SRC):
        raise SystemExit('Set SKIN_SRC to the upstream 1x Default skin dir '
                         '(src/skins-data/Skins/Default in the '
                         'audacious-plugins source tree)')
    return Image.open(f'{SRC}/{name}.png').convert('RGB')


def smart_up(im, tol=18):
    w, h = im.size
    a = np.asarray(im).astype(int)
    d = np.zeros((h, w))
    if w > 1:
        dx = np.abs(a[:, 1:] - a[:, :-1]).max(2)
        d[:, :-1] = np.maximum(d[:, :-1], dx)
        d[:, 1:] = np.maximum(d[:, 1:], dx)
    if h > 1:
        dy = np.abs(a[1:] - a[:-1]).max(2)
        d[:-1, :] = np.maximum(d[:-1, :], dy)
        d[1:, :] = np.maximum(d[1:, :], dy)
    smooth = (d < tol) & (d > 0)
    nearest = im.resize((w * R, h * R), Image.NEAREST)
    soft = im.resize((w * R, h * R), Image.BILINEAR)
    mask = Image.fromarray((smooth * 255).astype('uint8')).resize(
        (w * R, h * R), Image.BILINEAR)
    sheet = Image.composite(soft, nearest, mask)
    smooth_gradients(sheet, im)
    return sheet


def smooth_gradients(sheet, orig):
    """Re-render every monotonic 1x gradient ramp as a smooth 4x ramp.
    A ramp = >=4 px with >=2 same-sign steps of 3..60 (channel sum); a
    single hard step (two-tone faces, bevel lines) is left crisp."""
    a = np.asarray(orig).astype(int)
    h, w = a.shape[:2]
    for axis in (1, 0):
        m = a if axis == 1 else a.transpose(1, 0, 2)
        for i in range(m.shape[0]):
            j = 0
            C = m.shape[1]
            while j < C - 3:
                k, sgn, nz = j, 0, 0
                while k + 1 < C:
                    dv = (m[i, k + 1].astype(int) - m[i, k]).sum()
                    ad = np.abs(m[i, k + 1] - m[i, k]).sum()
                    if ad == 0:
                        k += 1
                        continue
                    if not 3 <= ad <= 60:
                        break
                    s = 1 if dv > 0 else -1
                    if sgn == 0:
                        sgn = s
                    if s != sgn:
                        break
                    k += 1
                    nz += 1
                if k - j >= 3 and nz >= 2:
                    cols = [tuple(int(v) for v in m[i, q])
                            for q in range(j, k + 1)]
                    if axis == 1:
                        smooth_hfill(sheet, i * R, (i + 1) * R, j, cols,
                                     step_tol=61)
                    else:
                        smooth_vfill(sheet, i * R, (i + 1) * R, j, cols,
                                     step_tol=61)
                    j = k
                else:
                    j = k + 1 if k > j else j + 1


def row_bg(orig, region, bg_x=None, max_lum=None):
    """Dominant (or sampled) background color per row of a 1x region."""
    x0, y0, x1, y1 = region
    colors = []
    prev = None
    for y in range(y0, y1):
        if bg_x is not None:
            colors.append(orig.getpixel((bg_x, y)))
        else:
            row = [orig.getpixel((x, y)) for x in range(x0, x1)]
            if max_lum is not None:
                kept = [c for c in row if sum(c) / 3 <= max_lum]
                row = kept or ([prev] if prev else row)
            n = len(row)
            prev = tuple(sorted(c[i] for c in row)[n // 2] for i in range(3))
            colors.append(prev)
    return colors


def repair_bg(sheet, orig, region, bg_x=None, max_lum=None):
    """Erase 1x region on the 4x sheet with per-row background colors,
    smoothly interpolated at 4x; hard steps (designed edges) are kept."""
    x0, y0, x1, y1 = region
    colors = row_bg(orig, region, bg_x, max_lum)
    d = ImageDraw.Draw(sheet)
    height = (y1 - y0) * R
    for yy in range(height):
        pos = (yy + 0.5) / R - 0.5
        k = int(pos) if pos >= 0 else -1
        t = pos - k
        if k < 0:
            c = colors[0]
        elif k >= len(colors) - 1:
            c = colors[-1]
        else:
            a, b = colors[k], colors[k + 1]
            if _diff(a, b) > 30:
                c = a if t < 0.5 else b
            else:
                c = tuple(int(a[i] + (b[i] - a[i]) * t) for i in range(3))
        d.rectangle([x0 * R, y0 * R + yy, x1 * R - 1, y0 * R + yy], fill=c)


def find_ink(orig, region, tol=60, bg_x=None):
    """bbox+color of pixels differing from per-row bg. Returns (bbox, color) in 1x."""
    x0, y0, x1, y1 = region
    colors = row_bg(orig, region, bg_x)
    best, bbox = None, None
    brightest = -1
    for y in range(y0, y1):
        bg = colors[y - y0]
        for x in range(x0, x1):
            c = orig.getpixel((x, y))
            if sum(abs(c[i] - bg[i]) for i in range(3)) > tol:
                bbox = (min(bbox[0], x), min(bbox[1], y), max(bbox[2], x),
                        max(bbox[3], y)) if bbox else (x, y, x, y)
                lum = c[0] + c[1] + c[2]
                if lum > brightest:
                    brightest = lum
                    best = c
    return bbox, best


class Overlay:
    """Supersampled RGBA overlay pasted onto the 4x sheet."""

    def __init__(self, sheet):
        self.sheet = sheet
        self.im = Image.new('RGBA', (sheet.width * SS, sheet.height * SS),
                            (0, 0, 0, 0))
        self.d = ImageDraw.Draw(self.im)

    def poly(self, pts, fill):
        self.d.polygon([(x * R * SS, y * R * SS) for x, y in pts], fill=fill)

    def rect(self, x0, y0, x1, y1, fill):
        k = R * SS
        self.d.rectangle([x0 * k, y0 * k, x1 * k - 1, y1 * k - 1], fill=fill)

    def rrect(self, x0, y0, x1, y1, rad, fill, outline=None, ow=0):
        k = R * SS
        self.d.rounded_rectangle([x0 * k, y0 * k, x1 * k - 1, y1 * k - 1],
                                 radius=rad * k, fill=fill, outline=outline,
                                 width=int(ow * k))
    def ellipse(self, x0, y0, x1, y1, fill, outline=None, ow=0):
        k = R * SS
        self.d.ellipse([x0 * k, y0 * k, x1 * k - 1, y1 * k - 1], fill=fill,
                       outline=outline, width=int(ow * k))

    def line(self, pts, fill, w):
        k = R * SS
        self.d.line([(x * k, y * k) for x, y in pts], fill=fill,
                    width=max(1, int(w * k)))

    def apply(self):
        small = self.im.resize((self.sheet.width, self.sheet.height),
                               Image.LANCZOS)
        self.sheet.paste(small, (0, 0), small)


_fonts = {}

def get_font(px, path=FONT_BOLD):
    key = (path, px)
    if key not in _fonts:
        _fonts[key] = ImageFont.truetype(path, px)
    return _fonts[key]


def fit_font(text, target_h4, path=FONT_BOLD):
    size = target_h4
    for _ in range(6):
        f = get_font(size, path)
        b = f.getbbox(text)
        h = b[3] - b[1]
        if h == 0:
            break
        size = max(6, round(size * target_h4 / h))
        if abs(h - target_h4) <= 1:
            break
    return size


def _diff(a, b):
    return sum(abs(a[i] - b[i]) for i in range(3))


def bg_lum(orig, region):
    x0, y0, x1, y1 = region
    lums = sorted(sum(orig.getpixel((x, y))) / 3
                  for x in range(x0, x1) for y in range(y0, y1))
    return lums[len(lums) // 2]


def render_char(ch, size, squeeze=1.0, path=FONT_BOLD, bold=0):
    """RGBA glyph tile + (x-offset of glyph box, cap-anchor y offset).

    `bold` adds an outline stroke (in 4x units); the original's small
    labels were rendered with hinting, which snaps stems to full pixels
    and reads denser than a plain downsample."""
    f = get_font(size, path)
    b = f.getbbox(ch)
    bA = f.getbbox('A')
    pad = size // 2 + 2 + bold
    w = max(1, b[2] - b[0])
    tile = Image.new('L', (w + 2 * pad, (b[3] - bA[1]) + 2 * pad), 0)
    td = ImageDraw.Draw(tile)
    td.text((pad - b[0], pad - bA[1]), ch, font=f, fill=255,
            stroke_width=bold, stroke_fill=255)
    if squeeze != 1.0:
        tile = tile.resize((max(1, int(tile.width * squeeze)), tile.height),
                           Image.LANCZOS)
    return tile, pad * squeeze, pad


def draw_label(sheet, orig, region, text, fill=None, shadow=None, bg_x=None,
               tol=60, shadow_px=1, repair=True, squeeze_extra=1.0,
               cap_px=None, center_in=None, span_px=None, bold=0,
               glyph_scale=None, gap_px=0.0, cap_top=None, optical=True,
               track_px=None):
    """Redraw `text` over the original label: same span and baseline,
    strictly equal gaps between letters.

    region: 1x box containing the original label (and nothing else).
    shadow_px: rows of drop shadow included in the ink bbox (excluded from
    cap height). center_in: optional (x0, x1) in 1x to center the text
    block in (e.g. a button face) instead of using the original span."""
    bbox, ink = find_ink(orig, region, tol=tol, bg_x=bg_x)
    if repair:
        x0, y0, x1, y1 = region
        pad_reg = (max(0, x0 - 1), max(0, y0 - 1),
                   min(orig.width, x1 + 1), min(orig.height, y1 + 1))
        repair_bg(sheet, orig, pad_reg, bg_x=bg_x,
                  max_lum=None if bg_x is not None else bg_lum(orig, region) + 25)
    if not bbox:
        return
    n = len(text)
    if cap_px is not None:
        cap_h4 = cap_px * R
    else:
        cap_h4 = (bbox[3] - bbox[1] + 1 - shadow_px) * R
    cap_top4 = (cap_top if cap_top is not None else bbox[1]) * R
    size = fit_font('A', cap_h4)
    if fill is None:
        fill = ink
    f = get_font(size)
    ws = [f.getbbox(ch)[2] - f.getbbox(ch)[0] + 2 * bold for ch in text]
    span4 = (span_px * R) if span_px else (bbox[2] + 1 - bbox[0]) * R
    # Equal gaps between glyph edges. Glyphs keep their natural width
    # whenever they fit the span (the original renders them nearly
    # touching); squeezing is a fallback only, since it thins the stems
    # and makes the text read lighter than the original.
    if glyph_scale is not None:
        # fixed letter width (the caller keeps several labels consistent);
        # the block is centred instead of stretched to the span
        sq = glyph_scale * squeeze_extra
        gap = gap_px * R
    else:
        sq = min(1.0, span4 / sum(ws)) * squeeze_extra
        gap = ((span4 - sum(ws) * sq) / (n - 1)) if n > 1 else 0
    if optical and n > 1:
        # equal closest-approach gaps between the rendered inks, not between
        # glyph boxes: box gaps read uneven next to diagonals (A, Y)
        # lay the word out with the font's own advance widths (sidebearings
        # are the type designer's solution to uneven-looking gaps around
        # L feet, T crossbars, diagonals), plus uniform tracking so the
        # ink block exactly fills the original span
        advs = [f.getlength(ch) for ch in text]
        bbs = [f.getbbox(ch) for ch in text]
        span0 = (sum(advs[:-1]) + bbs[-1][2] - bbs[0][0]) * sq
        if track_px is not None:
            t = track_px * R
            span4 = span0 + t * (n - 1)
        else:
            t = (span4 - span0) / (n - 1) if n > 1 else 0.0
        if center_in is not None:
            start = (center_in[0] + center_in[1]) * R / 2 - span4 / 2
        else:
            start = bbox[0] * R
        pen = start - bbs[0][0] * sq
        for i, ch in enumerate(text):
            tile, padx, pady = render_char(ch, size, sq, bold=bold)
            gx = int(round(pen + bbs[i][0] * sq - padx))
            gy = int(cap_top4 - pady)
            if shadow:
                off = max(2, R * 3 // 4)
                sh = tile.point(lambda v: int(v * 0.45))
                col = Image.new('RGB', tile.size, shadow)
                sheet.paste(col, (gx + off, gy + off), sh)
            col = Image.new('RGB', tile.size, fill)
            sheet.paste(col, (gx, gy), tile)
            pen += advs[i] * sq + t
        return
    block_w = sum(ws) * sq + gap * (n - 1)
    if center_in is not None:
        x = (center_in[0] + center_in[1]) * R / 2 - block_w / 2
    else:
        x = bbox[0] * R + (span4 - block_w) / 2
    for ch, w in zip(text, ws):
        tile, padx, pady = render_char(ch, size, sq, bold=bold)
        gx = int(round(x - padx))
        gy = int(cap_top4 - pady)
        if shadow:
            off = max(2, R * 3 // 4)
            sh = tile.point(lambda v: int(v * 0.45))
            col = Image.new('RGB', tile.size, shadow)
            sheet.paste(col, (gx + off, gy + off), sh)
        col = Image.new('RGB', tile.size, fill)
        sheet.paste(col, (gx, gy), tile)
        x += w * sq + gap


def std_tri_up(ov, cell_x, cell_y, fill):
    """Shade chevron, main-window style, anchored to a 9x9 cell."""
    cx = cell_x + 4.5
    ov.poly([(cx, cell_y + 3.7), (cx - 3.5, cell_y + 8.0),
             (cx + 3.5, cell_y + 8.0)], fill)


def std_tri_down(ov, cell_x, cell_y, fill):
    cx = cell_x + 4.5
    ov.poly([(cx - 3.5, cell_y + 4.0), (cx + 3.5, cell_y + 4.0),
             (cx, cell_y + 8.3)], fill)


def smooth_vfill(sheet, x0_4, x1_4, y0_1x, colors, step_tol=30):
    """Fill a 4x column span with per-1x-row colors, vertically interpolated
    (hard steps preserved). y0_1x is the 1x row of colors[0]."""
    d = ImageDraw.Draw(sheet)
    for yy in range(len(colors) * R):
        pos = (yy + 0.5) / R - 0.5
        k = int(pos) if pos >= 0 else -1
        t = pos - k
        if k < 0:
            c = colors[0]
        elif k >= len(colors) - 1:
            c = colors[-1]
        else:
            a, b = colors[k], colors[k + 1]
            if _diff(a, b) > step_tol:
                c = a if t < 0.5 else b
            else:
                c = tuple(int(a[i] + (b[i] - a[i]) * t) for i in range(3))
        d.rectangle([x0_4, y0_1x * R + yy, x1_4 - 1, y0_1x * R + yy], fill=c)


def smooth_hfill(sheet, y0_4, y1_4, x0_1x, colors, step_tol=30):
    """Horizontal analog of smooth_vfill."""
    d = ImageDraw.Draw(sheet)
    for xx in range(len(colors) * R):
        pos = (xx + 0.5) / R - 0.5
        k = int(pos) if pos >= 0 else -1
        t = pos - k
        if k < 0:
            c = colors[0]
        elif k >= len(colors) - 1:
            c = colors[-1]
        else:
            a, b = colors[k], colors[k + 1]
            if _diff(a, b) > step_tol:
                c = a if t < 0.5 else b
            else:
                c = tuple(int(a[i] + (b[i] - a[i]) * t) for i in range(3))
        d.rectangle([x0_1x * R + xx, y0_4, x0_1x * R + xx, y1_4 - 1], fill=c)


def smooth_track_highlight(sheet, orig):
    """Ramp the sliders' grey 2-row highlight (e.g. 59/31 or 64/32 over
    black).  smart_up() keeps that step as two flat 4px bands; a ramp reads
    as the intended smooth grade.  Must run right after smart_up(), before
    any text or glyph drawing.  The guards are strict -- a neutral-grey
    bright-over-dim pair sitting directly on darker rows -- so borders,
    knobs and lettering never match."""
    a = np.asarray(orig.convert('RGB')).astype(int)
    h, w, _ = a.shape
    for y in range(1, h - 2):
        for x in range(w):
            c1, c2 = a[y, x], a[y + 1, x]
            if c1.max() - c1.min() > 8 or c2.max() - c2.min() > 8:
                continue
            if not (45 <= c1[0] <= 90 and 20 <= c2[0] <= 45):
                continue
            if a[y - 1, x].max() >= c2[0] or a[y + 2, x].max() >= c2[0]:
                continue
            smooth_vfill(sheet, x * R, (x + 1) * R, y,
                         [tuple(int(v) for v in c1),
                          tuple(int(v) for v in c2)], step_tol=999)


def glyph_x(ov, bbox, fill, lw=1.15):
    x0, y0, x1, y1 = bbox
    cx, cy = (x0 + x1 + 1) / 2, (y0 + y1 + 1) / 2
    r = (x1 - x0 + 1) / 2 - 0.4
    ov.line([(cx - r, cy - r), (cx + r, cy + r)], fill, lw)
    ov.line([(cx - r, cy + r), (cx + r, cy - r)], fill, lw)


_logo_cache = {}

def render_logo(px, ball=(215, 215, 215), ink=(10, 10, 10)):
    """Audacious 'a' ball from the official SVG: grey disc, dark glyph."""
    key = (px, ball, ink)
    if key in _logo_cache:
        return _logo_cache[key]
    import cairosvg, io
    svg = open(os.path.join(_HERE, 'audacious.svg')).read()
    svg = svg.replace('<path d="M96 48a48 48 0 0 1-48 48A48 48 0 0 1 0 48 '
                      '48 48 0 0 1 48 0a48 48 0 0 1 48 48z"/>', '')
    svg = svg.replace('fill="#d9d9d9"', 'fill="rgb(%d,%d,%d)"' % ball)
    big = px * 4
    scale = big * 96 // 72
    png = cairosvg.svg2png(bytestring=svg.encode(), output_width=scale,
                           output_height=scale)
    im = Image.open(io.BytesIO(png)).convert('RGBA')
    k = im.width / 96.0
    base = Image.new('RGBA', im.size, (0, 0, 0, 0))
    d = ImageDraw.Draw(base)
    d.ellipse([12 * k, 12 * k, 84 * k, 84 * k], fill=ink)
    base.alpha_composite(im)
    disc = base.crop((int(12 * k), int(12 * k), int(84 * k), int(84 * k)))
    disc = disc.resize((px, px), Image.LANCZOS)
    _logo_cache[key] = disc
    return disc


def smooth_mask(mask_arr, round_px=0.12):
    """Upscale a 1x boolean ink mask to 4x with rounded, anti-aliased edges."""
    from PIL import ImageFilter
    m = Image.fromarray((np.asarray(mask_arr) * 255).astype(np.uint8), 'L')
    ss = 8
    big = m.resize((m.width * R * ss, m.height * R * ss), Image.NEAREST)
    big = big.filter(ImageFilter.GaussianBlur(round_px * R * ss))
    big = big.point(lambda v: 255 if v >= 128 else 0)
    return big.resize((m.width * R, m.height * R), Image.BOX)


def smooth_banding(sheet, step_max=42, min_run=3, protect=()):
    """Final pass: any run of >=min_run uniform 1x blocks whose neighbours
    step by a small amount is a leftover blocky gradient -- re-render it as
    a smooth ramp.  Hard edges (steps > step_max), flat areas (step 0) and
    detailed/AA blocks (non-uniform) are untouched."""
    import numpy as np
    a = np.asarray(sheet, dtype=np.int16)
    H, W, _ = a.shape
    bh, bw = H // R, W // R
    blk = a[:bh * R, :bw * R].reshape(bh, R, bw, R, 3)
    uni = (blk.max(axis=(1, 3)) == blk.min(axis=(1, 3))).all(axis=2)
    mean = blk[:, 0, :, 0, :]

    def runs(u, m):
        out = []
        for i in range(u.shape[0]):
            j0 = 0
            for j in range(1, u.shape[1] + 1):
                ok = (j < u.shape[1] and u[i, j] and u[i, j - 1] and
                      0 < np.abs(m[i, j] - m[i, j - 1]).sum() <= step_max)
                if not ok:
                    if j - j0 >= min_run:
                        out.append((i, j0, j))
                    j0 = j
        return out

    def hit(x0, y0, x1, y1):
        return any(x0 < p[2] and x1 > p[0] and y0 < p[3] and y1 > p[1]
                   for p in protect)

    for i, j0, j1 in runs(uni.T, mean.transpose(1, 0, 2)):   # vertical
        if hit(i, j0, i + 1, j1):
            continue
        cols = [tuple(int(v) for v in mean[k, i]) for k in range(j0, j1)]
        smooth_vfill(sheet, i * R, (i + 1) * R, j0, cols, step_tol=999)
    for i, j0, j1 in runs(uni, mean):                        # horizontal
        if hit(j0, i, j1, i + 1):
            continue
        cols = [tuple(int(v) for v in mean[i, k]) for k in range(j0, j1)]
        smooth_hfill(sheet, i * R, (i + 1) * R, j0, cols, step_tol=999)


def save(sheet, name, protect=()):
    import os
    smooth_banding(sheet, protect=protect)
    os.makedirs(OUT, exist_ok=True)
    sheet.save(f'{OUT}/{name}.png', optimize=True)
    print(name, sheet.size)
