#!/usr/bin/env python3
"""Tickets 07-nov-2026 (fotos térmicas) → altas + cola Recibir.

3 pedidos del mismo día (cliente Palillero / Bodega F-42):
  1) Equilibrio 450987 · Iztapalapa 2 · pedido online · $697.11
  2) Cityfarma Iztapalapa S338883 · $1,884.14
  3) Bodega F-42 Caja 2/86837 · $451.12

Equilibrio: costo = P.U. neto tras descuento; lote de fábrica sí; caducidad NO.
Cityfarma / Bodega: P.U. del papel (suma renglones = total); sin lote en cola.
Nombres de mostrador (ficha), no el código truncado del ticket.
Sin caducidad inventada (MMAA de la caja). Sin producto_imagenes en el txn.
"""
from __future__ import annotations

import csv
import math
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
OUT_SQL = ROOT / "sql" / "patch_recepciones_tickets_20261107_SOLO_pegar_esto.sql"
OUT_MD = ROOT / "sql" / "LEERME_tickets_20261107.md"
GEN = ROOT / "sql" / "generated"
FOTO = "https://www.farmacapital.mx/catalogo-propia"


def ceil_pvp(costo: float, tipo: str) -> int:
    factor = 1.25 if tipo == "marca" else 1.6
    return int(math.ceil(costo * factor))


def sku_fc(ean: str) -> str:
    digits = "".join(c for c in ean if c.isdigit())
    return "FC-" + digits[-8:]


def sql_str(s: str | None) -> str:
    if s is None:
        return "null"
    return "'" + str(s).replace("'", "''") + "'"


def row(
    *,
    ticket: str,
    ean: str,
    snap: str,
    nombre: str,
    qty: int,
    pu: float,
    sku: str | None = None,
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
    ya: bool = True,
    lote: str | None = None,
    foto: str | None = None,
) -> dict:
    return {
        "ticket": ticket,
        "ean": ean,
        "sku": sku or sku_fc(ean),
        "snap": snap,
        "nombre": nombre,
        "qty": qty,
        "pu": round(pu, 2),
        "sub": round(pu * qty, 2),
        "precio": ceil_pvp(pu, tipo),
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
        "lote": lote,
        "foto": f"{FOTO}/{foto}" if foto else None,
        "match": "ya" if ya else "alta",
    }


