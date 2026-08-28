-- ============================================================================
-- FARMA CAPITAL — Altas de la lista “sí faltan” (no eran pack ya abierto)
--
-- FarmaLive 9861, Surtidor 112558, IFC 1/2. Precio = ceil(costo*1.6),
-- provisional; Ibarra corrige a mano. Sin lotes (el ticket no los trae).
--
-- Velázquez alcanfor C/50 se carga como 1 caja (no se abre).
-- No toca Bepanthen 30 g ni Laritol EX ni perillas N0–N4/N6.
-- Idempotente. No va en transacción.
-- ============================================================================

do $alta$
declare
  r record;
  v_pid bigint;
begin
  for r in
    select * from (values
      -- sku, ean (null si IFC), nombre, costo, stock, categoria, tipo
      ('FL-8427330',  '7501008427330',
       'Bepanthen pomada 100 g',
       131.81, 1, 'Medicamentos', 'marca'),
      ('FL-8509810',  '7501088509810',
       'Antiflu-Des pediátrico solución 30 ml',
       149.35, 1, 'Medicamentos', 'marca'),
      ('FL-5008459',  '7501065008459',
       'Theraflu TD rojo sobres C/10',
       170.32, 2, 'Medicamentos', 'marca'),
      ('FL-7103422',  '7501537103422',
       'Tribedoce DX ampolletas C/3',
       56.84, 2, 'Medicamentos', 'marca'),
      ('FL-27573773', '7501027573773',
       'Mamila Evenflo Ensueño 8 oz',
       15.48, 2, 'Bebés', 'marca'),
      ('FL-3406730',  '7503003406730',
       'Venda Quirmex 7.5 cm',
       6.66, 12, 'Botiquín', 'marca'),
      ('FL-6910609',  '714706910609',
       'Broncolin jarabe etiqueta verde 140 ml',
       74.28, 1, 'Medicamentos', 'marca'),
      ('ST-8223704',  '7501298223704',
       'Dolo-Neurobion tabletas C/20',
       269.28, 1, 'Medicamentos', 'marca'),
      ('IFC-LAVAOJOS', null,
       'Arfam lava ojos vidrio',
       11.00, 2, 'Otro', 'marca'),
      ('IFC-CLAVO', null,
       'Esencia de clavo Herbotec 10 ml',
       10.00, 3, 'Otro', 'marca'),
      ('IFC-GRANADA', null,
       'Mercurio jarabe de granada C/25',
       7.00, 3, 'Otro', 'marca'),
      ('IFC-RICINO', null,
       'Mercurio aceite de ricino C/25',
       9.50, 3, 'Otro', 'marca'),
      ('IFC-ALCANFOR', null,
       'Velázquez alcanfor pastillas C/50 sobres',
       127.50, 1, 'Otro', 'marca'),
      ('IFC-PERILLA-N5', null,
       'Perilla Edigar N5 caja',
       20.50, 2, 'Otro', 'marca')
    ) as t(sku, ean, nombre, costo, stock, categoria, tipo)
  loop
    v_pid := null;
    if r.ean is not null then
      select id into v_pid from public.productos
       where codigo_barras = r.ean or sku = r.sku
       limit 1;
    else
      select id into v_pid from public.productos
       where sku = r.sku
       limit 1;
    end if;

    if v_pid is not null then
      raise notice 'YA EXISTÍA % (id %)', r.sku, v_pid;
      continue;
    end if;

    insert into public.productos
      (nombre, sku, codigo_barras, categoria, tipo, descripcion,
       costo, precio, stock, stock_minimo, activo, requiere_receta)
    values
      (r.nombre, r.sku, r.ean, r.categoria, r.tipo,
       'Alta lista faltantes 2026-08-16 · precio provisional ceil(costo*1.6)',
       r.costo, ceil(r.costo * 1.6),
       r.stock, 1, true, false);
    raise notice 'CREADO %', r.sku;
  end loop;
end
$alta$;

select sku, nombre, codigo_barras, costo, precio, stock
from public.productos
where sku in (
  'FL-8427330','FL-8509810','FL-5008459','FL-7103422','FL-27573773',
  'FL-3406730','FL-6910609','ST-8223704',
  'IFC-LAVAOJOS','IFC-CLAVO','IFC-GRANADA','IFC-RICINO',
  'IFC-ALCANFOR','IFC-PERILLA-N5'
)
order by sku;
