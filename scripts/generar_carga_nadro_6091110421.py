#!/usr/bin/env python3
"""Factura Nadro folio 6091110421 (13-oct-2026, 6 renglones) → catálogo + cola Recibir.

CFDI foto 14-oct-2026. EAN iNadro (Just Omega y Metformina: dígito verificador
corregido respecto al OCR de la foto).
Ficha de mostrador desde iNadro / retailer (no código del ticket).
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

FOLIO = "6091110421"
PROVEEDOR = "Nadro"
FECHA = "2026-10-13"
TOTAL_TICKET = 720.23


def precio(costo: float, tipo: str) -> int:
    """Recargo sobre costo (markup): marca +25%, genérico +60%."""
    m = 0.25 if tipo == "marca" else 0.60
    return math.ceil(costo * (1 + m))


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
        "AMCEF CEFTRIA 1G SI FA 10ML LGEN",
        1,
        19.80,
        "7501349012011",
        "nadro",
        "Amcef IV ceftriaxona 1 g",
        "generico",
        "Medicamentos",
        "Antibióticos",
        "Amcef",
        "Frasco ámpula + diluyente 10 ml",
        "Solución inyectable",
        "AMSA",
        "Ceftriaxona 1 g",
        True,
        True,
    ),
    (
        "AMCEF IM CEFT500MG SI FA 2ML LGEN",
        4,
        64.40,
        "7501349011007",
        "catalogo",
        "Amcef IM ceftriaxona 500 mg",
        "generico",
        "Medicamentos",
        "Antibióticos",
        "Amcef",
        "Frasco ámpula + diluyente 2 ml",
        "Solución inyectable",
        "AMSA",
        "Ceftriaxona 500 mg",
        True,
        False,
    ),
    (
        "C-BOOST SUP ALIM OMEGA3 FCO 90GOM",
        1,
        118.18,
        "7501022112274",
        "nadro",
        "C-Boost Omega 3 + vitaminas C, E y D",
        "marca",
        "Vitaminas",
        "Omega 3",
        "C-Boost",
        "Frasco 90 gomitas",
        "Gomita",
        "Grisi",
        "Omega 3 / vitaminas C, E y D",
        False,
        True,
    ),
    (
        "COLAG/BIOTA HIA S ALIM FSA 14GOM",
        2,
        98.02,
        "7501853805253",
        "nadro",
        "Glowy SKN colágeno biotina ácido hialurónico",
        "marca",
        "Vitaminas",
        "Colágeno",
        "Natural Health",
        "Bolsa 14 gomitas",
        "Gomita",
        "Natural Health",
        "Colágeno / biotina / ácido hialurónico",
        False,
        True,
    ),
    (
        "JUST OMEGA3 S ALIM DHA EPA 120 GOM",
        1,
        188.48,
        "7503024083439",
        "nadro",
        "Just Omega 3 DHA EPA",
        "marca",
        "Vitaminas",
        "Omega 3",
        "Olnatura Just",
        "Frasco 120 gomitas",
        "Gomita",
        "Olnatura",
        "Omega 3 DHA / EPA",
        False,
        True,
    ),
    (
        "METFORMINA LP 500 MG 30 TAB LGEN",
        2,
        155.64,
        "7502226293929",
        "nadro",
        "Metformina LP 500 mg",
        "generico",
        "Medicamentos",
        "Antidiabéticos",
        "Alpharma",
        "Frasco 30 tabletas",
        "Tableta de liberación prolongada",
        "Alpharma",
        "Metformina 500 mg",
        True,
        True,
    ),
]

SKU_EXISTENTE = {
    "7501349011007": "FC-07F04F88",  # Amcef IM 500 mg ya en catálogo
}


def rows():
    out = []
    for snap, qty, sub, ean, match, *_rest in RAW:
        out.append(
            {
                "nombre": snap,
                "qty": qty,
                "sub": sub,
                "pu": round(sub / qty, 2),
                "ean": ean,
                "sku": SKU_EXISTENTE.get(ean, sku_de(ean)),
                "match": match,
            }
        )
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
        out.append(
            {
                "ean": ean,
                "sku": SKU_EXISTENTE.get(ean, sku_de(ean)),
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

    body = f"""-- Factura Nadro folio {FOLIO} ({FECHA}) — altas + cola Recibir.
