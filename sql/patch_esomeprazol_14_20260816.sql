-- ============================================================================
-- FARMA CAPITAL — Esomeprazol 40 mg C/14 Maver  16-ago-2026
--
-- El EAN 7502009748912 no está. Solo existe la caja de 28
-- (EQ-MAV415, 7502009749292). Foto lote 2 par 0099 + ticket MAV380.
--
-- Costo ticket $51.64 · precio ceil 60% = $83 · stock 1.
-- Idempotente: no crea si el EAN o el SKU ya existen.
-- ============================================================================

do $alta$
declare
  v_id bigint;
begin
  select id into v_id from public.productos
   where codigo_barras = '7502009748912' or sku = 'EQ-MAV380'
   limit 1;
  if v_id is null then
    insert into public.productos (
      nombre, sku, codigo_barras, categoria, tipo,
      presentacion, principio_activo, denominacion_generica,
      forma_farmaceutica, marca, concentracion, unidades_por_caja,
      costo, precio, stock, stock_minimo, activo, requiere_receta
    ) values (
      'Esomeprazol 14 Tab 40 Mg',
      'EQ-MAV380', '7502009748912', 'Gastro', 'generico',
      'Caja con 14 tabletas', 'Esomeprazol', 'Esomeprazol',
      'Tableta liberación retardada', 'Maver', '40 mg', 14,
      51.64, ceil(51.64 * 1.6), 1, 1, true, false
    );
    raise notice 'CREADO EQ-MAV380 Esomeprazol 14 Tab 40 Mg';
  else
    raise notice 'YA EXISTÍA Esomeprazol 14 (id %)', v_id;
  end if;
end
$alta$;

select sku, nombre, codigo_barras, presentacion, costo, precio, stock, activo
from public.productos
where sku in ('EQ-MAV380', 'EQ-MAV415')
   or codigo_barras in ('7502009748912', '7502009749292')
order by sku;
