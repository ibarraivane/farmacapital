-- ============================================================================
-- Rendimiento POS · 24-sep-2026 · RPC de cambios (delta) del catálogo
--
-- Problema: con cada venta / recepción / edición, TODAS las terminales del POS
-- volvían a bajar el catálogo completo (empleado_listar_productos_con_lotes_pos:
-- todas las filas + lotes) más otras dos llamadas.
--
-- Esto agrega un RPC que devuelve SOLO los productos modificados desde p_desde
-- (incluye los que quedaron inactivos, para que el cliente los quite).
-- Los cambios en lotes también llegan porque trg_sync_productos_stock hace
-- UPDATE a productos en cada cambio de lote, y el trigger de abajo mueve
-- updated_at. El cliente además hace refresco completo cada 5 min.
--
-- La base viva NO tenía productos.updated_at (ERROR 42703 al crear el índice).
-- Este archivo la agrega, rellena las filas viejas con una fecha antigua (para
-- que el primer delta no baje todo el catálogo) y crea el trigger BEFORE UPDATE.
-- No toca precio, stock, costo ni lotes. El POS nuevo funciona sin este RPC
-- (cae al refresco completo).
-- Pegar en Supabase → SQL Editor → Run. Idempotente.
-- ============================================================================

begin;

alter table public.productos
  add column if not exists updated_at timestamptz;

-- Fecha vieja a propósito: si se pusiera now(), el primer delta devolvería
-- todos los productos. Los cambios de verdad empiezan a partir de este parche.
update public.productos
   set updated_at = timestamptz '2000-01-01+00'
 where updated_at is null;

alter table public.productos
  alter column updated_at set default now();

create or replace function public.update_productos_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists trigger_update_productos_updated_at on public.productos;
create trigger trigger_update_productos_updated_at
  before update on public.productos
  for each row
  execute function public.update_productos_updated_at();

create index if not exists idx_productos_updated_at
  on public.productos (updated_at);

create or replace function public.empleado_listar_productos_pos_delta(
  p_session_token uuid,
  p_desde timestamptz
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_dummy bigint;
begin
  v_dummy := public.fn_require_empleado(p_session_token);

  return jsonb_build_object(
    'ahora', clock_timestamp(),
    'productos', coalesce((
      select jsonb_agg(((to_jsonb(pr) - 'costo') || jsonb_build_object('lotes', lt.js)) order by pr.nombre nulls last)
      from public.productos pr
      left join lateral (
        select coalesce(
          jsonb_agg(
            jsonb_build_object(
              'id', l.id,
              'numero_lote', l.numero_lote,
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
      where pr.updated_at >= p_desde
    ), '[]'::jsonb)
  );
end;
$$;

revoke all on function public.empleado_listar_productos_pos_delta(uuid, timestamptz) from public;
grant execute on function public.empleado_listar_productos_pos_delta(uuid, timestamptz) to anon, authenticated;

commit;

-- Verificación (correr aparte, con un token de sesión de empleado vigente):
--   select jsonb_array_length((public.empleado_listar_productos_pos_delta('<TOKEN>', now() - interval '10 minutes'))->'productos');
