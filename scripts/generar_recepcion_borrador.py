#!/usr/bin/env python3
"""CSV + SQL de un ticket de compra para la cola Recibir (borrador, sin stock)."""
from __future__ import annotations

import csv
from pathlib import Path


def sql_str(v: str | None) -> str:
    if v is None:
        return "null"
    return "'" + str(v).replace("'", "''") + "'"


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
    lines = [
        f"-- Pedido {proveedor} {folio} ({fecha}) — cola Recibir, borrador.",
        "-- No suma stock: las piezas entran al escanear con pistola y poner MMAA de la caja.",
        "-- El pedido no trae lote ni caducidad; se quedan en null. No inventar 0000.",
        "-- Idempotente. Pegar en Supabase → SQL Editor → Run.",
        "",
        "begin;",
        "",
        "do $$",
        "declare",
        "  v_id bigint;",
        "  r record;",
        "  v_pid bigint;",
        "begin",
        "  select id into v_id",
        "  from public.recepciones",
        f"  where folio = {sql_str(folio)} and coalesce(proveedor, '') ilike {sql_str('%' + proveedor_ilike + '%')}",
        "  order by id desc",
        "  limit 1;",
        "",
        "  if v_id is not null and (select estado from public.recepciones where id = v_id) <> 'borrador' then",
        f"    raise notice 'Recepcion {proveedor} {folio} ya cerrada (id %)', v_id;",
        "  else",
        "    if v_id is null then",
        "      insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)",
        f"      values ({sql_str(proveedor)}, {sql_str(folio)}, {sql_str(fecha)}, {total:.2f}, 'borrador',",
        f"              {sql_str(notas)})",
        "      returning id into v_id;",
        "    else",
        "      delete from public.recepcion_items where recepcion_id = v_id;",
        "      update public.recepciones",
        f"      set total_ticket = {total:.2f}, fecha = {sql_str(fecha)}, proveedor = {sql_str(proveedor)}, updated_at = now()",
        "      where id = v_id;",
        "    end if;",
        "",
        "    for r in",
        "      select * from (values",
    ]
    vals = []
    for i, row in enumerate(rows):
        ean = row.get("ean") or ""
        sku = row.get("sku") or None
        costo = f"{row['pu']:.2f}::numeric" if i == 0 else f"{row['pu']:.2f}"
        vals.append(
            f"        ({sql_str(ean)}, {sql_str(row['nombre'])}, {int(row['qty'])}, {costo}, {sql_str(sku)})"
        )
    lines.append(",\n".join(vals))
    lines += [
        "      ) as t(ean, nombre, qty, costo, sku)",
        "    loop",
        "      v_pid := null;",
        "      if r.ean is not null and btrim(r.ean) <> '' then",
        "        v_pid := public.fc_buscar_producto_escaneo(r.ean);",
        "      end if;",
        "      if v_pid is null and r.sku is not null then",
        "        v_pid := public.fc_buscar_producto_escaneo(r.sku);",
        "      end if;",
        "",
        "      insert into public.recepcion_items (",
        "        recepcion_id, producto_id, codigo_escaneado, nombre_snapshot,",
        "        cantidad, fecha_caducidad, numero_lote, costo_estimado, pendiente_alta,",
        "        origen, confirmado, lote_distinto, lote_id",
        "      ) values (",
        "        v_id, v_pid, nullif(btrim(r.ean), ''), r.nombre, r.qty, null, null, r.costo,",
        "        (v_pid is null), 'pdf', false,",
        "        (v_pid is not null and exists (",
        "          select 1 from public.lotes l",
        "          where l.producto_id = v_pid and coalesce(l.activo, true)",
        "            and coalesce(l.cantidad_actual, 0) > 0",
        "        )),",
        "        null",
        "      );",
        "    end loop;",
        "",
        f"    raise notice 'Recepcion {proveedor} {folio} lista id=% — escanear caja por caja', v_id;",
        "  end if;",
        "end $$;",
        "",
        "commit;",
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
        f"where r.folio = {sql_str(folio)} and coalesce(r.proveedor, '') ilike {sql_str('%' + proveedor_ilike + '%')}",
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
