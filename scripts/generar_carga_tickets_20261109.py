#!/usr/bin/env python3
"""Tickets 09-nov-2026 (fotos) → altas + cola Recibir.

  Bodega F-42 / Citymark · folio 383312 (CODE128 del pie; encabezado Caja 4 doblado)
  IFC F8 Tienda · folio 132888
  Farmaceuticos Tenorio · 3854927 · 3857153
  Cityfarma Iztapalapa · S339688 (10-nov, misma tanda de fotos)

Nombres de mostrador (no código de ticket). Caducidad null (MMAA de la caja).
Bodega: P.U. ya con IVA (suma renglones = total).
IFC: menudeo por pieza; Aceite Romero EAN 3311000001537; Mertodol EAN 759684313257.
Tenorio: costo = importe / cantidad (IVA de renglón aparte; Systane lleva IVA 16%).
Cityfarma: costo = P.U. (IVA 0 en ticket; pendiente de pago anotado).
SIN producto_imagenes en el mismo txn. SIN bloques dollar-quote.
"""
from __future__ import annotations

import math
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
OUT_SQL = ROOT / "sql" / "patch_recibir_tickets_0911_SOLO_pegar_esto.sql"
OUT_MD = ROOT / "sql" / "LEERME_tickets_20261109.md"
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
    return f"{FOTO}/{name}" if name else None


