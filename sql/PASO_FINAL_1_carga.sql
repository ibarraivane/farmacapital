-- PASO FINAL 1/3 — Completar inventario (idempotente)
-- Ejecutar en orden 1 → 2 → 3. Si ya tienes 433 productos, esto solo agrega faltantes.

begin;

create temp table if not exists _fc_carga_map (
  codigo_barras text primary key,
  producto_id bigint
) on commit drop;

insert into _fc_carga_map (codigo_barras, producto_id)
select codigo_barras, id from public.productos
where codigo_barras is not null and btrim(codigo_barras) <> ''
on conflict (codigo_barras) do nothing;



-- 77827 L1 Desod Obao R-Nat Coco R-On 65G
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-52844825'
     or codigo_barras = '7509552844825'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
      jsonb_build_object(
      'nombre', 'Desod Obao R-Nat Coco R-On 65G',
      'sku', 'FC-52844825',
      'codigo_barras', '7509552844825',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Desod Obao R-Nat Coco R-On 65G — Ticket 77827',
      'costo', 29.55,
      'precio', 39.9,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-77827-1',
      NULL,
      29.55,
      null
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7509552844825', id from public.productos where codigo_barras = '7509552844825'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- 77827 L2 Desod Obao Game 48Hr R-On 65G N
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-52933307'
     or codigo_barras = '7509552933307'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
      jsonb_build_object(
      'nombre', 'Desod Obao Game 48Hr R-On 65G N',
      'sku', 'FC-52933307',
      'codigo_barras', '7509552933307',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Desod Obao Game 48Hr R-On 65G N — Ticket 77827',
      'costo', 24.71,
      'precio', 33.36,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-77827-2',
      NULL,
      24.71,
      null
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7509552933307', id from public.productos where codigo_barras = '7509552933307'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- 77827 L3 Desod Obad P/Del R-On 65G
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-27250612'
     or codigo_barras = '7501027250612'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
      jsonb_build_object(
      'nombre', 'Desod Obad P/Del R-On 65G',
      'sku', 'FC-27250612',
      'codigo_barras', '7501027250612',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Desod Obad P/Del R-On 65G — Ticket 77827',
      'costo', 24.71,
      'precio', 33.36,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-77827-3',
      NULL,
      24.71,
      null
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7501027250612', id from public.productos where codigo_barras = '7501027250612'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- 77827 L4 Desod Obao Clas R-On 65G
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-27286017'
     or codigo_barras = '7501027286017'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
      jsonb_build_object(
      'nombre', 'Desod Obao Clas R-On 65G',
      'sku', 'FC-27286017',
      'codigo_barras', '7501027286017',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Desod Obao Clas R-On 65G — Ticket 77827',
      'costo', 45.83,
      'precio', 61.88,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-77827-4',
      NULL,
      45.83,
      null
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7501027286017', id from public.productos where codigo_barras = '7501027286017'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- 77827 L5 Desod Obao Men Tatto Aqua R-On 65G
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-52876406'
     or codigo_barras = '7509552876406'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
      jsonb_build_object(
      'nombre', 'Desod Obao Men Tatto Aqua R-On 65G',
      'sku', 'FC-52876406',
      'codigo_barras', '7509552876406',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Desod Obao Men Tatto Aqua R-On 65G — Ticket 77827',
      'costo', 45.83,
      'precio', 61.88,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-77827-5',
      NULL,
      45.83,
      null
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7509552876406', id from public.productos where codigo_barras = '7509552876406'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- 77827 L6 Desod Axe Men Young Spy 150Ml
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-30622622'
     or codigo_barras = '750630622622'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
      jsonb_build_object(
      'nombre', 'Desod Axe Men Young Spy 150Ml',
      'sku', 'FC-30622622',
      'codigo_barras', '750630622622',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Desod Axe Men Young Spy 150Ml — Ticket 77827',
      'costo', 45.83,
      'precio', 61.88,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-77827-6',
      NULL,
      45.83,
      null
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '750630622622', id from public.productos where codigo_barras = '750630622622'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- 77827 L7 Desod Axe Icechi E-Frio Spy 150Ml
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-06213906'
     or codigo_barras = '7506306213906'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
      jsonb_build_object(
      'nombre', 'Desod Axe Icechi E-Frio Spy 150Ml',
      'sku', 'FC-06213906',
      'codigo_barras', '7506306213906',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Desod Axe Icechi E-Frio Spy 150Ml — Ticket 77827',
      'costo', 25.83,
      'precio', 34.88,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-77827-7',
      NULL,
      25.83,
      null
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7506306213906', id from public.productos where codigo_barras = '7506306213906'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- 77827 L8 Desod Rexona Men Marine Spy 150Ml
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-93037806'
     or codigo_barras = '7791293037806'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
      jsonb_build_object(
      'nombre', 'Desod Rexona Men Marine Spy 150Ml',
      'sku', 'FC-93037806',
      'codigo_barras', '7791293037806',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Desod Rexona Men Marine Spy 150Ml — Ticket 77827',
      'costo', 62.83,
      'precio', 84.83,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-77827-8',
      NULL,
      62.83,
      null
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7791293037806', id from public.productos where codigo_barras = '7791293037806'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- 77827 L9 Desod Obao Men Tato Rebel R-On65
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-55280956'
     or codigo_barras = '750955280956'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
      jsonb_build_object(
      'nombre', 'Desod Obao Men Tato Rebel R-On65',
      'sku', 'FC-55280956',
      'codigo_barras', '750955280956',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Desod Obao Men Tato Rebel R-On65 — Ticket 77827',
      'costo', 54.68,
      'precio', 73.82,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-77827-9',
      NULL,
      54.68,
      null
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '750955280956', id from public.productos where codigo_barras = '750955280956'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- 77827 L10 Desod Axe Excite Seco Spy 152Ml
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-93025919'
     or codigo_barras = '7791293025919'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
      jsonb_build_object(
      'nombre', 'Desod Axe Excite Seco Spy 152Ml',
      'sku', 'FC-93025919',
      'codigo_barras', '7791293025919',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Desod Axe Excite Seco Spy 152Ml — Ticket 77827',
      'costo', 45.83,
      'precio', 61.88,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-77827-10',
      NULL,
      45.83,
      null
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7791293025919', id from public.productos where codigo_barras = '7791293025919'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- 77827 L11 Desod Rexona Men V8 Tun Spy 90G
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-93022567'
     or codigo_barras = '7791293022567'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
      jsonb_build_object(
      'nombre', 'Desod Rexona Men V8 Tun Spy 90G',
      'sku', 'FC-93022567',
      'codigo_barras', '7791293022567',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Desod Rexona Men V8 Tun Spy 90G — Ticket 77827',
      'costo', 51.5,
      'precio', 69.53,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-77827-11',
      NULL,
      51.5,
      null
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7791293022567', id from public.productos where codigo_barras = '7791293022567'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- 77827 L12 Desod Axe Intense 48H Spy 150Ml
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-06244795'
     or codigo_barras = '7506306244795'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
      jsonb_build_object(
      'nombre', 'Desod Axe Intense 48H Spy 150Ml',
      'sku', 'FC-06244795',
      'codigo_barras', '7506306244795',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Desod Axe Intense 48H Spy 150Ml — Ticket 77827',
      'costo', 54.68,
      'precio', 73.82,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-77827-12',
      NULL,
      54.68,
      null
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7506306244795', id from public.productos where codigo_barras = '7506306244795'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- 77827 L13 Desod Rexona 48H Happy-M Stick 45G
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-75076009'
     or codigo_barras = '75076009'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
      jsonb_build_object(
      'nombre', 'Desod Rexona 48H Happy-M Stick 45G',
      'sku', 'FC-75076009',
      'codigo_barras', '75076009',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Desod Rexona 48H Happy-M Stick 45G — Ticket 77827',
      'costo', 53.5,
      'precio', 72.23,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-77827-13',
      NULL,
      53.5,
      null
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '75076009', id from public.productos where codigo_barras = '75076009'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- 77827 L14 Desod Axe Men Dark Temp Spy150Ml
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-93025797'
     or codigo_barras = '7791293025797'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
      jsonb_build_object(
      'nombre', 'Desod Axe Men Dark Temp Spy150Ml',
      'sku', 'FC-93025797',
      'codigo_barras', '7791293025797',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Desod Axe Men Dark Temp Spy150Ml — Ticket 77827',
      'costo', 53.5,
      'precio', 72.23,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-77827-14',
      NULL,
      53.5,
      null
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7791293025797', id from public.productos where codigo_barras = '7791293025797'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- 77827 L15 Desod Rexona Men Sport Spy 150Ml
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-93038223'
     or codigo_barras = '7791293038223'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
      jsonb_build_object(
      'nombre', 'Desod Rexona Men Sport Spy 150Ml',
      'sku', 'FC-93038223',
      'codigo_barras', '7791293038223',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Desod Rexona Men Sport Spy 150Ml — Ticket 77827',
      'costo', 45.83,
      'precio', 61.88,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-77827-15',
      NULL,
      45.83,
      null
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7791293038223', id from public.productos where codigo_barras = '7791293038223'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- 77827 L16 Desod Rexona Bamboo 48H Stick 45G
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-75062897'
     or codigo_barras = '75062897'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
      jsonb_build_object(
      'nombre', 'Desod Rexona Bamboo 48H Stick 45G',
      'sku', 'FC-75062897',
      'codigo_barras', '75062897',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Desod Rexona Bamboo 48H Stick 45G — Ticket 77827',
      'costo', 45.83,
      'precio', 61.88,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-77827-16',
      NULL,
      45.83,
      null
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '75062897', id from public.productos where codigo_barras = '75062897'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- 77827 L17 Desod Axe Men Epic-F 48H Spy 150Ml
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-06245686'
     or codigo_barras = '7506306245686'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
      jsonb_build_object(
      'nombre', 'Desod Axe Men Epic-F 48H Spy 150Ml',
      'sku', 'FC-06245686',
      'codigo_barras', '7506306245686',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Desod Axe Men Epic-F 48H Spy 150Ml — Ticket 77827',
      'costo', 45.83,
      'precio', 61.88,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-77827-17',
      NULL,
      45.83,
      null
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7506306245686', id from public.productos where codigo_barras = '7506306245686'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- 77827 L18 Desod Axe Men Gold Temp
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-93025865'
     or codigo_barras = '7791293025865'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
      jsonb_build_object(
      'nombre', 'Desod Axe Men Gold Temp',
      'sku', 'FC-93025865',
      'codigo_barras', '7791293025865',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Desod Axe Men Gold Temp — Ticket 77827',
      'costo', 45.83,
      'precio', 61.88,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-77827-18',
      NULL,
      45.83,
      null
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7791293025865', id from public.productos where codigo_barras = '7791293025865'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- 77827 L19 Jbn Grisi Neutro 150 G
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-22105207'
     or codigo_barras = '7501022105207'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
      jsonb_build_object(
      'nombre', 'Jbn Grisi Neutro 150 G',
      'sku', 'FC-22105207',
      'codigo_barras', '7501022105207',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Jbn Grisi Neutro 150 G — Ticket 77827',
      'costo', 20.14,
      'precio', 27.19,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      3,
      'TK-77827-19',
      NULL,
      20.14,
      null
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7501022105207', id from public.productos where codigo_barras = '7501022105207'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- 77827 L20 Jbn Dove Barra Blanca
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-38891190'
     or codigo_barras = '067238891190'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
      jsonb_build_object(
      'nombre', 'Jbn Dove Barra Blanca',
      'sku', 'FC-38891190',
      'codigo_barras', '067238891190',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Jbn Dove Barra Blanca — Ticket 77827',
      'costo', 60.54,
      'precio', 81.73,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      2,
      'TK-77827-20',
      NULL,
      60.54,
      null
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '067238891190', id from public.productos where codigo_barras = '067238891190'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- 77827 L21 Desod Rexona Pom-Dry48H Stick45G
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-75062927'
     or codigo_barras = '75062927'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
      jsonb_build_object(
      'nombre', 'Desod Rexona Pom-Dry48H Stick45G',
      'sku', 'FC-75062927',
      'codigo_barras', '75062927',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Desod Rexona Pom-Dry48H Stick45G — Ticket 77827',
      'costo', 30.21,
      'precio', 40.79,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-77827-21',
      NULL,
      30.21,
      null
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '75062927', id from public.productos where codigo_barras = '75062927'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- 77827 L22 Jbn Asepxia Bicarbon Sod 100G
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-40036965'
     or codigo_barras = '650240036965'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
      jsonb_build_object(
      'nombre', 'Jbn Asepxia Bicarbon Sod 100G',
      'sku', 'FC-40036965',
      'codigo_barras', '650240036965',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Jbn Asepxia Bicarbon Sod 100G — Ticket 77827',
      'costo', 14.45,
      'precio', 19.51,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-77827-22',
      NULL,
      14.45,
      null
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '650240036965', id from public.productos where codigo_barras = '650240036965'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- 77827 L23 Jbn Asexia Exfol 100G
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-40004643'
     or codigo_barras = '650240004643'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
      jsonb_build_object(
      'nombre', 'Jbn Asexia Exfol 100G',
      'sku', 'FC-40004643',
      'codigo_barras', '650240004643',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Jbn Asexia Exfol 100G — Ticket 77827',
      'costo', 38.66,
      'precio', 52.2,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-77827-23',
      NULL,
      38.66,
      null
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '650240004643', id from public.productos where codigo_barras = '650240004643'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- 77827 L24 Jbn Grisi Avena 125G
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-22150801'
     or codigo_barras = '7501022150801'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
      jsonb_build_object(
      'nombre', 'Jbn Grisi Avena 125G',
      'sku', 'FC-22150801',
      'codigo_barras', '7501022150801',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Jbn Grisi Avena 125G — Ticket 77827',
      'costo', 15.02,
      'precio', 20.28,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-77827-24',
      NULL,
      15.02,
      null
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7501022150801', id from public.productos where codigo_barras = '7501022150801'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- 77827 L25 Jbn Escudo Antibact 110Gr
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-25605514'
     or codigo_barras = '7506425605514'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
      jsonb_build_object(
      'nombre', 'Jbn Escudo Antibact 110Gr',
      'sku', 'FC-25605514',
      'codigo_barras', '7506425605514',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Jbn Escudo Antibact 110Gr — Ticket 77827',
      'costo', 26.75,
      'precio', 36.12,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      2,
      'TK-77827-25',
      NULL,
      26.75,
      null
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7506425605514', id from public.productos where codigo_barras = '7506425605514'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- 77827 L26 Azufre Jabon C Miel 80
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-14119032'
     or codigo_barras = '7503014119032'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
      jsonb_build_object(
      'nombre', 'Azufre Jabon C Miel 80',
      'sku', 'FC-14119032',
      'codigo_barras', '7503014119032',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Azufre Jabon C Miel 80 — Ticket 77827',
      'costo', 30.21,
      'precio', 40.79,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-77827-26',
      NULL,
      30.21,
      null
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7503014119032', id from public.productos where codigo_barras = '7503014119032'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- 77827 L28 Jbn Dove Barra Karite Vainill 135G
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-06230507'
     or codigo_barras = '7506306230507'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
      jsonb_build_object(
      'nombre', 'Jbn Dove Barra Karite Vainill 135G',
      'sku', 'FC-06230507',
      'codigo_barras', '7506306230507',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Jbn Dove Barra Karite Vainill 135G — Ticket 77827',
      'costo', 30.21,
      'precio', 40.79,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-77827-28',
      NULL,
      30.21,
      null
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7506306230507', id from public.productos where codigo_barras = '7506306230507'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- 77827 L29 Jbn Grisi Leche De Burra 125G
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-22150092'
     or codigo_barras = '7501022150092'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
      jsonb_build_object(
      'nombre', 'Jbn Grisi Leche De Burra 125G',
      'sku', 'FC-22150092',
      'codigo_barras', '7501022150092',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Jbn Grisi Leche De Burra 125G — Ticket 77827',
      'costo', 42.82,
      'precio', 57.81,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-77827-29',
      NULL,
      42.82,
      null
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7501022150092', id from public.productos where codigo_barras = '7501022150092'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- 77827 L30 Jbn Grisi Corp Diabecare 125 G
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-22111352'
     or codigo_barras = '7501022111352'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
      jsonb_build_object(
      'nombre', 'Jbn Grisi Corp Diabecare 125 G',
      'sku', 'FC-22111352',
      'codigo_barras', '7501022111352',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Jbn Grisi Corp Diabecare 125 G — Ticket 77827',
      'costo', 35.61,
      'precio', 48.08,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-77827-30',
      NULL,
      35.61,
      null
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7501022111352', id from public.productos where codigo_barras = '7501022111352'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- 77827 L31 Desod Rex Mot-Sen Sport Stick
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-75069223'
     or codigo_barras = '75069223'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
      jsonb_build_object(
      'nombre', 'Desod Rex Mot-Sen Sport Stick',
      'sku', 'FC-75069223',
      'codigo_barras', '75069223',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Desod Rex Mot-Sen Sport Stick — Ticket 77827',
      'costo', 16.7,
      'precio', 22.55,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-77827-31',
      NULL,
      16.7,
      null
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '75069223', id from public.productos where codigo_barras = '75069223'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- 77827 L32 Jbn Liq Palmol N-Bal Dermol 221Mln
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-46059556'
     or codigo_barras = '7509546059556'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7509546059556', id from public.productos where codigo_barras = '7509546059556'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- 77827 L33 Jbn Liq Blumen Coconut Para 221Ml
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-67905186'
     or codigo_barras = '7506267905186'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
      jsonb_build_object(
      'nombre', 'Jbn Liq Blumen Coconut Para 221Ml',
      'sku', 'FC-67905186',
      'codigo_barras', '7506267905186',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Jbn Liq Blumen Coconut Para 221Ml — Ticket 77827',
      'costo', 128.57,
      'precio', 173.57,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-77827-33',
      NULL,
      128.57,
      null
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7506267905186', id from public.productos where codigo_barras = '7506267905186'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- 77827 L34 Jbn Palmol N-Bal Dermo Limp 120G
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-46683133'
     or codigo_barras = '7509546683133'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
      jsonb_build_object(
      'nombre', 'Jbn Palmol N-Bal Dermo Limp 120G',
      'sku', 'FC-46683133',
      'codigo_barras', '7509546683133',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Jbn Palmol N-Bal Dermo Limp 120G — Ticket 77827',
      'costo', 8.96,
      'precio', 12.1,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      2,
      'TK-77827-34',
      NULL,
      8.96,
      null
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7509546683133', id from public.productos where codigo_barras = '7509546683133'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- 77827 L35 Desod Dove Dermac Sk-C 48H Spy150Ml
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-06241206'
     or codigo_barras = '7506306241206'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
      jsonb_build_object(
      'nombre', 'Desod Dove Dermac Sk-C 48H Spy150Ml',
      'sku', 'FC-06241206',
      'codigo_barras', '7506306241206',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Desod Dove Dermac Sk-C 48H Spy150Ml — Ticket 77827',
      'costo', 54.12,
      'precio', 73.07,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      2,
      'TK-77827-35',
      NULL,
      54.12,
      null
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7506306241206', id from public.productos where codigo_barras = '7506306241206'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- 77827 L36 Jbn Escudo Rosa Prot Y Cuid 110G
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-43489004'
     or codigo_barras = '7501943489004'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
      jsonb_build_object(
      'nombre', 'Jbn Escudo Rosa Prot Y Cuid 110G',
      'sku', 'FC-43489004',
      'codigo_barras', '7501943489004',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Jbn Escudo Rosa Prot Y Cuid 110G — Ticket 77827',
      'costo', 40.73,
      'precio', 54.99,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      2,
      'TK-77827-36',
      NULL,
      40.73,
      null
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7501943489004', id from public.productos where codigo_barras = '7501943489004'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- 77827 L37 Agua Mic Garnier De Rosas 400 Ml
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-42326414'
     or codigo_barras = '3600542326414'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
      jsonb_build_object(
      'nombre', 'Agua Mic Garnier De Rosas 400 Ml',
      'sku', 'FC-42326414',
      'codigo_barras', '3600542326414',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Agua Mic Garnier De Rosas 400 Ml — Ticket 77827',
      'costo', 27.75,
      'precio', 37.47,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-77827-37',
      NULL,
      27.75,
      null
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '3600542326414', id from public.productos where codigo_barras = '3600542326414'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- 77827 L38 Agua Mic Vitacilina Ros-Sab 500Mln
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-76000284'
     or codigo_barras = '7506376000284'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
      jsonb_build_object(
      'nombre', 'Agua Mic Vitacilina Ros-Sab 500Mln',
      'sku', 'FC-76000284',
      'codigo_barras', '7506376000284',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Agua Mic Vitacilina Ros-Sab 500Mln — Ticket 77827',
      'costo', 21.08,
      'precio', 28.46,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-77827-38',
      NULL,
      21.08,
      null
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7506376000284', id from public.productos where codigo_barras = '7506376000284'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- 77827 L39 Desmaq Bifasico Oil Nuvel 125Ml
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-82790504'
     or codigo_barras = '7501082790504'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
      jsonb_build_object(
      'nombre', 'Desmaq Bifasico Oil Nuvel 125Ml',
      'sku', 'FC-82790504',
      'codigo_barras', '7501082790504',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Desmaq Bifasico Oil Nuvel 125Ml — Ticket 77827',
      'costo', 16.7,
      'precio', 22.55,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-77827-39',
      NULL,
      16.7,
      null
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7501082790504', id from public.productos where codigo_barras = '7501082790504'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- 77827 L40 Agua Mice Natural-G Bifasic 120Ml
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-45722547'
     or codigo_barras = '7502245722547'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
      jsonb_build_object(
      'nombre', 'Agua Mice Natural-G Bifasic 120Ml',
      'sku', 'FC-45722547',
      'codigo_barras', '7502245722547',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Agua Mice Natural-G Bifasic 120Ml — Ticket 77827',
      'costo', 37.72,
      'precio', 50.93,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-77827-40',
      NULL,
      37.72,
      null
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7502245722547', id from public.productos where codigo_barras = '7502245722547'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- 77827 L41 Jbn Liq Blumen Cherry Bloss 221Ml
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-67905131'
     or codigo_barras = '7506267905131'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
      jsonb_build_object(
      'nombre', 'Jbn Liq Blumen Cherry Bloss 221Ml',
      'sku', 'FC-67905131',
      'codigo_barras', '7506267905131',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Jbn Liq Blumen Cherry Bloss 221Ml — Ticket 77827',
      'costo', 17.78,
      'precio', 24.01,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-77827-41',
      NULL,
      17.78,
      null
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7506267905131', id from public.productos where codigo_barras = '7506267905131'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- 77827 L42 Tas Hum Claris Desmaq Aloe C/40
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-21012303'
     or codigo_barras = '7502221012303'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
      jsonb_build_object(
      'nombre', 'Tas Hum Claris Desmaq Aloe C/40',
      'sku', 'FC-21012303',
      'codigo_barras', '7502221012303',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Tas Hum Claris Desmaq Aloe C/40 — Ticket 77827',
      'costo', 14.78,
      'precio', 19.96,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      2,
      'TK-77827-42',
      NULL,
      14.78,
      null
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7502221012303', id from public.productos where codigo_barras = '7502221012303'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- 77827 L43 Jabon De Proteina De Arroz Y Concha Nacar 8
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-14121782'
     or codigo_barras = '7505514121782'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
      jsonb_build_object(
      'nombre', 'Jabon De Proteina De Arroz Y Concha Nacar 8',
      'sku', 'FC-14121782',
      'codigo_barras', '7505514121782',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Jabon De Proteina De Arroz Y Concha Nacar 8 — Ticket 77827',
      'costo', 167.69,
      'precio', 226.39,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-77827-43',
      NULL,
      167.69,
      null
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7505514121782', id from public.productos where codigo_barras = '7505514121782'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- 77827 L44 Jbn Escudo Azul Rey 135G
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-25652716'
     or codigo_barras = '7506425652716'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
      jsonb_build_object(
      'nombre', 'Jbn Escudo Azul Rey 135G',
      'sku', 'FC-25652716',
      'codigo_barras', '7506425652716',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Jbn Escudo Azul Rey 135G — Ticket 77827',
      'costo', 73.65,
      'precio', 99.43,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      2,
      'TK-77827-44',
      NULL,
      73.65,
      null
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7506425652716', id from public.productos where codigo_barras = '7506425652716'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- 77827 L45 Deo Aero Dove Tono Uniforme 150Ml 3Pack
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-06248052'
     or codigo_barras = '7506306248052'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
      jsonb_build_object(
      'nombre', 'Deo Aero Dove Tono Uniforme 150Ml 3Pack',
      'sku', 'FC-06248052',
      'codigo_barras', '7506306248052',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Deo Aero Dove Tono Uniforme 150Ml 3Pack — Ticket 77827',
      'costo', 147.3,
      'precio', 198.86,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-77827-45',
      NULL,
      147.3,
      null
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7506306248052', id from public.productos where codigo_barras = '7506306248052'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- 77827 L46 Deo Dove Spy Invisible Dry 150Ml C3
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-06248045'
     or codigo_barras = '7506306248045'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
      jsonb_build_object(
      'nombre', 'Deo Dove Spy Invisible Dry 150Ml C3',
      'sku', 'FC-06248045',
      'codigo_barras', '7506306248045',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Deo Dove Spy Invisible Dry 150Ml C3 — Ticket 77827',
      'costo', 129.46,
      'precio', 174.78,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-77827-46',
      NULL,
      129.46,
      null
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7506306248045', id from public.productos where codigo_barras = '7506306248045'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- 77827 L47 Jbn Liq Palmol Aquarium 221Ml
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-35911208'
     or codigo_barras = '7501035911208'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
      jsonb_build_object(
      'nombre', 'Jbn Liq Palmol Aquarium 221Ml',
      'sku', 'FC-35911208',
      'codigo_barras', '7501035911208',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Jbn Liq Palmol Aquarium 221Ml — Ticket 77827',
      'costo', 45.83,
      'precio', 61.88,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-77827-47',
      NULL,
      45.83,
      null
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7501035911208', id from public.productos where codigo_barras = '7501035911208'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- 77827 L48 Desod Nivea Pearlb Mspy150Ml
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-08837311'
     or codigo_barras = '4005808837311'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
      jsonb_build_object(
      'nombre', 'Desod Nivea Pearlb Mspy150Ml',
      'sku', 'FC-08837311',
      'codigo_barras', '4005808837311',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Desod Nivea Pearlb Mspy150Ml — Ticket 77827',
      'costo', 12.54,
      'precio', 16.93,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      2,
      'TK-77827-48',
      NULL,
      12.54,
      null
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '4005808837311', id from public.productos where codigo_barras = '4005808837311'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- 77827 L49 Deo Axe Spy 150Ml 48H Anarchy Fresh Love Fo
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-06209862'
     or codigo_barras = '7506306209862'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
      jsonb_build_object(
      'nombre', 'Deo Axe Spy 150Ml 48H Anarchy Fresh Love Fo',
      'sku', 'FC-06209862',
      'codigo_barras', '7506306209862',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Deo Axe Spy 150Ml 48H Anarchy Fresh Love Fo — Ticket 77827',
      'costo', 16.87,
      'precio', 22.78,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-77827-49',
      NULL,
      16.87,
      null
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7506306209862', id from public.productos where codigo_barras = '7506306209862'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- 77827 L50 Jbn Liq Escudo Blanco Neut 225Ml
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-43489165'
     or codigo_barras = '7501943489165'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
      jsonb_build_object(
      'nombre', 'Jbn Liq Escudo Blanco Neut 225Ml',
      'sku', 'FC-43489165',
      'codigo_barras', '7501943489165',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Jbn Liq Escudo Blanco Neut 225Ml — Ticket 77827',
      'costo', 45.83,
      'precio', 61.88,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-77827-50',
      NULL,
      45.83,
      null
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7501943489165', id from public.productos where codigo_barras = '7501943489165'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- 77827 L51 Jaloma Agua De Rosas 130Ml Spray
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-84900280'
     or codigo_barras = '759684900280'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
      jsonb_build_object(
      'nombre', 'Jaloma Agua De Rosas 130Ml Spray',
      'sku', 'FC-84900280',
      'codigo_barras', '759684900280',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Jaloma Agua De Rosas 130Ml Spray — Ticket 77827',
      'costo', 23.79,
      'precio', 32.12,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-77827-51',
      NULL,
      23.79,
      null
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '759684900280', id from public.productos where codigo_barras = '759684900280'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- 77827 L52 Desod Axe Wom Anarchy Spy 150Ml
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-06226852'
     or codigo_barras = '7506306226852'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
      jsonb_build_object(
      'nombre', 'Desod Axe Wom Anarchy Spy 150Ml',
      'sku', 'FC-06226852',
      'codigo_barras', '7506306226852',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Desod Axe Wom Anarchy Spy 150Ml — Ticket 77827',
      'costo', 88.8,
      'precio', 119.89,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-77827-52',
      NULL,
      88.8,
      null
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7506306226852', id from public.productos where codigo_barras = '7506306226852'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- 77827 L53 Jbn Lio Palmol Flor Czo-Rsa 221Ml
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-46657035'
     or codigo_barras = '7509546657035'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
      jsonb_build_object(
      'nombre', 'Jbn Lio Palmol Flor Czo-Rsa 221Ml',
      'sku', 'FC-46657035',
      'codigo_barras', '7509546657035',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Jbn Lio Palmol Flor Czo-Rsa 221Ml — Ticket 77827',
      'costo', 45.83,
      'precio', 61.88,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-77827-53',
      NULL,
      45.83,
      null
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7509546657035', id from public.productos where codigo_barras = '7509546657035'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- 77827 L54 Loc Limp Ponds Bio-Hydra Dual 200Ml
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-56330378'
     or codigo_barras = '7501056330378'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
      jsonb_build_object(
      'nombre', 'Loc Limp Ponds Bio-Hydra Dual 200Ml',
      'sku', 'FC-56330378',
      'codigo_barras', '7501056330378',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Loc Limp Ponds Bio-Hydra Dual 200Ml — Ticket 77827',
      'costo', 28.1,
      'precio', 37.94,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-77827-54',
      NULL,
      28.1,
      null
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7501056330378', id from public.productos where codigo_barras = '7501056330378'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- 77827 L55 Deo Mexsana P/Pies Spy 150Ml
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-76040436'
     or codigo_barras = '7502276040436'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
      jsonb_build_object(
      'nombre', 'Deo Mexsana P/Pies Spy 150Ml',
      'sku', 'FC-76040436',
      'codigo_barras', '7502276040436',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Deo Mexsana P/Pies Spy 150Ml — Ticket 77827',
      'costo', 49.29,
      'precio', 66.55,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-77827-55',
      NULL,
      49.29,
      null
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7502276040436', id from public.productos where codigo_barras = '7502276040436'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- 77827 L56 Tco Desod Odolex
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-61113000'
     or codigo_barras = '7501361113000'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
      jsonb_build_object(
      'nombre', 'Tco Desod Odolex',
      'sku', 'FC-61113000',
      'codigo_barras', '7501361113000',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Tco Desod Odolex — Ticket 77827',
      'costo', 31.77,
      'precio', 42.89,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-77827-56',
      NULL,
      31.77,
      null
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7501361113000', id from public.productos where codigo_barras = '7501361113000'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- 77827 L57 Odolex Naturals 300Gr Talco Desodorante
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-61123009'
     or codigo_barras = '7501361123009'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
      jsonb_build_object(
      'nombre', 'Odolex Naturals 300Gr Talco Desodorante',
      'sku', 'FC-61123009',
      'codigo_barras', '7501361123009',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Odolex Naturals 300Gr Talco Desodorante — Ticket 77827',
      'costo', 23.99,
      'precio', 32.39,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-77827-57',
      NULL,
      23.99,
      null
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7501361123009', id from public.productos where codigo_barras = '7501361123009'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- 77827 L58 Tiraleche De Cristal 1 Pza
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-41500096'
     or codigo_barras = '7501441500096'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
      jsonb_build_object(
      'nombre', 'Tiraleche De Cristal 1 Pza',
      'sku', 'FC-41500096',
      'codigo_barras', '7501441500096',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Tiraleche De Cristal 1 Pza — Ticket 77827',
      'costo', 80.46,
      'precio', 108.63,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-77827-58',
      NULL,
      80.46,
      null
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7501441500096', id from public.productos where codigo_barras = '7501441500096'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- 77827 L59 Sh Pert Plus Ac-Oliva 400Ml
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-20500201'
     or codigo_barras = '810120500201'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
      jsonb_build_object(
      'nombre', 'Sh Pert Plus Ac-Oliva 400Ml',
      'sku', 'FC-20500201',
      'codigo_barras', '810120500201',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Sh Pert Plus Ac-Oliva 400Ml — Ticket 77827',
      'costo', 64.12,
      'precio', 86.57,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-77827-59',
      NULL,
      64.12,
      null
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '810120500201', id from public.productos where codigo_barras = '810120500201'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- 77827 L60 Ting Polvo 85G
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-72300171'
     or codigo_barras = '7501072300171'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
      jsonb_build_object(
      'nombre', 'Ting Polvo 85G',
      'sku', 'FC-72300171',
      'codigo_barras', '7501072300171',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Ting Polvo 85G — Ticket 77827',
      'costo', 43.58,
      'precio', 58.84,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-77827-60',
      NULL,
      43.58,
      null
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7501072300171', id from public.productos where codigo_barras = '7501072300171'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- 77827 L61 Ico Desod Rexona Effi Fresh 200G
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-06217461'
     or codigo_barras = '7506306217461'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
      jsonb_build_object(
      'nombre', 'Ico Desod Rexona Effi Fresh 200G',
      'sku', 'FC-06217461',
      'codigo_barras', '7506306217461',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Ico Desod Rexona Effi Fresh 200G — Ticket 77827',
      'costo', 43.58,
      'precio', 58.84,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-77827-61',
      NULL,
      43.58,
      null
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7506306217461', id from public.productos where codigo_barras = '7506306217461'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- 77827 L62 Quita Esm Nuvel Humec 125Ml
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-82740011'
     or codigo_barras = '7501082740011'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
      jsonb_build_object(
      'nombre', 'Quita Esm Nuvel Humec 125Ml',
      'sku', 'FC-82740011',
      'codigo_barras', '7501082740011',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Quita Esm Nuvel Humec 125Ml — Ticket 77827',
      'costo', 43.58,
      'precio', 58.84,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-77827-62',
      NULL,
      43.58,
      null
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7501082740011', id from public.productos where codigo_barras = '7501082740011'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- 77827 L63 Cra Fructis Pei B-Dano Quim 300Ml
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-52910971'
     or codigo_barras = '7509552910971'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
      jsonb_build_object(
      'nombre', 'Cra Fructis Pei B-Dano Quim 300Ml',
      'sku', 'FC-52910971',
      'codigo_barras', '7509552910971',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Cra Fructis Pei B-Dano Quim 300Ml — Ticket 77827',
      'costo', 78.22,
      'precio', 105.6,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-77827-63',
      NULL,
      78.22,
      null
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7509552910971', id from public.productos where codigo_barras = '7509552910971'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- 77827 L64 Cra Fructis Pei Oil-R L-Coco 300Ml
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-52816297'
     or codigo_barras = '7509552816297'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
      jsonb_build_object(
      'nombre', 'Cra Fructis Pei Oil-R L-Coco 300Ml',
      'sku', 'FC-52816297',
      'codigo_barras', '7509552816297',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Cra Fructis Pei Oil-R L-Coco 300Ml — Ticket 77827',
      'costo', 63.05,
      'precio', 85.12,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-77827-64',
      NULL,
      63.05,
      null
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7509552816297', id from public.productos where codigo_barras = '7509552816297'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- 77827 L66 Sh Int Lomecan V 200Ml
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-40025839'
     or codigo_barras = '650240025839'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
      jsonb_build_object(
      'nombre', 'Sh Int Lomecan V 200Ml',
      'sku', 'FC-40025839',
      'codigo_barras', '650240025839',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Sh Int Lomecan V 200Ml — Ticket 77827',
      'costo', 17.2,
      'precio', 23.22,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-77827-66',
      NULL,
      17.2,
      null
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '650240025839', id from public.productos where codigo_barras = '650240025839'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- 77827 L68 Sh Int Lomecan V Aclar 200Ml
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-40030338'
     or codigo_barras = '650240030338'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '650240030338', id from public.productos where codigo_barras = '650240030338'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- 77827 L69 Silkhair Quita Esmalte Mora Azul 100Ml
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-45720550'
     or codigo_barras = '7502245720550'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7502245720550', id from public.productos where codigo_barras = '7502245720550'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- 77827 L70 Cra Nutribela1O Bio Colageno 300Gn
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-92511261'
     or codigo_barras = '7506192511261'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7506192511261', id from public.productos where codigo_barras = '7506192511261'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- 77827 L71 Cra Nutribela Nutrice Tarro 300G
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-92509213'
     or codigo_barras = '7506192509213'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7506192509213', id from public.productos where codigo_barras = '7506192509213'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- 77827 L73 Rexona 1O0Gr Tco Pies Efficient Orig
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-06257597'
     or codigo_barras = '7506306257597'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7506306257597', id from public.productos where codigo_barras = '7506306257597'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- 77827 L74 Sh Caprice Nat Mzna 380 Ml
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-46073156'
     or codigo_barras = '7509546073156'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7509546073156', id from public.productos where codigo_barras = '7509546073156'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- 77827 L75 Cra Pert Oliv+Ac Agu P/Pein 100 Ml
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-20500171'
     or codigo_barras = '810120500171'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '810120500171', id from public.productos where codigo_barras = '810120500171'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- 77827 L76 Ac Pantene Bambu 400Ml
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-35155922'
     or codigo_barras = '7500435155922'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7500435155922', id from public.productos where codigo_barras = '7500435155922'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- 77827 L78 Acono Pant Brillo Extremo 40Cml
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-07457826'
     or codigo_barras = '7501007457826'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7501007457826', id from public.productos where codigo_barras = '7501007457826'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- 77827 L79 Cra Sedal Rizos Obedie 300Ml
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-56340131'
     or codigo_barras = '7501056340131'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7501056340131', id from public.productos where codigo_barras = '7501056340131'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- 77827 L80 Acond Pant Rizos Definid 400Ml
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-01165321'
     or codigo_barras = '7501001165321'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7501001165321', id from public.productos where codigo_barras = '7501001165321'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- 77827 L81 Sh Sedal Rizos Def Inf-Act 180Ml
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-06249783'
     or codigo_barras = '7506306249783'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7506306249783', id from public.productos where codigo_barras = '7506306249783'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- 77827 L82 Tco Desod Eficc Pies 200 G
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-56360429'
     or codigo_barras = '7501056360429'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7501056360429', id from public.productos where codigo_barras = '7501056360429'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- 77827 L83 Cra Sedal Sos Recon-Estru 300Ml
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-56340025'
     or codigo_barras = '7501056340025'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7501056340025', id from public.productos where codigo_barras = '7501056340025'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- 77827 L84 Cra Sedal Rizos Obedientes 135Ml
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-56342227'
     or codigo_barras = '7501056342227'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7501056342227', id from public.productos where codigo_barras = '7501056342227'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- 77827 L85 Sh Sedal Ceramidas Inf-Act 180Ml
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-06249776'
     or codigo_barras = '7506306249776'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7506306249776', id from public.productos where codigo_barras = '7506306249776'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- 77827 L86 Sh Pant Ctrcaida A/Pv 400Ml
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-01303454'
     or codigo_barras = '7501001303454'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7501001303454', id from public.productos where codigo_barras = '7501001303454'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- 77827 L87 Sh Pant Brillo Extremo
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-07457796'
     or codigo_barras = '7501007457796'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7501007457796', id from public.productos where codigo_barras = '7501007457796'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- 77827 L89 Sh Pant Bambu Ctrl Caida 400 Ml
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-35155847'
     or codigo_barras = '7500435155847'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7500435155847', id from public.productos where codigo_barras = '7500435155847'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- 77827 L90 Sh Savile Ker-Sab Fza Repar 700Ml
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-06249240'
     or codigo_barras = '7506306249240'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7506306249240', id from public.productos where codigo_barras = '7506306249240'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- 77827 L91 Sh Savile Bio-Sab Creci Res 700Ml
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-06249226'
     or codigo_barras = '7506306249226'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7506306249226', id from public.productos where codigo_barras = '7506306249226'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- 77827 L92 Silica Shine Sil 3/1 Uva 120 Mi
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-24511629'
     or codigo_barras = '7502224511629'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7502224511629', id from public.productos where codigo_barras = '7502224511629'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- 77827 L93 Cra Sedal Anti Nudos 300 Ml
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-06234062'
     or codigo_barras = '7506306234062'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7506306234062', id from public.productos where codigo_barras = '7506306234062'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- 77827 L94 Cra Sedal Recons Estructur 135Ml
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-56342258'
     or codigo_barras = '7501056342258'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7501056342258', id from public.productos where codigo_barras = '7501056342258'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- 77827 L95 Tco Desdo Odolex 150 G
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-61111501'
     or codigo_barras = '7501361111501'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7501361111501', id from public.productos where codigo_barras = '7501361111501'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- 77827 L96 Tco Odolex Fresh 150G
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-61124013'
     or codigo_barras = '7501361124013'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7501361124013', id from public.productos where codigo_barras = '7501361124013'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- 77827 L97 Cra Sedal Sos Ceramida 300Ml
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-56340124'
     or codigo_barras = '7501056340124'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7501056340124', id from public.productos where codigo_barras = '7501056340124'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- 77827 L98 Sh Hbs Limp Renoy 375Ml
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-35020008'
     or codigo_barras = '7500435020008'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7500435020008', id from public.productos where codigo_barras = '7500435020008'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- 77827 L99 Mousse Herbal Ess Rizo 200G
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-35169035'
     or codigo_barras = '7500435169035'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7500435169035', id from public.productos where codigo_barras = '7500435169035'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- 77827 L100 Sh Hash Anti Comezon 375Ml
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-35168991'
     or codigo_barras = '7500435168991'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7500435168991', id from public.productos where codigo_barras = '7500435168991'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- 77827 L101 Sh Hash Anti Comezon 375Ml
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-35231237'
     or codigo_barras = '7500435231237'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7500435231237', id from public.productos where codigo_barras = '7500435231237'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- 77827 L102 Cera Mod Ego Met 25 G
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-92504539'
     or codigo_barras = '7506192504539'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7506192504539', id from public.productos where codigo_barras = '7506192504539'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- 77827 L103 Cera Gel Moco De Gorila Citr 100G
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-38312374'
     or codigo_barras = '7501438312374'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7501438312374', id from public.productos where codigo_barras = '7501438312374'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- 77827 L104 Sh H&S Anti Comezon 180 Ml
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-35231244'
     or codigo_barras = '7500435231244'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7500435231244', id from public.productos where codigo_barras = '7500435231244'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- 77827 L105 Sh Hbs Alivio Instant
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-35020077'
     or codigo_barras = '7500435020077'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7500435020077', id from public.productos where codigo_barras = '7500435020077'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- 77827 L106 Gel Ego Magnetic Fij-Alta 200 Ml
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-92503558'
     or codigo_barras = '7506192503558'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7506192503558', id from public.productos where codigo_barras = '7506192503558'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- 77827 L107 Gel X-Extreme Titan 250G
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-99425580'
     or codigo_barras = '7501199425580'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7501199425580', id from public.productos where codigo_barras = '7501199425580'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- 77827 L108 Gel Moco De Gorila Punk 80 G
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-99428024'
     or codigo_barras = '7501199428024'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7501199428024', id from public.productos where codigo_barras = '7501199428024'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- 77827 L109 Sh Caprice Sp Biotina Fza 200Ml
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-46073040'
     or codigo_barras = '7509546073040'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7509546073040', id from public.productos where codigo_barras = '7509546073040'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- 77827 L110 Sh Caprice Sp Acti Ceramida 200Ml
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-46073033'
     or codigo_barras = '7509546073033'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7509546073033', id from public.productos where codigo_barras = '7509546073033'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- 77827 L111 Silica Shine Sily Oleo Argan 120Ml
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-54073302'
     or codigo_barras = '7502254073302'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7502254073302', id from public.productos where codigo_barras = '7502254073302'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- 77827 L112 Silica Shine Sily 3/1 Mora 120Ml
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-24511711'
     or codigo_barras = '7502224511711'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7502224511711', id from public.productos where codigo_barras = '7502224511711'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- 77827 L113 Silica Shine Sily 3/1 Naran 12Cml
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-24511636'
     or codigo_barras = '7502224511636'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7502224511636', id from public.productos where codigo_barras = '7502224511636'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- 77827 L114 Brill Palmol Lio 115M
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-75001865'
     or codigo_barras = '75001865'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '75001865', id from public.productos where codigo_barras = '75001865'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- 77827 L115 Mousse Caprice Volum-Cirl 200 G
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-46655055'
     or codigo_barras = '7509546655055'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7509546655055', id from public.productos where codigo_barras = '7509546655055'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- 77827 L116 Gel Ego Fresh C-Cas Fij-Alt 200Ml
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-06247468'
     or codigo_barras = '7506306247468'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7506306247468', id from public.productos where codigo_barras = '7506306247468'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- 77827 L117 Gel Ego For Men Attraction 200 Ml
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-92506601'
     or codigo_barras = '7506192506601'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7506192506601', id from public.productos where codigo_barras = '7506192506601'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- 77827 L118 Cep Dent Oral-B Indicat35Sve
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-86494262'
     or codigo_barras = '7501086494262'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7501086494262', id from public.productos where codigo_barras = '7501086494262'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- 77827 L119 Cera Ego Firme Matte 25 G
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-92506045'
     or codigo_barras = '7506192506045'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7506192506045', id from public.productos where codigo_barras = '7506192506045'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- 77827 L120 Acetona Jaloma 60 Ml
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-84431050'
     or codigo_barras = '759684431050'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '759684431050', id from public.productos where codigo_barras = '759684431050'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- 77827 L121 Silkhair Quita Esmalte Coco 100 Ml
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-45720567'
     or codigo_barras = '7502245720567'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7502245720567', id from public.productos where codigo_barras = '7502245720567'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- 77827 L122 Acetona Jaloma 120 Ml
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-84437151'
     or codigo_barras = '759684437151'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '759684437151', id from public.productos where codigo_barras = '759684437151'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- 77827 L123 Protec Tocmx2.75M 1 Pza Venda De Yeso C12
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-48640775'
     or codigo_barras = '7501048640775'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7501048640775', id from public.productos where codigo_barras = '7501048640775'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- 77827 L124 Protec 15Cmx2.75M 1 Pza Venda De Yeso C12
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-48640799'
     or codigo_barras = '7501048640799'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7501048640799', id from public.productos where codigo_barras = '7501048640799'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- 77827 L125 Protec 20Cmx2.75M 1 Pza Venda De Yeso
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-46640629'
     or codigo_barras = '7501046640629'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7501046640629', id from public.productos where codigo_barras = '7501046640629'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- 77827 L126 Protec 5Cmx2.75M 1 Pza Venda De Yeso C12 Pz
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-48640751'
     or codigo_barras = '7501048640751'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7501048640751', id from public.productos where codigo_barras = '7501048640751'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- 77827 L127 Ternura Flor-Balon 18 Pzs Chupon Con Miel
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-26462078'
     or codigo_barras = '7501026462078'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7501026462078', id from public.productos where codigo_barras = '7501026462078'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- 77827 L128 Cra Nivea Sdatarr Giga 400Ml
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-54500216'
     or codigo_barras = '7501054500216'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7501054500216', id from public.productos where codigo_barras = '7501054500216'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- 77827 L129 Desod Ego Force 24H R-On 45Ml Dic26
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-75064938'
     or codigo_barras = '75064938'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '75064938', id from public.productos where codigo_barras = '75064938'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- 77827 L130 Cra Hinds Liq Agave Azul 400Ml
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-20501673'
     or codigo_barras = '810120501673'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '810120501673', id from public.productos where codigo_barras = '810120501673'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- 77827 L131 Cra Nivea B Sofmilk Sec400Ml
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-08802838'
     or codigo_barras = '4005808802838'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '4005808802838', id from public.productos where codigo_barras = '4005808802838'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- 77827 L133 Cra Grisi Conchnac P/Manos 80 Ml
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-36040450'
     or codigo_barras = '037836040450'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '037836040450', id from public.productos where codigo_barras = '037836040450'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- 77827 L134 Cra Clarant B3 Nml/Gsa 100G
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-56330309'
     or codigo_barras = '7501056330309'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7501056330309', id from public.productos where codigo_barras = '7501056330309'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- 77827 L135 Cra Nivea Cuidada Clar-Nat 200Ml
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-42270027'
     or codigo_barras = '42270027'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '42270027', id from public.productos where codigo_barras = '42270027'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- 77827 L136 Gel Niv Fac Ref Hidra Hyalu 200Ml
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-00942760'
     or codigo_barras = '4005900942760'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '4005900942760', id from public.productos where codigo_barras = '4005900942760'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- 77827 L137 Cra Corp Niveamilk 400Ml+Cra100Ml
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-54558682'
     or codigo_barras = '7501054558682'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7501054558682', id from public.productos where codigo_barras = '7501054558682'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- 77827 L138 Cra Teatrical Cel-Ma Nutrit 400Ml
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-40030963'
     or codigo_barras = '650240030963'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '650240030963', id from public.productos where codigo_barras = '650240030963'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- 77827 L139 Chupon Ternura Ortodontic Miel C3
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-26462061'
     or codigo_barras = '7501026462061'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7501026462061', id from public.productos where codigo_barras = '7501026462061'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- 77827 L140 Cra Lubriderm Uv Fps15 120Ml
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-35469151'
     or codigo_barras = '7702035469151'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7702035469151', id from public.productos where codigo_barras = '7702035469151'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- 77827 L141 Sh Grisi Ricitos Oro Biopure 250Ml
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-36032776'
     or codigo_barras = '037836032776'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '037836032776', id from public.productos where codigo_barras = '037836032776'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- 77827 L142 Jbn Johnson'S Baby Antes/Dor 75 G
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-07502441'
     or codigo_barras = '7501007502441'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7501007502441', id from public.productos where codigo_barras = '7501007502441'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- 77827 L143 Jbn Palmol N-Bal Corp Baby0% 90G
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-46655079'
     or codigo_barras = '7509546655079'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7509546655079', id from public.productos where codigo_barras = '7509546655079'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- 77827 L144 Tco Nuvel Protec Pura Para Bebe200G
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-82790016'
     or codigo_barras = '7501082790016'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7501082790016', id from public.productos where codigo_barras = '7501082790016'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- 77827 L145 Cra Hinds Hidr-Extr Almendras 500Ml
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-36041402'
     or codigo_barras = '037836041402'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '037836041402', id from public.productos where codigo_barras = '037836041402'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- 77827 L146 Cra Lubriderm Thint Psec120Ml
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-07528939'
     or codigo_barras = '7501007528939'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7501007528939', id from public.productos where codigo_barras = '7501007528939'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- 77827 L147 Cra Lubriderm P/Normal 120Ml
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-31244486'
     or codigo_barras = '7702031244486'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7702031244486', id from public.productos where codigo_barras = '7702031244486'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- 77827 L149 Sh Mennen Zero% Sve 400Ml
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-46074504'
     or codigo_barras = '7509546074504'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7509546074504', id from public.productos where codigo_barras = '7509546074504'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- 77827 L150 Sh Ricitos Oro Agua De Coco 250Ml
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-36033735'
     or codigo_barras = '037836033735'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '037836033735', id from public.productos where codigo_barras = '037836033735'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- 77827 L151 Sh Mennen Lavan-Extrac Aven 200Ml
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-46650708'
     or codigo_barras = '7509546650708'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7509546650708', id from public.productos where codigo_barras = '7509546650708'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- 77827 L152 Sh Grisi Rici Oro Miel 250Ml
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-22133286'
     or codigo_barras = '7501022133286'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7501022133286', id from public.productos where codigo_barras = '7501022133286'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- 77827 L153 Cep Dent Accion Mayo Alcan Somed
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-86472048'
     or codigo_barras = '7501086472048'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7501086472048', id from public.productos where codigo_barras = '7501086472048'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- 77827 L154 Sensodyne Protec Complet + Acc Lim Efec 90G
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-09498091'
     or codigo_barras = '7896009498091'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7896009498091', id from public.productos where codigo_barras = '7896009498091'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- 77827 L155 Cep Dent Oral-B 3Dw Advant Med2X1
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-95129166'
     or codigo_barras = '7506195129166'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7506195129166', id from public.productos where codigo_barras = '7506195129166'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- 77827 L156 Cra Nivea Cuidado Int P/Mano 75Ml
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-42417644'
     or codigo_barras = '42417644'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '42417644', id from public.productos where codigo_barras = '42417644'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- 77827 L157 Cd Sensodyne Original
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-09419324'
     or codigo_barras = '7896009419324'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7896009419324', id from public.productos where codigo_barras = '7896009419324'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- 77827 L158 Cra Teatrical Lanol/Ros 52Gr
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-40013898'
     or codigo_barras = '650240013898'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '650240013898', id from public.productos where codigo_barras = '650240013898'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- 77827 L159 Cra Corp Niv Soft M P/Seca 100Ml
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-54549819'
     or codigo_barras = '7501054549819'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7501054549819', id from public.productos where codigo_barras = '7501054549819'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- 77827 L160 Tas San Kotex Ant Flujo Abundante S/A 10Pz
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-17360604'
     or codigo_barras = '7501017360604'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7501017360604', id from public.productos where codigo_barras = '7501017360604'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- 77827 L161 Sh Mennen Miel-Mza Sve 200Ml
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-46072050'
     or codigo_barras = '7509546072050'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7509546072050', id from public.productos where codigo_barras = '7509546072050'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- 77827 L162 Jbn Ricitos D Oro Neutro 90 G
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-22150221'
     or codigo_barras = '7501022150221'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7501022150221', id from public.productos where codigo_barras = '7501022150221'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- 77827 L163 Cra Grisi Aloe Vera P/Manos 80 Mln
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-20501765'
     or codigo_barras = '810120501765'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '810120501765', id from public.productos where codigo_barras = '810120501765'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- 77827 L164 Cra S Ponds Humectante 100G
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-56326142'
     or codigo_barras = '7501056326142'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7501056326142', id from public.productos where codigo_barras = '7501056326142'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- 77827 L165 Protec Tensolastic Plus 10Cmx5M Venda Elast
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-48691005'
     or codigo_barras = '7501048691005'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7501048691005', id from public.productos where codigo_barras = '7501048691005'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- 77827 L166 Enj Buc List Anticari-Al 250Ml
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-31976394'
     or codigo_barras = '7702031976394'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7702031976394', id from public.productos where codigo_barras = '7702031976394'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- 77827 L167 Tas Sanit Kotex Nat Flex Noct C/5
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-43427754'
     or codigo_barras = '7501943427754'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7501943427754', id from public.productos where codigo_barras = '7501943427754'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- 77827 L169 Enj Buc List Care Zero Mta 250Ml
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-31887928'
     or codigo_barras = '7702031887928'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7702031887928', id from public.productos where codigo_barras = '7702031887928'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- 77827 L170 Cra Nivea Sda Tarro 100 Ml
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-54503095'
     or codigo_barras = '7501054503095'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7501054503095', id from public.productos where codigo_barras = '7501054503095'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- 77827 L171 Tas Hum Th Bebin Super C/80
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-85800198'
     or codigo_barras = '619585800198'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '619585800198', id from public.productos where codigo_barras = '619585800198'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- 77827 L172 Cep Dent Clinic Adulto Med 40 C12
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-72629012'
     or codigo_barras = '7501072629012'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7501072629012', id from public.productos where codigo_barras = '7501072629012'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- 77827 L173 Enj Buc List Zero Mta Sve 250Ml
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-10974329'
     or codigo_barras = '7891010974329'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7891010974329', id from public.productos where codigo_barras = '7891010974329'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- 77827 L174 Nivea 75Ml Cra P/Manos 3En1 Ant-Arrugas
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-00701992'
     or codigo_barras = '4005900701992'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '4005900701992', id from public.productos where codigo_barras = '4005900701992'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- 77827 L175 Jbn Mennen Baby Magic Lavan 90 G
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-46655727'
     or codigo_barras = '7509546655727'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7509546655727', id from public.productos where codigo_barras = '7509546655727'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- 77827 L177 Tco Mennen Azul 200G
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-35908130'
     or codigo_barras = '7501035908130'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7501035908130', id from public.productos where codigo_barras = '7501035908130'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- 77827 L178 Protec Tensolastic Plus 15Cmx5M Venda Elast
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-48691104'
     or codigo_barras = '7501048691104'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7501048691104', id from public.productos where codigo_barras = '7501048691104'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- 77827 L179 Tco Mennen Rosa 200G
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-35908147'
     or codigo_barras = '7501035908147'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7501035908147', id from public.productos where codigo_barras = '7501035908147'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- 77827 L180 Tas Sanit Saba Inv Alas C/10
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-19006371'
     or codigo_barras = '7501019006371'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7501019006371', id from public.productos where codigo_barras = '7501019006371'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- 77827 L181 Bebin Super 4Opzs Toallitas Humedas
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-85103015'
     or codigo_barras = '619585103015'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '619585103015', id from public.productos where codigo_barras = '619585103015'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- 77827 L182 Protec Tensolastic Plus 5Cmx5M Venda Elasti
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-48690800'
     or codigo_barras = '7501048690800'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7501048690800', id from public.productos where codigo_barras = '7501048690800'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- 77827 L183 C D Sensodyne Rapido Alivio 100G
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-40171550'
     or codigo_barras = '7794640171550'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
      jsonb_build_object(
      'nombre', 'C D Sensodyne Rapido Alivio 100G',
      'sku', 'FC-40171550',
      'codigo_barras', '7794640171550',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'C D Sensodyne Rapido Alivio 100G — Ticket 77827',
      'costo', 405.32,
      'precio', 547.19,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-77827-183',
      NULL,
      405.32,
      null
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7794640171550', id from public.productos where codigo_barras = '7794640171550'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- 77827 L184 Protec Tensolastic Plus 7Cmx5M Venda Elasti
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-48690909'
     or codigo_barras = '7501048690909'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
      jsonb_build_object(
      'nombre', 'Protec Tensolastic Plus 7Cmx5M Venda Elasti',
      'sku', 'FC-48690909',
      'codigo_barras', '7501048690909',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Protec Tensolastic Plus 7Cmx5M Venda Elasti — Ticket 77827',
      'costo', 405.32,
      'precio', 547.19,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-77827-184',
      NULL,
      405.32,
      null
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7501048690909', id from public.productos where codigo_barras = '7501048690909'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- 112558 L1 DIBAR ALCOHOL 125ML ROJO
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-68900264'
     or codigo_barras = '7501868900264'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7501868900264', id from public.productos where codigo_barras = '7501868900264'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- 112558 L2 DIBAR ALCOHOL ILT ROJO
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-68960257'
     or codigo_barras = '7501868960257'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7501868960257', id from public.productos where codigo_barras = '7501868960257'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- 112558 L3 ADIBAR ALCOHOL 250ML. ROJO
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-68900226'
     or codigo_barras = '7501868900226'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7501868900226', id from public.productos where codigo_barras = '7501868900226'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- 112558 L4 DIBAR ALCOHOL 500ML. ROJO
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-68990023'
     or codigo_barras = '7501868990023'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7501868990023', id from public.productos where codigo_barras = '7501868990023'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- 112558 L5 AGUA DESTILADA LA FLOR 1 LT
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-77620056'
     or codigo_barras = '7501677620056'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7501677620056', id from public.productos where codigo_barras = '7501677620056'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- 112558 L6 ARNICA MERCURIO
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-00003920'
     or codigo_barras = '3311000003920'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '3311000003920', id from public.productos where codigo_barras = '3311000003920'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- 112558 L7 CREMA AMARILLA VITACILINA ACLARADORA
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-76000260'
     or codigo_barras = '7506376000260'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7506376000260', id from public.productos where codigo_barras = '7506376000260'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

commit;
