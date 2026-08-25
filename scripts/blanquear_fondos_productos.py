#!/usr/bin/env python3
"""Pasa packshots con fondo negro/transparente a JPEG sobre blanco.

El negro no es CSS: los WebP de Levic traen alfa y al guardarse como JPEG
el canvas/PIL pinta la transparencia de negro. Este script:

  1. Si el SKU es EQ-{CLAVE}, re-baja el WebP de Levic y lo aplana sobre blanco.
  2. Si no, rellena desde las esquinas los píxeles casi negros.

Solo toca Storage + imagen_url / imagen_mobile_url.
"""
from __future__ import annotations

import io
import json
import ssl
import time
import urllib.error
import urllib.request
from concurrent.futures import ThreadPoolExecutor, as_completed
from pathlib import Path

from PIL import Image

ROOT = Path("/Users/ibarra/farmacapital")
CACHE = f"v=20260818w"
CTX = ssl.create_default_context()
UA = "FarmaCapitalCatalog/1.0"
TH_CORNER = 24
LEVIC = "https://visoti.mx/imagenes/Grande/{clave}.webp"


def load_env():
    vals = {}
    for name in (".env", ".env.local"):
        path = ROOT / name
        if not path.exists():
            continue
        for line in path.read_text(encoding="utf-8").splitlines():
            line = line.strip()
            if not line or line.startswith("#") or "=" not in line:
                continue
            k, _, v = line.partition("=")
            vals.setdefault(k.strip(), v.strip().strip('"').strip("'"))
    return vals


def rest(url, key, method, path, data=None, content_type="application/json", extra=None):
    headers = {
        "apikey": key,
        "Authorization": f"Bearer {key}",
        "User-Agent": UA,
    }
    if content_type:
        headers["Content-Type"] = content_type
    if extra:
        headers.update(extra)
    body = data if isinstance(data, (bytes, bytearray)) else (None if data is None else json.dumps(data).encode())
    req = urllib.request.Request(url + path, data=body, method=method, headers=headers)
    try:
        with urllib.request.urlopen(req, context=CTX, timeout=90) as r:
            return r.status, r.read()
    except urllib.error.HTTPError as e:
        return e.code, e.read()


def fetch(url, timeout=40):
    req = urllib.request.Request(url, headers={"User-Agent": UA})
    with urllib.request.urlopen(req, context=CTX, timeout=timeout) as r:
        return r.read()


def flatten_white(im: Image.Image) -> Image.Image:
    if im.mode in ("RGBA", "LA") or (im.mode == "P" and "transparency" in im.info):
        rgba = im.convert("RGBA")
        bg = Image.new("RGBA", rgba.size, (255, 255, 255, 255))
        return Image.alpha_composite(bg, rgba).convert("RGB")
    return im.convert("RGB")


def corners_black(im: Image.Image) -> bool:
    rgb = im.convert("RGB")
    w, h = rgb.size
    if w < 8 or h < 8:
        return False
    px = rgb.load()
    pts = [(2, 2), (w - 3, 2), (2, h - 3), (w - 3, h - 3)]
    dark = 0
    for x, y in pts:
        r, g, b = px[x, y]
        if r <= TH_CORNER and g <= TH_CORNER and b <= TH_CORNER:
            dark += 1
    return dark >= 3


def jpeg_bytes(im: Image.Image) -> bytes:
    buf = io.BytesIO()
    im.save(buf, "JPEG", quality=90, optimize=True, subsampling=0)
    return buf.getvalue()


