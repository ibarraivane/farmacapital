-- =============================================================================
-- PEGAR TODO ESTE ARCHIVO en Supabase → SQL Editor → Run
-- Corrige EANs / fichas mal mapeados (fotos de la caja 04-nov-2026).
--
-- Sahuayo 432467:
--   Huggies: ticket decía E5 Niño → caja E4 Unisex 36 · EAN 7501943441767
--   Saba Buenas Noches: EAN malo 7501019006609 → 7501019070532
--   Kotex: ticket Anatómica → caja Regular con alas · EAN 7501943424562
--
-- Farma Mayoreo V01000002384:
--   Ticket decía roll-on → caja Nuvel Softy spray 170 ml · 7501082731064
--   Ticket decía roll-on Aclarado → caja Aclarado Ideal spray 150 ml · 7501082736021
--
-- Caducidad null (MMAA de la caja). Sin dollar-quote. Idempotente en borrador.
-- =============================================================================

begin;

create temp table _fc_fix_ean (
  ticket text not null,
  ean_malo text,
  ean_bueno text not null,
  sku text not null,
  nombre text not null,
  snap text,
  qty integer,
  costo numeric(12,2),
  precio numeric(12,2) not null,
  tipo text not null,
  categoria text not null,
  subcategoria text,
  forma text,
  marca text,
  laboratorio text,
  presentacion text,
  principio_activo text,
  concentracion text,
  receta boolean not null default false,
  imagen text,
  primary key (ticket, ean_bueno)
) on commit drop;

insert into _fc_fix_ean (
  ticket, ean_malo, ean_bueno, sku, nombre, snap, qty, costo, precio, tipo,
  categoria, subcategoria, forma, marca, laboratorio, presentacion,
  principio_activo, concentracion, receta, imagen
) values
  (
    'sahuayo', '7501943441804', '7501943441767', 'FC-43441767',
    'Huggies Supreme etapa 4 Unisex',
    'PZA.HUGGIE SU E5 NIÑO5X36 1/36',
    1, 314.37, 393, 'marca', 'Bebés', 'Pañales', null, 'Huggies', 'Kimberly-Clark',
    'Bolsa con 36 pañales etapa 4 (9 a 12 kg) unisex', null, null, false,
    'https://www.farmacapital.mx/catalogo-propia/huggies-supreme-e4-unisex-36-7501943441767.jpg'
  ),
  (
    'sahuayo', '7501019006609', '7501019070532', 'FC-01907053',
    'Saba Buenas Noches',
    'PZA.SABA BUENAS NOCHES 1/10 UN',
    2, 21.35, 27, 'marca', 'Higiene', 'Toallas femeninas', null, 'Saba', 'Essity',
    'Paquete con 10 toallas nocturnas extra largas con alas', null, null, false,
    'https://www.farmacapital.mx/catalogo-propia/saba-buenas-noches-10-7501019070532.jpg'
  ),
  (
    'sahuayo', '7501943424623', '7501943424562', 'FC-43424562',
    'Kotex Regular con alas',
    'PZA.KOTEX ANATOMICA C/A 1/10 U',
    2, 14.69, 19, 'marca', 'Higiene', 'Toallas femeninas', null, 'Kotex', 'Kimberly-Clark',
    'Paquete con 10 toallas regular con alas', null, null, false,
    'https://www.farmacapital.mx/catalogo-propia/kotex-regular-alas-10-7501943424562.jpg'
  ),
  (
    'farmamayoreo', '7501082731323', '7501082731064', 'FC-82731064',
    'Nuvel Softy antitranspirante',
    'DESODORANTE NUVEL ANTITRANSPIRANTE BEAUTY ROLL-ON 55 ML',
    4, 11.96, 15, 'marca', 'Cuidado personal', 'Desodorante', 'Spray', 'Nuvel', 'Lavin',
    'Aerosol 170 ml', null, null, false,
    'https://www.farmacapital.mx/catalogo-propia/nuvel-softy-spray-170ml-7501082731064.jpg'
  ),
  (
    'farmamayoreo', '7501082730258', '7501082736021', 'FC-82736021',
    'Nuvel Aclarado Ideal antitranspirante',
    'DESODORANTE NUVEL ANTITRANSPIRANTE ACLARADO IDEAL ROLL-ON 50 ML',
    8, 16.96, 22, 'marca', 'Cuidado personal', 'Desodorante', 'Spray', 'Nuvel', 'Lavin',
    'Aerosol 150 ml', null, null, false,
    'https://www.farmacapital.mx/catalogo-propia/nuvel-aclarado-ideal-spray-150ml-7501082736021.jpg'
  );

