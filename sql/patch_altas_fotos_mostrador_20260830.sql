-- ============================================================================
-- Altas de mostrador 30-ago-2026 (fotos EAN + nombre)
--
-- Ninguno estaba en catálogo. INSERT ONLY si el EAN/SKU no existe.
-- Stock 1 por pieza fotografiada. Precios de venta = referencia de plaza / PMP
-- de la caja (ajustar costo real cuando haya ticket).
--
--  1. GUM Flossers hilo con mango C/30     070942307109   lote 260103  cad 2028-12
--  2. Encendedor Riegel                    855553008221   lote 24E20746
--  3. Nikzon 90 tab masticables            650240001314   lote 6141019314  cad 2028-06  PMP $650
--  4. Xiomara cera telaraña 100 g          7501846506198  lote 230626101-1 cad 2028-06
--       ≠ Cera Tel 7501846504569 (otra presentación)
--  5. JULAB norfloxacino/fenazopiridina    7502227879559  lote RJL030  cad 2028-05  PMP $330
--  6. Minociclina 100 mg C/10 Serral       7501258210379  lote 260141  cad 2028-01  PMP $577.50
--       ≠ Azitromicina Serral 7501258210393
--  7. LAÜR Infantil inyectable C/3         7502001167001  (sin lote en foto)
--       ≠ LAÜR Adulto EQ-SON264 7502001166981
--
-- Ampicilina 250 mg/5 mL frasco 60 mL (lote B2601006, cad DIC 27, PMP $350):
--   SIN EAN en las fotos. No se da de alta. No uses 7502001167001 (eso es LAÜR Infantil).
--
-- Ejecutar en Supabase SQL Editor (archivo completo).
-- ============================================================================

begin;

do $$
declare
  r record;
  v_pid bigint;
  v_lid bigint;
