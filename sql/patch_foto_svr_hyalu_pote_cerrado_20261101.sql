-- ============================================================================
-- HOTFIX: Hyalu Biotic — foto del pote cerrado (no el despiece refill)
-- 2026-11-01
-- Pegar TODO en Supabase → Run → Ctrl+Shift+R en el POS.
-- ============================================================================

begin;

update public.productos
set
  nombre = 'SVR Hyalu Biotic',
  presentacion = '50 ml',
  imagen_url =
    'https://cdn.shopify.com/s/files/1/0256/9021/0376/files/1.7-Biotic-Hyalu-1031416-SVR-Soinhydratantintensifal_acidehyaluronique_7aa08e2b-01d8-438d-8e78-84fcf8bff115.jpg?v=1769783382',
  imagen_mobile_url =
    'https://cdn.shopify.com/s/files/1/0256/9021/0376/files/1.7-Biotic-Hyalu-1031416-SVR-Soinhydratantintensifal_acidehyaluronique_7aa08e2b-01d8-438d-8e78-84fcf8bff115.jpg?v=1769783382'
where codigo_barras = '3662361004300'
   or sku in ('FC-61004300', 'FC-ND-61004300');

insert into public.producto_imagenes
  (producto_id, url, storage_path, posicion, es_principal, origen)
select
  p.id,
  p.imagen_url,
  null,
  coalesce((select max(i.posicion) from public.producto_imagenes i where i.producto_id = p.id), 0) + 1,
  false,
  'distribuidor'
from public.productos p
where (p.codigo_barras = '3662361004300' or p.sku in ('FC-61004300', 'FC-ND-61004300'))
  and p.imagen_url is not null
  and not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id and i.url = p.imagen_url
  );

update public.producto_imagenes i
set es_principal = false
where i.producto_id in (
  select id from public.productos
  where codigo_barras = '3662361004300' or sku in ('FC-61004300', 'FC-ND-61004300')
);

update public.producto_imagenes i
set es_principal = true
from public.productos p
where i.producto_id = p.id
  and (p.codigo_barras = '3662361004300' or p.sku in ('FC-61004300', 'FC-ND-61004300'))
  and i.url = p.imagen_url;

commit;

select sku, nombre, presentacion, left(imagen_url, 100) as foto
from public.productos
where codigo_barras = '3662361004300' or sku in ('FC-61004300', 'FC-ND-61004300');
