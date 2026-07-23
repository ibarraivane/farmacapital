-- FarmaCapital — Corregir nombre legacy «Farmax» en alertas legales (COFEPRIS / IMPI)
-- Ejecutar en Supabase SQL Editor (query separada del password reset).

update public.alertas_legales
set nombre = regexp_replace(nombre, '\mFarmax\M', 'FarmaCapital', 'gi')
where nombre ~* '\mfarmax\M';

create or replace function public.admin_corregir_marca_alertas_legales(p_session_token uuid)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare v_n int := 0;
begin
  perform public.fn_require_admin(p_session_token);

  update public.alertas_legales
  set nombre = regexp_replace(nombre, '\mFarmax\M', 'FarmaCapital', 'gi')
  where nombre ~* '\mfarmax\M';
  get diagnostics v_n = row_count;

  return jsonb_build_object('success', true, 'nombres', v_n);
end;
$$;

grant execute on function public.admin_corregir_marca_alertas_legales(uuid) to anon, authenticated;
