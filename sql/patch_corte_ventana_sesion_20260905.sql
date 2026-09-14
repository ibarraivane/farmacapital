-- ============================================================
-- Corte: la ventana de efectivo arranca al ABRIR, no en el corte previo.
--
-- Bug (5-sep-2026, René): sistema $214 = ventas de hoy $184 + $30 que
-- ocurrieron después del corte anterior. Ese $30 ya estaba en el cajón
-- cuando contaron el fondo ($4,443.50). Sumarlo otra vez infló el
-- esperado $30 y fabricó un faltante de $23.
--
-- Fórmula que cuadra con el cajón:
--   esperado = fondo_contado_al_abrir + movimientos_desde_que_abrió
--
-- Lo vendido entre el corte previo y esta apertura NO se vuelve a sumar:
-- ya viaja dentro del fondo. El detalle puede mencionarlo; el esperado no.
--
-- Idempotente. Pegar en Supabase → SQL Editor.
-- ============================================================

begin;

create or replace function public.fn_ventana_corte(
  p_sesion_id bigint default null,
  p_fin       timestamptz default now()
)
returns jsonb
language plpgsql
stable
set search_path = public, pg_temp
as $$
declare
  v_prev   timestamptz;
  v_abrio  timestamptz;
  v_inicio timestamptz;
begin
  v_prev := public.fn_corte_previo_at(p_fin);

  if p_sesion_id is not null then
    select abierta_at into v_abrio from public.caja_sesiones where id = p_sesion_id;
  end if;

  -- Con sesión: desde que contaron el fondo. Sin sesión (ajuste admin):
  -- desde el corte previo, o el inicio del día.
  if v_abrio is not null then
    v_inicio := v_abrio;
  else
    v_inicio := coalesce(
      v_prev,
      (((p_fin at time zone 'America/Mexico_City')::date)::timestamp)
        at time zone 'America/Mexico_City'
    );
  end if;

  return jsonb_build_object(
    'inicio', v_inicio,
    'fin', p_fin,
    'corte_previo', v_prev,
    'abierta_at', v_abrio
  );
end;
$$;

comment on function public.fn_ventana_corte(bigint, timestamptz) is
  'Ventana de efectivo del corte: con caja abierta, desde abierta_at. El corte previo no se re-suma: ese dinero ya iba en el fondo.';

comment on function public.fn_corte_previo_at(timestamptz) is
  'Momento del último corte vigente. Ya no es el inicio de la ventana de efectivo si hay sesión abierta.';

grant execute on function public.fn_ventana_corte(bigint, timestamptz) to anon, authenticated;

commit;
