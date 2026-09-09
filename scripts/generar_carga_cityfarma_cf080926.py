#!/usr/bin/env python3
"""Ticket Cityfarma Iztapalapa 08-sep-2026 (cliente 307513) → catálogo + cola Recibir.

Ticket térmico Central de Abastos, 16 renglones / 37 pzas / $1,648.69.
Nombres de mostrador desde ficha (no el código interno NOV/ALP/MAV…).
Sin lote ni MMAA en la cola: salen de la caja al escanear. No inventar 0000.
Citrato Naturex: el renglón trae IVA; el costo es Total/pza (IVA incluido).
"""
from __future__ import annotations

import math
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from generar_recepcion_borrador import report, write_ticket_csv

ROOT = Path(__file__).resolve().parents[1]
OUT_TICKET = ROOT / "sql" / "generated" / "ticket_cityfarma_cf080926.csv"
OUT_SQL = ROOT / "sql" / "patch_carga_cityfarma_cf080926.sql"

# Folio no viene legible en las fotos; usamos fecha + cliente del ticket.
FOLIO = "CF080926"
PROVEEDOR = "Cityfarma Iztapalapa"
FECHA = "2026-09-08"
TOTAL_TICKET = 1648.69
FOTO_BASE = "https://www.farmacapital.mx/catalogo-propia"


def ceil_pvp(costo: float, factor: float = 1.6) -> int:
    return int(math.ceil(costo * factor))


def sku_de(ean: str) -> str:
    return "FC-" + ean[-8:]


def sql_str(s: str | None) -> str:
    if s is None:
        return "null"
    return "'" + str(s).replace("'", "''") + "'"


def foto(name: str | None) -> tuple[str | None, str | None]:
    if not name:
        return None, None
    return f"{FOTO_BASE}/{name}", f"catalogo-propia/{name}"


