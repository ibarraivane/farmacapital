-- Recibir: el precio se pone solo; la caducidad sigue saliendo de la caja.
--
-- Qué arregla
--   1) fc_recepcion_json no mandaba costo_estimado. La pistola pedía MMAA
--      y el recuadro de costo salía vacío aunque el ticket ya lo traía.
--   2) Rellena costo_estimado vacío en tickets vivos (borrador / pendiente)
--      con catálogo → última compra → lote.
--   3) Pone PVP (productos.precio) en productos a recibir que no tienen
--      precio: recargo 25% patente / 60% genérico, peso entero hacia arriba.
--      No pisa un PVP que ya esté. El vendedor lo corrobora en mostrador.
--
-- Ejecutar TODO en Supabase → SQL Editor → Run. Idempotente.

begin;

create or replace function public.fc_recepcion_json(p_recepcion_id bigint)
returns jsonb
language plpgsql
stable
set search_path = public
as $$
declare
  v_rec public.recepciones%rowtype;
  v_items jsonb;
  v_subtotal numeric;
  v_renglones int;
  v_piezas int;
  v_pendientes int;
  v_sin_confirmar int;
  v_sin_cad int;
begin
  select * into v_rec from public.recepciones where id = p_recepcion_id;
  if not found then
    return null;
  end if;

  select
    coalesce(jsonb_agg(
      jsonb_build_object(
        'id', i.id,
        'producto_id', i.producto_id,
        'codigo_escaneado', i.codigo_escaneado,
        'nombre', coalesce(pr.nombre, i.nombre_snapshot, i.codigo_escaneado),
        'sku', pr.sku,
        'cantidad', i.cantidad,
        'fecha_caducidad', i.fecha_caducidad,
        'numero_lote', i.numero_lote,
        'costo_estimado', i.costo_estimado,
        'costo_catalogo', pr.costo,
        'precio', pr.precio,
        'tipo', pr.tipo,
        'pendiente_alta', i.pendiente_alta,
        'confirmado', i.confirmado,
        'origen', i.origen,
        'lote_distinto', i.lote_distinto,
        'lote_id', i.lote_id,
        'lotes_piso', (
          select coalesce(jsonb_agg(l.numero_lote order by l.fecha_caducidad nulls first, l.id), '[]'::jsonb)
          from public.lotes l
          where l.producto_id = i.producto_id
            and coalesce(l.activo, true)
            and coalesce(l.cantidad_actual, 0) > 0
        )
      )
      order by i.confirmado, i.id
    ), '[]'::jsonb),
    coalesce(sum(i.cantidad * coalesce(i.costo_estimado, 0)), 0),
    count(*)::int,
    coalesce(sum(i.cantidad), 0)::int,
    count(*) filter (where i.pendiente_alta)::int,
    count(*) filter (where not i.confirmado)::int,
    count(*) filter (where i.lote_id is not null and i.fecha_caducidad is null)::int
  into v_items, v_subtotal, v_renglones, v_piezas, v_pendientes, v_sin_confirmar, v_sin_cad
  from public.recepcion_items i
  left join public.productos pr on pr.id = i.producto_id
  where i.recepcion_id = p_recepcion_id;

  return jsonb_build_object(
    'id', v_rec.id,
    'proveedor', v_rec.proveedor,
    'folio', v_rec.folio,
    'fecha', v_rec.fecha,
    'total_ticket', v_rec.total_ticket,
    'estado', v_rec.estado,
    'capturado_por', v_rec.capturado_por,
    'subtotal_estimado', round(v_subtotal, 2),
    'diferencia', case
      when v_rec.total_ticket is null then null
      else round(v_subtotal - v_rec.total_ticket, 2)
    end,
    'renglones', v_renglones,
    'piezas', v_piezas,
    'pendientes_alta', v_pendientes,
    'sin_confirmar', v_sin_confirmar,
    'sin_caducidad_anaquel', v_sin_cad,
    'updated_at', v_rec.updated_at,
    'cerrado_en', v_rec.cerrado_en,
    'items', v_items
  );
