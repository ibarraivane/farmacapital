-- Recargos de recibos (Izzi, CFE, Sky…) editables por el admin.
-- Las recargas de tiempo aire siguen en 0.
-- Ejecutar en Supabase SQL Editor. Idempotente.

begin;

insert into public.configuracion (clave, valor)
values (
  'servicios_recargos',
  '{"cfe":8,"telmex":8,"totalplay":8,"izzi":10,"sky":10,"agua":8,"gas":8,"otro":10}'
)
on conflict (clave) do nothing;

create or replace function public.admin_set_servicios_recargos(
  p_session_token uuid,
  p_recargos      jsonb
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_actor bigint;
  v_id text;
  v_val numeric;
  v_clean jsonb := '{}'::jsonb;
  v_ids text[] := array['cfe','telmex','totalplay','izzi','sky','agua','gas','otro'];
begin
  v_actor := public.fn_require_admin(p_session_token);

  if p_recargos is null or jsonb_typeof(p_recargos) <> 'object' then
    return jsonb_build_object('success', false, 'error', 'recargos_invalidos');
  end if;

  foreach v_id in array v_ids loop
    begin
      v_val := round((p_recargos ->> v_id)::numeric, 2);
    exception when others then
      return jsonb_build_object('success', false, 'error', 'El recargo de ' || v_id || ' es inválido');
    end;
    if v_val is null or v_val <= 0 then
      return jsonb_build_object('success', false, 'error', 'El recargo de ' || v_id || ' tiene que ser mayor a 0');
    end if;
    if v_val > 200 then
      return jsonb_build_object('success', false, 'error', 'El recargo de ' || v_id || ' no puede pasar de $200');
    end if;
    v_clean := v_clean || jsonb_build_object(v_id, v_val);
  end loop;

  insert into public.configuracion (clave, valor)
  values ('servicios_recargos', v_clean::text)
  on conflict (clave) do update set valor = excluded.valor;

  begin
    insert into public.audit_log (usuario_id, usuario_nombre, accion, tabla, registro_id, detalle)
    values (
      v_actor,
      (select nombre from public.usuarios where id = v_actor),
      'set_servicios_recargos',
      'configuracion',
      'servicios_recargos',
      v_clean::text
    );
  exception when others then null;
  end;

  return jsonb_build_object('success', true, 'recargos', v_clean);
end;
$$;

grant execute on function public.admin_set_servicios_recargos(uuid, jsonb)
  to anon, authenticated;

commit;
