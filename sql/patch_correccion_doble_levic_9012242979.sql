-- Levic A 9012242979 (14-sep-2026): la factura se entró dos veces a stock.
--
-- No es merma ni robo. Casi cada renglón quedó con DOS lotes de la
-- cantidad del papel (HT-Bloc 2+2, Prochor 3+3, …). El anaquel tiene
-- una sola vez lo que dice la factura; el sistema cuenta la copia.
--
-- Ácido alendrónico AMSA 7501349014190:
--   Equilibrio 12-sep, lote U25T260, 4 cajas (ese lote ya está en 3).
--   Levic, lote U26A275, 1 caja, cargada dos veces.
--   Sistema 5 = 3 + 1 + 1. Al bajar la copia quedan 4, que es el conteo físico.
--   stock_unidades y stock_blisters en 0: no hay caja abierta.
--
-- Este archivo:
--   1) Evita que un doble toque en Recibir vuelva a sumar el renglón completo.
--   2) Apaga solo el lote duplicado de ESTA factura (mismo número de lote,
--      misma cantidad inicial, entre el 14 y el 17 de septiembre).
--      No toca el lote más viejo, ni lotes de otro número, ni ventas.
--   3) Deja el reporte: factura vs vendido vs stock.
--
-- Idempotente. Pegar entero en Supabase → SQL Editor → Run.
-- Zagapsol no se duplicó: el reporte lo muestra y no lo baja.

begin;

-- ── 1) Recibir: no sumar otra vez la cantidad completa ─────────────
create or replace function public.recepcion_entrar_stock_item(
  p_item_id bigint,
  p_cantidad integer,
  p_proveedor text,
  p_user_id bigint
)
returns bigint
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_item public.recepcion_items%rowtype;
  v_lote_id bigint;
  v_numero text;
  v_folio text;
  v_producto_id bigint;
begin
  if p_cantidad is null or p_cantidad <= 0 then
    return null;
  end if;

  select * into v_item
  from public.recepcion_items
  where id = p_item_id
  for update;
  if not found then raise exception 'renglon no existe'; end if;

  if v_item.pendiente_alta or v_item.producto_id is null then
    v_producto_id := public.fc_buscar_producto_escaneo(v_item.codigo_escaneado);
    if v_producto_id is null then
      return v_item.lote_id;
    end if;
    update public.recepcion_items
    set producto_id = v_producto_id, pendiente_alta = false
    where id = p_item_id;
    select * into v_item
    from public.recepcion_items
    where id = p_item_id
    for update;
  end if;

  if v_item.fecha_caducidad is null then
    raise exception 'Caducidad requerida (MMAA de la caja)';
  end if;

  if v_item.lote_id is not null then
    -- Doble toque / cierre que manda otra vez la cantidad del renglón.
    -- Un aumento real manda solo el delta, que es menor que la cantidad ya guardada.
    if p_cantidad >= coalesce(v_item.cantidad, 0)
       and exists (
         select 1
         from public.lotes l
         where l.id = v_item.lote_id
           and coalesce(l.cantidad_inicial, 0) >= coalesce(v_item.cantidad, 0)
       )
    then
      return v_item.lote_id;
    end if;

    update public.lotes
    set
      cantidad_actual = coalesce(cantidad_actual, 0) + p_cantidad,
      activo = true,
      fecha_caducidad = coalesce(fecha_caducidad, v_item.fecha_caducidad),
      costo_unitario = coalesce(v_item.costo_estimado, costo_unitario)
    where id = v_item.lote_id;

    if v_item.costo_estimado is not null and v_item.costo_estimado > 0 then
      update public.productos
      set costo = v_item.costo_estimado
      where id = v_item.producto_id;
    end if;

    insert into public.movimientos_inventario (producto_id, tipo, cantidad, motivo, usuario_id)
    values (
      v_item.producto_id, 'entrada', p_cantidad,
      format('Recibir confirmado (lote %s)', coalesce(v_item.numero_lote, v_item.lote_id::text)),
      p_user_id::integer
    );

    update public.productos p
    set stock = coalesce((
      select sum(l.cantidad_actual) from public.lotes l
      where l.producto_id = p.id and coalesce(l.activo, true)
    ), 0)
    where p.id = v_item.producto_id;

    return v_item.lote_id;
  end if;

  select folio into v_folio from public.recepciones where id = v_item.recepcion_id;
  v_numero := coalesce(
    nullif(btrim(v_item.numero_lote), ''),
    'RX-' || coalesce(nullif(btrim(v_folio), ''), to_char(now(), 'YYYYMMDD'))
      || '-' || v_item.id::text
  );

  select lote_id into v_lote_id
  from public.receive_merchandise_lote(
    v_item.producto_id, p_cantidad, v_numero,
    v_item.fecha_caducidad, v_item.costo_estimado, p_proveedor, p_user_id
  );

  if v_lote_id is null then
    raise exception
      'No se pudo crear el lote en anaquel para % (producto %). Revisa receive_merchandise_lote.',
      coalesce(v_item.codigo_escaneado, '?'),
      v_item.producto_id;
  end if;

  update public.recepcion_items
  set lote_id = v_lote_id, numero_lote = v_numero
  where id = p_item_id;

  update public.productos p
  set stock = coalesce((
    select sum(l.cantidad_actual) from public.lotes l
    where l.producto_id = p.id and coalesce(l.activo, true)
  ), 0)
  where p.id = v_item.producto_id;

  return v_lote_id;
