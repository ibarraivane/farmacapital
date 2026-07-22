#!/usr/bin/env python3
"""
Regenera assets de marca FarmaCapital desde el PNG maestro del cliente.
Sin upscaling (evita pixelado) — solo recorte + iconos cuadrados.
"""
from PIL import Image
import numpy as np
import os
import shutil

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SRC = os.path.expanduser(
    "~/.cursor/projects/Users-ibarra-farmacapital/assets/image-21ba8be8-9e4f-4caf-bd2a-864d31e4da5a.png"
)
OUT_BRAND = os.path.join(ROOT, "public/brand")
OUT_ICONS = os.path.join(ROOT, "public/icons")
OUT_PUB = os.path.join(ROOT, "public")


def rgba_arr(im):
    return np.array(im.convert("RGBA"))


def knock_out_white(im, tol=245):
    arr = rgba_arr(im)
    r, g, b, a = arr[:, :, 0], arr[:, :, 1], arr[:, :, 2], arr[:, :, 3]
    white = (r >= tol) & (g >= tol) & (b >= tol)
    arr[white, 3] = 0
    return Image.fromarray(arr)


def trim_alpha(im):
    arr = rgba_arr(im)
    a = arr[:, :, 3]
    if not (a > 8).any():
        return im
    ys, xs = np.where(a > 8)
    return im.crop((xs.min(), ys.min(), xs.max() + 1, ys.max() + 1))


def fit_square(im, size, pad=0.12):
    im = trim_alpha(im)
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


def main():
    if not os.path.exists(SRC):
        raise SystemExit(f"No se encontró logo maestro: {SRC}")

    src = knock_out_white(Image.open(SRC).convert("RGBA"))
    w, h = src.size

    # Bandas verticales medidas en el PNG maestro (718×212)
    logo_main = trim_alpha(src.crop((0, 84, w, 134)))
    logo_admin = trim_alpha(src.crop((0, 84, w, 173)))
    icon_src = trim_alpha(src.crop((0, 84, 220, 173)))

    shutil.copy2(SRC, os.path.join(OUT_BRAND, "farmacapital-logo-master.png"))

    save_png(logo_main, os.path.join(OUT_BRAND, "farmacapital-logo-full.png"))
    save_png(logo_admin, os.path.join(OUT_BRAND, "farmacapital-logo-admin.png"))

    icon_master = fit_square(icon_src, 512, pad=0.1)
    save_png(icon_master, os.path.join(OUT_BRAND, "farmacapital-icon.png"))

    for s in (16, 32, 48, 72, 96, 128, 192, 512):
        save_png(fit_square(icon_src, s, pad=0.1), os.path.join(OUT_ICONS, f"farmacapital-{s}.png"))

    save_png(fit_square(icon_src, 180, pad=0.1), os.path.join(OUT_PUB, "apple-touch-icon.png"))
    save_png(fit_square(icon_src, 32, pad=0.1), os.path.join(OUT_PUB, "favicon-32.png"))

    ico_imgs = [fit_square(icon_src, s, pad=0.1).convert("RGBA") for s in (16, 32, 48)]
    ico_imgs[-1].save(
        os.path.join(OUT_PUB, "favicon.ico"),
        format="ICO",
        sizes=[(s, s) for s in (16, 32, 48)],
    )

    full = Image.open(os.path.join(OUT_BRAND, "farmacapital-logo-full.png"))
    admin = Image.open(os.path.join(OUT_BRAND, "farmacapital-logo-admin.png"))
    print("OK full", full.size, "admin", admin.size, "icon", icon_master.size)


if __name__ == "__main__":
    main()
