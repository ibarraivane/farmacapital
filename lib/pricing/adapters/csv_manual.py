"""Adapters CSV/EDI para distribuidores farmacéuticos (requieren credenciales).

No scrapean. Cuando exista un archivo de catálogo con precios en
pricing/precios_proveedores/{Fuente}_YYYYMMDD.csv (o un CSV genérico),
entra al mismo pipeline sin tocar el resto del código.

Columnas aceptadas (cualquiera de):
  - esquema normalizado (fuente, producto_raw, precio_empaque, ...)
  - genérico: sku / codigo, nombre / producto, precio / costo, marca
"""

from __future__ import annotations

import csv
from datetime import date
from pathlib import Path

from lib.pricing.adapter import AdapterManualCSV
from lib.pricing.normalize import extraer_tamano
from lib.pricing.schema import COLUMNAS_CSV, fila_vacia

ROOT = Path(__file__).resolve().parents[3]
DIR = ROOT / "pricing" / "precios_proveedores"


def _money(v) -> float | None:
    if v is None or v == "":
        return None
    s = str(v).replace("$", "").replace(",", "").strip()
    try:
        return float(s)
    except ValueError:
        return None


def normalizar_fila_manual(row: dict, *, fuente: str, fecha: str) -> dict:
    if "producto_raw" in row and "precio_empaque" in row:
        out = fila_vacia(**{k: row.get(k) for k in COLUMNAS_CSV if k in row})
        out["fuente"] = fuente
        out["tipo_fuente"] = "distribuidor_farma"
        out["fecha_captura"] = row.get("fecha_captura") or fecha
        return out

    nombre = (row.get("nombre") or row.get("producto") or row.get("descripcion") or "").strip()
    precio = _money(row.get("precio") or row.get("costo") or row.get("precio_mayoreo") or row.get("precio_empaque"))
    tam = extraer_tamano(nombre + " " + str(row.get("presentacion") or ""))
    empaque = int(row.get("cantidad_empaque") or (tam.empaque_unidades if tam else 1) or 1)
    individuales = tam.piezas_totales() if tam and tam.unidad == "pza" else empaque
    if individuales <= 0:
        individuales = 1
    unitario = (precio / individuales) if precio is not None else None
    return fila_vacia(
        fuente=fuente,
        tipo_fuente="distribuidor_farma",
        fecha_captura=fecha,
        producto_raw=nombre,
        marca=(row.get("marca") or "").strip(),
        presentacion=(row.get("presentacion") or (f"{tam.cantidad:g} {tam.unidad}" if tam else "")),
        unidad_base=tam.unidad if tam else "pza",
        cantidad_empaque=individuales,
        precio_empaque=precio,
        precio_unitario=round(unitario, 4) if unitario is not None else None,
        moneda="MXN",
        notas="carga_manual_csv",
        id_producto_proveedor=str(row.get("sku") or row.get("codigo") or row.get("ean") or nombre)[:80],
    )


class DistribuidorFarmaAdapter(AdapterManualCSV):
    def __init__(self, nombre: str):
        self.nombre = nombre

    def extraer(self, *, usar_cache: bool = True, fecha: date | None = None, force: bool = False) -> list[dict]:
        d = fecha or date.today()
        cands = sorted(DIR.glob(f"{self.nombre}_*.csv"))
        if not cands:
            return []
        path = cands[-1]
        fecha_s = d.isoformat()
        filas = []
        with path.open(encoding="utf-8", newline="") as fh:
            for row in csv.DictReader(fh):
                filas.append(normalizar_fila_manual(row, fuente=self.nombre, fecha=fecha_s))
        return filas


DISTRIBUIDORES_FARMA = [
    "Nadro",
    "Marzam",
    "Difarmer",
    "Levic",
    "FarmacosNacionales",
    "AlmacenDeDrogas",
]


def adapters_farma() -> list[DistribuidorFarmaAdapter]:
    return [DistribuidorFarmaAdapter(n) for n in DISTRIBUIDORES_FARMA]
