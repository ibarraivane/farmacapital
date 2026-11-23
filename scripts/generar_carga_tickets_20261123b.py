#!/usr/bin/env python3
"""Tickets 23-nov-2026 (lote B) → altas + cola Recibir.

4 pedidos:
  Farma Mayoreo V01000005551 · Farma Mayoreo V01000005552
  Sahuayo 436374 · Cityfarma S343593

Nombres de mostrador. Caducidad null (MMAA de la caja).
Farma Mayoreo: lote de fabrica si; caducidad del papel NO.
SIN producto_imagenes. SIN dollar-quote.
"""
from __future__ import annotations

import math
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
OUT_SQL = ROOT / "sql" / "patch_recibir_tickets_2311b_SOLO_pegar_esto.sql"
OUT_MD = ROOT / "sql" / "LEERME_recibir_tickets_2311b_SOLO_pegar_esto.md"
FOTO = "https://www.farmacapital.mx/catalogo-propia"


def ceil_pvp(costo: float, tipo: str) -> int:
    return int(math.ceil(costo * (1.25 if tipo == "marca" else 1.6)))


def sku_de(ean: str) -> str:
    return "FC-" + ean[-8:]


def sql_str(v) -> str:
    if v is None:
        return "null"
    if isinstance(v, bool):
        return "true" if v else "false"
    if isinstance(v, (int, float)) and not isinstance(v, bool):
        return str(v)
    return "'" + str(v).replace("'", "''") + "'"


def foto(name: str | None) -> str | None:
    if not name:
        return None
    path = ROOT / "public" / "catalogo-propia" / name
    if path.exists() and path.stat().st_size >= 4000:
        return f"{FOTO}/{name}"
    return f"{FOTO}/{name}"


def P(
    ean: str,
    *,
    nombre: str,
    tipo: str = "marca",
    categoria: str = "Medicamentos",
    subcategoria: str | None = None,
    forma: str | None = None,
    marca: str | None = None,
    laboratorio: str | None = None,
    presentacion: str | None = None,
    principio: str | None = None,
    concentracion: str | None = None,
    receta: bool = False,
    ya: bool = False,
    sku: str | None = None,
    foto_file: str | None = None,
) -> dict:
    return {
        "ean": ean,
        "sku": sku or sku_de(ean),
        "nombre": nombre,
        "tipo": tipo,
        "categoria": categoria,
        "subcategoria": subcategoria,
        "forma": forma,
        "marca": marca,
        "laboratorio": laboratorio,
        "presentacion": presentacion,
        "principio": principio,
        "concentracion": concentracion,
        "receta": receta,
        "ya": ya,
        "foto": foto(foto_file),
    }


