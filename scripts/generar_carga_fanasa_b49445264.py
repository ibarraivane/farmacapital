#!/usr/bin/env python3
"""Pedido Fanasa factura B49445264 (02-nov-2026, 2 renglones) → catálogo + cola Recibir.

Fotos factura (códigos EAN + precios farmacia). CANT=1 por renglón (BUL es bulto, no
cantidad facturada). Costo = PRECIO FARMACIA = IMPORTE NETO. PVP = recargo marca +25%.
Ficha Carnot — no el código del ticket. Stock al escanear + MMAA.
"""
from __future__ import annotations

import math
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from generar_recepcion_borrador import report, write_ticket_csv

ROOT = Path(__file__).resolve().parents[1]
OUT_TICKET = ROOT / "sql" / "generated" / "ticket_fanasa_b49445264.csv"
OUT_SQL = ROOT / "sql" / "patch_carga_fanasa_b49445264.sql"
OUT_LEERME = ROOT / "sql" / "LEERME_fanasa_b49445264.md"

FOLIO = "B49445264"
PROVEEDOR = "Fanasa"
FECHA = "2026-11-02"
TOTAL_TICKET = 667.19


def precio(costo: float, tipo: str) -> int:
    return math.ceil(costo * (1.25 if tipo == "marca" else 1.60))


def sku_de(ean: str) -> str:
    return "FC-" + ean[-8:]


def sql_str(s: str | None) -> str:
    if s is None:
        return "null"
    return "'" + str(s).replace("'", "''") + "'"


