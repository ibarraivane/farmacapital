-- FarmaCapital — Endurecer accesos admin + tienda (20 ago 2026)
-- Ejecutar en Supabase SQL Editor DESPUÉS de desplegar el front/API.
-- Idempotente.

begin;

-- ── 1) Rate limit de login (empleados y clientes) ───────────────────────────
create table if not exists public.login_intentos (
  clave            text primary key,
  fallos           integer not null default 0,
  bloqueado_hasta  timestamptz,
  updated_at       timestamptz not null default now()
);

alter table public.login_intentos enable row level security;
revoke all on table public.login_intentos from anon, authenticated;

create or replace function public.fn_login_rate_blocked(p_clave text)
returns boolean
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_hasta timestamptz;
begin
  select bloqueado_hasta into v_hasta
  from public.login_intentos
  where clave = p_clave;
  return v_hasta is not null and v_hasta > now();
end;
$$;

create or replace function public.fn_login_rate_fail(p_clave text)
returns void
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_fallos integer;
begin
  insert into public.login_intentos (clave, fallos, updated_at)
  values (p_clave, 1, now())
  on conflict (clave) do update
    set fallos = case
          when public.login_intentos.bloqueado_hasta is not null
           and public.login_intentos.bloqueado_hasta < now()
          then 1
          else public.login_intentos.fallos + 1
        end,
        updated_at = now()
  returning fallos into v_fallos;

  if v_fallos >= 5 then
    update public.login_intentos
       set bloqueado_hasta = now() + interval '15 minutes',
           updated_at = now()
     where clave = p_clave;
  end if;
end;
$$;

create or replace function public.fn_login_rate_ok(p_clave text)
returns void
language plpgsql
security definer
set search_path = public, pg_temp
as $$
begin
  delete from public.login_intentos where clave = p_clave;
end;
$$;

revoke all on function public.fn_login_rate_blocked(text) from public, anon, authenticated;
revoke all on function public.fn_login_rate_fail(text) from public, anon, authenticated;
revoke all on function public.fn_login_rate_ok(text) from public, anon, authenticated;

-- Sesiones de empleado: 8 h (alineado al panel)
alter table public.sesiones
  alter column expires_at set default (now() + interval '8 hours');

-- ── 2) Cerrar SELECT anónimo en tablas operativas / PII ─────────────────────
-- El panel y la tienda ya leen estas tablas por RPC, no por REST directo.
-- Se mantienen públicas: productos, banners, promociones, sucursales, configuracion.

do $$
declare
  v_tbls text[] := array[
    'pedidos','pedido_items','clientes','usuarios','empleados',
    'citas','cortes_caja','movimientos_caja',
    'facturas','devoluciones','devolucion_items',
    'compras','compra_items',
    'direcciones_cliente','envios','folios',
    'bitacora_cofepris','bitacora_usuarios',
    'alertas_legales','proveedores',
    'movimientos_inventario','stock_reservations',
    'perfiles','medicos','consumibles_consulta',
    'procedimientos_medicos','equipamiento_consultorio',
    'lotes','lotes_producto'
  ];
  v_tbl text;
  v_pol record;
begin
  foreach v_tbl in array v_tbls
  loop
    perform 1 from information_schema.tables
     where table_schema = 'public' and table_name = v_tbl;
    if not found then continue; end if;

    execute format('revoke select on public.%I from anon, authenticated', v_tbl);
    execute format('alter table public.%I enable row level security', v_tbl);

    for v_pol in
      select policyname from pg_policies
      where schemaname = 'public' and tablename = v_tbl
        and cmd in ('SELECT', 'ALL')
    loop
      execute format('drop policy if exists %I on public.%I', v_pol.policyname, v_tbl);
    end loop;
  end loop;
end $$;

do $$
begin
  revoke select (id, nombre, telefono, email, puntos, notas, alergias, antecedentes,
    direccion, fecha_nacimiento, genero, rfc, razon_social, cp, created_at, updated_at)
    on public.clientes from anon, authenticated;
exception when others then null;
end $$;

do $$
begin
  revoke select (id, nombre, email, rol, activo, created_at, updated_at)
    on public.usuarios from anon, authenticated;
exception when others then null;
end $$;

