#!/usr/bin/env python3
"""Genera CSV + SQL del ticket Farmalive 11590 (Club Iztapalapa 1, 21-ago-2026)."""
from __future__ import annotations

import csv
import math
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
OUT_TICKET = ROOT / "sql" / "generated" / "ticket_farmalive_11590.csv"
OUT_IMPORT = ROOT / "sql" / "generated" / "import_inventario_farmalive_11590.csv"
OUT_SQL = ROOT / "sql" / "patch_carga_farmalive_11590.sql"

FOLIO = "11590"
PROVEEDOR = "Farmalive"
FECHA = "2026-08-21"
TEMP = "_fc_fl11590"
# Lote de RECEPCIÓN (no de fábrica). Misma idea que Recibir: RX- + tienda + fecha + folio.
# El ticket Farmalive no imprime lote de laboratorio.
LOTE_RX = "RX-FARMALIVE-20260821-11590"


def ceil_pvp(costo: float, factor: float = 1.6) -> float:
    return float(math.ceil(costo * factor))


def sql_str(v: str | None) -> str:
    if v is None:
        return "null"
    return "'" + str(v).replace("'", "''") + "'"


def sql_bool(v: bool) -> str:
    return "true" if v else "false"


# Costo = precio NETO (lista × (1 − desc)). El ticket no imprime lote ni caducidad.
ROWS = [
    {
        "linea": 1,
        "ean": "7501065054029",
        "desc_ticket": "TUMS SURTIDO TAB MAST C/48",
        "qty": 2,
        "lista": 87.00,
        "desc_pct": 2.0,
        "pu": 85.26,
        "subtotal": 170.52,
        "lote": LOTE_RX,
        "match": False,
        "sku": "FC-65054029",
        "nombre": "Tums surtido tabletas masticables C/48",
        "categoria": "Gastro",
        "tipo": "marca",
        "precio": ceil_pvp(85.26),
        "stock_minimo": 2,
        "marca": "Tums",
        "presentacion": "Caja con 48 tabletas masticables",
        "principio": "Carbonato de calcio",
        "concentracion": "",
        "receta": False,
        "notas": "Ticket Farmalive 11590 · ≠ Tums 8 tab FC-65054135 EAN 7501065054043",
    },
    {
        "linea": 2,
        "ean": "7501019064807",
        "desc_ticket": "PANTS TENA COMFORT GDE C/13",
        "qty": 1,
        "lista": 119.60,
        "desc_pct": 5.0,
        "pu": 113.62,
        "subtotal": 113.62,
        "lote": LOTE_RX,
        "match": False,
        "sku": "FC-19064807",
        "nombre": "Tena Pants Comfort grande C/13",
        "categoria": "Higiene",
        "tipo": "marca",
        "precio": ceil_pvp(113.62),
        "stock_minimo": 1,
        "marca": "Tena",
        "presentacion": "Bolsa con 13 pants talla grande",
        "principio": "",
        "concentracion": "",
        "receta": False,
        "notas": "Ticket Farmalive 11590 · Essity",
    },
    {
        "linea": 3,
        "ean": "7500435179980",
        "desc_ticket": "ENJ BUCAL ORAL B 100% 250 ML",
        "qty": 2,
        "lista": 50.30,
        "desc_pct": 5.0,
        "pu": 47.79,
        "subtotal": 95.57,
        "lote": LOTE_RX,
        "match": False,
        "sku": "FC-43517980",
        "nombre": "Oral-B enjuague bucal 100% 250 mL",
        "categoria": "Cuidado personal",
        "tipo": "marca",
        "precio": ceil_pvp(47.79),
        "stock_minimo": 2,
        "marca": "Oral-B",
        "presentacion": "Botella 250 mL",
        "principio": "",
        "concentracion": "",
        "receta": False,
        "notas": "Ticket Farmalive 11590",
    },
    {
        "linea": 4,
        "ean": "7891051037878",
        "desc_ticket": "ENJ BUCAL ORAL B COMPLET 250 ML",
        "qty": 2,
        "lista": 50.00,
        "desc_pct": 5.0,
        "pu": 47.50,
        "subtotal": 95.00,
        "lote": LOTE_RX,
        "match": False,
        "sku": "FC-51037878",
        "nombre": "Oral-B enjuague bucal Complete 250 mL",
        "categoria": "Cuidado personal",
        "tipo": "marca",
        "precio": ceil_pvp(47.50),
        "stock_minimo": 2,
        "marca": "Oral-B",
        "presentacion": "Botella 250 mL",
        "principio": "",
        "concentracion": "",
        "receta": False,
        "notas": "Ticket Farmalive 11590 · distinto del Oral-B 100%",
    },
    {
        "linea": 5,
        "ean": "5000174305449",
        "desc_ticket": "CREMA DENT FIXODENT ORIGINAL 40 ML",
        "qty": 2,
        "lista": 95.20,
        "desc_pct": 2.0,
        "pu": 93.30,
        "subtotal": 186.59,
        "lote": LOTE_RX,
        "match": False,
        "sku": "FC-74305449",
        "nombre": "Fixodent Original crema dental 40 mL",
        "categoria": "Cuidado personal",
        "tipo": "marca",
        "precio": ceil_pvp(93.30),
        "stock_minimo": 2,
        "marca": "Fixodent",
        "presentacion": "Tubo 40 mL",
        "principio": "",
        "concentracion": "",
        "receta": False,
        "notas": "Ticket Farmalive 11590 · adhesivo para dentadura",
    },
    {
        "linea": 6,
        "ean": "020800600330",
        "desc_ticket": "TAMPONES TAMPAX SUPER C/10",
        "qty": 1,
        "lista": 44.00,
        "desc_pct": 2.0,
        "pu": 43.12,
        "subtotal": 43.12,
        "lote": LOTE_RX,
        "match": False,
        "sku": "FC-08006033",
        "nombre": "Tampax Super C/10",
        "categoria": "Higiene",
        "tipo": "marca",
        "precio": ceil_pvp(43.12),
        "stock_minimo": 1,
        "marca": "Tampax",
        "presentacion": "Caja con 10 tampones super",
        "principio": "",
        "concentracion": "",
        "receta": False,
        "notas": "Ticket Farmalive 11590 · UPC 12 dígitos 020800600330",
    },
]


