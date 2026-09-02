-- Lysol desinfectante antibacterial Crisp Linen 475 g
-- EAN de la lata: 7501058752796 (Fahorro SKU = mismo EAN).
-- No esta en iNadro. PVP 179 = ancla Home Depot / Benavides (~180).
-- Sin costo de compra (no vino en ticket). Stock 0: entra al escanear.
-- FAB 20/04/26 del fondo de la lata NO es caducidad. No inventar MMAA.
-- Lote de caja B26110-H02: anotarlo al escanear, no aqui.
-- SIN bloques $$. Supabase → SQL Editor → Run.

begin;

insert into public.productos (
  nombre, sku, codigo_barras, categoria, tipo, descripcion,
  costo, precio, stock, stock_minimo, activo, requiere_receta
)
select
  'Lysol desinfectante antibacterial Crisp Linen 475 g',
  case
    when exists (
      select 1 from public.productos p
      where p.sku = 'FC-58752796'
        and coalesce(p.codigo_barras, '') <> '7501058752796'
    ) then 'FC-ND-58752796'
    else 'FC-58752796'
  end,
  '7501058752796',
  'Higiene',
  'marca',
  'Alta foto lata · Reckitt Benckiser · PVP ancla HD/Benavides 179 · sin costo de compra',
  null,
  179,
  0,
  1,
  true,
  false
where public.fc_buscar_producto_escaneo('7501058752796') is null;

commit;

select
  p.id,
  p.sku,
  p.codigo_barras as ean,
  p.nombre,
  p.costo,
  p.precio,
  p.stock,
  p.tipo,
  p.categoria
from public.productos p
where p.codigo_barras = '7501058752796'
   or p.sku in ('FC-58752796', 'FC-ND-58752796');
