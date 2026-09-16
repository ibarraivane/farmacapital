-- Flujo de caja: corregir un gasto capturado a mano (categoría, fecha, monto…).
-- No toca salidas derivadas (comisión, merma, liquidación).
-- Ejecutar TODO el archivo en Supabase → SQL Editor → Run. Idempotente.

begin;

create or replace function public.admin_actualizar_gasto(
  p_session_token uuid,
  p_id            bigint,
  p_gasto         jsonb
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_actor     bigint;
  v_g         jsonb := coalesce(p_gasto, '{}'::jsonb);
  v_fecha     date;
  v_cat       text;
  v_concepto  text;
  v_monto     numeric;
  v_afecta    boolean;
  v_origen    text;
  v_row       jsonb;
  v_n         int;
begin
  v_actor := public.fn_require_admin(p_session_token);

  if p_id is null then
    return jsonb_build_object('success', false, 'error', 'Id requerido');
  end if;

  select g.origen into v_origen
    from public.gastos g
   where g.id = p_id
     and g.eliminado_at is null;

  if not found then
    return jsonb_build_object('success', false, 'error', 'Gasto no encontrado');
  end if;

  if v_origen is distinct from 'manual' then
    return jsonb_build_object(
      'success', false,
      'error', 'Esa salida la armó el sistema. No se corrige a mano.'
    );
  end if;

  begin
    v_fecha := coalesce(nullif(v_g->>'fecha', '')::date,
                        (now() at time zone 'America/Mexico_City')::date);
  exception when others then
    return jsonb_build_object('success', false, 'error', 'Fecha inválida');
  end;

  v_cat := lower(trim(coalesce(v_g->>'categoria', '')));
  if v_cat not in (
    'renta','nomina','servicios','comisiones','mermas','mantenimiento',
    'publicidad','insumos','seguros','licencias','impuestos','financieros',
    'ajuste_redondeo','compra_inventario','otros'
  ) then
    return jsonb_build_object('success', false, 'error', 'Categoría inválida');
  end if;

  v_concepto := trim(coalesce(v_g->>'concepto', ''));
  if v_concepto = '' then
    return jsonb_build_object('success', false, 'error', 'Concepto requerido');
  end if;

  begin
    v_monto := round(coalesce((v_g->>'monto')::numeric, 0), 2);
  exception when others then
    return jsonb_build_object('success', false, 'error', 'Monto inválido');
  end;
  if v_monto <= 0 then
    return jsonb_build_object('success', false, 'error', 'El monto debe ser mayor a 0');
  end if;

  if v_cat = 'compra_inventario' then
    v_afecta := false;
  else
    v_afecta := coalesce((v_g->>'afecta_pl')::boolean, true);
  end if;

  update public.gastos
     set fecha         = v_fecha,
         categoria     = v_cat,
         concepto      = v_concepto,
         monto         = v_monto,
         proveedor     = nullif(trim(coalesce(v_g->>'proveedor', '')), ''),
         es_recurrente = coalesce((v_g->>'es_recurrente')::boolean, false),
         periodicidad  = nullif(trim(coalesce(v_g->>'periodicidad', '')), ''),
         notas         = nullif(trim(coalesce(v_g->>'notas', '')), ''),
         afecta_pl     = v_afecta
   where id = p_id
     and eliminado_at is null
     and origen = 'manual';

  get diagnostics v_n = row_count;
  if v_n = 0 then
    return jsonb_build_object('success', false, 'error', 'No se pudo guardar');
  end if;

  begin
    insert into public.audit_log (usuario_id, usuario_nombre, accion, tabla, registro_id, detalle)
    values (
      v_actor,
      (select nombre from public.usuarios where id = v_actor),
      'actualizar_gasto',
      'gastos',
      p_id::text,
      jsonb_build_object('categoria', v_cat, 'monto', v_monto, 'concepto', v_concepto)::text
    );
  exception when others then null;
  end;

  select jsonb_build_object(
    'id', g.id,
    'fecha', g.fecha,
    'categoria', g.categoria,
    'concepto', g.concepto,
    'monto', g.monto,
    'origen', g.origen,
    'es_recurrente', g.es_recurrente,
    'periodicidad', g.periodicidad,
    'proveedor', g.proveedor,
    'afecta_pl', g.afecta_pl,
    'notas', g.notas
  ) into v_row
  from public.gastos g
  where g.id = p_id;

  return jsonb_build_object('success', true, 'gasto', v_row);
end;
$$;

grant execute on function public.admin_actualizar_gasto(uuid, bigint, jsonb)
  to anon, authenticated;

notify pgrst, 'reload schema';

commit;
