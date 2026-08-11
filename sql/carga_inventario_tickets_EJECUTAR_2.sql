
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

-- 77827 L69 Silkhair Quita Esmalte Mora Azul 100Ml
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7502245720550' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7502245720550';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Silkhair Quita Esmalte Mora Azul 100Ml',
      'sku', 'FC-45720550',
      'codigo_barras', '7502245720550',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Silkhair Quita Esmalte Mora Azul 100Ml — Ticket 77827',
      'costo', 41.84,
      'precio', 56.49,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-77827-69',
      NULL,
      41.84,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7502245720550', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-77827-69', NULL, 41.84, 'Bodega F-42 Ejidos del Moral', null
    );
  end if;
end $$;

-- 77827 L70 Cra Nutribela1O Bio Colageno 300Gn
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7506192511261' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7506192511261';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Cra Nutribela1O Bio Colageno 300Gn',
      'sku', 'FC-92511261',
      'codigo_barras', '7506192511261',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Cra Nutribela1O Bio Colageno 300Gn — Ticket 77827',
      'costo', 29.31,
      'precio', 39.57,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-77827-70',
      NULL,
      29.31,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7506192511261', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-77827-70', NULL, 29.31, 'Bodega F-42 Ejidos del Moral', null
    );
  end if;
end $$;

-- 77827 L71 Cra Nutribela Nutrice Tarro 300G
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7506192509213' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7506192509213';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Cra Nutribela Nutrice Tarro 300G',
      'sku', 'FC-92509213',
      'codigo_barras', '7506192509213',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Cra Nutribela Nutrice Tarro 300G — Ticket 77827',
      'costo', 40.24,
      'precio', 54.33,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-77827-71',
      NULL,
      40.24,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7506192509213', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-77827-71', NULL, 40.24, 'Bodega F-42 Ejidos del Moral', null
    );
  end if;
end $$;

-- 77827 L73 Rexona 1O0Gr Tco Pies Efficient Orig
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7506306257597' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7506306257597';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Rexona 1O0Gr Tco Pies Efficient Orig',
      'sku', 'FC-06257597',
      'codigo_barras', '7506306257597',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Rexona 1O0Gr Tco Pies Efficient Orig — Ticket 77827',
      'costo', 75.7,
      'precio', 102.2,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-77827-73',
      NULL,
      75.7,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7506306257597', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-77827-73', NULL, 75.7, 'Bodega F-42 Ejidos del Moral', null
    );
  end if;
end $$;

-- 77827 L74 Sh Caprice Nat Mzna 380 Ml
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7509546073156' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7509546073156';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Sh Caprice Nat Mzna 380 Ml',
      'sku', 'FC-46073156',
      'codigo_barras', '7509546073156',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Sh Caprice Nat Mzna 380 Ml — Ticket 77827',
      'costo', 75.7,
      'precio', 102.2,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-77827-74',
      NULL,
      75.7,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7509546073156', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-77827-74', NULL, 75.7, 'Bodega F-42 Ejidos del Moral', null
    );
  end if;
end $$;

-- 77827 L75 Cra Pert Oliv+Ac Agu P/Pein 100 Ml
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '810120500171' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '810120500171';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Cra Pert Oliv+Ac Agu P/Pein 100 Ml',
      'sku', 'FC-20500171',
      'codigo_barras', '810120500171',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Cra Pert Oliv+Ac Agu P/Pein 100 Ml — Ticket 77827',
      'costo', 25.04,
      'precio', 33.81,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      2,
      'TK-77827-75',
      NULL,
      25.04,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('810120500171', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 2, 'TK-77827-75', NULL, 25.04, 'Bodega F-42 Ejidos del Moral', null
    );
  end if;
end $$;

-- 77827 L76 Ac Pantene Bambu 400Ml
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7500435155922' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7500435155922';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Ac Pantene Bambu 400Ml',
      'sku', 'FC-35155922',
      'codigo_barras', '7500435155922',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Ac Pantene Bambu 400Ml — Ticket 77827',
      'costo', 15.7,
      'precio', 21.2,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-77827-76',
      NULL,
      15.7,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7500435155922', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-77827-76', NULL, 15.7, 'Bodega F-42 Ejidos del Moral', null
    );
  end if;
end $$;

-- 77827 L78 Acono Pant Brillo Extremo 40Cml
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7501007457826' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7501007457826';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Acono Pant Brillo Extremo 40Cml',
      'sku', 'FC-07457826',
      'codigo_barras', '7501007457826',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Acono Pant Brillo Extremo 40Cml — Ticket 77827',
      'costo', 75.7,
      'precio', 102.2,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-77827-78',
      NULL,
      75.7,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7501007457826', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-77827-78', NULL, 75.7, 'Bodega F-42 Ejidos del Moral', null
    );
  end if;
end $$;

-- 77827 L79 Cra Sedal Rizos Obedie 300Ml
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7501056340131' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7501056340131';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Cra Sedal Rizos Obedie 300Ml',
      'sku', 'FC-56340131',
      'codigo_barras', '7501056340131',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Cra Sedal Rizos Obedie 300Ml — Ticket 77827',
      'costo', 19.11,
      'precio', 25.8,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-77827-79',
      NULL,
      19.11,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7501056340131', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-77827-79', NULL, 19.11, 'Bodega F-42 Ejidos del Moral', null
    );
  end if;
end $$;

-- 77827 L80 Acond Pant Rizos Definid 400Ml
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7501001165321' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7501001165321';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Acond Pant Rizos Definid 400Ml',
      'sku', 'FC-01165321',
      'codigo_barras', '7501001165321',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Acond Pant Rizos Definid 400Ml — Ticket 77827',
      'costo', 71.8,
      'precio', 96.93,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-77827-80',
      NULL,
      71.8,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7501001165321', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-77827-80', NULL, 71.8, 'Bodega F-42 Ejidos del Moral', null
    );
  end if;
end $$;

-- 77827 L81 Sh Sedal Rizos Def Inf-Act 180Ml
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7506306249783' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7506306249783';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Sh Sedal Rizos Def Inf-Act 180Ml',
      'sku', 'FC-06249783',
      'codigo_barras', '7506306249783',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Sh Sedal Rizos Def Inf-Act 180Ml — Ticket 77827',
      'costo', 50.07,
      'precio', 67.6,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-77827-81',
      NULL,
      50.07,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7506306249783', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-77827-81', NULL, 50.07, 'Bodega F-42 Ejidos del Moral', null
    );
  end if;
end $$;

-- 77827 L82 Tco Desod Eficc Pies 200 G
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7501056360429' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7501056360429';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Tco Desod Eficc Pies 200 G',
      'sku', 'FC-56360429',
      'codigo_barras', '7501056360429',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Tco Desod Eficc Pies 200 G — Ticket 77827',
      'costo', 36.33,
      'precio', 49.05,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-77827-82',
      NULL,
      36.33,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7501056360429', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-77827-82', NULL, 36.33, 'Bodega F-42 Ejidos del Moral', null
    );
  end if;
end $$;

-- 77827 L83 Cra Sedal Sos Recon-Estru 300Ml
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7501056340025' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7501056340025';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Cra Sedal Sos Recon-Estru 300Ml',
      'sku', 'FC-56340025',
      'codigo_barras', '7501056340025',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Cra Sedal Sos Recon-Estru 300Ml — Ticket 77827',
      'costo', 18.88,
      'precio', 25.49,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-77827-83',
      NULL,
      18.88,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7501056340025', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-77827-83', NULL, 18.88, 'Bodega F-42 Ejidos del Moral', null
    );
  end if;
end $$;

-- 77827 L84 Cra Sedal Rizos Obedientes 135Ml
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7501056342227' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7501056342227';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Cra Sedal Rizos Obedientes 135Ml',
      'sku', 'FC-56342227',
      'codigo_barras', '7501056342227',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Cra Sedal Rizos Obedientes 135Ml — Ticket 77827',
      'costo', 8.24,
      'precio', 11.13,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      2,
      'TK-77827-84',
      NULL,
      8.24,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7501056342227', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 2, 'TK-77827-84', NULL, 8.24, 'Bodega F-42 Ejidos del Moral', null
    );
  end if;
end $$;

-- 77827 L85 Sh Sedal Ceramidas Inf-Act 180Ml
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7506306249776' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7506306249776';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Sh Sedal Ceramidas Inf-Act 180Ml',
      'sku', 'FC-06249776',
      'codigo_barras', '7506306249776',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Sh Sedal Ceramidas Inf-Act 180Ml — Ticket 77827',
      'costo', 75.7,
      'precio', 102.2,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-77827-85',
      NULL,
      75.7,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7506306249776', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-77827-85', NULL, 75.7, 'Bodega F-42 Ejidos del Moral', null
    );
  end if;
end $$;

-- 77827 L86 Sh Pant Ctrcaida A/Pv 400Ml
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7501001303454' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7501001303454';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Sh Pant Ctrcaida A/Pv 400Ml',
      'sku', 'FC-01303454',
      'codigo_barras', '7501001303454',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Sh Pant Ctrcaida A/Pv 400Ml — Ticket 77827',
      'costo', 40.66,
      'precio', 54.9,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-77827-86',
      NULL,
      40.66,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7501001303454', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-77827-86', NULL, 40.66, 'Bodega F-42 Ejidos del Moral', null
    );
  end if;
end $$;

