-- ============================================================================
-- PDF del mes: generado_por comparaba usuarios.id (integer) con auth.uid()
--
-- Postgres: operator does not exist: integer = uuid
-- FarmaCapital no usa auth.uid(). El nombre sale de la sesión del empleado.
--
-- Pegar TODO en Supabase → SQL Editor → Run. Idempotente.
-- ============================================================================

begin;

create or replace function public.rpc_reporte_mensual(p_anio int, p_mes int)
returns jsonb
language plpgsql stable security definer set search_path = public as $$
declare
  v_desde   timestamp;
  v_hasta   timestamp;
  v_corte   timestamp;          -- fin real (si el mes está en curso, hoy)
  v_parcial boolean;
  v_dias    int;
  v_pdesde  timestamp;
  v_phasta  timestamp;
  v_hoy     timestamp := fn_rep_local(now());
begin
  perform fn_rep_exige_admin();

  v_desde := make_timestamp(p_anio, p_mes, 1, 0, 0, 0);
  v_hasta := v_desde + interval '1 month';
  v_parcial := v_hoy < v_hasta;
  v_corte := least(v_hasta, date_trunc('day', v_hoy) + interval '1 day');

  -- Mes anterior comparado contra el MISMO TRAMO, no contra el mes completo.
  v_dias   := (v_corte::date - v_desde::date);
  v_pdesde := v_desde - interval '1 month';
  v_phasta := case when v_parcial then v_pdesde + (v_dias || ' days')::interval
                   else v_desde end;

  return jsonb_build_object(
    'meta', jsonb_build_object(
      'anio', p_anio, 'mes', p_mes,
      'desde', v_desde, 'hasta', v_corte,
      'parcial', v_parcial,
      'generado_at', v_hoy,
      -- usuarios.id es integer. auth.uid() es uuid y truena
      -- "operator does not exist: integer = uuid". La sesión es el token.
      'generado_por', (
        select u.nombre
        from public.usuarios u
        join public.sesiones s on s.usuario_id = u.id
        where s.token = nullif(current_setting('farmacapital.session_token', true), '')::uuid
          and s.revoked_at is null
          and s.expires_at > now()
        limit 1
      ),
      'zona', 'America/Mexico_City'),
    'resumen',      fn_rep_resumen(v_desde, v_corte),
    'previo',       fn_rep_resumen(v_pdesde, v_phasta),
    'crecimiento',  fn_rep_crecimiento(v_desde, v_corte),
    'tiempo',       fn_rep_tiempo(v_desde, v_corte),
    'productos',    fn_rep_productos(v_desde, v_corte),
    'inventario',   fn_rep_inventario(v_desde, v_corte),
    'dinero',       fn_rep_dinero(v_desde, v_corte),
    'personal',     fn_rep_personal(v_desde, v_corte)
  );
end;
$$;

commit;