# ── Equilibrio 450987 ──────────────────────────────────────────────
EQ = [
    row(
        ticket="equilibrio",
        ean="7502211786788",
        sku="EQ-LOE096",
        snap="LOE096 VILADOL PLUS 20 TAB 10/500 MG",
        nombre="Vidalol Plus",
        qty=5,
        pu=47.91,
        lote="R2606704",
        tipo="generico",
        subcategoria="Gastro",
        forma="Tableta",
        marca="Vidalol",
        laboratorio="Loeffler",
        presentacion="Caja con 20 tabletas",
        principio="Butilhioscina / paracetamol",
        concentracion="10/500 mg",
        receta=True,
        ya=True,
    ),
    row(
        ticket="equilibrio",
        ean="7501349022515",
        sku="FC-22B18244",
        snap="AMS263 CEFOTAXIMA I.M. 1 FA 1G/4 ML",
        nombre="Cefotaxima IM 1 g",
        qty=3,
        pu=33.23,
        lote="J26M085",
        tipo="generico",
        subcategoria="Antibióticos",
        forma="Solución inyectable",
        marca="AMSA",
        laboratorio="AMSA",
        presentacion="Frasco ámpula con diluyente 4 ml",
        principio="Cefotaxima",
        concentracion="1 g / 4 ml",
        receta=True,
        ya=True,
    ),
    row(
        ticket="equilibrio",
        ean="7502009747281",
        sku="FC-09747281",
        snap="MAV343 DOLVER 10 TAB 800 MG",
        nombre="Dolver ibuprofeno 800 mg",
        qty=5,
        pu=20.79,
        lote="261657",
        tipo="generico",
        categoria="Analgésico",
        forma="Tableta",
        marca="Dolver",
        laboratorio="Maver",
        presentacion="Caja con 10 tabletas",
        principio="Ibuprofeno",
        concentracion="800 mg",
        receta=False,
        ya=False,
        # TODO packshot Dolver 800 mg C/10 (EAN 7502009747281)
    ),
    row(
        ticket="equilibrio",
        ean="7502001161511",
        sku="EQ-SON024",
        snap="SON024 BENTIX 1 CMA 40G 3/0.0 %",
        nombre="Bentix",
        qty=3,
        pu=29.20,
        lote="26071952",
        tipo="generico",
        subcategoria="Dermatológico",
        forma="Crema",
        marca="Bentix",
        laboratorio="Son's",
        presentacion="Tubo 40 g",
        principio="Clioquinol / fluocinolona",
        concentracion="3% / 0.01%",
        receta=True,
        ya=True,
    ),
    row(
        ticket="equilibrio",
        ean="7502001160019",
        sku="EQ-SON033",
        snap="SON033 BUSCONET 1 FA 250/20MG/5ML",
        nombre="Busconet inyectable",
        qty=3,
        pu=35.57,
        lote="26051306",
        tipo="generico",
        subcategoria="Gastro",
        forma="Solución inyectable",
        marca="Busconet",
        laboratorio="Son's",
        presentacion="Frasco ámpula 5 ml",
        principio="Metamizol sódico / butilhioscina",
        concentracion="250/20 mg / 5 ml",
        receta=True,
        ya=True,
        foto="busconet-inyectable-5ml.jpg",
    ),
    row(
        ticket="equilibrio",
        ean="7501349012004",
        sku="FC-BE76D409",
        snap="AMS004 AMCEF I.M. 1 FA 1G/3.5 ML",
        nombre="Amcef IM 1 g",
        qty=3,
        pu=19.87,
        lote="J25N051",
        tipo="generico",
        subcategoria="Antibióticos",
        forma="Solución inyectable",
        marca="Amcef",
        laboratorio="AMSA",
        presentacion="Frasco ámpula con diluyente 3.5 ml",
        principio="Ceftriaxona",
        concentracion="1 g / 3.5 ml",
        receta=True,
        ya=True,
    ),
]

