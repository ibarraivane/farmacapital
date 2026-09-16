#!/usr/bin/env python3
"""Tickets 15-sep-2026 (fotos térmicas) → altas + cola Recibir.

5 pedidos:
  Cityfarma S322819 (14-sep), S322895, S322903
  Equilibrio 444555
  Bodega F-42 27163 (Caja 4)

Nombres de mostrador desde ficha (no el código del ticket).
Sin caducidad inventada (MMAA de la caja). Equilibrio sí trae lote de fábrica.
Fotos nuevas en public/catalogo-propia/ (tras deploy).
Metformina Ascend: TODO foto pendiente.
"""
from __future__ import annotations

import math
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from generar_recepcion_borrador import report, write_ticket_csv

ROOT = Path(__file__).resolve().parents[1]
FOTO_BASE = "https://www.farmacapital.mx/catalogo-propia"
OUT_DIR = ROOT / "sql"
GEN_DIR = ROOT / "sql" / "generated"


def ceil_pvp(costo: float, tipo: str) -> int:
    factor = 1.25 if tipo == "marca" else 1.6
    return int(math.ceil(costo * factor))


def sku_de(ean: str) -> str:
    return "FC-" + ean[-8:]


def sql_str(s: str | None) -> str:
    if s is None:
        return "null"
    return "'" + str(s).replace("'", "''") + "'"


def foto_url(name: str | None) -> str | None:
    if not name:
        return None
    return f"{FOTO_BASE}/{name}"


