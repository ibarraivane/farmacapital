-- Vista tienda / POS: mismo bote y tamaño, sabores en botones.
-- Solo escribe grupo_publico y variante_publica.
-- No toca stock, precio, costo, EAN, lotes ni nombre.

begin;

alter table public.productos
  add column if not exists grupo_publico text,
  add column if not exists variante_publica text;

comment on column public.productos.grupo_publico is
  'Vista tienda y POS. Misma clave = una tarjeta. Null = un SKU, una tarjeta. No afecta inventario.';

comment on column public.productos.variante_publica is
  'Texto del botón de sabor en tienda y POS. Solo vista.';

create index if not exists productos_grupo_publico_idx
  on public.productos (grupo_publico)
  where grupo_publico is not null;

update public.productos as p
set grupo_publico = v.grupo,
    variante_publica = v.variante
from (values
  -- Creatine Electrolyte Refresher, 30 porciones
  ('FC-35707855', 'birdman-creatine-electrolyte-30', 'Lemon Twist'),
  ('FC-84247462', 'birdman-creatine-electrolyte-30', 'Pink Lemonade'),
  ('FC-86925142', 'birdman-creatine-electrolyte-30', 'Watermelon Splash'),
  ('FC-44992467', 'birdman-creatine-electrolyte-30', 'Golden Peach'),
  -- Creatine for Women, 40 porciones
  ('FC-39606823', 'birdman-creatine-for-women-40', 'Pink Lemonade'),
  ('FC-44415196', 'birdman-creatine-for-women-40', 'Sin sabor'),
  -- Falcon Performance: cada tamaño es su grupo
  ('FC-29281200', 'birdman-falcon-performance-1140', 'Choco Bronze'),
  ('FC-06433650', 'birdman-falcon-performance-1140', 'Golden Vainilla'),
  ('FC-65091786', 'birdman-falcon-performance-552', 'Choco Bronze'),
  ('FC-83546244', 'birdman-falcon-performance-552', 'Golden Vainilla'),
  ('FC-00403428', 'birdman-falcon-performance-1900', 'Choco Bronze'),
  ('FC-53267306', 'birdman-falcon-performance-1900', 'Golden Vanilla'),
  ('FC-71374695', 'birdman-falcon-performance-sobres-10', 'Choco Bronze'),
  ('FC-96653081', 'birdman-falcon-performance-sobres-10', 'Golden Vanilla'),
  -- Falcon Protein 480 g (Pumpkin Spice entra aquí; el de 510 g es otro tamaño)
  ('FC-34437733', 'birdman-falcon-protein-480', 'Chai'),
  ('FC-10011410', 'birdman-falcon-protein-480', 'Chocolate'),
  ('FC-53536505', 'birdman-falcon-protein-480', 'Fresa'),
  ('FC-40393268', 'birdman-falcon-protein-480', 'Natural'),
  ('FC-31502844', 'birdman-falcon-protein-480', 'Vainilla'),
  ('FC-03985090', 'birdman-falcon-protein-480', 'Pumpkin Spice'),
  -- Falcon Protein 960 g
  ('FC-57110856', 'birdman-falcon-protein-960', 'Chai'),
  ('FC-82046711', 'birdman-falcon-protein-960', 'Chocolate'),
  ('FC-01318124', 'birdman-falcon-protein-960', 'Fresa'),
  ('FC-29984421', 'birdman-falcon-protein-960', 'Natural'),
  ('FC-82042925', 'birdman-falcon-protein-960', 'Vainilla'),
  -- Falcon Protein 1.8 kg
  ('FC-16339939', 'birdman-falcon-protein-1800', 'Chocolate'),
  ('FC-30796929', 'birdman-falcon-protein-1800', 'Vainilla'),
  -- 12 sobres fórmula anterior y 12 sobres nueva: líneas distintas
  ('FC-04614023', 'birdman-falcon-protein-sobres-12', 'Chai'),
  ('FC-59010784', 'birdman-falcon-protein-sobres-12', 'Chocolate'),
  ('FC-22516107', 'birdman-falcon-protein-sobres-12', 'Fresa'),
  ('FC-22844910', 'birdman-falcon-protein-sobres-12', 'Natural'),
  ('FC-11941078', 'birdman-falcon-protein-sobres-12', 'Vainilla'),
  ('FC-80802444', 'birdman-falcon-protein-sobres-12-nueva', 'Chai'),
  ('FC-83686649', 'birdman-falcon-protein-sobres-12-nueva', 'Chocolate'),
  ('FC-90048160', 'birdman-falcon-protein-sobres-12-nueva', 'Fresa'),
  ('FC-78739107', 'birdman-falcon-protein-sobres-12-nueva', 'Natural'),
  ('FC-38682539', 'birdman-falcon-protein-sobres-12-nueva', 'Vainilla'),
  -- Falcon Protein 1.17 kg
  ('FC-65234248', 'birdman-falcon-protein-1170', 'Chocolate'),
  ('FC-75908505', 'birdman-falcon-protein-1170', 'Fresa'),
  -- Fitmingo: sobres, 1.02 kg, 1.7 kg y 510 g
  ('FC-27361051', 'birdman-fitmingo-sobres-10', 'Blueberry'),
  ('FC-18543595', 'birdman-fitmingo-sobres-10', 'Moka'),
  ('FC-87504720', 'birdman-fitmingo-sobres-10', 'Vainilla'),
  ('FC-14780513', 'birdman-fitmingo-1020', 'Blueberry'),
  ('FC-50466353', 'birdman-fitmingo-1020', 'Moka'),
  ('FC-34993090', 'birdman-fitmingo-1020', 'Vainilla'),
  ('FC-03210058', 'birdman-fitmingo-1700', 'Blueberry'),
  ('FC-07219482', 'birdman-fitmingo-1700', 'Moka'),
  ('FC-46159837', 'birdman-fitmingo-1700', 'Vainilla'),
  ('FC-88523700', 'birdman-fitmingo-510', 'Blueberry'),
  ('FC-59181380', 'birdman-fitmingo-510', 'Moka'),
  ('FC-57892117', 'birdman-fitmingo-510', 'Vainilla'),
  -- Parrot Greens: sobres, 210 g y 900 g
  ('FC-77916472', 'birdman-parrot-sobres-12', 'Berry vainilla'),
  ('FC-25076842', 'birdman-parrot-sobres-12', 'Matcha'),
  ('FC-01616372', 'birdman-parrot-210', 'Berry vainilla'),
  ('FC-93003613', 'birdman-parrot-210', 'Matcha'),
  ('FC-04988756', 'birdman-parrot-900', 'Berry vainilla'),
  ('FC-84598525', 'birdman-parrot-900', 'Matcha'),
  -- Peacock: sobres y 882 g
  ('FC-02498861', 'birdman-peacock-sobres-10', 'Chocolate'),
  ('FC-36570999', 'birdman-peacock-sobres-10', 'Coco vainilla'),
  ('FC-63173998', 'birdman-peacock-882', 'Chocolate'),
  ('FC-43080464', 'birdman-peacock-882', 'Coco vainilla'),
  -- H Balance: 30 porciones (222 g) y 60 porciones (444 g)
  ('FC-68156235', 'birdman-h-balance-222', 'Pink Lemonade'),
  ('FC-88147536', 'birdman-h-balance-222', 'Sin sabor'),
  ('FC-98639917', 'birdman-h-balance-444', 'Pink Lemonade'),
  ('FC-44427678', 'birdman-h-balance-444', 'Sin sabor'),
  -- MCT en polvo 432 g. El líquido (270 / 420 ml) no es sabor.
  ('FC-84758742', 'birdman-mct-powder-432', 'Natural'),
  ('FC-96952979', 'birdman-mct-powder-432', 'Vainilla'),
  -- BCAAs 405 g
  ('FC-84453698', 'birdman-bcaa-405', 'Fresa'),
  ('FC-28049265', 'birdman-bcaa-405', 'Mora-Limón'),
  -- Bebida 946 ml. Light se queda sola: no es un sabor.
  ('FC-53935550', 'birdman-bebida-946', 'Almendra'),
  ('FC-22161396', 'birdman-bebida-946', 'Chocolate'),
  ('FC-77665700', 'birdman-bebida-946', 'Original')
) as v(sku, grupo, variante)
where p.sku = v.sku;

commit;