CAT: dict[str, dict] = {
    # Farma Mayoreo
    "7503002163023": P(
        "7503002163023",
        nombre="Xtreme gel Professional",
        categoria="Cuidado personal",
        subcategoria="Cabello",
        forma="Gel",
        marca="Xtreme",
        presentacion="Envase 250 g",
        ya=True,
        foto_file="xtreme-gel-profesional-250g.jpg",
    ),
    "7451079003523": P(
        "7451079003523",
        nombre="Mejoralito pediatrico",
        forma="Tabletas masticables",
        marca="Mejoralito",
        laboratorio="GSK",
        presentacion="Caja con 30 tabletas",
        principio="Paracetamol",
        ya=False,
    ),
    "7503002163610": P(
        "7503002163610",
        nombre="Xtreme gel Attraction",
        categoria="Cuidado personal",
        subcategoria="Cabello",
        forma="Gel",
        marca="Xtreme",
        presentacion="Envase 250 g",
        ya=True,
        foto_file="xtreme-gel-attraction-250g.jpg",
    ),
    "7501199416885": P(
        "7501199416885",
        nombre="Xtreme gel Princesa",
        categoria="Cuidado personal",
        subcategoria="Cabello",
        forma="Gel",
        marca="Xtreme",
        presentacion="Envase 200 g",
        ya=False,
    ),
    "7501054558682": P(
        "7501054558682",
        nombre="Nivea Milk Nutritiva pack 400 ml + 100 ml",
        categoria="Cuidado de la piel",
        forma="Crema corporal",
        marca="Nivea",
        laboratorio="Beiersdorf",
        presentacion="Pack 400 ml + 100 ml",
        ya=True,
        sku="FC-54558682",
    ),
    # Sahuayo
    "7506425607808": P(
        "7506425607808",
        nombre="Huggies Supreme toallitas humedas",
        categoria="Bebes",
        subcategoria="Toallitas",
        forma="Toallas humedas",
        marca="Huggies",
        laboratorio="Kimberly-Clark",
        presentacion="Bolsa con 80 piezas",
        ya=False,
    ),
    "7501943441767": P(
        "7501943441767",
        nombre="Huggies Supreme etapa 4",
        categoria="Bebes",
        subcategoria="Panales",
        marca="Huggies",
        laboratorio="Kimberly-Clark",
        presentacion="Bolsa con 36 panales etapa 4",
        ya=True,
        sku="FC-43441767",
        foto_file="huggies-supreme-e4-unisex-36-7501943441767.jpg",
    ),
    # Cityfarma
    "7502276040368": P(
        "7502276040368",
        nombre="Desenfriol D",
        forma="Tabletas",
        marca="Desenfriol",
        laboratorio="Bayer",
        presentacion="Caja con 30 tabletas",
        principio="Clorfenamina / Fenilefrina / Paracetamol",
        ya=True,
    ),
    "7502276040641": P(
        "7502276040641",
        nombre="Desenfriol D",
        forma="Tabletas",
        marca="Desenfriol",
        laboratorio="Bayer",
        presentacion="Caja con 6 tabletas",
        principio="Clorfenamina / Fenilefrina / Paracetamol",
        ya=True,
        sku="FC-27604064",
        foto_file="desenfriol-d-c6.jpg",
    ),
    "7502276040405": P(
        "7502276040405",
        nombre="Desenfriolito Plus",
        forma="Tabletas masticables",
        marca="Desenfriolito",
        laboratorio="Bayer",
        presentacion="Caja con 24 tabletas",
        principio="Clorfenamina / Fenilefrina / Paracetamol",
        concentracion="1 mg / 2.5 mg / 80 mg",
        ya=True,
        sku="FC-76040610",
    ),
    "7502276040627": P(
        "7502276040627",
        nombre="Desenfriolito Plus",
        forma="Tabletas masticables",
        marca="Desenfriolito",
        laboratorio="Bayer",
        presentacion="Caja con 6 tabletas",
        principio="Clorfenamina / Fenilefrina / Paracetamol",
        concentracion="1 mg / 2.5 mg / 80 mg",
        ya=False,
    ),
    "7501088505126": P(
        "7501088505126",
        nombre="Neuralin",
        forma="Ampolleta",
        marca="Neuralin",
        presentacion="1 ampolleta",
        principio="Diclofenaco / Tiamina / Piridoxina / Cianocobalamina",
        receta=True,
        ya=True,
        sku="FC-8505126",
    ),
    "7501298265100": P(
        "7501298265100",
        nombre="Neurobion",
        categoria="Vitaminas",
        forma="Tabletas",
        marca="Neurobion",
        laboratorio="Merck",
        presentacion="Caja con 60 tabletas",
        principio="Tiamina / Piridoxina / Cianocobalamina",
        concentracion="100 mg / 5 mg / 50 mcg",
        ya=False,
    ),
}


def row(ean: str, snap: str, qty: int, pu: float, lote: str | None = None) -> dict:
    f = CAT[ean]
    costo = round(pu, 2)
    return {
        **f,
        "snap": snap[:60],
        "qty": qty,
        "pu": costo,
        "precio": ceil_pvp(costo, f["tipo"]),
        "lote": lote,
        "sub": round(qty * pu, 2),
    }


