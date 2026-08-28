#!/usr/bin/env python3
"""Genera CSV + SQL de la factura Levic A 9012078353 (20-ago-2026)."""
from __future__ import annotations

import csv
import math
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
OUT_TICKET = ROOT / "sql" / "generated" / "ticket_levic_9012078353.csv"
OUT_IMPORT = ROOT / "sql" / "generated" / "import_inventario_levic_9012078353.csv"
OUT_SQL = ROOT / "sql" / "patch_carga_levic_9012078353.sql"

FOLIO = "9012078353"
PROVEEDOR = "Levic"
FECHA = "2026-08-20"
TEMP = "_fc_lv9012078353"
TOTAL_CFDI = 637.25


def ceil_pvp(costo: float, factor: float = 1.6) -> float:
    return float(math.ceil(costo * factor))


def sql_str(v: str | None) -> str:
    if v is None:
        return "null"
    return "'" + str(v).replace("'", "''") + "'"


def sql_bool(v: bool) -> str:
    return "true" if v else "false"


# Costo = Precio neto del CFDI (no el PMP). Lote de fábrica sí viene en la factura.
# Caducidad del papel se anota en el CSV; la carga SQL NO la escribe (MMAA sale de la caja).
ROWS = [
    {
        "linea": 1,
        "clave": "BEA267",
        "ean": "7501342802749",
        "desc_ticket": "SILDENAFIL 1 TAB 50 MG",
        "qty": 4,
        "pmp": 80.00,
        "pu": 4.90,
        "subtotal": 19.60,
        "lote": "ECM297C",
        "caducidad": "2028-03-30",
        "match": False,
        "sku": "EQ-BEA267",
        "nombre": "Sildenafil beadvance 50 mg 1 tableta",
        "categoria": "Medicamentos",
        "tipo": "generico",
        "precio": ceil_pvp(4.90),
        "stock_minimo": 4,
        "marca": "beadvance",
        "presentacion": "1 tableta",
        "principio": "Sildenafil",
        "concentracion": "50 mg",
        "receta": True,
        "notas": "Factura Levic 9012078353 · ≠ Sildenafil C/4 100 mg EQ-ULT145 · ≠ Figral C/10",
    },
    {
        "linea": 2,
        "clave": "BIO212",
        "ean": "7501573909958",
        "desc_ticket": "COLCHICINA 30 TAB 1 MG",
        "qty": 2,
        "pmp": 180.00,
        "pu": 31.24,
        "subtotal": 62.48,
        "lote": "SD2602",
        "caducidad": "2028-04-30",
        "match": True,
        "sku": "EQ-BIO212",
        "nombre": "Colchicina 30 Tab 1 Mg",
        "categoria": "Medicamentos",
        "tipo": "generico",
        "precio": ceil_pvp(31.24),
        "stock_minimo": 2,
        "marca": "Biomep",
        "presentacion": "Caja con 30 tabletas",
        "principio": "Colchicina",
        "concentracion": "1 mg",
        "receta": True,
        "notas": "Factura Levic 9012078353 · ya existía EQ-BIO212",
    },
    {
        "linea": 3,
        "clave": "DES016",
        "ean": "7501048335138",
        "desc_ticket": "AGUA OXIGEN DERMOCLEEN 1 BOT 100 ML",
        "qty": 2,
        "pmp": 38.82,
        "pu": 8.08,
        "subtotal": 16.16,
        "lote": "3A206030",
        "caducidad": "2031-05-30",
        "match": True,
        "sku": "FC-83351381",
        "nombre": "Agua oxigenada Dermocleen 100 mL",
        "categoria": "Botiquín",
        "tipo": "marca",
        "precio": ceil_pvp(8.08),
        "stock_minimo": 2,
        "marca": "Dermocleen",
        "presentacion": "Frasco 100 mL",
        "principio": "Peróxido de hidrógeno",
        "concentracion": "2.5 a 3.5%",
        "receta": False,
        "notas": "Factura Levic 9012078353 · ya existía FC-83351381 (a veces listado como Protec)",
    },
    {
        "linea": 4,
        "clave": "DES017",
        "ean": "7501048335169",
        "desc_ticket": "AGUA OXIGEN DERMOCLEEN 1 BOT 230 ML",
        "qty": 2,
        "pmp": 55.56,
        "pu": 11.57,
        "subtotal": 23.14,
        "lote": "3A196054",
        "caducidad": "2031-05-30",
        "match": True,
        "sku": "FC-83351691",
        "nombre": "Agua oxigenada Dermocleen 230 mL",
        "categoria": "Botiquín",
        "tipo": "marca",
        "precio": ceil_pvp(11.57),
        "stock_minimo": 2,
        "marca": "Dermocleen",
        "presentacion": "Frasco 230 mL",
        "principio": "Peróxido de hidrógeno",
        "concentracion": "2.5 a 3.5%",
        "receta": False,
        "notas": "Factura Levic 9012078353 · ya existía FC-83351691 · ≠ 100 mL",
    },
    {
        "linea": 5,
        "clave": "MAV236",
        "ean": "7502009745478",
        "desc_ticket": "IDELIVER PRO 14 TAB 60 MG",
        "qty": 4,
        "pmp": 308.00,
        "pu": 63.74,
        "subtotal": 254.96,
        "lote": "283429",
        "caducidad": "2028-05-30",
        "match": True,
        "sku": "EQ-MAV236",
        "nombre": "Ideliver Pro duloxetina 60 mg C/14",
        "categoria": "Medicamentos",
        "tipo": "marca",
        "precio": ceil_pvp(63.74),
        "stock_minimo": 2,
        "marca": "Maver",
        "presentacion": "Caja con 14 tabletas",
        "principio": "Duloxetina",
        "concentracion": "60 mg",
        "receta": True,
        "notas": "Factura Levic 9012078353 · ya existía EQ-MAV236 · costo subió; PVP 96→102",
    },
    {
        "linea": 6,
        "clave": "QUI139",
        "ean": "7501109769063",
        "desc_ticket": "AGECAPS MINOXIDIL HOMBRE 5% SOL 60 ML",
        "qty": 1,
        "pmp": 600.00,
        "pu": 150.00,
        "subtotal": 150.00,
        "lote": "26C063",
        "caducidad": "2028-02-29",
        "match": False,
        "sku": "EQ-QUI139",
        "nombre": "Agecaps minoxidil hombre 5% solución 60 mL",
        "categoria": "Cuidado personal",
        "tipo": "marca",
        "precio": ceil_pvp(150.00),
        "stock_minimo": 1,
        "marca": "Agecaps",
        "presentacion": "Frasco 60 mL",
        "principio": "Minoxidil",
        "concentracion": "5%",
        "receta": False,
        "notas": "Factura Levic 9012078353 · Química y Farmacia · PMP $600",
    },
    {
        "linea": 7,
        "clave": "ULT201",
        "ean": "7502216800984",
        "desc_ticket": "ACEMETACINA 14 CAPS 90 MG",
        "qty": 2,
        "pmp": 502.30,
        "pu": 52.31,
        "subtotal": 104.62,
        "lote": "68N323A",
        "caducidad": "2029-02-28",
        "match": True,
        "sku": "FC-C9F4ACCC",
        "nombre": "Acemetacina 14 cáps 90 mg",
        "categoria": "Analgésico",
        "tipo": "generico",
        "precio": ceil_pvp(52.31),
        "stock_minimo": 2,
        "marca": "Ultra",
        "presentacion": "Caja con 14 cápsulas",
        "principio": "Acemetacina",
        "concentracion": "90 mg",
        "receta": True,
        "notas": "Factura Levic 9012078353 · ya existía FC-C9F4ACCC · pegar EAN si faltaba",
    },
]


