#!/usr/bin/env python3
"""CSV + SQL de un ticket de compra para la cola Recibir (borrador, sin stock)."""
from __future__ import annotations

import csv
import re
from pathlib import Path


def sql_str(v: str | None) -> str:
    if v is None:
        return "null"
    return "'" + str(v).replace("'", "''") + "'"


def temp_table_name(folio: str, proveedor_ilike: str) -> str:
    slug = re.sub(r"[^a-zA-Z0-9]+", "", f"{proveedor_ilike}{folio}")[:24] or "ticket"
    return f"_fc_rx_{slug.lower()}"


def write_ticket_csv(path: Path, *, folio: str, fecha: str, proveedor: str, total: float, rows: list) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", newline="", encoding="utf-8") as fh:
        w = csv.writer(fh)
        w.writerow([
            "linea", "folio", "fecha", "proveedor", "ean",
            "descripcion_ticket", "cantidad", "precio_unitario", "subtotal",
            "lote", "caducidad", "sku_farmacapital", "total_ticket", "match",
        ])
        for i, r in enumerate(rows, start=1):
            w.writerow([
                i, folio, fecha, proveedor, r.get("ean") or "",
                r["nombre"], r["qty"], f"{r['pu']:.2f}", f"{r['sub']:.2f}",
                "", "", r.get("sku") or "", f"{total:.2f}", r.get("match") or "",
            ])


