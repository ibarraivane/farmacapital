-- FarmaCapital — Fase (b) Caso A: avisos de disponibilidad.
-- Idempotente. Requiere patch_encargo_medicamentos_fase_a_20260915.sql.
--
-- Trigger conceptual "entrada validada" → productos.stock pasa de <=0 a >0
-- (cubre recepción, lotes, ajustes). Estado UI listo_avisar se DERIVA:
--   notificado=false AND productos.stock > 0

begin;

-- ── Alta pública (service_role / API) ───────────────────────────────
create or replace function public.tienda_crear_aviso_disponibilidad(
  p_producto_id      bigint,
  p_cliente_telefono text,
  p_cliente_nombre   text default null
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_tel   text;
  v_nom   text;
  v_stock numeric;
  v_id    uuid;
  v_exist uuid;
begin
  v_tel := regexp_replace(coalesce(p_cliente_telefono, ''), '\D', '', 'g');
  if length(v_tel) >= 10 then
    v_tel := right(v_tel, 10);
  end if;
  if v_tel !~ '^[0-9]{10}$' then
    raise exception 'telefono_invalido' using errcode = '22023';
  end if;

  v_nom := nullif(trim(regexp_replace(coalesce(p_cliente_nombre, ''), '\s+', ' ', 'g')), '');
  if v_nom is not null then
    v_nom := left(v_nom, 120);
  end if;

  select coalesce(p.stock, 0) into v_stock
  from public.productos p
  where p.id = p_producto_id;

  if v_stock is null then
    raise exception 'producto_no_encontrado' using errcode = 'P0002';
  end if;
  if v_stock > 0 then
    raise exception 'producto_con_stock' using errcode = '23514';
  end if;

  select a.id into v_exist
  from public.aviso_disponibilidad a
  where a.producto_id = p_producto_id
    and a.cliente_telefono = v_tel
    and a.notificado = false
  limit 1;

  if v_exist is not null then
    if v_nom is not null then
      update public.aviso_disponibilidad
         set cliente_nombre = coalesce(cliente_nombre, v_nom)
       where id = v_exist
         and cliente_nombre is null;
    end if;
    return jsonb_build_object(
      'id', v_exist,
      'producto_id', p_producto_id,
      'cliente_telefono', v_tel,
      'duplicado', true,
      'mensaje', 'Ya estás registrado: te avisamos cuando haya stock.'
    );
  end if;

  insert into public.aviso_disponibilidad (
    producto_id, cliente_telefono, cliente_nombre
  ) values (
    p_producto_id, v_tel, v_nom
  )
  returning id into v_id;

  return jsonb_build_object(
    'id', v_id,
    'producto_id', p_producto_id,
    'cliente_telefono', v_tel,
    'duplicado', false,
    'mensaje', 'Listo. Te avisamos por WhatsApp cuando esté disponible.'
  );
end;
$$;

revoke all on function public.tienda_crear_aviso_disponibilidad(bigint, text, text)
  from public, anon, authenticated;
grant execute on function public.tienda_crear_aviso_disponibilidad(bigint, text, text)
  to service_role;

comment on function public.tienda_crear_aviso_disponibilidad(bigint, text, text) is
  'Caso A público: alta de aviso. Dedupe (producto_id, telefono) activo. Solo service_role (API).';

-- ── Listado empleado (Pedidos online → Avisos) ──────────────────────
create or replace function public.empleado_listar_avisos_disponibilidad(
  p_session_token uuid,
  p_filtro        text default 'listos', -- listos | pendientes | avisados | todos
  p_limite        integer default 100
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_dummy bigint;
  v_lim   integer;
  v_f     text;
begin
  v_dummy := public.fn_require_empleado(p_session_token);
  v_lim := greatest(1, least(coalesce(p_limite, 100), 300));
  v_f := lower(trim(coalesce(p_filtro, 'listos')));
  if v_f not in ('listos', 'pendientes', 'avisados', 'todos') then
    v_f := 'listos';
  end if;

  return coalesce((
    select jsonb_agg(row_to_json(x)::jsonb order by x.sort_at desc)
    from (
      select
        a.id,
        a.producto_id,
        p.nombre as producto_nombre,
        coalesce(p.stock, 0) as producto_stock,
        a.cliente_telefono,
        a.cliente_nombre,
        a.notificado,
        a.notificado_at,
        a.created_at,
        case
          when a.notificado then 'avisado'
          when coalesce(p.stock, 0) > 0 then 'listo_avisar'
          else 'pendiente'
        end as estado_ui,
        case
          when a.notificado then a.notificado_at
          when coalesce(p.stock, 0) > 0 then a.created_at
          else a.created_at
        end as sort_at
      from public.aviso_disponibilidad a
      join public.productos p on p.id = a.producto_id
      where
        (v_f = 'todos')
        or (v_f = 'avisados' and a.notificado = true)
        or (v_f = 'listos' and a.notificado = false and coalesce(p.stock, 0) > 0)
        or (v_f = 'pendientes' and a.notificado = false and coalesce(p.stock, 0) <= 0)
      order by sort_at desc
      limit v_lim
    ) x
  ), '[]'::jsonb);
end;
$$;

revoke all on function public.empleado_listar_avisos_disponibilidad(uuid, text, integer)
  from public, anon, authenticated;
grant execute on function public.empleado_listar_avisos_disponibilidad(uuid, text, integer)
  to authenticated, anon;

comment on function public.empleado_listar_avisos_disponibilidad(uuid, text, integer) is
  'Cola Caso A para Pedidos online. listos = stock>0 y no notificado (1 wa.me por fila).';

create or replace function public.empleado_contar_avisos_listos(
  p_session_token uuid
)
returns integer
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_dummy bigint;
  v_n     integer;
begin
  v_dummy := public.fn_require_empleado(p_session_token);
  select count(*)::integer into v_n
  from public.aviso_disponibilidad a
  join public.productos p on p.id = a.producto_id
  where a.notificado = false
    and coalesce(p.stock, 0) > 0;
  return coalesce(v_n, 0);
end;
$$;

revoke all on function public.empleado_contar_avisos_listos(uuid)
  from public, anon, authenticated;
grant execute on function public.empleado_contar_avisos_listos(uuid)
  to authenticated, anon;

create or replace function public.empleado_marcar_aviso_notificado(
  p_session_token uuid,
  p_aviso_id      uuid
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_dummy bigint;
  v_row   public.aviso_disponibilidad%rowtype;
begin
  v_dummy := public.fn_require_empleado(p_session_token);

  update public.aviso_disponibilidad
     set notificado = true,
         notificado_at = now()
   where id = p_aviso_id
     and notificado = false
  returning * into v_row;

  if v_row.id is null then
    select * into v_row from public.aviso_disponibilidad where id = p_aviso_id;
    if v_row.id is null then
      raise exception 'aviso_no_encontrado' using errcode = 'P0002';
    end if;
  end if;

  return jsonb_build_object(
    'id', v_row.id,
    'producto_id', v_row.producto_id,
    'cliente_telefono', v_row.cliente_telefono,
    'notificado', v_row.notificado,
    'notificado_at', v_row.notificado_at
  );
end;
$$;

revoke all on function public.empleado_marcar_aviso_notificado(uuid, uuid)
  from public, anon, authenticated;
grant execute on function public.empleado_marcar_aviso_notificado(uuid, uuid)
  to authenticated, anon;

-- ── Hook stock 0 → >0 (auditoría / futuro push; UI deriva estado) ───
create table if not exists public.aviso_disponibilidad_eventos (
  id           bigserial primary key,
  producto_id  bigint not null references public.productos(id) on delete cascade,
  stock_antes  numeric,
  stock_despues numeric,
  avisos_pendientes integer not null default 0,
  created_at   timestamptz not null default now()
);

create index if not exists aviso_disponibilidad_eventos_prod_idx
  on public.aviso_disponibilidad_eventos (producto_id, created_at desc);

comment on table public.aviso_disponibilidad_eventos is
  'Log cuando un producto pasa de stock<=0 a >0 con avisos pendientes. Fase b.';

alter table public.aviso_disponibilidad_eventos enable row level security;
revoke all on table public.aviso_disponibilidad_eventos from anon, authenticated;
drop policy if exists aviso_disponibilidad_eventos_sin_acceso on public.aviso_disponibilidad_eventos;
create policy aviso_disponibilidad_eventos_sin_acceso
  on public.aviso_disponibilidad_eventos
  for all using (false) with check (false);

create or replace function public.trg_productos_aviso_disponibilidad_restock()
returns trigger
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_n integer;
begin
  if tg_op = 'UPDATE'
     and coalesce(old.stock, 0) <= 0
     and coalesce(new.stock, 0) > 0
  then
    select count(*)::integer into v_n
    from public.aviso_disponibilidad a
    where a.producto_id = new.id
      and a.notificado = false;

    if coalesce(v_n, 0) > 0 then
      insert into public.aviso_disponibilidad_eventos (
        producto_id, stock_antes, stock_despues, avisos_pendientes
      ) values (
        new.id, old.stock, new.stock, v_n
      );
    end if;
  end if;
  return new;
end;
$$;

drop trigger if exists trg_productos_aviso_disponibilidad_restock on public.productos;
create trigger trg_productos_aviso_disponibilidad_restock
  after update of stock on public.productos
  for each row
  execute function public.trg_productos_aviso_disponibilidad_restock();

commit;
