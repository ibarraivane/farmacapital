-- Altas desde foto mostrador 05-sep-2026 (NO es factura Nadro).
-- Diagnóstico: sql/LEERME_foto_nadro_20260905.md
--
-- Carticap / Oral-B gingivitis / Estomaquil suspensión no estaban en catálogo.
-- Neo-Melubrina Infantil sí (FC-50003151) pero con nombre/forma mal.
-- Tylenol C/10 ya existe (FC-75354321) — no se toca stock.
--
-- Costos = referencia mayoreo / ficha; precio = costo × 1.25 (marca).
-- Stock 0. SIN do $$. Idempotente.
-- Pegar TODO en Supabase → SQL Editor → Run.
-- Fotos: después del deploy → patch_fotos_foto_mostrador_20260905.sql

begin;

-- ── 1) Fix Neo-Melubrina Infantil (ya existía, mal nombrada) ─────
update public.productos
set
  nombre = 'Neo-Melubrina Infantil metamizol jarabe 100 mL',
  marca = 'Neo-Melubrina',
  laboratorio = coalesce(nullif(btrim(laboratorio), ''), 'Opella / Sanofi'),
  presentacion = 'Caja con frasco 100 mL + pipeta',
  forma_farmaceutica = 'Jarabe',
  principio_activo = 'Metamizol sódico',
  concentracion = '250 mg / 5 mL',
  categoria = coalesce(nullif(btrim(categoria), ''), 'Analgésico'),
  subcategoria = coalesce(nullif(btrim(subcategoria), ''), 'Antipirético infantil'),
  tipo = 'marca',
  activo = true
where sku = 'FC-50003151'
   or codigo_barras = '7501165000315'
   or codigo_barras = '75011650003151';

-- Tylenol C/10: asegurar nombre legible (ya estaba)
update public.productos
set
  nombre = 'Tylenol paracetamol 500 mg C/10',
  marca = coalesce(nullif(btrim(marca), ''), 'Tylenol'),
  laboratorio = coalesce(nullif(btrim(laboratorio), ''), 'Kenvue'),
  presentacion = coalesce(nullif(btrim(presentacion), ''), 'Caja con 10 tabletas'),
  forma_farmaceutica = coalesce(nullif(btrim(forma_farmaceutica), ''), 'Tableta'),
  principio_activo = coalesce(nullif(btrim(principio_activo), ''), 'Paracetamol'),
  concentracion = coalesce(nullif(btrim(concentracion), ''), '500 mg'),
  categoria = coalesce(nullif(btrim(categoria), ''), 'Analgésico'),
  tipo = 'marca',
  activo = true
where sku = 'FC-75354321'
   or codigo_barras = '7501007535432'
   or codigo_barras = '75010075354321';

-- ── 2) Altas nuevas (stock 0) ────────────────────────────────────
create temp table _fc_foto_altas (
  ean text primary key,
  sku text not null,
  nombre text not null,
  costo numeric(12,2) not null,
  precio numeric(12,2) not null,
  tipo text not null,
  categoria text not null,
  marca text,
  laboratorio text,
  presentacion text,
  principio_activo text,
  concentracion text,
  forma_farmaceutica text,
  subcategoria text,
  receta boolean not null
) on commit drop;

insert into _fc_foto_altas values
  ('7502227426067', 'FC-27426067',
   'Carticap FOR glucosamina/condroitina C/60',
   87.42, 110, 'marca', 'Suplemento', 'Carticap', 'Gelpharma',
   'Caja con 60 cápsulas',
   'Glucosamina / Condroitina / Vitamina C / Manganeso',
   '300 mg / 200 mg / 30 mg / 20 mg',
   'Cápsula', 'Osteoartritis', false),
  ('7501086453221', 'FC-08645322',
   'Oral-B enjuague bucal para gingivitis 350 mL',
   185.00, 232, 'marca', 'Higiene', 'Oral-B', 'Procter & Gamble',
   'Botella 350 mL',
   'Digluconato de clorhexidina',
   '0.12 %',
   'Enjuague bucal', 'Higiene bucal', false),
  ('7501369200108', 'FC-69200108',
   'Estomaquil Exper3 suspensión 240 mL',
   72.00, 90, 'marca', 'Digestivo', 'Estomaquil', 'Laboratorios Higia',
   'Frasco 240 mL',
   'Carbonato de calcio / Hidróxido de magnesio / Subsalicilato de bismuto',
   '2.67 g / 1.67 g / 1 g por 100 mL',
   'Suspensión', 'Antiácido', false);

insert into public.productos (
  nombre, sku, codigo_barras, categoria, tipo, descripcion,
  costo, precio, stock, stock_minimo, activo, requiere_receta,
  marca, laboratorio, presentacion, principio_activo, concentracion,
  forma_farmaceutica, subcategoria
)
select
  t.nombre,
  t.sku,
  t.ean,
  t.categoria,
  t.tipo,
  'Alta foto mostrador 2026-09-05 · NO viene en tickets Nadro 1658128647824 ni 20260901 · stock 0 hasta ticket real',
  t.costo,
  t.precio,
  0,
  2,
  true,
  t.receta,
  t.marca,
  t.laboratorio,
  t.presentacion,
  t.principio_activo,
  t.concentracion,
  t.forma_farmaceutica,
  t.subcategoria
from _fc_foto_altas t
where not exists (
  select 1 from public.productos p
  where p.codigo_barras = t.ean or p.sku = t.sku
);

-- Si ya existían por EAN/SKU, solo enriquecer ficha (no pisar precio/costo buenos)
update public.productos p
set
  nombre = t.nombre,
  marca = coalesce(nullif(btrim(p.marca), ''), t.marca),
  laboratorio = coalesce(nullif(btrim(p.laboratorio), ''), t.laboratorio),
  presentacion = coalesce(nullif(btrim(p.presentacion), ''), t.presentacion),
  principio_activo = coalesce(nullif(btrim(p.principio_activo), ''), t.principio_activo),
  concentracion = coalesce(nullif(btrim(p.concentracion), ''), t.concentracion),
  forma_farmaceutica = coalesce(nullif(btrim(p.forma_farmaceutica), ''), t.forma_farmaceutica),
  subcategoria = coalesce(nullif(btrim(p.subcategoria), ''), t.subcategoria),
  categoria = coalesce(nullif(btrim(p.categoria), ''), t.categoria),
  tipo = t.tipo,
  costo = case when coalesce(p.costo, 0) <= 0 then t.costo else p.costo end,
  precio = case
    when coalesce(p.precio, 0) <= 0 then t.precio
    when coalesce(p.precio, 0) < (coalesce(nullif(p.costo, 0), t.costo) * 1.15) then t.precio
    else p.precio
  end,
  activo = true,
  codigo_barras = t.ean
from _fc_foto_altas t
where p.codigo_barras = t.ean or p.sku = t.sku;

commit;

select sku, codigo_barras, nombre, marca, presentacion, forma_farmaceutica, stock, costo, precio, activo
from public.productos
where codigo_barras in (
  '7502227426067', '7501086453221', '7501369200108',
  '7501165000315', '7501007535432'
)
   or sku in ('FC-27426067', 'FC-08645322', 'FC-69200108', 'FC-50003151', 'FC-75354321')
order by nombre;
