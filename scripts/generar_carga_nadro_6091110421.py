#!/usr/bin/env python3
"""Pedido Nadro folio 6091110421 (13-oct-2026, 6 renglones) → catálogo + cola Recibir.

Fotos factura (lado EAN + cantidades + totales). Costo = VALOR UNITARIO (PR FAR
con oferta 15% en Amcef). PVP = recargo sobre costo (marca +25% / genérico +60%).
Ficha de mostrador desde retailer/proveedor — no el código LGEN del ticket.
Sin lote ni MMAA en la cola: salen de la caja al escanear.
"""
from __future__ import annotations

import math
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from generar_recepcion_borrador import report, write_ticket_csv

ROOT = Path(__file__).resolve().parents[1]
OUT_TICKET = ROOT / "sql" / "generated" / "ticket_nadro_6091110421.csv"
OUT_SQL = ROOT / "sql" / "patch_carga_nadro_6091110421.sql"
OUT_LEERME = ROOT / "sql" / "LEERME_nadro_6091110421.md"

FOLIO = "6091110421"
PROVEEDOR = "Nadro"
FECHA = "2026-10-13"
TOTAL_TICKET = 644.52


def precio(costo: float, tipo: str) -> int:
    """Recargo sobre costo (markup), no margen sobre venta."""
    return math.ceil(costo * (1.25 if tipo == "marca" else 1.60))


def sku_de(ean: str) -> str:
    return "FC-" + ean[-8:]


def sql_str(s: str | None) -> str:
    if s is None:
        return "null"
    return "'" + str(s).replace("'", "''") + "'"


# snap ticket, qty, pu, ean, match,
# nombre POS, tipo, cat, subcat, marca, presentacion, forma, lab, pa, conc, receta, alta_nueva
RAW = [
    (
        "AMCEF CEFTRIA 1G SI FA 10ML LGEN",
        1,
        19.80,
        "7501349012011",
        "nadro",
        "Amcef IV 1 g",
        "generico",
        "Medicamentos",
        "Antibióticos",
        "Amcef",
        "Caja con frasco ámpula y diluyente 10 ml",
        "Solución inyectable",
        "AMSA",
        "Ceftriaxona",
        "1 g",
        True,
        True,  # IV 1 g/10 ml ≠ Amcef IM 1 g/3.5 ml (7501349012004)
    ),
    (
        "AMCEF IM CEFT500MG SI FA2ML LGEN",
        4,
        16.10,
        "7501349011007",
        "nadro",
        "Amcef IM 500 mg",
        "generico",
        "Medicamentos",
        "Antibióticos",
        "Amcef",
        "Caja con frasco ámpula y diluyente 2 ml",
        "Solución inyectable",
        "AMSA",
        "Ceftriaxona",
        "500 mg",
        True,
        False,  # ya existe FC-07F04F88
    ),
    (
        "C-BOOST SUP ALIM OMEGA3 FCO 90GOM",
        1,
        118.18,
        "7501022112274",
        "nadro",
        "C-Boost Omega 3 + vitaminas C, D y E",
        "marca",
        "Vitaminas",
        "Omega 3",
        "C-Boost",
        "Frasco con 90 gomitas",
        "Gomita",
        "Grisi",
        "Omega 3 / vitamina C / D / E",
        None,
        False,
        True,
    ),
    (
        "COLAG/BIOT/A HIA S ALIM FSA 14GOM",
        2,
        49.01,
        "7501853805253",
        "nadro",
        "Natural Health colágeno + biotina + ácido hialurónico",
        "marca",
        "Vitaminas",
        "Colágeno",
        "Natural Health",
        "Envase con 14 gomitas",
        "Gomita",
        "Natural Health",
        "Colágeno / biotina / ácido hialurónico",
        None,
        False,
        True,
    ),
    (
        "JUST OMEGA3 S ALIM DHA EPA 120 GOM",
        1,
        188.48,
        "7503024083439",
        "nadro",
        "Just Omega 3 DHA y EPA",
        "marca",
        "Vitaminas",
        "Omega 3",
        "Olnatura Just",
        "Frasco con 120 gomitas",
        "Gomita",
        "Olnatura",
        "Omega 3 DHA / EPA",
        None,
        False,
        True,
    ),
    (
        "METFORMINA LP 500 MG 30 TAB LGEN",
        2,
        77.82,
        "7502226293929",
        "nadro",
        "Metformina LP 500 mg",
        "generico",
        "Medicamentos",
        "Diabetes",
        "Alpharma",
        "Caja con frasco 30 tabletas",
        "Tableta de liberación prolongada",
        "Alpharma",
        "Metformina",
        "500 mg",
        True,
        True,
    ),
]


