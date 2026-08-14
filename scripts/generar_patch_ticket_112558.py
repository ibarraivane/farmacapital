#!/usr/bin/env python3
"""Genera sql/patch_ticket_112558_completo.sql desde datos curados del OCR ticket 112558."""

from __future__ import annotations

import math
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "sql" / "patch_ticket_112558_completo.sql"


def util_min(c: float) -> float:
    if c < 20:
        return 5
    if c < 50:
        return 8
    return 0


def precio_venta(c: float) -> int:
    return math.ceil(max(c * 1.5, c + util_min(c)))


# Ticket 112558 · El Surtidor · 08-08-2026
# (sku, barcode, qty, precio_lista, importe, descuento, total_linea, nombre, marca, presentacion, categoria, forma)
ITEMS = [
    ("FC-68900264", "7501868900264", 48, 9.00, 432.00, 43.43, 388.57, "Alcohol Dibar 125 ml rojo", "Dibar", "125 ML", "Botiquín", "Alcohol"),
    ("FC-68960257", "7501868960257", 12, 56.00, 672.00, 33.55, 638.45, "Alcohol Dibar 1 L rojo", "Dibar", "1 L", "Botiquín", "Alcohol"),
    ("FC-68900226", "7501868900226", 36, 16.50, 594.00, 29.65, 564.35, "Alcohol Dibar 250 ml rojo", "Dibar", "250 ML", "Botiquín", "Alcohol"),
    ("FC-68990023", "7501868990023", 24, 30.00, 720.00, 43.15, 676.85, "Alcohol Dibar 500 ml rojo", "Dibar", "500 ML", "Botiquín", "Alcohol"),
    ("FC-77620056", "7501677620056", 3, 19.00, 57.00, 0.00, 57.00, "Agua destilada La Flor 1 L", "La Flor", "1 L", "Botiquín", "Agua destilada"),
    ("FC-00003920", "3311000003920", 10, 15.00, 150.00, 0.00, 150.00, "Arnica Mercurio", "Mercurio", None, "Producto", None),
    ("FC-76000260", "7506376000260", 1, 80.00, 80.00, 0.00, 80.00, "Crema Vitacilina amarilla aclaradora", "Vitacilina", None, "Cuidado personal", "Crema"),
    ("FC-76000253", "7506376000253", 1, 80.00, 80.00, 0.00, 80.00, "Crema Vitacilina roja antiarrugas 100 g", "Vitacilina", "100 G", "Cuidado personal", "Crema"),
    ("FC-43475014", "7501943475014", 2, 99.00, 198.00, 0.00, 198.00, "Diapro Confort Gde C/10", "Diapro", "C/10", "Cuidado personal", None),
    ("FC-16800803", "7501116800803", 2, 85.00, 170.00, 0.00, 170.00, "Diapro Confort Med C/10", "Diapro", "C/10", "Cuidado personal", None),
    ("FC-86901100", "7501186901100", 5, 7.40, 37.00, 0.00, 37.00, "Alcohol Dibar 125 ml azul", "Dibar", "125 ML", "Botiquín", "Alcohol"),
    ("FC-68901131", "7501868901131", 5, 41.00, 205.00, 0.00, 205.00, "Alcohol Dibar azul 1 L", "Dibar", "1 L", "Botiquín", "Alcohol"),
    ("FC-68901117", "7501868901117", 5, 11.30, 56.50, 0.00, 56.50, "Alcohol Dibar 250 ml azul", "Dibar", "250 ML", "Botiquín", "Alcohol"),
    ("FC-68901124", "7501868901124", 1, 120.00, 120.00, 0.00, 120.00, "Alcohol Dibar azul 500 ml", "Dibar", "500 ML", "Botiquín", "Alcohol"),
    ("FC-98223704", "7501298223704", 2, 280.50, 561.00, 291.72, 269.28, "Bolo Eurobion tab C/20", "Eurobion", "C/20", "Medicamento", "Tabletas"),
    ("FC-33950100", "7501033950100", 2, 42.00, 84.00, 0.00, 84.00, "Ensure líquido 236 ml chocolate", "Ensure", "236 ML", "Suplemento", "Líquido"),
    ("FC-33950063", "7501033950063", 2, 42.00, 84.00, 0.00, 84.00, "Pediasure líquido 236 ml fresa", "Pediasure", "236 ML", "Suplemento", "Líquido"),
    ("FC-33950070", "7501033950070", 2, 42.00, 84.00, 0.00, 84.00, "Ensure líquido 236 ml vainilla", "Ensure", "236 ML", "Suplemento", "Líquido"),
    ("FC-33956133", "7501033956133", 2, 51.04, 102.08, 7.08, 95.00, "Glucerna líquido 237 ml chocolate", "Glucerna", "237 ML", "Suplemento", "Líquido"),
    ("FC-33956126", "7501033956126", 2, 47.50, 95.00, 0.00, 95.00, "Glucerna líquido 237 ml vainilla", "Glucerna", "237 ML", "Suplemento", "Líquido"),
    ("FC-33956140", "7501033956140", 2, 47.50, 95.00, 0.00, 95.00, "Glucerna SR líquido 237 ml fresa", "Glucerna", "237 ML", "Suplemento", "Líquido"),
    ("FC-07521317", "7501507521317", 100, 1.20, 119.99, 0.00, 119.99, "Gotero cristal", "Genérico", None, "Botiquín", "Gotero"),
    ("FC-01157296", "7501001157296", 5, 17.00, 85.00, 0.00, 85.00, "Naturella flujo moderado C/8 con alas", "Naturella", "C/8", "Higiene", "Toallas sanitarias"),
    ("FC-01405335", "7501001405335", 5, 18.50, 92.50, 0.00, 92.50, "Naturella noche con alas C/8", "Naturella", "C/8", "Higiene", "Toallas sanitarias"),
    ("FC-33951008", "7501033951008", 2, 44.00, 88.00, 0.00, 88.00, "Pediasure líquido 236 ml chocolate", "Pediasure", "236 ML", "Suplemento", "Líquido"),
    ("FC-33954245", "7501033954245", 2, 44.00, 88.00, 0.00, 88.00, "Pediasure líquido 236 ml fresa", "Pediasure", "236 ML", "Suplemento", "Líquido"),
    ("FC-33950209", "7501033950209", 2, 44.00, 88.00, 0.00, 88.00, "Pediasure líquido 236 ml vainilla", "Pediasure", "236 ML", "Suplemento", "Líquido"),
    ("FC-19006623", "7501019006623", 10, 9.80, 99.00, 0.00, 99.00, "Saba buenas noches", "Saba", None, "Higiene", "Toallas sanitarias"),
    ("FC-65054135", "7501065054043", 1, 52.06, 52.06, 14.58, 37.48, "Tums Extra surtido 750 mg C/24 (3 rollos x 8)", "Tums", "C/24", "Gastro", "Tableta masticable"),
    ("FC-56323066", "7501056323066", 1, 27.00, 27.00, 0.00, 27.00, "Vaseline FaseLine puro 42 g", "Vaseline", "42 G", "Producto", None),
    ("FC-56323059", "7501056323059", 1, 45.50, 45.50, 0.00, 45.50, "Vaseline puro 85 g", "Vaseline", "85 G", "Producto", None),
    ("FC-01246730", "7501001246730", 1, 255.00, 255.00, 0.00, 255.00, "Vicks Vaporub pomada 12 g C/12 latas", "Vicks", "12 G", "Botiquín", None),
    ("FC-02012475", "7590002012475", 1, 238.32, 238.32, 113.20, 125.12, "Vicks Vaporub ungüento 100 g", "Vicks", "100 G", "Botiquín", "Ungüento"),
    ("FC-02012468", "7590002012468", 1, 201.00, 201.00, 118.59, 82.41, "Vicks Vaporub ungüento 50 g", "Vicks", "50 G", "Botiquín", "Balsamo"),
]


