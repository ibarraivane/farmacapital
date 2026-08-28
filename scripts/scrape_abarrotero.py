#!/usr/bin/env python3
"""Extrae Farmacia + Cuidado personal de Abarrotero.com (WooCommerce Store API)."""

from __future__ import annotations

import argparse
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT))

from lib.pricing.adapters.abarrotero import AbarroteroAdapter  # noqa: E402


def main() -> int:
    p = argparse.ArgumentParser(description="Scrape Abarrotero → pricing/precios_proveedores/")
    p.add_argument("--force", action="store_true")
    p.add_argument("--sin-cache", action="store_true")
    args = p.parse_args()
    filas = AbarroteroAdapter().extraer(usar_cache=not args.sin_cache, force=args.force)
    print(f"Abarrotero: {len(filas)} filas")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
