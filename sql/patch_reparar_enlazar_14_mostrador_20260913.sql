-- ============================================================================
-- FARMA CAPITAL — Reparar 14 EANs mostrador (13-sep-2026)
--
-- Si ya corriste el alta y Recibir sigue en rojo:
--   1) este script vuelve a crear lo que falte (DO, sin temp table)
--   2) enlaza recepcion_items.pendiente_alta por EAN
--   3) al final lista qué quedó en catálogo
--
-- Pegar TODO en Supabase → SQL Editor → Run.
-- Luego en la app: recarga fuerte (o cierra y abre Recibir) y vuelve a escanear.
-- ============================================================================

do $$
declare
  r record;
  v_pid bigint;
  v_sku text;
  v_creados int := 0;
  v_existian int := 0;
  v_enlazados int := 0;
  n int;
begin
  for r in
    select * from (values
      ('7506306208353', 'FC-06208353', 'St. Ives crema corporal Humectación Profunda avena y karité 200 ml', 48.00::numeric, 'Cuidado personal', 'St. Ives', '200 ml', 'Crema', 'Crema corporal'),
      ('7502254072831', 'FC-54072831', 'Seda Pure Brillo Keratin sílica spray 125 ml', 89.00, 'Cuidado personal', 'Seda Pure', '125 ml', 'Spray', 'Cuidado del cabello'),
      ('7501027233974', 'FC-27233974', 'L''Oréal Paris Studio Line Invisi Fix Ultra Fijación gel 180 g', 97.00, 'Cuidado personal', 'L''Oréal Paris', '180 g', 'Gel', 'Cuidado del cabello'),
      ('7702035433299', 'FC-35433299', 'Listerine Pro-Encías enjuague bucal menta 250 ml', 99.00, 'Higiene', 'Listerine', '250 ml', 'Enjuague', 'Higiene bucal'),
      ('7502254073715', 'FC-54073715', 'Seda Pure tratamiento bifase keratina 250 ml', 95.00, 'Cuidado personal', 'Seda Pure', '250 ml', 'Spray', 'Cuidado del cabello'),
      ('7501080111455', 'FC-80111455', 'Just For Men tinte barba y bigote negro', 165.00, 'Cuidado personal', 'Just For Men', 'Kit gel', 'Gel', 'Tinte'),
      ('7506306208315', 'FC-06208315', 'St. Ives crema corporal Piel Renovada colágeno y elastina 200 ml', 49.00, 'Cuidado personal', 'St. Ives', '200 ml', 'Crema', 'Crema corporal'),
      ('7502254073357', 'FC-54073357', 'Seda Pure sílica spray uva 300 ml', 94.00, 'Cuidado personal', 'Seda Pure', '300 ml', 'Spray', 'Cuidado del cabello'),
      ('7502254073371', 'FC-54073371', 'Seda Pure sílica spray argán 300 ml', 94.00, 'Cuidado personal', 'Seda Pure', '300 ml', 'Spray', 'Cuidado del cabello'),
      ('810120500164', 'FC-20500164', 'Pert crema para peinar kera + aguacate 100 ml', 55.00, 'Cuidado personal', 'Pert', '100 ml', 'Crema', 'Cuidado del cabello'),
      ('850040940602', 'FC-40940602', 'Grisi Organogal Silver kit shampoo 400 ml + tratamiento canas 130 ml', 189.00, 'Cuidado personal', 'Grisi', 'Kit 400 ml + 130 ml', 'Kit', 'Cuidado del cabello'),
      ('070330717541', 'FC-30717541', 'BIC Comfort 3 rastrillos desechables 12 pzas', 120.00, 'Higiene', 'BIC', '12 pzas', 'Rastrillo', 'Afeitado'),
      ('070330731813', 'FC-30731813', 'BIC Soleil 3 Color Collection rastrillos 12 pzas', 145.00, 'Higiene', 'BIC', '12 pzas', 'Rastrillo', 'Afeitado'),
      ('7501943476271', 'FC-43476271', 'Kleenex pañuelos faciales bote 50 pzas', 45.00, 'Higiene', 'Kleenex', 'Bote 50 pzas', 'Pañuelos', 'Pañuelos')
    ) as t(ean, sku, nombre, precio, categoria, marca, presentacion, forma_farmaceutica, subcategoria)
  loop
    v_pid := public.fc_buscar_producto_escaneo(r.ean);

    -- Variante UPC sin cero a la izquierda (pistola a veces lo come)
    if v_pid is null and left(r.ean, 1) = '0' and length(r.ean) = 12 then
      v_pid := public.fc_buscar_producto_escaneo(substr(r.ean, 2));
    end if;

    if v_pid is not null then
      v_existian := v_existian + 1;
      update public.productos p
      set
        activo = true,
        nombre = coalesce(nullif(btrim(p.nombre), ''), r.nombre),
        marca = coalesce(nullif(btrim(p.marca), ''), r.marca),
        presentacion = coalesce(nullif(btrim(p.presentacion), ''), r.presentacion),
        forma_farmaceutica = coalesce(nullif(btrim(p.forma_farmaceutica), ''), r.forma_farmaceutica),
        subcategoria = coalesce(nullif(btrim(p.subcategoria), ''), r.subcategoria),
        categoria = coalesce(nullif(btrim(p.categoria), ''), r.categoria),
        codigo_barras = coalesce(nullif(btrim(p.codigo_barras), ''), r.ean),
        precio = case when coalesce(p.precio, 0) <= 1 then r.precio else p.precio end
      where p.id = v_pid;
    else
      v_sku := r.sku;
      if exists (
        select 1 from public.productos p
        where p.sku = v_sku
          and coalesce(p.codigo_barras, '') <> r.ean
      ) then
        v_sku := 'FC-ND-' || right(r.ean, 8);
      end if;

      insert into public.productos (
        nombre, sku, codigo_barras, categoria, tipo, descripcion,
        costo, precio, stock, stock_minimo, activo, requiere_receta,
        marca, presentacion, forma_farmaceutica, subcategoria
      ) values (
        r.nombre,
        v_sku,
        r.ean,
        r.categoria,
        'marca',
        'Alta/reparación mostrador 2026-09-13 · EAN ' || r.ean || ' · stock 0 hasta Recibir',
        null,
        r.precio,
        0,
        1,
        true,
        false,
        r.marca,
        r.presentacion,
        r.forma_farmaceutica,
        r.subcategoria
      )
      returning id into v_pid;
      v_creados := v_creados + 1;
    end if;
  end loop;

  -- Enlazar renglones rojos de Recibir cuyo EAN ya está en catálogo
  update public.recepcion_items i
  set
    producto_id = public.fc_buscar_producto_escaneo(i.codigo_escaneado),
    pendiente_alta = false
  where i.pendiente_alta
    and public.fc_buscar_producto_escaneo(i.codigo_escaneado) is not null;

  get diagnostics n = row_count;
  v_enlazados := n;

  -- Pistola sin el 0 inicial del UPC
  update public.recepcion_items i
  set
    producto_id = public.fc_buscar_producto_escaneo(
      '0' || regexp_replace(i.codigo_escaneado, '\D', '', 'g')
    ),
    pendiente_alta = false
  where i.pendiente_alta
    and i.producto_id is null
    and length(regexp_replace(coalesce(i.codigo_escaneado, ''), '\D', '', 'g')) in (11, 12)
    and left(regexp_replace(coalesce(i.codigo_escaneado, ''), '\D', '', 'g'), 1) <> '0'
    and public.fc_buscar_producto_escaneo(
      '0' || regexp_replace(i.codigo_escaneado, '\D', '', 'g')
    ) is not null;

  get diagnostics n = row_count;
  v_enlazados := v_enlazados + n;

  raise notice 'Reparación 14: creados=% ya_estaban=% renglones_enlazados=%',
    v_creados, v_existian, v_enlazados;
