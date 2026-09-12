#!/usr/bin/env python3
"""Cityfarma · orden S322410 (12-sep-2026) → catálogo + cola Recibir.

Fuente: ticket térmico Cityfarma Central de Abastos Iztapalapa.
Cliente LUIS ANGEL PALILLERO VENTURA · vendedor Eduardo Nicanor · 15:21.
Pendiente de pago $1,916.97 (Pagado $0). IVA 0%.
Sin lote ni MMAA en el papel: salen de la caja al escanear.
Nombres de ficha (Sanofi Allegra, AMSA, Pisa Dolac, P&G, Bruluagsa), no del renglón.
"""
from __future__ import annotations

import math
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from generar_recepcion_borrador import report, write_ticket_csv

ROOT = Path(__file__).resolve().parents[1]
OUT_CSV = ROOT / "sql" / "generated" / "ticket_cityfarma_s322410.csv"
OUT_SQL = ROOT / "sql" / "patch_carga_cityfarma_s322410.sql"

FOLIO = "S322410"
PROVEEDOR = "Cityfarma Iztapalapa"
FECHA = "2026-09-12"
TOTAL = 1916.97
FOTO = "https://www.farmacapital.mx/catalogo-propia/{}"


def ceil_pvp(costo: float, factor: float = 1.6) -> int:
    return int(math.ceil(costo * factor))


def sku_de(ean: str) -> str:
    return "FC-" + ean[-8:]


def sql_str(s: str | None) -> str:
    if s is None:
        return "null"
    return "'" + str(s).replace("'", "''") + "'"


