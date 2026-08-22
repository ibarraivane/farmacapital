-- Corte: el efectivo sigue al cajón abierto, no al reloj de las 15:30.
-- La recarga de Mary a las 17:24 (sesión matutina aún abierta) ya no se va
-- al vespertino de Erika. 22 ago 2026. Idempotente.

begin;

create or replace function public.reconcile_shift_cash(
  p_turno text,
  p_fecha date
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_inicio timestamptz;
  v_fin    timestamptz;
  v_hay_sesion boolean := false;

  v_ef_pedidos   numeric := 0;
  v_tar_pedidos  numeric := 0;
  v_mp_pedidos   numeric := 0;
  v_spei_pedidos numeric := 0;

  v_ef_serv   numeric := 0;
  v_tar_serv  numeric := 0;

  v_dev_ef numeric := 0;
  v_dev_in numeric := 0;
  v_dev_tar numeric := 0;
  v_dev_cred numeric := 0;
begin
  if p_turno = 'matutino' then
    v_inicio := (p_fecha + time '00:00:00')     at time zone 'America/Mexico_City';
    v_fin    := (p_fecha + time '15:29:59.999') at time zone 'America/Mexico_City';
  else
    v_inicio := (p_fecha + time '15:30:00')     at time zone 'America/Mexico_City';
    v_fin    := (p_fecha + time '23:59:59.999') at time zone 'America/Mexico_City';
  end if;

  select exists (
    select 1 from public.caja_sesiones s
    where s.fecha = p_fecha and s.turno = p_turno
  ) into v_hay_sesion;

  select
    coalesce(sum(total - coalesce(monto_credito, 0)) filter (where metodo_pago = 'efectivo'), 0),
    coalesce(sum(total - coalesce(monto_credito, 0)) filter (where metodo_pago = 'tarjeta'),  0),
    coalesce(sum(total - coalesce(monto_credito, 0)) filter (where metodo_pago in ('mercadopago','mercadopago_point')), 0),
    coalesce(sum(total - coalesce(monto_credito, 0)) filter (where metodo_pago = 'spei'),     0)
  into v_ef_pedidos, v_tar_pedidos, v_mp_pedidos, v_spei_pedidos
  from public.pedidos p
  where p.estado = 'completado'
    and (
      (
        v_hay_sesion
        and exists (
          select 1 from public.caja_sesiones s
          where s.fecha = p_fecha and s.turno = p_turno
            and p.created_at >= s.abierta_at
            and p.created_at <= coalesce(s.cerrada_at, now())
        )
      )
      or (
        not v_hay_sesion
        and p.created_at between v_inicio and v_fin
      )
    );

  select
    coalesce(sum(total_cobrado) filter (where metodo_pago = 'efectivo'), 0),
    coalesce(sum(total_cobrado) filter (where metodo_pago = 'tarjeta'),  0)
  into v_ef_serv, v_tar_serv
  from public.pagos_servicio ps
  where (
      (
        v_hay_sesion
        and exists (
          select 1 from public.caja_sesiones s
          where s.fecha = p_fecha and s.turno = p_turno
            and ps.created_at >= s.abierta_at
            and ps.created_at <= coalesce(s.cerrada_at, now())
        )
      )
      or (
        not v_hay_sesion
        and ps.created_at between v_inicio and v_fin
      )
    );

  select
    coalesce(sum(monto_efectivo), 0),
    coalesce(sum(monto_efectivo_ingreso), 0),
    coalesce(sum(monto_tarjeta_ingreso), 0),
    coalesce(sum(monto_credito), 0)
  into v_dev_ef, v_dev_in, v_dev_tar, v_dev_cred
  from public.devoluciones d
  where d.estado = 'aprobada'
    and (
      (
        v_hay_sesion
        and exists (
          select 1 from public.caja_sesiones s
          where s.fecha = p_fecha and s.turno = p_turno
            and d.created_at >= s.abierta_at
            and d.created_at <= coalesce(s.cerrada_at, now())
        )
      )
      or (
        not v_hay_sesion
        and d.created_at between v_inicio and v_fin
      )
    );

  return jsonb_build_object(
    'efectivo_sistema',   v_ef_pedidos + v_ef_serv - v_dev_ef + v_dev_in,
    'tarjeta',            v_tar_pedidos + v_tar_serv + v_dev_tar,
    'mercadopago',        v_mp_pedidos,
    'spei',               v_spei_pedidos,
    'efectivo_pedidos',   v_ef_pedidos,
    'efectivo_servicios', v_ef_serv,
    'efectivo_devoluciones', v_dev_ef,
    'efectivo_cambios_ingreso', v_dev_in,
    'credito_otorgado',   v_dev_cred,
    'tarjeta_pedidos',    v_tar_pedidos,
    'tarjeta_servicios',  v_tar_serv,
    'tarjeta_cambios',    v_dev_tar,
    'rango_inicio',       v_inicio,
    'rango_fin',          v_fin,
    'por_sesion',         v_hay_sesion
  );
end;
$$;

grant execute on function public.reconcile_shift_cash(text, date) to anon, authenticated;

-- Cuadrar cortes del 21 ago con la regla nueva (cajón, no reloj).
update public.cortes_caja c
set efectivo_sistema = coalesce(
  (public.reconcile_shift_cash(c.turno, c.fecha)->>'efectivo_sistema')::numeric, 0
)
where c.id in (12, 13);

commit;
