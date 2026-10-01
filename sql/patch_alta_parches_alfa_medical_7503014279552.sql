-- ============================================================================
-- Parches adhesivos Alfa Medical blancos C/10 · EAN 7503014279552
--
-- Caja con 10 parches, 2 tamaños (4 de 10×10 cm + 6 de 6×8 cm).
-- Hipoalergénicos · absorbentes · no se pegan a la herida.
-- Ficha: tienda.alfa-medical.com.mx + EAN de caja (foto mostrador).
--
-- Ya estaba en staging Nadro 20260901 (FC-14279552 · costo 53.15 · PVP 71)
-- pero no aparece en producción → este patch lo crea o completa la ficha.
--
-- SKU canónico: FC- + últimos 8 del EAN = FC-14279552
-- Costo Nadro $53.15 · tipo marca → PVP ceil(53.15×1.25) = $67
-- Stock 0 hasta Recibir. Sin inventar lote ni caducidad.
--
-- NO hay EAN de fábrica por tamaño (solo esta caja mixta).
-- Para vender por pieza grande/chica tras abrir caja, corre también:
--   sql/patch_alta_parches_alfa_piezas_tamanos.sql
--
-- Foto: public/catalogo-propia/parches-adhesivos-alfa-medical-blancos-c10.jpg
--       packshot Mercadofarma / caja oficial.
--       jsDelivr del commit (inmediato) + /catalogo-propia/ tras deploy.
-- Pegar TODO en Supabase → SQL Editor → Run.
-- ============================================================================

begin;

insert into public.productos (
  nombre, sku, codigo_barras, categoria, subcategoria, tipo, descripcion,
  marca, presentacion, forma_farmaceutica,
  costo, precio, imagen_url, imagen_mobile_url,
  stock, stock_minimo, activo, requiere_receta,
  disponible, visible_tienda
)
select
  'Parches adhesivos blancos',
  case
    when exists (
      select 1 from public.productos p
      where p.sku = 'FC-14279552'
        and coalesce(p.codigo_barras, '') <> '7503014279552'
    ) then 'FC-ND-14279552'
    else 'FC-14279552'
  end,
  '7503014279552',
  'Botiquín',
  'Material de curación',
  'marca',
  'Parches adhesivos hipoalergénicos Alfa Medical · 2 tamaños · no se pegan a la herida · EAN 7503014279552 · listo para pistola',
  'Alfa Medical',
  '10 parches (4 de 10×10 cm + 6 de 6×8 cm)',
  'Parche adhesivo',
  53.15,
  67,
  'https://cdn.jsdelivr.net/gh/ibarraivane/farmacapital@448a72d6/public/catalogo-propia/parches-adhesivos-alfa-medical-blancos-c10.jpg',
  'https://cdn.jsdelivr.net/gh/ibarraivane/farmacapital@448a72d6/public/catalogo-propia/parches-adhesivos-alfa-medical-blancos-c10.jpg',
  0,
  1,
  true,
  false,
  'inmediato',
  true
where public.fc_buscar_producto_escaneo('7503014279552') is null
  and not exists (
    select 1 from public.productos p
    where p.codigo_barras = '7503014279552'
       or p.sku in ('FC-14279552', 'FC-ND-14279552')
  );

-- Si ya existía (Nadro u otro): completar ficha sin pisar costo/PVP/stock/foto buena.
update public.productos p
set
  nombre = 'Parches adhesivos blancos',
  marca = 'Alfa Medical',
  presentacion = coalesce(
    nullif(btrim(p.presentacion), ''),
    '10 parches (4 de 10×10 cm + 6 de 6×8 cm)'
  ),
  forma_farmaceutica = coalesce(
    nullif(btrim(p.forma_farmaceutica), ''),
    'Parche adhesivo'
  ),
  categoria = coalesce(nullif(btrim(p.categoria), ''), 'Botiquín'),
  subcategoria = coalesce(
    nullif(btrim(p.subcategoria), ''),
    'Material de curación'
  ),
  tipo = coalesce(nullif(btrim(p.tipo), ''), 'marca'),
  codigo_barras = coalesce(nullif(btrim(p.codigo_barras), ''), '7503014279552'),
  costo = case
    when coalesce(p.costo, 0) <= 0 then 53.15
    else p.costo
  end,
  precio = case
    when coalesce(p.precio, 0) <= 0 then 67
    else p.precio
  end,
  requiere_receta = false,
  activo = true,
  visible_tienda = true,
  disponible = coalesce(nullif(btrim(p.disponible), ''), 'inmediato'),
  descripcion = coalesce(
    nullif(btrim(p.descripcion), ''),
    'Parches adhesivos hipoalergénicos Alfa Medical · 2 tamaños · no se pegan a la herida · EAN 7503014279552 · listo para pistola'
  ),
  imagen_url = coalesce(
    nullif(btrim(p.imagen_url), ''),
    'https://cdn.jsdelivr.net/gh/ibarraivane/farmacapital@448a72d6/public/catalogo-propia/parches-adhesivos-alfa-medical-blancos-c10.jpg'
  ),
  imagen_mobile_url = coalesce(
    nullif(btrim(p.imagen_mobile_url), ''),
    'https://cdn.jsdelivr.net/gh/ibarraivane/farmacapital@448a72d6/public/catalogo-propia/parches-adhesivos-alfa-medical-blancos-c10.jpg'
  )
where p.codigo_barras = '7503014279552'
   or p.sku in ('FC-14279552', 'FC-ND-14279552');

insert into public.producto_imagenes (
  producto_id, url, storage_path, posicion, es_principal, origen
)
select
  p.id,
  'https://cdn.jsdelivr.net/gh/ibarraivane/farmacapital@448a72d6/public/catalogo-propia/parches-adhesivos-alfa-medical-blancos-c10.jpg',
  'catalogo-propia/parches-adhesivos-alfa-medical-blancos-c10.jpg',
  1,
  true,
  'distribuidor'
from public.productos p
where (p.codigo_barras = '7503014279552' or p.sku in ('FC-14279552', 'FC-ND-14279552'))
  and not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id
      and i.url like '%parches-adhesivos-alfa-medical-blancos-c10%'
  );

commit;

select
  p.id,
  p.sku,
  p.codigo_barras as ean,
  p.nombre,
  p.marca,
  p.presentacion,
  p.categoria,
  p.subcategoria,
  p.forma_farmaceutica,
  p.tipo,
  p.costo,
  p.precio,
  p.stock,
  p.activo,
  left(p.imagen_url, 96) as foto
from public.productos p
where p.codigo_barras = '7503014279552'
   or p.sku in ('FC-14279552', 'FC-ND-14279552')
order by p.sku;
