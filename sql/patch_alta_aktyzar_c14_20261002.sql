-- Alta: Aktyzar Omeprazol 20 mg C/14 (Solfrán) — 02-oct-2026
-- EAN confirmado en Farma Medical: 7502274792207
-- (En catálogo ya estaba C/120 = FC-82200016 / 7501482200016; esta es otra presentación.)
-- Costo ancla mayoreo ~$8.86; precio = ceil(costo × 1.60) genérico.
-- Stock 0 hasta Recibir. SIN inventar caducidad.
-- Idempotente. Pegar TODO en Supabase → SQL Editor → Run.
-- Foto: después del deploy → patch_fotos_caja_lote_20261002.sql

begin;

insert into public.productos (
  nombre, sku, codigo_barras, categoria, tipo, descripcion,
  costo, precio, stock, stock_minimo, activo, requiere_receta,
  marca, laboratorio, presentacion, principio_activo, concentracion,
  forma_farmaceutica, subcategoria
)
select
  'Aktyzar Omeprazol 20 mg',
  'FC-74792207',
  '7502274792207',
  'Gastro',
  'generico',
  'Aktyzar Omeprazol 20 mg · Solfrán · Caja con 14 cápsulas',
  8.86,
  15,
  0,
  5,
  true,
  false,
  'Aktyzar',
  'Solfrán Laboratorios',
  'Caja con 14 cápsulas',
  'Omeprazol',
  '20 mg',
  'Cápsulas',
  'Protector gástrico'
where not exists (
  select 1 from public.productos p
  where p.codigo_barras = '7502274792207'
     or p.codigo_barras = '75022747922070'
     or p.sku = 'FC-74792207'
);

-- Si ya existía sin ficha completa, completa campos (no pisa stock/precio si ya hay venta).
update public.productos
set
  nombre = 'Aktyzar Omeprazol 20 mg',
  marca = coalesce(nullif(btrim(marca), ''), 'Aktyzar'),
  laboratorio = coalesce(nullif(btrim(laboratorio), ''), 'Solfrán Laboratorios'),
  presentacion = coalesce(nullif(btrim(presentacion), ''), 'Caja con 14 cápsulas'),
  forma_farmaceutica = coalesce(nullif(btrim(forma_farmaceutica), ''), 'Cápsulas'),
  principio_activo = coalesce(nullif(btrim(principio_activo), ''), 'Omeprazol'),
  concentracion = coalesce(nullif(btrim(concentracion), ''), '20 mg'),
  categoria = coalesce(nullif(btrim(categoria), ''), 'Gastro'),
  subcategoria = coalesce(nullif(btrim(subcategoria), ''), 'Protector gástrico'),
  tipo = coalesce(nullif(btrim(tipo), ''), 'generico'),
  activo = true
where sku = 'FC-74792207'
   or codigo_barras = '7502274792207'
   or codigo_barras = '75022747922070';

commit;

select id, sku, codigo_barras, nombre, presentacion, costo, precio, stock,
       left(coalesce(imagen_url, ''), 90) as imagen
from public.productos
where sku = 'FC-74792207'
   or codigo_barras in ('7502274792207', '75022747922070');
