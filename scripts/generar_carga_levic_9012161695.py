#!/usr/bin/env python3
"""Factura Levic A 9012161695 (CFDI 01-sep-2026) → CSV Recibir + SQL.

Costo = Precio neto del CFDI. IVA $16.26 solo de Optimila-H (Grin).
Lote de fábrica sí viene en la factura (se anota en el ticket).
Caducidad del papel NO se escribe en SQL: MMAA sale de la caja. 0000 inválido.
"""
from __future__ import annotations

import csv
import math
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from generar_recepcion_borrador import report, sql_str

ROOT = Path(__file__).resolve().parents[1]
OUT_TICKET = ROOT / "sql" / "generated" / "ticket_levic_9012161695.csv"
OUT_SQL = ROOT / "sql" / "patch_carga_levic_9012161695.sql"

FOLIO = "9012161695"
PROVEEDOR = "Levic"
FECHA = "2026-09-01"
TOTAL_TICKET = 1045.64  # CFDI Total
SUBTOTAL_CFDI = 1029.38
IVA_CFDI = 16.26  # solo Optimila-H
UUID = "B4C6FCD0-6A11-4A09-A23C-DA984F71C7FD"


def ceil_pvp(costo: float, factor: float = 1.6) -> float:
    return float(math.ceil(costo * factor))


# match=False → no estaba en historial local (SQL igual busca por EAN/SKU).
# EAN: FarmaSmart / Curitek / Sufarmed / YZA · portal Levic (INN023 = 00840000…).
ROWS = [
    {
        "clave": "ALP0634",
        "ean": "7502226294766",
        "nombre": "Losartan Alpharma 30 tab 50 mg",
        "desc_ticket": "LOSARTAN 30 TAB 50 MG",
        "qty": 5,
        "pu": 11.08,
        "sub": 55.40,
        "lote": "2606703",
        "caducidad": "2028-06-30",
        "sku": "EQ-ALP0634",
        "match": False,
        "categoria": "Medicamentos",
        "tipo": "generico",
        "marca": "Alpharma",
        "presentacion": "Caja con 30 tabletas",
        "principio": "Losartán potásico",
        "concentracion": "50 mg",
        "receta": True,
        "stock_minimo": 4,
    },
    {
        "clave": "AMS318",
        "ean": "7501349028159",
        "nombre": "Losartan AMSA 30 comprimidos 50 mg",
        "desc_ticket": "LOSARTAN 30 COMP 50 MG",
        "qty": 5,
        "pu": 11.90,
        "sub": 59.50,
        "lote": "U26M066",
        "caducidad": "2028-03-30",
        "sku": "EQ-AMS318",
        "match": False,
        "categoria": "Medicamentos",
        "tipo": "generico",
        "marca": "AMSA",
        "presentacion": "Caja con 30 comprimidos",
        "principio": "Losartán potásico",
        "concentracion": "50 mg",
        "receta": True,
        "stock_minimo": 4,
    },
    {
        "clave": "BEA367",
        "ean": "7501342803548",
        "nombre": "Losartan beadvance 60 tab 50 mg",
        "desc_ticket": "LOSARTAN 60 TAB 50 MG",
        "qty": 2,
        "pu": 28.11,
        "sub": 56.22,
        "lote": "5GM003B",
        "caducidad": "2027-07-30",
        "sku": "EQ-BEA367",
        "match": False,
        "categoria": "Medicamentos",
        "tipo": "generico",
        "marca": "beadvance",
        "presentacion": "Caja con 60 tabletas",
        "principio": "Losartán potásico",
        "concentracion": "50 mg",
        "receta": True,
        "stock_minimo": 2,
    },
    {
        "clave": "INN022",
        "ean": "008400005656",
        "nombre": "Optimila-H Grin gotas 15 mL",
        "desc_ticket": "OPTIMILA-H 1 GOT 15 ML (GRIN)",
        "qty": 2,
        "pu": 50.82,
        "sub": 101.64,
        "lote": "XB01048",
        "caducidad": "2027-11-30",
        "sku": "EQ-INN022",
        "match": False,
        "categoria": "Medicamentos",
        "tipo": "marca",
        "marca": "Grin",
        "presentacion": "Frasco gotero 15 mL",
        "principio": "Manzanilla / Hialuronato",
        "concentracion": None,
        "receta": False,
        "stock_minimo": 2,
    },
    {
        "clave": "MAV204",
        "ean": "7502009744358",
        "nombre": "Alderan Losartán 15 tab 100 mg",
        "desc_ticket": "ALDERAN 15 TAB 100 MG",
        "qty": 2,
        "pu": 21.25,
        "sub": 42.50,
        "lote": "256436",
        "caducidad": "2027-11-30",
        "sku": "EQ-MAV204",
        "match": False,
        "categoria": "Medicamentos",
        "tipo": "marca",
        "marca": "Maver",
        "presentacion": "Caja con 15 tabletas",
        "principio": "Losartán potásico",
        "concentracion": "100 mg",
        "receta": True,
        "stock_minimo": 2,
    },
    {
        "clave": "VAL129",
        "ean": "7501122961901",
        "nombre": "Eldoquin crema 4% 30 g",
        "desc_ticket": "ELDOQUIN 4 % 1 CMA 30 G",
        "qty": 2,
        "pu": 357.06,
        "sub": 714.12,
        "lote": "438137",
        "caducidad": "2031-02-28",
        "sku": "EQ-VAL129",
        "match": False,
        "categoria": "Medicamentos",
        "tipo": "marca",
        "marca": "Eldoquin",
        "presentacion": "Tubo 30 g",
        "principio": "Hidroquinona",
        "concentracion": "4%",
        "receta": False,
        "stock_minimo": 1,
    },
]


