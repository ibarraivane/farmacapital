-- Palmolive Optims Extra Suavidad, crema para peinar 250 ml.
--
-- El ticket Bodega F-42 84416 (30-sep-2026) traía la misma crema en dos
-- renglones, con nombres cortados y dos códigos. El alta hizo dos productos:
--
--   FC-46695570  7509546695570  «Crema Palmo Opt P/Pein Ker Rh 250Mln»  ← se queda
--   FC-46695587  7509546695587  «Crema Palmol Opt P/Pein Kerat 250Mln»  ← se fusiona
--
-- La foto que está en la ficha es la botella: Optims Extra Suavidad,
-- Vital Keratina + vitamina B, 250 ml.
-- Las dos piezas del ticket quedan en el SKU vivo. Los dos códigos sirven
-- en la pistola. Idempotente.
--
-- Pegar en Supabase → SQL Editor → Run.

begin;

do $$
declare
  v_keep bigint;
  v_dup bigint;
  v_stock_dup numeric := 0;
  v_lotes_dup int := 0;
  v_piezas numeric := 0;
begin
  select id into v_keep from public.productos where sku = 'FC-46695570' order by id limit 1;
  select id into v_dup from public.productos where sku = 'FC-46695587' order by id limit 1;

  if v_keep is null then
    raise exception 'No está FC-46695570 (Optims Extra Suavidad, EAN 7509546695570).';
  end if;

  if v_dup is not null and v_dup <> v_keep then
    select coalesce(stock, 0) into v_stock_dup from public.productos where id = v_dup;
    select count(*) into v_lotes_dup
    from public.lotes
    where producto_id = v_dup
      and coalesce(activo, true)
      and coalesce(cantidad_actual, 0) > 0;

    update public.productos
       set codigo_barras = null
     where id = v_dup
       and codigo_barras is not null;

    update public.lotes
       set producto_id = v_keep
     where producto_id = v_dup;

    if v_stock_dup > 0 and v_lotes_dup = 0 then
      update public.productos
         set stock = coalesce(stock, 0) + v_stock_dup
       where id = v_keep;
    end if;

    if to_regclass('public.movimientos_inventario') is not null then
      execute
        'update public.movimientos_inventario set producto_id = $1 where producto_id = $2'
        using v_keep, v_dup;
    end if;

    update public.productos
       set activo = false,
           stock = 0,
           descripcion = case
             when coalesce(descripcion, '') ilike '%fusionado a FC-46695570%' then descripcion
             else coalesce(nullif(btrim(descripcion), '') || ' ', '')
                  || 'Mismo producto que FC-46695570. Fusionado el 2026-10-04.'
           end
     where id = v_dup;

    if exists (
      select 1 from information_schema.columns
      where table_schema = 'public' and table_name = 'productos' and column_name = 'visible_tienda'
    ) then
      execute 'update public.productos set visible_tienda = false where id = $1' using v_dup;
    end if;
  end if;

  update public.productos
     set codigo_barras = null
   where id <> v_keep
     and regexp_replace(coalesce(codigo_barras, ''), '\D', '', 'g') in ('7509546695570', '7509546695587');

  select coalesce(sum(cantidad_actual), 0) into v_piezas
  from public.lotes
  where producto_id = v_keep
    and coalesce(activo, true);

  update public.productos
     set nombre = 'Optims Extra Suavidad crema para peinar',
         marca = 'Palmolive',
         presentacion = '250 ml',
         forma_farmaceutica = 'Crema',
         categoria = 'Cuidado personal',
         codigo_barras = '7509546695570',
         activo = true,
         stock = greatest(coalesce(stock, 0), v_piezas),
         descripcion = 'Palmolive Optims Extra Suavidad, crema para peinar 250 ml. '
           || 'EAN 7509546695570. El código 7509546695587 del ticket F-42 84416 es el mismo producto.'
   where id = v_keep;

  if exists (
    select 1 from information_schema.columns
    where table_schema = 'public' and table_name = 'productos' and column_name = 'visible_tienda'
  ) then
    execute 'update public.productos set visible_tienda = true where id = $1' using v_keep;
  end if;
end $$;

commit;

select id, sku, nombre, marca, presentacion, codigo_barras, stock, activo, visible_tienda
from public.productos
where sku in ('FC-46695570', 'FC-46695587')
order by sku;
