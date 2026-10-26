#!/usr/bin/env python3
# NO pegar este archivo en Supabase. Genera el SQL; el que se corre es:
#   sql/patch_carga_levic_9012442706.sql
"""Factura Levic A 9012442706 (CFDI 12-oct-2026) → CSV Recibir + SQL.

11 renglones · TOT 25 pzas. Costo = Precio neto.
IVA $13.33 solo de Seltz Magnesio Complex.
Lote de fábrica sí viene. Caducidad del papel NO se escribe: MMAA de la caja.
Nombres de mostrador desde packshot Visoti / ficha, no el código del ticket.
"""
from __future__ import annotations

import math
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from generar_recepcion_borrador import report, sql_str

ROOT = Path(__file__).resolve().parents[1]
OUT_TICKET = ROOT / "sql" / "generated" / "ticket_levic_9012442706.csv"
OUT_SQL = ROOT / "sql" / "patch_carga_levic_9012442706.sql"
OUT_FOTOS = ROOT / "sql" / "patch_fotos_levic_9012442706.sql"

FOLIO = "9012442706"
PROVEEDOR = "Levic"
FECHA = "2026-10-12"
SUBTOTAL_CFDI = 930.48
IVA_CFDI = 13.33  # Seltz Magnesio Complex
TOTAL_TICKET = 943.81
ENTREGA = "833148360"
FOTO_BASE = "https://www.farmacapital.mx/catalogo-propia"


def ceil_pvp(costo: float, tipo: str) -> int:
    factor = 1.25 if tipo == "marca" else 1.6
    return int(math.ceil(costo * factor))


def sku_ean(ean: str) -> str:
    return "FC-" + ean[-8:]