# Fichas (EAN de mayoreo / ficha de lab, no el SKU del ticket):
ROWS = [
    {
        "ean": "8907730000039",
        "sku": sku_de("8907730000039"),
        "snap": "NOV133 ACETIF SI 1 SOL INY 1000MG/100 ML",
        "nombre": "Acetif SI paracetamol solución inyectable 1000 mg/100 ml",
        "qty": 2,
        "pu": 65.23,
        "sub": 130.46,
        "lote": "26D0801",
        "cad": "2028-03-31",
        "tipo": "marca",
        "categoria": "Analgésico",
        "subcategoria": "Inyectable",
        "forma": "Solución inyectable",
        "marca": "Acetif SI",
        "laboratorio": "NOVAG",
        "presentacion": "Frasco 100 ml",
        "principio": "Paracetamol",
        "concentracion": "1000 mg/100 ml",
        "receta": True,
        "ya": False,
        "foto_file": "acetif-si-1000mg-100ml.jpg",
    },
    {
        "ean": "7503004908776",
        "sku": sku_de("7503004908776"),
        "snap": "ALP0191 METFORMINA 30 TAB 850 MG",
        "nombre": "Metformina Alpharma 850 mg C/30",
        "qty": 2,
        "pu": 18.40,
        "sub": 36.80,
        "lote": "2607313",
        "cad": "2028-07-31",
        "tipo": "generico",
        "categoria": "Diabetes",
        "subcategoria": None,
        "forma": "Tabletas",
        "marca": "Alpharma",
        "laboratorio": "ALPHARMA",
        "presentacion": "Caja con 30 tabletas",
        "principio": "Metformina",
        "concentracion": "850 mg",
        "receta": True,
        "ya": False,
        "foto_file": "metformina-alpharma-850-c30.jpg",
    },
    {
        "ean": "7501836003621",
        "sku": "FC-36003621",
        "snap": "LIF162 PRECICOL 1 GOT 20 ML",
        "nombre": "Precicol hioscina/paracetamol gotas 20 ml",
        "qty": 2,
        "pu": 36.31,
        "sub": 72.62,
        "lote": "26E126",
        "cad": "2028-06-30",
        "tipo": "marca",
        "categoria": "Gastro",
        "subcategoria": "Antiespasmódico",
        "forma": "Gotas",
        "marca": "Precicol",
        "laboratorio": "LIFERPAL",
        "presentacion": "Frasco gotero 20 ml",
        "principio": "Butilhioscina + paracetamol",
        "concentracion": "2 mg/100 mg/ml",
        "receta": False,
        "ya": True,
        "foto_file": None,
    },
    {
        "ean": "7502001163485",
        "sku": "EQ-SON164",
        "snap": "SON164 CLOTRIMAZOL DUAL 3 OVS 200MG 1CMA 10G",
        "nombre": "Clotrimazol Dual óvulos 200 mg C/3 + crema 1% 10 g",
        "qty": 2,
        "pu": 48.98,
        "sub": 97.96,
        "lote": "26051202",
        "cad": "2028-05-31",
        "tipo": "generico",
        "categoria": "Ginecología",
        "subcategoria": "Antimicótico",
        "forma": "Óvulos + crema",
        "marca": "Son's",
        "laboratorio": "QUIMICA SON'S",
        "presentacion": "Caja con 3 óvulos y tubo 10 g",
        "principio": "Clotrimazol",
        "concentracion": "200 mg / 1%",
        "receta": False,
        "ya": True,
        "foto_file": "clotrimazol-dual-sons.jpg",
    },
    {
        "ean": "7502226294254",
        "sku": sku_de("7502226294254"),
        "snap": "ALP0568 TERBINAFINA 1 SPRAY 1%/30 ML",
        "nombre": "Losil-S terbinafina spray 1% 30 ml",
        "qty": 1,
        "pu": 35.28,
        "sub": 35.28,
        "lote": "2605920",
        "cad": "2028-05-13",
        "tipo": "generico",
        "categoria": "Dermatología",
        "subcategoria": "Antimicótico",
        "forma": "Spray",
        "marca": "Losil-S",
        "laboratorio": "ALPHARMA",
        "presentacion": "Frasco atomizador 30 ml",
        "principio": "Terbinafina",
        "concentracion": "1%",
        "receta": False,
        "ya": False,
        "foto_file": "losil-s-terbinafina-spray.jpg",
    },
    {
        "ean": "7502009744440",
        "sku": sku_de("7502009744440"),
        "snap": "MAV207 VALTROVER G 10 SOB 4 MG",
        "nombre": "Valtrover G montelukast granulado 4 mg C/10",
        "qty": 2,
        "pu": 55.10,
        "sub": 110.20,
        "lote": "254143",
        "cad": "2027-08-01",
        "tipo": "marca",
        "categoria": "Respiratorio",
        "subcategoria": "Antiasmático",
        "forma": "Granulado",
        "marca": "Valtrover G",
        "laboratorio": "MAVER",
        "presentacion": "Caja con 10 sobres",
        "principio": "Montelukast",
        "concentracion": "4 mg",
        "receta": True,
        "ya": False,
        "foto_file": "valtrover-g-4mg-c10.jpg",
    },
    {
        "ean": "780083140939",
        "sku": "FC-DE106642",
        "snap": "COL008 AMPIGRIN INF 3 AMP 250/200/100/30MG/3 ML",
        "nombre": "Ampigrin Infantil ampicilina 250 mg 3 amp",
        "qty": 2,
        "pu": 72.22,
        "sub": 144.44,
        "lote": "26240043",
        "cad": "2028-01-12",
        "tipo": "marca",
        "categoria": "Antibiótico",
        "subcategoria": "Inyectable",
        "forma": "Solución inyectable",
        "marca": "Ampigrin",
        "laboratorio": "COLLINS",
        "presentacion": "Caja con 3 frascos ámpula + 3 diluyentes 3 ml",
        "principio": "Ampicilina + metamizol + guaifenesina + lidocaína",
        "concentracion": "250/200/100/30 mg/3 ml",
        "receta": True,
        "ya": True,
        "foto_file": "ampigrin-infantil-3amp.jpg",
    },
    {
        "ean": "7501349027343",
        "sku": sku_de("7501349027343"),
        "snap": "AMS277 AMSAFAST 21 CAPS 120 MG",
        "nombre": "Amsafast orlistat 120 mg C/21",
        "qty": 3,
        "pu": 95.63,
        "sub": 286.89,
        "lote": "U26E260",
        "cad": "2028-01-01",
        "tipo": "marca",
        "categoria": "Gastro",
        "subcategoria": "Obesidad",
        "forma": "Cápsulas",
        "marca": "Amsafast",
        "laboratorio": "AMSA",
        "presentacion": "Caja con 21 cápsulas",
        "principio": "Orlistat",
        "concentracion": "120 mg",
        "receta": True,
        "ya": False,
        "foto_file": "amsafast-120mg-c21.jpg",
    },
    {
        "ean": "7502009747052",
        "sku": sku_de("7502009747052"),
        "snap": "MAV344 CORIVER 10 TAB 750 MG",
        "nombre": "Coriver paracetamol 750 mg C/10",
        "qty": 5,
        "pu": 7.71,
        "sub": 38.55,
        "lote": "263137",
        "cad": "2028-05-31",
        "tipo": "marca",
        "categoria": "Analgésico",
        "subcategoria": None,
        "forma": "Tabletas",
        "marca": "Coriver",
        "laboratorio": "MAVER",
        "presentacion": "Caja con 10 tabletas",
        "principio": "Paracetamol",
        "concentracion": "750 mg",
        "receta": False,
        "ya": False,
        "foto_file": "coriver-750mg-c10.jpg",
    },
    {
        "ean": "7502259892403",
        "sku": "FC-9892403",
        "snap": "NAT0617 CITRATO DE MAGNESIO 30 CAP 1.82G C/U",
        "nombre": "Naturex citrato de magnesio y lecitina de soya C/30",
        "qty": 2,
        # Ticket: P.U. 41.96 + IVA → Total 97.35 → costo pagado / pza
        "pu": 48.68,
        "sub": 97.35,
        "lote": "263394",
        "cad": "2028-05-31",
        "tipo": "marca",
        "categoria": "Vitaminas",
        "subcategoria": "Minerales",
        "forma": "Cápsulas",
        "marca": "Naturex",
        "laboratorio": "NATUREX",
        "presentacion": "Caja con 30 cápsulas",
        "principio": "Citrato de magnesio + lecitina de soya",
        "concentracion": "1.82 g",
        "receta": False,
        "ya": True,
        "foto_file": None,
        "iva_incluido": True,
    },
    {
        "ean": "7501349028036",
        "sku": sku_de("7501349028036"),
        "snap": "AMS336 MOMETASONA 1 SUSP .05G/18 ML",
        "nombre": "Mometasona AMSA suspensión nasal 0.05% 18 ml",
        "qty": 1,
        "pu": 109.63,
        "sub": 109.63,
        "lote": "A26A120",
        "cad": "2028-04-01",
        "tipo": "generico",
        "categoria": "Respiratorio",
        "subcategoria": "Nasal",
        "forma": "Suspensión nasal",
        "marca": "AMSA",
        "laboratorio": "AMSA",
        "presentacion": "Frasco nebulizador 18 ml (140 dosis)",
        "principio": "Furoato de mometasona",
        "concentracion": "50 mcg/dosis",
        "receta": True,
        "ya": False,
        "foto_file": "mometasona-amsa-18ml.jpg",
    },
    {
        "ean": "7503000422511",
        "sku": "FC-00422511",
        "snap": "MAV003 BACTIVER 1 SUSP 40/200/5/120 ML",
        "nombre": "Bactiver sulfametoxazol/trimetoprima susp. 120 ml",
        "qty": 3,
        "pu": 20.85,
        "sub": 62.55,
        "lote": "262631",
        "cad": "2028-05-01",
        "tipo": "marca",
        "categoria": "Antibiótico",
        "subcategoria": None,
        "forma": "Suspensión",
        "marca": "Bactiver",
        "laboratorio": "MAVER",
        "presentacion": "Frasco 120 ml",
        "principio": "Sulfametoxazol + trimetoprima",
        "concentracion": "200/40 mg/5 ml",
        "receta": True,
        "ya": True,
        "foto_file": None,
    },
    {
        "ean": "780083140922",
        "sku": "FC-2001A890",
        "snap": "COL009 AMPIGRIN AD 3 AMP 500/500/100/30MG/3 ML",
        "nombre": "Ampigrin AD ampicilina/dicloxacilina 3 amp",
        "qty": 2,
        "pu": 79.44,
        "sub": 158.88,
        "lote": "26240110",
        "cad": "2028-03-31",
        "tipo": "marca",
        "categoria": "Antibiótico",
        "subcategoria": "Inyectable",
        "forma": "Solución inyectable",
        "marca": "Ampigrin",
        "laboratorio": "COLLINS",
        "presentacion": "Caja con 3 frascos ámpula + 3 diluyentes 3 ml",
        "principio": "Ampicilina + dicloxacilina + guaifenesina + clorfenamina",
        "concentracion": "500/500/100/30 mg/3 ml",
        "receta": True,
        "ya": True,
        "foto_file": "ampigrin-ad-3amp.jpg",
    },
    {
        "ean": "7502001160019",
        "sku": "EQ-SON033",
        "snap": "SON033 BUSCONET 1 FA 250/20MG/5ML",
        "nombre": "Busconet butilhioscina/metamizol inyectable 5 ml",
        "qty": 3,
        "pu": 32.10,
        "sub": 96.30,
        "lote": "26051306",
        "cad": "2029-05-31",
        "tipo": "marca",
        "categoria": "Gastro",
        "subcategoria": "Antiespasmódico",
        "forma": "Solución inyectable",
        "marca": "Busconet",
        "laboratorio": "QUIMICA SON'S",
        "presentacion": "Caja con 1 ampolleta 5 ml",
        "principio": "Butilhioscina + metamizol sódico",
        "concentracion": "20 mg / 2.5 g / 5 ml",
        "receta": True,
        "ya": False,
        "foto_file": "busconet-inyectable-5ml.jpg",
    },
    {
        "ean": "7501349020337",
        "sku": "FC-49020337",
        "snap": "AMS502 SULINDACO 20 TAB 200 MG",
        "nombre": "Sulindaco AMSA 200 mg C/20",
        "qty": 3,
        "pu": 47.34,
        "sub": 142.02,
        "lote": "U26E326",
        "cad": "2028-01-31",
        "tipo": "generico",
        "categoria": "Analgésico",
        "subcategoria": "AINE",
        "forma": "Tabletas",
        "marca": "AMSA",
        "laboratorio": "AMSA",
        "presentacion": "Caja con 20 tabletas",
        "principio": "Sulindaco",
        "concentracion": "200 mg",
        "receta": True,
        "ya": True,
        "foto_file": None,
    },
    {
        "ean": "75006433",
        "sku": "EQ-NOV005",
        "snap": "NOV005 CIRULAN 1 GOT 400MG/1/20 ML",
        "nombre": "Cirulan metoclopramida solución oral 400 mg / 20 ml",
        "qty": 2,
        "pu": 14.38,
        "sub": 28.76,
        "lote": "120036",
        "cad": "2029-03-01",
        "tipo": "marca",
        "categoria": "Gastro",
        "subcategoria": None,
        "forma": "Gotas",
        "marca": "Cirulan",
        "laboratorio": "NOVAG",
        "presentacion": "Frasco gotero 20 ml",
        "principio": "Metoclopramida",
        "concentracion": "4 mg/ml",
        "receta": True,
        "ya": False,
        "foto_file": "cirulan-gotas-20ml.jpg",
    },
]