begin
  for r in
    select * from (values
      (
        '070942307109'::text, 'FC-42307109'::text, null::text,
        'GUM Flossers hilo dental con mango C/30'::text, 'GUM'::text,
        'Bolsa con 30 palillos con hilo'::text, 'Hilo dental con mango'::text,
        null::text, null::text,
        'Higiene'::text, 'marca'::text,
        'Fotos 20260830 · Sunstar GUM Flossers C/30 · UPC 070942307109 (EAN-13 0070942307109) · lote 260103 · cad 2028-12 · ≠ hilo en rollo 070942303194 / 7502235820369'::text,
        16::numeric, 28::numeric, 1::integer,
        '260103'::text, '2028-12-31'::date, false, 2,
        '%gum%flosser%'::text
      ),
      (
        '855553008221', 'FC-53008221', null,
        'Encendedor desechable Riegel', 'Riegel',
        '1 pieza'::text, 'Encendedor'::text,
        null, null,
        'Botiquín', 'marca',
        'Fotos 20260830 · Riegel USA · UPC 855553008221 · lote 24E20746 · MFG ZY-2A · no hay otro encendedor en catálogo',
        7, 12, 1,
        '24E20746', null::date, false, 2,
        '%encendedor%riegel%'
      ),
      (
        '650240001314', 'FC-40001314', null,
        'Nikzon 90 tabletas masticables', 'Nikzon',
        'Caja con 90 tabletas masticables'::text, 'Tabletas masticables'::text,
        'Ruscus aculeatus / Lactobacillus sporogenes / Ácido ascórbico'::text,
        '2 mg / 8.3 mg / 40 mg'::text,
        'Herbolario', 'marca',
        'Fotos 20260830 · Genomma Nikzon C/90 · EAN 650240001314 · lote 6141019314 · cad JUN 2028 · PMP caja $650 · herbolario hemorroides',
        380, 549, 1,
        '6141019314', '2028-06-30'::date, false, 1,
        '%nikzon%'
      ),
      (
        '7501846506198', 'FC-46506198', null,
        'Xiomara cera modeladora telaraña 100 g', 'Xiomara',
        'Frasco 100 g'::text, 'Cera'::text,
        null, null,
        'Cuidado personal', 'marca',
        'Fotos 20260830 · Xiomara Elastik Wax telaraña 100 g · EAN 7501846506198 · lote 230626101-1 · cad JUN 2028 · ≠ Cera Tel 7501846504569 ≠ Cera Fix 7501846506181',
        52, 89, 1,
        '230626101-1', '2028-06-30'::date, false, 1,
        '%xiomara%telaraña%100%'
      ),
      (
        '7502227879559', 'FC-27879559', null,
        'JULAB norfloxacino/fenazopiridina 400/100 mg C/8', 'RAAM',
        'Caja con 8 tabletas'::text, 'Tabletas'::text,
        'Norfloxacino / Fenazopiridina'::text, '400 mg / 100 mg'::text,
        'Antibiótico', 'marca',
        'Fotos 20260830 · RAAM JULAB C/8 · EAN 7502227879559 · lote RJL030 · cad MAY 2028 · PMP $330 · receta · ≠ fenazopiridina sola Urezol/Randall',
        185, 279, 1,
        'RJL030', '2028-05-31'::date, true, 1,
        '%julab%'
      ),
      (
        '7501258210379', 'FC-58210379', null,
        'Minociclina 100 mg C/10 Serral', 'Serral',
        'Caja con 10 tabletas'::text, 'Tabletas'::text,
        'Clorhidrato de minociclina'::text, '100 mg'::text,
        'Antibiótico', 'generico',
        'Fotos 20260830 · Serral minociclina 100 mg C/10 · EAN 7501258210379 · lote 260141 · cad ENE 2028 · PMP $577.50 · receta · ≠ Azitromicina Serral 7501258210393',
        340, 499, 1,
        '260141', '2028-01-31'::date, true, 1,
        '%minociclina%'
      ),
      (
        '7502001167001', 'FC-01167001', null,
        'LAÜR Infantil solución inyectable C/3', 'SON''S',
        'Caja con 3 frascos ámpula, 3 ampolletas 3 mL y 3 jeringas'::text,
        'Solución inyectable'::text,
        'Ampicilina / Metamizol / Guaifenesina / Lidocaína / Clorfenamina'::text,
        '250 mg / 200 mg / 100 mg / 30 mg / 2 mg'::text,
        'Antibiótico', 'marca',
        'Fotos 20260830 · Química Son''s LAÜR Infantil · EAN 7502001167001 · receta IM · ≠ Adulto EQ-SON264 7502001166981 (500/500 mg)',
        58, 96, 1,
        'S/L', null::date, true, 1,
        '%laur%infantil%'
      )
    ) as t(
      ean, sku, alt_sku, nombre, marca, presentacion, forma, principio,
      concentracion, categoria, tipo, descripcion, costo, precio, qty,
      lote, cad, receta, stock_min, patron
    )
  loop
    v_pid := null;
    v_lid := null;

    select p.id into v_pid
    from public.productos p
    where p.codigo_barras in (r.ean, '0' || r.ean, ltrim(r.ean, '0'))
       or p.sku = r.sku
       or (r.alt_sku is not null and p.sku = r.alt_sku)
       or (
         r.patron is not null
         and p.nombre ilike r.patron
         and not (r.sku = 'FC-01167001' and p.nombre ilike '%adulto%')
         and not (r.sku = 'FC-46506198' and (
           p.codigo_barras in ('7501846504569', '7501846506181', '7501846505283')
           or p.nombre ilike '%cera tel%'
           or p.nombre ilike '%cera fix%'
           or p.nombre ilike '%cera mate%'
         ))
         and not (r.sku = 'FC-58210379' and p.nombre ilike '%azitromicina%')
       )
    order by case
      when p.codigo_barras = r.ean then 0
      when p.sku = r.sku then 1
      else 2
    end, p.id
    limit 1;

    if v_pid is null then
      select f.producto_id, f.lote_id into v_pid, v_lid
      from public.create_producto_with_lote(
        jsonb_build_object(
          'nombre', r.nombre,
          'sku', r.sku,
          'codigo_barras', r.ean,
          'categoria', r.categoria,
          'tipo', r.tipo,
          'descripcion', r.descripcion,
          'costo', r.costo,
          'precio', r.precio,
          'stock_minimo', r.stock_min,
          'activo', true,
          'requiere_receta', r.receta
        ),
        r.qty,
        r.lote,
        r.cad,
        r.costo,
        null::bigint
      ) f;
      raise notice 'CREADO % sku % ean % id % lote %', r.nombre, r.sku, r.ean, v_pid, v_lid;
    else
      raise notice 'SKIP % ya existe id % (no se duplica stock)', r.nombre, v_pid;
    end if;

    update public.productos set
      marca = coalesce(nullif(marca, ''), r.marca),
      presentacion = coalesce(nullif(presentacion, ''), r.presentacion),
      forma_farmaceutica = coalesce(nullif(forma_farmaceutica, ''), r.forma),
      principio_activo = coalesce(nullif(principio_activo, ''), r.principio),
      concentracion = coalesce(nullif(concentracion, ''), r.concentracion),
      categoria = coalesce(nullif(categoria, ''), r.categoria),
      tipo = r.tipo,
      requiere_receta = r.receta
    where id = v_pid;
  end loop;

  raise notice 'Ampicilina 250 mg/5 mL 60 mL: SIN EAN en fotos; no se alta. No uses 7502001167001.';
end $$;

commit;

select
  p.sku,
  p.nombre,
  p.codigo_barras,
  p.marca,
  p.categoria,
  p.costo,
  p.precio,
  p.stock,
  p.requiere_receta,
  l.numero_lote,
  l.fecha_caducidad,
  l.cantidad_actual
from public.productos p
left join public.lotes l on l.producto_id = p.id and coalesce(l.activo, true) = true
where p.codigo_barras in (
    '070942307109', '0070942307109',
    '855553008221',
    '650240001314',
    '7501846506198',
    '7502227879559',
    '7501258210379',
    '7502001167001'
  )
   or p.sku in (
    'FC-42307109', 'FC-53008221', 'FC-40001314', 'FC-46506198',
    'FC-27879559', 'FC-58210379', 'FC-01167001'
  )
order by p.sku, l.fecha_caducidad;
