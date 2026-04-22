-- FARMAX — Admin: asignar o restablecer contraseña de tienda para un cliente
-- (cuentas creadas en mostrador sin password_hash, o solicitud vía solicitar_reset_password).
--
-- Ejecutar en Supabase SQL Editor. Revoca sesiones web del cliente al cambiar la clave.

begin;

create or replace function public.admin_asignar_password_cliente(
  p_session_token  uuid,
  p_cliente_id     bigint,
  p_nueva_password text
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_updated bigint;
begin
  perform public.fn_require_admin(p_session_token);

  if p_nueva_password is null or length(p_nueva_password) < 6 then
    return jsonb_build_object('success', false, 'error', 'La contraseña debe tener al menos 6 caracteres');
  end if;

  if p_cliente_id is null then
    return jsonb_build_object('success', false, 'error', 'Cliente no válido');
  end if;

  update public.clientes
     set password_hash = public.fn_hash_cliente(p_nueva_password)
   where id = p_cliente_id
   returning id into v_updated;

  if v_updated is null then
    return jsonb_build_object('success', false, 'error', 'Cliente no encontrado');
  end if;

  update public.sesiones_cliente
     set revoked_at = now()
   where cliente_id = p_cliente_id
     and revoked_at is null;

  return jsonb_build_object('success', true);
end;
$$;

grant execute on function public.admin_asignar_password_cliente(uuid, bigint, text) to anon, authenticated;

commit;
