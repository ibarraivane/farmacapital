-- Corrige el cobro del 26-sep-2026 que se registró todo en efectivo ($50)
-- y en realidad fueron $30 en efectivo + $20 en la terminal BBVA.
--
-- Antes, en este orden:
--   1) sql/patch_pagos_servicio_mixto_20260926.sql
--   2) sql/patch_flujo_caja_servicios_mixto_20260926.sql
--
-- Solo toca un renglón: el único pago de servicio de ese día, en efectivo,
-- con total $50. Si hay más de uno, no adivina y no cambia nada.
-- Idempotente: si ya quedó en mixto $30 + $20, no lo vuelve a escribir.
-- El corte abierto toma el desglose al cerrar. No reescribe un corte ya guardado.

begin;

do $$
declare
  v_n    int;
  v_ps   public.pagos_servicio%rowtype;
  v_nota text := 'Corregido: $30 efectivo + $20 terminal BBVA';
  v_lista text;
begin
  if not exists (
    select 1
    from information_schema.columns
    where table_schema = 'public'
      and table_name = 'pagos_servicio'
      and column_name = 'monto_efectivo'
  ) then
    raise exception 'Falta monto_efectivo. Primero corre sql/patch_pagos_servicio_mixto_20260926.sql';
  end if;

  select * into v_ps
  from public.pagos_servicio
  where metodo_pago = 'mixto'
    and round(total_cobrado, 2) = 50
    and round(coalesce(monto_efectivo, 0), 2) = 30
    and round(coalesce(monto_tarjeta, 0), 2) = 20
    and (created_at at time zone 'America/Mexico_City')::date = date '2026-09-26'
  order by created_at desc
  limit 1;

  if v_ps.id is not null then
    raise notice 'Ya está corregido: % · efectivo % · tarjeta %',
      v_ps.folio, v_ps.monto_efectivo, v_ps.monto_tarjeta;
    return;
  end if;

  select count(*) into v_n
  from public.pagos_servicio
  where metodo_pago = 'efectivo'
    and round(total_cobrado, 2) = 50
    and (created_at at time zone 'America/Mexico_City')::date = date '2026-09-26';

  if v_n = 0 then
    raise exception 'No hay un pago de servicio del 26-sep-2026 en efectivo por $50.';
  end if;

  if v_n > 1 then
    select string_agg(
      folio || ' ' || to_char(created_at at time zone 'America/Mexico_City', 'HH24:MI') || ' ' || proveedor,
      ', ' order by created_at
    )
    into v_lista
    from public.pagos_servicio
    where metodo_pago = 'efectivo'
      and round(total_cobrado, 2) = 50
      and (created_at at time zone 'America/Mexico_City')::date = date '2026-09-26';
    raise exception 'Hay % pagos del 26-sep en efectivo por $50. No se tocó ninguno: %', v_n, v_lista;
  end if;

  select * into v_ps
  from public.pagos_servicio
  where metodo_pago = 'efectivo'
    and round(total_cobrado, 2) = 50
    and (created_at at time zone 'America/Mexico_City')::date = date '2026-09-26'
  limit 1;

  update public.pagos_servicio
  set metodo_pago = 'mixto',
      monto_efectivo = 30,
      monto_tarjeta = 20,
      liquidado_point = false,
      notas = case
        when coalesce(notas, '') ilike '%terminal BBVA%' then notas
        when coalesce(btrim(notas), '') = '' then v_nota
        else notas || ' · ' || v_nota
      end
  where id = v_ps.id
    and metodo_pago = 'efectivo'
    and round(total_cobrado, 2) = 50;

  if not found then
    raise exception 'No se pudo corregir %', v_ps.folio;
  end if;

  raise notice 'Corregido % (%): efectivo $50 → mixto $30 efectivo + $20 tarjeta BBVA',
    v_ps.folio, v_ps.proveedor;
end $$;

commit;
