-- ============================================================
-- FARMAX — F6b patch: whitelist real de admin_editar_producto
-- ============================================================
-- Corrige nombres de columnas para coincidir con el schema real
-- que usa el frontend: descuento_pct, stock_minimo, venta_unidad,
-- unidades_por_caja, precio_unidad, stock_unidades.
-- ============================================================

begin;

-- Estrategia: UPDATE dinámico. Solo actualiza columnas presentes
-- en p_patch Y que existan en la tabla. Imposible tocar columnas
-- fuera de whitelist o inexistentes.
create or replace function public.admin_editar_producto(
  p_session_token uuid,
  p_producto_id   bigint,
  p_patch         jsonb
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_actor_id bigint;
  v_allowed  text[] := array[
    'nombre','sku','codigo_barras','categoria','subcategoria',
    'marca','tipo','descripcion','precio','costo','stock_minimo',
    'proveedor','descuento_pct','imagen_url','presentacion',
    'principio_activo','requiere_receta','notas','activo',
    'controlado','grupo_controlado','visible_tienda',
    'venta_unidad','unidades_por_caja','precio_unidad','stock_unidades',
    'precio_similares','precio_del_ahorro','fecha_actualizacion_precios'
  ];
  v_cols      text[];
  v_key       text;
  v_set_parts text[] := array[]::text[];
  v_sql       text;
  v_count     int;
begin
  v_actor_id := public.fn_require_admin(p_session_token);

  -- Obtener columnas reales de productos
  select array_agg(column_name::text) into v_cols
  from information_schema.columns
  where table_schema = 'public' and table_name = 'productos';

  -- Construir SET clause solo con columnas válidas y presentes
  for v_key in select jsonb_object_keys(p_patch)
  loop
    if v_key = any(v_allowed) and v_key = any(v_cols) then
      v_set_parts := array_append(
        v_set_parts,
        format('%I = ($1 ->> %L)::text::%s',
               v_key, v_key,
               case v_key
                 when 'precio' then 'numeric'
                 when 'costo'  then 'numeric'
                 when 'descuento_pct' then 'numeric'
                 when 'precio_unidad' then 'numeric'
                 when 'precio_similares' then 'numeric'
                 when 'precio_del_ahorro' then 'numeric'
                 when 'fecha_actualizacion_precios' then 'date'
                 when 'stock_minimo' then 'integer'
                 when 'unidades_por_caja' then 'integer'
                 when 'stock_unidades' then 'integer'
                 when 'activo' then 'boolean'
                 when 'requiere_receta' then 'boolean'
                 when 'controlado' then 'boolean'
                 when 'visible_tienda' then 'boolean'
                 when 'venta_unidad' then 'boolean'
                 else 'text'
               end
              )
      );
    end if;
  end loop;

  if array_length(v_set_parts, 1) is null then
    raise exception 'No hay campos permitidos para actualizar';
  end if;

  v_sql := format(
    'update public.productos set %s where id = $2',
    array_to_string(v_set_parts, ', ')
  );

  execute v_sql using p_patch, p_producto_id;
  get diagnostics v_count = row_count;
  if v_count = 0 then
    raise exception 'Producto % no encontrado', p_producto_id;
  end if;

  begin
    insert into public.audit_log (usuario_id, usuario_nombre, accion, tabla, registro_id, detalle)
    values (
      v_actor_id,
      (select nombre from public.usuarios where id = v_actor_id),
      'editar_producto', 'productos', p_producto_id::text, p_patch
    );
  exception when others then null;
  end;

  return jsonb_build_object('success', true);
end;
$$;

grant execute on function public.admin_editar_producto(uuid, bigint, jsonb) to anon, authenticated;


-- ============================================================
-- RRHH: admin_crear_empleado / admin_toggle_empleado / admin_eliminar_empleado
-- ============================================================

create or replace function public.admin_crear_empleado(
  p_session_token      uuid,
  p_nombre             text,
  p_telefono           text default null,
  p_rol                text default 'vendedor',
  p_turno              text default 'matutino',
  p_salario_quincenal  numeric default 0
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_actor bigint;
  v_new_id bigint;
begin
  v_actor := public.fn_require_admin(p_session_token);

  if coalesce(trim(p_nombre), '') = '' then
    raise exception 'El nombre es obligatorio';
  end if;

  insert into public.empleados(
    nombre, telefono, rol, turno, salario_quincenal, estado
  ) values (
    trim(p_nombre), nullif(trim(coalesce(p_telefono,'')),''),
    p_rol, p_turno, coalesce(p_salario_quincenal,0), true
  )
  returning id into v_new_id;

  begin
    insert into public.audit_log (usuario_id, usuario_nombre, accion, tabla, registro_id, detalle)
    values (v_actor,
            (select nombre from public.usuarios where id=v_actor),
            'crear_empleado', 'empleados', v_new_id::text,
            jsonb_build_object('nombre',p_nombre,'rol',p_rol));
  exception when others then null;
  end;

  return jsonb_build_object('success', true, 'empleado_id', v_new_id);
end;
$$;

grant execute on function public.admin_crear_empleado(uuid, text, text, text, text, numeric) to anon, authenticated;


create or replace function public.admin_toggle_empleado(
  p_session_token uuid,
  p_empleado_id   bigint,
  p_estado        boolean
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare v_actor bigint;
begin
  v_actor := public.fn_require_admin(p_session_token);
  update public.empleados set estado = p_estado where id = p_empleado_id;
  if not found then
    raise exception 'Empleado % no encontrado', p_empleado_id;
  end if;

  begin
    insert into public.audit_log (usuario_id, usuario_nombre, accion, tabla, registro_id, detalle)
    values (v_actor,
            (select nombre from public.usuarios where id=v_actor),
            'toggle_empleado', 'empleados', p_empleado_id::text,
            jsonb_build_object('estado',p_estado));
  exception when others then null;
  end;

  return jsonb_build_object('success', true);
end;
$$;

grant execute on function public.admin_toggle_empleado(uuid, bigint, boolean) to anon, authenticated;


create or replace function public.admin_eliminar_empleado(
  p_session_token uuid,
  p_empleado_id   bigint
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare v_actor bigint;
begin
  v_actor := public.fn_require_admin(p_session_token);
  delete from public.empleados where id = p_empleado_id;
  if not found then
    raise exception 'Empleado % no encontrado', p_empleado_id;
  end if;

  begin
    insert into public.audit_log (usuario_id, usuario_nombre, accion, tabla, registro_id, detalle)
    values (v_actor,
            (select nombre from public.usuarios where id=v_actor),
            'eliminar_empleado', 'empleados', p_empleado_id::text,
            jsonb_build_object('empleado_id',p_empleado_id));
  exception when others then null;
  end;

  return jsonb_build_object('success', true);
end;
$$;

grant execute on function public.admin_eliminar_empleado(uuid, bigint) to anon, authenticated;


-- ============================================================
-- POS: admin_set_receta_origen_pedido
-- Permite marcar el origen de receta en un pedido recién creado.
-- ============================================================

create or replace function public.admin_set_receta_origen_pedido(
  p_session_token uuid,
  p_pedido_id     bigint,
  p_receta_origen text
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_actor bigint;
begin
  v_actor := public.fn_require_empleado(p_session_token);

  if p_receta_origen not in ('medico_farmax','medico_externo','no_aplica') then
    raise exception 'Valor de receta_origen inválido';
  end if;

  update public.pedidos
    set receta_origen = p_receta_origen
    where id = p_pedido_id;
  if not found then
    raise exception 'Pedido % no encontrado', p_pedido_id;
  end if;

  return jsonb_build_object('success', true);
end;
$$;

grant execute on function public.admin_set_receta_origen_pedido(uuid, bigint, text) to anon, authenticated;


-- ============================================================
-- Empleado: empleado_cambiar_password (propia contraseña)
-- ============================================================

create or replace function public.empleado_cambiar_password(
  p_session_token   uuid,
  p_password_actual text,
  p_password_nueva  text
)
returns jsonb
language plpgsql
security definer
set search_path = public, extensions, pg_temp
as $$
declare
  v_user     record;
  v_actor_id bigint;
  v_hash_in  text;
  v_new_salt text;
  v_new_hash text;
begin
  v_actor_id := public.fn_require_empleado(p_session_token);
  if length(p_password_nueva) < 6 then
    raise exception 'La contraseña nueva debe tener al menos 6 caracteres';
  end if;

  select id, password_hash, salt into v_user
  from public.usuarios where id = v_actor_id;

  v_hash_in := public.fn_hash_empleado(p_password_actual, v_user.salt);

  if v_hash_in is distinct from v_user.password_hash then
    return jsonb_build_object('success', false, 'error', 'Contraseña actual incorrecta');
  end if;

  v_new_salt := public.fn_generar_salt();
  v_new_hash := public.fn_hash_empleado(p_password_nueva, v_new_salt);

  update public.usuarios
    set password_hash = v_new_hash, salt = v_new_salt
    where id = v_actor_id;

  begin
    insert into public.audit_log (usuario_id, usuario_nombre, accion, tabla, registro_id, detalle)
    values (v_actor_id,
            (select nombre from public.usuarios where id = v_actor_id),
            'cambiar_password_propia', 'usuarios', v_actor_id::text, '{}'::jsonb);
  exception when others then null;
  end;

  return jsonb_build_object('success', true);
end;
$$;

grant execute on function public.empleado_cambiar_password(uuid, text, text) to anon, authenticated;


-- ============================================================
-- Doctora: doctora_completar_consulta
-- Completa la consulta con diagnóstico, medicamentos, procedimientos,
-- notas, opcionalmente actualiza notas del paciente y registra consumibles.
-- ============================================================

create or replace function public.doctora_completar_consulta(
  p_session_token    uuid,
  p_cita_id          bigint,
  p_diagnostico      text,
  p_medicamentos     jsonb   default '[]'::jsonb,
  p_procedimientos   jsonb   default '[]'::jsonb,
  p_notas_medico     text    default null,
  p_alergias         text    default null,
  p_antecedentes     text    default null,
  p_consumibles      jsonb   default '[]'::jsonb,
  p_signos_vitales   jsonb   default null,
  p_expediente       jsonb   default null,
  p_receta_surtido   text    default null,
  p_completar        boolean default true
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_actor       bigint;
  v_cita        record;
  v_fin_iso     timestamptz := now();
  v_dur_sec     int;
  v_nota        text;
  v_item        jsonb;
begin
  v_actor := public.fn_require_empleado(p_session_token);

  if p_completar and coalesce(trim(p_diagnostico), '') = '' then
    raise exception 'El diagnóstico es obligatorio para terminar la consulta';
  end if;

  select id, telefono, confirmada_inicio_at into v_cita
  from public.citas where id = p_cita_id;

  if v_cita.id is null then
    raise exception 'Cita % no encontrada', p_cita_id;
  end if;

  if v_cita.confirmada_inicio_at is not null then
    v_dur_sec := greatest(0, extract(epoch from (v_fin_iso - v_cita.confirmada_inicio_at))::int);
  end if;

  update public.citas set
    estado                    = case when p_completar then 'completada' else estado end,
    diagnostico               = coalesce(nullif(trim(p_diagnostico),''), diagnostico),
    medicamentos_prescritos   = case when jsonb_typeof(p_medicamentos)='array' and jsonb_array_length(p_medicamentos) > 0
                                       then p_medicamentos else medicamentos_prescritos end,
    procedimientos_realizados = case when jsonb_typeof(p_procedimientos)='array' and jsonb_array_length(p_procedimientos) > 0
                                       then p_procedimientos else procedimientos_realizados end,
    notas_medico              = coalesce(nullif(trim(coalesce(p_notas_medico,'')),''), notas_medico),
    signos_vitales            = coalesce(p_signos_vitales, signos_vitales),
    expediente_json           = coalesce(p_expediente, expediente_json),
    receta_surtido_en         = coalesce(nullif(p_receta_surtido,''), receta_surtido_en),
    consulta_fin_at           = case when p_completar then v_fin_iso else consulta_fin_at end,
    duracion_consulta_segundos= case when p_completar then v_dur_sec else duracion_consulta_segundos end
  where id = p_cita_id;

  if v_cita.telefono is not null and (
       coalesce(trim(p_alergias),'')     <> '' or
       coalesce(trim(p_antecedentes),'') <> ''
     ) then
    v_nota := trim(
      coalesce(case when coalesce(trim(p_alergias),'')<>''
                    then 'ALERGIAS: ' || trim(p_alergias) else '' end, '')
      || case when coalesce(trim(p_alergias),'')<>''
                and coalesce(trim(p_antecedentes),'')<>''
             then ' | ' else '' end
      || coalesce(case when coalesce(trim(p_antecedentes),'')<>''
                       then 'ANTECEDENTES: ' || trim(p_antecedentes) else '' end, '')
    );
    update public.clientes
      set notas = v_nota
      where telefono = v_cita.telefono;
  end if;

  if jsonb_typeof(p_consumibles) = 'array' and jsonb_array_length(p_consumibles) > 0 then
    for v_item in select * from jsonb_array_elements(p_consumibles)
    loop
      insert into public.consumibles_consulta(
        cita_id, producto_id, cantidad, precio, cobrado
      ) values (
        p_cita_id,
        (v_item->>'producto_id')::bigint,
        coalesce((v_item->>'cantidad')::int, 1),
        coalesce((v_item->>'precio')::numeric, 0),
        false
      );
    end loop;
  end if;

  begin
    insert into public.audit_log (usuario_id, usuario_nombre, accion, tabla, registro_id, detalle)
    values (v_actor,
            (select nombre from public.usuarios where id = v_actor),
            'completar_consulta', 'citas', p_cita_id::text,
            jsonb_build_object(
              'diagnostico', p_diagnostico,
              'duracion_seg', v_dur_sec,
              'num_medicamentos', jsonb_array_length(coalesce(p_medicamentos,'[]'::jsonb))
            ));
  exception when others then null;
  end;

  return jsonb_build_object('success', true, 'duracion_seg', v_dur_sec);
end;
$$;

grant execute on function public.doctora_completar_consulta(uuid, bigint, text, jsonb, jsonb, text, text, text, jsonb, jsonb, jsonb, text, boolean) to anon, authenticated;


-- ============================================================
-- Admin: admin_crear_cliente_manual (sin contraseña, desde gestión)
-- ============================================================

create or replace function public.admin_crear_cliente_manual(
  p_session_token uuid,
  p_nombre        text,
  p_telefono      text,
  p_email         text default null,
  p_notas         text default null
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_actor bigint;
  v_new_id bigint;
begin
  v_actor := public.fn_require_empleado(p_session_token);

  if coalesce(trim(p_nombre),'') = '' or coalesce(trim(p_telefono),'') = '' then
    raise exception 'Nombre y teléfono son obligatorios';
  end if;

  if exists(select 1 from public.clientes where telefono = trim(p_telefono)) then
    return jsonb_build_object('success', false, 'error', 'Ya existe un cliente con ese teléfono');
  end if;

  insert into public.clientes(nombre, telefono, email, notas, puntos)
  values (trim(p_nombre), trim(p_telefono),
          nullif(trim(coalesce(p_email,'')),''),
          nullif(trim(coalesce(p_notas,'')),''),
          0)
  returning id into v_new_id;

  begin
    insert into public.audit_log (usuario_id, usuario_nombre, accion, tabla, registro_id, detalle)
    values (v_actor,
            (select nombre from public.usuarios where id = v_actor),
            'crear_cliente_manual', 'clientes', v_new_id::text,
            jsonb_build_object('nombre',p_nombre,'telefono',p_telefono));
  exception when others then null;
  end;

  return jsonb_build_object('success', true, 'cliente_id', v_new_id,
           'cliente', (select to_jsonb(c) from public.clientes c where c.id = v_new_id));
end;
$$;

grant execute on function public.admin_crear_cliente_manual(uuid, text, text, text, text) to anon, authenticated;


-- ============================================================
-- COFEPRIS: admin_registrar_bitacora_cofepris
-- ============================================================

create or replace function public.admin_registrar_bitacora_cofepris(
  p_session_token uuid,
  p_items         jsonb
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_actor bigint;
  v_item  jsonb;
  v_count int := 0;
begin
  v_actor := public.fn_require_empleado(p_session_token);

  if jsonb_typeof(p_items) <> 'array' or jsonb_array_length(p_items) = 0 then
    return jsonb_build_object('success', true, 'insertados', 0);
  end if;

  for v_item in select * from jsonb_array_elements(p_items)
  loop
    insert into public.bitacora_cofepris(
      medicamento, lote, caducidad, cantidad,
      receta, medico, cedula_medico, paciente,
      empleado_id
    ) values (
      v_item->>'medicamento',
      v_item->>'lote',
      nullif(v_item->>'caducidad','')::date,
      coalesce((v_item->>'cantidad')::int, 1),
      v_item->>'receta',
      v_item->>'medico',
      v_item->>'cedula_medico',
      v_item->>'paciente',
      v_actor
    );
    v_count := v_count + 1;
  end loop;

  return jsonb_build_object('success', true, 'insertados', v_count);
end;
$$;

grant execute on function public.admin_registrar_bitacora_cofepris(uuid, jsonb) to anon, authenticated;


-- ============================================================
-- CATÁLOGO MÉDICO: procedimientos_medicos / medicos
-- ============================================================

create or replace function public.admin_upsert_procedimiento_medico(
  p_session_token uuid,
  p_id            bigint,
  p_payload       jsonb
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare v_id bigint;
begin
  perform public.fn_require_admin(p_session_token);

  if p_id is null then
    insert into public.procedimientos_medicos(nombre, precio, duracion_min, descripcion, activo, consumibles_default)
    values (
      p_payload->>'nombre',
      coalesce((p_payload->>'precio')::numeric, 0),
      coalesce((p_payload->>'duracion_min')::int, 30),
      p_payload->>'descripcion',
      coalesce((p_payload->>'activo')::boolean, true),
      coalesce(p_payload->'consumibles_default', '[]'::jsonb)
    ) returning id into v_id;
  else
    update public.procedimientos_medicos set
      nombre              = coalesce(p_payload->>'nombre', nombre),
      precio              = coalesce((p_payload->>'precio')::numeric, precio),
      duracion_min        = coalesce((p_payload->>'duracion_min')::int, duracion_min),
      descripcion         = coalesce(p_payload->>'descripcion', descripcion),
      activo              = coalesce((p_payload->>'activo')::boolean, activo),
      consumibles_default = coalesce(p_payload->'consumibles_default', consumibles_default)
    where id = p_id;
    if not found then raise exception 'Procedimiento % no encontrado', p_id; end if;
    v_id := p_id;
  end if;

  return jsonb_build_object('success', true, 'id', v_id);
end;
$$;

create or replace function public.admin_toggle_procedimiento_medico(
  p_session_token uuid, p_id bigint, p_activo boolean
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
begin
  perform public.fn_require_admin(p_session_token);
  update public.procedimientos_medicos set activo = p_activo where id = p_id;
  if not found then raise exception 'Procedimiento % no encontrado', p_id; end if;
  return jsonb_build_object('success', true);
end;
$$;

create or replace function public.admin_seed_procedimientos_medicos(
  p_session_token uuid, p_items jsonb
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare v_item jsonb; v_count int := 0;
begin
  perform public.fn_require_admin(p_session_token);
  if jsonb_typeof(p_items) <> 'array' then
    return jsonb_build_object('success', true, 'insertados', 0);
  end if;
  for v_item in select * from jsonb_array_elements(p_items) loop
    insert into public.procedimientos_medicos(nombre, precio, duracion_min, descripcion, activo, consumibles_default)
    values (
      v_item->>'nombre',
      coalesce((v_item->>'precio')::numeric, 0),
      coalesce((v_item->>'duracion_min')::int, 30),
      v_item->>'descripcion',
      true,
      coalesce(v_item->'consumibles_default', '[]'::jsonb)
    )
    on conflict do nothing;
    v_count := v_count + 1;
  end loop;
  return jsonb_build_object('success', true, 'insertados', v_count);
end;
$$;

create or replace function public.admin_upsert_medico(
  p_session_token uuid,
  p_id            bigint,
  p_payload       jsonb
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare v_id bigint;
begin
  perform public.fn_require_admin(p_session_token);

  declare
    v_cols text[];
    v_key  text;
    v_set  text[] := array[]::text[];
    v_sql  text;
  begin
    select array_agg(column_name::text) into v_cols
    from information_schema.columns
    where table_schema='public' and table_name='medicos';

    if p_id is null then
      -- INSERT dinámico: solo columnas que existen
      declare
        v_cols_ins text[] := array[]::text[];
        v_vals_ins text[] := array[]::text[];
      begin
        for v_key in select jsonb_object_keys(p_payload) loop
          if v_key = any(v_cols) then
            v_cols_ins := array_append(v_cols_ins, format('%I', v_key));
            v_vals_ins := array_append(v_vals_ins, format('(($1 ->> %L)::text)::%s', v_key,
              case v_key
                when 'monto_fijo' then 'numeric'
                when 'porcentaje' then 'numeric'
                when 'activo'     then 'boolean'
                else 'text'
              end));
          end if;
        end loop;
        v_sql := format('insert into public.medicos(%s) values(%s) returning id',
          array_to_string(v_cols_ins, ', '),
          array_to_string(v_vals_ins, ', '));
        execute v_sql using p_payload into v_id;
      end;
    else
      for v_key in select jsonb_object_keys(p_payload) loop
        if v_key = any(v_cols) then
          v_set := array_append(v_set, format('%I = (($1 ->> %L)::text)::%s', v_key, v_key,
            case v_key
              when 'monto_fijo' then 'numeric'
              when 'porcentaje' then 'numeric'
              when 'activo'     then 'boolean'
              else 'text'
            end));
        end if;
      end loop;
      if array_length(v_set,1) is null then
        raise exception 'No hay campos válidos para actualizar';
      end if;
      v_sql := format('update public.medicos set %s where id = $2', array_to_string(v_set, ', '));
      execute v_sql using p_payload, p_id;
      if not found then raise exception 'Médico % no encontrado', p_id; end if;
      v_id := p_id;
    end if;
  end;

  return jsonb_build_object('success', true, 'id', v_id);
end;
$$;

create or replace function public.admin_toggle_medico(
  p_session_token uuid, p_id bigint, p_activo boolean
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
begin
  perform public.fn_require_admin(p_session_token);
  update public.medicos set activo = p_activo where id = p_id;
  if not found then raise exception 'Médico % no encontrado', p_id; end if;
  return jsonb_build_object('success', true);
end;
$$;

grant execute on function public.admin_upsert_procedimiento_medico(uuid, bigint, jsonb) to anon, authenticated;
grant execute on function public.admin_toggle_procedimiento_medico(uuid, bigint, boolean) to anon, authenticated;
grant execute on function public.admin_seed_procedimientos_medicos(uuid, jsonb) to anon, authenticated;
grant execute on function public.admin_upsert_medico(uuid, bigint, jsonb) to anon, authenticated;
grant execute on function public.admin_toggle_medico(uuid, bigint, boolean) to anon, authenticated;


-- ============================================================
-- COFEPRIS: alertas_legales (admin)
-- ============================================================

create or replace function public.admin_actualizar_alerta_legal(
  p_session_token   uuid,
  p_id              bigint,
  p_fecha_vencimiento date
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
begin
  perform public.fn_require_admin(p_session_token);
  update public.alertas_legales set fecha_vencimiento = p_fecha_vencimiento where id = p_id;
  if not found then raise exception 'Alerta % no encontrada', p_id; end if;
  return jsonb_build_object('success', true);
end;
$$;

create or replace function public.admin_seed_alertas_legales(
  p_session_token uuid, p_items jsonb
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare v_item jsonb; v_count int := 0;
begin
  perform public.fn_require_admin(p_session_token);
  if jsonb_typeof(p_items) <> 'array' then
    return jsonb_build_object('success', true, 'insertados', 0);
  end if;
  for v_item in select * from jsonb_array_elements(p_items) loop
    insert into public.alertas_legales(nombre, tipo, fecha_vencimiento, dias_aviso, activo, notas)
    values (
      v_item->>'nombre', v_item->>'tipo',
      nullif(v_item->>'fecha_vencimiento','')::date,
      coalesce((v_item->>'dias_aviso')::int, 30),
      true,
      v_item->>'notas'
    )
    on conflict do nothing;
    v_count := v_count + 1;
  end loop;
  return jsonb_build_object('success', true, 'insertados', v_count);
end;
$$;

grant execute on function public.admin_actualizar_alerta_legal(uuid, bigint, date) to anon, authenticated;
grant execute on function public.admin_seed_alertas_legales(uuid, jsonb) to anon, authenticated;

commit;
