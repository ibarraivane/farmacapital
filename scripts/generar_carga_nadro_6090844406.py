#!/usr/bin/env python3
"""Factura Nadro folio 6090844406 (06-oct-2026, 2 renglones) → catálogo + cola Recibir.

EAN oficiales iNadro / Farmacias Especializadas / San Jorge.
Sin lote ni MMAA en la cola: salen de la caja al escanear.
Fotos en public/catalogo-propia/ (SQL de foto tras deploy).
"""
from __future__ import annotations

import math
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from generar_recepcion_borrador import report, write_ticket_csv

ROOT = Path(__file__).resolve().parents[1]
OUT_TICKET = ROOT / "sql" / "generated" / "ticket_nadro_6090844406.csv"
OUT_SQL = ROOT / "sql" / "patch_carga_nadro_6090844406.sql"
OUT_FOTOS = ROOT / "sql" / "patch_fotos_nadro_6090844406.sql"
OUT_MD = ROOT / "sql" / "LEERME_nadro_6090844406.md"
FOTO_BASE = "https://www.farmacapital.mx/catalogo-propia"

FOLIO = "6090844406"
PROVEEDOR = "Nadro"
FECHA = "2026-10-06"
TOTAL_TICKET = 343.20


def precio(costo: float, tipo: str) -> int:
    """Recargo sobre costo: marca +25%, genérico +60%."""
    factor = 1.25 if tipo == "marca" else 1.6
    return int(math.ceil(costo * factor))


def sku_de(ean: str) -> str:
    return "FC-" + ean[-8:]


def sql_str(s: str | None) -> str:
    if s is None:
        return "null"
    return "'" + str(s).replace("'", "''") + "'"


# snap ticket, qty, pu, ean, match,
# nombre POS, tipo, cat, subcat, marca, presentacion, forma, lab, pa, conc, receta, alta, foto
RAW = [
    (
        "BIMATOPROST 0.3MG SOL 3 ML LGEN",
        1,
        209.38,
        "7502231320696",
        "alta_nueva",
        "Mictrobil bimatoprost 0.3 mg",
        "generico",
        "Medicamentos",
        "Oftalmología",
        "Mictrobil",
        "Frasco gotero 3 ml",
        "Solución oftálmica",
        "Micro Pharmaceuticals",
        "Bimatoprost",
        "0.3 mg/ml",
        True,
        True,
        "mictrobil-bimatoprost-0.3mg-3ml-7502231320696.jpg",
    ),
    (
        "LATANOPR .05MG OFTA 3ML GTS LGEN",
        1,
        133.82,
        "75055813",
        "alta_nueva",
        "Exakta latanoprost 0.05 mg",
        "generico",
        "Medicamentos",
        "Oftalmología",
        "Exakta",
        "Frasco gotero 3 ml",
        "Solución oftálmica",
        "Opko",
        "Latanoprost",
        "0.05 mg/ml",
        True,
        True,
        "exakta-latanoprost-0.05mg-3ml-75055813.jpg",
    ),
]


def rows():
    out = []
    for snap, qty, pu, ean, match, *_rest in RAW:
        out.append(
            {
                "nombre": snap,
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
        foto,
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
                "foto": f"{FOTO_BASE}/{foto}",
                "foto_file": foto,
            }
        )
    return out


