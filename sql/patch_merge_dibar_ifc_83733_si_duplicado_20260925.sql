-- Dibar C/24: si quedaron FC-IFC-83733 Y FC-68950207 (o dos con el mismo EAN),
-- unificar al que tenga EAN 7501868950207 (preferir FC-68950207 / el de barcode).
-- Mismo bug que pomada manzana: carga IFC sin EAN + alta con EAN.
-- Idempotente. Solo actúa si hay ≥2 fichas activas en el grupo.

begin;

select
  p.id, p.sku, p.codigo_barras as ean, p.activo, p.stock,
  p.stock_unidades, p.venta_unidad, left(p.nombre, 48) as nombre
from public.productos p
where p.sku in ('FC-IFC-83733', 'FC-68950207')
   or p.codigo_barras = '7501868950207'
order by p.sku;

do $$
declare
  v_bueno bigint;
  v_n integer;
  r record;
begin
  select count(*)::int into v_n
  from public.productos p
  where p.activo = true
    and (
      p.sku in ('FC-IFC-83733', 'FC-68950207')
      or p.codigo_barras = '7501868950207'
    );

  if v_n < 2 then
    raise notice 'Dibar: % ficha(s) activa(s) — nada que unificar', v_n;
    return;
  end if;

  select p.id into v_bueno
  from public.productos p
  where p.activo = true
    and (
      p.sku in ('FC-IFC-83733', 'FC-68950207')
      or p.codigo_barras = '7501868950207'
    )
  order by
    case when regexp_replace(coalesce(p.codigo_barras,''), '\D', '', 'g') = '7501868950207' then 0 else 1 end,
    case when p.sku = 'FC-68950207' then 0 when p.sku = 'FC-IFC-83733' then 1 else 2 end,
    p.id
  limit 1;

  update public.productos set
    codigo_barras = coalesce(nullif(btrim(codigo_barras), ''), '7501868950207'),
    nombre = 'Dibar venda elástica 7.5 cm colores C/24',
    marca = 'Dibar',
    presentacion = 'Paquete C/24',
    venta_unidad = true,
    unidades_por_caja = 24,
    precio_unidad = case when coalesce(precio_unidad, 0) <= 0 then 20 else precio_unidad end,
    activo = true
  where id = v_bueno;

  for r in
    select p.id, p.sku, coalesce(p.stock, 0) as stock, coalesce(p.stock_unidades, 0) as sueltas
    from public.productos p
    where p.activo = true
      and p.id <> v_bueno
      and (
        p.sku in ('FC-IFC-83733', 'FC-68950207')
        or p.codigo_barras = '7501868950207'
      )
  loop
    update public.recepcion_items set producto_id = v_bueno where producto_id = r.id;

    -- Mover lotes / sueltas al bueno solo si el bueno no tiene ya piezas
    if coalesce((select stock from public.productos where id = v_bueno), 0) = 0
       and coalesce((select stock_unidades from public.productos where id = v_bueno), 0) = 0
    then
      update public.lotes set producto_id = v_bueno
       where producto_id = r.id and coalesce(activo, true) and coalesce(cantidad_actual, 0) > 0;
      update public.productos set
        stock = coalesce(stock, 0) + r.stock,
        stock_unidades = coalesce(stock_unidades, 0) + r.sueltas
      where id = v_bueno;
    end if;

    update public.lotes set activo = false, cantidad_actual = 0 where producto_id = r.id;
    update public.productos set activo = false, stock = 0, stock_unidades = 0 where id = r.id;
    raise notice 'Dibar: apagado % (id %)', r.sku, r.id;
  end loop;

  raise notice 'Dibar canónico id %', v_bueno;
end $$;

commit;

select
  p.sku, p.codigo_barras as ean, p.activo, p.stock, p.stock_unidades,
  p.venta_unidad, p.precio_unidad, left(p.nombre, 48) as nombre
from public.productos p
where p.sku in ('FC-IFC-83733', 'FC-68950207')
   or p.codigo_barras = '7501868950207'
order by p.activo desc, p.sku;
