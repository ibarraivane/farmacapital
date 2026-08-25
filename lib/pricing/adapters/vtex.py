"""Benchmark retail VTEX (Chedraui, Walmart si aplica).

tipo_fuente = benchmark_retail → NUNCA entra al cálculo de costo / mejor compra.
Solo sirve para «¿mi precio de venta es competitivo?».

Endpoint:
  /api/catalog_system/pub/products/search?fq=...&_from=0&_to=49
"""

from __future__ import annotations

from datetime import date
from pathlib import Path

from lib.pricing.adapter import ProveedorAdapter
from lib.pricing.http import fetch_json, ruta_cache
from lib.pricing.normalize import extraer_tamano
from lib.pricing.schema import fila_vacia

PAGE = 50


def parsear_vtex(payload: list, *, fuente: str, fecha: str) -> list[dict]:
    filas = []
    for prod in payload or []:
        nombre = str(prod.get("productName") or prod.get("productTitle") or "").strip()
        marca = str(prod.get("brand") or "").strip()
        cats = prod.get("categories") or []
        categoria = cats[0] if cats else ""
        link = prod.get("link") or ""
        tam = extraer_tamano(nombre)
        items = prod.get("items") or []
        for item in items:
            sellers = item.get("sellers") or []
            offer = (sellers[0].get("commertialOffer") if sellers else {}) or {}
            precio = offer.get("Price")
            try:
                precio = float(precio) if precio not in (None, "") else None
            except (TypeError, ValueError):
                precio = None
            sku = str(item.get("itemId") or item.get("ean") or prod.get("productId") or "")
            empaque = tam.empaque_unidades if tam else 1
            individuales = tam.piezas_totales() if tam and tam.unidad == "pza" else empaque
            if individuales <= 0:
                individuales = 1
            unitario = (precio / individuales) if precio is not None else None
            filas.append(fila_vacia(
                fuente=fuente,
                tipo_fuente="benchmark_retail",
                fecha_captura=fecha,
                url=link,
                categoria=categoria,
                producto_raw=nombre,
                marca=marca,
                presentacion=f"{tam.cantidad:g} {tam.unidad}" if tam else "",
                unidad_base=tam.unidad if tam else "pza",
                cantidad_empaque=individuales,
                precio_empaque=precio,
                precio_unitario=round(unitario, 4) if unitario is not None else None,
                moneda="MXN",
                notas="benchmark_retail: no usar como costo de compra",
                id_producto_proveedor=sku,
            ))
    return filas


class VtexBenchmarkAdapter(ProveedorAdapter):
    tipo_fuente = "benchmark_retail"
    requiere_credenciales = False
    host: str = ""
    fq: str = ""  # filtro de categoría opcional

    def extraer(self, *, usar_cache: bool = True, fecha: date | None = None, force: bool = False) -> list[dict]:
        root = Path(__file__).resolve().parents[3]
        d = fecha or date.today()
        dest = self.archivo_hoy(d)
        if dest.exists() and not force:
            return self.cargar_csv(dest)
        if not self.host:
            return []

        fecha_s = d.isoformat()
        fecha_dir = d.strftime("%Y%m%d")
        slug = self.nombre.lower()
        todas: list[dict] = []
        inicio = 0
        while True:
            fin = inicio + PAGE - 1
            q = f"fq={self.fq}&" if self.fq else ""
            url = f"https://{self.host}/api/catalog_system/pub/products/search?{q}_from={inicio}&_to={fin}"
            cache = ruta_cache(root, slug, fecha_dir, f"search_{inicio}_{fin}.json")
            try:
                payload = fetch_json(url, cache_path=cache, usar_cache=usar_cache)
            except Exception:
                break
            if not isinstance(payload, list) or not payload:
                break
            todas.extend(parsear_vtex(payload, fuente=self.nombre, fecha=fecha_s))
            if len(payload) < PAGE:
                break
            inicio += PAGE
        self.guardar(todas, d)
        return todas


class ChedrauiAdapter(VtexBenchmarkAdapter):
    nombre = "Chedraui"
    host = "www.chedraui.com.mx"


class WalmartAdapter(VtexBenchmarkAdapter):
    """Walmart MX no siempre es VTEX; el adapter intenta el endpoint y si falla queda vacío."""

    nombre = "Walmart"
    host = "super.walmart.com.mx"