ROWS = [
    {
        "clave": "ALP0609",
        "ean": "7501384541620",
        "sku": sku_ean("7501384541620"),
        "nombre": "Gabapentina 400 mg",
        "desc_ticket": "GABAPENTINA 15 CAPS 400 MG",
        "qty": 1,
        "pu": 54.16,
        "sub": 54.16,
        "lote": "6080726",
        "caducidad": "2028-07-30",
        "match": False,
        "categoria": "Medicamentos",
        "tipo": "generico",
        "marca": "Psicofarma",
        "presentacion": "Caja con 15 cápsulas",
        "principio": "Gabapentina",
        "concentracion": "400 mg",
        "forma": "Cápsulas",
        "receta": True,
        "stock_minimo": 1,
        "foto": "gabapentina-psicofarma-400-7501384541620.jpg",
    },
    {
        "clave": "ALP0675",
        "ean": None,
        "sku": "EQ-ALP0675",
        "nombre": "Rosuvastatina 20 mg",
        "desc_ticket": "ROSUVASTATINA 15 TAB 20 MG",
        "qty": 1,
        "pu": 43.85,
        "sub": 43.85,
        "lote": "2609123",
        "caducidad": "2028-09-30",
        "match": False,
        "categoria": "Medicamentos",
        "tipo": "generico",
        "marca": "Alpharma",
        "presentacion": "Caja con 15 tabletas",
        "principio": "Rosuvastatina",
        "concentracion": "20 mg",
        "forma": "Tabletas",
        "receta": True,
        "stock_minimo": 1,
        "foto": "rosuvastatina-alpharma-20mg-15tab.jpg",
    },
    {
        "clave": "AMS322",
        "ean": "7501349021181",
        "sku": "EQ-AMS322",
        "nombre": "Cefalexina 500 mg",
        "desc_ticket": "CEFALEXINA 20 CAP 500 MG",
        "qty": 4,
        "pu": 39.58,
        "sub": 158.32,
        "lote": "J26A067",
        "caducidad": "2028-04-30",
        "match": True,
        "categoria": "Medicamentos",
        "tipo": "generico",
        "marca": "AMSA",
        "presentacion": "Caja con 20 cápsulas",
        "principio": "Cefalexina",
        "concentracion": "500 mg",
        "forma": "Cápsulas",
        "receta": True,
        "stock_minimo": 2,
        "foto": "cefalexina-amsa-500-7501349021181.jpg",
    },
    {
        "clave": "AMS329",
        "ean": "7501349020436",
        "sku": sku_ean("7501349020436"),
        "nombre": "Gabapentina 300 mg",
        "desc_ticket": "GABAPENTINA 15 CAPS 300 MG",
        "qty": 2,
        "pu": 23.27,
        "sub": 46.54,
        "lote": "U26E313",
        "caducidad": "2028-01-30",
        "match": False,
        "categoria": "Medicamentos",
        "tipo": "generico",
        "marca": "AMSA",
        "presentacion": "Caja con 15 cápsulas",
        "principio": "Gabapentina",
        "concentracion": "300 mg",
        "forma": "Cápsulas",
        "receta": True,
        "stock_minimo": 2,
        "foto": "gabapentina-amsa-300-7501349020436.jpg",
    },
    {
        "clave": "BEA394",
        "ean": "7501342803715",
        "sku": sku_ean("7501342803715"),
        "nombre": "Telmisartán 40 mg",
        "desc_ticket": "TELMISARTAN 30 TAB 40MG",
        "qty": 2,
        "pu": 39.35,
        "sub": 78.70,
        "lote": "U26F330",
        "caducidad": "2028-02-28",
        "match": False,
        "categoria": "Medicamentos",
        "tipo": "generico",
        "marca": "beadvance",
        "presentacion": "Caja con frasco con 30 tabletas",
        "principio": "Telmisartán",
        "concentracion": "40 mg",
        "forma": "Tabletas",
        "receta": True,
        "stock_minimo": 2,
        "foto": "telmisartan-beadvance-40-7501342803715.jpg",
    },
    {
        "clave": "CHI055",
        "ean": "7501088505485",
        "sku": sku_ean("7501088505485"),
        "nombre": "Synalar-O",
        "desc_ticket": "SYNALAR-OTICO 1 SOL 15 ML",
        "qty": 1,
        "pu": 188.05,
        "sub": 188.05,
        "lote": "BEK048",
        "caducidad": "2027-10-30",
        "match": False,
        "categoria": "Medicamentos",
        "tipo": "marca",
        "marca": "Synalar-O",
        "presentacion": "Frasco gotero 15 mL",
        "principio": "Fluocinolona / lidocaína / neomicina / polimixina B",
        "concentracion": "0.25 mg/mL",
        "forma": "Solución ótica",
        "receta": False,
        "stock_minimo": 1,
        "foto": "synalar-otico-15ml-7501088505485.jpg",
    },
    {
        "clave": "GEN002",
        "ean": "7501842900105",
        "sku": sku_ean("7501842900105"),
        "nombre": "Adopren 600 mg",
        "desc_ticket": "ADOPREN 10 TAB 600 MG",
        "qty": 5,
        "pu": 15.93,
        "sub": 79.65,
        "lote": "602015A",
        "caducidad": "2028-08-13",
        "match": False,
        "categoria": "Medicamentos",
        "tipo": "marca",
        "marca": "Adopren",
        "presentacion": "Caja con 10 tabletas",
        "principio": "Ibuprofeno",
        "concentracion": "600 mg",
        "forma": "Tabletas",
        "receta": False,
        "stock_minimo": 4,
        "foto": "adopren-600-7501842900105.jpg",
    },
    {
        "clave": "GEN003",
        "ean": "7501842952890",
        "sku": sku_ean("7501842952890"),
        "nombre": "Adopren 800 mg",
        "desc_ticket": "ADOPREN 10 TAB 800 MG",
        "qty": 3,
        "pu": 19.60,
        "sub": 58.80,
        "lote": "603025A",
        "caducidad": "2028-09-02",
        "match": False,
        "categoria": "Medicamentos",
        "tipo": "marca",
        "marca": "Adopren",
        "presentacion": "Caja con 10 tabletas",
        "principio": "Ibuprofeno",
        "concentracion": "800 mg",
        "forma": "Tabletas",
        "receta": False,
        "stock_minimo": 2,
        "foto": "adopren-800-7501842952890.jpg",
    },
    {
        "clave": "NOV125",
        "ean": "7501075721249",
        "sku": sku_ean("7501075721249"),
        "nombre": "Natrazim 40 mg",
        "desc_ticket": "NATRAZIM 14 TAB 40 MG",
        "qty": 2,
        "pu": 21.73,
        "sub": 43.46,
        "lote": "881976",
        "caducidad": "2028-06-01",
        "match": False,
        "categoria": "Medicamentos",
        "tipo": "marca",
        "marca": "Natrazim",
        "presentacion": "Caja con 14 tabletas",
        "principio": "Telmisartán",
        "concentracion": "40 mg",
        "forma": "Tabletas",
        "receta": True,
        "stock_minimo": 2,
        "foto": "natrazim-40-7501075721249.jpg",
    },
    {
        "clave": "SET021",
        "ean": None,
        "sku": "EQ-SET021",
        "nombre": "Magnesio Complex",
        "desc_ticket": "MAGNESIO COMPLEX 20 TAB 84G",
        "qty": 1,
        "pu": 83.34,
        "sub": 83.34,
        "lote": "L60639",
        "caducidad": "2029-03-31",
        "match": False,
        "categoria": "Suplementos",
        "tipo": "marca",
        "marca": "Seltz",
        "presentacion": "20 tabletas efervescentes",
        "principio": "Bisglicinato / citrato / malato de magnesio",
        "concentracion": None,
        "forma": "Tabletas efervescentes",
        "receta": False,
        "stock_minimo": 1,
        "foto": "seltz-magnesio-complex-20tab.jpg",
    },
    {
        "clave": "VIT068",
        "ean": "7501478316813",
        "sku": "EQ-VIT068",
        "nombre": "Ibuprofeno cafeína 400/100 mg",
        "desc_ticket": "IBUPRO-CAFE 10 CAPS 400 MG/100 MG",
        "qty": 3,
        "pu": 31.87,
        "sub": 95.61,
        "lote": "M26091",
        "caducidad": "2028-04-30",
        "match": True,
        "categoria": "Medicamentos",
        "tipo": "marca",
        "marca": "Gel Pharma",
        "presentacion": "Caja con 10 cápsulas",
        "principio": "Ibuprofeno / cafeína",
        "concentracion": "400 mg / 100 mg",
        "forma": "Cápsulas",
        "receta": False,
        "stock_minimo": 2,
        "foto": "ibuprofeno-cafeina-gelpharma-7501478316813.jpg",
    },
]


