#!/usr/bin/env python3
# NO pegar este archivo en Supabase. Genera el SQL; el que se corre es:
#   sql/patch_carga_cityfarma_s322817.sql
"""Ticket Cityfarma S322817 (14-sep-2026) → catálogo + cola Recibir.

Ticket térmico Central de Abastos, cliente Luis Ángel Palillero.
Orden 2026-09-14 17:30:03 · total impreso $3,940.28 (tarjeta).

Nombres de mostrador salen de ficha (YZA/Fahorro/Kenvue/Bayer/etc.),
no del renglón del ticket. Sin lote ni MMAA: salen de la caja al escanear.
Cityfarma no publica PDP.
"""
from __future__ import annotations

import math
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from generar_recepcion_borrador import report, write_ticket_csv

ROOT = Path(__file__).resolve().parents[1]
OUT_TICKET = ROOT / "sql" / "generated" / "ticket_cityfarma_s322817.csv"
OUT_SQL = ROOT / "sql" / "patch_carga_cityfarma_s322817.sql"

FOLIO = "S322817"
PROVEEDOR = "Cityfarma Iztapalapa"
FECHA = "2026-09-14"
TOTAL_TICKET = 3940.28  # total impreso (suma P.U.×qty ≈ 3940.29; Clearblue 2×191.15→382.29)
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


