#!/usr/bin/env python3
"""Genera el CSV de Recibir + el SQL 'corroborar' del pedido Levic 1020554215.

El pedido surtido no trae lote ni caducidad: el lote se anota cuando llega la
factura y la MMAA SIEMPRE sale de la caja al escanear. Aquí no se inventa nada.
Claves resueltas contra catalogo-imagenes/_trabajo/levic_catalogo.tsv.
"""
from __future__ import annotations

import csv
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
OUT_TICKET = ROOT / "sql" / "generated" / "ticket_levic_1020554215.csv"
OUT_SQL = ROOT / "sql" / "patch_recepcion_levic_1020554215_corroborar.sql"

FOLIO = "1020554215"
PROVEEDOR = "Levic"
FECHA = "2026-08-25"          # fecha del pedido; cámbiala si el papel dice otra
TOTAL_TICKET = 1377.28        # IVA 0.00 en todo el pedido

# posicion, clave Levic, EAN de catálogo Levic, nombre del pedido, surtido, PU, subtotal
ROWS = [
    (10,  "AMS165", "7501349012943", "FLUCONAZOL 1 CAPS 150 MG",                   4,  13.61,  54.44, "FC-5BC5F234"),
    (20,  "AMS253", "7501349027329", "DEXAMETASONA 1 FA 8MG/2 ML",                 4,   9.28,  37.12, "EQ-AMS253"),
    (30,  "AMS495", "7501349020139", "FLUCONAZOL 10 CAP 100 MG",                   1,  18.29,  18.29, ""),
    (40,  "BEA420", "7502209857032", "FLUCONAZOL 10 CAPS 100 MG",                  1,  17.35,  17.35, ""),
    (50,  "CHI030", "7501088505126", "NEURALIN INY 2 AMP 200MG/100MG/5GM",         1, 148.89, 148.89, "FC-8505126"),
    (60,  "GNO016", "650240029165",  "LOMECAN DUO 3 OVULOS Y CREMA 200 MG",        2, 176.10, 352.20, ""),
    (70,  "LIV177", "7501058714312", "TEMPRA GOTAS UVA 10 G 30 ML",                1, 168.72, 168.72, ""),
    (80,  "RAM156", "7502227879610", "DUET FLEXENOL NF 16 TAB 275/300 MG",         5,  30.06, 150.30, ""),
    (90,  "SIE060", "7501300407047", "FEBRAX 15 TAB 275/300 MG",                   1, 204.38, 204.38, ""),
    (100, "SIE061", "7501300407054", "FEBRAX SUPOSITORIOS 1CJA C/5 100/200 MG",    1, 128.75, 128.75, ""),
    (110, "SOF054", "7501482200016", "OMEPRAZOL (AKTYZAR) 120 CAPS 20MG",          2,  48.42,  96.84, "FC-82200016"),
]


def sql_str(v: str) -> str:
    return "'" + str(v).replace("'", "''") + "'"


def write_ticket_csv() -> None:
    OUT_TICKET.parent.mkdir(parents=True, exist_ok=True)
    with OUT_TICKET.open("w", newline="", encoding="utf-8") as fh:
        w = csv.writer(fh)
        w.writerow([
            "linea", "folio", "fecha", "proveedor", "ean", "clave_levic",
            "descripcion_ticket", "cantidad", "precio_unitario", "subtotal",
            "lote", "caducidad", "sku_farmacapital", "total_ticket",
        ])
        for i, (pos, clave, ean, nombre, qty, pu, sub, sku) in enumerate(ROWS, start=1):
            w.writerow([
                i, FOLIO, FECHA, PROVEEDOR, ean, clave, nombre, qty,
                f"{pu:.2f}", f"{sub:.2f}", "", "", sku, f"{TOTAL_TICKET:.2f}",
            ])


