-- Precio por pieza suelta: el dueño puede poner menos que la regla.
-- Antes, precio_unidad_efectivo hacía GREATEST(manual, regla) y el trigger
-- de productos devolvía $7 aunque Ivan grabara $3 (gasa C/100).
--
-- La regla solo se usa si precio_unidad está vacío o 0.
-- create_sale_transaction_v2 ya llama esta función: el POS cobra el guardado.

create or replace function public.precio_unidad_efectivo(
  p_costo numeric,
  p_precio_caja numeric,
  p_upc integer,
  p_categoria text,
  p_tipo text,
  p_precio_unidad_guardado numeric
)
returns numeric
language sql
immutable
as $$
  select case
    when coalesce(p_precio_unidad_guardado, 0) > 0
      then ceil(p_precio_unidad_guardado)
    else public.calc_precio_unidad_sugerido(
      p_costo, p_precio_caja, p_upc, p_categoria, p_tipo
    )
  end;
$$;

-- Gasa Lox10 C/100 (SKU unidad FC-68900134-UNIT)
update public.productos
   set precio_unidad = 3
 where sku = 'FC-68900134'
   and coalesce(venta_unidad, false) = true;

select sku, nombre, precio, costo, unidades_por_caja, precio_unidad,
       public.calc_precio_unidad_sugerido(costo, precio, unidades_por_caja, categoria, tipo) as sugerido,
       public.precio_unidad_efectivo(costo, precio, unidades_por_caja, categoria, tipo, precio_unidad) as efectivo
  from public.productos
 where sku = 'FC-68900134';
