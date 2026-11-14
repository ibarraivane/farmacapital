#!/usr/bin/env python3
"""Carrito Farmater Ventas (farmaterventas.com) 13-nov-2026 → cola Recibir.

Cityfarma Iztapalapa · folio FCV-20261113 · $1,153.37 · 15 renglones.
Fotos del carrito (aún sin folio de pedido post-checkout).
P.U. ya con IVA / oferta (suma qty×P.U. ≈ total carrito).
Nombres de ficha (BuscaMed / PLM / catálogo previo), no del renglón *FC*.
CADP 11-2027 de Normex en vitrina NO se guarda como caducidad (MMAA de caja).
SIN producto_imagenes en el mismo txn. SIN bloques dollar-quote.
"""
from __future__ import annotations

import math
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
OUT_SQL = ROOT / "sql" / "patch_recibir_farmater_fcv_20261113_SOLO_pegar_esto.sql"
OUT_MD = ROOT / "sql" / "LEERME_farmater_fcv_20261113_SOLO_pegar_esto.md"
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
    tipo: str = "generico",
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


# Fichas de mostrador por EAN (BuscaMed / PLM / cargas previas).
CAT: dict[str, dict] = {
    # BuscaMed EAN → Micromex (Farmater etiqueta MICRO LABS).
    "7502231321778": P(
        "7502231321778",
        nombre="Olopatadina 2 mg/ml",
        tipo="generico",
        subcategoria="Oftálmico",
        forma="Gotas oftálmicas",
        marca="Olopatadina",
        laboratorio="Micromex",
        presentacion="Frasco gotero 5 ml",
        principio="Olopatadina",
        concentracion="2 mg/ml",
        receta=True,
        ya=False,
    ),
    # Tenorio / PLM / BuscaMed.
    "7501300420541": P(
        "7501300420541",
        nombre="Aliren 50/3/300 mg",
        tipo="marca",
        subcategoria="Respiratorio",
        forma="Cápsulas",
        marca="Aliren",
        laboratorio="Siegfried Rhein",
        presentacion="Caja con 24 cápsulas",
        principio="Amantadina / clorfenamina / paracetamol",
        concentracion="50/3/300 mg",
        receta=False,
        ya=True,
        foto_file="aliren-50-3-300-c24-7501300420541.jpg",
    ),
    # BuscaMed / ADN Pharma.
    "7500462933746": P(
        "7500462933746",
        nombre="Inha-Rub",
        tipo="marca",
        categoria="Cuidado personal",
        subcategoria="Respiratorio",
        forma="Ungüento",
        marca="Inha-Rub",
        laboratorio="ADN Pharma",
        presentacion="Tarro 40 g",
        principio="Alcanfor / mentol / eucalipto",
        receta=False,
        ya=False,
    ),
    # Catálogo previo FC-02012475.
    "7590002012475": P(
        "7590002012475",
        nombre="Vicks VapoRub",
        tipo="marca",
        categoria="Cuidado personal",
        subcategoria="Respiratorio",
        forma="Ungüento",
        marca="Vicks",
        laboratorio="Procter & Gamble",
        presentacion="Tarro 100 g",
        principio="Alcanfor / mentol / eucalipto",
        receta=False,
        ya=True,
        sku="FC-02012475",
    ),
    # Farmacias Liz / Biomep · paracetamol 750.
    "7501573900269": P(
        "7501573900269",
        nombre="Quitadol 750 mg",
        tipo="generico",
        categoria="Analgésico",
        forma="Tabletas",
        marca="Quitadol",
        laboratorio="Biomep",
        presentacion="Caja con 10 tabletas",
        principio="Paracetamol",
        concentracion="750 mg",
        receta=False,
        ya=False,
    ),
    # Lote4 / Loeffler · terbinafina 1% 30 g.
    "7502211783282": P(
        "7502211783282",
        nombre="Erbitrax 1%",
        tipo="generico",
        categoria="Dermatología",
        forma="Crema",
        marca="Erbitrax",
        laboratorio="Loeffler",
        presentacion="Tubo 30 g",
        principio="Terbinafina",
        concentracion="1%",
        receta=False,
        ya=True,
        sku="FC-11783282",
    ),
    # DISA / Loeffler · terbinafina 1% 15 g.
    "7502211783275": P(
        "7502211783275",
        nombre="Erbitrax 1%",
        tipo="generico",
        categoria="Dermatología",
        forma="Crema",
        marca="Erbitrax",
        laboratorio="Loeffler",
        presentacion="Tubo 15 g",
        principio="Terbinafina",
        concentracion="1%",
        receta=False,
        ya=False,
    ),
    # Levic / Brudifarma · prednisolona.
    "7501537102395": P(
        "7501537102395",
        nombre="Norapred 50 mg",
        tipo="generico",
        forma="Tabletas",
        marca="Norapred",
        laboratorio="Brudifarma",
        presentacion="Caja con 20 tabletas",
        principio="Prednisolona",
        concentracion="50 mg",
        receta=True,
        ya=True,
        sku="FMX-502376",
    ),
    # PLM · ambroxol / dextrometorfano adulto 225/225 mg/100 ml.
    "7501537103484": P(
        "7501537103484",
        nombre="Oxolbrul adulto",
        tipo="generico",
        subcategoria="Respiratorio",
        forma="Solución oral",
        marca="Oxolbrul",
        laboratorio="Brudifarma",
        presentacion="Frasco 120 ml",
        principio="Ambroxol / dextrometorfano",
        concentracion="225/225 mg/100 ml",
        receta=False,
        ya=False,
    ),
    # Maver · betametasona / dexclorofeniramina.
    "7502009746239": P(
        "7502009746239",
        nombre="Erispan compuesto 5/0.25 mg",
        tipo="marca",
        forma="Tabletas",
        marca="Erispan",
        laboratorio="Maver",
        presentacion="Caja con 10 tabletas",
        principio="Betametasona / dexclorofeniramina",
        concentracion="5 mg / 0.25 mg",
        receta=True,
        ya=True,
        sku="EQ-MAV295",
    ),
    # Ticket 04-nov · Hypack.
    "7502009740916": P(
        "7502009740916",
        nombre="Erispan Hypack 8 mg/2 ml",
        tipo="marca",
        forma="Solución inyectable",
        marca="Erispan",
        laboratorio="Maver",
        presentacion="Frasco ámpula 2 ml",
        principio="Betametasona",
        concentracion="8 mg/2 ml",
        receta=True,
        ya=True,
        sku="FC-50AC2C82",
        foto_file="erispan-hypack-8mg-7502009740916.jpg",
    ),
    # Lote4 / Quifa · leche de magnesia. CADP 11-2027 solo en vitrina.
    "7501109790739": P(
        "7501109790739",
        nombre="Normex leche de magnesia",
        tipo="marca",
        categoria="Gastro",
        forma="Suspensión",
        marca="Normex",
        laboratorio="Química y Farmacia",
        presentacion="Frasco 60 ml",
        principio="Hidróxido de magnesio",
        concentracion="8.5 g/100 ml",
        receta=False,
        ya=True,
        sku="FC-09790739",
    ),
    # Progela · ibuprofeno 400 (distinto de Gelubrin 600 FC-5C8C9C11).
    "7503008344785": P(
        "7503008344785",
        nombre="Gelubrin 400 mg",
        tipo="generico",
        categoria="Analgésico",
        forma="Cápsulas",
        marca="Gelubrin",
        laboratorio="Progela",
        presentacion="Caja con 10 cápsulas",
        principio="Ibuprofeno",
        concentracion="400 mg",
        receta=False,
        ya=True,
        sku="EQ-PGE033",
    ),
    # DISA / Genética · ibuprofeno 400.
    "7501842900099": P(
        "7501842900099",
        nombre="Adopren 400 mg",
        tipo="generico",
        categoria="Analgésico",
        forma="Tabletas",
        marca="Adopren",
        laboratorio="Genética",
        presentacion="Caja con 10 tabletas",
        principio="Ibuprofeno",
        concentracion="400 mg",
        receta=True,
        ya=False,
    ),
    # PiSA · NaCl 0.9% 1000 ml.
    "7501125100130": P(
        "7501125100130",
        nombre="Solución CS 0.9%",
        tipo="generico",
        categoria="Hidratación",
        forma="Solución intravenosa",
        marca="Solución CS",
        laboratorio="PiSA",
        presentacion="Bolsa 1000 ml",
        principio="Cloruro de sodio",
        concentracion="0.9%",
        receta=True,
        ya=True,
        sku="FMX-503320",
    ),
}