end;
$$;

create or replace function public.recepcion_confirmar_item(
  p_session_token uuid,
  p_item_id bigint,
  p_fecha_caducidad date,
  p_cantidad integer default null,
  p_costo numeric default null
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_user bigint;
  v_item public.recepcion_items%rowtype;
  v_recepcion_id bigint;
  v_estado text;
  v_proveedor text;
  v_qty integer;
  v_delta integer;
  v_costo numeric;
  v_lote_id bigint;
  v_pendiente boolean;
begin
  v_user := public.fn_require_empleado(p_session_token);
  if p_fecha_caducidad is null then
    raise exception 'Caducidad requerida (MMAA de la caja)';
  end if;

  select i.recepcion_id into v_recepcion_id
  from public.recepcion_items i
  where i.id = p_item_id;
  if not found then raise exception 'renglon no existe'; end if;

  select estado, proveedor into v_estado, v_proveedor
  from public.recepciones
  where id = v_recepcion_id
  for update;
  if v_estado not in ('borrador', 'pendiente_alta', 'pendiente_caducidad') then
    raise exception 'Este ticket ya se cerró. Si faltan caducidades, hay que reabrirlo.';
  end if;

  -- Después del lock: si el otro toque ya creó el lote, esta lectura lo ve.
  select i.* into v_item
  from public.recepcion_items i
  where i.id = p_item_id
  for update;

  v_qty := coalesce(p_cantidad, v_item.cantidad);
  if v_qty is null or v_qty <= 0 then raise exception 'cantidad invalida'; end if;

  v_costo := case
    when p_costo is not null and p_costo > 0 then p_costo
    else v_item.costo_estimado
  end;

  update public.recepcion_items
  set
    fecha_caducidad = p_fecha_caducidad,
    cantidad = v_qty,
    costo_estimado = v_costo,
    confirmado = true
  where id = p_item_id;

  if v_item.confirmado and v_item.lote_id is not null then
    v_delta := v_qty - v_item.cantidad;
    update public.lotes
    set fecha_caducidad = p_fecha_caducidad,
        costo_unitario = coalesce(v_costo, costo_unitario)
    where id = v_item.lote_id;
    if v_costo is not null and v_costo > 0 and not v_item.pendiente_alta and v_item.producto_id is not null then
      update public.productos set costo = v_costo where id = v_item.producto_id;
    end if;
    if v_delta > 0 then
      perform public.recepcion_entrar_stock_item(p_item_id, v_delta, v_proveedor, v_user);
    elsif v_delta < 0 then
      update public.lotes
      set
        cantidad_actual = greatest(0, coalesce(cantidad_actual, 0) + v_delta),
        activo = (greatest(0, coalesce(cantidad_actual, 0) + v_delta) > 0)
      where id = v_item.lote_id;
      update public.productos p
      set stock = coalesce((
        select sum(l.cantidad_actual) from public.lotes l
        where l.producto_id = p.id and coalesce(l.activo, true)
      ), 0)
      where p.id = v_item.producto_id;
    end if;
  else
    perform public.recepcion_entrar_stock_item(p_item_id, v_qty, v_proveedor, v_user);
  end if;

  select lote_id, pendiente_alta
    into v_lote_id, v_pendiente
  from public.recepcion_items
  where id = p_item_id;

  if not coalesce(v_pendiente, false) and v_lote_id is null then
    raise exception
      'El renglón quedó confirmado pero NO entró a inventario (sin lote). Escanea de nuevo o revisa que el EAN esté en catálogo.';
  end if;

  update public.recepciones set updated_at = now() where id = v_item.recepcion_id;
  return public.fc_recepcion_json(v_item.recepcion_id);
end;
$$;

revoke execute on function public.recepcion_entrar_stock_item(bigint, integer, text, bigint) from public, anon, authenticated;
grant execute on function public.recepcion_confirmar_item(uuid, bigint, date, integer, numeric)
  to anon, authenticated;

-- ── 2) Factura (cantidad y lote del papel, no del anaquel) ────────
create temp table fc_levic_factura (
  ean text primary key,
  sku text,
  qty integer not null,
  lote text not null,
  nombre text
) on commit drop;