TICKETS = [
    {
        "tmp": "_fc_fm_5551",
        "folio": "V01000005551",
        "proveedor": "Farma Mayoreo",
        "proveedor_ilike": "farma mayoreo",
        "fecha": "2026-11-23",
        "total": 304.53,
        "notas": (
            "Farma Mayoreo · ID Venta V01000005551 · 23-nov-2026 14:02 · "
            "Alfredo Luciano Salazar · caja 3 · efectivo · PUBLICO GENERAL · "
            "P.U. con IVA · lote de fabrica; caducidad NO · cola Recibir"
        ),
        "header": "Farma Mayoreo · folio V01000005551 · 2026-11-23 · total $304.53 · 4 renglones",
        "rows": [
            row("7503002163023", "GEL PARA PEINAR XTREME 250 G", 5, 24.76, "K72556L404"),
            row("7451079003523", "MEJORALITO PEDIATRICO CON 30 TABLETAS MASTICABLES", 1, 60.78, "UH4N"),
            row("7503002163610", "GEL PARA PEINAR XTREME ATTRACTION CON ENVASE 250G", 4, 23.94, None),
            row("7501199416885", "GEL PARA PEINAR XTREME PRINCESA CON ENVASE 200G", 1, 24.19, None),
        ],
    },
    {
        "tmp": "_fc_fm_5552",
        "folio": "V01000005552",
        "proveedor": "Farma Mayoreo",
        "proveedor_ilike": "farma mayoreo",
        "fecha": "2026-11-23",
        "total": 80.00,
        "notas": (
            "Farma Mayoreo · ID Venta V01000005552 · 23-nov-2026 14:02 · "
            "Alfredo Luciano Salazar · caja 3 · efectivo · PUBLICO GENERAL · "
            "Nivea Milk pack · cola Recibir; MMAA de la caja"
        ),
        "header": "Farma Mayoreo · folio V01000005552 · 2026-11-23 · total $80.00 · 1 renglón",
        "rows": [
            row("7501054558682", "CRA CORP NIVEA MILK 400 ML + CRA 100 ML", 1, 80.00, None),
        ],
    },
    {
        "tmp": "_fc_sah_436374",
        "folio": "436374",
        "proveedor": "Sahuayo",
        "proveedor_ilike": "sahuayo",
        "fecha": "2026-11-23",
        "total": 297.74,
        "notas": (
            "Sahuayo · ticket 436374 · 23-nov-2026 14:17 · Central Abastos F26/F28 · "
            "Ma. Fernanda Galindo · tarjeta credito · 2 renglones · cola Recibir; MMAA de la caja"
        ),
        "header": "Sahuayo · folio 436374 · 2026-11-23 · total $297.74 · 2 renglones",
        "rows": [
            row("7506425607808", "PZA.T.H. HUGGIES SUPR.80s 1/80", 1, 47.76, None),
            row("7501943441767", "PZA.HUGGIE SU E4 NIÑO5X36 1/36", 1, 249.98, None),
        ],
    },
    {
        "tmp": "_fc_cf_s343593",
        "folio": "S343593",
        "proveedor": "Cityfarma Iztapalapa",
        "proveedor_ilike": "cityfarma",
        "fecha": "2026-11-23",
        "total": 1137.54,
        "notas": (
            "Cityfarma Iztapalapa · orden S343593 · 23-nov-2026 13:20 · Jonathan Moreno · "
            "cliente Luis Angel Palillero Ventura · pendiente de pago $1,137.54 · "
            "IVA 0 · cola Recibir; MMAA de la caja"
        ),
        "header": "Cityfarma · folio S343593 · 2026-11-23 · total $1,137.54 · 6 renglones · pendiente de pago",
        "rows": [
            row("7502276040368", "DESENFRIOL D C30 TAB", 2, 59.26, None),
            row("7502276040641", "DESENFRIOL D C6 TAB", 5, 17.43, None),
            row("7502276040405", "DESENFRIOLITO PLUS C", 3, 55.89, None),
            row("7502276040627", "DESENFRIOLITO PLUS C", 10, 17.83, None),
            row("7501088505126", "NEURALIN C 1 AMP", 1, 142.38, None),
            row("7501298265100", "NEUROBION 60GRAG", 1, 443.52, None),
        ],
    },
]


