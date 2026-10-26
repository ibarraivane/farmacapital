-- ============================================================================
-- FARMACAPITAL — Alastin precio laboratorio 2026 (bajo pedido / listo para ordenar)
-- Costo = precio con IVA de lista (0% descuento volumen).
-- Precio = PVP sugerido de la lista.
-- Si el EAN ya venía de Dermaexpress/MePiel: actualiza costo/precio (más barato lab).
-- No toca stock de anaquel > 0 salvo para bajar costo si lab es más barato.
-- Regenerar: python3 scripts/generar_alta_laboratorio_dermo.py
-- ============================================================================

begin;

create temporary table _fc_alastin_lab (
  ean text,
  sku text not null,
  nombre text not null,
  presentacion text,
  forma text,
  costo numeric(12,2) not null,
  precio numeric(12,2) not null,
  imagen_url text,
  cabina boolean not null default false,
  costo_sin_iva numeric(12,2)
) on commit drop;

insert into _fc_alastin_lab
  (ean, sku, nombre, presentacion, forma, costo, precio, imagen_url, cabina, costo_sin_iva) values
  ('3499320016360', 'FC-20016360', 'Alastin Inhance Post-Injection Serum 10 ml', '10 ml', 'Sérum', 719.20, 1006.88, 'https://cdn.shopify.com/s/files/1/0088/1937/6188/files/3499320000084.jpg', false, 620.00),
  ('3499320016377', 'FC-20016377', 'Alastin Restorative Eye Complex 14.8 ml', '14.8 ml', 'Crema', 1148.40, 1607.76, 'https://cdn.shopify.com/s/files/1/0088/1937/6188/files/1_1_4ad879e1-fa41-4f01-8b16-fe5a0916992a.avif', false, 990.00),
  ('3499320016322', 'FC-20016322', 'Alastin HA Immerse Serum 29.6 ml', '29.6 ml', 'Sérum', 1310.80, 1835.12, 'https://cdn.shopify.com/s/files/1/0088/1937/6188/files/1_1_a8e4d89c-cbc8-4556-9b74-85941320fd42.avif', false, 1130.00),
  ('3499320016384', 'FC-20016384', 'Alastin Restorative Neck Complex 50 ml', '50 ml', 'Crema', 1426.80, 1997.52, 'https://cdn.shopify.com/s/files/1/0088/1937/6188/files/1_7afb5c2b-4775-4010-9c3b-d6a87d8eb9a2.png', false, 1230.00),
  ('810105153484', 'FC-05153484', 'Alastin Hydratint Pro Mineral SPF 36', '91 g', 'Protector solar', 1670.40, 1870.85, 'https://cdn.shopify.com/s/files/1/0088/1937/6188/files/HydraTintProMineralSunscreenSPF36_capoff_reflection.avif', false, 1440.00),
  ('851144006355', 'FC-44006355', 'Alastin SilkShield All Mineral Sunscreen SPF 30', '53.8 ml', 'Protector solar', 1682.00, 1883.84, 'https://cdn.shopify.com/s/files/1/0088/1937/6188/files/SilkSHIELDProMineralSunscreenSPF30_closed_reflection.avif', false, 1450.00),
  ('851144006287', 'FC-44006287', 'Alastin Ultra Nourishing Moisturizer', '59 ml', 'Crema', 1856.00, 2078.72, 'https://cdn.shopify.com/s/files/1/0088/1937/6188/files/Alastin_Moisturiser_720x_1.avif', false, 1600.00),
  ('3499320016391', 'FC-20016391', 'Alastin A-Luminate Brightening Serum 50 ml', '50 ml', 'Sérum', 1948.80, 2728.32, 'https://cdn.shopify.com/s/files/1/0088/1937/6188/files/1_1_bc06f568-9f86-4d8d-a537-5f2cdbc1c829.avif', false, 1680.00),
  ('3499320016346', 'FC-20016346', 'Alastin Transform Body Complex 170 g', '170 g', 'Crema', 2378.00, 3329.20, 'https://cdn.shopify.com/s/files/1/0088/1937/6188/files/3499320016346.jpg', false, 2050.00),
  ('3499320016353', 'FC-20016353', 'Alastin Regenerating Skin Nectar 29.6 ml', '29.6 ml', 'Sérum', 2436.00, 3410.40, 'https://cdn.shopify.com/s/files/1/0088/1937/6188/files/1_1_6961422a-e2e9-4c10-b703-40dc0543b054.avif', false, 2100.00),
  ('3499320018227', 'FC-20018227', 'Alastin Restorative Skin Complex 29.6 ml', '29.6 ml', 'Sérum', 2436.00, 3410.40, 'https://cdn.shopify.com/s/files/1/0088/1937/6188/files/1_1_b7577e14-c69b-44df-9047-1797f29fd540.avif', false, 2100.00),
  ('810105153682', 'FC-05153682', 'Alastin C-Radical Defense Serum Antioxidante 29.6 ml', '29.6 ml', 'Sérum', 3572.80, 4001.54, 'https://cdn.shopify.com/s/files/1/0088/1937/6188/files/1_a5a7577a-ae3d-4021-b9a2-104045ada068.png', false, 3080.00),
  (null, 'FC-AL-BB-INH', 'Alastin Inhance Post-Injection Serum Back Bar 29.6 ml', '29.6 ml', 'Sérum', 2552.00, 3572.80, '', true, 2200.00),
  (null, 'FC-AL-BB-NEC', 'Alastin Regenerating Skin Nectar Back Bar 118.3 ml', '118.3 ml', 'Sérum', 6124.80, 8574.72, '', true, 5280.00);

