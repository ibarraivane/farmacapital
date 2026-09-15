#!/usr/bin/env python3
# NO pegar este archivo en Supabase. Genera el SQL; el que se corre es:
#   sql/patch_carga_cityfarma_s322819.sql
"""Ticket Cityfarma S322819 (14-sep-2026) → catálogo + cola Recibir.

Mismo cliente / misma visita que S322817. Ticket térmico Central de Abastos.
Orden 2026-09-14 17:30:15 · pendiente de pago $738.06 (suma de renglones).
Lotes impresos (BT1ALD1, AX4250) NO se cargan: MMAA/lote salen de la caja al escanear.

Flanax y Lomotil ya estaban en catálogo (FC-08499412 / FC-002663).
"""
from __future__ import annotations

import math
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from generar_recepcion_borrador import report, write_ticket_csv

ROOT = Path(__file__).resolve().parents[1]
OUT_TICKET = ROOT / "sql" / "generated" / "ticket_cityfarma_s322819.csv"
OUT_SQL = ROOT / "sql" / "patch_carga_cityfarma_s322819.sql"

FOLIO = "S322819"
PROVEEDOR = "Cityfarma Iztapalapa"
FECHA = "2026-09-14"
TOTAL_TICKET = 738.06  # pendiente de pago = suma renglones (ticket imprime Total $0.00)
FOTO_BASE = "https://www.farmacapital.mx/catalogo-propia"


def ceil_pvp(costo: float, factor: float = 1.6) -> int:
    return int(math.ceil(costo * factor))


def sku_de(ean: str) -> str:
    return "FC-" + ean[-8:]


def sql_str(s: str | None) -> str:
    if s is None:
        return "null"
    return "'" + str(s).replace("'", "''") + "'"


