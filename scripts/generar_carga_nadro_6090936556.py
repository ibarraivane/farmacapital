#!/usr/bin/env python3
"""Factura Nadro folio 6090936556 (08-oct-2026, 7 renglones) → catálogo + cola Recibir.

EAN de caja (Sufarmed / Prixz / Farma24 / Curitek). Varios dígitos del papel
fallan check GS1 (caso Garnier 000004568). Pistola = barcode de la caja.
Ficha de mostrador, no el código LGEN del ticket.
Recargo sobre costo: genérico +60%. No es margen sobre venta.
Sin lote ni MMAA en la cola: salen de la caja al escanear.
"""
from __future__ import annotations

import math
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from generar_recepcion_borrador import report, write_ticket_csv

ROOT = Path(__file__).resolve().parents[1]
OUT_TICKET = ROOT / "sql" / "generated" / "ticket_nadro_6090936556.csv"
OUT_SQL = ROOT / "sql" / "patch_carga_nadro_6090936556.sql"

FOLIO = "6090936556"
PROVEEDOR = "Nadro"
FECHA = "2026-10-08"
TOTAL_TICKET = 778.42
FOTO_BASE = "https://www.farmacapital.mx/catalogo-propia"


def precio_markup(costo: float, tipo: str) -> int:
    recargo = 0.25 if tipo == "marca" else 0.60
    return math.ceil(costo * (1 + recargo))


def sku_de(ean: str) -> str:
    return "FC-" + ean[-8:]


def sql_str(s: str | None) -> str:
    if s is None:
        return "null"
    return "'" + str(s).replace("'", "''") + "'"


# snap ticket, qty, pu, ean pistola, sku (None → FC-últimos 8), match,
# nombre POS, tipo, cat, subcat, marca, presentacion, forma, lab, pa, conc,
# receta, alta_nueva, foto_file
RAW = [
    (
        "AMOXICILINA 250 MG 12 CAPS LGEN",
        5,
        15.48,
        "7503001007281",
        None,
        "nadro",
        "Vandix 250 mg",
        "generico",
        "Medicamentos",
        "Antibióticos",
        "Vandix",
        "C/12 cápsulas",
        "Cápsulas",
        "Wandel",
        "Amoxicilina",
        "250 mg",
        True,
        True,
        "vandix-amoxicilina-250mg-c12-7503001007281.jpg",
    ),
    (
        "AMOXICILINA 500 MG 12 CAPS LGEN",
        5,
        18.76,
        "7501349021570",
        "FC-49021570",
        "catalogo",
        "Amoxicilina 500 mg",
        "generico",
        "Medicamentos",
        "Antibióticos",
        None,
        "C/12 cápsulas",
        "Cápsulas",
        "AMSA",
        "Amoxicilina",
        "500 mg",
        True,
        False,
        "amoxicilina-500mg-c12-amsa-7501349021570.jpg",
    ),
    (
        "AMPICILINA 1 G 10 TAB LGEN",
        4,
        24.63,
        "7501349022881",
        "FC-F82A6E4B",
        "catalogo",
        "Ampicilina 1 g",
        "generico",
        "Medicamentos",
        "Antibióticos",
        None,
        "C/10 tabletas",
        "Tabletas",
        "AMSA",
        "Ampicilina",
        "1 g",
        True,
        False,
        "ampicilina-1g-c10-amsa-7501349022881.jpg",
    ),
    (
        "AMPICILINA 250 MG 60 ML SUSP LGEN",
        4,
        16.71,
        "7503001007137",
        None,
        "nadro",
        "Mexapin 250 mg/5 ml",
        "generico",
        "Medicamentos",
        "Antibióticos",
        "Mexapin",
        "Frasco 60 ml",
        "Suspensión",
        "Wandel",
        "Ampicilina",
        "250 mg/5 ml",
        True,
        True,
        "mexapin-ampicilina-250mg-susp-60ml-7503001007137.jpg",
    ),
    (
        "AMPICILINA 500 MG 20 CAPS LGEN",
        3,
        29.35,
        "7503001007168",
        None,
        "nadro",
        "Mexapin 500 mg",
        "generico",
        "Medicamentos",
        "Antibióticos",
        "Mexapin",
        "C/20 cápsulas",
        "Cápsulas",
        "Wandel",
        "Ampicilina",
        "500 mg",
        True,
        True,
        "mexapin-ampicilina-500mg-c20-7503001007168.jpg",
    ),
    (
        "BONGLIXAN 100UI S I FA 10ML LGEN",
        1,
        224.99,
        "7502247375543",
        None,
        "nadro",
        "Bonglixan 100 UI",
        "generico",
        "Medicamentos",
        "Diabetes",
        "Bonglixan",
        "Frasco ámpula 10 ml",
        "Solución inyectable",
        "Landsteiner Scientific",
        "Insulina glargina",
        "100 UI/ml",
        True,
        True,
        "bonglixan-insulina-glargina-100ui-10ml-7502247375543.jpg",
    ),
    (
        "BRESALTEC 100 UG INH 200 DOSIS LGEN",
        3,
        42.94,
        "7506022327635",
        None,
        "nadro",
        "Bresaltec 100 µg",
        "generico",
        "Medicamentos",
        "Respiratorio",
        "Bresaltec",
        "200 dosis",
        "Aerosol",
        "BiosynTec",
        "Salbutamol",
        "100 µg/dosis",
        True,
        True,
        "bresaltec-salbutamol-100ug-200dosis-7506022327635.jpg",
    ),
]


