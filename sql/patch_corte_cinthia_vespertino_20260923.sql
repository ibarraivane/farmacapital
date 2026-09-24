-- Cierre del turno de Cynthia con el conteo de la pantalla (efectivo 4837).
-- No exige que la caja siga abierta ni que el turno diga vespertino:
-- usa su sesión de hoy que todavía no tiene corte.
--
-- Pegar TODO en Supabase → SQL Editor → Run.
-- Si ya tiene corte, no inserta otro: muestra el que ya está.
-- Si no hay sesión suya de hoy, el mensaje lista lo que sí encontró.

begin;

do $$
declare
  v_user_id bigint;
  v_nombre  text;
  v_nombres text;
  v_sesion  public.caja_sesiones%rowtype;
  v_denoms  jsonb := '{"500":4,"200":4,"100":11,"50":17,"10":4,"5":5,"2":3,"1":16}'::jsonb;
  v_decl    numeric;
  v_vent    jsonb;
  v_inicio  timestamptz;
  v_fin     timestamptz;
  v_r       jsonb;
  v_sistema numeric;
  v_tarjeta numeric;
  v_mp      numeric;
  v_spei    numeric;
  v_fila    public.cortes_caja%rowtype;
  v_ahora   timestamp;
  v_fecha   date;
  v_diag    text;
begin
  select count(*), string_agg(u.id::text || ' ' || u.nombre, ', ' order by u.id)
    into v_user_id, v_nombres
  from public.usuarios u
  where u.eliminado_at is null
    and (u.nombre ilike '%cinth%' or u.nombre ilike '%cynth%' or u.nombre ilike '%cintia%');

  if v_user_id is distinct from 1 then
    raise exception 'Usuarios que coinciden con Cynthia: %', coalesce(v_nombres, '(ninguno)');
  end if;

  select u.id, u.nombre into v_user_id, v_nombre
  from public.usuarios u
  where u.eliminado_at is null
    and (u.nombre ilike '%cinth%' or u.nombre ilike '%cynth%' or u.nombre ilike '%cintia%');

  v_ahora := now() at time zone 'America/Mexico_City';
  v_fecha := v_ahora::date;

  -- Ya cortó hoy: no duplicar.
  if exists (
    select 1 from public.cortes_caja c
    where c.empleado_id = v_user_id
      and c.anulado_at is null
      and c.created_at >= (v_fecha::timestamp at time zone 'America/Mexico_City')
      and c.created_at <  ((v_fecha + 1)::timestamp at time zone 'America/Mexico_City')
  ) then
    return;
  end if;

  select * into v_sesion
  from public.caja_sesiones s
  where s.empleado_id = v_user_id
    and s.estado = 'abierta'
  order by s.abierta_at desc
  limit 1;

  if v_sesion.id is null then
    select * into v_sesion
    from public.caja_sesiones s
    where s.empleado_id = v_user_id
      and s.corte_id is null
      and s.fecha >= v_fecha - 1
    order by s.abierta_at desc
    limit 1;
  end if;

  if v_sesion.id is null then
    select string_agg(
             format('id=%s estado=%s turno=%s fondo=%s fecha=%s abierta=%s corte=%s',
                    s.id, s.estado, s.turno, s.fondo_contado, s.fecha, s.abierta_at, s.corte_id),
             ' | ' order by s.abierta_at desc)
      into v_diag
    from (
      select * from public.caja_sesiones
      where empleado_id = v_user_id
      order by abierta_at desc
      limit 5
    ) s;
    raise exception 'No hay sesión de Cynthia sin corte (hoy o ayer). Últimas: %', coalesce(v_diag, '(ninguna)');
  end if;

  v_decl := public.fn_sumar_denominaciones(v_denoms);
  if v_decl <> 4837 then
    raise exception 'El desglose no suma 4837 (sumó %)', v_decl;
  end if;

  v_fin    := now();
  v_vent   := public.fn_ventana_corte(v_sesion.id, v_fin);
  v_inicio := (v_vent->>'inicio')::timestamptz;

  v_r       := public.reconcile_cash_rango(v_inicio, v_fin);
  v_sistema := coalesce((v_r->>'efectivo_sistema')::numeric, 0);
  v_tarjeta := coalesce((v_r->>'tarjeta')::numeric, 0);
  v_mp      := coalesce((v_r->>'mercadopago')::numeric, 0);
  v_spei    := coalesce((v_r->>'spei')::numeric, 0);

  insert into public.cortes_caja (
    turno, empleado_id, fecha, hora_apertura, hora_cierre,
    efectivo_declarado, efectivo_sistema, fondo_inicial,
    total_tarjeta, total_spei, total_mercadopago,
    contado_por, denominaciones, notas
  ) values (
    v_sesion.turno, v_user_id, v_fecha,
    (v_inicio at time zone 'America/Mexico_City')::time, v_ahora::time,
    v_decl, v_sistema, v_sesion.fondo_contado,
    v_tarjeta, v_spei, v_mp,
    v_nombre, v_denoms,
    'Cierre de gerencia con el conteo de Cynthia. Ella ya no estaba en la tablet.'
  ) returning * into v_fila;

  update public.caja_sesiones
     set estado = 'cerrada',
         cerrada_at = coalesce(cerrada_at, v_fin),
         corte_id = v_fila.id
   where id = v_sesion.id
     and corte_id is null;
end
$$;

select c.id as corte_id,
       u.nombre,
       c.turno,
       c.fondo_inicial,
       c.efectivo_declarado,
       c.efectivo_sistema,
       c.diferencia,
       c.total_tarjeta,
       c.total_mercadopago,
       s.estado as sesion,
       s.id as sesion_id
from public.cortes_caja c
join public.usuarios u on u.id = c.empleado_id
left join public.caja_sesiones s on s.corte_id = c.id
where c.anulado_at is null
  and (u.nombre ilike '%cinth%' or u.nombre ilike '%cynth%' or u.nombre ilike '%cintia%')
  and c.created_at >= ((now() at time zone 'America/Mexico_City')::date::timestamp at time zone 'America/Mexico_City')
order by c.id desc
limit 1;

commit;