-- 77827 L87 Sh Pant Brillo Extremo
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7501007457796' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7501007457796';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Sh Pant Brillo Extremo',
      'sku', 'FC-07457796',
      'codigo_barras', '7501007457796',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Sh Pant Brillo Extremo — Ticket 77827',
      'costo', 75.7,
      'precio', 102.2,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-77827-87',
      NULL,
      75.7,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7501007457796', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-77827-87', NULL, 75.7, 'Bodega F-42 Ejidos del Moral', null
    );
  end if;
end $$;

-- 77827 L89 Sh Pant Bambu Ctrl Caida 400 Ml
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7500435155847' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7500435155847';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Sh Pant Bambu Ctrl Caida 400 Ml',
      'sku', 'FC-35155847',
      'codigo_barras', '7500435155847',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Sh Pant Bambu Ctrl Caida 400 Ml — Ticket 77827',
      'costo', 40.66,
      'precio', 54.9,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-77827-89',
      NULL,
      40.66,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7500435155847', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-77827-89', NULL, 40.66, 'Bodega F-42 Ejidos del Moral', null
    );
  end if;
end $$;

-- 77827 L90 Sh Savile Ker-Sab Fza Repar 700Ml
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7506306249240' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7506306249240';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Sh Savile Ker-Sab Fza Repar 700Ml',
      'sku', 'FC-06249240',
      'codigo_barras', '7506306249240',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Sh Savile Ker-Sab Fza Repar 700Ml — Ticket 77827',
      'costo', 44.76,
      'precio', 60.43,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-77827-90',
      NULL,
      44.76,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7506306249240', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-77827-90', NULL, 44.76, 'Bodega F-42 Ejidos del Moral', null
    );
  end if;
end $$;

-- 77827 L91 Sh Savile Bio-Sab Creci Res 700Ml
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7506306249226' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7506306249226';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Sh Savile Bio-Sab Creci Res 700Ml',
      'sku', 'FC-06249226',
      'codigo_barras', '7506306249226',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Sh Savile Bio-Sab Creci Res 700Ml — Ticket 77827',
      'costo', 50.07,
      'precio', 67.6,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-77827-91',
      NULL,
      50.07,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7506306249226', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-77827-91', NULL, 50.07, 'Bodega F-42 Ejidos del Moral', null
    );
  end if;
end $$;

-- 77827 L92 Silica Shine Sil 3/1 Uva 120 Mi
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7502224511629' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7502224511629';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Silica Shine Sil 3/1 Uva 120 Mi',
      'sku', 'FC-24511629',
      'codigo_barras', '7502224511629',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Silica Shine Sil 3/1 Uva 120 Mi — Ticket 77827',
      'costo', 18.17,
      'precio', 24.53,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-77827-92',
      NULL,
      18.17,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7502224511629', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-77827-92', NULL, 18.17, 'Bodega F-42 Ejidos del Moral', null
    );
  end if;
end $$;

-- 77827 L93 Cra Sedal Anti Nudos 300 Ml
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7506306234062' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7506306234062';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Cra Sedal Anti Nudos 300 Ml',
      'sku', 'FC-06234062',
      'codigo_barras', '7506306234062',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Cra Sedal Anti Nudos 300 Ml — Ticket 77827',
      'costo', 17.77,
      'precio', 23.99,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-77827-93',
      NULL,
      17.77,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7506306234062', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-77827-93', NULL, 17.77, 'Bodega F-42 Ejidos del Moral', null
    );
  end if;
end $$;

-- 77827 L94 Cra Sedal Recons Estructur 135Ml
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7501056342258' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7501056342258';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Cra Sedal Recons Estructur 135Ml',
      'sku', 'FC-56342258',
      'codigo_barras', '7501056342258',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Cra Sedal Recons Estructur 135Ml — Ticket 77827',
      'costo', 17.77,
      'precio', 23.99,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-77827-94',
      NULL,
      17.77,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7501056342258', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-77827-94', NULL, 17.77, 'Bodega F-42 Ejidos del Moral', null
    );
  end if;
end $$;

-- 77827 L95 Tco Desdo Odolex 150 G
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7501361111501' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7501361111501';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Tco Desdo Odolex 150 G',
      'sku', 'FC-61111501',
      'codigo_barras', '7501361111501',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Tco Desdo Odolex 150 G — Ticket 77827',
      'costo', 50.07,
      'precio', 67.6,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-77827-95',
      NULL,
      50.07,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7501361111501', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-77827-95', NULL, 50.07, 'Bodega F-42 Ejidos del Moral', null
    );
  end if;
end $$;

-- 77827 L96 Tco Odolex Fresh 150G
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7501361124013' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7501361124013';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Tco Odolex Fresh 150G',
      'sku', 'FC-61124013',
      'codigo_barras', '7501361124013',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Tco Odolex Fresh 150G — Ticket 77827',
      'costo', 73.76,
      'precio', 99.58,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-77827-96',
      NULL,
      73.76,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7501361124013', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-77827-96', NULL, 73.76, 'Bodega F-42 Ejidos del Moral', null
    );
  end if;
end $$;

-- 77827 L97 Cra Sedal Sos Ceramida 300Ml
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7501056340124' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7501056340124';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Cra Sedal Sos Ceramida 300Ml',
      'sku', 'FC-56340124',
      'codigo_barras', '7501056340124',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Cra Sedal Sos Ceramida 300Ml — Ticket 77827',
      'costo', 57.9,
      'precio', 78.17,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-77827-97',
      NULL,
      57.9,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7501056340124', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-77827-97', NULL, 57.9, 'Bodega F-42 Ejidos del Moral', null
    );
  end if;
end $$;

-- 77827 L98 Sh Hbs Limp Renoy 375Ml
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7500435020008' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7500435020008';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Sh Hbs Limp Renoy 375Ml',
      'sku', 'FC-35020008',
      'codigo_barras', '7500435020008',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Sh Hbs Limp Renoy 375Ml — Ticket 77827',
      'costo', 57.9,
      'precio', 78.17,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-77827-98',
      NULL,
      57.9,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7500435020008', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-77827-98', NULL, 57.9, 'Bodega F-42 Ejidos del Moral', null
    );
  end if;
end $$;

-- 77827 L99 Mousse Herbal Ess Rizo 200G
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7500435169035' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7500435169035';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Mousse Herbal Ess Rizo 200G',
      'sku', 'FC-35169035',
      'codigo_barras', '7500435169035',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Mousse Herbal Ess Rizo 200G — Ticket 77827',
      'costo', 73.76,
      'precio', 99.58,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-77827-99',
      NULL,
      73.76,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7500435169035', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-77827-99', NULL, 73.76, 'Bodega F-42 Ejidos del Moral', null
    );
  end if;
end $$;

-- 77827 L100 Sh Hash Anti Comezon 375Ml
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7500435168991' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7500435168991';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Sh Hash Anti Comezon 375Ml',
      'sku', 'FC-35168991',
      'codigo_barras', '7500435168991',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Sh Hash Anti Comezon 375Ml — Ticket 77827',
      'costo', 32.34,
      'precio', 43.66,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-77827-100',
      NULL,
      32.34,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7500435168991', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-77827-100', NULL, 32.34, 'Bodega F-42 Ejidos del Moral', null
    );
  end if;
end $$;

-- 77827 L101 Sh Hash Anti Comezon 375Ml
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7500435231237' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7500435231237';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Sh Hash Anti Comezon 375Ml',
      'sku', 'FC-35231237',
      'codigo_barras', '7500435231237',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Sh Hash Anti Comezon 375Ml — Ticket 77827',
      'costo', 36.73,
      'precio', 49.59,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-77827-101',
      NULL,
      36.73,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7500435231237', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-77827-101', NULL, 36.73, 'Bodega F-42 Ejidos del Moral', null
    );
  end if;
end $$;

-- 77827 L102 Cera Mod Ego Met 25 G
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7506192504539' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7506192504539';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Cera Mod Ego Met 25 G',
      'sku', 'FC-92504539',
      'codigo_barras', '7506192504539',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Cera Mod Ego Met 25 G — Ticket 77827',
      'costo', 36.73,
      'precio', 49.59,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-77827-102',
      NULL,
      36.73,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7506192504539', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-77827-102', NULL, 36.73, 'Bodega F-42 Ejidos del Moral', null
    );
  end if;
end $$;

-- 77827 L103 Cera Gel Moco De Gorila Citr 100G
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7501438312374' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7501438312374';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Cera Gel Moco De Gorila Citr 100G',
      'sku', 'FC-38312374',
      'codigo_barras', '7501438312374',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Cera Gel Moco De Gorila Citr 100G — Ticket 77827',
      'costo', 24.91,
      'precio', 33.63,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-77827-103',
      NULL,
      24.91,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7501438312374', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-77827-103', NULL, 24.91, 'Bodega F-42 Ejidos del Moral', null
    );
  end if;
end $$;

-- 77827 L104 Sh H&S Anti Comezon 180 Ml
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7500435231244' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7500435231244';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Sh H&S Anti Comezon 180 Ml',
      'sku', 'FC-35231244',
      'codigo_barras', '7500435231244',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Sh H&S Anti Comezon 180 Ml — Ticket 77827',
      'costo', 18.39,
      'precio', 24.83,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-77827-104',
      NULL,
      18.39,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7500435231244', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-77827-104', NULL, 18.39, 'Bodega F-42 Ejidos del Moral', null
    );
  end if;
end $$;

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

