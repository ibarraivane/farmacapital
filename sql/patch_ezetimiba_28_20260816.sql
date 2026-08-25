-- ============================================================================
-- FARMA CAPITAL — Ezetimiba / Simvastatina 10/20 C/28 AMSA  16-ago-2026
--
-- 7501349024540 no está. EQ-AMS274 es la caja de 14 (7501349024533,
-- cad. ene-2028, $55.90). La foto 0092 + cad. oct-2027 es el ticket
-- AMS275: 28 tabletas, lote U25T362, costo $100.08.
--
-- No se toca EQ-AMS274. Idempotente.
-- ============================================================================

do $alta$
declare
  v_id bigint;
begin
  select id into v_id from public.productos
   where codigo_barras = '7501349024540' or sku = 'EQ-AMS275'
   limit 1;
  if v_id is null then
    insert into public.productos (
      nombre, sku, codigo_barras, categoria, tipo,
      presentacion, principio_activo, denominacion_generica,
      forma_farmaceutica, marca, concentracion, unidades_por_caja,
      costo, precio, stock, stock_minimo, activo, requiere_receta
    ) values (
      'Ezetimiba/Simvasta 28 Tab 10/20 Mg',
      'EQ-AMS275', '7501349024540', 'Cardiovascular', 'generico',
      'Caja con 28 tabletas', 'Ezetimiba / Simvastatina',
      'Ezetimiba / Simvastatina',
      'Tableta', 'AMSA', '10 mg / 20 mg', 28,
      100.08, ceil(100.08 * 1.6), 1, 1, true, true
    );
    raise notice 'CREADO EQ-AMS275 Ezetimiba/Simvasta 28 Tab';
  else
    raise notice 'YA EXISTÍA Ezetimiba 28 (id %)', v_id;
  end if;
end
$alta$;

select sku, nombre, codigo_barras, presentacion, costo, precio, stock, activo
from public.productos
where sku in ('EQ-AMS274', 'EQ-AMS275')
   or codigo_barras in ('7501349024533', '7501349024540')
order by sku;
