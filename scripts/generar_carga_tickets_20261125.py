#!/usr/bin/env python3
"""Tickets Recibir 25-nov-2026 · cliente Luis Angel Palillero Ventura.

- Cityfarma Iztapalapa S344146 · 25-nov 09:43 · 9 renglones · 25 pzas.
- Equilibrio 452985 · 25-nov 11:34 · pedido online · 1 renglón · 4 pzas · $67.33 (pagado de caja).

Costo = P.U. impreso (Equilibrio: neto antes de IVA). Precio nuevo = costo x 1.25 (marca)
o x 1.60 (genérico). Lote solo si viene en el papel. Caducidad null (MMAA de la caja).
Fichas de mostrador desde la ficha del proveedor/retailer, no el código del ticket.
SIN bloques dollar-quote. SIN producto_imagenes en el mismo txn.
"""
from __future__ import annotations

from decimal import ROUND_CEILING, Decimal
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
FOTO_BASE = "https://www.farmacapital.mx/catalogo-propia"
FECHA = "2026-11-25"


def ceil_pvp(costo: float, tipo: str) -> int:
    factor = Decimal("1.25") if tipo == "marca" else Decimal("1.60")
    return int((Decimal(str(costo)) * factor).to_integral_value(rounding=ROUND_CEILING))


def sku_de(ean: str) -> str:
    return "FC-" + ean[-8:]


def sql_str(v) -> str:
    if v is None:
        return "null"
    if isinstance(v, bool):
        return "true" if v else "false"
    if isinstance(v, (int, float)):
        return str(v)
    return "'" + str(v).replace("'", "''") + "'"


def foto_url(name: str | None) -> str | None:
    if not name:
        return None
    if not (ROOT / "public" / "catalogo-propia" / name).exists():
        return None
    return f"{FOTO_BASE}/{name}"


def R(
    ean: str,
    snap: str,
    qty: int,
    pu: float,
    *,
    nombre: str,
    marca: str | None,
    laboratorio: str | None,
    presentacion: str | None,
    forma: str | None,
    categoria: str = "Medicamentos",
    subcategoria: str | None = None,
    principio: str | None = None,
    concentracion: str | None = None,
    tipo: str = "marca",
    receta: bool = False,
    ya: bool = False,
    sku: str | None = None,
    lote: str | None = None,
    foto: str | None = None,
) -> dict:
    costo = round(pu, 2)
    return {
        "ean": ean,
        "sku": sku or sku_de(ean),
        "nombre": nombre,
        "snap": snap[:60],
        "qty": qty,
        "pu": costo,
        "sub": round(qty * costo, 2),
        "precio": ceil_pvp(costo, tipo),
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
        "imagen": foto_url(foto),
    }