# snap, qty, pu, ean, match, pos, tipo, cat, subcat, marca, presentacion, forma, lab, pa, conc, receta, alta
RAW = [
    (
        "FLUXEDAN BROMHEXINA OXELADINA 24 COM",
        1,
        313.41,
        "7501070903237",
        "fanasa",
        "Fluxedan 6/12 mg",
        "marca",
        "Medicamentos",
        "Respiratorio",
        "Fluxedan",
        "Caja con 24 comprimidos",
        "Comprimido",
        "Carnot",
        "Bromhexina / oxeladina",
        "6 mg / 12 mg",
        True,
        True,
    ),
    (
        "FLUXEDAN CLORHIDRATO DE BROMHEXINA 6/12 mg/10 ml 1 JBE 225 ml",
        1,
        353.78,
        "7501070900441",
        "fanasa",
        "Fluxedan jarabe",
        "marca",
        "Medicamentos",
        "Respiratorio",
        "Fluxedan",
        "Frasco 225 ml con medida",
        "Jarabe",
        "Carnot",
        "Bromhexina / oxeladina",
        "6 mg / 12 mg por 10 ml",
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

    body = f"""-- Pedido Fanasa folio {FOLIO} ({FECHA}) — altas + cola Recibir.
-- Factura · pedido 57020464 · total ${TOTAL_TICKET:.2f}.
-- CANT=1 por renglón (columna BUL ≠ cantidad). Costo = PRECIO FARMACIA.
-- PVP = recargo marca ×1.25. Ficha Carnot (PCI en ticket = Productos Científicos).
-- SIN bloques dollar-quote (do $$). El SQL Editor de Supabase los corta.
-- Ticket borrador. Stock al escanear + MMAA de la caja. No inventar 0000.
-- Idempotente mientras el ticket siga en borrador.
-- Pegar TODO este archivo en Supabase → SQL Editor → Run.
-- Fotos: tras deploy, pegar sql/patch_fotos_fanasa_b49445264.sql

begin;

create temp table _fc_fnb49445264 (
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

insert into _fc_fnb49445264
  (linea, ean, sku, nombre, snap, qty, costo, precio, tipo, categoria, subcategoria,
   marca, presentacion, forma, laboratorio, principio_activo, concentracion, receta, alta_nueva)
values
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
    ) then 'FC-ND-' || right(t.ean, 8)
    else t.sku
  end,
  t.ean,
  t.categoria,
  t.tipo,
  'Alta Fanasa {FOLIO} · {FECHA} · listo para pistola',
  t.costo,
  t.precio,
  0,
  1,
  true,
  t.receta
from _fc_fnb49445264 t
where t.alta_nueva
  and public.fc_buscar_producto_escaneo(t.ean) is null;

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
from _fc_fnb49445264 t
where p.id = public.fc_buscar_producto_escaneo(t.ean);

update public.productos p
set
  costo = t.costo,
  precio = case
    when coalesce(p.precio, 0) <= 1 then t.precio
    else p.precio
  end
from _fc_fnb49445264 t
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
  {sql_str(f"Pedido Fanasa {FOLIO} · pedido 57020464 · 02-11-26 · $667.19 · Fluxedan Comp + Jarabe · cola Recibir; stock al confirmar pistola")}
where not exists (
  select 1 from public.recepciones
  where folio = {sql_str(FOLIO)} and coalesce(proveedor, '') ilike '%fanasa%'
);

update public.recepciones
set
  total_ticket = {TOTAL_TICKET:.2f},
  fecha = {sql_str(FECHA)},
  proveedor = {sql_str(PROVEEDOR)},
  notas = {sql_str(f"Pedido Fanasa {FOLIO} · pedido 57020464 · 02-11-26 · $667.19 · Fluxedan Comp + Jarabe · cola Recibir; stock al confirmar pistola")},
  updated_at = now()
where folio = {sql_str(FOLIO)}
  and coalesce(proveedor, '') ilike '%fanasa%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = {sql_str(FOLIO)}
  and coalesce(r.proveedor, '') ilike '%fanasa%'
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
from _fc_fnb49445264 t
join public.recepciones r
  on r.folio = {sql_str(FOLIO)}
 and coalesce(r.proveedor, '') ilike '%fanasa%'
 and r.estado = 'borrador'
left join lateral (
  select coalesce(
    public.fc_buscar_producto_escaneo(t.ean),
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
  case when i.pendiente_alta then 'ALTA NUEVA' else 'YA EXISTE' end as estado,
  p.sku,
  left(p.nombre, 48) as nombre_catalogo
from public.recepcion_items i
join public.recepciones r on r.id = i.recepcion_id
left join public.productos p on p.id = i.producto_id
where r.folio = {sql_str(FOLIO)} and coalesce(r.proveedor, '') ilike '%fanasa%'
order by i.id;
"""
    path.write_text(body, encoding="utf-8")


def write_leerme(path: Path, items: list) -> None:
    lines = [
        f"# Fanasa folio {FOLIO} · 02-nov-2026 · ${TOTAL_TICKET:,.2f}",
        "",
        "Factura Fanasa (lado EAN + lado precios). Pedido **57020464**. Entrega FarmaCapital La Capi.",
        "",
        "## Veredicto",
        "",
        "**Ticket nuevo.** 2 renglones, ambos alta Fluxedan (Carnot).",
        "",
        "| EAN | Ticket | SKU | Nombre mostrador | Qty | Costo |",
        "|---|---|---|---|---|---|",
    ]
    for r in items:
        lines.append(
            f"| `{r['ean']}` | {r['snap']} | `{r['sku']}` | {r['nombre']} | {r['qty']} | ${r['costo']:.2f} |"
        )
    lines += [
        "",
        "### Cantidades",
        "",
        "Columna **CANT = 1** en ambos. La columna **BUL** (2 / 1) es bulto/logística,",
        "no piezas facturadas: el importe neto = precio farmacia × 1.",
        "",
        "## Qué pegar en Supabase",
        "",
        f"1. `sql/patch_carga_fanasa_b49445264.sql` — altas + cola Recibir borrador.",
        f"2. Tras deploy Vercel: `sql/patch_fotos_fanasa_b49445264.sql`.",
        "",
        f"CSV: `sql/generated/ticket_fanasa_b49445264.csv`.",
        "",
        "Stock **0** hasta pistola + MMAA de la caja.",
        "",
        f"Regenerar: `python3 scripts/generar_carga_fanasa_b49445264.py`",
        "",
    ]
    path.write_text("\n".join(lines), encoding="utf-8")


if __name__ == "__main__":
    r = rows()
    a = altas()
    assert len(RAW) == 2
    suma = sum(x["sub"] for x in r)
    assert abs(suma - TOTAL_TICKET) < 0.02, (suma, TOTAL_TICKET)

    write_ticket_csv(OUT_TICKET, folio=FOLIO, fecha=FECHA, proveedor=PROVEEDOR, total=TOTAL_TICKET, rows=r)
    write_unified_sql(OUT_SQL, a)
    write_leerme(OUT_LEERME, a)
    print(f"csv    {OUT_TICKET}")
    print(f"sql    {OUT_SQL}")
    print(f"leerme {OUT_LEERME}")
    print(report(r, TOTAL_TICKET))
    for x in a:
        print(f"  {x['sku']}  {x['ean']}  ×{x['qty']}  ${x['costo']:.2f} → ${x['precio']}  {x['nombre']}")
