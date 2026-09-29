#!/usr/bin/env python3
"""Pedido Nadro folio 6090551411 (28-sep-2026, CFDI) → catálogo + cola Recibir.

Factura UUID 63A7365A-98A6-4068-83F3-1897395A2AE8 · NADRO MEXICO SUR.
Ficha iNadro / retailers (no código del PDF). EANs pistola = iNadro (factura
imprimió check digit inválido en chupón y Hypafix).
Sin lote ni MMAA en la cola: salen de la caja al escanear.
"""
from __future__ import annotations

import math
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from generar_recepcion_borrador import report, write_ticket_csv

ROOT = Path(__file__).resolve().parents[1]
OUT_TICKET = ROOT / "sql" / "generated" / "ticket_nadro_6090551411.csv"
OUT_SQL = ROOT / "sql" / "patch_carga_nadro_6090551411.sql"

FOLIO = "6090551411"
PROVEEDOR = "Nadro"
FECHA = "2026-09-28"
# Factura TOTAL con IVA. Suma renglones (sin IVA) = 379.47.
TOTAL_TICKET = 440.18
SUBTOTAL_RENGLONES = 379.47


def precio(costo: float, tipo: str) -> int:
    """Recargo sobre costo (alta Recibir): marca +25%, genérico +60%."""
    markup = 0.25 if tipo == "marca" else 0.60
    return math.ceil(costo * (1 + markup))


def sku_de(ean: str) -> str:
    return "FC-" + ean[-8:]


def sql_str(s: str | None) -> str:
    if s is None:
        return "null"
    return "'" + str(s).replace("'", "''") + "'"


# snap ticket, qty, subtotal, ean pistola, match,
# nombre POS, tipo, cat, subcat, marca, presentacion, forma, lab, pa, receta, alta_nueva
RAW = [
    (
        "CHUPON TERNURA FLOR/BALON MIEL S",
        18,
        55.80,
        "7501026462245",  # factura 7501025462245 (DV inválido); caja/iNadro 6462245
        "catalogo",
        "Chupón Ternura flor y balón con miel",
        "marca",
        "Bebés",
        "Chupones",
        "Ternura",
        "1 pieza",
        "Chupón",
        "M.A. Carter",
        None,
        False,
        False,
    ),
    (
        "LEUKOPLAST HYPAFIX 10 CM X 2M",
        1,
        71.63,
        "4042809591446",  # factura 4042809591448 (DV inválido); iNadro/GS1 1446
        "alta_nueva",
        "Leukoplast Hypafix",
        "marca",
        "Botiquín",
        "Material de curación",
        "Leukoplast",
        "10 cm × 2 m",
        "Lámina adhesiva",
        "Essity",
        None,
        False,
        True,
    ),
    (
        "MJE ASEPXIA PVO COM TONO CANELA 10G",
        1,
        126.02,
        "650240032431",
        "alta_nueva",
        "Asepxia polvo compacto Canela",
        "marca",
        "Cuidado personal",
        "Maquillaje",
        "Asepxia",
        "10 g",
        "Polvo compacto",
        "Genomma Lab",
        None,
        False,
        True,
    ),
    (
        "MJE ASEPXIABBPVOCOMPNATMA 10G",
        1,
        126.02,
        "650240032455",
        "alta_nueva",
        "Asepxia BB polvo compacto Natural Mate",
        "marca",
        "Cuidado personal",
        "Maquillaje",
        "Asepxia",
        "10 g",
        "Polvo compacto",
        "Genomma Lab",
        None,
        False,
        True,
    ),
]


def rows():
    out = []
    for nombre, qty, sub, ean, match, *_rest in RAW:
        out.append(
            {
                "nombre": nombre,
                "qty": qty,
                "sub": sub,
                "pu": round(sub / qty, 2),
                "ean": ean,
                "sku": sku_de(ean) if match != "catalogo" or ean != "7501026462245" else "FC-26462078",
                "match": match,
            }
        )
    # Chupón ya existe como FC-26462078
    out[0]["sku"] = "FC-26462078"
    return out


def altas():
    out = []
    for (
        snap,
        qty,
        sub,
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
        receta,
        alta,
    ) in RAW:
        pu = round(sub / qty, 2)
        sku = "FC-26462078" if ean == "7501026462245" else sku_de(ean)
        out.append(
            {
                "ean": ean,
                "sku": sku,
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
                "receta": receta,
                "alta_nueva": alta,
                "qty": qty,
                "match": match,
            }
        )
    return out


