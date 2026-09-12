#!/usr/bin/env python3
"""Ticket El Surtidor 126922 (08-sep-2026) → catálogo + cola Recibir.

Luis · Central de Abastos F48 · Alfredo Murillo Guzmán.
7 SKU ya venían del ticket 112558 (solo costo). 2 altas: Aspirina Protect y Saba Largo 16.
EAN Saba del ticket salió truncado (750101906116); se usa ficha YZA 7501019068713 (Largo 16).
Nombres de mostrador desde ficha, no del renglón. Sin lote ni MMAA.
"""
from __future__ import annotations

import math
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from generar_recepcion_borrador import report, write_ticket_csv

ROOT = Path(__file__).resolve().parents[1]
OUT_TICKET = ROOT / "sql" / "generated" / "ticket_surtidor_126922.csv"
OUT_SQL = ROOT / "sql" / "patch_carga_surtidor_126922.sql"

FOLIO = "126922"
PROVEEDOR = "El Surtidor"
FECHA = "2026-09-08"
TOTAL_TICKET = 474.59
FOTO_BASE = "https://www.farmacapital.mx/catalogo-propia"


def ceil_pvp(costo: float, factor: float = 1.5) -> int:
    util_min = 5 if costo < 20 else (8 if costo < 50 else 0)
    return int(math.ceil(max(costo * factor, costo + util_min)))


def sku_de(ean: str) -> str:
    return "FC-" + ean[-8:]


def sql_str(s: str | None) -> str:
    if s is None:
        return "null"
    return "'" + str(s).replace("'", "''") + "'"