insert into fc_levic_factura (ean, sku, qty, lote, nombre) values
  ('7506335701214', 'EQ-ACC092', 2, 'M2406436', 'HT-Bloc Accord ondansetrón 1 amp 4 mg/2 mL'),
  ('7501384541163', 'EQ-ALP0608', 1, '7230526', 'Carbamazepina Alpharma 20 tab 200 mg'),
  ('7501349020122', 'EQ-AMS132', 2, 'B26A507', 'Clonixinato de lisina AMSA 5 amp 100 mg/2 mL'),
  ('7501349014190', 'EQ-AMS147', 1, 'U26A275', 'Ácido alendrónico AMSA 30 tab 10 mg'),
  ('7501277071685', 'EQ-APO216', 3, '0806M26', 'Prochor Apotex propranolol 30 tab 40 mg'),
  ('7502209850231', 'EQ-AVT218', 2, 'SF26155', 'Zagapsol amlodipino 10 tab 5 mg'),
  ('7501342804408', 'EQ-BEA424', 3, '670188', 'Metoprolol beadvance 20 tab 100 mg'),
  ('7501842951657', 'EQ-GEN062', 2, '614015A', 'Pakid Genética paracetamol/ibuprofeno 20 tab 325/200 mg'),
  ('6358975544000', 'EQ-JAV050', 1, '0200107', 'Clorofil Jahvs solución clorofila 500 mL'),
  ('7506022315038', 'EQ-JAY216', 2, '6A0023C06', 'Navontec Jayor ondansetrón 3 amp 8 mg/4 mL'),
  ('7502211788690', 'EQ-LOE123', 1, 'R2511440', 'Diotexona Loeffler dimeticona gotero 30 mL'),
  ('7502009742798', 'EQ-MAV176', 2, '262633', 'Laritol EX Maver loratadina/ambroxol solución 30 mL'),
  ('7502009746321', 'EQ-MAV300', 2, '260451', 'Nisolver Maver prednisolona solución 100 mL'),
  ('7502009747274', 'EQ-MAV342', 2, '264180', 'Dolver Maver ibuprofeno 10 tab 600 mg'),
  ('7502009748035', 'EQ-MAV364', 2, '261915', 'Tinitrend Maver tretinoína crema 0.05% 30 g'),
  ('7502009747410', 'EQ-MAV375', 2, '260872', 'Tinitrend Maver tretinoína crema 0.05% 40 g'),
  ('7503027446279', 'EQ-PGE057', 3, 'U0400', 'Gelubrin Progela ibuprofeno 10 cáps 600 mg'),
  ('7501563380163', 'EQ-RAD081', 1, '28563', 'Fumarato ferroso Randall 50 tab 200 mg'),
  ('7501563380415', 'EQ-RAD097', 2, '21902', 'Tretinoína Randall crema 0.05% 20 g'),
  ('7502227876428', 'EQ-RAM141', 2, 'RBA029', 'Breflumar Raam flunarizina 20 tab 5 mg'),
  ('7501258203593', 'EQ-SER024', 3, '260057', 'Lonixer Serral clonixinato 10 tab 125 mg'),
  ('7501258203586', 'EQ-SER025', 3, '260186', 'Lonixer Serral clonixinato 10 tab 250 mg'),
  ('7506281106019', 'EQ-STR005', 1, 'SU01US', 'Ferro-4 Streger 30 grageas'),
  ('7501122960201', 'EQ-VAL063', 1, '430098', 'Arretin tretinoína crema 0.05% 30 g');

