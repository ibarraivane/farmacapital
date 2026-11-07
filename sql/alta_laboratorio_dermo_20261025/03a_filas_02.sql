-- Medik8 filas bloque 02
begin;
insert into public._fc_medik8_stg (sku, nombre, nombre_lista, descripcion, presentacion, gama, costo, precio) values
  ('FC-74430698', 'Medik8 Press & Clear Refill 150ml', 'Press & Clear Refill', 'Tónico exfoliante BHA al 2% Acido Salicílico de liberación Gentil (Repuesto)', '150ml', 'Acids', 899.00, 1285.00),
  ('FC-40886192', 'Medik8 Press & Clear 150ml', 'Press & Clear', 'Tónico exfoliante BHA al 2% Acido Salicílico de liberación Gentil', '150ml', 'Acids', 1049.00, 1499.00),
  ('FC-23619254', 'Medik8 Sleep Glycolic 30ml', 'Sleep Glycolic', 'Peel AHA de Liberación Gradual para uso en casa por la noche', '30ml', 'Acids', 1169.00, 1670.00),
  ('FC-55259678', 'Medik8 Eyelift Peptides 15ml', 'Eyelift Peptides', 'Gel reafirmante anti edad', '15ml', 'Peptides', 1349.00, 1927.00),
  ('FC-36126531', 'Medik8 Clarity Peptides 30ml', 'Clarity Peptides', 'Suero de péptidos infusionado con 10% de Niacinamida', '30ml', 'Peptides', 1349.00, 1927.00),
  ('FC-38164609', 'Medik8 Liquid Peptides 30ml', 'Liquid Peptides', 'Complejo de péptidos con tecnología dron', '30ml', 'Peptides', 1649.00, 2355.00),
  ('FC-36816525', 'Medik8 Bakuchiol Peptides 30ml', 'Bakuchiol Peptides', 'Suero alternativo al retinol infusionado con péptidos', '30ml', 'Peptides', 1649.00, 2355.00),
  ('FC-47587412', 'Medik8 Copper PCA Peptides 30ml', 'Copper PCA Peptides', 'Suero antioxidante con cobre patentado y péptidos energizantes', '30ml', 'Peptides', 1772.00, 2531.00),
  ('FC-47819842', 'Medik8 Oxy-R Peptides 2x10ml', 'Oxy-R Peptides', 'Suero de péptidos iluminadores con Oxiresveratrol de alta potencia', '2x10ml', 'Peptides', 1772.00, 2531.00),
  ('FC-28164460', 'Medik8 Liquid Peptides Advanced MP 30ml', 'Liquid Peptides Advanced MP', 'Suero de Complejo Multi Péptidos al 30% con Factores de Crecimiento', '30ml', 'Peptides', 2117.00, 3024.00),
  ('FC-54913537', 'Medik8 Calmwise Serum 15ml', 'Calmwise Serum', 'Elixir anti enrojecimiento', '15ml', 'Target Serum', 1169.00, 1670.00),
  ('FC-23303811', 'Medik8 Blemish SOS 15ml', 'Blemish SOS', 'Gel de rápida acción focalizada', '15ml', 'Add on', 681.00, 974.00),
  ('FC-17884911', 'Medik8 Pore Refining Scrub 75ml', 'Pore Refining Scrub', 'Exfoliante natural de acción dual', '75ml', 'Add on', 959.00, 1370.00),
  ('FC-49093558', 'Medik8 Natural Clay Mask 75ml', 'Natural Clay Mask', 'Mascarilla de arcilla purificante y descongestionante', '75ml', 'Add on', 959.00, 1370.00),
  ('FC-44982233', 'Medik8 Ultimate Recovery 30ml', 'Ultimate Recovery', 'Crema reparadora intensiva de la piel', '30ml', 'Add on', 1169.00, 1670.00),
  ('FC-22593071', 'Medik8 H.E.O Mask 2x50ml', 'H.E.O Mask', 'Mascarilla de humectación a proporción óptima', '2x50ml', 'Add on', 1799.00, 2570.00),
  ('FC-32417681', 'Medik8 Ultimate Recovery Bio Cellulose Mask 6 pzas', 'Ultimate Recovery Bio Cellulose Mask', 'Mascarilla mineral hidratante de biocelulosa', '6 pzas', 'Add on', 2099.00, 2998.00),
  ('FC-12086355', 'Medik8 r-Retinoate Day & Night Eye Serum 15ml', 'r-Retinoate Day & Night Eye Serum', 'Suero reactivador de juventud para contorno de ojos', '15ml', 'r-Retinoate', 2699.00, 3855.00),
  ('FC-06028427', 'Medik8 r-Retinoate Day & Night 50ml', 'r-Retinoate Day & Night', 'Suero reactivador de juventud', '50ml', 'r-Retinoate', 4062.00, 5802.00),
  ('FC-95577459', 'Medik8 r-Retinoate Intense 50ml', 'r-Retinoate Intense', 'Suero reactivador de juventud intensivo', '50ml', 'r-Retinoate', 6242.00, 8918.00),
  ('FC-75908324', 'Medik8 CSA The CSA Retinol Edition Retinol 3TR 15ml Kit', 'CSA The CSA Retinol Edition Retinol 3TR 15ml', '', 'Kit', 'Kits', 3568.00, 5096.00),
  ('FC-25642733', 'Medik8 The CSA Kit', 'The CSA', 'Kit Bakuchiol Edition Peptides 30ml', 'Kit', 'Kits', 3897.00, 5568.00),
  ('FC-05886819', 'Medik8 Post Treatment Post Treatment Kit', 'Post Treatment Post Treatment', 'Kit Sunscreen 15ml', 'Kit', 'Kits', 959.00, 1370.00),
  ('FC-86831707', 'Medik8 Try Me Size Cream Cleanse 40ml', 'Try Me Size Cream Cleanse', 'Limpiadora Cremosa - Para piel normal a seca', '40ml', 'Cleanse', 300.00, 428.00),
  ('FC-46774963', 'Medik8 Try Me Size Surface Radiance Cleanse 40ml', 'Try Me Size Surface Radiance Cleanse', 'Gel limpiador de mangostán y renovador AHA/BHA', '40ml', 'Cleanse', 300.00, 428.00)
on conflict (sku) do update set
  nombre = excluded.nombre,
  nombre_lista = excluded.nombre_lista,
  descripcion = excluded.descripcion,
  presentacion = excluded.presentacion,
  gama = excluded.gama,
  costo = excluded.costo,
  precio = excluded.precio;
commit;