ROWS = [
    {
        "ean": "7501008499412",
        "sku": "FC-08499412",
        "snap": "FLANAXPRO 660MG C8 T",
        "nombre": "Flanax 660 mg liberación prolongada C/8 tabletas",
        "qty": 2,
        "pu": 225.16,
        "sub": 450.32,
        "tipo": "marca",
        "categoria": "Analgésico",
        "subcategoria": None,
        "forma": "Tableta de liberación prolongada",
        "marca": "Flanax",
        "laboratorio": "BAYER",
        "presentacion": "Caja con 8 tabletas",
        "principio": "Naproxeno sódico",
        "concentracion": "660 mg",
        "receta": False,
        "ya": True,
        "foto": f"{FOTO_BASE}/flanax-660mg-8tab-7501008499412.jpg",
        "foto_file": "catalogo-propia/flanax-660mg-8tab-7501008499412.jpg",
    },
    {
        "ean": "7501057002663",
        "sku": "FC-002663",
        "snap": "LOMOTIL 2 MG C 8 TAB",
        "nombre": "Lomotil loperamida 2 mg C/8 tabletas",
        "qty": 2,
        "pu": 143.87,
        "sub": 287.74,
        "tipo": "marca",
        "categoria": "Gastro",
        "subcategoria": "Antidiarreico",
        "forma": "Tableta",
        "marca": "Lomotil",
        "laboratorio": "JANSSEN",
        "presentacion": "Caja con 8 tabletas",
        "principio": "Loperamida",
        "concentracion": "2 mg",
        "receta": False,
        "ya": True,
        "foto": f"{FOTO_BASE}/lomotil-2mg-8tab-7501057002663.jpg",
        "foto_file": "catalogo-propia/lomotil-2mg-8tab-7501057002663.jpg",
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
            "{receta}, {imagen})".format(
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
                imagen=sql_str(r["foto"]),
            )
        )

    eans = [sql_str(r["ean"]) for r in ROWS]
    body = f"""-- =============================================================================
-- ESTE es el archivo para Supabase (SQL). NO pegues scripts/generar_carga_*.py
-- Archivo: sql/patch_carga_cityfarma_s322819.sql
-- Pegar TODO abajo en Supabase → SQL Editor → Run.
-- =============================================================================
-- Cityfarma Iztapalapa · orden {FOLIO} · {FECHA} 17:30
-- Ticket térmico Central de Abastos. P.U. ya trae IVA.
-- Total $0.00 / Pendiente de pago ${TOTAL_TICKET:.2f} → se usa suma de renglones.
-- 2 ya en catálogo (Flanax FC-08499412, Lomotil FC-002663). Stock 0 hasta pistola.
-- Lotes del ticket (BT1ALD1, AX4250) NO se cargan: MMAA de la caja.
-- Nombres de ficha (Fahorro/Bayer/Janssen), no del ticket (FLANAXPRO…).
-- SIN bloques dollar-quote. Idempotente mientras el ticket siga en borrador.

begin;

create temp table _fc_cf_s322819 (
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
  imagen text
) on commit drop;

insert into _fc_cf_s322819 (
  linea, ean, sku, nombre, snap, qty, costo, precio, tipo, categoria,
  subcategoria, forma, marca, laboratorio, presentacion, principio_activo,
  concentracion, receta, imagen
) values
{chr(10).join(v + ("," if i < len(vals) - 1 else ";") for i, v in enumerate(vals))}

insert into public.productos (
  nombre, sku, codigo_barras, categoria, tipo, descripcion,
  costo, precio, stock, stock_minimo, activo, requiere_receta
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
  t.tipo,
  'Alta Cityfarma {FOLIO} · {FECHA} · listo para pistola',
  t.costo,
  t.precio,
  0,
  1,
  true,
  t.receta
from _fc_cf_s322819 t
where public.fc_buscar_producto_escaneo(t.ean) is null;

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
from _fc_cf_s322819 t
where p.id = public.fc_buscar_producto_escaneo(t.ean)
  and (
    coalesce(p.costo, 0) <= 0
    or t.costo < p.costo
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
  forma_farmaceutica = coalesce(nullif(trim(p.forma_farmaceutica), ''), t.forma),
  imagen_url = coalesce(nullif(trim(p.imagen_url), ''), t.imagen),
  imagen_mobile_url = coalesce(nullif(trim(p.imagen_mobile_url), ''), t.imagen)
from _fc_cf_s322819 t
where p.id = public.fc_buscar_producto_escaneo(t.ean);

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
  proveedor = {sql_str(PROVEEDOR)},
  estado = 'borrador',
  notas = {sql_str(f"Ticket Cityfarma {FOLIO} · {FECHA} · cola Recibir; stock al confirmar pistola")}
where folio = {sql_str(FOLIO)}
  and coalesce(proveedor, '') ilike '%cityfarma%'
  and estado in ('borrador', 'pendiente_alta', 'pendiente_caducidad');

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
from _fc_cf_s322819 t
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
  (producto_id, url, posicion, es_principal, origen)
select
  p.id,
  t.imagen,
  coalesce((
    select max(i.posicion) from public.producto_imagenes i
    where i.producto_id = p.id
  ), 0) + 1,
  not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id and i.es_principal
  ),
  'propia'
from _fc_cf_s322819 t
join public.productos p on p.id = public.fc_buscar_producto_escaneo(t.ean)
where t.imagen is not null
  and not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id and i.url = t.imagen
  );

commit;

select
  r.id, r.proveedor, r.folio, r.estado, r.total_ticket,
  (select count(*) from public.recepcion_items i where i.recepcion_id = r.id) as renglones
from public.recepciones r
where r.folio = {sql_str(FOLIO)}
order by r.id desc;

select
  i.codigo_escaneado as ean,
  left(i.nombre_snapshot, 52) as nombre,
  i.cantidad,
  i.costo_estimado,
  case when i.pendiente_alta then 'ALTA NUEVA' else 'EN CATALOGO' end as estado
from public.recepcion_items i
join public.recepciones r on r.id = i.recepcion_id
where r.folio = {sql_str(FOLIO)} and coalesce(r.proveedor, '') ilike '%cityfarma%'
order by i.id;

select
  p.sku, p.codigo_barras as ean, left(p.nombre, 52) as nombre,
  p.marca, p.costo, p.precio, p.stock, left(coalesce(p.imagen_url, ''), 56) as foto
from public.productos p
where p.codigo_barras in (
{chr(10).join("  " + e + ("," if i < len(eans) - 1 else "") for i, e in enumerate(eans))}
)
order by p.nombre;
"""
    path.write_text(body, encoding="utf-8")


if __name__ == "__main__":
    r = ticket_rows()
    assert len(ROWS) == 2
    suma = sum(x["sub"] for x in ROWS)
    assert abs(suma - TOTAL_TICKET) < 0.02, (suma, TOTAL_TICKET)
    for x in ROWS:
        assert abs(x["pu"] * x["qty"] - x["sub"]) < 0.02, x
        assert "FLANAXPRO" not in x["nombre"].upper()
        assert "Flanax" in x["nombre"] or "Lomotil" in x["nombre"]

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
    for x in ROWS:
        print(f"  {x['ean']}  {x['qty']}×{x['pu']:.2f}  {x['nombre']}")
