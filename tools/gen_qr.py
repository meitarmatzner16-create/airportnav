"""Generate a branded QR code pointing at the live AirportNav web demo.

Usage:
    python tools/gen_qr.py [url] [out.png]

Defaults to the GitHub Pages deployment, so a bare `python tools/gen_qr.py`
regenerates the portfolio asset in place.

Colours match the app: ink #0F2350 modules on white, so the code sits
comfortably next to the rest of the brand in a portfolio layout.
"""

import sys

import qrcode
from qrcode.constants import ERROR_CORRECT_H

LIVE_URL = "https://meitarmatzner16-create.github.io/airportnav/"
DEFAULT_OUT = "docs/portfolio/airportnav-qr.png"

url = sys.argv[1] if len(sys.argv) > 1 else LIVE_URL
out = sys.argv[2] if len(sys.argv) > 2 else DEFAULT_OUT

qr = qrcode.QRCode(
    version=None,
    error_correction=ERROR_CORRECT_H,  # high, so the logo can be overlaid later
    box_size=12,
    border=3,
)
qr.add_data(url)
qr.make(fit=True)

img = qr.make_image(fill_color="#0F2350", back_color="white").convert("RGB")
img.save(out)
print(f"{url} -> {out}  ({img.size[0]}x{img.size[1]})")
