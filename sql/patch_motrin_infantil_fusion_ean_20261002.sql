-- ============================================================================
-- Motrin Infantil 120 ml: unificar al EAN nuevo de caja
--
-- Confirmado: mismo producto (ibuprofeno 2 g/100 ml, frasco 120 ml, sabor
-- frutas). No es el Pediátrico 15 ml (7501109902637).
--
--   Viejo (ticket Farmalive / J&J): 7501007535494 · FC-07535494  ← se queda
--   Nuevo (caja Kenvue actual):     7501109902866 · FC-09902866  ← se fusiona
--
-- Esto:
--   1) Pasa lotes + stock del duplicado a FC-07535494.
--   2) Deja codigo_barras = 7501109902866 en la ficha viva.
--   3) Guarda el EAN viejo en descripción + par en fc_match (pistola/ticket).
--   4) Desactiva el renglón duplicado (no borra historial de ventas).
--
-- Idempotente. Pegar TODO en Supabase → SQL Editor → Run.
-- ============================================================================

begin;

-- Vista previa (qué hay hoy)
select
  p.id,
  p.sku,
  p.nombre,
  p.codigo_barras,
  p.stock,
  p.activo,
  coalesce((
    select sum(l.cantidad_actual)::int
    from public.lotes l
    where l.producto_id = p.id and coalesce(l.activo, true)
  ), 0) as stock_lotes
from public.productos p
where p.sku in ('FC-07535494', 'FC-09902866')
   or regexp_replace(coalesce(p.codigo_barras, ''), '\D', '', 'g')
        in ('7501007535494', '7501109902866')
order by p.sku;

do $$
declare
  v_keep bigint;
  v_dup  bigint;
  v_ean_nuevo text := '7501109902866';
  v_ean_viejo text := '7501007535494';
  v_stock_dup numeric := 0;
  v_lotes_movidos int := 0;
begin
  -- Ficha que se queda: la histórica con stock (FC-07535494) o, si no,
  -- la que ya tenga el EAN viejo / nuevo.
  select p.id into v_keep
  from public.productos p
  where p.sku = 'FC-07535494'
  order by p.id
  limit 1;

  if v_keep is null then
    select p.id into v_keep
    from public.productos p
    where regexp_replace(coalesce(p.codigo_barras, ''), '\D', '', 'g') = v_ean_viejo
    order by coalesce(p.stock, 0) desc, p.id
    limit 1;
  end if;

  if v_keep is null then
    select p.id into v_keep
    from public.productos p
    where regexp_replace(coalesce(p.codigo_barras, ''), '\D', '', 'g') = v_ean_nuevo
    order by coalesce(p.stock, 0) desc, p.id
    limit 1;
  end if;

  if v_keep is null then
    raise exception 'No hay ficha Motrin Infantil (FC-07535494 / EAN % o %)',
      v_ean_viejo, v_ean_nuevo;
  end if;

  -- Duplicado: FC-09902866 u otra ficha con el EAN nuevo (distinta de keep)
  select p.id into v_dup
  from public.productos p
  where p.id <> v_keep
    and (
      p.sku = 'FC-09902866'
      or regexp_replace(coalesce(p.codigo_barras, ''), '\D', '', 'g') = v_ean_nuevo
    )
  order by case when p.sku = 'FC-09902866' then 0 else 1 end, p.id
  limit 1;

  if v_dup is not null then
    select coalesce(stock, 0) into v_stock_dup
    from public.productos where id = v_dup;

    -- Stock solo en cabecera del duplicado (sin lotes con piezas)
    if v_stock_dup > 0
       and not exists (
         select 1 from public.lotes l
         where l.producto_id = v_dup
           and coalesce(l.activo, true)
           and coalesce(l.cantidad_actual, 0) > 0
       )
    then
      update public.productos
         set stock = coalesce(stock, 0) + v_stock_dup
       where id = v_keep;
    end if;

    -- Liberar UNIQUE de codigo_barras en el duplicado
    update public.productos
       set codigo_barras = null
     where id = v_dup
       and codigo_barras is not null;

    -- Pasar lotes al SKU vivo
    update public.lotes
       set producto_id = v_keep
     where producto_id = v_dup;
    get diagnostics v_lotes_movidos = row_count;

    if to_regclass('public.movimientos_inventario') is not null then
      execute
        'update public.movimientos_inventario set producto_id = $1 where producto_id = $2'
        using v_keep, v_dup;
    end if;

    update public.productos
       set
         activo = false,
         stock = 0,
         descripcion = case
           when descripcion ilike '%fusionado a FC-07535494%'
             or descripcion ilike '%fusionado a%' || v_ean_nuevo || '%'
             then descripcion
           else coalesce(nullif(btrim(descripcion), '') || ' ', '')
                || 'Duplicado Motrin Infantil: fusionado a FC-07535494 / EAN '
                || v_ean_nuevo || ' (2026-10-02).'
         end
     where id = v_dup;

    if exists (
      select 1 from information_schema.columns
      where table_schema = 'public' and table_name = 'productos'
        and column_name = 'visible_tienda'
    ) then
      execute 'update public.productos set visible_tienda = false where id = $1'
        using v_dup;
    end if;
  end if;

  -- Ninguna otra ficha se queda con estos EAN
  update public.productos
     set codigo_barras = null
   where id <> v_keep
     and regexp_replace(coalesce(codigo_barras, ''), '\D', '', 'g')
         in (v_ean_nuevo, v_ean_viejo);

  -- Ficha viva → EAN de caja + alias viejo en descripción
  update public.productos
     set
       codigo_barras = v_ean_nuevo,
       activo = true,
       marca = coalesce(nullif(btrim(marca), ''), 'Motrin'),
       presentacion = coalesce(
         nullif(btrim(presentacion), ''),
         'Frasco 120 ml sabor frutas'
       ),
       principio_activo = coalesce(
         nullif(btrim(principio_activo), ''),
         'Ibuprofeno 2 g/100 ml'
       ),
       forma_farmaceutica = coalesce(
         nullif(btrim(forma_farmaceutica), ''),
         'Suspensión'
       ),
       descripcion = case
         when descripcion ilike '%' || v_ean_viejo || '%'
          and descripcion ilike '%' || v_ean_nuevo || '%' then descripcion
         when coalesce(btrim(descripcion), '') = '' then
           'Motrin Infantil suspensión 120 ml sabor frutas · EAN caja '
           || v_ean_nuevo || ' · EAN ticket/viejo ' || v_ean_viejo || '.'
         else
           btrim(descripcion)
           || case when descripcion ilike '%' || v_ean_nuevo || '%' then ''
                   else ' EAN caja ' || v_ean_nuevo || '.' end
           || case when descripcion ilike '%' || v_ean_viejo || '%' then ''
                   else ' EAN ticket/viejo ' || v_ean_viejo || '.' end
       end,
       stock = case
         when exists (
           select 1 from public.lotes l
           where l.producto_id = v_keep
             and coalesce(l.activo, true)
             and coalesce(l.cantidad_actual, 0) > 0
         ) then (
           select coalesce(sum(l.cantidad_actual), 0)
           from public.lotes l
           where l.producto_id = v_keep and coalesce(l.activo, true)
         )
         else coalesce(stock, 0)
       end
   where id = v_keep;

  raise notice 'Motrin fusion: keep=% dup=% lotes_movidos=%',
    v_keep, v_dup, v_lotes_movidos;