def rows():
    out = []
    for snap, qty, pu, ean, sku, match, *_rest in RAW:
        out.append(
            {
                "nombre": snap,
                "qty": qty,
                "sub": round(pu * qty, 2),
                "pu": pu,
                "ean": ean,
                "sku": sku or sku_de(ean),
                "match": match,
            }
        )
    return out


def altas():
    out = []
    for (
        snap,
        qty,
        pu,
        ean,
        sku,
        match,
        pos,
        tipo,
        cat,
        subcat,
        marca,
        presentacion,
        forma,
        lab,
        pa,
        conc,
        receta,
        alta,
        foto,
    ) in RAW:
        out.append(
            {
                "ean": ean,
                "sku": sku or sku_de(ean),
                "nombre": pos,
                "snap": snap,
                "costo": pu,
                "precio": precio_markup(pu, tipo),
                "tipo": tipo,
                "categoria": cat,
                "subcategoria": subcat,
                "marca": marca,
                "presentacion": presentacion,
                "forma": forma,
                "laboratorio": lab,
                "principio_activo": pa,
                "concentracion": conc,
                "receta": receta,
                "alta_nueva": alta,
                "qty": qty,
                "imagen": f"{FOTO_BASE}/{foto}",
                "foto_file": f"catalogo-propia/{foto}",
            }
        )
    return out


