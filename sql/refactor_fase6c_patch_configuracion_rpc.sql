-- ============================================================
-- FARMAX — Parche: escritura en configuracion vía RPC (F6)
-- ============================================================
-- Tras F6a, anon/authenticated no tienen INSERT/UPDATE directo.
-- El módulo Metas y Precios (ConfigConsultorioModule) debe usar esta RPC.
--
-- Quién: cualquier empleado con sesión válida (misma regla que otras
-- operaciones de staff; el UI ya restringe el módulo por rol).
--
-- Ejecutar en Supabase SQL Editor (idempotente).
-- ============================================================

begin;

create or replace function public.empleado_upsert_configuracion(
  p_session_token uuid,
  p_clave         text,
  p_valor         text
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  k text := trim(coalesce(p_clave, ''));
begin
  perform public.fn_require_empleado(p_session_token);

  if k = '' then
    return jsonb_build_object('success', false, 'error', 'Clave requerida');
  end if;

  insert into public.configuracion (clave, valor)
  values (k, coalesce(p_valor, ''))
  on conflict (clave) do update
    set valor = excluded.valor;

  return jsonb_build_object('success', true);
end;
$$;

grant execute on function public.empleado_upsert_configuracion(uuid, text, text) to anon, authenticated;

commit;