def row(ean: str, snap: str, qty: int, pu: float) -> dict:
    if ean not in CAT:
        raise SystemExit(f"Falta ficha CAT para EAN {ean}")
    p = CAT[ean]
    return {
        **p,
        "snap": snap,
        "qty": qty,
        "pu": round(pu, 2),
        "sub": round(qty * round(pu, 2), 2),
        "precio": ceil_pvp(pu, p["tipo"]),
    }


TICKET = {
    "key": "farmater_fcv_20261113",
    "tmp": "_fc_fcv_20261113",
    "folio": "FCV-20261113",
    "proveedor": "Cityfarma Iztapalapa",
    "proveedor_ilike": "cityfarma",
    "fecha": "2026-11-13",
    "total": 1153.37,
    "notas": (
        "Farmater Ventas (farmaterventas.com) · carrito 13-nov-2026 21:11 · "
        "folio interno FCV-20261113 (sin No. pedido post-checkout en fotos) · "
        "15 renglones · P.U. oferta con IVA · total $1,153.37 · "
        "Normex vitrina CADP 11-2027 → caducidad null (MMAA de caja) · cola Recibir"
    ),
    "header": (
        "Cityfarma Iztapalapa · folio FCV-20261113 · 2026-11-13 · total $1,153.37 · 15 renglones\n"
        "-- Carrito farmaterventas.com. P.U. oferta con IVA."
    ),
    "rows": [
        row("7502231321778", "OLOPATADINA 2.0MG/ML GTS OFT 5ML *MIC*", 1, 139.25),
        row("7501300420541", "ALIREN 50/3/300MG CAP C/24 *SGF*", 1, 118.68),
        row("7500462933746", "INHA-RUB UNG 40GR *ADN*", 1, 19.89),
        row("7590002012475", "VICK VAPORUB UNG 100GR *P&G*", 1, 194.38),
        row("7501573900269", "*FC* QUITADOL 750MG. TAB. C/10 *BMP*", 5, 7.78),
        row("7502211783282", "*FC* ERBITRAX 1% CREMA 30GR. *LOE*PI", 2, 24.35),
        row("7502211783275", "*FC* ERBITRAX 1% CREMA 15GR. *LOE*", 2, 18.90),
        row("7501537102395", "*FC* NORAPRED 50MG. TAB. C/20 *BRU*", 3, 31.43),
        row("7501537103484", "*FC* OXOLBRUL ADT 225/225MG/100ML SOL 120ML *BRU*", 2, 20.12),
        row("7502009746239", "*FC* ERISPAN COMPUESTO 5.0/0.25MG TAB C/10 *MVE*", 3, 8.38),
        row("7502009740916", "*FC* ERISPAN 8MG/2ML SOL INY. C/1 *MVE*", 3, 23.31),
        row("7501109790739", "*FC* CADP 11-2027 NORMEX 8.5GR SUSP 60ML. *QYF*", 2, 12.02),
        row("7503008344785", "*FC* GELUBRIN 400MG CAP C/10 *PRO*", 10, 12.27),
        row("7501842900099", "*FC* ADOPREN 400MG TAB C/10 *GEN* R", 3, 10.82),
        row("7501125100130", "*FC* SOLUC. CS 1000ML. *PIS* R", 4, 36.73),
    ],
}


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
    t = TICKET
    s = round(sum(r["sub"] for r in t["rows"]), 2)
    # Carrito muestra totales de renglón redondeados; qty×P.U. puede diferir ~$0.05.
    line_display = 1153.37
    diff = abs(s - t["total"])
    if diff > 0.10:
        raise SystemExit(f"{t['folio']}: sum {s} != total {t['total']} (diff {diff})")
    print(
        f"{t['folio']}: {len(t['rows'])} rows · sum qty×PU {s} · "
        f"total carrito {line_display} · ticket {t['total']} · Δ{diff:.2f}"
    )

    parts = [
        "-- =============================================================================",
        "-- PEGAR TODO ESTE ARCHIVO en Supabase → SQL Editor → Run",
        "-- Farmater Ventas / Cityfarma · FCV-20261113 · 13-nov-2026 → cola Recibir.",
        "-- Merge a GitHub NO lo crea. Sin bloques dollar-quote. Sin producto_imagenes.",
        "-- Caducidad null: MMAA de la caja. No inventar 0000.",
        "-- Al final: VERIFICACION con folio FCV-20261113 en borrador.",
        "-- Luego: tablet Recibir → recargar → aparece la tarjeta Cityfarma.",
        "-- =============================================================================",
        "",
        render_ticket(t),
        """
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
where r.folio = 'FCV-20261113'
  and coalesce(r.proveedor, '') ilike '%cityfarma%'
group by r.id, r.folio, r.proveedor, r.estado, r.total_ticket
order by r.folio;
""",
    ]
    OUT_SQL.write_text("\n".join(parts), encoding="utf-8")

    n_alta = sum(1 for r in t["rows"] if not r["ya"])
    lines = "\n".join(
        f"| {r['ean']} | {r['snap'][:42]} | `{r['sku']}` | {r['nombre']} | {r['qty']} | ${r['pu']:.2f} |"
        for r in t["rows"]
    )
    OUT_MD.write_text(
        f"""# Farmater FCV-20261113 → Recibir

El merge a GitHub **no** crea la cola. Hay que **Run** el SQL en Supabase.

| Proveedor | Folio | Total | Renglones | Altas nuevas |
|---|---|---|---|---|
| Cityfarma Iztapalapa | **FCV-20261113** | ${t['total']:,.2f} | {len(t['rows'])} | {n_alta} |

## Pasos

1. Supabase → SQL Editor → New query
2. Raw: https://raw.githubusercontent.com/ibarraivane/farmacapital/main/sql/patch_recibir_farmater_fcv_20261113_SOLO_pegar_esto.sql
3. Selecciona TODO → copiar → pegar → **Run**
4. Abajo: VERIFICACION con folio `FCV-20261113` en `borrador` (15 renglones)
5. Tablet: Recibir → recargar

## Renglones

| EAN | Snapshot carrito | SKU | Mostrador | Qty | P.U. |
|---|---|---|---|---|---|
{lines}

## Notas

- Folio interno `FCV-20261113` porque el carrito aún no tenía No. de pedido en las fotos.
- Normex viene como CADP 11-2027 en vitrina: **caducidad null** hasta MMAA de caja.
- Fotos pendientes (alta sin packshot en `catalogo-propia/`): Olopatadina, Inha-Rub, Quitadol 750, Erbitrax 15 g, Oxolbrul, Adopren 400.
""",
        encoding="utf-8",
    )
    print(f"Wrote {OUT_SQL.relative_to(ROOT)} ({OUT_SQL.stat().st_size} bytes)")
    print(f"Wrote {OUT_MD.relative_to(ROOT)}")


if __name__ == "__main__":
    main()
