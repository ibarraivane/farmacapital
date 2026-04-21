-- ============================================================
-- FARMAX — Parche: GRANT SELECT en tablas operativas (PostgREST)
-- ============================================================
-- Síntoma: 403 en HEAD/GET a /rest/v1/cortes_caja, pedidos, etc.
-- desde el admin (badges, dashboard) aunque RLS tenga USING(true).
--
-- Causa típica tras F6a: solo productos/banners/promociones/sucursales
-- tienen GRANT SELECT explícito; el resto dependía de permisos previos
-- que ya no aplican si la tabla se recreó o el proyecto se ajustó.
--
-- NO otorgamos SELECT completo sobre usuarios/clientes/empleados:
-- esas tablas usan column-level grants en F6a (password_hash, etc.).
--
-- Ejecutar en Supabase SQL Editor (idempotente).
-- ============================================================

begin;

do $$
declare
  v_operativas text[] := array[
    'pedidos','pedido_items','promocion_productos',
    'citas','consumibles_consulta','procedimientos_medicos','medicos',
    'lotes','proveedores','configuracion',
    'cortes_caja','movimientos_caja',
    'facturas','devoluciones','devolucion_items',
    'compras','compra_items',
    'alertas_legales','bitacora_cofepris',
    'movimientos_inventario',
    'folios','envios','direcciones_cliente',
    'equipamiento_consultorio','stock_reservations',
    'perfiles','bitacora_usuarios',
    'lotes_producto'
  ];
  v_tbl text;
begin
  foreach v_tbl in array v_operativas
  loop
    if not exists (
      select 1 from information_schema.tables
      where table_schema = 'public' and table_name = v_tbl
    ) then
      continue;
    end if;

    execute format(
      'grant select on public.%I to anon, authenticated',
      v_tbl
    );
  end loop;
end $$;

commit;

-- Verificación rápida (opcional):
-- select grantee, table_name, privilege_type
-- from information_schema.role_table_grants
-- where table_schema = 'public' and table_name in ('pedidos','cortes_caja')
--   and grantee in ('anon','authenticated') order by table_name, grantee;
