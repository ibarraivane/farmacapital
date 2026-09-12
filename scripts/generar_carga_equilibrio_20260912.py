#!/usr/bin/env python3
"""Equilibrio · ticket térmico foto 12-sep-2026.

Fuente: ticket físico Equilibrio Iztapalapa (EQF_CAJA3_IZTA2).
Folio no venía en el recorte: usamos 20260912.
Total $950.72 · IVA $0 · 7 renglones / 21 pzas.
Costo = P.U. del ticket. Lote de fábrica sí. Caducidad NO (MMAA de la caja).
EANs desde Sufarmed / DISA / FarmaSmart / Sanorim (no inventados).
"""
from __future__ import annotations

import math
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from generar_recepcion_borrador import report, sql_str

ROOT = Path(__file__).resolve().parents[1]
FOLIO = "20260912"
PROVEEDOR = "Equilibrio"
FECHA = "2026-09-12"
TOTAL = 950.72
FOTO = "https://www.farmacapital.mx/catalogo-propia/{}"

# nombre = mostrador; snap = texto del ticket
ROWS = [
    {
        "ean": "7502227871058",
        "sku": "EQ-RAM014",
        "nombre": "Fermig Sumatriptán 100 mg C/2 RAAM",
        "snap": "RAM014 FERMIG 2 TAB 100 MG",
        "qty": 2,
        "pu": 62.07,
        "sub": 124.14,
        "lote": "RFR356",
        "tipo": "generico",
        "categoria": "Medicamentos",
        "receta": True,
        "marca": "RAAM",
        "presentacion": "Caja con 2 tabletas",
        "principio": "Sumatriptán",
        "concentracion": "100 mg",
        "forma": "Tableta",
        "subcat": "Neurología",
        "imagen": None,  # ya en catálogo
    },
    {
        "ean": "7502227871065",
        "sku": "EQ-RAM015",
        "nombre": "Fermig Sumatriptán 50 mg C/2 RAAM",
        "snap": "RAM015 FERMIG 2 TAB 50 MG",
        "qty": 2,
        "pu": 49.30,
        "sub": 98.60,
        "lote": "RFR354",
        "tipo": "generico",
        "categoria": "Medicamentos",
        "receta": True,
        "marca": "RAAM",
        "presentacion": "Caja con 2 tabletas",
        "principio": "Sumatriptán",
        "concentracion": "50 mg",
        "forma": "Tableta",
        "subcat": "Neurología",
        "imagen": FOTO.format("fermig-sumatriptan-50-2-raam.png"),
    },
    {
        "ean": "7501075714173",
        "sku": "EQ-NOV038",
        "nombre": "Prontol Metoprolol 100 mg C/20 Novag",
        "snap": "NOV038 PRONTOL 20 TAB 100 MG",
        "qty": 4,
        "pu": 9.98,
        "sub": 39.92,
        "lote": "670106",
        "tipo": "generico",
        "categoria": "Hipertensión",
        "receta": True,
        "marca": "Novag",
        "presentacion": "Caja con 20 tabletas",
        "principio": "Metoprolol",
        "concentracion": "100 mg",
        "forma": "Tableta",
        "subcat": "Cardiovascular",
        "imagen": FOTO.format("prontol-metoprolol-100-20-novag.webp"),
    },
    {
        "ean": "7502009749322",
        "sku": "EQ-MAV394",
        "nombre": "Coniax Citicolina 500 mg C/10 Maver",
        "snap": "MAV394 CONIAX 10 COMP 500 MG",
        "qty": 3,
        "pu": 121.98,
        "sub": 365.94,
        "lote": "263274",
        "tipo": "marca",
        "categoria": "Medicamentos",
        "receta": True,
        "marca": "Maver",
        "presentacion": "Caja con 10 comprimidos",
        "principio": "Citicolina",
        "concentracion": "500 mg",
        "forma": "Comprimido",
        "subcat": "Neurología",
        "imagen": FOTO.format("coniax-citicolina-500-10-maver.jpg"),
    },
    {
        "ean": "7501349014190",
        "sku": "EQ-AMS147",
        "nombre": "Ácido alendrónico 10 mg C/30 AMSA",
        "snap": "AMS147 ACIDO ALENDRONICO 30 TAB 10 MG",
        "qty": 4,
        "pu": 25.93,
        "sub": 103.72,
        "lote": "U25T260",
        "tipo": "generico",
        "categoria": "Medicamentos",
        "receta": True,
        "marca": "AMSA",
        "presentacion": "Caja con 30 tabletas",
        "principio": "Ácido alendrónico",
        "concentracion": "10 mg",
        "forma": "Tableta",
        "subcat": "Osteoporosis",
        "imagen": FOTO.format("acido-alendronico-10-30-amsa.jpg"),
    },
    {
        "ean": "7502247373495",
        "sku": "EQ-LAN057",
        "nombre": "Bacat Atorvastatina 20 mg C/30 Landsteiner",
        "snap": "LAN057 BACAT 30 TAB 20 MG",
        "qty": 5,
        "pu": 39.54,
        "sub": 197.70,
        "lote": "L26G0409",
        "tipo": "generico",
        "categoria": "Medicamentos",
        "receta": True,
        "marca": "Landsteiner",
        "presentacion": "Caja con 30 tabletas",
        "principio": "Atorvastatina",
        "concentracion": "20 mg",
        "forma": "Tableta",
        "subcat": "Cardiovascular",
        "imagen": FOTO.format("bacat-atorvastatina-20-30-landsteiner.webp"),
    },
    {
        "ean": "7501836006028",
        "sku": "FC-36006028",
        "nombre": "Virindrez Infantil oximetazolina 0.025% 20 mL",
        "snap": "LIF161 VIRINDREZ INFANTIL 1 ATOM 25 MG/20 ML",
        "qty": 1,
        "pu": 20.70,
        "sub": 20.70,
        "lote": "26C079",
        "tipo": "marca",
        "categoria": "Medicamentos",
        "receta": False,
        "marca": "Liferpal MD",
        "presentacion": "Frasco atomizador 20 mL",
        "principio": "Oximetazolina",
        "concentracion": "0.025%",
        "forma": "Solución nasal",
        "subcat": "Respiratorio",
        "imagen": None,  # ya en catálogo
    },
]


