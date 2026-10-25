#!/usr/bin/env python3
"""Nota HS Comercial T610241957 (2026-10-24) → CSV + SQL Recibir.

Ticket imprime MAYORISTA DE DULCES IZTAPALAPA, S.A. DE C.V.
(Central de Abasto Sec.2 Bodega E-17, RFC MDI0803131A9).
Negocio / web: HS Comercial (www.hscomercial.mx).

EAN de fotos de caja (sql/patch_ean_hs_comercial_T610241957.sql).
Altas por SKU mnemónico FC-HS-* (Orbit Menta → FC-LV-ORBITMEN40).

Mayoreo → piezas de mostrador (misma regla que recepcionPackPiezas):
  Bocadin 12/50pzs ×1 BLS     → 50 pzas · EAN 025046501052
  Chiki Botella 32/40pzs ×1   → 40 pzas · EAN 799583006003 (Alvher)
  Orbit 4's Menta 24/40pzs ×1 → 40 pzas · EAN 7502271913353
  Skittles Paquete 220g DIS   → 10 sobres 22 g · EAN 7502226816937
  M&M Chocolate café 32/6 ×1  → 6 pzas · EAN 7502271917641
  Kit Kat Chunky 40g 12/6 ×1  → 6 pzas · EAN 7501058626554

Costos: línea bruta del ticket prorrateada al total tarjeta $396.66
(descuento $33.54 sobre subtotal $430.20). PVP impulso +40% ceil.
Sin lote ni MMAA.
"""
from __future__ import annotations

import csv
import math
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
OUT_CSV = ROOT / "sql" / "generated" / "ticket_hs_comercial_T610241957.csv"
OUT_SQL = ROOT / "sql" / "patch_carga_hs_comercial_T610241957.sql"
OUT_MD = ROOT / "sql" / "LEERME_hs_comercial_T610241957.md"

FOLIO = "T610241957"
PROVEEDOR = "HS Comercial"
FECHA = "2026-10-24"
TOTAL_TICKET = 396.66
SUBTOTAL_BRUTO = 430.20
DESCUENTO = 33.54


def q(s: str) -> str:
    return "'" + s.replace("'", "''") + "'"


def pvp_impulso(costo: float) -> float:
    """+40% sobre costo, ceil a peso entero (mismo criterio La Victoria)."""
    return float(math.ceil(costo * 1.4 - 1e-9))


ROWS = [
    {
        "linea": 1,
        "sku": "FC-HS-BOCADIN50",
        "ean": "025046501052",
        "snap": "Bimbo BOCADIN Bolsa 12/50pzs",
        "nombre": "Bocadin",
        "marca": "Bimbo",
        "presentacion": "Bolsa 50 piezas (525 g)",
        "categoria": "Impulso",
        "tipo": "marca",
        "pzas_por_caja": 50,
        "costo_caja_bruto": 59.60,
    },
    {
        "linea": 2,
        "sku": "FC-HS-CHIKIBOT40",
        "ean": "799583006003",
        "snap": "alv.Chiki BOTELLA 32/40pzs",
        "nombre": "Chiki Botella",
        "marca": "Alvher",
        "presentacion": "Botella (bolsa mayoreo 40)",
        "categoria": "Impulso",
        "tipo": "marca",
        "pzas_por_caja": 40,
        "costo_caja_bruto": 35.20,
    },
    {
        "linea": 3,
        "sku": "FC-LV-ORBITMEN40",
        "ean": "7502271913353",
        "snap": "wrigley Orbit 4is Menta 24/40pzs",
        "nombre": "Orbit 4's Menta",
        "marca": "Orbit",
        "presentacion": "Pack 4 pastillas (exhibidor 40)",
        "categoria": "Impulso",
        "tipo": "marca",
        "pzas_por_caja": 40,
        "costo_caja_bruto": 84.00,
    },
    {
        "linea": 4,
        "sku": "FC-HS-SKITTLES220",
        "ean": "7502226816937",
        "snap": "wrigley Skittles PAQUETE Original 220g",
        "nombre": "Skittles Original",
        "marca": "Skittles",
        # Foto caja: 10 piezas de 22 g = CONT. NET. 220 g.
        "presentacion": "Caja 10 sobres 22 g (220 g)",
        "categoria": "Impulso",
        "tipo": "marca",
        "pzas_por_caja": 10,
        "costo_caja_bruto": 72.00,
    },
    {
        "linea": 5,
        "sku": "FC-HS-MMCAFE6",
        "ean": "7502271917641",
        "snap": "effem m&m CHOCOLATE cafe 32/6pzs",
        "nombre": "M&M's Chocolate",
        "marca": "M&M's",
        "presentacion": "6 pack 37.8 g (226.8 g)",
        "categoria": "Impulso",
        "tipo": "marca",
        "pzas_por_caja": 6,
        "costo_caja_bruto": 88.00,
    },
    {
        "linea": 6,
        "sku": "FC-HS-KITCHUNKY6",
        "ean": "7501058626554",
        "snap": "nest.KIT KAT Chunky 40g 12/6pzs",
        "nombre": "Kit Kat Chunky",
        "marca": "Kit Kat",
        "presentacion": "Caja 6 barras 40 g",
        "categoria": "Impulso",
        "tipo": "marca",
        "pzas_por_caja": 6,
        "costo_caja_bruto": 91.40,
    },
]


