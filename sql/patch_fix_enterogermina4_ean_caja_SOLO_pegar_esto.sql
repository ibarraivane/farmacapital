-- =============================================================================
-- PEGAR TODO en Supabase → SQL Editor → Run
-- Corrige EANs de caja (Cityfarma 15341570):
--   Enterogermina 4 billones → 7501165010826 (SKU FC-65010826)
--   Arluy Duo 200/300 mg     → 7841141004051 (SKU FC-41004051)
-- Antes: 7501165010628 / 7841141004068 por OCR.
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
    '7841141004051', '7841141004068', '7841141004061'
  )
   or sku in (
    'FC-65010826', 'FC-15010628', 'FC-65010628',
    'FC-41004051', 'FC-41104068', 'FC-41004068'
  )
order by nombre, id;

select i.codigo_escaneado, i.nombre_snapshot, i.producto_id, i.pendiente_alta
from public.recepcion_items i
join public.recepciones r on r.id = i.recepcion_id
where r.folio = '15341570'
  and coalesce(r.proveedor, '') ilike '%cityfarma%'
  and (
    i.nombre_snapshot ilike '%ENTEROGERMINA 4%'
    or i.nombre_snapshot ilike '%ARLUY%'
    or i.codigo_escaneado like '7501165010%'
    or i.codigo_escaneado like '78411410040%'
  )
order by i.nombre_snapshot;

commit;
