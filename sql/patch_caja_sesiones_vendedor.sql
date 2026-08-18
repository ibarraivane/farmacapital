-- Apertura de caja por turno (vendedor).
-- Una sesión abierta = fondo contado + hora real de entrada.
-- El corte existente cierra esa sesión (hora de salida).
-- Ejecutar en Supabase SQL Editor.

begin;

create table if not exists public.caja_sesiones (
  id                 bigserial primary key,
  empleado_id        bigint not null references public.usuarios(id),
  turno              text not null check (turno in ('matutino', 'vespertino')),
  fecha              date not null,
  fondo_contado      numeric not null default 0,
  denominaciones     jsonb not null default '{}'::jsonb,
  nota_apertura      text,
  abierta_at         timestamptz not null default now(),
  cerrada_at         timestamptz,
  corte_id           bigint references public.cortes_caja(id),
  estado             text not null default 'abierta'
                     check (estado in ('abierta', 'cerrada')),
  created_at         timestamptz not null default now()
);

create unique index if not exists caja_sesiones_una_abierta_empleado
  on public.caja_sesiones (empleado_id)
  where estado = 'abierta';

-- Una sola caja física: no dos turnos abiertos a la vez.
create unique index if not exists caja_sesiones_una_abierta_global
  on public.caja_sesiones ((true))
  where estado = 'abierta';

comment on table public.caja_sesiones is
  'Turno de caja. abierta_at = hora de entrada; cerrada_at = hora de salida (corte).';

alter table public.caja_sesiones enable row level security;


-- ============================================================
-- Suma el desglose en el servidor. Si el cliente manda un total, se ignora.
-- ============================================================
create or replace function public.fn_sumar_denominaciones(p_denoms jsonb)
returns numeric
language plpgsql
immutable
set search_path = public, pg_temp
as $$
declare
  v_total numeric := 0;
  v_key text;
  v_qty int;
  v_face numeric;
begin
  if p_denoms is null or jsonb_typeof(p_denoms) <> 'object' then
    return 0;
  end if;
  for v_key, v_qty in
    select key, greatest(0, coalesce(value::text::int, 0))
    from jsonb_each_text(p_denoms)
  loop
    begin
      v_face := v_key::numeric;
    exception when others then
      continue;
    end;
    if v_face not in (1000, 500, 200, 100, 50, 20, 10, 5, 2, 1, 0.5) then
      continue;
    end if;
    v_total := v_total + (v_face * v_qty);
  end loop;
  return round(v_total, 2);
end;
$$;


create or replace function public.fn_require_caja_abierta_vendedor(p_session_token uuid)
returns bigint
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_user_id bigint;
  v_rol text;
begin
  v_user_id := public.fn_require_empleado(p_session_token);
  select rol into v_rol from public.usuarios where id = v_user_id;
  if coalesce(v_rol, '') <> 'vendedor' then
    return v_user_id;
  end if;
  if not exists (
    select 1 from public.caja_sesiones
    where empleado_id = v_user_id and estado = 'abierta'
  ) then
    raise exception 'Debes abrir caja antes de vender'
      using errcode = 'P0001';
  end if;
  return v_user_id;
end;
$$;


create or replace function public.empleado_sesion_caja_abierta(p_session_token uuid)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_user_id bigint;
  v_row public.caja_sesiones%rowtype;
begin
  v_user_id := public.fn_require_empleado(p_session_token);
  select * into v_row
  from public.caja_sesiones
  where estado = 'abierta'
    and empleado_id = v_user_id
  limit 1;
  if v_row.id is null then
    return jsonb_build_object('abierta', false);
  end if;
  return jsonb_build_object(
    'abierta', true,
    'id', v_row.id,
    'turno', v_row.turno,
    'fecha', v_row.fecha,
    'fondo_contado', v_row.fondo_contado,
    'denominaciones', v_row.denominaciones,
    'nota_apertura', v_row.nota_apertura,
    'abierta_at', v_row.abierta_at
  );