def write_ticket_csv() -> None:
    OUT_TICKET.parent.mkdir(parents=True, exist_ok=True)
    fields = [
        "linea", "folio", "fecha", "proveedor", "ean", "descripcion_ticket",
        "cantidad", "precio_unitario", "subtotal", "lote", "caducidad",
        "sku_farmacapital", "accion",
    ]
    with OUT_TICKET.open("w", encoding="utf-8", newline="") as f:
        w = csv.DictWriter(f, fieldnames=fields)
        w.writeheader()
        for r in ROWS:
            w.writerow({
                "linea": r["linea"],
                "folio": FOLIO,
                "fecha": FECHA,
                "proveedor": PROVEEDOR,
                "ean": r["ean"],
                "descripcion_ticket": r["desc_ticket"],
                "cantidad": r["qty"],
                "precio_unitario": f"{r['pu']:.2f}",
                "subtotal": f"{r['subtotal']:.2f}",
                "lote": r["lote"],
                "caducidad": r["caducidad"],
                "sku_farmacapital": r["sku"],
                "accion": "recibir" if r["match"] else "alta",
            })


def write_import_csv() -> None:
    fields = [
        "SKU", "Codigo_Barras", "Nombre", "Categoria", "Tipo", "Stock", "Stock_Minimo",
        "Precio_Venta", "Costo", "Proveedor", "Lote", "Fecha_Caducidad",
        "Descuento_Porcentaje",
        "Marca_Comercial", "Principio_Activo", "Concentracion", "Presentacion",
        "Contenido_Caja", "Linea_Comercial", "Grupo_Farmacologico", "Jerarquia",
        "SKU_Casa_Saba", "Stock_Maximo", "Notas",
    ]
    with OUT_IMPORT.open("w", encoding="utf-8-sig", newline="") as f:
        w = csv.DictWriter(f, fieldnames=fields, quoting=csv.QUOTE_ALL)
        w.writeheader()
        for r in ROWS:
            w.writerow({
                "SKU": r["sku"],
                "Codigo_Barras": r["ean"],
                "Nombre": r["nombre"],
                "Categoria": r["categoria"],
                "Tipo": r["tipo"],
                "Stock": r["qty"],
                "Stock_Minimo": r["stock_minimo"],
                "Precio_Venta": f"{r['precio']:.2f}",
                "Costo": f"{r['pu']:.2f}",
                "Proveedor": PROVEEDOR,
                "Lote": r["lote"],
                "Fecha_Caducidad": "",
                "Descuento_Porcentaje": "0",
                "Marca_Comercial": r["marca"],
                "Principio_Activo": r["principio"],
                "Concentracion": r["concentracion"],
                "Presentacion": r["presentacion"],
                "Contenido_Caja": "",
                "Linea_Comercial": "",
                "Grupo_Farmacologico": "",
                "Jerarquia": "",
                "SKU_Casa_Saba": r["clave"],
                "Stock_Maximo": "",
                "Notas": r["notas"],
            })


