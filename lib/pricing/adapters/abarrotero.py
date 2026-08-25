"""Abarrotero.com — WooCommerce Store API pública.

Precio tachado (regular) vs precio actual (sale). La venta es por caja:
se extraen las piezas del nombre para calcular precio unitario.
"""

from __future__ import annotations

import re
from datetime import date
from html import unescape
from pathlib import Path

from lib.pricing.adapter import ProveedorAdapter
from lib.pricing.http import HttpError, fetch_json, ruta_cache
from lib.pricing.normalize import extraer_tamano
from lib.pricing.schema import fila_vacia

BASE = "https://abarrotero.com"
STORE = f"{BASE}/wp-json/wc/store/v1/products"
# Farmacia + cuidado personal (IDs confirmados en el Store API)
CATEGORIAS = {
    6873: "farmacia",
    8221: "cuidado-personal",
}
PER_PAGE = 50


def _precio_wc(prices: dict | None) -> tuple[float | None, float | None]:
    """Devuelve (precio_actual, precio_tachado). currency_minor_unit=0 → pesos enteros."""
    if not prices:
        return None, None
    minor = int(prices.get("currency_minor_unit") or 0)
    factor = 10 ** minor

    def conv(key):
        raw = prices.get(key)
        if raw in (None, "", "0"):
            return None
        try:
            return float(raw) / factor
        except (TypeError, ValueError):
            return None

    actual = conv("sale_price") or conv("price")
    tachado = conv("regular_price")
    if tachado and actual and abs(tachado - actual) < 1e-6:
        tachado = None
    return actual, tachado


_RE_CAJA = re.compile(
    r"caja\s+con\s+(\d+)\s*(?:pzas?|piezas?|bolsas?|barras?|frascos?|unidades?)?",
    re.I,
)


def parsear_producto_wc(prod: dict, *, fecha: str) -> dict:
    nombre = unescape(str(prod.get("name") or "")).replace("&#8211;", "—")
    cats = prod.get("categories") or []
    categoria = cats[0]["name"] if cats else ""
    actual, tachado = _precio_wc(prod.get("prices"))
    tam = extraer_tamano(nombre)
    m_caja = _RE_CAJA.search(nombre)
    empaque = int(m_caja.group(1)) if m_caja else (tam.empaque_unidades if tam else 1)
    if tam and tam.unidad == "pza" and tam.cantidad > 1 and empaque == 1:
        # "Kit con 25 tests" → 25 piezas
        individuales = tam.cantidad
    elif tam and tam.unidad == "pza" and empaque > 1 and tam.empaque_unidades == 1:
        individuales = empaque * tam.cantidad
    else:
        individuales = empaque if empaque > 0 else 1
        if tam and tam.unidad == "pza":
            individuales = tam.piezas_totales() if tam.empaque_unidades > 1 else (empaque * (tam.cantidad if tam.cantidad > 1 else 1))

    if individuales <= 0:
        individuales = 1
    unitario = (actual / individuales) if actual is not None else None
    notas = ""
    if tachado:
        notas = f"tachado={tachado}; actual={actual}"
    presentacion = f"{tam.cantidad:g} {tam.unidad}" if tam else ""
    return fila_vacia(
        fuente="Abarrotero",
        tipo_fuente="mayorista",
        fecha_captura=fecha,
        url=prod.get("permalink") or "",
        categoria=categoria,
        producto_raw=nombre,
        marca="",
        presentacion=presentacion,
        unidad_base=tam.unidad if tam else "pza",
        cantidad_empaque=int(individuales) if individuales == int(individuales) else individuales,
        precio_empaque=actual,
        precio_unitario=round(unitario, 4) if unitario is not None else None,
        min_piezas=empaque if empaque > 1 else 1,
        precio_escalon=None,
        moneda=(prod.get("prices") or {}).get("currency_code") or "MXN",
        notas=notas,
        id_producto_proveedor=str(prod.get("sku") or prod.get("id") or ""),
    )


class AbarroteroAdapter(ProveedorAdapter):
    nombre = "Abarrotero"
    tipo_fuente = "mayorista"

    def extraer(self, *, usar_cache: bool = True, fecha: date | None = None, force: bool = False) -> list[dict]:
        root = Path(__file__).resolve().parents[3]
        d = fecha or date.today()
        dest = self.archivo_hoy(d)
        if dest.exists() and not force:
            return self.cargar_csv(dest)

        fecha_s = d.isoformat()
        fecha_dir = d.strftime("%Y%m%d")
        todas: list[dict] = []
        vistos: set[str] = set()
        for cat_id, slug in CATEGORIAS.items():
            page = 1
            while True:
                url = f"{STORE}?category={cat_id}&per_page={PER_PAGE}&page={page}"
                cache = ruta_cache(root, "abarrotero", fecha_dir, f"{slug}_p{page}.json")
                try:
                    payload = fetch_json(
                        url,
                        cache_path=cache,
                        usar_cache=usar_cache,
                        extra_headers={
                            "Referer": f"{BASE}/categoria-producto/{slug}/",
                            "Accept": "application/json",
                        },
                    )
                except HttpError as e:
                    print(f"  Abarrotero {slug} p{page}: {e}")
                    break
                if not isinstance(payload, list) or not payload:
                    break
                for prod in payload:
                    fila = parsear_producto_wc(prod, fecha=fecha_s)
                    key = fila["id_producto_proveedor"]
                    if key in vistos:
                        continue
                    vistos.add(key)
                    todas.append(fila)
                if len(payload) < PER_PAGE:
                    break
                page += 1
        self.guardar(todas, d)
        return todas
