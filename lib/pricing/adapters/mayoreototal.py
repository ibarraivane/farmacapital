"""MayoreoTotal (Shopify) — GET /products.json paginado.

Fuente pública, estable. Es la referencia del esquema normalizado.
"""

from __future__ import annotations

from datetime import date
from html import unescape

from lib.pricing.adapter import ProveedorAdapter
from lib.pricing.http import fetch_json, ruta_cache
from lib.pricing.normalize import extraer_tamano, inferir_tipo
from lib.pricing.schema import fila_vacia

ROOT_HTTP = None  # se resuelve en extraer
BASE = "https://mayoreototal.mx"
PAGE_SIZE = 250


def _precio(v) -> float | None:
    try:
        return float(str(v).replace(",", ""))
    except (TypeError, ValueError):
        return None


def parsear_products_json(payload: dict, *, fecha: str) -> list[dict]:
    """Convierte un page de products.json a filas normalizadas (una por variante)."""
    filas = []
    for prod in payload.get("products") or []:
        handle = prod.get("handle") or ""
        title = unescape(str(prod.get("title") or "")).strip()
        vendor = (prod.get("vendor") or "").strip()
        ptype = (prod.get("product_type") or "").strip()
        tags = prod.get("tags") or []
        if isinstance(tags, str):
            tags = [t.strip() for t in tags.split(",")]
        categoria = ptype or (tags[0] if tags else "")
        url = f"{BASE}/products/{handle}" if handle else BASE
        marca = vendor if vendor and vendor.lower() not in {"mayoreototal", "mayoreo total"} else ""
        tam = extraer_tamano(title)
        for var in prod.get("variants") or []:
            precio = _precio(var.get("price"))
            sku = str(var.get("sku") or var.get("id") or "").strip()
            var_title = var.get("title") or ""
            nombre = title if var_title in ("", "Default Title") else f"{title} {var_title}"
            empaque = tam.empaque_unidades if tam else 1
            piezas = tam.piezas_totales() if tam and tam.unidad == "pza" else empaque
            if piezas <= 0:
                piezas = 1
            unitario = (precio / piezas) if precio is not None else None
            presentacion = ""
            if tam:
                presentacion = f"{tam.cantidad:g} {tam.unidad}"
                if empaque > 1:
                    presentacion = f"{empaque} × {presentacion}"
            filas.append(fila_vacia(
                fuente="MayoreoTotal",
                tipo_fuente="mayorista",
                fecha_captura=fecha,
                url=url,
                categoria=categoria,
                producto_raw=nombre,
                marca=marca,
                presentacion=presentacion,
                unidad_base=tam.unidad if tam else "pza",
                cantidad_empaque=int(piezas) if piezas == int(piezas) else piezas,
                precio_empaque=precio,
                precio_unitario=round(unitario, 4) if unitario is not None else None,
                min_piezas=1,
                precio_escalon=None,
                moneda="MXN",
                notas=f"tipo={inferir_tipo(nombre) or '-'}; shopify_id={prod.get('id')}",
                id_producto_proveedor=sku or str(prod.get("id")),
            ))
    return filas


class MayoreoTotalAdapter(ProveedorAdapter):
    nombre = "MayoreoTotal"
    tipo_fuente = "mayorista"

    def extraer(self, *, usar_cache: bool = True, fecha: date | None = None, force: bool = False) -> list[dict]:
        from pathlib import Path

        root = Path(__file__).resolve().parents[3]
        d = fecha or date.today()
        dest = self.archivo_hoy(d)
        if dest.exists() and not force:
            return self.cargar_csv(dest)

        fecha_s = d.isoformat()
        fecha_dir = d.strftime("%Y%m%d")
        todas: list[dict] = []
        page = 1
        while True:
            url = f"{BASE}/products.json?limit={PAGE_SIZE}&page={page}"
            cache = ruta_cache(root, "mayoreototal", fecha_dir, f"products_p{page}.json")
            payload = fetch_json(url, cache_path=cache, usar_cache=usar_cache)
            productos = payload.get("products") if isinstance(payload, dict) else []
            if not productos:
                break
            todas.extend(parsear_products_json(payload, fecha=fecha_s))
            if len(productos) < PAGE_SIZE:
                break
            page += 1
        self.guardar(todas, d)
        return todas
