#!/usr/bin/env python3
"""Farma City / Cityfarma Iztapalapa 23-nov-2026 → altas + cola Recibir.

Ticket Luis Angel Palillero Ventura · prioridad ALTA · surtido sin certificar
· impresión 23/11/2026 13:28:46 · 18 renglones · 60 pzas · $3,312.49 efectivo.

Folio en papel tapado por estampa SURTIDO → S341128 (13:28 del 23).
Lote de fábrica sí (cuando viene en el papel). Caducidad null (MMAA de la caja).
SIN producto_imagenes en el mismo txn. SIN bloques dollar-quote.
"""
from __future__ import annotations

import math
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
OUT_SQL = ROOT / "sql" / "patch_recibir_farmacity_S341128_SOLO_pegar_esto.sql"
OUT_MD = ROOT / "sql" / "LEERME_farmacity_S341128_SOLO_pegar_esto.md"
FOTO = "https://www.farmacapital.mx/catalogo-propia"

FOLIO = "S341128"
PROVEEDOR = "Cityfarma Iztapalapa"
FECHA = "2026-11-23"
TOTAL = 3312.49


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
    return f"{FOTO}/{name}" if name else None


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
    "7501008499818": P(
        "7501008499818",
        nombre="Aspirina 500 mg",
        marca="Aspirina",
        laboratorio="Bayer",
        presentacion="Caja con 80 tabletas",
        forma="Tabletas",
        principio="Acido acetilsalicilico",
        concentracion="500 mg",
        ya=True,
        sku="FC-08499818",
    ),
    "7502001166066": P(
        "7502001166066",
        nombre="Barmicil",
        marca="Barmicil",
        laboratorio="Sons",
        presentacion="Tubo 40 g",
        forma="Crema",
        principio="Betametasona / Gentamicina / Clotrimazol",
        ya=True,
        sku="FC-01166066",
    ),
    "7501008433676": P(
        "7501008433676",
        nombre="Cafiaspirina",
        marca="Cafiaspirina",
        laboratorio="Bayer",
        presentacion="Caja con 40 tabletas",
        forma="Tabletas",
        principio="Acido acetilsalicilico / Cafeina",
        ya=False,
    ),
    "7501008433553": P(
        "7501008433553",
        nombre="Cafiaspirina Forte",
        marca="Cafiaspirina",
        laboratorio="Bayer",
        presentacion="Caja con 24 tabletas",
        forma="Tabletas",
        principio="Acido acetilsalicilico / Cafeina",
        ya=True,
    ),
    "7502009743627": P(
        "7502009743627",
        nombre="Cefalexina suspension 250 mg/5 ml",
        tipo="generico",
        marca="Cefalexina",
        laboratorio="Maver",
        presentacion="Frasco 100 ml",
        forma="Suspension",
        principio="Cefalexina",
        concentracion="250 mg/5 ml",
        receta=True,
        ya=False,
    ),
    "7502240450018": P(
        "7502240450018",
        nombre="Charyn 500 mg",
        marca="Charyn",
        laboratorio="Wermar",
        presentacion="Caja con 3 tabletas",
        forma="Tabletas",
        principio="Azitromicina",
        concentracion="500 mg",
        receta=True,
        ya=True,
        sku="EQ-WER038",
    ),
    "7502240450025": P(
        "7502240450025",
        nombre="Charyn 500 mg",
        marca="Charyn",
        laboratorio="Wermar",
        presentacion="Caja con 4 tabletas",
        forma="Tabletas",
        principio="Azitromicina",
        concentracion="500 mg",
        receta=True,
        ya=False,
    ),
    "7501258205221": P(
        "7501258205221",
        nombre="Cyrux 200 mcg",
        marca="Cyrux",
        laboratorio="Serral",
        presentacion="Caja con 28 tabletas",
        forma="Tabletas",
        principio="Misoprostol",
        concentracion="200 mcg",
        receta=True,
        ya=False,
    ),
    "5000174003963": P(
        "5000174003963",
        nombre="Fixodent Fresh",
        categoria="Cuidado personal",
        marca="Fixodent",
        presentacion="Pasta 40 g",
        forma="Adhesivo dental",
        ya=False,
        foto_file="fixodent-fresh-40g.jpg",
    ),
    "650240070389": P(
        "650240070389",
        nombre="Genoprazol 20 mg",
        marca="Genoprazol",
        laboratorio="Genomma",
        presentacion="2 pack 14 capsulas",
        forma="Capsulas",
        principio="Omeprazol",
        concentracion="20 mg",
        ya=False,
    ),
    "7501871720606": P(
        "7501871720606",
        nombre="Geslutin 100 mg",
        marca="Geslutin",
        laboratorio="Asofarma",
        presentacion="Caja con 30 perlas",
        forma="Perlas",
        principio="Progesterona",
        concentracion="100 mg",
        receta=True,
        ya=False,
    ),
    "7501547509016": P(
        "7501547509016",
        nombre="Indarzona",
        marca="Indarzona",
        laboratorio="Streger",
        presentacion="Caja con 30 capsulas",
        forma="Capsulas",
        principio="Indometacina / Dexametasona",
        concentracion="25 mg / 0.5 mg",
        receta=True,
        ya=True,
        sku="FC-F7A2CACF",
    ),
    "7502001162365": P(
        "7502001162365",
        nombre="Mornin 40 mg",
        marca="Mornin",
        laboratorio="Sons",
        presentacion="Caja con 7 capsulas",
        forma="Capsulas",
        principio="Omeprazol",
        concentracion="40 mg",
        ya=True,
        sku="FC-01162365",
    ),
    # Ticket 8400007018 (sin ceros). Canonico Grin: 008400007018.
    "008400007018": P(
        "008400007018",
        nombre="Neomicina Polimixina Gramicidina",
        tipo="generico",
        marca="Grin",
        laboratorio="Grin",
        presentacion="Frasco 15 ml",
        forma="Gotas oftalmicas",
        principio="Neomicina / Polimixina B / Gramicidina",
        receta=True,
        ya=False,
    ),
    "7502009749247": P(
        "7502009749247",
        nombre="Rivaroxaban 20 mg",
        tipo="generico",
        marca="Rivaroxaban",
        laboratorio="Maver",
        presentacion="Caja con 28 tabletas",
        forma="Tabletas",
        principio="Rivaroxaban",
        concentracion="20 mg",
        receta=True,
        ya=False,
    ),
    "650240010712": P(
        "650240010712",
        nombre="Tukol-D jarabe adulto",
        marca="Tukol-D",
        laboratorio="Genomma",
        presentacion="Frasco 125 ml",
        forma="Jarabe",
        principio="Guaifenesina / Dextrometorfano",
        ya=True,
        sku="FC-40010712",
    ),
    "3700039500027": P(
        "3700039500027",
        nombre="Utrogestan 100 mg",
        marca="Utrogestan",
        laboratorio="Besins",
        presentacion="Caja",
        forma="Capsulas",
        principio="Progesterona",
        concentracion="100 mg",
        receta=True,
        ya=False,
    ),
    "7502223553477": P(
        "7502223553477",
        nombre="Zolufen 20 mg",
        marca="Zolufen",
        laboratorio="Synthon",
        presentacion="Frasco con 30 capsulas",
        forma="Capsulas",
        principio="Omeprazol",
        concentracion="20 mg",
        ya=True,
        sku="FC-23553477",
        foto_file="zolufen-omeprazol-20mg-30caps-7502223553477.jpg",
    ),
}


