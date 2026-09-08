-- Alcohol Dibar rojo 500 ml (FC-68990023)
-- El ticket 112558 dejó 7501868990023 (checksum GS1 inválido).
-- El bote escanea 7501868900233 (EAN-13 válido).
--
-- Stock 0 es real: POS e Inventario no dejan “cargar” un lote vacío
-- (“Producto sin stock — usá Recibir”). Recibir tampoco encontraba el
-- bote, así que las piezas no entraban y el anaquel seguía en 0.
-- Este patch NO inventa piezas. Tras pegarlo: Recibir → pistola del
-- bote → cantidad + MMAA de la caja. Ahí sube el stock.
--
-- Si ya se dio de alta un segundo renglón con el EAN del bote, se le
-- quita el código para no chocar el UNIQUE y se queda FC-68990023.

begin;

update public.productos
   set codigo_barras = null
 where codigo_barras = '7501868900233'
   and sku is distinct from 'FC-68990023';

update public.productos
set
  codigo_barras = '7501868900233',
  marca = coalesce(nullif(btrim(marca), ''), 'Dibar'),
  presentacion = coalesce(nullif(btrim(presentacion), ''), '500 ML'),
  forma_farmaceutica = coalesce(nullif(btrim(forma_farmaceutica), ''), 'Alcohol'),
  descripcion = case
    when descripcion ilike '%7501868990023%' then descripcion
    when coalesce(btrim(descripcion), '') = '' then
      'Alcohol Dibar rojo 96° 500 ml. EAN bote 7501868900233 · EAN ticket OCR 7501868990023.'
    else
      btrim(descripcion) || ' EAN bote 7501868900233 · EAN ticket OCR 7501868990023.'
  end
where sku = 'FC-68990023'
   or codigo_barras in ('7501868990023', '7501868900233');

-- Recibir en servidor: el beep del bote tiene que encontrar el SKU
-- aunque el catálogo aún tenga el EAN del ticket (o al revés).
create or replace function public.fc_match_codigo_barras(p_scan text, p_stored text)
returns boolean
language sql
immutable
parallel safe
as $$
  with n as (
    select
      regexp_replace(coalesce(p_scan, ''), '\s', '', 'g') as scan,
      regexp_replace(coalesce(p_stored, ''), '\s', '', 'g') as stored
  )
  select
    case
      when n.scan = '' or n.stored = '' then false
      when n.scan = n.stored then true
      when length(n.scan) = 12 and length(n.stored) = 13
        and n.stored = '0' || n.scan then true
      when length(n.stored) = 12 and length(n.scan) = 13
        and n.scan = '0' || n.stored then true
      when n.scan in ('7501868900233', '7501868990023')
       and n.stored in ('7501868900233', '7501868990023') then true
      when n.scan in ('747589705123', '714706903205')
       and n.stored in ('747589705123', '714706903205') then true
      else false
    end
  from n;
$$;

create or replace function public.fc_buscar_producto_escaneo(p_codigo text)
returns bigint
language plpgsql
stable
set search_path = public
as $$
declare
  v_codigo text;
  v_id bigint;
  v_n int;
begin
  v_codigo := btrim(coalesce(p_codigo, ''));
  if v_codigo = '' then
    return null;
  end if;

  select count(*), min(p.id)
    into v_n, v_id
  from public.productos p
  where coalesce(p.activo, true)
    and (
      public.fc_match_codigo_barras(v_codigo, p.codigo_barras)
      or upper(btrim(coalesce(p.sku, ''))) = upper(v_codigo)
      or (
        p.descripcion is not null
        and exists (
          select 1
          from regexp_matches(p.descripcion, '\d{12,14}', 'g') as m(x)
          where public.fc_match_codigo_barras(v_codigo, m.x)
        )
      )
    );

  if v_n = 1 then
    return v_id;
  end if;
  if v_n > 1 then
    select p.id into v_id
    from public.productos p
    where coalesce(p.activo, true)
      and public.fc_match_codigo_barras(v_codigo, p.codigo_barras)
    order by p.id
    limit 1;
    if v_id is not null then
      return v_id;
    end if;
    select p.id into v_id
    from public.productos p
    where coalesce(p.activo, true)
      and upper(btrim(coalesce(p.sku, ''))) = upper(v_codigo)
    order by p.id
    limit 1;
    return v_id;
  end if;
  return null;
end;
$$;

grant execute on function public.fc_match_codigo_barras(text, text) to anon, authenticated, service_role;
grant execute on function public.fc_buscar_producto_escaneo(text) to anon, authenticated, service_role;

commit;

select sku, codigo_barras, nombre, marca, presentacion, stock, costo, precio
  from public.productos
 where sku = 'FC-68990023'
    or codigo_barras in ('7501868900233', '7501868990023')
    or (nombre ilike '%dibar%' and presentacion ilike '%500%');
