#!/usr/bin/env python3
"""Regenera PNG de marca FarmaCapital desde el logo maestro."""
from PIL import Image
import numpy as np
import os

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SRC = os.path.expanduser(
    "~/.cursor/projects/Users-ibarra-farmacapital/assets/image-21ba8be8-9e4f-4caf-bd2a-864d31e4da5a.png"
)

OUT_BRAND = os.path.join(ROOT, "public/brand")
OUT_ICONS = os.path.join(ROOT, "public/icons")
OUT_PUB = os.path.join(ROOT, "public")


def rgba_arr(im):
    return np.array(im.convert("RGBA"))


def content_mask(arr, tol=240):
    r, g, b, a = arr[:, :, 0], arr[:, :, 1], arr[:, :, 2], arr[:, :, 3]
    return (a > 10) & ~((r >= tol) & (g >= tol) & (b >= tol))


def trim_content(im, tol=240):
    arr = rgba_arr(im)
    m = content_mask(arr, tol)
    if not m.any():
        return im
    ys, xs = np.where(m)
    return im.crop((xs.min(), ys.min(), xs.max() + 1, ys.max() + 1))


def to_white(im):
    arr = rgba_arr(im)
    a = arr[:, :, 3]
    out = np.zeros_like(arr)
    out[:, :, 3] = a
    white = a > 0
    out[white, 0] = 255
    out[white, 1] = 255
    out[white, 2] = 255
    return Image.fromarray(out)


def fit_square(im, size, pad=0.1):
    im = trim_content(im)
    w, h = im.size
    inner = int(size * (1 - 2 * pad))
    scale = inner / max(w, h)
    nw, nh = max(1, int(w * scale)), max(1, int(h * scale))
    im2 = im.resize((nw, nh), Image.Resampling.LANCZOS)
    canvas = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    canvas.paste(im2, ((size - nw) // 2, (size - nh) // 2), im2)
    return canvas


def save_png(im, path):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    im.save(path, "PNG", optimize=True)


def scale_to_width(im, target_w):
    w, h = im.size
    nh = max(1, int(h * target_w / w))
    return im.resize((target_w, nh), Image.Resampling.LANCZOS)


def main():
    src = Image.open(SRC).convert("RGBA")
    w, h = src.size

    logo_main = trim_content(src.crop((0, 85, w, 134)))
    logo_admin = trim_content(src.crop((0, 85, w, 173)))
    icon_src = trim_content(src.crop((0, 85, 210, 173)))

    pairs = [
        (logo_main, "farmacapital-logo-full.png", 944),
        (logo_main, "farmacapital-logo-full@2x.png", 1888),
        (logo_admin, "farmacapital-logo-admin.png", 944),
        (logo_admin, "farmacapital-logo-admin@2x.png", 1888),
    ]
    for base, name, tw in pairs:
        save_png(scale_to_width(base, tw), os.path.join(OUT_BRAND, name))

    for name in (
        "farmacapital-logo-full.png",
        "farmacapital-logo-full@2x.png",
        "farmacapital-logo-admin.png",
        "farmacapital-logo-admin@2x.png",
    ):
        im = Image.open(os.path.join(OUT_BRAND, name))
        light_name = name.replace(".png", "-light.png")
        save_png(to_white(im), os.path.join(OUT_BRAND, light_name))

    # Alias tienda/header
    save_png(
        Image.open(os.path.join(OUT_BRAND, "farmacapital-logo-full-light.png")),
        os.path.join(OUT_BRAND, "farmacapital-logo-light.png"),
    )
    save_png(
        Image.open(os.path.join(OUT_BRAND, "farmacapital-logo-full-light@2x.png")),
        os.path.join(OUT_BRAND, "farmacapital-logo-light@2x.png"),
    )

    icon_master = fit_square(icon_src, 512, pad=0.1)
    save_png(icon_master, os.path.join(OUT_BRAND, "farmacapital-icon.png"))
    save_png(to_white(icon_master), os.path.join(OUT_BRAND, "farmacapital-icon-light.png"))

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
    print("OK full", full.size, "admin", admin.size)


if __name__ == "__main__":
    main()