CITYFARMA_ROWS = [
    R(
        "7501537103545",
        "ADINOL PARACETAMOL I",
        2,
        20.90,
        nombre="Adinol Paracetamol Infantil 3.2 g/100 ml",
        marca="Adinol",
        laboratorio="Bruluart",
        presentacion="Frasco 120 ml con cuchara dosificadora",
        forma="Solución oral",
        subcategoria="Analgésicos y antipiréticos",
        principio="Paracetamol",
        concentracion="3.2 g/100 ml",
        receta=True,
        foto="adinol-paracetamol-infantil-uva-7501537103545.jpg",
    ),
    R(
        "780083148645",
        "COBEDINA NS C10 TABS",
        2,
        10.40,
        nombre="Cobedina NS",
        marca="Cobedina",
        laboratorio="Collins",
        presentacion="Caja con 10 tabletas",
        forma="Tabletas",
        subcategoria="Antialérgicos y corticoides",
        principio="Loratadina / Betametasona",
        concentracion="5 mg / 0.25 mg",
        receta=True,
        foto="cobedina-ns-loratadina-betametasona-780083148645.jpg",
    ),
    R(
        "7501125104268",
        "ELECTROLIT 625ML FRE",
        2,
        20.14,
        nombre="Electrolit Fresa 625 ml",
        marca="Electrolit",
        laboratorio="Lab Pisa",
        presentacion="Botella 625 ml",
        forma="Suero oral",
        categoria="Hidratación",
        subcategoria="Electrolitos",
        ya=True,
        sku="FC-25104268",
    ),
    R(
        "7501033956140",
        "GLUCERNA 237ML FRESA",
        5,
        50.56,
        nombre="Glucerna fresa 237 ml",
        marca="Glucerna",
        laboratorio="Abbott",
        presentacion="Frasco 237 ml",
        forma="Líquido",
        categoria="Suplemento",
        subcategoria="Suplemento nutricional",
        ya=True,
        sku="FC-33956140",
    ),
    R(
        "75049805",
        "NEOMICINA POLIMIXINA",
        2,
        37.81,
        nombre="Neomicina polimixina gramicidina 15 ml",
        marca="Exakta",
        laboratorio="Exakta",
        presentacion="Frasco 15 ml gotas oftálmicas",
        forma="Gotas oftálmicas",
        principio="Neomicina / Polimixina B / Gramicidina",
        receta=True,
        tipo="generico",
        ya=True,
        sku="EQ-EXA035",
    ),
    R(
        "7503028771691",
        "ROSUVASTATINA 20MG C",
        4,
        35.74,
        nombre="Rosuvastatina 20 mg",
        marca="Suanca",
        laboratorio="Suanca",
        presentacion="Caja con 10 tabletas",
        forma="Tabletas",
        subcategoria="Cardiovascular",
        principio="Rosuvastatina",
        concentracion="20 mg",
        receta=True,
        tipo="generico",
    ),
    R(
        "7501537163266",
        "TRIBEDOCE COMP C3 AM",
        5,
        50.11,
        nombre="Tribedoce Compuesto",
        marca="Tribedoce",
        laboratorio="Bruluart",
        presentacion="Caja con 3 ampolletas",
        forma="Ampolleta",
        principio="Diclofenaco / complejo B (tiamina, piridoxina, cianocobalamina)",
        receta=True,
        ya=True,
        sku="FC-37163266",
    ),
    R(
        "7500435122726",
        "VAPORUB EXH C 12 LAT",
        1,
        260.00,
        nombre="Vicks VapoRub 12 g",
        marca="Vicks",
        laboratorio="Procter & Gamble",
        presentacion="Exhibidor con 12 latas de 12 g",
        forma="Ungüento",
        categoria="Botiquín",
        principio="Alcanfor / mentol / aceite de eucalipto",
        foto="vicks-vaporub-12g.jpg",
    ),
    R(
        "7501871720590",
        "VARTALON COMP C30 SO",
        2,
        1010.64,
        nombre="Vartalon Compositum",
        marca="Vartalon",
        laboratorio="Asofarma",
        presentacion="Caja con 30 sobres",
        forma="Polvo",
        ya=True,
        sku="FC-71720590",
    ),
]

EQUILIBRIO_ROWS = [
    R(
        "7506022331038",
        "JAY253 CANULA NASAL P/OXIGENO PED 1 PUNTAS",
        4,
        14.51,
        nombre="Cánula nasal para oxígeno pediátrica",
        marca=None,
        laboratorio=None,
        presentacion="Pieza, puntas nasales pediátrica",
        forma="Dispositivo",
        categoria="Dispositivos",
        subcategoria="Oxígeno",
        lote="2510950005",
        ya=True,
        sku="EQ-JAY253",
    ),
]

