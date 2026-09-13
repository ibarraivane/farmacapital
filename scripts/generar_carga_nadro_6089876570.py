#!/usr/bin/env python3
"""Pedido Nadro folio 6089876570 (09-sep-2026, 8 renglones) → catálogo + cola Recibir.

Fuente: factura PDF escaneada (Archivo_escaneado_20260910-1158).
EAN corroborados contra catálogo FarmaCapital / GS1 / fichas de lab.
Sin lote ni MMAA: salen de la caja al escanear.
"""
from __future__ import annotations

import math
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from generar_recepcion_borrador import report, write_ticket_csv

ROOT = Path(__file__).resolve().parents[1]
OUT_TICKET = ROOT / "sql" / "generated" / "ticket_nadro_6089876570.csv"
OUT_SQL = ROOT / "sql" / "patch_carga_nadro_6089876570.sql"

FOLIO = "6089876570"
PROVEEDOR = "Nadro"
FECHA = "2026-09-09"
TOTAL_TICKET = 426.83


def precio(costo: float, tipo: str) -> int:
    margen = 25 if tipo == "marca" else 60
    return math.ceil(costo / (1 - margen / 100))


def sku_de(ean: str) -> str:
    return "FC-" + ean[-8:]


def sql_str(s: str | None) -> str:
    if s is None:
        return "null"
    return "'" + str(s).replace("'", "''") + "'"


# nombre ticket, qty, subtotal, ean pistola, sku, match, nombre POS, tipo, cat, receta, ya_catalogo
RAW = [
    ("CRA LUBRIDERM P/NORMAL 120ML", 2, 56.14, "7702031244486", "FC-31244486", "catalogo",
     "Crema Lubriderm piel normal 120 ml", "marca", "Cuidado personal", False, True),
    ("DIRPASID 10 MG 20 TAB LGEN", 2, 15.78, "7502208892638", "FC-08892638", "catalogo",
     "Dirpasid Metoclopramida 10 mg 20 tabletas", "generico", "Medicamentos", False, True),
    ("ESTROPAJO F-CLEAN CLASICA SAL C/1", 3, 22.59, "7503005405168", "FC-05405168", "catalogo",
     "Estropajo F-Clean clásica", "marca", "Cuidado personal", False, True),
    ("METOCLOPRAMIDA 10MG 20 TAB LGEN", 4, 27.52, "7501563310269", "", "nadro",
     "Biopram Metoclopramida 10 mg 20 tabletas", "generico", "Medicamentos", False, False),
    ("PARCHE CURITAS EL GALLO C/6", 2, 109.68, "7702003477270", "", "nadro",
     "Curitas parche para callos El Gallo 6 piezas", "marca", "Botiquín", False, False),
    ("REALDRAX-MXD 20/400MG 10TAB LGEN", 3, 121.02, "7501836010087", "EQ-LIF153", "catalogo",
     "Realdrax MXD Hioscina/Ibuprofeno 20/400 mg 10 tabletas", "generico", "Medicamentos", False, True),
    ("SUEROX 8IONES MORA AZUL/HIERB 630ML", 2, 24.28, "6502400322958", "FC-40032295", "catalogo",
     "Suerox 8 iones Mora Azul 630 ml", "marca", "Cuidado personal", False, True),
    ("TCO DESOD ODOLEX 150 G", 1, 13.64, "7501361111501", "FC-61111501", "catalogo",
     "Talco desodorante Odolex 150 g", "marca", "Cuidado personal", False, True),
]


def rows():
    out = []
    for nombre, qty, sub, ean, sku, match, *_rest in RAW:
        out.append({
            "nombre": nombre,
            "qty": qty,
            "sub": sub,
            "pu": round(sub / qty, 2),
            "ean": ean,
            "sku": sku or sku_de(ean),
            "match": match,
        })
    return out