end
$$;

-- Diagnóstico: tiene que devolver 14 filas
select
  t.ean,
  public.fc_buscar_producto_escaneo(t.ean) as producto_id,
  p.sku,
  p.nombre,
  p.activo
from (
  values
    ('7506306208353'),
    ('7502254072831'),
    ('7501027233974'),
    ('7702035433299'),
    ('7502254073715'),
    ('7501080111455'),
    ('7506306208315'),
    ('7502254073357'),
    ('7502254073371'),
    ('810120500164'),
    ('850040940602'),
    ('070330717541'),
    ('070330731813'),
    ('7501943476271')
) as t(ean)
left join public.productos p
  on p.id = public.fc_buscar_producto_escaneo(t.ean)
order by t.ean;

-- Renglones de Recibir que aún siguen en rojo para estos EAN
select
  i.id,
  i.codigo_escaneado,
  i.pendiente_alta,
  i.producto_id,
  i.nombre_snapshot
from public.recepcion_items i
where i.pendiente_alta
  and regexp_replace(coalesce(i.codigo_escaneado, ''), '\D', '', 'g') in (
    '7506306208353', '7502254072831', '7501027233974', '7702035433299',
    '7502254073715', '7501080111455', '7506306208315', '7502254073357',
    '7502254073371', '810120500164', '850040940602', '070330717541',
    '70330717541', '070330731813', '70330731813', '7501943476271'
  )
order by i.id;