TICKETS = [
    {
        "key": "cityfarma_S344146",
        "folio": "S344146",
        "proveedor": "Cityfarma Iztapalapa",
        "proveedor_ilike": "%cityfarma%",
        "tmp": "_fc_cf_s344146",
        "total": 3106.11,
        "subtotal": 3106.11,
        "total_papel": "Subtotal impreso $3,091.24 · Total impreso $0.00 (sin pago)",
        "titulo": "Farma City / Cityfarma Iztapalapa S344146 · 25-nov-2026 09:43",
        "notas": (
            "Cityfarma Iztapalapa · pedido S344146 · 25-nov-2026 09:43 · "
            "cliente Luis Angel Palillero Ventura · vendedor Eduardo Nicanor · "
            "9 renglones · 25 pzas · suma renglones $3,106.11 (subtotal papel $3,091.24) · "
            "sin lote impreso · caducidad NO · cola Recibir"
        ),
        "rows": CITYFARMA_ROWS,
        "md": "LEERME_cityfarma_S344146_SOLO_pegar_esto.md",
        "sql": "patch_recibir_cityfarma_S344146_SOLO_pegar_esto.sql",
        "revisar": [
            "Subtotal impreso $3,091.24 no cuadra con la suma de renglones $3,106.11 (dif. $14.87). Revisar el papel original.",
            "Cobedina NS: costo impreso $10.40 por caja. Las farmacias en línea la venden entre $45 y $91, así que el precio por fórmula ($13) está muy bajo. Confirmar el costo antes de publicar.",
            "Adinol infantil: precio por fórmula $27. BuscaMed lo lista en $24. Revisar margen antes de publicar.",
            "Vicks VapoRub: el renglón es un exhibidor de 12 latas (1 pieza a $260). Si en mostrador se vende por lata, el stock se tiene que ajustar a 12 por exhibidor.",
            "Vicks VapoRub: ya existe FC-01246730 (Vicks pomada 12 g C/12 latas) con EAN 7501001246730. Este ticket usa el EAN del papel 7500435122726. Confirmar que no sea el mismo producto.",
            "Rosuvastatina 20 mg Suanca: alta sin foto. No encontré un packshot limpio (la única imagen tenía marca de agua de otra farmacia). Pendiente foto antes de cerrar el alta.",
            "Sin lote impreso en el papel: capturar lote y MMAA de cada caja al escanear.",
        ],
    },
    {
        "key": "equilibrio_452985",
        "folio": "452985",
        "proveedor": "Equilibrio",
        "proveedor_ilike": "%equilibrio%",
        "tmp": "_fc_eq_452985",
        "total": 67.33,
        "subtotal": 58.04,
        "total_papel": "Subtotal $58.04 + IVA $9.29 = Total $67.33 (pagado de caja, Miriam)",
        "titulo": "Equilibrio 452985 · pedido online Iztapalapa 2 · 25-nov-2026 11:34",
        "notas": (
            "Equilibrio · ticket 452985 · 25-nov-2026 11:34 · cliente 307513 Luis Angel · "
            "1 renglón · 4 pzas · $67.33 con IVA · pagado de caja · "
            "lote impreso 2510950005 · caducidad NO · cola Recibir"
        ),
        "rows": EQUILIBRIO_ROWS,
        "md": "LEERME_equilibrio_452985_SOLO_pegar_esto.md",
        "sql": "patch_recibir_equilibrio_452985_SOLO_pegar_esto.sql",
        "revisar": [
            "Caducidad impresa en el papel: 23/10/2030. El ticket de Recibir se carga con caducidad null (MMAA de la caja), como en los demás tickets de Equilibrio. Confirmar con la caja.",
            "Lote impreso 2510950005: se carga en el renglón. Confirmar contra la caja al escanear.",
            "Pagado de caja por Miriam ($67, según nota manuscrita en el papel).",
        ],
    },
]