# Costo unitario = total_linea / qty (Aspirina ya con 33.5% desc → 134.99).
ROWS = [
    {
        "ean": "7501318612655",
        "sku": sku_de("7501318612655"),
        "snap": "ASPIRINA PROTEC TAB C/28 100MG",
        "nombre": "Aspirina Protect 100 mg C/28",
        "qty": 1,
        "pu": 134.99,
        "sub": 134.99,
        "tipo": "marca",
        "categoria": "Analgésico",
        "subcategoria": "Antiagregante",
        "forma": "Tabletas",
        "marca": "Aspirina",
        "laboratorio": "BAYER",
        "presentacion": "Caja con 28 tabletas de liberación retardada",
        "principio": "Ácido acetilsalicílico",
        "concentracion": "100 mg",
        "receta": False,
        "ya": False,
        "foto": f"{FOTO_BASE}/aspirina-protect-100mg-28.jpg",
        "foto_file": "catalogo-propia/aspirina-protect-100mg-28.jpg",
    },
    {
        "ean": "7501868901131",
        "sku": "FC-68901131",
        "snap": "DIBAR ALCOHOL AZUL 1LT",
        "nombre": "Alcohol etílico Dibar azul 71.6° 1 L",
        "qty": 2,
        "pu": 41.00,
        "sub": 82.00,
        "tipo": "marca",
        "categoria": "Botiquín",
        "subcategoria": "Alcohol",
        "forma": "Alcohol etílico",
        "marca": "Dibar",
        "laboratorio": "DIBAR",
        "presentacion": "Frasco 1 L",
        "principio": "Alcohol etílico",
        "concentracion": "71.6°",
        "receta": False,
        "ya": True,
        "foto": None,
        "foto_file": None,
    },
    {
        "ean": "7501868901117",
        "sku": "FC-68901117",
        "snap": "DIBAR ALCOHOL AZUL 250ML",
        "nombre": "Alcohol etílico Dibar azul 71.6° 250 ml",
        "qty": 2,
        "pu": 11.30,
        "sub": 22.60,
        "tipo": "marca",
        "categoria": "Botiquín",
        "subcategoria": "Alcohol",
        "forma": "Alcohol etílico",
        "marca": "Dibar",
        "laboratorio": "DIBAR",
        "presentacion": "Frasco 250 ml",
        "principio": "Alcohol etílico",
        "concentracion": "71.6°",
        "receta": False,
        "ya": True,
        "foto": None,
        "foto_file": None,
    },
    {
        "ean": "7501868901124",
        "sku": "FC-68901124",
        "snap": "DIBAR ALCOHOL AZUL 500ML",
        "nombre": "Alcohol etílico Dibar azul 71.6° 500 ml",
        "qty": 2,
        "pu": 24.00,
        "sub": 48.00,
        "tipo": "marca",
        "categoria": "Botiquín",
        "subcategoria": "Alcohol",
        "forma": "Alcohol etílico",
        "marca": "Dibar",
        "laboratorio": "DIBAR",
        "presentacion": "Frasco 500 ml",
        "principio": "Alcohol etílico",
        "concentracion": "71.6°",
        "receta": False,
        "ya": True,
        "foto": f"{FOTO_BASE}/dibar-azul-500ml.jpg",
        "foto_file": "catalogo-propia/dibar-azul-500ml.jpg",
    },
    {
        "ean": "7501033950100",
        "sku": "FC-33950100",
        "snap": "ENSURE LIQ 236ML CHTE",
        "nombre": "Ensure líquido 236 ml chocolate",
        "qty": 1,
        "pu": 42.00,
        "sub": 42.00,
        "tipo": "marca",
        "categoria": "Suplemento",
        "subcategoria": "Líquido",
        "forma": "Líquido",
        "marca": "Ensure",
        "laboratorio": "ABBOTT",
        "presentacion": "Tetra 236 ml",
        "principio": "Suplemento nutricional",
        "concentracion": None,
        "receta": False,
        "ya": True,
        "foto": None,
        "foto_file": None,
    },
    {
        "ean": "7501033950063",
        "sku": "FC-33950063",
        "snap": "ENSURE LIQ 236ML FSA",
        "nombre": "Ensure líquido 236 ml fresa",
        "qty": 1,
        "pu": 42.00,
        "sub": 42.00,
        "tipo": "marca",
        "categoria": "Suplemento",
        "subcategoria": "Líquido",
        "forma": "Líquido",
        "marca": "Ensure",
        "laboratorio": "ABBOTT",
        "presentacion": "Tetra 236 ml",
        "principio": "Suplemento nutricional",
        "concentracion": None,
        "receta": False,
        "ya": True,
        "foto": None,
        "foto_file": None,
    },
    {
        "ean": "7501033951008",
        "sku": "FC-33951008",
        "snap": "PEDIASURE LIQ 236ML CHTE",
        "nombre": "Pediasure líquido 236 ml chocolate",
        "qty": 1,
        "pu": 44.00,
        "sub": 44.00,
        "tipo": "marca",
        "categoria": "Suplemento",
        "subcategoria": "Líquido",
        "forma": "Líquido",
        "marca": "Pediasure",
        "laboratorio": "ABBOTT",
        "presentacion": "Tetra 236 ml",
        "principio": "Suplemento nutricional",
        "concentracion": None,
        "receta": False,
        "ya": True,
        "foto": None,
        "foto_file": None,
    },
    {
        "ean": "7501033950209",
        "sku": "FC-33950209",
        "snap": "PEDIASURE LIQ 236ML VNLLA",
        "nombre": "Pediasure líquido 236 ml vainilla",
        "qty": 1,
        "pu": 44.00,
        "sub": 44.00,
        "tipo": "marca",
        "categoria": "Suplemento",
        "subcategoria": "Líquido",
        "forma": "Líquido",
        "marca": "Pediasure",
        "laboratorio": "ABBOTT",
        "presentacion": "Tetra 236 ml",
        "principio": "Suplemento nutricional",
        "concentracion": None,
        "receta": False,
        "ya": True,
        "foto": None,
        "foto_file": None,
    },
    {
        # Ticket OCR: 750101906116 (12 dígitos). Ficha YZA Largo 16: 7501019068713.
        "ean": "7501019068713",
        "sku": sku_de("7501019068713"),
        "snap": "SABA PANTY PROTEC LARGO C/16 CHICO",
        "nombre": "Saba pantiprotectores diarios largo C/16",
        "qty": 1,
        "pu": 15.00,
        "sub": 15.00,
        "tipo": "marca",
        "categoria": "Higiene",
        "subcategoria": "Protectores diarios",
        "forma": "Protectores diarios",
        "marca": "Saba",
        "laboratorio": "ESSITY",
        "presentacion": "Paquete con 16 protectores largos",
        "principio": None,
        "concentracion": None,
        "receta": False,
        "ya": False,
        "foto": f"{FOTO_BASE}/saba-panty-largo-16.jpg",
        "foto_file": "catalogo-propia/saba-panty-largo-16.jpg",
    },
]