# ── Cityfarma S338883 ──────────────────────────────────────────────
CF = [
    row(
        ticket="cityfarma",
        ean="7500462746698",
        sku="FC-62746698",
        snap="AJOLOTIUS REFORZADO",
        nombre="Ajolotius Reforzado",
        qty=2,
        pu=55.10,
        tipo="marca",
        categoria="Suplementos",
        forma="Jarabe",
        marca="Ajolotius",
        laboratorio="Bioalimentos",
        presentacion="Frasco 250 ml",
        principio=None,
        concentracion=None,
        receta=False,
        ya=True,
    ),
    row(
        ticket="cityfarma",
        ean="7502321440013",
        sku="FC-21440013",
        snap="BUSCAPINA DUO C10 TA",
        nombre="Buscapina Duo",
        qty=3,
        pu=106.44,
        tipo="marca",
        subcategoria="Gastro",
        forma="Tableta",
        marca="Buscapina",
        laboratorio="Sanofi",
        presentacion="Caja con 10 tabletas",
        principio="Hioscina / paracetamol",
        concentracion="10/500 mg",
        receta=False,
        ya=False,
    ),
    row(
        ticket="cityfarma",
        ean="7501070615277",
        sku="FC-70615277",
        snap="DAFLON 500M C 20 TAB",
        nombre="Daflon 500 mg",
        qty=1,
        pu=430.00,
        tipo="marca",
        subcategoria="Circulatorio",
        forma="Tableta",
        marca="Daflon",
        laboratorio="Sanfer",
        presentacion="Caja con 20 tabletas",
        principio="Diosmina / hesperidina",
        concentracion="450/50 mg",
        receta=False,
        ya=False,
    ),
    row(
        ticket="cityfarma",
        ean="7501075727890",
        sku="FC-75727890",
        snap="DUOSYM TRIMEBUTINA/S",
        nombre="Duosym",
        qty=2,
        pu=123.94,
        tipo="marca",
        subcategoria="Gastro",
        forma="Comprimido",
        marca="Duosym",
        laboratorio="Novag",
        presentacion="Caja con 24 comprimidos",
        principio="Trimebutina / simeticona",
        concentracion="200/75 mg",
        receta=False,
        ya=False,
    ),
    row(
        ticket="cityfarma",
        ean="7501064560163",
        sku="FC-64560163",
        snap="IODEX CRISTAL 24",
        nombre="Iodex Cristal",
        qty=1,
        pu=72.77,
        tipo="marca",
        categoria="Cuidado personal",
        subcategoria="Ungüento",
        forma="Ungüento",
        marca="Iodex",
        laboratorio="Haleon",
        presentacion="Tubo 60 g",
        principio="Mentol / eucalipto",
        concentracion=None,
        receta=False,
        ya=True,
    ),
    row(
        ticket="cityfarma",
        ean="7501300408259",
        sku="FC-00408259",
        snap="PLIDAN 10 MG C 20 CO",
        nombre="Plidan 10 mg",
        qty=1,
        pu=239.12,
        tipo="marca",
        subcategoria="Gastro",
        forma="Comprimido",
        marca="Plidan",
        laboratorio="Siegfried Rhein",
        presentacion="Caja con 20 comprimidos",
        principio="Pargeverina",
        concentracion="10 mg",
        receta=False,
        ya=False,
    ),
    row(
        ticket="cityfarma",
        ean="7501300408204",
        sku="FC-00408204",
        snap="PLIDAN COMPUESTO C20",
        nombre="Plidan Compuesto",
        qty=1,
        pu=253.08,
        tipo="marca",
        subcategoria="Gastro",
        forma="Comprimido",
        marca="Plidan",
        laboratorio="Siegfried Rhein",
        presentacion="Caja con 20 comprimidos",
        principio="Pargeverina / clonixinato de lisina",
        concentracion="10/125 mg",
        receta=False,
        ya=False,
    ),
    row(
        ticket="cityfarma",
        ean="7501349028364",
        sku="EQ-AMS279",
        snap="POPRAM 40MG C14 TABS",
        nombre="Popram pantoprazol 40 mg",
        qty=2,
        pu=27.93,
        tipo="generico",
        subcategoria="Gastro",
        forma="Tableta",
        marca="Popram",
        laboratorio="AMSA",
        presentacion="Caja con 14 tabletas",
        principio="Pantoprazol",
        concentracion="40 mg",
        receta=True,
        ya=True,
    ),
    row(
        ticket="cityfarma",
        ean="714908100228",
        sku="EQ-SAN025",
        snap="REVENOX 3MG C60 TABS",
        nombre="Revenox melatonina 3 mg",
        qty=1,
        pu=70.43,
        tipo="marca",
        categoria="Suplementos",
        forma="Tableta",
        marca="Revenox",
        laboratorio="Salud Natural",
        presentacion="Frasco con 60 tabletas",
        principio="Melatonina",
        concentracion="3 mg",
        receta=False,
        ya=True,
    ),
    row(
        ticket="cityfarma",
        ean="7501349029729",
        sku="FC-49029729",
        snap="TELMISARTAN HIDROCLO",
        nombre="Telmisartán / hidroclorotiazida 80/12.5 mg",
        qty=2,
        pu=42.74,
        tipo="generico",
        subcategoria="Cardiovascular",
        forma="Tableta",
        marca="AMSA",
        laboratorio="AMSA",
        presentacion="Caja con 14 tabletas",
        principio="Telmisartán / hidroclorotiazida",
        concentracion="80/12.5 mg",
        receta=True,
        ya=False,
    ),
]

