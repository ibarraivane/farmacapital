-- Medik8 filas bloque 03
begin;
insert into public._fc_medik8_stg (sku, nombre, nombre_lista, descripcion, presentacion, gama, costo, precio) values
  ('FC-34776764', 'Medik8 Try Me Size Gentle Cleanse 40ml', 'Try Me Size Gentle Cleanse', 'Espuma hidratante de romero', '40ml', 'Cleanse', 300.00, 428.00),
  ('FC-92098655', 'Medik8 Try Me Size Clarifying Foam 40ml', 'Try Me Size Clarifying Foam', 'Limpiadora libre de aceite para tratar brotes AHA/BHA', '40ml', 'Cleanse', 300.00, 428.00),
  ('FC-56380755', 'Medik8 Try Me Size Calmwise Soothing Cleanser 40ml', 'Try Me Size Calmwise Soothing Cleanser', 'Espuma ultra suave de clorofila', '40ml', 'Cleanse', 300.00, 428.00),
  ('FC-08505003', 'Medik8 Try Me Size Micellar Mousse 40ml', 'Try Me Size Micellar Mousse', 'Limpiadora nutriente y purificadora de fácil enjuague', '40ml', 'Cleanse', 300.00, 428.00),
  ('FC-11691960', 'Medik8 Try Me Size C-Tetra 8ml', 'Try Me Size C-Tetra', 'Suero antioxidante lípido de vitamina C', '8ml', 'Vitamin C', 420.00, 600.00),
  ('FC-70089054', 'Medik8 Try Me Size C-Tetra Cream 12.5ml', 'Try Me Size C-Tetra Cream', 'Crema antioxidante lípida de vitamina C', '12.5ml', 'Vitamin C', 540.00, 771.00),
  ('FC-52576278', 'Medik8 Try Me Size C-Tetra Luxe 8ml', 'Try Me Size C-Tetra Luxe', 'Suero antioxidante lípido de vitamina C', '8ml', 'Vitamin C', 600.00, 857.00),
  ('FC-63223301', 'Medik8 Try Me Size Daily Radiance Vitamin C 12.5ml', 'Try Me Size Daily Radiance Vitamin C', 'Crema antioxidante C-Tetra FPS 30', '12.5ml', 'Vitamin C', 570.00, 814.00),
  ('FC-12011025', 'Medik8 Try Me Size Intelligent Retinol 3TR 4ml', 'Try Me Size Intelligent Retinol 3TR', 'Suero de Retinol Avanzado de Noche 0.3% de Retinol', '4ml', 'Vitamin A', 330.00, 471.00),
  ('FC-82667730', 'Medik8 Try Me Size Intelligent Retinol 6TR 4ml', 'Try Me Size Intelligent Retinol 6TR', 'Suero de Retinol Avanzado de Noche 0.6% de Retinol', '4ml', 'Vitamin A', 390.00, 557.00),
  ('FC-76430409', 'Medik8 Try Me Size Calmwise Colour Correct 15ml', 'Try Me Size Calmwise Colour Correct', 'Crema neutralizadora de enrojecimiento', '15ml', 'Advanced (Day)', 510.00, 728.00),
  ('FC-23504156', 'Medik8 Try Me Size Advanced Night Restore 12.5ml', 'Try Me Size Advanced Night Restore', 'Crema rejuvenecedora de reparación celular', '12.5ml', 'Advanced (Night)', 570.00, 814.00),
  ('FC-54365154', 'Medik8 Try Me Size Hydr8 B5 8ml', 'Try Me Size Hydr8 B5', 'Suero de rehidratación líquida', '8ml', 'Boosters', 480.00, 685.00),
  ('FC-58184194', 'Medik8 Try Me Size Hydr8 B5 Intense Acido 8ml', 'Try Me Size Hydr8 B5 Intense Acido', 'hialurónico con NMF', '8ml', 'Boosters', 600.00, 857.00),
  ('FC-36009622', 'Medik8 Try Me Size Liquid Peptides 8ml', 'Try Me Size Liquid Peptides', 'Complejo de péptidos con tecnología dron', '8ml', 'Peptides', 570.00, 814.00),
  ('FC-16348762', 'Medik8 Try Me Press & Glow 50ml', 'Try Me Press & Glow', 'Tónico de PHA para Exfoliación Diara con Activador de Enzimas', '50ml', 'Acids', 330.00, 471.00),
  ('FC-25948640', 'Medik8 Try Me Press & Clear 50ml', 'Try Me Press & Clear', 'Tónico exfoliante BHA al 2% Acido Salicílico de liberación Gentil', '50ml', 'Acids', 360.00, 514.00)
on conflict (sku) do update set
  nombre = excluded.nombre,
  nombre_lista = excluded.nombre_lista,
  descripcion = excluded.descripcion,
  presentacion = excluded.presentacion,
  gama = excluded.gama,
  costo = excluded.costo,
  precio = excluded.precio;
commit;
