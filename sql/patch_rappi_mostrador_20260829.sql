-- ============================================================================
-- Rappi: no publicar cajas de mostrador ni cajas abiertas
-- 2026-08-29
--
-- 1) C/40+ con venta_unidad (Alka-Seltzer C/100, Aspirina 80, Cafiaspirina
--    C/100, etc.) no salen a Rappi: se venden por pieza en mostrador.
-- 2) Si ya hay stock_unidades, esa caja está abierta: se descuenta 1 del
--    stock publicado (y luego el colchón de 2).
--
-- Idempotente. Correr en SQL Editor (postgres / service role).
-- ============================================================================

begin;

create or replace function public.rappi_cajas_cerradas(
  p_stock integer,
  p_venta_unidad boolean,
  p_stock_unidades integer,
  p_unidades_por_caja integer
)
returns integer
language sql
immutable
as $$
  select case
    when coalesce(p_venta_unidad, false) and coalesce(p_unidades_por_caja, 0) >= 40 then 0
    when coalesce(p_venta_unidad, false) and coalesce(p_stock_unidades, 0) > 0
      then greatest(coalesce(p_stock, 0) - 1, 0)
    else greatest(coalesce(p_stock, 0), 0)
  end;
$$;

-- Nueva firma (4 args). La de 2 args se borra al final, cuando el trigger ya no la usa.
create or replace function public.rappi_producto_eligible(
  p_activo boolean,
  p_requiere_receta boolean,
  p_venta_unidad boolean,
  p_unidades_por_caja integer
)
returns boolean
language sql
immutable
as $$
  select coalesce(p_activo, true)
     and not coalesce(p_requiere_receta, false)
     and not (coalesce(p_venta_unidad, false) and coalesce(p_unidades_por_caja, 0) >= 40);
$$;

create or replace function public.trg_productos_rappi_sync_queue()
returns trigger
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_reserva integer;
  v_sku text;
  v_old_sr integer;
  v_new_sr integer;
  v_old_disp boolean;
  v_new_disp boolean;
  v_old_elig boolean;
  v_new_elig boolean;
  v_old_cajas integer;
  v_new_cajas integer;
  v_enqueue boolean := false;
  v_reason text;
begin
  v_sku := nullif(btrim(coalesce(new.sku, '')), '');
  if v_sku is null then
    return new;
  end if;

  v_reserva := public.rappi_cfg_int('rappi_reserva_mostrador', 2);
  v_new_elig := public.rappi_producto_eligible(
    new.activo, new.requiere_receta,
    new.venta_unidad, new.unidades_por_caja
  );
  v_new_cajas := public.rappi_cajas_cerradas(
    new.stock, new.venta_unidad, new.stock_unidades, new.unidades_por_caja
  );
  v_new_sr := public.rappi_stock_publicado(v_new_cajas, v_reserva);
  v_new_disp := v_new_elig and v_new_sr > 0;

  if tg_op = 'INSERT' then
    v_enqueue := v_new_disp;
    v_reason := 'insert';
  else
    v_old_elig := public.rappi_producto_eligible(
      old.activo, old.requiere_receta,
      old.venta_unidad, old.unidades_por_caja
    );
    v_old_cajas := public.rappi_cajas_cerradas(
      old.stock, old.venta_unidad, old.stock_unidades, old.unidades_por_caja
    );
    v_old_sr := public.rappi_stock_publicado(v_old_cajas, v_reserva);
    v_old_disp := v_old_elig and v_old_sr > 0;

    if v_old_disp is distinct from v_new_disp then
      v_enqueue := true;
      v_reason := 'availability';
    elsif v_new_disp and ((v_old_sr <= 5) is distinct from (v_new_sr <= 5)) then
      v_enqueue := true;
      v_reason := 'threshold';
    end if;
  end if;

  if not v_enqueue then
    return new;
  end if;

  insert into public.rappi_sync_queue (
    producto_id, sku, accion, payload, estado, available_at
  ) values (
    new.id,
    v_sku,
    'disponibilidad',
    jsonb_build_object(
      'sku', v_sku,
      'producto_id', new.id,
      'stock_local', coalesce(new.stock, 0),
      'stock_unidades', coalesce(new.stock_unidades, 0),
      'cajas_cerradas', v_new_cajas,
      'reserva_mostrador', v_reserva,
      'stock_rappi', v_new_sr,
      'disponible', v_new_disp,
      'eligible', v_new_elig,
      'reason', v_reason
    ),
    'pendiente',
    now()
  )
  on conflict (sku) where (estado = 'pendiente')
  do update set
    producto_id = excluded.producto_id,
    payload = excluded.payload,
    updated_at = now(),
    available_at = least(public.rappi_sync_queue.available_at, now());

  return new;
end;
$$;

drop trigger if exists trg_productos_rappi_sync on public.productos;
create trigger trg_productos_rappi_sync
  after insert or update of stock, activo, requiere_receta, venta_unidad, unidades_por_caja, stock_unidades
  on public.productos
  for each row
  execute procedure public.trg_productos_rappi_sync_queue();

comment on function public.rappi_cajas_cerradas(integer, boolean, integer, integer) is
  'Cajas que sí pueden ir a Rappi: 0 si C/40+ de mostrador; stock-1 si ya hay sueltas.';

drop function if exists public.rappi_producto_eligible(boolean, boolean);

commit;