# (ean_ticket, snap, qty, pu, lote)
# Neomicina: en papel 8400007018 → EAN canonico 008400007018
LINES: list[tuple[str, str, int, float, str | None]] = [
    ("7501008499818", "ASPIRINA 500MG C80 T", 2, 75.51, "X26SW7"),
    ("7502001166066", "BARMICIL 40G SONS BE", 15, 19.82, None),
    ("7501008433676", "CAFIASPIRINA 40TAB J", 3, 42.05, None),
    ("7501008433553", "CAFIASPIRINA FORTE C", 3, 71.71, None),
    ("7502009743627", "CEFALEXINA SUSP 250M", 3, 21.46, "264360"),
    ("7502240450018", "CHARYN 500MG C 3 TAB", 10, 22.35, "260460"),
    ("7502240450025", "CHARYN C4TAB 500MG A", 5, 29.89, "260533"),
    ("7501258205221", "CYRUX 200MG C28 TABS", 2, 186.18, "260474"),
    ("5000174003963", "FIXODENT FRESH PAST", 2, 89.21, "6054028890"),
    ("650240070389", "GENOPRAZOL 20MG CAP", 1, 82.84, "G248"),
    ("7501871720606", "GESLUTIN 100MG C 30", 1, 460.06, "10049"),
    ("7501547509016", "INDARZONA CAP C 30", 2, 56.50, "SB02DC"),
    ("7502001162365", "MORNIN 40MG C7 CAPS", 5, 12.91, "26061602"),
    ("008400007018", "NEOMICINA POLIMIXINA", 1, 53.32, "XB01110"),
    ("7502009749247", "RIVAROXABAN 20MG C28", 2, 151.44, "255115"),
    ("650240010712", "TUKOL D JBE AD 125", 1, 94.73, None),
    ("3700039500027", "UTROGESTAN 100MG PER", 1, 347.53, "262085"),
    ("7502223553477", "ZOLUFEN 20MG CAP C30", 1, 15.88, "Z26013A"),
]


def build_rows() -> list[dict]:
    out = []
    for ean, snap, qty, pu, lote in LINES:
        f = CAT[ean]
        costo = round(pu, 2)
        out.append(
            {
                **f,
                "snap": snap[:60],
                "qty": qty,
                "pu": costo,
                "precio": ceil_pvp(costo, f["tipo"]),
                "lote": lote,
                "sub": round(qty * pu, 2),
            }
        )
    return out


