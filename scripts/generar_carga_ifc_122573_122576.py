#!/usr/bin/env python3
"""Farma Centre / IFC F8 Tienda · tickets 122573 + 122576 (05-sep-2026).

Fotos del ticket leídas 05-sep-2026. P.PUBLICO = costo de compra.
Sin lote ni MMAA: salen de la caja al escanear. No inventar 0000.

Fichas:
  · Reomatolum Del Viejito — ya en catálogo (FC-1FBF5206 / 7503002045008)
  · Kohn lavaojos plástico — EAN Sufarmed 7506346604917
  · Mercurio Pomada Manzana — ficha Mayfar MER-010; sin EAN público
"""
from __future__ import annotations

import math
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from generar_recepcion_borrador import report, write_recepcion_sql, write_ticket_csv

ROOT = Path(__file__).resolve().parents[1]
PROVEEDOR = "IFC F8 Tienda"
PROVEEDOR_ILIKE = "ifc"
FECHA = "2026-09-05"

# Folio 122573 · MAYOREO · $120.00 · 11:17
FOLIO_A = "122573"
TOTAL_A = 120.00
ROWS_A = [
    {
        "nombre": "Del Viejito Reomatolum pomada 60 g",
        "desc_ticket": "POMADA REOMATOLUM DEL VIEJITO 60G",
        "qty": 5,
        "pu": 20.00,
        "sub": 100.00,
        "ean": "7503002045008",
        "sku": "FC-1FBF5206",
        "match": "catalogo",
    },
    {
        "nombre": "Kohn lavaojos de plástico",
        "desc_ticket": "KOHN LAVA OJOS DE PLASTICO 2024 82955",
        "qty": 5,
        "pu": 4.00,
        "sub": 20.00,
        "ean": "7506346604917",
        "sku": "FC-46604917",
        "match": "sufarmed",
    },
]

# Folio 122576 · MENUDEO · $28.50 · 11:20
FOLIO_B = "122576"
TOTAL_B = 28.50
ROWS_B = [
    {
        "nombre": "Mercurio Pomada Manzana 50 g",
        "desc_ticket": "MERCURIO POMADA MANZANA C/25 2530123 82943",
        "qty": 3,
        "pu": 9.50,
        "sub": 28.50,
        "ean": "",  # sin EAN público; se liga por SKU tras el alta
        "sku": "FC-MER-MANZANA",
        "match": "mayfar",
    },
]


def ceil_pvp(costo: float, factor: float = 1.6) -> float:
    return float(math.ceil(costo * factor))