def write_unified_sql(path: Path, items: list) -> None:
    vals = []
    for i, r in enumerate(items):
        vals.append(
            "  ({linea}, {ean}, {sku}, {pos}, {snap}, {qty}, {costo}, {precio}, {tipo}, "
            "{cat}, {subcat}, {marca}, {pres}, {forma}, {lab}, {pa}, {conc}, {receta}, {alta}, {img})".format(
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
                img=sql_str(r["foto"]),
            )
        )

    body = f"""-- Factura Nadro folio {FOLIO} ({FECHA}) — altas + cola Recibir.
-- CFDI 06-oct-2026 · total ${TOTAL_TICKET:.2f} · 2 piezas
-- SIN bloques dollar-quote (do $$). El SQL Editor de Supabase los corta.
-- 2 altas stock 0 (Mictrobil, Exakta latanoprost).
-- Ficha desde iNadro (no código del ticket). MICROGRP/LGEN no son marca de mostrador.
-- Ticket borrador. Stock al escanear + MMAA de la caja. No inventar 0000.
-- Idempotente mientras el ticket siga en borrador.
-- Pegar TODO este archivo en Supabase → SQL Editor → Run.
-- Fotos: tras deploy, pegar sql/patch_fotos_nadro_{FOLIO}.sql

begin;

create temp table _fc_nd6090844406 (
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
  alta_nueva boolean not null,
  imagen text
) on commit drop;

insert into _fc_nd6090844406
  (linea, ean, sku, nombre, snap, qty, costo, precio, tipo, categoria, subcategoria,
   marca, presentacion, forma, laboratorio, principio_activo, concentracion, receta, alta_nueva, imagen)
values
{",\n".join(vals)};

-- Altas nuevas (solo si el EAN no existe).
insert into public.productos (
  nombre, sku, codigo_barras, categoria, tipo, descripcion,
  costo, precio, stock, stock_minimo, activo, requiere_receta,
  marca, presentacion, forma_farmaceutica, principio_activo, concentracion,
  laboratorio, subcategoria, imagen_url, imagen_mobile_url
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
  t.receta,
  t.marca,
  t.presentacion,
  t.forma,
  t.principio_activo,
  t.concentracion,
  t.laboratorio,
  t.subcategoria,
  t.imagen,
  t.imagen
from _fc_nd6090844406 t
where t.alta_nueva
  and public.fc_buscar_producto_escaneo(t.ean) is null;

-- Ficha de mostrador (marca real, no casa Nadro LGEN/MICROGRP como marca).
update public.productos p set
  marca = coalesce(nullif(btrim(t.marca), ''), p.marca),
  presentacion = t.presentacion,
  forma_farmaceutica = t.forma,
  principio_activo = t.principio_activo,
  concentracion = t.concentracion,
  subcategoria = t.subcategoria,
  laboratorio = coalesce(nullif(btrim(t.laboratorio), ''), nullif(btrim(p.laboratorio), ''), t.laboratorio),
  nombre = t.nombre,
  categoria = t.categoria,
  tipo = t.tipo,
  requiere_receta = t.receta,
  imagen_url = coalesce(nullif(btrim(p.imagen_url), ''), t.imagen),
  imagen_mobile_url = coalesce(nullif(btrim(p.imagen_mobile_url), ''), t.imagen)
from _fc_nd6090844406 t
where p.id = public.fc_buscar_producto_escaneo(t.ean);

-- Costos del ticket (PVP solo si estaba en 0).
update public.productos p
set
  costo = t.costo,
  precio = case
    when coalesce(p.precio, 0) <= 0 then t.precio
    else p.precio
  end
from _fc_nd6090844406 t
where p.id = public.fc_buscar_producto_escaneo(t.ean)
  and (
    p.costo is distinct from t.costo
    or coalesce(p.precio, 0) <= 0
  );

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'Nadro',
  '{FOLIO}',
  '{FECHA}',
  {TOTAL_TICKET:.2f},
  'borrador',
  'Factura Nadro {FOLIO} · 06-10-26 · EAN iNadro · cola Recibir; stock al confirmar pistola'
where not exists (
  select 1 from public.recepciones
  where folio = '{FOLIO}' and coalesce(proveedor, '') ilike '%nadro%'
);

update public.recepciones
set
  total_ticket = {TOTAL_TICKET:.2f},
  fecha = '{FECHA}',
  proveedor = 'Nadro',
  notas = 'Factura Nadro {FOLIO} · 06-10-26 · EAN iNadro · cola Recibir; stock al confirmar pistola',
  updated_at = now()
where folio = '{FOLIO}'
  and coalesce(proveedor, '') ilike '%nadro%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = '{FOLIO}'
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
from _fc_nd6090844406 t
join public.recepciones r
  on r.folio = '{FOLIO}'
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
where r.folio = '{FOLIO}' and coalesce(r.proveedor, '') ilike '%nadro%'
order by i.id;
"""
    path.write_text(body, encoding="utf-8")