# ── Bodega F-42 86837 ──────────────────────────────────────────────
BF = [
    row(
        ticket="bodega",
        ean="7501026462078",
        sku="FC-26462078",
        snap="TERNURA FLOR-BALON 18 PZS CHUPON CON MIEL",
        nombre="Ternura chupón flor-balón con miel",
        qty=1,
        pu=61.02,
        tipo="marca",
        categoria="Cuidado personal",
        subcategoria="Infantil",
        forma="Chupón",
        marca="Ternura",
        laboratorio="Ternura",
        presentacion="Exhibidor 18 piezas",
        receta=False,
        ya=True,
        foto="ternura-chupon-flor-balon-miel-18-7501026462078.jpg",
    ),
    row(
        ticket="bodega",
        ean="7501056342227",
        sku="FC-56342227",
        snap="CRA SEDAL RIZOS OBEDIENTES 135ML",
        nombre="Sedal Rizos Obedientes",
        qty=2,
        pu=17.965,
        tipo="marca",
        categoria="Cuidado personal",
        subcategoria="Cuidado capilar",
        forma="Crema para peinar",
        marca="Sedal",
        laboratorio="Unilever",
        presentacion="Tubo 135 ml",
        receta=False,
        ya=True,
    ),
    row(
        ticket="bodega",
        ean="7506306251373",
        sku="FC-06251373",
        snap="SEDAL 135ML CRA P/PEIN CERAMIDAS",
        nombre="Sedal Ceramidas",
        qty=2,
        pu=19.685,
        tipo="marca",
        categoria="Cuidado personal",
        subcategoria="Cuidado capilar",
        forma="Crema para peinar",
        marca="Sedal",
        laboratorio="Unilever",
        presentacion="Tubo 135 ml",
        receta=False,
        ya=False,
    ),
    row(
        ticket="bodega",
        ean="7506306258013",
        sku="FC-06258013",
        snap="CRA SEDAL P/PEI MEGA CRECIM 300ML",
        nombre="Sedal Mega Crecimiento",
        qty=1,
        pu=52.48,
        tipo="marca",
        categoria="Cuidado personal",
        subcategoria="Cuidado capilar",
        forma="Crema para peinar",
        marca="Sedal",
        laboratorio="Unilever",
        presentacion="Tubo 300 ml",
        receta=False,
        ya=False,
    ),
    row(
        ticket="bodega",
        ean="7506306224780",
        sku="FC-06224780",
        snap="CRA SEDAL P/PEI PREB+BIOTIN 300ML",
        nombre="Sedal Prebiótico + Biotina",
        qty=1,
        pu=50.07,
        tipo="marca",
        categoria="Cuidado personal",
        subcategoria="Cuidado capilar",
        forma="Crema para peinar",
        marca="Sedal",
        laboratorio="Unilever",
        presentacion="Tubo 300 ml",
        receta=False,
        ya=False,
    ),
    row(
        ticket="bodega",
        ean="7501056340025",
        sku="FC-56340025",
        snap="CRA SEDAL SOS RECON-ESTRU 300ML",
        nombre="Sedal SOS Restauración Instantánea",
        qty=1,
        pu=50.07,
        tipo="marca",
        categoria="Cuidado personal",
        subcategoria="Cuidado capilar",
        forma="Crema para peinar",
        marca="Sedal",
        laboratorio="Unilever",
        presentacion="Tubo 300 ml",
        receta=False,
        ya=True,
    ),
    row(
        ticket="bodega",
        ean="7506306210905",
        sku="FC-06210905",
        snap="CRA SEDAL P/PEI MICEL -ARROZ 300ML",
        nombre="Sedal Micelar Arroz",
        qty=1,
        pu=50.07,
        tipo="marca",
        categoria="Cuidado personal",
        subcategoria="Cuidado capilar",
        forma="Crema para peinar",
        marca="Sedal",
        laboratorio="Unilever",
        presentacion="Tubo 300 ml",
        receta=False,
        ya=False,
    ),
    row(
        ticket="bodega",
        ean="7501056340100",
        sku="FC-56340100",
        snap="CRA SEDAL ANTI SPONGE 300 ML",
        nombre="Sedal Anti-esponjado",
        qty=1,
        pu=50.07,
        tipo="marca",
        categoria="Cuidado personal",
        subcategoria="Cuidado capilar",
        forma="Crema para peinar",
        marca="Sedal",
        laboratorio="Unilever",
        presentacion="Tubo 300 ml",
        receta=False,
        ya=False,
    ),
    row(
        ticket="bodega",
        ean="7501086494262",
        sku="FC-86494262",
        snap="CEP DENT ORAL-B INDICAT35SVE",
        nombre="Oral-B Indicator 35 suave",
        qty=2,
        pu=31.02,
        tipo="marca",
        categoria="Cuidado personal",
        subcategoria="Higiene bucal",
        forma="Cepillo dental",
        marca="Oral-B",
        laboratorio="P&G",
        presentacion="1 pieza",
        receta=False,
        ya=True,
    ),
]