create temp table fc_levic_pid on commit drop as
select
  f.*,
  public.fc_buscar_producto_escaneo(f.ean) as producto_id
from fc_levic_factura f;

-- Lotes copia: mismo número que el papel, misma cantidad inicial,
-- creados al recibir esta factura, y que nadie ha vendido (siguen enteros).
-- Se conserva el más antiguo.
create temp table fc_levic_baja on commit drop as
select
  l.id as lote_id,
  l.producto_id,
  f.ean,
  l.numero_lote,
  l.cantidad_actual as piezas
from fc_levic_pid f
join public.lotes l on l.producto_id = f.producto_id
where f.producto_id is not null
  and l.numero_lote = f.lote
  and l.cantidad_inicial = f.qty
  and coalesce(l.activo, true)
  and coalesce(l.cantidad_actual, 0) > 0
  and l.cantidad_actual = l.cantidad_inicial
  and l.created_at >= timestamptz '2026-09-14 00:00:00 America/Mexico_City'
  and l.created_at < timestamptz '2026-09-18 00:00:00 America/Mexico_City'
  and l.id <> (
    select l2.id
    from public.lotes l2
    where l2.producto_id = l.producto_id
      and l2.numero_lote = f.lote
      and l2.cantidad_inicial = f.qty
      and l2.created_at >= timestamptz '2026-09-14 00:00:00 America/Mexico_City'
      and l2.created_at < timestamptz '2026-09-18 00:00:00 America/Mexico_City'
    order by l2.created_at, l2.id
    limit 1
  );

update public.lotes l
set cantidad_actual = 0,
    activo = false
from fc_levic_baja b
where l.id = b.lote_id;

insert into public.movimientos_inventario (producto_id, tipo, cantidad, motivo, usuario_id)
select
  b.producto_id,
  'ajuste',
  sum(b.piezas)::integer,
  'Corrección: recepción duplicada Levic 9012242979 (error de sistema, no merma)',
  null
from fc_levic_baja b
group by b.producto_id;

update public.productos p
set stock = coalesce((
  select sum(l.cantidad_actual)::integer
  from public.lotes l
  where l.producto_id = p.id
    and coalesce(l.activo, true)
), 0)
where p.id in (select producto_id from fc_levic_baja);

commit;