def ceil_pvp(costo: float, factor: float = 1.6) -> float:
    return float(math.ceil(costo * factor))


def write_csv(path: Path) -> None:
    import csv

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
                "nombre_mostrador",
                "cantidad",
                "precio_unitario",
                "subtotal",
                "lote",
                "sku_farmacapital",
                "total_ticket",
            ]
        )
        for i, r in enumerate(ROWS, start=1):
            w.writerow(
                [
                    i,
                    FOLIO,
                    FECHA,
                    PROVEEDOR,
                    r["ean"],
                    r["snap"],
                    r["nombre"],
                    r["qty"],
                    f"{r['pu']:.2f}",
                    f"{r['sub']:.2f}",
                    r["lote"],
                    r["sku"],
                    f"{TOTAL:.2f}",
                ]
            )


def write_carga_sql(path: Path) -> None:
    lines = [
        "-- Equilibrio · foto 12-sep-2026 · caja Iztapalapa 2.",
        "-- Folio no venía en el recorte: usamos 20260912.",
        f"-- Total ${TOTAL:,.2f} · 7 renglones / 21 pzas.",
        "-- Costo = P.U. del ticket. Lote de fábrica sí. Caducidad NO:",
        "-- Recibir pide MMAA de la caja. 0000 es inválido.",
        "-- Fichas: Sufarmed / DISA / FarmaSmart / Sanorim (EAN verificados).",
        "-- Fotos en public/catalogo-propia/ (URLs tras deploy Vercel).",
        "-- SIN bloques dollar-quote. Pegar TODO en Supabase → SQL Editor → Run.",
        "",
        "begin;",
        "",
        "create temp table _fc_eq20260912 (",
        "  linea integer primary key,",
        "  ean text not null,",
        "  sku text not null,",
        "  nombre text not null,",
        "  snap text not null,",
        "  qty integer not null,",
        "  costo numeric(12,2) not null,",
        "  precio numeric(12,2) not null,",
        "  tipo text not null,",
        "  categoria text not null,",
        "  receta boolean not null,",
        "  marca text,",
        "  presentacion text,",
        "  principio text,",
        "  concentracion text,",
        "  forma text,",
        "  subcat text,",
        "  imagen text,",
        "  lote text",
        ") on commit drop;",
        "",
        "insert into _fc_eq20260912 (",
        "  linea, ean, sku, nombre, snap, qty, costo, precio, tipo, categoria, receta,",
        "  marca, presentacion, principio, concentracion, forma, subcat, imagen, lote",
        ") values",
    ]
    vals = []
    for i, r in enumerate(ROWS, start=1):
        pvp = ceil_pvp(r["pu"])
        vals.append(
            "  ("
            f"{i}, {sql_str(r['ean'])}, {sql_str(r['sku'])},\n"
            f"   {sql_str(r['nombre'])},\n"
            f"   {sql_str(r['snap'])},\n"
            f"   {r['qty']}, {r['pu']:.2f}, {pvp:.0f}, {sql_str(r['tipo'])}, {sql_str(r['categoria'])}, "
            f"{'true' if r['receta'] else 'false'},\n"
            f"   {sql_str(r['marca'])}, {sql_str(r['presentacion'])}, {sql_str(r['principio'])}, "
            f"{sql_str(r['concentracion'])}, {sql_str(r['forma'])},\n"
            f"   {sql_str(r['subcat'])}, {sql_str(r['imagen'])}, {sql_str(r['lote'])})"
        )
    lines.append(",\n".join(vals) + ";")

    lines += [
        "",
        "insert into public.productos (",
        "  nombre, sku, codigo_barras, categoria, subcategoria, tipo, descripcion,",
        "  marca, presentacion, principio_activo, concentracion, forma_farmaceutica,",
        "  costo, precio, imagen_url, imagen_mobile_url,",
        "  stock, stock_minimo, activo, requiere_receta",
        ")",
        "select",
        "  t.nombre,",
        "  case",
        "    when exists (",
        "      select 1 from public.productos p",
        "      where p.sku = t.sku and coalesce(p.codigo_barras, '') <> t.ean",
        "    ) then 'EQ-' || t.ean",
        "    else t.sku",
        "  end,",
        "  t.ean,",
        "  t.categoria,",
        "  t.subcat,",
        "  t.tipo,",
        "  'Alta Equilibrio 20260912 · foto ticket · listo para pistola',",
        "  t.marca,",
        "  t.presentacion,",
        "  t.principio,",
        "  t.concentracion,",
        "  t.forma,",
        "  t.costo,",
        "  t.precio,",
        "  t.imagen,",
        "  t.imagen,",
        "  0,",
        "  1,",
        "  true,",
        "  t.receta",
        "from (",
        "  select distinct on (ean) *",
        "  from _fc_eq20260912",
        "  order by ean, linea",
        ") t",
        "where public.fc_buscar_producto_escaneo(t.ean) is null",
        "  and public.fc_buscar_producto_escaneo(t.sku) is null;",
        "",
        "update public.productos p",
        "set",
        "  costo = t.costo,",
        "  precio = case",
        "    when coalesce(p.precio, 0) <= 0 then t.precio",
        "    else p.precio",
        "  end,",
        "  marca = coalesce(nullif(trim(p.marca), ''), t.marca),",
        "  presentacion = coalesce(nullif(trim(p.presentacion), ''), t.presentacion),",
        "  principio_activo = coalesce(nullif(trim(p.principio_activo), ''), t.principio),",
        "  concentracion = coalesce(nullif(trim(p.concentracion), ''), t.concentracion),",
        "  forma_farmaceutica = coalesce(nullif(trim(p.forma_farmaceutica), ''), t.forma),",
        "  subcategoria = coalesce(nullif(trim(p.subcategoria), ''), t.subcat),",
        "  imagen_url = coalesce(nullif(trim(p.imagen_url), ''), t.imagen),",
        "  imagen_mobile_url = coalesce(nullif(trim(p.imagen_mobile_url), ''), t.imagen),",
        "  codigo_barras = coalesce(nullif(trim(p.codigo_barras), ''), t.ean)",
        "from (",
        "  select distinct on (ean) *",
        "  from _fc_eq20260912",
        "  order by ean, linea",
        ") t",
        "where p.id = coalesce(",
        "  public.fc_buscar_producto_escaneo(t.ean),",
        "  public.fc_buscar_producto_escaneo(t.sku)",
        ");",
        "",
        "insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)",
        "select",
        f"  {sql_str(PROVEEDOR)},",
        f"  {sql_str(FOLIO)},",
        f"  {sql_str(FECHA)},",
        f"  {TOTAL:.2f},",
        "  'borrador',",
        "  'Ticket Equilibrio térmico · caja Iztapalapa 2 · foto 12-sep-2026 · "
        "folio no en recorte · cola Recibir; stock al confirmar pistola · "
        "lote de fábrica en el papel; MMAA de la caja'",
        "where not exists (",
        "  select 1 from public.recepciones",
        f"  where folio = {sql_str(FOLIO)} and coalesce(proveedor, '') ilike '%equilibrio%'",
        ");",
        "",
        "update public.recepciones",
        "set",
        f"  total_ticket = {TOTAL:.2f},",
        f"  fecha = {sql_str(FECHA)},",
        f"  proveedor = {sql_str(PROVEEDOR)},",
        "  notas = 'Ticket Equilibrio térmico · caja Iztapalapa 2 · foto 12-sep-2026 · "
        "folio no en recorte · cola Recibir; stock al confirmar pistola · "
        "lote de fábrica en el papel; MMAA de la caja',",
        "  updated_at = now()",
        f"where folio = {sql_str(FOLIO)}",
        "  and coalesce(proveedor, '') ilike '%equilibrio%'",
        "  and estado = 'borrador';",
        "",
        "delete from public.recepcion_items i",
        "using public.recepciones r",
        "where i.recepcion_id = r.id",
        f"  and r.folio = {sql_str(FOLIO)}",
        "  and coalesce(r.proveedor, '') ilike '%equilibrio%'",
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
        "  t.ean,",
        "  t.nombre,",
        "  t.qty,",
        "  null,",
        "  t.lote,",
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
        "        and l.numero_lote is distinct from t.lote",
        "    )",
        "  ),",
        "  null",
        "from _fc_eq20260912 t",
        "join public.recepciones r",
        f"  on r.folio = {sql_str(FOLIO)}",
        " and coalesce(r.proveedor, '') ilike '%equilibrio%'",
        " and r.estado = 'borrador'",
        "left join lateral (",
        "  select coalesce(",
        "    public.fc_buscar_producto_escaneo(t.ean),",
        "    public.fc_buscar_producto_escaneo(t.sku)",
        "  ) as pid",
        ") v on true",
        "order by t.linea;",
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
        f"where r.folio = {sql_str(FOLIO)} and coalesce(r.proveedor, '') ilike '%equilibrio%'",
        "order by i.id;",
        "",
    ]
    path.write_text("\n".join(lines), encoding="utf-8")


def main() -> None:
    out_csv = ROOT / "sql" / "generated" / f"ticket_equilibrio_{FOLIO}.csv"
    out_sql = ROOT / "sql" / f"patch_carga_equilibrio_{FOLIO}.sql"
    write_csv(out_csv)
    write_carga_sql(out_sql)

    data = [
        {
            "nombre": r["nombre"],
            "qty": r["qty"],
            "sub": r["sub"],
            "pu": r["pu"],
            "ean": r["ean"],
            "sku": r["sku"],
            "match": "ean",
        }
        for r in ROWS
    ]
    suma = sum(r["sub"] for r in data)
    piezas = sum(r["qty"] for r in data)
    print(report(data, TOTAL))
    print(f"piezas={piezas} esperado=21 ok={piezas == 21}")
    print(f"suma=${suma:.2f} total=${TOTAL:.2f} delta={suma - TOTAL:.2f}")
    print(f"csv={out_csv}")
    print(f"sql={out_sql}")
    if piezas != 21 or abs(suma - TOTAL) >= 0.02:
        raise SystemExit("totales no cuadran")


if __name__ == "__main__":
    main()