def P(
    ean: str,
    *,
    nombre: str,
    tipo: str = "marca",
    categoria: str = "Cuidado personal",
    subcategoria: str | None = "Higiene bucal",
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
    "070942304542": P(
        "070942304542",
        nombre="GUM hilo dental + enhebrador",
        forma="Hilo dental",
        marca="GUM",
        laboratorio="Sunstar",
        presentacion="22.9 m con enhebrador",
        ya=True,
        foto_file="gum-hilo-dental-enhebrador-22.9m-070942304542.jpg",
    ),
    "7501035911376": P(
        "7501035911376",
        nombre="Colgate Total Clean Mint",
        forma="Pasta dental",
        marca="Colgate",
        laboratorio="Colgate-Palmolive",
        presentacion="Tubo 150 ml",
        ya=False,
    ),
    "070942303194": P(
        "070942303194",
        nombre="GUM hilo dental con cera",
        forma="Hilo dental",
        marca="GUM",
        laboratorio="Sunstar",
        presentacion="128 m",
        ya=True,
    ),
    "7800005082024": P(
        "7800005082024",
        nombre="Oral-B Essential Floss con cera",
        forma="Hilo dental",
        marca="Oral-B",
        laboratorio="P&G",
        presentacion="50 m",
        ya=False,
    ),
    "7500435129749": P(
        "7500435129749",
        nombre="Oral-B Essential Floss menta",
        forma="Hilo dental",
        marca="Oral-B",
        laboratorio="P&G",
        presentacion="2 × 50 m",
        ya=False,
    ),
    "7509546653495": P(
        "7509546653495",
        nombre="Colgate Total 12 Clean Mint",
        forma="Pasta dental",
        marca="Colgate",
        laboratorio="Colgate-Palmolive",
        presentacion="Tubo 65 ml",
        ya=True,
        sku="FC-66534951",
    ),
    "759684313257": P(
        "759684313257",
        nombre="Mertodol blanco con atomizador",
        categoria="Botiquín",
        subcategoria="Antiséptico",
        forma="Solución",
        marca="Jaloma",
        laboratorio="Jaloma",
        presentacion="40 ml con atomizador",
        principio="Cloruro de benzalconio",
        concentracion="0.13%",
        ya=False,
    ),
    "3311000001537": P(
        "3311000001537",
        nombre="Aceite de romero Mercurio",
        categoria="Cuidado personal",
        subcategoria="Botiquín",
        forma="Aceite",
        marca="Mercurio",
        laboratorio="Mercurio",
        presentacion="Frasco (pieza de C/25)",
        ya=True,
        sku="FC-38CAFE6B",
    ),
    # Tenorio
    "7502001166981": P(
        "7502001166981",
        nombre="Laur Adulto",
        tipo="generico",
        categoria="Medicamentos",
        subcategoria="Antibiótico",
        forma="Solución inyectable",
        marca="Laur",
        laboratorio="Son's",
        presentacion="Caja con 3 frascos ámpula",
        principio="Ampicilina / Metamizol / Guaifenesina / Lidocaína / Clorfenamina",
        concentracion="500/500/100/30/4 mg",
        receta=True,
        ya=True,
        sku="EQ-SON264",
    ),
    "650240007408": P(
        "650240007408",
        nombre="Silka Medic",
        tipo="marca",
        categoria="Medicamentos",
        subcategoria="Dermatología",
        forma="Gel",
        marca="Silka Medic",
        laboratorio="Genomma Lab",
        presentacion="Tubo 15 g",
        principio="Terbinafina",
        concentracion="1%",
        ya=True,
        sku="FC-00740024",
    ),
    "650240005398": P(
        "650240005398",
        nombre="Silka Medic",
        tipo="marca",
        categoria="Medicamentos",
        subcategoria="Dermatología",
        forma="Gel",
        marca="Silka Medic",
        laboratorio="Genomma Lab",
        presentacion="Tubo 30 g",
        principio="Terbinafina",
        concentracion="1%",
        ya=False,
    ),
    "7501482200016": P(
        "7501482200016",
        nombre="Aktyzar omeprazol 20 mg",
        tipo="generico",
        categoria="Medicamentos",
        subcategoria="Gastro",
        forma="Cápsulas",
        marca="Aktyzar",
        laboratorio="Solfran",
        presentacion="Frasco con 120 cápsulas",
        principio="Omeprazol",
        concentracion="20 mg",
        receta=True,
        ya=True,
        sku="FC-82200016",
        foto_file="aktyzar-omeprazol-20mg-120cap.jpg",
    ),
    "7506494600465": P(
        "7506494600465",
        nombre="Precazit 1 mg",
        tipo="generico",
        categoria="Medicamentos",
        subcategoria="Gastro",
        forma="Comprimidos",
        marca="Precazit",
        laboratorio="Schoen",
        presentacion="Caja con 30 comprimidos",
        principio="Prucaloprida",
        concentracion="1 mg",
        receta=True,
        ya=False,
    ),
    "7502247378100": P(
        "7502247378100",
        nombre="Xilostran 450/50 mg",
        tipo="generico",
        categoria="Medicamentos",
        subcategoria="Circulación",
        forma="Tabletas",
        marca="Xilostran",
        laboratorio="Landsteiner",
        presentacion="Caja con 20 tabletas",
        principio="Diosmina / Hesperidina",
        concentracion="450 mg / 50 mg",
        ya=False,
    ),
    "7502247373495": P(
        "7502247373495",
        nombre="Bacat atorvastatina 20 mg",
        tipo="generico",
        categoria="Medicamentos",
        subcategoria="Lípidos",
        forma="Tabletas",
        marca="Bacat",
        laboratorio="Landsteiner",
        presentacion="Caja con 30 tabletas",
        principio="Atorvastatina",
        concentracion="20 mg",
        receta=True,
        ya=True,
        sku="EQ-LAN057",
        foto_file="bacat-atorvastatina-20mg-c30-7502247373495.jpg",
    ),
    "7502247378179": P(
        "7502247378179",
        nombre="Bacat atorvastatina 20 mg",
        tipo="generico",
        categoria="Medicamentos",
        subcategoria="Lípidos",
        forma="Tabletas",
        marca="Bacat",
        laboratorio="Landsteiner",
        presentacion="Caja con 60 tabletas",
        principio="Atorvastatina",
        concentracion="20 mg",
        receta=True,
        ya=False,
    ),
    "7502247373228": P(
        "7502247373228",
        nombre="Bacat atorvastatina 20 mg",
        tipo="generico",
        categoria="Medicamentos",
        subcategoria="Lípidos",
        forma="Tabletas",
        marca="Bacat",
        laboratorio="Landsteiner",
        presentacion="Caja con 10 tabletas",
        principio="Atorvastatina",
        concentracion="20 mg",
        receta=True,
        ya=False,
    ),
    "7506331302002": P(
        "7506331302002",
        nombre="Relozibin ertapenem 1 g",
        tipo="marca",
        categoria="Medicamentos",
        subcategoria="Antibiótico",
        forma="Solución inyectable",
        marca="Relozibin",
        laboratorio="Aurovida",
        presentacion="Caja con 1 frasco ámpula",
        principio="Ertapenem",
        concentracion="1 g",
        receta=True,
        ya=False,
    ),
    "300651429312": P(
        "300651429312",
        nombre="Systane Ultra",
        tipo="marca",
        categoria="Cuidado personal",
        subcategoria="Oftálmico",
        forma="Gotas",
        marca="Systane",
        laboratorio="Alcon",
        presentacion="Frasco gotero",
        ya=False,
    ),
    "7501058714305": P(
        "7501058714305",
        nombre="Tempra jarabe infantil",
        tipo="marca",
        categoria="Medicamentos",
        subcategoria="Analgésico",
        forma="Jarabe",
        marca="Tempra",
        laboratorio="RB Health",
        presentacion="Frasco 120 ml",
        principio="Paracetamol",
        concentracion="3.2 g / 120 ml",
        ya=True,
        sku="FC-50724298",
    ),
}