def write_sql() -> None:
    lines = [
        "-- Levic · factura interna A 9012078353 · CFDI 20-ago-2026 00:44",
        "-- Folio fiscal 9E99EEE5-8369-4D61-8E09-17F0ECBB6670 · PUE efectivo $637.25",
        "-- Receptor LUIS ANGEL PALILLERO VENTURA · 7 renglones (hoja 1; totales cuadran).",
        "-- Costo = Precio neto del CFDI (no el PMP). Lote = de fábrica (sí viene en la factura).",
        "-- Caducidad del papel NO se escribe aquí: Recibir captura MMAA de la caja.",
        "--",
        "-- 5 ya estaban · 2 altas (sildenafil 1 tab, Agecaps minoxidil).",
        "-- ADDITIVO e idempotente (si el numero_lote ya existe, no vuelve a recibir).",
        "--",
        "-- Elige UNA vía: este SQL **o** Importar CSV. No las dos.",
        "-- Ejecutar en Supabase SQL Editor (archivo completo).",
        "-- proveedor no existe en productos: se guarda en lotes.proveedor_id.",
        "",
        "begin;",
        "",
        f"create temp table {TEMP} (",
        "  linea integer,",
        "  ean text primary key,",
        "  sku text not null,",
        "  nombre text not null,",
        "  categoria text not null,",
        "  tipo text not null,",
        "  qty integer not null,",
        "  costo numeric(12,2) not null,",
        "  precio numeric(12,2) not null,",
        "  stock_minimo integer not null,",
        "  lote text not null,",
        "  marca text,",
        "  presentacion text,",
        "  principio_activo text,",
        "  concentracion text,",
        "  requiere_receta boolean not null default false,",
        "  notas text,",
        "  es_alta boolean not null",
        ") on commit drop;",
        "",
        f"insert into {TEMP} values",
    ]
    vals = []
    for r in ROWS:
        vals.append(
            "  ({linea}, {ean}, {sku}, {nombre}, {cat}, {tipo}, {qty}, {costo}, {precio}, {smin}, {lote}, {marca}, {pres}, {pa}, {conc}, {receta}, {notas}, {alta})".format(
                linea=r["linea"],
                ean=sql_str(r["ean"]),
                sku=sql_str(r["sku"]),
                nombre=sql_str(r["nombre"]),
                cat=sql_str(r["categoria"]),
                tipo=sql_str(r["tipo"]),
                qty=r["qty"],
                costo=f"{r['pu']:.2f}",
                precio=f"{r['precio']:.2f}",
                smin=r["stock_minimo"],
                lote=sql_str(r["lote"]),
                marca=sql_str(r["marca"]),
                pres=sql_str(r["presentacion"]),
                pa=sql_str(r["principio"] or None),
                conc=sql_str(r["concentracion"] or None),
                receta=sql_bool(r["receta"]),
                notas=sql_str(r["notas"]),
                alta="true" if not r["match"] else "false",
            )
        )
    lines.append(",\n".join(vals) + ";")
    lines += [
        "",
        "do $$",
        "declare",
        "  r record;",
        "  v_pid bigint;",
        "  v_lid bigint;",
        "  n_alta integer := 0;",
        "  n_recv integer := 0;",
        "  n_skip integer := 0;",
        "begin",
        f"  for r in select * from {TEMP} order by linea loop",
        "    select p.id into v_pid",
        "    from public.productos p",
        "    where p.codigo_barras = r.ean or p.sku = r.sku",
        "    order by case when p.codigo_barras = r.ean then 0 else 1 end, p.id",
        "    limit 1;",
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
        "          'requiere_receta', r.requiere_receta",
        "        ),",
        "        0,",
        "        null,",
        "        null::date,",
        "        r.costo,",
        "        null::bigint",
        "      ) f;",
        "      n_alta := n_alta + 1;",
        "    else",
        "      update public.productos set",
        "        costo = r.costo,",
        "        precio = r.precio,",
        "        stock_minimo = greatest(coalesce(stock_minimo, 0), r.stock_minimo),",
        "        codigo_barras = coalesce(nullif(codigo_barras, ''), r.ean)",
        "      where id = v_pid;",
        "    end if;",
        "",
        "    update public.productos set",
        "      marca = r.marca,",
        "      presentacion = r.presentacion,",
        "      principio_activo = coalesce(r.principio_activo, principio_activo),",
        "      concentracion = coalesce(r.concentracion, concentracion),",
        "      categoria = r.categoria",
        "    where id = v_pid;",
        "  end loop;",
        "",
        "  raise notice 'Levic 9012078353: % altas de catálogo (stock = Recibir)', n_alta;",
        "end $$;",
        "",
        "select",
        "  t.linea,",
        "  t.sku,",
        "  t.ean,",
        "  left(t.nombre, 42) as nombre,",
        "  t.qty as pzas_ticket,",
        "  p.stock as stock_bd,",
        "  t.costo as costo_ticket,",
        "  p.costo as costo_bd,",
        "  t.precio as pvp,",
        "  p.precio as pvp_bd,",
        "  l.numero_lote,",
        "  l.cantidad_actual as lote_qty,",
        "  case",
        "    when p.id is null then 'SIN PRODUCTO'",
        "    when l.id is null then 'SIN LOTE'",
        "    else 'OK'",
        "  end as estado",
        f"from {TEMP} t",
        "left join public.productos p on p.codigo_barras = t.ean or p.sku = t.sku",
        "left join lateral (",
        "  select l.* from public.lotes l",
        "  where l.producto_id = p.id and l.numero_lote = t.lote and coalesce(l.activo, true)",
        "  order by l.id desc",
        "  limit 1",
        ") l on true",
        "order by t.linea;",
        "",
        "commit;",
        "",
    ]
    OUT_SQL.write_text("\n".join(lines), encoding="utf-8")


if __name__ == "__main__":
    write_ticket_csv()
    write_import_csv()
    write_sql()
    total = sum(r["subtotal"] for r in ROWS)
    print(f"ticket  {OUT_TICKET}")
    print(f"import  {OUT_IMPORT}")
    print(f"sql     {OUT_SQL}")
    print(f"lineas {len(ROWS)}  suma renglones ${total:.2f}  CFDI ${TOTAL_CFDI:.2f}")
    print(f"altas {sum(1 for r in ROWS if not r['match'])}  recibir {sum(1 for r in ROWS if r['match'])}")
