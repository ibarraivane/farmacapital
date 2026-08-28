"""Esquema normalizado de precios de proveedor.

Todas las fuentes (Shopify, Magento, WooCommerce, CSV/EDI) se reducen a estas
columnas exactas antes de matchear contra el catálogo FarmaCapital.
"""

from __future__ import annotations

from datetime import date

COLUMNAS_NORMALIZADAS = [
    "fuente",
    "tipo_fuente",
    "fecha_captura",
    "url",
    "categoria",
    "producto_raw",
    "marca",
    "presentacion",
    "unidad_base",
    "cantidad_empaque",
    "precio_empaque",
    "precio_unitario",
    "min_piezas",
    "precio_escalon",
    "moneda",
    "minimo_compra_pedido",
    "notas",
    # extras internos (no pedidas en el CSV público, pero útiles para matching)
    "id_producto_proveedor",
]

TIPO_FUENTE = ("mayorista", "distribuidor_farma", "benchmark_retail")
UNIDAD_BASE = ("g", "ml", "pza")

# Columnas que se escriben al CSV público (sin id interno al final si se prefiere
# dejarlo: el prompt pide las 17 primeras; id se guarda igual para matches).
COLUMNAS_CSV = COLUMNAS_NORMALIZADAS[:]


def fila_vacia(**kwargs) -> dict:
    """Fila normalizada con defaults. Sobrescribir con kwargs."""
    base = {
        "fuente": "",
        "tipo_fuente": "mayorista",
        "fecha_captura": date.today().isoformat(),
        "url": "",
        "categoria": "",
        "producto_raw": "",
        "marca": "",
        "presentacion": "",
        "unidad_base": "pza",
        "cantidad_empaque": 1,
        "precio_empaque": None,
        "precio_unitario": None,
        "min_piezas": 1,
        "precio_escalon": None,
        "moneda": "MXN",
        "minimo_compra_pedido": None,
        "notas": "",
        "id_producto_proveedor": "",
    }
    base.update(kwargs)
    return base


def nombre_archivo_fuente(fuente: str, fecha: date | None = None) -> str:
    """Patrón Exprezo_YYYYMMDD.csv."""
    d = fecha or date.today()
    return f"{fuente}_{d.strftime('%Y%m%d')}.csv"
