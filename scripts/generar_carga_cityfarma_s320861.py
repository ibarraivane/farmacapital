#!/usr/bin/env python3
"""Ticket Cityfarma S320861 (04-sep-2026) → catálogo + cola Recibir.

Nombres de mostrador salen de ficha (Gelpharma, Higia, YZA/P&G, Tylenol, Fahorro),
no del renglón del ticket. Sin lote ni MMAA: salen de la caja al escanear.
Nadro no tiene estos EAN. Cityfarma no publica PDP.
"""
from __future__ import annotations

import math
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from generar_recepcion_borrador import report, write_ticket_csv

ROOT = Path(__file__).resolve().parents[1]
OUT_TICKET = ROOT / "sql" / "generated" / "ticket_cityfarma_s320861.csv"
OUT_SQL = ROOT / "sql" / "patch_carga_cityfarma_s320861.sql"

FOLIO = "S320861"
PROVEEDOR = "Cityfarma Iztapalapa"
FECHA = "2026-09-04"
TOTAL_TICKET = 1383.55
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
# Carticap For C/60 — Gelpharma / Medicar EAN 7502227426067 (ficha C/30 de gelpharma.com es otra)
# Estomaquil Exper3 240 ml — Higia + Farmapronto/Fahorro EAN
# Neo-Melubrina jarabe 100 ml — Opella/Sanofi, ya en catálogo FC-50003151
# Oral-B Gingivitis 350 ml — YZA/P&G EAN 7501086453221
# Tylenol C/10 — ya en catálogo FC-75354321 (Kenvue)
# Tylenol C/20 — tylenol.com.mx + Fahorro EAN 7501100088095
ROWS = [
    {
        "ean": "7502227426067",
        "sku": sku_de("7502227426067"),
        "snap": "CARTICAP FOR C60 CAP",
        "nombre": "Carticap For glucosamina/condroitina C/60",
        "qty": 4,
        "pu": 77.58,
        "sub": 310.32,
        "tipo": "marca",
        "categoria": "Vitaminas",
        "subcategoria": "Articulaciones",
        "forma": "Cápsulas",
        "marca": "Carticap",
        "laboratorio": "GELPHARMA",
        "presentacion": "Caja con 60 cápsulas",
        "principio": "Glucosamina + condroitina + vitamina C + manganeso",
        "concentracion": "300/200/30/20 mg",
        "receta": False,
        "ya": False,
        "foto": f"{FOTO_BASE}/carticap-for-c60.jpg",
        "foto_file": "catalogo-propia/carticap-for-c60.jpg",
    },
    {
        "ean": "7501369200108",
        "sku": sku_de("7501369200108"),
        "snap": "ESTOMAQUIL EXPER3 SU",
        "nombre": "Estomaquil Exper3 suspensión 240 ml",
        "qty": 2,
        "pu": 84.34,
        "sub": 168.68,
        "tipo": "marca",
        "categoria": "Gastro",
        "subcategoria": "Antiácido",
        "forma": "Suspensión",
        "marca": "Estomaquil",
        "laboratorio": "LAB HIGIA",
        "presentacion": "Frasco 240 ml",
        "principio": "Carbonato de calcio + hidróxido de magnesio + subsalicilato de bismuto",
        "concentracion": "2.67/1.67/1 g/100 ml",
        "receta": False,
        "ya": False,
        "foto": f"{FOTO_BASE}/estomaquil-exper3-240ml.jpg",
        "foto_file": "catalogo-propia/estomaquil-exper3-240ml.jpg",
    },
    {
        "ean": "7501165000315",
        "sku": "FC-50003151",
        "snap": "NEO MELUBRINA JBE",
        "nombre": "Neo-Melubrina jarabe infantil 250 mg/5 ml 100 ml",
        "qty": 2,
        "pu": 110.86,
        "sub": 221.72,
        "tipo": "marca",
        "categoria": "Analgésico",
        "subcategoria": None,
        "forma": "Jarabe",
        "marca": "Neo-Melubrina",
        "laboratorio": "OPELLA",
        "presentacion": "Frasco 100 ml con pipeta o vaso dosificador",
        "principio": "Metamizol sódico",
        "concentracion": "250 mg/5 ml",
        "receta": False,
        "ya": True,
        "foto": f"{FOTO_BASE}/neo-melubrina-jarabe-100ml.jpg",
        "foto_file": "catalogo-propia/neo-melubrina-jarabe-100ml.jpg",
    },
    {
        "ean": "7501086453221",
        "sku": sku_de("7501086453221"),
        "snap": "ORAL B ENJBUC GINGIV",
        "nombre": "Oral-B enjuague bucal Gingivitis 350 ml",
        "qty": 2,
        "pu": 180.01,
        "sub": 360.02,
        "tipo": "marca",
        "categoria": "Cuidado personal",
        "subcategoria": "Higiene bucal",
        "forma": "Enjuague",
        "marca": "Oral-B",
        "laboratorio": "P&G",
        "presentacion": "Frasco 350 ml",
        "principio": "Clorhexidina",
        "concentracion": "0.12%",
        "receta": False,
        "ya": False,
        "foto": f"{FOTO_BASE}/oral-b-enjuague-gingivitis-350ml.jpg",
        "foto_file": "catalogo-propia/oral-b-enjuague-gingivitis-350ml.jpg",
    },
    {
        "ean": "7501007535432",
        "sku": "FC-75354321",
        "snap": "TYLENOL 500MG C10 PA",
        "nombre": "Tylenol paracetamol 500 mg C/10",
        "qty": 3,
        "pu": 47.49,
        "sub": 142.47,
        "tipo": "marca",
        "categoria": "Analgésico",
        "subcategoria": None,
        "forma": "Tabletas",
        "marca": "Tylenol",
        "laboratorio": "KENVUE",
        "presentacion": "Caja con 10 tabletas",
        "principio": "Paracetamol",
        "concentracion": "500 mg",
        "receta": False,
        "ya": True,
        "foto": None,
        "foto_file": None,
    },
    {
        "ean": "7501100088095",
        "sku": "FC-10008809",
        "snap": "TYLENOL 500MG C20 TA",
        "nombre": "Tylenol paracetamol 500 mg C/20",
        "qty": 2,
        "pu": 90.17,
        "sub": 180.34,
        "tipo": "marca",
        "categoria": "Analgésico",
        "subcategoria": None,
        "forma": "Tabletas",
        "marca": "Tylenol",
        "laboratorio": "KENVUE",
        "presentacion": "Caja con 20 tabletas",
        "principio": "Paracetamol",
        "concentracion": "500 mg",
        "receta": False,
        "ya": False,
        "foto": f"{FOTO_BASE}/tylenol-500mg-c20.jpg",
        "foto_file": "catalogo-propia/tylenol-500mg-c20.jpg",
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
    body = f"""-- Cityfarma Iztapalapa · orden {FOLIO} · {FECHA} 16:50
-- Ticket térmico Central de Abastos. P.U. ya trae IVA (suma renglones = ${TOTAL_TICKET:.2f}).
-- El ticket imprime Total $0.00; se usa la suma de renglones (igual que 6315912).
-- 4 altas stock 0. 2 ya estaban (Neo-Melubrina, Tylenol C/10): solo costo, no PVP.
-- Tylenol C/10 se renombra si quedó como 'Tylenol' para no confundirlo con el C/20.
-- Neo-Melubrina: si la forma dice Inyectable, se corrige a Jarabe.
-- Sin lote ni caducidad (MMAA de la caja). No inventar 0000.
-- Nombres de ficha, no del ticket. Fotos en public/catalogo-propia/ (tras deploy).
-- SIN bloques dollar-quote. Idempotente mientras el ticket siga en borrador.
-- Pegar TODO este archivo en Supabase → SQL Editor → Run.

begin;

create temp table _fc_cf_s320861 (
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

insert into _fc_cf_s320861 (
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
from _fc_cf_s320861 t
where public.fc_buscar_producto_escaneo(t.ean) is null;

-- Ya existían: costo. PVP solo si estaba en 0.
update public.productos p
set
  costo = t.costo,
  precio = case
    when coalesce(p.precio, 0) <= 0 then t.precio
    else p.precio
  end
from _fc_cf_s320861 t
where p.id = public.fc_buscar_producto_escaneo(t.ean)
  and (
    p.costo is distinct from t.costo
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
from _fc_cf_s320861 t
where p.id = public.fc_buscar_producto_escaneo(t.ean);

-- Tylenol C/10: el nombre corto choca con el C/20 nuevo.
update public.productos p
set nombre = t.nombre,
    presentacion = t.presentacion,
    forma_farmaceutica = t.forma,
    categoria = t.categoria
from _fc_cf_s320861 t
where p.id = public.fc_buscar_producto_escaneo(t.ean)
  and t.ean = '7501007535432'
  and (
    p.nombre ~* '^tylenol$'
    or length(trim(p.nombre)) <= 10
  );

-- Neo-Melubrina jarabe mal clasificada como inyectable.
update public.productos p
set forma_farmaceutica = t.forma,
    presentacion = coalesce(nullif(trim(p.presentacion), ''), t.presentacion),
    nombre = case
      when p.nombre ~* 'inyect' then t.nombre
      else p.nombre
    end
from _fc_cf_s320861 t
where p.id = public.fc_buscar_producto_escaneo(t.ean)
  and t.ean = '7501165000315'
  and (
    coalesce(p.forma_farmaceutica, '') ~* 'inyect'
    or p.nombre ~* 'inyect'
  );

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
from _fc_cf_s320861 t
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
from _fc_cf_s320861 t
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
    assert len(ROWS) == 6, len(ROWS)
    suma = sum(x["sub"] for x in ROWS)
    assert abs(suma - TOTAL_TICKET) < 0.02, (suma, TOTAL_TICKET)
    for x in ROWS:
        assert abs(x["pu"] * x["qty"] - x["sub"]) < 0.02, x

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
