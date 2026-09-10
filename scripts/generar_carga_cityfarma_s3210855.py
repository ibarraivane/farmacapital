#!/usr/bin/env python3
"""Ticket Cityfarma S3210855 (06-sep-2026) → catálogo + cola Recibir.

Ticket térmico Central de Abastos, cliente Luis Ángel Palillero.
Orden 2026-09-06 17:07 · impreso 2026-09-08 17:13 · total $1,413.98.

Nombres de mostrador salen de ficha (Bayer, Kenvue, Reckitt, Haleon, Bausch),
no del renglón del ticket. Sin lote ni MMAA: salen de la caja al escanear.
Costo de un SKU que ya existía solo se pisa si este ticket es más barato.
"""
from __future__ import annotations

import math
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from generar_recepcion_borrador import report, write_ticket_csv

ROOT = Path(__file__).resolve().parents[1]
OUT_TICKET = ROOT / "sql" / "generated" / "ticket_cityfarma_s3210855.csv"
OUT_SQL = ROOT / "sql" / "patch_carga_cityfarma_s3210855.sql"

FOLIO = "S3210855"
PROVEEDOR = "Cityfarma Iztapalapa"
FECHA = "2026-09-06"
TOTAL_TICKET = 1413.98  # total impreso (suma renglones 1413.74; 24¢ de redondeo IVA)
FOTO_BASE = "https://www.farmacapital.mx/catalogo-propia"


def ceil_pvp(costo: float, factor: float = 1.6) -> int:
    return int(math.ceil(costo * factor))


def sku_de(ean: str) -> str:
    return "FC-" + ean[-8:]


def sql_str(s: str | None) -> str:
    if s is None:
        return "null"
    return "'" + str(s).replace("'", "''") + "'"