end;
$$;

-- Costo del renglón si el ticket no lo trajo.
update public.recepcion_items i
set costo_estimado = x.costo
from (
  select
    i2.id,
    coalesce(
      nullif(i2.costo_estimado, 0),
      nullif(p.costo, 0),
      (
        select a.precio
        from public.producto_precios_referencia_actual a
        where a.producto_id = i2.producto_id
          and a.fuente = 'ultima_compra'
          and a.precio is not null
          and a.precio > 0
        limit 1
      ),
      (
        select l.costo_unitario
        from public.lotes l
        where l.producto_id = i2.producto_id
          and coalesce(l.activo, true)
          and l.costo_unitario is not null
          and l.costo_unitario > 0
        order by coalesce(l.cantidad_actual, 0) desc, l.id desc
        limit 1
      )
    ) as costo
  from public.recepcion_items i2
  join public.recepciones r on r.id = i2.recepcion_id
  left join public.productos p on p.id = i2.producto_id
  where r.estado in ('borrador', 'pendiente_alta', 'pendiente_caducidad')
) x
where i.id = x.id
  and (i.costo_estimado is null or i.costo_estimado <= 0)
  and x.costo is not null
  and x.costo > 0;

-- PVP faltante en productos de esos tickets. No pisa un precio ya puesto.
update public.productos p
set precio = x.pvp
from (
  select
    p2.id,
    ceil(
      c.costo * case
        when lower(coalesce(p2.tipo, '')) in ('marca', 'patente') then 1.25
        else 1.60
      end
    )::numeric as pvp,
    c.costo
  from public.productos p2
  join (
    select
      i.producto_id,
      max(coalesce(nullif(i.costo_estimado, 0), nullif(pr.costo, 0))) as costo
    from public.recepcion_items i
    join public.recepciones r on r.id = i.recepcion_id
    left join public.productos pr on pr.id = i.producto_id
    where r.estado in ('borrador', 'pendiente_alta', 'pendiente_caducidad')
      and i.producto_id is not null
      and not i.pendiente_alta
    group by i.producto_id
  ) c on c.producto_id = p2.id
  where c.costo is not null
    and c.costo > 0
    and (p2.precio is null or p2.precio <= 0)
) x
where p.id = x.id
  and (p.precio is null or p.precio <= 0)
  and x.pvp > x.costo;

notify pgrst, 'reload schema';

commit;

-- ─────────────── Qué quedó en tickets vivos ───────────────
select
  r.proveedor,
  r.folio,
  r.estado,
  count(*) as renglones,
  count(*) filter (where i.costo_estimado is not null and i.costo_estimado > 0) as con_costo,
  count(*) filter (where i.costo_estimado is null or i.costo_estimado <= 0) as sin_costo,
  count(*) filter (where coalesce(p.precio, 0) <= 0 and i.producto_id is not null) as sin_pvp
from public.recepciones r
join public.recepcion_items i on i.recepcion_id = r.id
left join public.productos p on p.id = i.producto_id
where r.estado in ('borrador', 'pendiente_alta', 'pendiente_caducidad')
group by r.id, r.proveedor, r.folio, r.estado
order by r.updated_at desc;

select
  r.folio,
  left(coalesce(p.nombre, i.nombre_snapshot), 40) as producto,
  i.cantidad,
  i.costo_estimado as costo,
  p.precio as pvp,
  p.tipo
from public.recepcion_items i
join public.recepciones r on r.id = i.recepcion_id
left join public.productos p on p.id = i.producto_id
where r.estado in ('borrador', 'pendiente_alta', 'pendiente_caducidad')
  and (
    i.costo_estimado is null
    or i.costo_estimado <= 0
    or (i.producto_id is not null and coalesce(p.precio, 0) <= 0)
  )
order by r.folio, i.id;