-- 77827 L106 Gel Ego Magnetic Fij-Alta 200 Ml
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7506192503558' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7506192503558';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Gel Ego Magnetic Fij-Alta 200 Ml',
      'sku', 'FC-92503558',
      'codigo_barras', '7506192503558',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Gel Ego Magnetic Fij-Alta 200 Ml — Ticket 77827',
      'costo', 56.61,
      'precio', 76.43,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-77827-106',
      NULL,
      56.61,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7506192503558', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-77827-106', NULL, 56.61, 'Bodega F-42 Ejidos del Moral', null
    );
  end if;
end $$;

-- 77827 L107 Gel X-Extreme Titan 250G
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7501199425580' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7501199425580';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Gel X-Extreme Titan 250G',
      'sku', 'FC-99425580',
      'codigo_barras', '7501199425580',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Gel X-Extreme Titan 250G — Ticket 77827',
      'costo', 7.37,
      'precio', 9.95,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      2,
      'TK-77827-107',
      NULL,
      7.37,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7501199425580', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 2, 'TK-77827-107', NULL, 7.37, 'Bodega F-42 Ejidos del Moral', null
    );
  end if;
end $$;

-- 77827 L108 Gel Moco De Gorila Punk 80 G
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7501199428024' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7501199428024';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Gel Moco De Gorila Punk 80 G',
      'sku', 'FC-99428024',
      'codigo_barras', '7501199428024',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Gel Moco De Gorila Punk 80 G — Ticket 77827',
      'costo', 7.37,
      'precio', 9.95,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      2,
      'TK-77827-108',
      NULL,
      7.37,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7501199428024', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 2, 'TK-77827-108', NULL, 7.37, 'Bodega F-42 Ejidos del Moral', null
    );
  end if;
end $$;

-- 77827 L109 Sh Caprice Sp Biotina Fza 200Ml
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7509546073040' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7509546073040';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Sh Caprice Sp Biotina Fza 200Ml',
      'sku', 'FC-46073040',
      'codigo_barras', '7509546073040',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Sh Caprice Sp Biotina Fza 200Ml — Ticket 77827',
      'costo', 45.26,
      'precio', 61.11,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-77827-109',
      NULL,
      45.26,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7509546073040', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-77827-109', NULL, 45.26, 'Bodega F-42 Ejidos del Moral', null
    );
  end if;
end $$;

-- 77827 L110 Sh Caprice Sp Acti Ceramida 200Ml
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7509546073033' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7509546073033';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Sh Caprice Sp Acti Ceramida 200Ml',
      'sku', 'FC-46073033',
      'codigo_barras', '7509546073033',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Sh Caprice Sp Acti Ceramida 200Ml — Ticket 77827',
      'costo', 45.26,
      'precio', 61.11,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-77827-110',
      NULL,
      45.26,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7509546073033', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-77827-110', NULL, 45.26, 'Bodega F-42 Ejidos del Moral', null
    );
  end if;
end $$;

-- 77827 L111 Silica Shine Sily Oleo Argan 120Ml
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7502254073302' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7502254073302';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Silica Shine Sily Oleo Argan 120Ml',
      'sku', 'FC-54073302',
      'codigo_barras', '7502254073302',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Silica Shine Sily Oleo Argan 120Ml — Ticket 77827',
      'costo', 44.76,
      'precio', 60.43,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-77827-111',
      NULL,
      44.76,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7502254073302', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-77827-111', NULL, 44.76, 'Bodega F-42 Ejidos del Moral', null
    );
  end if;
end $$;

-- 77827 L112 Silica Shine Sily 3/1 Mora 120Ml
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7502224511711' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7502224511711';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Silica Shine Sily 3/1 Mora 120Ml',
      'sku', 'FC-24511711',
      'codigo_barras', '7502224511711',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Silica Shine Sily 3/1 Mora 120Ml — Ticket 77827',
      'costo', 45.64,
      'precio', 61.62,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-77827-112',
      NULL,
      45.64,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7502224511711', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-77827-112', NULL, 45.64, 'Bodega F-42 Ejidos del Moral', null
    );
  end if;
end $$;

-- 77827 L113 Silica Shine Sily 3/1 Naran 12Cml
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7502224511636' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7502224511636';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Silica Shine Sily 3/1 Naran 12Cml',
      'sku', 'FC-24511636',
      'codigo_barras', '7502224511636',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Silica Shine Sily 3/1 Naran 12Cml — Ticket 77827',
      'costo', 50.51,
      'precio', 68.19,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-77827-113',
      NULL,
      50.51,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7502224511636', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-77827-113', NULL, 50.51, 'Bodega F-42 Ejidos del Moral', null
    );
  end if;
end $$;

-- 77827 L114 Brill Palmol Lio 115M
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '75001865' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '75001865';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Brill Palmol Lio 115M',
      'sku', 'FC-75001865',
      'codigo_barras', '75001865',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Brill Palmol Lio 115M — Ticket 77827',
      'costo', 17.54,
      'precio', 23.68,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-77827-114',
      NULL,
      17.54,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('75001865', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-77827-114', NULL, 17.54, 'Bodega F-42 Ejidos del Moral', null
    );
  end if;
end $$;

-- 77827 L115 Mousse Caprice Volum-Cirl 200 G
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7509546655055' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7509546655055';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Mousse Caprice Volum-Cirl 200 G',
      'sku', 'FC-46655055',
      'codigo_barras', '7509546655055',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Mousse Caprice Volum-Cirl 200 G — Ticket 77827',
      'costo', 20.02,
      'precio', 27.03,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-77827-115',
      NULL,
      20.02,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7509546655055', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-77827-115', NULL, 20.02, 'Bodega F-42 Ejidos del Moral', null
    );
  end if;
end $$;

-- 77827 L116 Gel Ego Fresh C-Cas Fij-Alt 200Ml
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7506306247468' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7506306247468';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Gel Ego Fresh C-Cas Fij-Alt 200Ml',
      'sku', 'FC-06247468',
      'codigo_barras', '7506306247468',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Gel Ego Fresh C-Cas Fij-Alt 200Ml — Ticket 77827',
      'costo', 62.04,
      'precio', 83.76,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-77827-116',
      NULL,
      62.04,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7506306247468', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-77827-116', NULL, 62.04, 'Bodega F-42 Ejidos del Moral', null
    );
  end if;
end $$;

-- 77827 L117 Gel Ego For Men Attraction 200 Ml
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7506192506601' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7506192506601';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Gel Ego For Men Attraction 200 Ml',
      'sku', 'FC-92506601',
      'codigo_barras', '7506192506601',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Gel Ego For Men Attraction 200 Ml — Ticket 77827',
      'costo', 17.98,
      'precio', 24.28,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-77827-117',
      NULL,
      17.98,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7506192506601', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-77827-117', NULL, 17.98, 'Bodega F-42 Ejidos del Moral', null
    );
  end if;
end $$;

-- 77827 L118 Cep Dent Oral-B Indicat35Sve
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7501086494262' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7501086494262';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Cep Dent Oral-B Indicat35Sve',
      'sku', 'FC-86494262',
      'codigo_barras', '7501086494262',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Cep Dent Oral-B Indicat35Sve — Ticket 77827',
      'costo', 8.6,
      'precio', 11.61,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      2,
      'TK-77827-118',
      NULL,
      8.6,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7501086494262', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 2, 'TK-77827-118', NULL, 8.6, 'Bodega F-42 Ejidos del Moral', null
    );
  end if;
end $$;

-- 77827 L119 Cera Ego Firme Matte 25 G
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7506192506045' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7506192506045';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Cera Ego Firme Matte 25 G',
      'sku', 'FC-92506045',
      'codigo_barras', '7506192506045',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Cera Ego Firme Matte 25 G — Ticket 77827',
      'costo', 17.2,
      'precio', 23.22,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-77827-119',
      NULL,
      17.2,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7506192506045', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-77827-119', NULL, 17.2, 'Bodega F-42 Ejidos del Moral', null
    );
  end if;
end $$;

-- 77827 L120 Acetona Jaloma 60 Ml
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '759684431050' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '759684431050';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Acetona Jaloma 60 Ml',
      'sku', 'FC-84431050',
      'codigo_barras', '759684431050',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Acetona Jaloma 60 Ml — Ticket 77827',
      'costo', 19.77,
      'precio', 26.69,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-77827-120',
      NULL,
      19.77,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('759684431050', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-77827-120', NULL, 19.77, 'Bodega F-42 Ejidos del Moral', null
    );
  end if;
end $$;

-- 77827 L121 Silkhair Quita Esmalte Coco 100 Ml
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7502245720567' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7502245720567';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Silkhair Quita Esmalte Coco 100 Ml',
      'sku', 'FC-45720567',
      'codigo_barras', '7502245720567',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Silkhair Quita Esmalte Coco 100 Ml — Ticket 77827',
      'costo', 2.75,
      'precio', 3.72,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-77827-121',
      NULL,
      2.75,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7502245720567', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-77827-121', NULL, 2.75, 'Bodega F-42 Ejidos del Moral', null
    );
  end if;
end $$;

-- 77827 L122 Acetona Jaloma 120 Ml
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '759684437151' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '759684437151';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Acetona Jaloma 120 Ml',
      'sku', 'FC-84437151',
      'codigo_barras', '759684437151',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Acetona Jaloma 120 Ml — Ticket 77827',
      'costo', 2.75,
      'precio', 3.72,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-77827-122',
      NULL,
      2.75,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('759684437151', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-77827-122', NULL, 2.75, 'Bodega F-42 Ejidos del Moral', null
    );
  end if;
end $$;