-- ── 3) Checkout guest + puntos solo al pago aprobado ───────────────────────
alter table public.pedidos
  add column if not exists guest_nombre text,
  add column if not exists guest_telefono text,
  add column if not exists guest_email text,
  add column if not exists whatsapp_recibo boolean not null default false,
  add column if not exists puntos_acreditados boolean not null default false;

create or replace function public.service_acreditar_puntos_pedido(p_pedido_id bigint)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_pedido record;
  v_pts integer;
begin
  if p_pedido_id is null then
    return jsonb_build_object('ok', false, 'error', 'missing_pedido');
  end if;

  select * into v_pedido from public.pedidos where id = p_pedido_id for update;
  if v_pedido.id is null then
    return jsonb_build_object('ok', false, 'error', 'not_found');
  end if;
  if coalesce(v_pedido.puntos_acreditados, false) then
    return jsonb_build_object('ok', true, 'already', true);
  end if;
  if v_pedido.cliente_id is null then
    return jsonb_build_object('ok', false, 'error', 'no_cliente');
  end if;

  v_pts := floor(coalesce(v_pedido.total, 0) / 10);
  if v_pts > 0 then
    update public.clientes
       set puntos = coalesce(puntos, 0) + v_pts
     where id = v_pedido.cliente_id;
  end if;

  update public.pedidos
     set puntos_acreditados = true
   where id = p_pedido_id;

  return jsonb_build_object('ok', true, 'puntos', v_pts);
end;
$$;

revoke all on function public.service_acreditar_puntos_pedido(bigint) from public, anon, authenticated;
grant execute on function public.service_acreditar_puntos_pedido(bigint) to service_role;

