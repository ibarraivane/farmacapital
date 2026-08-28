-- ============================================================================
-- Los 14 productos del lote 4 que no vienen en el ticket de Equilibrio
--
-- Se dieron de alta desactivados porque sin costo no se les puede calcular
-- precio de venta. Aquí se les captura el costo y se reactivan solos.
--
-- Cómo usarlo: pon el costo real de compra en lugar de cada NULL y corre el
-- archivo. Los renglones que dejes en NULL se quedan como están, no estorban.
--
-- Después corre sql/pricing/004_apply_pricing_idempotente.sql para que el
-- motor de precios les ponga el precio de venta.
-- ============================================================================

begin;

with costos(ean, costo) as (
  values
    -- Ajolotius (herbolarios, proveedor propio)
    ('7500462746612', null::numeric),  -- Ajolotius jarabe original 250 mL
    ('7500462746698', null::numeric),  -- Ajolotius jarabe con propóleo 250 mL
    ('7506452400267', null::numeric),  -- Ajolotius jarabe Elderberry / mora azul 250 mL
    ('7500462746643', null::numeric),  -- Ajolotius caramelos con azúcar, caja 25 g
    ('7506452400038', null::numeric),  -- Ajolotius caramelos sin azúcar, caja 22 g

    -- Marcas grandes, se compran fuera de Equilibrio
    ('7501033956775', null::numeric),  -- Pedialyte SR 60 mEq uva 500 mL
    ('7501328979496', null::numeric),  -- Histiacil NF jarabe infantil 150 mL
    ('7501032911454', null::numeric),  -- OFF! Extra Duración aerosol 170 g
    ('7506306234062', null::numeric),  -- Sedal Hidratación
    ('0759684273094', null::numeric),  -- Hisopos de algodón Jaloma, tarro

    -- Farmacéuticos sin línea en el ticket
    ('7501088579615', null::numeric),  -- Topron (Nifuroxazida) 400 mg c/16 cáps
    ('0714706910906', null::numeric),  -- Broncolin Bicoestol pastillas c/16

    -- Preservativos. El ticket trae dos líneas Max Sens 3+1 que podrían ser
    -- estas, pero con otro nombre de variante: PBY007 Tropicana Mix ($23.17,
    -- lote TRP060326) y PBY008 Passion Mix ($23.21, lote PAS160526).
    ('7503014377197', null::numeric),  -- Playboy Max Sens Extra Delgados 3+1
    ('7503014377180', null::numeric)   -- Playboy Max Sens Extra Sensible 3+1
)
update public.productos p
set
  costo  = c.costo,
  precio = ceil(c.costo * 1.6),
  activo = true
from costos c
where p.codigo_barras = c.ean
  and c.costo is not null
  and c.costo > 0;

-- El costo también va al lote, para que el margen salga bien en los reportes.
update public.lotes l
set costo_unitario = p.costo
from public.productos p
where l.producto_id = p.id
  and coalesce(l.costo_unitario, 0) = 0
  and coalesce(p.costo, 0) > 0
  and p.codigo_barras in (
    '7500462746612',
    '7500462746698',
    '7506452400267',
    '7500462746643',
    '7506452400038',
    '7501033956775',
    '7501328979496',
    '7501032911454',
    '7506306234062',
    '0759684273094',
    '7501088579615',
    '0714706910906',
    '7503014377197',
    '7503014377180'
  );

commit;

-- ---------------------------------------------------------------------------
-- Qué sigue pendiente
-- ---------------------------------------------------------------------------
select
  p.sku,
  p.nombre,
  p.codigo_barras,
  p.costo,
  p.precio,
  p.activo
from public.productos p
where p.codigo_barras in (
    '7500462746612',
    '7500462746698',
    '7506452400267',
    '7500462746643',
    '7506452400038',
    '7501033956775',
    '7501328979496',
    '7501032911454',
    '7506306234062',
    '0759684273094',
    '7501088579615',
    '0714706910906',
    '7503014377197',
    '7503014377180'
  )
  and coalesce(p.costo, 0) = 0
order by p.nombre;