-- 77827 L123 Protec Tocmx2.75M 1 Pza Venda De Yeso C12
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7501048640775' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7501048640775';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Protec Tocmx2.75M 1 Pza Venda De Yeso C12',
      'sku', 'FC-48640775',
      'codigo_barras', '7501048640775',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Protec Tocmx2.75M 1 Pza Venda De Yeso C12 — Ticket 77827',
      'costo', 2.75,
      'precio', 3.72,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-77827-123',
      NULL,
      2.75,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7501048640775', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-77827-123', NULL, 2.75, 'Bodega F-42 Ejidos del Moral', null
    );
  end if;
end $$;

-- 77827 L124 Protec 15Cmx2.75M 1 Pza Venda De Yeso C12
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7501048640799' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7501048640799';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Protec 15Cmx2.75M 1 Pza Venda De Yeso C12',
      'sku', 'FC-48640799',
      'codigo_barras', '7501048640799',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Protec 15Cmx2.75M 1 Pza Venda De Yeso C12 — Ticket 77827',
      'costo', 2.75,
      'precio', 3.72,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-77827-124',
      NULL,
      2.75,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7501048640799', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-77827-124', NULL, 2.75, 'Bodega F-42 Ejidos del Moral', null
    );
  end if;
end $$;

-- 77827 L125 Protec 20Cmx2.75M 1 Pza Venda De Yeso
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7501046640629' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7501046640629';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Protec 20Cmx2.75M 1 Pza Venda De Yeso',
      'sku', 'FC-46640629',
      'codigo_barras', '7501046640629',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Protec 20Cmx2.75M 1 Pza Venda De Yeso — Ticket 77827',
      'costo', 61.02,
      'precio', 82.38,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-77827-125',
      NULL,
      61.02,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7501046640629', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-77827-125', NULL, 61.02, 'Bodega F-42 Ejidos del Moral', null
    );
  end if;
end $$;

-- 77827 L126 Protec 5Cmx2.75M 1 Pza Venda De Yeso C12 Pz
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7501048640751' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7501048640751';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Protec 5Cmx2.75M 1 Pza Venda De Yeso C12 Pz',
      'sku', 'FC-48640751',
      'codigo_barras', '7501048640751',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Protec 5Cmx2.75M 1 Pza Venda De Yeso C12 Pz — Ticket 77827',
      'costo', 147.15,
      'precio', 198.66,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-77827-126',
      NULL,
      147.15,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7501048640751', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-77827-126', NULL, 147.15, 'Bodega F-42 Ejidos del Moral', null
    );
  end if;
end $$;

-- 77827 L127 Ternura Flor-Balon 18 Pzs Chupon Con Miel
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7501026462078' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7501026462078';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Ternura Flor-Balon 18 Pzs Chupon Con Miel',
      'sku', 'FC-26462078',
      'codigo_barras', '7501026462078',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Ternura Flor-Balon 18 Pzs Chupon Con Miel — Ticket 77827',
      'costo', 47.79,
      'precio', 64.52,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-77827-127',
      NULL,
      47.79,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7501026462078', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-77827-127', NULL, 47.79, 'Bodega F-42 Ejidos del Moral', null
    );
  end if;
end $$;

-- 77827 L128 Cra Nivea Sdatarr Giga 400Ml
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7501054500216' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7501054500216';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Cra Nivea Sdatarr Giga 400Ml',
      'sku', 'FC-54500216',
      'codigo_barras', '7501054500216',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Cra Nivea Sdatarr Giga 400Ml — Ticket 77827',
      'costo', 42.25,
      'precio', 57.04,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-77827-128',
      NULL,
      42.25,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7501054500216', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-77827-128', NULL, 42.25, 'Bodega F-42 Ejidos del Moral', null
    );
  end if;
end $$;

-- 77827 L129 Desod Ego Force 24H R-On 45Ml Dic26
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '75064938' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '75064938';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Desod Ego Force 24H R-On 45Ml Dic26',
      'sku', 'FC-75064938',
      'codigo_barras', '75064938',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Desod Ego Force 24H R-On 45Ml Dic26 — Ticket 77827',
      'costo', 42.24,
      'precio', 57.03,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      2,
      'TK-77827-129',
      NULL,
      42.24,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('75064938', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 2, 'TK-77827-129', NULL, 42.24, 'Bodega F-42 Ejidos del Moral', null
    );
  end if;
end $$;

-- 77827 L130 Cra Hinds Liq Agave Azul 400Ml
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '810120501673' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '810120501673';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Cra Hinds Liq Agave Azul 400Ml',
      'sku', 'FC-20501673',
      'codigo_barras', '810120501673',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Cra Hinds Liq Agave Azul 400Ml — Ticket 77827',
      'costo', 59.81,
      'precio', 80.75,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-77827-130',
      NULL,
      59.81,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('810120501673', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-77827-130', NULL, 59.81, 'Bodega F-42 Ejidos del Moral', null
    );
  end if;
end $$;

-- 77827 L131 Cra Nivea B Sofmilk Sec400Ml
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '4005808802838' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '4005808802838';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Cra Nivea B Sofmilk Sec400Ml',
      'sku', 'FC-08802838',
      'codigo_barras', '4005808802838',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Cra Nivea B Sofmilk Sec400Ml — Ticket 77827',
      'costo', 43.63,
      'precio', 58.91,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-77827-131',
      NULL,
      43.63,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('4005808802838', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-77827-131', NULL, 43.63, 'Bodega F-42 Ejidos del Moral', null
    );
  end if;
end $$;

-- 77827 L133 Cra Grisi Conchnac P/Manos 80 Ml
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '037836040450' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '037836040450';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Cra Grisi Conchnac P/Manos 80 Ml',
      'sku', 'FC-36040450',
      'codigo_barras', '037836040450',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Cra Grisi Conchnac P/Manos 80 Ml — Ticket 77827',
      'costo', 86.77,
      'precio', 117.14,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-77827-133',
      NULL,
      86.77,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('037836040450', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-77827-133', NULL, 86.77, 'Bodega F-42 Ejidos del Moral', null
    );
  end if;
end $$;

-- 77827 L134 Cra Clarant B3 Nml/Gsa 100G
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7501056330309' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7501056330309';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Cra Clarant B3 Nml/Gsa 100G',
      'sku', 'FC-56330309',
      'codigo_barras', '7501056330309',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Cra Clarant B3 Nml/Gsa 100G — Ticket 77827',
      'costo', 105.35,
      'precio', 142.23,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-77827-134',
      NULL,
      105.35,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7501056330309', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-77827-134', NULL, 105.35, 'Bodega F-42 Ejidos del Moral', null
    );
  end if;
end $$;

-- 77827 L135 Cra Nivea Cuidada Clar-Nat 200Ml
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '42270027' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '42270027';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Cra Nivea Cuidada Clar-Nat 200Ml',
      'sku', 'FC-42270027',
      'codigo_barras', '42270027',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Cra Nivea Cuidada Clar-Nat 200Ml — Ticket 77827',
      'costo', 85.87,
      'precio', 115.93,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-77827-135',
      NULL,
      85.87,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('42270027', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-77827-135', NULL, 85.87, 'Bodega F-42 Ejidos del Moral', null
    );
  end if;
end $$;

-- 77827 L136 Gel Niv Fac Ref Hidra Hyalu 200Ml
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '4005900942760' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '4005900942760';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Gel Niv Fac Ref Hidra Hyalu 200Ml',
      'sku', 'FC-00942760',
      'codigo_barras', '4005900942760',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Gel Niv Fac Ref Hidra Hyalu 200Ml — Ticket 77827',
      'costo', 62.25,
      'precio', 84.04,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-77827-136',
      NULL,
      62.25,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('4005900942760', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-77827-136', NULL, 62.25, 'Bodega F-42 Ejidos del Moral', null
    );
  end if;
end $$;

-- 77827 L137 Cra Corp Niveamilk 400Ml+Cra100Ml
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7501054558682' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7501054558682';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Cra Corp Niveamilk 400Ml+Cra100Ml',
      'sku', 'FC-54558682',
      'codigo_barras', '7501054558682',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Cra Corp Niveamilk 400Ml+Cra100Ml — Ticket 77827',
      'costo', 22.3,
      'precio', 30.11,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-77827-137',
      NULL,
      22.3,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7501054558682', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-77827-137', NULL, 22.3, 'Bodega F-42 Ejidos del Moral', null
    );
  end if;
end $$;

-- 77827 L138 Cra Teatrical Cel-Ma Nutrit 400Ml
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '650240030963' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '650240030963';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Cra Teatrical Cel-Ma Nutrit 400Ml',
      'sku', 'FC-40030963',
      'codigo_barras', '650240030963',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Cra Teatrical Cel-Ma Nutrit 400Ml — Ticket 77827',
      'costo', 34.41,
      'precio', 46.46,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-77827-138',
      NULL,
      34.41,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('650240030963', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-77827-138', NULL, 34.41, 'Bodega F-42 Ejidos del Moral', null
    );
  end if;
end $$;

-- 77827 L139 Chupon Ternura Ortodontic Miel C3
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7501026462061' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7501026462061';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Chupon Ternura Ortodontic Miel C3',
      'sku', 'FC-26462061',
      'codigo_barras', '7501026462061',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Chupon Ternura Ortodontic Miel C3 — Ticket 77827',
      'costo', 74.31,
      'precio', 100.32,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-77827-139',
      NULL,
      74.31,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7501026462061', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-77827-139', NULL, 74.31, 'Bodega F-42 Ejidos del Moral', null
    );
  end if;
