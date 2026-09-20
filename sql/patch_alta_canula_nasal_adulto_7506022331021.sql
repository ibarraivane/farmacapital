-- ============================================================================
-- Cánula nasal para oxígeno adulto · EAN 7506022331021
--
-- Misma ficha que la pediátrica ya en catálogo:
--   EQ-JAY253 · 7506022331038 · Cánula nasal para oxígeno pediátrica
--   Dispositivos / Oxígeno / Dispositivo / genérico
--   Pieza, puntas nasales · PVP $25 · costo Equilibrio $17.54
--
-- El adulto Equilibrio 444836 ya existe como EQ-JAY267
-- ("Puntas nasales para oxígeno adulto") SIN código de barras.
-- Este patch le pega el EAN y alinea el nombre. No duplica stock.
--
-- Si EQ-JAY267 no existiera: inserta FC-23331021 (últimos 8 del EAN),
-- stock 0, sin inventar lote ni caducidad.
--
-- Foto: public/catalogo-propia/canula-nasal-adulto-2-mm-x-1-80-m-sensi-medical.jpg
--       packshot Promexsa Sensi Medical (2 mm × 1.80 m). Correr DESPUÉS
--       del deploy, o la URL jsDelivr del commit de esta rama.
-- Pegar TODO en Supabase → SQL Editor → Run.
-- ============================================================================

begin;

-- 1) Adulto Equilibrio sin EAN: pegar código y alinear ficha con la infantil.
update public.productos p
set
  codigo_barras = '7506022331021',
  nombre = 'Cánula nasal para oxígeno adulto',
  categoria = 'Dispositivos',
  subcategoria = 'Oxígeno',
  forma_farmaceutica = 'Dispositivo',
  tipo = 'generico',
  presentacion = 'Pieza, puntas nasales adulto',
  disponible = 'inmediato',
  visible_tienda = true,
  requiere_receta = false,
  activo = true,
  descripcion = coalesce(
    nullif(btrim(p.descripcion), ''),
    'Alta Equilibrio 444836 · hermano de EQ-JAY253 pediátrica · EAN 7506022331021 · listo para pistola'
  ),
  imagen_url = coalesce(
    nullif(btrim(p.imagen_url), ''),
    'https://www.farmacapital.mx/catalogo-propia/canula-nasal-adulto-2-mm-x-1-80-m-sensi-medical.jpg'
  ),
  imagen_mobile_url = coalesce(
    nullif(btrim(p.imagen_mobile_url), ''),
    'https://www.farmacapital.mx/catalogo-propia/canula-nasal-adulto-2-mm-x-1-80-m-sensi-medical.jpg'
  )
where p.sku = 'EQ-JAY267'
  and (p.codigo_barras is null or btrim(p.codigo_barras) = '')
  and public.fc_buscar_producto_escaneo('7506022331021') is null
  and not exists (
    select 1 from public.productos o
    where o.codigo_barras = '7506022331021'
      and o.id <> p.id
  );

-- 2) Si no hay adulto ni este EAN: alta canónica FC- + últimos 8.
insert into public.productos (
  nombre, sku, codigo_barras, categoria, subcategoria, tipo, descripcion,
  marca, presentacion, forma_farmaceutica,
  costo, precio, imagen_url, imagen_mobile_url,
  stock, stock_minimo, activo, requiere_receta,
  disponible, visible_tienda
)
select
  'Cánula nasal para oxígeno adulto',
  'FC-23331021',
  '7506022331021',
  'Dispositivos',
  'Oxígeno',
  'generico',
  'Hermano de EQ-JAY253 pediátrica · EAN 7506022331021 · listo para pistola',
  inf.marca,
  'Pieza, puntas nasales adulto',
  'Dispositivo',
  coalesce(inf.costo, 17.54),
  coalesce(inf.precio, 25),
  'https://www.farmacapital.mx/catalogo-propia/canula-nasal-adulto-2-mm-x-1-80-m-sensi-medical.jpg',
  'https://www.farmacapital.mx/catalogo-propia/canula-nasal-adulto-2-mm-x-1-80-m-sensi-medical.jpg',
  0,
  1,
  true,
  false,
  'inmediato',
  true