# Fichas (no el código del ticket):
# Bedoyecta Tri — ya FC-30133021 / Bausch + Lomb. Ticket $225 (lista Farma City $225).
#   OCR del térmico leyó $25; el total y la lista cierran con $225.00.
# Bepanthen Multiusos 30 g — ya FC-08498798, nombre vivo "Bepanthen Cutanea".
# Microlax C/4 — Kenvue, Farmatodo EAN 7501007532387.
# Sico Sensitive C/9 — Reckitt / Farmatodo EAN 7501058368133.
# Sico Cereza 50 ml — ya FC-87932321. Ticket $96.59 > costo $95.79 → no pisar.
# Sico Rojo Feel C/3 — ya FC-83683367. Ticket $55.74 > costo $54.71 → no pisar.
# Softlube 56.7 g — ya FC-01015141. Ticket $80.82 < costo $94.75 → sí.
# TempraFen 400 mg C/10 — Reckitt, tempra.com.mx. Lista Farma City $60.88; ticket $60.86.
# Tums Extra C/3 — ya FC-65054135, nombre vivo "TUMS". Ticket $39.44 > $37.48 → no pisar.
ROWS = [
    {
        "ean": "7501123013302",
        "sku": "FC-30133021",
        "snap": "BEDOYECTA TRI AMP",
        "nombre": "Bedoyecta Tri ampolleta",
        "qty": 1,
        "pu": 225.00,
        "sub": 225.00,
        "tipo": "marca",
        "categoria": "Vitaminas",
        "subcategoria": None,
        "forma": "Ampolleta",
        "marca": "Bedoyecta",
        "laboratorio": "BAUSCH LOMB MEXICO",
        "presentacion": "Ampolleta inyectable",
        "principio": "Hidroxocobalamina / tiamina / piridoxina",
        "concentracion": None,
        "receta": False,
        "ya": True,
        "foto": None,
        "foto_file": None,
    },
    {
        "ean": "7501008498798",
        "sku": "FC-08498798",
        "snap": "BEPANTHEN 30G MULTI",
        "nombre": "Bepanthen Multiusos pomada 30 g",
        "qty": 2,
        "pu": 64.37,
        "sub": 128.74,
        "tipo": "marca",
        "categoria": "Dermocosmético",
        "subcategoria": "Piel",
        "forma": "Pomada",
        "marca": "Bepanthen",
        "laboratorio": "BAYER OTC",
        "presentacion": "Tubo 30 g",
        "principio": "Dexpantenol",
        "concentracion": None,
        "receta": False,
        "ya": True,
        "foto": None,
        "foto_file": None,
    },
    {
        "ean": "7501007532387",
        "sku": sku_de("7501007532387"),
        "snap": "MICROLAX ENEMAS C4",
        "nombre": "Microlax laxante C/4 microenemas",
        "qty": 1,
        "pu": 179.33,
        "sub": 179.33,
        "tipo": "marca",
        "categoria": "Gastro",
        "subcategoria": "Laxante",
        "forma": "Microenema",
        "marca": "Microlax",
        "laboratorio": "KENVUE",
        "presentacion": "Caja con 4 microenemas de 5 ml",
        "principio": "Citrato de sodio + laurilsulfato de sodio",
        "concentracion": "90 mg / 9 mg/ml",
        "receta": False,
        "ya": False,
        "foto": f"{FOTO_BASE}/microlax-c4-7501007532387.jpg",
        "foto_file": "catalogo-propia/microlax-c4-7501007532387.jpg",
    },
    {
        "ean": "7501058368133",
        "sku": sku_de("7501058368133"),
        "snap": "SICO C9 ROJO SENSITIVE",
        "nombre": "Sico Sensitive condones delgados C/9",
        "qty": 1,
        "pu": 156.62,
        "sub": 156.62,
        "tipo": "marca",
        "categoria": "Cuidado personal",
        "subcategoria": "Salud sexual",
        "forma": "Condón",
        "marca": "Sico",
        "laboratorio": "RB HEALTH",
        "presentacion": "Cartera con 9",
        "principio": "Látex",
        "concentracion": None,
        "receta": False,
        "ya": False,
        "foto": f"{FOTO_BASE}/sico-sensitive-c9-7501058368133.jpg",
        "foto_file": "catalogo-propia/sico-sensitive-c9-7501058368133.jpg",
    },
    {
        "ean": "7501058793232",
        "sku": "FC-87932321",
        "snap": "SICO LUBRIC CEREZA",
        "nombre": "Sico lubricante cereza 50 ml",
        "qty": 3,
        "pu": 96.59,
        "sub": 289.77,
        "tipo": "marca",
        "categoria": "Cuidado personal",
        "subcategoria": "Salud sexual",
        "forma": "Lubricante",
        "marca": "Sico",
        "laboratorio": "RB HEALTH",
        "presentacion": "Frasco 50 ml",
        "principio": None,
        "concentracion": None,
        "receta": False,
        "ya": True,
        "foto": None,
        "foto_file": None,
    },
    {
        "ean": "7501058368126",
        "sku": "FC-83683367",
        "snap": "SICO ROJO SENS C3",
        "nombre": "Sico Rojo Feel condones C/3",
        "qty": 2,
        "pu": 55.74,
        "sub": 111.48,
        "tipo": "marca",
        "categoria": "Cuidado personal",
        "subcategoria": "Salud sexual",
        "forma": "Condón",
        "marca": "Sico",
        "laboratorio": "RB HEALTH",
        "presentacion": "Cartera con 3",
        "principio": "Látex",
        "concentracion": None,
        "receta": False,
        "ya": True,
        "foto": None,
        "foto_file": None,
    },
    {
        "ean": "7506460101514",
        "sku": "FC-01015141",
        "snap": "SICO SOFTLUBE GEL",
        "nombre": "Sico Softlube gel lubricante original 56.7 g",
        "qty": 2,
        "pu": 80.82,
        "sub": 161.64,
        "tipo": "marca",
        "categoria": "Cuidado personal",
        "subcategoria": "Salud sexual",
        "forma": "Lubricante",
        "marca": "Sico",
        "laboratorio": "RB HEALTH",
        "presentacion": "Tubo 56.7 g",
        "principio": None,
        "concentracion": None,
        "receta": False,
        "ya": True,
        "foto": None,
        "foto_file": None,
    },
    {
        "ean": "7506460101002",
        "sku": sku_de("7506460101002"),
        "snap": "TEMPRA FEN 400MG C10",
        "nombre": "TempraFen ibuprofeno 400 mg C/10",
        "qty": 2,
        "pu": 60.86,
        "sub": 121.72,
        "tipo": "marca",
        "categoria": "Analgésico",
        "subcategoria": None,
        "forma": "Cápsulas",
        "marca": "TempraFen",
        "laboratorio": "RB HEALTH",
        "presentacion": "Caja con 10 cápsulas",
        "principio": "Ibuprofeno",
        "concentracion": "400 mg",
        "receta": False,
        "ya": False,
        "foto": f"{FOTO_BASE}/tempra-fen-400mg-c10-7506460101002.jpg",
        "foto_file": "catalogo-propia/tempra-fen-400mg-c10-7506460101002.jpg",
    },
    {
        "ean": "7501065054043",
        "sku": "FC-65054135",
        "snap": "TUMS SURT C3",
        "nombre": "Tums Extra surtido 750 mg C/3 (3 rollos × 8)",
        "qty": 1,
        "pu": 39.44,
        "sub": 39.44,
        "tipo": "marca",
        "categoria": "Gastro",
        "subcategoria": "Antiácido",
        "forma": "Tableta masticable",
        "marca": "Tums",
        "laboratorio": "HALEON",
        "presentacion": "3 rollos × 8 tabletas",
        "principio": "Carbonato de calcio",
        "concentracion": "750 mg",
        "receta": False,
        "ya": True,
        "foto": None,
        "foto_file": None,
    },
]


