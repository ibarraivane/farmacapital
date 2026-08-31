#!/usr/bin/env python3
"""Factura Levic A 9012148211 (CFDI 31-ago-2026) → CSV Recibir + SQL.

El XML no trae lote ni caducidad: no se inventan. MMAA sale de la caja.
Costo = ValorUnitario neto del CFDI (IVA 16% de Sensodyne va en el total, no en el renglón).
"""
from __future__ import annotations

import math
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from generar_recepcion_borrador import report, sql_str, write_ticket_csv

ROOT = Path(__file__).resolve().parents[1]
OUT_TICKET = ROOT / "sql" / "generated" / "ticket_levic_9012148211.csv"
OUT_SQL = ROOT / "sql" / "patch_carga_levic_9012148211.sql"

FOLIO = "9012148211"
PROVEEDOR = "Levic"
FECHA = "2026-08-31"
TOTAL_TICKET = 627.85  # CFDI Total (incluye IVA $9.10 de Sensodyne)
SUBTOTAL_CFDI = 618.75
IVA_CFDI = 9.10
UUID = "1E6D645D-8DDC-4CF9-83FC-6250FBE6EE67"


def ceil_pvp(costo: float, factor: float = 1.6) -> float:
    return float(math.ceil(costo * factor))


# match=True → ya estaba en catálogo FarmaCapital (no alta).
# EAN de claves nuevas: portal/farmacias MX (presentación 1 pieza, no C/6).
ROWS = [
    {
        "clave": "AMS349",
        "ean": "7501349021808",
        "nombre": "Cefotaxima IM 500 mg/2 ml",
        "desc_ticket": "CEFOTAXIMA I.M. 1 FA 500MG/2 ML",
        "qty": 1,
        "pu": 27.99,
        "sub": 27.99,
        "sku": "EQ-AMS349",
        "match": False,
        "categoria": "Medicamentos",
        "tipo": "generico",
        "marca": "AMSA",
        "presentacion": "Frasco ámpula 500 mg + diluyente 2 mL",
        "principio": "Cefotaxima",
        "concentracion": "500 mg/2 ml",
        "receta": True,
        "stock_minimo": 1,
    },
    {
        "clave": "BIO002",
        "ean": "7501573900535",
        "nombre": "Biomesina 10 tab 10 mg",
        "desc_ticket": "BIOMESINA 10 TAB 10 MG",
        "qty": 3,
        "pu": 13.54,
        "sub": 40.62,
        "sku": "EQ-BIO002",
        "match": False,
        "categoria": "Medicamentos",
        "tipo": "marca",
        "marca": "Biomep",
        "presentacion": "Caja con 10 tabletas",
        "principio": "Butilhioscina",
        "concentracion": "10 mg",
        "receta": False,
        "stock_minimo": 2,
    },
    {
        "clave": "HLN078",
        "ean": "7896009498091",
        "nombre": "Sensodyne Complete Protection 90 g",
        "desc_ticket": "SENSODYNE COMPLETE PROTEC 1 TUBO 90 G",
        "qty": 1,
        "pu": 56.88,
        "sub": 56.88,
        "sku": "FC-09498091",
        "match": True,
        "categoria": "Cuidado personal",
        "tipo": "marca",
        "marca": "Sensodyne",
        "presentacion": "Tubo 90 g",
        "principio": None,
        "concentracion": None,
        "receta": False,
        "stock_minimo": 1,
    },
    {
        "clave": "LOE131",
        "ean": "7502211789284",
        "nombre": "Faribrox TM infantil 150/113 mg jarabe 150 mL",
        "desc_ticket": "FARIBROX TM INF 1 JBE 150/113MG/100/150",
        "qty": 2,
        "pu": 23.41,
        "sub": 46.82,
        "sku": "EQ-LOE131",
        "match": True,
        "categoria": "Medicamentos",
        "tipo": "marca",
        "marca": "Loeffler",
        "presentacion": "Frasco 150 mL",
        "principio": "Ambroxol / Dextrometorfano",
        "concentracion": "150/113 mg/100 mL",
        "receta": False,
        "stock_minimo": 2,
    },
    {
        "clave": "MAV102",
        "ean": "7502009740794",
        "nombre": "Lincover lincomicina 16 cáps 500 mg",
        "desc_ticket": "LINCOVER 16 CAPS 500 MG",
        "qty": 2,
        "pu": 58.74,
        "sub": 117.48,
        "sku": "EQ-MAV102",
        "match": False,
        "categoria": "Medicamentos",
        "tipo": "marca",
        "marca": "Maver",
        "presentacion": "Caja con 16 cápsulas",
        "principio": "Lincomicina",
        "concentracion": "500 mg",
        "receta": True,
        "stock_minimo": 2,
    },
    {
        "clave": "MAV162",
        "ean": "7502009741593",
        "nombre": "Dolxen 10 tab 500 mg",
        "desc_ticket": "DOLXEN 10 TAB 500 MG",
        "qty": 5,
        "pu": 19.88,
        "sub": 99.40,
        "sku": "EQ-MAV162",
        "match": True,
        "categoria": "Medicamentos",
        "tipo": "marca",
        "marca": "Maver",
        "presentacion": "Caja con 10 tabletas",
        "principio": "Naproxeno",
        "concentracion": "500 mg",
        "receta": False,
        "stock_minimo": 2,
    },
    {
        "clave": "SON039",
        "ean": "7502001163782",
        "nombre": "Dicleophen 12 cáps 500 mg",
        "desc_ticket": "DICLEOPHEN 12 CAPS 500 MG",
        "qty": 3,
        "pu": 29.76,
        "sub": 89.28,
        "sku": "EQ-SON039",
        "match": True,
        "categoria": "Medicamentos",
        "tipo": "marca",
        "marca": "SON'S",
        "presentacion": "Caja con 12 cápsulas",
        "principio": "Dicloxacilina",
        "concentracion": "500 mg",
        "receta": True,
        "stock_minimo": 2,
    },
    {
        "clave": "SON083",
        "ean": "7502001161627",
        "nombre": "Lisonin 1 amp 600 mg/2 ml",
        "desc_ticket": "LISONIN 1 AMP 600MG/2 ML",
        "qty": 1,
        "pu": 36.45,
        "sub": 36.45,
        "sku": "EQ-SON083",
        "match": False,
        "categoria": "Medicamentos",
        "tipo": "marca",
        "marca": "SON'S",
        "presentacion": "1 ampolleta 2 mL",
        "principio": "Lincomicina",
        "concentracion": "600 mg/2 ml",
        "receta": True,
        "stock_minimo": 1,
    },
    {
        "clave": "SON084",
        "ean": "7502001161597",
        "nombre": "Lisonin 1 amp 300 mg/1 ml",
        "desc_ticket": "LISONIN 1 AMP 300MG/1 ML",
        "qty": 2,
        "pu": 26.73,
        "sub": 53.46,
        "sku": "EQ-SON084",
        "match": False,
        "categoria": "Medicamentos",
        "tipo": "marca",
        "marca": "SON'S",
        "presentacion": "1 ampolleta 1 mL",
        "principio": "Lincomicina",
        "concentracion": "300 mg/1 ml",
        "receta": True,
        "stock_minimo": 2,
    },
    {
        "clave": "WER015",
        "ean": "7503003738879",
        "nombre": "Rosel-T 15 tab 300/50/3 mg",
        "desc_ticket": "ROSEL T 15 TAB 300/50/3 MG",
        "qty": 1,
        "pu": 22.25,
        "sub": 22.25,
        "sku": "FC-03738879",
        "match": True,
        "categoria": "Medicamentos",
        "tipo": "marca",
        "marca": "Wermar",
        "presentacion": "Caja con 15 tabletas",
        "principio": "Paracetamol / Amantadina / Clorfenamina",
        "concentracion": "300/50/3 mg",
        "receta": False,
        "stock_minimo": 1,
    },
    {
        "clave": "WER025",
        "ean": "7503003738404",
        "nombre": "Amantadina (Rosel) 24 cáps 50/3/300 mg",
        "desc_ticket": "AMANTADINA(ROSEL) 24 CAPS 50/3/300 MG",
        "qty": 1,
        "pu": 28.12,
        "sub": 28.12,
        "sku": "EQ-WER025",
        "match": True,
        "categoria": "Medicamentos",
        "tipo": "marca",
        "marca": "Wermar",
        "presentacion": "Caja con 24 cápsulas",
        "principio": "Amantadina / Clorfenamina / Paracetamol",
        "concentracion": "50/3/300 mg",
        "receta": False,
        "stock_minimo": 1,
    },
]


