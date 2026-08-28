-- ============================================================================
-- FARMA CAPITAL — 5 precios rotos (16-ago-2026)
--
-- Solo estos SKU. No toca el resto del catálogo ni costos ajenos.
-- Idempotente: cada UPDATE lleva un filtro del valor viejo.
--
-- 1. Jaloma labios C/60: se vende por pieza. Costo caja 171.50 / 60 = 2.86.
--    Precio de pieza ya era 8 (piso +$5). Stock 1 caja → 60 pzas.
-- 2. Gasa 10x10: se quedó el precio de la caja (197.73). Pieza = ceil(12.36*1.5)=19.
-- 3. Lactopram infantil: precio 0.01 → 39 (el calculated_price que ya tenía).
-- 4. Nesajar C/16: precio 77.14 < costo 114.27 → 155 (OTC marca +35%).
-- 5. Vitacilina humectante: 374 (×5 de más) → 104 (sin_clasificar +35%).
-- ============================================================================

-- 1) Jaloma pomada labios: abrir la caja
update public.productos
set
  costo = round(171.50 / 60, 2),          -- 2.86
  precio = 8,
  stock = 60,
  venta_unidad = false,
  unidades_por_caja = 0,
  precio_unidad = 0,
  stock_unidades = 0,
  calculated_price = 8,
  markup_percentage = 0.40,
  manual_price_override = true,
  price_needs_review = false
where sku = 'FC-4391156'
  and codigo_barras = '759684391255'
  and costo >= 100;                       -- sigue siendo costo de caja

-- 2) Gasa 10x10
update public.productos
set
  precio = 19,
  calculated_price = 19,
  markup_percentage = 0.50,
  manual_price_override = false,
  price_needs_review = false
where sku = 'FC-68900127'
  and codigo_barras = '7501868900127'
  and precio > 50;

-- 3) Lactopram infantil
update public.productos
set
  precio = 39,
  calculated_price = 39,
  manual_price_override = false,
  price_needs_review = false
where sku = 'FC-08344495'
  and codigo_barras = '7503008344495'
  and precio < 1;

-- 4) Nesajar — solo el precio de la caja; la pieza suelta (13) se deja
update public.productos
set
  precio = 155,
  calculated_price = 155,
  markup_percentage = 0.35,
  manual_price_override = false,
  price_needs_review = false
where sku = 'FC-7426449'
  and codigo_barras = '7502227426449'
  and precio < costo;

-- 5) Vitacilina crema humectante
update public.productos
set
  precio = 104,
  calculated_price = 104,
  markup_percentage = 0.35,
  manual_price_override = false,
  price_needs_review = false
where sku = 'FC-76000277'
  and codigo_barras = '7506376000277'
  and precio > 200;

-- Comprobación
select sku, nombre, costo, precio, stock, venta_unidad, precio_unidad
from public.productos
where sku in ('FC-4391156','FC-68900127','FC-08344495','FC-7426449','FC-76000277')
order by sku;
