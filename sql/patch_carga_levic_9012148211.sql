-- Levic · factura interna A 9012148211 · CFDI 31-ago-2026 02:53
-- Folio fiscal 1E6D645D-8DDC-4CF9-83FC-6250FBE6EE67 · PUE efectivo $627.85
-- Receptor LUIS ANGEL PALILLERO VENTURA · 11 renglones · 22 pzas.
-- Subtotal CFDI $618.75 + IVA $9.10 (solo Sensodyne) = $627.85.
-- Costo = ValorUnitario neto. El XML no trae lote ni caducidad: no se inventan.
-- MMAA sale de la caja al escanear. 0000 es inválido.
--
-- 6 ya estaban · 5 altas (Cefotaxima 500 mg, Biomesina, Lincover, Lisonin 600, Lisonin 300).
-- Altas: stock 0. En existentes solo se actualiza costo (no el PVP).
-- Idempotente. Pegar en Supabase SQL Editor (archivo completo).

begin;

-- ── 1) Catálogo: altas faltantes + costo de esta factura ──────────
do $$
declare
  r record;
  v_pid bigint;
  n_alta integer := 0;
  n_costo integer := 0;
begin
  for r in
    select * from (values
      ('7501349021808', 'EQ-AMS349', 'Cefotaxima IM 500 mg/2 ml', 'Medicamentos', 'generico', 27.99::numeric, 45.00, 1, 'AMSA', 'Frasco ámpula 500 mg + diluyente 2 mL', 'Cefotaxima', '500 mg/2 ml', true, 'Factura Levic 9012148211 · clave AMS349', true),
      ('7501573900535', 'EQ-BIO002', 'Biomesina 10 tab 10 mg', 'Medicamentos', 'marca', 13.54, 22.00, 2, 'Biomep', 'Caja con 10 tabletas', 'Butilhioscina', '10 mg', false, 'Factura Levic 9012148211 · clave BIO002', true),
      ('7896009498091', 'FC-09498091', 'Sensodyne Complete Protection 90 g', 'Cuidado personal', 'marca', 56.88, 92.00, 1, 'Sensodyne', 'Tubo 90 g', null, null, false, 'Factura Levic 9012148211 · clave HLN078', false),
      ('7502211789284', 'EQ-LOE131', 'Faribrox TM infantil 150/113 mg jarabe 150 mL', 'Medicamentos', 'marca', 23.41, 38.00, 2, 'Loeffler', 'Frasco 150 mL', 'Ambroxol / Dextrometorfano', '150/113 mg/100 mL', false, 'Factura Levic 9012148211 · clave LOE131', false),
      ('7502009740794', 'EQ-MAV102', 'Lincover lincomicina 16 cáps 500 mg', 'Medicamentos', 'marca', 58.74, 94.00, 2, 'Maver', 'Caja con 16 cápsulas', 'Lincomicina', '500 mg', true, 'Factura Levic 9012148211 · clave MAV102', true),
      ('7502009741593', 'EQ-MAV162', 'Dolxen 10 tab 500 mg', 'Medicamentos', 'marca', 19.88, 32.00, 2, 'Maver', 'Caja con 10 tabletas', 'Naproxeno', '500 mg', false, 'Factura Levic 9012148211 · clave MAV162', false),
      ('7502001163782', 'EQ-SON039', 'Dicleophen 12 cáps 500 mg', 'Medicamentos', 'marca', 29.76, 48.00, 2, 'SON''S', 'Caja con 12 cápsulas', 'Dicloxacilina', '500 mg', true, 'Factura Levic 9012148211 · clave SON039', false),
      ('7502001161627', 'EQ-SON083', 'Lisonin 1 amp 600 mg/2 ml', 'Medicamentos', 'marca', 36.45, 59.00, 1, 'SON''S', '1 ampolleta 2 mL', 'Lincomicina', '600 mg/2 ml', true, 'Factura Levic 9012148211 · clave SON083', true),
      ('7502001161597', 'EQ-SON084', 'Lisonin 1 amp 300 mg/1 ml', 'Medicamentos', 'marca', 26.73, 43.00, 2, 'SON''S', '1 ampolleta 1 mL', 'Lincomicina', '300 mg/1 ml', true, 'Factura Levic 9012148211 · clave SON084', true),
      ('7503003738879', 'FC-03738879', 'Rosel-T 15 tab 300/50/3 mg', 'Medicamentos', 'marca', 22.25, 36.00, 1, 'Wermar', 'Caja con 15 tabletas', 'Paracetamol / Amantadina / Clorfenamina', '300/50/3 mg', false, 'Factura Levic 9012148211 · clave WER015', false),
      ('7503003738404', 'EQ-WER025', 'Amantadina (Rosel) 24 cáps 50/3/300 mg', 'Medicamentos', 'marca', 28.12, 45.00, 1, 'Wermar', 'Caja con 24 cápsulas', 'Amantadina / Clorfenamina / Paracetamol', '50/3/300 mg', false, 'Factura Levic 9012148211 · clave WER025', false)
    ) as t(ean, sku, nombre, categoria, tipo, costo, precio, stock_minimo,
           marca, presentacion, principio, concentracion, receta, notas, es_alta)
  loop
    v_pid := public.fc_buscar_producto_escaneo(r.ean);
    if v_pid is null then
      v_pid := public.fc_buscar_producto_escaneo(r.sku);
    end if;

    if v_pid is null then
      select f.producto_id into v_pid
      from public.create_producto_with_lote(
        jsonb_build_object(
          'nombre', r.nombre,
          'sku', r.sku,
          'codigo_barras', r.ean,
          'categoria', r.categoria,
          'tipo', r.tipo,
          'descripcion', r.notas,
          'costo', r.costo,
          'precio', r.precio,
          'stock_minimo', r.stock_minimo,
          'activo', true,
          'requiere_receta', r.receta
        ),
        0, null, null::date, r.costo, null::bigint
      ) f;
      n_alta := n_alta + 1;
    else
      update public.productos set
        costo = r.costo,
        stock_minimo = greatest(coalesce(stock_minimo, 0), r.stock_minimo),
        codigo_barras = coalesce(nullif(codigo_barras, ''), r.ean)
      where id = v_pid;
      n_costo := n_costo + 1;
    end if;

    update public.productos set
      marca = coalesce(nullif(marca, ''), r.marca),
      presentacion = coalesce(nullif(presentacion, ''), r.presentacion),
      principio_activo = coalesce(nullif(principio_activo, ''), r.principio),
      concentracion = coalesce(nullif(concentracion, ''), r.concentracion)
    where id = v_pid;
  end loop;

  raise notice 'Levic 9012148211: % altas de catálogo, % costos actualizados (stock = Recibir)',
    n_alta, n_costo;
