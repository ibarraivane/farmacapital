#!/usr/bin/env python3
"""Ticket City Mark 2026-09-12 → altas con foto + cola Recibir.

Fuente: ticket físico «Cliente: PUBLICO EN GENERAL» (encabezado cortado).
Folio no venía en el recorte: usamos 20260912.
17 líneas / 22 piezas / $1,486.47. Sin lote ni MMAA.
EAN del ticket. Nombres de mostrador limpios.
Fotos en public/catalogo-propia/ (URLs tras deploy).
"""
from __future__ import annotations

import math
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from generar_recepcion_borrador import report, write_recepcion_sql, write_ticket_csv

ROOT = Path(__file__).resolve().parents[1]
FOLIO = "20260912"
PROVEEDOR = "City Mark"
PROVEEDOR_ILIKE = "city mark"
FECHA = "2026-09-12"
TOTAL = 1486.47
FOTO = "https://www.farmacapital.mx/catalogo-propia/{}"


def ceil_pvp(costo: float, factor: float = 1.6) -> int:
    return int(math.ceil(costo * factor))


def sku_de(ean: str) -> str:
    return "FC-" + ean[-8:]


def sql_str(s: str | None) -> str:
    if s is None:
        return "null"
    return "'" + str(s).replace("'", "''") + "'"


