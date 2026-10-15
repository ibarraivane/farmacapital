-- Venta por pieza · pedido Raquel WhatsApp 2026-10-15
-- Schick bolsa 12, Tabcin exhibidor C/60 (ambas), Chicolastic etapa 2–5.
-- Idempotente. No inventa caducidad ni mueve stock de cajas.
-- Ver LEERME_ajuste_conteo_raquel_20261015.md

begin;

-- Schick Xtreme 3 Piel Sensible · bolsa 12 (FC-274881475)
-- Ya existe pieza suelta FC-66701015 @ $23 (EAN 7591066701015).
update public.productos
   set venta_unidad = true,
       unidades_por_caja = 12,
       precio_unidad = 23,
       presentacion = coalesce(nullif(btrim(presentacion), ''), 'Bolsa con 12 rastrillos'),
       descripcion = trim(both ' ·' from concat_ws(
         ' · ',
         nullif(trim(both ' ·' from coalesce(descripcion, '')), ''),
         'Venta por pieza Raquel 2026-10-15 · 12 rastrillos · PVP unidad $23'
       ))
 where sku = 'FC-274881475'
    or codigo_barras = '7502274881475';

-- Tabcin efervescente exhibidor 60 (324 mg y 500 mg)
update public.productos
   set venta_unidad = true,
       unidades_por_caja = 60,
       precio_unidad = 4,
       presentacion = coalesce(nullif(btrim(presentacion), ''), 'Exhibidor con 60 tabletas'),
       forma_farmaceutica = coalesce(nullif(btrim(forma_farmaceutica), ''), 'Tabletas efervescentes'),
       descripcion = trim(both ' ·' from concat_ws(
         ' · ',
         nullif(trim(both ' ·' from coalesce(descripcion, '')), ''),
         'Venta por pieza Raquel 2026-10-15 · exhibidor 60 · PVP unidad $4'
       ))
 where sku in ('FC-08485378', 'FC-08495339')
    or codigo_barras in ('7501008485378', '7501008495339');

-- Chicolastic Classic etapa 2–5: solo vende piezas (no la bolsa cerrada).
-- Etapa 1 (RN / FC-11701268) no se toca.
update public.productos
   set venta_unidad = true,
       unidades_por_caja = 14,
       precio_unidad = case
         when coalesce(precio_unidad, 0) > 0 then precio_unidad
         when coalesce(precio, 0) > 0 then round((precio / 14.0)::numeric, 2)
         else precio_unidad
       end,
       descripcion = trim(both ' ·' from concat_ws(
         ' · ',
         nullif(trim(both ' ·' from coalesce(descripcion, '')), ''),
         'Venta por pieza Raquel 2026-10-15 · etapa 2+ · bolsa 14'
       ))
 where sku in ('FC-11701087', 'FC-11705314', 'FC-11705414', 'FC-11701174');

commit;

select sku, left(nombre, 44) as nombre,
       venta_unidad, unidades_por_caja, precio, precio_unidad, stock
  from public.productos
 where sku in (
   'FC-274881475','FC-08485378','FC-08495339',
   'FC-11701087','FC-11705314','FC-11705414','FC-11701174','FC-11701268'
 )
 order by sku;