-- Altas correctas si no existen
insert into public.productos (
  nombre, sku, codigo_barras, categoria, subcategoria, tipo, descripcion,
  costo, precio, stock, stock_minimo, activo, requiere_receta,
  marca, presentacion, forma_farmaceutica, principio_activo, concentracion,
  laboratorio, imagen_url, imagen_mobile_url
)
select
  t.nombre,
  case
    when exists (
      select 1 from public.productos p
      where p.sku = t.sku and coalesce(p.codigo_barras, '') <> t.ean_bueno
    ) then 'FC-ND-' || right(t.ean_bueno, 8)
    else t.sku
  end,
  t.ean_bueno,
  t.categoria,
  t.subcategoria,
  t.tipo,
  'Corrección EAN caja 04-nov-2026 · listo para pistola',
  t.costo,
  t.precio,
  0,
  1,
  true,
  t.receta,
  t.marca,
  t.presentacion,
  t.forma,
  t.principio_activo,
  t.concentracion,
  t.laboratorio,
  t.imagen,
  t.imagen
from _fc_fix_ean t
where public.fc_buscar_producto_escaneo(t.ean_bueno) is null
  and public.fc_buscar_producto_escaneo(t.sku) is null;

-- Ya existían: costo / PVP solo si 0 / ficha vacía / foto si falta
update public.productos p
set
  costo = coalesce(t.costo, p.costo),
  precio = case when coalesce(p.precio, 0) <= 0 then t.precio else p.precio end,
  nombre = case
    when length(trim(coalesce(p.nombre, ''))) < 8 then t.nombre
    when p.nombre ilike '%etapa 5%' and t.ean_bueno = '7501943441767' then t.nombre
    when p.nombre ilike '%anat_mica%' and t.ean_bueno = '7501943424562' then t.nombre
    when p.nombre ilike '%roll%on%' and t.ean_bueno in ('7501082731064', '7501082736021') then t.nombre
    else p.nombre
  end,
  marca = coalesce(nullif(trim(p.marca), ''), t.marca),
  presentacion = coalesce(nullif(trim(p.presentacion), ''), t.presentacion),
  forma_farmaceutica = coalesce(nullif(trim(p.forma_farmaceutica), ''), t.forma),
  laboratorio = coalesce(nullif(trim(p.laboratorio), ''), t.laboratorio),
  subcategoria = coalesce(nullif(trim(p.subcategoria), ''), t.subcategoria),
  imagen_url = coalesce(nullif(trim(p.imagen_url), ''), t.imagen),
  imagen_mobile_url = coalesce(nullif(trim(p.imagen_mobile_url), ''), t.imagen),
  codigo_barras = coalesce(nullif(trim(p.codigo_barras), ''), t.ean_bueno)
from _fc_fix_ean t
where p.id = coalesce(
  public.fc_buscar_producto_escaneo(t.ean_bueno),
  public.fc_buscar_producto_escaneo(t.sku)
);

-- Si el alta errónea (EAN malo) sigue sin stock y solo sirve este ticket,
-- reescribe el código de barras al bueno cuando el SKU coincide con el malo.
update public.productos p
set
  codigo_barras = t.ean_bueno,
  nombre = t.nombre,
  presentacion = t.presentacion,
  forma_farmaceutica = coalesce(t.forma, p.forma_farmaceutica),
  imagen_url = coalesce(t.imagen, p.imagen_url),
  imagen_mobile_url = coalesce(t.imagen, p.imagen_mobile_url),
  updated_at = now()
from _fc_fix_ean t
where p.codigo_barras = t.ean_malo
  and coalesce(p.stock, 0) = 0
  and public.fc_buscar_producto_escaneo(t.ean_bueno) is null;

-- ---------- Sahuayo 432467: re-ligar renglones ----------
update public.recepcion_items i
set
  codigo_escaneado = t.ean_bueno,
  nombre_snapshot = t.nombre,
  producto_id = coalesce(
    public.fc_buscar_producto_escaneo(t.ean_bueno),
    public.fc_buscar_producto_escaneo(t.sku)
  ),
  pendiente_alta = (
    coalesce(
      public.fc_buscar_producto_escaneo(t.ean_bueno),
      public.fc_buscar_producto_escaneo(t.sku)
    ) is null
  )
