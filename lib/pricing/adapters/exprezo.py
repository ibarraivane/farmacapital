"""Cargador del CSV histórico de Exprezo (formato Categoria/Producto/Precio Mayoreo).

No scrapea: Exprezo es portal con login. Normaliza el archivo ya extraído al esquema común.
"""

from __future__ import annotations

import csv
import re
from datetime import date
from pathlib import Path

from lib.pricing.adapter import ProveedorAdapter
from lib.pricing.normalize import extraer_tamano
from lib.pricing.schema import fila_vacia

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


def parsear_csv_exprezo(path: Path, *, fecha: str) -> list[dict]:
    filas = []
    with path.open(encoding="utf-8", newline="") as fh:
        for i, row in enumerate(csv.DictReader(fh), start=2):
            nombre = (row.get("Producto") or row.get("producto") or "").strip()
            if not nombre:
                continue
            mayoreo = _money(row.get("Precio Mayoreo") or row.get("precio_mayoreo"))
            tam = extraer_tamano(nombre)
            empaque = tam.empaque_unidades if tam else 1
            individuales = tam.piezas_totales() if tam and tam.unidad == "pza" else empaque
            if individuales <= 0:
                individuales = 1
            unitario = (mayoreo / individuales) if mayoreo is not None else None
            notas = ""
            sitio_unidad = _money(row.get("Precio por Unidad") or row.get("precio_unidad"))
            if sitio_unidad is not None:
                notas = f"sitio_reporta_unidad={sitio_unidad} (no se usa; se calcula)"
            filas.append(fila_vacia(
                fuente="Exprezo",
                tipo_fuente="mayorista",
                fecha_captura=fecha,
                url="",
                categoria=(row.get("Categoria") or row.get("categoria") or "").strip(),
                producto_raw=nombre,
                marca="",
                presentacion=f"{tam.cantidad:g} {tam.unidad}" if tam else "",
                unidad_base=tam.unidad if tam else "pza",
                cantidad_empaque=int(individuales) if individuales == int(individuales) else individuales,
                precio_empaque=mayoreo,
                precio_unitario=round(unitario, 4) if unitario is not None else None,
                min_piezas=1,
                moneda="MXN",
                notas=notas,
                id_producto_proveedor=f"exprezo-{i}-{re.sub(r'[^a-z0-9]+', '-', nombre.lower())[:40]}",
            ))
    return filas


class ExprezoAdapter(ProveedorAdapter):
    nombre = "Exprezo"
    tipo_fuente = "mayorista"

    def extraer(self, *, usar_cache: bool = True, fecha: date | None = None, force: bool = False) -> list[dict]:
        from lib.pricing.io_csv import escribir_csv

        d = fecha or date.today()
        dest = self.archivo_hoy(d)
        origen = DIR / "Exprezo_20260812.csv"
        # Nunca sobrescribir el CSV histórico de 4 columnas.
        if dest.resolve() == origen.resolve():
            dest = DIR / "Exprezo_norm.csv"
        if dest.exists() and not force:
            return self.cargar_csv(dest)
        if not origen.exists():
            return self.cargar_csv()
        filas = parsear_csv_exprezo(origen, fecha="2026-08-12")
        escribir_csv(dest, filas)
        return filas
