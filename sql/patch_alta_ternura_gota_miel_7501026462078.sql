-- ============================================================================
-- Alta Ternura chupón Gota de Miel · EAN 7501026462078
--
-- Recibir Bodega F-42 / Citymark 76370: «1 producto sin registrar en catálogo».
-- Ficha de la caja (bebé ternura / W.A. Carter): Chupón Gota de Miel, 0% BPA,
-- bulbo látex hipoalergénico. Ticket: TERNURA FLOR-BALON 18 PZS CHUPON CON MIEL.
--
-- SKU FC-26462078 (últimos 8 del EAN). Costo ticket $61.02 · PVP $77 (+25% marca).
-- Stock 0 hasta pistola + MMAA de la caja. No inventar 0000.
-- SIN do $$. Idempotente. Pegar TODO en Supabase → SQL Editor → Run.
-- Foto tras deploy: https://www.farmacapital.mx/catalogo-propia/ternura-chupon-gota-miel-18-7501026462078.jpg
-- ============================================================================

begin;

insert into public.productos (
  nombre, sku, codigo_barras, categoria, subcategoria, tipo, descripcion,
  costo, precio, stock, stock_minimo, activo, requiere_receta,
  marca, presentacion, forma_farmaceutica, laboratorio,
  imagen_url, imagen_mobile_url
)
select
  'Ternura chupón Gota de Miel',
  case
    when exists (
      select 1 from public.productos p
      where p.sku = 'FC-26462078'
        and coalesce(p.codigo_barras, '') is distinct from '7501026462078'
    ) then 'FC-ND-26462078'
    else 'FC-26462078'
  end,
  '7501026462078',
  'Cuidado personal',
  'Bebé',
  'marca',
  'Alta Recibir Bodega F-42 76370 · Chupón Gota de Miel · W.A. Carter · 0% BPA · látex hipoalergénico · exhibidor 18 pzas · listo para pistola',
  61.02,
  77,
  0,
  1,
  true,
  false,
  'Ternura',
  'Exhibidor con 18 piezas',
  'Chupón',
  'W.A. Carter',
  'https://www.farmacapital.mx/catalogo-propia/ternura-chupon-gota-miel-18-7501026462078.jpg',
  'https://www.farmacapital.mx/catalogo-propia/ternura-chupon-gota-miel-18-7501026462078.jpg'
where public.fc_buscar_producto_escaneo('7501026462078') is null
  and public.fc_buscar_producto_escaneo('FC-26462078') is null
  and not exists (
    select 1 from public.productos p
    where p.codigo_barras = '7501026462078' or p.sku in ('FC-26462078', 'FC-ND-26462078')
  );

-- Completar ficha si ya existía a medias
update public.productos p
set
  nombre = 'Ternura chupón Gota de Miel',
  marca = coalesce(nullif(trim(p.marca), ''), 'Ternura'),
  laboratorio = coalesce(nullif(trim(p.laboratorio), ''), 'W.A. Carter'),
  presentacion = coalesce(nullif(trim(p.presentacion), ''), 'Exhibidor con 18 piezas'),
  forma_farmaceutica = coalesce(nullif(trim(p.forma_farmaceutica), ''), 'Chupón'),
  categoria = coalesce(nullif(trim(p.categoria), ''), 'Cuidado personal'),
  subcategoria = coalesce(nullif(trim(p.subcategoria), ''), 'Bebé'),
  tipo = coalesce(nullif(trim(p.tipo), ''), 'marca'),
  codigo_barras = '7501026462078',
  costo = case when coalesce(p.costo, 0) <= 0.01 then 61.02 else p.costo end,
  precio = case when coalesce(p.precio, 0) <= 1 then 77 else p.precio end,
  imagen_url = coalesce(nullif(trim(p.imagen_url), ''),
    'https://www.farmacapital.mx/catalogo-propia/ternura-chupon-gota-miel-18-7501026462078.jpg'),
  imagen_mobile_url = coalesce(nullif(trim(p.imagen_mobile_url), ''),
    'https://www.farmacapital.mx/catalogo-propia/ternura-chupon-gota-miel-18-7501026462078.jpg'),
  activo = true,
  stock_minimo = greatest(coalesce(p.stock_minimo, 0), 1)
where p.id = public.fc_buscar_producto_escaneo('7501026462078')
   or p.sku in ('FC-26462078', 'FC-ND-26462078');

-- Enlazar renglones grises de Recibir (ticket 76370 u otros con este EAN)
update public.recepcion_items i
set
  producto_id = public.fc_buscar_producto_escaneo('7501026462078'),
  pendiente_alta = false,
  nombre_snapshot = coalesce(nullif(btrim(i.nombre_snapshot), ''), 'TERNURA FLOR-BALON 18 PZS CHUPON CON MIEL'),
  costo_estimado = coalesce(i.costo_estimado, 61.02)
where i.producto_id is null
  and coalesce(i.pendiente_alta, true)
  and (
    coalesce(i.codigo_escaneado, '') = '7501026462078'
    or i.nombre_snapshot ilike '%TERNURA%FLOR%BALON%'
    or i.nombre_snapshot ilike '%TERNURA%GOTA%MIEL%'
  )
  and public.fc_buscar_producto_escaneo('7501026462078') is not null;

commit;

select
  p.id,
  p.sku,
  p.codigo_barras as ean,
  p.nombre,
  p.marca,
  p.presentacion,
  p.laboratorio,
  p.costo,
  p.precio,
  p.stock,
  p.imagen_url
from public.productos p
where p.codigo_barras = '7501026462078'
   or p.sku in ('FC-26462078', 'FC-ND-26462078');