def rows():
    out = []
    for nombre, qty, pu, ean, match, *_rest in RAW:
        out.append(
            {
                "nombre": nombre,
                "qty": qty,
                "sub": round(pu * qty, 2),
                "pu": pu,
                "ean": ean,
                "sku": sku_de(ean),
                "match": match,
            }
        )
    return out


def altas():
    out = []
    for (
        snap,
        qty,
        pu,
        ean,
        match,
        pos,
        tipo,
        cat,
        subcat,
        marca,
        presentacion,
        forma,
        lab,
        pa,
        conc,
        receta,
        alta,
    ) in RAW:
        out.append(
            {
                "ean": ean,
                "sku": sku_de(ean),
                "nombre": pos,
                "snap": snap,
                "costo": pu,
                "precio": precio(pu, tipo),
                "tipo": tipo,
                "categoria": cat,
                "subcategoria": subcat,
                "marca": marca,
                "presentacion": presentacion,
                "forma": forma,
                "laboratorio": lab,
                "principio_activo": pa,
                "concentracion": conc,
                "receta": receta,
                "alta_nueva": alta,
                "qty": qty,
            }
        )
    return out


def write_unified_sql(path: Path, items: list) -> None:
    vals = []
    for i, r in enumerate(items):
        vals.append(
            "  ({linea}, {ean}, {sku}, {pos}, {snap}, {qty}, {costo}, {precio}, {tipo}, "
            "{cat}, {subcat}, {marca}, {pres}, {forma}, {lab}, {pa}, {conc}, {receta}, {alta})".format(
                linea=i + 1,
                ean=sql_str(r["ean"]),
                sku=sql_str(r["sku"]),
                pos=sql_str(r["nombre"]),
                snap=sql_str(r["snap"]),
                qty=int(r["qty"]),
                costo=f"{r['costo']:.2f}",
                precio=r["precio"],
                tipo=sql_str(r["tipo"]),
                cat=sql_str(r["categoria"]),
                subcat=sql_str(r["subcategoria"]),
                marca=sql_str(r["marca"]),
                pres=sql_str(r["presentacion"]),
                forma=sql_str(r["forma"]),
                lab=sql_str(r["laboratorio"]),
                pa=sql_str(r["principio_activo"]),
                conc=sql_str(r["concentracion"]),
                receta="true" if r["receta"] else "false",
                alta="true" if r["alta_nueva"] else "false",
            )
        )

    body = f"""-- Pedido Nadro folio {FOLIO} ({FECHA}) — altas + cola Recibir.
-- Factura · total ${TOTAL_TICKET:.2f} · costo = VALOR UNITARIO (Amcef con OFTA 15%).
-- PVP = recargo sobre costo (marca ×1.25 / genérico ×1.60). No margen sobre venta.
-- Amcef IV 1 g EAN 7501349012011 ≠ Amcef IM 1 g 7501349012004 (FC-BE76D409).
-- Amcef IM 500 mg ya existe (FC-07F04F88); solo costo + ficha.
-- SIN bloques dollar-quote (do $$). El SQL Editor de Supabase los corta.
-- Ticket borrador. Stock al escanear + MMAA de la caja. No inventar 0000.
-- Idempotente mientras el ticket siga en borrador.
-- Pegar TODO este archivo en Supabase → SQL Editor → Run.
-- Fotos: tras deploy, pegar sql/patch_fotos_nadro_6091110421.sql

begin;

create temp table _fc_nd6091110421 (
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
  marca text,
  presentacion text,
  forma text,
  laboratorio text,
  principio_activo text,
  concentracion text,
  receta boolean not null,
  alta_nueva boolean not null
) on commit drop;

insert into _fc_nd6091110421
  (linea, ean, sku, nombre, snap, qty, costo, precio, tipo, categoria, subcategoria,
   marca, presentacion, forma, laboratorio, principio_activo, concentracion, receta, alta_nueva)
values
{chr(10).join(v + ("," if i < len(vals) - 1 else ";") for i, v in enumerate(vals))}

-- Altas nuevas (solo si el EAN no existe).
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
    ) then 'FC-ND-' || right(t.ean, 8)
    else t.sku
  end,
  t.ean,
  t.categoria,
  t.tipo,
  'Alta Nadro {FOLIO} · {FECHA} · listo para pistola',
  t.costo,
  t.precio,
  0,
  1,
  true,
  t.receta
from _fc_nd6091110421 t
where t.alta_nueva
  and public.fc_buscar_producto_escaneo(t.ean) is null;

-- Ficha de mostrador (marca real, no casa Nadro LGEN).
update public.productos p set
  marca = t.marca,
  presentacion = t.presentacion,
  forma_farmaceutica = t.forma,
  principio_activo = t.principio_activo,
  concentracion = coalesce(t.concentracion, p.concentracion),
  subcategoria = t.subcategoria,
  laboratorio = coalesce(nullif(btrim(p.laboratorio), ''), t.laboratorio),
  nombre = t.nombre,
  categoria = t.categoria,
  tipo = t.tipo,
  requiere_receta = t.receta,
  codigo_barras = coalesce(nullif(btrim(p.codigo_barras), ''), t.ean)
from _fc_nd6091110421 t
where p.id = public.fc_buscar_producto_escaneo(t.ean);

-- Costos del ticket (PVP solo si estaba en 0 / ≤1).
update public.productos p
set
  costo = t.costo,
  precio = case
    when coalesce(p.precio, 0) <= 1 then t.precio
    else p.precio
  end
from _fc_nd6091110421 t
where p.id = public.fc_buscar_producto_escaneo(t.ean)
  and (
    p.costo is distinct from t.costo
    or coalesce(p.precio, 0) <= 1
  );

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  {sql_str(PROVEEDOR)},
  {sql_str(FOLIO)},
  {sql_str(FECHA)},
  {TOTAL_TICKET:.2f},
  'borrador',
  {sql_str(f"Pedido Nadro {FOLIO} · factura 13-10-26 · $644.52 · Amcef IV nuevo · cola Recibir; stock al confirmar pistola")}
where not exists (
  select 1 from public.recepciones
  where folio = {sql_str(FOLIO)} and coalesce(proveedor, '') ilike '%nadro%'
);

update public.recepciones
set
  total_ticket = {TOTAL_TICKET:.2f},
  fecha = {sql_str(FECHA)},
  proveedor = {sql_str(PROVEEDOR)},
  notas = {sql_str(f"Pedido Nadro {FOLIO} · factura 13-10-26 · $644.52 · Amcef IV nuevo · cola Recibir; stock al confirmar pistola")},
  updated_at = now()
where folio = {sql_str(FOLIO)}
  and coalesce(proveedor, '') ilike '%nadro%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = {sql_str(FOLIO)}
  and coalesce(r.proveedor, '') ilike '%nadro%'
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
  t.snap,
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
from _fc_nd6091110421 t
join public.recepciones r
  on r.folio = {sql_str(FOLIO)}
 and coalesce(r.proveedor, '') ilike '%nadro%'
 and r.estado = 'borrador'
left join lateral (
  select coalesce(
    public.fc_buscar_producto_escaneo(t.ean),
    public.fc_buscar_producto_escaneo(t.sku),
    -- Amcef IM 500 mg histórico sin EAN en algunos renglones
    case
      when t.ean = '7501349011007'
        then public.fc_buscar_producto_escaneo('FC-07F04F88')
      else null
    end
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
  case when i.pendiente_alta then 'ALTA NUEVA' else 'YA EXISTE' end as estado,
  p.sku,
  left(p.nombre, 48) as nombre_catalogo
from public.recepcion_items i
join public.recepciones r on r.id = i.recepcion_id
left join public.productos p on p.id = i.producto_id
where r.folio = {sql_str(FOLIO)} and coalesce(r.proveedor, '') ilike '%nadro%'
order by i.id;
"""
    path.write_text(body, encoding="utf-8")