from (
  select p.marca, p.costo, p.precio
  from public.productos p
  where p.sku = 'EQ-JAY253'
     or p.codigo_barras = '7506022331038'
  order by case when p.sku = 'EQ-JAY253' then 0 else 1 end
  limit 1
) inf
where public.fc_buscar_producto_escaneo('7506022331021') is null
  and public.fc_buscar_producto_escaneo('FC-23331021') is null
  and not exists (
    select 1 from public.productos p
    where p.codigo_barras = '7506022331021'
       or p.sku in ('FC-23331021', 'EQ-JAY267')
  );

-- Si la infantil aún no está (borde): insertar con los mismos números.
insert into public.productos (
  nombre, sku, codigo_barras, categoria, subcategoria, tipo, descripcion,
  presentacion, forma_farmaceutica,
  costo, precio, imagen_url, imagen_mobile_url,
  stock, stock_minimo, activo, requiere_receta,
  disponible, visible_tienda
)
select
  'Cánula nasal para oxígeno adulto',
  'FC-23331021',
  '7506022331021',
  'Dispositivos',
  'Oxígeno',
  'generico',
  'Hermano de la cánula nasal pediátrica · EAN 7506022331021 · listo para pistola',
  'Pieza, puntas nasales adulto',
  'Dispositivo',
  17.54,
  25,
  'https://www.farmacapital.mx/catalogo-propia/canula-nasal-adulto-2-mm-x-1-80-m-sensi-medical.jpg',
  'https://www.farmacapital.mx/catalogo-propia/canula-nasal-adulto-2-mm-x-1-80-m-sensi-medical.jpg',
  0,
  1,
  true,
  false,
  'inmediato',
  true
where public.fc_buscar_producto_escaneo('7506022331021') is null
  and not exists (
    select 1 from public.productos p
    where p.codigo_barras = '7506022331021'
       or p.sku in ('FC-23331021', 'EQ-JAY267')
  );

-- 3) Completar huecos sin pisar costo / PVP / stock / foto buena.
update public.productos p
set
  nombre = 'Cánula nasal para oxígeno adulto',
  categoria = coalesce(nullif(btrim(p.categoria), ''), 'Dispositivos'),
  subcategoria = coalesce(nullif(btrim(p.subcategoria), ''), 'Oxígeno'),
  forma_farmaceutica = coalesce(nullif(btrim(p.forma_farmaceutica), ''), 'Dispositivo'),
  tipo = coalesce(nullif(btrim(p.tipo), ''), 'generico'),
  presentacion = coalesce(nullif(btrim(p.presentacion), ''), 'Pieza, puntas nasales adulto'),
  codigo_barras = coalesce(nullif(btrim(p.codigo_barras), ''), '7506022331021'),
  requiere_receta = false,
  activo = true,
  visible_tienda = true,
  disponible = coalesce(nullif(btrim(p.disponible), ''), 'inmediato'),
  imagen_url = coalesce(
    nullif(btrim(p.imagen_url), ''),
    'https://www.farmacapital.mx/catalogo-propia/canula-nasal-adulto-2-mm-x-1-80-m-sensi-medical.jpg'
  ),
  imagen_mobile_url = coalesce(
    nullif(btrim(p.imagen_mobile_url), ''),
    'https://www.farmacapital.mx/catalogo-propia/canula-nasal-adulto-2-mm-x-1-80-m-sensi-medical.jpg'
  )
where p.codigo_barras = '7506022331021'
   or p.sku in ('EQ-JAY267', 'FC-23331021');

insert into public.producto_imagenes (
  producto_id, url, storage_path, posicion, es_principal, origen
)
select
  p.id,
  'https://www.farmacapital.mx/catalogo-propia/canula-nasal-adulto-2-mm-x-1-80-m-sensi-medical.jpg',
  'catalogo-propia/canula-nasal-adulto-2-mm-x-1-80-m-sensi-medical.jpg',
  1,
  true,
  'distribuidor'
from public.productos p
where (p.codigo_barras = '7506022331021' or p.sku in ('EQ-JAY267', 'FC-23331021'))
  and not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id
      and i.url like '%canula-nasal-adulto-2-mm-x-1-80-m-sensi-medical%'
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
  left(p.imagen_url, 96) as foto
from public.productos p
where p.codigo_barras in ('7506022331021', '7506022331038')
   or p.sku in ('EQ-JAY267', 'EQ-JAY253', 'FC-23331021')
order by p.sku;
