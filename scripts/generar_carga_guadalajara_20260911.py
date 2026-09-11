#!/usr/bin/env python3
"""Tickets Farmacias Guadalajara 11-sep-2026 → altas + cola Recibir.

Fuente: tickets térmicos SUC SN Lorenzo Iztapalapa CDMX (fotos).
  1) NO TICKET 531527 · Lenzetto 6.5 ml · $578.76 · FOLIO FACTURA 599104-181830-424489
  2) Wegovy 1.7 mg · $4,650.00 · AUT 764870 (NO TICKET no salió en la foto)

EAN de fichas México (no inventados):
  Lenzetto 6.5 ml 56 dosis → 7506352500128 (SFE / Farmacia Herrera)
  Wegovy FlexTouch 1.7 mg → 7503007822970 (tienda Novo Nordisk / Fahorro)

Nombres de mostrador desde ficha (no el renglón del ticket).
Sin lote ni MMAA. Stock al escanear + caducidad de la caja.
"""
from __future__ import annotations

import math
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from generar_recepcion_borrador import report, write_recepcion_sql, write_ticket_csv

ROOT = Path(__file__).resolve().parents[1]
OUT_TICKET_L = ROOT / "sql" / "generated" / "ticket_guadalajara_531527.csv"
OUT_TICKET_W = ROOT / "sql" / "generated" / "ticket_guadalajara_AUT764870.csv"
OUT_SQL = ROOT / "sql" / "patch_carga_guadalajara_20260911.sql"
OUT_FOTOS = ROOT / "sql" / "patch_fotos_guadalajara_20260911.sql"

PROVEEDOR = "Farmacias Guadalajara"
FECHA = "2026-09-11"

FOTO_BASE = "https://www.farmacapital.mx/catalogo-propia"


def ceil_pvp(costo: float) -> int:
    """Marca/patente: markup 25% sobre costo (recepcionAlta)."""
    return int(math.ceil(costo * 1.25))


def sku_de(ean: str) -> str:
    return "FC-" + ean[-8:]


# folio, total, row dict for recepción + ficha alta
TICKETS = [
    {
        "folio": "531527",
        "fecha": FECHA,
        "total": 578.76,
        "notas": (
            "Ticket FG 531527 · SUC SN Lorenzo Iztapalapa · "
            "FOLIO FACTURA 599104-181830-424489 · 2026-09-11 15:50 · "
            "cola Recibir; stock al confirmar pistola"
        ),
        "row": {
            "nombre": "LENZETTO 1.53MG/DS 6.5ML 56D SOL",
            "qty": 1,
            "pu": 578.76,
            "sub": 578.76,
            "ean": "7506352500128",
            "sku": sku_de("7506352500128"),
            "match": "guadalajara",
        },
        "alta": {
            "ean": "7506352500128",
            "sku": sku_de("7506352500128"),
            "nombre": "Lenzetto estradiol 1.53 mg/dosis solución aerosol 6.5 ml (56 dosis)",
            "marca": "Lenzetto",
            "laboratorio": "Gedeon Richter",
            "presentacion": "Caja con frasco 6.5 ml (56 dosis)",
            "principio_activo": "Estradiol",
            "concentracion": "1.53 mg/dosis",
            "forma_farmaceutica": "Solución aerosol transdérmica",
            "categoria": "Medicamentos",
            "subcategoria": "Terapia hormonal",
            "tipo": "marca",
            "receta": True,
            "costo": 578.76,
            "precio": ceil_pvp(578.76),
            "foto": f"{FOTO_BASE}/lenzetto-1.53mg-6.5ml.jpg",
            "descripcion": (
                "Ticket FG 531527 · LENZETTO 1.53MG/DS 6.5ML 56D SOL · "
                "ficha SFE/Herrera EAN 7506352500128"
            ),
        },
    },
    {
        "folio": "AUT-764870",
        "fecha": FECHA,
        "total": 4650.00,
        "notas": (
            "Ticket FG Wegovy · SUC SN Lorenzo Iztapalapa · "
            "AUT Bancomer 764870 (NO TICKET no visible en foto) · "
            "misma caja 2 / misma tarjeta · cola Recibir; stock al confirmar pistola · "
            "cadena de frío 2–8 °C"
        ),
        "row": {
            "nombre": "WEGOVY 1.7MG SOL INY 1 PLUMA/PRE",
            "qty": 1,
            "pu": 4650.00,
            "sub": 4650.00,
            "ean": "7503007822970",
            "sku": sku_de("7503007822970"),
            "match": "guadalajara",
        },
        "alta": {
            "ean": "7503007822970",
            "sku": sku_de("7503007822970"),
            "nombre": "Wegovy FlexTouch semaglutida 1.7 mg/dosis pluma 3 ml + 4 agujas",
            "marca": "Wegovy",
            "laboratorio": "Novo Nordisk",
            "presentacion": "Caja con 1 pluma FlexTouch 3 ml y 4 agujas NovoFine Plus",
            "principio_activo": "Semaglutida",
            "concentracion": "1.7 mg/dosis (2.27 mg/mL)",
            "forma_farmaceutica": "Solución inyectable",
            "categoria": "Medicamentos",
            "subcategoria": "Control de peso",
            "tipo": "marca",
            "receta": True,
            "costo": 4650.00,
            "precio": ceil_pvp(4650.00),
            "foto": f"{FOTO_BASE}/wegovy-flextouch-1.7mg.jpg",
            "descripcion": (
                "Ticket FG AUT-764870 · WEGOVY 1.7MG SOL INY 1 PLUMA/PRE · "
                "ficha Novo Nordisk/Fahorro EAN 7503007822970 · refrigerar 2–8 °C"
            ),
        },
    },
]