end $$;

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

-- 77827 L141 Sh Grisi Ricitos Oro Biopure 250Ml
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '037836032776' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '037836032776';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Sh Grisi Ricitos Oro Biopure 250Ml',
      'sku', 'FC-36032776',
      'codigo_barras', '037836032776',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Sh Grisi Ricitos Oro Biopure 250Ml — Ticket 77827',
      'costo', 29.96,
      'precio', 40.45,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-77827-141',
      NULL,
      29.96,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('037836032776', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-77827-141', NULL, 29.96, 'Bodega F-42 Ejidos del Moral', null
    );
  end if;
end $$;

-- 77827 L142 Jbn Johnson'S Baby Antes/Dor 75 G
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7501007502441' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7501007502441';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Jbn Johnson''S Baby Antes/Dor 75 G',
      'sku', 'FC-07502441',
      'codigo_barras', '7501007502441',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Jbn Johnson''S Baby Antes/Dor 75 G — Ticket 77827',
      'costo', 20.65,
      'precio', 27.88,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-77827-142',
      NULL,
      20.65,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7501007502441', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-77827-142', NULL, 20.65, 'Bodega F-42 Ejidos del Moral', null
    );
  end if;
end $$;

-- 77827 L143 Jbn Palmol N-Bal Corp Baby0% 90G
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7509546655079' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7509546655079';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Jbn Palmol N-Bal Corp Baby0% 90G',
      'sku', 'FC-46655079',
      'codigo_barras', '7509546655079',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Jbn Palmol N-Bal Corp Baby0% 90G — Ticket 77827',
      'costo', 19.95,
      'precio', 26.94,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      2,
      'TK-77827-143',
      NULL,
      19.95,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7509546655079', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 2, 'TK-77827-143', NULL, 19.95, 'Bodega F-42 Ejidos del Moral', null
    );
  end if;
end $$;

-- 77827 L144 Tco Nuvel Protec Pura Para Bebe200G
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7501082790016' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7501082790016';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Tco Nuvel Protec Pura Para Bebe200G',
      'sku', 'FC-82790016',
      'codigo_barras', '7501082790016',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Tco Nuvel Protec Pura Para Bebe200G — Ticket 77827',
      'costo', 39.9,
      'precio', 53.87,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-77827-144',
      NULL,
      39.9,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7501082790016', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-77827-144', NULL, 39.9, 'Bodega F-42 Ejidos del Moral', null
    );
  end if;
end $$;

-- 77827 L145 Cra Hinds Hidr-Extr Almendras 500Ml
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '037836041402' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '037836041402';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Cra Hinds Hidr-Extr Almendras 500Ml',
      'sku', 'FC-36041402',
      'codigo_barras', '037836041402',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Cra Hinds Hidr-Extr Almendras 500Ml — Ticket 77827',
      'costo', 31.59,
      'precio', 42.65,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-77827-145',
      NULL,
      31.59,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('037836041402', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-77827-145', NULL, 31.59, 'Bodega F-42 Ejidos del Moral', null
    );
  end if;
end $$;

-- 77827 L146 Cra Lubriderm Thint Psec120Ml
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7501007528939' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7501007528939';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Cra Lubriderm Thint Psec120Ml',
      'sku', 'FC-07528939',
      'codigo_barras', '7501007528939',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Cra Lubriderm Thint Psec120Ml — Ticket 77827',
      'costo', 49.97,
      'precio', 67.46,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-77827-146',
      NULL,
      49.97,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7501007528939', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-77827-146', NULL, 49.97, 'Bodega F-42 Ejidos del Moral', null
    );
  end if;
end $$;

-- 77827 L147 Cra Lubriderm P/Normal 120Ml
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7702031244486' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7702031244486';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Cra Lubriderm P/Normal 120Ml',
      'sku', 'FC-31244486',
      'codigo_barras', '7702031244486',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Cra Lubriderm P/Normal 120Ml — Ticket 77827',
      'costo', 43.59,
      'precio', 58.85,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-77827-147',
      NULL,
      43.59,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7702031244486', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-77827-147', NULL, 43.59, 'Bodega F-42 Ejidos del Moral', null
    );
  end if;
end $$;

-- 77827 L149 Sh Mennen Zero% Sve 400Ml
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7509546074504' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7509546074504';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Sh Mennen Zero% Sve 400Ml',
      'sku', 'FC-46074504',
      'codigo_barras', '7509546074504',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Sh Mennen Zero% Sve 400Ml — Ticket 77827',
      'costo', 66.93,
      'precio', 90.36,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-77827-149',
      NULL,
      66.93,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7509546074504', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-77827-149', NULL, 66.93, 'Bodega F-42 Ejidos del Moral', null
    );
  end if;
end $$;

-- 77827 L150 Sh Ricitos Oro Agua De Coco 250Ml
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '037836033735' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '037836033735';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Sh Ricitos Oro Agua De Coco 250Ml',
      'sku', 'FC-36033735',
      'codigo_barras', '037836033735',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Sh Ricitos Oro Agua De Coco 250Ml — Ticket 77827',
      'costo', 66.93,
      'precio', 90.36,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-77827-150',
      NULL,
      66.93,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('037836033735', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-77827-150', NULL, 66.93, 'Bodega F-42 Ejidos del Moral', null
    );
  end if;
end $$;

-- 77827 L151 Sh Mennen Lavan-Extrac Aven 200Ml
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7509546650708' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7509546650708';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Sh Mennen Lavan-Extrac Aven 200Ml',
      'sku', 'FC-46650708',
      'codigo_barras', '7509546650708',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Sh Mennen Lavan-Extrac Aven 200Ml — Ticket 77827',
      'costo', 53.99,
      'precio', 72.89,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-77827-151',
      NULL,
      53.99,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7509546650708', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-77827-151', NULL, 53.99, 'Bodega F-42 Ejidos del Moral', null
    );
  end if;
end $$;

-- 77827 L152 Sh Grisi Rici Oro Miel 250Ml
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7501022133286' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7501022133286';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Sh Grisi Rici Oro Miel 250Ml',
      'sku', 'FC-22133286',
      'codigo_barras', '7501022133286',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Sh Grisi Rici Oro Miel 250Ml — Ticket 77827',
      'costo', 70.91,
      'precio', 95.73,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-77827-152',
      NULL,
      70.91,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7501022133286', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-77827-152', NULL, 70.91, 'Bodega F-42 Ejidos del Moral', null
    );
  end if;
end $$;

-- 77827 L153 Cep Dent Accion Mayo Alcan Somed
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7501086472048' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7501086472048';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Cep Dent Accion Mayo Alcan Somed',
      'sku', 'FC-86472048',
      'codigo_barras', '7501086472048',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Cep Dent Accion Mayo Alcan Somed — Ticket 77827',
      'costo', 35.45,
      'precio', 47.86,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      2,
      'TK-77827-153',
      NULL,
      35.45,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7501086472048', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 2, 'TK-77827-153', NULL, 35.45, 'Bodega F-42 Ejidos del Moral', null
    );
  end if;
end $$;

-- 77827 L154 Sensodyne Protec Complet + Acc Lim Efec 90G
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7896009498091' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7896009498091';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Sensodyne Protec Complet + Acc Lim Efec 90G',
      'sku', 'FC-09498091',
      'codigo_barras', '7896009498091',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Sensodyne Protec Complet + Acc Lim Efec 90G — Ticket 77827',
      'costo', 48.58,
      'precio', 65.59,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-77827-154',
      NULL,
      48.58,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7896009498091', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-77827-154', NULL, 48.58, 'Bodega F-42 Ejidos del Moral', null
    );
  end if;
end $$;

-- 77827 L155 Cep Dent Oral-B 3Dw Advant Med2X1
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7506195129166' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7506195129166';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Cep Dent Oral-B 3Dw Advant Med2X1',
      'sku', 'FC-95129166',
      'codigo_barras', '7506195129166',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Cep Dent Oral-B 3Dw Advant Med2X1 — Ticket 77827',
      'costo', 70.91,
      'precio', 95.73,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-77827-155',
      NULL,
      70.91,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7506195129166', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-77827-155', NULL, 70.91, 'Bodega F-42 Ejidos del Moral', null
    );
  end if;
end $$;

-- 77827 L156 Cra Nivea Cuidado Int P/Mano 75Ml
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '42417644' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '42417644';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Cra Nivea Cuidado Int P/Mano 75Ml',
      'sku', 'FC-42417644',
      'codigo_barras', '42417644',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Cra Nivea Cuidado Int P/Mano 75Ml — Ticket 77827',
      'costo', 30.36,
      'precio', 40.99,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-77827-156',
      NULL,
      30.36,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('42417644', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-77827-156', NULL, 30.36, 'Bodega F-42 Ejidos del Moral', null
    );
  end if;
end $$;

-- 77827 L157 Cd Sensodyne Original
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7896009419324' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7896009419324';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Cd Sensodyne Original',
      'sku', 'FC-09419324',
      'codigo_barras', '7896009419324',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Cd Sensodyne Original — Ticket 77827',
      'costo', 26.38,
      'precio', 35.62,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-77827-157',
      NULL,
      26.38,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7896009419324', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-77827-157', NULL, 26.38, 'Bodega F-42 Ejidos del Moral', null
    );
  end if;
end $$;

