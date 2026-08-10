-- Suplemento: 15 lineas omitidas en _EJECUTAR_1..4 (+15 pzas)
-- Ejecutar UNA vez. Si un SKU ya existe, create_producto puede fallar: revisar notices.

begin;

create temp table if not exists _fc_carga_map (
  codigo_barras text primary key,
  producto_id bigint
) on commit drop;

insert into _fc_carga_map (codigo_barras, producto_id)
select codigo_barras, id from public.productos
where codigo_barras is not null and btrim(codigo_barras) <> ''
on conflict (codigo_barras) do nothing;


-- 440393 L1 TERFICHO 40 CAPS 100 MG (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
  jsonb_build_object(
      'nombre', 'TERFICHO 40 CAPS 100 MG',
      'sku', 'FC-F967863B',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'TERFICHO 40 CAPS 100 MG — Ticket 440393',
      'costo', 46.05,
      'precio', 62.17,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  1,
  '5M297',
  '2028-01-17',
  46.05,
  null
);

-- 440393 L77 PERLUDIL 1 FA 150/10 MG (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
  jsonb_build_object(
      'nombre', 'PERLUDIL 1 FA 150/10 MG',
      'sku', 'FC-AA905BF7',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'PERLUDIL 1 FA 150/10 MG — Ticket 440393',
      'costo', 16.11,
      'precio', 21.75,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  1,
  'S2341670',
  '2027-11-30',
  16.11,
  null
);

-- 440393 L154 OVISEN 14 TAB 20 MG (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
  jsonb_build_object(
      'nombre', 'OVISEN 14 TAB 20 MG',
      'sku', 'FC-FD92D114',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'OVISEN 14 TAB 20 MG — Ticket 440393',
      'costo', 10.19,
      'precio', 13.76,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  1,
  'SC2622',
  '2028-03-01',
  10.19,
  null
);

-- 77827 L32 Jbn Liq Palmol N-Bal Dermol 221Mln
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7509546059556' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7509546059556';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Jbn Liq Palmol N-Bal Dermol 221Mln',
      'sku', 'FC-46059556',
      'codigo_barras', '7509546059556',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Jbn Liq Palmol N-Bal Dermol 221Mln — Ticket 77827',
      'costo', 52.29,
      'precio', 70.6,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-77827-32',
      NULL,
      52.29,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7509546059556', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-77827-32', NULL, 52.29, 'Bodega F-42 Ejidos del Moral', null
    );
  end if;
end $$;

-- 77827 L68 Sh Int Lomecan V Aclar 200Ml
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '650240030338' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '650240030338';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Sh Int Lomecan V Aclar 200Ml',
      'sku', 'FC-40030338',
      'codigo_barras', '650240030338',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Sh Int Lomecan V Aclar 200Ml — Ticket 77827',
      'costo', 41.84,
      'precio', 56.49,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-77827-68',
      NULL,
      41.84,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('650240030338', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-77827-68', NULL, 41.84, 'Bodega F-42 Ejidos del Moral', null
    );
  end if;
end $$;

-- 77827 L105 Sh Hbs Alivio Instant
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7500435020077' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7500435020077';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Sh Hbs Alivio Instant',
      'sku', 'FC-35020077',
      'codigo_barras', '7500435020077',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Sh Hbs Alivio Instant — Ticket 77827',
      'costo', 45.23,
      'precio', 61.07,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-77827-105',
      NULL,
      45.23,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7500435020077', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-77827-105', NULL, 45.23, 'Bodega F-42 Ejidos del Moral', null
    );
  end if;
end $$;

-- 77827 L140 Cra Lubriderm Uv Fps15 120Ml
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7702035469151' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7702035469151';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Cra Lubriderm Uv Fps15 120Ml',
      'sku', 'FC-35469151',
      'codigo_barras', '7702035469151',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Cra Lubriderm Uv Fps15 120Ml — Ticket 77827',
      'costo', 15.51,
      'precio', 20.94,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-77827-140',
      NULL,
      15.51,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7702035469151', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-77827-140', NULL, 15.51, 'Bodega F-42 Ejidos del Moral', null
    );
  end if;
end $$;

-- 77827 L177 Tco Mennen Azul 200G
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7501035908130' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7501035908130';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Tco Mennen Azul 200G',
      'sku', 'FC-35908130',
      'codigo_barras', '7501035908130',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Tco Mennen Azul 200G — Ticket 77827',
      'costo', 69.19,
      'precio', 93.41,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-77827-177',
      NULL,
      69.19,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7501035908130', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-77827-177', NULL, 69.19, 'Bodega F-42 Ejidos del Moral', null
    );
  end if;
end $$;

-- 112558 L27 TB 3 SURT
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

-- FMX-080826 L22 FC 01/04/2028 (sin barcode)
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

-- FL-080826 L11 Bisolvon Jbe Ine 120 Ml | Lăb Hormona $ 147.90 Des
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

-- FL-080826 L42 Lactopram 430 Mg Cap C/20 Progela 29.30 Descto: La
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

-- FL-080826 L73 Panuelos Leenex C/90 | Kimberly Clark 25. $ Descto
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '75064256131681' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '75064256131681';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Panuelos Leenex C/90 | Kimberly Clark 25. $ Descto: 2.0% Leenex C/90 | Kimberly Clark Bib Evenelo',
      'sku', 'FC-56131681',
      'codigo_barras', '75064256131681',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Panuelos Leenex C/90 | Kimberly Clark 25. $ Descto: 2.0% Leenex C/90 | Kimberly Clark Bib Evenelo — Ticket FL-080826',
      'costo', 24.89,
      'precio', 33.61,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-73',
      NULL,
      24.89,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('75064256131681', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-FL-080826-73', NULL, 24.89, 'FarmaLive', null
    );
  end if;
end $$;

-- FL-080826 L104 Nestum Probioticos Marcas Nestle Avena 270 Nestum 
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '75010586167151' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '75010586167151';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Nestum Probioticos Marcas Nestle Avena 270 Nestum Probioticos Marcas Nestle',
      'sku', 'FC-86167151',
      'codigo_barras', '75010586167151',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Nestum Probioticos Marcas Nestle Avena 270 Nestum Probioticos Marcas Nestle — Ticket FL-080826',
      'costo', 52.43,
      'precio', 70.79,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-104',
      NULL,
      52.43,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('75010586167151', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-FL-080826-104', NULL, 52.43, 'FarmaLive', null
    );
  end if;
end $$;

-- FL-080826 L135 Ajolotius Pastillas Elderberry Past Bioalimentos N
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '75064524004581' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '75064524004581';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Ajolotius Pastillas Elderberry Past Bioalimentos Nat $ 21.00 Descto: 2.0% Ajolotius Pastillas Elderberry Past',
      'sku', 'FC-24004581',
      'codigo_barras', '75064524004581',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Ajolotius Pastillas Elderberry Past Bioalimentos Nat $ 21.00 Descto: 2.0% Ajolotius Pastillas Elderberry Past — Ticket FL-080826',
      'costo', 21.0,
      'precio', 28.35,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-135',
      NULL,
      21.0,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('75064524004581', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-FL-080826-135', NULL, 21.0, 'FarmaLive', null
    );
  end if;
end $$;

commit;
