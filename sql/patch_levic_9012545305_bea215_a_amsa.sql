-- ============================================================================
-- Levic 9012545305 · renglón BEA215 → caja real AMSA
--
-- Factura: BEA215 DICLOFENACO 20 TAB 100 MG (Beadvance)
-- Caja en mostrador: AMSA Diclofenaco iny 75 mg/3 mL C/2 · EAN 7501349025929
--                    (EQ-AMS362)
--
-- NO usar 7501342802145 (Beadvance). Si ya se pegó ese patch, este lo revierte.
-- Stock 0 hasta pistola + MMAA de la caja AMSA. No inventar 0000.
-- Pegar TODO en Supabase → SQL Editor → Run.
-- ============================================================================

begin;

-- Si se ligó el EAN Beadvance por error, quitarlo de EQ-BEA215.
update public.productos
set codigo_barras = null
where sku = 'EQ-BEA215'
  and codigo_barras = '7501342802145';

-- Asegurar EAN AMSA en el SKU correcto (ya debería estar).
update public.productos
set codigo_barras = '7501349025929'
where sku = 'EQ-AMS362'
  and (
    codigo_barras is null
    or btrim(codigo_barras) = ''
  )
  and not exists (
    select 1 from public.productos p2
    where p2.codigo_barras = '7501349025929'
      and p2.sku is distinct from 'EQ-AMS362'
  );

-- Renglón vivo del ticket: apunta a AMSA, no a Beadvance.
update public.recepcion_items i
set
  producto_id = coalesce(
    public.fc_buscar_producto_escaneo('7501349025929'),
    public.fc_buscar_producto_escaneo('EQ-AMS362')
  ),
  codigo_escaneado = '7501349025929',
  nombre_snapshot = 'DICLOFENACO 2 FA 75MG/3 ML | AMSA (factura BEA215; caja AMSA)',
  numero_lote = null,
  fecha_caducidad = null,
  pendiente_alta = (
    coalesce(
      public.fc_buscar_producto_escaneo('7501349025929'),
      public.fc_buscar_producto_escaneo('EQ-AMS362')
    ) is null
  ),
  confirmado = false,
  lote_id = null,
  lote_distinto = (
    coalesce(
      public.fc_buscar_producto_escaneo('7501349025929'),
      public.fc_buscar_producto_escaneo('EQ-AMS362')
    ) is not null
    and exists (
      select 1 from public.lotes l
      where l.producto_id = coalesce(
          public.fc_buscar_producto_escaneo('7501349025929'),
          public.fc_buscar_producto_escaneo('EQ-AMS362')
        )
        and coalesce(l.activo, true)
        and coalesce(l.cantidad_actual, 0) > 0
    )
  )
from public.recepciones r
where i.recepcion_id = r.id
  and r.folio = '9012545305'
  and coalesce(r.proveedor, '') ilike '%levic%'
  and r.estado = 'borrador'
  and not coalesce(i.confirmado, false)
  and (
    i.codigo_escaneado in ('EQ-BEA215', 'BEA215', '7501342802145')
    or i.nombre_snapshot ilike '%beadvance%'
    or i.producto_id = public.fc_buscar_producto_escaneo('EQ-BEA215')
  );

update public.recepciones
set
  notas = 'Factura Levic A 9012545305 · CFDI B57229E5-7DBB-4B9F-A23E-B1D28E33B872 · BEA215 en papel pero caja AMSA iny 7501349025929 · cola Recibir; MMAA de la caja AMSA',
  updated_at = now()
where folio = '9012545305'
  and coalesce(proveedor, '') ilike '%levic%'
  and estado = 'borrador';

commit;

select
  i.codigo_escaneado as ean,
  left(i.nombre_snapshot, 56) as nombre,
  i.cantidad,
  i.costo_estimado,
  i.numero_lote,
  i.pendiente_alta,
  i.confirmado,
  p.sku,
  p.marca
from public.recepcion_items i
join public.recepciones r on r.id = i.recepcion_id
left join public.productos p on p.id = i.producto_id
where r.folio = '9012545305'
  and coalesce(r.proveedor, '') ilike '%levic%'
  and (
    i.codigo_escaneado = '7501349025929'
    or i.nombre_snapshot ilike '%AMSA%'
    or i.nombre_snapshot ilike '%beadvance%'
  );
