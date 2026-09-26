-- ============================================================================
-- FARMA CAPITAL — Alta foto mostrador 24-sep-2026
--
-- KleenBebé Suavelastic Etapa 6 Extra Jumbo · bolsa 60 pañales · unisex
-- EAN-13 de la bolsa: 7501943414235
-- Clave impresa CLAVE 64342: código de anaquel Kimberly, no es el código de barras.
-- Peso en la bolsa y en la ficha del mismo EAN: 13.5 a 17 kg.
--
-- Sin costo de compra (foto, no ticket). PVP ancla Soriana $415
-- (mismo EAN, 60 piezas). No es costo de mayoreo ni recargo FarmaCapital.
-- Stock 0 hasta Recibir. La bolsa no trae lote ni caducidad: no se inventan.
--
-- NO confundir con las bolsas de 40 piezas (otro EAN, mayoreo).
--
-- SKU: FC-43414235 (últimos 8 del EAN).
-- Si ese SKU ya pertenece a otro EAN → FC-ND-43414235.
-- SIN do $$. Pegar TODO en Supabase → SQL Editor → Run.
-- Foto: después del deploy → patch_foto_kleenbebe_suavelastic_e6_60_20260924.sql
-- ============================================================================

begin;

insert into public.productos (
  nombre, sku, codigo_barras, categoria, tipo, descripcion,
  costo, precio, stock, stock_minimo, activo, requiere_receta,
  marca, presentacion, forma_farmaceutica, subcategoria
)
select
  'KleenBebé Suavelastic Etapa 6 Extra Jumbo',
  case
    when exists (
      select 1 from public.productos p
      where p.sku = 'FC-43414235'
        and coalesce(p.codigo_barras, '') <> '7501943414235'
    ) then 'FC-ND-43414235'
    else 'FC-43414235'
  end,
  '7501943414235',
  'Bebés',
  'marca',
  'Alta foto mostrador 2026-09-24 · Kimberly-Clark · EAN 7501943414235 · clave bolsa 64342 · unisex · 13.5 a 17 kg · PVP ancla Soriana 415 · sin costo de compra',
  null,
  415.00,
  0,
  1,
  true,
  false,
  'KleenBebé',
  'Bolsa con 60 pañales (13.5 a 17 kg)',
  'Pañal',
  'Pañales'
where public.fc_buscar_producto_escaneo('7501943414235') is null
  and not exists (
    select 1 from public.productos p
    where p.codigo_barras = '7501943414235'
  )
  and not exists (
    select 1 from public.productos p
    where p.sku = case
      when exists (
        select 1 from public.productos x
        where x.sku = 'FC-43414235'
          and coalesce(x.codigo_barras, '') <> '7501943414235'
      ) then 'FC-ND-43414235'
      else 'FC-43414235'
    end
  );

commit;

select
  p.id,
  p.sku,
  p.codigo_barras as ean,
  p.nombre,
  p.marca,
  p.presentacion,
  p.costo,
  p.precio,
  p.stock,
  p.categoria,
  p.subcategoria,
  p.activo
from public.productos p
where p.codigo_barras = '7501943414235'
   or p.sku in ('FC-43414235', 'FC-ND-43414235');