def write_fotos_sql(path: Path, items: list) -> None:
    lines = [
        f"-- Fotos catalogo-propia · corrida DESPUÉS del deploy de Vercel.",
        f"-- Packshots Nadro {FOLIO}:",
    ]
    for r in items:
        lines.append(f"--   {r['foto_file']}")
    lines += [
        "-- SIN do $$. Pegar TODO en Supabase → SQL Editor → Run.",
        "",
        "begin;",
        "",
    ]
    for r in items:
        url = r["foto"]
        ean = r["ean"]
        sku = r["sku"]
        stem = r["foto_file"].rsplit(".", 1)[0]
        lines += [
            "update public.productos",
            f"set imagen_url = {sql_str(url)},",
            f"    imagen_mobile_url = {sql_str(url)}",
            f"where (codigo_barras = {sql_str(ean)} or sku in ({sql_str(sku)}, {sql_str('FC-ND-' + ean[-8:])}))",
            "  and (",
            "    imagen_url is null",
            "    or btrim(imagen_url) = ''",
            f"    or imagen_url not like '%catalogo-propia/{stem}%'",
            "  );",
            "",
            "insert into public.producto_imagenes (producto_id, url, posicion, es_principal, origen)",
            "select p.id,",
            f"       {sql_str(url)},",
            "       coalesce((select max(i.posicion) from public.producto_imagenes i where i.producto_id = p.id), 0) + 1,",
            "       not exists (",
            "         select 1 from public.producto_imagenes i",
            "         where i.producto_id = p.id and i.es_principal",
            "       ),",
            "       'propia'",
            "from public.productos p",
            f"where (p.codigo_barras = {sql_str(ean)} or p.sku in ({sql_str(sku)}, {sql_str('FC-ND-' + ean[-8:])}))",
            "  and not exists (",
            "    select 1 from public.producto_imagenes i",
            "    where i.producto_id = p.id",
            f"      and i.url like '%catalogo-propia/{stem}%'",
            "  );",
            "",
        ]
    eans = ", ".join(sql_str(r["ean"]) for r in items)
    skus = ", ".join(
        sql_str(s)
        for r in items
        for s in (r["sku"], f"FC-ND-{r['ean'][-8:]}")
    )
    lines += [
        "commit;",
        "",
        "select sku, codigo_barras, left(nombre, 40) as nombre, imagen_url",
        "from public.productos",
        f"where codigo_barras in ({eans})",
        f"   or sku in ({skus});",
        "",
    ]
    path.write_text("\n".join(lines), encoding="utf-8")


def write_md(path: Path, items: list) -> None:
    rows_md = "\n".join(
        f"| `{r['ean']}` | {r['snap']} ×{r['qty']} | `{r['sku']}` | **Alta nueva** · ${r['costo']:.2f} → ${r['precio']} |"
        for r in items
    )
    path.write_text(
        f"""# Nadro folio {FOLIO} · 06-oct-2026 · ${TOTAL_TICKET:.2f}

Factura CFDI (foto) · FARMACAPITAL (LA CAP) · 2 piezas oftálmicas.

## Veredicto

| EAN | Ticket | SKU | Acción |
|---|---|---|---|
{rows_md}

## Qué pegar en Supabase

1. `sql/patch_carga_nadro_{FOLIO}.sql` — altas + cola Recibir borrador.
2. Tras deploy Vercel: `sql/patch_fotos_nadro_{FOLIO}.sql`.

Stock **0** hasta escanear con pistola y capturar MMAA de la caja.

## Notas

- Nombres de mostrador desde ficha iNadro (Mictrobil / Exakta), no el código LGEN del ticket.
- EAN Bimatoprost: `7502231320696` (iNadro + Farmacias Especializadas). EAN Latanoprost: `75055813` (iNadro / Prixz / San Jorge).
- Recargo genérico +60% sobre costo. Receta: sí (oftálmicos fracción IV).
- Regenerar: `python3 scripts/generar_carga_nadro_{FOLIO}.py`
""",
        encoding="utf-8",
    )


def main() -> None:
    items = altas()
    write_ticket_csv(
        OUT_TICKET,
        folio=FOLIO,
        fecha=FECHA,
        proveedor=PROVEEDOR,
        total=TOTAL_TICKET,
        rows=rows(),
    )
    write_unified_sql(OUT_SQL, items)
    write_fotos_sql(OUT_FOTOS, items)
    write_md(OUT_MD, items)
    print(report(rows(), TOTAL_TICKET))
    print(f"OK csv → {OUT_TICKET}")
    print(f"OK sql → {OUT_SQL}")
    print(f"OK fotos → {OUT_FOTOS}")
    print(f"OK md → {OUT_MD}")
    for r in items:
        foto = ROOT / "public" / "catalogo-propia" / r["foto_file"]
        assert foto.exists(), f"Falta packshot {foto}"
        print(f"  foto {r['foto_file']} ({foto.stat().st_size} bytes)")


if __name__ == "__main__":
    main()