def sql_literal(s: str | None) -> str:
    if s is None:
        return "null"
    return "'" + s.replace("'", "''") + "'"


# Productos que probablemente no existen aún en BD (resto ya viene de carga previa)
CREATE_IF_MISSING_SKUS = {
    "FC-43475014": "TK-112558-8G",
    "FC-33956126": "TK-112558-19V",
}

MATCH_PRODUCTO = "p.sku = t.sku or p.codigo_barras = t.codigo_barras"


def main() -> None:
    rows = []
    for item in ITEMS:
        sku, bc, qty, lista, imp, desc, total, nombre, marca, pres, cat, forma = item
        costo = round(total / qty, 2)
        pct = round(desc / imp * 100, 2) if imp and desc else 0
        rows.append((sku, bc, qty, lista, pct, imp, desc, total, costo, precio_venta(costo), nombre, marca, pres, cat, forma))

    vals = []
    for r in rows:
        sku, bc, qty, lista, pct, imp, desc, total, costo, precio, nombre, marca, pres, cat, forma = r
        vals.append(
            f"  ({sql_literal(sku)},{sql_literal(bc)},{qty},{lista},{pct},{imp},{desc},{total},{costo},{precio},"
            f"{sql_literal(nombre)},{sql_literal(marca)},{sql_literal(pres)},{sql_literal(cat)},{sql_literal(forma)})"
        )

    insert_vals = ",\n".join(vals)
    create_blocks = []
    for r in rows:
        sku, bc, qty, lista, pct, imp, desc, total, costo, precio, nombre, marca, pres, cat, forma = r
        lote = CREATE_IF_MISSING_SKUS.get(sku)
        if not lote:
            continue
        cat_sql = sql_literal(cat)
        pres_sql = sql_literal(pres)
        forma_sql = sql_literal(forma)
        create_blocks.append(
            f"""-- Alta si falta: {nombre}
do $$
begin
  if not exists (select 1 from public.productos where sku = {sql_literal(sku)} or codigo_barras = {sql_literal(bc)}) then
    perform * from public.create_producto_with_lote(
      jsonb_build_object(
        'nombre', {sql_literal(nombre)},
        'sku', {sql_literal(sku)},
        'codigo_barras', {sql_literal(bc)},
        'categoria', {cat_sql},
        'tipo', 'marca',
        'descripcion', {sql_literal(nombre + ' — ticket 112558')},
        'costo', {costo},
        'precio', {precio},
        'stock_minimo', 2,
        'activo', true,
        'requiere_receta', false
      ),
      {qty},
      {sql_literal(lote)},
      null,
      {costo},
      null
    );
    update public.productos set
      marca = {sql_literal(marca)},
      presentacion = {pres_sql},
      forma_farmaceutica = {forma_sql},
      proveedor = 'El Surtidor de su Farmacia'
    where sku = {sql_literal(sku)} or codigo_barras = {sql_literal(bc)};
  end if;
end $$;
"""
        )
    creates_sql = "\n".join(create_blocks)
    sql = f"""-- ============================================================================
-- CORRECCIÓN COMPLETA ticket 112558 · El Surtidor de su Farmacia · 08-08-2026
-- {len(rows)} productos · cantidades + costo unitario NETO (Total÷pzas, c/descuento) + marcas
--
-- Columnas ticket: Precio (lista) → Importe → Descuento → Total (s/IVA)
-- costo unitario = Total ÷ cantidad
-- Regenerar: python3 scripts/generar_patch_ticket_112558.py
-- Ejecutar UNA vez en Supabase SQL Editor.
-- NO ejecutar patch_cantidades_tickets_completo.sql sobre estos SKUs (contradice el ticket).
-- ============================================================================

begin;

{creates_sql}

create temp table _fc_tk112558 (
  sku text primary key,
  codigo_barras text,
  qty integer not null,
  precio_lista numeric(10,2),
  pct_desc numeric(5,2),
  importe numeric(10,2),
  descuento numeric(10,2),
  total_linea numeric(10,2),
  costo_unitario numeric(10,2) not null,
  precio_venta numeric(10,2) not null,
  nombre text not null,
  marca text not null,
  presentacion text,
  categoria text,
  forma_farmaceutica text
) on commit drop;

insert into _fc_tk112558 values
{insert_vals};

update public.productos p set
  sku = t.sku,
  nombre = t.nombre,
  codigo_barras = t.codigo_barras,
  marca = t.marca,
  presentacion = t.presentacion,
  categoria = t.categoria,
  forma_farmaceutica = t.forma_farmaceutica,
  tipo = 'marca',
  costo = t.costo_unitario,
  precio = t.precio_venta,
  descripcion = t.nombre || ' — ticket 112558'
from _fc_tk112558 t
where {MATCH_PRODUCTO};

-- Productos sin lote activo: recibir mercancía
do $$
declare r record; v_lid bigint;
begin
  for r in
    select t.*, p.id as producto_id
    from _fc_tk112558 t
    join public.productos p on ({MATCH_PRODUCTO})
    where not exists (
      select 1 from public.lotes l
      where l.producto_id = p.id and coalesce(l.activo, true)
    )
  loop
    select lote_id into v_lid from public.receive_merchandise_lote(
      r.producto_id, r.qty, 'TK-112558-' || r.sku, null, r.costo_unitario, 'El Surtidor de su Farmacia', null
    );
  end loop;
end $$;

create temp table _fc_tk112558_lote as
select distinct on (p.id)
  p.id as producto_id, t.qty, t.costo_unitario, l.id as lote_id
from _fc_tk112558 t
join public.productos p on ({MATCH_PRODUCTO})
join public.lotes l on l.producto_id = p.id and coalesce(l.activo, true)
order by p.id,
  case when l.numero_lote ilike 'TK-112558-%' then 0 when l.numero_lote ilike 'TK-%' then 1 else 2 end,
  l.created_at desc nulls last, l.id desc;

update public.lotes l set cantidad_actual = 0
from _fc_tk112558_lote pl
where l.producto_id = pl.producto_id and l.id <> pl.lote_id
  and coalesce(l.activo, true) and coalesce(l.cantidad_actual, 0) <> 0;

update public.lotes l set cantidad_actual = pl.qty, costo_unitario = pl.costo_unitario
from _fc_tk112558_lote pl where l.id = pl.lote_id;

update public.lotes l set costo_unitario = pl.costo_unitario
from _fc_tk112558_lote pl
where l.producto_id = pl.producto_id and coalesce(l.activo, true)
  and coalesce(l.costo_unitario, 0) is distinct from pl.costo_unitario;

update public.productos p set stock = coalesce((
  select sum(l.cantidad_actual) from public.lotes l
  where l.producto_id = p.id and coalesce(l.activo, true)
), 0)
from _fc_tk112558 t
where {MATCH_PRODUCTO};

select t.sku as sku_ticket, p.sku as sku_bd, t.codigo_barras, left(t.nombre, 32) as producto,
  t.qty as pzas_ticket, p.stock as stock_bd, t.costo_unitario as costo_neto, p.costo,
  case
    when p.id is null then 'SIN PRODUCTO'
    when p.sku is null or btrim(p.sku) = '' then 'REVISAR SKU'
    when abs(p.costo - t.costo_unitario) > 0.01 then 'REVISAR COSTO'
    when p.stock <> t.qty then 'REVISAR STOCK'
    else 'OK'
  end as estado
from _fc_tk112558 t
left join public.productos p on ({MATCH_PRODUCTO})
order by t.sku;

commit;
"""
    OUT.write_text(sql, encoding="utf-8")
    print(f"Wrote {OUT} ({len(rows)} products)")


if __name__ == "__main__":
    main()