-- 77827 L158 Cra Teatrical Lanol/Ros 52Gr
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '650240013898' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '650240013898';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Cra Teatrical Lanol/Ros 52Gr',
      'sku', 'FC-40013898',
      'codigo_barras', '650240013898',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Cra Teatrical Lanol/Ros 52Gr — Ticket 77827',
      'costo', 26.3,
      'precio', 35.51,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-77827-158',
      NULL,
      26.3,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('650240013898', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-77827-158', NULL, 26.3, 'Bodega F-42 Ejidos del Moral', null
    );
  end if;
end $$;

-- 77827 L159 Cra Corp Niv Soft M P/Seca 100Ml
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7501054549819' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7501054549819';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Cra Corp Niv Soft M P/Seca 100Ml',
      'sku', 'FC-54549819',
      'codigo_barras', '7501054549819',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Cra Corp Niv Soft M P/Seca 100Ml — Ticket 77827',
      'costo', 26.3,
      'precio', 35.51,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-77827-159',
      NULL,
      26.3,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7501054549819', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-77827-159', NULL, 26.3, 'Bodega F-42 Ejidos del Moral', null
    );
  end if;
end $$;

-- 77827 L160 Tas San Kotex Ant Flujo Abundante S/A 10Pz
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7501017360604' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7501017360604';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Tas San Kotex Ant Flujo Abundante S/A 10Pz',
      'sku', 'FC-17360604',
      'codigo_barras', '7501017360604',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Tas San Kotex Ant Flujo Abundante S/A 10Pz — Ticket 77827',
      'costo', 10.4,
      'precio', 14.04,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      2,
      'TK-77827-160',
      NULL,
      10.4,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7501017360604', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 2, 'TK-77827-160', NULL, 10.4, 'Bodega F-42 Ejidos del Moral', null
    );
  end if;
end $$;

-- 77827 L161 Sh Mennen Miel-Mza Sve 200Ml
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7509546072050' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7509546072050';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Sh Mennen Miel-Mza Sve 200Ml',
      'sku', 'FC-46072050',
      'codigo_barras', '7509546072050',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Sh Mennen Miel-Mza Sve 200Ml — Ticket 77827',
      'costo', 20.8,
      'precio', 28.08,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-77827-161',
      NULL,
      20.8,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7509546072050', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-77827-161', NULL, 20.8, 'Bodega F-42 Ejidos del Moral', null
    );
  end if;
end $$;

-- 77827 L162 Jbn Ricitos D Oro Neutro 90 G
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7501022150221' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7501022150221';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Jbn Ricitos D Oro Neutro 90 G',
      'sku', 'FC-22150221',
      'codigo_barras', '7501022150221',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Jbn Ricitos D Oro Neutro 90 G — Ticket 77827',
      'costo', 59.36,
      'precio', 80.14,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-77827-162',
      NULL,
      59.36,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7501022150221', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-77827-162', NULL, 59.36, 'Bodega F-42 Ejidos del Moral', null
    );
  end if;
end $$;

-- 77827 L163 Cra Grisi Aloe Vera P/Manos 80 Mln
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '810120501765' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '810120501765';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Cra Grisi Aloe Vera P/Manos 80 Mln',
      'sku', 'FC-20501765',
      'codigo_barras', '810120501765',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Cra Grisi Aloe Vera P/Manos 80 Mln — Ticket 77827',
      'costo', 26.48,
      'precio', 35.75,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-77827-163',
      NULL,
      26.48,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('810120501765', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-77827-163', NULL, 26.48, 'Bodega F-42 Ejidos del Moral', null
    );
  end if;
end $$;

-- 77827 L164 Cra S Ponds Humectante 100G
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7501056326142' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7501056326142';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Cra S Ponds Humectante 100G',
      'sku', 'FC-56326142',
      'codigo_barras', '7501056326142',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Cra S Ponds Humectante 100G — Ticket 77827',
      'costo', 26.48,
      'precio', 35.75,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-77827-164',
      NULL,
      26.48,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7501056326142', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-77827-164', NULL, 26.48, 'Bodega F-42 Ejidos del Moral', null
    );
  end if;
end $$;

-- 77827 L165 Protec Tensolastic Plus 10Cmx5M Venda Elast
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7501048691005' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7501048691005';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Protec Tensolastic Plus 10Cmx5M Venda Elast',
      'sku', 'FC-48691005',
      'codigo_barras', '7501048691005',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Protec Tensolastic Plus 10Cmx5M Venda Elast — Ticket 77827',
      'costo', 20.02,
      'precio', 27.03,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-77827-165',
      NULL,
      20.02,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7501048691005', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-77827-165', NULL, 20.02, 'Bodega F-42 Ejidos del Moral', null
    );
  end if;
end $$;

-- 77827 L166 Enj Buc List Anticari-Al 250Ml
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7702031976394' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7702031976394';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Enj Buc List Anticari-Al 250Ml',
      'sku', 'FC-31976394',
      'codigo_barras', '7702031976394',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Enj Buc List Anticari-Al 250Ml — Ticket 77827',
      'costo', 30.02,
      'precio', 40.53,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-77827-166',
      NULL,
      30.02,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7702031976394', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-77827-166', NULL, 30.02, 'Bodega F-42 Ejidos del Moral', null
    );
  end if;
end $$;

-- 77827 L167 Tas Sanit Kotex Nat Flex Noct C/5
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7501943427754' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7501943427754';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Tas Sanit Kotex Nat Flex Noct C/5',
      'sku', 'FC-43427754',
      'codigo_barras', '7501943427754',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Tas Sanit Kotex Nat Flex Noct C/5 — Ticket 77827',
      'costo', 31.77,
      'precio', 42.89,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      2,
      'TK-77827-167',
      NULL,
      31.77,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7501943427754', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 2, 'TK-77827-167', NULL, 31.77, 'Bodega F-42 Ejidos del Moral', null
    );
  end if;
end $$;

-- 77827 L169 Enj Buc List Care Zero Mta 250Ml
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7702031887928' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7702031887928';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Enj Buc List Care Zero Mta 250Ml',
      'sku', 'FC-31887928',
      'codigo_barras', '7702031887928',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Enj Buc List Care Zero Mta 250Ml — Ticket 77827',
      'costo', 26.2,
      'precio', 35.38,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-77827-169',
      NULL,
      26.2,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7702031887928', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-77827-169', NULL, 26.2, 'Bodega F-42 Ejidos del Moral', null
    );
  end if;
end $$;

-- 77827 L170 Cra Nivea Sda Tarro 100 Ml
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7501054503095' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7501054503095';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Cra Nivea Sda Tarro 100 Ml',
      'sku', 'FC-54503095',
      'codigo_barras', '7501054503095',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Cra Nivea Sda Tarro 100 Ml — Ticket 77827',
      'costo', 96.63,
      'precio', 130.46,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-77827-170',
      NULL,
      96.63,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7501054503095', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-77827-170', NULL, 96.63, 'Bodega F-42 Ejidos del Moral', null
    );
  end if;
end $$;

-- 77827 L171 Tas Hum Th Bebin Super C/80
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '619585800198' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '619585800198';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Tas Hum Th Bebin Super C/80',
      'sku', 'FC-85800198',
      'codigo_barras', '619585800198',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Tas Hum Th Bebin Super C/80 — Ticket 77827',
      'costo', 36.3,
      'precio', 49.01,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-77827-171',
      NULL,
      36.3,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('619585800198', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-77827-171', NULL, 36.3, 'Bodega F-42 Ejidos del Moral', null
    );
  end if;
end $$;

-- 77827 L172 Cep Dent Clinic Adulto Med 40 C12
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7501072629012' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7501072629012';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Cep Dent Clinic Adulto Med 40 C12',
      'sku', 'FC-72629012',
      'codigo_barras', '7501072629012',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Cep Dent Clinic Adulto Med 40 C12 — Ticket 77827',
      'costo', 36.3,
      'precio', 49.01,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-77827-172',
      NULL,
      36.3,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7501072629012', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-77827-172', NULL, 36.3, 'Bodega F-42 Ejidos del Moral', null
    );
  end if;
end $$;

-- 77827 L173 Enj Buc List Zero Mta Sve 250Ml
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7891010974329' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7891010974329';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Enj Buc List Zero Mta Sve 250Ml',
      'sku', 'FC-10974329',
      'codigo_barras', '7891010974329',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Enj Buc List Zero Mta Sve 250Ml — Ticket 77827',
      'costo', 12.97,
      'precio', 17.51,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-77827-173',
      NULL,
      12.97,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7891010974329', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-77827-173', NULL, 12.97, 'Bodega F-42 Ejidos del Moral', null
    );
  end if;
end $$;

-- 77827 L174 Nivea 75Ml Cra P/Manos 3En1 Ant-Arrugas
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '4005900701992' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '4005900701992';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Nivea 75Ml Cra P/Manos 3En1 Ant-Arrugas',
      'sku', 'FC-00701992',
      'codigo_barras', '4005900701992',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Nivea 75Ml Cra P/Manos 3En1 Ant-Arrugas — Ticket 77827',
      'costo', 12.97,
      'precio', 17.51,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-77827-174',
      NULL,
      12.97,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('4005900701992', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-77827-174', NULL, 12.97, 'Bodega F-42 Ejidos del Moral', null
    );
  end if;
end $$;

