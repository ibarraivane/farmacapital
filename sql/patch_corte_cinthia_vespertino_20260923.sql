-- Cierre del vespertino de Cynthia. Ella ya no está en la tablet.
-- No usa su clave: toma la caja que sigue abierta a su nombre.
-- Conteo de la pantalla: fondo 3393, efectivo 4837.
--
-- Pegar TODO en Supabase → SQL Editor → Run.
-- Si no coincide el caso (no es su caja, el fondo no es 3393, o ya hay corte),
-- falla con "division by zero" y no cambia nada.
-- Al final tiene que salir una fila con corte_id y diferencia.

begin;

do $$
declare
  v_user_id bigint;
  v_nombre  text;
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
begin
  select u.id, u.nombre into v_user_id, v_nombre
  from public.usuarios u
  where u.eliminado_at is null
    and (u.nombre ilike '%cinth%' or u.nombre ilike '%cynth%' or u.nombre ilike '%cintia%');
  if v_user_id is null or (select count(*) from public.usuarios u
        where u.eliminado_at is null
          and (u.nombre ilike '%cinth%' or u.nombre ilike '%cynth%' or u.nombre ilike '%cintia%')) <> 1 then
    raise exception 'division by zero';
  end if;

  select * into v_sesion
  from public.caja_sesiones s
  where s.empleado_id = v_user_id
    and s.estado = 'abierta';
  if v_sesion.id is null
     or (select count(*) from public.caja_sesiones s
           where s.empleado_id = v_user_id and s.estado = 'abierta') <> 1
     or v_sesion.fondo_contado <> 3393
     or v_sesion.turno <> 'vespertino' then
    raise exception 'division by zero';
  end if;

  v_decl := public.fn_sumar_denominaciones(v_denoms);
  if v_decl <> 4837 then
    raise exception 'division by zero';
  end if;

  v_fin    := now();
  v_vent   := public.fn_ventana_corte(v_sesion.id, v_fin);
  v_inicio := (v_vent->>'inicio')::timestamptz;
  v_ahora  := v_fin at time zone 'America/Mexico_City';

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
    v_sesion.turno, v_user_id, v_ahora::date,
    (v_inicio at time zone 'America/Mexico_City')::time, v_ahora::time,
    v_decl, v_sistema, v_sesion.fondo_contado,
    v_tarjeta, v_spei, v_mp,
    v_nombre, v_denoms,
    'Cierre de gerencia con el conteo de Cynthia. Ella ya no estaba en la tablet.'
  ) returning * into v_fila;

  update public.caja_sesiones
     set estado = 'cerrada',
         cerrada_at = v_fin,
         corte_id = v_fila.id
   where id = v_sesion.id
     and estado = 'abierta';

  begin
    insert into public.audit_log (usuario_id, usuario_nombre, accion, tabla, registro_id, detalle)
    values (v_user_id, v_nombre, 'corte_caja', 'cortes_caja', v_fila.id::text,
      jsonb_build_object(
        'turno', v_sesion.turno,
        'diferencia', v_fila.diferencia,
        'total', v_fila.total_general,
        'fondo', v_fila.fondo_inicial,
        'declarado', v_decl,
        'hecho_por', 'gerencia',
        'sesion_id', v_sesion.id
      ));
  exception when others then null;
  end;
end
$$;

select c.id as corte_id,
       c.turno,
       c.fondo_inicial,
       c.efectivo_declarado,
       c.efectivo_sistema,
       c.diferencia,
       c.total_tarjeta,
       c.total_mercadopago,
       s.estado as sesion
from public.cortes_caja c
join public.caja_sesiones s on s.corte_id = c.id
join public.usuarios u on u.id = c.empleado_id
where u.nombre ilike '%cinth%'
   or u.nombre ilike '%cynth%'
   or u.nombre ilike '%cintia%'
order by c.id desc
limit 1;

commit;
