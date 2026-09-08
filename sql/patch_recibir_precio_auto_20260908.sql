-- Recibir: el precio se pone solo; SIEMPRE por pieza, no el importe del renglón.
-- La caducidad sigue saliendo de la caja.
--
-- Qué arregla
--   1) fc_recepcion_json no mandaba costo_estimado. La pistola pedía MMAA
--      y el recuadro de costo salía vacío aunque el ticket ya lo traía.
--   2) Rellena costo_estimado vacío en tickets vivos (borrador / pendiente)
--      con catálogo → última compra → lote.
--   3) Si el renglón trajo el total de 2 (Neutrogena 91.78) lo parte:
--      costo por pieza 45.89. Lo mismo en catálogo / lote / PVP si se
--      guardó el de dos como si fuera de una.
--   4) Pone PVP (productos.precio) en productos a recibir que no tienen
--      precio: recargo 25% patente / 60% genérico, peso entero hacia arriba.
--      Sobre el costo UNITARIO. No pisa un PVP que ya esté bien.
--
-- Ejecutar TODO en Supabase → SQL Editor → Run. Idempotente.
-- Si ya corriste una versión anterior, vuelve a correr esta: corrige el de dos.

begin;

create or replace function public.fc_costo_unitario_renglon(
  p_costo numeric,
  p_cantidad integer,
  p_subtotal numeric default null
)
returns numeric
language sql
immutable
as $$
  select case
    when p_costo is null and p_subtotal is not null and coalesce(p_cantidad, 1) > 1
      then round(p_subtotal / p_cantidad, 4)
    when p_costo is null then p_subtotal
    when coalesce(p_cantidad, 1) <= 1 then p_costo
    when p_subtotal is not null and abs(p_costo - p_subtotal) <= 0.03
      then round(p_subtotal / p_cantidad, 4)
    else p_costo
  end;
$$;

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