def render(rows: list[dict]) -> str:
    tmp = "_fc_cf_s341128"
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
                lote=sql_str(r["lote"]),
            )
        )
    n_alta = sum(1 for r in rows if not r["ya"])
    n_ya = sum(1 for r in rows if r["ya"])
    ilike = sql_str("%cityfarma%")
    notas = (
        f"Cityfarma Iztapalapa · orden {FOLIO} · 23-nov-2026 13:28 · "
        "cliente Luis Angel Palillero Ventura · prioridad ALTA · surtido sin certificar · "
        "18 renglones · 60 pzas · efectivo $3,312.49 · folio estimado (estampa tapa orden) · "
        "lote de fabrica si; caducidad NO · cola Recibir"
    )
    return f"""-- =============================================================================
-- PEGAR TODO ESTE ARCHIVO en Supabase → SQL Editor → Run
-- Farma City / Cityfarma Iztapalapa {FOLIO} · $3,312.49 · 18 renglones · 60 pzas
-- Merge a GitHub NO crea la cola. Sin dollar-quote. Sin producto_imagenes.
-- Lote de fabrica si. Caducidad null: MMAA de la caja. No inventar 0000.
-- =============================================================================

rollback;

-- ========== {PROVEEDOR} {FOLIO} ==========
-- {PROVEEDOR} · folio {FOLIO} · {FECHA} · total ${TOTAL:,.2f} · 18 renglones
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
{chr(10).join(v + (',' if i < len(vals) else '') for i, v in enumerate(vals, start=1))};

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
  'Alta {PROVEEDOR} {FOLIO} · {FECHA} · listo para pistola',
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
  {sql_str(PROVEEDOR)},
  {sql_str(FOLIO)},
  {sql_str(FECHA)},
  {TOTAL:.2f},
  'borrador',
  {sql_str(notas)}
where not exists (
  select 1 from public.recepciones
  where folio = {sql_str(FOLIO)}
    and coalesce(proveedor, '') ilike {ilike}
);

update public.recepciones
set
  total_ticket = {TOTAL:.2f},
  fecha = {sql_str(FECHA)},
  proveedor = {sql_str(PROVEEDOR)},
  notas = {sql_str(notas)},
  updated_at = now()
where folio = {sql_str(FOLIO)}
  and coalesce(proveedor, '') ilike {ilike}
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = {sql_str(FOLIO)}
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
  on r.folio = {sql_str(FOLIO)}
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
where r.folio = {sql_str(FOLIO)}
  and coalesce(r.proveedor, '') ilike {ilike}
group by r.id, r.folio, r.proveedor, r.estado, r.total_ticket;

select
  t.linea,
  t.ean,
  t.sku,
  t.nombre,
  t.qty,
  t.costo,
  t.lote,
  case
    when coalesce(
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
    ) is null then 'PENDIENTE_ALTA' else 'OK' end as match,
  t.ya as marcado_ya
from {tmp} t
order by t.linea;

commit;
"""


def main() -> None:
    rows = build_rows()
    missing = [ean for ean, *_ in LINES if ean not in CAT]
    if missing:
        raise SystemExit(f"Faltan fichas: {missing}")
    s = round(sum(r["sub"] for r in rows), 2)
    if abs(s - TOTAL) > 0.05:
        raise SystemExit(f"suma {s} != {TOTAL}")
    piezas = sum(r["qty"] for r in rows)
    if piezas != 60:
        raise SystemExit(f"piezas {piezas} != 60")
    print(f"{FOLIO}: {len(rows)} rows · sum {s} · piezas {piezas} · total {TOTAL}")

    sql = render(rows)
    if "$$" in sql:
        raise SystemExit("ERROR: el SQL contiene $$")
    OUT_SQL.write_text(sql, encoding="utf-8")
    OUT_MD.write_text(
        f"""# Farma City / Cityfarma Iztapalapa {FOLIO} — pegar en Supabase

Luis Angel Palillero Ventura · 23-nov-2026 13:28 · **${TOTAL:,.2f}** · 60 pzas · 18 renglones.
Folio en papel tapado por estampa SURTIDO → **`{FOLIO}`** (hora de impresión).

## Pegar ahora

1. Raw: https://raw.githubusercontent.com/ibarraivane/farmacapital/main/sql/patch_recibir_farmacity_S341128_SOLO_pegar_esto.sql
2. Selecciona TODO → copiar → Supabase SQL Editor → **Run**
3. VERIFICACION: folio `{FOLIO}`, estado `borrador`, 18 renglones, 60 piezas
4. Tablet: Recibir → recargar → tarjeta **Cityfarma Iztapalapa · {FOLIO}** (Farma City)

Lote de fábrica sí. MMAA de la caja. Si el folio real en papel es otro Sxxxxx, avisa y lo renombramos.

## Notas

- Neomicina: papel `8400007018` → EAN canónico Grin `008400007018`.
- Cyrux: **200 mcg** (no mg) misoprostol Serral.
- Genoprazol: 2 pack 14 cápsulas omeprazol 20 mg.
""",
        encoding="utf-8",
    )
    print(f"→ {OUT_SQL.relative_to(ROOT)} ({OUT_SQL.stat().st_size} bytes)")
    print(f"→ {OUT_MD.relative_to(ROOT)}")


if __name__ == "__main__":
    main()
