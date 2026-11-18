-- =============================================================================
-- PEGAR TODO en Supabase → SQL Editor → Run
-- Corrige Enterogermina 4 billones: EAN de la caja = 7501165010826
-- (antes quedó 7501165010628 por OCR/dígito inventado)
-- SKU canónico: FC-65010826
-- Sin dollar-quote. Idempotente.
-- =============================================================================

begin;

-- 1) Producto con EAN/SKU mal
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

-- 2) Si ya existía el EAN bueno en otro renglón y el malo sigue: enlaza items al bueno
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

-- 3) Cityfarma 15341570: asegura snapshot/código del renglón Enterogermina 4
update public.recepcion_items i
set
  codigo_escaneado = '7501165010826',
  nombre_snapshot = coalesce(nullif(btrim(i.nombre_snapshot), ''), 'ENTEROGERMINA 4 BILL'),
  producto_id = coalesce(
    public.fc_buscar_producto_escaneo('7501165010826'),
    public.fc_buscar_producto_escaneo('FC-65010826'),
    i.producto_id
  ),
  pendiente_alta = false
from public.recepciones r
where i.recepcion_id = r.id
  and r.folio = '15341570'
  and coalesce(r.proveedor, '') ilike '%cityfarma%'
  and (
    i.codigo_escaneado in ('7501165010628', '7501165010826', 'FC-15010628', 'FC-65010826')
    or i.nombre_snapshot ilike '%ENTEROGERMINA 4%'
  );

-- VERIFICACION
select id, sku, codigo_barras, nombre
from public.productos
where codigo_barras in ('7501165010826', '7501165010628')
   or sku in ('FC-65010826', 'FC-15010628', 'FC-65010628')
order by id;

select i.codigo_escaneado, i.nombre_snapshot, i.producto_id, i.pendiente_alta
from public.recepcion_items i
join public.recepciones r on r.id = i.recepcion_id
where r.folio = '15341570'
  and coalesce(r.proveedor, '') ilike '%cityfarma%'
  and (
    i.codigo_escaneado like '7501165010%'
    or i.nombre_snapshot ilike '%ENTEROGERMINA 4%'
  );

commit;