def sql_str(v: str | None) -> str:
    if v is None:
        return "null"
    return "'" + str(v).replace("'", "''") + "'"


def write_combined_sql(path: Path) -> None:
    lines = [
        "-- Farmacias Guadalajara · tickets 11-sep-2026 — altas + cola Recibir.",
        "-- SIN bloques dollar-quote (do $$). El SQL Editor de Supabase los corta.",
        "-- 2 altas stock 0 (Lenzetto + Wegovy). Tickets borrador separados.",
        "-- Stock al escanear + MMAA de la caja. No inventar 0000.",
        "-- Folio Wegovy = AUT-764870: el NO TICKET no salió en la foto; corregir si aparece.",
        "-- Fotos en catalogo-propia: visibles tras deploy → patch_fotos_guadalajara_20260911.sql",
        "-- Idempotente mientras los tickets sigan en borrador.",
        "-- Pegar TODO este archivo en Supabase → SQL Editor → Run.",
        "",
        "begin;",
        "",
        "create temp table _fc_gdl20260911 (",
        "  linea integer primary key,",
        "  folio text not null,",
        "  ean text not null,",
        "  sku text not null,",
        "  nombre text not null,",
        "  snap text not null,",
        "  qty integer not null,",
        "  costo numeric(12,2) not null,",
        "  precio numeric(12,2) not null,",
        "  tipo text not null,",
        "  categoria text not null,",
        "  subcategoria text,",
        "  marca text,",
        "  laboratorio text,",
        "  presentacion text,",
        "  principio_activo text,",
        "  concentracion text,",
        "  forma_farmaceutica text,",
        "  imagen_url text,",
        "  descripcion text,",
        "  receta boolean not null",
        ") on commit drop;",
        "",
        "insert into _fc_gdl20260911 (",
        "  linea, folio, ean, sku, nombre, snap, qty, costo, precio, tipo,",
        "  categoria, subcategoria, marca, laboratorio, presentacion,",
        "  principio_activo, concentracion, forma_farmaceutica, imagen_url,",
        "  descripcion, receta",
        ") values",
    ]

    vals = []
    for i, t in enumerate(TICKETS, start=1):
        a = t["alta"]
        r = t["row"]
        vals.append(
            "  ("
            + ", ".join(
                [
                    str(i),
                    sql_str(t["folio"]),
                    sql_str(a["ean"]),
                    sql_str(a["sku"]),
                    sql_str(a["nombre"]),
                    sql_str(r["nombre"]),
                    str(r["qty"]),
                    f"{a['costo']:.2f}",
                    str(a["precio"]),
                    sql_str(a["tipo"]),
                    sql_str(a["categoria"]),
                    sql_str(a["subcategoria"]),
                    sql_str(a["marca"]),
                    sql_str(a["laboratorio"]),
                    sql_str(a["presentacion"]),
                    sql_str(a["principio_activo"]),
                    sql_str(a["concentracion"]),
                    sql_str(a["forma_farmaceutica"]),
                    sql_str(a["foto"]),
                    sql_str(a["descripcion"]),
                    "true" if a["receta"] else "false",
                ]
            )
            + ")"
        )
    lines.append(",\n".join(vals) + ";")

    lines += [
        "",
        "insert into public.productos (",
        "  nombre, sku, codigo_barras, categoria, tipo, descripcion,",
        "  costo, precio, stock, stock_minimo, activo, requiere_receta,",
        "  marca, laboratorio, presentacion, principio_activo, concentracion,",
        "  forma_farmaceutica, subcategoria, imagen_url",
        ")",
        "select",
        "  t.nombre,",
        "  case",
        "    when exists (",
        "      select 1 from public.productos p",
        "      where p.sku = t.sku and coalesce(p.codigo_barras, '') <> t.ean",
        "    ) then 'FC-GDL-' || right(t.ean, 8)",
        "    else t.sku",
        "  end,",
        "  t.ean,",
        "  t.categoria,",
        "  t.tipo,",
        "  t.descripcion,",
        "  t.costo,",
        "  t.precio,",
        "  0,",
        "  1,",
        "  true,",
        "  t.receta,",
        "  t.marca,",
        "  t.laboratorio,",
        "  t.presentacion,",
        "  t.principio_activo,",
        "  t.concentracion,",
        "  t.forma_farmaceutica,",
        "  t.subcategoria,",
        "  t.imagen_url",
        "from _fc_gdl20260911 t",
        "where public.fc_buscar_producto_escaneo(t.ean) is null;",
        "",
        "update public.productos p",
        "set",
        "  costo = t.costo,",
        "  precio = case when coalesce(p.precio, 0) <= 0 then t.precio else p.precio end,",
        "  nombre = t.nombre,",
        "  marca = coalesce(nullif(btrim(p.marca), ''), t.marca),",
        "  laboratorio = coalesce(nullif(btrim(p.laboratorio), ''), t.laboratorio),",
        "  presentacion = coalesce(nullif(btrim(p.presentacion), ''), t.presentacion),",
        "  principio_activo = coalesce(nullif(btrim(p.principio_activo), ''), t.principio_activo),",
        "  concentracion = coalesce(nullif(btrim(p.concentracion), ''), t.concentracion),",
        "  forma_farmaceutica = coalesce(nullif(btrim(p.forma_farmaceutica), ''), t.forma_farmaceutica),",
        "  categoria = coalesce(nullif(btrim(p.categoria), ''), t.categoria),",
        "  subcategoria = coalesce(nullif(btrim(p.subcategoria), ''), t.subcategoria),",
        "  requiere_receta = t.receta,",
        "  activo = true,",
        "  imagen_url = coalesce(nullif(btrim(p.imagen_url), ''), t.imagen_url)",
        "from _fc_gdl20260911 t",
        "where p.id = public.fc_buscar_producto_escaneo(t.ean);",
        "",
    ]

    for t in TICKETS:
        folio = t["folio"]
        total = t["total"]
        notas = t["notas"]
        lines += [
            f"-- ── Ticket {folio} ──────────────────────────────────────────",
            "insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)",
            "select",
            f"  {sql_str(PROVEEDOR)},",
            f"  {sql_str(folio)},",
            f"  {sql_str(t['fecha'])},",
            f"  {total:.2f},",
            "  'borrador',",
            f"  {sql_str(notas)}",
            "where not exists (",
            "  select 1 from public.recepciones",
            f"  where folio = {sql_str(folio)}",
            "    and coalesce(proveedor, '') ilike '%guadalajara%'",
            ");",
            "",
            "update public.recepciones",
            "set",
            f"  total_ticket = {total:.2f},",
            f"  fecha = {sql_str(t['fecha'])},",
            f"  proveedor = {sql_str(PROVEEDOR)},",
            f"  notas = {sql_str(notas)},",
            "  updated_at = now()",
            f"where folio = {sql_str(folio)}",
            "  and coalesce(proveedor, '') ilike '%guadalajara%'",
            "  and estado = 'borrador';",
            "",
            "delete from public.recepcion_items i",
            "using public.recepciones r",
            "where i.recepcion_id = r.id",
            f"  and r.folio = {sql_str(folio)}",
            "  and coalesce(r.proveedor, '') ilike '%guadalajara%'",
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
            "  t.snap,",
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
            "from _fc_gdl20260911 t",
            "join public.recepciones r",
            f"  on r.folio = {sql_str(folio)}",
            " and coalesce(r.proveedor, '') ilike '%guadalajara%'",
            " and r.estado = 'borrador'",
            "left join lateral (",
            "  select coalesce(",
            "    public.fc_buscar_producto_escaneo(t.ean),",
            "    public.fc_buscar_producto_escaneo(t.sku)",
            "  ) as pid",
            ") v on true",
            f"where t.folio = {sql_str(folio)}",
            "order by t.linea;",
            "",
        ]

    lines += [
        "commit;",
        "",
        "select",
        "  r.folio,",
        "  r.estado,",
        "  r.total_ticket,",
        "  count(i.*) as renglones,",
        "  count(*) filter (where not coalesce(i.confirmado, false)) as pendientes_pistola",
        "from public.recepciones r",
        "left join public.recepcion_items i on i.recepcion_id = r.id",
        "where coalesce(r.proveedor, '') ilike '%guadalajara%'",
        "  and r.folio in ('531527', 'AUT-764870')",
        "group by r.id, r.folio, r.estado, r.total_ticket",
        "order by r.folio;",
        "",
        "select",
        "  r.folio,",
        "  i.codigo_escaneado as ean,",
        "  left(i.nombre_snapshot, 48) as snap,",
        "  left(p.nombre, 56) as catalogo,",
        "  i.cantidad,",
        "  i.costo_estimado,",
        "  case when i.pendiente_alta then 'ALTA NUEVA' else 'YA EXISTE' end as estado",
        "from public.recepcion_items i",
        "join public.recepciones r on r.id = i.recepcion_id",
        "left join public.productos p on p.id = i.producto_id",
        "where coalesce(r.proveedor, '') ilike '%guadalajara%'",
        "  and r.folio in ('531527', 'AUT-764870')",
        "order by r.folio, i.id;",
        "",
    ]
    path.write_text("\n".join(lines), encoding="utf-8")


