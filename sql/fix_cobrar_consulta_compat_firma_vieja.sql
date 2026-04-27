-- Compatibilidad temporal para frontend viejo en cache (Vercel):
-- firma antigua: cobrar_consulta(p_cita_id, p_cliente_id, p_metodo_pago, p_session_token)
-- delega a la firma nueva F6b:
-- cobrar_consulta(p_session_token, p_cita_id, p_metodo_pago, p_precio_consulta, p_ya_pago_consulta, p_parte_doctor, p_parte_farmacia)

begin;

create or replace function public.cobrar_consulta(
  p_cita_id        bigint,
  p_cliente_id     bigint,
  p_metodo_pago    text,
  p_session_token  uuid
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_precio_consulta numeric := 80;
  v_ya_pago         boolean := false;
  v_parte_doctor    numeric := 0;
  v_parte_farmacia  numeric := 0;
begin
  -- Mantener compatibilidad sin depender del cliente.
  -- p_cliente_id se conserva por firma legacy, pero no se usa en la lógica nueva.
  begin
    select nullif(trim(valor), '')::numeric
      into v_precio_consulta
      from public.configuracion
      where clave = 'precio_consulta'
      limit 1;
  exception
    when others then
      v_precio_consulta := 80;
  end;

  select (coalesce(c.pago_estado, '') = 'pagada' or c.pedido_consulta_id is not null)
    into v_ya_pago
    from public.citas c
    where c.id = p_cita_id;

  if coalesce(v_ya_pago, false) then
    v_parte_doctor := 0;
    v_parte_farmacia := 0;
  else
    v_parte_doctor := round((coalesce(v_precio_consulta, 80) * 0.70)::numeric, 2);
    v_parte_farmacia := round((coalesce(v_precio_consulta, 80) - v_parte_doctor)::numeric, 2);
  end if;

  return public.cobrar_consulta(
    p_session_token   => p_session_token,
    p_cita_id         => p_cita_id,
    p_metodo_pago     => p_metodo_pago,
    p_precio_consulta => coalesce(v_precio_consulta, 80),
    p_ya_pago_consulta => coalesce(v_ya_pago, false),
    p_parte_doctor    => v_parte_doctor,
    p_parte_farmacia  => v_parte_farmacia
  );
end;
$$;

grant execute on function public.cobrar_consulta(bigint, bigint, text, uuid) to anon, authenticated;

commit;