def write_unified_sql(path: Path, items: list) -> None:
    vals = []
    for i, r in enumerate(items):
        vals.append(
            "  ({linea}, {ean}, {sku}, {pos}, {snap}, {qty}, {costo}, {precio}, {tipo}, "
            "{cat}, {subcat}, {marca}, {pres}, {forma}, {lab}, {pa}, {conc}, {receta}, "
            "{alta}, {imagen}, {foto})".format(
                linea=i + 1,
                ean=sql_str(r["ean"]),
                sku=sql_str(r["sku"]),
                pos=sql_str(r["nombre"]),
                snap=sql_str(r["snap"]),
                qty=int(r["qty"]),
                costo=f"{r['costo']:.2f}",
                precio=r["precio"],
                tipo=sql_str(r["tipo"]),
                cat=sql_str(r["categoria"]),
                subcat=sql_str(r["subcategoria"]),
                marca=sql_str(r["marca"]),
                pres=sql_str(r["presentacion"]),
                forma=sql_str(r["forma"]),
                lab=sql_str(r["laboratorio"]),
                pa=sql_str(r["principio_activo"]),
                conc=sql_str(r["concentracion"]),
                receta="true" if r["receta"] else "false",
                alta="true" if r["alta_nueva"] else "false",
                imagen=sql_str(r["imagen"]),
                foto=sql_str(r["foto_file"]),
            )
        )

    eans_sql = ",\n  ".join(sql_str(r["ean"]) for r in items)
    body = f"""-- Factura Nadro folio {FOLIO} ({FECHA}) — altas + cola Recibir.
-- CFDI 08-oct-2026 · NADRO MEXICO SUR · UUID 40B36653-DBBA-42FC-B94B-AE0074E75C9D
-- Total ${TOTAL_TICKET:.2f} · 7 renglones · 25 piezas
-- EAN de caja (no OCR sucio del papel: varios fallan check GS1).
-- Ficha de mostrador: Vandix / Mexapin / Bonglixan / Bresaltec. LGEN no es marca.
-- LIFEFACTOR / JAYOR del ticket = casa Nadro, no laboratorio de caja.
-- Recargo genérico +60% sobre costo. PVP existente no se pisa.
-- 5 altas stock 0. 2 ya en catálogo (FC-49021570, FC-F82A6E4B).
-- Bonglixan: cadena fría. Stock al escanear + MMAA de la caja. No inventar 0000.
-- Fotos en public/catalogo-propia/ (visibles tras deploy Vercel).
-- SIN bloques dollar-quote (do $$). El SQL Editor de Supabase los corta.
-- Idempotente mientras el ticket siga en borrador.
-- Pegar TODO este archivo en Supabase → SQL Editor → Run.

begin;

create temp table _fc_nd6090936556 (
  linea integer primary key,
  ean text not null,
  sku text not null,
  nombre text not null,
  snap text not null,
  qty integer not null,
  costo numeric(12,2) not null,
  precio numeric(12,2) not null,
  tipo text not null,
  categoria text not null,
  subcategoria text,
  marca text,
  presentacion text,
  forma text,
  laboratorio text,
  principio_activo text,
  concentracion text,
  receta boolean not null,
  alta_nueva boolean not null,
  imagen text,
  foto_file text
) on commit drop;

insert into _fc_nd6090936556
  (linea, ean, sku, nombre, snap, qty, costo, precio, tipo, categoria, subcategoria,
   marca, presentacion, forma, laboratorio, principio_activo, concentracion,
   receta, alta_nueva, imagen, foto_file)
values
{chr(10).join(v + ("," if i < len(vals) - 1 else ";") for i, v in enumerate(vals))}

-- Altas nuevas (solo si el EAN no existe).
insert into public.productos (
  nombre, sku, codigo_barras, categoria, subcategoria, tipo, descripcion,
  costo, precio, stock, stock_minimo, activo, requiere_receta,
  marca, presentacion, forma_farmaceutica, principio_activo, concentracion,
  laboratorio, imagen_url, imagen_mobile_url
)
select
  t.nombre,
  case
    when exists (
      select 1 from public.productos p
      where p.sku = t.sku and coalesce(p.codigo_barras, '') <> t.ean
    ) then 'FC-ND-' || right(t.ean, 8)
    else t.sku
  end,
  t.ean,
  t.categoria,
  t.subcategoria,
  t.tipo,
  'Alta Nadro {FOLIO} · {FECHA} · listo para pistola',
  t.costo,
  t.precio,
  0,
  1,
  true,
  t.receta,
  t.marca,
  t.presentacion,
  t.forma,
  t.principio_activo,
  t.concentracion,
  t.laboratorio,
  t.imagen,
  t.imagen
from _fc_nd6090936556 t
where t.alta_nueva
  and public.fc_buscar_producto_escaneo(t.ean) is null;

-- Ficha de mostrador (marca real, no casa Nadro LGEN / LIFEFACTOR / JAYOR).
update public.productos p set
  marca = coalesce(nullif(btrim(t.marca), ''), p.marca),
  presentacion = t.presentacion,
  forma_farmaceutica = t.forma,
  principio_activo = t.principio_activo,
  concentracion = t.concentracion,
  subcategoria = t.subcategoria,
  laboratorio = coalesce(nullif(btrim(t.laboratorio), ''), nullif(btrim(p.laboratorio), ''), t.laboratorio),
  nombre = t.nombre,
  categoria = t.categoria,
  tipo = t.tipo,
  requiere_receta = t.receta
from _fc_nd6090936556 t
where p.id = public.fc_buscar_producto_escaneo(t.ean);

-- Costos del ticket (PVP solo si estaba en 0).
update public.productos p
set
  costo = t.costo,
  precio = case
    when coalesce(p.precio, 0) <= 0 then t.precio
    else p.precio
  end
from _fc_nd6090936556 t
where p.id = public.fc_buscar_producto_escaneo(t.ean)
  and (
    p.costo is distinct from t.costo
    or coalesce(p.precio, 0) <= 0
  );

-- Foto si falta (no pisa packshot que ya esté).
update public.productos p
set
  imagen_url = t.imagen,
  imagen_mobile_url = coalesce(nullif(btrim(p.imagen_mobile_url), ''), t.imagen)
from _fc_nd6090936556 t
where p.id = public.fc_buscar_producto_escaneo(t.ean)
  and t.imagen is not null
  and (
    p.imagen_url is null
    or btrim(p.imagen_url) = ''
    or p.imagen_url not like '%catalogo-propia/%'
  );

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  {sql_str(PROVEEDOR)},
  {sql_str(FOLIO)},
  {sql_str(FECHA)},
  {TOTAL_TICKET:.2f},
  'borrador',
  {sql_str("Factura Nadro 6090936556 · 08-10-26 · EAN caja · Bonglixan cadena fría · cola Recibir; stock al confirmar pistola")}
where not exists (
  select 1 from public.recepciones
  where folio = {sql_str(FOLIO)} and coalesce(proveedor, '') ilike '%nadro%'
);

update public.recepciones
set
  total_ticket = {TOTAL_TICKET:.2f},
  fecha = {sql_str(FECHA)},
  proveedor = {sql_str(PROVEEDOR)},
  notas = {sql_str("Factura Nadro 6090936556 · 08-10-26 · EAN caja · Bonglixan cadena fría · cola Recibir; stock al confirmar pistola")},
  updated_at = now()
where folio = {sql_str(FOLIO)}
  and coalesce(proveedor, '') ilike '%nadro%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = {sql_str(FOLIO)}
  and coalesce(r.proveedor, '') ilike '%nadro%'
  and r.estado = 'borrador';

insert into public.recepcion_items (
  recepcion_id, producto_id, codigo_escaneado, nombre_snapshot,
  cantidad, fecha_caducidad, numero_lote, costo_estimado, pendiente_alta,
  origen, confirmado, lote_distinto, lote_id
)
select
  r.id,
  v.pid,
  t.ean,
  t.snap,
  t.qty,
  null,
  null,
  t.costo,
  (v.pid is null),
  'pdf',
  false,
  (
    v.pid is not null and exists (
      select 1 from public.lotes l
      where l.producto_id = v.pid
        and coalesce(l.activo, true)
        and coalesce(l.cantidad_actual, 0) > 0
    )
  ),
  null
from _fc_nd6090936556 t
join public.recepciones r
  on r.folio = {sql_str(FOLIO)}
 and coalesce(r.proveedor, '') ilike '%nadro%'
 and r.estado = 'borrador'
left join lateral (
  select coalesce(
    public.fc_buscar_producto_escaneo(t.ean),
    public.fc_buscar_producto_escaneo(t.sku)
  ) as pid
) v on true
order by t.linea;

insert into public.producto_imagenes
  (producto_id, url, storage_path, posicion, es_principal, origen)
select
  p.id,
  t.imagen,
  t.foto_file,
  coalesce((
    select max(i.posicion) from public.producto_imagenes i
    where i.producto_id = p.id
  ), 0) + 1,
  not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id and i.es_principal
  ),
  'propia'
from _fc_nd6090936556 t
join public.productos p on p.id = public.fc_buscar_producto_escaneo(t.ean)
where t.imagen is not null
  and not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id and i.url = t.imagen
  );

commit;

select
  i.id,
  i.codigo_escaneado as ean,
  left(i.nombre_snapshot, 48) as nombre,
  i.cantidad,
  i.costo_estimado,
  case when i.pendiente_alta then 'ALTA NUEVA' else 'YA EXISTE' end as estado,
  p.sku,
  left(p.nombre, 48) as nombre_catalogo
from public.recepcion_items i
join public.recepciones r on r.id = i.recepcion_id
left join public.productos p on p.id = i.producto_id
where r.folio = {sql_str(FOLIO)} and coalesce(r.proveedor, '') ilike '%nadro%'
order by i.id;

select
  p.sku,
  p.codigo_barras as ean,
  left(p.nombre, 40) as nombre,
  p.marca,
  p.presentacion,
  p.costo,
  p.precio,
  p.stock,
  left(coalesce(p.imagen_url, ''), 56) as foto
from public.productos p
where p.codigo_barras in (
  {eans_sql}
)
order by p.nombre;
"""
    path.write_text(body, encoding="utf-8")


if __name__ == "__main__":
    r = rows()
    a = altas()
    skus = [x["sku"] for x in a]
    assert len(skus) == len(set(skus)), skus
    assert len(RAW) == 7, len(RAW)
    suma = sum(x["sub"] for x in r)
    assert abs(suma - TOTAL_TICKET) < 0.02, (suma, TOTAL_TICKET)
    assert sum(x["qty"] for x in r) == 25
    for x in a:
        foto = ROOT / "public" / x["foto_file"]
        assert foto.exists() and foto.stat().st_size > 2000, x["foto_file"]

    write_ticket_csv(OUT_TICKET, folio=FOLIO, fecha=FECHA, proveedor=PROVEEDOR, total=TOTAL_TICKET, rows=r)
    write_unified_sql(OUT_SQL, a)
    print(f"csv   {OUT_TICKET}")
    print(f"sql   {OUT_SQL}")
    print(report(r, TOTAL_TICKET))
    print("altas", sum(1 for x in a if x["alta_nueva"]))
    for x in a:
        print(f"  {x['sku']}  {x['ean']}  ${x['costo']:.2f} → ${x['precio']}  {x['nombre']}")
