-- Recibir: lista de tickets pendientes + Nuevo no pisa el borrador anterior.
-- También arma Cityfarma 6315912 y Farmalive 11590 si el stock ya se cargó.
-- 21-ago-2026. Idempotente.
-- Requiere: patch_recepcion_pdf_confirmar_20260821.sql y los SQL de carga.

begin;

-- Nuevo ticket = INSERT. Ya no reescribe el borrador que está abierto.
create or replace function public.recepcion_abrir(
  p_session_token uuid,
  p_proveedor text default null,
  p_folio text default null,
  p_total_ticket numeric default null
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_user bigint;
  v_id bigint;
begin
  v_user := public.fn_require_empleado(p_session_token);

  insert into public.recepciones (proveedor, folio, total_ticket, capturado_por, estado)
  values (
    nullif(btrim(p_proveedor), ''),
    nullif(btrim(p_folio), ''),
    p_total_ticket,
    v_user,
    'borrador'
  )
  returning id into v_id;

  return public.fc_recepcion_json(v_id);
end;
$$;

create or replace function public.recepcion_abrir_existente(
  p_session_token uuid,
  p_recepcion_id bigint
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_user bigint;
  v_estado text;
begin
  v_user := public.fn_require_empleado(p_session_token);
  if p_recepcion_id is null then
    raise exception 'recepcion_id requerido';
  end if;
  select estado into v_estado from public.recepciones where id = p_recepcion_id;
  if not found then
    raise exception 'recepcion no existe';
  end if;
  if v_estado not in ('borrador', 'pendiente_alta', 'pendiente_caducidad') then
    raise exception 'esa recepcion ya esta cerrada';
  end if;
  update public.recepciones set updated_at = now() where id = p_recepcion_id;
  return public.fc_recepcion_json(p_recepcion_id);
end;
$$;

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

grant execute on function public.recepcion_abrir(uuid, text, text, numeric) to anon, authenticated;
grant execute on function public.recepcion_abrir_existente(uuid, bigint) to anon, authenticated;
grant execute on function public.recepcion_listar_abiertas(uuid) to anon, authenticated;

-- ---------------------------------------------------------------------------
-- Cola: los dos tickets de hoy, sin volver a sumar stock.
-- ---------------------------------------------------------------------------
create or replace function public.fc_recepcion_upsert_ticket_corroborar(
  p_proveedor text,
  p_folio text,
  p_fecha date,
  p_total numeric,
  p_notas text,
  p_items jsonb
)
returns bigint
language plpgsql
security definer
set search_path = public
as $$
declare
  v_id bigint;
  v_estado text;
  el jsonb;
  v_ean text;
  v_pid bigint;
  v_lid bigint;
begin
  select r.id, r.estado into v_id, v_estado
  from public.recepciones r
  where r.folio = p_folio
    and (
      coalesce(r.proveedor, '') = ''
      or r.proveedor ilike '%' || split_part(p_proveedor, ' ', 1) || '%'
      or p_proveedor ilike '%' || split_part(coalesce(r.proveedor, ''), ' ', 1) || '%'
    )
  order by r.id desc
  limit 1;

  if v_id is not null and v_estado is distinct from 'borrador' then
    return v_id;
  end if;

  if v_id is null then
    insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
    values (p_proveedor, p_folio, p_fecha, p_total, 'borrador', p_notas)
    returning id into v_id;
  else
    delete from public.recepcion_items where recepcion_id = v_id;
    update public.recepciones
    set total_ticket = p_total, notas = p_notas, updated_at = now()
    where id = v_id;
  end if;

  for el in select value from jsonb_array_elements(p_items)
  loop
    v_ean := el->>'ean';
    v_pid := public.fc_buscar_producto_escaneo(v_ean);
    v_lid := null;
    if v_pid is not null and nullif(el->>'lote', '') is not null then
      select l.id into v_lid
      from public.lotes l
      where l.producto_id = v_pid
        and l.numero_lote = el->>'lote'
        and coalesce(l.activo, true)
      order by l.id desc
      limit 1;
    end if;

    insert into public.recepcion_items (
      recepcion_id, producto_id, codigo_escaneado, nombre_snapshot,
      cantidad, numero_lote, costo_estimado, pendiente_alta,
      origen, confirmado, lote_distinto, lote_id
    ) values (
      v_id,
      v_pid,
      v_ean,
      el->>'nombre',
      coalesce((el->>'qty')::int, 1),
      nullif(el->>'lote', ''),
      nullif(el->>'costo', '')::numeric,
      (v_pid is null),
      'pdf',
      false,
      (
        v_pid is not null and exists (
          select 1 from public.lotes l
          where l.producto_id = v_pid
            and coalesce(l.activo, true)
            and coalesce(l.cantidad_actual, 0) > 0
            and l.numero_lote is distinct from (el->>'lote')
        )
      ),
      v_lid
    );
  end loop;

  return v_id;
end;
$$;

select public.fc_recepcion_upsert_ticket_corroborar(
  'Cityfarma Iztapalapa',
  '6315912',
  '2026-08-21',
  2570.99,
  'Ticket Cityfarma 6315912 · stock ya recibido; falta caducidad de caja',
  '[
    {"ean":"7501050613453","nombre":"Afrin Adulto spray 20 mL","qty":2,"costo":75.38,"lote":"2601928"},
    {"ean":"7501050623766","nombre":"Afrin No Drip solución nasal 15 mL","qty":2,"costo":115.52,"lote":"2601390"},
    {"ean":"7501165001725","nombre":"Allegra fexofenadina 180 mg C/10","qty":1,"costo":362.97,"lote":"GMX0303"},
    {"ean":"7501065001337","nombre":"Caltrate 600 + D C/30","qty":2,"costo":153.59,"lote":"T75M"},
    {"ean":"7502276040368","nombre":"Desenfriol D","qty":3,"costo":61.68,"lote":"2601928"},
    {"ean":"7502276040405","nombre":"Desenfriolito Plus Masticables","qty":2,"costo":57.76,"lote":"X26RXS"},
    {"ean":"7501300421524","nombre":"Dolac ketorolaco 10 mg C/10","qty":3,"costo":99.73,"lote":"T0623"},
    {"ean":"3664798074680","nombre":"Enterogermina 2 billones C/10","qty":1,"costo":200.00,"lote":"6I086"},
    {"ean":"7501289511421","nombre":"Pasta Lassar Andromaco 30 g","qty":2,"costo":22.50,"lote":"26PL029"},
    {"ean":"7501289511414","nombre":"Pasta Lassar Andromaco 60 g","qty":2,"costo":47.37,"lote":"26PL057"},
    {"ean":"4001895928765","nombre":"Tegaderm 3M 10 x 12 cm C/50","qty":1,"costo":579.55,"lote":"344JWY"}
  ]'::jsonb
);

select public.fc_recepcion_upsert_ticket_corroborar(
  'Farmalive',
  '11590',
  '2026-08-21',
  704.42,
  'Ticket Farmalive 11590 · stock ya recibido; falta caducidad de caja',
  '[
    {"ean":"7501065054029","nombre":"Tums surtido tabletas masticables C/48","qty":2,"costo":85.26,"lote":"RX-FARMALIVE-20260821-11590"},
    {"ean":"7501019064807","nombre":"Tena Pants Comfort grande C/13","qty":1,"costo":113.62,"lote":"RX-FARMALIVE-20260821-11590"},
    {"ean":"7500435179980","nombre":"Oral-B enjuague bucal 100% 250 mL","qty":2,"costo":47.79,"lote":"RX-FARMALIVE-20260821-11590"},
    {"ean":"7891051037878","nombre":"Oral-B enjuague bucal Complete 250 mL","qty":2,"costo":47.50,"lote":"RX-FARMALIVE-20260821-11590"},
    {"ean":"5000174305449","nombre":"Fixodent Original crema dental 40 mL","qty":2,"costo":93.30,"lote":"RX-FARMALIVE-20260821-11590"},
    {"ean":"020800600330","nombre":"Tampax Super C/10","qty":1,"costo":43.12,"lote":"RX-FARMALIVE-20260821-11590"}
  ]'::jsonb
);

commit;

select id, folio, proveedor, estado,
  (select count(*) from public.recepcion_items i where i.recepcion_id = r.id) as renglones
from public.recepciones r
where folio in ('6315912', '11590')
order by folio;
