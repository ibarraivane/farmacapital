-- PASO FINAL 3/3 — Completar inventario (idempotente)
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



-- FL-080826 L73 Panuelos Leenex C/90 | Kimberly Clark 25. $ Descto
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-56131681'
     or codigo_barras = '75064256131681'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '75064256131681', id from public.productos where codigo_barras = '75064256131681'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- FL-080826 L74 Cremi Dent Colgate Triple Acc 75 Ml Colgate Paimol
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-60009851'
     or codigo_barras = '75095460009851'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
      jsonb_build_object(
      'nombre', 'Cremi Dent Colgate Triple Acc 75 Ml Colgate Paimolive $ 19.20 Descto: 2.0K $ 18.82 Dent Colgate Triple Acc 75 Ml Colgate',
      'sku', 'FC-60009851',
      'codigo_barras', '75095460009851',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Cremi Dent Colgate Triple Acc 75 Ml Colgate Paimolive $ 19.20 Descto: 2.0K $ 18.82 Dent Colgate Triple Acc 75 Ml Colgate — Ticket FL-080826',
      'costo', 19.2,
      'precio', 25.92,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-74',
      NULL,
      19.2,
      null
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '75095460009851', id from public.productos where codigo_barras = '75095460009851'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- FL-080826 L75 Jeringa Sens Imedicai Insul 0.5 Ml C/100 | Jayor 1
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-23273451'
     or codigo_barras = '75060223273451'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
      jsonb_build_object(
      'nombre', 'Jeringa Sens Imedicai Insul 0.5 Ml C/100 | Jayor 1 $ 217.20 Jeringa Sens Imedicai Insul 0.5 Ml',
      'sku', 'FC-23273451',
      'codigo_barras', '75060223273451',
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'Jeringa Sens Imedicai Insul 0.5 Ml C/100 | Jayor 1 $ 217.20 Jeringa Sens Imedicai Insul 0.5 Ml — Ticket FL-080826',
      'costo', 217.2,
      'precio', 293.23,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-75',
      NULL,
      217.2,
      null
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '75060223273451', id from public.productos where codigo_barras = '75060223273451'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- FL-080826 L76 Bib Evenelo Ensueno Azul 802 | Kimberly Clark 1 $ 
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-75163051'
     or codigo_barras = '75010275163051'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
      jsonb_build_object(
      'nombre', 'Bib Evenelo Ensueno Azul 802 | Kimberly Clark 1 $ 15.80 Descto: 2.0K Bib Evenelo Ensueno Azul 802 | Kimberly Clark',
      'sku', 'FC-75163051',
      'codigo_barras', '75010275163051',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Bib Evenelo Ensueno Azul 802 | Kimberly Clark 1 $ 15.80 Descto: 2.0K Bib Evenelo Ensueno Azul 802 | Kimberly Clark — Ticket FL-080826',
      'costo', 15.8,
      'precio', 21.33,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-76',
      NULL,
      15.8,
      null
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '75010275163051', id from public.productos where codigo_barras = '75010275163051'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- FL-080826 L77 Bib Evenelo Colors 8 02 | Kimberly Clark $ 15.80 D
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-27512574'
     or codigo_barras = '7501027512574'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
      jsonb_build_object(
      'nombre', 'Bib Evenelo Colors 8 02 | Kimberly Clark $ 15.80 Descto: 2.0% $ 15.48 $ 47.40 Colors 8 02 | Kimberly Clark',
      'sku', 'FC-27512574',
      'codigo_barras', '7501027512574',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Bib Evenelo Colors 8 02 | Kimberly Clark $ 15.80 Descto: 2.0% $ 15.48 $ 47.40 Colors 8 02 | Kimberly Clark — Ticket FL-080826',
      'costo', 15.8,
      'precio', 21.33,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-77',
      NULL,
      15.8,
      null
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7501027512574', id from public.productos where codigo_barras = '7501027512574'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- FL-080826 L78 Bib Evenelo Colors 4 02 Kimberly Clark $ 13.40 Des
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-75125811'
     or codigo_barras = '75010275125811'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
      jsonb_build_object(
      'nombre', 'Bib Evenelo Colors 4 02 Kimberly Clark $ 13.40 Descto: 2.0* $ 13.13 40.20 Colors 4 02 Kimberly Clark Cepillo 17702010631',
      'sku', 'FC-75125811',
      'codigo_barras', '75010275125811',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Bib Evenelo Colors 4 02 Kimberly Clark $ 13.40 Descto: 2.0* $ 13.13 40.20 Colors 4 02 Kimberly Clark Cepillo 17702010631 — Ticket FL-080826',
      'costo', 13.4,
      'precio', 18.1,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-78',
      NULL,
      13.4,
      null
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '75010275125811', id from public.productos where codigo_barras = '75010275125811'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- FL-080826 L79 Algodon Quirmex Quirmex Descto: 2.0% Torunda De 76
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-34067851'
     or codigo_barras = '75030034067851'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
      jsonb_build_object(
      'nombre', 'Algodon Quirmex Quirmex Descto: 2.0% Torunda De 76 Algodon Quirmex Quirmex Torunda De',
      'sku', 'FC-34067851',
      'codigo_barras', '75030034067851',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Algodon Quirmex Quirmex Descto: 2.0% Torunda De 76 Algodon Quirmex Quirmex Torunda De — Ticket FL-080826',
      'costo', 17.54,
      'precio', 23.68,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-79',
      NULL,
      17.54,
      null
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '75030034067851', id from public.productos where codigo_barras = '75030034067851'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- FL-080826 L80 Pads Facial Protec Redondos C/100 | Degasa 2 $ 21.
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-48623006'
     or codigo_barras = '7501048623006'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
      jsonb_build_object(
      'nombre', 'Pads Facial Protec Redondos C/100 | Degasa 2 $ 21.70 Pads Facial Protec Redondos C/100 | Degasa',
      'sku', 'FC-48623006',
      'codigo_barras', '7501048623006',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Pads Facial Protec Redondos C/100 | Degasa 2 $ 21.70 Pads Facial Protec Redondos C/100 | Degasa — Ticket FL-080826',
      'costo', 21.7,
      'precio', 29.3,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-80',
      NULL,
      21.7,
      null
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7501048623006', id from public.productos where codigo_barras = '7501048623006'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- FL-080826 L81 Jeringa Sensimedical Insul 0.3 Ml C/100 | Jayor 1 
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-23272151'
     or codigo_barras = '75060223272151'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
      jsonb_build_object(
      'nombre', 'Jeringa Sensimedical Insul 0.3 Ml C/100 | Jayor 1 $ Jeringa Sensimedical Insul 0.3 Ml',
      'sku', 'FC-23272151',
      'codigo_barras', '75060223272151',
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'Jeringa Sensimedical Insul 0.3 Ml C/100 | Jayor 1 $ Jeringa Sensimedical Insul 0.3 Ml — Ticket FL-080826',
      'costo', 212.86,
      'precio', 287.37,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-81',
      NULL,
      212.86,
      null
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '75060223272151', id from public.productos where codigo_barras = '75060223272151'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- FL-080826 L82 Algodon Dibar 5 Gr Dibar 12 $ 6.90 Descto: 2.0% $ 
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-68910041'
     or codigo_barras = '7501868910041'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
      jsonb_build_object(
      'nombre', 'Algodon Dibar 5 Gr Dibar 12 $ 6.90 Descto: 2.0% $ 6.76 $ 82.80 5 Gr Dibar',
      'sku', 'FC-68910041',
      'codigo_barras', '7501868910041',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Algodon Dibar 5 Gr Dibar 12 $ 6.90 Descto: 2.0% $ 6.76 $ 82.80 5 Gr Dibar — Ticket FL-080826',
      'costo', 0.58,
      'precio', 0.79,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      12,
      'TK-FL-080826-82',
      NULL,
      0.58,
      null
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7501868910041', id from public.productos where codigo_barras = '7501868910041'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- FL-080826 L83 Algodon Dibar 200 Gr Dibak 2 $ 35.30 Descto: 2.0% 
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-89100101'
     or codigo_barras = '75018689100101'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
      jsonb_build_object(
      'nombre', 'Algodon Dibar 200 Gr Dibak 2 $ 35.30 Descto: 2.0% $ 34.59 70.60 200 Gr Dibak',
      'sku', 'FC-89100101',
      'codigo_barras', '75018689100101',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Algodon Dibar 200 Gr Dibak 2 $ 35.30 Descto: 2.0% $ 34.59 70.60 200 Gr Dibak — Ticket FL-080826',
      'costo', 17.65,
      'precio', 23.83,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      2,
      'TK-FL-080826-83',
      NULL,
      17.65,
      null
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '75018689100101', id from public.productos where codigo_barras = '75018689100101'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- FL-080826 L84 Venda Quirmex 7.5 Cm | Quirmex 12 $ 6.80 Descto: 2
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-34067301'
     or codigo_barras = '75030034067301'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
      jsonb_build_object(
      'nombre', 'Venda Quirmex 7.5 Cm | Quirmex 12 $ 6.80 Descto: 2.0% $ 6.66 7.5 Cm | Quirmex 5 50300340R7231 Venda Quirmex Cm | Quirmex',
      'sku', 'FC-34067301',
      'codigo_barras', '75030034067301',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Venda Quirmex 7.5 Cm | Quirmex 12 $ 6.80 Descto: 2.0% $ 6.66 7.5 Cm | Quirmex 5 50300340R7231 Venda Quirmex Cm | Quirmex — Ticket FL-080826',
      'costo', 0.57,
      'precio', 0.77,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      12,
      'TK-FL-080826-84',
      NULL,
      0.57,
      null
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '75030034067301', id from public.productos where codigo_barras = '75030034067301'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- FL-080826 L85 Venda Quirme) Lo Cm Quirmex 8.90 Descto: 2.0% $ 8.
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-34067471'
     or codigo_barras = '75030034067471'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
      jsonb_build_object(
      'nombre', 'Venda Quirme) Lo Cm Quirmex 8.90 Descto: 2.0% $ 8.72 Lo Cm Quirmex',
      'sku', 'FC-34067471',
      'codigo_barras', '75030034067471',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Venda Quirme) Lo Cm Quirmex 8.90 Descto: 2.0% $ 8.72 Lo Cm Quirmex — Ticket FL-080826',
      'costo', 8.72,
      'precio', 11.78,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-85',
      NULL,
      8.72,
      null
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '75030034067471', id from public.productos where codigo_barras = '75030034067471'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- FL-080826 L86 Venda Quirmex 30 Cm | Quirmex 24.20 Descto: 2.0% $
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-34067781'
     or codigo_barras = '75030034067781'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
      jsonb_build_object(
      'nombre', 'Venda Quirmex 30 Cm | Quirmex 24.20 Descto: 2.0% $ 23.72 96.80 30 Cm | Quirmex Dibar Algodon Dibar',
      'sku', 'FC-34067781',
      'codigo_barras', '75030034067781',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Venda Quirmex 30 Cm | Quirmex 24.20 Descto: 2.0% $ 23.72 96.80 30 Cm | Quirmex Dibar Algodon Dibar — Ticket FL-080826',
      'costo', 23.72,
      'precio', 32.03,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-86',
      NULL,
      23.72,
      null
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '75030034067781', id from public.productos where codigo_barras = '75030034067781'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- FL-080826 L87 60 Gr | Dibar Descto: 2.0% Algodon Dibar $ 10.10 6
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-68910034'
     or codigo_barras = '7501868910034'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
      jsonb_build_object(
      'nombre', '60 Gr | Dibar Descto: 2.0% Algodon Dibar $ 10.10 60 Gr | Dibar Algodon Dibar',
      'sku', 'FC-68910034',
      'codigo_barras', '7501868910034',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', '60 Gr | Dibar Descto: 2.0% Algodon Dibar $ 10.10 60 Gr | Dibar Algodon Dibar — Ticket FL-080826',
      'costo', 10.1,
      'precio', 13.64,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-87',
      NULL,
      10.1,
      null
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7501868910034', id from public.productos where codigo_barras = '7501868910034'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- FL-080826 L88 Crema Dent Colgate Total Colgate Palmolive $ Colga
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-66534951'
     or codigo_barras = '75095466534951'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
      jsonb_build_object(
      'nombre', 'Crema Dent Colgate Total Colgate Palmolive $ Colgate Total Colgate',
      'sku', 'FC-66534951',
      'codigo_barras', '75095466534951',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Crema Dent Colgate Total Colgate Palmolive $ Colgate Total Colgate — Ticket FL-080826',
      'costo', 22.93,
      'precio', 30.96,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-88',
      NULL,
      22.93,
      null
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '75095466534951', id from public.productos where codigo_barras = '75095466534951'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- FL-080826 L89 Gel Antibacterial Protec 250 Ml Degasa 22.40 Antib
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-83510531'
     or codigo_barras = '75010483510531'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
      jsonb_build_object(
      'nombre', 'Gel Antibacterial Protec 250 Ml Degasa 22.40 Antibacterial Protec 250 Ml Degasa',
      'sku', 'FC-83510531',
      'codigo_barras', '75010483510531',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Gel Antibacterial Protec 250 Ml Degasa 22.40 Antibacterial Protec 250 Ml Degasa — Ticket FL-080826',
      'costo', 123.58,
      'precio', 166.84,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-89',
      NULL,
      123.58,
      null
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '75010483510531', id from public.productos where codigo_barras = '75010483510531'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- FL-080826 L90 Gasa Dibar 10X10 Paq 10 Cajitas/10 126.10 Dibar Ga
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-68900127'
     or codigo_barras = '7501868900127'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
      jsonb_build_object(
      'nombre', 'Gasa Dibar 10X10 Paq 10 Cajitas/10 126.10 Dibar Gasa Dibar 10X10 Paq 10 Cajitas/10',
      'sku', 'FC-68900127',
      'codigo_barras', '7501868900127',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Gasa Dibar 10X10 Paq 10 Cajitas/10 126.10 Dibar Gasa Dibar 10X10 Paq 10 Cajitas/10 — Ticket FL-080826',
      'costo', 123.58,
      'precio', 166.84,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-90',
      NULL,
      123.58,
      null
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7501868900127', id from public.productos where codigo_barras = '7501868900127'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- FL-080826 L91 Lox10 Exh C/100 Descto: 2.0% Gasa Dibar Dibar 111.
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-68900134'
     or codigo_barras = '7501868900134'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
      jsonb_build_object(
      'nombre', 'Lox10 Exh C/100 Descto: 2.0% Gasa Dibar Dibar 111.10 Lox10 Exh C/100 Gasa Dibar Dibar',
      'sku', 'FC-68900134',
      'codigo_barras', '7501868900134',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Lox10 Exh C/100 Descto: 2.0% Gasa Dibar Dibar 111.10 Lox10 Exh C/100 Gasa Dibar Dibar — Ticket FL-080826',
      'costo', 108.88,
      'precio', 146.99,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-91',
      NULL,
      108.88,
      null
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7501868900134', id from public.productos where codigo_barras = '7501868900134'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- FL-080826 L92 Espuma 120 Mi Descto: 2.0% Dermodine Degasa Espuma
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-50882017'
     or codigo_barras = '7501250882017'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
      jsonb_build_object(
      'nombre', 'Espuma 120 Mi Descto: 2.0% Dermodine Degasa Espuma 120 Mi Dermodine',
      'sku', 'FC-50882017',
      'codigo_barras', '7501250882017',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Espuma 120 Mi Descto: 2.0% Dermodine Degasa Espuma 120 Mi Dermodine — Ticket FL-080826',
      'costo', 75.2,
      'precio', 101.53,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-92',
      NULL,
      75.2,
      null
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7501250882017', id from public.productos where codigo_barras = '7501250882017'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- FL-080826 L93 0 Dermod Ine M 1 Degasa 37.60 Dermod Ine Degasa
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-08820243'
     or codigo_barras = '75012508820243'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
      jsonb_build_object(
      'nombre', '0 Dermod Ine M 1 Degasa 37.60 Dermod Ine Degasa',
      'sku', 'FC-08820243',
      'codigo_barras', '75012508820243',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', '0 Dermod Ine M 1 Degasa 37.60 Dermod Ine Degasa — Ticket FL-080826',
      'costo', 36.85,
      'precio', 49.75,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-93',
      NULL,
      36.85,
      null
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '75012508820243', id from public.productos where codigo_barras = '75012508820243'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- FL-080826 L94 Cre Vitacilina Humectante 100 Gr Vitacilina Humect
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-76000277'
     or codigo_barras = '7506376000277'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
      jsonb_build_object(
      'nombre', 'Cre Vitacilina Humectante 100 Gr Vitacilina Humectante',
      'sku', 'FC-76000277',
      'codigo_barras', '7506376000277',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Cre Vitacilina Humectante 100 Gr Vitacilina Humectante — Ticket FL-080826',
      'costo', 77.03,
      'precio', 104.0,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-94',
      NULL,
      77.03,
      null
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7506376000277', id from public.productos where codigo_barras = '7506376000277'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- FL-080826 L95 0 Stick Tripack Des Old Spice Gr Pg Pere Descto: 2
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-51444145'
     or codigo_barras = '75004351444145'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
      jsonb_build_object(
      'nombre', '0 Stick Tripack Des Old Spice Gr Pg Pere Descto: 2.0% Stick Tripack Des Old Spice Pg Pere',
      'sku', 'FC-51444145',
      'codigo_barras', '75004351444145',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', '0 Stick Tripack Des Old Spice Gr Pg Pere Descto: 2.0% Stick Tripack Des Old Spice Pg Pere — Ticket FL-080826',
      'costo', 135.73,
      'precio', 183.24,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-95',
      NULL,
      135.73,
      null
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '75004351444145', id from public.productos where codigo_barras = '75004351444145'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- FL-080826 L96 Jermocleen Agua Oxigenada 230Ml Degasa Jermocleen 
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-83351691'
     or codigo_barras = '75010483351691'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
      jsonb_build_object(
      'nombre', 'Jermocleen Agua Oxigenada 230Ml Degasa Jermocleen Agua Oxigenada',
      'sku', 'FC-83351691',
      'codigo_barras', '75010483351691',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Jermocleen Agua Oxigenada 230Ml Degasa Jermocleen Agua Oxigenada — Ticket FL-080826',
      'costo', 10.19,
      'precio', 13.76,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-96',
      NULL,
      10.19,
      null
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '75010483351691', id from public.productos where codigo_barras = '75010483351691'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- FL-080826 L97 Dermocleen Agua Oxigenada 100Ml | Degasa $ Dermocl
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-83351381'
     or codigo_barras = '75010483351381'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
      jsonb_build_object(
      'nombre', 'Dermocleen Agua Oxigenada 100Ml | Degasa $ Dermocleen Agua Oxigenada 100Ml',
      'sku', 'FC-83351381',
      'codigo_barras', '75010483351381',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Dermocleen Agua Oxigenada 100Ml | Degasa $ Dermocleen Agua Oxigenada 100Ml — Ticket FL-080826',
      'costo', 7.64,
      'precio', 10.32,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-97',
      NULL,
      7.64,
      null
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '75010483351381', id from public.productos where codigo_barras = '75010483351381'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- FL-080826 L98 Pedialyte Sr60 Uva 500 Mi Abbott $ 24.30 Pedialyte
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-33956775'
     or codigo_barras = '7501033956775'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
      jsonb_build_object(
      'nombre', 'Pedialyte Sr60 Uva 500 Mi Abbott $ 24.30 Pedialyte Sr60 Uva 500 Mi',
      'sku', 'FC-33956775',
      'codigo_barras', '7501033956775',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Pedialyte Sr60 Uva 500 Mi Abbott $ 24.30 Pedialyte Sr60 Uva 500 Mi — Ticket FL-080826',
      'costo', 24.3,
      'precio', 32.81,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-98',
      NULL,
      24.3,
      null
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7501033956775', id from public.productos where codigo_barras = '7501033956775'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- FL-080826 L99 Fresa 500 Pedialyte Sr60 Ml Abbott $ Fresa 500 Ped
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-33961373'
     or codigo_barras = '7501033961373'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
      jsonb_build_object(
      'nombre', 'Fresa 500 Pedialyte Sr60 Ml Abbott $ Fresa 500 Pedialyte Sr60 Abbott',
      'sku', 'FC-33961373',
      'codigo_barras', '7501033961373',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Fresa 500 Pedialyte Sr60 Ml Abbott $ Fresa 500 Pedialyte Sr60 Abbott — Ticket FL-080826',
      'costo', 23.81,
      'precio', 32.15,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-99',
      NULL,
      23.81,
      null
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7501033961373', id from public.productos where codigo_barras = '7501033961373'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- FL-080826 L100 Agua Oxigenada Dermocleen 480Ml | Degasa 15.00 Agu
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-48335305'
     or codigo_barras = '7501048335305'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
      jsonb_build_object(
      'nombre', 'Agua Oxigenada Dermocleen 480Ml | Degasa 15.00 Agua Oxigenada Dermocleen 480Ml',
      'sku', 'FC-48335305',
      'codigo_barras', '7501048335305',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Agua Oxigenada Dermocleen 480Ml | Degasa 15.00 Agua Oxigenada Dermocleen 480Ml — Ticket FL-080826',
      'costo', 14.7,
      'precio', 19.85,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-100',
      NULL,
      14.7,
      null
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7501048335305', id from public.productos where codigo_barras = '7501048335305'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- FL-080826 L101 Manzana 500 Ml Descto: 2.0% Pedialyte Manzana 500 
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-33954740'
     or codigo_barras = '7501033954740'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
      jsonb_build_object(
      'nombre', 'Manzana 500 Ml Descto: 2.0% Pedialyte Manzana 500 Ml Pedialyte',
      'sku', 'FC-33954740',
      'codigo_barras', '7501033954740',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Manzana 500 Ml Descto: 2.0% Pedialyte Manzana 500 Ml Pedialyte — Ticket FL-080826',
      'costo', 23.81,
      'precio', 32.15,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-101',
      NULL,
      23.81,
      null
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7501033954740', id from public.productos where codigo_barras = '7501033954740'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- FL-080826 L102 Inder 360 Gf Descto: 2.0% Leche Nido Marcas Nestle
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-59225411'
     or codigo_barras = '7501059225411'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
      jsonb_build_object(
      'nombre', 'Inder 360 Gf Descto: 2.0% Leche Nido Marcas Nestle Inder 360 Gf Leche Nido Marcas',
      'sku', 'FC-59225411',
      'codigo_barras', '7501059225411',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Inder 360 Gf Descto: 2.0% Leche Nido Marcas Nestle Inder 360 Gf Leche Nido Marcas — Ticket FL-080826',
      'costo', 74.19,
      'precio', 100.16,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-102',
      NULL,
      74.19,
      null
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7501059225411', id from public.productos where codigo_barras = '7501059225411'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- FL-080826 L103 360 Gr | Marcas Descto: 2.0% Leche Nidal 1 Nestle 
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-51067711'
     or codigo_barras = '75064751067711'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
      jsonb_build_object(
      'nombre', '360 Gr | Marcas Descto: 2.0% Leche Nidal 1 Nestle $ 112.70 360 Gr | Marcas Leche Nidal 1 Nestle',
      'sku', 'FC-51067711',
      'codigo_barras', '75064751067711',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', '360 Gr | Marcas Descto: 2.0% Leche Nidal 1 Nestle $ 112.70 360 Gr | Marcas Leche Nidal 1 Nestle — Ticket FL-080826',
      'costo', 112.7,
      'precio', 152.15,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-103',
      NULL,
      112.7,
      null
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '75064751067711', id from public.productos where codigo_barras = '75064751067711'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- FL-080826 L104 Nestum Probioticos Marcas Nestle Avena 270 Nestum 
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-86167151'
     or codigo_barras = '75010586167151'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '75010586167151', id from public.productos where codigo_barras = '75010586167151'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- FL-080826 L105 Nutri Rindes Leche Nido Marcas Nestle Bolsa 240 Gr
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-92821171'
     or codigo_barras = '75010592821171'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
      jsonb_build_object(
      'nombre', 'Nutri Rindes Leche Nido Marcas Nestle Bolsa 240 Gr Nutri Rindes Leche Nido Marcas Nestle',
      'sku', 'FC-92821171',
      'codigo_barras', '75010592821171',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Nutri Rindes Leche Nido Marcas Nestle Bolsa 240 Gr Nutri Rindes Leche Nido Marcas Nestle — Ticket FL-080826',
      'costo', 30.67,
      'precio', 41.41,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-105',
      NULL,
      30.67,
      null
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '75010592821171', id from public.productos where codigo_barras = '75010592821171'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- FL-080826 L106 Nutri Rindes Leche Nido Marcas Nestle Bolsa Nutri 
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-58611420'
     or codigo_barras = '7501058611420'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
      jsonb_build_object(
      'nombre', 'Nutri Rindes Leche Nido Marcas Nestle Bolsa Nutri Rindes Leche Nido',
      'sku', 'FC-58611420',
      'codigo_barras', '7501058611420',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Nutri Rindes Leche Nido Marcas Nestle Bolsa Nutri Rindes Leche Nido — Ticket FL-080826',
      'costo', 53.7,
      'precio', 72.5,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-106',
      NULL,
      53.7,
      null
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7501058611420', id from public.productos where codigo_barras = '7501058611420'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- FL-080826 L107 Öpt Imal Leche Nan 1 Marcas Pro Öpt Imal Leche Nan
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-51078461'
     or codigo_barras = '75064751078461'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
      jsonb_build_object(
      'nombre', 'Öpt Imal Leche Nan 1 Marcas Pro Öpt Imal Leche Nan 1',
      'sku', 'FC-51078461',
      'codigo_barras', '75064751078461',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Öpt Imal Leche Nan 1 Marcas Pro Öpt Imal Leche Nan 1 — Ticket FL-080826',
      'costo', 129.4,
      'precio', 174.7,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-107',
      NULL,
      129.4,
      null
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '75064751078461', id from public.productos where codigo_barras = '75064751078461'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- FL-080826 L108 Öptimal Marcas Nestle Bolsa Leche Nan 2 Gr Öptimal
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-51078531'
     or codigo_barras = '75064751078531'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
      jsonb_build_object(
      'nombre', 'Öptimal Marcas Nestle Bolsa Leche Nan 2 Gr Öptimal Marcas Nestle Bolsa',
      'sku', 'FC-51078531',
      'codigo_barras', '75064751078531',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Öptimal Marcas Nestle Bolsa Leche Nan 2 Gr Öptimal Marcas Nestle Bolsa — Ticket FL-080826',
      'costo', 58.7,
      'precio', 79.25,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-108',
      NULL,
      58.7,
      null
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '75064751078531', id from public.productos where codigo_barras = '75064751078531'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- FL-080826 L109 Vaso Recolector I Quirmex Quirmex Descto: 2.0% $ 3
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-29003221'
     or codigo_barras = '75065529003221'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
      jsonb_build_object(
      'nombre', 'Vaso Recolector I Quirmex Quirmex Descto: 2.0% $ 3.70 Recolector I Quirmex Quirmex',
      'sku', 'FC-29003221',
      'codigo_barras', '75065529003221',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Vaso Recolector I Quirmex Quirmex Descto: 2.0% $ 3.70 Recolector I Quirmex Quirmex — Ticket FL-080826',
      'costo', 3.7,
      'precio', 5.0,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-109',
      NULL,
      3.7,
      null
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '75065529003221', id from public.productos where codigo_barras = '75065529003221'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- FL-080826 L110 525 Ml | Lab Pisa Electrolit Uva $ 20,50 Descto: 2
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-51448511'
     or codigo_barras = '75011251448511'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
      jsonb_build_object(
      'nombre', '525 Ml | Lab Pisa Electrolit Uva $ 20,50 Descto: 2.0% $ 20.09 525 Ml | Lab Pisa Electrolit Uva',
      'sku', 'FC-51448511',
      'codigo_barras', '75011251448511',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', '525 Ml | Lab Pisa Electrolit Uva $ 20,50 Descto: 2.0% $ 20.09 525 Ml | Lab Pisa Electrolit Uva — Ticket FL-080826',
      'costo', 20.5,
      'precio', 27.68,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-110',
      NULL,
      20.5,
      null
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '75011251448511', id from public.productos where codigo_barras = '75011251448511'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- FL-080826 L111 Electrolit Coco 625 Ml Lab Pisa 20.50 Descto: 2.0%
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-25104411'
     or codigo_barras = '7501125104411'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
      jsonb_build_object(
      'nombre', 'Electrolit Coco 625 Ml Lab Pisa 20.50 Descto: 2.0% Electrolit Coco 625 Ml Pisa',
      'sku', 'FC-25104411',
      'codigo_barras', '7501125104411',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Electrolit Coco 625 Ml Lab Pisa 20.50 Descto: 2.0% Electrolit Coco 625 Ml Pisa — Ticket FL-080826',
      'costo', 20.09,
      'precio', 27.13,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-111',
      NULL,
      20.09,
      null
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7501125104411', id from public.productos where codigo_barras = '7501125104411'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- FL-080826 L112 Electrolit Eresa-Kiwi 625 Ml | Lab Pisa 2 20.50 El
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-25149221'
     or codigo_barras = '7501125149221'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
      jsonb_build_object(
      'nombre', 'Electrolit Eresa-Kiwi 625 Ml | Lab Pisa 2 20.50 Electrolit Eresa-Kiwi 625 Ml | Lab Pisa',
      'sku', 'FC-25149221',
      'codigo_barras', '7501125149221',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Electrolit Eresa-Kiwi 625 Ml | Lab Pisa 2 20.50 Electrolit Eresa-Kiwi 625 Ml | Lab Pisa — Ticket FL-080826',
      'costo', 20.09,
      'precio', 27.13,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-112',
      NULL,
      20.09,
      null
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7501125149221', id from public.productos where codigo_barras = '7501125149221'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- FL-080826 L113 Electrolit Èresa 625 Mi | Lab Pisa $ 20.50 Descto:
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-25104268'
     or codigo_barras = '7501125104268'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
      jsonb_build_object(
      'nombre', 'Electrolit Èresa 625 Mi | Lab Pisa $ 20.50 Descto: 2.0K $ 20.09 [75011251747971 Electrolid Èresa 625 Mi | Lab Pisa',
      'sku', 'FC-25104268',
      'codigo_barras', '7501125104268',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Electrolit Èresa 625 Mi | Lab Pisa $ 20.50 Descto: 2.0K $ 20.09 [75011251747971 Electrolid Èresa 625 Mi | Lab Pisa — Ticket FL-080826',
      'costo', 20.5,
      'precio', 27.68,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-113',
      NULL,
      20.5,
      null
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7501125104268', id from public.productos where codigo_barras = '7501125104268'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- FL-080826 L114 Electrolid Mora Azul 625 Ml | Lab Pisa 2 $ 20.50 D
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-51747971'
     or codigo_barras = '75011251747971'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
      jsonb_build_object(
      'nombre', 'Electrolid Mora Azul 625 Ml | Lab Pisa 2 $ 20.50 Descto: 2.0K $ 20.09 Mora Azul 625 Ml | Lab Pisa',
      'sku', 'FC-51747971',
      'codigo_barras', '75011251747971',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Electrolid Mora Azul 625 Ml | Lab Pisa 2 $ 20.50 Descto: 2.0K $ 20.09 Mora Azul 625 Ml | Lab Pisa — Ticket FL-080826',
      'costo', 20.5,
      'precio', 27.68,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-114',
      NULL,
      20.5,
      null
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '75011251747971', id from public.productos where codigo_barras = '75011251747971'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- FL-080826 L115 Absorsec C/120 Clark Descto: 2.0% Toa Hum Kimberly
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-43471900'
     or codigo_barras = '7501943471900'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
      jsonb_build_object(
      'nombre', 'Absorsec C/120 Clark Descto: 2.0% Toa Hum Kimberly Absorsec C/120 Clark Toa Hum',
      'sku', 'FC-43471900',
      'codigo_barras', '7501943471900',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Absorsec C/120 Clark Descto: 2.0% Toa Hum Kimberly Absorsec C/120 Clark Toa Hum — Ticket FL-080826',
      'costo', 21.46,
      'precio', 28.98,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-115',
      NULL,
      21.46,
      null
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7501943471900', id from public.productos where codigo_barras = '7501943471900'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- FL-080826 L116 Cotonetes Quirmex Tarro C/100 1 Quirmex 2 12.00 Co
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-34064021'
     or codigo_barras = '75030034064021'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
      jsonb_build_object(
      'nombre', 'Cotonetes Quirmex Tarro C/100 1 Quirmex 2 12.00 Cotonetes Quirmex Tarro C/100 1 Quirmex',
      'sku', 'FC-34064021',
      'codigo_barras', '75030034064021',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Cotonetes Quirmex Tarro C/100 1 Quirmex 2 12.00 Cotonetes Quirmex Tarro C/100 1 Quirmex — Ticket FL-080826',
      'costo', 11.76,
      'precio', 15.88,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-116',
      NULL,
      11.76,
      null
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '75030034064021', id from public.productos where codigo_barras = '75030034064021'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- FL-080826 L117 Lubricante Prudence Grosella 75 Ml | Dkt Mexico $ 
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-14983153'
     or codigo_barras = '7502214983153'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
      jsonb_build_object(
      'nombre', 'Lubricante Prudence Grosella 75 Ml | Dkt Mexico $ 68.20 Lubricante Prudence Grosella 75 Ml | Dkt',
      'sku', 'FC-14983153',
      'codigo_barras', '7502214983153',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Lubricante Prudence Grosella 75 Ml | Dkt Mexico $ 68.20 Lubricante Prudence Grosella 75 Ml | Dkt — Ticket FL-080826',
      'costo', 68.2,
      'precio', 92.07,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-117',
      NULL,
      68.2,
      null
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7502214983153', id from public.productos where codigo_barras = '7502214983153'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- FL-080826 L118 Toa -Hum Huggies Cuidado Puro C/80 | Kimberly Clar
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-43454811'
     or codigo_barras = '7501943454811'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
      jsonb_build_object(
      'nombre', 'Toa -Hum Huggies Cuidado Puro C/80 | Kimberly Clark $ 39.60 Descto: 2.0K 9 Huggies Cuidado Puro C/80 | Kimberly Clark',
      'sku', 'FC-43454811',
      'codigo_barras', '7501943454811',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Toa -Hum Huggies Cuidado Puro C/80 | Kimberly Clark $ 39.60 Descto: 2.0K 9 Huggies Cuidado Puro C/80 | Kimberly Clark — Ticket FL-080826',
      'costo', 39.6,
      'precio', 53.47,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-118',
      NULL,
      39.6,
      null
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7501943454811', id from public.productos where codigo_barras = '7501943454811'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- FL-080826 L119 Retardante C/3 Descto: 9.0% [7502214985348] Cond P
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-49824391'
     or codigo_barras = '75022149824391'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
      jsonb_build_object(
      'nombre', 'Retardante C/3 Descto: 9.0% [7502214985348] Cond Prudence ''Ull Retardante C/3',
      'sku', 'FC-49824391',
      'codigo_barras', '75022149824391',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Retardante C/3 Descto: 9.0% [7502214985348] Cond Prudence ''Ull Retardante C/3 — Ticket FL-080826',
      'costo', 48.6,
      'precio', 65.61,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-119',
      NULL,
      48.6,
      null
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '75022149824391', id from public.productos where codigo_barras = '75022149824391'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- FL-080826 L120 Cond Prudence 'Ull Sensitive C/3 Dkt Cond Prudence
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-14985348'
     or codigo_barras = '7502214985348'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
      jsonb_build_object(
      'nombre', 'Cond Prudence ''Ull Sensitive C/3 Dkt Cond Prudence ''Ull Sensitive',
      'sku', 'FC-14985348',
      'codigo_barras', '7502214985348',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Cond Prudence ''Ull Sensitive C/3 Dkt Cond Prudence ''Ull Sensitive — Ticket FL-080826',
      'costo', 41.31,
      'precio', 55.77,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-120',
      NULL,
      41.31,
      null
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7502214985348', id from public.productos where codigo_barras = '7502214985348'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- FL-080826 L121 Cond Prudence Extra Pleasure C/3 Dkt Cond Prudence
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-49853867'
     or codigo_barras = '75022149853867'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
      jsonb_build_object(
      'nombre', 'Cond Prudence Extra Pleasure C/3 Dkt Cond Prudence Extra Pleasure',
      'sku', 'FC-49853867',
      'codigo_barras', '75022149853867',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Cond Prudence Extra Pleasure C/3 Dkt Cond Prudence Extra Pleasure — Ticket FL-080826',
      'costo', 41.31,
      'precio', 55.77,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-121',
      NULL,
      41.31,
      null
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '75022149853867', id from public.productos where codigo_barras = '75022149853867'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- FL-080826 L122 Cond Prudence Iva C/3 Dki Mexico S Cond Prudence I
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-49824911'
     or codigo_barras = '75022149824911'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
      jsonb_build_object(
      'nombre', 'Cond Prudence Iva C/3 Dki Mexico S Cond Prudence Iva C/3 Mexico',
      'sku', 'FC-49824911',
      'codigo_barras', '75022149824911',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Cond Prudence Iva C/3 Dki Mexico S Cond Prudence Iva C/3 Mexico — Ticket FL-080826',
      'costo', 31.03,
      'precio', 41.9,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-122',
      NULL,
      31.03,
      null
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '75022149824911', id from public.productos where codigo_barras = '75022149824911'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- FL-080826 L123 Cond Prudence Chicle C/E Idkt Cond Prudence Chicle
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-14985805'
     or codigo_barras = '7502214985805'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
      jsonb_build_object(
      'nombre', 'Cond Prudence Chicle C/E Idkt Cond Prudence Chicle',
      'sku', 'FC-14985805',
      'codigo_barras', '7502214985805',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Cond Prudence Chicle C/E Idkt Cond Prudence Chicle — Ticket FL-080826',
      'costo', 44.23,
      'precio', 59.72,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-123',
      NULL,
      44.23,
      null
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7502214985805', id from public.productos where codigo_barras = '7502214985805'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- FL-080826 L124 Lubricante Prudence Natural 75 Ml Lubricante Prude
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-14983726'
     or codigo_barras = '7502214983726'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
      jsonb_build_object(
      'nombre', 'Lubricante Prudence Natural 75 Ml Lubricante Prudence Natural',
      'sku', 'FC-14983726',
      'codigo_barras', '7502214983726',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Lubricante Prudence Natural 75 Ml Lubricante Prudence Natural — Ticket FL-080826',
      'costo', 62.06,
      'precio', 83.79,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-124',
      NULL,
      62.06,
      null
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7502214983726', id from public.productos where codigo_barras = '7502214983726'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- FL-080826 L125 Fresa C/3 I Dkt Descto: 9.0% Cond Prudence Fresa I
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-49824771'
     or codigo_barras = '75022149824771'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
      jsonb_build_object(
      'nombre', 'Fresa C/3 I Dkt Descto: 9.0% Cond Prudence Fresa I Dkt Cond Prudence',
      'sku', 'FC-49824771',
      'codigo_barras', '75022149824771',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Fresa C/3 I Dkt Descto: 9.0% Cond Prudence Fresa I Dkt Cond Prudence — Ticket FL-080826',
      'costo', 31.03,
      'precio', 41.9,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-125',
      NULL,
      31.03,
      null
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '75022149824771', id from public.productos where codigo_barras = '75022149824771'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- FL-080826 L126 0.9 Mt Hilo Dental Ğum Expanding Sunstar Americasi
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-58203691'
     or codigo_barras = '75022358203691'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
      jsonb_build_object(
      'nombre', '0.9 Mt Hilo Dental Ğum Expanding Sunstar Americasi $ 18.90 Descto: 2.0% Hilo Dental Ğum Expanding Sunstar Americasi',
      'sku', 'FC-58203691',
      'codigo_barras', '75022358203691',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', '0.9 Mt Hilo Dental Ğum Expanding Sunstar Americasi $ 18.90 Descto: 2.0% Hilo Dental Ğum Expanding Sunstar Americasi — Ticket FL-080826',
      'costo', 18.9,
      'precio', 25.52,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-126',
      NULL,
      18.9,
      null
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '75022358203691', id from public.productos where codigo_barras = '75022358203691'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- FL-080826 L127 Chocolate C/3 Descto: 9.0% Cond Prudence Dkt Mexic
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-14982514'
     or codigo_barras = '7502214982514'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
      jsonb_build_object(
      'nombre', 'Chocolate C/3 Descto: 9.0% Cond Prudence Dkt Mexico $ 34.10 Chocolate C/3 Cond Prudence Dkt Mexico',
      'sku', 'FC-14982514',
      'codigo_barras', '7502214982514',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Chocolate C/3 Descto: 9.0% Cond Prudence Dkt Mexico $ 34.10 Chocolate C/3 Cond Prudence Dkt Mexico — Ticket FL-080826',
      'costo', 34.1,
      'precio', 46.04,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-127',
      NULL,
      34.1,
      null
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7502214982514', id from public.productos where codigo_barras = '7502214982514'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- FL-080826 L128 Eresa Pomada Labello Bde Merico $ 56.50 Descto: 2.
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-45079011'
     or codigo_barras = '75010545079011'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
      jsonb_build_object(
      'nombre', 'Eresa Pomada Labello Bde Merico $ 56.50 Descto: 2.0% Eresa Pomada Labello Bde Merico',
      'sku', 'FC-45079011',
      'codigo_barras', '75010545079011',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Eresa Pomada Labello Bde Merico $ 56.50 Descto: 2.0% Eresa Pomada Labello Bde Merico — Ticket FL-080826',
      'costo', 56.5,
      'precio', 76.28,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-128',
      NULL,
      56.5,
      null
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '75010545079011', id from public.productos where codigo_barras = '75010545079011'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- FL-080826 L129 Mora C/3 Dkt Cond Prudence Mexico 34.10 Mora C/3 C
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-14980596'
     or codigo_barras = '7502214980596'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
      jsonb_build_object(
      'nombre', 'Mora C/3 Dkt Cond Prudence Mexico 34.10 Mora C/3 Cond Prudence Mexico',
      'sku', 'FC-14980596',
      'codigo_barras', '7502214980596',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Mora C/3 Dkt Cond Prudence Mexico 34.10 Mora C/3 Cond Prudence Mexico — Ticket FL-080826',
      'costo', 31.03,
      'precio', 41.9,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-129',
      NULL,
      31.03,
      null
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7502214980596', id from public.productos where codigo_barras = '7502214980596'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- FL-080826 L130 Cond Prudence Clasico C/3 I Dkt Mexico 32.20 Desct
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-49800151'
     or codigo_barras = '75022149800151'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
      jsonb_build_object(
      'nombre', 'Cond Prudence Clasico C/3 I Dkt Mexico 32.20 Descto: 9.0% Cond Prudence Clasico C/3 I Dkt Mexico',
      'sku', 'FC-49800151',
      'codigo_barras', '75022149800151',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Cond Prudence Clasico C/3 I Dkt Mexico 32.20 Descto: 9.0% Cond Prudence Clasico C/3 I Dkt Mexico — Ticket FL-080826',
      'costo', 29.3,
      'precio', 39.56,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-130',
      NULL,
      29.3,
      null
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '75022149800151', id from public.productos where codigo_barras = '75022149800151'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- FL-080826 L131 Jarabe 250 Ml 1 Nat Descto: 2.0% Ajolotius Bioal I
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-62746605'
     or codigo_barras = '7500462746605'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
      jsonb_build_object(
      'nombre', 'Jarabe 250 Ml 1 Nat Descto: 2.0% Ajolotius Bioal Imentos Jarabe 250 Ml 1 Ajolotius Bioal Imentos',
      'sku', 'FC-62746605',
      'codigo_barras', '7500462746605',
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'Jarabe 250 Ml 1 Nat Descto: 2.0% Ajolotius Bioal Imentos Jarabe 250 Ml 1 Ajolotius Bioal Imentos — Ticket FL-080826',
      'costo', 28.0,
      'precio', 37.81,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-131',
      NULL,
      28.0,
      null
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7500462746605', id from public.productos where codigo_barras = '7500462746605'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- FL-080826 L132 Pomada Labello Hydro-C I Bde Mexico $ 56.50 Descto
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-45045281'
     or codigo_barras = '75010545045281'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
      jsonb_build_object(
      'nombre', 'Pomada Labello Hydro-C I Bde Mexico $ 56.50 Descto: 2.0% $ 55.37 Pomada Labello Hydro-C I Bde Mexico',
      'sku', 'FC-45045281',
      'codigo_barras', '75010545045281',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Pomada Labello Hydro-C I Bde Mexico $ 56.50 Descto: 2.0% $ 55.37 Pomada Labello Hydro-C I Bde Mexico — Ticket FL-080826',
      'costo', 56.5,
      'precio', 76.28,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-132',
      NULL,
      56.5,
      null
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '75010545045281', id from public.productos where codigo_barras = '75010545045281'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- FL-080826 L133 Pomada I.Abeili.C Lasico | Rde Mexic( 56.50 Descto
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-54504870'
     or codigo_barras = '7501054504870'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
      jsonb_build_object(
      'nombre', 'Pomada I.Abeili.C Lasico | Rde Mexic( 56.50 Descto: 2.0% $ 55.37 56.50 Lasico | Rde Mexic(',
      'sku', 'FC-54504870',
      'codigo_barras', '7501054504870',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Pomada I.Abeili.C Lasico | Rde Mexic( 56.50 Descto: 2.0% $ 55.37 56.50 Lasico | Rde Mexic( — Ticket FL-080826',
      'costo', 55.37,
      'precio', 74.75,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-133',
      NULL,
      55.37,
      null
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7501054504870', id from public.productos where codigo_barras = '7501054504870'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- FL-080826 L134 Ajolotius Jengibre Tab C/10 Bioalimentos Nati Jeng
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-52400212'
     or codigo_barras = '7506452400212'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
      jsonb_build_object(
      'nombre', 'Ajolotius Jengibre Tab C/10 Bioalimentos Nati Jengibre C/10 Bioalimentos',
      'sku', 'FC-52400212',
      'codigo_barras', '7506452400212',
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'Ajolotius Jengibre Tab C/10 Bioalimentos Nati Jengibre C/10 Bioalimentos — Ticket FL-080826',
      'costo', 20.5,
      'precio', 27.68,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-134',
      NULL,
      20.5,
      null
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7506452400212', id from public.productos where codigo_barras = '7506452400212'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- FL-080826 L135 Ajolotius Pastillas Elderberry Past Bioalimentos N
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-24004581'
     or codigo_barras = '75064524004581'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '75064524004581', id from public.productos where codigo_barras = '75064524004581'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- FL-080826 L136 Toa Hum Escudo Intbacterial C/50 $ Besbfrzy Clark 
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-56034041'
     or codigo_barras = '75064256034041'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
      jsonb_build_object(
      'nombre', 'Toa Hum Escudo Intbacterial C/50 $ Besbfrzy Clark 15.60 Toa Hum Escudo Intbacterial C/50 Besbfrzy Clark',
      'sku', 'FC-56034041',
      'codigo_barras', '75064256034041',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Toa Hum Escudo Intbacterial C/50 $ Besbfrzy Clark 15.60 Toa Hum Escudo Intbacterial C/50 Besbfrzy Clark — Ticket FL-080826',
      'costo', 15.29,
      'precio', 20.65,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-136',
      NULL,
      15.29,
      null
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '75064256034041', id from public.productos where codigo_barras = '75064256034041'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- FL-080826 L137 1083 Oro Manzanilla Ml Hnos 31.40 Descto: 2.0% Oro
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-21042481'
     or codigo_barras = '75010221042481'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
      jsonb_build_object(
      'nombre', '1083 Oro Manzanilla Ml Hnos 31.40 Descto: 2.0% Oro Manzanilla Hnos',
      'sku', 'FC-21042481',
      'codigo_barras', '75010221042481',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', '1083 Oro Manzanilla Ml Hnos 31.40 Descto: 2.0% Oro Manzanilla Hnos — Ticket FL-080826',
      'costo', 30.77,
      'precio', 41.54,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-137',
      NULL,
      30.77,
      null
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '75010221042481', id from public.productos where codigo_barras = '75010221042481'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- FL-080826 L138 , Ajolotius Jbe Elderberry 2501 Bioalimentos Nati 
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-52400267'
     or codigo_barras = '7506452400267'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
      jsonb_build_object(
      'nombre', ', Ajolotius Jbe Elderberry 2501 Bioalimentos Nati 74.70 $ $ 73.21 Elderberry 2501 Bioalimentos Nati',
      'sku', 'FC-52400267',
      'codigo_barras', '7506452400267',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', ', Ajolotius Jbe Elderberry 2501 Bioalimentos Nati 74.70 $ $ 73.21 Elderberry 2501 Bioalimentos Nati — Ticket FL-080826',
      'costo', 73.21,
      'precio', 98.84,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-138',
      NULL,
      73.21,
      null
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7506452400267', id from public.productos where codigo_barras = '7506452400267'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- FL-080826 L139 Ajolotius Jarabe S/Azucar 250 Ml. I Bioalimentos N
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-62746612'
     or codigo_barras = '7500462746612'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
      jsonb_build_object(
      'nombre', 'Ajolotius Jarabe S/Azucar 250 Ml. I Bioalimentos Nati $ 89.20 $ 87.42 Ajolotius Jarabe S/Azucar 250 Ml. I Bioalimentos N',
      'sku', 'FC-62746612',
      'codigo_barras', '7500462746612',
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'Ajolotius Jarabe S/Azucar 250 Ml. I Bioalimentos Nati $ 89.20 $ 87.42 Ajolotius Jarabe S/Azucar 250 Ml. I Bioalimentos N — Ticket FL-080826',
      'costo', 89.2,
      'precio', 120.43,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-139',
      NULL,
      89.2,
      null
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7500462746612', id from public.productos where codigo_barras = '7500462746612'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- FL-080826 L140 Ajolotius Menta Eucal S/Azucar Past Ajolotius Ment
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-52400038'
     or codigo_barras = '7506452400038'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
      jsonb_build_object(
      'nombre', 'Ajolotius Menta Eucal S/Azucar Past Ajolotius Menta Eucal',
      'sku', 'FC-52400038',
      'codigo_barras', '7506452400038',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Ajolotius Menta Eucal S/Azucar Past Ajolotius Menta Eucal — Ticket FL-080826',
      'costo', 21.36,
      'precio', 28.84,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-140',
      NULL,
      21.36,
      null
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7506452400038', id from public.productos where codigo_barras = '7506452400038'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- FL-080826 L141 Ajolotius Jarabe Reforzado 250 Ml Bioalimentos Nat
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-62746698'
     or codigo_barras = '7500462746698'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
      jsonb_build_object(
      'nombre', 'Ajolotius Jarabe Reforzado 250 Ml Bioalimentos Nat: Ajolotius Jarabe Reforzado',
      'sku', 'FC-62746698',
      'codigo_barras', '7500462746698',
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'Ajolotius Jarabe Reforzado 250 Ml Bioalimentos Nat: Ajolotius Jarabe Reforzado — Ticket FL-080826',
      'costo', 7.45,
      'precio', 10.06,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-141',
      NULL,
      7.45,
      null
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7500462746698', id from public.productos where codigo_barras = '7500462746698'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- FL-080826 L142 Poroso Arnica Parche Leon Bde Poroso Arnica Parche
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-45307181'
     or codigo_barras = '75010545307181'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
      jsonb_build_object(
      'nombre', 'Poroso Arnica Parche Leon Bde Poroso Arnica Parche',
      'sku', 'FC-45307181',
      'codigo_barras', '75010545307181',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Poroso Arnica Parche Leon Bde Poroso Arnica Parche — Ticket FL-080826',
      'costo', 149.35,
      'precio', 201.63,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-142',
      NULL,
      149.35,
      null
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '75010545307181', id from public.productos where codigo_barras = '75010545307181'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- FL-080826 L143 Ajolotius Menta Fucal C/10 Bioalimentos Ajolotius 
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-62746643'
     or codigo_barras = '7500462746643'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
      jsonb_build_object(
      'nombre', 'Ajolotius Menta Fucal C/10 Bioalimentos Ajolotius Menta Fucal',
      'sku', 'FC-62746643',
      'codigo_barras', '7500462746643',
      'categoria', 'GENERAL',
      'tipo', 'GENERICO',
      'descripcion', 'Ajolotius Menta Fucal C/10 Bioalimentos Ajolotius Menta Fucal — Ticket FL-080826',
      'costo', 19.5,
      'precio', 26.33,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
      1,
      'TK-FL-080826-143',
      NULL,
      19.5,
      null
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7500462746643', id from public.productos where codigo_barras = '7500462746643'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;


-- Resync stock desde lotes
update public.productos p
set stock = coalesce((
  select sum(l.cantidad_actual)
  from public.lotes l
  where l.producto_id = p.id and coalesce(l.activo, true) = true
), 0);

commit;

-- Verificar
select count(*) as productos_ticket
from public.productos where sku like 'FC-%' and sku not like 'FC100%';
select sum(cantidad_actual) as stock_lotes from public.lotes;