def ticket_rows() -> list:
    out = []
    for r in ROWS:
        out.append({
            "nombre": r["snap"],
            "qty": r["qty"],
            "sub": r["sub"],
            "pu": r["pu"],
            "ean": r["ean"],
            "sku": r["sku"],
            "match": "catalogo" if r["ya"] else "alta",
        })
    return out


def write_sql(path: Path) -> None:
    vals = []
    for i, r in enumerate(ROWS):
        precio = ceil_pvp(r["pu"])
        vals.append(
            "  ({linea}, {ean}, {sku}, {nombre}, {snap}, {qty}, {costo}, {precio}, "
            "{tipo}, {cat}, {subcat}, {forma}, {marca}, {lab}, {pres}, {pa}, {conc}, "
            "{receta}, {ya}, {foto}, {foto_file})".format(
                linea=i + 1,
                ean=sql_str(r["ean"]),
                sku=sql_str(r["sku"]),
                nombre=sql_str(r["nombre"]),
                snap=sql_str(r["snap"]),
                qty=int(r["qty"]),
                costo=f"{r['pu']:.2f}",
                precio=precio,
                tipo=sql_str(r["tipo"]),
                cat=sql_str(r["categoria"]),
                subcat=sql_str(r["subcategoria"]),
                forma=sql_str(r["forma"]),
                marca=sql_str(r["marca"]),
                lab=sql_str(r["laboratorio"]),
                pres=sql_str(r["presentacion"]),
                pa=sql_str(r["principio"]),
                conc=sql_str(r["concentracion"]),
                receta="true" if r["receta"] else "false",
                ya="true" if r["ya"] else "false",
                foto=sql_str(r["foto"]),
                foto_file=sql_str(r["foto_file"]),
            )
        )

    eans = [sql_str(r["ean"]) for r in ROWS]
    body = f"""-- Cityfarma Iztapalapa · orden {FOLIO} · {FECHA} 17:07 (impreso 2026-09-08 17:13)
-- Ticket térmico Central de Abastos. P.U. ya trae IVA.
-- Total impreso ${TOTAL_TICKET:.2f}. Suma de 9 renglones $1413.74 (24¢ de redondeo).
-- 3 altas stock 0: Microlax C/4, Sico Sensitive C/9, TempraFen 400 mg C/10.
-- 6 ya estaban. Costo solo si este ticket es más barato (o no había).
--   Baja: Bedoyecta 273.42→225.00 · Bepanthen 131.81→64.37 · Softlube 94.75→80.82
--   No pisa: Sico Cereza 95.79 / Sico Rojo 54.71 / Tums 37.48
-- Tums se renombra (estaba 'TUMS') para no confundirlo con el C/48.
-- Bepanthen se renombra si quedó como 'Bepanthen Cutanea'.
-- Softlube: nombre cortado + quita 'Latex' (es gel, no condón).
-- Sin lote ni caducidad (MMAA de la caja). No inventar 0000.
-- Nombres de ficha, no del ticket. Fotos nuevas en public/catalogo-propia/ (tras deploy).
-- SIN bloques dollar-quote. Idempotente mientras el ticket siga en borrador.
-- Pegar TODO este archivo en Supabase → SQL Editor → Run.

begin;

create temp table _fc_cf_s3210855 (
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

insert into _fc_cf_s3210855 (
  linea, ean, sku, nombre, snap, qty, costo, precio, tipo, categoria,
  subcategoria, forma, marca, laboratorio, presentacion, principio_activo,
  concentracion, receta, ya, imagen, foto_file
) values
{chr(10).join(v + ("," if i < len(vals) - 1 else ";") for i, v in enumerate(vals))}

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
from _fc_cf_s3210855 t
where public.fc_buscar_producto_escaneo(t.ean) is null;

-- Ya existían: costo solo si el ticket es más barato (o no había). PVP solo si está en 0.
update public.productos p
set
  costo = case
    when coalesce(p.costo, 0) <= 0 then t.costo
    when t.costo < p.costo then t.costo
    else p.costo
  end,
  precio = case
    when coalesce(p.precio, 0) <= 0 then t.precio
    else p.precio
  end
from _fc_cf_s3210855 t
where p.id = public.fc_buscar_producto_escaneo(t.ean)
  and (
    coalesce(p.costo, 0) <= 0
    or t.costo < p.costo
    or coalesce(p.precio, 0) <= 0
  );

-- Ficha vacía / foto si falta. No pisa una foto que ya esté.
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
from _fc_cf_s3210855 t
where p.id = public.fc_buscar_producto_escaneo(t.ean);

-- Tums C/3: el nombre corto choca con el C/48 y no dice la presentación.
update public.productos p
set nombre = t.nombre,
    marca = t.marca,
    presentacion = t.presentacion,
    forma_farmaceutica = t.forma,
    categoria = t.categoria,
    subcategoria = coalesce(nullif(trim(p.subcategoria), ''), t.subcategoria),
    concentracion = coalesce(nullif(trim(p.concentracion), ''), t.concentracion),
    laboratorio = coalesce(nullif(trim(p.laboratorio), ''), t.laboratorio)
from _fc_cf_s3210855 t
where p.id = public.fc_buscar_producto_escaneo(t.ean)
  and t.ean = '7501065054043'
  and (
    p.nombre ~* '^tums$'
    or length(trim(p.nombre)) <= 8
    or coalesce(p.presentacion, '') ~* '^8 tabletas$'
  );

-- Bepanthen 30 g: 'Cutanea' no es el nombre de mostrador.
update public.productos p
set nombre = t.nombre,
    presentacion = t.presentacion,
    forma_farmaceutica = coalesce(nullif(trim(p.forma_farmaceutica), ''), t.forma),
    categoria = case
      when coalesce(p.categoria, '') ~* '^(otro|general)$' then t.categoria
      else p.categoria
    end,
    subcategoria = coalesce(nullif(trim(p.subcategoria), ''), t.subcategoria)
from _fc_cf_s3210855 t
where p.id = public.fc_buscar_producto_escaneo(t.ean)
  and t.ean = '7501008498798'
  and (
    p.nombre ~* 'cutanea'
    or length(trim(p.nombre)) <= 20
  );

-- Softlube: nombre cortado 'Origin'. El principio 'Latex' es del condón, no del gel.
update public.productos p
set nombre = t.nombre,
    presentacion = t.presentacion,
    forma_farmaceutica = coalesce(nullif(trim(p.forma_farmaceutica), ''), t.forma),
    principio_activo = case
      when coalesce(p.principio_activo, '') ~* 'latex' then null
      else p.principio_activo
    end,
    categoria = case
      when coalesce(p.categoria, '') ~* '^(otro|general)$' then t.categoria
      else p.categoria
    end,
    subcategoria = coalesce(nullif(trim(p.subcategoria), ''), t.subcategoria)
from _fc_cf_s3210855 t
where p.id = public.fc_buscar_producto_escaneo(t.ean)
  and t.ean = '7506460101514';

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  {sql_str(PROVEEDOR)},
  {sql_str(FOLIO)},
  {sql_str(FECHA)},
  {TOTAL_TICKET:.2f},
  'borrador',
  {sql_str(f"Ticket Cityfarma {FOLIO} · {FECHA} · cola Recibir; stock al confirmar pistola")}
where not exists (
  select 1 from public.recepciones
  where folio = {sql_str(FOLIO)} and coalesce(proveedor, '') ilike '%cityfarma%'
);

update public.recepciones
set
  total_ticket = {TOTAL_TICKET:.2f},
  fecha = {sql_str(FECHA)},
  proveedor = {sql_str(PROVEEDOR)}
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
from _fc_cf_s3210855 t
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
  ), 0) + 1,
  not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id and i.es_principal
  ),
  'propia'
from _fc_cf_s3210855 t
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
  left(i.nombre_snapshot, 52) as nombre,
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
  left(p.nombre, 52) as nombre,
  p.marca,
  p.presentacion,
  p.costo,
  p.precio,
  p.stock,
  left(coalesce(p.imagen_url, ''), 56) as foto
from public.productos p
where p.codigo_barras in (
{chr(10).join("  " + e + ("," if i < len(eans) - 1 else "") for i, e in enumerate(eans))}
)
order by p.nombre;
"""
    path.write_text(body, encoding="utf-8")