end $$;

-- ── 2) Cola Recibir (borrador, sin sumar piezas) ──────────────────
do $$
declare
  v_id bigint;
  r record;
  v_pid bigint;
begin
  select id into v_id
  from public.recepciones
  where folio = '9012148211' and coalesce(proveedor, '') ilike '%levic%'
  order by id desc
  limit 1;

  if v_id is not null and (select estado from public.recepciones where id = v_id) <> 'borrador' then
    raise notice 'Recepcion Levic 9012148211 ya cerrada (id %)', v_id;
  else
    if v_id is null then
      insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
      values ('Levic', '9012148211', '2026-08-31', 627.85, 'borrador',
              'Factura Levic A 9012148211 · CFDI 1E6D645D-8DDC-4CF9-83FC-6250FBE6EE67 · cola Recibir; stock al confirmar pistola · sin lote en el XML')
      returning id into v_id;
    else
      delete from public.recepcion_items where recepcion_id = v_id;
      update public.recepciones
      set total_ticket = 627.85, fecha = '2026-08-31',
          proveedor = 'Levic', notas = 'Factura Levic A 9012148211 · CFDI 1E6D645D-8DDC-4CF9-83FC-6250FBE6EE67 · cola Recibir; stock al confirmar pistola · sin lote en el XML', updated_at = now()
      where id = v_id;
    end if;

    for r in
      select * from (values
        ('7501349021808', 'Cefotaxima IM 500 mg/2 ml', 1, 27.99::numeric, 'EQ-AMS349'),
        ('7501573900535', 'Biomesina 10 tab 10 mg', 3, 13.54, 'EQ-BIO002'),
        ('7896009498091', 'Sensodyne Complete Protection 90 g', 1, 56.88, 'FC-09498091'),
        ('7502211789284', 'Faribrox TM infantil 150/113 mg jarabe 150 mL', 2, 23.41, 'EQ-LOE131'),
        ('7502009740794', 'Lincover lincomicina 16 cáps 500 mg', 2, 58.74, 'EQ-MAV102'),
        ('7502009741593', 'Dolxen 10 tab 500 mg', 5, 19.88, 'EQ-MAV162'),
        ('7502001163782', 'Dicleophen 12 cáps 500 mg', 3, 29.76, 'EQ-SON039'),
        ('7502001161627', 'Lisonin 1 amp 600 mg/2 ml', 1, 36.45, 'EQ-SON083'),
        ('7502001161597', 'Lisonin 1 amp 300 mg/1 ml', 2, 26.73, 'EQ-SON084'),
        ('7503003738879', 'Rosel-T 15 tab 300/50/3 mg', 1, 22.25, 'FC-03738879'),
        ('7503003738404', 'Amantadina (Rosel) 24 cáps 50/3/300 mg', 1, 28.12, 'EQ-WER025')
      ) as t(ean, nombre, qty, costo, sku)
    loop
      v_pid := public.fc_buscar_producto_escaneo(r.ean);
      if v_pid is null then
        v_pid := public.fc_buscar_producto_escaneo(r.sku);
      end if;

      insert into public.recepcion_items (
        recepcion_id, producto_id, codigo_escaneado, nombre_snapshot,
        cantidad, fecha_caducidad, numero_lote, costo_estimado, pendiente_alta,
        origen, confirmado, lote_distinto, lote_id
      ) values (
        v_id, v_pid, r.ean, r.nombre, r.qty, null, null, r.costo,
        (v_pid is null), 'pdf', false,
        (v_pid is not null and exists (
          select 1 from public.lotes l
          where l.producto_id = v_pid and coalesce(l.activo, true)
            and coalesce(l.cantidad_actual, 0) > 0
        )),
        null
      );
    end loop;

    raise notice 'Recepcion Levic 9012148211 lista id=% — escanear caja por caja', v_id;
  end if;
end $$;

commit;

select
  i.id,
  i.codigo_escaneado as ean,
  left(i.nombre_snapshot, 48) as nombre,
  i.cantidad,
  i.costo_estimado,
  case when i.pendiente_alta then 'ALTA NUEVA' else 'YA EXISTE' end as estado
from public.recepcion_items i
join public.recepciones r on r.id = i.recepcion_id
where r.folio = '9012148211' and coalesce(r.proveedor, '') ilike '%levic%'
order by i.id;
