-- ============================================================
-- FARMAX — Parche: alertas_legales (badges + COFEPRIS + dashboard)
-- ============================================================
-- Síntoma: "permission denied for table alertas_legales" desde
-- PostgREST aun con RLS USING(true) si falta GRANT SELECT, o si
-- el proyecto quedó sin policy.
--
-- 1) Repara GRANT + policy idempotente.
-- 2) RPCs admin para leer sin depender del grant (SECURITY DEFINER).
--
-- Ejecutar en Supabase SQL Editor después de F6a + F6c + F6b patch COFEPRIS.
-- ============================================================

begin;

-- Reparar privilegio de lectura REST (PostgREST = anon/authenticated)
grant select on public.alertas_legales to anon, authenticated;

alter table public.alertas_legales enable row level security;

drop policy if exists rls_alertas_legales_rest_read on public.alertas_legales;
create policy rls_alertas_legales_rest_read
  on public.alertas_legales for select
  to anon, authenticated
  using (true);


-- Lista completa para módulo COFEPRIS (mismo shape que select *)
create or replace function public.admin_listar_alertas_legales(p_session_token uuid)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
begin
  perform public.fn_require_admin(p_session_token);
  return coalesce(
    (select jsonb_agg(to_jsonb(a) order by a.nombre) from public.alertas_legales a),
    '[]'::jsonb
  );
end;
$$;

grant execute on function public.admin_listar_alertas_legales(uuid) to anon, authenticated;


-- Ventana COFEPRIS (30 días): items + totales para dashboard y badges
create or replace function public.admin_alertas_cofepris_ventana(
  p_session_token uuid,
  p_limite        date,
  p_hoy           date
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_items jsonb;
  v_total int;
  v_venc  int;
begin
  perform public.fn_require_admin(p_session_token);

  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'id', a.id,
        'nombre', a.nombre,
        'fecha_vencimiento', a.fecha_vencimiento
      )
      order by a.fecha_vencimiento
    ),
    '[]'::jsonb
  )
  into v_items
  from public.alertas_legales a
  where a.activo = true
    and a.fecha_vencimiento is not null
    and a.fecha_vencimiento <= p_limite;

  v_total := coalesce(jsonb_array_length(v_items), 0);

  select count(*)::int into v_venc
  from public.alertas_legales a
  where a.activo = true
    and a.fecha_vencimiento is not null
    and a.fecha_vencimiento <= p_limite
    and a.fecha_vencimiento < p_hoy;

  return jsonb_build_object(
    'items', v_items,
    'total_ventana', v_total,
    'vencidas', v_venc
  );
end;
$$;

grant execute on function public.admin_alertas_cofepris_ventana(uuid, date, date) to anon, authenticated;

commit;
