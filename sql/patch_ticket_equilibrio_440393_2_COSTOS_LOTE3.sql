-- ============================================================================
-- FARMA CAPITAL — Costos del lote 3 desde el ticket Equilibrio 440393
-- ============================================================================
-- Aplica costo real, numero de lote y caducidad a los 23 productos del lote 3
-- que cruzan de forma confiable contra el ticket.
--
-- Criterio de inclusion (solo matches seguros):
--   A) el numero de lote registrado coincide EXACTO con el del ticket, o
--   B) el nombre comercial coincide de forma inequivoca (una sola linea
--      candidata en las 481 del ticket).
--
-- Los casos en conflicto quedan FUERA a proposito y estan documentados en
-- sql/generated/match_ticket_equilibrio_lote3.md
--
-- Idempotente. Respalda en public.costos_ticket_440393_respaldo antes de tocar.
-- NO fija precio de venta: eso lo hace el motor de pricing (sql/pricing/).
-- ============================================================================

begin;

-- ---------------------------------------------------------------------------
-- 1) Respaldo
-- ---------------------------------------------------------------------------
create table if not exists public.costos_ticket_440393_respaldo (
  respaldo_at       timestamptz not null default now(),
  producto_id       bigint      not null,
  sku               text,
  nombre            text,
  costo_anterior    numeric(10,2),
  precio_anterior   numeric(10,2),
  descripcion_ant   text,
  lote_anterior     text,
  caducidad_ant     date,
  primary key (producto_id)
);

-- ---------------------------------------------------------------------------
-- 2) Datos del ticket + aplicacion
-- ---------------------------------------------------------------------------
do $blk$
declare
  r            record;
  v_pid        bigint;
  v_lote_id    bigint;
  v_tiene_review boolean;
  v_aplicados  integer := 0;
  v_faltantes  text[]  := '{}';