# Fichas (no el código del ticket). ya=True solo si ya está en catálogo con ese EAN.
ROWS = [
    {
        "ean": "7503004908875",
        "snap": "ACARBOSA 50MG C30TAB",
        "nombre": "Acarbosa Alpharma 50 mg C/30 tabletas",
        "qty": 1, "pu": 45.20, "sub": 45.20,
        "tipo": "generico", "categoria": "Diabetes", "subcategoria": None,
        "forma": "Tableta", "marca": "Alpharma", "laboratorio": "ALPHARMA",
        "presentacion": "Caja con 30 tabletas", "principio": "Acarbosa",
        "concentracion": "50 mg", "receta": True, "ya": False,
        "foto_file": "acarbosa-alpharma-50mg-30tab-7503004908875.jpg",
    },
    {
        "ean": "7501349028296",
        "snap": "BICALUTAMIDA 50MG C1",
        "nombre": "Bicalutamida AMSA 50 mg C/14 tabletas",
        "qty": 2, "pu": 134.52, "sub": 269.04,
        "tipo": "generico", "categoria": "Medicamentos", "subcategoria": "Oncología",
        "forma": "Tableta", "marca": "AMSA", "laboratorio": "AMSA",
        "presentacion": "Caja con 14 tabletas", "principio": "Bicalutamida",
        "concentracion": "50 mg", "receta": True, "ya": False,
        "foto_file": "bicalutamida-50mg-14tab-7501349028296.jpg",
    },
    {
        "ean": "7501390910182",
        "snap": "BIOTREFON L C12 SOBR",
        "nombre": "Biotrefón L cobamamida 1000 mcg polvo C/12 sobres",
        "qty": 1, "pu": 298.69, "sub": 298.69,
        "tipo": "marca", "categoria": "Vitaminas", "subcategoria": None,
        "forma": "Polvo oral", "marca": "Biotrefón L", "laboratorio": "ITALMEX",
        "presentacion": "Caja con 12 sobres", "principio": "Cobamamida",
        "concentracion": "1000 mcg", "receta": False, "ya": False,
        "foto_file": "biotrefon-l-1000mcg-12sobres-7501390910182.jpg",
    },
    {
        "ean": "7501478317421",
        "snap": "BOCETIX LEVOCETIRIZI",
        "nombre": "Bocetix levocetirizina 0.5 mg/ml solución oral 150 ml",
        "qty": 2, "pu": 66.70, "sub": 133.40,
        "tipo": "marca", "categoria": "Respiratorio", "subcategoria": "Antihistamínico",
        "forma": "Solución oral", "marca": "Bocetix", "laboratorio": "VITAE",
        "presentacion": "Frasco 150 ml", "principio": "Levocetirizina",
        "concentracion": "0.5 mg/ml", "receta": False, "ya": True,
        "foto_file": "bocetix-levocetirizina-150ml.jpg",
    },
    {
        "ean": "7502009743993",
        "snap": "CARNITINA 500MG C30",
        "nombre": "Carnitina +B Naturex L-carnitina C/30 cápsulas",
        "qty": 2, "pu": 55.16, "sub": 110.32,
        "tipo": "marca", "categoria": "Vitaminas", "subcategoria": "Suplemento",
        "forma": "Cápsula", "marca": "Naturex", "laboratorio": "NATUREX",
        "presentacion": "Frasco con 30 cápsulas", "principio": "L-carnitina",
        "concentracion": "500 mg", "receta": False, "ya": False,
        "foto_file": "carnitina-naturex-500mg-30cap-7502009743993.jpg",
    },
    {
        "ean": "7506494600311",
        "snap": "CLOROPIRAMINA 25MG C",
        "nombre": "Cloropiramina 25 mg tabletas",
        "qty": 1, "pu": 40.24, "sub": 40.24,
        "tipo": "generico", "categoria": "Respiratorio", "subcategoria": "Antihistamínico",
        "forma": "Tableta", "marca": "Cloropiramina", "laboratorio": None,
        "presentacion": None, "principio": "Cloropiramina",
        "concentracion": "25 mg", "receta": True, "ya": False,
        "foto_file": None,  # TODO foto pendiente
    },
    {
        "ean": "7501836003140",
        "snap": "CONTRAXEN 200MG/2500",
        "nombre": "Contraxen carisoprodol 200 mg / naproxeno 250 mg C/30 cápsulas",
        "qty": 2, "pu": 78.80, "sub": 157.60,
        "tipo": "marca", "categoria": "Analgésico", "subcategoria": "Relajante muscular",
        "forma": "Cápsula", "marca": "Contraxen", "laboratorio": "LIFERPAL MD",
        "presentacion": "Caja con 30 cápsulas", "principio": "Carisoprodol / Naproxeno",
        "concentracion": "200 mg / 250 mg", "receta": True, "ya": False,
        "foto_file": "contraxen-200-250mg-30cap-7501836003140.jpg",
    },
    {
        "ean": "7501075711011",
        "snap": "DEBISOR 10MG C20 TA",
        "nombre": "Debisor dinitrato de isosorbida 10 mg C/20 tabletas",
        "qty": 3, "pu": 8.94, "sub": 26.82,
        "tipo": "marca", "categoria": "Cardiovascular", "subcategoria": None,
        "forma": "Tableta", "marca": "Debisor", "laboratorio": "NOVAG",
        "presentacion": "Caja con 20 tabletas", "principio": "Dinitrato de isosorbida",
        "concentracion": "10 mg", "receta": True, "ya": False,
        "foto_file": "debisor-isosorbida-10mg-20tab-7501075711011.jpg",
    },
    {
        "ean": "7501300422750",
        "snap": "DORIXINA FTE 250MG C",
        "nombre": "Dorixina Forte clonixinato de lisina 250 mg C/20 comprimidos",
        "qty": 1, "pu": 239.40, "sub": 239.40,
        "tipo": "marca", "categoria": "Analgésico", "subcategoria": None,
        "forma": "Comprimido", "marca": "Dorixina Forte", "laboratorio": "SIEGFRIED RHEIN",
        "presentacion": "Caja con 20 comprimidos", "principio": "Clonixinato de lisina",
        "concentracion": "250 mg", "receta": True, "ya": False,
        "foto_file": "dorixina-forte-250mg-20comp-7501300422750.jpg",
    },
    {
        "ean": "7501573925071",
        "snap": "DOSTERIL 10MG C30 TA",
        "nombre": "Dosteril lisinopril 10 mg C/30 tabletas",
        "qty": 4, "pu": 18.46, "sub": 73.84,
        "tipo": "marca", "categoria": "Cardiovascular", "subcategoria": None,
        "forma": "Tableta", "marca": "Dosteril", "laboratorio": "BIOMEP",
        "presentacion": "Caja con 30 tabletas", "principio": "Lisinopril",
        "concentracion": "10 mg", "receta": True, "ya": False,
        "foto_file": None,  # TODO foto pendiente
    },
    {
        "ean": "75004996",
        "snap": "ESPAVEN PED GTS 15",
        "nombre": "Espavén Pediátrico dimeticona 100 mg/ml gotas 30 ml",
        "qty": 1, "pu": 175.97, "sub": 175.97,
        "tipo": "marca", "categoria": "Gastro", "subcategoria": "Antiflatulento",
        "forma": "Gotas orales", "marca": "Espavén", "laboratorio": "BAUSCH HEALTH",
        "presentacion": "Frasco gotero 30 ml", "principio": "Dimeticona",
        "concentracion": "100 mg/ml", "receta": False, "ya": False,
        "foto_file": "espaven-pediatrico-gotas-30ml-75004996.jpg",
    },
    {
        "ean": "3664798073256",
        "snap": "HISTIACIL GR3 AMBROX",
        "nombre": "Histiacil GR3 ambroxol 20 mg pastillas limón C/18",
        "qty": 1, "pu": 109.51, "sub": 109.51,
        "tipo": "marca", "categoria": "Respiratorio", "subcategoria": None,
        "forma": "Pastilla bucal", "marca": "Histiacil", "laboratorio": "SANOFI",
        "presentacion": "Caja con 18 pastillas", "principio": "Ambroxol",
        "concentracion": "20 mg", "receta": False, "ya": False,
        "foto_file": "histiacil-gr3-ambroxol-limon-18-3664798073256.jpg",
    },
    {
        "ean": "7891317048860",
        "snap": "MELOX PLUS C30 TABS",
        "nombre": "Melox Plus Cereza tabletas masticables C/30",
        "qty": 1, "pu": 94.86, "sub": 94.86,
        "tipo": "marca", "categoria": "Gastro", "subcategoria": "Antiácido",
        "forma": "Tableta masticable", "marca": "Melox Plus", "laboratorio": "EUROFARMA",
        "presentacion": "Caja con 30 tabletas", "principio": "Aluminio / Magnesio / Simeticona",
        "concentracion": "200/200/25 mg", "receta": False, "ya": False,
        "foto_file": "melox-plus-cereza-30tab-7891317048860.jpg",
    },
    {
        "ean": "7501109902637",
        "snap": "MOTRIN GTS PEDIATR",
        "nombre": "Motrin Pediátrico ibuprofeno 40 mg/ml gotas 15 ml",
        "qty": 1, "pu": 117.88, "sub": 117.88,
        "tipo": "marca", "categoria": "Analgésico", "subcategoria": "Pediátrico",
        "forma": "Suspensión oral", "marca": "Motrin", "laboratorio": "KENVUE",
        "presentacion": "Frasco 15 ml + pipeta", "principio": "Ibuprofeno",
        "concentracion": "40 mg/ml", "receta": False, "ya": False,
        "foto_file": "motrin-pediatrico-gotas-15ml-7501109902637.jpg",
    },
    {
        "ean": "7501109902866",
        "snap": "MOTRIN INF SUSP 20M",
        "nombre": "Motrin Infantil ibuprofeno suspensión 120 ml",
        "qty": 2, "pu": 184.49, "sub": 368.98,
        "tipo": "marca", "categoria": "Analgésico", "subcategoria": "Pediátrico",
        "forma": "Suspensión oral", "marca": "Motrin", "laboratorio": "KENVUE",
        "presentacion": "Frasco 120 ml", "principio": "Ibuprofeno",
        "concentracion": "100 mg/5 ml", "receta": False, "ya": False,
        "foto_file": "motrin-infantil-susp-120ml-7501109902866.jpg",
    },
    {
        "ean": "7506295337454",
        "snap": "PBA EMB CLEAR BLUE D",
        "nombre": "Clearblue Digital prueba de embarazo con indicador de semanas",
        "qty": 2, "pu": 191.15, "sub": 382.29,
        "tipo": "marca", "categoria": "Pruebas", "subcategoria": "Embarazo",
        "forma": "Prueba diagnóstica", "marca": "Clearblue", "laboratorio": "SPD / P&G",
        "presentacion": "Caja con 1 prueba", "principio": None,
        "concentracion": None, "receta": False, "ya": False,
        "foto_file": "clearblue-digital-embarazo-7506295337454.jpg",
    },
    {
        "ean": "7502009744341",
        "snap": "PRILVER 5MG C16 TABS",
        "nombre": "Prilver ramipril 5 mg C/16 tabletas",
        "qty": 3, "pu": 38.86, "sub": 116.58,
        "tipo": "marca", "categoria": "Cardiovascular", "subcategoria": None,
        "forma": "Tableta", "marca": "Prilver", "laboratorio": "MAVER",
        "presentacion": "Caja con 16 tabletas", "principio": "Ramipril",
        "concentracion": "5 mg", "receta": True, "ya": False,
        "foto_file": "prilver-ramipril-5mg-16tab-7502009744341.jpg",
    },
    {
        "ean": "7501168810713",
        "snap": "SALOFALK 500 MG C 40",
        "nombre": "Salofalk mesalazina 500 mg C/40 tabletas",
        "qty": 1, "pu": 446.06, "sub": 446.06,
        "tipo": "marca", "categoria": "Gastro", "subcategoria": None,
        "forma": "Tableta", "marca": "Salofalk", "laboratorio": "FARMASA",
        "presentacion": "Caja con 40 tabletas", "principio": "Mesalazina",
        "concentracion": "500 mg", "receta": True, "ya": False,
        "foto_file": "salofalk-mesalazina-500mg-40tab-7501168810713.jpg",
    },
    {
        "ean": "7503003738671",
        "snap": "SEPIA 33 3 166 6MG",
        "nombre": "Sepia itraconazol 33.3 mg / secnidazol 166.6 mg C/16 cápsulas",
        "qty": 1, "pu": 96.59, "sub": 96.59,
        "tipo": "marca", "categoria": "Ginecología", "subcategoria": None,
        "forma": "Cápsula", "marca": "Sepia", "laboratorio": "WERMAR",
        "presentacion": "Caja con 16 cápsulas", "principio": "Itraconazol / Secnidazol",
        "concentracion": "33.3 mg / 166.6 mg", "receta": True, "ya": False,
        "foto_file": None,  # TODO foto pendiente
    },
    {
        "ean": "7503045798022",
        "snap": "SITAGLIPTINA METFORM",
        "nombre": "Dinaglix-Duo sitagliptina 50 mg / metformina 500 mg C/28",
        "qty": 1, "pu": 98.27, "sub": 98.27,
        "tipo": "marca", "categoria": "Diabetes", "subcategoria": None,
        "forma": "Comprimido", "marca": "Dinaglix-Duo", "laboratorio": "MAVER",
        "presentacion": "Caja con 28 comprimidos", "principio": "Sitagliptina / Metformina",
        "concentracion": "50 mg / 500 mg", "receta": True, "ya": False,
        "foto_file": None,  # TODO foto pendiente
    },
    {
        "ean": "7502009749469",
        "snap": "TRIBENOSIDO/LIDOCAIN",
        "nombre": "Tribenósido 5% / lidocaína 2% crema rectal 30 g",
        "qty": 2, "pu": 78.00, "sub": 156.00,
        "tipo": "generico", "categoria": "Gastro", "subcategoria": "Proctología",
        "forma": "Crema rectal", "marca": "Maver", "laboratorio": "MAVER",
        "presentacion": "Tubo 30 g", "principio": "Tribenósido / Lidocaína",
        "concentracion": "5% / 2%", "receta": True, "ya": False,
        "foto_file": None,  # TODO foto pendiente
    },
    {
        "ean": "7501065054043",
        "snap": "TUMS SURT C3",
        "nombre": "Tums Extra surtido 750 mg C/3 (3 rollos × 8)",
        "qty": 4, "pu": 39.44, "sub": 157.76,
        "tipo": "marca", "categoria": "Gastro", "subcategoria": "Antiácido",
        "forma": "Tableta masticable", "marca": "Tums", "laboratorio": "HALEON",
        "presentacion": "3 rollos × 8 tabletas", "principio": "Carbonato de calcio",
        "concentracion": "750 mg", "receta": False, "ya": True,
        "foto_file": "tums-extra-surtido-c3-7501065054043.jpg",
    },
    {
        "ean": "7501258208550",
        "snap": "VALACICLOVIR 500MG T",
        "nombre": "Valaciclovir Serral 500 mg C/10 tabletas",
        "qty": 1, "pu": 224.98, "sub": 224.98,
        "tipo": "generico", "categoria": "Medicamentos", "subcategoria": "Antiviral",
        "forma": "Tableta", "marca": "Serral", "laboratorio": "SERRAL",
        "presentacion": "Caja con 10 tabletas", "principio": "Valaciclovir",
        "concentracion": "500 mg", "receta": True, "ya": False,
        "foto_file": None,  # TODO foto pendiente
    },
]