# ya=True: solo actualiza costo (Allegra 180 y Sedalmerck ya cargados).
# Allegra marca: margen ~20% (costo cerca de menudeo). Resto ceil 60%.
ROWS = [
    {
        "ean": "7501165001725",
        "sku": "FC-16500172",
        "snap": "ALLEGRA 180 MG C 10",
        "nombre": "Allegra fexofenadina 180 mg C/10",
        "qty": 2,
        "pu": 348.98,
        "sub": 697.96,
        "factor": 1.2,
        "tipo": "marca",
        "categoria": "Alergia",
        "subcategoria": "Antihistamínico",
        "forma": "Tableta",
        "marca": "Allegra",
        "laboratorio": "Sanofi",
        "presentacion": "Caja con 10 tabletas",
        "principio": "Fexofenadina",
        "concentracion": "180 mg",
        "receta": False,
        "ya": True,
        "foto": FOTO.format("allegra-fexofenadina-180-10.jpg"),
        "foto_file": "catalogo-propia/allegra-fexofenadina-180-10.jpg",
    },
    {
        "ean": "7501165006386",
        "sku": sku_de("7501165006386"),
        "snap": "ALLEGRA D 60 25MG C",
        "nombre": "Allegra D fexofenadina/fenilefrina 60/25 mg C/10",
        "qty": 1,
        "pu": 302.23,
        "sub": 302.23,
        "factor": 1.2,
        "tipo": "marca",
        "categoria": "Alergia",
        "subcategoria": "Antihistamínico",
        "forma": "Tableta",
        "marca": "Allegra",
        "laboratorio": "Sanofi",
        "presentacion": "Caja con 10 tabletas",
        "principio": "Fexofenadina + fenilefrina",
        "concentracion": "60/25 mg",
        "receta": False,
        "ya": False,
        "foto": FOTO.format("allegra-d-60-25-10.jpg"),
        "foto_file": "catalogo-propia/allegra-d-60-25-10.jpg",
    },
    {
        "ean": "7501165006171",
        "sku": sku_de("7501165006171"),
        "snap": "ALLEGRA SUSP 150ML",
        "nombre": "Allegra suspensión 6 mg/mL 150 mL",
        "qty": 1,
        "pu": 324.07,
        "sub": 324.07,
        "factor": 1.2,
        "tipo": "marca",
        "categoria": "Alergia",
        "subcategoria": "Antihistamínico",
        "forma": "Suspensión",
        "marca": "Allegra",
        "laboratorio": "Sanofi",
        "presentacion": "Frasco 150 mL",
        "principio": "Fexofenadina",
        "concentracion": "6 mg/mL",
        "receta": False,
        "ya": False,
        "foto": FOTO.format("allegra-suspension-150ml.jpg"),
        "foto_file": "catalogo-propia/allegra-suspension-150ml.jpg",
    },
    {
        "ean": "7501300420824",
        "sku": sku_de("7501300420824"),
        "snap": "DOLAC SUBL C/6 30MG",
        "nombre": "Dolac ketorolaco sublingual 30 mg C/6",
        "qty": 1,
        "pu": 136.28,
        "sub": 136.28,
        "factor": 1.6,
        "tipo": "marca",
        "categoria": "Analgésicos",
        "subcategoria": "Antiinflamatorio",
        "forma": "Tableta sublingual",
        "marca": "Dolac",
        "laboratorio": "Pisa",
        "presentacion": "Caja con 6 tabletas",
        "principio": "Ketorolaco",
        "concentracion": "30 mg",
        "receta": True,
        "ya": False,
        "foto": FOTO.format("dolac-ketorolaco-sublingual-30-6.jpg"),
        "foto_file": "catalogo-propia/dolac-ketorolaco-sublingual-30-6.jpg",
    },
    {
        "ean": "7501349027060",
        "sku": sku_de("7501349027060"),
        "snap": "FEXOFENADINA 120MG C",
        "nombre": "Fexofenadina 120 mg C/10 AMSA",
        "qty": 2,
        "pu": 34.51,
        "sub": 69.02,
        "factor": 1.6,
        "tipo": "generico",
        "categoria": "Alergia",
        "subcategoria": "Antihistamínico",
        "forma": "Tableta",
        "marca": "AMSA",
        "laboratorio": "AMSA",
        "presentacion": "Caja con 10 tabletas",
        "principio": "Fexofenadina",
        "concentracion": "120 mg",
        "receta": False,
        "ya": False,
        "foto": FOTO.format("fexofenadina-120-amsa-10.jpg"),
        "foto_file": "catalogo-propia/fexofenadina-120-amsa-10.jpg",
    },
    {
        "ean": "7501349025059",
        "sku": sku_de("7501349025059"),
        "snap": "FEXOFENADINA 180MG C",
        "nombre": "Fexofenadina 180 mg C/10 AMSA",
        "qty": 2,
        "pu": 47.89,
        "sub": 95.78,
        "factor": 1.6,
        "tipo": "generico",
        "categoria": "Alergia",
        "subcategoria": "Antihistamínico",
        "forma": "Tableta",
        "marca": "AMSA",
        "laboratorio": "AMSA",
        "presentacion": "Caja con 10 tabletas",
        "principio": "Fexofenadina",
        "concentracion": "180 mg",
        "receta": False,
        "ya": False,
        "foto": FOTO.format("fexofenadina-180-amsa-10.png"),
        "foto_file": "catalogo-propia/fexofenadina-180-amsa-10.png",
    },
    {
        "ean": "7500435230445",
        "sku": sku_de("7500435230445"),
        "snap": "NYQUIL Z 25MG 10CAPS",
        "nombre": "NyQuil Z difenhidramina 25 mg C/10",
        "qty": 1,
        "pu": 103.85,
        "sub": 103.85,
        "factor": 1.6,
        "tipo": "marca",
        "categoria": "Respiratorio",
        "subcategoria": "Sueño / resfriado",
        "forma": "Cápsula",
        "marca": "NyQuil",
        "laboratorio": "Procter & Gamble",
        "presentacion": "Caja con 10 cápsulas",
        "principio": "Difenhidramina",
        "concentracion": "25 mg",
        "receta": False,
        "ya": False,
        "foto": FOTO.format("nyquil-z-difenhidramina-25-10.jpg"),
        "foto_file": "catalogo-propia/nyquil-z-difenhidramina-25-10.jpg",
    },
    {
        "ean": "7502208895219",
        "sku": sku_de("7502208895219"),
        "snap": "PORTEM AS PARACETAMO",
        "nombre": "Portem AS paracetamol/cafeína 500/50 mg C/20",
        "qty": 3,
        "pu": 15.26,
        "sub": 45.78,
        "factor": 1.6,
        "tipo": "marca",
        "categoria": "Analgésicos",
        "subcategoria": "Analgésico",
        "forma": "Tableta",
        "marca": "Portem AS",
        "laboratorio": "Bruluagsa",
        "presentacion": "Caja con 20 tabletas",
        "principio": "Paracetamol + cafeína",
        "concentracion": "500/50 mg",
        "receta": False,
        "ya": False,
        "foto": FOTO.format("portem-as-paracetamol-cafeina-500-50-20.jpg"),
        "foto_file": "catalogo-propia/portem-as-paracetamol-cafeina-500-50-20.jpg",
    },
    {
        "ean": "7501298281209",
        "sku": "FC-8281209",
        "snap": "SEDALMERCK C 20 TABS",
        "nombre": "Sedalmerck C/20 tabletas",
        "qty": 2,
        "pu": 71.00,
        "sub": 142.00,
        "factor": 1.6,
        "tipo": "marca",
        "categoria": "Analgésicos",
        "subcategoria": "Analgésico",
        "forma": "Tableta",
        "marca": "Sedalmerck",
        "laboratorio": "P&G Health",
        "presentacion": "Caja con 20 tabletas",
        "principio": "Paracetamol + cafeína + fenilefrina",
        "concentracion": "500/50/5 mg",
        "receta": False,
        "ya": True,
        "foto": FOTO.format("sedalmerck-20.jpg"),
        "foto_file": "catalogo-propia/sedalmerck-20.jpg",
    },
]