TICKETS_META = {
    "equilibrio": {
        "key": "equilibrio",
        "proveedor": "Equilibrio",
        "ilike": "equilibrio",
        "folio": "450987",
        "fecha": "2026-11-07",
        "total": 697.11,
        "notas": (
            "Ticket Equilibrio folio 450987 · cliente 307513 Luis Angel · "
            "pedido online Iztapalapa 2 · 07-nov-2026 15:01 · 22 pzas · $697.11 · "
            "lote de fábrica en renglón; MMAA de la caja · cola Recibir"
        ),
        "rows": EQ,
    },
    "cityfarma": {
        "key": "cityfarma",
        "proveedor": "Cityfarma Iztapalapa",
        "ilike": "cityfarma",
        "folio": "S338883",
        "fecha": "2026-11-07",
        "total": 1884.14,
        "notas": (
            "Ticket Cityfarma S338883 · 07-nov-2026 15:07 · cliente Luis Angel · "
            "vendedor Eduardo · $1,884.14 · cola Recibir; "
            "stock al confirmar pistola + MMAA"
        ),
        "rows": CF,
    },
    "bodega": {
        "key": "bodega",
        "proveedor": "Bodega F-42",
        "ilike": "bodega",
        "folio": "86837",
        "fecha": "2026-11-07",
        "total": 451.12,
        "notas": (
            "Ticket Bodega F-42 / Citymark · Caja 2/86837 · Ejidos del Moral · "
            "07-nov-2026 15:22 · 12 pzas · $451.12 · cola Recibir; "
            "stock al confirmar pistola + MMAA"
        ),
        "rows": BF,
    },
}


def validate() -> None:
    eq_pcs = sum(r["qty"] for r in EQ)
    assert eq_pcs == 22, eq_pcs
    assert abs(round(sum(r["sub"] for r in EQ), 2) - 697.11) < 0.02

    cf_pcs = sum(r["qty"] for r in CF)
    assert cf_pcs == 16, cf_pcs
    assert abs(round(sum(r["sub"] for r in CF), 2) - 1884.14) < 0.05

    # Subtotales impresos Bodega (P.U. a 3 decimales)
    bf_printed = [61.02, 35.93, 39.37, 52.48, 50.07, 50.07, 50.07, 50.07, 62.04]
    assert abs(round(sum(bf_printed), 2) - 451.12) < 0.02
    assert sum(r["qty"] for r in BF) == 12
    for r, printed in zip(BF, bf_printed, strict=True):
        r["sub"] = printed
        r["pu"] = round(printed / r["qty"], 4)

    for r in EQ + CF + BF:
        assert not r["nombre"].isupper(), r["nombre"]
        assert len(r["ean"]) >= 8, r["ean"]
        assert abs(r["pu"] * r["qty"] - r["sub"]) < 0.05, r


