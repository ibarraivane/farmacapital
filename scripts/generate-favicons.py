#!/usr/bin/env python3
"""
Genera favicons e iconos PWA de FarmaCapital optimizados para pestañas del navegador.

Diseño: badge azul marca (#1E3ABA) con cruz médica blanca y acento verde.
Zona segura ~18% para que no se recorte en tabs 16×16.
"""
from __future__ import annotations

import math
import struct
import zlib
from pathlib import Path

try:
    from PIL import Image, ImageDraw
except ImportError as exc:
    raise SystemExit("Instala Pillow: pip install Pillow") from exc

ROOT = Path(__file__).resolve().parents[1]
PUBLIC = ROOT / "public"

# Paleta FarmaCapital
BLUE_DARK = (13, 27, 42)       # #0D1B2A
BLUE_BRAND = (30, 58, 186)     # #1E3ABA
GREEN_ACCENT = (34, 197, 94)   # #22C55E — legible en badge azul
WHITE = (255, 255, 255)


def lerp(a: float, b: float, t: float) -> float:
    return a + (b - a) * t


def blend(c1: tuple[int, int, int], c2: tuple[int, int, int], t: float) -> tuple[int, int, int]:
    return (
        int(lerp(c1[0], c2[0], t)),
        int(lerp(c1[1], c2[1], t)),
        int(lerp(c1[2], c2[2], t)),
    )


def draw_rounded_rect(draw: ImageDraw.ImageDraw, box, radius: float, fill):
    x0, y0, x1, y1 = box
    draw.rounded_rectangle(box, radius=radius, fill=fill)


def draw_favicon(size: int, *, dark_tab: bool = False) -> Image.Image:
    """Renderiza icono cuadrado con zona segura."""
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    # Zona segura: contenido dentro del 16%–84% del canvas
    margin = size * 0.08
    inner = size - margin * 2
    x0, y0 = margin, margin
    x1, y1 = margin + inner, margin + inner
    radius = inner * 0.22

    # Fondo: gradiente diagonal azul oscuro → azul marca (más contraste que outline)
    bg = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    bg_draw = ImageDraw.Draw(bg)
    for y in range(int(y0), int(y1)):
        for x in range(int(x0), int(x1)):
            t = ((x - x0) / inner * 0.55 + (y - y0) / inner * 0.45)
            t = max(0.0, min(1.0, t))
            col = blend(BLUE_DARK, BLUE_BRAND, t)
            bg.putpixel((x, y), (*col, 255))
    # Enmascarar con rounded rect
    mask = Image.new("L", (size, size), 0)
    ImageDraw.Draw(mask).rounded_rectangle((x0, y0, x1, y1), radius=radius, fill=255)
    img = Image.composite(bg, img, mask)

    draw = ImageDraw.Draw(img)

    # Borde sutil para separar de tabs oscuros (solo variante dark_tab ligeramente más clara)
    if dark_tab:
        border = tuple(min(255, c + 18) for c in BLUE_BRAND)
        draw.rounded_rectangle((x0, y0, x1, y1), radius=radius, outline=(*border, 200), width=max(1, size // 32))

    cx = size / 2
    cy = size / 2
    arm_w = size * 0.19
    arm_h = size * 0.42
    cross_radius = arm_w / 2

    # Cruz blanca gruesa con esquinas redondeadas
    v_box = (cx - arm_w / 2, cy - arm_h / 2, cx + arm_w / 2, cy + arm_h / 2)
    h_box = (cx - arm_h / 2, cy - arm_w / 2, cx + arm_h / 2, cy + arm_w / 2)
    draw.rounded_rectangle(v_box, radius=cross_radius, fill=(*WHITE, 255))
    draw.rounded_rectangle(h_box, radius=cross_radius, fill=(*WHITE, 255))

    # Acento verde: arco en cuadrante inferior-izquierdo (marca reconocible a 16px)
    stroke = max(2, int(size * 0.09))
    arc_box = (
        cx - arm_h * 0.55,
        cy - arm_h * 0.05,
        cx + arm_h * 0.15,
        cy + arm_h * 0.55,
    )
    draw.arc(arc_box, start=200, end=320, fill=(*GREEN_ACCENT, 255), width=stroke)

    return img


def save_png(img: Image.Image, path: Path):
    path.parent.mkdir(parents=True, exist_ok=True)
    img.save(path, format="PNG", optimize=True)
    print(f"  wrote {path.relative_to(ROOT)}")


def save_ico(images: list[tuple[int, Image.Image]], path: Path):
    """ICO multi-resolución."""
    path.parent.mkdir(parents=True, exist_ok=True)
    # Pillow guarda ICO con la imagen más grande; para multi-size usamos save con append_images
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
      <stop offset="0%" stop-color="#0D1B2A"/>
      <stop offset="100%" stop-color="#1E3ABA"/>
    </linearGradient>
  </defs>
  <!-- Zona segura 18%: contenido en 2.5–29.5 -->
  <rect x="2.5" y="2.5" width="27" height="27" rx="6" fill="url(#fc-bg)"/>
  <!-- Cruz médica -->
  <rect x="13" y="8.5" width="6" height="15" rx="3" fill="#FFFFFF"/>
  <rect x="8.5" y="13" width="15" height="6" rx="3" fill="#FFFFFF"/>
  <!-- Acento verde marca -->
  <path d="M 11.5 20.5 A 5 5 0 0 1 14.5 14.5" fill="none" stroke="#22C55E" stroke-width="2.2" stroke-linecap="round"/>
</svg>
"""
    path.write_text(svg, encoding="utf-8")
    print(f"  wrote {path.relative_to(ROOT)}")


def main():
    print("Generando favicons FarmaCapital…")
    write_svg(PUBLIC / "favicon.svg")

    light_32 = draw_favicon(32, dark_tab=False)
    dark_32 = draw_favicon(32, dark_tab=True)
    save_png(light_32, PUBLIC / "favicon-32.png")
    save_png(dark_32, PUBLIC / "favicon-32-dark.png")

    icon_sizes = [16, 32, 48, 72, 96, 128, 192, 512]
    ico_images: list[tuple[int, Image.Image]] = []

    for sz in icon_sizes:
        im_light = draw_favicon(sz, dark_tab=False)
        im_dark = draw_favicon(sz, dark_tab=True)
        save_png(im_light, PUBLIC / "icons" / f"farmacapital-{sz}.png")
        save_png(im_dark, PUBLIC / "icons" / f"farmacapital-{sz}-dark.png")
        if sz in (16, 32, 48):
            ico_images.append((sz, im_light))

    save_png(draw_favicon(180, dark_tab=False), PUBLIC / "apple-touch-icon.png")
    save_ico(ico_images, PUBLIC / "favicon.ico")
    save_ico(ico_images, PUBLIC / "favicon-light.ico")

    print("Listo.")


if __name__ == "__main__":
    main()
