
begin;

create temp table if not exists _fc_carga_map (
  codigo_barras text primary key,
  producto_id bigint
) on commit drop;

insert into _fc_carga_map (codigo_barras, producto_id)
select codigo_barras, id from public.productos
where codigo_barras is not null and btrim(codigo_barras) <> ''
on conflict (codigo_barras) do nothing;

do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7501065054135' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7501065054135';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'TB 3 SURT',
      'sku', 'FC-65054135',
      'codigo_barras', '7501065054135',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'TB 3 SURT — Ticket 112558',
      'costo', 37.48,
      'precio', 50.6,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-112558-27',
      NULL,
      37.48,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7501065054135', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-112558-27', NULL, 37.48, 'El Surtidor de su Farmacia', null
    );
  end if;
end $$;

-- 112558 L28 FASELINE PURO 42G
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7501056323066' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7501056323066';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'FASELINE PURO 42G',
      'sku', 'FC-56323066',
      'codigo_barras', '7501056323066',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'FASELINE PURO 42G — Ticket 112558',
      'costo', 15.5,
      'precio', 20.93,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-112558-28',
      NULL,
      15.5,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7501056323066', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-112558-28', NULL, 15.5, 'El Surtidor de su Farmacia', null
    );
  end if;
end $$;

-- 112558 L29 VASELINE PURO 85G
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7501056323059' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7501056323059';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'VASELINE PURO 85G',
      'sku', 'FC-56323059',
      'codigo_barras', '7501056323059',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'VASELINE PURO 85G — Ticket 112558',
      'costo', 45.5,
      'precio', 61.43,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-112558-29',
      NULL,
      45.5,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7501056323059', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-112558-29', NULL, 45.5, 'El Surtidor de su Farmacia', null
    );
  end if;
end $$;

-- 112558 L30 VAPORUB POM 12G C12 LATAS
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7501001246730' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7501001246730';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'VAPORUB POM 12G C12 LATAS',
      'sku', 'FC-01246730',
      'codigo_barras', '7501001246730',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'VAPORUB POM 12G C12 LATAS — Ticket 112558',
      'costo', 255.0,
      'precio', 344.25,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-112558-30',
      NULL,
      255.0,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7501001246730', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-112558-30', NULL, 255.0, 'El Surtidor de su Farmacia', null
    );
  end if;
end $$;

-- 112558 L31 VICK NAPORUB UNG 100G
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7590002012475' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7590002012475';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'VICK NAPORUB UNG 100G',
      'sku', 'FC-02012475',
      'codigo_barras', '7590002012475',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'VICK NAPORUB UNG 100G — Ticket 112558',
      'costo', 113.2,
      'precio', 152.83,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-112558-31',
      NULL,
      113.2,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7590002012475', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-112558-31', NULL, 113.2, 'El Surtidor de su Farmacia', null
    );
  end if;
end $$;

-- 112558 L32 VICK VAPORUB UNG 50G
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7590002012468' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7590002012468';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'VICK VAPORUB UNG 50G',
      'sku', 'FC-02012468',
      'codigo_barras', '7590002012468',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'VICK VAPORUB UNG 50G — Ticket 112558',
      'costo', 82.41,
      'precio', 111.26,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-112558-32',
      NULL,
      82.41,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7590002012468', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-112558-32', NULL, 82.41, 'El Surtidor de su Farmacia', null
    );
  end if;
end $$;

