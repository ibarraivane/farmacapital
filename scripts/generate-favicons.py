#!/usr/bin/env python3
"""
Genera favicons e iconos PWA de FarmaCapital.

iOS (apple-touch-icon) y maskable requieren fondo OPACO a todo el canvas.
Si hay transparencia, Safari la pinta de negro y el icono se ve con marco feo.
"""
from __future__ import annotations

from pathlib import Path

try:
    from PIL import Image, ImageDraw
except ImportError as exc:
    raise SystemExit("Instala Pillow: pip install Pillow") from exc

ROOT = Path(__file__).resolve().parents[1]
PUBLIC = ROOT / "public"

# Paleta FarmaCapital
INK = (0, 21, 52)              # #001534
BLUE_DARK = (13, 27, 42)       # #0D1B2A
BLUE_BRAND = (30, 58, 186)     # #1E3ABA
GREEN_ACCENT = (34, 197, 94)   # #22C55E
WHITE = (255, 255, 255)


def lerp(a: float, b: float, t: float) -> float:
    return a + (b - a) * t


def blend(c1, c2, t: float):
    return (
        int(lerp(c1[0], c2[0], t)),
        int(lerp(c1[1], c2[1], t)),
        int(lerp(c1[2], c2[2], t)),
    )


def fill_gradient(img: Image.Image, box, c1, c2):
    x0, y0, x1, y1 = (int(v) for v in box)
    w = max(1, x1 - x0)
    h = max(1, y1 - y0)
    px = img.load()
    for y in range(y0, y1):
        for x in range(x0, x1):
            t = ((x - x0) / w * 0.55 + (y - y0) / h * 0.45)
            t = max(0.0, min(1.0, t))
            px[x, y] = (*blend(c1, c2, t), 255)


def draw_cross(draw: ImageDraw.ImageDraw, size: int, cx: float, cy: float, scale: float):
    arm_w = size * 0.19 * scale
    arm_h = size * 0.42 * scale
    cross_radius = arm_w / 2
    v_box = (cx - arm_w / 2, cy - arm_h / 2, cx + arm_w / 2, cy + arm_h / 2)
    h_box = (cx - arm_h / 2, cy - arm_w / 2, cx + arm_h / 2, cy + arm_w / 2)
    draw.rounded_rectangle(v_box, radius=cross_radius, fill=(*WHITE, 255))
    draw.rounded_rectangle(h_box, radius=cross_radius, fill=(*WHITE, 255))

    stroke = max(2, int(size * 0.09 * scale))
    arc_box = (
        cx - arm_h * 0.55,
        cy - arm_h * 0.05,
        cx + arm_h * 0.15,
        cy + arm_h * 0.55,
    )
    draw.arc(arc_box, start=200, end=320, fill=(*GREEN_ACCENT, 255), width=stroke)


