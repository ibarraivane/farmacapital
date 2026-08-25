"""Cascada de matching A / B / C + persistencia de decisiones manuales."""

from __future__ import annotations

import csv
from dataclasses import dataclass, field
from pathlib import Path

from rapidfuzz import fuzz

from lib.pricing.normalize import (
    Tamano,
    corregir_marca,
    extraer_tamano,
    inferir_marca_de_nombre,
    inferir_tipo,
    normalizar_marca,
    normalizar_nombre,
    precio_por_unidad_base,
    tamanos_equivalentes,
)

ROOT = Path(__file__).resolve().parents[2]
MATCHES_CONFIRMADOS = ROOT / "pricing" / "matches_confirmados.csv"
UMBRAL_B = 85
TOP_C = 3


@dataclass
class ProductoCatalogo:
    sku: str
    nombre: str
    marca: str
    presentacion: str = ""
    costo: float | None = None
    precio_venta: float | None = None
    tipo: str = ""
    nombre_norm: str = ""
    marca_norm: str = ""
    tamano: Tamano | None = None
    tipo_prod: str = ""


@dataclass
class ProductoProveedor:
    fuente: str
    id_producto_proveedor: str
    producto_raw: str
    marca: str = ""
    presentacion: str = ""
    tipo_fuente: str = "mayorista"
    precio_empaque: float | None = None
    precio_unitario: float | None = None
    cantidad_empaque: int = 1
    min_piezas: int = 1
    precio_escalon: float | None = None
    minimo_compra_pedido: float | None = None
    url: str = ""
    categoria: str = ""
    nombre_norm: str = ""
    marca_norm: str = ""
    tamano: Tamano | None = None
    tipo_prod: str = ""
    precio_base: float | None = None


@dataclass
class Match:
    sku: str
    fuente: str
    nivel: str  # A | B | C | confirmado | ninguno
    score: float
    proveedor: ProductoProveedor | None
    candidatos: list[tuple[ProductoProveedor, float]] = field(default_factory=list)


def cargar_confirmados(path: Path | None = None) -> dict[tuple[str, str], str]:
    """Mapa (sku, fuente) → id_producto_proveedor."""
    p = path or MATCHES_CONFIRMADOS
    out: dict[tuple[str, str], str] = {}
    if not p.exists():
        return out
    with p.open(encoding="utf-8", newline="") as fh:
        for row in csv.DictReader(fh):
            sku = (row.get("sku") or "").strip()
            fuente = (row.get("fuente") or "").strip()
            pid = (row.get("id_producto_proveedor") or "").strip()
            if sku and fuente and pid:
                out[(sku, fuente)] = pid
    return out


def enriquecer_catalogo(items: list[ProductoCatalogo], marcas: list[str] | None = None) -> list[ProductoCatalogo]:
    marcas = marcas or [p.marca for p in items]
    for p in items:
        p.nombre_norm = normalizar_nombre(f"{p.marca} {p.nombre} {p.presentacion}")
        marca_corr, _ = corregir_marca(p.marca, marcas)
        p.marca_norm = marca_corr or normalizar_marca(p.marca)
        p.tamano = extraer_tamano(f"{p.presentacion} {p.nombre}")
        p.tipo_prod = inferir_tipo(f"{p.nombre} {p.presentacion} {p.tipo}")
    return items


def enriquecer_proveedor(
    items: list[ProductoProveedor],
    marcas_catalogo: list[str],
) -> list[ProductoProveedor]:
    for p in items:
        p.nombre_norm = normalizar_nombre(p.producto_raw)
        marca = p.marca or inferir_marca_de_nombre(p.producto_raw, marcas_catalogo)
        marca_corr, _ = corregir_marca(marca, marcas_catalogo)
        p.marca_norm = marca_corr or normalizar_marca(marca)
        p.tamano = extraer_tamano(f"{p.presentacion} {p.producto_raw}")
        p.tipo_prod = inferir_tipo(p.producto_raw)
        p.precio_base = precio_por_unidad_base(p.precio_unitario, p.tamano)
    return items


def _indice_por_marca(proveedores: list[ProductoProveedor]) -> dict[str, list[ProductoProveedor]]:
    idx: dict[str, list[ProductoProveedor]] = {}
    for p in proveedores:
        if p.marca_norm:
            idx.setdefault(p.marca_norm, []).append(p)
    return idx


