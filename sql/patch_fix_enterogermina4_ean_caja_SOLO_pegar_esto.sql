-- =============================================================================
-- PEGAR TODO en Supabase → SQL Editor → Run
-- Corrige EANs de caja:
--   Enterogermina 4 billones → 7501165010826 (SKU FC-65010826)  Cityfarma 15341570
--   Arluy Duo 200/300 mg     → 7841141004051 (SKU FC-41004051)  Cityfarma 15341570
--   Naturella sin alas C/8   → 7506195158739 (SKU FC-95158739)  Surtidor 161443
-- Sin dollar-quote. Idempotente.
-- =============================================================================

begin;

-- ========== Enterogermina 4 billones ==========
update public.productos p
set
  codigo_barras = '7501165010826',
  sku = case
    when p.sku in ('FC-15010628', 'FC-65010628', 'FC-ND-65010628')
      and not exists (
        select 1 from public.productos p2
        where p2.sku = 'FC-65010826'
          and p2.id is distinct from p.id
      ) then 'FC-65010826'
    else p.sku
  end,
  nombre = case
    when length(trim(coalesce(p.nombre, ''))) < 8 then 'Enterogermina 4 billones'
    else p.nombre
  end,
  marca = coalesce(nullif(trim(p.marca), ''), 'Enterogermina'),
  presentacion = coalesce(nullif(trim(p.presentacion), ''), 'Caja con 10 ampolletas'),
  principio_activo = coalesce(nullif(trim(p.principio_activo), ''), 'Bacillus clausii'),
  concentracion = coalesce(nullif(trim(p.concentracion), ''), '4 billones UFC'),
  updated_at = now()
where p.codigo_barras = '7501165010628'
   or p.sku in ('FC-15010628', 'FC-65010628');

update public.recepcion_items i
set
  codigo_escaneado = '7501165010826',
  producto_id = coalesce(
    public.fc_buscar_producto_escaneo('7501165010826'),
    public.fc_buscar_producto_escaneo('FC-65010826'),
    i.producto_id
  ),
  pendiente_alta = (
    coalesce(
      public.fc_buscar_producto_escaneo('7501165010826'),
      public.fc_buscar_producto_escaneo('FC-65010826'),
      i.producto_id
    ) is null
  )
where i.codigo_escaneado in ('7501165010628', 'FC-15010628', 'FC-65010628');

-- ========== Arluy Duo (caja Adium) ==========
update public.productos p
set
  codigo_barras = '7841141004051',
  sku = case
    when p.sku in ('FC-41104068', 'FC-41004068', 'FC-ND-41104068', 'FC-ND-41004068')
      and not exists (
        select 1 from public.productos p2
        where p2.sku = 'FC-41004051'
          and p2.id is distinct from p.id
      ) then 'FC-41004051'
    else p.sku
  end,
  nombre = case
    when length(trim(coalesce(p.nombre, ''))) < 8 then 'Arluy Duo 200/300 mg'
    else p.nombre
  end,
  marca = coalesce(nullif(trim(p.marca), ''), 'Arluy Duo'),
  presentacion = coalesce(nullif(trim(p.presentacion), ''), 'Caja con 30 capsulas'),
  forma_farmaceutica = coalesce(nullif(trim(p.forma_farmaceutica), ''), 'Capsulas'),
  principio_activo = coalesce(nullif(trim(p.principio_activo), ''), 'Mebeverina / Simeticona'),
  concentracion = coalesce(nullif(trim(p.concentracion), ''), '200 mg / 300 mg'),
  updated_at = now()
where p.codigo_barras in ('7841141004068', '7841141004061')
   or p.sku in ('FC-41104068', 'FC-41004068');

update public.recepcion_items i
set
  codigo_escaneado = '7841141004051',
  producto_id = coalesce(
    public.fc_buscar_producto_escaneo('7841141004051'),
    public.fc_buscar_producto_escaneo('FC-41004051'),
    i.producto_id
  ),
  pendiente_alta = (
    coalesce(
      public.fc_buscar_producto_escaneo('7841141004051'),
      public.fc_buscar_producto_escaneo('FC-41004051'),
      i.producto_id
    ) is null
  )
where i.codigo_escaneado in ('7841141004068', '7841141004061', 'FC-41104068', 'FC-41004068');

-- ========== Naturella regulares sin alas C/8 (caja P&G) ==========
-- NO tocar el producto con alas 7501001157296 / FC-01157296 del catálogo.
-- Alta nueva con EAN de caja + reenlace del renglón Surtidor 161443.
insert into public.productos (
  nombre, sku, codigo_barras, categoria, tipo, descripcion,
  costo, precio, stock, stock_minimo, activo, requiere_receta,
  marca, presentacion, forma_farmaceutica, concentracion
)
select
  'Naturella regulares sin alas',
  'FC-95158739',
  '7506195158739',
  'Higiene',
  'marca',
  'Alta Surtidor 161443 · Naturella sin alas EAN de caja',
  13.00,
  17,
  0,
  1,
  true,
  false,
  'Naturella',
  'Caja con 8 toallas',
  'Toallas sanitarias',
  'Flujo abundante'
where public.fc_buscar_producto_escaneo('7506195158739') is null
  and public.fc_buscar_producto_escaneo('FC-95158739') is null
  and not exists (
    select 1 from public.productos p
    where nullif(btrim(p.codigo_barras), '') = '7506195158739'
       or p.sku = 'FC-95158739'
  );