def sql_value_tuple(linea: int, r: dict) -> str:
    return (
        f"({sql_str(r['ticket'])}, {linea}, {sql_str(r['ean'])}, {sql_str(r['sku'])}, "
        f"{sql_str(r['nombre'])}, {sql_str(r['snap'])}, {r['qty']}, {r['pu']:.2f}, {r['precio']}, "
        f"{sql_str(r['tipo'])}, {sql_str(r['categoria'])}, {sql_str(r['subcategoria'])}, "
        f"{sql_str(r['forma'])}, {sql_str(r['marca'])}, {sql_str(r['laboratorio'])}, "
        f"{sql_str(r['presentacion'])}, {sql_str(r['principio'])}, {sql_str(r['concentracion'])}, "
        f"{'true' if r['receta'] else 'false'}, {'false' if r['ya'] else 'true'}, "
        f"{sql_str(r['foto'])}, {sql_str(r['lote'])})"
    )


def recepcion_block(meta: dict) -> str:
    folio = meta["folio"]
    ilike = meta["ilike"]
    key = meta["key"]
    lote_expr = "t.lote" if key == "equilibrio" else "null"
    return f"""
-- ── {meta['proveedor']} · {folio} ──
insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  {sql_str(meta['proveedor'])},
  {sql_str(folio)},
  {sql_str(meta['fecha'])},
  {meta['total']:.2f},
  'borrador',
  {sql_str(meta['notas'])}
where not exists (
  select 1 from public.recepciones
  where folio = {sql_str(folio)}
    and coalesce(proveedor, '') ilike {sql_str('%' + ilike + '%')}
);

update public.recepciones
set
  total_ticket = {meta['total']:.2f},
  fecha = {sql_str(meta['fecha'])},
  proveedor = {sql_str(meta['proveedor'])},
  notas = {sql_str(meta['notas'])},
  updated_at = now()
where folio = {sql_str(folio)}
  and coalesce(proveedor, '') ilike {sql_str('%' + ilike + '%')}
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = {sql_str(folio)}
  and coalesce(r.proveedor, '') ilike {sql_str('%' + ilike + '%')}
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
  {lote_expr},
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
from _fc_tk_20261107 t
join public.recepciones r
  on r.folio = {sql_str(folio)}
 and coalesce(r.proveedor, '') ilike {sql_str('%' + ilike + '%')}
 and r.estado = 'borrador'
left join lateral (
  select coalesce(
    public.fc_buscar_producto_escaneo(t.ean),
    public.fc_buscar_producto_escaneo(t.sku)
  ) as pid
) v on true
where t.ticket = {sql_str(key)}
order by t.linea;
"""