def foto_url(r: dict) -> str:
    return f"{FOTO_BASE}/{r['foto']}"


def write_sql() -> None:
    notas = (
        f"Factura Levic A {FOLIO} · entrega {ENTREGA} · PUE efectivo ${TOTAL_TICKET:.2f} · "
        "cola Recibir; stock al confirmar pistola · lote de fábrica en el papel; MMAA de la caja"
    )
    vals = []
    for i, r in enumerate(ROWS, start=1):
        vals.append(
            "  ({linea}, {clave}, {ean}, {sku}, {nombre}, {snap}, {qty}, {costo}, {precio}, "
            "{tipo}, {cat}, {forma}, {marca}, {pres}, {pa}, {conc}, {receta}, {smin}, "
            "{lote}, {foto}, {foto_file})".format(
                linea=i,
                clave=sql_str(r["clave"]),
                ean=sql_str(r["ean"]),
                sku=sql_str(r["sku"]),
                nombre=sql_str(r["nombre"]),
                snap=sql_str(r["nombre"]),
                qty=int(r["qty"]),
                costo=f"{r['pu']:.2f}",
                precio=ceil_pvp(r["pu"], r["tipo"]),
                tipo=sql_str(r["tipo"]),
                cat=sql_str(r["categoria"]),
                forma=sql_str(r["forma"]),
                marca=sql_str(r["marca"]),
                pres=sql_str(r["presentacion"]),
                pa=sql_str(r["principio"]),
                conc=sql_str(r["concentracion"]),
                receta="true" if r["receta"] else "false",
                smin=r["stock_minimo"],
                lote=sql_str(r["lote"]),
                foto=sql_str(foto_url(r)),
                foto_file=sql_str(f"catalogo-propia/{r['foto']}"),
            )
        )

    body = f"""-- Levic · factura interna A {FOLIO} · CFDI {FECHA} · entrega {ENTREGA}
-- Receptor LUIS ANGEL PALILLERO VENTURA · {len(ROWS)} renglones · {sum(r['qty'] for r in ROWS)} pzas (TOT 25).
-- Subtotal ${SUBTOTAL_CFDI:.2f} + IVA ${IVA_CFDI:.2f} (Seltz Magnesio Complex) = ${TOTAL_TICKET:.2f}.
-- Costo = Precio neto. Lote = de fábrica. Caducidad del papel NO se escribe (MMAA de la caja).
-- 0000 es inválido. Altas stock 0. En existentes solo costo (no el PVP).
-- Nombres de packshot Visoti, no del renglón del ticket.
-- SIN bloques dollar-quote. Idempotente mientras el ticket siga en borrador.
-- Pegar TODO este archivo en Supabase → SQL Editor → Run.
-- Tras deploy Vercel: sql/patch_fotos_levic_9012442706.sql

begin;

create temp table _fc_rx_levic9012442706 (
  linea integer primary key,
  clave text not null,
  ean text,
  sku text not null,
  nombre text not null,
  snap text not null,
  qty integer not null,
  costo numeric(12,2) not null,
  precio numeric(12,2) not null,
  tipo text not null,
  categoria text not null,
  forma text,
  marca text,
  presentacion text,
  principio_activo text,
  concentracion text,
  receta boolean not null,
  stock_minimo integer not null,
  lote text,
  imagen text,
  foto_file text
) on commit drop;

insert into _fc_rx_levic9012442706 (
  linea, clave, ean, sku, nombre, snap, qty, costo, precio, tipo, categoria,
  forma, marca, presentacion, principio_activo, concentracion, receta,
  stock_minimo, lote, imagen, foto_file
) values
{chr(10).join(v + ("," if i < len(vals) - 1 else ";") for i, v in enumerate(vals))}

insert into public.productos (
  nombre, sku, codigo_barras, categoria, tipo, descripcion,
  costo, precio, stock, stock_minimo, activo, requiere_receta,
  marca, presentacion, forma_farmaceutica, principio_activo, concentracion,
  imagen_url, imagen_mobile_url
)
select
  t.nombre,
  case
    when exists (
      select 1 from public.productos p
      where p.sku = t.sku
        and coalesce(p.codigo_barras, '') is distinct from coalesce(t.ean, '')
    ) then 'FC-ND-' || right(coalesce(t.ean, replace(t.sku, 'EQ-', '')), 8)
    else t.sku
  end,
  nullif(t.ean, ''),
  t.categoria,
  t.tipo,
  'Factura Levic {FOLIO} · clave ' || t.clave || ' · lote ' || coalesce(t.lote, ''),
  t.costo,
  t.precio,
  0,
  t.stock_minimo,
  true,
  t.receta,
  t.marca,
  t.presentacion,
  t.forma,
  t.principio_activo,
  t.concentracion,
  t.imagen,
  t.imagen
from _fc_rx_levic9012442706 t
where coalesce(
        public.fc_buscar_producto_escaneo(nullif(t.ean, '')),
        public.fc_buscar_producto_escaneo(t.sku)
      ) is null;

update public.productos p
set
  costo = t.costo,
  stock_minimo = greatest(coalesce(p.stock_minimo, 0), t.stock_minimo),
  codigo_barras = coalesce(nullif(p.codigo_barras, ''), nullif(t.ean, '')),
  precio = case when coalesce(p.precio, 0) <= 0 then t.precio else p.precio end
from _fc_rx_levic9012442706 t
where p.id = coalesce(
  public.fc_buscar_producto_escaneo(nullif(t.ean, '')),
  public.fc_buscar_producto_escaneo(t.sku)
);

update public.productos p
set
  marca = coalesce(nullif(trim(p.marca), ''), t.marca),
  presentacion = coalesce(nullif(trim(p.presentacion), ''), t.presentacion),
  principio_activo = coalesce(nullif(trim(p.principio_activo), ''), t.principio_activo),
  concentracion = coalesce(nullif(trim(p.concentracion), ''), t.concentracion),
  forma_farmaceutica = coalesce(nullif(trim(p.forma_farmaceutica), ''), t.forma)
from _fc_rx_levic9012442706 t
where p.id = coalesce(
  public.fc_buscar_producto_escaneo(nullif(t.ean, '')),
  public.fc_buscar_producto_escaneo(t.sku)
);

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  {sql_str(PROVEEDOR)},
  {sql_str(FOLIO)},
  {sql_str(FECHA)},
  {TOTAL_TICKET:.2f},
  'borrador',
  {sql_str(notas)}
where not exists (
  select 1 from public.recepciones
  where folio = {sql_str(FOLIO)} and coalesce(proveedor, '') ilike '%levic%'
);

update public.recepciones
set
  total_ticket = {TOTAL_TICKET:.2f},
  fecha = {sql_str(FECHA)},
  proveedor = {sql_str(PROVEEDOR)},
  notas = {sql_str(notas)},
  updated_at = now()
where folio = {sql_str(FOLIO)}
  and coalesce(proveedor, '') ilike '%levic%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = {sql_str(FOLIO)}
  and coalesce(r.proveedor, '') ilike '%levic%'
  and r.estado = 'borrador';

insert into public.recepcion_items (
  recepcion_id, producto_id, codigo_escaneado, nombre_snapshot,
  cantidad, fecha_caducidad, numero_lote, costo_estimado, pendiente_alta,
  origen, confirmado, lote_distinto, lote_id
)
select
  r.id,
  v.pid,
  coalesce(nullif(t.ean, ''), t.sku),
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
        and l.numero_lote is distinct from t.lote
    )
  ),
  null
from _fc_rx_levic9012442706 t
join public.recepciones r
  on r.folio = {sql_str(FOLIO)}
 and coalesce(r.proveedor, '') ilike '%levic%'
 and r.estado = 'borrador'
left join lateral (
  select coalesce(
    public.fc_buscar_producto_escaneo(nullif(t.ean, '')),
    public.fc_buscar_producto_escaneo(t.sku)
  ) as pid
) v on true
order by t.linea;

commit;

select
  i.id,
  i.codigo_escaneado as ean,
  left(i.nombre_snapshot, 48) as nombre,
  i.cantidad,
  i.costo_estimado,
  i.numero_lote,
  case when i.pendiente_alta then 'ALTA NUEVA' else 'YA EXISTE' end as estado
from public.recepcion_items i
join public.recepciones r on r.id = i.recepcion_id
where r.folio = {sql_str(FOLIO)} and coalesce(r.proveedor, '') ilike '%levic%'
order by i.id;
"""
    OUT_SQL.write_text(body, encoding="utf-8")

    foto_lines = [
        f"-- Fotos Levic A {FOLIO} — pegar DESPUÉS del deploy de public/catalogo-propia/",
        "-- Solo rellena si imagen_url está vacía (no pisa foto mejor).",
        "",
        "begin;",
        "",
    ]
    for r in ROWS:
        url = foto_url(r)
        if r["ean"]:
            where = f"codigo_barras = {sql_str(r['ean'])}"
        else:
            where = f"sku = {sql_str(r['sku'])}"
        foto_lines += [
            "update public.productos",
            f"set imagen_url = {sql_str(url)},",
            f"    imagen_mobile_url = coalesce(nullif(imagen_mobile_url, ''), {sql_str(url)}),",
            "    updated_at = now()",
            f"where {where}",
            "  and coalesce(nullif(imagen_url, ''), '') = '';",
            "",
        ]
    foto_lines += ["commit;", ""]
    OUT_FOTOS.write_text("\n".join(foto_lines), encoding="utf-8")