-- ── 4) Checkout guest: no pegar a cuenta con contraseña; sin puntos; lock stock ──
create or replace function public.cliente_crear_pedido_online(
  p_session_token          uuid,
  p_cart                   jsonb,
  p_metodo_pago            text,
  p_tipo_entrega           text default 'recoger',
  p_direccion              text default null,
  p_guest_nombre           text default null,
  p_guest_telefono         text default null,
  p_guest_email            text default null,
  p_reservation_session_id text default null,
  p_whatsapp_recibo        boolean default false
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_cli_id       bigint;
  v_pedido_id    bigint;
  v_item         jsonb;
  v_pid          bigint;
  v_qty          numeric;
  v_prod         record;
  v_total        numeric := 0;
  v_puntos_ganados int := 0;
  v_telefono_norm text;
  v_n_items      int := 0;
  v_sum_lotes    integer;
  v_stock_eff    integer;
  v_existing     bigint;
  v_guest        boolean := false;
begin
  if p_session_token is not null then
    v_cli_id := public.fn_validar_token_cliente(p_session_token);
    if v_cli_id is null then
      raise exception 'Sesión cliente inválida' using errcode = '28000';
    end if;
  else
    v_guest := true;
    if p_guest_telefono is null or length(trim(p_guest_telefono))=0 then
      raise exception 'Teléfono requerido para checkout sin cuenta';
    end if;
    if p_guest_nombre is null or length(trim(p_guest_nombre))=0 then
      raise exception 'Nombre requerido para checkout sin cuenta';
    end if;

    v_telefono_norm := trim(p_guest_telefono);

    select c.id into v_existing
      from public.clientes c
     where public.fn_digits_mx(c.telefono) = public.fn_digits_mx(v_telefono_norm)
       and c.password_hash is not null
       and length(c.password_hash) > 0
     limit 1;

    if v_existing is not null then
      raise exception 'Ya hay una cuenta con este teléfono. Inicia sesión para continuar';
    end if;

    select c.id into v_cli_id
      from public.clientes c
     where public.fn_digits_mx(c.telefono) = public.fn_digits_mx(v_telefono_norm)
     limit 1;

    if v_cli_id is null then
      insert into public.clientes (nombre, telefono, email, puntos)
      values (trim(p_guest_nombre), v_telefono_norm,
              nullif(trim(coalesce(p_guest_email,'')),''), 0)
      returning id into v_cli_id;
    end if;
  end if;

  if jsonb_array_length(coalesce(p_cart,'[]'::jsonb)) = 0 then
    raise exception 'Carrito vacío';
  end if;

  if p_metodo_pago not in ('tarjeta','mercadopago','efectivo') then
    raise exception 'Método de pago inválido';
  end if;
  if p_tipo_entrega not in ('recoger','envio') then
    raise exception 'Tipo de entrega inválido';
  end if;
  if p_tipo_entrega = 'envio' and (p_direccion is null or length(trim(p_direccion))=0) then
    raise exception 'Dirección requerida para envío';
  end if;

  for v_item in select * from jsonb_array_elements(p_cart)
  loop
    v_pid := (v_item->>'producto_id')::bigint;
    v_qty := (v_item->>'cantidad')::numeric;
    if v_qty is null or v_qty <= 0 then
      raise exception 'Cantidad inválida para producto %', v_pid;
    end if;

    select id, precio, activo, stock, nombre, requiere_receta
      into v_prod
      from public.productos
     where id = v_pid
     for update;

    if v_prod.id is null then
      raise exception 'Producto % no existe', v_pid;
    end if;
    if not coalesce(v_prod.activo, false) then
      raise exception 'Producto "%" no está disponible', v_prod.nombre;
    end if;

    perform 1 from public.lotes
     where producto_id = v_pid and coalesce(activo, true)
     for update;

    select coalesce(sum(l.cantidad_actual), 0)::integer
      into v_sum_lotes
      from public.lotes l
     where l.producto_id = v_pid
       and coalesce(l.activo, true);

    v_stock_eff := greatest(coalesce(v_prod.stock, 0), coalesce(v_sum_lotes, 0));

    if v_stock_eff < v_qty then
      raise exception 'Stock insuficiente para "%": disponible=%, solicitado=%',
                      v_prod.nombre, v_stock_eff, v_qty;
    end if;
    if coalesce(v_prod.requiere_receta, false) then
      raise exception 'El producto "%" requiere receta médica y no puede venderse online',
                      v_prod.nombre;
    end if;

    v_total := v_total + (v_prod.precio * v_qty);
    v_n_items := v_n_items + 1;
  end loop;

  if v_total <= 0 then
    raise exception 'Total inválido';
  end if;

  insert into public.pedidos (
    cliente_id, total, estado, tipo, tipo_entrega, direccion, metodo_pago,
    whatsapp_recibo, guest_nombre, guest_telefono, guest_email, puntos_acreditados
  ) values (
    v_cli_id, v_total, 'pendiente', 'online', p_tipo_entrega, p_direccion, p_metodo_pago,
    coalesce(p_whatsapp_recibo, false),
    case when v_guest then trim(p_guest_nombre) else null end,
    case when v_guest then v_telefono_norm else null end,
    case when v_guest then nullif(trim(coalesce(p_guest_email,'')),'') else null end,
    false
  ) returning id into v_pedido_id;

  for v_item in select * from jsonb_array_elements(p_cart)
  loop
    v_pid := (v_item->>'producto_id')::bigint;
    v_qty := (v_item->>'cantidad')::numeric;
    select precio into v_prod from public.productos where id = v_pid;

    insert into public.pedido_items (pedido_id, producto_id, cantidad, precio_unitario)
    values (v_pedido_id, v_pid, v_qty, v_prod.precio);
  end loop;

  v_puntos_ganados := floor(v_total / 10);

  if p_reservation_session_id is not null then
    begin
      perform public.confirm_stock_reservation(p_reservation_session_id, v_pedido_id);
    exception when others then
      raise notice 'confirm_stock_reservation no disponible: %', SQLERRM;
    end;
  end if;

  return jsonb_build_object(
    'success', true,
    'pedido_id', v_pedido_id,
    'cliente_id', v_cli_id,
    'total', v_total,
    'puntos_ganados', v_puntos_ganados,
    'items', v_n_items,
    'whatsapp_recibo', coalesce(p_whatsapp_recibo, false)
  );
end;
$$;

grant execute on function public.cliente_crear_pedido_online(
  uuid, jsonb, text, text, text, text, text, text, text, boolean
) to anon, authenticated;

-- ── 5) Receta: solo pedidos recientes (POS) ────────────────────────────────
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
   where id = p_pedido_id
     and created_at > now() - interval '24 hours';
  if not found then
    raise exception 'Pedido % no encontrado o fuera de ventana de 24 h', p_pedido_id;
  end if;

  return jsonb_build_object('success', true);
end;
$$;

grant execute on function public.admin_set_receta_origen_pedido(uuid, bigint, text) to anon, authenticated;

commit;