begin
  select exists (
    select 1 from information_schema.columns
    where table_schema = 'public' and table_name = 'productos'
      and column_name = 'price_needs_review'
  ) into v_tiene_review;

  for r in
    select * from (values
      -- sku,            codigo_prov, lote,          caducidad,      costo
      ('FC-00422511', 'MAV003',  '262631',     '2028-05-01'::date,  21.28),
      ('FC-53601339', 'DAC005',  '26C0037',    '2028-03-31'::date,  31.49),
      ('FC-82200016', 'SOF054',  '61168',      '2028-06-05'::date,  46.79),
      ('FC-31405888', 'COL083',  '26141277',   '2028-05-23'::date,  48.77),
      ('FC-09749209', 'MAV400',  '20251225',   '2028-12-31'::date,  14.37),
      ('FC-27875568', 'RAM100',  'RD085',      '2028-03-31'::date,  47.31),
      ('FC-1FFBB505', 'MAI157',  '6BD201',     '2028-02-01'::date,  40.91),
      ('FC-52D2A43A', 'LOE070',  'R25126048',  '2028-01-13'::date,  29.08),
      ('FC-09745584', 'MAV245',  '261962',     '2028-03-01'::date,  49.25),
      ('FC-75723137', 'NOV136',  '540266',     '2028-05-01'::date,  13.93),
      ('FC-03388008', 'RAY114',  '25109',      '2027-05-01'::date,  34.55),
      ('FC-73906469', 'BIO146',  'LD2619',     '2028-04-01'::date,  39.49),
      ('FC-27427392', 'GEP030',  '260735',     '2028-03-01'::date,  47.28),
      ('FC-03738879', 'WER015',  '251070',     '2028-01-01'::date,  21.26),
      ('FC-01165953', 'SON226',  '26051290',   '2028-05-01'::date,  29.92),
      ('FC-11165726', 'SON173',  '25123585',   '2027-12-01'::date,  19.61),
      ('FC-31144302', 'COL145',  '26140881',   '2028-04-06'::date,  33.61),
      ('FC-04908738', 'ALP0380', '2602578',    '2028-02-01'::date,  23.30),
      ('FC-16803800', 'AVI004',  '5LM253D',    '2028-11-15'::date,  32.76),
      ('FC-36003621', 'LIF162',  '26C062',     '2028-03-31'::date,  37.22),
      ('FC-27872123', 'RAM054',  '7220526',    '2028-03-31'::date,  19.65),
      ('FC-27871416', 'RAM046',  'RR184',      '2028-03-31'::date,  15.49),
      ('FC-75718676', 'NOV098',  '491066',     '2030-04-01'::date,  97.10)
    ) as t(sku, codigo_prov, lote, caducidad, costo)
  loop
    select id into v_pid from public.productos where sku = r.sku;

    if v_pid is null then
      v_faltantes := v_faltantes || r.sku;
      continue;
    end if;

    -- respaldo (solo la primera vez por producto)
    insert into public.costos_ticket_440393_respaldo
      (producto_id, sku, nombre, costo_anterior, precio_anterior, descripcion_ant,
       lote_anterior, caducidad_ant)
    select p.id, p.sku, p.nombre, p.costo, p.precio, p.descripcion,
           l.numero_lote, l.fecha_caducidad
    from public.productos p
    left join lateral (
      select numero_lote, fecha_caducidad
      from public.lotes where producto_id = p.id order by id limit 1
    ) l on true
    where p.id = v_pid
    on conflict (producto_id) do nothing;

    -- costo + limpieza de la marca "costo pendiente ticket"
    update public.productos
    set costo = r.costo,
        descripcion = nullif(
          btrim(
            regexp_replace(
              coalesce(descripcion, ''),
              '\s*·?\s*costo pendiente ticket', '', 'gi'
            )
          ) || ' · Ticket Equilibrio 440393 (' || r.codigo_prov || ')',
          ' · Ticket Equilibrio 440393 (' || r.codigo_prov || ')'
        )
    where id = v_pid
      and (coalesce(costo, 0) <> r.costo
           or coalesce(descripcion, '') not like '%Ticket Equilibrio 440393%');

    if v_tiene_review then
      execute 'update public.productos set price_needs_review = true where id = $1'
        using v_pid;
    end if;

    -- lote: actualiza el existente o crea uno
    select id into v_lote_id
    from public.lotes
    where producto_id = v_pid
    order by id
    limit 1;

    if v_lote_id is null then
      insert into public.lotes
        (producto_id, numero_lote, fecha_caducidad, cantidad_actual, costo_unitario, activo)
      values
        (v_pid, r.lote, r.caducidad, 0, r.costo, true);
    else
      update public.lotes
      set numero_lote     = r.lote,
          fecha_caducidad = r.caducidad,
          costo_unitario  = r.costo
      where id = v_lote_id;
    end if;

    v_aplicados := v_aplicados + 1;
  end loop;

  raise notice 'Costos aplicados: %', v_aplicados;
  if array_length(v_faltantes, 1) is not null then
    raise notice 'SKUs no encontrados en productos: %', v_faltantes;
  end if;
end
$blk$;

commit;

-- ---------------------------------------------------------------------------
-- 3) Verificacion
-- ---------------------------------------------------------------------------
select p.sku, p.nombre, p.costo, p.precio, l.numero_lote, l.fecha_caducidad, l.costo_unitario
from public.productos p
left join public.lotes l on l.producto_id = p.id
where p.sku in (
  'FC-00422511','FC-53601339','FC-82200016','FC-31405888','FC-09749209',
  'FC-27875568','FC-1FFBB505','FC-52D2A43A','FC-09745584','FC-75723137',
  'FC-03388008','FC-73906469','FC-27427392','FC-03738879','FC-01165953',
  'FC-11165726','FC-31144302','FC-04908738','FC-16803800','FC-36003621',
  'FC-27872123','FC-27871416','FC-75718676'
)
order by p.sku;

-- Siguiente paso sugerido: recalcular precios con el motor de pricing
--   \i sql/pricing/003_preview_pricing.sql
--   \i sql/pricing/004_apply_pricing_idempotente.sql
