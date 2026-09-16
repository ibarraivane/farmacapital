#!/usr/bin/env python3
"""Nota Dulcería La Victoria T280034008 (2026-09-15) → CSV + SQL Recibir.

El ticket imprime «DULCERIA LA FAMOSA» (WinCaja) pero el negocio es
Dulcería La Victoria, Bodega F-20 Central de Abasto
(correo quejas_ysug@dulcerialavictoria.com.mx — mismo patrón T280033139).

Sin EAN en el papel. Altas por SKU mnemónico FC-LV-*;
codigo_barras queda null hasta escanear la caja.
Mayoreo → piezas de mostrador:
  HALLS EXTRA STRONG 30/12PZ ×1 → 12 pzas (cuadreta)
  SKITTLES ORIGINAL 24/10PZ ×2 → 48 pzas (2 exhibidores)
Total tarjeta $223.20. Sin lote ni MMAA.
"""
from __future__ import annotations

import csv
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
OUT_CSV = ROOT / "sql" / "generated" / "ticket_dulceria_victoria_T280034008.csv"
OUT_SQL = ROOT / "sql" / "patch_carga_dulceria_victoria_T280034008.sql"

FOLIO = "T280034008"
PROVEEDOR = "Dulcería La Victoria"
FECHA = "2026-09-15"
TOTAL_TICKET = 223.20


def q(s: str) -> str:
    return "'" + s.replace("'", "''") + "'"


ROWS = [
    {
        "linea": 1,
        "sku": "FC-LV-HALLSX12",
        "snap": "HALLS EXTRA STRONG 30/12PZ",
        "nombre": "Halls Extra Strong",
        "marca": "Halls",
        "presentacion": "Pack (cuadreta 12 · master 30)",
        "categoria": "Impulso",
        "tipo": "marca",
        "cajas": 1,
        "pzas_por_caja": 12,
        "costo_caja": 74.00,
        "precio": 9.00,
    },
    {
        "linea": 2,
        "sku": "FC-LV-SKITTLES24",
        "snap": "SKITTLES ORIGINAL, 24/10PZ.",
        "nombre": "Skittles Original bolsa",
        "marca": "Skittles",
        "presentacion": "Bolsa (caja mayoreo 24/10PZ)",
        "categoria": "Impulso",
        "tipo": "marca",
        "cajas": 2,
        "pzas_por_caja": 24,
        "costo_caja": 74.60,
        "precio": 5.00,
    },
]


def expand() -> list[dict]:
    out = []
    for r in ROWS:
        qty = r["cajas"] * r["pzas_por_caja"]
        costo = round(r["costo_caja"] / r["pzas_por_caja"], 4)
        out.append({**r, "qty": qty, "costo": costo})
    return out


def write_csv(rows: list[dict]) -> None:
    OUT_CSV.parent.mkdir(parents=True, exist_ok=True)
    with OUT_CSV.open("w", newline="", encoding="utf-8") as fh:
        w = csv.writer(fh)
        w.writerow([
            "linea", "folio", "fecha", "proveedor", "ean", "sku",
            "descripcion_ticket", "cantidad_mostrador", "costo_unitario",
            "subtotal", "total_ticket",
        ])
        for r in rows:
            sub = round(r["costo"] * r["qty"], 2)
            w.writerow([
                r["linea"], FOLIO, FECHA, PROVEEDOR, "", r["sku"],
                r["snap"], r["qty"], f"{r['costo']:.4f}", f"{sub:.2f}",
                f"{TOTAL_TICKET:.2f}",
            ])


