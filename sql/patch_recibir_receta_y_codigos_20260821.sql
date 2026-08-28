-- Recibir: receta del piso (no sobreescribir catálogo) + códigos en la lista
-- para abrir un ticket escaneando cualquier caja.

update public.productos
set requiere_receta = false
where sku in ('EQ-MAV236', 'EQ-BIO212', 'FC-C9F4ACCC', 'EQ-BEA267')
  and coalesce(requiere_receta, false) is distinct from false;

update public.recepciones
set proveedor = 'Levic'
where id = 4
  and folio = '9012078353'
  and coalesce(proveedor, '') is distinct from 'Levic';

create or replace function public.recepcion_listar_abiertas(
  p_session_token uuid
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_user bigint;
  v_out jsonb;
begin
  v_user := public.fn_require_empleado(p_session_token);
  select coalesce(jsonb_agg(row_to_json(x)::jsonb order by x.updated_at desc), '[]'::jsonb)
  into v_out
  from (
    select
      r.id,
      r.proveedor,
      r.folio,
      r.fecha,
      r.total_ticket,
      r.estado,
      r.updated_at,
      count(i.id)::int as renglones,
      coalesce(sum(i.cantidad), 0)::int as piezas,
      count(*) filter (where i.pendiente_alta)::int as pendientes_alta,
      count(*) filter (where not i.confirmado)::int as sin_confirmar,
      count(*) filter (where i.lote_id is not null and i.fecha_caducidad is null)::int as sin_caducidad_anaquel,
      coalesce(
        array_remove(array_agg(distinct i.codigo_escaneado), null),
        array[]::text[]
      ) as codigos
    from public.recepciones r
    left join public.recepcion_items i on i.recepcion_id = r.id
    where r.estado in ('borrador', 'pendiente_alta', 'pendiente_caducidad')
    group by r.id
  ) x;
  return v_out;
end;
$$;

grant execute on function public.recepcion_listar_abiertas(uuid) to anon, authenticated;
