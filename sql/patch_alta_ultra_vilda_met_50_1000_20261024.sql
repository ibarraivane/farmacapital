-- Alta catálogo: Ultra Vildagliptina/Metformina 50/1000 mg C/30
-- EAN de caja: 7502216790506 · SKU FC-16790506
-- Marca de laboratorio Ultra (no «Desia»). Stock 0. Sin caducidad inventada.
-- NO va en el ticket Equilibrio 241026 (ese solo trae 50/500 y 50/850).
-- PVP genérico ancla (hermanos EQ-ULT284 $254 / EQ-ULT285 $276 → $298).
-- Costo null hasta compra; no inventar mayoreo.
-- Pegar TODO en Supabase → SQL Editor → Run.

begin;

-- Si el EAN ya está en otro SKU, soltarlo para no chocar UNIQUE.
update public.productos
set codigo_barras = null
where codigo_barras = '7502216790506'
  and sku is distinct from 'FC-16790506';

insert into public.productos (
  nombre, sku, codigo_barras, categoria, subcategoria, tipo, descripcion,
  marca, laboratorio, presentacion, forma_farmaceutica, principio_activo,
  concentracion, costo, precio, stock, stock_minimo, activo, requiere_receta
)
select
  'Vildagliptina/metformina 50/1000 mg',
  'FC-16790506',
  '7502216790506',
  'Medicamentos',
  'Diabetes',
  'generico',
  'Alta foto caja Ultra 24-oct-2026 · EAN 7502216790506 · no pertenece a Equilibrio 241026',
  'Ultra',
  'Ultra',
  'Caja con 30 comprimidos',
  'Comprimido',
  'Vildagliptina / metformina',
  '50/1000 mg',
  null,
  298,
  0,
  2,
  true,
  true
where public.fc_buscar_producto_escaneo('7502216790506') is null
  and not exists (
    select 1 from public.productos p where p.sku = 'FC-16790506'
  );

update public.productos p
set
  codigo_barras = '7502216790506',
  nombre = 'Vildagliptina/metformina 50/1000 mg',
  marca = 'Ultra',
  laboratorio = coalesce(nullif(btrim(p.laboratorio), ''), 'Ultra'),
  presentacion = 'Caja con 30 comprimidos',
  forma_farmaceutica = 'Comprimido',
  principio_activo = 'Vildagliptina / metformina',
  concentracion = '50/1000 mg',
  categoria = 'Medicamentos',
  subcategoria = 'Diabetes',
  tipo = 'generico',
  requiere_receta = true,
  precio = case when coalesce(p.precio, 0) <= 0 then 298 else p.precio end,
  activo = true
where p.sku = 'FC-16790506'
   or p.codigo_barras = '7502216790506';

commit;

select
  id,
  sku,
  codigo_barras as ean,
  nombre,
  marca,
  concentracion,
  presentacion,
  precio,
  costo,
  stock,
  requiere_receta
from public.productos
where sku = 'FC-16790506'
   or codigo_barras = '7502216790506';