# ── productos (catálogo) ────────────────────────────────────────────
# ya=True → solo costo / ficha vacía; ya=False → alta si no existe
PRODUCTOS = {
    "3664798074680": {
        "sku": "FC-79807468",
        "nombre": "Enterogermina 2 billones C/10",
        "tipo": "marca",
        "categoria": "Gastro",
        "subcategoria": "Probiótico",
        "forma": "Suspensión",
        "marca": "Enterogermina",
        "laboratorio": "Opella",
        "presentacion": "Caja con 10 frascos 5 mL",
        "principio": "Bacillus clausii",
        "concentracion": "2 billones",
        "receta": False,
        "ya": True,
        "foto": None,  # ya en catálogo; no pisar
        "foto_file": None,
    },
    "7501008499412": {
        "sku": "FC-08499412",
        "nombre": "Flanax Pro naproxeno sódico 660 mg C/8",
        "tipo": "marca",
        "categoria": "Analgésico",
        "subcategoria": None,
        "forma": "Tabletas",
        "marca": "Flanax",
        "laboratorio": "Bayer",
        "presentacion": "Caja con 8 tabletas de liberación prolongada",
        "principio": "Naproxeno sódico",
        "concentracion": "660 mg",
        "receta": False,
        "ya": True,
        "foto": foto_url("flanax-pro-660mg-c8-7501008499412.jpg"),
        "foto_file": "catalogo-propia/flanax-pro-660mg-c8-7501008499412.jpg",
    },
    "7501057002663": {
        "sku": "FC-002663",
        "nombre": "Lomotil loperamida 2 mg C/8",
        "tipo": "marca",
        "categoria": "Gastro",
        "subcategoria": "Antidiarreico",
        "forma": "Tabletas",
        "marca": "Lomotil",
        "laboratorio": "Johnson & Johnson",
        "presentacion": "Caja con 8 tabletas",
        "principio": "Loperamida",
        "concentracion": "2 mg",
        "receta": False,
        "ya": True,
        "foto": foto_url("lomotil-2mg-c8-7501057002663.jpg"),
        "foto_file": "catalogo-propia/lomotil-2mg-c8-7501057002663.jpg",
    },
    "7503046016507": {
        "sku": sku_de("7503046016507"),
        "nombre": "Metformina LP Ascend 750 mg C/30",
        "tipo": "generico",
        "categoria": "Diabetes",
        "subcategoria": None,
        "forma": "Tabletas",
        "marca": "Ascend",
        "laboratorio": "Ascend",
        "presentacion": "Caja con 30 tabletas de liberación prolongada",
        "principio": "Metformina",
        "concentracion": "750 mg",
        "receta": True,
        "ya": False,
        # TODO foto: no hay packshot Ascend usable en CDN público al armar el ticket.
        "foto": None,
        "foto_file": None,
    },
    "3664798027525": {
        "sku": sku_de("3664798027525"),
        "nombre": "Pharmaton Woman 50+ cápsulas C/30",
        "tipo": "marca",
        "categoria": "Vitaminas",
        "subcategoria": "Multivitamínico",
        "forma": "Cápsulas",
        "marca": "Pharmaton",
        "laboratorio": "Opella",
        "presentacion": "Caja con 30 cápsulas de 750 mg",
        "principio": "Omega-3 + hierro + vitaminas",
        "concentracion": "750 mg",
        "receta": False,
        "ya": False,
        "foto": foto_url("pharmaton-woman-50-c30-3664798027525.jpg"),
        "foto_file": "catalogo-propia/pharmaton-woman-50-c30-3664798027525.jpg",
    },
    "7500435234313": {
        "sku": sku_de("7500435234313"),
        "nombre": "Crest Complete 4 en 1 menta suave 61 ml",
        "tipo": "marca",
        "categoria": "Cuidado personal",
        "subcategoria": "Higiene bucal",
        "forma": "Crema dental",
        "marca": "Crest",
        "laboratorio": "P&G",
        "presentacion": "Tubo 61 ml",
        "principio": None,
        "concentracion": None,
        "receta": False,
        "ya": False,
        "foto": foto_url("crest-complete-4en1-61ml-7500435234313.jpg"),
        "foto_file": "catalogo-propia/crest-complete-4en1-61ml-7500435234313.jpg",
    },
    "7500435258166": {
        "sku": sku_de("7500435258166"),
        "nombre": "Oral-B Frescura Duradera pasta dental 66 ml",
        "tipo": "marca",
        "categoria": "Cuidado personal",
        "subcategoria": "Higiene bucal",
        "forma": "Crema dental",
        "marca": "Oral-B",
        "laboratorio": "P&G",
        "presentacion": "Tubo 66 ml",
        "principio": None,
        "concentracion": None,
        "receta": False,
        "ya": False,
        "foto": foto_url("oral-b-frescura-duradera-66ml-7500435258166.jpg"),
        "foto_file": "catalogo-propia/oral-b-frescura-duradera-66ml-7500435258166.jpg",
    },
    "7502009741524": {
        "sku": "FC-9741524",
        "nombre": "Naturex colágeno hidrolizado 700 mg C/60",
        "tipo": "marca",
        "categoria": "Vitaminas",
        "subcategoria": "Colágeno",
        "forma": "Tabletas",
        "marca": "Naturex",
        "laboratorio": "Naturex",
        "presentacion": "Caja con 60 tabletas de 700 mg",
        "principio": "Colágeno hidrolizado",
        "concentracion": "700 mg",
        "receta": False,
        "ya": True,
        "foto": foto_url("naturex-colageno-700mg-c60-7502009741524.jpg"),
        "foto_file": "catalogo-propia/naturex-colageno-700mg-c60-7502009741524.jpg",
    },
    "7501075723137": {
        "sku": "FC-75723137",
        "nombre": "Novakosid senósidos A-B 8.6 mg C/20",
        "tipo": "marca",
        "categoria": "Gastro",
        "subcategoria": "Laxante",
        "forma": "Tabletas",
        "marca": "Novakosid",
        "laboratorio": "Novag",
        "presentacion": "Caja con 20 tabletas",
        "principio": "Senósidos A-B",
        "concentracion": "8.6 mg",
        "receta": False,
        "ya": True,
        "foto": None,
        "foto_file": None,
    },
    "7502266031116": {
        "sku": sku_de("7502266031116"),
        "nombre": "Colagener-3 pepino-limón polvo 150 g",
        "tipo": "marca",
        "categoria": "Vitaminas",
        "subcategoria": "Colágeno",
        "forma": "Polvo",
        "marca": "Biomiral",
        "laboratorio": "Biomiral",
        "presentacion": "Bolsa doypack 150 g (30 porciones de 5 g)",
        "principio": "Colágeno hidrolizado + magnesio + vitamina C + biotina",
        "concentracion": "3 g colágeno / 5 g",
        "receta": False,
        "ya": False,
        "foto": foto_url("colagener-3-pepino-limon-150g-7502266031116.jpg"),
        "foto_file": "catalogo-propia/colagener-3-pepino-limon-150g-7502266031116.jpg",
    },
}


