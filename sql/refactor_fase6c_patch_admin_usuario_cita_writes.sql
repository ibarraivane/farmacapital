-- ============================================================
-- FARMAX — Parche F6: RPCs para escrituras que aún usaba el FE
-- ============================================================
-- Contexto: F6a revoca INSERT/UPDATE directo. Estas RPCs reemplazan:
--   • UPDATE usuarios (edición perfil + modulos_custom)
--   • UPDATE citas.medicamentos_prescritos (sync receta POS)
--
-- Además el FE debe llamar doctora_completar_consulta en lugar de
-- UPDATE citas al terminar consulta rápida (ver Admin.jsx).
--
-- Ejecutar en Supabase SQL Editor (idempotente).
-- ============================================================

begin;

-- ── Admin: datos de perfil (sin password) ───────────────────
create or replace function public.admin_actualizar_usuario_datos(
  p_session_token uuid,
  p_usuario_id    bigint,
  p_nombre        text,
  p_email         text,
  p_telefono      text,
  p_rol           text,
  p_notas         text,
  p_activo        boolean
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_actor bigint;
  v_n     int;
begin
  v_actor := public.fn_require_admin(p_session_token);

  if p_usuario_id is null then
    return jsonb_build_object('success', false, 'error', 'Usuario requerido');
  end if;
  if coalesce(trim(p_nombre), '') = '' then
    return jsonb_build_object('success', false, 'error', 'Nombre obligatorio');
  end if;
  if coalesce(trim(p_email), '') = '' then
    return jsonb_build_object('success', false, 'error', 'Correo obligatorio');
  end if;

  update public.usuarios
     set nombre   = trim(p_nombre),
         email    = lower(trim(p_email)),
         telefono = nullif(trim(coalesce(p_telefono, '')), ''),
         rol      = coalesce(nullif(trim(p_rol), ''), rol),
         notas    = nullif(trim(coalesce(p_notas, '')), ''),
         activo   = coalesce(p_activo, true)
   where id = p_usuario_id;

  get diagnostics v_n = row_count;
  if v_n = 0 then
    return jsonb_build_object('success', false, 'error', 'Usuario no encontrado');
  end if;

  begin
    insert into public.audit_log (usuario_id, usuario_nombre, accion, tabla, registro_id, detalle)
    values (v_actor, (select nombre from public.usuarios where id = v_actor),
            'editar_usuario', 'usuarios', p_usuario_id::text, '{}'::jsonb);
  exception when others then null;
  end;

  return jsonb_build_object(
    'success', true,
    'user', (
      select jsonb_build_object(
        'id', u.id, 'nombre', u.nombre, 'email', u.email, 'telefono', u.telefono,
        'rol', u.rol, 'notas', u.notas, 'activo', u.activo, 'modulos_custom', u.modulos_custom
      )
      from public.usuarios u where u.id = p_usuario_id
    )
  );
end;
$$;

grant execute on function public.admin_actualizar_usuario_datos(uuid, bigint, text, text, text, text, text, boolean)
  to anon, authenticated;


-- ── Admin: modulos_custom (null = limpiar override) ─────────
create or replace function public.admin_set_usuario_modulos_custom(
  p_session_token uuid,
  p_usuario_id    bigint,
  p_modulos_custom jsonb
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_actor bigint;
  v_n     int;
begin
  v_actor := public.fn_require_admin(p_session_token);

  if p_usuario_id is null then
    return jsonb_build_object('success', false, 'error', 'Usuario requerido');
  end if;

  update public.usuarios
     set modulos_custom = p_modulos_custom
   where id = p_usuario_id;

  get diagnostics v_n = row_count;
  if v_n = 0 then
    return jsonb_build_object('success', false, 'error', 'Usuario no encontrado');
  end if;

  begin
    insert into public.audit_log (usuario_id, usuario_nombre, accion, tabla, registro_id, detalle)
    values (v_actor, (select nombre from public.usuarios where id = v_actor),
            'modulos_custom', 'usuarios', p_usuario_id::text,
            coalesce(jsonb_build_object('payload', p_modulos_custom), '{}'::jsonb));
  exception when others then null;
  end;

  return jsonb_build_object('success', true);
end;
$$;

grant execute on function public.admin_set_usuario_modulos_custom(uuid, bigint, jsonb)
  to anon, authenticated;


-- ── Staff: solo JSON medicamentos_prescritos (receta POS) ────
create or replace function public.empleado_patch_cita_medicamentos(
  p_session_token uuid,
  p_cita_id       bigint,
  p_medicamentos  jsonb
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_n int;
begin
  perform public.fn_require_empleado(p_session_token);

  if p_cita_id is null then
    return jsonb_build_object('success', false, 'error', 'Cita requerida');
  end if;
  if p_medicamentos is null or jsonb_typeof(p_medicamentos) <> 'array' then
    return jsonb_build_object('success', false, 'error', 'medicamentos debe ser arreglo JSON');
  end if;

  update public.citas
     set medicamentos_prescritos = p_medicamentos
   where id = p_cita_id;

  get diagnostics v_n = row_count;
  if v_n = 0 then
    return jsonb_build_object('success', false, 'error', 'Cita no encontrada');
  end if;

  return jsonb_build_object('success', true);
end;
$$;

grant execute on function public.empleado_patch_cita_medicamentos(uuid, bigint, jsonb)
  to anon, authenticated;

commit;
