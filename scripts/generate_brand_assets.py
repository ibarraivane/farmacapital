#!/usr/bin/env python3
"""
Regenera assets FarmaCapital desde PNG maestro en alta definición.
Fuente: public/brand/farmacapital-logo-master.png (1754×897)
"""
from PIL import Image
import numpy as np
import os
import shutil
import base64
from io import BytesIO

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


def png_to_b64(im):
    buf = BytesIO()
    im.save(buf, format="PNG", optimize=True)
    return base64.b64encode(buf.getvalue()).decode("ascii")


def write_favicon_svg(icon_light_im, icon_dark_im, path):
    """SVG con prefers-color-scheme — favicon adaptativo en navegadores modernos."""
    b64_light = png_to_b64(icon_light_im)
    b64_dark = png_to_b64(icon_dark_im)
    svg = f"""<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" viewBox="0 0 32 32">
  <style>
    #fc-icon-light {{ display: block; }}
    #fc-icon-dark {{ display: none; }}
    @media (prefers-color-scheme: dark) {{
      #fc-icon-light {{ display: none; }}
      #fc-icon-dark {{ display: block; }}
    }}
  </style>
  <image id="fc-icon-light" width="32" height="32" xlink:href="data:image/png;base64,{b64_light}"/>
  <image id="fc-icon-dark" width="32" height="32" xlink:href="data:image/png;base64,{b64_dark}"/>
</svg>
"""
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, "w", encoding="utf-8") as f:
        f.write(svg)


def make_light_variant(im):
    """Fondo oscuro: tinta navy → blanco. Conserva verde y azul de marca."""
    arr = rgba_arr(im).copy()
    r, g, b, a = arr[:, :, 0], arr[:, :, 1], arr[:, :, 2], arr[:, :, 3]
    visible = a > 10
    green = visible & (g > r + 25) & (g > b + 10) & (g > 80)
    blue = visible & ~green & (b > r + 15) & (b > 90)
    ink = visible & ~green & ~blue
    arr[ink, 0] = 255
    arr[ink, 1] = 255
    arr[ink, 2] = 255
    return Image.fromarray(arr)


def make_og_share(icon_light_im, path, *, size=(1200, 630), pad=0.16):
    """Tarjeta Open Graph / WhatsApp: solo isotipo (cruz) grande, centrado, sin recortes."""
    w, h = size
    ink = (0, 21, 52)  # #001534

    bg = Image.new("RGB", (w, h), ink)
    icon = trim_content(icon_light_im)
    iw, ih = icon.size
    max_w = int(w * (1 - 2 * pad))
    max_h = int(h * (1 - 2 * pad))
    scale = min(max_w / iw, max_h / ih)
    nw, nh = max(1, int(iw * scale)), max(1, int(ih * scale))
    icon = icon.resize((nw, nh), Image.Resampling.LANCZOS)
    layer = Image.new("RGBA", (nw, nh), (0, 0, 0, 0))
    layer.paste(icon, (0, 0), icon.split()[3] if icon.mode == "RGBA" else None)
    bg.paste(layer, ((w - nw) // 2, (h - nh) // 2), layer)
    save_png(bg.convert("RGB"), path)


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

    icon_light_src = make_light_variant(icon_src)
    make_og_share(icon_light_src, os.path.join(OUT_ICONS, "og-icon.png"))

    w, h = full.size
    save_png(full.resize((w // 2, max(1, h // 2)), Image.Resampling.LANCZOS),
             os.path.join(OUT_BRAND, "farmacapital-logo-full@1x.png"))
    lw, lh = light.size
    save_png(light.resize((lw // 2, max(1, lh // 2)), Image.Resampling.LANCZOS),
             os.path.join(OUT_BRAND, "farmacapital-logo-full-light@1x.png"))

    icon_master = fit_square(icon_src, 512, pad=0.16)
    save_png(icon_master, os.path.join(OUT_BRAND, "farmacapital-icon.png"))

    icon_light_src = make_light_variant(icon_src)
    icon_light_master = fit_square(icon_light_src, 512, pad=0.16)
    save_png(icon_light_master, os.path.join(OUT_BRAND, "farmacapital-icon-light.png"))

    for s in (16, 32, 48, 72, 96, 128, 192, 512):
        save_png(fit_square(icon_src, s, pad=0.08), os.path.join(OUT_ICONS, f"farmacapital-{s}.png"))
        save_png(fit_square(icon_light_src, s, pad=0.08), os.path.join(OUT_ICONS, f"farmacapital-{s}-dark.png"))

    save_png(fit_square(icon_src, 180, pad=0.08), os.path.join(OUT_PUB, "apple-touch-icon.png"))
    fav32 = fit_square(icon_src, 32, pad=0.08)
    fav32_dark = fit_square(icon_light_src, 32, pad=0.08)
    save_png(fav32, os.path.join(OUT_PUB, "favicon-32.png"))
    save_png(fav32_dark, os.path.join(OUT_PUB, "favicon-32-dark.png"))
    write_favicon_svg(fav32, fav32_dark, os.path.join(OUT_PUB, "favicon.svg"))

    ico = [fit_square(icon_src, s, pad=0.08).convert("RGBA") for s in (16, 32, 48)]
    ico[-1].save(os.path.join(OUT_PUB, "favicon.ico"), format="ICO", sizes=[(16, 16), (32, 32), (48, 48)])
    # favicon-light.ico: fallback cuando el navegador pide /favicon.ico en pestaña oscura
    ico_dark = [fit_square(icon_light_src, s, pad=0.08).convert("RGBA") for s in (16, 32, 48)]
    ico_dark[-1].save(os.path.join(OUT_PUB, "favicon-light.ico"), format="ICO", sizes=[(16, 16), (32, 32), (48, 48)])

    print("OK master", Image.open(MASTER).size, "full", full.size, "icon_box", icon_src.size)


if __name__ == "__main__":
    main()