def expand() -> list[dict]:
    factor = TOTAL_TICKET / SUBTOTAL_BRUTO
    out: list[dict] = []
    allocated = 0.0
    for i, r in enumerate(ROWS):
        if i < len(ROWS) - 1:
            net = round(r["costo_caja_bruto"] * factor, 2)
            allocated += net
        else:
            net = round(TOTAL_TICKET - allocated, 2)
        qty = r["pzas_por_caja"]
        costo = round(net / qty, 4)
        out.append(
            {
                **r,
                "qty": qty,
                "costo_caja_neto": net,
                "costo": costo,
                "precio": pvp_impulso(costo),
            }
        )
    return out


def write_csv(rows: list[dict]) -> None:
    OUT_CSV.parent.mkdir(parents=True, exist_ok=True)
    with OUT_CSV.open("w", newline="", encoding="utf-8") as fh:
        w = csv.writer(fh)
        w.writerow(
            [
                "linea",
                "folio",
                "fecha",
                "proveedor",
                "ean",
                "sku",
                "descripcion_ticket",
                "cantidad_mostrador",
                "costo_unitario",
                "subtotal_neto",
                "total_ticket",
            ]
        )
        for r in rows:
            w.writerow(
                [
                    r["linea"],
                    FOLIO,
                    FECHA,
                    PROVEEDOR,
                    r.get("ean") or "",
                    r["sku"],
                    r["snap"],
                    r["qty"],
                    f"{r['costo']:.4f}",
                    f"{r['costo_caja_neto']:.2f}",
                    f"{TOTAL_TICKET:.2f}",
                ]
            )


