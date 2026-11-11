#!/usr/bin/env python3
"""Tickets 09-nov-2026 (fotos) → altas + cola Recibir.

  Bodega F-42 / Citymark · folio 383312 (CODE128 del pie; encabezado Caja 4 doblado)
  IFC F8 Tienda · folio 132888

Nombres de mostrador (no código de ticket). Caducidad null (MMAA de la caja).
Bodega: P.U. ya con IVA (suma renglones = total).
IFC: menudeo por pieza; Aceite Romero EAN 3311000001537; Mertodol EAN 759684313257.
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
        diff = abs(s - t["total"])
        if diff > 0.05:
            raise SystemExit(f"{t['folio']}: sum {s} != total {t['total']} (diff {diff})")
        print(f"{t['folio']}: {len(t['rows'])} rows · sum {s} · total {t['total']} · Δ{diff:.2f}")

    parts = [
        "-- =============================================================================",
        "-- PEGAR TODO ESTE ARCHIVO en Supabase → SQL Editor → Run",
        "-- Tickets 09-nov-2026 → cola Recibir (borrador).",
        "--   1) Bodega F-42 383312 · $611.15 · 7 renglones",
        "--   2) IFC F8 Tienda 132888 · $118.00 · 2 renglones",
        "-- Merge a GitHub NO los crea. Sin bloques dollar-quote. Sin producto_imagenes.",
        "-- Caducidad null: MMAA de la caja. No inventar 0000.",
        "-- Cada ticket es begin/commit independiente.",
        "-- Al final: VERIFICACION FINAL con los 2 folios en borrador.",
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
        f"""# Tickets 09-nov-2026 → Recibir

Pegar **todo** el SQL abajo en el chat / `sql/patch_recibir_tickets_0911_SOLO_pegar_esto.sql` en Supabase → SQL Editor → Run.

## Tickets

| Proveedor | Folio | Total | Renglones |
|---|---|---|---|
{table}

## Notas

1. **Bodega F-42 383312:** Caja 4 · P.U. ya con IVA. Folio leído del **CODE128** del pie (el encabezado `Caja 4/…` venía doblado). Si el papel muestra otro número, avisa y lo renombramos.
2. **IFC 132888:** menudeo · Aceite romero → EAN `3311000001537` (SKU `FC-38CAFE6B`) · Mertodol Jaloma → EAN `759684313257` (mismo frasco que en Bodega).
3. **Stock:** 0 hasta pistola + MMAA. No poner `0000`.
4. **Fotos:** GUM + enhebrador ya en `catalogo-propia/`; Colgate / Oral-B / Mertodol 40 ml pendientes (no bloquea Recibir).

## Después del SQL

1. Recargar Recibir en la tablet.
2. Deben aparecer **2 botones** nuevos.
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