from public.recepciones r
join _fc_fix_ean t on t.ticket = 'sahuayo'
where i.recepcion_id = r.id
  and r.folio = '432467'
  and coalesce(r.proveedor, '') ilike '%sahuayo%'
  and r.estado = 'borrador'
  and (
    i.codigo_escaneado = t.ean_malo
    or (t.snap is not null and i.nombre_snapshot = t.snap)
    or (t.ean_malo = '7501943441804' and i.nombre_snapshot ilike '%huggie%')
    or (t.ean_malo = '7501019006609' and i.nombre_snapshot ilike '%saba%buenas%')
    or (t.ean_malo = '7501943424623' and (
      i.nombre_snapshot ilike '%kotex%anat%'
      or i.nombre_snapshot ilike '%kotex%regular%'
    ))
  );

-- ---------- Farma Mayoreo V01000002384: re-ligar renglones ----------
update public.recepcion_items i
set
  codigo_escaneado = t.ean_bueno,
  nombre_snapshot = t.nombre,
  producto_id = coalesce(
    public.fc_buscar_producto_escaneo(t.ean_bueno),
    public.fc_buscar_producto_escaneo(t.sku)
  ),
  pendiente_alta = (
    coalesce(
      public.fc_buscar_producto_escaneo(t.ean_bueno),
      public.fc_buscar_producto_escaneo(t.sku)
    ) is null
  )
from public.recepciones r
join _fc_fix_ean t on t.ticket = 'farmamayoreo'
where i.recepcion_id = r.id
  and r.folio = 'V01000002384'
  and coalesce(r.proveedor, '') ilike '%farma mayoreo%'
  and r.estado = 'borrador'
  and (
    i.codigo_escaneado = t.ean_malo
    or (t.ean_malo = '7501082731323' and (
      i.nombre_snapshot ilike '%beauty%'
      or i.nombre_snapshot ilike '%softy%'
      or i.codigo_escaneado = '7501082731064'
    ))
    or (t.ean_malo = '7501082730258' and (
      i.nombre_snapshot ilike '%aclarado%'
      or i.nombre_snapshot ilike '%aclarante%'
      or i.codigo_escaneado = '7501082736021'
    ))
  );

-- Notas de corrección en tickets vivos
update public.recepciones
set
  notas = coalesce(notas, '') || ' · Corregido EAN caja: Huggies E4 7501943441767 · Saba 7501019070532 · Kotex Regular 7501943424562',
  updated_at = now()
where folio = '432467'
  and coalesce(proveedor, '') ilike '%sahuayo%'
  and estado = 'borrador'
  and coalesce(notas, '') not ilike '%Corregido EAN caja: Huggies%';

update public.recepciones
set
  notas = coalesce(notas, '') || ' · Corregido EAN caja: Nuvel Softy spray 7501082731064 · Aclarado Ideal spray 7501082736021 (no roll-on)',
  updated_at = now()
where folio = 'V01000002384'
  and coalesce(proveedor, '') ilike '%farma mayoreo%'
  and estado = 'borrador'
  and coalesce(notas, '') not ilike '%Corregido EAN caja: Nuvel Softy%';

-- VERIFICACION
select
  'sahuayo' as ticket,
  i.codigo_escaneado as ean,
  i.nombre_snapshot,
  i.cantidad,
  i.costo_estimado,
  case when i.producto_id is null then 'PENDIENTE_ALTA' else 'OK' end as match
from public.recepciones r
join public.recepcion_items i on i.recepcion_id = r.id
where r.folio = '432467'
  and coalesce(r.proveedor, '') ilike '%sahuayo%'
  and (
    i.codigo_escaneado in ('7501943441767', '7501019070532', '7501943424562',
                           '7501943441804', '7501019006609', '7501943424623')
    or i.nombre_snapshot ilike '%huggie%'
    or i.nombre_snapshot ilike '%saba%'
    or i.nombre_snapshot ilike '%kotex%'
  )
order by i.codigo_escaneado;

select
  'farmamayoreo' as ticket,
  i.codigo_escaneado as ean,
  i.nombre_snapshot,
  i.cantidad,
  i.costo_estimado,
  case when i.producto_id is null then 'PENDIENTE_ALTA' else 'OK' end as match
from public.recepciones r
join public.recepcion_items i on i.recepcion_id = r.id
where r.folio = 'V01000002384'
  and coalesce(r.proveedor, '') ilike '%farma mayoreo%'
order by i.codigo_escaneado;

select
  t.ean_bueno,
  t.sku,
  t.nombre,
  case
    when public.fc_buscar_producto_escaneo(t.ean_bueno) is null
      and public.fc_buscar_producto_escaneo(t.sku) is null
    then 'PENDIENTE_ALTA'
    else 'OK'
  end as catalogo
from _fc_fix_ean t
order by t.ticket, t.ean_bueno;

commit;