def enrich_fotos() -> None:
    for r in ROWS:
        url, path = foto(r.get("foto_file"))
        r["foto"] = url
        r["foto_path"] = path


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
            "lote": r.get("lote") or "",
            "caducidad": r.get("cad") or "",
        })
    return out


def write_ticket_csv_con_lote(path: Path, rows: list) -> None:
    """Igual que write_ticket_csv pero guarda lote/cad del térmico (auditoría)."""
    import csv

    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", newline="", encoding="utf-8") as fh:
        w = csv.writer(fh)
        w.writerow([
            "linea", "folio", "fecha", "proveedor", "ean",
            "descripcion_ticket", "cantidad", "precio_unitario", "subtotal",
            "lote", "caducidad", "sku_farmacapital", "total_ticket", "match",
        ])
        for i, r in enumerate(rows, start=1):
            w.writerow([
                i, FOLIO, FECHA, PROVEEDOR, r.get("ean") or "",
                r["nombre"], r["qty"], f"{r['pu']:.2f}", f"{r['sub']:.2f}",
                r.get("lote") or "", r.get("caducidad") or "",
                r.get("sku") or "", f"{TOTAL_TICKET:.2f}", r.get("match") or "",
            ])


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
                foto_file=sql_str(r["foto_path"]),
            )
        )

    eans = [sql_str(r["ean"]) for r in ROWS]
    n_alta = sum(1 for r in ROWS if not r["ya"])
    n_ya = sum(1 for r in ROWS if r["ya"])
    tmp = "_fc_cf_cf080926"
    body = f"""-- Cityfarma Iztapalapa · venta {FOLIO} · {FECHA} 16:37
-- Ticket térmico Central de Abastos. Cliente 307513 Luis Ángel Palillero.
-- Total $1,648.69 (SUB $1,635.26 + IVA $13.43). 16 renglones / 37 pzas.
-- {n_alta} altas stock 0. {n_ya} ya estaban: solo costo (PVP si estaba en 0).
-- Ampigrin Infantil: corrige nombre si quedó como Infamid.
-- Clotrimazol Dual: corrige typo Clotrinazol.
-- Sin lote ni caducidad en la cola (MMAA de la caja). No inventar 0000.
-- CSV guarda lote/cad del ticket solo para auditoría.
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
  foto_file text
) on commit drop;

insert into {tmp} (
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

-- Ampigrin Infantil: el catálogo lo tenía mal como Infamid.
update public.productos p
set
  nombre = t.nombre,
  marca = t.marca,
  presentacion = t.presentacion,
  forma_farmaceutica = t.forma,
  principio_activo = t.principio_activo,
  concentracion = t.concentracion,
  laboratorio = t.laboratorio,
  categoria = t.categoria,
  subcategoria = t.subcategoria
from {tmp} t
where p.id = public.fc_buscar_producto_escaneo(t.ean)
  and t.ean = '780083140939'
  and (
    p.nombre ~* 'infamid'
    or p.nombre ~* 'metamizol.*dexametasona'
    or p.nombre ~* 'ampigrim'
  );

-- Clotrimazol Dual: typo Clotrinazol.
update public.productos p
set
  nombre = t.nombre,
  marca = coalesce(nullif(trim(p.marca), ''), t.marca),
  presentacion = t.presentacion
from {tmp} t
where p.id = public.fc_buscar_producto_escaneo(t.ean)
  and t.ean = '7502001163485'
  and p.nombre ~* 'clotrinazol';

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  {sql_str(PROVEEDOR)},
  {sql_str(FOLIO)},
  {sql_str(FECHA)},
  {TOTAL_TICKET:.2f},
  'borrador',
  {sql_str(f"Ticket Cityfarma {FOLIO} · {FECHA} · cliente 307513 · cola Recibir; stock al confirmar pistola")}
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
from {tmp} t
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
from {tmp} t
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
    enrich_fotos()
    r = ticket_rows()
    skus = [x["sku"] for x in ROWS]
    eans = [x["ean"] for x in ROWS]
    assert len(skus) == len(set(skus)), skus
    assert len(eans) == len(set(eans)), eans
    assert len(ROWS) == 16, len(ROWS)
    assert sum(x["qty"] for x in ROWS) == 37
    suma = sum(x["sub"] for x in ROWS)
    assert abs(suma - TOTAL_TICKET) < 0.02, (suma, TOTAL_TICKET)
    for x in ROWS:
        if x.get("iva_incluido"):
            # Costo con IVA: Total/pza; sub es el Total del renglón.
            assert abs(x["pu"] * x["qty"] - x["sub"]) < 0.03, x
        else:
            assert abs(x["pu"] * x["qty"] - x["sub"]) < 0.02, x
        if x["foto_file"]:
            assert (ROOT / "public" / "catalogo-propia" / x["foto_file"]).exists(), x["foto_file"]

    write_ticket_csv_con_lote(OUT_TICKET, r)
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
