-- Aplica staging Medik8 → productos + referencias
begin;

do $$
begin
  if to_regclass('public._fc_medik8_stg') is null then
    raise exception 'Falta _fc_medik8_stg. Corre 00_staging_medik8.sql y las filas 03a.';
  end if;
end $$;

insert into public.productos (
  nombre, sku, codigo_barras, categoria, tipo, descripcion,
  costo, precio, stock, stock_minimo, activo, requiere_receta,
  marca, laboratorio, presentacion, subcategoria, bajo_pedido
)
select
  t.nombre,
  t.sku,
  null,
  'Cuidado personal',
  'marca',
  coalesce(nullif(t.descripcion, ''), 'Medik8 · Dermatotec especialistas 2025')
    || coalesce(' · ' || nullif(t.gama, ''), ''),
  t.costo,
  t.precio,
  0,
  1,
  true,
  false,
  'Medik8',
  'Dermatotec',
  t.presentacion,
  'Dermatología',
  true
from public._fc_medik8_stg t
where not exists (
  select 1 from public.productos p where p.sku = t.sku
);

update public.productos p
   set costo = t.costo,
       precio = case
         when coalesce(p.stock, 0) > 0 and coalesce(p.precio, 0) > 0.01 then p.precio
         else t.precio
       end,
       bajo_pedido = case when coalesce(p.stock, 0) > 0 then false else true end,
       activo = true,
       marca = 'Medik8',
       laboratorio = 'Dermatotec',
       presentacion = coalesce(nullif(btrim(p.presentacion), ''), t.presentacion),
       subcategoria = 'Dermatología',
       categoria = 'Cuidado personal',
       descripcion = coalesce(nullif(btrim(p.descripcion), ''), t.descripcion)
  from public._fc_medik8_stg t
 where p.sku = t.sku
   and coalesce(p.stock, 0) = 0;

delete from public.producto_precios_referencia r
 using public.productos p, public._fc_medik8_stg t
 where r.producto_id = p.id
   and p.sku = t.sku
   and r.fuente = 'medik8'
   and r.origen = 'import_csv'
   and r.fecha = current_date;

insert into public.producto_precios_referencia
  (producto_id, fuente, tipo, precio, sku_externo, origen, notas)
select p.id, 'medik8', 'compra', t.costo, t.sku, 'import_csv',
       'Medik8 especialistas 2025 · Dermatotec · RRP ' || t.precio::text
         || coalesce(' · ' || nullif(t.gama, ''), '')
  from public._fc_medik8_stg t
  join public.productos p on p.sku = t.sku;

drop table if exists public._fc_medik8_stg;

commit;

select count(*) as medik8_productos
from public.productos
where marca ilike 'medik8';