def render_ticket(t: dict) -> str:
    rows = t["rows"]
    tmp = t["tmp"]
    folio = t["folio"]
    vals = []
    for i, r in enumerate(rows, start=1):
        vals.append(
            "  ({linea}, {ean}, {sku}, {nombre}, {snap}, {qty}, {costo}, {precio}, "
            "{tipo}, {cat}, {sub}, {forma}, {marca}, {lab}, {pres}, {pa}, {conc}, "
            "{receta}, {ya}, {img}, {lote})".format(
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
                sub=sql_str(r["subcategoria"]),
                forma=sql_str(r["forma"]),
                marca=sql_str(r["marca"]),
                lab=sql_str(r["laboratorio"]),
                pres=sql_str(r["presentacion"]),
                pa=sql_str(r["principio"]),
                conc=sql_str(r["concentracion"]),
                receta=sql_str(r["receta"]),
                ya=sql_str(r["ya"]),
                img=sql_str(r["foto"]),
                lote=sql_str(r.get("lote")),
            )
        )
    n_alta = sum(1 for r in rows if not r["ya"])
    n_ya = sum(1 for r in rows if r["ya"])
    ilike = sql_str("%" + t["proveedor_ilike"] + "%")
    return f"""
-- ========== {t['proveedor']} {folio} ==========
-- {t['header']}
-- {n_alta} alta(s) stock 0. {n_ya} ya estaban: solo costo / ficha vacia, no PVP.
-- Nombres de ficha, no del ticket. SIN dollar-quote. Idempotente en borrador.
-- Caducidad null: MMAA de la caja. No inventar 0000.

begin;

create temp table {tmp} (
  linea integer primary key,
  ean text,
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
  lote text
) on commit drop;

insert into {tmp} (
  linea, ean, sku, nombre, snap, qty, costo, precio, tipo, categoria,
  subcategoria, forma, marca, laboratorio, presentacion, principio_activo,
  concentracion, receta, ya, imagen, lote
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
    when not exists (
      select 1 from public.productos p where p.sku = t.sku
    ) then t.sku
    when t.ean is not null and not exists (
      select 1 from public.productos p
      where p.sku = ('FC-ND-' || right(t.ean, 8))
    ) then 'FC-ND-' || right(t.ean, 8)
    when t.ean is not null then
      'FC-T' || lpad(t.linea::text, 2, '0') || '-' || right(t.ean, 8)
    else 'FC-T' || lpad(t.linea::text, 2, '0') || '-' || right(t.sku, 8)
  end,
  t.ean,
  t.categoria,
  t.subcategoria,
  t.tipo,
  'Alta {t["proveedor"]} {folio} · {t["fecha"]} · listo para pistola',
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
from (
  select distinct on (coalesce(ean, sku)) *
  from {tmp}
  order by coalesce(ean, sku), linea
) t
where (t.ean is null or not exists (
    select 1 from public.productos p
    where nullif(btrim(p.codigo_barras), '') = t.ean
  ))
  and not exists (
    select 1 from public.productos p
    where p.sku = t.sku
      and (
        t.ean is null
        or nullif(btrim(p.codigo_barras), '') is null
        or nullif(btrim(p.codigo_barras), '') = t.ean
      )
  )
  and not exists (
    select 1 from public.productos p
    where p.sku = (
      case
        when not exists (
          select 1 from public.productos x where x.sku = t.sku
        ) then t.sku
        when t.ean is not null and not exists (
          select 1 from public.productos x
          where x.sku = ('FC-ND-' || right(t.ean, 8))
        ) then 'FC-ND-' || right(t.ean, 8)
        when t.ean is not null then
          'FC-T' || lpad(t.linea::text, 2, '0') || '-' || right(t.ean, 8)
        else 'FC-T' || lpad(t.linea::text, 2, '0') || '-' || right(t.sku, 8)
      end
    )
  );

update public.productos p
set
  costo = t.costo,
  precio = case
    when coalesce(p.precio, 0) <= 0 then t.precio
    else p.precio
  end
from (
  select distinct on (coalesce(ean, sku)) *
  from {tmp}
  order by coalesce(ean, sku), linea
) t
where p.id = coalesce(
  case when t.ean is not null then public.fc_buscar_producto_escaneo(t.ean) end,
  public.fc_buscar_producto_escaneo(t.sku),
  (
    select p2.id from public.productos p2
    where t.ean is not null
      and nullif(btrim(p2.codigo_barras), '') = t.ean
    order by p2.id
    limit 1
  ),
  (
    select p2.id from public.productos p2
    where p2.sku = t.sku
    order by p2.id
    limit 1
  )
)
  and (
    p.costo is distinct from t.costo
    or coalesce(p.precio, 0) <= 0
  );

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
  imagen_mobile_url = coalesce(nullif(trim(p.imagen_mobile_url), ''), t.imagen),
  codigo_barras = coalesce(nullif(p.codigo_barras, ''), t.ean)
from (
  select distinct on (coalesce(ean, sku)) *
  from {tmp}
  order by coalesce(ean, sku), linea
) t
where p.id = coalesce(
  case when t.ean is not null then public.fc_buscar_producto_escaneo(t.ean) end,
  public.fc_buscar_producto_escaneo(t.sku),
  (
    select p2.id from public.productos p2
    where t.ean is not null
      and nullif(btrim(p2.codigo_barras), '') = t.ean
    order by p2.id
    limit 1
  ),
  (
    select p2.id from public.productos p2
    where p2.sku = t.sku
    order by p2.id
    limit 1
  )
);

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  {sql_str(t["proveedor"])},
  {sql_str(folio)},
  {sql_str(t["fecha"])},
  {t["total"]:.2f},
  'borrador',
  {sql_str(t["notas"])}
where not exists (
  select 1 from public.recepciones
  where folio = {sql_str(folio)}
    and coalesce(proveedor, '') ilike {ilike}
);

update public.recepciones
set
  total_ticket = {t["total"]:.2f},
  fecha = {sql_str(t["fecha"])},
  proveedor = {sql_str(t["proveedor"])},
  notas = {sql_str(t["notas"])},
  updated_at = now()
where folio = {sql_str(folio)}
  and coalesce(proveedor, '') ilike {ilike}
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = {sql_str(folio)}
  and coalesce(r.proveedor, '') ilike {ilike}
  and r.estado = 'borrador';

insert into public.recepcion_items (
  recepcion_id, producto_id, codigo_escaneado, nombre_snapshot,
  cantidad, fecha_caducidad, numero_lote, costo_estimado, pendiente_alta,
  origen, confirmado, lote_distinto, lote_id
)
select
  r.id,
  v.pid,
  coalesce(nullif(btrim(t.ean), ''), t.sku),
  t.snap,
  t.qty,
  null,
  t.lote,
  t.costo,
  (v.pid is null),
  'pdf',
  false,
  false,
  null
from {tmp} t
join public.recepciones r
  on r.folio = {sql_str(folio)}
 and coalesce(r.proveedor, '') ilike {ilike}
 and r.estado = 'borrador'
left join lateral (
  select coalesce(
    case when nullif(btrim(t.ean), '') is not null
      then public.fc_buscar_producto_escaneo(nullif(btrim(t.ean), ''))
      else null end,
    public.fc_buscar_producto_escaneo(t.sku),
    (
      select p2.id from public.productos p2
      where nullif(btrim(t.ean), '') is not null
        and nullif(btrim(p2.codigo_barras), '') = nullif(btrim(t.ean), '')
      order by p2.id
      limit 1
    ),
    (
      select p2.id from public.productos p2
      where p2.sku = t.sku
      order by p2.id
      limit 1
    )
  ) as pid
) v on true
order by t.linea;

select
  r.folio,
  r.proveedor,
  r.estado,
  r.total_ticket,
  count(i.*) as renglones,
  sum(i.cantidad) as piezas,
  count(*) filter (where i.confirmado is not true) as sin_confirmar,
  bool_or(i.pendiente_alta) as tiene_pendiente_alta
from public.recepciones r
left join public.recepcion_items i on i.recepcion_id = r.id
where r.folio = {sql_str(folio)}
  and coalesce(r.proveedor, '') ilike {ilike}
group by r.id, r.folio, r.proveedor, r.estado, r.total_ticket;

commit;
"""