-- Altas nuevas
insert into public.productos (
  nombre, sku, codigo_barras, categoria, tipo, descripcion,
  costo, precio, stock, stock_minimo, activo, requiere_receta,
  marca, laboratorio, presentacion, forma_farmaceutica, subcategoria,
  imagen_url, bajo_pedido
)
select
  t.nombre,
  case
    when exists (
      select 1 from public.productos p
      where p.sku = t.sku
        and coalesce(p.codigo_barras, '') is distinct from coalesce(t.ean, '')
    ) then t.sku || '-LAB'
    else t.sku
  end,
  t.ean,
  'Cuidado personal',
  'marca',
  'Alastin laboratorio 2026 · listo para ordenar · costo base c/IVA',
  t.costo,
  t.precio,
  0,
  1,
  true,
  false,
  'Alastin',
  'Alastin',
  t.presentacion,
  t.forma,
  'Dermatología',
  nullif(t.imagen_url, ''),
  true
from _fc_alastin_lab t
where not exists (
  select 1 from public.productos p
  where (t.ean is not null and p.codigo_barras = t.ean)
     or (t.ean is null and p.sku = t.sku)
);

-- Actualiza existentes (incluye los que vinieron de Dermaexpress)
update public.productos p
   set costo = t.costo,
       precio = case
         when coalesce(p.stock, 0) > 0 and coalesce(p.precio, 0) > 0.01 then p.precio
         else t.precio
       end,
       bajo_pedido = case when coalesce(p.stock, 0) > 0 then false else true end,
       activo = true,
       marca = 'Alastin',
       laboratorio = coalesce(nullif(btrim(p.laboratorio), ''), 'Alastin'),
       presentacion = coalesce(nullif(btrim(p.presentacion), ''), t.presentacion),
       forma_farmaceutica = coalesce(nullif(btrim(p.forma_farmaceutica), ''), t.forma),
       subcategoria = 'Dermatología',
       categoria = 'Cuidado personal',
       imagen_url = coalesce(nullif(btrim(p.imagen_url), ''), nullif(t.imagen_url, '')),
       nombre = case
         when p.nombre ilike '%alastin%' then p.nombre
         else t.nombre
       end
  from _fc_alastin_lab t
 where (t.ean is not null and p.codigo_barras = t.ean)
    or (t.ean is null and p.sku = t.sku);

delete from public.producto_precios_referencia r
 using public.productos p, _fc_alastin_lab t
 where r.producto_id = p.id
   and r.fuente = 'alastin'
   and r.origen = 'import_csv'
   and r.fecha = current_date
   and (
     (t.ean is not null and p.codigo_barras = t.ean)
     or (t.ean is null and p.sku = t.sku)
   );

insert into public.producto_precios_referencia
  (producto_id, fuente, tipo, precio, sku_externo, origen, notas)
select p.id, 'alastin', 'compra', t.costo, coalesce(t.ean, t.sku), 'import_csv',
       'Lista Alastin 2026 · base c/IVA'
         || coalesce(' · sin IVA ' || t.costo_sin_iva::text, '')
         || ' · PVP sugerido ' || t.precio::text
         || case when t.cabina then ' · cabina' else '' end
         || ' · descuentos volumen: 15%@30k / 20%@60k / 25%@80k / 30%@140k / 35%@200k (sobre sin IVA)'
  from _fc_alastin_lab t
  join public.productos p
    on (t.ean is not null and p.codigo_barras = t.ean)
    or (t.ean is null and p.sku = t.sku);

commit;

select p.sku, p.codigo_barras, p.nombre, p.costo, p.precio, p.bajo_pedido, p.stock
from public.productos p
where p.marca ilike 'alastin'
order by p.nombre;