def write_unified_sql(path: Path, items: list) -> None:
    vals = []
    for i, r in enumerate(items):
        vals.append(
            "  ({linea}, {ean}, {sku}, {pos}, {snap}, {qty}, {costo}, {precio}, {tipo}, "
            "{cat}, {subcat}, {marca}, {pres}, {forma}, {lab}, {pa}, {receta}, {alta})".format(
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
                receta="true" if r["receta"] else "false",
                alta="true" if r["alta_nueva"] else "false",
            )
        )

    body = f"""-- Pedido Nadro folio {FOLIO} ({FECHA}) — altas + cola Recibir.
-- Factura CFDI UUID 63A7365A-98A6-4068-83F3-1897395A2AE8 · total ${TOTAL_TICKET:.2f}
-- Subtotal renglones ${SUBTOTAL_RENGLONES:.2f} + IVA $60.71.
-- SIN bloques dollar-quote (do $$). El SQL Editor de Supabase los corta.
-- 3 altas stock 0 + 1 ya en catálogo (chupón FC-26462078).
-- Ficha iNadro / retailers (no código del ticket).
-- EANs pistola: chupón 7501026462245 (factura imprimió 5462245); Hypafix 4042809591446 (factura 1448).
-- Ticket borrador. Stock al escanear + MMAA de la caja. No inventar 0000.
-- Idempotente mientras el ticket siga en borrador.
-- Pegar TODO este archivo en Supabase → SQL Editor → Run.
-- Fotos: tras deploy, pegar sql/patch_fotos_nadro_6090551411.sql

begin;

create temp table _fc_nd6090551411 (
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
  receta boolean not null,
  alta_nueva boolean not null
) on commit drop;

insert into _fc_nd6090551411
  (linea, ean, sku, nombre, snap, qty, costo, precio, tipo, categoria, subcategoria,
   marca, presentacion, forma, laboratorio, principio_activo, receta, alta_nueva)
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
from _fc_nd6090551411 t
where t.alta_nueva
  and public.fc_buscar_producto_escaneo(t.ean) is null;

-- Ficha de mostrador (marca real, no casa Nadro CARTER/ESSITY/GENOMMALAB como marca).
update public.productos p set
  marca = t.marca,
  presentacion = t.presentacion,
  forma_farmaceutica = t.forma,
  principio_activo = t.principio_activo,
  subcategoria = t.subcategoria,
  laboratorio = coalesce(nullif(btrim(p.laboratorio), ''), t.laboratorio),
  nombre = t.nombre,
  categoria = t.categoria,
  tipo = t.tipo,
  requiere_receta = t.receta
from _fc_nd6090551411 t
where p.id = public.fc_buscar_producto_escaneo(t.ean);

-- Costos del ticket (PVP solo si estaba en 0).
update public.productos p
set
  costo = t.costo,
  precio = case
    when coalesce(p.precio, 0) <= 0 then t.precio
    else p.precio
  end
from _fc_nd6090551411 t
where p.id = public.fc_buscar_producto_escaneo(t.ean)
  and (
    p.costo is distinct from t.costo
    or coalesce(p.precio, 0) <= 0
  );

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  {sql_str(PROVEEDOR)},
  {sql_str(FOLIO)},
  {sql_str(FECHA)},
  {TOTAL_TICKET:.2f},
  'borrador',
  {sql_str(f"Pedido Nadro {FOLIO} · CFDI 28-09-26 · EAN iNadro · cola Recibir; stock al confirmar pistola · chupón/Hypafix DV corregido")}
where not exists (
  select 1 from public.recepciones
  where folio = {sql_str(FOLIO)} and coalesce(proveedor, '') ilike '%nadro%'
);

update public.recepciones
set
  total_ticket = {TOTAL_TICKET:.2f},
  fecha = {sql_str(FECHA)},
  proveedor = {sql_str(PROVEEDOR)},
  notas = {sql_str(f"Pedido Nadro {FOLIO} · CFDI 28-09-26 · EAN iNadro · cola Recibir; stock al confirmar pistola · chupón/Hypafix DV corregido")},
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
from _fc_nd6090551411 t
join public.recepciones r
  on r.folio = {sql_str(FOLIO)}
 and coalesce(r.proveedor, '') ilike '%nadro%'
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
where r.folio = {sql_str(FOLIO)} and coalesce(r.proveedor, '') ilike '%nadro%'
order by i.id;
"""
    path.write_text(body, encoding="utf-8")


if __name__ == "__main__":
    r = rows()
    a = altas()
    skus = [x["sku"] for x in a]
    assert len(skus) == len(set(skus)), skus
    assert len(RAW) == 4, len(RAW)
    suma = sum(x["sub"] for x in r)
    assert abs(suma - SUBTOTAL_RENGLONES) < 0.02, (suma, SUBTOTAL_RENGLONES)
    assert a[0]["ean"] == "7501026462245"
    assert a[1]["ean"] == "4042809591446"
    assert a[0]["precio"] == 4  # 3.10 × 1.25
    assert a[1]["precio"] == 90  # 71.63 × 1.25
    assert a[2]["precio"] == 158  # 126.02 × 1.25
    assert a[3]["precio"] == 158

    write_ticket_csv(OUT_TICKET, folio=FOLIO, fecha=FECHA, proveedor=PROVEEDOR, total=TOTAL_TICKET, rows=r)
    write_unified_sql(OUT_SQL, a)
    print(f"csv   {OUT_TICKET}")
    print(f"sql   {OUT_SQL}")
    print(report(r, TOTAL_TICKET))
    print("altas", sum(1 for x in a if x["alta_nueva"]))
    for x in a:
        print(f"  {x['sku']}  {x['ean']}  ${x['costo']:.2f} → ${x['precio']}  {x['nombre']}")