def write_leerme(path: Path, items: list) -> None:
    lines = [
        f"# Nadro folio {FOLIO} · 13-oct-2026 · ${TOTAL_TICKET:,.2f}",
        "",
        "Fotos factura (códigos EAN + cantidades circuladas + totales).",
        "",
        "## Veredicto",
        "",
        "**Ticket nuevo.** 6 renglones. Amcef IM 500 mg ya estaba; el resto es alta.",
        "",
        "| EAN | Ticket | SKU | Nombre mostrador | Acción |",
        "|---|---|---|---|---|",
    ]
    for r in items:
        accion = "Solo costo + ficha" if not r["alta_nueva"] else "Alta + foto"
        lines.append(
            f"| `{r['ean']}` | {r['snap']} ×{r['qty']} | `{r['sku']}` | {r['nombre']} | {accion} |"
        )
    lines += [
        "",
        "### Amcef IV vs IM 1 g",
        "",
        f"Este ticket trae **IV 1 g / 10 ml** (`7501349012011`). El catálogo ya tenía",
        f"**IM 1 g / 3.5 ml** (`7501349012004` / `FC-BE76D409`). No se mezclan.",
        "",
        "## Qué pegar en Supabase",
        "",
        f"1. `sql/patch_carga_nadro_{FOLIO}.sql` — altas + cola Recibir borrador.",
        f"2. Tras deploy Vercel: `sql/patch_fotos_nadro_{FOLIO}.sql`.",
        "",
        f"CSV: `sql/generated/ticket_nadro_{FOLIO}.csv`.",
        "",
        "Stock **0** hasta escanear con pistola y capturar MMAA de la caja.",
        "",
        f"Regenerar: `python3 scripts/generar_carga_nadro_{FOLIO}.py`",
        "",
    ]
    path.write_text("\n".join(lines), encoding="utf-8")


if __name__ == "__main__":
    r = rows()
    a = altas()
    skus = [x["sku"] for x in a]
    assert len(skus) == len(set(skus)), skus
    assert len(RAW) == 6, len(RAW)
    suma = sum(x["sub"] for x in r)
    assert abs(suma - TOTAL_TICKET) < 0.02, (suma, TOTAL_TICKET)

    write_ticket_csv(OUT_TICKET, folio=FOLIO, fecha=FECHA, proveedor=PROVEEDOR, total=TOTAL_TICKET, rows=r)
    write_unified_sql(OUT_SQL, a)
    write_leerme(OUT_LEERME, a)
    print(f"csv    {OUT_TICKET}")
    print(f"sql    {OUT_SQL}")
    print(f"leerme {OUT_LEERME}")
    print(report(r, TOTAL_TICKET))
    print("altas", sum(1 for x in a if x["alta_nueva"]))
    for x in a:
        tag = "ALTA" if x["alta_nueva"] else "EXISTE"
        print(f"  [{tag}] {x['sku']}  {x['ean']}  ×{x['qty']}  ${x['costo']:.2f} → ${x['precio']}  {x['nombre']}")
