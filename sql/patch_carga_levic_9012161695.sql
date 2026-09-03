-- Levic · factura interna A 9012161695 · CFDI 01-sep-2026 23:14
-- Folio fiscal B4C6FCD0-6A11-4A09-A23C-DA984F71C7FD · PUE efectivo $1045.64
-- Receptor LUIS ANGEL PALILLERO VENTURA · 6 renglones · 18 pzas.
-- Subtotal CFDI $1029.38 + IVA $16.26 (solo Optimila-H) = $1045.64.
-- Costo = Precio neto. Lote = de fábrica (sí viene en la factura).
-- Caducidad del papel NO se escribe aquí: Recibir captura MMAA de la caja.
-- 0000 es inválido.
--
-- 0 ya estaban · 6 altas (Losartan Alpharma/AMSA/beadvance, Optimila-H, Alderan, Eldoquin).
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
      ('7502226294766', 'EQ-ALP0634', 'Losartan Alpharma 30 tab 50 mg', 'Medicamentos', 'generico', 11.08::numeric, 18.00, 4, 'Alpharma', 'Caja con 30 tabletas', 'Losartán potásico', '50 mg', true, 'Factura Levic 9012161695 · clave ALP0634 · lote 2606703', true),
      ('7501349028159', 'EQ-AMS318', 'Losartan AMSA 30 comprimidos 50 mg', 'Medicamentos', 'generico', 11.90, 20.00, 4, 'AMSA', 'Caja con 30 comprimidos', 'Losartán potásico', '50 mg', true, 'Factura Levic 9012161695 · clave AMS318 · lote U26M066', true),
      ('7501342803548', 'EQ-BEA367', 'Losartan beadvance 60 tab 50 mg', 'Medicamentos', 'generico', 28.11, 45.00, 2, 'beadvance', 'Caja con 60 tabletas', 'Losartán potásico', '50 mg', true, 'Factura Levic 9012161695 · clave BEA367 · lote 5GM003B', true),
      ('008400005656', 'EQ-INN022', 'Optimila-H Grin gotas 15 mL', 'Medicamentos', 'marca', 50.82, 82.00, 2, 'Grin', 'Frasco gotero 15 mL', 'Manzanilla / Hialuronato', null, false, 'Factura Levic 9012161695 · clave INN022 · lote XB01048', true),
      ('7502009744358', 'EQ-MAV204', 'Alderan Losartán 15 tab 100 mg', 'Medicamentos', 'marca', 21.25, 34.00, 2, 'Maver', 'Caja con 15 tabletas', 'Losartán potásico', '100 mg', true, 'Factura Levic 9012161695 · clave MAV204 · lote 256436', true),
      ('7501122961901', 'EQ-VAL129', 'Eldoquin crema 4% 30 g', 'Medicamentos', 'marca', 357.06, 572.00, 1, 'Eldoquin', 'Tubo 30 g', 'Hidroquinona', '4%', false, 'Factura Levic 9012161695 · clave VAL129 · lote 438137', true)
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

  raise notice 'Levic 9012161695: % altas de catálogo, % costos actualizados (stock = Recibir)',
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
  where folio = '9012161695' and coalesce(proveedor, '') ilike '%levic%'
  order by id desc
  limit 1;

  if v_id is not null and (select estado from public.recepciones where id = v_id) <> 'borrador' then
    raise notice 'Recepcion Levic 9012161695 ya cerrada (id %)', v_id;
  else
    if v_id is null then
      insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
      values ('Levic', '9012161695', '2026-09-01', 1045.64, 'borrador',
              'Factura Levic A 9012161695 · CFDI B4C6FCD0-6A11-4A09-A23C-DA984F71C7FD · cola Recibir; stock al confirmar pistola · lote de fábrica en el papel; MMAA de la caja')
      returning id into v_id;
    else
      delete from public.recepcion_items where recepcion_id = v_id;
      update public.recepciones
      set total_ticket = 1045.64, fecha = '2026-09-01',
          proveedor = 'Levic', notas = 'Factura Levic A 9012161695 · CFDI B4C6FCD0-6A11-4A09-A23C-DA984F71C7FD · cola Recibir; stock al confirmar pistola · lote de fábrica en el papel; MMAA de la caja', updated_at = now()
      where id = v_id;
    end if;

    for r in
      select * from (values
        ('7502226294766', 'Losartan Alpharma 30 tab 50 mg', 5, 11.08::numeric, 'EQ-ALP0634', '2606703'),
        ('7501349028159', 'Losartan AMSA 30 comprimidos 50 mg', 5, 11.90, 'EQ-AMS318', 'U26M066'),
        ('7501342803548', 'Losartan beadvance 60 tab 50 mg', 2, 28.11, 'EQ-BEA367', '5GM003B'),
        ('008400005656', 'Optimila-H Grin gotas 15 mL', 2, 50.82, 'EQ-INN022', 'XB01048'),
        ('7502009744358', 'Alderan Losartán 15 tab 100 mg', 2, 21.25, 'EQ-MAV204', '256436'),
        ('7501122961901', 'Eldoquin crema 4% 30 g', 2, 357.06, 'EQ-VAL129', '438137')
      ) as t(ean, nombre, qty, costo, sku, lote)
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
        v_id, v_pid, r.ean, r.nombre, r.qty, null, r.lote, r.costo,
        (v_pid is null), 'pdf', false,
        (v_pid is not null and exists (
          select 1 from public.lotes l
          where l.producto_id = v_pid and coalesce(l.activo, true)
            and coalesce(l.cantidad_actual, 0) > 0
            and l.numero_lote is distinct from r.lote
        )),
        null
      );
    end loop;

    raise notice 'Recepcion Levic 9012161695 lista id=% — escanear caja por caja', v_id;
  end if;
end $$;

commit;

select
  i.id,
  i.codigo_escaneado as ean,
  left(i.nombre_snapshot, 48) as nombre,
  i.cantidad,
  i.costo_estimado,
  i.numero_lote,
  case when i.pendiente_alta then 'ALTA NUEVA' else 'YA EXISTE' end as estado
from public.recepcion_items i
join public.recepciones r on r.id = i.recepcion_id
where r.folio = '9012161695' and coalesce(r.proveedor, '') ilike '%levic%'
order by i.id;
