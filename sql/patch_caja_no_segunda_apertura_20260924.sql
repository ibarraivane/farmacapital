-- Un reinicio a mitad del cierre no debe pedir abrir el otro turno.
-- Si ya hubo caja hoy y la persona no cubre los dos, turno_abrir queda null.
-- Pegar en Supabase → SQL Editor → Run.

begin;

create or replace function public.fn_turno_abrir_hoy(p_user_id bigint)
returns text
language plpgsql
volatile
set search_path = public, pg_temp
as $$
declare
  v_asignado text;
  v_ahora    timestamp;
  v_minutos  int;
  v_fecha    date;
  v_ya_mat   boolean;
  v_ya_vesp  boolean;
  v_reloj    text;
begin
  v_asignado := public.fn_turno_caja_de(p_user_id);
  if v_asignado is null then
    return null;
  end if;

  v_ahora   := now() at time zone 'America/Mexico_City';
  v_fecha   := v_ahora::date;
  v_minutos := (extract(hour from v_ahora)::int * 60)
             + extract(minute from v_ahora)::int;
  v_reloj   := case
                 when v_minutos < (15 * 60 + 30) then 'matutino'
                 else 'vespertino'
               end;

  v_ya_mat  := public.fn_empleado_ya_tuvo_turno_hoy(p_user_id, 'matutino',   v_fecha);
  v_ya_vesp := public.fn_empleado_ya_tuvo_turno_hoy(p_user_id, 'vespertino', v_fecha);

  if v_ya_mat and v_ya_vesp then
    return null;
  end if;

  -- Ya tuvo una caja y no cubre ambos: no encadenar el otro turno.
  if (v_ya_mat or v_ya_vesp)
     and not coalesce(public.fn_cubre_ambos_hoy(p_user_id), false) then
    return null;
  end if;

  if v_ya_mat and not v_ya_vesp then
    return 'vespertino';
  end if;
  if v_ya_vesp and not v_ya_mat then
    return 'matutino';
  end if;

  return v_reloj;
end;
$$;

grant execute on function public.fn_turno_abrir_hoy(bigint) to anon, authenticated;

notify pgrst, 'reload schema';

commit;
