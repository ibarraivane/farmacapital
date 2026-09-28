-- Aspirina Junior C/60 (FC-8494226 · 7501008494226)
--
-- La caja trae 60 tabletas. unidades_por_caja estuvo en 40
-- (sql/pricing/generated/completar_empaque_unidades_2026-08-15.sql).
-- Ese 40 se quedó en stock_unidades. Mientras había caja cerrada el POS
-- decía "1 en stock". Al vender la última caja el letrero pasa a "40 piezas"
-- aunque el anaquel quedó vacío.
--
-- 1) Corrige el empaque a 60 y, si ya no hay caja vendible, pone las sueltas en 0.
-- 2) De aquí en adelante, si se vende la última caja de un producto por pieza
--    y esas sueltas no salieron de "Abrir caja", se borran al cerrar la transacción.
--
-- Pegar en Supabase → SQL Editor → Run.

begin;

do $$
declare
  r record;
  v_cajas integer;
  v_motivo text := 'Aspirina Junior: quitar sueltas fantasma tras vender la última caja';
begin
  for r in
    select p.id, coalesce(p.stock_unidades, 0) as sueltas, coalesce(p.unidades_por_caja, 0) as upc
    from public.productos p
    where p.sku in ('FC-8494226', 'FC-08494226')
       or p.codigo_barras = '7501008494226'
    for update
  loop
    select coalesce(sum(l.cantidad_actual), 0)::integer
      into v_cajas
    from public.lotes l
    where l.producto_id = r.id
      and coalesce(l.activo, true) = true
      and coalesce(l.cantidad_actual, 0) > 0
      and (l.fecha_caducidad is null or l.fecha_caducidad >= current_date);

    update public.productos
    set
      unidades_por_caja = case when r.upc in (0, 40) then 60 else unidades_por_caja end,
      stock_unidades = case when v_cajas = 0 then 0 else stock_unidades end
    where id = r.id;

    if v_cajas = 0 and r.sueltas > 0 and not exists (
      select 1
      from public.movimientos_inventario m
      where m.producto_id = r.id
        and m.motivo = v_motivo
    ) then
      insert into public.movimientos_inventario (producto_id, tipo, cantidad, motivo)
      values (r.id, 'ajuste', r.sueltas, v_motivo);
    end if;
  end loop;
end $$;

create or replace function public.fn_limpiar_piezas_fantasma_sin_caja()
returns trigger
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_pid bigint;
  v_cajas integer;
  v_sueltas integer;
  v_venta boolean;
  v_abrio boolean;
begin
  v_pid := coalesce(new.producto_id, old.producto_id);
  if v_pid is null then
    return null;
  end if;

  select coalesce(p.venta_unidad, false), coalesce(p.stock_unidades, 0)
    into v_venta, v_sueltas
  from public.productos p
  where p.id = v_pid
  for update;

  if not found or not v_venta or v_sueltas <= 0 then
    return null;
  end if;

  select coalesce(sum(l.cantidad_actual), 0)::integer
    into v_cajas
  from public.lotes l
  where l.producto_id = v_pid
    and coalesce(l.activo, true) = true
    and coalesce(l.cantidad_actual, 0) > 0
    and (l.fecha_caducidad is null or l.fecha_caducidad >= current_date);

  if v_cajas > 0 then
    return null;
  end if;

  select exists (
    select 1
    from public.movimientos_inventario m
    where m.producto_id = v_pid
      and m.motivo ilike 'Abrir caja%'
  ) into v_abrio;

  if v_abrio then
    return null;
  end if;

  update public.productos
  set stock_unidades = 0
  where id = v_pid
    and coalesce(stock_unidades, 0) <> 0;

  insert into public.movimientos_inventario (producto_id, tipo, cantidad, motivo)
  values (
    v_pid,
    'ajuste',
    v_sueltas,
    'Piezas sueltas fantasma: no hubo abrir caja y ya no quedan cajas'
  );

  return null;
end;
$$;

drop trigger if exists trg_limpiar_piezas_fantasma_sin_caja on public.lotes;

create constraint trigger trg_limpiar_piezas_fantasma_sin_caja
after insert or update or delete on public.lotes
deferrable initially deferred
for each row
execute function public.fn_limpiar_piezas_fantasma_sin_caja();

commit;