# ya=True: solo costo (ya en catálogo). Resto: alta stock 0 + foto.
ROWS = [
    dict(
        ean="7501943476271",
        snap="KLENNEX PAÑ BOTE C50",
        nombre="Kleenex pañuelos bote C/50",
        qty=2,
        pu=29.14,
        sub=58.28,
        tipo="marca",
        categoria="Cuidado personal",
        subcategoria="Pañuelos",
        forma="Pañuelos",
        marca="Kleenex",
        laboratorio="Kimberly-Clark",
        presentacion="Bote con 50 pañuelos",
        ya=False,
        foto="kleenex-panuelos-bote-50.jpg",
    ),
    dict(
        ean="070330731813",
        snap="BIC SOLEIL 3 COLOR COLLECTION 12 PZS OFERTA 20%",
        nombre="BIC Soleil 3 Color Collection 12 pzas",
        qty=1,
        pu=155.32,
        sub=155.32,
        tipo="marca",
        categoria="Cuidado personal",
        subcategoria="Afeitado",
        forma="Rastrillo",
        marca="BIC",
        laboratorio="BIC",
        presentacion="Paquete 12 piezas",
        ya=False,
        foto="bic-soleil-3-color-12.jpg",
    ),
    dict(
        ean="070330717541",
        snap="BIC TIRA ADVANC TIRA RASTRILLO 12 PZS OFERTA 20%",
        nombre="BIC Advance tira rastrillo 12 pzas",
        qty=1,
        pu=169.60,
        sub=169.60,
        tipo="marca",
        categoria="Cuidado personal",
        subcategoria="Afeitado",
        forma="Rastrillo",
        marca="BIC",
        laboratorio="BIC",
        presentacion="Tira 12 piezas",
        ya=False,
        foto="bic-advance-tira-12.jpg",
    ),
    dict(
        ean="850040940602",
        snap="GRISI 400ML SH ORGAN SILVER + 130ML CANAS P LATI",
        nombre="Grisi Organogal Silver shampoo 400 ml + canas 130 ml",
        qty=1,
        pu=87.35,
        sub=87.35,
        tipo="marca",
        categoria="Cuidado personal",
        subcategoria="Cabello",
        forma="Kit",
        marca="Grisi",
        laboratorio="Grisi",
        presentacion="Shampoo 400 ml + tratamiento 130 ml",
        ya=False,
        foto="grisi-organogal-silver-kit.jpg",
    ),
    dict(
        ean="810120500164",
        snap="CRA PERT KERA+AC AGU P/PEIN 100 ML",
        nombre="Pert crema peinar keratina + aguacate 100 ml",
        qty=2,
        pu=14.80,
        sub=29.60,
        tipo="marca",
        categoria="Cuidado personal",
        subcategoria="Cabello",
        forma="Crema",
        marca="Pert",
        laboratorio="Grisi",
        presentacion="Frasco 100 ml",
        ya=False,
        foto="pert-crema-kera-aguacate-100.jpg",
    ),
    dict(
        ean="7502254073371",
        snap="SILICA SEDA PURE ARGAN SPY 300ML",
        nombre="Seda Pure silica argán spray 300 ml",
        qty=1,
        pu=69.04,
        sub=69.04,
        tipo="marca",
        categoria="Cuidado personal",
        subcategoria="Cabello",
        forma="Spray",
        marca="Seda Pure",
        laboratorio="Seda Pure",
        presentacion="Spray 300 ml",
        ya=False,
        foto="seda-pure-silica-argan-300.jpg",
    ),
    dict(
        ean="7502254073357",
        snap="SILICA SEDA PURE UVA SPY300ML",
        nombre="Seda Pure silica uva spray 300 ml",
        qty=1,
        pu=69.05,
        sub=69.05,
        tipo="marca",
        categoria="Cuidado personal",
        subcategoria="Cabello",
        forma="Spray",
        marca="Seda Pure",
        laboratorio="Seda Pure",
        presentacion="Spray 300 ml",
        ya=False,
        foto="seda-pure-silica-uva-300.jpg",
    ),
    dict(
        ean="7506306208315",
        snap="CRA S TIVES COLAGENO Y ELAS 200ML OCT26",
        nombre="St Ives colágeno y elastina 200 ml",
        qty=1,
        pu=32.31,
        sub=32.31,
        tipo="marca",
        categoria="Cuidado personal",
        subcategoria="Corporal",
        forma="Crema",
        marca="St. Ives",
        laboratorio="Unilever",
        presentacion="Tubo 200 ml",
        ya=False,
        foto="st-ives-colageno-elastina-200.jpg",
    ),
    dict(
        ean="7501080111455",
        snap="TIN JUST F-MEN BARBA/B NEGRO",
        nombre="Just For Men tinte barba/bigote negro",
        qty=2,
        pu=171.14,
        sub=342.28,
        tipo="marca",
        categoria="Cuidado personal",
        subcategoria="Tinte",
        forma="Kit",
        marca="Just For Men",
        laboratorio="Combe",
        presentacion="Kit barba/bigote negro",
        ya=False,
        foto="just-for-men-barba-negro.jpg",
    ),
    dict(
        ean="7502254073715",
        snap="ACOND SEDA PURE KERAT BIFAS 250ML",
        nombre="Seda Pure acondicionador kerat bifásico 250 ml",
        qty=1,
        pu=55.10,
        sub=55.10,
        tipo="marca",
        categoria="Cuidado personal",
        subcategoria="Cabello",
        forma="Acondicionador",
        marca="Seda Pure",
        laboratorio="Seda Pure",
        presentacion="Frasco 250 ml",
        ya=False,
        foto="seda-pure-acond-kerat-250.jpg",
    ),
    dict(
        ean="810120500171",
        sku="FC-20500171",
        snap="CRA PERT OLIV+AC AGU P/PEIN 100 ML",
        nombre="Pert crema peinar oliva + aguacate 100 ml",
        qty=2,
        pu=14.80,
        sub=29.60,
        tipo="marca",
        categoria="Cuidado personal",
        subcategoria="Cabello",
        forma="Crema",
        marca="Pert",
        laboratorio="Grisi",
        presentacion="Frasco 100 ml",
        ya=True,
        foto=None,
    ),
    dict(
        ean="7702031887928",
        sku="FC-31887928",
        snap="ENJ BUC LIST CARE ZERO MTA 250ML",
        nombre="Listerine Care Zero menta 250 ml",
        qty=1,
        pu=63.53,
        sub=63.53,
        tipo="marca",
        categoria="Cuidado personal",
        subcategoria="Bucal",
        forma="Enjuague",
        marca="Listerine",
        laboratorio="J&J",
        presentacion="Frasco 250 ml",
        ya=True,
        foto=None,
    ),
    dict(
        ean="7891010974329",
        sku="FC-10974329",
        snap="ENJ BUC LIST ZERO MTA SVE 250ML",
        nombre="Listerine Zero menta suave 250 ml",
        qty=1,
        pu=54.06,
        sub=54.06,
        tipo="marca",
        categoria="Cuidado personal",
        subcategoria="Bucal",
        forma="Enjuague",
        marca="Listerine",
        laboratorio="J&J",
        presentacion="Frasco 250 ml",
        ya=True,
        foto=None,
    ),
    dict(
        ean="7702035433299",
        snap="ENJ BUC LIST DEF/DYENC 250ML",
        nombre="Listerine Defense 250 ml",
        qty=1,
        pu=63.86,
        sub=63.86,
        tipo="marca",
        categoria="Cuidado personal",
        subcategoria="Bucal",
        forma="Enjuague",
        marca="Listerine",
        laboratorio="J&J",
        presentacion="Frasco 250 ml",
        ya=False,
        foto="listerine-defense-250.jpg",
    ),
    dict(
        ean="7501027233974",
        snap="GEL LOREAL FIX INV U/FIJ 180G",
        nombre="L'Oréal Fix Inv ultra fijación gel 180 g",
        qty=1,
        pu=58.10,
        sub=58.10,
        tipo="marca",
        categoria="Cuidado personal",
        subcategoria="Cabello",
        forma="Gel",
        marca="L'Oréal",
        laboratorio="L'Oréal",
        presentacion="Tubo 180 g",
        ya=False,
        foto="loreal-fix-inv-ultra-180.jpg",
    ),
    dict(
        ean="7502254072831",
        snap="SILICA SEDA PURE BRILLO EXTRE 125ML",
        nombre="Seda Pure silica brillo extremo 125 ml",
        qty=2,
        pu=58.54,
        sub=117.08,
        tipo="marca",
        categoria="Cuidado personal",
        subcategoria="Cabello",
        forma="Spray",
        marca="Seda Pure",
        laboratorio="Seda Pure",
        presentacion="Spray 125 ml",
        ya=False,
        foto="seda-pure-silica-brillo-125.jpg",
    ),
    dict(
        ean="7506306208353",
        snap="CRA ST IVES AVENA Y KARITE 200ML NOV26",
        nombre="St Ives avena y karité 200 ml",
        qty=1,
        pu=32.31,
        sub=32.31,
        tipo="marca",
        categoria="Cuidado personal",
        subcategoria="Corporal",
        forma="Crema",
        marca="St. Ives",
        laboratorio="Unilever",
        presentacion="Tubo 200 ml",
        ya=False,
        foto="st-ives-avena-karite-200.jpg",
    ),
]


