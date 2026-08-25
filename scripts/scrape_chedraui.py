#!/usr/bin/env python3
"""Benchmark Chedraui (VTEX). Las filas salen con tipo_fuente=benchmark_retail."""

from __future__ import annotations

import argparse
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT))

from lib.pricing.adapters.vtex import ChedrauiAdapter  # noqa: E402


def main() -> int:
    p = argparse.ArgumentParser()
    p.add_argument("--force", action="store_true")
    p.add_argument("--sin-cache", action="store_true")
    args = p.parse_args()
    filas = ChedrauiAdapter().extraer(usar_cache=not args.sin_cache, force=args.force)
    print(f"Chedraui (benchmark): {len(filas)} filas")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