-- ── 6) Login empleado con lockout (fuera del bloque anterior por tamaño) ──
begin;

create or replace function public.login_empleado(
  p_identificador text,
  p_password      text,
  p_ip            text default null,
  p_user_agent    text default null
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_usuario record;
  v_hash    text;
  v_token   uuid;
  v_id      text;
  v_tel     text;
  v_clave   text;
begin
  if p_identificador is null or p_password is null
     or length(trim(p_identificador)) = 0 or length(p_password) = 0 then
    return jsonb_build_object('success', false, 'error', 'Credenciales vacías');
  end if;

  v_id := trim(p_identificador);
  v_clave := 'empleado:' || lower(v_id);

  if public.fn_login_rate_blocked(v_clave) then
    return jsonb_build_object('success', false, 'error', 'Demasiados intentos. Espera 15 minutos.');
  end if;

  begin
    v_tel := public.fn_tel_empleado(v_id);
  exception when undefined_function then
    v_tel := null;
  end;

  select u.* into v_usuario
  from public.usuarios u
  where u.activo = true
    and u.eliminado_at is null
    and (
      (u.email is not null and lower(u.email) = lower(v_id))
      or (v_tel is not null and public.fn_tel_empleado(u.telefono) = v_tel)
      or (u.telefono is not null and u.telefono = v_id)
    )
  limit 1;

  v_hash := public.fn_hash_empleado(p_password, coalesce(v_usuario.salt, ''));

  if v_usuario.id is null or v_hash <> v_usuario.password_hash then
    perform public.fn_login_rate_fail(v_clave);
    return jsonb_build_object('success', false, 'error', 'Credenciales inválidas');
  end if;

  perform public.fn_login_rate_ok(v_clave);

  delete from public.sesiones
  where usuario_id = v_usuario.id
    and (expires_at < now() or revoked_at is not null);

  insert into public.sesiones (usuario_id, ip, user_agent, expires_at)
  values (v_usuario.id, p_ip, p_user_agent, now() + interval '8 hours')
  returning token into v_token;

  return jsonb_build_object(
    'success', true,
    'token',   v_token,
    'usuario', jsonb_build_object(
      'id',             v_usuario.id,
      'nombre',         v_usuario.nombre,
      'email',          v_usuario.email,
      'telefono',       v_usuario.telefono,
      'rol',            v_usuario.rol,
      'turno',          v_usuario.turno,
      'modulos_custom', v_usuario.modulos_custom
    )
  );
end;
$$;

grant execute on function public.login_empleado(text, text, text, text) to anon, authenticated;

create or replace function public.login_cliente(
  p_telefono   text,
  p_password   text,
  p_ip         text default null,
  p_user_agent text default null
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_cliente record;
  v_hash    text;
  v_token   uuid;
  v_id      bigint;
  v_clave   text;
begin
  if p_telefono is null or p_password is null
     or length(trim(p_telefono)) = 0 or length(p_password) = 0 then
    return jsonb_build_object('success', false, 'error', 'Credenciales vacías');
  end if;

  v_clave := 'cliente:' || lower(trim(p_telefono));
  if public.fn_login_rate_blocked(v_clave) then
    return jsonb_build_object('success', false, 'error', 'Demasiados intentos. Espera 15 minutos.');
  end if;

  v_id := public.fn_resolver_cliente_id_por_identificador(trim(p_telefono));
  if v_id is null then
    perform public.fn_login_rate_fail(v_clave);
    return jsonb_build_object('success', false, 'error', 'Correo, teléfono o contraseña incorrectos');
  end if;

  select c.* into v_cliente from public.clientes c where c.id = v_id;

  if v_cliente.password_hash is null or length(v_cliente.password_hash) = 0 then
    perform public.fn_login_rate_fail(v_clave);
    return jsonb_build_object(
      'success', false,
      'error', 'Tu cuenta necesita una contraseña. Usa recuperar acceso o regístrate de nuevo.'
    );
  end if;

  v_hash := public.fn_hash_cliente(p_password);
  if v_hash <> v_cliente.password_hash then
    perform public.fn_login_rate_fail(v_clave);
    return jsonb_build_object('success', false, 'error', 'Correo, teléfono o contraseña incorrectos');
  end if;

  perform public.fn_login_rate_ok(v_clave);

  delete from public.sesiones_cliente
  where cliente_id = v_cliente.id
    and (expires_at < now() or revoked_at is not null);

  insert into public.sesiones_cliente (cliente_id, ip, user_agent)
  values (v_cliente.id, p_ip, p_user_agent)
  returning token into v_token;

  return jsonb_build_object(
    'success', true,
    'token',   v_token,
    'cliente', jsonb_build_object(
      'id',       v_cliente.id,
      'nombre',   v_cliente.nombre,
      'telefono', v_cliente.telefono,
      'email',    v_cliente.email,
      'puntos',   v_cliente.puntos
    )
  );
end;
$$;

grant execute on function public.login_cliente(text, text, text, text) to anon, authenticated;

-- Password mínimo 8 al crear usuario (redefine la función actual)
create or replace function public.admin_crear_usuario(
  p_session_token uuid,
  p_nombre        text,
  p_password      text,
  p_rol           text,
  p_email         text default null,
  p_telefono      text default null,
  p_modulos_custom jsonb default null,
  p_notas         text default null
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_actor_id   bigint;
  v_new_id     bigint;
  v_salt       text;
  v_hash       text;
  v_rol        text;
  v_email      text;
  v_tel        text;
  v_user       jsonb;
begin
  v_actor_id := public.fn_require_admin(p_session_token);
  v_rol := lower(trim(coalesce(p_rol, '')));
  if v_rol = 'empleado' then v_rol := 'vendedor'; end if;
  if v_rol = 'consultorio' then v_rol := 'doctora'; end if;

  if p_nombre is null or length(trim(p_nombre)) = 0 then
    raise exception 'Nombre requerido';
  end if;
  if p_password is null or length(p_password) < 8 then
    raise exception 'Password mínimo 8 caracteres';
  end if;
  if v_rol not in ('admin', 'vendedor', 'doctora', 'gerente') then
    raise exception 'Rol inválido: %', p_rol;
  end if;

  v_email := nullif(lower(trim(coalesce(p_email, ''))), '');
  v_tel := public.fn_tel_empleado(p_telefono);

  if v_email is null and v_tel is null then
    raise exception 'Indica correo o teléfono para que pueda iniciar sesión';
  end if;

  if v_email is not null then
    if exists (
      select 1 from public.usuarios
      where lower(email) = v_email and eliminado_at is null
    ) then
      raise exception 'Ya existe un usuario con ese email';
    end if;
  end if;

  if v_tel is not null then
    if exists (
      select 1 from public.usuarios
      where public.fn_tel_empleado(telefono) = v_tel
        and eliminado_at is null
    ) then
      raise exception 'Ya existe un usuario con ese teléfono';
    end if;
  end if;

  v_salt := public.fn_generar_salt();
  v_hash := public.fn_hash_empleado(p_password, v_salt);

  insert into public.usuarios (nombre, email, telefono, password_hash, salt, rol, activo, modulos_custom, notas)
  values (
    trim(p_nombre),
    v_email,
    v_tel,
    v_hash, v_salt, v_rol, true, p_modulos_custom, p_notas
  )
  returning id into v_new_id;

  begin
    insert into public.perfiles (usuario_id, nombre, telefono)
    values (v_new_id, trim(p_nombre), v_tel)
    on conflict (usuario_id) do update
      set nombre = excluded.nombre, telefono = excluded.telefono;
  exception when others then
    null;
  end;

  begin
    insert into public.audit_log (usuario_id, usuario_nombre, accion, tabla, registro_id, detalle)
    values (
      v_actor_id,
      (select nombre from public.usuarios where id = v_actor_id),
      'crear_usuario', 'usuarios', v_new_id::text,
      jsonb_build_object('rol', v_rol, 'email', p_email)
    );
  exception when others then null;
  end;

  select jsonb_build_object(
    'id', u.id, 'nombre', u.nombre, 'email', u.email, 'telefono', u.telefono,
    'rol', u.rol, 'notas', u.notas, 'activo', u.activo, 'modulos_custom', u.modulos_custom
  ) into v_user
  from public.usuarios u where u.id = v_new_id;

  return jsonb_build_object('success', true, 'user', v_user, 'usuario', v_user);
end;
$$;

grant execute on function public.admin_crear_usuario(uuid, text, text, text, text, text, jsonb, text) to anon, authenticated;

commit;
