#!/usr/bin/env python3
"""Orquesta extractores + matching + Comparativo_Multiproveedor_{YYYYMMDD}.xlsx.

Uso:
  PYTHONPATH=. python3 scripts/run_pricing.py
  python3 scripts/run_pricing.py --saltar-scrape --fuentes MayoreoTotal,Exprezo
  python3 scripts/run_pricing.py --con-benchmark   # incluye Chedraui/Walmart (no van a costo)
"""

from __future__ import annotations

import argparse
import sys
from datetime import date
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT))

from lib.pricing.io_csv import cargar_catalogo  # noqa: E402
from lib.pricing.match import (  # noqa: E402
    ProductoCatalogo,
    ProductoProveedor,
    cargar_confirmados,
    enriquecer_catalogo,
    enriquecer_proveedor,
    matchear_fuente,
)
from lib.pricing.registro import BENCHMARK, PRIORIDAD_SCRAPE, todos_adapters  # noqa: E402
from lib.pricing.report import escribir_comparativo  # noqa: E402


def _num(v):
    if v in (None, ""):
        return None
    try:
        return float(v)
    except (TypeError, ValueError):
        return None


def fila_a_proveedor(row: dict) -> ProductoProveedor:
    return ProductoProveedor(
        fuente=row.get("fuente") or "",
        id_producto_proveedor=str(row.get("id_producto_proveedor") or ""),
        producto_raw=row.get("producto_raw") or "",
        marca=row.get("marca") or "",
        presentacion=row.get("presentacion") or "",
        tipo_fuente=row.get("tipo_fuente") or "mayorista",
        precio_empaque=_num(row.get("precio_empaque")),
        precio_unitario=_num(row.get("precio_unitario")),
        cantidad_empaque=int(float(row.get("cantidad_empaque") or 1)),
        min_piezas=int(float(row.get("min_piezas") or 1)),
        precio_escalon=_num(row.get("precio_escalon")),
        minimo_compra_pedido=_num(row.get("minimo_compra_pedido")),
        url=row.get("url") or "",
        categoria=row.get("categoria") or "",
    )


def main() -> int:
    p = argparse.ArgumentParser(description="Pipeline multi-proveedor FarmaCapital")
    p.add_argument("--fuentes", default="", help="Lista separada por comas (default: prioridad 1 + Exprezo)")
    p.add_argument("--saltar-scrape", action="store_true", help="Solo lee CSVs ya guardados")
    p.add_argument("--force", action="store_true")
    p.add_argument("--sin-cache", action="store_true")
    p.add_argument("--con-benchmark", action="store_true", help="Suma Walmart/Chedraui (solo venta)")
    p.add_argument("--catalogo", default="", help="CSV o xlsx del inventario (default: preview CSV)")
    args = p.parse_args()

    adapters = todos_adapters()
    if args.fuentes:
        nombres = [x.strip().lower() for x in args.fuentes.split(",") if x.strip()]
    else:
        nombres = list(PRIORIDAD_SCRAPE)
        if args.con_benchmark:
            nombres.extend(BENCHMARK)

    catalogo_raw = cargar_catalogo(Path(args.catalogo) if args.catalogo else None)
    catalogo = enriquecer_catalogo([
        ProductoCatalogo(
            sku=r["sku"],
            nombre=r["nombre"],
            marca=r["marca"],
            presentacion=r.get("presentacion") or "",
            costo=r.get("costo"),
            precio_venta=r.get("precio_venta"),
            tipo=r.get("tipo") or "",
        )
        for r in catalogo_raw
    ])
    marcas = [c.marca for c in catalogo]
    confirmados = cargar_confirmados()
    print(f"Catálogo: {len(catalogo)} SKUs. Confirmados manuales: {len(confirmados)}")

    por_fuente = {}
    for nom in nombres:
        ad = adapters.get(nom)
        if ad is None:
            print(f"  (fuente desconocida: {nom})")
            continue
        print(f"→ {ad.nombre} ({ad.tipo_fuente}"
              f"{', credenciales/CSV' if ad.requiere_credenciales else ''})")
        if args.saltar_scrape:
            filas = ad.cargar_csv()
        else:
            try:
                filas = ad.extraer(usar_cache=not args.sin_cache, force=args.force)
            except Exception as e:
                print(f"  error extrayendo {ad.nombre}: {e}")
                filas = ad.cargar_csv()
        if not filas:
            print(f"  sin filas (¿falta CSV de {ad.nombre}?)")
            continue
        provs = enriquecer_proveedor([fila_a_proveedor(f) for f in filas], marcas)
        matches = matchear_fuente(catalogo, provs, ad.nombre, confirmados)
        a = sum(1 for m in matches if m.nivel in {"A", "confirmado"} and m.proveedor)
        b = sum(1 for m in matches if m.nivel == "B" and m.proveedor)
        c = sum(1 for m in matches if m.nivel == "C")
        print(f"  {len(filas)} productos · matches A={a} B={b} C(revisión)={c}")
        por_fuente[ad.nombre] = matches

    if not por_fuente:
        print("Nada que reportar.")
        return 1

    dest = ROOT / "pricing" / "reportes" / f"Comparativo_Multiproveedor_{date.today().strftime('%Y%m%d')}.xlsx"
    escribir_comparativo(catalogo, por_fuente, dest)
    print(f"Listo: {dest}")
    print("FarmaCapital_vs_Exprezo.xlsx no se tocó.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
