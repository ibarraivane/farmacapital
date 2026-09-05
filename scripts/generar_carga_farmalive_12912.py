#!/usr/bin/env python3
"""Ticket Farmalive 12912 (2026-09-05) → CSV + SQL cola Recibir.

Fuente: ticket físico FARMA live Club Iztapalapa 1.
43 artículos impresos / 68 unidades. Total a pagar $3,180.61
(subtotal $3,245.52 − descuento 2% $64.91).
Costo = precio neto (después del 2%).
Bio Electro promo $0.01 x2 consolidado en 4 pzas a costo efectivo.
Sin lote ni MMAA.
"""
from __future__ import annotations

import csv
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from generar_recepcion_borrador import report, sql_str

ROOT = Path(__file__).resolve().parents[1]
OUT_CSV = ROOT / "sql" / "generated" / "ticket_farmalive_12912.csv"
OUT_SQL = ROOT / "sql" / "patch_recepcion_farmalive_12912_corroborar.sql"

FOLIO = "12912"
PROVEEDOR = "Farmalive"
FECHA = "2026-09-05"
TOTAL_TICKET = 3180.61

# descripcion ticket, qty, subtotal_neto, ean
# Bio Electro: líneas 2@$78.40 + promo 2@$0.01 → 4 pzas / $156.83 (absorbe $0.01 del redondeo del ticket)
RAW = [
    ("TOA SANIT SABA BUENAS NOCHES C/24 | SCA", 1, 60.17, "7501019006692"),
    ("TOA SANIT SABA BUENAS NOCHES EXTRA C/12 | ESSITY", 1, 44.39, "7501019036590"),
    ("TOA SANIT SABA ULT INVISIBLE C/A C/10 | ESSITY", 1, 23.91, "7501019006296"),
    ("TOA SANIT SABA AMORE S/ALAS C/8 | SCA", 1, 9.90, "7501019031144"),
    ("TOA SANIT SABA INTIMA REG S/ALAS C/10 | SCA", 1, 13.52, "7501019006104"),
    ("TOA SANIT SABA INV BUENOS DIAS C/A C/14 | ESSITY", 1, 33.03, "7501019006418"),
    ("TORUNDA DE ALGODON QUIRMEX 75 GR | QUIRMEX", 2, 35.08, "7503003406785"),
    ("MASC CABELLO FRUCTIS BANANA 350 ML | FRABEL", 1, 56.94, "7509552828078"),
    ("PADS FACIAL PROTEC REDONDOS C/100 | DEGASA", 2, 42.53, "7501048623006"),
    ("ALMOHADILLAS RETANGULARES QUIRMEX C/100 | QUIRMEX", 1, 32.83, "7506552900247"),
    ("TINTE KOLESTON # 20 NEGRO | HFC PRESTI", 2, 107.80, "3614225108709"),
    ("TINTE KOLESTON # 40 CASTANO MEDIO | HFC PRESTI", 2, 107.80, "3614225108747"),
    ("TINTE KOLESTON # 466 BORGONA INTENSO | HFC PRESTI", 2, 107.80, "3614225108761"),
    ("TINTE KOLESTON # 70 RUBIO MEDIANO | HFC PRESTI", 2, 107.80, "3614225108877"),
    ("CRE VITACILINA FACIAL HUMECTANTE 100 GR | KSK", 2, 154.06, "7506376000277"),
    ("CRE VITACILINA FACIAL ANTIARRUGAS 100 GR | KSK", 2, 154.06, "7506376000253"),
    ("VITACILINA 16 GR 2X1 | KSK", 5, 121.52, "7502250343065"),
    ("VITACILINA 28 GR 2X1 | KSK", 4, 145.04, "7502250343072"),
    ("RIOPAN SOBRES C/20 | TAKEDA", 1, 268.72, "7501092793045"),
    ("ALLIVIAX GARGANTA TAB C/6 | GENOMMA LAB", 2, 29.40, "650240070839"),
    ("JABON NORDIKO ORIGINAL 130 GR NVO | GENOMMA LAB", 1, 10.78, "650240071775"),
    ("JABON NORDIKO ICY BLAST 130 GR | GENOMMA LAB", 1, 15.58, "650240071799"),
    ("XL-3 TAB C/10 | GENOMMA LAB", 1, 30.38, "650240052545"),
    ("CRE VITACILINA FACIAL ACLARADO 100 GR | KSK", 2, 154.06, "7506376000260"),
    ("VITACILINA SERUM FAC VITAMINA C 30ML | KSK", 1, 117.89, "7502250342570"),
    ("VITACILINA SERUM FAC COLAGENO 30ML | KSK", 1, 117.89, "7502250342563"),
    ("CRE VITACILINA FACIAL MELATONINA 100 GR | KSK", 1, 110.25, "7502250343102"),
    ("ALLIVIAX 550 MG TAB C/10 | GENOMMA LAB", 3, 177.87, "650240013805"),
    ("POMADA DE LA CAMPANA 19 GR | GENOMMA LAB", 2, 31.95, "7501065628121"),
    ("POMADA DE LA CAMPANA 35 GR | GENOMMA LAB", 2, 47.82, "7501065628145"),
    ("DRAMAMINE TAB C/24 | JOHNSON JOHNSON", 1, 154.84, "7501007532363"),
    ("RAST GILLETTE MACH3 C/1 | PG PERF", 1, 117.60, "7702018001071"),
    ("CRE HINDS ALMENDRAS 90 ML | GRISI HNOS", 1, 17.64, "037836041389"),
    ("CRE HINDS INSPIR RESECA 90 ML | GRISI HNOS", 1, 17.64, "037836041297"),
    ("CRE HINDS NAT RESECA 90 ML | GRISI HNOS", 1, 17.64, "037836041341"),
    ("RAST GILLETTE PRESTOBARBA3 MUJER 2PACK | PG PERF", 1, 41.94, "7702018874781"),
    ("RAST GILLETTE PRESTOBARBA3 HOMBRE 2PACK | PG PERF", 1, 65.17, "7702018874729"),
    ("ELECTROLIT FRESA-KIWI 625 ML | LAB PISA", 1, 20.09, "7501125149221"),
    ("ELECTROLIT MORA AZUL 625 ML | LAB PISA", 2, 40.18, "7501125174797"),
    ("ELECTROLIT UVA 625 ML | LAB PISA", 2, 40.18, "7501125144851"),
    ("ELECTROLIT FRESA 625 ML | LAB PISA", 1, 20.09, "7501125104268"),
    # 2@$78.40 + promo 2@$0.01 + $0.01 redondeo ticket → 4 pzas / $156.83
    ("BIO ELECTRO TAB C/24 | GENOMMA LAB", 4, 156.83, "650240007651"),
]