def write_carga_sql(path: Path) -> None:
    """Altas de catálogo (stock 0) + ficha. SIN do $$.

    Foto inmediata = URL de ficha (Mayfar / Kohn). Copias en
    public/catalogo-propia/ para pasar a URL propia después del deploy.
    """
    foto_reo = (
        "https://acdn-us.mitiendanube.com/stores/004/824/171/products/"
        "mer128-8c5715a7144487dbd317373352570961-640-0.webp"
    )
    foto_kohn = "https://kohnmexico.com/wp-content/uploads/2016/12/lava_ojos.jpg"
    foto_manz = (
        "https://acdn-us.mitiendanube.com/stores/004/824/171/products/"
        "mer010-3391c4a7525545e5be17194451807817-640-0.webp"
    )
    pvp_kohn = ceil_pvp(4.00)
    pvp_manz = ceil_pvp(9.50)

    lines = [
        "-- Farma Centre / IFC F8 Tienda · altas de catálogo (122573 + 122576).",
        "-- SIN bloques dollar-quote. Stock = 0; entra al escanear en Recibir.",
        "-- Fotos: URL de ficha (Mayfar/Kohn). Copias en public/catalogo-propia/",
        "-- para sql de foto propia DESPUÉS del deploy (como Dibar).",
        "-- Orden: 1) este archivo  2) patch_recepcion_ifc_122573.sql",
        "--         3) patch_recepcion_ifc_122576.sql",
        "-- Idempotente. Pegar TODO en Supabase → SQL Editor → Run.",
        "",
        "begin;",
        "",
        "-- 1) Reomatolum: ya existe; costo + ficha; no pisa PVP ni foto buena",
        "update public.productos set",
        "  costo = 20.00,",
        "  marca = coalesce(nullif(btrim(marca), ''), 'Del Viejito'),",
        "  presentacion = coalesce(nullif(btrim(presentacion), ''), '60 g'),",
        "  forma_farmaceutica = coalesce(nullif(btrim(forma_farmaceutica), ''), 'Pomada'),",
        "  categoria = coalesce(nullif(btrim(categoria), ''), 'Cuidado personal'),",
        "  codigo_barras = coalesce(nullif(btrim(codigo_barras), ''), '7503002045008'),",
        f"  imagen_url = coalesce(nullif(btrim(imagen_url), ''), {repr(foto_reo)})",
        "where sku = 'FC-1FBF5206'",
        "   or codigo_barras = '7503002045008';",
        "",
        "-- 2) Kohn lavaojos plástico",
        "insert into public.productos (",
        "  nombre, sku, codigo_barras, categoria, tipo, descripcion,",
        "  costo, precio, stock, stock_minimo, activo, requiere_receta,",
        "  marca, presentacion, forma_farmaceutica, imagen_url",
        ")",
        "select",
        "  'Kohn lavaojos de plástico',",
        "  'FC-46604917',",
        "  '7506346604917',",
        "  'Dispositivo médico',",
        "  'marca',",
        "  'Ticket IFC 122573 · Farma Centre · EAN Sufarmed · foto Kohn México',",
        f"  4.00, {pvp_kohn:.2f}, 0, 2, true, false,",
        "  'Kohn',",
        "  'Pieza',",
        "  'Dispositivo',",
        f"  {repr(foto_kohn)}",
        "where public.fc_buscar_producto_escaneo('7506346604917') is null",
        "  and not exists (select 1 from public.productos where sku = 'FC-46604917');",
        "",
        "update public.productos set",
        "  costo = 4.00,",
        f"  precio = case when coalesce(precio, 0) <= 0 then {pvp_kohn:.2f} else precio end,",
        "  marca = coalesce(nullif(btrim(marca), ''), 'Kohn'),",
        "  presentacion = coalesce(nullif(btrim(presentacion), ''), 'Pieza'),",
        "  categoria = coalesce(nullif(btrim(categoria), ''), 'Dispositivo médico'),",
        f"  imagen_url = coalesce(nullif(btrim(imagen_url), ''), {repr(foto_kohn)})",
        "where sku = 'FC-46604917' or codigo_barras = '7506346604917';",
        "",
        "-- 3) Mercurio Pomada Manzana (sin EAN público; ligar código de la caja)",
        "insert into public.productos (",
        "  nombre, sku, codigo_barras, categoria, tipo, descripcion,",
        "  costo, precio, stock, stock_minimo, activo, requiere_receta,",
        "  marca, presentacion, forma_farmaceutica, imagen_url",
        ")",
        "select",
        "  'Mercurio Pomada Manzana 50 g',",
        "  'FC-MER-MANZANA',",
        "  null,",
        "  'Cuidado personal',",
        "  'marca',",
        "  'Ticket IFC 122576 · Farma Centre · ficha Mayfar MER-010 · falta EAN de caja',",
        f"  9.50, {pvp_manz:.2f}, 0, 2, true, false,",
        "  'Mercurio',",
        "  '50 g',",
        "  'Pomada',",
        f"  {repr(foto_manz)}",
        "where not exists (select 1 from public.productos where sku = 'FC-MER-MANZANA');",
        "",
        "update public.productos set",
        "  costo = 9.50,",
        f"  precio = case when coalesce(precio, 0) <= 0 then {pvp_manz:.2f} else precio end,",
        "  marca = coalesce(nullif(btrim(marca), ''), 'Mercurio'),",
        "  presentacion = coalesce(nullif(btrim(presentacion), ''), '50 g'),",
        "  forma_farmaceutica = coalesce(nullif(btrim(forma_farmaceutica), ''), 'Pomada'),",
        "  categoria = coalesce(nullif(btrim(categoria), ''), 'Cuidado personal'),",
        f"  imagen_url = coalesce(nullif(btrim(imagen_url), ''), {repr(foto_manz)})",
        "where sku = 'FC-MER-MANZANA';",
        "",
        "commit;",
        "",
        "select sku, codigo_barras as ean, left(nombre, 42) as nombre, costo, precio, stock,",
        "  left(imagen_url, 72) as foto",
        "from public.productos",
        "where sku in ('FC-1FBF5206', 'FC-46604917', 'FC-MER-MANZANA')",
        "   or codigo_barras in ('7503002045008', '7506346604917')",
        "order by sku;",
        "",
    ]
    path.write_text("\n".join(lines), encoding="utf-8")


def main() -> None:
    out_csv_a = ROOT / "sql" / "generated" / f"ticket_ifc_{FOLIO_A}.csv"
    out_csv_b = ROOT / "sql" / "generated" / f"ticket_ifc_{FOLIO_B}.csv"
    out_rx_a = ROOT / "sql" / f"patch_recepcion_ifc_{FOLIO_A}.sql"
    out_rx_b = ROOT / "sql" / f"patch_recepcion_ifc_{FOLIO_B}.sql"
    out_carga = ROOT / "sql" / "patch_carga_ifc_122573_122576.sql"

    write_ticket_csv(out_csv_a, folio=FOLIO_A, fecha=FECHA, proveedor=PROVEEDOR, total=TOTAL_A, rows=ROWS_A)
    write_ticket_csv(out_csv_b, folio=FOLIO_B, fecha=FECHA, proveedor=PROVEEDOR, total=TOTAL_B, rows=ROWS_B)

    write_recepcion_sql(
        out_rx_a,
        folio=FOLIO_A,
        proveedor=PROVEEDOR,
        proveedor_ilike=PROVEEDOR_ILIKE,
        fecha=FECHA,
        total=TOTAL_A,
        notas=(
            f"Farma Centre / IFC F8 Tienda · folio {FOLIO_A} · MAYOREO · "
            "05-sep-2026 11:17 · cola Recibir; stock al confirmar pistola"
        ),
        rows=ROWS_A,
    )
    write_recepcion_sql(
        out_rx_b,
        folio=FOLIO_B,
        proveedor=PROVEEDOR,
        proveedor_ilike=PROVEEDOR_ILIKE,
        fecha=FECHA,
        total=TOTAL_B,
        notas=(
            f"Farma Centre / IFC F8 Tienda · folio {FOLIO_B} · MENUDEO · "
            "05-sep-2026 11:20 · cola Recibir; stock al confirmar pistola · "
            "Pomada Manzana sin EAN: ligar código de la caja al escanear"
        ),
        rows=ROWS_B,
    )
    write_carga_sql(out_carga)

    print("A", report(ROWS_A, TOTAL_A), "→", out_rx_a.name)
    print("B", report(ROWS_B, TOTAL_B), "→", out_rx_b.name)
    print("carga", out_carga.name)


if __name__ == "__main__":
    main()