end;
$$;


create or replace function public.abrir_sesion_caja(
  p_session_token uuid,
  p_denominaciones jsonb,
  p_nota text default null
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_user_id bigint;
  v_rol text;
  v_nombre text;
  v_ahora timestamp;
  v_minutos int;
  v_turno text;
  v_fondo numeric;
  v_id bigint;
  v_ocupada text;
begin
  v_user_id := public.fn_require_empleado(p_session_token);
  select rol, nombre into v_rol, v_nombre from public.usuarios where id = v_user_id;

  if exists (
    select 1 from public.caja_sesiones
    where empleado_id = v_user_id and estado = 'abierta'
  ) then
    return jsonb_build_object('success', false, 'error', 'Ya tienes una caja abierta.');
  end if;

  select u.nombre into v_ocupada
  from public.caja_sesiones s
  join public.usuarios u on u.id = s.empleado_id
  where s.estado = 'abierta'
  limit 1;
  if v_ocupada is not null then
    return jsonb_build_object(
      'success', false,
      'error', format('Hay una caja abierta de %s. Debe cerrar turno antes de que abras la tuya.', v_ocupada)
    );
  end if;

  v_fondo := public.fn_sumar_denominaciones(p_denominaciones);
  v_ahora := now() at time zone 'America/Mexico_City';
  v_minutos := (extract(hour from v_ahora)::int * 60) + extract(minute from v_ahora)::int;
  v_turno := case when v_minutos < (15 * 60 + 30) then 'matutino' else 'vespertino' end;

  insert into public.caja_sesiones (
    empleado_id, turno, fecha, fondo_contado, denominaciones, nota_apertura, abierta_at, estado
  ) values (
    v_user_id, v_turno, v_ahora::date, v_fondo,
    coalesce(p_denominaciones, '{}'::jsonb),
    nullif(btrim(coalesce(p_nota, '')), ''),
    now(),
    'abierta'
  ) returning id into v_id;

  begin
    insert into public.audit_log (usuario_id, usuario_nombre, accion, tabla, registro_id, detalle)
    values (
      v_user_id, v_nombre,
      'abrir_caja', 'caja_sesiones', v_id::text,
      jsonb_build_object('turno', v_turno, 'fondo', v_fondo)
    );
  exception when others then null;
  end;

  return jsonb_build_object(
    'success', true,
    'abierta', true,
    'id', v_id,
    'turno', v_turno,
    'fondo_contado', v_fondo,
    'abierta_at', now()
  );
end;
$$;


-- Venta POS: el vendedor no cobra sin caja abierta.
create or replace function public.create_sale_transaction_secure(
  p_session_token uuid,
  p_metodo_pago   text,
  p_total         numeric,
  p_cart_items    jsonb,
  p_cliente_id    bigint default null,
  p_tipo          text   default 'pos',
  p_tipo_entrega  text   default null,
  p_direccion     text   default null
)
returns table(pedido_id bigint, success boolean)
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_user_id bigint;
begin
  v_user_id := public.fn_require_caja_abierta_vendedor(p_session_token);
  return query
  select * from public.create_sale_transaction_v2(
    v_user_id, p_metodo_pago, p_total, p_cart_items,
    p_cliente_id, p_tipo, p_tipo_entrega, p_direccion
  );
end;
$$;


create or replace function public.cobrar_consulta(
  p_session_token   uuid,
  p_cita_id         bigint,
  p_metodo_pago     text,
  p_precio_consulta numeric,
  p_ya_pago_consulta boolean default false,
  p_parte_doctor    numeric default 0,
  p_parte_farmacia  numeric default 0
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_actor_id bigint;
  v_cita     record;
  v_cli      record;
  v_total_consumibles numeric := 0;
  v_base_cobrar numeric;
  v_total_final numeric;
  v_pedido_id bigint;
  v_puntos_nuevos int;
begin
  v_actor_id := public.fn_require_caja_abierta_vendedor(p_session_token);

  select * into v_cita from public.citas where id = p_cita_id;
  if v_cita.id is null then
    raise exception 'Cita % no encontrada', p_cita_id;
  end if;

  select coalesce(sum(precio * cantidad), 0) into v_total_consumibles
  from public.consumibles_consulta
  where cita_id = p_cita_id and coalesce(cobrado, false) = false;

  v_base_cobrar := case when p_ya_pago_consulta then 0 else coalesce(p_precio_consulta, 0) end;
  v_total_final := v_base_cobrar + v_total_consumibles;

  if v_total_final <= 0 then
    raise exception 'No hay monto por cobrar';
  end if;

  select * into v_cli from public.clientes where telefono = v_cita.telefono limit 1;

  insert into public.pedidos (
    cliente_id, total, estado, tipo, metodo_pago, atendido_por
  ) values (
    v_cli.id, v_total_final, 'completado', 'consulta',
    p_metodo_pago, v_actor_id
  ) returning id into v_pedido_id;

  update public.consumibles_consulta set cobrado = true
  where cita_id = p_cita_id and coalesce(cobrado, false) = false;

  if v_base_cobrar > 0 then
    update public.citas set
      pago_estado = 'pagada',
      pedido_consulta_id = v_pedido_id,
      precio_consulta_cobrado = p_precio_consulta,
      ingreso_doctor = p_parte_doctor,
      ingreso_farmacia = p_parte_farmacia
    where id = p_cita_id;
  else
    update public.citas set
      pago_estado = 'pagada',
      pedido_consulta_id = v_pedido_id
    where id = p_cita_id;
  end if;

  if v_cli.id is not null then
    v_puntos_nuevos := floor(v_total_final / 10);
    update public.clientes
       set puntos = coalesce(puntos, 0) + v_puntos_nuevos
     where id = v_cli.id;
  end if;

  return jsonb_build_object(
    'success', true,
    'pedido_id', v_pedido_id,
    'total_final', v_total_final,
    'consumibles_total', v_total_consumibles,
    'puntos_ganados', coalesce(v_puntos_nuevos, 0)
  );
end;
$$;


-- POS: no mandar costo al cliente.
create or replace function public.empleado_listar_productos_con_lotes_pos(p_session_token uuid)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_dummy bigint;
begin
  v_dummy := public.fn_require_empleado(p_session_token);
  return coalesce((
    select jsonb_agg(((to_jsonb(pr) - 'costo') || jsonb_build_object('lotes', lt.js)) order by pr.nombre nulls last)
    from public.productos pr
    left join lateral (
      select
        coalesce(
          jsonb_agg(
            jsonb_build_object(
              'fecha_caducidad', l.fecha_caducidad,
              'cantidad_actual', l.cantidad_actual,
              'activo', l.activo
            )
            order by l.id
          ),
          '[]'::jsonb
        ) as js
      from public.lotes l
      where l.producto_id = pr.id
    ) lt on true
    where coalesce(pr.activo, true) is true
  ), '[]'::jsonb);
end;
$$;


-- Lotes: el vendedor no recibe costo_unitario.
create or replace function public.empleado_listar_lotes_inventario(
  p_session_token uuid
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_user_id bigint;
  v_rol text;
begin
  v_user_id := public.fn_require_empleado(p_session_token);
  select rol into v_rol from public.usuarios where id = v_user_id;

  return coalesce((
    select jsonb_agg(
      (case when coalesce(v_rol, '') = 'vendedor'
            then to_jsonb(l) - 'costo_unitario'
            else to_jsonb(l)
       end) ||
      jsonb_build_object(
        'productos', jsonb_build_object(
          'id', pr.id,
          'nombre', pr.nombre,
          'sku', pr.sku,
          'codigo_barras', pr.codigo_barras,
          'marca', pr.marca,
          'presentacion', pr.presentacion,
          'forma_farmaceutica', pr.forma_farmaceutica,
          'categoria', pr.categoria
        ),
        'proveedores', jsonb_build_object('id', pv.id, 'nombre', pv.nombre)
      )
      order by l.fecha_caducidad nulls last
    )
    from public.lotes l
    join public.productos pr on pr.id = l.producto_id
    left join public.proveedores pv on pv.id = l.proveedor_id
    where coalesce(l.activo, true)
  ), '[]'::jsonb);
end;
$$;


-- Historial de cortes: el vendedor solo ve los suyos, sin esperado del sistema.
create or replace function public.empleado_listar_cortes_caja(
  p_session_token uuid,
  p_limite int default 40,
  p_fecha_desde date default null,
  p_fecha_hasta date default null,
  p_turno text default null
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_user_id bigint;
  v_rol text;
begin
  v_user_id := public.fn_require_empleado(p_session_token);
  select rol into v_rol from public.usuarios where id = v_user_id;
  return coalesce((
    select jsonb_agg(row_js order by ord desc nulls last)
    from (
      select
        jsonb_build_object(
          'id',                 c.id,
          'fecha',             (c.fecha + coalesce(c.hora_cierre, c.hora_apertura)),
          'turno',              c.turno,
          'cajero',             u.nombre,
          'contado_por',        c.contado_por,
          'fondo_inicial',      c.fondo_inicial,
          'efectivo_declarado', c.efectivo_declarado,
          'efectivo_sistema',   case when coalesce(v_rol,'') = 'vendedor' then null else c.efectivo_sistema end,
          'esperado',           case when coalesce(v_rol,'') = 'vendedor' then null else (c.fondo_inicial + c.efectivo_sistema) end,
          'diferencia',         c.diferencia,
          'tarjeta',            c.total_tarjeta,
          'spei',               c.total_spei,
          'mercadopago',        c.total_mercadopago,
          'total_general',      case when coalesce(v_rol,'') = 'vendedor' then null else c.total_general end,
          'denominaciones',     c.denominaciones,
          'notas',              c.notas
        ) as row_js,
        c.created_at as ord
      from public.cortes_caja c
      left join public.usuarios u on u.id = c.empleado_id
      where (p_fecha_desde is null or c.fecha >= p_fecha_desde)
        and (p_fecha_hasta is null or c.fecha <= p_fecha_hasta)
        and (p_turno is null or p_turno = '' or p_turno = 'todos' or c.turno = p_turno)
        and (coalesce(v_rol,'') <> 'vendedor' or c.empleado_id = v_user_id)
      order by c.created_at desc nulls last
      limit greatest(1, least(coalesce(p_limite, 40), 120))
    ) s
  ), '[]'::jsonb);
end;
$$;


-- Corte: usa fondo y hora real de la sesión abierta; la cierra.
create or replace function public.registrar_corte_caja(
  p_session_token      uuid,
  p_turno              text,
  p_efectivo_declarado numeric,
  p_efectivo_sistema   numeric,
  p_tarjeta            numeric,
  p_mercadopago        numeric,
  p_diferencia         numeric,
  p_total_general      numeric,
  p_spei               numeric default 0,
  p_notas              text default null,
  p_fondo_inicial      numeric default 0,
  p_contado_por        text default null,
  p_denominaciones     jsonb default null
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_actor_id bigint;
  v_nombre   text;
  v_corte_id bigint;
  v_ahora    timestamp;
  v_apertura time;
  v_sistema  numeric;
  v_fila     public.cortes_caja%rowtype;
  v_sesion   public.caja_sesiones%rowtype;
  v_fondo    numeric;
  v_turno    text;
  v_decl     numeric;
begin
  v_actor_id := public.fn_require_empleado(p_session_token);
  select nombre into v_nombre from public.usuarios where id = v_actor_id;

  v_ahora := now() at time zone 'America/Mexico_City';
  v_decl  := public.fn_sumar_denominaciones(p_denominaciones);
  if v_decl is null or v_decl = 0 then
    v_decl := coalesce(p_efectivo_declarado, 0);
  end if;

  select * into v_sesion
  from public.caja_sesiones
  where empleado_id = v_actor_id and estado = 'abierta'
  limit 1;

  if v_sesion.id is not null then
    v_fondo := v_sesion.fondo_contado;
    v_turno := v_sesion.turno;
    v_apertura := (v_sesion.abierta_at at time zone 'America/Mexico_City')::time;
  else
    v_fondo := coalesce(p_fondo_inicial, 0);
    v_turno := coalesce(nullif(p_turno, ''), 'matutino');
    v_apertura := case when v_turno = 'matutino' then time '08:00' else time '15:00' end;
  end if;

  v_sistema := coalesce(
    (public.reconcile_shift_cash(v_turno, v_ahora::date)->>'efectivo_sistema')::numeric, 0);

  insert into public.cortes_caja (
    turno, empleado_id, fecha, hora_apertura, hora_cierre,
    efectivo_declarado, efectivo_sistema, fondo_inicial,
    total_tarjeta, total_spei, total_mercadopago,
    contado_por, denominaciones, notas
  ) values (
    v_turno, v_actor_id, v_ahora::date, v_apertura, v_ahora::time,
    v_decl, v_sistema, v_fondo,
    coalesce(p_tarjeta, 0), coalesce(p_spei, 0), coalesce(p_mercadopago, 0),
    nullif(btrim(coalesce(p_contado_por, '')), ''), p_denominaciones, p_notas
  ) returning * into v_fila;

  v_corte_id := v_fila.id;

  if v_sesion.id is not null then
    update public.caja_sesiones
       set estado = 'cerrada',
           cerrada_at = now(),
           corte_id = v_corte_id
     where id = v_sesion.id;
  end if;

  begin
    insert into public.audit_log (usuario_id, usuario_nombre, accion, tabla, registro_id, detalle)
    values (
      v_actor_id, v_nombre,
      'corte_caja', 'cortes_caja', v_corte_id::text,
      jsonb_build_object('turno', v_turno, 'diferencia', v_fila.diferencia,
                         'total', v_fila.total_general, 'fondo', v_fila.fondo_inicial)
    );
  exception when others then null;
  end;

  return jsonb_build_object(
    'success',          true,
    'corte_id',         v_corte_id,
    'efectivo_sistema', v_fila.efectivo_sistema,
    'fondo_inicial',    v_fila.fondo_inicial,
    'esperado',         v_fila.fondo_inicial + v_fila.efectivo_sistema,
    'diferencia',       v_fila.diferencia,
    'total_general',    v_fila.total_general,
    'hora_apertura',    v_fila.hora_apertura,
    'hora_cierre',      v_fila.hora_cierre
  );
end;
$$;


grant execute on function public.fn_sumar_denominaciones(jsonb) to anon, authenticated;
grant execute on function public.fn_require_caja_abierta_vendedor(uuid) to anon, authenticated;
grant execute on function public.empleado_sesion_caja_abierta(uuid) to anon, authenticated;
grant execute on function public.abrir_sesion_caja(uuid, jsonb, text) to anon, authenticated;
grant execute on function public.create_sale_transaction_secure(uuid, text, numeric, jsonb, bigint, text, text, text) to anon, authenticated;
grant execute on function public.cobrar_consulta(uuid, bigint, text, numeric, boolean, numeric, numeric) to anon, authenticated;
grant execute on function public.empleado_listar_productos_con_lotes_pos(uuid) to anon, authenticated;
grant execute on function public.empleado_listar_lotes_inventario(uuid) to anon, authenticated;
grant execute on function public.empleado_listar_cortes_caja(uuid, int, date, date, text) to anon, authenticated;
grant execute on function public.registrar_corte_caja(uuid, text, numeric, numeric, numeric, numeric, numeric, numeric, numeric, text, numeric, text, jsonb) to anon, authenticated;

commit;