def rows() -> list[dict]:
    out = []
    for nombre, qty, sub, ean in RAW:
        out.append(
            {
                "nombre": nombre,
                "qty": qty,
                "sub": sub,
                "pu": round(sub / qty, 3),
                "ean": ean,
                "sku": "",
                "match": "ticket",
            }
        )
    return out


def write_csv(path: Path, data: list[dict]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", newline="", encoding="utf-8") as fh:
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
                    f"{TOTAL_TICKET:.2f}",
                    r["match"],
                ]
            )


def write_sql(path: Path, data: list[dict]) -> None:
    notas = (
        f"Pedido Farmalive {FOLIO} · Club Iztapalapa 1 · "
        "EAN del ticket · precio neto (−2%) · Bio Electro promo consolidada · "
        "cola Recibir; stock al confirmar pistola"
    )
    lines = [
        f"-- Pedido Farmalive {FOLIO} ({FECHA}) — cola Recibir, borrador.",
        "-- No suma stock: las piezas entran al escanear con pistola y poner MMAA de la caja.",
        "-- El pedido no trae lote ni caducidad; se quedan en null. No inventar 0000.",
        "-- Precio neto (Descto 2%). Bio Electro promo $0.01 consolidada en 4 pzas.",
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
        f"  where folio = {sql_str(FOLIO)} and coalesce(proveedor, '') ilike '%farmalive%'",
        "  order by id desc",
        "  limit 1;",
        "",
        "  if v_id is not null and (select estado from public.recepciones where id = v_id) <> 'borrador' then",
        f"    raise notice 'Recepcion Farmalive {FOLIO} ya cerrada (id %)', v_id;",
        "  else",
        "    if v_id is null then",
        "      insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)",
        f"      values ({sql_str(PROVEEDOR)}, {sql_str(FOLIO)}, {sql_str(FECHA)}, {TOTAL_TICKET:.2f}, 'borrador',",
        f"              {sql_str(notas)})",
        "      returning id into v_id;",
        "    else",
        "      delete from public.recepcion_items where recepcion_id = v_id;",
        "      update public.recepciones",
        f"      set total_ticket = {TOTAL_TICKET:.2f}, fecha = {sql_str(FECHA)}, proveedor = {sql_str(PROVEEDOR)}, updated_at = now()",
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
        f"    raise notice 'Recepcion Farmalive {FOLIO} lista id=% — escanear caja por caja', v_id;",
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
        f"where r.folio = {sql_str(FOLIO)} and coalesce(r.proveedor, '') ilike '%farmalive%'",
        "order by i.id;",
        "",
    ]
    path.write_text("\n".join(lines), encoding="utf-8")


def main() -> None:
    data = rows()
    write_csv(OUT_CSV, data)
    write_sql(OUT_SQL, data)
    suma = sum(r["sub"] for r in data)
    piezas = sum(r["qty"] for r in data)
    print(report(data, TOTAL_TICKET))
    print(f"piezas={piezas} esperado=68 ok={piezas == 68}")
    print(f"suma=${suma:.2f} total=${TOTAL_TICKET:.2f} delta={suma - TOTAL_TICKET:.2f}")
    print(f"lineas={len(data)}")
    print(f"csv={OUT_CSV}")
    print(f"sql={OUT_SQL}")
    if piezas != 68 or abs(suma - TOTAL_TICKET) >= 0.02:
        raise SystemExit("totales no cuadran")


if __name__ == "__main__":
    main()
