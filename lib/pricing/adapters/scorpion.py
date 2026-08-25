"""Scorpion (scorpion.com.mx) — Magento, precios escalonados por volumen.

Patrón: Pieza $X · Desde N Pieza(s) $Y c/u · Caja M Pieza(s) $Z c/u
"""

from __future__ import annotations

import re
from datetime import date
from html import unescape
from pathlib import Path

from lib.pricing.adapter import ProveedorAdapter
from lib.pricing.http import fetch, ruta_cache
from lib.pricing.normalize import extraer_tamano
from lib.pricing.schema import fila_vacia

BASE = "https://www.scorpion.com.mx"
CATEGORIAS = [
    "/tienda/higiene-y-cuidado-personal.html",
    "/tienda/bebes/pa-ales-y-toallas.html",
    "/tienda/bebes/pa-ales-y-toallas/pa-ales.html",
    "/tienda/bebes/pa-ales-y-toallas/toallas.html",
    "/tienda/higiene-y-cuidado-personal/proteccion-femenina.html",
    "/tienda/higiene-y-cuidado-personal/cuidado-del-cabello.html",
    "/tienda/higiene-y-cuidado-personal/cuidado-corporal-y-de-manos.html",
    "/tienda/higiene-y-cuidado-personal/cuidado-bucal.html",
    "/tienda/higiene-y-cuidado-personal/cuidado-facial-y-afeitado.html",
]

_RE_LINK = re.compile(
    r'<a class="product-item-link" href="([^"]+)">\s*([^<]+?)\s*</a>',
    re.I,
)
_RE_ID = re.compile(r'data-product-id="(\d+)"')
_RE_PIEZA = re.compile(
    r"<h4>\s*Pieza\s*</h4>\s*<div class=\"price\"><span class=\"price\">\$([0-9.,]+)",
    re.I,
)
_RE_DESDE_PRECIO = re.compile(
    r"Desde(?:\s|<[^>]+>)*?(\d+)\s*Pieza(?:s|\(s\))?(?:\s|<[^>]+>)*?\$([0-9.,]+)\s*c/u",
    re.I,
)
_RE_CAJA = re.compile(
    r"Caja(?:\s|<[^>]+>)*?(\d+)\s*Pieza(?:s|\(s\))?(?:\s|<[^>]+>)*?\$([0-9.,]+)\s*c/u",
    re.I,
)
_RE_PAGINAS = re.compile(r"[?&]p=(\d+)")
_RE_BLOQUE = re.compile(
    r'(<div class="product-item-info.*?)(?=<div class="product-item-info|$)',
    re.S | re.I,
)


def _money(s: str) -> float | None:
    try:
        return float(s.replace(",", "").strip())
    except (TypeError, ValueError):
        return None


def parsear_listado(html: str, *, fecha: str, categoria: str) -> list[dict]:
    """Parsea una página de categoría Magento a filas normalizadas."""
    bloques = _RE_BLOQUE.findall(html)
    if not bloques:
        # fallback: partir por cada product-item-link
        partes = html.split('class="product-item-link"')
        bloques = partes[1:] if len(partes) > 1 else []
        bloques = ['<a class="product-item-link"' + b for b in bloques]

    filas = []
    vistos: set[str] = set()
    for bloque in bloques:
        m_link = _RE_LINK.search(bloque) or re.search(
            r'href="([^"]+\.html)"[^>]*>\s*([^<]+)', bloque
        )
        if not m_link:
            continue
        url, nombre = m_link.group(1), unescape(m_link.group(2)).strip()
        if url in vistos:
            continue
        vistos.add(url)
        m_id = _RE_ID.search(bloque)
        pid = m_id.group(1) if m_id else url.rsplit("/", 1)[-1]
        m_pieza = _RE_PIEZA.search(bloque)
        precio_pieza = _money(m_pieza.group(1)) if m_pieza else None
        m_desde = _RE_DESDE_PRECIO.search(bloque)
        min_piezas, precio_escalon = 1, None
        if m_desde:
            min_piezas = int(m_desde.group(1))
            precio_escalon = _money(m_desde.group(2))
        m_caja = _RE_CAJA.search(bloque)
        piezas_caja, precio_caja = None, None
        if m_caja:
            piezas_caja = int(m_caja.group(1))
            precio_caja = _money(m_caja.group(2))

        tam = extraer_tamano(nombre)
        # Empaque: preferir "Caja N Pieza(s)" del sitio; si el nombre trae 14/8, N=14.
        if piezas_caja:
            empaque = piezas_caja
        elif tam:
            empaque = tam.empaque_unidades
        else:
            empaque = 1

        precio_empaque = precio_caja if precio_caja is not None else precio_pieza
        # Piezas individuales: empaque × tamaño interno si es pza (8 toallas × 14 packs)
        if tam and tam.unidad == "pza" and tam.cantidad > 1:
            individuales = empaque * tam.cantidad if tam.empaque_unidades == 1 else tam.piezas_totales()
            # Si el sitio ya dio N packs (caja) y el nombre es "paquete con 8", individuales = N*8
            if piezas_caja and tam.empaque_unidades == 1:
                individuales = piezas_caja * tam.cantidad
        else:
            individuales = empaque

        if not individuales:
            individuales = 1
        unitario = (precio_empaque / individuales) if precio_empaque is not None else None

        presentacion = ""
        if tam:
            presentacion = f"{tam.cantidad:g} {tam.unidad}"
        notas = f"pieza={precio_pieza}; caja={precio_caja}x{piezas_caja}; envio $70 / gratis $1100"
        filas.append(fila_vacia(
            fuente="Scorpion",
            tipo_fuente="mayorista",
            fecha_captura=fecha,
            url=url,
            categoria=categoria,
            producto_raw=nombre,
            marca="",
            presentacion=presentacion,
            unidad_base=tam.unidad if tam else "pza",
            cantidad_empaque=int(individuales) if individuales == int(individuales) else individuales,
            precio_empaque=precio_empaque,
            precio_unitario=round(unitario, 4) if unitario is not None else None,
            min_piezas=min_piezas,
            precio_escalon=precio_escalon,
            moneda="MXN",
            minimo_compra_pedido=None,
            notas=notas,
            id_producto_proveedor=str(pid),
        ))
    return filas


def paginas_en(html: str) -> int:
    nums = [int(x) for x in _RE_PAGINAS.findall(html)]
    return max(nums) if nums else 1


class ScorpionAdapter(ProveedorAdapter):
    nombre = "Scorpion"
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
        for path in CATEGORIAS:
            slug = path.strip("/").replace("/", "_").replace(".html", "")
            url0 = BASE + path
            html0 = fetch(
                url0,
                cache_path=ruta_cache(root, "scorpion", fecha_dir, f"{slug}_p1.html"),
                usar_cache=usar_cache,
            )
            n_pags = paginas_en(html0)
            paginas = [html0]
            for p in range(2, n_pags + 1):
                sep = "&" if "?" in path else "?"
                paginas.append(fetch(
                    f"{BASE}{path}{sep}p={p}",
                    cache_path=ruta_cache(root, "scorpion", fecha_dir, f"{slug}_p{p}.html"),
                    usar_cache=usar_cache,
                ))
            cat = path.split("/")[-1].replace(".html", "")
            for html in paginas:
                for fila in parsear_listado(html, fecha=fecha_s, categoria=cat):
                    key = fila["id_producto_proveedor"]
                    if key in vistos:
                        continue
                    vistos.add(key)
                    todas.append(fila)
        self.guardar(todas, d)
        return todas
