#!/usr/bin/env python3
"""Ticket City Mark 2026-09-05 → CSV + SQL cola Recibir.

Fuente: ticket físico «Cliente: PUBLICO EN GENERAL».
84 líneas / 119 piezas / $5,007.41. Sin lote ni MMAA.
"""
from __future__ import annotations

import csv
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from generar_recepcion_borrador import report, sql_str

ROOT = Path(__file__).resolve().parents[1]
SRC = ROOT / "sql" / "generated" / "ticket_citymark_20260905.csv"
OUT_CSV = ROOT / "sql" / "generated" / "ticket_citymark_20260905.csv"
OUT_SQL = ROOT / "sql" / "patch_recepcion_citymark_20260905_corroborar.sql"

FOLIO = "20260905"
PROVEEDOR = "City Mark"
FECHA = "2026-09-05"
TOTAL = 5007.41


def load() -> list[dict]:
    rows = list(csv.DictReader(SRC.open(encoding="utf-8")))
    out = []
    for r in rows:
        qty = int(r["cantidad"])
        sub = float(r["subtotal"])
        out.append(
            {
                "nombre": r["descripcion_ticket"],
                "qty": qty,
                "sub": sub,
                "pu": round(sub / qty, 3),
                "ean": r["ean"],
            }
        )
    assert len(out) == 84
    assert abs(sum(x["sub"] for x in out) - TOTAL) < 0.02
    assert sum(x["qty"] for x in out) == 119
    return out


def write_csv(data: list[dict]) -> None:
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
                "descripcion_ticket",
                "cantidad",
                "precio_unitario",
                "subtotal",
                "lote",
                "caducidad",
                "sku_farmacapital",
                "total_ticket",
                "match",
            ]
        )
        for i, r in enumerate(data, start=1):
            w.writerow(
                [
                    i,
                    FOLIO,
                    FECHA,
                    PROVEEDOR,
                    r["ean"],
                    r["nombre"],
                    r["qty"],
                    f"{r['pu']:.3f}",
                    f"{r['sub']:.2f}",
                    "",
                    "",
                    "",
                    f"{TOTAL:.2f}",
                    "ticket",
                ]
            )


def write_sql(data: list[dict]) -> None:
    notas = (
        f"Pedido City Mark {FOLIO} · ticket PUBLICO EN GENERAL · "
        "EAN del ticket · cola Recibir; stock al confirmar pistola"
    )
    lines = [
        f"-- Pedido City Mark {FOLIO} ({FECHA}) — cola Recibir, borrador.",
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
        f"  where folio = {sql_str(FOLIO)} and coalesce(proveedor, '') ilike '%city mark%'",
        "  order by id desc",
        "  limit 1;",
        "",
        "  if v_id is not null and (select estado from public.recepciones where id = v_id) <> 'borrador' then",
        f"    raise notice 'Recepcion City Mark {FOLIO} ya cerrada (id %)', v_id;",
        "  else",
        "    if v_id is null then",
        "      insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)",
        f"      values ({sql_str(PROVEEDOR)}, {sql_str(FOLIO)}, {sql_str(FECHA)}, {TOTAL:.2f}, 'borrador',",
        f"              {sql_str(notas)})",
        "      returning id into v_id;",
        "    else",
        "      delete from public.recepcion_items where recepcion_id = v_id;",
        "      update public.recepciones",
        f"      set total_ticket = {TOTAL:.2f}, fecha = {sql_str(FECHA)}, proveedor = {sql_str(PROVEEDOR)}, updated_at = now()",
        "      where id = v_id;",
        "    end if;",
        "",
        "    for r in",
        "      select * from (values",
    ]
    vals = []
    for i, row in enumerate(data):
        costo = f"{row['pu']:.3f}::numeric" if i == 0 else f"{row['pu']:.3f}"
        vals.append(
            f"        ({sql_str(row['ean'])}, {sql_str(row['nombre'])}, {int(row['qty'])}, {costo}, null)"
        )
    lines.append(",\n".join(vals))
    lines += [
        "      ) as t(ean, nombre, qty, costo, sku)",
        "    loop",
        "      v_pid := null;",
        "      if r.ean is not null and btrim(r.ean) <> '' then",
        "        v_pid := public.fc_buscar_producto_escaneo(r.ean);",
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
        f"    raise notice 'Recepcion City Mark {FOLIO} lista id=% — escanear caja por caja', v_id;",
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
        f"where r.folio = {sql_str(FOLIO)} and coalesce(r.proveedor, '') ilike '%city mark%'",
        "order by i.id;",
        "",
    ]
    OUT_SQL.write_text("\n".join(lines), encoding="utf-8")


def main() -> None:
    data = load()
    write_csv(data)
    write_sql(data)
    print(report([{**r, "match": "ticket"} for r in data], TOTAL))
    print(f"csv={OUT_CSV}")
    print(f"sql={OUT_SQL}")


if __name__ == "__main__":
    main()