def csv_rows() -> list[dict]:
    out = []
    for r in ROWS:
        out.append({
            "ean": r["ean"],
            "nombre": r["desc_ticket"],
            "qty": r["qty"],
            "pu": r["pu"],
            "sub": r["sub"],
            "sku": r["sku"],
            "match": "recibir" if r["match"] else "alta",
        })
    return out


def write_sql() -> None:
    altas = [r for r in ROWS if not r["match"]]
    notas = (
        f"Factura Levic A {FOLIO} · CFDI {UUID} · cola Recibir; "
        "stock al confirmar pistola · sin lote en el XML"
    )
    lines = [
        f"-- Levic · factura interna A {FOLIO} · CFDI 31-ago-2026 02:53",
        f"-- Folio fiscal {UUID} · PUE efectivo ${TOTAL_TICKET:.2f}",
        f"-- Receptor LUIS ANGEL PALILLERO VENTURA · 11 renglones · 22 pzas.",
        f"-- Subtotal CFDI ${SUBTOTAL_CFDI:.2f} + IVA ${IVA_CFDI:.2f} (solo Sensodyne) = ${TOTAL_TICKET:.2f}.",
        "-- Costo = ValorUnitario neto. El XML no trae lote ni caducidad: no se inventan.",
        "-- MMAA sale de la caja al escanear. 0000 es inválido.",
        "--",
        f"-- {len(ROWS) - len(altas)} ya estaban · {len(altas)} altas "
        "(Cefotaxima 500 mg, Biomesina, Lincover, Lisonin 600, Lisonin 300).",
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
        nota = f"Factura Levic {FOLIO} · clave {r['clave']}"
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
            f"        ({sql_str(r['ean'])}, {sql_str(r['nombre'])}, {r['qty']}, {costo}, {sql_str(r['sku'])})"
        )
    lines.append(",\n".join(recv))
    lines += [
        "      ) as t(ean, nombre, qty, costo, sku)",
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
        "  left(i.nombre_snapshot, 48) as nombre,",
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
    rows = csv_rows()
    write_ticket_csv(OUT_TICKET, folio=FOLIO, fecha=FECHA, proveedor=PROVEEDOR, total=TOTAL_TICKET, rows=rows)
    write_sql()
    suma = sum(r["sub"] for r in ROWS)
    print(f"csv  {OUT_TICKET}")
    print(f"sql  {OUT_SQL}")
    print(report(rows, TOTAL_TICKET))
    print(
        f"productos ${suma:.2f} + IVA ${IVA_CFDI:.2f} = ${suma + IVA_CFDI:.2f} "
        f"(CFDI ${TOTAL_TICKET:.2f})"
    )
    print(f"altas {sum(1 for r in ROWS if not r['match'])}  recibir {sum(1 for r in ROWS if r['match'])}")