def row(ean: str, snap: str, qty: int, pu: float) -> dict:
    p = CAT[ean]
    pu_r = round(pu, 3)
    return {
        **p,
        "snap": snap,
        "qty": qty,
        "pu": pu_r,
        "sub": round(qty * pu_r, 2),
        "precio": ceil_pvp(pu_r, p["tipo"]),
    }


TICKETS = [
    {
        "key": "bodega_f42_383312",
        "tmp": "_fc_bf42_383312",
        "folio": "383312",
        "proveedor": "Bodega F-42",
        "proveedor_ilike": "bodega%f-42",
        "fecha": "2026-11-09",
        "total": 611.15,
        "notas": (
            "Bodega F-42 / Citymark · Caja 4 · folio 383312 (CODE128 del pie; "
            "encabezado Caja 4/… doblado en la foto) · 09-nov-2026 17:07 · "
            "Público en general · TC $611.15 · P.U. ya con IVA · cola Recibir"
        ),
        "header": (
            "Bodega F-42 · folio 383312 · 2026-11-09 17:07 · total $611.15 · 7 renglones\n"
            "-- P.U. ya con IVA (suma = total). Folio del CODE128 del pie."
        ),
        "rows": [
            row("070942304542", "HILO DENT GUM + ENHEBRADOR 22.9M", 1, 97.54),
            row("7501035911376", "C D COLGATE TOTAL 150 ML", 3, 53.50),
            row("070942303194", "HILO DENT GUM C/CERAS MTA 129P", 1, 56.61),
            row("7800005082024", "HILO SDA ORAL-B CERA", 2, 69.315),
            row("7500435129749", "HILO DENT ORAL-B ESS FLOSS 2PACK", 1, 70.77),
            row("7509546653495", "C D COLGATE TOTAL12 CLEAN MI 65ML", 2, 23.445),
            row("759684313257", "MERTODOL BCO JALOMA C/ATO 40ML S", 2, 20.105),
        ],
    },
    {
        "key": "ifc_132888",
        "tmp": "_fc_ifc_132888",
        "folio": "132888",
        "proveedor": "IFC F8 Tienda",
        "proveedor_ilike": "ifc",
        "fecha": "2026-11-09",
        "total": 118.00,
        "notas": (
            "IFC F8 Tienda / Farma Centre · folio 132888 · 09-nov-2026 16:52 · "
            "cliente Luis · San Bernabé 317 · MENUDEO · Aceite romero Mercurio "
            "10 pzas + Mertodol Jaloma 2 pzas · cola Recibir"
        ),
        "header": (
            "IFC F8 Tienda · folio 132888 · 2026-11-09 16:52 · total $118.00 · 2 renglones\n"
            "-- Menudeo por pieza. Romero EAN 3311000001537. Mertodol EAN 759684313257."
        ),
        "rows": [
            row("3311000001537", "MERCURIO ACEITE ROMERO C/25 1910923 83187", 10, 8.50),
            row("759684313257", "JALOMA MERTIOLATE BLANCO 40ML C/25 0179039 83217", 2, 16.50),
        ],
    },
    {
        "key": "tenorio_3854927",
        "tmp": "_fc_tn_3854927",
        "folio": "3854927",
        "proveedor": "Farmaceuticos Tenorio",
        "proveedor_ilike": "tenorio",
        "fecha": "2026-11-09",
        "total": 1334.26,
        "notas": (
            "Factura Farmaceuticos Tenorio folio 3854927 · 09-nov-2026 08:24 · "
            "cliente 20077 Palillero Ventura · ref 2159588 · ruta Puebla · 1 caja · "
            "IVA $0 · costo = importe/cantidad · cola Recibir"
        ),
        "header": (
            "Farmaceuticos Tenorio · folio 3854927 · 2026-11-09 08:24 · total $1,334.26\n"
            "-- Cliente 20077 · ref 2159588 · IVA 0. Costo = importe/cantidad.\n"
            "-- Laur EAN canónico 7502001166981 (ticket OCR ilegible). Precazit EAN 7506494600465."
        ),
        "rows": [
            row("7502001166981", "LAUR ADT 500/500/100/30/4MG SOL INY", 2, 63.88),
            row("650240007408", "SILKA MEDIC 1% GEL 15GR GNL", 3, 55.04),
            row("650240005398", "SILKA MEDIC 1% GEL 30GR GNL", 2, 71.97),
            row("7501482200016", "AKTYZAR 20MG CAP C/120 SFR", 5, 43.97),
            row("7506494600465", "PRECAZIT 1MG COMP C/30 SHO", 2, 94.98),
            row("7502247378100", "XILOSTRAN 450/50MG TAB C/20 LAN", 3, 46.90),
            row("7502247373495", "BACAT 20MG TAB C/30 LAN", 5, 35.28),
            row("7502247378179", "BACAT 20MG TAB C/60 LAN", 2, 67.25),
            row("7502247373228", "BACAT 20MG TAB C/10 LAN", 3, 12.01),
        ],
    },
    {
        "key": "tenorio_3857153",
        "tmp": "_fc_tn_3857153",
        "folio": "3857153",
        "proveedor": "Farmaceuticos Tenorio",
        "proveedor_ilike": "tenorio",
        "fecha": "2026-11-09",
        "total": 2567.43,
        # Suma de importes (sin IVA de Systane); total_ticket sí incluye IVA.
        "sum_check": 2489.14,
        "notas": (
            "Factura Farmaceuticos Tenorio folio 3857153 · 09-nov-2026 20:59 · "
            "cliente 20077 Palillero Ventura · ref 2160359 · ruta Puebla · 1 caja · "
            "subtotal $2,489.14 + IVA $78.29 (Systane) · Relozibin EAN 7506331302002 · "
            "costo = importe/cantidad · cola Recibir"
        ),
        "header": (
            "Farmaceuticos Tenorio · folio 3857153 · 2026-11-09 20:59 · total $2,567.43\n"
            "-- Relozibin 4 pzas · Systane 2 pzas. Costo = importe/cantidad (IVA aparte en Systane).\n"
            "-- Relozibin EAN canónico 7506331302002 (ticket OCR 750303…)."
        ),
        "rows": [
            row("7506331302002", "RELOZIBIN 1GR SOLUC INY C/1 AUR", 4, 499.95),
            row("300651429312", "SYSTANE 4/3/1 GTS OFT CADP 12-2027", 2, 244.67),
        ],
    },
    {
        "key": "cityfarma_s339688",
        "tmp": "_fc_cf_s339688",
        "folio": "S339688",
        "proveedor": "Cityfarma Iztapalapa",
        "proveedor_ilike": "cityfarma",
        "fecha": "2026-11-10",
        "total": 178.21,
        "notas": (
            "Cityfarma Iztapalapa · orden S339688 · 10-nov-2026 16:58 · Jonathan Moreno · "
            "cliente Luis Angel Palillero · Tempra jarabe infantil · pendiente de pago $178.21 · "
            "IVA 0 · cola Recibir"
        ),
        "header": (
            "Cityfarma Iztapalapa · folio S339688 · 2026-11-10 16:58 · total $178.21 · 1 renglón\n"
            "-- Pendiente de pago en el papel. Costo = P.U. EAN 7501058714305."
        ),
        "rows": [
            row("7501058714305", "TEMPRA JBE INF 3 2 1", 1, 178.21),
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
            "{receta}, {ya}, {img})".format(
                linea=i,
                ean=sql_str(r["ean"]),
                sku=sql_str(r["sku"]),
                nombre=sql_str(r["nombre"]),
                snap=sql_str(r["snap"]),
                qty=int(r["qty"]),
                costo=(f"{r['pu']:.3f}" if round(r["pu"], 2) != round(r["pu"], 3) else f"{r['pu']:.2f}"),
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
            )
        )
    n_alta = sum(1 for r in rows if not r["ya"])
    n_ya = sum(1 for r in rows if r["ya"])
    ilike = sql_str("%" + t["proveedor_ilike"] + "%")
    return f"""
-- ========== {t['proveedor']} {folio} ==========
-- {t['header']}
-- {n_alta} alta(s) stock 0. {n_ya} ya estaban: solo costo / ficha vacía, no PVP.
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
  costo numeric(12,3) not null,
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
  imagen text
) on commit drop;

insert into {tmp} (
  linea, ean, sku, nombre, snap, qty, costo, precio, tipo, categoria,
  subcategoria, forma, marca, laboratorio, presentacion, principio_activo,
  concentracion, receta, ya, imagen
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
    when t.ean is not null and exists (
      select 1 from public.productos p
      where p.sku = t.sku and coalesce(p.codigo_barras, '') <> t.ean
    ) then 'FC-ND-' || right(t.ean, 8)
    else t.sku
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
where (t.ean is null or public.fc_buscar_producto_escaneo(t.ean) is null)
  and public.fc_buscar_producto_escaneo(t.sku) is null;

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
  public.fc_buscar_producto_escaneo(t.sku)
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
  codigo_barras = case
    when t.ean is not null then coalesce(nullif(trim(p.codigo_barras), ''), t.ean)
    else p.codigo_barras
  end
from (
  select distinct on (coalesce(ean, sku)) *
  from {tmp}
  order by coalesce(ean, sku), linea
) t
where p.id = coalesce(
  case when t.ean is not null then public.fc_buscar_producto_escaneo(t.ean) end,
  public.fc_buscar_producto_escaneo(t.sku)
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
    public.fc_buscar_producto_escaneo(t.sku)
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

select
  t.linea,
  t.ean,
  t.sku,
  t.nombre,
  t.qty,
  t.costo,
  case
    when coalesce(
      case when t.ean is not null then public.fc_buscar_producto_escaneo(t.ean) end,
      public.fc_buscar_producto_escaneo(t.sku)
    ) is null then 'PENDIENTE_ALTA' else 'OK' end as match,
  t.ya as marcado_ya
from {tmp} t
order by t.linea;

commit;
"""


def main() -> None:
    for t in TICKETS:
        s = round(sum(r["sub"] for r in t["rows"]), 2)
        target = t.get("sum_check", t["total"])
        diff = abs(s - target)
        if diff > 0.05:
            raise SystemExit(f"{t['folio']}: sum {s} != check {target} (diff {diff})")
        print(f"{t['folio']}: {len(t['rows'])} rows · sum {s} · total {t['total']} · Δ{diff:.2f}")

    parts = [
        "-- =============================================================================",
        "-- PEGAR TODO ESTE ARCHIVO en Supabase → SQL Editor → Run",
        "-- Tickets 09-nov-2026 → cola Recibir (borrador).",
        "--   1) Bodega F-42 383312 · $611.15 · 7 renglones",
        "--   2) IFC F8 Tienda 132888 · $118.00 · 2 renglones",
        "--   3) Tenorio 3854927 · $1,334.26 · 9 renglones",
        "--   4) Tenorio 3857153 · $2,567.43 · 2 renglones",
        "--   5) Cityfarma S339688 · $178.21 · 1 renglón (10-nov)",
        "-- Merge a GitHub NO los crea. Sin bloques dollar-quote. Sin producto_imagenes.",
        "-- Caducidad null: MMAA de la caja. No inventar 0000.",
        "-- Cada ticket es begin/commit independiente.",
        "-- Al final: VERIFICACION FINAL con los 5 folios en borrador.",
        "-- Luego: tablet Recibir → recargar → aparecen las tarjetas.",
        "-- =============================================================================",
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
    OUT_SQL.write_text("\n".join(parts), encoding="utf-8")

    table = "\n".join(
        f"| {t['proveedor']} | **{t['folio']}** | ${t['total']:,.2f} | {len(t['rows'])} |"
        for t in TICKETS
    )
    OUT_MD.write_text(
        f"""# Tickets 09–10-nov-2026 → Recibir

Pegar **todo** el SQL abajo en el chat / `sql/patch_recibir_tickets_0911_SOLO_pegar_esto.sql` en Supabase → SQL Editor → Run.


## Tickets

| Proveedor | Folio | Total | Renglones |
|---|---|---|---|
{table}

## Notas

1. **Bodega F-42 383312:** Caja 4 · P.U. ya con IVA. Folio leído del **CODE128** del pie (el encabezado `Caja 4/…` venía doblado). Si el papel muestra otro número, avisa y lo renombramos.
2. **IFC 132888:** menudeo · Aceite romero → EAN `3311000001537` (SKU `FC-38CAFE6B`) · Mertodol Jaloma → EAN `759684313257` (mismo frasco que en Bodega).
3. **Tenorio 3854927:** costo = importe/cantidad · IVA $0 · Laur EAN canónico `7502001166981` · Precazit `7506494600465`.
4. **Tenorio 3857153:** Relozibin EAN `7506331302002` · Systane UPC `300651429312` · IVA $78.29 solo en Systane (costo = importe sin IVA).
5. **Cityfarma S339688:** Tempra jarabe infantil EAN `7501058714305` · **pendiente de pago** $178.21 en el papel.
6. **Stock:** 0 hasta pistola + MMAA. No poner `0000`.
7. **Fotos:** GUM + enhebrador / Aktyzar / Bacat C/30 ya en `catalogo-propia/`; el resto pendiente (no bloquea Recibir).

## Después del SQL

1. Recargar Recibir en la tablet.
2. Deben aparecer **5 botones** nuevos.
3. Escanear → MMAA → Guardar renglón.
""",
        encoding="utf-8",
    )
    print(f"→ {OUT_SQL.relative_to(ROOT)} ({OUT_SQL.stat().st_size} bytes)")
    print(f"→ {OUT_MD.relative_to(ROOT)}")
    if "$$" in OUT_SQL.read_text(encoding="utf-8"):
        raise SystemExit("ERROR: el SQL contiene $$ (dollar-quote)")


if __name__ == "__main__":
    main()