update public.productos p
set
  nombre = case
    when length(trim(coalesce(p.nombre, ''))) < 8
      or p.nombre ilike '%flujo moderado%' then 'Naturella regulares sin alas'
    else p.nombre
  end,
  marca = coalesce(nullif(trim(p.marca), ''), 'Naturella'),
  presentacion = coalesce(nullif(trim(p.presentacion), ''), 'Caja con 8 toallas'),
  forma_farmaceutica = coalesce(nullif(trim(p.forma_farmaceutica), ''), 'Toallas sanitarias'),
  concentracion = coalesce(nullif(trim(p.concentracion), ''), 'Flujo abundante'),
  costo = case when coalesce(p.costo, 0) <= 0 then 13.00 else p.costo end,
  precio = case when coalesce(p.precio, 0) <= 0 then 17 else p.precio end,
  updated_at = now()
where p.codigo_barras = '7506195158739'
   or p.sku = 'FC-95158739';

update public.recepcion_items i
set
  codigo_escaneado = '7506195158739',
  nombre_snapshot = coalesce(nullif(btrim(i.nombre_snapshot), ''), 'NATURELLA FLUJO MOD S/ALAS C/8'),
  producto_id = coalesce(
    public.fc_buscar_producto_escaneo('7506195158739'),
    public.fc_buscar_producto_escaneo('FC-95158739'),
    i.producto_id
  ),
  pendiente_alta = (
    coalesce(
      public.fc_buscar_producto_escaneo('7506195158739'),
      public.fc_buscar_producto_escaneo('FC-95158739')
    ) is null
  )
from public.recepciones r
where i.recepcion_id = r.id
  and r.folio = '161443'
  and coalesce(r.proveedor, '') ilike '%surtidor%'
  and (
    i.nombre_snapshot ilike '%NATURELLA%S/ALAS%'
    or i.codigo_escaneado in ('7501001157296', '7506195158739', 'FC-01157296', 'FC-95158739')
  );

-- Cityfarma 15341570: renglones Enterogermina 4 + Arluy
update public.recepcion_items i
set
  codigo_escaneado = case
    when i.nombre_snapshot ilike '%ENTEROGERMINA 4%'
      or i.codigo_escaneado in ('7501165010628', '7501165010826', 'FC-15010628', 'FC-65010826')
      then '7501165010826'
    when i.nombre_snapshot ilike '%ARLUY%'
      or i.codigo_escaneado in ('7841141004068', '7841141004061', '7841141004051', 'FC-41104068', 'FC-41004051')
      then '7841141004051'
    else i.codigo_escaneado
  end,
  producto_id = coalesce(
    case
      when i.nombre_snapshot ilike '%ENTEROGERMINA 4%'
        or i.codigo_escaneado in ('7501165010628', '7501165010826', 'FC-15010628', 'FC-65010826')
        then coalesce(
          public.fc_buscar_producto_escaneo('7501165010826'),
          public.fc_buscar_producto_escaneo('FC-65010826')
        )
      when i.nombre_snapshot ilike '%ARLUY%'
        or i.codigo_escaneado in ('7841141004068', '7841141004061', '7841141004051', 'FC-41104068', 'FC-41004051')
        then coalesce(
          public.fc_buscar_producto_escaneo('7841141004051'),
          public.fc_buscar_producto_escaneo('FC-41004051')
        )
      else null
    end,
    i.producto_id
  ),
  pendiente_alta = false
from public.recepciones r
where i.recepcion_id = r.id
  and r.folio = '15341570'
  and coalesce(r.proveedor, '') ilike '%cityfarma%'
  and (
    i.nombre_snapshot ilike '%ENTEROGERMINA 4%'
    or i.nombre_snapshot ilike '%ARLUY%'
    or i.codigo_escaneado in (
      '7501165010628', '7501165010826', 'FC-15010628', 'FC-65010826',
      '7841141004068', '7841141004061', '7841141004051', 'FC-41104068', 'FC-41004051'
    )
  );

-- VERIFICACION
select id, sku, codigo_barras, nombre
from public.productos
where codigo_barras in (
    '7501165010826', '7501165010628',
    '7841141004051', '7841141004068',
    '7506195158739', '7501001157296'
  )
   or sku in (
    'FC-65010826', 'FC-15010628',
    'FC-41004051', 'FC-41104068',
    'FC-95158739', 'FC-01157296'
  )
order by nombre, id;

select r.folio, i.codigo_escaneado, i.nombre_snapshot, i.producto_id, i.pendiente_alta
from public.recepcion_items i
join public.recepciones r on r.id = i.recepcion_id
where (
    (r.folio = '15341570' and coalesce(r.proveedor, '') ilike '%cityfarma%'
      and (
        i.nombre_snapshot ilike '%ENTEROGERMINA 4%'
        or i.nombre_snapshot ilike '%ARLUY%'
        or i.codigo_escaneado like '7501165010%'
        or i.codigo_escaneado like '78411410040%'
      ))
 or (r.folio = '161443' and coalesce(r.proveedor, '') ilike '%surtidor%'
      and (
        i.nombre_snapshot ilike '%NATURELLA%'
        or i.codigo_escaneado in ('7506195158739', '7501001157296', 'FC-95158739', 'FC-01157296')
      ))
)
order by r.folio, i.nombre_snapshot;

commit;