if __name__ == "__main__":
    for r in ROWS:
        assert abs(r["pu"] * r["qty"] - r["sub"]) < 0.02, r
        assert "C/1" not in r["nombre"] and "15 CAPS" not in r["nombre"]
    suma = sum(r["sub"] for r in ROWS)
    assert abs(suma - SUBTOTAL_CFDI) < 0.02, (suma, SUBTOTAL_CFDI)
    assert abs(suma + IVA_CFDI - TOTAL_TICKET) < 0.02
    assert sum(r["qty"] for r in ROWS) == 25
    skus = [r["sku"] for r in ROWS]
    assert len(skus) == len(set(skus)), skus

    csv_rows = [
        {
            "ean": r["ean"] or "",
            "nombre": r["desc_ticket"],
            "qty": r["qty"],
            "pu": r["pu"],
            "sub": r["sub"],
            "sku": r["sku"],
            "match": "recibir" if r["match"] else "alta",
        }
        for r in ROWS
    ]
    # CSV extra clave/lote: write custom
    OUT_TICKET.parent.mkdir(parents=True, exist_ok=True)
    import csv
    with OUT_TICKET.open("w", newline="", encoding="utf-8") as fh:
        w = csv.writer(fh)
        w.writerow([
            "linea", "folio", "fecha", "proveedor", "ean", "clave_levic",
            "descripcion_ticket", "cantidad", "precio_unitario", "subtotal",
            "lote", "caducidad", "sku_farmacapital", "total_ticket", "match",
        ])
        for i, r in enumerate(ROWS, start=1):
            w.writerow([
                i, FOLIO, FECHA, PROVEEDOR, r["ean"] or "", r["clave"],
                r["desc_ticket"], r["qty"], f"{r['pu']:.2f}", f"{r['sub']:.2f}",
                r["lote"], r["caducidad"], r["sku"], f"{TOTAL_TICKET:.2f}",
                "recibir" if r["match"] else "alta",
            ])
    write_sql()
    print(f"csv  {OUT_TICKET}")
    print(f"sql  {OUT_SQL}")
    print(f"fotos {OUT_FOTOS}")
    print(report(csv_rows, TOTAL_TICKET))
    print(
        f"productos ${suma:.2f} + IVA ${IVA_CFDI:.2f} = ${suma + IVA_CFDI:.2f} "
        f"(CFDI ${TOTAL_TICKET:.2f})"
    )
    print(f"altas {sum(1 for r in ROWS if not r['match'])}  recibir {sum(1 for r in ROWS if r['match'])}")
    print(f"piezas {sum(r['qty'] for r in ROWS)}")
    for r in ROWS:
        print(
            f"  {r['clave']:7} {(r['ean'] or 'sin-ean'):13}  {r['qty']}×{r['pu']:.2f}  "
            f"PVP {ceil_pvp(r['pu'], r['tipo'])}  "
            f"{'ya' if r['match'] else 'ALTA'}  {r['nombre']}"
        )