def main() -> None:
    for t in TICKETS:
        s = round(sum(r["sub"] for r in t["rows"]), 2)
        if abs(s - t["total"]) > 0.05:
            raise SystemExit(f"{t['folio']}: sum {s} != {t['total']}")
        print(f"{t['folio']}: {len(t['rows'])} rows · sum {s} · total {t['total']}")

    parts = [
        "-- =============================================================================",
        "-- PEGAR TODO ESTE ARCHIVO en Supabase → SQL Editor → Run",
        "-- Tickets 23-nov-2026 (lote B) → cola Recibir (borrador).",
        "-- Farma Mayoreo V01000005551 + V01000005552 · Sahuayo 436374 · Cityfarma S343593",
        "-- Merge a GitHub NO los crea. Sin dollar-quote. Sin producto_imagenes.",
        "-- Caducidad null: MMAA de la caja. No inventar 0000.",
        "-- Cada ticket es begin/commit independiente.",
        "-- =============================================================================",
        "",
        "rollback;",
        "",
    ]
    for t in TICKETS:
        parts.append(render_ticket(t))

    ver_ors = "\n or ".join(
        f"(r.folio = {sql_str(t['folio'])} and coalesce(r.proveedor, '') ilike {sql_str('%' + t['proveedor_ilike'] + '%')})"
        for t in TICKETS
    )
    parts.append(
        f"""
-- ========== VERIFICACION FINAL ==========
select
  r.folio,
  r.proveedor,
  r.estado,
  r.total_ticket,
  count(i.*) as renglones,
  sum(i.cantidad) as piezas,
  count(*) filter (where i.confirmado is not true) as sin_confirmar
from public.recepciones r
left join public.recepcion_items i on i.recepcion_id = r.id
where (
    {ver_ors}
)
group by r.id, r.folio, r.proveedor, r.estado, r.total_ticket
order by r.folio;
"""
    )
    sql = "\n".join(parts)
    if "$$" in sql:
        raise SystemExit("ERROR: $$")
    OUT_SQL.write_text(sql, encoding="utf-8")

    table = "\n".join(
        f"| {t['proveedor']} | **{t['folio']}** | ${t['total']:,.2f} | {len(t['rows'])} |"
        for t in TICKETS
    )
    OUT_MD.write_text(
        f"""# Tickets 23-nov-2026 (lote B) → Recibir

El merge a GitHub **no** crea la cola. Pegar **todo** el SQL en Supabase → SQL Editor → Run.

## Tickets

| Proveedor | Folio | Total | Renglones |
|---|---|---|---|
{table}

## Pasos

1. Raw: https://raw.githubusercontent.com/ibarraivane/farmacapital/main/sql/patch_recibir_tickets_2311b_SOLO_pegar_esto.sql
2. Selecciona TODO → copiar → pegar → **Run**
3. VERIFICACION FINAL con los 4 folios en `borrador`
4. Tablet Recibir → recargar

## Notas

1. **Farma Mayoreo:** lote de fábrica si; caducidad del papel NO.
2. **Sahuayo:** Huggies toallitas Supreme 80 `7506425607808`; E4 `7501943441767`.
3. **Cityfarma S343593:** pendiente de pago $1,137.54 · Desenfriolito Plus C/6 `7502276040627`.
4. **Stock:** 0 hasta pistola + MMAA.
""",
        encoding="utf-8",
    )
    print(f"→ {OUT_SQL.relative_to(ROOT)} ({OUT_SQL.stat().st_size} bytes)")


if __name__ == "__main__":
    main()
