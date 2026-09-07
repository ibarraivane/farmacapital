#!/usr/bin/env python3
"""Copia packshots Open Facts → public/catalogo-propia/cm-{ean}.jpg"""
from __future__ import annotations

import json
import urllib.request
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SRC = ROOT / "sql" / "generated" / "citymark_obf_lookup.json"
DEST = ROOT / "public" / "catalogo-propia"
UA = "FarmaCapital/1.0 (catalogo@farmacapital.mx)"


def main() -> None:
    DEST.mkdir(parents=True, exist_ok=True)
    rows = json.loads(SRC.read_text(encoding="utf-8"))
    ok = 0
    for r in rows:
        url = r.get("imagen")
        ean = r.get("ean")
        if not url or not ean:
            continue
        dest = DEST / f"cm-{ean}.jpg"
        if dest.exists() and dest.stat().st_size > 800:
            ok += 1
            continue
        req = urllib.request.Request(url, headers={"User-Agent": UA})
        try:
            with urllib.request.urlopen(req, timeout=20) as resp:
                data = resp.read()
            if len(data) < 800 or data[:3] not in (b"\xff\xd8\xff", b"\x89PN"):
                # jpeg o png; algunos CDN mandan webp
                if data[:4] != b"RIFF" and data[:3] not in (b"\xff\xd8\xff", b"\x89PN"):
                    print("skip", ean, "bytes", len(data))
                    continue
            dest.write_bytes(data)
            ok += 1
            print("ok", ean, dest.stat().st_size)
        except Exception as e:
            print("fail", ean, e)
    print(f"fotos {ok}")


if __name__ == "__main__":
    main()