def write_sql() -> None:
    all_rows: list[dict] = []
    values: list[str] = []
    linea_global = 0
    for key in ("equilibrio", "cityfarma", "bodega"):
        for i, r in enumerate(TICKETS_META[key]["rows"], start=1):
            linea_global += 1
            # per-ticket linea for ordering within ticket
            values.append(sql_value_tuple(i, r))
            all_rows.append(r)

    body_vals = ",\n".join(values)
    blocks = "\n".join(recepcion_block(TICKETS_META[k]) for k in ("equilibrio", "cityfarma", "bodega"))

    sql = f"""-- =============================================================================
-- PEGAR TODO ESTE ARCHIVO en Supabase → SQL Editor → Run
-- Tickets 07-nov-2026 → cola Recibir (borrador)
--
-- 1) Equilibrio · 450987 · $697.11 · 6 renglones / 22 pzas
-- 2) Cityfarma Iztapalapa · S338883 · $1,884.14 · 10 renglones / 16 pzas
-- 3) Bodega F-42 · 86837 · $451.12 · 9 renglones / 12 pzas
--
-- Merge a GitHub NO crea la tarjeta. Este Run sí.
-- Sin bloques dollar-quote. Sin galería extra. Idempotente en borrador.
-- Caducidad null (MMAA de la caja). No inventar 0000.
-- Equilibrio: lote de fábrica en renglón. Cityfarma/Bodega: lote null.
-- =============================================================================

begin;

create temp table _fc_tk_20261107 (
  ticket text not null,
  linea integer not null,
  ean text not null,
  sku text not null,
  nombre text not null,
  snap text not null,
  qty integer not null,
  costo numeric(12,2) not null,
  precio numeric(12,2) not null,
  tipo text,
  categoria text,
  subcategoria text,
  forma text,
  marca text,
  laboratorio text,
  presentacion text,
  principio_activo text,
  concentracion text,
  receta boolean,
  es_alta boolean not null default true,
  imagen text,
  lote text,
  primary key (ticket, linea)
) on commit drop;

insert into _fc_tk_20261107 (
  ticket, linea, ean, sku, nombre, snap, qty, costo, precio, tipo, categoria,
  subcategoria, forma, marca, laboratorio, presentacion, principio_activo,
  concentracion, receta, es_alta, imagen, lote
) values
{body_vals};

-- Altas (stock 0 hasta pistola)
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
      where p.sku = t.sku and coalesce(p.codigo_barras, '') is distinct from t.ean
    ) then 'FC-ND-' || right(t.ean, 8)
    else t.sku
  end,
  t.ean,
  coalesce(t.categoria, 'Medicamentos'),
  t.subcategoria,
  coalesce(t.tipo, 'generico'),
  'Alta ticket 07-nov-2026 · ' || t.ticket || ' · listo para pistola',
  t.costo,
  t.precio,
  0, 1, true, coalesce(t.receta, false),
  t.marca, t.presentacion, t.forma, t.principio_activo, t.concentracion, t.laboratorio,
  t.imagen, t.imagen
from (
  select distinct on (ean) *
  from _fc_tk_20261107
  where es_alta
  order by ean, linea
) t
where public.fc_buscar_producto_escaneo(t.ean) is null
  and public.fc_buscar_producto_escaneo(t.sku) is null
  and not exists (
    select 1 from public.productos p
    where p.codigo_barras = t.ean or p.sku = t.sku
  );

-- Costos (no baja PVP bueno)
update public.productos p
set
  costo = t.costo,
  precio = case
    when coalesce(p.precio, 0) <= 1 then t.precio
    else p.precio
  end,
  codigo_barras = coalesce(nullif(btrim(p.codigo_barras), ''), t.ean)
from (
  select distinct on (ean) *
  from _fc_tk_20261107
  where costo >= 1
  order by ean, linea
) t
where p.id = coalesce(
  public.fc_buscar_producto_escaneo(t.ean),
  public.fc_buscar_producto_escaneo(t.sku)
);

-- Ficha / foto si falta (no pisa foto buena)
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
  codigo_barras = coalesce(nullif(trim(p.codigo_barras), ''), t.ean),
  requiere_receta = case when coalesce(t.receta, false) then true else p.requiere_receta end
from (
  select distinct on (ean) *
  from _fc_tk_20261107
  order by ean, linea
) t
where p.id = coalesce(
  public.fc_buscar_producto_escaneo(t.ean),
  public.fc_buscar_producto_escaneo(t.sku)
);
{blocks}
commit;

-- VERIFICACION
select
  r.proveedor,
  r.folio,
  r.estado,
  r.total_ticket,
  count(i.*) as renglones,
  coalesce(sum(i.cantidad), 0) as piezas,
  count(*) filter (where not coalesce(i.confirmado, false)) as sin_confirmar
from public.recepciones r
left join public.recepcion_items i on i.recepcion_id = r.id
where (r.folio = '450987' and coalesce(r.proveedor, '') ilike '%equilibrio%')
   or (r.folio = 'S338883' and coalesce(r.proveedor, '') ilike '%cityfarma%')
   or (r.folio = '86837' and coalesce(r.proveedor, '') ilike '%bodega%')
group by r.id, r.proveedor, r.folio, r.estado, r.total_ticket
order by r.folio;
"""
    OUT_SQL.write_text(sql, encoding="utf-8")