def flood_black_to_white(im: Image.Image, th: int = 28) -> Image.Image:
    rgb = im.convert("RGB")
    px = rgb.load()
    w, h = rgb.size
    from collections import deque
    seen = bytearray(w * h)
    q = deque()

    def dark(x, y):
        r, g, b = px[x, y]
        return r <= th and g <= th and b <= th

    seeds = [(0, 0), (w - 1, 0), (0, h - 1), (w - 1, h - 1)]
    for x in range(0, w, max(1, w // 8)):
        seeds.append((x, 0))
        seeds.append((x, h - 1))
    for y in range(0, h, max(1, h // 8)):
        seeds.append((0, y))
        seeds.append((w - 1, y))
    for x, y in seeds:
        if 0 <= x < w and 0 <= y < h and dark(x, y):
            q.append((x, y))
    while q:
        x, y = q.popleft()
        i = y * w + x
        if seen[i]:
            continue
        if not dark(x, y):
            continue
        seen[i] = 1
        px[x, y] = (255, 255, 255)
        if x + 1 < w:
            q.append((x + 1, y))
        if x:
            q.append((x - 1, y))
        if y + 1 < h:
            q.append((x, y + 1))
        if y:
            q.append((x, y - 1))
    return rgb


def levic_clave(sku: str):
    s = (sku or "").strip().upper()
    if s.startswith("EQ-") and len(s) > 3:
        return s[3:]
    return None


def process_one(prod, base, key):
    pid = prod["id"]
    sku = prod.get("sku") or ""
    src_url = (prod.get("imagen_url") or "").split("?")[0]
    if not src_url:
        return {"id": pid, "sku": sku, "ok": False, "reason": "sin_url"}

    raw = fetch(src_url)
    im = Image.open(io.BytesIO(raw))
    if not corners_black(im):
        return {"id": pid, "sku": sku, "ok": True, "reason": "ya_blanco"}

    out = None
    how = "flood"
    clave = levic_clave(sku)
    if clave:
        try:
            webp = fetch(LEVIC.format(clave=clave))
            src = Image.open(io.BytesIO(webp))
            if src.mode in ("RGBA", "LA") or (src.mode == "P" and "transparency" in src.info):
                out = flatten_white(src)
                how = "levic_alpha"
            elif not corners_black(src):
                out = flatten_white(src)
                how = "levic_rgb"
        except Exception:
            out = None

    if out is None:
        out = flood_black_to_white(flatten_white(im))
        how = "flood"

    payload = jpeg_bytes(out)
    object_path = f"/{pid}/desktop.jpg"
    st, raw_up = rest(
        base, key, "PUT",
        f"/storage/v1/object/productos{object_path}",
        data=payload,
        content_type="image/jpeg",
        extra={"x-upsert": "true", "cache-control": "3600"},
    )
    if st >= 400:
        return {"id": pid, "sku": sku, "ok": False, "reason": f"upload_{st}"}

    public = f"{base}/storage/v1/object/public/productos/{pid}/desktop.jpg?{CACHE}"
    st2, raw2 = rest(
        base, key, "PATCH",
        f"/rest/v1/productos?id=eq.{pid}",
        data={"imagen_url": public, "imagen_mobile_url": public},
        extra={"Prefer": "return=minimal"},
    )
    if st2 >= 400:
        return {"id": pid, "sku": sku, "ok": False, "reason": f"patch_{st2} {raw2[:120]!r}"}
    return {"id": pid, "sku": sku, "ok": True, "reason": how, "bytes": len(payload)}


def main():
    env = load_env()
    base = (env.get("REACT_APP_SUPABASE_URL") or "").rstrip("/")
    key = env.get("SUPABASE_SERVICE_ROLE_KEY") or env.get("REACT_APP_SUPABASE_ANON_KEY") or ""
    if not base or not key:
        raise SystemExit("Faltan credenciales Supabase")

    st, raw = rest(
        base, key, "GET",
        "/rest/v1/productos?select=id,sku,imagen_url&imagen_url=not.is.null&activo=eq.true&limit=5000",
    )
    if st >= 400:
        raise SystemExit(f"No pude leer productos: {st}")
    productos = json.loads(raw)
    print(json.dumps({"con_foto": len(productos)}, ensure_ascii=False))

    stats = {"ya_blanco": 0, "levic_alpha": 0, "levic_rgb": 0, "flood": 0, "fail": 0}
    t0 = time.time()
    with ThreadPoolExecutor(max_workers=8) as ex:
        futs = [ex.submit(process_one, p, base, key) for p in productos]
        for i, fut in enumerate(as_completed(futs), 1):
            r = fut.result()
            reason = r.get("reason") or "fail"
            if not r.get("ok"):
                stats["fail"] += 1
                print("FAIL", r)
            elif reason in stats:
                stats[reason] += 1
            else:
                stats[reason] = stats.get(reason, 0) + 1
            if i % 50 == 0:
                print(f"... {i}/{len(productos)} {stats}")
    print(json.dumps({"elapsed_s": round(time.time() - t0, 1), **stats}, ensure_ascii=False))


if __name__ == "__main__":
    main()