def write_ticket_csv() -> None:
    OUT_TICKET.parent.mkdir(parents=True, exist_ok=True)
    with OUT_TICKET.open("w", newline="", encoding="utf-8") as fh:
        w = csv.writer(fh)
        w.writerow([
            "linea", "folio", "fecha", "proveedor", "ean", "clave_levic",
            "descripcion_ticket", "cantidad", "precio_unitario", "subtotal",
            "lote", "caducidad", "sku_farmacapital", "total_ticket", "match",
        ])
        for i, r in enumerate(ROWS, start=1):
            w.writerow([
                i, FOLIO, FECHA, PROVEEDOR, r["ean"], r["clave"],
                r["desc_ticket"], r["qty"], f"{r['pu']:.2f}", f"{r['sub']:.2f}",
                r["lote"], r["caducidad"], r["sku"], f"{TOTAL_TICKET:.2f}",
                "recibir" if r["match"] else "alta",
            ])


def write_sql() -> None:
    altas = [r for r in ROWS if not r["match"]]
    notas = (
        f"Factura Levic A {FOLIO} · CFDI {UUID} · cola Recibir; "
        "stock al confirmar pistola · lote de fábrica en el papel; MMAA de la caja"
    )
    lines = [
        f"-- Levic · factura interna A {FOLIO} · CFDI 01-sep-2026 23:14",
        f"-- Folio fiscal {UUID} · PUE efectivo ${TOTAL_TICKET:.2f}",
        f"-- Receptor LUIS ANGEL PALILLERO VENTURA · 6 renglones · 18 pzas.",
        f"-- Subtotal CFDI ${SUBTOTAL_CFDI:.2f} + IVA ${IVA_CFDI:.2f} (solo Optimila-H) = ${TOTAL_TICKET:.2f}.",
        "-- Costo = Precio neto. Lote = de fábrica (sí viene en la factura).",
        "-- Caducidad del papel NO se escribe aquí: Recibir captura MMAA de la caja.",
        "-- 0000 es inválido.",
        "--",
        f"-- {len(ROWS) - len(altas)} ya estaban · {len(altas)} altas "
        "(Losartan Alpharma/AMSA/beadvance, Optimila-H, Alderan, Eldoquin).",
        "-- Altas: stock 0. En existentes solo se actualiza costo (no el PVP).",
        "-- Idempotente. Pegar en Supabase SQL Editor (archivo completo).",
        "",
        "begin;",
        "",
        "-- ── 1) Catálogo: altas faltantes + costo de esta factura ──────────",
        "do $$",
        "declare",
        "  r record;",
        "  v_pid bigint;",
        "  n_alta integer := 0;",
        "  n_costo integer := 0;",
        "begin",
        "  for r in",
        "    select * from (values",
    ]
    vals = []
    for i, r in enumerate(ROWS):
        costo = f"{r['pu']:.2f}::numeric" if i == 0 else f"{r['pu']:.2f}"
        precio = f"{ceil_pvp(r['pu']):.2f}"
        receta = "true" if r["receta"] else "false"
        alta = "true" if not r["match"] else "false"
        nota = f"Factura Levic {FOLIO} · clave {r['clave']} · lote {r['lote']}"
        vals.append(
            "      ({ean}, {sku}, {nombre}, {cat}, {tipo}, {costo}, {precio}, {smin}, "
            "{marca}, {pres}, {pa}, {conc}, {receta}, {notas}, {alta})".format(
                ean=sql_str(r["ean"]),
                sku=sql_str(r["sku"]),
                nombre=sql_str(r["nombre"]),
                cat=sql_str(r["categoria"]),
                tipo=sql_str(r["tipo"]),
                costo=costo,
                precio=precio,
                smin=r["stock_minimo"],
                marca=sql_str(r["marca"]),
                pres=sql_str(r["presentacion"]),
                pa=sql_str(r["principio"]),
                conc=sql_str(r["concentracion"]),
                receta=receta,
                notas=sql_str(nota),
                alta=alta,
            )
        )
    lines.append(",\n".join(vals))
    lines += [
        "    ) as t(ean, sku, nombre, categoria, tipo, costo, precio, stock_minimo,",
        "           marca, presentacion, principio, concentracion, receta, notas, es_alta)",
        "  loop",
        "    v_pid := public.fc_buscar_producto_escaneo(r.ean);",
        "    if v_pid is null then",
        "      v_pid := public.fc_buscar_producto_escaneo(r.sku);",
        "    end if;",
        "",
        "    if v_pid is null then",
        "      select f.producto_id into v_pid",
        "      from public.create_producto_with_lote(",
        "        jsonb_build_object(",
        "          'nombre', r.nombre,",
        "          'sku', r.sku,",
        "          'codigo_barras', r.ean,",
        "          'categoria', r.categoria,",
        "          'tipo', r.tipo,",
        "          'descripcion', r.notas,",
        "          'costo', r.costo,",
        "          'precio', r.precio,",
        "          'stock_minimo', r.stock_minimo,",
        "          'activo', true,",
        "          'requiere_receta', r.receta",
        "        ),",
        "        0, null, null::date, r.costo, null::bigint",
        "      ) f;",
        "      n_alta := n_alta + 1;",
        "    else",
        "      update public.productos set",
        "        costo = r.costo,",
        "        stock_minimo = greatest(coalesce(stock_minimo, 0), r.stock_minimo),",
        "        codigo_barras = coalesce(nullif(codigo_barras, ''), r.ean)",
        "      where id = v_pid;",
        "      n_costo := n_costo + 1;",
        "    end if;",
        "",
        "    update public.productos set",
        "      marca = coalesce(nullif(marca, ''), r.marca),",
        "      presentacion = coalesce(nullif(presentacion, ''), r.presentacion),",
        "      principio_activo = coalesce(nullif(principio_activo, ''), r.principio),",
        "      concentracion = coalesce(nullif(concentracion, ''), r.concentracion)",
        "    where id = v_pid;",
        "  end loop;",
        "",
        f"  raise notice 'Levic {FOLIO}: % altas de catálogo, % costos actualizados (stock = Recibir)',",
        "    n_alta, n_costo;",
        "end $$;",
        "",
        "-- ── 2) Cola Recibir (borrador, sin sumar piezas) ──────────────────",
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
        f"              {sql_str(notas)})",
        "      returning id into v_id;",
        "    else",
        "      delete from public.recepcion_items where recepcion_id = v_id;",
        "      update public.recepciones",
        f"      set total_ticket = {TOTAL_TICKET:.2f}, fecha = {sql_str(FECHA)},",
        f"          proveedor = {sql_str(PROVEEDOR)}, notas = {sql_str(notas)}, updated_at = now()",
        "      where id = v_id;",
        "    end if;",
        "",
        "    for r in",
        "      select * from (values",
    ]
    recv = []
    for i, r in enumerate(ROWS):
        costo = f"{r['pu']:.2f}::numeric" if i == 0 else f"{r['pu']:.2f}"
        recv.append(
            f"        ({sql_str(r['ean'])}, {sql_str(r['nombre'])}, {r['qty']}, {costo}, "
            f"{sql_str(r['sku'])}, {sql_str(r['lote'])})"
        )
    lines.append(",\n".join(recv))
    lines += [
        "      ) as t(ean, nombre, qty, costo, sku, lote)",
        "    loop",
        "      v_pid := public.fc_buscar_producto_escaneo(r.ean);",
        "      if v_pid is null then",
        "        v_pid := public.fc_buscar_producto_escaneo(r.sku);",
        "      end if;",
        "",
        "      insert into public.recepcion_items (",
        "        recepcion_id, producto_id, codigo_escaneado, nombre_snapshot,",
        "        cantidad, fecha_caducidad, numero_lote, costo_estimado, pendiente_alta,",
        "        origen, confirmado, lote_distinto, lote_id",
        "      ) values (",
        "        v_id, v_pid, r.ean, r.nombre, r.qty, null, r.lote, r.costo,",
        "        (v_pid is null), 'pdf', false,",
        "        (v_pid is not null and exists (",
        "          select 1 from public.lotes l",
        "          where l.producto_id = v_pid and coalesce(l.activo, true)",
        "            and coalesce(l.cantidad_actual, 0) > 0",
        "            and l.numero_lote is distinct from r.lote",
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
        "  left(i.nombre_snapshot, 48) as nombre,",
        "  i.cantidad,",
        "  i.costo_estimado,",
        "  i.numero_lote,",
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
    rows_rep = [
        {
            "ean": r["ean"],
            "nombre": r["desc_ticket"],
            "qty": r["qty"],
            "pu": r["pu"],
            "sub": r["sub"],
            "sku": r["sku"],
            "match": "recibir" if r["match"] else "alta",
        }
        for r in ROWS
    ]
    suma = sum(r["sub"] for r in ROWS)
    print(f"csv  {OUT_TICKET}")
    print(f"sql  {OUT_SQL}")
    print(report(rows_rep, TOTAL_TICKET))
    print(
        f"productos ${suma:.2f} + IVA ${IVA_CFDI:.2f} = ${suma + IVA_CFDI:.2f} "
        f"(CFDI ${TOTAL_TICKET:.2f})"
    )
    print(f"altas {sum(1 for r in ROWS if not r['match'])}  recibir {sum(1 for r in ROWS if r['match'])}")
    print(f"piezas {sum(r['qty'] for r in ROWS)}")