-- Factura vs vendido vs stock, ya con la copia bajada.
-- stock_antes = stock_ahora + lo que este parche quitó.
with factura(ean, sku, qty, lote, nombre) as (
  values
    ('7506335701214', 'EQ-ACC092', 2, 'M2406436', 'HT-Bloc Accord ondansetrón 1 amp 4 mg/2 mL'),
    ('7501384541163', 'EQ-ALP0608', 1, '7230526', 'Carbamazepina Alpharma 20 tab 200 mg'),
    ('7501349020122', 'EQ-AMS132', 2, 'B26A507', 'Clonixinato de lisina AMSA 5 amp 100 mg/2 mL'),
    ('7501349014190', 'EQ-AMS147', 1, 'U26A275', 'Ácido alendrónico AMSA 30 tab 10 mg'),
    ('7501277071685', 'EQ-APO216', 3, '0806M26', 'Prochor Apotex propranolol 30 tab 40 mg'),
    ('7502209850231', 'EQ-AVT218', 2, 'SF26155', 'Zagapsol amlodipino 10 tab 5 mg'),
    ('7501342804408', 'EQ-BEA424', 3, '670188', 'Metoprolol beadvance 20 tab 100 mg'),
    ('7501842951657', 'EQ-GEN062', 2, '614015A', 'Pakid Genética paracetamol/ibuprofeno 20 tab 325/200 mg'),
    ('6358975544000', 'EQ-JAV050', 1, '0200107', 'Clorofil Jahvs solución clorofila 500 mL'),
    ('7506022315038', 'EQ-JAY216', 2, '6A0023C06', 'Navontec Jayor ondansetrón 3 amp 8 mg/4 mL'),
    ('7502211788690', 'EQ-LOE123', 1, 'R2511440', 'Diotexona Loeffler dimeticona gotero 30 mL'),
    ('7502009742798', 'EQ-MAV176', 2, '262633', 'Laritol EX Maver loratadina/ambroxol solución 30 mL'),
    ('7502009746321', 'EQ-MAV300', 2, '260451', 'Nisolver Maver prednisolona solución 100 mL'),
    ('7502009747274', 'EQ-MAV342', 2, '264180', 'Dolver Maver ibuprofeno 10 tab 600 mg'),
    ('7502009748035', 'EQ-MAV364', 2, '261915', 'Tinitrend Maver tretinoína crema 0.05% 30 g'),
    ('7502009747410', 'EQ-MAV375', 2, '260872', 'Tinitrend Maver tretinoína crema 0.05% 40 g'),
    ('7503027446279', 'EQ-PGE057', 3, 'U0400', 'Gelubrin Progela ibuprofeno 10 cáps 600 mg'),
    ('7501563380163', 'EQ-RAD081', 1, '28563', 'Fumarato ferroso Randall 50 tab 200 mg'),
    ('7501563380415', 'EQ-RAD097', 2, '21902', 'Tretinoína Randall crema 0.05% 20 g'),
    ('7502227876428', 'EQ-RAM141', 2, 'RBA029', 'Breflumar Raam flunarizina 20 tab 5 mg'),
    ('7501258203593', 'EQ-SER024', 3, '260057', 'Lonixer Serral clonixinato 10 tab 125 mg'),
    ('7501258203586', 'EQ-SER025', 3, '260186', 'Lonixer Serral clonixinato 10 tab 250 mg'),
    ('7506281106019', 'EQ-STR005', 1, 'SU01US', 'Ferro-4 Streger 30 grageas'),
    ('7501122960201', 'EQ-VAL063', 1, '430098', 'Arretin tretinoína crema 0.05% 30 g')
),
pid as (
  select f.*, public.fc_buscar_producto_escaneo(f.ean) as producto_id
  from factura f
)
select
  f.sku,
  f.nombre,
  f.qty as cajas_en_factura,
  f.lote as lote_factura,
  coalesce(v.vendidas, 0) as vendidas,
  coalesce(p.stock, 0) + coalesce(b.duplicado_bajado, 0) as stock_antes,
  coalesce(b.duplicado_bajado, 0) as duplicado_bajado,
  coalesce(p.stock, 0) as stock_ahora,
  coalesce(p.stock_unidades, 0) as piezas_sueltas,
  coalesce(p.stock_blisters, 0) as blisters,
  (
    select string_agg(
      coalesce(l.numero_lote, '?') || ' x' || l.cantidad_actual::text,
      ', ' order by l.fecha_caducidad nulls first, l.id
    )
    from public.lotes l
    where l.producto_id = p.id
      and coalesce(l.activo, true)
      and coalesce(l.cantidad_actual, 0) > 0
  ) as lotes_que_quedan
from pid f
left join public.productos p on p.id = f.producto_id
left join (
  select m.producto_id, sum(m.cantidad)::integer as duplicado_bajado
  from public.movimientos_inventario m
  where m.motivo = 'Corrección: recepción duplicada Levic 9012242979 (error de sistema, no merma)'
    and m.tipo = 'ajuste'
  group by m.producto_id
) b on b.producto_id = f.producto_id
left join (
  select i.producto_id, sum(i.cantidad)::integer as vendidas
  from public.pedido_items i
  join public.pedidos ped on ped.id = i.pedido_id
  where coalesce(ped.estado::text, '') not in ('cancelado', 'anulado', 'cancelada')
  group by i.producto_id
) v on v.producto_id = f.producto_id
order by f.nombre;