-- 77827 L175 Jbn Mennen Baby Magic Lavan 90 G
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7509546655727' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7509546655727';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Jbn Mennen Baby Magic Lavan 90 G',
      'sku', 'FC-46655727',
      'codigo_barras', '7509546655727',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Jbn Mennen Baby Magic Lavan 90 G — Ticket 77827',
      'costo', 38.31,
      'precio', 51.72,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-77827-175',
      NULL,
      38.31,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7509546655727', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-77827-175', NULL, 38.31, 'Bodega F-42 Ejidos del Moral', null
    );
  end if;
end $$;

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

-- 77827 L178 Protec Tensolastic Plus 15Cmx5M Venda Elast
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7501048691104' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7501048691104';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Protec Tensolastic Plus 15Cmx5M Venda Elast',
      'sku', 'FC-48691104',
      'codigo_barras', '7501048691104',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Protec Tensolastic Plus 15Cmx5M Venda Elast — Ticket 77827',
      'costo', 40.68,
      'precio', 54.92,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-77827-178',
      NULL,
      40.68,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7501048691104', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-77827-178', NULL, 40.68, 'Bodega F-42 Ejidos del Moral', null
    );
  end if;
end $$;

-- 77827 L179 Tco Mennen Rosa 200G
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7501035908147' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7501035908147';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Tco Mennen Rosa 200G',
      'sku', 'FC-35908147',
      'codigo_barras', '7501035908147',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Tco Mennen Rosa 200G — Ticket 77827',
      'costo', 13.32,
      'precio', 17.99,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-77827-179',
      NULL,
      13.32,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7501035908147', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-77827-179', NULL, 13.32, 'Bodega F-42 Ejidos del Moral', null
    );
  end if;
end $$;

-- 77827 L180 Tas Sanit Saba Inv Alas C/10
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7501019006371' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7501019006371';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Tas Sanit Saba Inv Alas C/10',
      'sku', 'FC-19006371',
      'codigo_barras', '7501019006371',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Tas Sanit Saba Inv Alas C/10 — Ticket 77827',
      'costo', 7.21,
      'precio', 9.74,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      2,
      'TK-77827-180',
      NULL,
      7.21,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7501019006371', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 2, 'TK-77827-180', NULL, 7.21, 'Bodega F-42 Ejidos del Moral', null
    );
  end if;
end $$;

-- 77827 L181 Bebin Super 4Opzs Toallitas Humedas
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '619585103015' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '619585103015';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Bebin Super 4Opzs Toallitas Humedas',
      'sku', 'FC-85103015',
      'codigo_barras', '619585103015',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Bebin Super 4Opzs Toallitas Humedas — Ticket 77827',
      'costo', 106.44,
      'precio', 143.7,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-77827-181',
      NULL,
      106.44,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('619585103015', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-77827-181', NULL, 106.44, 'Bodega F-42 Ejidos del Moral', null
    );
  end if;
end $$;

-- 77827 L182 Protec Tensolastic Plus 5Cmx5M Venda Elasti
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7501048690800' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7501048690800';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Protec Tensolastic Plus 5Cmx5M Venda Elasti',
      'sku', 'FC-48690800',
      'codigo_barras', '7501048690800',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Protec Tensolastic Plus 5Cmx5M Venda Elasti — Ticket 77827',
      'costo', 21.14,
      'precio', 28.54,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-77827-182',
      NULL,
      21.14,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7501048690800', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-77827-182', NULL, 21.14, 'Bodega F-42 Ejidos del Moral', null
    );
  end if;
end $$;

-- 77827 L183 C D Sensodyne Rapido Alivio 100G
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7794640171550' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7794640171550';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'C D Sensodyne Rapido Alivio 100G',
      'sku', 'FC-40171550',
      'codigo_barras', '7794640171550',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'C D Sensodyne Rapido Alivio 100G — Ticket 77827',
      'costo', 106.44,
      'precio', 143.69,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-77827-183',
      NULL,
      106.44,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7794640171550', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-77827-183', NULL, 106.44, 'Bodega F-42 Ejidos del Moral', null
    );
  end if;
end $$;

-- 77827 L184 Protec Tensolastic Plus 7Cmx5M Venda Elasti
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7501048690909' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7501048690909';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'Protec Tensolastic Plus 7Cmx5M Venda Elasti',
      'sku', 'FC-48690909',
      'codigo_barras', '7501048690909',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Protec Tensolastic Plus 7Cmx5M Venda Elasti — Ticket 77827',
      'costo', 21.14,
      'precio', 28.54,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-77827-184',
      NULL,
      21.14,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7501048690909', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-77827-184', NULL, 21.14, 'Bodega F-42 Ejidos del Moral', null
    );
  end if;
end $$;

-- 112558 L1 DIBAR ALCOHOL 125ML ROJO
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7501868900264' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7501868900264';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'DIBAR ALCOHOL 125ML ROJO',
      'sku', 'FC-68900264',
      'codigo_barras', '7501868900264',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'DIBAR ALCOHOL 125ML ROJO — Ticket 112558',
      'costo', 8.1,
      'precio', 10.94,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      48,
      'TK-112558-1',
      NULL,
      8.1,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7501868900264', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 48, 'TK-112558-1', NULL, 8.1, 'El Surtidor de su Farmacia', null
    );
  end if;
end $$;

-- 112558 L2 DIBAR ALCOHOL ILT ROJO
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7501868960257' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7501868960257';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'DIBAR ALCOHOL ILT ROJO',
      'sku', 'FC-68960257',
      'codigo_barras', '7501868960257',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'DIBAR ALCOHOL ILT ROJO — Ticket 112558',
      'costo', 638.45,
      'precio', 861.91,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-112558-2',
      NULL,
      638.45,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7501868960257', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-112558-2', NULL, 638.45, 'El Surtidor de su Farmacia', null
    );
  end if;
end $$;

-- 112558 L3 ADIBAR ALCOHOL 250ML. ROJO
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7501868900226' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7501868900226';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'ADIBAR ALCOHOL 250ML. ROJO',
      'sku', 'FC-68900226',
      'codigo_barras', '7501868900226',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'ADIBAR ALCOHOL 250ML. ROJO — Ticket 112558',
      'costo', 15.68,
      'precio', 21.17,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      36,
      'TK-112558-3',
      NULL,
      15.68,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7501868900226', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 36, 'TK-112558-3', NULL, 15.68, 'El Surtidor de su Farmacia', null
    );
  end if;
end $$;

-- 112558 L4 DIBAR ALCOHOL 500ML. ROJO
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7501868990023' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7501868990023';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'DIBAR ALCOHOL 500ML. ROJO',
      'sku', 'FC-68990023',
      'codigo_barras', '7501868990023',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'DIBAR ALCOHOL 500ML. ROJO — Ticket 112558',
      'costo', 676.85,
      'precio', 913.75,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-112558-4',
      NULL,
      676.85,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7501868990023', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-112558-4', NULL, 676.85, 'El Surtidor de su Farmacia', null
    );
  end if;
end $$;

-- 112558 L5 AGUA DESTILADA LA FLOR 1 LT
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7501677620056' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7501677620056';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'AGUA DESTILADA LA FLOR 1 LT',
      'sku', 'FC-77620056',
      'codigo_barras', '7501677620056',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'AGUA DESTILADA LA FLOR 1 LT — Ticket 112558',
      'costo', 19.0,
      'precio', 25.65,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      3,
      'TK-112558-5',
      NULL,
      19.0,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7501677620056', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 3, 'TK-112558-5', NULL, 19.0, 'El Surtidor de su Farmacia', null
    );
  end if;
end $$;

-- 112558 L6 ARNICA MERCURIO
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '3311000003920' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '3311000003920';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'ARNICA MERCURIO',
      'sku', 'FC-00003920',
      'codigo_barras', '3311000003920',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'ARNICA MERCURIO — Ticket 112558',
      'costo', 15.0,
      'precio', 20.25,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      10,
      'TK-112558-6',
      NULL,
      15.0,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('3311000003920', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 10, 'TK-112558-6', NULL, 15.0, 'El Surtidor de su Farmacia', null
    );
  end if;
end $$;

-- 112558 L7 CREMA AMARILLA VITACILINA ACLARADORA
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7506376000260' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7506376000260';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'CREMA AMARILLA VITACILINA ACLARADORA',
      'sku', 'FC-76000260',
      'codigo_barras', '7506376000260',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'CREMA AMARILLA VITACILINA ACLARADORA — Ticket 112558',
      'costo', 80.0,
      'precio', 108.0,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-112558-7',
      NULL,
      80.0,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7506376000260', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-112558-7', NULL, 80.0, 'El Surtidor de su Farmacia', null
    );
  end if;
end $$;

-- 112558 L8 CREMA ROJA VITACILINA ANTIARRUGAS 100GR
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7506376000253' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7506376000253';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'CREMA ROJA VITACILINA ANTIARRUGAS 100GR',
      'sku', 'FC-76000253',
      'codigo_barras', '7506376000253',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'CREMA ROJA VITACILINA ANTIARRUGAS 100GR — Ticket 112558',
      'costo', 80.0,
      'precio', 108.0,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-112558-8',
      NULL,
      80.0,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7506376000253', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-112558-8', NULL, 80.0, 'El Surtidor de su Farmacia', null
    );
  end if;
end $$;

-- 112558 L9 DIAPRO CONFORT MED C/10
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7501116800803' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7501116800803';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'DIAPRO CONFORT MED C/10',
      'sku', 'FC-16800803',
      'codigo_barras', '7501116800803',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'DIAPRO CONFORT MED C/10 — Ticket 112558',
      'costo', 170.0,
      'precio', 229.51,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-112558-9',
      NULL,
      170.0,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7501116800803', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-112558-9', NULL, 170.0, 'El Surtidor de su Farmacia', null
    );
  end if;