def write_sql(path: Path) -> None:
    vals = []
    for i, r in enumerate(ROWS, start=1):
        precio = ceil_pvp(r["pu"], r["factor"])
        vals.append(
            f"  ({i}, {sql_str(r['ean'])}, {sql_str(r['sku'])}, {sql_str(r['nombre'])},\n"
            f"   {sql_str(r['snap'])}, {r['qty']}, {r['pu']:.2f}, {precio},\n"
            f"   {sql_str(r['tipo'])}, {sql_str(r['categoria'])}, {sql_str(r['subcategoria'])},\n"
            f"   {sql_str(r['forma'])}, {sql_str(r['marca'])}, {sql_str(r['laboratorio'])},\n"
            f"   {sql_str(r['presentacion'])}, {sql_str(r['principio'])}, {sql_str(r['concentracion'])},\n"
            f"   {'true' if r['receta'] else 'false'}, {'true' if r['ya'] else 'false'},\n"
            f"   {sql_str(r['foto'])}, {sql_str(r['foto_file'])})"
        )

    body = f"""-- Cityfarma Iztapalapa · orden {FOLIO} · {FECHA} 15:21
-- Ticket térmico Central de Abastos. Pendiente de pago ${TOTAL:.2f} (IVA 0%).
-- P.U. = costo. Sin lote ni caducidad: MMAA de la caja. No inventar 0000.
-- Allegra 180 y Sedalmerck ya estaban: solo costo (+ foto si faltaba).
-- 7 altas stock 0. Nombres de ficha, no del ticket.
-- Fotos en public/catalogo-propia/ (URLs tras deploy).
-- SIN bloques dollar-quote. Idempotente mientras el ticket siga en borrador.
-- Pegar TODO este archivo en Supabase → SQL Editor → Run.

begin;

create temp table _fc_cf_s322410 (
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
  forma text,
  marca text,
  laboratorio text,
  presentacion text,
  principio_activo text,
  concentracion text,
  receta boolean not null,
  ya boolean not null,
  imagen text,
  foto_file text
) on commit drop;

insert into _fc_cf_s322410 (
  linea, ean, sku, nombre, snap, qty, costo, precio, tipo, categoria,
  subcategoria, forma, marca, laboratorio, presentacion, principio_activo,
  concentracion, receta, ya, imagen, foto_file
) values
{",".join(chr(10) + v for v in vals)};

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
    ) then 'FC-CF-' || right(t.ean, 8)
    else t.sku
  end,
  t.ean,
  t.categoria,
  t.subcategoria,
  t.tipo,
  'Alta Cityfarma {FOLIO} · {FECHA} · listo para pistola',
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
from _fc_cf_s322410 t
where public.fc_buscar_producto_escaneo(t.ean) is null;

update public.productos p
set
  costo = t.costo,
  precio = case
    when coalesce(p.precio, 0) <= 0 then t.precio
    else p.precio
  end
from _fc_cf_s322410 t
where p.id = public.fc_buscar_producto_escaneo(t.ean)
  and (
    p.costo is distinct from t.costo
    or coalesce(p.precio, 0) <= 0
  );

update public.productos p
set
  marca = coalesce(nullif(trim(p.marca), ''), t.marca),
  presentacion = coalesce(nullif(trim(p.presentacion), ''), t.presentacion),
  principio_activo = coalesce(nullif(trim(p.principio_activo), ''), t.principio_activo),
  concentracion = coalesce(nullif(trim(p.concentracion), ''), t.concentracion),
  laboratorio = coalesce(nullif(trim(p.laboratorio), ''), t.laboratorio),
  subcategoria = coalesce(nullif(trim(p.subcategoria), ''), t.subcategoria),
  imagen_url = coalesce(nullif(trim(p.imagen_url), ''), t.imagen),
  imagen_mobile_url = coalesce(nullif(trim(p.imagen_mobile_url), ''), t.imagen)
from _fc_cf_s322410 t
where p.id = public.fc_buscar_producto_escaneo(t.ean);

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  {sql_str(PROVEEDOR)},
  {sql_str(FOLIO)},
  {sql_str(FECHA)},
  {TOTAL:.2f},
  'borrador',
  {sql_str(f"Ticket Cityfarma {FOLIO} · {FECHA} 15:21 · pendiente de pago · cola Recibir; stock al confirmar pistola")}
where not exists (
  select 1 from public.recepciones
  where folio = {sql_str(FOLIO)} and coalesce(proveedor, '') ilike '%cityfarma%'
);

update public.recepciones
set
  total_ticket = {TOTAL:.2f},
  fecha = {sql_str(FECHA)},
  proveedor = {sql_str(PROVEEDOR)},
  notas = {sql_str(f"Ticket Cityfarma {FOLIO} · {FECHA} 15:21 · pendiente de pago · cola Recibir; stock al confirmar pistola")},
  updated_at = now()
where folio = {sql_str(FOLIO)}
  and coalesce(proveedor, '') ilike '%cityfarma%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = {sql_str(FOLIO)}
  and coalesce(r.proveedor, '') ilike '%cityfarma%'
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
  t.nombre,
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
from _fc_cf_s322410 t
join public.recepciones r
  on r.folio = {sql_str(FOLIO)}
 and coalesce(r.proveedor, '') ilike '%cityfarma%'
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
  ), -1) + 1,
  not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id and i.es_principal
  ),
  'propia'
from _fc_cf_s322410 t
join public.productos p on p.id = public.fc_buscar_producto_escaneo(t.ean)
where t.imagen is not null
  and not exists (
    select 1 from public.producto_imagenes x
    where x.producto_id = p.id and x.url = t.imagen
  );

commit;

select
  i.id,
  i.codigo_escaneado as ean,
  left(i.nombre_snapshot, 48) as nombre,
  i.cantidad,
  i.costo_estimado,
  case when i.pendiente_alta then 'ALTA NUEVA' else 'YA EXISTE' end as estado
from public.recepcion_items i
join public.recepciones r on r.id = i.recepcion_id
where r.folio = {sql_str(FOLIO)} and coalesce(r.proveedor, '') ilike '%cityfarma%'
order by i.id;

select
  p.sku,
  p.codigo_barras as ean,
  left(p.nombre, 48) as nombre,
  p.costo,
  p.precio,
  p.stock,
  left(coalesce(p.imagen_url, '(sin foto)'), 64) as foto
from public.productos p
where p.codigo_barras in ({", ".join(sql_str(r["ean"]) for r in ROWS)})
order by p.sku;
"""
    path.write_text(body, encoding="utf-8")


def main() -> None:
    data = [
        {
            "nombre": r["nombre"],
            "qty": r["qty"],
            "sub": r["sub"],
            "pu": r["pu"],
            "ean": r["ean"],
            "sku": r["sku"],
            "match": "ya" if r["ya"] else "alta",
        }
        for r in ROWS
    ]
    write_ticket_csv(OUT_CSV, folio=FOLIO, fecha=FECHA, proveedor=PROVEEDOR, total=TOTAL, rows=data)
    write_sql(OUT_SQL)

    suma = sum(r["sub"] for r in data)
    piezas = sum(r["qty"] for r in data)
    print(report(data, TOTAL))
    print(f"piezas={piezas} esperado=15 ok={piezas == 15}")
    print(f"lineas={len(data)} esperado=9 ok={len(data) == 9}")
    print(f"suma=${suma:.2f} total=${TOTAL:.2f} delta={suma - TOTAL:.2f}")
    print(f"csv={OUT_CSV}")
    print(f"sql={OUT_SQL}")
    if piezas != 15 or len(data) != 9 or abs(suma - TOTAL) >= 0.02:
        raise SystemExit("totales no cuadran")


if __name__ == "__main__":
    main()
