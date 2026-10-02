-- ============================================================================
-- FARMACAPITAL — Alta foto mostrador 02-oct-2026
--
-- No aparecen al escanear (foto pistola / caja):
--
-- 1) Ricitos de Oro Bio-Pure jabón de tocador para bebé 90 g
--    UPC-A de la caja: 037836050725 (0 37836 05072 5)
--    Distinto del Neutro 7501022150221 (FC-22150221) y del shampoo
--    Bio-Pure 250 ml 037836032776 (FC-36032776).
--    Ficha: BuscaMed / Vitau / El Cisne · Grisi · hipoalergénico.
--    PVP ancla Vitau $31 · sin costo de compra (foto, no ticket).
--
-- 2) Colgate Total Prevención Activa Encías Saludables enjuague 250 ml
--    EAN-13 del frasco: 7509546666969 (7 509546 666969)
--    Zero alcohol · bilingüe PT/ES · packshot DelSol.
--    Distinto del enjuague Total 60 ml ya en catálogo.
--    PVP ancla DelSol $89.90 · Fahorro lista ~$102 · sin costo.
--
-- Stock 0 hasta Recibir. No inventar lote ni caducidad.
-- SKUs: FC- + últimos 8 del EAN. Si el SKU ya es de otro EAN → FC-ND-.
--
-- Fotos en public/catalogo-propia/ (van con el deploy):
--   ricitos-de-oro-bio-pure-jabon-90g-037836050725.jpg
--   colgate-total-encias-prevencion-activa-250ml-7509546666969.jpg
-- ORDEN: 1) merge/deploy  2) pegar este SQL en Supabase → Run.
-- SIN do $$. Pegar TODO.
-- ============================================================================

begin;

-- ---------------------------------------------------------------------------
-- 1) Ricitos de Oro Bio-Pure jabón 90 g · 037836050725
-- ---------------------------------------------------------------------------
insert into public.productos (
  nombre, sku, codigo_barras, categoria, subcategoria, tipo, descripcion,
  marca, presentacion, forma_farmaceutica, laboratorio,
  costo, precio, imagen_url, imagen_mobile_url,
  stock, stock_minimo, activo, requiere_receta
)
select
  'Ricitos de Oro Bio-Pure',
  case
    when exists (
      select 1 from public.productos p
      where p.sku = 'FC-36050725'
        and coalesce(p.codigo_barras, '') <> '037836050725'
    ) then 'FC-ND-36050725'
    else 'FC-36050725'
  end,
  '037836050725',
  'Bebés',
  'Higiene bebé',
  'marca',
  'Alta foto mostrador 2026-10-02 · Grisi Ricitos de Oro Bio-Pure jabón de tocador para bebé · hipoalergénico · extracto de uva verde · UPC 037836050725 · PVP ancla Vitau 31 · sin costo de compra',
  'Ricitos de Oro',
  '90 g',
  'Jabón',
  'GRISI',
  null,
  31,
  'https://www.farmacapital.mx/catalogo-propia/ricitos-de-oro-bio-pure-jabon-90g-037836050725.jpg',
  'https://www.farmacapital.mx/catalogo-propia/ricitos-de-oro-bio-pure-jabon-90g-037836050725.jpg',
  0,
  1,
  true,
  false
where public.fc_buscar_producto_escaneo('037836050725') is null
  and not exists (
    select 1 from public.productos p
    where p.codigo_barras in ('037836050725', '0037836050725', '37836050725')
  )
  and not exists (
    select 1 from public.productos p
    where p.sku = case
      when exists (
        select 1 from public.productos x
        where x.sku = 'FC-36050725'
          and coalesce(x.codigo_barras, '') <> '037836050725'
      ) then 'FC-ND-36050725'
      else 'FC-36050725'
    end
  );

insert into public.producto_imagenes (
  producto_id, url, storage_path, posicion, es_principal, origen
)
select
  p.id,
  'https://www.farmacapital.mx/catalogo-propia/ricitos-de-oro-bio-pure-jabon-90g-037836050725.jpg',
  'catalogo-propia/ricitos-de-oro-bio-pure-jabon-90g-037836050725.jpg',
  0,
  true,
  'propia'
from public.productos p
where (p.codigo_barras = '037836050725' or p.sku in ('FC-36050725', 'FC-ND-36050725'))
  and not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id
      and i.url like '%ricitos-de-oro-bio-pure-jabon-90g-037836050725%'
  );

-- ---------------------------------------------------------------------------
-- 2) Colgate Total Prevención Activa Encías Saludables 250 ml · 7509546666969
-- ---------------------------------------------------------------------------
insert into public.productos (
  nombre, sku, codigo_barras, categoria, subcategoria, tipo, descripcion,
  marca, presentacion, forma_farmaceutica, laboratorio,
  costo, precio, imagen_url, imagen_mobile_url,
  stock, stock_minimo, activo, requiere_receta
)
select
  'Colgate Total Prevención Activa Encías Saludables',
  case
    when exists (
      select 1 from public.productos p
      where p.sku = 'FC-46666969'
        and coalesce(p.codigo_barras, '') <> '7509546666969'
    ) then 'FC-ND-46666969'
    else 'FC-46666969'
  end,
  '7509546666969',
  'Higiene',
  'Higiene bucal',
  'marca',
  'Alta foto mostrador 2026-10-02 · Colgate Total Prevención Activa Encías Saludables enjuague bucal 250 ml · zero alcohol · EAN 7509546666969 · PVP ancla DelSol 89.90 · sin costo de compra',
  'Colgate',
  '250 ml',
  'Enjuague bucal',
  'COLGATE-PALMOLIVE',
  null,
  90,
  'https://www.farmacapital.mx/catalogo-propia/colgate-total-encias-prevencion-activa-250ml-7509546666969.jpg',
  'https://www.farmacapital.mx/catalogo-propia/colgate-total-encias-prevencion-activa-250ml-7509546666969.jpg',
  0,
  1,
  true,
  false
where public.fc_buscar_producto_escaneo('7509546666969') is null
  and not exists (
    select 1 from public.productos p
    where p.codigo_barras = '7509546666969'
  )
  and not exists (
    select 1 from public.productos p
    where p.sku = case
      when exists (
        select 1 from public.productos x
        where x.sku = 'FC-46666969'
          and coalesce(x.codigo_barras, '') <> '7509546666969'
      ) then 'FC-ND-46666969'
      else 'FC-46666969'
    end
  );

insert into public.producto_imagenes (
  producto_id, url, storage_path, posicion, es_principal, origen
)
select
  p.id,
  'https://www.farmacapital.mx/catalogo-propia/colgate-total-encias-prevencion-activa-250ml-7509546666969.jpg',
  'catalogo-propia/colgate-total-encias-prevencion-activa-250ml-7509546666969.jpg',
  0,
  true,
  'propia'
from public.productos p
where (p.codigo_barras = '7509546666969' or p.sku in ('FC-46666969', 'FC-ND-46666969'))
  and not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id
      and i.url like '%colgate-total-encias-prevencion-activa-250ml-7509546666969%'
  );

commit;

select
  p.id,
  p.sku,
  p.codigo_barras as ean,
  p.nombre,
  p.marca,
  p.presentacion,
  p.forma_farmaceutica,
  p.costo,
  p.precio,
  p.stock,
  p.categoria,
  p.activo,
  left(p.imagen_url, 90) as foto
from public.productos p
where p.codigo_barras in ('037836050725', '7509546666969')
   or p.sku in (
     'FC-36050725', 'FC-ND-36050725',
     'FC-46666969', 'FC-ND-46666969'
   )
order by p.codigo_barras, p.sku;