def write_ticket_csv() -> None:
    OUT_TICKET.parent.mkdir(parents=True, exist_ok=True)
    fields = [
        "linea", "folio", "fecha", "proveedor", "ean", "descripcion_ticket",
        "cantidad", "precio_lista", "descuento_pct", "precio_neto", "subtotal",
        "lote", "caducidad", "sku_farmacapital", "accion",
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
                "precio_lista": f"{r['lista']:.2f}",
                "descuento_pct": f"{r['desc_pct']:.1f}",
                "precio_neto": f"{r['pu']:.2f}",
                "subtotal": f"{r['subtotal']:.2f}",
                "lote": r["lote"],
                "caducidad": "",
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
                "SKU_Casa_Saba": "",
                "Stock_Maximo": "",
                "Notas": r["notas"],
            })


def write_sql() -> None:
    lines = [
        "-- Farmalive Club Iztapalapa 1 · ticket 11590 · 21-ago-2026 09:46",
        "-- Central de Abastos · tarjeta crédito $704.42",
        "-- 6 renglones · costo = precio NETO (después del descuento del ticket).",
        "-- El ticket no trae lote de fábrica. Lote de recepción (como Recibir):",
        "--   RX-FARMALIVE-20260821-11590  = tienda + fecha + folio.",
        "-- No es el lote impreso en la caja. Al abrirla, cámbialo en Lotes y pon caducidad.",
        "--",
        "-- 6 altas. El Tums C/48 NO es el Tums de 8 tab (FC-65054135 / 7501065054043).",
        "-- ADDITIVO e idempotente (si ya existe ese RX- en el producto, no vuelve a recibir).",
        "--",
        "-- Corre este archivo .sql en Supabase. NO pegues el CSV.",
        "-- Elige UNA vía: este SQL o Importar CSV. No las dos.",
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
        "        stock_minimo = r.stock_minimo",
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
        "  raise notice 'Farmalive 11590: % altas, % recepciones, % lotes ya existian', n_alta, n_recv, n_skip;",
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
    print(f"lineas {len(ROWS)}  total ${total:.2f}  altas {sum(1 for r in ROWS if not r['match'])}")