def write_sql(rows: list[dict]) -> None:
    notas = (
        f"Nota {FOLIO} · ticket imprime La Famosa · negocio La Victoria F-20 · "
        "Halls Extra Strong 12 pzas + Skittles Original 48 pzas · "
        "EAN pendiente de caja · stock al confirmar pistola"
    )
    vals = []
    for r in rows:
        vals.append(
            f"  ({r['linea']}, {q(r['sku'])}, {q(r['snap'])}, {q(r['nombre'])}, "
            f"{q(r['marca'])}, {q(r['presentacion'])}, {q(r['categoria'])}, "
            f"{q(r['tipo'])}, {r['qty']}, {r['costo']:.4f}, {r['precio']:.2f})"
        )

    sql = f"""-- Dulcería La Victoria · nota {FOLIO} · {FECHA} 08:50
-- Ticket imprime «DULCERIA LA FAMOSA» (WinCaja) pero el negocio
-- es Dulcería La Victoria, Bodega F-20 Central de Abasto
-- (correo quejas_ysug@dulcerialavictoria.com.mx).
-- Total tarjeta ${TOTAL_TICKET:.2f}. Mayoreo → piezas de mostrador.
--
-- SIN EAN en el ticket: no se inventan códigos. codigo_barras queda null
-- hasta escanear la caja. Stock al confirmar en Recibir + MMAA de la caja.
-- No poner caducidad 0000.
--
-- Idempotente mientras el ticket siga en borrador.
-- Pegar TODO este archivo en Supabase → SQL Editor → Run.

begin;

insert into public.proveedores (nombre, activo)
select {q(PROVEEDOR)}, true
where not exists (
  select 1 from public.proveedores
  where lower(btrim(nombre)) = lower({q(PROVEEDOR)})
);

create temp table _fc_lv_t280034008 (
  linea integer primary key,
  sku text not null,
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

insert into _fc_lv_t280034008
  (linea, sku, snap, nombre, marca, presentacion, categoria, tipo, qty, costo, precio)
values
{',\n'.join(vals)};

-- Altas sin EAN (null). Completar codigo_barras al escanear la caja.
insert into public.productos (
  nombre, sku, codigo_barras, categoria, tipo, descripcion,
  marca, presentacion, costo, precio, stock, stock_minimo,
  activo, requiere_receta
)
select
  t.nombre,
  t.sku,
  null,
  t.categoria,
  t.tipo,
  {q(f'Alta Dulcería La Victoria {FOLIO} · {FECHA} · EAN pendiente de caja · ticket decía La Famosa')},
  t.marca,
  t.presentacion,
  t.costo,
  t.precio,
  0,
  greatest(2, least(t.qty / 4, 10)),
  true,
  false
from _fc_lv_t280034008 t
where not exists (
  select 1 from public.productos p where p.sku = t.sku
);

update public.productos p
set
  costo = t.costo,
  precio = case when coalesce(p.precio, 0) <= 0 then t.precio else p.precio end,
  marca = coalesce(nullif(btrim(p.marca), ''), t.marca),
  presentacion = coalesce(nullif(btrim(p.presentacion), ''), t.presentacion),
  categoria = t.categoria
from _fc_lv_t280034008 t
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
    and coalesce(proveedor, '') ilike '%victoria%'
);

update public.recepciones
set
  total_ticket = {TOTAL_TICKET:.2f},
  fecha = {q(FECHA)},
  proveedor = {q(PROVEEDOR)},
  notas = {q(notas)},
  updated_at = now()
where folio = {q(FOLIO)}
  and coalesce(proveedor, '') ilike '%victoria%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = {q(FOLIO)}
  and coalesce(r.proveedor, '') ilike '%victoria%'
  and r.estado = 'borrador';

insert into public.recepcion_items (
  recepcion_id, producto_id, codigo_escaneado, nombre_snapshot,
  cantidad, fecha_caducidad, numero_lote, costo_estimado, pendiente_alta,
  origen, confirmado, lote_distinto, lote_id
)
select
  r.id,
  p.id,
  null,
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
from _fc_lv_t280034008 t
join public.recepciones r
  on r.folio = {q(FOLIO)}
 and coalesce(r.proveedor, '') ilike '%victoria%'
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
where r.folio = {q(FOLIO)} and coalesce(r.proveedor, '') ilike '%victoria%'
order by i.id;
"""
    OUT_SQL.write_text(sql, encoding="utf-8")


def main() -> None:
    rows = expand()
    suma = sum(round(r["costo"] * r["qty"], 2) for r in rows)
    piezas = sum(r["qty"] for r in rows)
    write_csv(rows)
    write_sql(rows)
    print(f"lineas={len(rows)} piezas={piezas} suma=${suma:.2f} ticket=${TOTAL_TICKET:.2f}")
    print(f"csv={OUT_CSV}")
    print(f"sql={OUT_SQL}")
    assert abs(suma - TOTAL_TICKET) < 0.05, (suma, TOTAL_TICKET)
    assert piezas == 60


if __name__ == "__main__":
    main()