def write_sql() -> None:
    lines = [
        f"-- Pedido Levic {FOLIO} ({FECHA}) — lo deja en la cola de Recibir, en borrador.",
        "-- No suma stock: las piezas entran al escanear con pistola y poner MMAA de la caja.",
        "-- El pedido surtido no trae lote; se queda en null hasta que llegue la factura.",
        "-- Idempotente. Pegar en Supabase.",
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
        f"  where folio = {sql_str(FOLIO)} and coalesce(proveedor, '') ilike '%levic%'",
        "  order by id desc",
        "  limit 1;",
        "",
        "  if v_id is not null and (select estado from public.recepciones where id = v_id) <> 'borrador' then",
        f"    raise notice 'Recepcion Levic {FOLIO} ya cerrada (id %)', v_id;",
        "  else",
        "    if v_id is null then",
        "      insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)",
        f"      values ({sql_str(PROVEEDOR)}, {sql_str(FOLIO)}, {sql_str(FECHA)}, {TOTAL_TICKET:.2f}, 'borrador',",
        f"              'Pedido Levic {FOLIO} · cola Recibir; stock al confirmar pistola')",
        "      returning id into v_id;",
        "    else",
        "      delete from public.recepcion_items where recepcion_id = v_id;",
        "      update public.recepciones",
        f"      set total_ticket = {TOTAL_TICKET:.2f}, fecha = {sql_str(FECHA)}, updated_at = now()",
        "      where id = v_id;",
        "    end if;",
        "",
        "    for r in",
        "      select * from (values",
    ]
    vals = []
    for pos, clave, ean, nombre, qty, pu, sub, sku in ROWS:
        costo = f"{pu:.2f}::numeric" if pos == ROWS[0][0] else f"{pu:.2f}"
        vals.append(f"        ({sql_str(ean)}, {sql_str(nombre)}, {qty}, {costo}, {sql_str(sku) if sku else 'null'})")
    lines.append(",\n".join(vals))
    lines += [
        "      ) as t(ean, nombre, qty, costo, sku)",
        "    loop",
        "      v_pid := public.fc_buscar_producto_escaneo(r.ean);",
        "      if v_pid is null and r.sku is not null then",
        "        v_pid := public.fc_buscar_producto_escaneo(r.sku);",
        "      end if;",
        "",
        "      insert into public.recepcion_items (",
        "        recepcion_id, producto_id, codigo_escaneado, nombre_snapshot,",
        "        cantidad, fecha_caducidad, numero_lote, costo_estimado, pendiente_alta,",
        "        origen, confirmado, lote_distinto, lote_id",
        "      ) values (",
        "        v_id, v_pid, r.ean, r.nombre, r.qty, null, null, r.costo,",
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
        f"    raise notice 'Recepcion Levic {FOLIO} lista id=% — escanear caja por caja', v_id;",
        "  end if;",
        "end $$;",
        "",
        "commit;",
        "",
        "select",
        "  i.id,",
        "  i.codigo_escaneado as ean,",
        "  left(i.nombre_snapshot, 42) as nombre,",
        "  i.cantidad,",
        "  i.costo_estimado,",
        "  case when i.pendiente_alta then 'ALTA NUEVA' else 'YA EXISTE' end as estado",
        "from public.recepcion_items i",
        "join public.recepciones r on r.id = i.recepcion_id",
        f"where r.folio = {sql_str(FOLIO)} and coalesce(r.proveedor, '') ilike '%levic%'",
        "order by i.id;",
        "",
    ]
    OUT_SQL.write_text("\n".join(lines), encoding="utf-8")


if __name__ == "__main__":
    write_ticket_csv()
    write_sql()
    suma = sum(r[6] for r in ROWS)
    print(f"csv  {OUT_TICKET}")
    print(f"sql  {OUT_SQL}")
    print(f"lineas {len(ROWS)}  suma ${suma:.2f}  pedido ${TOTAL_TICKET:.2f}  cuadra={abs(suma - TOTAL_TICKET) < 0.01}")
    print(f"piezas {sum(r[4] for r in ROWS)}")
