#!/usr/bin/env python3
"""Extrae Higiene / Pañales de Scorpion (Magento) con escalones de volumen."""

from __future__ import annotations

import argparse
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT))

from lib.pricing.adapters.scorpion import ScorpionAdapter  # noqa: E402


def main() -> int:
    p = argparse.ArgumentParser(description="Scrape Scorpion → pricing/precios_proveedores/")
    p.add_argument("--force", action="store_true")
    p.add_argument("--sin-cache", action="store_true")
    args = p.parse_args()
    filas = ScorpionAdapter().extraer(usar_cache=not args.sin_cache, force=args.force)
    print(f"Scorpion: {len(filas)} filas")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