def row(ean: str, snap: str, qty: int, pu: float, lote: str | None = None) -> dict:
    p = PRODUCTOS[ean]
    sub = round(qty * pu, 2)
    return {
        "ean": ean,
        "sku": p["sku"],
        "snap": snap,
        "nombre": p["nombre"],
        "qty": qty,
        "pu": pu,
        "sub": sub,
        "lote": lote,
        **{k: p[k] for k in (
            "tipo", "categoria", "subcategoria", "forma", "marca", "laboratorio",
            "presentacion", "principio", "concentracion", "receta", "ya", "foto", "foto_file",
        )},
        "precio": ceil_pvp(pu, p["tipo"]),
        "match": "ya" if p["ya"] else "alta",
    }


TICKETS = [
    {
        "key": "cityfarma_s322819",
        "folio": "S322819",
        "proveedor": "Cityfarma Iztapalapa",
        "proveedor_ilike": "cityfarma",
        "fecha": "2026-09-14",
        "total": 738.06,
        "notas": (
            "Ticket Cityfarma S322819 · 14-sep-2026 · foto térmica · "
            "Pendiente de pago $738.06 · cola Recibir; stock al confirmar pistola"
        ),
        "tmp": "_fc_cf_s322819",
        "header": (
            "Cityfarma Iztapalapa · orden S322819 · 2026-09-14 17:30\n"
            "-- Ticket térmico. IVA 0%. Pendiente de pago = suma renglones $738.06.\n"
            "-- Flanax Pro EAN 7501008499412 (ficha 660 mg LP C/8; ticket dice FLANAXPRO).\n"
            "-- Lomotil EAN canónico 7501057002663 (lista Cityfarma $143.87).\n"
            "-- Sin lote ni caducidad (MMAA de la caja). No inventar 0000."
        ),
        "rows": [
            row("7501008499412", "FLANAXPRO 550MG C8 T", 2, 225.16),
            row("7501057002663", "LOMOTIL 2 MG C 8 TAB", 2, 143.87),
        ],
    },
    {
        "key": "cityfarma_s322895",
        "folio": "S322895",
        "proveedor": "Cityfarma Iztapalapa",
        "proveedor_ilike": "cityfarma",
        "fecha": "2026-09-15",
        "total": 582.12,
        "notas": (
            "Ticket Cityfarma S322895 · 15-sep-2026 · foto térmica · "
            "Pendiente de pago $582.12 · cola Recibir; stock al confirmar pistola"
        ),
        "tmp": "_fc_cf_s322895",
        "header": (
            "Cityfarma Iztapalapa · orden S322895 · 2026-09-15 09:24\n"
            "-- Ticket térmico. Pendiente de pago $582.12 (subtotal + IVA del ticket).\n"
            "-- Metformina LP Ascend EAN 7503046016507 · TODO foto packshot Ascend.\n"
            "-- Pharmaton Woman 50+ EAN 3664798027525 (ficha Opella / Sanborns).\n"
            "-- Sin lote ni caducidad (MMAA de la caja). No inventar 0000."
        ),
        "rows": [
            row("7503046016507", "METFORMINA 750MG C30", 4, 45.51),
            row("3664798027525", "PHARMATON WOMAN 50MA", 2, 200.04),
        ],
    },
    {
        "key": "cityfarma_s322903",
        "folio": "S322903",
        "proveedor": "Cityfarma Iztapalapa",
        "proveedor_ilike": "cityfarma",
        "fecha": "2026-09-15",
        "total": 400.00,
        "notas": (
            "Ticket Cityfarma S322903 · 15-sep-2026 · foto térmica · "
            "Pendiente de pago $400.00 · cola Recibir; stock al confirmar pistola"
        ),
        "tmp": "_fc_cf_s322903",
        "header": (
            "Cityfarma Iztapalapa · orden S322903 · 2026-09-15 09:30\n"
            "-- Ticket térmico. IVA 0%. Pendiente de pago = $400.00.\n"
            "-- Enterogermina ya en catálogo (FC-79807468).\n"
            "-- Sin lote ni caducidad (MMAA de la caja). No inventar 0000."
        ),
        "rows": [
            row("3664798074680", "ENTEROGERMINA 2 BILL", 2, 200.00),
        ],
    },
    {
        "key": "equilibrio_444555",
        "folio": "444555",
        "proveedor": "Equilibrio",
        "proveedor_ilike": "equilibrio",
        "fecha": "2026-09-15",
        "total": 477.49,
        "notas": (
            "Ticket Equilibrio 444555 · Iztapalapa 2 · 15-sep-2026 · foto térmica · "
            "cliente 307513 · cola Recibir; stock al confirmar pistola"
        ),
        "tmp": "_fc_eq_444555",
        "header": (
            "Equilibrio · ticket 444555 · 2026-09-15 09:20 · sucursal Iztapalapa 2\n"
            "-- Pedido online. Total $477.49. Claves NAT0220/NOV138/BMI092 → EAN Levic/Gremfar.\n"
            "-- Lote de fábrica sí. Caducidad NO: Recibir pide MMAA de la caja. 0000 inválido.\n"
            "-- Naturex y Novakosid ya estaban; Colagener-3 alta nueva."
        ),
        "rows": [
            row("7502009741524", "NAT0220 COLAGENO 60 TAB 71.42/1.42/700 MG", 2, 38.03, "262618"),
            row("7501075723137", "NOV138 NOVAKOSID 20 TAB 8.6 MG", 10, 13.65, "540286"),
            row("7502266031116", "BMI092 COLAGENER-3 SOB 150 G", 2, 108.95, "26E002"),
        ],
    },
    {
        "key": "bodega_f42_27163",
        "folio": "27163",
        "proveedor": "Bodega F-42",
        "proveedor_ilike": "bodega",
        "fecha": "2026-09-15",
        "total": 266.39,
        "notas": (
            "Ticket Bodega F-42 Caja 4/27163 · 15-sep-2026 · foto térmica · "
            "tarjeta $266.39 · cola Recibir; stock al confirmar pistola"
        ),
        "tmp": "_fc_bf42_27163",
        "header": (
            "Bodega F-42 Ejidos del Moral · Caja 4/27163 · 2026-09-15 09:42\n"
            "-- Ticket térmico. Subtotal $229.65 + impuestos $36.74 = $266.39.\n"
            "-- Costo = P.U. impreso (antes de impuestos de ticket).\n"
            "-- Sin lote ni caducidad (MMAA de la caja). No inventar 0000."
        ),
        "rows": [
            row("7500435234313", "CREST COMPLETE 4EN1", 12, 18.16),
            row("7500435258166", "ORAL-B 66ML CRA DENT FRESC DURADERA C36", 2, 24.26),
        ],
    },
]