def write_sql(rows: list[dict]) -> None:
    notas = (
        f"Nota {FOLIO} · Mayorista de Dulces Iztapalapa Bodega E-17 · "
        "HS Comercial · 6 renglones impulso · EAN de fotos de caja · "
        "stock al confirmar pistola · descuento ticket prorrateado"
    )
    vals = []
    for r in rows:
        ean_sql = "null" if not r.get("ean") else q(r["ean"])
        vals.append(
            f"  ({r['linea']}, {q(r['sku'])}, {ean_sql}, {q(r['snap'])}, {q(r['nombre'])}, "
            f"{q(r['marca'])}, {q(r['presentacion'])}, {q(r['categoria'])}, "
            f"{q(r['tipo'])}, {r['qty']}, {r['costo']:.4f}, {r['precio']:.2f})"
        )

    sql = f"""-- HS Comercial · nota {FOLIO} · {FECHA} 13:24
-- Ticket imprime «MAYORISTA DE DULCES IZTAPALAPA, S.A. DE C.V.»
-- (Central de Abasto Sec.2 Bodega E-17, RFC MDI0803131A9).
-- Negocio: HS Comercial · www.hscomercial.mx · WhatsApp 55 4412 5724.
-- Total tarjeta ${TOTAL_TICKET:.2f} (bruto ${SUBTOTAL_BRUTO:.2f} − desc. ${DESCUENTO:.2f}).
-- Mayoreo → piezas de mostrador. Costo = línea neta / piezas.
-- EAN de fotos de caja (ver también sql/patch_ean_hs_comercial_T610241957.sql).
-- Stock al confirmar en Recibir + MMAA de la caja. No poner caducidad 0000.
--
-- Idempotente mientras el ticket siga en borrador.
-- Pegar TODO este archivo en Supabase → SQL Editor → Run.
-- Ver sql/LEERME_hs_comercial_T610241957.md

begin;

insert into public.proveedores (nombre, activo)
select {q(PROVEEDOR)}, true
where not exists (
  select 1 from public.proveedores
  where lower(btrim(nombre)) = lower({q(PROVEEDOR)})
);

create temp table _fc_hs_t610241957 (
  linea integer primary key,
  sku text not null,
  ean text,
  snap text not null,
  nombre text not null,
  marca text not null,
  presentacion text not null,
  categoria text not null,
  tipo text not null,
  qty integer not null,
  costo numeric(12,4) not null,
  precio numeric(12,2) not null
) on commit drop;

insert into _fc_hs_t610241957
  (linea, sku, ean, snap, nombre, marca, presentacion, categoria, tipo, qty, costo, precio)
values
{',\n'.join(vals)};

-- Soltar EAN de otro SKU si chocaría UNIQUE.
update public.productos p
set codigo_barras = null
where nullif(btrim(p.codigo_barras), '') in (
  select nullif(btrim(t.ean), '') from _fc_hs_t610241957 t where t.ean is not null
)
and p.sku not in (select t.sku from _fc_hs_t610241957 t);

insert into public.productos (
  nombre, sku, codigo_barras, categoria, tipo, descripcion,
  marca, presentacion, costo, precio, stock, stock_minimo,
  activo, requiere_receta
)
select
  t.nombre,
  t.sku,
  t.ean,
  t.categoria,
  t.tipo,
  {q(f'Alta HS Comercial {FOLIO} · {FECHA} · ticket Mayorista de Dulces Iztapalapa')},
  t.marca,
  t.presentacion,
  t.costo,
  t.precio,
  0,
  greatest(2, least(t.qty / 4, 10)),
  true,
  false
from _fc_hs_t610241957 t
where not exists (
  select 1 from public.productos p where p.sku = t.sku
);

update public.productos p
set
  costo = t.costo,
  precio = case when coalesce(p.precio, 0) <= 0 then t.precio else p.precio end,
  marca = coalesce(nullif(btrim(p.marca), ''), t.marca),
  presentacion = coalesce(nullif(btrim(p.presentacion), ''), t.presentacion),
  categoria = t.categoria,
  codigo_barras = case
    when nullif(btrim(p.codigo_barras), '') is null then t.ean
    else p.codigo_barras
  end
from _fc_hs_t610241957 t
where p.sku = t.sku;

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  {q(PROVEEDOR)},
  {q(FOLIO)},
  {q(FECHA)},
  {TOTAL_TICKET:.2f},
  'borrador',
  {q(notas)}
where not exists (
  select 1 from public.recepciones
  where folio = {q(FOLIO)}
    and coalesce(proveedor, '') ilike '%hs comercial%'
);

update public.recepciones
set
  total_ticket = {TOTAL_TICKET:.2f},
  fecha = {q(FECHA)},
  proveedor = {q(PROVEEDOR)},
  notas = {q(notas)},
  updated_at = now()
where folio = {q(FOLIO)}
  and coalesce(proveedor, '') ilike '%hs comercial%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = {q(FOLIO)}
  and coalesce(r.proveedor, '') ilike '%hs comercial%'
  and r.estado = 'borrador';

insert into public.recepcion_items (
  recepcion_id, producto_id, codigo_escaneado, nombre_snapshot,
  cantidad, fecha_caducidad, numero_lote, costo_estimado, pendiente_alta,
  origen, confirmado, lote_distinto, lote_id
)
select
  r.id,
  p.id,
  t.ean,
  t.snap,
  t.qty,
  null,
  null,
  t.costo,
  false,
  'pdf',
  false,
  (
    exists (
      select 1 from public.lotes l
      where l.producto_id = p.id
        and coalesce(l.activo, true)
        and coalesce(l.cantidad_actual, 0) > 0
    )
  ),
  null
from _fc_hs_t610241957 t
join public.recepciones r
  on r.folio = {q(FOLIO)}
 and coalesce(r.proveedor, '') ilike '%hs comercial%'
 and r.estado = 'borrador'
join public.productos p on p.sku = t.sku
order by t.linea;

commit;

select
  i.id,
  p.sku,
  p.codigo_barras as ean,
  left(i.nombre_snapshot, 40) as snap,
  left(p.nombre, 36) as nombre,
  i.cantidad as pzas,
  i.costo_estimado,
  p.precio as pvp,
  case when p.codigo_barras is null then 'EAN PENDIENTE' else 'OK' end as ean_estado
from public.recepcion_items i
join public.recepciones r on r.id = i.recepcion_id
join public.productos p on p.id = i.producto_id
where r.folio = {q(FOLIO)} and coalesce(r.proveedor, '') ilike '%hs comercial%'
order by i.id;
"""
    OUT_SQL.write_text(sql, encoding="utf-8")