for r in ROWS:
    r["sku"] = sku_de(r["ean"])
    url, path = foto(r.get("foto_file"))
    # Bocetix ya tiene foto propia sin EAN en el nombre
    if r["ean"] == "7501478317421":
        url, path = foto("bocetix-levocetirizina-150ml.jpg")
    r["foto"] = url
    r["foto_file_sql"] = path


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
    n_alta = sum(1 for r in ROWS if not r["ya"])
    n_ya = sum(1 for r in ROWS if r["ya"])
    sin_foto = [r["ean"] for r in ROWS if not r["foto"]]

    body = f"""-- =============================================================================
-- ESTE es el archivo para Supabase (SQL). NO pegues scripts/generar_carga_*.py
-- Archivo: sql/patch_carga_cityfarma_s322817.sql
-- Pegar TODO abajo en Supabase → SQL Editor → Run.
-- =============================================================================
-- Cityfarma Iztapalapa · orden {FOLIO} · {FECHA} 17:30
-- Ticket térmico Central de Abastos. P.U. ya trae IVA (total impreso ${TOTAL_TICKET:.2f}).
-- {len(ROWS)} renglones · {n_alta} altas stock 0 · {n_ya} ya en catálogo.
-- Sin lote ni caducidad (MMAA de la caja). No inventar 0000.
-- Nombres de ficha (YZA/Fahorro/Kenvue), no del ticket.
-- Fotos en public/catalogo-propia/ (tras deploy). Pendientes: {', '.join(sin_foto) or 'ninguna'}.
-- SIN bloques dollar-quote. Idempotente mientras el ticket siga en borrador.

begin;

create temp table _fc_cf_s322817 (
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

insert into _fc_cf_s322817 (
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
from _fc_cf_s322817 t
where public.fc_buscar_producto_escaneo(t.ean) is null;

-- Ya existían: costo solo si el ticket es más barato (o no había). PVP solo si está en 0.
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
from _fc_cf_s322817 t
where p.id = public.fc_buscar_producto_escaneo(t.ean)
  and (
    coalesce(p.costo, 0) <= 0
    or t.costo < p.costo
    or coalesce(p.precio, 0) <= 0
  );

-- Ficha / foto si faltan (no pisa lo que ya esté).
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
from _fc_cf_s322817 t
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
from _fc_cf_s322817 t
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
from _fc_cf_s322817 t
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
    skus = [x["sku"] for x in ROWS]
    assert len(skus) == len(set(skus)), skus
    assert len(ROWS) == 23, len(ROWS)
    suma = sum(x["sub"] for x in ROWS)
    assert abs(suma - TOTAL_TICKET) < 0.02, (suma, TOTAL_TICKET)
    for x in ROWS:
        assert abs(x["pu"] * x["qty"] - x["sub"]) < 0.02 or x["ean"] == "7506295337454", x
        assert "BLOQ" not in x["nombre"].upper()
        # no usar el código truncado del ticket como nombre de mostrador
        assert x["nombre"] != x["snap"]
        assert not x["nombre"].startswith("ACARBOSA 50MG")
        assert "Biotrefón" in x["nombre"] or "Biotrefon" not in x["snap"] or x["ean"] != "7501390910182"

    # Clearblue: subtotal impreso 382.29 vs 2×191.15
    cb = next(x for x in ROWS if x["ean"] == "7506295337454")
    assert cb["sub"] == 382.29

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
    print("sin_foto", [x["ean"] for x in ROWS if not x["foto"]])
    for x in ROWS:
        print(
            f"  {x['ean']}  {x['qty']}×{x['pu']:.2f}  PVP {ceil_pvp(x['pu'])}  "
            f"{'ya' if x['ya'] else 'ALTA'}  {x['nombre']}"
        )