-- IFC1-080826 L1 POMADA REOMATOLUM DEL VIEJITO 60G (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
  jsonb_build_object(
      'nombre', 'POMADA REOMATOLUM DEL VIEJITO 60G',
      'sku', 'FC-1FBF5206',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'POMADA REOMATOLUM DEL VIEJITO 60G — Ticket IFC1-080826',
      'costo', 20.0,
      'precio', 27.0,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  1,
  'TK-IFC1-080826-1',
  NULL,
  20.0,
  null
);

-- IFC1-080826 L2 POMADA REOMATOLUM DEL VIEJITO 60G VARFAM LAVA OJOS (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
  jsonb_build_object(
      'nombre', 'POMADA REOMATOLUM DEL VIEJITO 60G VARFAM LAVA OJOS VIDRIO ABR56 81606',
      'sku', 'FC-2E5B7248',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'POMADA REOMATOLUM DEL VIEJITO 60G VARFAM LAVA OJOS VIDRIO ABR56 81606 — Ticket IFC1-080826',
      'costo', 11.0,
      'precio', 14.86,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  2,
  'TK-IFC1-080826-2',
  NULL,
  11.0,
  null
);

-- IFC1-080826 L3 Producto IFC 3 (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
  jsonb_build_object(
      'nombre', 'Producto IFC 3',
      'sku', 'FC-D12CA0FA',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Producto IFC 3 — Ticket IFC1-080826',
      'costo', 10.0,
      'precio', 13.5,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  3,
  'TK-IFC1-080826-3',
  NULL,
  10.0,
  null
);

-- IFC1-080826 L4 MERCURIO ESPIRITUS UNTAR C/25 1770823 (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
  jsonb_build_object(
      'nombre', 'MERCURIO ESPIRITUS UNTAR C/25 1770823',
      'sku', 'FC-62034164',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'MERCURIO ESPIRITUS UNTAR C/25 1770823 — Ticket IFC1-080826',
      'costo', 6.0,
      'precio', 8.11,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  3,
  'TK-IFC1-080826-4',
  NULL,
  6.0,
  null
);

-- IFC1-080826 L5 MERCURIO ESPIRITUS TOMAR C/25 1760823 (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
  jsonb_build_object(
      'nombre', 'MERCURIO ESPIRITUS TOMAR C/25 1760823',
      'sku', 'FC-3676D5DC',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'MERCURIO ESPIRITUS TOMAR C/25 1760823 — Ticket IFC1-080826',
      'costo', 6.0,
      'precio', 8.11,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  3,
  'TK-IFC1-080826-5',
  NULL,
  6.0,
  null
);

-- IFC1-080826 L6 MERCURIO ACEITE OLIVO C/25 1000625 83825 (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
  jsonb_build_object(
      'nombre', 'MERCURIO ACEITE OLIVO C/25 1000625 83825',
      'sku', 'FC-5A697CC2',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'MERCURIO ACEITE OLIVO C/25 1000625 83825 — Ticket IFC1-080826',
      'costo', 8.0,
      'precio', 10.8,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  3,
  'TK-IFC1-080826-6',
  NULL,
  8.0,
  null
);

-- IFC1-080826 L7 MERCURIO GLICERINA C/25 1230723 83125 (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
  jsonb_build_object(
      'nombre', 'MERCURIO GLICERINA C/25 1230723 83125',
      'sku', 'FC-39036C88',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'MERCURIO GLICERINA C/25 1230723 83125 — Ticket IFC1-080826',
      'costo', 12.0,
      'precio', 16.21,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  3,
  'TK-IFC1-080826-7',
  NULL,
  12.0,
  null
);

-- IFC1-080826 L8 MERCURIO JARABE DE GRANADA. C/25 1750823 (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
  jsonb_build_object(
      'nombre', 'MERCURIO JARABE DE GRANADA. C/25 1750823',
      'sku', 'FC-DFF99C3F',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'MERCURIO JARABE DE GRANADA. C/25 1750823 — Ticket IFC1-080826',
      'costo', 7.0,
      'precio', 9.46,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  3,
  'TK-IFC1-080826-8',
  NULL,
  7.0,
  null
);

-- IFC1-080826 L9 MERCURIO ACEITE COCO C/25 800523 83064 (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
  jsonb_build_object(
      'nombre', 'MERCURIO ACEITE COCO C/25 800523 83064',
      'sku', 'FC-931B4809',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'MERCURIO ACEITE COCO C/25 800523 83064 — Ticket IFC1-080826',
      'costo', 8.0,
      'precio', 10.8,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  5,
  'TK-IFC1-080826-9',
  NULL,
  8.0,
  null
);

-- IFC1-080826 L10 MERCURIO ACEITE ALMENDRAS C/25 790523 (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
  jsonb_build_object(
      'nombre', 'MERCURIO ACEITE ALMENDRAS C/25 790523',
      'sku', 'FC-D4AC123B',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'MERCURIO ACEITE ALMENDRAS C/25 790523 — Ticket IFC1-080826',
      'costo', 8.0,
      'precio', 10.8,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  5,
  'TK-IFC1-080826-10',
  NULL,
  8.0,
  null
);

-- IFC1-080826 L11 MERCURIO ACEITE ROMERO C/25 1910923 (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
  jsonb_build_object(
      'nombre', 'MERCURIO ACEITE ROMERO C/25 1910923',
      'sku', 'FC-38CAFE6B',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'MERCURIO ACEITE ROMERO C/25 1910923 — Ticket IFC1-080826',
      'costo', 8.0,
      'precio', 10.8,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  3,
  'TK-IFC1-080826-11',
  NULL,
  8.0,
  null
);

-- IFC1-080826 L12 KOHN MERTIOLATE ROJO C/25 012023 82912 (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
  jsonb_build_object(
      'nombre', 'KOHN MERTIOLATE ROJO C/25 012023 82912',
      'sku', 'FC-926099D3',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'KOHN MERTIOLATE ROJO C/25 012023 82912 — Ticket IFC1-080826',
      'costo', 9.0,
      'precio', 12.15,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  5,
  'TK-IFC1-080826-12',
  NULL,
  9.0,
  null
);

-- IFC1-080826 L13 MADRID ACEITE EUCALIPTO C/25 2712017 83401 (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
  jsonb_build_object(
      'nombre', 'MADRID ACEITE EUCALIPTO C/25 2712017 83401',
      'sku', 'FC-E69F2E63',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'MADRID ACEITE EUCALIPTO C/25 2712017 83401 — Ticket IFC1-080826',
      'costo', 11.0,
      'precio', 14.86,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  3,
  'TK-IFC1-080826-13',
  NULL,
  11.0,
  null
);

-- IFC1-080826 L14 MERCURIO ARNICA UNTAR C/25 1790823 83156 (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
  jsonb_build_object(
      'nombre', 'MERCURIO ARNICA UNTAR C/25 1790823 83156',
      'sku', 'FC-25E452B6',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'MERCURIO ARNICA UNTAR C/25 1790823 83156 — Ticket IFC1-080826',
      'costo', 7.5,
      'precio', 10.13,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  3,
  'TK-IFC1-080826-14',
  NULL,
  7.5,
  null
);

-- IFC1-080826 L15 MERCURIO ARNICA TOMAR C/25 1780823 83156 (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
  jsonb_build_object(
      'nombre', 'MERCURIO ARNICA TOMAR C/25 1780823 83156',
      'sku', 'FC-127F5753',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'MERCURIO ARNICA TOMAR C/25 1780823 83156 — Ticket IFC1-080826',
      'costo', 7.5,
      'precio', 10.13,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  3,
  'TK-IFC1-080826-15',
  NULL,
  7.5,
  null
);

-- IFC1-080826 L16 MERCURIO YODO UNTAR C/25 1810623 83156 (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
  jsonb_build_object(
      'nombre', 'MERCURIO YODO UNTAR C/25 1810623 83156',
      'sku', 'FC-D3D28E20',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'MERCURIO YODO UNTAR C/25 1810623 83156 — Ticket IFC1-080826',
      'costo', 11.5,
      'precio', 15.53,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  3,
  'TK-IFC1-080826-16',
  NULL,
  11.5,
  null
);

-- IFC1-080826 L17 MERCURIO ACEITE GOMENOLADO C/25 1160623 (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
  jsonb_build_object(
      'nombre', 'MERCURIO ACEITE GOMENOLADO C/25 1160623',
      'sku', 'FC-69387811',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'MERCURIO ACEITE GOMENOLADO C/25 1160623 — Ticket IFC1-080826',
      'costo', 8.0,
      'precio', 10.8,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  3,
  'TK-IFC1-080826-17',
  NULL,
  8.0,
  null
);

-- IFC1-080826 L18 MERCURIO YODO TOMAR C/25 1800823 83156 (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
  jsonb_build_object(
      'nombre', 'MERCURIO YODO TOMAR C/25 1800823 83156',
      'sku', 'FC-A680F97E',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'MERCURIO YODO TOMAR C/25 1800823 83156 — Ticket IFC1-080826',
      'costo', 11.0,
      'precio', 14.86,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  3,
  'TK-IFC1-080826-18',
  NULL,
  11.0,
  null
);

-- IFC2-080826 L1 MERCURIO OXIDO DE ZINC C/50 1620824 83521 (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
  jsonb_build_object(
      'nombre', 'MERCURIO OXIDO DE ZINC C/50 1620824 83521',
      'sku', 'FC-C4530823',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'MERCURIO OXIDO DE ZINC C/50 1620824 83521 — Ticket IFC2-080826',
      'costo', 54.0,
      'precio', 72.91,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  1,
  'TK-IFC2-080826-1',
  NULL,
  54.0,
  null
);

-- IFC2-080826 L2 MERCURIO BISMUTO SUBNITRATO C/50 1390724 (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
  jsonb_build_object(
      'nombre', 'MERCURIO BISMUTO SUBNITRATO C/50 1390724',
      'sku', 'FC-D037156B',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'MERCURIO BISMUTO SUBNITRATO C/50 1390724 — Ticket IFC2-080826',
      'costo', 73.5,
      'precio', 99.23,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  1,
  'TK-IFC2-080826-2',
  NULL,
  73.5,
  null
);

-- IFC2-080826 L3 MERCURIO BICARBONATO SOBRES C/50 (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
  jsonb_build_object(
      'nombre', 'MERCURIO BICARBONATO SOBRES C/50',
      'sku', 'FC-B8D7C997',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'MERCURIO BICARBONATO SOBRES C/50 — Ticket IFC2-080826',
      'costo', 48.0,
      'precio', 64.81,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  1,
  'TK-IFC2-080826-3',
  NULL,
  48.0,
  null
);

-- IFC2-080826 L4 MERCURIO MAGNESIA ANISADA C/50 1560824 (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
  jsonb_build_object(
      'nombre', 'MERCURIO MAGNESIA ANISADA C/50 1560824',
      'sku', 'FC-CB5C11ED',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'MERCURIO MAGNESIA ANISADA C/50 1560824 — Ticket IFC2-080826',
      'costo', 51.5,
      'precio', 69.53,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  1,
  'TK-IFC2-080826-4',
  NULL,
  51.5,
  null
);

-- IFC2-080826 L5 / 2.00 PIEZA EDIGAR PERILLA N 6 CAJA 1649 81608 (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
  jsonb_build_object(
      'nombre', '/ 2.00 PIEZA EDIGAR PERILLA N 6 CAJA 1649 81608',
      'sku', 'FC-A871D831',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', '/ 2.00 PIEZA EDIGAR PERILLA N 6 CAJA 1649 81608 — Ticket IFC2-080826',
      'costo', 22.5,
      'precio', 30.38,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  2,
  'TK-IFC2-080826-5',
  NULL,
  22.5,
  null
);

-- IFC2-080826 L6 MERCURIO BORAX POLVO C/50 140072483490 (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
  jsonb_build_object(
      'nombre', 'MERCURIO BORAX POLVO C/50 140072483490',
      'sku', 'FC-578F060C',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'MERCURIO BORAX POLVO C/50 140072483490 — Ticket IFC2-080826',
      'costo', 53.0,
      'precio', 71.56,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  1,
  'TK-IFC2-080826-6',
  NULL,
  53.0,
  null
);

-- IFC2-080826 L7 MERCURIO PERLAS DE ETER C/50 1630824 (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
  jsonb_build_object(
      'nombre', 'MERCURIO PERLAS DE ETER C/50 1630824',
      'sku', 'FC-FBD776D2',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'MERCURIO PERLAS DE ETER C/50 1630824 — Ticket IFC2-080826',
      'costo', 170.0,
      'precio', 229.51,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  1,
  'TK-IFC2-080826-7',
  NULL,
  170.0,
  null
);

-- IFC2-080826 L8 MERCURIO FLOR DE ARNICA C/50 1430724 (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
  jsonb_build_object(
      'nombre', 'MERCURIO FLOR DE ARNICA C/50 1430724',
      'sku', 'FC-5EF90195',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'MERCURIO FLOR DE ARNICA C/50 1430724 — Ticket IFC2-080826',
      'costo', 55.0,
      'precio', 74.25,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  1,
  'TK-IFC2-080826-8',
  NULL,
  55.0,
  null
);

-- IFC2-080826 L9 EDIGAR PERILLA N O CAJA (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
  jsonb_build_object(
      'nombre', 'EDIGAR PERILLA N O CAJA',
      'sku', 'FC-9A1C64E7',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'EDIGAR PERILLA N O CAJA — Ticket IFC2-080826',
      'costo', 14.5,
      'precio', 19.58,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  2,
  'TK-IFC2-080826-9',
  NULL,
  14.5,
  null
);

-- IFC2-080826 L10 MERCURIO SULFATIAZOL POLVO C/50 1710824 (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
  jsonb_build_object(
      'nombre', 'MERCURIO SULFATIAZOL POLVO C/50 1710824',
      'sku', 'FC-47AAF23B',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'MERCURIO SULFATIAZOL POLVO C/50 1710824 — Ticket IFC2-080826',
      'costo', 69.0,
      'precio', 93.15,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  1,
  'TK-IFC2-080826-10',
  NULL,
  69.0,
  null
);

-- IFC2-080826 L11 EDIGAR PERILLA N 4 CAJA 1439 81608 (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
  jsonb_build_object(
      'nombre', 'EDIGAR PERILLA N 4 CAJA 1439 81608',
      'sku', 'FC-FFC25DD1',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'EDIGAR PERILLA N 4 CAJA 1439 81608 — Ticket IFC2-080826',
      'costo', 19.5,
      'precio', 26.33,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  2,
  'TK-IFC2-080826-11',
  NULL,
  19.5,
  null
);

-- IFC2-080826 L12 EDGAR PERILLA N 3 C A 1334 81608 (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
  jsonb_build_object(
      'nombre', 'EDGAR PERILLA N 3 C A 1334 81608',
      'sku', 'FC-614E4F82',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'EDGAR PERILLA N 3 C A 1334 81608 — Ticket IFC2-080826',
      'costo', 18.5,
      'precio', 24.98,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  2,
  'TK-IFC2-080826-12',
  NULL,
  18.5,
  null
);

-- IFC2-080826 L13 EDIGAR PERILLA N 2 CAJA 1145 81608 (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
  jsonb_build_object(
      'nombre', 'EDIGAR PERILLA N 2 CAJA 1145 81608',
      'sku', 'FC-C22EBFE6',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'EDIGAR PERILLA N 2 CAJA 1145 81608 — Ticket IFC2-080826',
      'costo', 16.0,
      'precio', 21.6,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  2,
  'TK-IFC2-080826-13',
  NULL,
  16.0,
  null
);

-- IFC2-080826 L14 EDIGAR PERILLA N 1 CAJA 1113 81608 (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
  jsonb_build_object(
      'nombre', 'EDIGAR PERILLA N 1 CAJA 1113 81608',
      'sku', 'FC-BCF59548',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'EDIGAR PERILLA N 1 CAJA 1113 81608 — Ticket IFC2-080826',
      'costo', 15.5,
      'precio', 20.93,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  12,
  'TK-IFC2-080826-14',
  NULL,
  15.5,
  null
);

-- IFC2-080826 L15 MERCURIO HABA ALCANFORADA C/50 1510724 (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
  jsonb_build_object(
      'nombre', 'MERCURIO HABA ALCANFORADA C/50 1510724',
      'sku', 'FC-9507CD66',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'MERCURIO HABA ALCANFORADA C/50 1510724 — Ticket IFC2-080826',
      'costo', 65.0,
      'precio', 87.75,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  1,
  'TK-IFC2-080826-15',
  NULL,
  65.0,
  null
);

-- IFC2-080826 L16 MERCURIO POMADA TEPEZCOHUITE C/25 (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
  jsonb_build_object(
      'nombre', 'MERCURIO POMADA TEPEZCOHUITE C/25',
      'sku', 'FC-FEAECBF1',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'MERCURIO POMADA TEPEZCOHUITE C/25 — Ticket IFC2-080826',
      'costo', 9.5,
      'precio', 12.83,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  3,
  'TK-IFC2-080826-16',
  NULL,
  9.5,
  null
);

-- IFC2-080826 L17 MERCURIO POMADA VENENO DE ABEJA C/25 (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
  jsonb_build_object(
      'nombre', 'MERCURIO POMADA VENENO DE ABEJA C/25',
      'sku', 'FC-9827438F',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'MERCURIO POMADA VENENO DE ABEJA C/25 — Ticket IFC2-080826',
      'costo', 9.5,
      'precio', 12.83,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  3,
  'TK-IFC2-080826-17',
  NULL,
  9.5,
  null
);

-- IFC2-080826 L18 MERCURIO POMADA PAN PUERCO C/25 25401233 (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
  jsonb_build_object(
      'nombre', 'MERCURIO POMADA PAN PUERCO C/25 25401233',
      'sku', 'FC-EFB599B5',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'MERCURIO POMADA PAN PUERCO C/25 25401233 — Ticket IFC2-080826',
      'costo', 9.5,
      'precio', 12.83,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  5,
  'TK-IFC2-080826-18',
  NULL,
  9.5,
  null
);

-- IFC2-080826 L19 VELAZQUEZ BICARBONATO GRANDE 200G C/10 (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
  jsonb_build_object(
      'nombre', 'VELAZQUEZ BICARBONATO GRANDE 200G C/10',
      'sku', 'FC-08DB70CB',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'VELAZQUEZ BICARBONATO GRANDE 200G C/10 — Ticket IFC2-080826',
      'costo', 11.5,
      'precio', 15.53,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  5,
  'TK-IFC2-080826-19',
  NULL,
  11.5,
  null
);

-- IFC2-080826 L20 MERCURIO POMADA ARNICA C/25 2550123 (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
  jsonb_build_object(
      'nombre', 'MERCURIO POMADA ARNICA C/25 2550123',
      'sku', 'FC-89F00320',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'MERCURIO POMADA ARNICA C/25 2550123 — Ticket IFC2-080826',
      'costo', 10.5,
      'precio', 14.18,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  5,
  'TK-IFC2-080826-20',
  NULL,
  10.5,
  null
);

-- IFC2-080826 L21 MERCURIO POMADA SULFATIAZOL C/25 2600223 (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
  jsonb_build_object(
      'nombre', 'MERCURIO POMADA SULFATIAZOL C/25 2600223',
      'sku', 'FC-FD718DF3',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'MERCURIO POMADA SULFATIAZOL C/25 2600223 — Ticket IFC2-080826',
      'costo', 11.5,
      'precio', 15.53,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  3,
  'TK-IFC2-080826-21',
  NULL,
  11.5,
  null
);

-- IFC2-080826 L22 MERCURIO POMADA OXIDO DE ZINC C/25 (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
  jsonb_build_object(
      'nombre', 'MERCURIO POMADA OXIDO DE ZINC C/25',
      'sku', 'FC-0ACC5B6A',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'MERCURIO POMADA OXIDO DE ZINC C/25 — Ticket IFC2-080826',
      'costo', 9.0,
      'precio', 12.15,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  3,
  'TK-IFC2-080826-22',
  NULL,
  9.0,
  null
);

-- IFC2-080826 L23 MERCURIO CLORURO DE MAGNESIO C/10 CAJITA (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
  jsonb_build_object(
      'nombre', 'MERCURIO CLORURO DE MAGNESIO C/10 CAJITA',
      'sku', 'FC-5D59ED54',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'MERCURIO CLORURO DE MAGNESIO C/10 CAJITA — Ticket IFC2-080826',
      'costo', 34.0,
      'precio', 45.91,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  2,
  'TK-IFC2-080826-23',
  NULL,
  34.0,
  null
);

-- FMX-080826 L1 FC 01/03/2030 (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
  jsonb_build_object(
      'nombre', 'FC 01/03/2030',
      'sku', 'FC-E5BA49B2',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'FC 01/03/2030 — Ticket FMX-080826',
      'costo', 71.53,
      'precio', 96.57,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  5,
  '7033325D',
  NULL,
  71.53,
  null
);

-- FMX-080826 L2 FC 01/11/2030| (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
  jsonb_build_object(
      'nombre', 'FC 01/11/2030|',
      'sku', 'FC-895EA161',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'FC 01/11/2030| — Ticket FMX-080826',
      'costo', 9.5,
      'precio', 12.83,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  1,
  '251101-2',
  NULL,
  9.5,
  null
);

-- FMX-080826 L3 Clave 302174 (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
  jsonb_build_object(
      'nombre', 'Clave 302174',
      'sku', 'FC-33B15A58',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'Clave 302174 — Ticket FMX-080826',
      'costo', 15.21,
      'precio', 20.54,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  4,
  '251101-3',
  NULL,
  15.21,
  null
);

-- FMX-080826 L4 MEDITEST PRUEBA EMBARAZO C/1 (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
  jsonb_build_object(
      'nombre', 'MEDITEST PRUEBA EMBARAZO C/1',
      'sku', 'FC-66055303',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'MEDITEST PRUEBA EMBARAZO C/1 — Ticket FMX-080826',
      'costo', 15.18,
      'precio', 20.5,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  6,
  'TK-FMX-080826-4',
  NULL,
  15.18,
  null
);

-- FMX-080826 L5 FC 01/09/2028 (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
  jsonb_build_object(
      'nombre', 'FC 01/09/2028',
      'sku', 'FC-DF92D3CF',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'FC 01/09/2028 — Ticket FMX-080826',
      'costo', 9.66,
      'precio', 13.05,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  1,
  'RIJ25078',
  NULL,
  9.66,
  null
);

-- FMX-080826 L6 FC 01/04/2029 (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
  jsonb_build_object(
      'nombre', 'FC 01/04/2029',
      'sku', 'FC-757DEC8A',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'FC 01/04/2029 — Ticket FMX-080826',
      'costo', 11.89,
      'precio', 16.06,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  1,
  'S26094',
  NULL,
  11.89,
  null
);

-- FMX-080826 L7 FC 01/04/2028 (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
  jsonb_build_object(
      'nombre', 'FC 01/04/2028',
      'sku', 'FC-108AB6B6',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'FC 01/04/2028 — Ticket FMX-080826',
      'costo', 45.3,
      'precio', 61.16,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  1,
  '262440',
  NULL,
  45.3,
  null
);

-- FMX-080826 L8 FC 01/05/2029 (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
  jsonb_build_object(
      'nombre', 'FC 01/05/2029',
      'sku', 'FC-22ECC02C',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'FC 01/05/2029 — Ticket FMX-080826',
      'costo', 71.6,
      'precio', 96.66,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  1,
  '0038U',
  NULL,
  71.6,
  null
);

-- FMX-080826 L9 FC 01/04/2028 (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
  jsonb_build_object(
      'nombre', 'FC 01/04/2028',
      'sku', 'FC-23B68FA1',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'FC 01/04/2028 — Ticket FMX-080826',
      'costo', 87.46,
      'precio', 118.08,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  1,
  'U0377',
  NULL,
  87.46,
  null
);

-- FMX-080826 L10 FC 01/04/2028 (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
  jsonb_build_object(
      'nombre', 'FC 01/04/2028',
      'sku', 'FC-87621652',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'FC 01/04/2028 — Ticket FMX-080826',
      'costo', 33.65,
      'precio', 45.43,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  1,
  '262526',
  NULL,
  33.65,
  null
);

-- FMX-080826 L11 FC 01/12/2028 (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
  jsonb_build_object(
      'nombre', 'FC 01/12/2028',
      'sku', 'FC-2E70DB7E',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'FC 01/12/2028 — Ticket FMX-080826',
      'costo', 44.46,
      'precio', 60.03,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  1,
  '25540582',
  NULL,
  44.46,
  null
);

-- FMX-080826 L12 FC 01/11/2028 (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
  jsonb_build_object(
      'nombre', 'FC 01/11/2028',
      'sku', 'FC-A166D66F',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'FC 01/11/2028 — Ticket FMX-080826',
      'costo', 74.27,
      'precio', 100.27,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  1,
  '26E0001',
  NULL,
  74.27,
  null
);

-- FMX-080826 L13 FC 01/04/2028 (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
  jsonb_build_object(
      'nombre', 'FC 01/04/2028',
      'sku', 'FC-7B88B47E',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'FC 01/04/2028 — Ticket FMX-080826',
      'costo', 40.54,
      'precio', 54.73,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  1,
  '262415',
  NULL,
  40.54,
  null
);

-- FMX-080826 L14 FC 01/12/2027 (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
  jsonb_build_object(
      'nombre', 'FC 01/12/2027',
      'sku', 'FC-F349C6DD',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'FC 01/12/2027 — Ticket FMX-080826',
      'costo', 41.06,
      'precio', 55.44,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  1,
  '256971',
  NULL,
  41.06,
  null
);

-- FMX-080826 L15 ANIMALIN GOTAS C/30 ML (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
  jsonb_build_object(
      'nombre', 'ANIMALIN GOTAS C/30 ML',
      'sku', 'FC-D751525D',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'ANIMALIN GOTAS C/30 ML — Ticket FMX-080826',
      'costo', 22.65,
      'precio', 30.58,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  1,
  '255714',
  NULL,
  22.65,
  null
);

-- FMX-080826 L16 GELCAVIT-9M CAPSULAS C/30 (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
  jsonb_build_object(
      'nombre', 'GELCAVIT-9M CAPSULAS C/30',
      'sku', 'FC-4F05124E',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'GELCAVIT-9M CAPSULAS C/30 — Ticket FMX-080826',
      'costo', 66.3,
      'precio', 89.51,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  1,
  '26C658',
  NULL,
  66.3,
  null
);

-- FMX-080826 L17 FC 01/01/2028 (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
  jsonb_build_object(
      'nombre', 'FC 01/01/2028',
      'sku', 'FC-85632ABD',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'FC 01/01/2028 — Ticket FMX-080826',
      'costo', 29.14,
      'precio', 39.34,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  1,
  '26E40105',
  NULL,
  29.14,
  null
);

-- FMX-080826 L18 FC 01/04/2028 (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
  jsonb_build_object(
      'nombre', 'FC 01/04/2028',
      'sku', 'FC-0906E3E1',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'FC 01/04/2028 — Ticket FMX-080826',
      'costo', 47.08,
      'precio', 63.56,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  1,
  '26A50040',
  NULL,
  47.08,
  null
);

-- FMX-080826 L19 FC 01/09/2027 (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
  jsonb_build_object(
      'nombre', 'FC 01/09/2027',
      'sku', 'FC-4C3B3B9C',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'FC 01/09/2027 — Ticket FMX-080826',
      'costo', 72.56,
      'precio', 97.96,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  1,
  '25J662',
  NULL,
  72.56,
  null
);

-- FMX-080826 L20 HUCIUS CAPSULAS C/30 (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
  jsonb_build_object(
      'nombre', 'HUCIUS CAPSULAS C/30',
      'sku', 'FC-1812D26D',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'HUCIUS CAPSULAS C/30 — Ticket FMX-080826',
      'costo', 78.16,
      'precio', 105.52,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  1,
  '26E00193',
  NULL,
  78.16,
  null
);

-- FMX-080826 L21 FC 01/02/2028 (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
  jsonb_build_object(
      'nombre', 'FC 01/02/2028',
      'sku', 'FC-EC96A027',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'FC 01/02/2028 — Ticket FMX-080826',
      'costo', 71.49,
      'precio', 96.52,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  1,
  '264672',
  NULL,
  71.49,
  null
);

select producto_id, lote_id from create_producto_with_lote(
  jsonb_build_object(
      'nombre', 'FC 01/04/2028',
      'sku', 'FC-3B7A358D',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'FC 01/04/2028 — Ticket FMX-080826',
      'costo', 77.28,
      'precio', 104.33,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  1,
  '28D007',
  NULL,
  77.28,
  null
);

-- FMX-080826 L23 FC 01/04/2028 (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
  jsonb_build_object(
      'nombre', 'FC 01/04/2028',
      'sku', 'FC-16C9352F',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'FC 01/04/2028 — Ticket FMX-080826',
      'costo', 76.55,
      'precio', 103.35,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  1,
  '26C694',
  NULL,
  76.55,
  null
);

-- FMX-080826 L24 FC 01/03/2029 (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
  jsonb_build_object(
      'nombre', 'FC 01/03/2029',
      'sku', 'FC-70F50FD7',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'FC 01/03/2029 — Ticket FMX-080826',
      'costo', 60.85,
      'precio', 82.15,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  1,
  '261SP0301',
  NULL,
  60.85,
  null
);

-- FMX-080826 L25 FC 01/03/2028 (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
  jsonb_build_object(
      'nombre', 'FC 01/03/2028',
      'sku', 'FC-D33D7A48',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'FC 01/03/2028 — Ticket FMX-080826',
      'costo', 62.12,
      'precio', 83.87,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  1,
  '26F30810',
  NULL,
  62.12,
  null
);

-- FMX-080826 L26 FOTOSUN-UV100 CREMA C/125 ML S0-FP$ (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
  jsonb_build_object(
      'nombre', 'FOTOSUN-UV100 CREMA C/125 ML S0-FP$',
      'sku', 'FC-00E8A9C7',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'FOTOSUN-UV100 CREMA C/125 ML S0-FP$ — Ticket FMX-080826',
      'costo', 74.27,
      'precio', 100.27,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  1,
  'TK-FMX-080826-26',
  NULL,
  74.27,
  null
);

-- FMX-080826 L27 FC 01/01/2028 (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
  jsonb_build_object(
      'nombre', 'FC 01/01/2028',
      'sku', 'FC-D4342B8E',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'FC 01/01/2028 — Ticket FMX-080826',
      'costo', 7.98,
      'precio', 10.78,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  1,
  '260021',
  NULL,
  7.98,
  null
);

-- FMX-080826 L28 FC 01/02/2028 (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
  jsonb_build_object(
      'nombre', 'FC 01/02/2028',
      'sku', 'FC-CF0AF2F6',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'FC 01/02/2028 — Ticket FMX-080826',
      'costo', 28.48,
      'precio', 38.45,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  1,
  '260915',
  NULL,
  28.48,
  null
);

-- FMX-080826 L29 FC 01/05/2028 (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
  jsonb_build_object(
      'nombre', 'FC 01/05/2028',
      'sku', 'FC-5CA1622C',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'FC 01/05/2028 — Ticket FMX-080826',
      'costo', 41.06,
      'precio', 55.44,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  1,
  '26Y01966',
  NULL,
  41.06,
  null
);

-- FMX-080826 L30 FC 01/04/2027 (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
  jsonb_build_object(
      'nombre', 'FC 01/04/2027',
      'sku', 'FC-D0A49FC8',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'FC 01/04/2027 — Ticket FMX-080826',
      'costo', 7.4,
      'precio', 10.0,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  1,
  '25402039',
  NULL,
  7.4,
  null
);

-- FMX-080826 L31 FC 01/02/2029 (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
  jsonb_build_object(
      'nombre', 'FC 01/02/2029',
      'sku', 'FC-EB5DCEBE',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'FC 01/02/2029 — Ticket FMX-080826',
      'costo', 1.85,
      'precio', 2.5,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  2,
  '202602',
  NULL,
  1.85,
  null
);

-- FMX-080826 L32 ERBITRAX TABLETAS 250 MG C/7 (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
  jsonb_build_object(
      'nombre', 'ERBITRAX TABLETAS 250 MG C/7',
      'sku', 'FC-DA34D88D',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'ERBITRAX TABLETAS 250 MG C/7 — Ticket FMX-080826',
      'costo', 5.54,
      'precio', 7.48,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  1,
  'R2601829',
  NULL,
  5.54,
  null
);

-- FMX-080826 L33 VALNAIT CAPSULAS C/30 (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
  jsonb_build_object(
      'nombre', 'VALNAIT CAPSULAS C/30',
      'sku', 'FC-BE2ACF63',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'VALNAIT CAPSULAS C/30 — Ticket FMX-080826',
      'costo', 4.56,
      'precio', 6.16,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  1,
  '26A01381',
  NULL,
  4.56,
  null
);

-- FMX-080826 L34 FC 01/03/2027 (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
  jsonb_build_object(
      'nombre', 'FC 01/03/2027',
      'sku', 'FC-D259E551',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'FC 01/03/2027 — Ticket FMX-080826',
      'costo', 13.49,
      'precio', 18.22,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  1,
  'SP020325',
  NULL,
  13.49,
  null
);

-- FMX-080826 L35 FC 01/12/2027 (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
  jsonb_build_object(
      'nombre', 'FC 01/12/2027',
      'sku', 'FC-2782A4D6',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'FC 01/12/2027 — Ticket FMX-080826',
      'costo', 62.96,
      'precio', 85.0,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  1,
  '25N50408',
  NULL,
  62.96,
  null
);

-- FMX-080826 L36 FC 01/02/2028 (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
  jsonb_build_object(
      'nombre', 'FC 01/02/2028',
      'sku', 'FC-E3CFD0A7',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'FC 01/02/2028 — Ticket FMX-080826',
      'costo', 18.43,
      'precio', 24.89,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  2,
  '260205',
  NULL,
  18.43,
  null
);

-- FMX-080826 L37 FC 01/04/2028 (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
  jsonb_build_object(
      'nombre', 'FC 01/04/2028',
      'sku', 'FC-39E059E2',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'FC 01/04/2028 — Ticket FMX-080826',
      'costo', 34.77,
      'precio', 46.94,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  1,
  '604203',
  NULL,
  34.77,
  null
);

-- FMX-080826 L38 ALEVARIN CAPSULAS C/45 (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
  jsonb_build_object(
      'nombre', 'ALEVARIN CAPSULAS C/45',
      'sku', 'FC-DF39BB27',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'ALEVARIN CAPSULAS C/45 — Ticket FMX-080826',
      'costo', 68.88,
      'precio', 92.99,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  1,
  '26A01563',
  NULL,
  68.88,
  null
);

-- FMX-080826 L39 FC 01/09/2027 (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
  jsonb_build_object(
      'nombre', 'FC 01/09/2027',
      'sku', 'FC-79C61297',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'FC 01/09/2027 — Ticket FMX-080826',
      'costo', 41.21,
      'precio', 55.64,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  1,
  '0925961',
  NULL,
  41.21,
  null
);

-- FMX-080826 L40 FC 01/06/2028 (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
  jsonb_build_object(
      'nombre', 'FC 01/06/2028',
      'sku', 'FC-EC93AE62',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'FC 01/06/2028 — Ticket FMX-080826',
      'costo', 8.99,
      'precio', 12.14,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  2,
  '0164389',
  NULL,
  8.99,
  null
);

-- FMX-080826 L41 FC 01/05/2028 (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
  jsonb_build_object(
      'nombre', 'FC 01/05/2028',
      'sku', 'FC-223B5D76',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'FC 01/05/2028 — Ticket FMX-080826',
      'costo', 10.47,
      'precio', 14.14,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  1,
  '26141117',
  NULL,
  10.47,
  null
);

-- FMX-080826 L42 FC 01/09/2027 (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
  jsonb_build_object(
      'nombre', 'FC 01/09/2027',
      'sku', 'FC-86606791',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'FC 01/09/2027 — Ticket FMX-080826',
      'costo', 94.83,
      'precio', 128.03,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  1,
  '25J664',
  NULL,
  94.83,
  null
);

-- FMX-080826 L43 Clave 300591 (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
  jsonb_build_object(
      'nombre', 'Clave 300591',
      'sku', 'FC-6D9926C2',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'Clave 300591 — Ticket FMX-080826',
      'costo', 5.4,
      'precio', 7.3,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  1,
  'TK-FMX-080826-43',
  NULL,
  5.4,
  null
);

-- FMX-080826 L44 FC 01/03/2028 (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
  jsonb_build_object(
      'nombre', 'FC 01/03/2028',
      'sku', 'FC-2E7C6CD6',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'FC 01/03/2028 — Ticket FMX-080826',
      'costo', 90.23,
      'precio', 121.82,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  1,
  '26540074',
  NULL,
  90.23,
  null
);

-- FMX-080826 L45 FC 01/03/2028 (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
  jsonb_build_object(
      'nombre', 'FC 01/03/2028',
      'sku', 'FC-D3FB53E9',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'FC 01/03/2028 — Ticket FMX-080826',
      'costo', 344.0,
      'precio', 464.4,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  1,
  '26140731',
  NULL,
  344.0,
  null
);

-- FMX-080826 L46 FC 01/06/2028 (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
  jsonb_build_object(
      'nombre', 'FC 01/06/2028',
      'sku', 'FC-E3C83D59',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'FC 01/06/2028 — Ticket FMX-080826',
      'costo', 29.46,
      'precio', 39.78,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  1,
  '26740135',
  NULL,
  29.46,
  null
);

-- FMX-080826 L47 FC 01/05/2028 (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
  jsonb_build_object(
      'nombre', 'FC 01/05/2028',
      'sku', 'FC-99F357DC',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'FC 01/05/2028 — Ticket FMX-080826',
      'costo', 2.6,
      'precio', 3.51,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  2,
  '0165578',
  NULL,
  2.6,
  null
);

-- FMX-080826 L48 FC 01/06/2028 (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
  jsonb_build_object(
      'nombre', 'FC 01/06/2028',
      'sku', 'FC-23CE9602',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'FC 01/06/2028 — Ticket FMX-080826',
      'costo', 17.98,
      'precio', 24.28,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  2,
  '0161683',
  NULL,
  17.98,
  null
);

-- FMX-080826 L49 FC 01/01/2028 (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
  jsonb_build_object(
      'nombre', 'FC 01/01/2028',
      'sku', 'FC-CAABC42B',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'FC 01/01/2028 — Ticket FMX-080826',
      'costo', 83.66,
      'precio', 112.95,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  1,
  '26AM34',
  NULL,
  83.66,
  null
);

-- FMX-080826 L50 FC 01/06/2028 (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
  jsonb_build_object(
      'nombre', 'FC 01/06/2028',
      'sku', 'FC-E94C79BA',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'FC 01/06/2028 — Ticket FMX-080826',
      'costo', 20.67,
      'precio', 27.91,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  1,
  'TK-FMX-080826-50',
  NULL,
  20.67,
  null
);

-- FMX-080826 L51 FC 01/10/2028 (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
  jsonb_build_object(
      'nombre', 'FC 01/10/2028',
      'sku', 'FC-D75138BB',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'FC 01/10/2028 — Ticket FMX-080826',
      'costo', 53.55,
      'precio', 72.3,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  1,
  '12026092',
  NULL,
  53.55,
  null
);

-- FMX-080826 L52 FC 01/11/2027 (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
  jsonb_build_object(
      'nombre', 'FC 01/11/2027',
      'sku', 'FC-6E084251',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'FC 01/11/2027 — Ticket FMX-080826',
      'costo', 32.74,
      'precio', 44.2,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  3,
  '5LM122A',
  NULL,
  32.74,
  null
);

-- FMX-080826 L53 FC 01/11/2028 (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
  jsonb_build_object(
      'nombre', 'FC 01/11/2028',
      'sku', 'FC-30F56906',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'FC 01/11/2028 — Ticket FMX-080826',
      'costo', 20.4,
      'precio', 27.54,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  1,
  '06026056',
  NULL,
  20.4,
  null
);

-- FMX-080826 L54 FC 01/05/2028 (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
  jsonb_build_object(
      'nombre', 'FC 01/05/2028',
      'sku', 'FC-046D8251',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'FC 01/05/2028 — Ticket FMX-080826',
      'costo', 50.64,
      'precio', 68.37,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  1,
  '0526059',
  NULL,
  50.64,
  null
);

-- FMX-080826 L55 FC 01/03/2028 (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
  jsonb_build_object(
      'nombre', 'FC 01/03/2028',
      'sku', 'FC-D69881BF',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'FC 01/03/2028 — Ticket FMX-080826',
      'costo', 9.94,
      'precio', 13.42,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  1,
  'B80046',
  NULL,
  9.94,
  null
);

-- FMX-080826 L56 FC 01/03/2028 (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
  jsonb_build_object(
      'nombre', 'FC 01/03/2028',
      'sku', 'FC-C3B611F3',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'FC 01/03/2028 — Ticket FMX-080826',
      'costo', 39.74,
      'precio', 53.65,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  2,
  '60705',
  NULL,
  39.74,
  null
);

-- FMX-080826 L57 FC 01/04/2030 (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
  jsonb_build_object(
      'nombre', 'FC 01/04/2030',
      'sku', 'FC-98518364',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'FC 01/04/2030 — Ticket FMX-080826',
      'costo', 35.1,
      'precio', 47.39,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  1,
  '2504863004',
  NULL,
  35.1,
  null
);

-- FMX-080826 L58 FC 01/04/2030 (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
  jsonb_build_object(
      'nombre', 'FC 01/04/2030',
      'sku', 'FC-F89008C6',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'FC 01/04/2030 — Ticket FMX-080826',
      'costo', 9.26,
      'precio', 12.51,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  3,
  '3189826E',
  NULL,
  9.26,
  null
);

-- FMX-080826 L59 FC 01/05/2030 (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
  jsonb_build_object(
      'nombre', 'FC 01/05/2030',
      'sku', 'FC-355851E7',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'FC 01/05/2030 — Ticket FMX-080826',
      'costo', 9.26,
      'precio', 12.51,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  3,
  '3211825F',
  NULL,
  9.26,
  null
);

-- FMX-080826 L60 FC 01711/2030 (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
  jsonb_build_object(
      'nombre', 'FC 01711/2030',
      'sku', 'FC-C8B741F6',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'FC 01711/2030 — Ticket FMX-080826',
      'costo', 10.45,
      'precio', 14.11,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  2,
  '251102-2',
  NULL,
  10.45,
  null
);

-- FMX-080826 L61 FC 01/11/2030 (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
  jsonb_build_object(
      'nombre', 'FC 01/11/2030',
      'sku', 'FC-3B0C76C8',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'FC 01/11/2030 — Ticket FMX-080826',
      'costo', 5.77,
      'precio', 7.79,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  5,
  '251102-1',
  NULL,
  5.77,
  null
);

-- FMX-080826 L62 CATETER/INTRAVENOSO-SUMITEX PU 22 G X 25 MM C/1 AZ (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
  jsonb_build_object(
      'nombre', 'CATETER/INTRAVENOSO-SUMITEX PU 22 G X 25 MM C/1 AZUL',
      'sku', 'FC-BE0A0E46',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'CATETER/INTRAVENOSO-SUMITEX PU 22 G X 25 MM C/1 AZUL — Ticket FMX-080826',
      'costo', 9.26,
      'precio', 12.51,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  3,
  '3189325E',
  NULL,
  9.26,
  null
);

-- FMX-080826 L63 FC 01/05/2028 (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
  jsonb_build_object(
      'nombre', 'FC 01/05/2028',
      'sku', 'FC-ED3B0AD4',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'FC 01/05/2028 — Ticket FMX-080826',
      'costo', 43.71,
      'precio', 59.01,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  1,
  'V26Y020',
  NULL,
  43.71,
  null
);

-- FMX-080826 L64 FC 01/06/2030 (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
  jsonb_build_object(
      'nombre', 'FC 01/06/2030',
      'sku', 'FC-83941A95',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'FC 01/06/2030 — Ticket FMX-080826',
      'costo', 8.56,
      'precio', 11.56,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  11,
  '2506885808',
  NULL,
  8.56,
  null
);

-- FMX-080826 L65 FC 01/01/2031 (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
  jsonb_build_object(
      'nombre', 'FC 01/01/2031',
      'sku', 'FC-E9FA700D',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'FC 01/01/2031 — Ticket FMX-080826',
      'costo', 15.27,
      'precio', 20.62,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  1,
  '2601973605',
  NULL,
  15.27,
  null
);

-- FMX-080826 L66 FC 01/06/2030 (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
  jsonb_build_object(
      'nombre', 'FC 01/06/2030',
      'sku', 'FC-BE977010',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'FC 01/06/2030 — Ticket FMX-080826',
      'costo', 15.5,
      'precio', 20.93,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  1,
  '2506885602',
  NULL,
  15.5,
  null
);

-- FMX-080826 L67 FC 01/02/2028 (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
  jsonb_build_object(
      'nombre', 'FC 01/02/2028',
      'sku', 'FC-35A0F20F',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'FC 01/02/2028 — Ticket FMX-080826',
      'costo', 30.36,
      'precio', 40.99,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  2,
  'P26F301',
  NULL,
  30.36,
  null
);

-- FMX-080826 L68 FC 01/12/2027 (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
  jsonb_build_object(
      'nombre', 'FC 01/12/2027',
      'sku', 'FC-AE88EDDC',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'FC 01/12/2027 — Ticket FMX-080826',
      'costo', 25.21,
      'precio', 34.04,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  1,
  '221205-1',
  NULL,
  25.21,
  null
);

-- FMX-080826 L69 FC 13/12/2030 (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
  jsonb_build_object(
      'nombre', 'FC 13/12/2030',
      'sku', 'FC-EE6593B4',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'FC 13/12/2030 — Ticket FMX-080826',
      'costo', 204.96,
      'precio', 276.7,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  1,
  '2512962201',
  NULL,
  204.96,
  null
);

-- FMX-080826 L70 FC 01/04/2030 (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
  jsonb_build_object(
      'nombre', 'FC 01/04/2030',
      'sku', 'FC-93322783',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'FC 01/04/2030 — Ticket FMX-080826',
      'costo', 24.17,
      'precio', 32.63,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  1,
  '2504864301',
  NULL,
  24.17,
  null
);

-- FMX-080826 L71 FC 01/12/2030 (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
  jsonb_build_object(
      'nombre', 'FC 01/12/2030',
      'sku', 'FC-20C90A6D',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'FC 01/12/2030 — Ticket FMX-080826',
      'costo', 160.56,
      'precio', 216.76,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  1,
  '1A12505',
  NULL,
  160.56,
  null
);

-- FMX-080826 L72 FC 01/03/2030 (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
  jsonb_build_object(
      'nombre', 'FC 01/03/2030',
      'sku', 'FC-7607DDA7',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'FC 01/03/2030 — Ticket FMX-080826',
      'costo', 16.45,
      'precio', 22.21,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  1,
  '2503853712',
  NULL,
  16.45,
  null
);

-- FMX-080826 L73 FC 06/06/2030 (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
  jsonb_build_object(
      'nombre', 'FC 06/06/2030',
      'sku', 'FC-8C9A304D',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'FC 06/06/2030 — Ticket FMX-080826',
      'costo', 15.5,
      'precio', 20.93,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  1,
  '2506885503',
  NULL,
  15.5,
  null
);

-- FMX-080826 L74 FC 15/04/2030 (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
  jsonb_build_object(
      'nombre', 'FC 15/04/2030',
      'sku', 'FC-BA60704A',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'FC 15/04/2030 — Ticket FMX-080826',
      'costo', 16.45,
      'precio', 22.21,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  1,
  '2504864004',
  NULL,
  16.45,
  null
);

-- FMX-080826 L75 FC 01/11/2029 (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
  jsonb_build_object(
      'nombre', 'FC 01/11/2029',
      'sku', 'FC-8EF34E83',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'FC 01/11/2029 — Ticket FMX-080826',
      'costo', 0.55,
      'precio', 0.75,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  1,
  '2411816005',
  NULL,
  0.55,
  null
);

-- FL-080826 L1 Desenfriolito Tab C/24 2 Pack Bayer Otc $ 93.80 De
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7502276040610' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7502276040610';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Desenfriolito Tab C/24 2 Pack Bayer Otc $ 93.80 Desenfriolito Tab C/24 2 Pack',
      'sku', 'FC-76040610',
      'codigo_barras', '7502276040610',
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'Desenfriolito Tab C/24 2 Pack Bayer Otc $ 93.80 Desenfriolito Tab C/24 2 Pack — Ticket FL-080826',
      'costo', 46.9,
      'precio', 63.32,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      2,
      'TK-FL-080826-1',
      NULL,
      46.9,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7502276040610', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 2, 'TK-FL-080826-1', NULL, 46.9, 'FarmaLive', null
    );
  end if;
end $$;

-- FL-080826 L2 Noche Tab C/12 Descto: 6.0K Tempra , Xt Noche Tab 
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7506460101231' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7506460101231';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Noche Tab C/12 Descto: 6.0K Tempra , Xt Noche Tab C/12 Tempra',
      'sku', 'FC-60101231',
      'codigo_barras', '7506460101231',
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'Noche Tab C/12 Descto: 6.0K Tempra , Xt Noche Tab C/12 Tempra — Ticket FL-080826',
      'costo', 59.69,
      'precio', 80.59,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-2',
      NULL,
      59.69,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7506460101231', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-FL-080826-2', NULL, 59.69, 'FarmaLive', null
    );
  end if;
end $$;

-- FL-080826 L3 Graneodin E Naranja Tab C/16 Rb Health 135.10 Gran
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '75010587154871' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '75010587154871';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Graneodin E Naranja Tab C/16 Rb Health 135.10 Graneodin E Naranja Tab C/16',
      'sku', 'FC-87154871',
      'codigo_barras', '75010587154871',
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'Graneodin E Naranja Tab C/16 Rb Health 135.10 Graneodin E Naranja Tab C/16 — Ticket FL-080826',
      'costo', 132.4,
      'precio', 178.74,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-3',
      NULL,
      132.4,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('75010587154871', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-FL-080826-3', NULL, 132.4, 'FarmaLive', null
    );
  end if;
end $$;

-- FL-080826 L4 Lubricante Soft Lub Pleasüre 56.7 Gr Health 1 $ 10
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7506460101521' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7506460101521';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Lubricante Soft Lub Pleasüre 56.7 Gr Health 1 $ 100.80 Soft Lub Pleasüre Er 222503430721 Vitacilina 28 | Ksk',
      'sku', 'FC-60101521',
      'codigo_barras', '7506460101521',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Lubricante Soft Lub Pleasüre 56.7 Gr Health 1 $ 100.80 Soft Lub Pleasüre Er 222503430721 Vitacilina 28 | Ksk — Ticket FL-080826',
      'costo', 100.8,
      'precio', 136.09,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-4',
      NULL,
      100.8,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7506460101521', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-FL-080826-4', NULL, 100.8, 'FarmaLive', null
    );
  end if;
end $$;

-- FL-080826 L5 Dtc (Rojo) 20 Descto: 2.0% Afrin Spray (Rojo) Afri
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '75010506134531' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '75010506134531';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Dtc (Rojo) 20 Descto: 2.0% Afrin Spray (Rojo) Afrin Spray Ml | Bayer',
      'sku', 'FC-06134531',
      'codigo_barras', '75010506134531',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Dtc (Rojo) 20 Descto: 2.0% Afrin Spray (Rojo) Afrin Spray Ml | Bayer — Ticket FL-080826',
      'costo', 75.46,
      'precio', 101.88,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-5',
      NULL,
      75.46,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('75010506134531', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-FL-080826-5', NULL, 75.46, 'FarmaLive', null
    );
  end if;
end $$;

-- FL-080826 L6 Pomada 100 Gr Descto: 2.0% Bepanthen Pomada Bepant
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7501008427330' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7501008427330';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Pomada 100 Gr Descto: 2.0% Bepanthen Pomada Bepanthen',
      'sku', 'FC-08427330',
      'codigo_barras', '7501008427330',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Pomada 100 Gr Descto: 2.0% Bepanthen Pomada Bepanthen — Ticket FL-080826',
      'costo', 131.81,
      'precio', 177.95,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-6',
      NULL,
      131.81,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7501008427330', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-FL-080826-6', NULL, 131.81, 'FarmaLive', null
    );
  end if;
end $$;

-- FL-080826 L7 Tempra 24 Hrs Cab C/12 Rb Health $ Tempra 24 Hrs C
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7501058792792' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7501058792792';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Tempra 24 Hrs Cab C/12 Rb Health $ Tempra 24 Hrs Cab C/12 1354312225027] Derman Crema 50',
      'sku', 'FC-58792792',
      'codigo_barras', '7501058792792',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Tempra 24 Hrs Cab C/12 Rb Health $ Tempra 24 Hrs Cab C/12 1354312225027] Derman Crema 50 — Ticket FL-080826',
      'costo', 45.6,
      'precio', 61.57,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-7',
      NULL,
      45.6,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7501058792792', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-FL-080826-7', NULL, 45.6, 'FarmaLive', null
    );
  end if;
end $$;

-- FL-080826 L8 Eomelubrina Tab C/10 | Opella $ 73.70 Descto: 2.0%
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '75011650002301' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '75011650002301';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Eomelubrina Tab C/10 | Opella $ 73.70 Descto: 2.0% $ 72.23 Eomelubrina Tab C/10 | Opella',
      'sku', 'FC-50002301',
      'codigo_barras', '75011650002301',
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'Eomelubrina Tab C/10 | Opella $ 73.70 Descto: 2.0% $ 72.23 Eomelubrina Tab C/10 | Opella — Ticket FL-080826',
      'costo', 72.23,
      'precio', 97.52,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-8',
      NULL,
      72.23,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('75011650002301', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-FL-080826-8', NULL, 72.23, 'FarmaLive', null
    );
  end if;
end $$;

-- FL-080826 L9 Histiacil Ne Jar Adto 150 Mi | Opella $ 124.40 $ 1
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7501328979502' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7501328979502';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Histiacil Ne Jar Adto 150 Mi | Opella $ 124.40 $ 124.40 Descto: 2.0% $ 121.91 $ 121.91 Jar Adto 150 Mi | Opella',
      'sku', 'FC-28979502',
      'codigo_barras', '7501328979502',
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'Histiacil Ne Jar Adto 150 Mi | Opella $ 124.40 $ 124.40 Descto: 2.0% $ 121.91 $ 121.91 Jar Adto 150 Mi | Opella — Ticket FL-080826',
      'costo', 124.4,
      'precio', 167.95,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-9',
      NULL,
      124.4,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7501328979502', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-FL-080826-9', NULL, 124.4, 'FarmaLive', null
    );
  end if;
end $$;

-- FL-080826 L10 Histiacil Ne Jar Ine 150 Ml | Opella 1 $ 125.80 $ 
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '75013289794961' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '75013289794961';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Histiacil Ne Jar Ine 150 Ml | Opella 1 $ 125.80 $ 125.80 Descto: 2.0% G 123.28 Jar Ine 150 Ml | Opella G 123.28',
      'sku', 'FC-89794961',
      'codigo_barras', '75013289794961',
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'Histiacil Ne Jar Ine 150 Ml | Opella 1 $ 125.80 $ 125.80 Descto: 2.0% G 123.28 Jar Ine 150 Ml | Opella G 123.28 — Ticket FL-080826',
      'costo', 125.8,
      'precio', 169.83,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-10',
      NULL,
      125.8,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('75013289794961', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-FL-080826-10', NULL, 125.8, 'FarmaLive', null
    );
  end if;
end $$;

do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '75010379071241' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '75010379071241';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Bisolvon Jbe Ine 120 Ml | Lăb Hormona $ 147.90 Descto: 2.0% $ 144.94 $ 147.90 Ine 120 Ml | Lăb Hormona',
      'sku', 'FC-79071241',
      'codigo_barras', '75010379071241',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Bisolvon Jbe Ine 120 Ml | Lăb Hormona $ 147.90 Descto: 2.0% $ 144.94 $ 147.90 Ine 120 Ml | Lăb Hormona — Ticket FL-080826',
      'costo', 147.9,
      'precio', 199.67,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-11',
      NULL,
      147.9,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('75010379071241', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-FL-080826-11', NULL, 147.9, 'FarmaLive', null
    );
  end if;
end $$;

-- FL-080826 L12 Nailex Desenterrador Unas 12 Ml Nailex Desenterrad
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '75022347624171' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '75022347624171';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Nailex Desenterrador Unas 12 Ml Nailex Desenterrador Unas',
      'sku', 'FC-47624171',
      'codigo_barras', '75022347624171',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Nailex Desenterrador Unas 12 Ml Nailex Desenterrador Unas — Ticket FL-080826',
      'costo', 54.49,
      'precio', 73.57,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-12',
      NULL,
      54.49,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('75022347624171', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-FL-080826-12', NULL, 54.49, 'FarmaLive', null
    );
  end if;
end $$;

-- FL-080826 L13 "Lasico Enz C/. Dwightnd Descto: 15.0% "Lasico Dwi
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7501080950139' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7501080950139';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', '"Lasico Enz C/. Dwightnd Descto: 15.0% "Lasico Dwightnd Cond Tro Jan',
      'sku', 'FC-80950139',
      'codigo_barras', '7501080950139',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', '"Lasico Enz C/. Dwightnd Descto: 15.0% "Lasico Dwightnd Cond Tro Jan — Ticket FL-080826',
      'costo', 42.5,
      'precio', 57.38,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-13',
      NULL,
      42.5,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7501080950139', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-FL-080826-13', NULL, 42.5, 'FarmaLive', null
    );
  end if;
end $$;

-- FL-080826 L14 Tribedoce Tab /30 Nvo Bruluart 5 $ 18.00 Tribedoce
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '75022088947797' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '75022088947797';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Tribedoce Tab /30 Nvo Bruluart 5 $ 18.00 Tribedoce Tab /30 Nvo Bruluart',
      'sku', 'FC-88947797',
      'codigo_barras', '75022088947797',
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'Tribedoce Tab /30 Nvo Bruluart 5 $ 18.00 Tribedoce Tab /30 Nvo Bruluart — Ticket FL-080826',
      'costo', 18.0,
      'precio', 24.3,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-14',
      NULL,
      18.0,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('75022088947797', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-FL-080826-14', NULL, 18.0, 'FarmaLive', null
    );
  end if;
end $$;

-- FL-080826 L15 Performance Tab Descto: 2.0% Centrum C/30 Pg Pere 
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '75010650959781' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '75010650959781';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Performance Tab Descto: 2.0% Centrum C/30 Pg Pere Performance Tab Centrum C/30',
      'sku', 'FC-50959781',
      'codigo_barras', '75010650959781',
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'Performance Tab Descto: 2.0% Centrum C/30 Pg Pere Performance Tab Centrum C/30 — Ticket FL-080826',
      'costo', 164.0,
      'precio', 221.4,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-15',
      NULL,
      164.0,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('75010650959781', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-FL-080826-15', NULL, 164.0, 'FarmaLive', null
    );
  end if;
end $$;

-- FL-080826 L16 È Tre & Ice C/3 Dwightnd Descto: 15.0% Cond Trojan
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7501080953017' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7501080953017';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'È Tre & Ice C/3 Dwightnd Descto: 15.0% Cond Trojan È Tre & Ice C/3 Dwightnd',
      'sku', 'FC-80953017',
      'codigo_barras', '7501080953017',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'È Tre & Ice C/3 Dwightnd Descto: 15.0% Cond Trojan È Tre & Ice C/3 Dwightnd — Ticket FL-080826',
      'costo', 49.0,
      'precio', 66.16,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-16',
      NULL,
      49.0,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7501080953017', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-FL-080826-16', NULL, 49.0, 'FarmaLive', null
    );
  end if;
end $$;

-- FL-080826 L17 Tempra 500 Mg Lab C/10 Rb Health $ 48.80 Descto: 6
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '75010954521161' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '75010954521161';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Tempra 500 Mg Lab C/10 Rb Health $ 48.80 Descto: 6.0% Tempra 500 Mg {8 022503405381 Vitacilina Ung I Ksk',
      'sku', 'FC-54521161',
      'codigo_barras', '75010954521161',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Tempra 500 Mg Lab C/10 Rb Health $ 48.80 Descto: 6.0% Tempra 500 Mg {8 022503405381 Vitacilina Ung I Ksk — Ticket FL-080826',
      'costo', 48.8,
      'precio', 65.88,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-17',
      NULL,
      48.8,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('75010954521161', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-FL-080826-17', NULL, 48.8, 'FarmaLive', null
    );
  end if;
end $$;

-- FL-080826 L18 Hipoglos Pac Turo 45 Gr | Andromaco 1 $ 71.00 Desc
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '75012895201021' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '75012895201021';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Hipoglos Pac Turo 45 Gr | Andromaco 1 $ 71.00 Descto: 2.0% $ 69.58 Turo 45 Gr | Andromaco',
      'sku', 'FC-95201021',
      'codigo_barras', '75012895201021',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Hipoglos Pac Turo 45 Gr | Andromaco 1 $ 71.00 Descto: 2.0% $ 69.58 Turo 45 Gr | Andromaco — Ticket FL-080826',
      'costo', 71.0,
      'precio', 95.85,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-18',
      NULL,
      71.0,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('75012895201021', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-FL-080826-18', NULL, 71.0, 'FarmaLive', null
    );
  end if;
end $$;

-- FL-080826 L19 Tabcin Eferv Tab C/12 | Bayer Ot C Descto: 2.0% 38
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7501008485316' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7501008485316';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Tabcin Eferv Tab C/12 | Bayer Ot C Descto: 2.0% 38.50 $ 37.73 Tab C/12 | Bayer Ot C',
      'sku', 'FC-08485316',
      'codigo_barras', '7501008485316',
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'Tabcin Eferv Tab C/12 | Bayer Ot C Descto: 2.0% 38.50 $ 37.73 Tab C/12 | Bayer Ot C — Ticket FL-080826',
      'costo', 37.73,
      'precio', 50.94,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-19',
      NULL,
      37.73,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7501008485316', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-FL-080826-19', NULL, 37.73, 'FarmaLive', null
    );
  end if;
end $$;

-- FL-080826 L20 Centrum Silver Tab C/30 Pg Pere 1 Centrum Silver T
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7501065095947' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7501065095947';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Centrum Silver Tab C/30 Pg Pere 1 Centrum Silver Tab C/30 Pere',
      'sku', 'FC-65095947',
      'codigo_barras', '7501065095947',
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'Centrum Silver Tab C/30 Pg Pere 1 Centrum Silver Tab C/30 Pere — Ticket FL-080826',
      'costo', 178.46,
      'precio', 240.93,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-20',
      NULL,
      178.46,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7501065095947', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-FL-080826-20', NULL, 178.46, 'FarmaLive', null
    );
  end if;
end $$;

-- FL-080826 L21 /10 | Rb Healte Sal De Uvas $ 37.90 Descto: 2.0% $
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7501095451096' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7501095451096';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', '/10 | Rb Healte Sal De Uvas $ 37.90 Descto: 2.0% $ 37.14 /10 | Rb Healte Sal De Uvas Fazolin E Gotas',
      'sku', 'FC-95451096',
      'codigo_barras', '7501095451096',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', '/10 | Rb Healte Sal De Uvas $ 37.90 Descto: 2.0% $ 37.14 /10 | Rb Healte Sal De Uvas Fazolin E Gotas — Ticket FL-080826',
      'costo', 37.9,
      'precio', 51.17,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-21',
      NULL,
      37.9,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7501095451096', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-FL-080826-21', NULL, 37.9, 'FarmaLive', null
    );
  end if;
end $$;

-- FL-080826 L22 Sanfer Descto: 8.04 Syncol Tab $ 107.40 $ 107.40 8
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7501079400556' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7501079400556';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Sanfer Descto: 8.04 Syncol Tab $ 107.40 $ 107.40 8 98.81 Sanfer Syncol Tab 871210734092301 Syncol Max Tab',
      'sku', 'FC-79400556',
      'codigo_barras', '7501079400556',
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'Sanfer Descto: 8.04 Syncol Tab $ 107.40 $ 107.40 8 98.81 Sanfer Syncol Tab 871210734092301 Syncol Max Tab — Ticket FL-080826',
      'costo', 107.4,
      'precio', 144.99,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-22',
      NULL,
      107.4,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7501079400556', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-FL-080826-22', NULL, 107.4, 'FarmaLive', null
    );
  end if;
end $$;

-- FL-080826 L23 Lubricante Sico Sens Calor 50 Ml | Rb Health 1 $ 1
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7501058793249' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7501058793249';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Lubricante Sico Sens Calor 50 Ml | Rb Health 1 $ 101.90 Lubricante Sico Sens Calor 50 Ml | Rb',
      'sku', 'FC-58793249',
      'codigo_barras', '7501058793249',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Lubricante Sico Sens Calor 50 Ml | Rb Health 1 $ 101.90 Lubricante Sico Sens Calor 50 Ml | Rb — Ticket FL-080826',
      'costo', 101.9,
      'precio', 137.57,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-23',
      NULL,
      101.9,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7501058793249', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-FL-080826-23', NULL, 101.9, 'FarmaLive', null
    );
  end if;
end $$;

-- FL-080826 L24 Sal De Uvas Ixh C/50 | Rb Healti 1 $ 163.50 Descto
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7501095467264' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7501095467264';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Sal De Uvas Ixh C/50 | Rb Healti 1 $ 163.50 Descto: 2.0% $ 160.23 Sal De Uvas Ixh C/50 | Rb Healti',
      'sku', 'FC-95467264',
      'codigo_barras', '7501095467264',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Sal De Uvas Ixh C/50 | Rb Healti 1 $ 163.50 Descto: 2.0% $ 160.23 Sal De Uvas Ixh C/50 | Rb Healti — Ticket FL-080826',
      'costo', 163.5,
      'precio', 220.73,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-24',
      NULL,
      163.5,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7501095467264', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-FL-080826-24', NULL, 163.5, 'FarmaLive', null
    );
  end if;
end $$;

-- FL-080826 L25 Lubricante Ico Cereza 50 Ml Rb Health 1 $ 101.90 I
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '75010587932321' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '75010587932321';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Lubricante Ico Cereza 50 Ml Rb Health 1 $ 101.90 Ico Cereza 50 Microdacyn',
      'sku', 'FC-87932321',
      'codigo_barras', '75010587932321',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Lubricante Ico Cereza 50 Ml Rb Health 1 $ 101.90 Ico Cereza 50 Microdacyn — Ticket FL-080826',
      'costo', 101.9,
      'precio', 137.57,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-25',
      NULL,
      101.9,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('75010587932321', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-FL-080826-25', NULL, 101.9, 'FarmaLive', null
    );
  end if;
end $$;

-- FL-080826 L26 Tab C/100 Descto: 2.0% Alka-Seltzer Bayer C/100 Al
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7501008443026' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7501008443026';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Tab C/100 Descto: 2.0% Alka-Seltzer Bayer C/100 Alka-Seltzer Ğel Rojo',
      'sku', 'FC-08443026',
      'codigo_barras', '7501008443026',
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'Tab C/100 Descto: 2.0% Alka-Seltzer Bayer C/100 Alka-Seltzer Ğel Rojo — Ticket FL-080826',
      'costo', 262.0,
      'precio', 353.71,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-26',
      NULL,
      262.0,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7501008443026', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-FL-080826-26', NULL, 262.0, 'FarmaLive', null
    );
  end if;
end $$;

-- FL-080826 L27 Tylenol Tab Kenvue 1 $ 50.00 Descto: 2.0% $ 49.00 
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '75010075354321' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '75010075354321';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Tylenol Tab Kenvue 1 $ 50.00 Descto: 2.0% $ 49.00 $ Kenvue',
      'sku', 'FC-75354321',
      'codigo_barras', '75010075354321',
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'Tylenol Tab Kenvue 1 $ 50.00 Descto: 2.0% $ 49.00 $ Kenvue — Ticket FL-080826',
      'costo', 50.0,
      'precio', 67.5,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-27',
      NULL,
      50.0,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('75010075354321', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-FL-080826-27', NULL, 50.0, 'FarmaLive', null
    );
  end if;
end $$;

-- FL-080826 L28 Aspirina Tab 80 2 Paci Bayer Onc 1 $ 124.80 Aspiri
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7501008491074' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7501008491074';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Aspirina Tab 80 2 Paci Bayer Onc 1 $ 124.80 Aspirina Tab 80 2 Paci [7360852785071 Manzaniila',
      'sku', 'FC-08491074',
      'codigo_barras', '7501008491074',
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'Aspirina Tab 80 2 Paci Bayer Onc 1 $ 124.80 Aspirina Tab 80 2 Paci [7360852785071 Manzaniila — Ticket FL-080826',
      'costo', 122.3,
      'precio', 165.11,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-28',
      NULL,
      122.3,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7501008491074', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-FL-080826-28', NULL, 122.3, 'FarmaLive', null
    );
  end if;
end $$;

-- FL-080826 L29 (A) Treda Tab €/20 Sanfer 2 $ 152.00 $ 304.00 Desc
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7501070612368' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7501070612368';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', '(A) Treda Tab €/20 Sanfer 2 $ 152.00 $ 304.00 Descto: 8.0% Sanfer Brunadol Tab Desato: 2.0%',
      'sku', 'FC-70612368',
      'codigo_barras', '7501070612368',
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', '(A) Treda Tab €/20 Sanfer 2 $ 152.00 $ 304.00 Descto: 8.0% Sanfer Brunadol Tab Desato: 2.0% — Ticket FL-080826',
      'costo', 76.0,
      'precio', 102.6,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      2,
      'TK-FL-080826-29',
      NULL,
      76.0,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7501070612368', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 2, 'TK-FL-080826-29', NULL, 76.0, 'FarmaLive', null
    );
  end if;
end $$;

-- FL-080826 L30 Anara Tab C/20 Chinoin 1 $ 162.60 Descto: 2.0% $ 1
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7501088508929' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7501088508929';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Anara Tab C/20 Chinoin 1 $ 162.60 Descto: 2.0% $ 159.35 Chinoin',
      'sku', 'FC-88508929',
      'codigo_barras', '7501088508929',
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'Anara Tab C/20 Chinoin 1 $ 162.60 Descto: 2.0% $ 159.35 Chinoin — Ticket FL-080826',
      'costo', 162.6,
      'precio', 219.52,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-30',
      NULL,
      162.6,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7501088508929', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-FL-080826-30', NULL, 162.6, 'FarmaLive', null
    );
  end if;
end $$;

-- FL-080826 L31 Forte Tab C/24 Descto: 2.0% Caf Iaspirina Forte C/
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '75010084335531' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '75010084335531';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Forte Tab C/24 Descto: 2.0% Caf Iaspirina Forte C/24 Caf Iaspirina',
      'sku', 'FC-84335531',
      'codigo_barras', '75010084335531',
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'Forte Tab C/24 Descto: 2.0% Caf Iaspirina Forte C/24 Caf Iaspirina — Ticket FL-080826',
      'costo', 71.79,
      'precio', 96.92,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-31',
      NULL,
      71.79,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('75010084335531', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-FL-080826-31', NULL, 71.79, 'FarmaLive', null
    );
  end if;
end $$;

-- FL-080826 L32 Sr I Lab Ting Crema 28 Hormona $ 73.60 Sr I Ting C
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '75010723001331' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '75010723001331';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Sr I Lab Ting Crema 28 Hormona $ 73.60 Sr I Ting Crema 28 Hormona',
      'sku', 'FC-23001331',
      'codigo_barras', '75010723001331',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Sr I Lab Ting Crema 28 Hormona $ 73.60 Sr I Ting Crema 28 Hormona — Ticket FL-080826',
      'costo', 73.6,
      'precio', 99.36,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-32',
      NULL,
      73.6,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('75010723001331', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-FL-080826-32', NULL, 73.6, 'FarmaLive', null
    );
  end if;
end $$;

-- FL-080826 L33 Scabisan Crema Er I Chinoin 1 $ 194.60 Descto: 2.0
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '75010885592111' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '75010885592111';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Scabisan Crema Er I Chinoin 1 $ 194.60 Descto: 2.0% $ 190.71 Scabisan Crema Er I Chinoin',
      'sku', 'FC-85592111',
      'codigo_barras', '75010885592111',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Scabisan Crema Er I Chinoin 1 $ 194.60 Descto: 2.0% $ 190.71 Scabisan Crema Er I Chinoin — Ticket FL-080826',
      'costo', 194.6,
      'precio', 262.72,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-33',
      NULL,
      194.6,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('75010885592111', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-FL-080826-33', NULL, 194.6, 'FarmaLive', null
    );
  end if;
end $$;

-- FL-080826 L34 Boost Tar C/50 Descto: 2.0% Alka-Seltzer Bayer Boo
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '75010084999001' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '75010084999001';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Boost Tar C/50 Descto: 2.0% Alka-Seltzer Bayer Boost Tar C/50 Alka-Seltzer',
      'sku', 'FC-84999001',
      'codigo_barras', '75010084999001',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Boost Tar C/50 Descto: 2.0% Alka-Seltzer Bayer Boost Tar C/50 Alka-Seltzer — Ticket FL-080826',
      'costo', 174.0,
      'precio', 234.9,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-34',
      NULL,
      174.0,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('75010084999001', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-FL-080826-34', NULL, 174.0, 'FarmaLive', null
    );
  end if;
end $$;

-- FL-080826 L35 Bepanthen Multiusos Pomada Otc 30 Bepanthen Multiu
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7501008498798' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7501008498798';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Bepanthen Multiusos Pomada Otc 30 Bepanthen Multiusos Pomada',
      'sku', 'FC-08498798',
      'codigo_barras', '7501008498798',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Bepanthen Multiusos Pomada Otc 30 Bepanthen Multiusos Pomada — Ticket FL-080826',
      'costo', 63.25,
      'precio', 85.39,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-35',
      NULL,
      63.25,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7501008498798', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-FL-080826-35', NULL, 63.25, 'FarmaLive', null
    );
  end if;
end $$;

-- FL-080826 L36 Cafiaspirina Tar C/100 2 Pace Bayer Otc 221.90 Des
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7501008491096' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7501008491096';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Cafiaspirina Tar C/100 2 Pace Bayer Otc 221.90 Descto: 2.0% Cafiaspirina Tar C/100 2 Pace Corega Ultra',
      'sku', 'FC-08491096',
      'codigo_barras', '7501008491096',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Cafiaspirina Tar C/100 2 Pace Bayer Otc 221.90 Descto: 2.0% Cafiaspirina Tar C/100 2 Pace Corega Ultra — Ticket FL-080826',
      'costo', 217.46,
      'precio', 293.58,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-36',
      NULL,
      217.46,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7501008491096', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-FL-080826-36', NULL, 217.46, 'FarmaLive', null
    );
  end if;
end $$;

-- FL-080826 L37 Iv Neomelubrina Jbe 100 Ml I Opella 121.00 Neomelu
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '75011650003151' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '75011650003151';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Iv Neomelubrina Jbe 100 Ml I Opella 121.00 Neomelubrina Jbe 100 Ml I Opella',
      'sku', 'FC-50003151',
      'codigo_barras', '75011650003151',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Iv Neomelubrina Jbe 100 Ml I Opella 121.00 Neomelubrina Jbe 100 Ml I Opella — Ticket FL-080826',
      'costo', 118.58,
      'precio', 160.09,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-37',
      NULL,
      118.58,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('75011650003151', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-FL-080826-37', NULL, 118.58, 'FarmaLive', null
    );
  end if;
end $$;

-- FL-080826 L38 (A) Loxcel Adto Tab C/1 | Lab Hormona 2 $ 78.00 De
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7502224227339' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7502224227339';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', '(A) Loxcel Adto Tab C/1 | Lab Hormona 2 $ 78.00 Descto: 6.0% $ 73.32 Adto Tab C/1 | Lab Hormona 2',
      'sku', 'FC-24227339',
      'codigo_barras', '7502224227339',
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', '(A) Loxcel Adto Tab C/1 | Lab Hormona 2 $ 78.00 Descto: 6.0% $ 73.32 Adto Tab C/1 | Lab Hormona 2 — Ticket FL-080826',
      'costo', 78.0,
      'precio', 105.31,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-38',
      NULL,
      78.0,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7502224227339', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-FL-080826-38', NULL, 78.0, 'FarmaLive', null
    );
  end if;
end $$;

-- FL-080826 L39 Herklin Shai 20 Ml Armstroni 1 $ 128.80 Descto: 2.
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '75010898100381' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '75010898100381';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Herklin Shai 20 Ml Armstroni 1 $ 128.80 Descto: 2.0% $ 126.22 $ 128.80 20 Ml Armstroni 265024 Genomma Alli-Triple',
      'sku', 'FC-98100381',
      'codigo_barras', '75010898100381',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Herklin Shai 20 Ml Armstroni 1 $ 128.80 Descto: 2.0% $ 126.22 $ 128.80 20 Ml Armstroni 265024 Genomma Alli-Triple — Ticket FL-080826',
      'costo', 128.8,
      'precio', 173.89,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-39',
      NULL,
      128.8,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('75010898100381', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-FL-080826-39', NULL, 128.8, 'FarmaLive', null
    );
  end if;
end $$;

-- FL-080826 L40 Supos Adto C/10 Otc Descto: 7.0% Senosiain Senosia
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7501314704156' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7501314704156';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Supos Adto C/10 Otc Descto: 7.0% Senosiain Senosiain Supos Adto C/10 Senosiain Senosiain',
      'sku', 'FC-14704156',
      'codigo_barras', '7501314704156',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Supos Adto C/10 Otc Descto: 7.0% Senosiain Senosiain Supos Adto C/10 Senosiain Senosiain — Ticket FL-080826',
      'costo', 58.96,
      'precio', 79.6,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-40',
      NULL,
      58.96,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7501314704156', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-FL-080826-40', NULL, 58.96, 'FarmaLive', null
    );
  end if;
end $$;

-- FL-080826 L41 Supos Ine C/10 Descto: 7.0% Senosiain Supos C/10 S
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7501314704163' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7501314704163';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Supos Ine C/10 Descto: 7.0% Senosiain Supos C/10 Senosiain',
      'sku', 'FC-14704163',
      'codigo_barras', '7501314704163',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Supos Ine C/10 Descto: 7.0% Senosiain Supos C/10 Senosiain — Ticket FL-080826',
      'costo', 58.96,
      'precio', 79.6,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-41',
      NULL,
      58.96,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7501314704163', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-FL-080826-41', NULL, 58.96, 'FarmaLive', null
    );
  end if;
end $$;

do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7503008344488' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7503008344488';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Lactopram 430 Mg Cap C/20 Progela 29.30 Descto: Lactopram 430 Mg Cap C/20 Progela',
      'sku', 'FC-08344488',
      'codigo_barras', '7503008344488',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Lactopram 430 Mg Cap C/20 Progela 29.30 Descto: Lactopram 430 Mg Cap C/20 Progela — Ticket FL-080826',
      'costo', 28.71,
      'precio', 38.76,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-42',
      NULL,
      28.71,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7503008344488', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-FL-080826-42', NULL, 28.71, 'FarmaLive', null
    );
  end if;
end $$;

-- FL-080826 L43 / 30 | Pg Pere Descto: 2.0% Centrum Tab $ 152.20 P
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7501065095718' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7501065095718';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', '/ 30 | Pg Pere Descto: 2.0% Centrum Tab $ 152.20 Pg Pere Centrum Tab',
      'sku', 'FC-65095718',
      'codigo_barras', '7501065095718',
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', '/ 30 | Pg Pere Descto: 2.0% Centrum Tab $ 152.20 Pg Pere Centrum Tab — Ticket FL-080826',
      'costo', 152.2,
      'precio', 205.47,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-43',
      NULL,
      152.2,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7501065095718', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-FL-080826-43', NULL, 152.2, 'FarmaLive', null
    );
  end if;
end $$;

-- FL-080826 L44 Soft Lub Lubricante Original 56.7 Soft Lubricante 
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '75064601015141' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '75064601015141';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Soft Lub Lubricante Original 56.7 Soft Lubricante Original',
      'sku', 'FC-01015141',
      'codigo_barras', '75064601015141',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Soft Lub Lubricante Original 56.7 Soft Lubricante Original — Ticket FL-080826',
      'costo', 78.49,
      'precio', 105.97,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-44',
      NULL,
      78.49,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('75064601015141', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-FL-080826-44', NULL, 78.49, 'FarmaLive', null
    );
  end if;
end $$;

-- FL-080826 L45 Aspirina Eferv Tab C/12 Bayer Otc Aspirina Eferv C
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7501008496701' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7501008496701';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Aspirina Eferv Tab C/12 Bayer Otc Aspirina Eferv C/12',
      'sku', 'FC-08496701',
      'codigo_barras', '7501008496701',
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'Aspirina Eferv Tab C/12 Bayer Otc Aspirina Eferv C/12 — Ticket FL-080826',
      'costo', 35.18,
      'precio', 47.5,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-45',
      NULL,
      35.18,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7501008496701', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-FL-080826-45', NULL, 35.18, 'FarmaLive', null
    );
  end if;
end $$;

-- FL-080826 L46 Tarmin 2 Mg /12 Tab Bruluagsa Descto: 2.05 6. Tarm
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '75022088915491' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '75022088915491';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Tarmin 2 Mg /12 Tab Bruluagsa Descto: 2.05 6. Tarmin 2 Mg /12 Tab Bruluagsa',
      'sku', 'FC-88915491',
      'codigo_barras', '75022088915491',
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'Tarmin 2 Mg /12 Tab Bruluagsa Descto: 2.05 6. Tarmin 2 Mg /12 Tab Bruluagsa — Ticket FL-080826',
      'costo', 80.9,
      'precio', 109.22,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-46',
      NULL,
      80.9,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('75022088915491', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-FL-080826-46', NULL, 80.9, 'FarmaLive', null
    );
  end if;
end $$;

-- FL-080826 L47 Descto: 2.0% Afrodit 400 Ui 46.00 $ $ 45.08 Afrodi
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7503008344747' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7503008344747';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Descto: 2.0% Afrodit 400 Ui 46.00 $ $ 45.08 Afrodit 400 Ui',
      'sku', 'FC-08344747',
      'codigo_barras', '7503008344747',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Descto: 2.0% Afrodit 400 Ui 46.00 $ $ 45.08 Afrodit 400 Ui — Ticket FL-080826',
      'costo', 45.08,
      'precio', 60.86,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-47',
      NULL,
      45.08,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7503008344747', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-FL-080826-47', NULL, 45.08, 'FarmaLive', null
    );
  end if;
end $$;

-- FL-080826 L48 Ky6 Tab C/10 Bruluart 5 $ 9.50 $ 9.31 $ 47.50 Brul
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7502208895196' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7502208895196';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Ky6 Tab C/10 Bruluart 5 $ 9.50 $ 9.31 $ 47.50 Bruluart E74011 Bayer 67 Aspirina Tab',
      'sku', 'FC-08895196',
      'codigo_barras', '7502208895196',
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'Ky6 Tab C/10 Bruluart 5 $ 9.50 $ 9.31 $ 47.50 Bruluart E74011 Bayer 67 Aspirina Tab — Ticket FL-080826',
      'costo', 1.9,
      'precio', 2.57,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      5,
      'TK-FL-080826-48',
      NULL,
      1.9,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7502208895196', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 5, 'TK-FL-080826-48', NULL, 1.9, 'FarmaLive', null
    );
  end if;
end $$;

-- FL-080826 L49 Herklin Ne Sham 60 Ml | Armstrong 1 $ 81.00 Herkli
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7501089810021' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7501089810021';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Herklin Ne Sham 60 Ml | Armstrong 1 $ 81.00 Herklin Ne Sham 60 Ml | Armstrong',
      'sku', 'FC-89810021',
      'codigo_barras', '7501089810021',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Herklin Ne Sham 60 Ml | Armstrong 1 $ 81.00 Herklin Ne Sham 60 Ml | Armstrong — Ticket FL-080826',
      'costo', 79.38,
      'precio', 107.17,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-49',
      NULL,
      79.38,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7501089810021', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-FL-080826-49', NULL, 79.38, 'FarmaLive', null
    );
  end if;
end $$;

-- FL-080826 L50 Lubricante Piel Con Piel 50 Mi Health 1 $ 102.50 L
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7506460101378' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7506460101378';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Lubricante Piel Con Piel 50 Mi Health 1 $ 102.50 Lubricante Piel Con Piel 50 Mi Lotrimin Uno',
      'sku', 'FC-60101378',
      'codigo_barras', '7506460101378',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Lubricante Piel Con Piel 50 Mi Health 1 $ 102.50 Lubricante Piel Con Piel 50 Mi Lotrimin Uno — Ticket FL-080826',
      'costo', 96.35,
      'precio', 130.08,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-50',
      NULL,
      96.35,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7506460101378', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-FL-080826-50', NULL, 96.35, 'FarmaLive', null
    );
  end if;
end $$;

-- FL-080826 L51 Desenfriol D Dab C/30 | Bayer Otc $ 63.00 Descto: 
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '75022760403681' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '75022760403681';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Desenfriol D Dab C/30 | Bayer Otc $ 63.00 Descto: 2.0% Desenfriol D Dab C/30 | Bayer 5022274264491 Nesajar Cap',
      'sku', 'FC-60403681',
      'codigo_barras', '75022760403681',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Desenfriol D Dab C/30 | Bayer Otc $ 63.00 Descto: 2.0% Desenfriol D Dab C/30 | Bayer 5022274264491 Nesajar Cap — Ticket FL-080826',
      'costo', 63.0,
      'precio', 85.06,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-51',
      NULL,
      63.0,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('75022760403681', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-FL-080826-51', NULL, 63.0, 'FarmaLive', null
    );
  end if;
end $$;

-- FL-080826 L52 Iv Cilocid 5 Mg Tab C/20 | Bruluari 7.40 Descto: 2
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '75022088923551' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '75022088923551';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Iv Cilocid 5 Mg Tab C/20 | Bruluari 7.40 Descto: 2.0% $ 7.25 Iv Cilocid 5 Mg Tab C/20 | Bruluari Senosiain',
      'sku', 'FC-88923551',
      'codigo_barras', '75022088923551',
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'Iv Cilocid 5 Mg Tab C/20 | Bruluari 7.40 Descto: 2.0% $ 7.25 Iv Cilocid 5 Mg Tab C/20 | Bruluari Senosiain — Ticket FL-080826',
      'costo', 7.25,
      'precio', 9.79,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-52',
      NULL,
      7.25,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('75022088923551', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-FL-080826-52', NULL, 7.25, 'FarmaLive', null
    );
  end if;
end $$;

-- FL-080826 L53 Ab Pis. Descto: 2.0% Agrifen Tab 5. $ 19.50 Ab Pis
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7501125116810' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7501125116810';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Ab Pis. Descto: 2.0% Agrifen Tab 5. $ 19.50 Ab Pis. Agrifen Tab',
      'sku', 'FC-25116810',
      'codigo_barras', '7501125116810',
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'Ab Pis. Descto: 2.0% Agrifen Tab 5. $ 19.50 Ab Pis. Agrifen Tab — Ticket FL-080826',
      'costo', 19.5,
      'precio', 26.33,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-53',
      NULL,
      19.5,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7501125116810', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-FL-080826-53', NULL, 19.5, 'FarmaLive', null
    );
  end if;
end $$;

-- FL-080826 L54 Vick Drops Tengibre Pastillas C/20 Vick Drops Teng
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7500435246309' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7500435246309';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Vick Drops Tengibre Pastillas C/20 Vick Drops Tengibre',
      'sku', 'FC-35246309',
      'codigo_barras', '7500435246309',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Vick Drops Tengibre Pastillas C/20 Vick Drops Tengibre — Ticket FL-080826',
      'costo', 37.53,
      'precio', 50.67,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-54',
      NULL,
      37.53,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7500435246309', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-FL-080826-54', NULL, 37.53, 'FarmaLive', null
    );
  end if;
end $$;

-- FL-080826 L55 Ecuperador Una Lab Pisa Descto: 2.0% Aile Marilla 
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '75022347640531' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '75022347640531';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Ecuperador Una Lab Pisa Descto: 2.0% Aile Marilla 15 M Ecuperador Una Aile Marilla 15 M',
      'sku', 'FC-47640531',
      'codigo_barras', '75022347640531',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Ecuperador Una Lab Pisa Descto: 2.0% Aile Marilla 15 M Ecuperador Una Aile Marilla 15 M — Ticket FL-080826',
      'costo', 55.6,
      'precio', 75.06,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-55',
      NULL,
      55.6,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('75022347640531', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-FL-080826-55', NULL, 55.6, 'FarmaLive', null
    );
  end if;
end $$;

-- FL-080826 L56 Saridon Tab 120 Bayer Oto $ 64.75 Saridon Tab
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '75010084095411' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '75010084095411';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Saridon Tab 120 Bayer Oto $ 64.75 Saridon Tab',
      'sku', 'FC-84095411',
      'codigo_barras', '75010084095411',
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'Saridon Tab 120 Bayer Oto $ 64.75 Saridon Tab — Ticket FL-080826',
      'costo', 64.75,
      'precio', 87.42,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-56',
      NULL,
      64.75,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('75010084095411', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-FL-080826-56', NULL, 64.75, 'FarmaLive', null
    );
  end if;
end $$;

-- FL-080826 L57 Jr. Jbe Ine 60 Mant Chinotes Chinoin Jr. Jbe Mant 
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '75010885097661' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '75010885097661';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Jr. Jbe Ine 60 Mant Chinotes Chinoin Jr. Jbe Mant Chinotes Chinoin',
      'sku', 'FC-85097661',
      'codigo_barras', '75010885097661',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Jr. Jbe Ine 60 Mant Chinotes Chinoin Jr. Jbe Mant Chinotes Chinoin — Ticket FL-080826',
      'costo', 127.9,
      'precio', 172.67,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-57',
      NULL,
      127.9,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('75010885097661', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-FL-080826-57', NULL, 127.9, 'FarmaLive', null
    );
  end if;
end $$;

-- FL-080826 L58 Afrin Spray No Drip Extra Humectante Afrin Spray D
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '75010506247327' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '75010506247327';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Afrin Spray No Drip Extra Humectante Afrin Spray Drip Extra',
      'sku', 'FC-06247327',
      'codigo_barras', '75010506247327',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Afrin Spray No Drip Extra Humectante Afrin Spray Drip Extra — Ticket FL-080826',
      'costo', 109.76,
      'precio', 148.18,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-58',
      NULL,
      109.76,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('75010506247327', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-FL-080826-58', NULL, 109.76, 'FarmaLive', null
    );
  end if;
end $$;

-- FL-080826 L59 Flanax 550 Mc Tab C/12 | Bayér Otc 203.00 Descto: 
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '75010084973401' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '75010084973401';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Flanax 550 Mc Tab C/12 | Bayér Otc 203.00 Descto: 10.0% $ 182.70 Tab C/12 | Chinoin',
      'sku', 'FC-84973401',
      'codigo_barras', '75010084973401',
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'Flanax 550 Mc Tab C/12 | Bayér Otc 203.00 Descto: 10.0% $ 182.70 Tab C/12 | Chinoin — Ticket FL-080826',
      'costo', 182.7,
      'precio', 246.65,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-59',
      NULL,
      182.7,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('75010084973401', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-FL-080826-59', NULL, 182.7, 'FarmaLive', null
    );
  end if;
end $$;

-- FL-080826 L60 Gr 5.58 Bayer Descto: 2.0% Flanax Gel 40 Otc Gr 5.
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7501008426944' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7501008426944';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Gr 5.58 Bayer Descto: 2.0% Flanax Gel 40 Otc Gr 5.58 Flanax Gel 40',
      'sku', 'FC-08426944',
      'codigo_barras', '7501008426944',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Gr 5.58 Bayer Descto: 2.0% Flanax Gel 40 Otc Gr 5.58 Flanax Gel 40 — Ticket FL-080826',
      'costo', 117.11,
      'precio', 158.1,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-60',
      NULL,
      117.11,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7501008426944', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-FL-080826-60', NULL, 117.11, 'FarmaLive', null
    );
  end if;
end $$;

-- FL-080826 L61 Iv Sot.O-Neurobion Dc Ete Jga Sot.O-Neurobion Prel
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '75012982176351' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '75012982176351';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Iv Sot.O-Neurobion Dc Ete Jga Sot.O-Neurobion Prell C/1 | Pg Health9.20',
      'sku', 'FC-82176351',
      'codigo_barras', '75012982176351',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Iv Sot.O-Neurobion Dc Ete Jga Sot.O-Neurobion Prell C/1 | Pg Health9.20 — Ticket FL-080826',
      'costo', 819.71,
      'precio', 1106.61,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-61',
      NULL,
      819.71,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('75012982176351', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-FL-080826-61', NULL, 819.71, 'FarmaLive', null
    );
  end if;
end $$;

-- FL-080826 L62 Iri Amp 50.000 Mexico Descto: Mexico Iv Bedoyecta 
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '75011230133021' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '75011230133021';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Iri Amp 50.000 Mexico Descto: Mexico Iv Bedoyecta Bausch',
      'sku', 'FC-30133021',
      'codigo_barras', '75011230133021',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Iri Amp 50.000 Mexico Descto: Mexico Iv Bedoyecta Bausch — Ticket FL-080826',
      'costo', 273.42,
      'precio', 369.12,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-62',
      NULL,
      273.42,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('75011230133021', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-FL-080826-62', NULL, 273.42, 'FarmaLive', null
    );
  end if;
end $$;

-- FL-080826 L63 Iv Dolo-Neurobion Dc Jga Preli C/3 3 Ml | Pg Healt
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7501298217659' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7501298217659';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Iv Dolo-Neurobion Dc Jga Preli C/3 3 Ml | Pg Health 23.25 Descto: 17.0% Dolo-Neurobion Dc Jga Preli C/3 3 Ml | Pg Health',
      'sku', 'FC-98217659',
      'codigo_barras', '7501298217659',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Iv Dolo-Neurobion Dc Jga Preli C/3 3 Ml | Pg Health 23.25 Descto: 17.0% Dolo-Neurobion Dc Jga Preli C/3 3 Ml | Pg Health — Ticket FL-080826',
      'costo', 434.3,
      'precio', 586.31,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-63',
      NULL,
      434.3,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7501298217659', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-FL-080826-63', NULL, 434.3, 'FarmaLive', null
    );
  end if;
end $$;

-- FL-080826 L64 Crema Dent Colgate Max Clean 120 Ml Colgate Palmol
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '75095466888171' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '75095466888171';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Crema Dent Colgate Max Clean 120 Ml Colgate Palmolive $ 25.50 Descto: 2.0% $ 24.99 Crema Dent Colgate Max Clean 120 Ml C',
      'sku', 'FC-66888171',
      'codigo_barras', '75095466888171',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Crema Dent Colgate Max Clean 120 Ml Colgate Palmolive $ 25.50 Descto: 2.0% $ 24.99 Crema Dent Colgate Max Clean 120 Ml C — Ticket FL-080826',
      'costo', 25.5,
      'precio', 34.43,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-64',
      NULL,
      25.5,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('75095466888171', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-FL-080826-64', NULL, 25.5, 'FarmaLive', null
    );
  end if;
end $$;

-- FL-080826 L65 90 Crema Dent Aot.Cate Me P Crema Dent Aot.Cate
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '75095466873531' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '75095466873531';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', '90 Crema Dent Aot.Cate Me P Crema Dent Aot.Cate',
      'sku', 'FC-66873531',
      'codigo_barras', '75095466873531',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', '90 Crema Dent Aot.Cate Me P Crema Dent Aot.Cate — Ticket FL-080826',
      'costo', 32.44,
      'precio', 43.8,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-65',
      NULL,
      32.44,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('75095466873531', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-FL-080826-65', NULL, 32.44, 'FarmaLive', null
    );
  end if;
end $$;

-- FL-080826 L66 Sigital Protec Desato: 2.0% Termometro Degasa 42.1
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '75010486708021' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '75010486708021';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Sigital Protec Desato: 2.0% Termometro Degasa 42.10 Sigital Protec Desato: 2.0% Termometro',
      'sku', 'FC-86708021',
      'codigo_barras', '75010486708021',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Sigital Protec Desato: 2.0% Termometro Degasa 42.10 Sigital Protec Desato: 2.0% Termometro — Ticket FL-080826',
      'costo', 41.26,
      'precio', 55.71,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-66',
      NULL,
      41.26,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('75010486708021', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-FL-080826-66', NULL, 41.26, 'FarmaLive', null
    );
  end if;
end $$;

-- FL-080826 L67 Tela Adhesiva Quirmex 2.5Cmxsm | Quirmex Descto: 2
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7503003406600' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7503003406600';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Tela Adhesiva Quirmex 2.5Cmxsm | Quirmex Descto: 2.0% 29.90 29.30 $ 89.70 Quirmex 2.5Cmxsm | Quirmex',
      'sku', 'FC-03406600',
      'codigo_barras', '7503003406600',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Tela Adhesiva Quirmex 2.5Cmxsm | Quirmex Descto: 2.0% 29.90 29.30 $ 89.70 Quirmex 2.5Cmxsm | Quirmex — Ticket FL-080826',
      'costo', 89.7,
      'precio', 121.1,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-67',
      NULL,
      89.7,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7503003406600', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-FL-080826-67', NULL, 89.7, 'FarmaLive', null
    );
  end if;
end $$;

-- FL-080826 L68 Tela Adhesiva Quirmex 1.25Cmx5M | Quirmex 19.00 De
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7503003406501' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7503003406501';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Tela Adhesiva Quirmex 1.25Cmx5M | Quirmex 19.00 Descto: 2.0% $ 18.62 $ Quirmex 1.25Cmx5M | Quirmex',
      'sku', 'FC-03406501',
      'codigo_barras', '7503003406501',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Tela Adhesiva Quirmex 1.25Cmx5M | Quirmex 19.00 Descto: 2.0% $ 18.62 $ Quirmex 1.25Cmx5M | Quirmex — Ticket FL-080826',
      'costo', 18.62,
      'precio', 25.14,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-68',
      NULL,
      18.62,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7503003406501', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-FL-080826-68', NULL, 18.62, 'FarmaLive', null
    );
  end if;
end $$;

-- FL-080826 L69 Tela Adhesiva Quirmex 2.5Cmxi̇m | Quirmex 5 $ 11.7
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '75030034063651' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '75030034063651';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Tela Adhesiva Quirmex 2.5Cmxi̇m | Quirmex 5 $ 11.70 Descto: 2.0% $ 11.47 | Tela Adhesiva Quirmex 2.5Cmxi̇m | Quirmex',
      'sku', 'FC-34063651',
      'codigo_barras', '75030034063651',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Tela Adhesiva Quirmex 2.5Cmxi̇m | Quirmex 5 $ 11.70 Descto: 2.0% $ 11.47 | Tela Adhesiva Quirmex 2.5Cmxi̇m | Quirmex — Ticket FL-080826',
      'costo', 2.34,
      'precio', 3.16,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      5,
      'TK-FL-080826-69',
      NULL,
      2.34,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('75030034063651', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 5, 'TK-FL-080826-69', NULL, 2.34, 'FarmaLive', null
    );
  end if;
end $$;

-- FL-080826 L70 Tela Adhesiva Quirmex 1.25Cmx1M | Quirmex 5 5.40 $
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '75030034062421' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '75030034062421';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Tela Adhesiva Quirmex 1.25Cmx1M | Quirmex 5 5.40 $ Tela Adhesiva Quirmex 1.25Cmx1M | Quirmex',
      'sku', 'FC-34062421',
      'codigo_barras', '75030034062421',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Tela Adhesiva Quirmex 1.25Cmx1M | Quirmex 5 5.40 $ Tela Adhesiva Quirmex 1.25Cmx1M | Quirmex — Ticket FL-080826',
      'costo', 5.29,
      'precio', 7.15,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-70',
      NULL,
      5.29,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('75030034062421', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-FL-080826-70', NULL, 5.29, 'FarmaLive', null
    );
  end if;
end $$;

-- FL-080826 L71 Crema Deni Colgate Trip Xtra B 50 Ml 1 Colgate Pai
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '75095460689091' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '75095460689091';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Crema Deni Colgate Trip Xtra B 50 Ml 1 Colgate Paimolive 14.00 Descto: 2.04 Colgate Trip Xtra B 50 Ml',
      'sku', 'FC-60689091',
      'codigo_barras', '75095460689091',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Crema Deni Colgate Trip Xtra B 50 Ml 1 Colgate Paimolive 14.00 Descto: 2.04 Colgate Trip Xtra B 50 Ml — Ticket FL-080826',
      'costo', 13.72,
      'precio', 18.53,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-71',
      NULL,
      13.72,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('75095460689091', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-FL-080826-71', NULL, 13.72, 'FarmaLive', null
    );
  end if;
end $$;

-- FL-080826 L72 Panuelos Kleenex Pack C/8 1 Kimberly Clark $ 33.30
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '75010173629981' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '75010173629981';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Panuelos Kleenex Pack C/8 1 Kimberly Clark $ 33.30 Descto: 2.04 Panuelos Kleenex Pack C/8 1 Kimberly Clark',
      'sku', 'FC-73629981',
      'codigo_barras', '75010173629981',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Panuelos Kleenex Pack C/8 1 Kimberly Clark $ 33.30 Descto: 2.04 Panuelos Kleenex Pack C/8 1 Kimberly Clark — Ticket FL-080826',
      'costo', 33.3,
      'precio', 44.96,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-72',
      NULL,
      33.3,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('75010173629981', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-FL-080826-72', NULL, 33.3, 'FarmaLive', null
    );
  end if;
end $$;
commit;