def ticket_rows() -> list:
    out = []
    for r in ROWS:
        out.append(
            {
                "nombre": r["snap"],
                "qty": r["qty"],
                "sub": r["sub"],
                "pu": r["pu"],
                "ean": r["ean"],
                "sku": r["sku"],
                "match": "catalogo" if r["ya"] else "alta",
            }
        )
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

    altas = sum(1 for r in ROWS if not r["ya"])
    ya = sum(1 for r in ROWS if r["ya"])
    body = f"""-- El Surtidor · venta {FOLIO} · {FECHA} · Luis · F48 Central de Abastos
-- Ticket térmico Alfredo Murillo Guzmán (El Surtidor de su Farmacia).
-- Total ticket ${TOTAL_TICKET:.2f} (Aspirina con 33.5% desc → costo 134.99).
-- {altas} altas stock 0. {ya} ya estaban (ticket 112558): solo costo, no PVP.
-- Ensure FSA 7501033950063: si quedó como Pediasure, se renombra a Ensure fresa.
-- Saba: OCR del ticket truncó el EAN a 750101906116; ficha YZA Largo 16 = 7501019068713.
-- Sin lote ni caducidad (MMAA de la caja). No inventar 0000.
-- Nombres de ficha, no del ticket. Fotos en public/catalogo-propia/ (tras deploy).
-- SIN bloques dollar-quote. Idempotente mientras el ticket siga en borrador.
-- Pegar TODO este archivo en Supabase → SQL Editor → Run.

begin;

create temp table _fc_sur_126922 (
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

insert into _fc_sur_126922 (
  linea, ean, sku, nombre, snap, qty, costo, precio, tipo, categoria,
  subcategoria, forma, marca, laboratorio, presentacion, principio_activo,
  concentracion, receta, ya, imagen, foto_file
) values
{chr(10).join(v + ("," if i < len(vals) - 1 else ";") for i, v in enumerate(vals))}

-- Alinear EAN del ticket al SKU conocido (evita duplicar Ensure/Dibar del 112558).
update public.productos p
set codigo_barras = t.ean
from _fc_sur_126922 t
where p.sku = t.sku
  and t.ya
  and coalesce(nullif(trim(p.codigo_barras), ''), '') is distinct from t.ean
  and not exists (
    select 1 from public.productos o
    where o.codigo_barras = t.ean and o.id <> p.id
  );

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
    ) then 'FC-SUR-' || right(t.ean, 8)
    else t.sku
  end,
  t.ean,
  t.categoria,
  t.subcategoria,
  t.tipo,
  'Alta El Surtidor {FOLIO} · {FECHA} · listo para pistola',
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
from _fc_sur_126922 t
where public.fc_buscar_producto_escaneo(t.ean) is null
  and public.fc_buscar_producto_escaneo(t.sku) is null;

-- Ya existían: costo. PVP solo si estaba en 0.
update public.productos p
set
  costo = t.costo,
  precio = case
    when coalesce(p.precio, 0) <= 0 then t.precio
    else p.precio
  end
from _fc_sur_126922 t
where p.id = coalesce(
    public.fc_buscar_producto_escaneo(t.ean),
    public.fc_buscar_producto_escaneo(t.sku)
  )
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
from _fc_sur_126922 t
where p.id = coalesce(
    public.fc_buscar_producto_escaneo(t.ean),
    public.fc_buscar_producto_escaneo(t.sku)
  );

-- Ensure FSA: en 112558 el SKU FC-33950063 quedó mal como Pediasure fresa.
update public.productos p
set
  nombre = t.nombre,
  marca = t.marca,
  presentacion = coalesce(nullif(trim(p.presentacion), ''), t.presentacion),
  categoria = t.categoria,
  subcategoria = t.subcategoria
from _fc_sur_126922 t
where p.id = coalesce(
    public.fc_buscar_producto_escaneo(t.ean),
    public.fc_buscar_producto_escaneo(t.sku)
  )
  and t.ean = '7501033950063'
  and (
    p.nombre ~* 'pedia'
    or coalesce(p.marca, '') ~* 'pedia'
  );

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  {sql_str(PROVEEDOR)},
  {sql_str(FOLIO)},
  {sql_str(FECHA)},
  {TOTAL_TICKET:.2f},
  'borrador',
  {sql_str(f"Ticket El Surtidor {FOLIO} · {FECHA} · Luis F48 · cola Recibir; stock al confirmar pistola")}
where not exists (
  select 1 from public.recepciones
  where folio = {sql_str(FOLIO)} and coalesce(proveedor, '') ilike '%surtidor%'
);

update public.recepciones
set
  total_ticket = {TOTAL_TICKET:.2f},
  fecha = {sql_str(FECHA)},
  proveedor = {sql_str(PROVEEDOR)}
where folio = {sql_str(FOLIO)}
  and coalesce(proveedor, '') ilike '%surtidor%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = {sql_str(FOLIO)}
  and coalesce(r.proveedor, '') ilike '%surtidor%'
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
from _fc_sur_126922 t
join public.recepciones r
  on r.folio = {sql_str(FOLIO)}
 and coalesce(r.proveedor, '') ilike '%surtidor%'
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
from _fc_sur_126922 t
join public.productos p on p.id = coalesce(
  public.fc_buscar_producto_escaneo(t.ean),
  public.fc_buscar_producto_escaneo(t.sku)
)
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
where r.folio = {sql_str(FOLIO)} and coalesce(r.proveedor, '') ilike '%surtidor%'
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
{chr(10).join("  " + sql_str(r["ean"]) + ("," if i < len(ROWS) - 1 else "") for i, r in enumerate(ROWS))}
)
order by p.nombre;
"""
    path.write_text(body, encoding="utf-8")


def main() -> None:
    rows = ticket_rows()
    write_ticket_csv(
        OUT_TICKET,
        folio=FOLIO,
        fecha=FECHA,
        proveedor=PROVEEDOR,
        total=TOTAL_TICKET,
        rows=rows,
    )
    write_sql(OUT_SQL)
    print(report(rows, TOTAL_TICKET))
    print(f"CSV {OUT_TICKET.relative_to(ROOT)}")
    print(f"SQL {OUT_SQL.relative_to(ROOT)}")
    for r in ROWS:
        tag = "catalogo" if r["ya"] else "ALTA"
        print(f"  {tag:8} {r['ean']}  x{r['qty']}  ${r['pu']:.2f}  {r['nombre']}")


if __name__ == "__main__":
    main()