-- CFDI 13-oct-2026 · total ${TOTAL_TICKET:.2f} · 11 piezas · 6 renglones
-- SIN bloques dollar-quote (do $$). El SQL Editor de Supabase los corta.
-- 5 altas stock 0. Amcef IM 500 mg ya en catálogo (FC-07F04F88).
-- Ficha desde iNadro / retailer (no código del ticket). LGEN no es marca.
-- Just Omega EAN 7503024083439 (foto OCR …438 inválido). Metformina 7502226293929.
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
  receta boolean not null,
  alta_nueva boolean not null
) on commit drop;

insert into _fc_nd6091110421
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
from _fc_nd6091110421 t
where t.alta_nueva
  and public.fc_buscar_producto_escaneo(t.ean) is null;

-- Enlazar EAN a SKU ya existente (Amcef IM) si faltaba código de barras.
update public.productos p
set codigo_barras = t.ean
from _fc_nd6091110421 t
where not t.alta_nueva
  and p.sku = t.sku
  and (
    p.codigo_barras is null
    or btrim(p.codigo_barras) = ''
    or p.codigo_barras = t.ean
  )
  and public.fc_buscar_producto_escaneo(t.ean) is null;

-- Ficha de mostrador (marca real, no casa Nadro LGEN).
update public.productos p set
  marca = coalesce(nullif(btrim(t.marca), ''), p.marca),
  presentacion = t.presentacion,
  forma_farmaceutica = t.forma,
  principio_activo = t.principio_activo,
  subcategoria = t.subcategoria,
  laboratorio = coalesce(nullif(btrim(t.laboratorio), ''), nullif(btrim(p.laboratorio), ''), t.laboratorio),
  nombre = t.nombre,
  categoria = t.categoria,
  tipo = t.tipo,
  requiere_receta = t.receta
from _fc_nd6091110421 t
where p.id = coalesce(
  public.fc_buscar_producto_escaneo(t.ean),
  public.fc_buscar_producto_escaneo(t.sku)
);

-- Costos del ticket (PVP solo si estaba en 0).
update public.productos p
set
  costo = t.costo,
  precio = case
    when coalesce(p.precio, 0) <= 0 then t.precio
    else p.precio
  end
from _fc_nd6091110421 t
where p.id = coalesce(
  public.fc_buscar_producto_escaneo(t.ean),
  public.fc_buscar_producto_escaneo(t.sku)
)
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
  {sql_str(f"Factura Nadro {FOLIO} · 13-10-26 · CFDI foto · cola Recibir; stock al confirmar pistola · Just/Metformina EAN verificador")}
where not exists (
  select 1 from public.recepciones
  where folio = {sql_str(FOLIO)} and coalesce(proveedor, '') ilike '%nadro%'
);

update public.recepciones
set
  total_ticket = {TOTAL_TICKET:.2f},
  fecha = {sql_str(FECHA)},
  proveedor = {sql_str(PROVEEDOR)},
  notas = {sql_str(f"Factura Nadro {FOLIO} · 13-10-26 · CFDI foto · cola Recibir; stock al confirmar pistola · Just/Metformina EAN verificador")},
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
    assert len(RAW) == 6, len(RAW)
    suma = sum(x["sub"] for x in r)
    assert abs(suma - 644.52) < 0.02, (suma, 644.52)
    assert sum(x["qty"] for x in r) == 11
    # EAN check digits
    def ok_ean(e: str) -> bool:
        s = sum(int(e[i]) * (1 if i % 2 == 0 else 3) for i in range(12))
        return int(e[12]) == (10 - (s % 10)) % 10

    for x in a:
        assert ok_ean(x["ean"]), x["ean"]

    write_ticket_csv(OUT_TICKET, folio=FOLIO, fecha=FECHA, proveedor=PROVEEDOR, total=TOTAL_TICKET, rows=r)
    write_unified_sql(OUT_SQL, a)
    print(f"csv   {OUT_TICKET}")
    print(f"sql   {OUT_SQL}")
    print(report(r, TOTAL_TICKET))
    print("altas", sum(1 for x in a if x["alta_nueva"]))
    for x in a:
        flag = "ALTA" if x["alta_nueva"] else "existe"
        print(f"  {x['sku']}  {x['ean']}  ${x['costo']:.2f} → ${x['precio']}  [{flag}]  {x['nombre']}")
