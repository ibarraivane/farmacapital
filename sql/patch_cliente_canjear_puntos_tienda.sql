-- Canje de puntos desde la tienda (cuenta del cliente).
-- Descuenta puntos y deja constancia en clientes.notas para caja.

begin;

create or replace function public.cliente_canjear_puntos_tienda(
  p_session_token uuid,
  p_puntos integer
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_cli_id bigint;
  v_pts int;
  v_nuevos int;
  v_ben text;
  v_codigo text;
  v_notas text;
begin
  if p_session_token is null then
    return jsonb_build_object('success', false, 'error', 'Sesión requerida');
  end if;
  v_cli_id := public.fn_validar_token_cliente(p_session_token);
  if v_cli_id is null then
    return jsonb_build_object('success', false, 'error', 'Sesión inválida');
  end if;

  if p_puntos not in (20, 50, 100, 160, 200) then
    return jsonb_build_object('success', false, 'error', 'Canje no válido');
  end if;

  v_ben := case p_puntos
    when 20 then '$10 descuento'
    when 50 then 'Envío gratis'
    when 100 then '$50 descuento'
    when 160 then 'Consulta médica gratis'
    when 200 then 'Producto gratis'
  end;

  select coalesce(puntos, 0) into v_pts from public.clientes where id = v_cli_id;
  if v_pts < p_puntos then
    return jsonb_build_object('success', false, 'error', 'Puntos insuficientes');
  end if;

  v_codigo := 'FC-' || p_puntos || '-' || upper(substr(md5(random()::text || clock_timestamp()::text), 1, 6));
  v_nuevos := v_pts - p_puntos;

  select coalesce(notas, '') into v_notas from public.clientes where id = v_cli_id;
  v_notas := trim(both from (v_notas || E'\n' || to_char(now() at time zone 'America/Mexico_City', 'YYYY-MM-DD HH24:MI')
    || ' CANJE ' || v_codigo || ' · ' || p_puntos || ' pts · ' || v_ben));

  update public.clientes
     set puntos = v_nuevos,
         notas = v_notas
   where id = v_cli_id;

  return jsonb_build_object(
    'success', true,
    'puntos', v_nuevos,
    'codigo', v_codigo,
    'beneficio', v_ben,
    'puntos_canjeados', p_puntos
  );
end;
$$;

grant execute on function public.cliente_canjear_puntos_tienda(uuid, integer) to anon, authenticated;

commit;