def write_carga_sql(ticket: dict) -> Path:
    rows = ticket["rows"]
    tmp = ticket["tmp"]
    folio = ticket["folio"]
    vals = []
    for i, r in enumerate(rows, start=1):
        vals.append(
            "  ({linea}, {ean}, {sku}, {nombre}, {snap}, {qty}, {costo}, {precio}, "
            "{tipo}, {cat}, {subcat}, {forma}, {marca}, {lab}, {pres}, {pa}, {conc}, "
            "{receta}, {ya}, {foto}, {foto_file}, {lote})".format(
                linea=i,
                ean=sql_str(r["ean"]),
                sku=sql_str(r["sku"]),
                nombre=sql_str(r["nombre"]),
                snap=sql_str(r["snap"]),
                qty=int(r["qty"]),
                costo=f"{r['pu']:.2f}",
                precio=int(r["precio"]),
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
                lote=sql_str(r.get("lote")),
            )
        )

    n_alta = sum(1 for r in rows if not r["ya"])
    n_ya = sum(1 for r in rows if r["ya"])
    body = f"""-- {ticket['header']}
-- {n_alta} alta(s) stock 0. {n_ya} ya estaban: solo costo / ficha vacía, no PVP.
-- Nombres de ficha, no del ticket. Fotos en public/catalogo-propia/ (tras deploy).
-- SIN bloques dollar-quote. Idempotente mientras el ticket siga en borrador.
-- Pegar TODO este archivo en Supabase → SQL Editor → Run.

begin;

create temp table {tmp} (
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
  foto_file text,
  lote text
) on commit drop;

insert into {tmp} (
  linea, ean, sku, nombre, snap, qty, costo, precio, tipo, categoria,
  subcategoria, forma, marca, laboratorio, presentacion, principio_activo,
  concentracion, receta, ya, imagen, foto_file, lote
) values
{",\n".join(vals)};

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
  'Alta {ticket["proveedor"]} {folio} · {ticket["fecha"]} · listo para pistola',
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
from {tmp} t
where public.fc_buscar_producto_escaneo(t.ean) is null;

-- Ya existían: costo. PVP solo si estaba en 0.
update public.productos p
set
  costo = t.costo,
  precio = case
    when coalesce(p.precio, 0) <= 0 then t.precio
    else p.precio
  end
from {tmp} t
where p.id = public.fc_buscar_producto_escaneo(t.ean)
  and (
    p.costo is distinct from t.costo
    or coalesce(p.precio, 0) <= 0
  );

-- Ficha vacía / foto si falta. No pisa una foto que ya esté.
update public.productos p
set
  nombre = case
    when length(trim(coalesce(p.nombre, ''))) < 8 then t.nombre
    else p.nombre
  end,
  marca = coalesce(nullif(trim(p.marca), ''), t.marca),
  presentacion = coalesce(nullif(trim(p.presentacion), ''), t.presentacion),
  principio_activo = coalesce(nullif(trim(p.principio_activo), ''), t.principio_activo),
  concentracion = coalesce(nullif(trim(p.concentracion), ''), t.concentracion),
  laboratorio = coalesce(nullif(trim(p.laboratorio), ''), t.laboratorio),
  subcategoria = coalesce(nullif(trim(p.subcategoria), ''), t.subcategoria),
  forma_farmaceutica = coalesce(nullif(trim(p.forma_farmaceutica), ''), t.forma),
  imagen_url = coalesce(nullif(trim(p.imagen_url), ''), t.imagen),
  imagen_mobile_url = coalesce(nullif(trim(p.imagen_mobile_url), ''), t.imagen)
from {tmp} t
where p.id = public.fc_buscar_producto_escaneo(t.ean);

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  {sql_str(ticket["proveedor"])},
  {sql_str(folio)},
  {sql_str(ticket["fecha"])},
  {ticket["total"]:.2f},
  'borrador',
  {sql_str(ticket["notas"])}
where not exists (
  select 1 from public.recepciones
  where folio = {sql_str(folio)}
    and coalesce(proveedor, '') ilike {sql_str("%" + ticket["proveedor_ilike"] + "%")}
);

update public.recepciones
set
  total_ticket = {ticket["total"]:.2f},
  fecha = {sql_str(ticket["fecha"])},
  proveedor = {sql_str(ticket["proveedor"])},
  notas = {sql_str(ticket["notas"])},
  updated_at = now()
where folio = {sql_str(folio)}
  and coalesce(proveedor, '') ilike {sql_str("%" + ticket["proveedor_ilike"] + "%")}
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = {sql_str(folio)}
  and coalesce(r.proveedor, '') ilike {sql_str("%" + ticket["proveedor_ilike"] + "%")}
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
  t.lote,
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
from {tmp} t
join public.recepciones r
  on r.folio = {sql_str(folio)}
 and coalesce(r.proveedor, '') ilike {sql_str("%" + ticket["proveedor_ilike"] + "%")}
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
    where i.producto_id = p.id and coalesce(i.es_principal, false)
  ),
  'propia'
from {tmp} t
join public.productos p on p.id = public.fc_buscar_producto_escaneo(t.ean)
where t.imagen is not null
  and not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id
      and (i.url = t.imagen or i.storage_path = t.foto_file)
  );

-- Diagnóstico
select
  r.folio,
  r.proveedor,
  r.estado,
  r.total_ticket,
  count(i.*) as renglones,
  sum(i.cantidad) as piezas,
  bool_or(i.pendiente_alta) as tiene_pendiente_alta
from public.recepciones r
left join public.recepcion_items i on i.recepcion_id = r.id
where r.folio = {sql_str(folio)}
  and coalesce(r.proveedor, '') ilike {sql_str("%" + ticket["proveedor_ilike"] + "%")}
group by r.id, r.folio, r.proveedor, r.estado, r.total_ticket;

select
  t.linea,
  t.ean,
  t.nombre,
  t.qty,
  t.costo,
  case when public.fc_buscar_producto_escaneo(t.ean) is null then 'PENDIENTE_ALTA' else 'OK' end as match,
  t.ya as marcado_ya
from {tmp} t
order by t.linea;

commit;
"""
    path = OUT_DIR / f"patch_carga_{ticket['key']}.sql"
    path.write_text(body, encoding="utf-8")
    return path