end $$;

-- 112558 L10 DABAN ALCOHOL AZUL 125ML.
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7501186901100' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7501186901100';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'DABAN ALCOHOL AZUL 125ML.',
      'sku', 'FC-86901100',
      'codigo_barras', '7501186901100',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'DABAN ALCOHOL AZUL 125ML. — Ticket 112558',
      'costo', 37.0,
      'precio', 49.95,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-112558-10',
      NULL,
      37.0,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7501186901100', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-112558-10', NULL, 37.0, 'El Surtidor de su Farmacia', null
    );
  end if;
end $$;

-- 112558 L11 ALCOHOL AZUL 1LT
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7501868901131' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7501868901131';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'ALCOHOL AZUL 1LT',
      'sku', 'FC-68901131',
      'codigo_barras', '7501868901131',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'ALCOHOL AZUL 1LT — Ticket 112558',
      'costo', 205.0,
      'precio', 276.75,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-112558-11',
      NULL,
      205.0,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7501868901131', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-112558-11', NULL, 205.0, 'El Surtidor de su Farmacia', null
    );
  end if;
end $$;

-- 112558 L12 DIBAR ALCOHOL AZUL 250ML
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7501868901117' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7501868901117';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'DIBAR ALCOHOL AZUL 250ML',
      'sku', 'FC-68901117',
      'codigo_barras', '7501868901117',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'DIBAR ALCOHOL AZUL 250ML — Ticket 112558',
      'costo', 56.5,
      'precio', 76.28,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-112558-12',
      NULL,
      56.5,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7501868901117', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-112558-12', NULL, 56.5, 'El Surtidor de su Farmacia', null
    );
  end if;
end $$;

-- 112558 L13 ALCOHOL AZUL 500ML
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7501868901124' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7501868901124';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'ALCOHOL AZUL 500ML',
      'sku', 'FC-68901124',
      'codigo_barras', '7501868901124',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'ALCOHOL AZUL 500ML — Ticket 112558',
      'costo', 120.0,
      'precio', 162.0,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-112558-13',
      NULL,
      120.0,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7501868901124', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-112558-13', NULL, 120.0, 'El Surtidor de su Farmacia', null
    );
  end if;
end $$;

-- 112558 L14 BOLO EUROBION TAB C/20
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7501298223704' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7501298223704';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'BOLO EUROBION TAB C/20',
      'sku', 'FC-98223704',
      'codigo_barras', '7501298223704',
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'BOLO EUROBION TAB C/20 — Ticket 112558',
      'costo', 269.28,
      'precio', 363.53,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-112558-14',
      NULL,
      269.28,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7501298223704', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-112558-14', NULL, 269.28, 'El Surtidor de su Farmacia', null
    );
  end if;
end $$;

-- 112558 L15 LIO 236ML CHTE
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7501033950100' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7501033950100';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'LIO 236ML CHTE',
      'sku', 'FC-33950100',
      'codigo_barras', '7501033950100',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'LIO 236ML CHTE — Ticket 112558',
      'costo', 42.0,
      'precio', 56.7,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      2,
      'TK-112558-15',
      NULL,
      42.0,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7501033950100', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 2, 'TK-112558-15', NULL, 42.0, 'El Surtidor de su Farmacia', null
    );
  end if;
end $$;

-- 112558 L16 BASUYE LIQ 236ML FSA
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7501033950063' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7501033950063';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'BASUYE LIQ 236ML FSA',
      'sku', 'FC-33950063',
      'codigo_barras', '7501033950063',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'BASUYE LIQ 236ML FSA — Ticket 112558',
      'costo', 84.0,
      'precio', 113.4,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-112558-16',
      NULL,
      84.0,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7501033950063', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-112558-16', NULL, 84.0, 'El Surtidor de su Farmacia', null
    );
  end if;
end $$;

-- 112558 L17 ENSURE LIQ 236ML VNLLA
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7501033950070' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7501033950070';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'ENSURE LIQ 236ML VNLLA',
      'sku', 'FC-33950070',
      'codigo_barras', '7501033950070',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'ENSURE LIQ 236ML VNLLA — Ticket 112558',
      'costo', 42.0,
      'precio', 56.7,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      2,
      'TK-112558-17',
      NULL,
      42.0,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7501033950070', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 2, 'TK-112558-17', NULL, 42.0, 'El Surtidor de su Farmacia', null
    );
  end if;
end $$;

-- 112558 L18 LUCERNA LIQ 237ML
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7501033956133' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7501033956133';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'LUCERNA LIQ 237ML',
      'sku', 'FC-33956133',
      'codigo_barras', '7501033956133',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'LUCERNA LIQ 237ML — Ticket 112558',
      'costo', 95.0,
      'precio', 128.25,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-112558-18',
      NULL,
      95.0,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7501033956133', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-112558-18', NULL, 95.0, 'El Surtidor de su Farmacia', null
    );
  end if;
end $$;

-- 112558 L19 GLUCERNA SR LIQ 237ML FRESA
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7501033956140' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7501033956140';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'GLUCERNA SR LIQ 237ML FRESA',
      'sku', 'FC-33956140',
      'codigo_barras', '7501033956140',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'GLUCERNA SR LIQ 237ML FRESA — Ticket 112558',
      'costo', 95.0,
      'precio', 128.25,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-112558-19',
      NULL,
      95.0,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7501033956140', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-112558-19', NULL, 95.0, 'El Surtidor de su Farmacia', null
    );
  end if;
end $$;

-- 112558 L20 GOTERO CRISTAL
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7501507521317' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7501507521317';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'GOTERO CRISTAL',
      'sku', 'FC-07521317',
      'codigo_barras', '7501507521317',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'GOTERO CRISTAL — Ticket 112558',
      'costo', 119.99,
      'precio', 161.99,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-112558-20',
      NULL,
      119.99,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7501507521317', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-112558-20', NULL, 119.99, 'El Surtidor de su Farmacia', null
    );
  end if;
end $$;

-- 112558 L21 NATURELLA FLUJO MOD C/ALAS C/8
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7501001157296' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7501001157296';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'NATURELLA FLUJO MOD C/ALAS C/8',
      'sku', 'FC-01157296',
      'codigo_barras', '7501001157296',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'NATURELLA FLUJO MOD C/ALAS C/8 — Ticket 112558',
      'costo', 85.0,
      'precio', 114.76,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-112558-21',
      NULL,
      85.0,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7501001157296', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-112558-21', NULL, 85.0, 'El Surtidor de su Farmacia', null
    );
  end if;
end $$;

-- 112558 L22 NATURELLA NOCHE CON ALAS C/8
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7501001405335' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7501001405335';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'NATURELLA NOCHE CON ALAS C/8',
      'sku', 'FC-01405335',
      'codigo_barras', '7501001405335',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'NATURELLA NOCHE CON ALAS C/8 — Ticket 112558',
      'costo', 18.5,
      'precio', 24.98,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      5,
      'TK-112558-22',
      NULL,
      18.5,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7501001405335', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 5, 'TK-112558-22', NULL, 18.5, 'El Surtidor de su Farmacia', null
    );
  end if;
end $$;

-- 112558 L23 EDIASURE LIQ 236ML CHTE
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7501033951008' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7501033951008';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'EDIASURE LIQ 236ML CHTE',
      'sku', 'FC-33951008',
      'codigo_barras', '7501033951008',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'EDIASURE LIQ 236ML CHTE — Ticket 112558',
      'costo', 44.0,
      'precio', 59.41,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      2,
      'TK-112558-23',
      NULL,
      44.0,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7501033951008', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 2, 'TK-112558-23', NULL, 44.0, 'El Surtidor de su Farmacia', null
    );
  end if;
end $$;

-- 112558 L24 PEDIASURE LIQ 236ML FSA
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7501033954245' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7501033954245';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'PEDIASURE LIQ 236ML FSA',
      'sku', 'FC-33954245',
      'codigo_barras', '7501033954245',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'PEDIASURE LIQ 236ML FSA — Ticket 112558',
      'costo', 44.0,
      'precio', 59.41,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      2,
      'TK-112558-24',
      NULL,
      44.0,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7501033954245', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 2, 'TK-112558-24', NULL, 44.0, 'El Surtidor de su Farmacia', null
    );
  end if;
end $$;

-- 112558 L25 PEDIASURE LIQ 236ML VNLLA
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7501033950209' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7501033950209';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'PEDIASURE LIQ 236ML VNLLA',
      'sku', 'FC-33950209',
      'codigo_barras', '7501033950209',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'PEDIASURE LIQ 236ML VNLLA — Ticket 112558',
      'costo', 88.0,
      'precio', 118.81,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-112558-25',
      NULL,
      88.0,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7501033950209', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-112558-25', NULL, 88.0, 'El Surtidor de su Farmacia', null
    );
  end if;
end $$;

-- 112558 L26 SABA BUENAS NOCHES
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7501019006623' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7501019006623';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
      jsonb_build_object(
      'nombre', 'SABA BUENAS NOCHES',
      'sku', 'FC-19006623',
      'codigo_barras', '7501019006623',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'SABA BUENAS NOCHES — Ticket 112558',
      'costo', 99.0,
      'precio', 133.65,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-112558-26',
      NULL,
      99.0,
      null
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7501019006623', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-112558-26', NULL, 99.0, 'El Surtidor de su Farmacia', null
    );
  end if;
end $$;
commit;