-- Cargar ticket: precio_unitario gana; si costo == subtotal y qty > 1, parte.
create or replace function public.recepcion_cargar_renglones(
  p_session_token uuid,
  p_recepcion_id bigint,
  p_items jsonb
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_user bigint;
  v_estado text;
  v_el jsonb;
  v_codigo text;
  v_sku text;
  v_nombre text;
  v_qty integer;
  v_costo numeric;
  v_subtotal numeric;
  v_lote text;
  v_pid bigint;
  v_lote_id bigint;
  v_distinto boolean;
  v_piso int;
begin
  v_user := public.fn_require_empleado(p_session_token);
  if p_items is null or jsonb_typeof(p_items) <> 'array' or jsonb_array_length(p_items) = 0 then
    raise exception 'No hay renglones en el ticket';
  end if;

  select estado into v_estado from public.recepciones where id = p_recepcion_id for update;
  if not found then raise exception 'recepcion no existe'; end if;
  if v_estado <> 'borrador' then raise exception 'solo se edita una recepcion en borrador'; end if;

  for v_el in select value from jsonb_array_elements(p_items)
  loop
    v_codigo := nullif(btrim(coalesce(v_el->>'codigo', v_el->>'codigo_barras', v_el->>'ean', '')), '');
    v_sku := nullif(btrim(coalesce(v_el->>'sku', '')), '');
    v_nombre := nullif(btrim(coalesce(v_el->>'nombre', v_el->>'descripcion', v_el->>'descripcion_ticket', '')), '');
    v_qty := coalesce(nullif(v_el->>'cantidad', '')::integer, nullif(v_el->>'qty', '')::integer, 1);
    v_costo := coalesce(
      nullif(v_el->>'precio_unitario', '')::numeric,
      nullif(v_el->>'costo_unitario', '')::numeric,
      nullif(v_el->>'costo', '')::numeric,
      nullif(v_el->>'precio', '')::numeric
    );
    v_subtotal := coalesce(
      nullif(v_el->>'subtotal', '')::numeric,
      nullif(v_el->>'importe_renglon', '')::numeric
    );
    v_costo := public.fc_costo_unitario_renglon(v_costo, v_qty, v_subtotal);
    v_lote := nullif(btrim(coalesce(v_el->>'numero_lote', v_el->>'lote', '')), '');
    if v_qty is null or v_qty <= 0 then
      continue;
    end if;

    v_pid := null;
    if v_codigo is not null then
      v_pid := public.fc_buscar_producto_escaneo(v_codigo);
    end if;
    if v_pid is null and v_sku is not null then
      v_pid := public.fc_buscar_producto_escaneo(v_sku);
    end if;

    v_lote_id := null;
    v_distinto := false;
    v_piso := 0;
    if v_pid is not null then
      select count(*)::int into v_piso
      from public.lotes l
      where l.producto_id = v_pid
        and coalesce(l.activo, true)
        and coalesce(l.cantidad_actual, 0) > 0;

      if v_lote is not null then
        select l.id into v_lote_id
        from public.lotes l
        where l.producto_id = v_pid
          and l.numero_lote = v_lote
          and coalesce(l.activo, true)
        order by l.id desc
        limit 1;
      end if;

      v_distinto := exists (
        select 1 from public.lotes l
        where l.producto_id = v_pid
          and coalesce(l.activo, true)
          and coalesce(l.cantidad_actual, 0) > 0
          and (v_lote is null or l.numero_lote is distinct from v_lote)
      );
    end if;

    insert into public.recepcion_items (
      recepcion_id, producto_id, codigo_escaneado, nombre_snapshot,
      cantidad, fecha_caducidad, numero_lote, costo_estimado,
      pendiente_alta, origen, confirmado, lote_distinto, lote_id
    ) values (
      p_recepcion_id,
      v_pid,
      coalesce(v_codigo, v_sku),
      coalesce(v_nombre, 'Renglón de ticket'),
      v_qty,
      null,  -- caducidad solo de la caja, nunca del PDF
      v_lote,
      v_costo,
      (v_pid is null),
      'pdf',
      false,
      v_distinto,
      v_lote_id
    );
  end loop;

  update public.recepciones set updated_at = now() where id = p_recepcion_id;
  return public.fc_recepcion_json(p_recepcion_id);
end;
$$;

-- Ticket entero guardó importes (sum de costo ≈ total; sum de costo×qty se pasa).
update public.recepcion_items i
set costo_estimado = round(i.costo_estimado / i.cantidad, 4)
where i.cantidad > 1
  and i.costo_estimado is not null
  and i.costo_estimado > 0
  and exists (
    select 1
    from public.recepciones r
    join public.recepcion_items x on x.recepcion_id = r.id
    where r.id = i.recepcion_id
      and r.estado in ('borrador', 'pendiente_alta', 'pendiente_caducidad')
      and r.total_ticket is not null
      and r.total_ticket > 0
    group by r.id, r.total_ticket
    having count(*) filter (where x.cantidad > 1 and coalesce(x.costo_estimado, 0) > 0) > 0
      and abs(sum(x.costo_estimado) filter (where coalesce(x.costo_estimado, 0) > 0) - r.total_ticket)
          <= greatest(2.0, 0.02 * r.total_ticket)
      and abs(sum(x.cantidad * x.costo_estimado) filter (where coalesce(x.costo_estimado, 0) > 0) - r.total_ticket)
          > abs(sum(x.costo_estimado) filter (where coalesce(x.costo_estimado, 0) > 0) - r.total_ticket)
  );

-- El renglón trae el de N y el catálogo / última compra trae el de una.
update public.recepcion_items i
set costo_estimado = round(i.costo_estimado / i.cantidad, 4)
from public.recepciones r
left join public.productos p on p.id = i.producto_id
where i.recepcion_id = r.id
  and r.estado in ('borrador', 'pendiente_alta', 'pendiente_caducidad')
  and i.cantidad > 1
  and i.costo_estimado is not null
  and i.costo_estimado > 0
  and (
    (
      coalesce(p.costo, 0) > 0
      and i.costo_estimado > p.costo * 1.1
      and abs(i.costo_estimado - p.costo * i.cantidad) <= greatest(0.05, 0.02 * i.costo_estimado)
    )
    or exists (
      select 1
      from public.producto_precios_referencia_actual a
      where a.producto_id = i.producto_id
        and a.fuente = 'ultima_compra'
        and a.precio is not null
        and a.precio > 0
        and i.costo_estimado > a.precio * 1.1
        and abs(i.costo_estimado - a.precio * i.cantidad) <= greatest(0.05, 0.02 * i.costo_estimado)
    )
  );

-- City Mark 20260905: el ticket trae precio unitario. Neutrogena = 45.89, no 91.78.
update public.recepcion_items i
set costo_estimado = v.unit
from public.recepciones r
join (
  values
    ('7891010245160', 45.890),
    ('7502221187575', 45.915),
    ('7501082736021', 35.450),
    ('7501082731071', 32.725),
    ('7506306251847', 68.730),
    ('7509546029139', 55.340),
    ('7509546071275', 29.487),
    ('78924338', 30.120),
    ('7506306226852', 45.830),
    ('78924345', 30.125),
    ('7509546060477', 29.163),
    ('7509546029825', 28.183),
    ('759684900204', 33.095),
    ('7501056330378', 88.790),
    ('7501035911024', 49.155),
    ('7509546068909', 13.525),
    ('7506425629442', 43.785),
    ('7702018913954', 36.495),
    ('7509546698137', 42.805),
    ('7509546674018', 42.815),
    ('7509546000350', 30.000),
    ('7891024028827', 13.385),
    ('3616303440534', 39.905),
    ('759684900280', 16.865),
    ('7891024027363', 13.040),
    ('759684313295', 25.775),
    ('7501033204920', 14.383)
) as v(ean, unit) on true
where i.recepcion_id = r.id
  and r.folio = '20260905'
  and coalesce(r.proveedor, '') ilike '%city mark%'
  and r.estado in ('borrador', 'pendiente_alta', 'pendiente_caducidad')
  and regexp_replace(coalesce(i.codigo_escaneado, ''), '\D', '', 'g')
      = regexp_replace(v.ean, '\D', '', 'g')
  and i.costo_estimado is distinct from v.unit;

-- Costo del renglón si el ticket no lo trajo (unitario de catálogo / compra / lote).
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

-- Catálogo / lote guardaron el de dos como si fuera de una.
update public.productos p
set costo = u.unit
from (
  select distinct on (i.producto_id)
    i.producto_id,
    i.costo_estimado as unit,
    i.cantidad
  from public.recepcion_items i
  join public.recepciones r on r.id = i.recepcion_id
  where r.estado in ('borrador', 'pendiente_alta', 'pendiente_caducidad')
    and i.producto_id is not null
    and i.cantidad > 1
    and i.costo_estimado is not null
    and i.costo_estimado > 0
    and not i.pendiente_alta
  order by i.producto_id, i.id desc
) u
where p.id = u.producto_id
  and coalesce(p.costo, 0) > 0
  and abs(p.costo - u.unit * u.cantidad) <= greatest(0.05, 0.02 * p.costo);

update public.lotes l
set costo_unitario = i.costo_estimado
from public.recepcion_items i
join public.recepciones r on r.id = i.recepcion_id
where l.id = i.lote_id
  and r.estado in ('borrador', 'pendiente_alta', 'pendiente_caducidad')
  and i.costo_estimado is not null
  and i.costo_estimado > 0
  and i.cantidad > 1
  and coalesce(l.costo_unitario, 0) > 0
  and abs(l.costo_unitario - i.costo_estimado * i.cantidad) <= greatest(0.05, 0.02 * l.costo_unitario);

-- PVP: sobre costo unitario. Corrige el que se armó con el importe de N piezas.
update public.productos p
set precio = x.pvp
from (
  select
    p2.id,
    c.unit,
    c.importe_renglon,
    ceil(
      c.unit * case
        when lower(coalesce(p2.tipo, '')) in ('marca', 'patente') then 1.25
        else 1.60
      end
    )::numeric as pvp
  from public.productos p2
  join (
    select
      i.producto_id,
      max(i.costo_estimado) as unit,
      max(i.costo_estimado * greatest(i.cantidad, 1)) as importe_renglon
    from public.recepcion_items i
    join public.recepciones r on r.id = i.recepcion_id
    where r.estado in ('borrador', 'pendiente_alta', 'pendiente_caducidad')
      and i.producto_id is not null
      and not i.pendiente_alta
      and i.costo_estimado is not null
      and i.costo_estimado > 0
    group by i.producto_id
  ) c on c.producto_id = p2.id
  where c.unit > 0
) x
where p.id = x.id
  and x.pvp > x.unit
  and (
    p.precio is null
    or p.precio <= 0
    or p.precio = ceil(x.importe_renglon * 1.25)
    or p.precio = ceil(x.importe_renglon * 1.60)
    or abs(p.precio - x.importe_renglon) < 0.02
  );

notify pgrst, 'reload schema';

commit;

-- ─────────────── Qué quedó en tickets vivos ───────────────
select
  r.proveedor,
  r.folio,
  r.estado,
  count(*) as renglones,
  count(*) filter (where i.costo_estimado is not null and i.costo_estimado > 0) as con_costo,
  count(*) filter (where i.cantidad > 1) as renglones_multi,
  count(*) filter (where i.costo_estimado is null or i.costo_estimado <= 0) as sin_costo,
  count(*) filter (where coalesce(p.precio, 0) <= 0 and i.producto_id is not null) as sin_pvp
from public.recepciones r
join public.recepcion_items i on i.recepcion_id = r.id
left join public.productos p on p.id = i.producto_id
where r.estado in ('borrador', 'pendiente_alta', 'pendiente_caducidad')
group by r.id, r.proveedor, r.folio, r.estado
order by r.updated_at desc;

-- Renglones de 2+ piezas: el costo tiene que ser de UNA, no el total.
select
  r.folio,
  left(coalesce(p.nombre, i.nombre_snapshot), 40) as producto,
  i.cantidad,
  i.costo_estimado as costo_por_pieza,
  round(i.cantidad * i.costo_estimado, 2) as importe_renglon,
  p.costo as costo_catalogo,
  p.precio as pvp,
  p.tipo
from public.recepcion_items i
join public.recepciones r on r.id = i.recepcion_id
left join public.productos p on p.id = i.producto_id
where r.estado in ('borrador', 'pendiente_alta', 'pendiente_caducidad')
  and i.cantidad > 1
order by r.folio, i.id;