def _tipos_compatibles(a: str, b: str) -> bool:
    if not a or not b:
        return True
    return a == b


def _score_nombre(a: str, b: str) -> float:
    if not a or not b:
        return 0.0
    return float(fuzz.token_set_ratio(a, b))


def matchear_sku(
    cat: ProductoCatalogo,
    proveedores: list[ProductoProveedor],
    por_marca: dict[str, list[ProductoProveedor]],
    confirmados: dict[tuple[str, str], str],
    fuente: str,
) -> Match:
    # 0) decisión manual previa
    pid = confirmados.get((cat.sku, fuente))
    if pid:
        for p in proveedores:
            if p.id_producto_proveedor == pid:
                return Match(cat.sku, fuente, "confirmado", 100.0, p)
        return Match(cat.sku, fuente, "confirmado", 100.0, None)

    mismos = por_marca.get(cat.marca_norm, []) if cat.marca_norm else []

    # A: marca + tamaño ±2% + tipo (si hay varios, gana el mejor nombre)
    if cat.marca_norm and cat.tamano is not None:
        cand_a: list[tuple[ProductoProveedor, float]] = []
        for p in mismos:
            if not tamanos_equivalentes(cat.tamano, p.tamano):
                continue
            if not _tipos_compatibles(cat.tipo_prod, p.tipo_prod):
                continue
            cand_a.append((p, _score_nombre(cat.nombre_norm, p.nombre_norm)))
        if cand_a:
            cand_a.sort(key=lambda x: x[1], reverse=True)
            p, score = cand_a[0]
            # Marca+tamaño+tipo sin overlap de nombre (Ceramida vs Rizos) no es A.
            if score >= 70:
                return Match(cat.sku, fuente, "A", max(score, 90.0), p, cand_a[:TOP_C])

    # B: misma marca + token_set_ratio ≥ 85 (solo dentro de la marca)
    if cat.marca_norm and mismos:
        ranked: list[tuple[ProductoProveedor, float]] = []
        for p in mismos:
            ranked.append((p, _score_nombre(cat.nombre_norm, p.nombre_norm)))
        ranked.sort(key=lambda x: x[1], reverse=True)
        if ranked and ranked[0][1] >= UMBRAL_B:
            return Match(cat.sku, fuente, "B", ranked[0][1], ranked[0][0], ranked[:TOP_C])
        return Match(cat.sku, fuente, "C", ranked[0][1] if ranked else 0.0, None, ranked[:TOP_C])

    # C: sin marca en común → NO auto-matchear
    ranked = []
    for p in proveedores:
        ranked.append((p, _score_nombre(cat.nombre_norm, p.nombre_norm)))
    ranked.sort(key=lambda x: x[1], reverse=True)
    return Match(cat.sku, fuente, "C", ranked[0][1] if ranked else 0.0, None, ranked[:TOP_C])


def matchear_fuente(
    catalogo: list[ProductoCatalogo],
    proveedores: list[ProductoProveedor],
    fuente: str,
    confirmados: dict[tuple[str, str], str] | None = None,
) -> list[Match]:
    confirmados = confirmados if confirmados is not None else cargar_confirmados()
    por_marca = _indice_por_marca(proveedores)
    return [matchear_sku(c, proveedores, por_marca, confirmados, fuente) for c in catalogo]


def alcanzable(prov: ProductoProveedor | None) -> bool:
    """Falso si el precio bueno exige escalón de volumen o mínimo de pedido."""
    if prov is None:
        return False
    if prov.min_piezas and prov.min_piezas > 1 and prov.precio_escalon:
        # El precio_unitario del CSV es de caja/pieza base, no del escalón.
        # Si solo existe escalón (sin precio_empaque usable), no es alcanzable suelto.
        pass
    if prov.minimo_compra_pedido and float(prov.minimo_compra_pedido) > 0:
        return False
    return True


def alcanzable_escalon(prov: ProductoProveedor | None) -> bool:
    if prov is None:
        return False
    if prov.min_piezas and int(prov.min_piezas) > 1:
        return False
    if prov.minimo_compra_pedido and float(prov.minimo_compra_pedido) > 0:
        return False
    return True
