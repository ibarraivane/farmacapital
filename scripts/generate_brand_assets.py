#!/usr/bin/env python3
"""
Regenera assets FarmaCapital desde PNG maestro en alta definición.
Fuente: public/brand/farmacapital-logo-master.png (1754×897)
"""
from PIL import Image
import numpy as np
import os
import shutil

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
MASTER = os.path.join(ROOT, "public/brand/farmacapital-logo-master.png")
OUT_BRAND = os.path.join(ROOT, "public/brand")
OUT_ICONS = os.path.join(ROOT, "public/icons")
OUT_PUB = os.path.join(ROOT, "public")


def rgba_arr(im):
    return np.array(im.convert("RGBA"))


def knock_out_white(im, tol=240):
    arr = rgba_arr(im)
    r, g, b = arr[:, :, 0], arr[:, :, 1], arr[:, :, 2]
    white = (r >= tol) & (g >= tol) & (b >= tol)
    arr[white, 3] = 0
    return Image.fromarray(arr)


def content_bbox(im, tol=240):
    arr = rgba_arr(im)
    r, g, b, a = arr[:, :, 0], arr[:, :, 1], arr[:, :, 2], arr[:, :, 3]
    m = (a > 10) & ~((r >= tol) & (g >= tol) & (b >= tol))
    if not m.any():
        return (0, 0, im.size[0], im.size[1])
    ys, xs = np.where(m)
    return (xs.min(), ys.min(), xs.max() + 1, ys.max() + 1)


def trim_content(im, tol=240):
    x0, y0, x1, y1 = content_bbox(im, tol)
    return im.crop((x0, y0, x1, y1))


def icon_bbox(im, tol=240):
    """Icono = primer bloque horizontal denso (cruz + C verde)."""
    arr = rgba_arr(im)
    r, g, b = arr[:, :, 0], arr[:, :, 1], arr[:, :, 2]
    m = ~((r >= tol) & (g >= tol) & (b >= tol))
    col = m.sum(axis=0)
    w = im.size[0]
    x0, y0, x1, y1 = content_bbox(im, tol)
    in_block = False
    blocks = []
    start = 0
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
    if not blocks:
        return (x0, y0, x1, y1)
    ix0, ix1 = blocks[0]
    return (ix0, y0, ix1 + 1, y1)


def fit_square(im, size, pad=0.1):
    im = trim_content(im)
    w, h = im.size
    inner = max(1, int(size * (1 - 2 * pad)))
    scale = inner / max(w, h)
    nw, nh = max(1, int(w * scale)), max(1, int(h * scale))
    im2 = im.resize((nw, nh), Image.Resampling.LANCZOS)
    canvas = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    canvas.paste(im2, ((size - nw) // 2, (size - nh) // 2), im2)
    return canvas


def save_png(im, path):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    im.save(path, "PNG", optimize=True)


def make_light_variant(im):
    """Wordmark blanco + cruz blanca; conserva el verde de marca para fondos oscuros."""
    arr = rgba_arr(im).copy()
    r, g, b, a = arr[:, :, 0], arr[:, :, 1], arr[:, :, 2], arr[:, :, 3]
    visible = a > 10
    green = visible & (g > r + 35) & (g > b + 10) & (g > 100)
    colored = visible & ~green
    arr[colored, 0] = 255
    arr[colored, 1] = 255
    arr[colored, 2] = 255
    return Image.fromarray(arr)


def main():
    if not os.path.exists(MASTER):
        alt = os.path.expanduser("~/Downloads/Logo FarmaCapital.png")
        if os.path.exists(alt):
            shutil.copy2(alt, MASTER)
        else:
            raise SystemExit(f"Coloca el PNG maestro en {MASTER}")

    src = knock_out_white(Image.open(MASTER).convert("RGBA"))
    full = trim_content(src)
    ib = icon_bbox(src)
    icon_src = src.crop(ib)

    save_png(full, os.path.join(OUT_BRAND, "farmacapital-logo-full.png"))
    save_png(full, os.path.join(OUT_BRAND, "farmacapital-logo-admin.png"))

    light = make_light_variant(full)
    save_png(light, os.path.join(OUT_BRAND, "farmacapital-logo-full-light.png"))

    w, h = full.size
    save_png(full.resize((w // 2, max(1, h // 2)), Image.Resampling.LANCZOS),
             os.path.join(OUT_BRAND, "farmacapital-logo-full@1x.png"))
    lw, lh = light.size
    save_png(light.resize((lw // 2, max(1, lh // 2)), Image.Resampling.LANCZOS),
             os.path.join(OUT_BRAND, "farmacapital-logo-full-light@1x.png"))

    icon_master = fit_square(icon_src, 512, pad=0.08)
    save_png(icon_master, os.path.join(OUT_BRAND, "farmacapital-icon.png"))

    for s in (16, 32, 48, 72, 96, 128, 192, 512):
        save_png(fit_square(icon_src, s, pad=0.08), os.path.join(OUT_ICONS, f"farmacapital-{s}.png"))

    save_png(fit_square(icon_src, 180, pad=0.08), os.path.join(OUT_PUB, "apple-touch-icon.png"))
    save_png(fit_square(icon_src, 32, pad=0.08), os.path.join(OUT_PUB, "favicon-32.png"))

    ico = [fit_square(icon_src, s, pad=0.08).convert("RGBA") for s in (16, 32, 48)]
    ico[-1].save(os.path.join(OUT_PUB, "favicon.ico"), format="ICO", sizes=[(16, 16), (32, 32), (48, 48)])

    print("OK master", Image.open(MASTER).size, "full", full.size, "icon_box", icon_src.size)


if __name__ == "__main__":
    main()