end $$;

-- Pistola / Recibir: ambos EAN abren la misma ficha
create or replace function public.fc_match_codigo_barras(p_scan text, p_stored text)
returns boolean
language sql
immutable
parallel safe
as $$
  with n as (
    select
      regexp_replace(coalesce(p_scan, ''), '\D', '', 'g') as scan,
      regexp_replace(coalesce(p_stored, ''), '\D', '', 'g') as stored
  )
  select
    case
      when n.scan = '' or n.stored = '' then false
      when n.scan = n.stored then true
      when length(n.scan) >= 12 and length(n.stored) >= 12
        and right(n.scan, 12) = right(n.stored, 12) then true
      when length(n.scan) = 12 and length(n.stored) = 13
        and n.stored = '0' || n.scan then true
      when length(n.stored) = 12 and length(n.scan) = 13
        and n.scan = '0' || n.stored then true
      when length(n.scan) >= 8 and length(n.stored) = length(n.scan) + 1
        and n.stored like n.scan || '_' then true
      when length(n.stored) >= 8 and length(n.scan) = length(n.stored) + 1
        and n.scan like n.stored || '_' then true
      when length(n.scan) = 13 and length(n.stored) = 12
        and n.scan like '6502400%' and n.stored like '650240%'
        and substring(n.scan from 8) = substring(n.stored from 7) then true
      when length(n.stored) = 13 and length(n.scan) = 12
        and n.stored like '6502400%' and n.scan like '650240%'
        and substring(n.stored from 8) = substring(n.scan from 7) then true
      when n.scan in ('7501868900233', '7501868990023')
       and n.stored in ('7501868900233', '7501868990023') then true
      when n.scan in ('747589705123', '714706903205')
       and n.stored in ('747589705123', '714706903205') then true
      when n.scan in ('650240079009', '6502400079009', '6502400070009')
       and n.stored in ('650240079009', '6502400079009', '6502400070009') then true
      when n.scan in ('650240078996', '6502400078996')
       and n.stored in ('650240078996', '6502400078996') then true
      -- Motrin Infantil 120 ml: caja nueva ↔ ticket/EAN viejo
      when n.scan in ('7501109902866', '7501007535494')
       and n.stored in ('7501109902866', '7501007535494') then true
      else false
    end
  from n;
$$;

grant execute on function public.fc_match_codigo_barras(text, text)
  to anon, authenticated, service_role;

-- Verificación
select
  p.id,
  p.sku,
  p.nombre,
  p.codigo_barras,
  p.stock,
  p.activo,
  left(p.descripcion, 120) as descripcion_corta,
  public.fc_match_codigo_barras('7501007535494', p.codigo_barras) as match_ean_viejo,
  public.fc_match_codigo_barras('7501109902866', p.codigo_barras) as match_ean_nuevo,
  public.fc_buscar_producto_escaneo('7501007535494') as id_scan_viejo,
  public.fc_buscar_producto_escaneo('7501109902866') as id_scan_nuevo
from public.productos p
where p.sku in ('FC-07535494', 'FC-09902866')
   or regexp_replace(coalesce(p.codigo_barras, ''), '\D', '', 'g')
        in ('7501007535494', '7501109902866')
   or p.descripcion ilike '%7501007535494%'
   or p.descripcion ilike '%7501109902866%'
order by p.activo desc, p.sku;

commit;