def write_recepcion_sql(
    path: Path,
    *,
    folio: str,
    proveedor: str,
    proveedor_ilike: str,
    fecha: str,
    total: float,
    notas: str,
    rows: list,
) -> None:
    """SQL sin bloques dollar-quote: el SQL Editor de Supabase corta do $$."""
    tmp = temp_table_name(folio, proveedor_ilike)
    folio_sql = sql_str(folio)
    prov_sql = sql_str(proveedor)
    prov_ilike_sql = sql_str("%" + proveedor_ilike + "%")
    fecha_sql = sql_str(fecha)
    notas_sql = sql_str(notas)

    lines = [
        f"-- Pedido {proveedor} {folio} ({fecha}) — cola Recibir, borrador.",
        "-- SIN bloques dollar-quote (do $$). El SQL Editor de Supabase los corta.",
        "-- No suma stock: las piezas entran al escanear con pistola y poner MMAA de la caja.",
        "-- El pedido no trae lote ni caducidad; se quedan en null. No inventar 0000.",
        "-- Idempotente mientras el ticket siga en borrador.",
        "-- Si ya está confirmado/cerrado, no crea otro ni toca renglones.",
        "-- Pegar TODO este archivo en Supabase → SQL Editor → Run.",
        "",
        "begin;",
        "",
        f"create temp table {tmp} (",
        "  linea integer primary key,",
        "  ean text,",
        "  sku text,",
        "  nombre text not null,",
        "  qty integer not null,",
        "  costo numeric(12,2) not null",
        ") on commit drop;",
        "",
        f"insert into {tmp} (linea, ean, sku, nombre, qty, costo) values",
    ]

    vals = []
    for i, row in enumerate(rows, start=1):
        ean = row.get("ean") or None
        sku = row.get("sku") or None
        vals.append(
            f"  ({i}, {sql_str(ean)}, {sql_str(sku)}, {sql_str(row['nombre'])}, "
            f"{int(row['qty'])}, {row['pu']:.2f})"
        )
    lines.append(",\n".join(vals) + ";")

    lines += [
        "",
        "insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)",
        "select",
        f"  {prov_sql},",
        f"  {folio_sql},",
        f"  {fecha_sql},",
        f"  {total:.2f},",
        "  'borrador',",
        f"  {notas_sql}",
        "where not exists (",
        "  select 1 from public.recepciones",
        f"  where folio = {folio_sql} and coalesce(proveedor, '') ilike {prov_ilike_sql}",
        ");",
        "",
        "update public.recepciones",
        "set",
        f"  total_ticket = {total:.2f},",
        f"  fecha = {fecha_sql},",
        f"  proveedor = {prov_sql},",
        f"  notas = {notas_sql},",
        "  updated_at = now()",
        f"where folio = {folio_sql}",
        f"  and coalesce(proveedor, '') ilike {prov_ilike_sql}",
        "  and estado = 'borrador';",
        "",
        "delete from public.recepcion_items i",
        "using public.recepciones r",
        "where i.recepcion_id = r.id",
        f"  and r.folio = {folio_sql}",
        f"  and coalesce(r.proveedor, '') ilike {prov_ilike_sql}",
        "  and r.estado = 'borrador';",
        "",
        "insert into public.recepcion_items (",
        "  recepcion_id, producto_id, codigo_escaneado, nombre_snapshot,",
        "  cantidad, fecha_caducidad, numero_lote, costo_estimado, pendiente_alta,",
        "  origen, confirmado, lote_distinto, lote_id",
        ")",
        "select",
        "  r.id,",
        "  v.pid,",
        "  nullif(btrim(t.ean), ''),",
        "  t.nombre,",
        "  t.qty,",
        "  null,",
        "  null,",
        "  t.costo,",
        "  (v.pid is null),",
        "  'pdf',",
        "  false,",
        "  (",
        "    v.pid is not null and exists (",
        "      select 1 from public.lotes l",
        "      where l.producto_id = v.pid",
        "        and coalesce(l.activo, true)",
        "        and coalesce(l.cantidad_actual, 0) > 0",
        "    )",
        "  ),",
        "  null",
        f"from {tmp} t",
        "join public.recepciones r",
        f"  on r.folio = {folio_sql}",
        f" and coalesce(r.proveedor, '') ilike {prov_ilike_sql}",
        " and r.estado = 'borrador'",
        "left join lateral (",
        "  select coalesce(",
        "    case when nullif(btrim(t.ean), '') is not null",
        "      then public.fc_buscar_producto_escaneo(nullif(btrim(t.ean), ''))",
        "      else null end,",
        "    case when nullif(btrim(t.sku), '') is not null",
        "      then public.fc_buscar_producto_escaneo(nullif(btrim(t.sku), ''))",
        "      else null end",
        "  ) as pid",
        ") v on true",
        "order by t.linea;",
        "",
        "commit;",
        "",
        "-- Diagnóstico: si renglones = 0 y estado <> borrador → ya estaba cerrada.",
        "-- Si 0 filas → no se insertó (revisa error arriba).",
        "select",
        "  r.id as recepcion_id,",
        "  r.folio,",
        "  r.estado,",
        "  r.total_ticket,",
        "  count(i.*) as renglones,",
        "  count(*) filter (where not coalesce(i.confirmado, false)) as pendientes_pistola",
        "from public.recepciones r",
        "left join public.recepcion_items i on i.recepcion_id = r.id",
        f"where r.folio = {folio_sql}",
        f"  and coalesce(r.proveedor, '') ilike {prov_ilike_sql}",
        "group by r.id, r.folio, r.estado, r.total_ticket",
        "order by r.id;",
        "",
        "select",
        "  i.id,",
        "  i.codigo_escaneado as ean,",
        "  left(i.nombre_snapshot, 48) as nombre,",
        "  i.cantidad,",
        "  i.costo_estimado,",
        "  case when i.pendiente_alta then 'ALTA NUEVA' else 'YA EXISTE' end as estado",
        "from public.recepcion_items i",
        "join public.recepciones r on r.id = i.recepcion_id",
        f"where r.folio = {folio_sql} and coalesce(r.proveedor, '') ilike {prov_ilike_sql}",
        "order by i.id;",
        "",
    ]
    path.write_text("\n".join(lines), encoding="utf-8")


def report(rows: list, total: float) -> str:
    suma = sum(r["sub"] for r in rows)
    piezas = sum(r["qty"] for r in rows)
    con_ean = sum(1 for r in rows if r.get("ean"))
    return (
        f"lineas {len(rows)}  piezas {piezas}  suma ${suma:.2f}  "
        f"pedido ${total:.2f}  cuadra={abs(suma - total) < 0.05}  ean={con_ean}/{len(rows)}"
    )
