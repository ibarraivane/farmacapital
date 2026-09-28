-- ============================================================================
-- Inventario carga rápido · 28-sep-2026
--
-- empleado_listar_lotes_inventario arma un solo jsonb con TODOS los lotes.
-- Con el catálogo actual esa respuesta se va de tiempo o de tamaño y el
-- módulo se queda en el skeleton (la pantalla espera productos + lotes).
--
-- Esta función devuelve como máximo 1000 lotes por llamada, con las columnas
-- que pinta la tabla. El cliente pide la siguiente página con el último id.
-- El inventario nuevo funciona sin este parche (cae a la lectura directa o
-- al RPC viejo). Pegar en Supabase → SQL Editor → Run. Idempotente.
-- ============================================================================

begin;

create index if not exists idx_productos_activo_nombre_id
  on public.productos (activo, nombre, id);

create or replace function public.empleado_listar_lotes_inventario_pagina(
  p_session_token uuid,
  p_despues_de bigint default 0,
  p_limite integer default 1000
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_dummy bigint;
  v_limite integer := least(greatest(coalesce(p_limite, 1000), 1), 1000);
  v_despues bigint := greatest(coalesce(p_despues_de, 0), 0);
begin
  v_dummy := public.fn_require_empleado(p_session_token);

  return coalesce((
    select jsonb_agg(q.row_js order by q.id)
    from (
      select
        l.id,
        jsonb_build_object(
          'id', l.id,
          'producto_id', l.producto_id,
          'numero_lote', l.numero_lote,
          'fecha_caducidad', l.fecha_caducidad,
          'cantidad_actual', l.cantidad_actual,
          'cantidad_inicial', l.cantidad_inicial,
          'costo_unitario', l.costo_unitario,
          'activo', l.activo,
          'fecha_recepcion', l.fecha_recepcion,
          'proveedor_id', l.proveedor_id,
          'productos', jsonb_build_object(
            'nombre', pr.nombre,
            'sku', pr.sku,
            'categoria', pr.categoria
          ),
          'proveedores', case
            when pv.id is null then null
            else jsonb_build_object('id', pv.id, 'nombre', pv.nombre)
          end
        ) as row_js
      from public.lotes l
      join public.productos pr on pr.id = l.producto_id
      left join public.proveedores pv on pv.id = l.proveedor_id
      where coalesce(l.activo, true)
        and l.id > v_despues
      order by l.id
      limit v_limite
    ) q
  ), '[]'::jsonb);
end;
$$;

grant execute on function public.empleado_listar_lotes_inventario_pagina(uuid, bigint, integer)
  to anon, authenticated;

commit;