if __name__ == "__main__":
    r = ticket_rows()
    skus = [x["sku"] for x in ROWS]
    assert len(skus) == len(set(skus)), skus
    assert len(ROWS) == 9, len(ROWS)
    suma = sum(x["sub"] for x in ROWS)
    assert abs(suma - 1413.74) < 0.02, (suma, 1413.74)
    assert abs(TOTAL_TICKET - 1413.98) < 0.02, TOTAL_TICKET
    assert sum(x["qty"] for x in ROWS) == 15
    for x in ROWS:
        assert abs(x["pu"] * x["qty"] - x["sub"]) < 0.02, x
    fotos = [ROOT / "public" / x["foto_file"] for x in ROWS if x["foto_file"]]
    for f in fotos:
        assert f.is_file() and f.stat().st_size > 1000, f

    write_ticket_csv(
        OUT_TICKET,
        folio=FOLIO,
        fecha=FECHA,
        proveedor=PROVEEDOR,
        total=TOTAL_TICKET,
        rows=r,
    )
    write_sql(OUT_SQL)
    print(f"csv  {OUT_TICKET}")
    print(f"sql  {OUT_SQL}")
    print(report(r, TOTAL_TICKET))
    print("altas", sum(1 for x in ROWS if not x["ya"]), "ya_catalogo", sum(1 for x in ROWS if x["ya"]))
    for x in ROWS:
        print(
            f"  {x['ean']}  {x['qty']}×{x['pu']:.2f}  "
            f"{'ya' if x['ya'] else 'ALTA'}  {x['nombre']}"
        )