def with_sku(r: dict) -> dict:
    out = dict(r)
    out["sku"] = r.get("sku") or sku_de(r["ean"])
    if r.get("foto"):
        out["foto_url"] = FOTO.format(r["foto"])
        out["foto_file"] = f"catalogo-propia/{r['foto']}"
    else:
        out["foto_url"] = None
        out["foto_file"] = None
    return out


def rows_rx() -> list[dict]:
    out = []
    for r in ROWS:
        e = with_sku(r)
        out.append(
            {
                "nombre": e["nombre"],
                "qty": e["qty"],
                "sub": e["sub"],
                "pu": e["pu"],
                "ean": e["ean"],
                "sku": e["sku"],
                "match": "ya" if e["ya"] else "alta",
            }
        )
    return out


def write_carga_sql(path: Path) -> None:
    vals = []
    for i, raw in enumerate(ROWS, start=1):
        r = with_sku(raw)
        precio = ceil_pvp(r["pu"])
        vals.append(
            f"  ({i}, {sql_str(r['ean'])}, {sql_str(r['sku'])}, {sql_str(r['nombre'])},\n"
            f"   {sql_str(r['snap'])}, {r['qty']}, {r['pu']:.2f}, {precio},\n"
            f"   {sql_str(r['tipo'])}, {sql_str(r['categoria'])}, {sql_str(r['subcategoria'])},\n"
            f"   {sql_str(r['forma'])}, {sql_str(r['marca'])}, {sql_str(r['laboratorio'])},\n"
            f"   {sql_str(r['presentacion'])},\n"
            f"   {'true' if r['ya'] else 'false'},\n"
            f"   {sql_str(r['foto_url'])}, {sql_str(r['foto_file'])})"
        )

    notas = (
        f"Pedido City Mark {FOLIO} · ticket PUBLICO EN GENERAL · "
        "encabezado cortado (folio/fecha estimados 12-sep-2026) · "
        "EAN del ticket · cola Recibir; stock al confirmar pistola · "
        "altas con ficha+foto en catalogo-propia"
    )

    body = f"""-- City Mark · folio {FOLIO} ({FECHA}) — altas con foto + cola Recibir.
-- Ticket PUBLICO EN GENERAL (encabezado cortado). Total ${TOTAL:.2f}.
-- P.U. = costo. Sin lote ni caducidad: MMAA de la caja. No inventar 0000.
-- 14 altas stock 0 + 3 ya existían (Pert oliva, Listerine Care/Zero).
-- Fotos en public/catalogo-propia/ (URLs tras deploy).
-- SIN bloques dollar-quote. Idempotente mientras el ticket siga en borrador.
-- Pegar TODO este archivo en Supabase → SQL Editor → Run.

begin;

create temp table _fc_cm_20260912 (
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
  ya boolean not null,
  imagen text,
  foto_file text
) on commit drop;

insert into _fc_cm_20260912 (
  linea, ean, sku, nombre, snap, qty, costo, precio, tipo, categoria,
  subcategoria, forma, marca, laboratorio, presentacion, ya, imagen, foto_file
) values
{",".join(chr(10) + v for v in vals)};

insert into public.productos (
  nombre, sku, codigo_barras, categoria, subcategoria, tipo, descripcion,
  costo, precio, stock, stock_minimo, activo, requiere_receta,
  marca, presentacion, forma_farmaceutica, laboratorio,
  imagen_url, imagen_mobile_url
)
select
  t.nombre,
  case
    when exists (
      select 1 from public.productos p
      where p.sku = t.sku and coalesce(p.codigo_barras, '') <> t.ean
    ) then 'FC-CM-' || right(t.ean, 8)
    else t.sku
  end,
  t.ean,
  t.categoria,
  t.subcategoria,
  t.tipo,
  'Alta City Mark {FOLIO} · {FECHA} · listo para pistola',
  t.costo,
  t.precio,
  0,
  1,
  true,
  false,
  t.marca,
  t.presentacion,
  t.forma,
  t.laboratorio,
  t.imagen,
  t.imagen
from _fc_cm_20260912 t
where public.fc_buscar_producto_escaneo(t.ean) is null;

update public.productos p
set
  costo = t.costo,
  precio = case
    when coalesce(p.precio, 0) <= 0 then t.precio
    else p.precio
  end
from _fc_cm_20260912 t
where p.id = public.fc_buscar_producto_escaneo(t.ean)
  and (
    p.costo is distinct from t.costo
    or coalesce(p.precio, 0) <= 0
  );

update public.productos p
set
  marca = coalesce(nullif(trim(p.marca), ''), t.marca),
  presentacion = coalesce(nullif(trim(p.presentacion), ''), t.presentacion),
  laboratorio = coalesce(nullif(trim(p.laboratorio), ''), t.laboratorio),
  subcategoria = coalesce(nullif(trim(p.subcategoria), ''), t.subcategoria),
  imagen_url = coalesce(nullif(trim(p.imagen_url), ''), t.imagen),
  imagen_mobile_url = coalesce(nullif(trim(p.imagen_mobile_url), ''), t.imagen)
from _fc_cm_20260912 t
where p.id = public.fc_buscar_producto_escaneo(t.ean);

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  {sql_str(PROVEEDOR)},
  {sql_str(FOLIO)},
  {sql_str(FECHA)},
  {TOTAL:.2f},
  'borrador',
  {sql_str(notas)}
where not exists (
  select 1 from public.recepciones
  where folio = {sql_str(FOLIO)} and coalesce(proveedor, '') ilike '%city mark%'
);

update public.recepciones
set
  total_ticket = {TOTAL:.2f},
  fecha = {sql_str(FECHA)},
  proveedor = {sql_str(PROVEEDOR)},
  notas = {sql_str(notas)},
  updated_at = now()
where folio = {sql_str(FOLIO)}
  and coalesce(proveedor, '') ilike '%city mark%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = {sql_str(FOLIO)}
  and coalesce(r.proveedor, '') ilike '%city mark%'
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
from _fc_cm_20260912 t
join public.recepciones r
  on r.folio = {sql_str(FOLIO)}
 and coalesce(r.proveedor, '') ilike '%city mark%'
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
from _fc_cm_20260912 t
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
where r.folio = {sql_str(FOLIO)} and coalesce(r.proveedor, '') ilike '%city mark%'
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
    data = rows_rx()
    out_csv = ROOT / "sql" / "generated" / f"ticket_citymark_{FOLIO}.csv"
    out_rx = ROOT / "sql" / f"patch_recepcion_citymark_{FOLIO}.sql"
    out_carga = ROOT / "sql" / f"patch_carga_citymark_{FOLIO}.sql"

    missing = []
    for r in ROWS:
        if r.get("foto"):
            p = ROOT / "public" / "catalogo-propia" / r["foto"]
            if not p.exists() or p.stat().st_size < 3000:
                missing.append(str(p))
    if missing:
        raise SystemExit("faltan fotos: " + ", ".join(missing))

    write_ticket_csv(out_csv, folio=FOLIO, fecha=FECHA, proveedor=PROVEEDOR, total=TOTAL, rows=data)
    write_recepcion_sql(
        out_rx,
        folio=FOLIO,
        proveedor=PROVEEDOR,
        proveedor_ilike=PROVEEDOR_ILIKE,
        fecha=FECHA,
        total=TOTAL,
        notas=(
            f"Pedido City Mark {FOLIO} · ticket PUBLICO EN GENERAL · "
            "encabezado cortado (folio/fecha estimados 12-sep-2026) · "
            "EAN del ticket · cola Recibir; stock al confirmar pistola · "
            "altas con ficha+foto en catalogo-propia"
        ),
        rows=data,
    )
    write_carga_sql(out_carga)

    suma = sum(r["sub"] for r in data)
    piezas = sum(r["qty"] for r in data)
    altas = sum(1 for r in ROWS if not r["ya"])
    print(report(data, TOTAL))
    print(f"piezas={piezas} esperado=22 ok={piezas == 22}")
    print(f"lineas={len(data)} esperado=17 ok={len(data) == 17}")
    print(f"altas={altas} ya={len(ROWS) - altas}")
    print(f"suma=${suma:.2f} total=${TOTAL:.2f} delta={suma - TOTAL:.2f}")
    print(f"csv={out_csv}")
    print(f"carga={out_carga}")
    print(f"rx={out_rx}")
    if piezas != 22 or len(data) != 17 or abs(suma - TOTAL) >= 0.02:
        raise SystemExit("totales no cuadran")


if __name__ == "__main__":
    main()
