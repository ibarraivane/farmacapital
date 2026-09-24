-- 24-sep-2026. Urgente: el corte de Raquel ya existe y su caja sigue abierta.
-- Cinthia no puede abrir. Las ventas de después del corte (el alcohol)
-- se quedan a nombre de Cinthia. No se toca el efectivo que Raquel declaró.
--
-- Pegar TODO en Supabase → SQL Editor → Run.
-- Si no coincide el caso, el error lo dice y no cambia nada.

begin;

do $$
declare
  v_raquel bigint;
  v_cinthia bigint;
  v_sesion public.caja_sesiones%rowtype;
  v_corte  public.cortes_caja%rowtype;
  v_hoy    date := (now() at time zone 'America/Mexico_City')::date;
  n_ped    int := 0;
  n_srv    int := 0;
begin
  select u.id into v_raquel
  from public.usuarios u
  where u.eliminado_at is null
    and u.nombre ilike '%raquel%'
  order by u.id
  limit 1;

  if v_raquel is null then
    raise exception 'No encontré el usuario de Raquel.';
  end if;

  select * into v_sesion
  from public.caja_sesiones s
  where s.empleado_id = v_raquel
    and s.estado = 'abierta'
  limit 1;

  if v_sesion.id is null then
    raise exception 'Raquel no tiene la caja abierta. El aviso ya no sale de su sesión.';
  end if;

  select * into v_corte
  from public.cortes_caja c
  where c.empleado_id = v_raquel
    and c.anulado_at is null
    and c.created_at >= (v_hoy::timestamp) at time zone 'America/Mexico_City'
    and c.created_at <  ((v_hoy + 1)::timestamp) at time zone 'America/Mexico_City'
  order by c.created_at desc
  limit 1;

  if v_corte.id is null then
    raise exception 'La caja % de Raquel sigue abierta y hoy no tiene corte. El cierre no se guardó: no la cerré a ciegas.', v_sesion.id;
  end if;

  if v_sesion.abierta_at >= v_corte.created_at then
    raise exception 'La caja abierta de Raquel (%) empezó después de su corte %. No la cerré.', v_sesion.id, v_corte.id;
  end if;

  select u.id into v_cinthia
  from public.usuarios u
  where u.eliminado_at is null
    and u.id <> v_raquel
    and (u.nombre ilike '%cinth%' or u.nombre ilike '%cynth%' or u.nombre ilike '%cintia%')
  order by u.id
  limit 1;

  update public.caja_sesiones
     set estado = 'cerrada',
         cerrada_at = v_corte.created_at,
         corte_id = v_corte.id,
         nota_apertura = concat_ws(
           ' ',
           nullif(btrim(nota_apertura), ''),
           '24-sep-2026: el corte ya estaba guardado y la sesión seguía abierta. Se cierra en la hora del corte, sin recontar.'
         )
   where id = v_sesion.id
     and estado = 'abierta';

  if v_cinthia is not null then
    update public.pedidos p
       set atendido_por = v_cinthia
     where p.atendido_por = v_raquel
       and p.created_at > v_corte.created_at;
    get diagnostics n_ped = row_count;

    update public.pagos_servicio ps
       set atendido_por = v_cinthia
     where ps.atendido_por = v_raquel
       and ps.created_at > v_corte.created_at;
    get diagnostics n_srv = row_count;
  end if;

  insert into public.audit_log (usuario_id, usuario_nombre, accion, tabla, registro_id, detalle)
  select v_raquel,
         u.nombre,
         'cerrar_caja_huerfana',
         'caja_sesiones',
         v_sesion.id::text,
         jsonb_build_object(
           'corte_id', v_corte.id,
           'cerrada_at', v_corte.created_at,
           'pedidos_a_cinthia', n_ped,
           'servicios_a_cinthia', n_srv
         )
    from public.usuarios u
   where u.id = v_raquel;

  raise notice 'Caja % cerrada con el corte %. Pedidos pasados a Cinthia: %. Servicios: %.',
    v_sesion.id, v_corte.id, n_ped, n_srv;
end $$;

commit;

select u.nombre,
       s.id as sesion,
       s.estado,
       s.turno,
       to_char(s.abierta_at at time zone 'America/Mexico_City', 'HH24:MI') as abrio,
       to_char(s.cerrada_at at time zone 'America/Mexico_City', 'HH24:MI') as cerro,
       s.corte_id
  from public.caja_sesiones s
  join public.usuarios u on u.id = s.empleado_id
 where s.fecha = (now() at time zone 'America/Mexico_City')::date
    or s.estado = 'abierta'
 order by s.abierta_at;