def draw_tab_favicon(size: int, *, dark_tab: bool = False) -> Image.Image:
    """Favicon de pestaña: badge redondeado (transparencia OK en tabs)."""
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    margin = size * 0.08
    inner = size - margin * 2
    x0, y0 = margin, margin
    x1, y1 = margin + inner, margin + inner
    radius = inner * 0.22

    bg = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    fill_gradient(bg, (x0, y0, x1, y1), BLUE_DARK, BLUE_BRAND)
    mask = Image.new("L", (size, size), 0)
    ImageDraw.Draw(mask).rounded_rectangle((x0, y0, x1, y1), radius=radius, fill=255)
    img = Image.composite(bg, img, mask)

    draw = ImageDraw.Draw(img)
    if dark_tab:
        border = tuple(min(255, c + 18) for c in BLUE_BRAND)
        draw.rounded_rectangle(
            (x0, y0, x1, y1),
            radius=radius,
            outline=(*border, 200),
            width=max(1, size // 32),
        )
    draw_cross(draw, size, size / 2, size / 2, scale=1.0)
    return img


def draw_app_icon(size: int, *, maskable: bool = False) -> Image.Image:
    """
    Icono de app / apple-touch: canvas 100% opaco.
    iOS aplica su propia máscara squircle; no dejar alpha en las esquinas.
    """
    img = Image.new("RGBA", (size, size), (*INK, 255))
    fill_gradient(img, (0, 0, size, size), INK, BLUE_BRAND)

    pad = 0.20 if maskable else 0.12
    usable = 1.0 - 2 * pad
    scale = usable / 0.84

    draw = ImageDraw.Draw(img)
    draw_cross(draw, size, size / 2, size / 2, scale=scale)

    px = img.load()
    for y in range(size):
        for x in range(size):
            r, g, b, a = px[x, y]
            if a < 255:
                px[x, y] = (r, g, b, 255)
    return img


def save_png(img: Image.Image, path: Path):
    path.parent.mkdir(parents=True, exist_ok=True)
    img.save(path, format="PNG", optimize=True)
    print(f"  wrote {path.relative_to(ROOT)}")


def save_ico(images: list[tuple[int, Image.Image]], path: Path):
    path.parent.mkdir(parents=True, exist_ok=True)
    sizes = sorted(images, key=lambda x: x[0], reverse=True)
    base = sizes[0][1]
    rest = [im for _, im in sizes[1:]]
    base.save(path, format="ICO", sizes=[(s[0], s[0]) for s in sizes], append_images=rest)
    print(f"  wrote {path.relative_to(ROOT)}")


def write_svg(path: Path):
    svg = """<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 32 32" role="img" aria-label="FarmaCapital">
  <defs>
    <linearGradient id="fc-bg" x1="0" y1="0" x2="1" y2="1">
      <stop offset="0%" stop-color="#001534"/>
      <stop offset="100%" stop-color="#1E3ABA"/>
    </linearGradient>
  </defs>
  <rect width="32" height="32" fill="url(#fc-bg)"/>
  <rect x="13" y="8.5" width="6" height="15" rx="3" fill="#FFFFFF"/>
  <rect x="8.5" y="13" width="15" height="6" rx="3" fill="#FFFFFF"/>
  <path d="M 11.5 20.5 A 5 5 0 0 1 14.5 14.5" fill="none" stroke="#22C55E" stroke-width="2.2" stroke-linecap="round"/>
</svg>
"""
    path.write_text(svg, encoding="utf-8")
    print(f"  wrote {path.relative_to(ROOT)}")


def main():
    print("Generando favicons / iconos PWA FarmaCapital…")
    write_svg(PUBLIC / "favicon.svg")

    save_png(draw_tab_favicon(32, dark_tab=False), PUBLIC / "favicon-32.png")
    save_png(draw_tab_favicon(32, dark_tab=True), PUBLIC / "favicon-32-dark.png")

    tab_sizes = [16, 32, 48, 72, 96, 128]
    ico_images: list[tuple[int, Image.Image]] = []
    for sz in tab_sizes:
        im_light = draw_tab_favicon(sz, dark_tab=False)
        im_dark = draw_tab_favicon(sz, dark_tab=True)
        save_png(im_light, PUBLIC / "icons" / f"farmacapital-{sz}.png")
        save_png(im_dark, PUBLIC / "icons" / f"farmacapital-{sz}-dark.png")
        if sz in (16, 32, 48):
            ico_images.append((sz, im_light))

    for sz in (192, 512):
        any_icon = draw_app_icon(sz, maskable=False)
        mask_icon = draw_app_icon(sz, maskable=True)
        save_png(any_icon, PUBLIC / "icons" / f"farmacapital-{sz}.png")
        save_png(mask_icon, PUBLIC / "icons" / f"farmacapital-{sz}-maskable.png")
        save_png(any_icon, PUBLIC / "icons" / f"farmacapital-{sz}-dark.png")

    # Safari / Agregar a Inicio: 180×180 full-bleed opaco
    save_png(draw_app_icon(180, maskable=False), PUBLIC / "apple-touch-icon.png")

    save_ico(ico_images, PUBLIC / "favicon.ico")
    save_ico(ico_images, PUBLIC / "favicon-light.ico")
    print("Listo.")


if __name__ == "__main__":
    main()