def write_md(rows: list[dict]) -> None:
    table = [
        "| # | Ticket | Piezas | Neto | Costo/pza | PVP | EAN | SKU |",
        "|---|--------|--------|------|-----------|-----|-----|-----|",
    ]
    for r in rows:
        table.append(
            f"| {r['linea']} | `{r['snap']}` | {r['qty']} | "
            f"${r['costo_caja_neto']:.2f} | ${r['costo']:.4f} | "
            f"${r['precio']:.0f} | `{r.get('ean') or '—'}` | `{r['sku']}` |"
        )
    md = f"""# Ticket HS Comercial · {FOLIO}

**Fecha:** {FECHA} 13:24 (America/Mexico_City) · Central de Abasto Bodega E-17  
**Total:** ${TOTAL_TICKET:.2f} (tarjeta débito) · bruto ${SUBTOTAL_BRUTO:.2f} · descuento ${DESCUENTO:.2f} · IVA impreso $10.43  
**Cajero:** 18 Abigail Rodríguez Hernández

## Proveedor: HS Comercial

El ticket imprime **MAYORISTA DE DULCES IZTAPALAPA, S.A. DE C.V.** (RFC `MDI0803131A9`), pero:

- Web / correo: `www.hscomercial.mx` · `domicilio@hscomercial.mx`
- WhatsApp: 55 4412 5724
- En código: `normalizeProveedorCompra("MAYORISTA DE DULCES…")` → `HS Comercial`

## Renglones (1 bolsa/display cada uno → piezas de mostrador)

{chr(10).join(table)}

`12/50pzs` / `32/40pzs` / `24/40pzs` / `32/6pzs` / `12/6pzs` = el 2.º número es el exhibidor (regla `piezasPorEmpaqueDesdeNombre`).  
Skittles **PAQUETE Original 220g**: caja con **10 sobres de 22 g** (foto; CONT. NET. 220 g).

## Cómo aplicar

1. Si el ticket **aún no** está en Recibir: pegar `sql/patch_carga_hs_comercial_T610241957.sql`.
2. Si ya corriste la carga sin EAN: pegar `sql/patch_ean_hs_comercial_T610241957.sql` (solo códigos).
3. Recibir → pistola → MMAA de la caja. No poner `0000`.
4. Packshot de mostrador → `public/catalogo-propia/` si hace falta (sin placeholder de competencia).

## Archivos

- `sql/generated/ticket_hs_comercial_T610241957.csv`
- `sql/patch_carga_hs_comercial_T610241957.sql`
- `sql/patch_ean_hs_comercial_T610241957.sql`
- `scripts/generar_carga_hs_comercial_T610241957.py`
"""
    OUT_MD.write_text(md, encoding="utf-8")


def main() -> None:
    rows = expand()
    suma = sum(r["costo_caja_neto"] for r in rows)
    piezas = sum(r["qty"] for r in rows)
    write_csv(rows)
    write_sql(rows)
    write_md(rows)
    print(f"lineas={len(rows)} piezas={piezas} suma=${suma:.2f} ticket=${TOTAL_TICKET:.2f}")
    print(f"csv={OUT_CSV}")
    print(f"sql={OUT_SQL}")
    print(f"md={OUT_MD}")
    assert abs(suma - TOTAL_TICKET) < 0.02, (suma, TOTAL_TICKET)
    assert abs(sum(r["costo_caja_bruto"] for r in ROWS) - SUBTOTAL_BRUTO) < 0.01
    assert piezas == 50 + 40 + 40 + 10 + 6 + 6


if __name__ == "__main__":
    main()