def altas():
    out = []
    for nombre, qty, sub, ean, sku, match, pos, tipo, cat, receta, ya in RAW:
        pu = round(sub / qty, 2)
        out.append({
            "ean": ean,
            "sku": sku or sku_de(ean),
            "nombre": pos,
            "costo": pu,
            "precio": precio(pu, tipo),
            "tipo": tipo,
            "categoria": cat,
            "receta": receta,
            "ya": ya,
            "snap": nombre,
        })
    return out


def write_unified_sql(path: Path, ticket_rows: list, items: list) -> None:
    by_ean = {r["ean"]: r for r in items}
    vals = []
    for i, row in enumerate(ticket_rows):
        meta = by_ean[row["ean"]]
        vals.append(
            "  ({linea}, {ean}, {sku}, {pos}, {snap}, {qty}, {costo}, {precio}, {tipo}, {cat}, {receta})".format(
                linea=i + 1,
                ean=sql_str(row["ean"]),
                sku=sql_str(row["sku"]),
                pos=sql_str(meta["nombre"]),
                snap=sql_str(row["nombre"]),
                qty=int(row["qty"]),
                costo=f"{row['pu']:.2f}",
                precio=meta["precio"],
                tipo=sql_str(meta["tipo"]),
                cat=sql_str(meta["categoria"]),
                receta="true" if meta["receta"] else "false",
            )
        )

    n_altas = sum(1 for x in items if not x["ya"])
    n_ya = sum(1 for x in items if x["ya"])
    body = f"""-- Pedido Nadro {FOLIO} ({FECHA}) — altas + cola Recibir.
-- SIN bloques dollar-quote (do $$). El SQL Editor de Supabase los corta.
-- {n_altas} altas stock 0. {n_ya} ya estaban: solo costo (y PVP si estaba en 0).
-- Ticket borrador. Stock al escanear + MMAA de la caja. No inventar 0000.
-- Idempotente mientras el ticket siga en borrador.
-- FOTOS PENDIENTES (altas nuevas): Biopram 7501563310269, Curitas El Gallo 7702003477270.
-- Pegar TODO este archivo en Supabase → SQL Editor → Run.

begin;

create temp table _fc_nd6089876570 (
  linea integer primary key,
  ean text not null,
  sku text not null,
  nombre text not null,
  snap text not null,
  qty integer not null,
  costo numeric(12,2) not null,
  precio numeric(12,2) not null,
  tipo text not null,
  categoria text not null,
  receta boolean not null
) on commit drop;

insert into _fc_nd6089876570 (linea, ean, sku, nombre, snap, qty, costo, precio, tipo, categoria, receta) values
{chr(10).join(v + ("," if i < len(vals) - 1 else ";") for i, v in enumerate(vals))}

insert into public.productos (
  nombre, sku, codigo_barras, categoria, tipo, descripcion,
  costo, precio, stock, stock_minimo, activo, requiere_receta
)
select
  t.nombre,
  case
    when exists (
      select 1 from public.productos p
      where p.sku = t.sku and coalesce(p.codigo_barras, '') <> t.ean
    ) then 'FC-ND-' || right(t.ean, 8)
    else t.sku
  end,
  t.ean,
  t.categoria,
  t.tipo,
  'Alta Nadro {FOLIO} · {FECHA} · listo para pistola',
  t.costo,
  t.precio,
  0,
  1,
  true,
  t.receta
from _fc_nd6089876570 t
where public.fc_buscar_producto_escaneo(t.ean) is null;

-- Estropajo: el alta vieja quedó con nombre de ticket/OCR; poner nombre de mostrador.
update public.productos p
set
  nombre = t.nombre,
  updated_at = now()
from _fc_nd6089876570 t
where p.id = public.fc_buscar_producto_escaneo(t.ean)
  and t.ean = '7503005405168'
  and (
    p.nombre ilike '%saluk fashion%'
    or p.nombre ilike '%estropajo f-clean%'
  )
  and p.nombre is distinct from t.nombre;

update public.productos p
set
  costo = t.costo,
  precio = case
    when coalesce(p.precio, 0) <= 0 then t.precio
    else p.precio
  end
from _fc_nd6089876570 t
where p.id = public.fc_buscar_producto_escaneo(t.ean)
  and (
    p.costo is distinct from t.costo
    or coalesce(p.precio, 0) <= 0
  );

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  {sql_str(PROVEEDOR)},
  {sql_str(FOLIO)},
  {sql_str(FECHA)},
  {TOTAL_TICKET:.2f},
  'borrador',
  {sql_str(f"Pedido Nadro {FOLIO} · factura 09-09-26 · EAN corroborados · cola Recibir; stock al confirmar pistola")}
where not exists (
  select 1 from public.recepciones
  where folio = {sql_str(FOLIO)} and coalesce(proveedor, '') ilike '%nadro%'
);

update public.recepciones
set
  total_ticket = {TOTAL_TICKET:.2f},
  fecha = {sql_str(FECHA)},
  proveedor = {sql_str(PROVEEDOR)}
where folio = {sql_str(FOLIO)}
  and coalesce(proveedor, '') ilike '%nadro%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = {sql_str(FOLIO)}
  and coalesce(r.proveedor, '') ilike '%nadro%'
  and r.estado = 'borrador';

insert into public.recepcion_items (
  recepcion_id, producto_id, codigo_escaneado, nombre_snapshot,
  cantidad, fecha_caducidad, numero_lote, costo_estimado, pendiente_alta,
  origen, confirmado, lote_distinto, lote_id
)
select
  r.id,
  v.pid,
  t.ean,
  t.snap,
  t.qty,
  null,
  null,
  t.costo,
  (v.pid is null),
  'pdf',
  false,
  (
    v.pid is not null and exists (
      select 1 from public.lotes l
      where l.producto_id = v.pid
        and coalesce(l.activo, true)
        and coalesce(l.cantidad_actual, 0) > 0
    )
  ),
  null
from _fc_nd6089876570 t
join public.recepciones r
  on r.folio = {sql_str(FOLIO)}
 and coalesce(r.proveedor, '') ilike '%nadro%'
 and r.estado = 'borrador'
left join lateral (
  select coalesce(
    public.fc_buscar_producto_escaneo(t.ean),
    public.fc_buscar_producto_escaneo(t.sku)
  ) as pid
) v on true
order by t.linea;

commit;

select
  i.id,
  i.codigo_escaneado as ean,
  left(i.nombre_snapshot, 48) as nombre,
  i.cantidad,
  i.costo_estimado,
  case when i.pendiente_alta then 'ALTA NUEVA' else 'YA EXISTE' end as estado
from public.recepcion_items i
join public.recepciones r on r.id = i.recepcion_id
where r.folio = {sql_str(FOLIO)} and coalesce(r.proveedor, '') ilike '%nadro%'
order by i.id;
"""
    path.write_text(body, encoding="utf-8")


if __name__ == "__main__":
    r = rows()
    a = altas()
    skus = [x["sku"] for x in a]
    assert len(skus) == len(set(skus)), skus
    assert len(RAW) == 8, len(RAW)
    suma = sum(x["sub"] for x in r)
    assert abs(suma - 390.65) < 0.02, (suma, 390.65)
    # IVA factura = 36.18 (redondeo SAT sobre gravados); total impreso 426.83
    assert abs(suma + 36.18 - TOTAL_TICKET) < 0.02, (suma + 36.18, TOTAL_TICKET)

    write_ticket_csv(OUT_TICKET, folio=FOLIO, fecha=FECHA, proveedor=PROVEEDOR, total=TOTAL_TICKET, rows=r)
    write_unified_sql(OUT_SQL, r, a)
    print(f"csv   {OUT_TICKET}")
    print(f"sql   {OUT_SQL}")
    print(report(r, TOTAL_TICKET))
    print("altas", sum(1 for x in a if not x["ya"]), "ya_catalogo", sum(1 for x in a if x["ya"]))
    for x in a:
        print(f"  {x['ean']}  {x['sku']:12}  {'YA' if x['ya'] else 'NUEVO':5}  ${x['costo']:.2f} → ${x['precio']}  {x['nombre']}")
