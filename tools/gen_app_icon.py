"""Generate the AirportNav launcher icons from the same 64-unit geometry as
lib/core/branding/logo_painter.dart, so the icon and the in-app mark can never
drift. Run from the airport_nav/ directory:  python tools/gen_app_icon.py
"""
import os
from PIL import Image, ImageDraw

S = 1024
K = S / 64.0
SKY2, SKY, AMBER, WHITE = (88, 149, 243), (53, 119, 231), (255, 176, 32), (255, 255, 255)

# Supersample factor - draw big, downscale, so curves and the plane are smooth.
SS = 4


def gradient(size, c1, c2):
    """Diagonal linear gradient, drawn small then upscaled."""
    n = 64
    g = Image.new("RGB", (n, n))
    px = g.load()
    for y in range(n):
        for x in range(n):
            t = (x + y) / (2.0 * (n - 1))
            px[x, y] = tuple(round(c1[i] + (c2[i] - c1[i]) * t) for i in range(3))
    return g.resize((size, size), Image.BICUBIC)


def tile_mask():
    """Rounded square minus the two boarding-pass notches (supersampled)."""
    big = S * SS
    k = big / 64.0
    m = Image.new("L", (big, big), 0)
    d = ImageDraw.Draw(m)
    d.rounded_rectangle([0, 0, big - 1, big - 1], radius=int(18 * k), fill=255)
    r, cy = 7.5 * k, 30 * k
    for cx in (0, big):
        d.ellipse([cx - r, cy - r, cx + r, cy + r], fill=0)
    return m.resize((S, S), Image.LANCZOS)


def draw_marks(size):
    """Amber route dots + white plane on a transparent layer."""
    big = size * SS
    k = big / 64.0
    layer = Image.new("RGBA", (big, big), (0, 0, 0, 0))
    d = ImageDraw.Draw(layer)

    # Amber route dots along the quadratic M13 48 Q25 47 33 38.
    # 4 dots matches the 7.5-grid-unit spacing used by LogoPainter, so the
    # icon and the in-app mark render the same route.
    p0, p1, p2 = (13 * k, 48 * k), (25 * k, 47 * k), (33 * k, 38 * k)
    for i in range(4):
        t = i / 3.0
        x = (1 - t) ** 2 * p0[0] + 2 * (1 - t) * t * p1[0] + t ** 2 * p2[0]
        y = (1 - t) ** 2 * p0[1] + 2 * (1 - t) * t * p1[1] + t ** 2 * p2[1]
        rr = 1.7 * k
        d.ellipse([x - rr, y - rr, x + rr, y + rr], fill=AMBER)

    # White plane
    d.polygon(
        [(49 * k, 15 * k), (27 * k, 25.5 * k), (36.5 * k, 29.5 * k), (40 * k, 39 * k)],
        fill=WHITE,
    )
    return layer.resize((size, size), Image.LANCZOS)


os.makedirs("assets/icons", exist_ok=True)

# ── Full tile icon ────────────────────────────────────────────────────
icon = Image.new("RGBA", (S, S), (0, 0, 0, 0))
icon.paste(gradient(S, SKY2, SKY), (0, 0), tile_mask())
marks = draw_marks(S)
icon.alpha_composite(marks)
icon.save("assets/icons/app_icon.png")

# ── Adaptive foreground: marks only, centred in the 66% safe area ─────
# Android masks adaptive icons to a circle/squircle, so the notches are cut
# off regardless. The marks are composed for the corner of a square tile, so
# reusing that layout leaves the plane stranded high-right inside the mask.
# Crop to the marks' actual bounding box and centre it instead.
fg = Image.new("RGBA", (S, S), (0, 0, 0, 0))
inner = int(S * 0.62)
scaled = draw_marks(inner)
bbox = scaled.getbbox()
if bbox:
    cropped = scaled.crop(bbox)
    fg.alpha_composite(
        cropped,
        ((S - cropped.width) // 2, (S - cropped.height) // 2),
    )
fg.save("assets/icons/app_icon_foreground.png")

print("wrote assets/icons/app_icon.png + app_icon_foreground.png")
