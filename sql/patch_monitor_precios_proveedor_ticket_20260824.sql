-- Complementa Aprobar PVP con el proveedor del ticket (ultima_compra / lotes).
-- No borra referencias existentes. Idempotente.

begin;

create or replace function public.admin_listar_propuestas_precio(
  p_session_token uuid,
  p_estado        text default 'PENDIENTE'
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
begin
  perform public.fn_require_admin(p_session_token);
  return coalesce((
    select jsonb_agg(row_js order by abs(coalesce(impacto, 0)) desc, id)
    from (
      select jsonb_build_object(
        'id', p.id,
        'producto_id', p.producto_id,
        'sku', p.sku,
        'nombre', p.nombre,
        'precio_actual', p.precio_actual,
        'costo_usado', p.costo_usado,
        'piezas_por_empaque', p.piezas_por_empaque,
        'referencia_unitaria', p.referencia_unitaria,
        'referencia_caja', p.referencia_caja,
        'n_fuentes', p.n_fuentes,
        'fecha_dato_mas_reciente', p.fecha_dato_mas_reciente,
        'piso', p.piso,
        'pmvp', p.pmvp,
        'pvp_sugerido', p.pvp_sugerido,
        'margen_resultante', p.margen_resultante,
        'impacto_estimado', p.impacto_estimado,
        'estado', p.estado,
        'precio_aprobado', p.precio_aprobado,
        'fecha_job', p.fecha_job,
        'created_at', p.created_at,
        'costo_compra', coalesce(uc.precio, p.costo_usado),
        'proveedor_compra', coalesce(
          nullif(btrim(uc.nombre_fuente), ''),
          nullif(btrim(lote_prov.nombre), '')
        )
      ) as row_js,
      p.impacto_estimado as impacto,
      p.id
      from public.propuestas_precio p
      left join public.producto_precios_referencia_actual uc
        on uc.producto_id = p.producto_id
       and uc.fuente = 'ultima_compra'
      left join lateral (
        select pv.nombre
        from public.lotes l
        left join public.proveedores pv on pv.id = l.proveedor_id
        where l.producto_id = p.producto_id
          and coalesce(l.activo, true)
          and nullif(btrim(pv.nombre), '') is not null
        order by (coalesce(l.cantidad_actual, 0) > 0) desc,
                 l.cantidad_actual desc nulls last,
                 l.created_at desc nulls last
        limit 1
      ) lote_prov on true
      where (
        p_estado is null or p_estado = 'TODAS'
        or p.estado = p_estado
      )
    ) s
  ), '[]'::jsonb);
end;
$$;

grant execute on function public.admin_listar_propuestas_precio(uuid, text) to anon, authenticated;

commit;