def main() -> None:
    GEN_DIR.mkdir(parents=True, exist_ok=True)
    for t in TICKETS:
        # Ajuste Bodega: P.U. con 3 decimales en ticket → redondeo a 2 en costo
        if t["key"] == "bodega_f42_27163":
            # 12*18.157=217.884 → 217.88; 2*24.255=48.51; usamos 18.16/24.26 y
            # corregimos subtotal implícito: mejor costo exacto con 2 decimales del importe/qty
            t["rows"][0]["pu"] = round(217.88 / 12, 2)  # 18.16
            t["rows"][1]["pu"] = round(48.51 / 2, 2)  # 24.26
            for r in t["rows"]:
                r["sub"] = round(r["qty"] * r["pu"], 2)
                r["precio"] = ceil_pvp(r["pu"], r["tipo"])

        csv_path = GEN_DIR / f"ticket_{t['key']}.csv"
        write_ticket_csv(
            csv_path,
            folio=t["folio"],
            fecha=t["fecha"],
            proveedor=t["proveedor"],
            total=t["total"],
            rows=[{"ean": r["ean"], "nombre": r["snap"], "qty": r["qty"],
                   "pu": r["pu"], "sub": r["sub"], "sku": r["sku"], "match": r["match"]}
                  for r in t["rows"]],
        )
        sql_path = write_carga_sql(t)
        print(f"{t['folio']}: {report(t['rows'], t['total'])}")
        print(f"  → {csv_path.relative_to(ROOT)}")
        print(f"  → {sql_path.relative_to(ROOT)}")


if __name__ == "__main__":
    main()