def render_sql(t: dict) -> str:
    rows = t["rows"]
    tmp = t["tmp"]
    folio = sql_str(t["folio"])
    proveedor = sql_str(t["proveedor"])
    ilike = sql_str(t["proveedor_ilike"])
    notas = sql_str(t["notas"])
    total = f"{t['total']:.2f}"
    n_alta = sum(1 for r in rows if not r["ya"])
    n_ya = sum(1 for r in rows if r["ya"])
    piezas = sum(r["qty"] for r in rows)

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
                img=sql_str(r["imagen"]),
                lote=sql_str(r["lote"]),
            )
        )
    values_sql = ",\n".join(vals)

    return f"""-- =============================================================================
-- PEGAR TODO ESTE ARCHIVO en Supabase → SQL Editor → Run
-- {t['titulo']}
-- {t['total_papel']}
-- {len(rows)} renglones · {piezas} pzas · total ${t['total']:,.2f}
-- Merge a GitHub NO crea la cola. Sin dollar-quote. Sin producto_imagenes.
-- Lote solo si viene impreso. Caducidad null: MMAA de la caja. No inventar 0000.
-- =============================================================================

rollback;

-- ========== {t['proveedor']} {t['folio']} ==========
-- {n_alta} alta(s) stock 0. {n_ya} ya estaban en catálogo: solo costo (precio solo si estaba en 0).
-- Nombres de ficha, no del ticket. Idempotente mientras el ticket siga en borrador.

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
{values_sql};

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
  'Alta {t['proveedor']} {t['folio']} · {FECHA} · listo para pistola',
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
  {proveedor},
  {folio},
  {sql_str(FECHA)},
  {total},
  'borrador',
  {notas}
where not exists (
  select 1 from public.recepciones
  where folio = {folio}
    and coalesce(proveedor, '') ilike {ilike}
);

update public.recepciones
set
  total_ticket = {total},
  fecha = {sql_str(FECHA)},
  proveedor = {proveedor},
  notas = {notas},
  updated_at = now()
where folio = {folio}
  and coalesce(proveedor, '') ilike {ilike}
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = {folio}
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
  on r.folio = {folio}
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
where r.folio = {folio}
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


def leerme(t: dict) -> str:
    rows = t["rows"]
    altas = [r for r in rows if not r["ya"]]
    ya = [r for r in rows if r["ya"]]
    piezas = sum(r["qty"] for r in rows)
    altas_txt = "\n".join(
        f"- **{r['sku']}** · {r['ean']} · {r['nombre']} · precio ${r['precio']} "
        f"(costo {r['pu']:.2f}) · foto: {'sí' if r['imagen'] else '**pendiente**'}"
        for r in altas
    )
    ya_txt = "\n".join(f"- {r['sku']} · {r['ean']} · {r['nombre']}" for r in ya)
    return f"""# {t['proveedor']} {t['folio']} — pegar en Supabase

{t['titulo']}

- {len(rows)} renglón(es) · **{piezas} pzas** · total guardado en Recibir **${t['total']:,.2f}**
- Papel: {t['total_papel']}

## Pegar ahora

1. Pegar **todo** `sql/{t['sql']}` en Supabase → SQL Editor → **Run**.
2. Verificación al final: folio `{t['folio']}`, estado `borrador`, {len(rows)} renglón(es), {piezas} piezas.
3. Tablet: Recibir → recargar → tarjeta **{t['proveedor']} · {t['folio']}**.
4. Escanear cada caja. MMAA de la caja (no inventar `0000`). Lote: el del papel si viene, si no, el de la caja.

## Altas nuevas (stock 0)

{altas_txt or '- Ninguna. Todo ya estaba en catálogo.'}

## Ya en catálogo (solo costo nuevo)

{ya_txt}

## Revisar antes de publicar

{chr(10).join('- ' + x for x in t['revisar'])}
"""


def main() -> None:
    for t in TICKETS:
        rows = t["rows"]
        suma = round(sum(r["sub"] for r in rows), 2)
        piezas = sum(r["qty"] for r in rows)
        if abs(suma - t["subtotal"]) > 0.05:
            raise SystemExit(f"{t['folio']}: suma renglones {suma} != subtotal {t['subtotal']}")
        sql = render_sql(t)
        if "$$" in sql:
            raise SystemExit(f"{t['folio']}: el SQL contiene $$")
        out_sql = ROOT / "sql" / t["sql"]
        out_md = ROOT / "sql" / t["md"]
        out_sql.write_text(sql, encoding="utf-8")
        out_md.write_text(leerme(t), encoding="utf-8")
        print(f"{t['folio']}: {len(rows)} renglones · {piezas} pzas · suma {suma} · total {t['total']}")
        print(f"  -> {out_sql.relative_to(ROOT)} ({out_sql.stat().st_size} bytes)")
        print(f"  -> {out_md.relative_to(ROOT)}")


if __name__ == "__main__":
    main()
