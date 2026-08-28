#!/usr/bin/env python3
"""Extrae el catálogo público de MayoreoTotal (Shopify) al esquema normalizado."""

from __future__ import annotations

import argparse
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT))

from lib.pricing.adapters.mayoreototal import MayoreoTotalAdapter  # noqa: E402


def main() -> int:
    p = argparse.ArgumentParser(description="Scrape MayoreoTotal → pricing/precios_proveedores/")
    p.add_argument("--force", action="store_true", help="Ignora el CSV del día y vuelve a bajar")
    p.add_argument("--sin-cache", action="store_true", help="No reutiliza JSON cacheado")
    args = p.parse_args()
    filas = MayoreoTotalAdapter().extraer(usar_cache=not args.sin_cache, force=args.force)
    print(f"MayoreoTotal: {len(filas)} filas")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