def write_fotos_sql(path: Path) -> None:
    lines = [
        "-- Farmacias Guadalajara 11-sep-2026 · fotos a catalogo-propia.",
        "-- Correr DESPUÉS del deploy de Vercel (los JPG viven en public/catalogo-propia/).",
        "-- SIN do $$. Pegar en Supabase → SQL Editor → Run.",
        "",
        "begin;",
        "",
    ]
    for t in TICKETS:
        a = t["alta"]
        foto = a["foto"]
        lines += [
            "update public.productos set",
            f"  imagen_url = {sql_str(foto)},",
            f"  imagen_mobile_url = {sql_str(foto)}",
            f"where codigo_barras = {sql_str(a['ean'])}",
            f"   or sku = {sql_str(a['sku'])};",
            "",
        ]
    lines += [
        "commit;",
        "",
        "select sku, codigo_barras as ean, left(nombre, 40) as nombre, left(imagen_url, 72) as foto",
        "from public.productos",
        "where codigo_barras in ('7506352500128', '7503007822970')",
        "   or sku in ('FC-52500128', 'FC-07822970')",
        "order by sku;",
        "",
    ]
    path.write_text("\n".join(lines), encoding="utf-8")


def main() -> None:
    for t, out in [
        (TICKETS[0], OUT_TICKET_L),
        (TICKETS[1], OUT_TICKET_W),
    ]:
        write_ticket_csv(
            out,
            folio=t["folio"],
            fecha=t["fecha"],
            proveedor=PROVEEDOR,
            total=t["total"],
            rows=[t["row"]],
        )
        print(out.name, report([t["row"]], t["total"]))

    write_combined_sql(OUT_SQL)
    write_fotos_sql(OUT_FOTOS)
    print("wrote", OUT_SQL.relative_to(ROOT))
    print("wrote", OUT_FOTOS.relative_to(ROOT))
    for t in TICKETS:
        a = t["alta"]
        print(
            f"  {t['folio']}: {a['nombre'][:48]}… "
            f"costo ${a['costo']:.2f} pvp ${a['precio']} ean {a['ean']}"
        )


if __name__ == "__main__":
    main()