def write_csvs() -> None:
    GEN.mkdir(parents=True, exist_ok=True)
    mapping = {
        "equilibrio": ("ticket_equilibrio_450987.csv", "450987", "Equilibrio", 697.11),
        "cityfarma": ("ticket_cityfarma_s338883.csv", "S338883", "Cityfarma Iztapalapa", 1884.14),
        "bodega": ("ticket_bodega_f42_86837.csv", "86837", "Bodega F-42", 451.12),
    }
    for key, (fname, folio, prov, total) in mapping.items():
        rows = TICKETS_META[key]["rows"]
        path = GEN / fname
        with path.open("w", newline="", encoding="utf-8") as fh:
            w = csv.writer(fh)
            w.writerow([
                "linea", "folio", "fecha", "proveedor", "ean",
                "descripcion_ticket", "nombre_mostrador", "cantidad",
                "precio_unitario", "subtotal", "lote", "sku_farmacapital",
                "total_ticket", "match",
            ])
            for i, r in enumerate(rows, start=1):
                w.writerow([
                    i, folio, "2026-11-07", prov, r["ean"],
                    r["snap"], r["nombre"], r["qty"],
                    f"{r['pu']:.2f}", f"{r['sub']:.2f}", r["lote"] or "",
                    r["sku"], f"{total:.2f}", r["match"],
                ])


def write_md() -> None:
    altas = [r for r in EQ + CF + BF if not r["ya"]]
    altas_txt = " · ".join(f"{r['sku']} {r['nombre']}" for r in altas)
    OUT_MD.write_text(
        f"""# Tickets 07-nov-2026 → Recibir

Tres tickets del mismo día. Pegar **todo** `sql/patch_recepciones_tickets_20261107_SOLO_pegar_esto.sql` en Supabase → SQL Editor → Run.

## Tickets

| Proveedor | Folio | Total | Renglones / pzas |
|---|---|---|---|
| Equilibrio (Iztapalapa 2) | **450987** | $697.11 | 6 / 22 |
| Cityfarma Iztapalapa | **S338883** | $1,884.14 | 10 / 16 |
| Bodega F-42 | **86837** | $451.12 | 9 / 12 |

## Notas

1. **Equilibrio:** costo = P.U. neto tras descuento; IVA $0; lote de fábrica sí; caducidad **no** (MMAA caja). Claves EQF → EAN ficha.
2. **Cityfarma:** P.U. del papel; suma de renglones = total $1,884.14. Sin lote en cola.
3. **Bodega F-42:** ticket imprime Citymark; folio **86837** (Caja 2). P.U. con IVA; suma = total.
4. Stock **0** hasta pistola + MMAA. No inventar `0000`.
5. Altas previstas ({len(altas)}): {altas_txt}

## Después del SQL

1. Recargar Recibir en la tablet.
2. Deben aparecer **3 botones** nuevos.
3. Escanear → MMAA → Guardar renglón.

## Regenerar

`python3 scripts/generar_carga_tickets_20261107.py`
""",
        encoding="utf-8",
    )


def main() -> None:
    validate()
    write_sql()
    write_csvs()
    write_md()
    print(f"SQL → {OUT_SQL}")
    print(f"MD  → {OUT_MD}")
    for key in ("equilibrio", "cityfarma", "bodega"):
        meta = TICKETS_META[key]
        pcs = sum(r["qty"] for r in meta["rows"])
        sub = round(sum(r["sub"] for r in meta["rows"]), 2)
        altas = sum(1 for r in meta["rows"] if not r["ya"])
        print(
            f"  {meta['proveedor']} {meta['folio']}: "
            f"{len(meta['rows'])} ren / {pcs} pzas / ${meta['total']:.2f} "
            f"(suma ${sub:.2f}) altas={altas}"
        )


if __name__ == "__main__":
    main()
