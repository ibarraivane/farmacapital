#!/usr/bin/env python3
"""Iconos PWA, favicon y tarjeta de WhatsApp desde el logotipo oficial.

No redibuja la cruz. Recorta el PNG maestro y solo aclara el contorno
tinta para que se lea sobre #001534. La tarjeta de compartir es 1200×630;
WhatsApp no debe usar el icono cuadrado de 512.
"""
from __future__ import annotations

from pathlib import Path

import numpy as np
from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parents[1]
PUBLIC = ROOT / "public"
BRAND = PUBLIC / "brand"
ICONS = PUBLIC / "icons"
MASTER = BRAND / "farmacapital-logo-master.png"

INK = (0, 21, 52)  # #001534
TEXT_MID = (168, 180, 196)
JADE = (2, 161, 88)


def _trim(im: Image.Image) -> Image.Image:
    bbox = im.getbbox()
    return im.crop(bbox) if bbox else im


def knock_out_white(im: Image.Image, tol: int = 240) -> Image.Image:
    arr = np.array(im.convert("RGBA"))
    r, g, b = arr[:, :, 0], arr[:, :, 1], arr[:, :, 2]
    arr[(r >= tol) & (g >= tol) & (b >= tol), 3] = 0
    return Image.fromarray(arr)


def icon_from_master() -> Image.Image:
    src = knock_out_white(Image.open(MASTER))
    arr = np.array(src)
    vis = arr[:, :, 3] > 10
    ys, xs = np.where(vis)
    y0, y1 = int(ys.min()), int(ys.max()) + 1
    x0, x1 = int(xs.min()), int(xs.max()) + 1
    col = vis.sum(axis=0)
    in_block = False
    start = 0
    blocks = []
    for x in range(x0, x1):
        if col[x] > 15:
            if not in_block:
                start = x
                in_block = True
        elif in_block:
            blocks.append((start, x - 1))
            in_block = False
    if in_block:
        blocks.append((start, x1 - 1))
    ix0, ix1 = blocks[0]
    return _trim(src.crop((ix0, y0, ix1 + 1, y1)))


def outline_for_navy(im: Image.Image) -> Image.Image:
    """Contorno tinta → blanco. Jade y azul de marca se quedan."""
    arr = np.array(im.convert("RGBA"))
    r, g, b, a = arr[:, :, 0], arr[:, :, 1], arr[:, :, 2], arr[:, :, 3]
    vis = a > 10
    jade = vis & (g > 90) & (g > r + 25) & (g > b + 5)
    brand_blue = vis & (b > 130) & (b > r + 40) & (b >= g)
    navy = vis & ~jade & ~brand_blue
    arr[navy, 0] = 255
    arr[navy, 1] = 255
    arr[navy, 2] = 255
    return Image.fromarray(arr)


def paste_mark(size: int, mark: Image.Image, *, bg: tuple[int, int, int], pad: float) -> Image.Image:
    canvas = Image.new("RGB", (size, size), bg)
    mark = _trim(mark)
    inner = max(1, int(size * (1 - 2 * pad)))
    mark = mark.copy()
    mark.thumbnail((inner, inner), Image.Resampling.LANCZOS)
    x = (size - mark.size[0]) // 2
    y = (size - mark.size[1]) // 2
    canvas.paste(mark, (x, y), mark)
    return canvas


def write_png(im: Image.Image, path: Path) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    im.save(path, format="PNG", optimize=True)
    print(f"  {path.relative_to(ROOT)}  {im.size[0]}×{im.size[1]}")


def write_favicon_svg(icon32: Image.Image, path: Path) -> None:
    import base64
    from io import BytesIO

    buf = BytesIO()
    icon32.save(buf, format="PNG", optimize=True)
    b64 = base64.b64encode(buf.getvalue()).decode("ascii")
    path.write_text(
        f"""<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" viewBox="0 0 32 32" role="img" aria-label="FarmaCapital">
  <image width="32" height="32" xlink:href="data:image/png;base64,{b64}"/>
</svg>
""",
        encoding="utf-8",
    )
    print(f"  {path.relative_to(ROOT)}")


def write_ico(images: list[Image.Image], path: Path) -> None:
    images[-1].save(path, format="ICO", sizes=[(im.size[0], im.size[0]) for im in images])
    print(f"  {path.relative_to(ROOT)}")


def _font(size: int) -> ImageFont.FreeTypeFont | ImageFont.ImageFont:
    for name in (
        "/usr/share/fonts/truetype/macos/Inter-SemiBold.ttf",
        "/usr/share/fonts/truetype/macos/Inter-Medium.ttf",
        "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf",
    ):
        p = Path(name)
        if p.exists():
            return ImageFont.truetype(str(p), size)
    return ImageFont.load_default()


def write_og_image(logo_light: Image.Image, path: Path) -> None:
    w, h = 1200, 630
    card = Image.new("RGB", (w, h), INK)
    logo = _trim(logo_light)
    target_w = 780
    scale = target_w / logo.size[0]
    logo = logo.resize((target_w, max(1, int(logo.size[1] * scale))), Image.Resampling.LANCZOS)
    x = (w - logo.size[0]) // 2
    y = (h - logo.size[1]) // 2 - 36
    card.paste(logo, (x, y), logo)

    draw = ImageDraw.Draw(card)
    draw.rectangle((0, h - 8, w, h), fill=JADE)

    font = _font(28)
    subtitle = "Farmacia & Salud  ·  Chinampac de Juárez, CDMX"
    tw = draw.textlength(subtitle, font=font)
    draw.text(((w - tw) / 2, y + logo.size[1] + 28), subtitle, font=font, fill=TEXT_MID)

    write_png(card, path)


def main() -> None:
    mark = outline_for_navy(icon_from_master())
    # Ya es wordmark blanco + cruz clara; NO quitar el blanco (borra el nombre).
    logo_light = Image.open(BRAND / "farmacapital-logo-full-light.png").convert("RGBA")

    print("Iconos PWA / favicon (cruz oficial sobre #001534)…")
    sizes = (16, 32, 48, 72, 96, 128, 192, 512)
    ico: list[Image.Image] = []
    for sz in sizes:
        app = paste_mark(sz, mark, bg=INK, pad=0.18)
        write_png(app, ICONS / f"farmacapital-{sz}.png")
        write_png(app, ICONS / f"farmacapital-{sz}-dark.png")
        if sz in (16, 32, 48):
            ico.append(app)

    write_png(paste_mark(180, mark, bg=INK, pad=0.16), PUBLIC / "apple-touch-icon.png")
    fav32 = paste_mark(32, mark, bg=INK, pad=0.12)
    write_png(fav32, PUBLIC / "favicon-32.png")
    write_png(fav32, PUBLIC / "favicon-32-dark.png")
    write_favicon_svg(fav32, PUBLIC / "favicon.svg")
    write_ico(ico, PUBLIC / "favicon.ico")
    write_ico(ico, PUBLIC / "favicon-light.ico")

    print("Tarjeta Open Graph 1200×630…")
    write_og_image(logo_light, PUBLIC / "og-image.png")
    print("Listo.")


if __name__ == "__main__":
    main()
