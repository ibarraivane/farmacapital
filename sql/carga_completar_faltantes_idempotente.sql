-- Completar carga idempotente (solo crea SKUs que falten)
-- Filas Excel: 627 | Margen: 35%
-- Uso: después de carga parcial _EJECUTAR_1..4 (ej. 433 productos, 972 pzas)
-- NO duplica productos existentes. Ejecutar UNA vez.

begin;

create temp table if not exists _fc_carga_map (
  codigo_barras text primary key,
  producto_id bigint
) on commit drop;

insert into _fc_carga_map (codigo_barras, producto_id)
select codigo_barras, id from public.productos
where codigo_barras is not null and btrim(codigo_barras) <> ''
on conflict (codigo_barras) do nothing;


-- idempotente FC-F967863B
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-F967863B') then
    perform producto_id, lote_id from create_producto_with_lote(

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
  end if;
end $$;

-- idempotente FC-C721E8D7
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-C721E8D7') then
    perform producto_id, lote_id from create_producto_with_lote(

  jsonb_build_object(
      'nombre', 'LEVOFLOXACINO 7 TAB 500 MG',
      'sku', 'FC-C721E8D7',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'LEVOFLOXACINO 7 TAB 500 MG — Ticket 440393',
      'costo', 18.77,
      'precio', 25.34,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  2,
  'U26M041',
  '2028-01-03',
  18.77,
  null

    );
  end if;
end $$;

-- idempotente FC-B25B4654
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-B25B4654') then
    perform producto_id, lote_id from create_producto_with_lote(

  jsonb_build_object(
      'nombre', 'CINA 7 TAB 750 MG',
      'sku', 'FC-B25B4654',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'CINA 7 TAB 750 MG — Ticket 440393',
      'costo', 28.87,
      'precio', 38.98,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  2,
  'U26D009',
  '2028-04-01',
  28.87,
  null

    );
  end if;
end $$;

-- idempotente FC-ACA2A2F6
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-ACA2A2F6') then
    perform producto_id, lote_id from create_producto_with_lote(

  jsonb_build_object(
      'nombre', 'ALOPURINOL 20 TAB 300 MG',
      'sku', 'FC-ACA2A2F6',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'ALOPURINOL 20 TAB 300 MG — Ticket 440393',
      'costo', 21.46,
      'precio', 28.98,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  2,
  'AB25002',
  '2027-10-31',
  21.46,
  null

    );
  end if;
end $$;

-- idempotente FC-174824A0
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-174824A0') then
    perform producto_id, lote_id from create_producto_with_lote(

  jsonb_build_object(
      'nombre', 'VERNISEN 6 TAB 200 MG',
      'sku', 'FC-174824A0',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'VERNISEN 6 TAB 200 MG — Ticket 440393',
      'costo', 12.38,
      'precio', 16.72,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  2,
  '790055',
  '2029-05-01',
  12.38,
  null

    );
  end if;
end $$;

-- idempotente FC-D5AC44CA
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-D5AC44CA') then
    perform producto_id, lote_id from create_producto_with_lote(

  jsonb_build_object(
      'nombre', 'AMIFARIN 20 CAPS 500 MG',
      'sku', 'FC-D5AC44CA',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'AMIFARIN 20 CAPS 500 MG — Ticket 440393',
      'costo', 45.78,
      'precio', 61.81,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  2,
  'C6227',
  '2028-04-01',
  45.78,
  null

    );
  end if;
end $$;

-- idempotente FC-9A4E4C31
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-9A4E4C31') then
    perform producto_id, lote_id from create_producto_with_lote(

  jsonb_build_object(
      'nombre', 'CLINDAMICINA FA 600MG/4ML',
      'sku', 'FC-9A4E4C31',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'CLINDAMICINA FA 600MG/4ML — Ticket 440393',
      'costo', 88.42,
      'precio', 119.37,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  2,
  'E25N206',
  '2027-01-01',
  88.42,
  null

    );
  end if;
end $$;

-- idempotente FC-40CE757D
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-40CE757D') then
    perform producto_id, lote_id from create_producto_with_lote(

  jsonb_build_object(
      'nombre', 'CEFALVER 12 TAB 1 G',
      'sku', 'FC-40CE757D',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'CEFALVER 12 TAB 1 G — Ticket 440393',
      'costo', 62.48,
      'precio', 84.35,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  1,
  '256934',
  '2028-02-01',
  62.48,
  null

    );
  end if;
end $$;

-- idempotente FC-B18E386A
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-B18E386A') then
    perform producto_id, lote_id from create_producto_with_lote(

  jsonb_build_object(
      'nombre', 'CEFAROXIL 15 TAB 500/30 MG',
      'sku', 'FC-B18E386A',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'CEFAROXIL 15 TAB 500/30 MG — Ticket 440393',
      'costo', 44.44,
      'precio', 60.0,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  1,
  '255417',
  '2028-10-01',
  44.44,
  null

    );
  end if;
end $$;

-- idempotente FC-1DA570E3
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-1DA570E3') then
    perform producto_id, lote_id from create_producto_with_lote(

  jsonb_build_object(
      'nombre', 'CLOXAN 20 COMP 30 MG',
      'sku', 'FC-1DA570E3',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'CLOXAN 20 COMP 30 MG — Ticket 440393',
      'costo', 9.75,
      'precio', 13.17,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  2,
  'SB2642',
  '2028-02-01',
  9.75,
  null

    );
  end if;
end $$;

-- idempotente FC-A455EE80
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-A455EE80') then
    perform producto_id, lote_id from create_producto_with_lote(

  jsonb_build_object(
      'nombre', 'CEFAGEN 1 SUSP 250MG/5/50 ML',
      'sku', 'FC-A455EE80',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'CEFAGEN 1 SUSP 250MG/5/50 ML — Ticket 440393',
      'costo', 74.58,
      'precio', 100.69,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  1,
  '256533',
  '2027-02-01',
  74.58,
  null

    );
  end if;
end $$;

-- idempotente FC-E374F23E
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-E374F23E') then
    perform producto_id, lote_id from create_producto_with_lote(

  jsonb_build_object(
      'nombre', 'CEFAGEN 1 SUSP 125MG/5/50 ML',
      'sku', 'FC-E374F23E',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'CEFAGEN 1 SUSP 125MG/5/50 ML — Ticket 440393',
      'costo', 48.48,
      'precio', 65.45,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  1,
  '255233',
  '2027-09-01',
  48.48,
  null

    );
  end if;
end $$;

-- idempotente FC-8FB65B79
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-8FB65B79') then
    perform producto_id, lote_id from create_producto_with_lote(

  jsonb_build_object(
      'nombre', 'KLARIX 1 SUSP 250MG/5ML 60 ML',
      'sku', 'FC-8FB65B79',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'KLARIX 1 SUSP 250MG/5ML 60 ML — Ticket 440393',
      'costo', 81.67,
      'precio', 110.26,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  1,
  '263020',
  '2028-05-01',
  81.67,
  null

    );
  end if;
end $$;

-- idempotente FC-2EDC6E3B
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-2EDC6E3B') then
    perform producto_id, lote_id from create_producto_with_lote(

  jsonb_build_object(
      'nombre', 'CEFAGEN 10 TAB 250 MG',
      'sku', 'FC-2EDC6E3B',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'CEFAGEN 10 TAB 250 MG — Ticket 440393',
      'costo', 82.09,
      'precio', 110.83,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  1,
  '254942',
  '2027-09-01',
  82.09,
  null

    );
  end if;
end $$;

-- idempotente FC-C101D5B1
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-C101D5B1') then
    perform producto_id, lote_id from create_producto_with_lote(

  jsonb_build_object(
      'nombre', 'BISOPROLOL 30 TAB 2.5 MG',
      'sku', 'FC-C101D5B1',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'BISOPROLOL 30 TAB 2.5 MG — Ticket 440393',
      'costo', 97.51,
      'precio', 131.64,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  1,
  '26E039',
  '2028-04-30',
  97.51,
  null

    );
  end if;
end $$;

-- idempotente FC-7AF7ACB5
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-7AF7ACB5') then
    perform producto_id, lote_id from create_producto_with_lote(

  jsonb_build_object(
      'nombre', 'CHARLYN 3 TAB 500 MG',
      'sku', 'FC-7AF7ACB5',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'CHARLYN 3 TAB 500 MG — Ticket 440393',
      'costo', 24.98,
      'precio', 33.73,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  6,
  '251303',
  '2028-02-01',
  24.98,
  null

    );
  end if;
end $$;

-- idempotente FC-CF18C740
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-CF18C740') then
    perform producto_id, lote_id from create_producto_with_lote(

  jsonb_build_object(
      'nombre', 'CLINDAMICINA 16 CAP 300 MG',
      'sku', 'FC-CF18C740',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'CLINDAMICINA 16 CAP 300 MG — Ticket 440393',
      'costo', 30.54,
      'precio', 41.23,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  3,
  'U26E412',
  '2028-01-01',
  30.54,
  null

    );
  end if;
end $$;

-- idempotente FC-E4EFC4C2
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-E4EFC4C2') then
    perform producto_id, lote_id from create_producto_with_lote(

  jsonb_build_object(
      'nombre', 'FASICLOR 15 CAPS 500 MG',
      'sku', 'FC-E4EFC4C2',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'FASICLOR 15 CAPS 500 MG — Ticket 440393',
      'costo', 137.92,
      'precio', 186.2,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  1,
  '255646',
  '2027-10-01',
  137.92,
  null

    );
  end if;
end $$;

-- idempotente FC-6EAD98A9
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-6EAD98A9') then
    perform producto_id, lote_id from create_producto_with_lote(

  jsonb_build_object(
      'nombre', 'CEPOBROM 12 CAPS 500/0.782 MG',
      'sku', 'FC-6EAD98A9',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'CEPOBROM 12 CAPS 500/0.782 MG — Ticket 440393',
      'costo', 47.97,
      'precio', 64.76,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  1,
  '260152',
  '2029-01-01',
  47.97,
  null

    );
  end if;
end $$;

-- idempotente FC-CF719C07
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-CF719C07') then
    perform producto_id, lote_id from create_producto_with_lote(

  jsonb_build_object(
      'nombre', 'DICLOFEN 12 CAPS 500 MG',
      'sku', 'FC-CF719C07',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'DICLOFEN 12 CAPS 500 MG — Ticket 440393',
      'costo', 26.82,
      'precio', 36.21,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  2,
  'E2605191',
  '2028-05-01',
  26.82,
  null

    );
  end if;
end $$;

-- idempotente FC-60F627D5
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-60F627D5') then
    perform producto_id, lote_id from create_producto_with_lote(

  jsonb_build_object(
      'nombre', 'GENTAMICINA 5 AMP 160MG/2ML',
      'sku', 'FC-60F627D5',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'GENTAMICINA 5 AMP 160MG/2ML — Ticket 440393',
      'costo', 52.57,
      'precio', 70.97,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  2,
  'B25N402',
  '2027-11-01',
  52.57,
  null

    );
  end if;
end $$;

-- idempotente FC-48F732CF
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-48F732CF') then
    perform producto_id, lote_id from create_producto_with_lote(

  jsonb_build_object(
      'nombre', 'EPICIN 20 CAPS 500 MG',
      'sku', 'FC-48F732CF',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'EPICIN 20 CAPS 500 MG — Ticket 440393',
      'costo', 29.56,
      'precio', 39.91,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  5,
  'E2603101',
  '2028-03-01',
  29.56,
  null

    );
  end if;
end $$;

-- idempotente FC-72C28BC1
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-72C28BC1') then
    perform producto_id, lote_id from create_producto_with_lote(

  jsonb_build_object(
      'nombre', 'KNORICIN 1 SUSP 125MG/5/60 ML',
      'sku', 'FC-72C28BC1',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'KNORICIN 1 SUSP 125MG/5/60 ML — Ticket 440393',
      'costo', 45.41,
      'precio', 61.31,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  1,
  '5F0981',
  '2027-06-01',
  45.41,
  null

    );
  end if;
end $$;

-- idempotente FC-443C330E
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-443C330E') then
    perform producto_id, lote_id from create_producto_with_lote(

  jsonb_build_object(
      'nombre', 'CEFAGEN 10 TAB 500 MG',
      'sku', 'FC-443C330E',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'CEFAGEN 10 TAB 500 MG — Ticket 440393',
      'costo', 144.13,
      'precio', 194.58,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  1,
  '256911',
  '2027-12-31',
  144.13,
  null

    );
  end if;
end $$;

-- idempotente FC-492D652F
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-492D652F') then
    perform producto_id, lote_id from create_producto_with_lote(

  jsonb_build_object(
      'nombre', 'CEFALVER 20 CAPS 500 MG',
      'sku', 'FC-492D652F',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'CEFALVER 20 CAPS 500 MG — Ticket 440393',
      'costo', 43.35,
      'precio', 58.53,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  1,
  '261277',
  '2028-02-01',
  43.35,
  null

    );
  end if;
end $$;

-- idempotente FC-86A95D07
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-86A95D07') then
    perform producto_id, lote_id from create_producto_with_lote(

  jsonb_build_object(
      'nombre', 'TROPHARMA 20 TAB 500 MG',
      'sku', 'FC-86A95D07',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'TROPHARMA 20 TAB 500 MG — Ticket 440393',
      'costo', 44.53,
      'precio', 60.12,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  2,
  '2512921',
  '2028-12-01',
  44.53,
  null

    );
  end if;
end $$;

-- idempotente FC-697EEAD0
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-697EEAD0') then
    perform producto_id, lote_id from create_producto_with_lote(

  jsonb_build_object(
      'nombre', 'KURTOSIL 1 CMA 20/1 MG',
      'sku', 'FC-697EEAD0',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'KURTOSIL 1 CMA 20/1 MG — Ticket 440393',
      'costo', 62.48,
      'precio', 84.35,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  1,
  '264239',
  '2028-06-30',
  62.48,
  null

    );
  end if;
end $$;

-- idempotente FC-830BF3FB
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-830BF3FB') then
    perform producto_id, lote_id from create_producto_with_lote(

  jsonb_build_object(
      'nombre', 'DIVILTAC 1 FA 150/10MG/1 ML',
      'sku', 'FC-830BF3FB',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'DIVILTAC 1 FA 150/10MG/1 ML — Ticket 440393',
      'costo', 34.45,
      'precio', 46.51,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  1,
  'H26020022',
  '2028-03-01',
  34.45,
  null

    );
  end if;
end $$;

-- idempotente FC-F3E734A0
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-F3E734A0') then
    perform producto_id, lote_id from create_producto_with_lote(

  jsonb_build_object(
      'nombre', 'FASICLOR 1 SUSP 375MG/5/50 ML',
      'sku', 'FC-F3E734A0',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'FASICLOR 1 SUSP 375MG/5/50 ML — Ticket 440393',
      'costo', 63.44,
      'precio', 85.65,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  1,
  '252890',
  '2028-06-01',
  63.44,
  null

    );
  end if;
end $$;

-- idempotente FC-74A5ABEE
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-74A5ABEE') then
    perform producto_id, lote_id from create_producto_with_lote(

  jsonb_build_object(
      'nombre', 'CIPROFLOXACINO 12 TAB 250 MG',
      'sku', 'FC-74A5ABEE',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'CIPROFLOXACINO 12 TAB 250 MG — Ticket 440393',
      'costo', 13.69,
      'precio', 18.49,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  2,
  'U26V028',
  '2028-06-30',
  13.69,
  null

    );
  end if;
end $$;

-- idempotente FC-AEA8C8DA
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-AEA8C8DA') then
    perform producto_id, lote_id from create_producto_with_lote(

  jsonb_build_object(
      'nombre', 'NAMIFEN 20 TAB 500 MG',
      'sku', 'FC-AEA8C8DA',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'NAMIFEN 20 TAB 500 MG — Ticket 440393',
      'costo', 24.28,
      'precio', 32.78,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  1,
  '440096',
  '2030-06-01',
  24.28,
  null

    );
  end if;
end $$;

-- idempotente FC-2005DD57
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-2005DD57') then
    perform producto_id, lote_id from create_producto_with_lote(

  jsonb_build_object(
      'nombre', 'CEFALEXINA 20 CAPS 500 MG',
      'sku', 'FC-2005DD57',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'CEFALEXINA 20 CAPS 500 MG — Ticket 440393',
      'costo', 39.84,
      'precio', 53.79,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  2,
  '26A067',
  '2028-01-01',
  39.84,
  null

    );
  end if;
end $$;

-- idempotente FC-B4477A00
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-B4477A00') then
    perform producto_id, lote_id from create_producto_with_lote(

  jsonb_build_object(
      'nombre', 'PENTIBROXIL 16 CAPS 500/30 MG',
      'sku', 'FC-B4477A00',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'PENTIBROXIL 16 CAPS 500/30 MG — Ticket 440393',
      'costo', 30.04,
      'precio', 40.56,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  2,
  '262066',
  '2028-04-01',
  30.04,
  null

    );
  end if;
end $$;

-- idempotente FC-85BDBD3D
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-85BDBD3D') then
    perform producto_id, lote_id from create_producto_with_lote(

  jsonb_build_object(
      'nombre', 'ACROXIL-C 1 SUSP 250MG/5/60 ML',
      'sku', 'FC-85BDBD3D',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'ACROXIL-C 1 SUSP 250MG/5/60 ML — Ticket 440393',
      'costo', 25.42,
      'precio', 34.32,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  1,
  'E2512603',
  '2027-11-01',
  25.42,
  null

    );
  end if;
end $$;

-- idempotente FC-7AA38F97
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-7AA38F97') then
    perform producto_id, lote_id from create_producto_with_lote(

  jsonb_build_object(
      'nombre', 'PENTIVER 1 SUSP 500MG/5/60 ML',
      'sku', 'FC-7AA38F97',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'PENTIVER 1 SUSP 500MG/5/60 ML — Ticket 440393',
      'costo', 31.2,
      'precio', 42.12,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  1,
  '256072',
  '2027-12-01',
  31.2,
  null

    );
  end if;
end $$;

-- idempotente FC-9538F7D6
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-9538F7D6') then
    perform producto_id, lote_id from create_producto_with_lote(

  jsonb_build_object(
      'nombre', 'FASICLOR 1 SUSP 250MG/5/75 ML',
      'sku', 'FC-9538F7D6',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'FASICLOR 1 SUSP 250MG/5/75 ML — Ticket 440393',
      'costo', 81.18,
      'precio', 109.6,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  1,
  '251778',
  '2028-10-01',
  81.18,
  null

    );
  end if;
end $$;

-- idempotente FC-01B2F362
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-01B2F362') then
    perform producto_id, lote_id from create_producto_with_lote(

  jsonb_build_object(
      'nombre', 'FASICLOR 1 SUSP 125MG/5/75 ML',
      'sku', 'FC-01B2F362',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'FASICLOR 1 SUSP 125MG/5/75 ML — Ticket 440393',
      'costo', 49.85,
      'precio', 67.3,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  1,
  '255772',
  '2027-10-01',
  49.85,
  null

    );
  end if;
end $$;

-- idempotente FC-50587FA6
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-50587FA6') then
    perform producto_id, lote_id from create_producto_with_lote(

  jsonb_build_object(
      'nombre', 'MEXAPIN 1 SUSP 125MG/5/60 ML',
      'sku', 'FC-50587FA6',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'MEXAPIN 1 SUSP 125MG/5/60 ML — Ticket 440393',
      'costo', 13.93,
      'precio', 18.81,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  1,
  'S5721',
  '2027-12-01',
  13.93,
  null

    );
  end if;
end $$;

-- idempotente FC-B72A6420
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-B72A6420') then
    perform producto_id, lote_id from create_producto_with_lote(

  jsonb_build_object(
      'nombre', 'PENTIVER 1 SUSP 250MG/5/90 ML',
      'sku', 'FC-B72A6420',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'PENTIVER 1 SUSP 250MG/5/90 ML — Ticket 440393',
      'costo', 27.06,
      'precio', 36.54,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  1,
  '257070',
  '2027-11-01',
  27.06,
  null

    );
  end if;
end $$;

-- idempotente FC-D9391288
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-D9391288') then
    perform producto_id, lote_id from create_producto_with_lote(

  jsonb_build_object(
      'nombre', 'AZITROMICINA 1 SUSP 200MG/5/15 ML',
      'sku', 'FC-D9391288',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'AZITROMICINA 1 SUSP 200MG/5/15 ML — Ticket 440393',
      'costo', 68.5,
      'precio', 92.48,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  1,
  '251985',
  '2027-11-26',
  68.5,
  null

    );
  end if;
end $$;

-- idempotente FC-41339950
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-41339950') then
    perform producto_id, lote_id from create_producto_with_lote(

  jsonb_build_object(
      'nombre', 'CLARITROMICINA 10 TAB 500 MG',
      'sku', 'FC-41339950',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'CLARITROMICINA 10 TAB 500 MG — Ticket 440393',
      'costo', 59.45,
      'precio', 80.26,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  2,
  'U26E021',
  '2028-02-01',
  59.45,
  null

    );
  end if;
end $$;

-- idempotente FC-E6112F15
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-E6112F15') then
    perform producto_id, lote_id from create_producto_with_lote(

  jsonb_build_object(
      'nombre', 'NALIXONE 20 TAB 500/50 MG',
      'sku', 'FC-E6112F15',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'NALIXONE 20 TAB 500/50 MG — Ticket 440393',
      'costo', 63.32,
      'precio', 85.49,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  2,
  '2630655',
  '2028-03-01',
  63.32,
  null

    );
  end if;
end $$;

-- idempotente FC-F183C6E9
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-F183C6E9') then
    perform producto_id, lote_id from create_producto_with_lote(

  jsonb_build_object(
      'nombre', 'PENIPOT 1 FA 800,000 UI',
      'sku', 'FC-F183C6E9',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'PENIPOT 1 FA 800,000 UI — Ticket 440393',
      'costo', 19.44,
      'precio', 26.25,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  6,
  '126A003',
  '2028-02-01',
  19.44,
  null

    );
  end if;
end $$;

-- idempotente FC-A0D320D1
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-A0D320D1') then
    perform producto_id, lote_id from create_producto_with_lote(

  jsonb_build_object(
      'nombre', 'AMOXICILINA 12 CAPS 500 MG',
      'sku', 'FC-A0D320D1',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'AMOXICILINA 12 CAPS 500 MG — Ticket 440393',
      'costo', 18.37,
      'precio', 24.8,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  5,
  'C0925787',
  '2027-09-01',
  18.37,
  null

    );
  end if;
end $$;

-- idempotente FC-95779436
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-95779436') then
    perform producto_id, lote_id from create_producto_with_lote(

  jsonb_build_object(
      'nombre', 'ACIDO ACETILSALICILICO EF 20 TAB 300 MG',
      'sku', 'FC-95779436',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'ACIDO ACETILSALICILICO EF 20 TAB 300 MG — Ticket 440393',
      'costo', 19.07,
      'precio', 25.75,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  5,
  '0380626',
  '2028-06-30',
  19.07,
  null

    );
  end if;
end $$;

-- idempotente FC-4C621D07
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-4C621D07') then
    perform producto_id, lote_id from create_producto_with_lote(

  jsonb_build_object(
      'nombre', 'VANMOXOL 1 SUSP 250/15MG/5/90 ML',
      'sku', 'FC-4C621D07',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'VANMOXOL 1 SUSP 250/15MG/5/90 ML — Ticket 440393',
      'costo', 18.03,
      'precio', 24.35,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  1,
  'S5406',
  '2027-03-01',
  18.03,
  null

    );
  end if;
end $$;

-- idempotente FC-022543CD
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-022543CD') then
    perform producto_id, lote_id from create_producto_with_lote(

  jsonb_build_object(
      'nombre', 'VALCLAN 10 TAB 500/125 MG',
      'sku', 'FC-022543CD',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'VALCLAN 10 TAB 500/125 MG — Ticket 440393',
      'costo', 37.22,
      'precio', 50.25,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  3,
  'T6079',
  '2028-02-01',
  37.22,
  null

    );
  end if;
end $$;

-- idempotente FC-64EB83AA
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-64EB83AA') then
    perform producto_id, lote_id from create_producto_with_lote(

  jsonb_build_object(
      'nombre', 'BENCIL/BENZ COMPL 1 FA 1,2 U 3 ML',
      'sku', 'FC-64EB83AA',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'BENCIL/BENZ COMPL 1 FA 1,2 U 3 ML — Ticket 440393',
      'costo', 18.07,
      'precio', 24.4,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  5,
  '125T007',
  '2027-05-01',
  18.07,
  null

    );
  end if;
end $$;

-- idempotente FC-D210172A
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-D210172A') then
    perform producto_id, lote_id from create_producto_with_lote(

  jsonb_build_object(
      'nombre', 'AMPICILINA 1 FA 1G/5 ML',
      'sku', 'FC-D210172A',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'AMPICILINA 1 FA 1G/5 ML — Ticket 440393',
      'costo', 25.48,
      'precio', 34.4,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  2,
  '126H505',
  '2027-06-01',
  25.48,
  null

    );
  end if;
end $$;

-- idempotente FC-7F90064A
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-7F90064A') then
    perform producto_id, lote_id from create_producto_with_lote(

  jsonb_build_object(
      'nombre', 'AMPICILINA 1 FA 500MG/2 ML',
      'sku', 'FC-7F90064A',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'AMPICILINA 1 FA 500MG/2 ML — Ticket 440393',
      'costo', 20.37,
      'precio', 27.5,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  2,
  '125S506',
  '2027-09-01',
  20.37,
  null

    );
  end if;
end $$;

-- idempotente FC-F82A6E4B
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-F82A6E4B') then
    perform producto_id, lote_id from create_producto_with_lote(

  jsonb_build_object(
      'nombre', 'AMPICILINA 10 TAB 1 G',
      'sku', 'FC-F82A6E4B',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'AMPICILINA 10 TAB 1 G — Ticket 440393',
      'costo', 27.05,
      'precio', 36.52,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  3,
  'Q0126016',
  '2028-01-01',
  27.05,
  null

    );
  end if;
end $$;

-- idempotente FC-5F30F9D4
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-5F30F9D4') then
    perform producto_id, lote_id from create_producto_with_lote(

  jsonb_build_object(
      'nombre', 'CLAMOXIN 10 TAB 500/125 MG',
      'sku', 'FC-5F30F9D4',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'CLAMOXIN 10 TAB 500/125 MG — Ticket 440393',
      'costo', 48.48,
      'precio', 65.45,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  3,
  '261979',
  '2028-04-01',
  48.48,
  null

    );
  end if;
end $$;

-- idempotente FC-7D1D9857
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-7D1D9857') then
    perform producto_id, lote_id from create_producto_with_lote(

  jsonb_build_object(
      'nombre', 'ACIDO ACETILSALICILICO 30 TAB 100MG',
      'sku', 'FC-7D1D9857',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'ACIDO ACETILSALICILICO 30 TAB 100MG — Ticket 440393',
      'costo', 14.85,
      'precio', 20.05,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  5,
  '6AM103C',
  '2028-01-01',
  14.85,
  null

    );
  end if;
end $$;

-- idempotente FC-516C2E89
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-516C2E89') then
    perform producto_id, lote_id from create_producto_with_lote(

  jsonb_build_object(
      'nombre', 'CLAMOXIN 12H JR 1 SUSP 400/57MG/5/50 ML',
      'sku', 'FC-516C2E89',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'CLAMOXIN 12H JR 1 SUSP 400/57MG/5/50 ML — Ticket 440393',
      'costo', 36.79,
      'precio', 49.67,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  3,
  '257270',
  '2028-01-01',
  36.79,
  null

    );
  end if;
end $$;

-- idempotente FC-05965071
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-05965071') then
    perform producto_id, lote_id from create_producto_with_lote(

  jsonb_build_object(
      'nombre', 'ACROXIL-C 12 CAPS 500/8 MG',
      'sku', 'FC-05965071',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'ACROXIL-C 12 CAPS 500/8 MG — Ticket 440393',
      'costo', 24.05,
      'precio', 32.47,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  1,
  'B2602071',
  '2028-02-01',
  24.05,
  null

    );
  end if;
end $$;

-- idempotente FC-930E0B1B
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-930E0B1B') then
    perform producto_id, lote_id from create_producto_with_lote(

  jsonb_build_object(
      'nombre', 'VANDIL 1 SUSP 250MG/5/75 ML',
      'sku', 'FC-930E0B1B',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'VANDIL 1 SUSP 250MG/5/75 ML — Ticket 440393',
      'costo', 20.58,
      'precio', 27.79,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  1,
  'S6252',
  '2028-04-01',
  20.58,
  null

    );
  end if;
end $$;

-- idempotente FC-405A75E3
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-405A75E3') then
    perform producto_id, lote_id from create_producto_with_lote(

  jsonb_build_object(
      'nombre', 'ACIDO URSODESOXICOLICO 50 CAP 250 MG',
      'sku', 'FC-405A75E3',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'ACIDO URSODESOXICOLICO 50 CAP 250 MG — Ticket 440393',
      'costo', 217.23,
      'precio', 293.27,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  1,
  'U26F085',
  '2028-02-01',
  217.23,
  null

    );
  end if;
end $$;

-- idempotente FC-D06E54FE
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-D06E54FE') then
    perform producto_id, lote_id from create_producto_with_lote(

  jsonb_build_object(
      'nombre', 'VALCLAN 10 TAB 875/125 MG',
      'sku', 'FC-D06E54FE',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'VALCLAN 10 TAB 875/125 MG — Ticket 440393',
      'costo', 51.18,
      'precio', 69.1,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  3,
  'T6315',
  '2028-01-01',
  51.18,
  null

    );
  end if;
end $$;

-- idempotente FC-3A4583F3
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-3A4583F3') then
    perform producto_id, lote_id from create_producto_with_lote(

  jsonb_build_object(
      'nombre', 'PENIPOT 1 FA 400,000 UI',
      'sku', 'FC-3A4583F3',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'PENIPOT 1 FA 400,000 UI — Ticket 440393',
      'costo', 14.07,
      'precio', 19.0,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  2,
  '125U014',
  '2027-06-01',
  14.07,
  null

    );
  end if;
end $$;

-- idempotente FC-F22C72BE
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-F22C72BE') then
    perform producto_id, lote_id from create_producto_with_lote(

  jsonb_build_object(
      'nombre', 'CLAMOXIN 12H 10 TAB 875/125 MG',
      'sku', 'FC-F22C72BE',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'CLAMOXIN 12H 10 TAB 875/125 MG — Ticket 440393',
      'costo', 55.03,
      'precio', 74.3,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  5,
  '263412',
  '2028-01-01',
  55.03,
  null

    );
  end if;
end $$;

-- idempotente FC-F48FF7EF
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-F48FF7EF') then
    perform producto_id, lote_id from create_producto_with_lote(

  jsonb_build_object(
      'nombre', 'CLAMOXIN 1 SUSP 250/62.5MG/5/60 ML',
      'sku', 'FC-F48FF7EF',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'CLAMOXIN 1 SUSP 250/62.5MG/5/60 ML — Ticket 440393',
      'costo', 35.62,
      'precio', 48.09,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  1,
  '260027',
  '2028-01-01',
  35.62,
  null

    );
  end if;
end $$;

-- idempotente FC-4BD80686
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-4BD80686') then
    perform producto_id, lote_id from create_producto_with_lote(

  jsonb_build_object(
      'nombre', 'BENEVENTOL 3 CAPS 400 MG',
      'sku', 'FC-4BD80686',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'BENEVENTOL 3 CAPS 400 MG — Ticket 440393',
      'costo', 88.17,
      'precio', 119.03,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  1,
  '256213',
  '2027-10-01',
  88.17,
  null

    );
  end if;
end $$;

-- idempotente FC-974EE5FD
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-974EE5FD') then
    perform producto_id, lote_id from create_producto_with_lote(

  jsonb_build_object(
      'nombre', 'GIMALXINA 1 SUSP 250MG/5/75 ML',
      'sku', 'FC-974EE5FD',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'GIMALXINA 1 SUSP 250MG/5/75 ML — Ticket 440393',
      'costo', 27.09,
      'precio', 36.58,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  1,
  '26240167',
  '2030-04-21',
  27.09,
  null

    );
  end if;
end $$;

-- idempotente FC-0E0A9E42
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-0E0A9E42') then
    perform producto_id, lote_id from create_producto_with_lote(

  jsonb_build_object(
      'nombre', 'CLAMOXIN S 1 SUSP 600/42.9MG/50 ML',
      'sku', 'FC-0E0A9E42',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'CLAMOXIN S 1 SUSP 600/42.9MG/50 ML — Ticket 440393',
      'costo', 47.99,
      'precio', 64.79,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  1,
  '256303',
  '2027-11-01',
  47.99,
  null

    );
  end if;
end $$;

-- idempotente FC-6519183A
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-6519183A') then
    perform producto_id, lote_id from create_producto_with_lote(

  jsonb_build_object(
      'nombre', 'CLAMOXIN 1 SUSP 125/31.25MG/5/60 ML',
      'sku', 'FC-6519183A',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'CLAMOXIN 1 SUSP 125/31.25MG/5/60 ML — Ticket 440393',
      'costo', 27.89,
      'precio', 37.66,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  1,
  '260677',
  '2028-02-01',
  27.89,
  null

    );
  end if;
end $$;

-- idempotente FC-DDFBABDF
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-DDFBABDF') then
    perform producto_id, lote_id from create_producto_with_lote(

  jsonb_build_object(
      'nombre', 'CLAMOXIN 12H PED 1 SUSP 200/28.5MG/40 ML',
      'sku', 'FC-DDFBABDF',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'CLAMOXIN 12H PED 1 SUSP 200/28.5MG/40 ML — Ticket 440393',
      'costo', 25.94,
      'precio', 35.02,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  1,
  '257267',
  '2028-01-01',
  25.94,
  null

    );
  end if;
end $$;

-- idempotente FC-C9F4ACCC
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-C9F4ACCC') then
    perform producto_id, lote_id from create_producto_with_lote(

  jsonb_build_object(
      'nombre', 'ACEMETACINA 14 CAPS 90 MG',
      'sku', 'FC-C9F4ACCC',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'ACEMETACINA 14 CAPS 90 MG — Ticket 440393',
      'costo', 39.44,
      'precio', 53.25,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  1,
  'CNF2656',
  '2029-03-30',
  39.44,
  null

    );
  end if;
end $$;

-- idempotente FC-17376CAE
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-17376CAE') then
    perform producto_id, lote_id from create_producto_with_lote(

  jsonb_build_object(
      'nombre', 'ASPITAK-P 30 COMP 100 MG',
      'sku', 'FC-17376CAE',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'ASPITAK-P 30 COMP 100 MG — Ticket 440393',
      'costo', 19.72,
      'precio', 26.63,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  2,
  '26051262',
  '2028-05-01',
  19.72,
  null

    );
  end if;
end $$;

-- idempotente FC-369D1689
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-369D1689') then
    perform producto_id, lote_id from create_producto_with_lote(

  jsonb_build_object(
      'nombre', 'BENEVENTOL 6 CAPS 400 MG',
      'sku', 'FC-369D1689',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'BENEVENTOL 6 CAPS 400 MG — Ticket 440393',
      'costo', 51.43,
      'precio', 69.44,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  1,
  '255831',
  '2027-10-01',
  51.43,
  null

    );
  end if;
end $$;

-- idempotente FC-B69FCBF4
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-B69FCBF4') then
    perform producto_id, lote_id from create_producto_with_lote(

  jsonb_build_object(
      'nombre', 'LESACLOR (MACLOV) 35 TAB 400 MG',
      'sku', 'FC-B69FCBF4',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'LESACLOR (MACLOV) 35 TAB 400 MG — Ticket 440393',
      'costo', 146.11,
      'precio', 197.25,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  1,
  'S19964',
  '2028-10-01',
  146.11,
  null

    );
  end if;
end $$;

-- idempotente FC-F4E9C71F
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-F4E9C71F') then
    perform producto_id, lote_id from create_producto_with_lote(

  jsonb_build_object(
      'nombre', 'AMOXICILINA 1 SUSP 500MG/5/75 ML',
      'sku', 'FC-F4E9C71F',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'AMOXICILINA 1 SUSP 500MG/5/75 ML — Ticket 440393',
      'costo', 72.03,
      'precio', 97.25,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  1,
  'Q626334',
  '2028-06-30',
  72.03,
  null

    );
  end if;
end $$;

-- idempotente FC-428A228F
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-428A228F') then
    perform producto_id, lote_id from create_producto_with_lote(

  jsonb_build_object(
      'nombre', 'GIMALXINA 12 CAPS 500 MG',
      'sku', 'FC-428A228F',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'GIMALXINA 12 CAPS 500 MG — Ticket 440393',
      'costo', 23.57,
      'precio', 31.82,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  2,
  '26240134',
  '2029-03-31',
  23.57,
  null

    );
  end if;
end $$;

-- idempotente FC-FD845E68
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-FD845E68') then
    perform producto_id, lote_id from create_producto_with_lote(

  jsonb_build_object(
      'nombre', 'ACICLOVIR 35 TAB 400 MG',
      'sku', 'FC-FD845E68',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'ACICLOVIR 35 TAB 400 MG — Ticket 440393',
      'costo', 23.68,
      'precio', 31.97,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  1,
  'U26F020',
  '2029-02-01',
  23.68,
  null

    );
  end if;
end $$;

-- idempotente FC-B2123139
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-B2123139') then
    perform producto_id, lote_id from create_producto_with_lote(

  jsonb_build_object(
      'nombre', 'OXIVAG 4 TAB 70 MG',
      'sku', 'FC-B2123139',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'OXIVAG 4 TAB 70 MG — Ticket 440393',
      'costo', 64.09,
      'precio', 86.53,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  1,
  '650086',
  '2028-02-01',
  64.09,
  null

    );
  end if;
end $$;

-- idempotente FC-11294615
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-11294615') then
    perform producto_id, lote_id from create_producto_with_lote(

  jsonb_build_object(
      'nombre', 'AMIKACINA 2 AMP 500MG/2 ML',
      'sku', 'FC-11294615',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'AMIKACINA 2 AMP 500MG/2 ML — Ticket 440393',
      'costo', 31.94,
      'precio', 43.12,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  1,
  '26F511',
  '2028-02-01',
  31.94,
  null

    );
  end if;
end $$;

-- idempotente FC-1FEA2FB7
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-1FEA2FB7') then
    perform producto_id, lote_id from create_producto_with_lote(

  jsonb_build_object(
      'nombre', 'AMIKACINA 1 AMP 500MG/2 ML',
      'sku', 'FC-1FEA2FB7',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'AMIKACINA 1 AMP 500MG/2 ML — Ticket 440393',
      'costo', 29.21,
      'precio', 39.44,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  1,
  '25T514',
  '2027-10-01',
  29.21,
  null

    );
  end if;
end $$;

-- idempotente FC-AA905BF7
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-AA905BF7') then
    perform producto_id, lote_id from create_producto_with_lote(

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
  end if;
end $$;

-- idempotente FC-AE5EEDF7
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-AE5EEDF7') then
    perform producto_id, lote_id from create_producto_with_lote(

  jsonb_build_object(
      'nombre', 'BACTIVER 20 TAB 400/80 MG',
      'sku', 'FC-AE5EEDF7',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'BACTIVER 20 TAB 400/80 MG — Ticket 440393',
      'costo', 48.65,
      'precio', 65.68,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  1,
  '261013',
  '2028-01-01',
  48.65,
  null

    );
  end if;
end $$;

-- idempotente FC-F8691496
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-F8691496') then
    perform producto_id, lote_id from create_producto_with_lote(

  jsonb_build_object(
      'nombre', 'BACTIVER F 16 TAB 160/800 MG',
      'sku', 'FC-F8691496',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'BACTIVER F 16 TAB 160/800 MG — Ticket 440393',
      'costo', 16.89,
      'precio', 22.81,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  3,
  '261127',
  '2028-03-01',
  16.89,
  null

    );
  end if;
end $$;

-- idempotente FC-6074BB64
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-6074BB64') then
    perform producto_id, lote_id from create_producto_with_lote(

  jsonb_build_object(
      'nombre', 'REDALIP 30 TAB 200 MG',
      'sku', 'FC-6074BB64',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'REDALIP 30 TAB 200 MG — Ticket 440393',
      'costo', 21.01,
      'precio', 28.37,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  2,
  '251660',
  '2027-04-01',
  21.01,
  null

    );
  end if;
end $$;

-- idempotente FC-E826D304
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-E826D304') then
    perform producto_id, lote_id from create_producto_with_lote(

  jsonb_build_object(
      'nombre', 'LINCOMICINA 600MG/2ML 6 AMPOLLETAS',
      'sku', 'FC-E826D304',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'LINCOMICINA 600MG/2ML 6 AMPOLLETAS — Ticket 440393',
      'costo', 47.85,
      'precio', 64.6,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  2,
  'B25D203',
  '2027-12-31',
  47.85,
  null

    );
  end if;
end $$;

-- idempotente FC-4F737E93
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-4F737E93') then
    perform producto_id, lote_id from create_producto_with_lote(

  jsonb_build_object(
      'nombre', 'CLOXAN 1 SOL 300MG/120ML',
      'sku', 'FC-4F737E93',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'CLOXAN 1 SOL 300MG/120ML — Ticket 440393',
      'costo', 44.04,
      'precio', 59.46,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  1,
  'LE2626',
  NULL,
  44.04,
  null

    );
  end if;
end $$;

-- idempotente FC-DB3B2584
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-DB3B2584') then
    perform producto_id, lote_id from create_producto_with_lote(

  jsonb_build_object(
      'nombre', 'CELESBITAN 1 FA C/BER 6MG/2 ML',
      'sku', 'FC-DB3B2584',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'CELESBITAN 1 FA C/BER 6MG/2 ML — Ticket 440393',
      'costo', 16.91,
      'precio', 22.83,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  2,
  '26C2109',
  '2028-06-01',
  16.91,
  null

    );
  end if;
end $$;

-- idempotente FC-22B18244
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-22B18244') then
    perform producto_id, lote_id from create_producto_with_lote(

  jsonb_build_object(
      'nombre', 'CEFOTAXIMA I.M. 1 FA 1G/4 ML',
      'sku', 'FC-22B18244',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'CEFOTAXIMA I.M. 1 FA 1G/4 ML — Ticket 440393',
      'costo', 31.06,
      'precio', 41.94,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  3,
  'J25T017',
  '2027-10-01',
  31.06,
  null

    );
  end if;
end $$;

-- idempotente FC-4A0245DA
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-4A0245DA') then
    perform producto_id, lote_id from create_producto_with_lote(

  jsonb_build_object(
      'nombre', 'AMLODIPINO 100 TAB 5 MG',
      'sku', 'FC-4A0245DA',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'AMLODIPINO 100 TAB 5 MG — Ticket 440393',
      'costo', 32.52,
      'precio', 43.91,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  1,
  '5LM125B',
  '2027-11-09',
  32.52,
  null

    );
  end if;
end $$;

-- idempotente FC-29670370
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-29670370') then
    perform producto_id, lote_id from create_producto_with_lote(

  jsonb_build_object(
      'nombre', 'DEGORTZIN 1 SOL 100 MG/50 ML',
      'sku', 'FC-29670370',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'DEGORTZIN 1 SOL 100 MG/50 ML — Ticket 440393',
      'costo', 35.71,
      'precio', 48.21,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  2,
  '444AA',
  '2028-03-31',
  35.71,
  null

    );
  end if;
end $$;

-- idempotente FC-69A3C416
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-69A3C416') then
    perform producto_id, lote_id from create_producto_with_lote(

  jsonb_build_object(
      'nombre', 'WEXPEC 1 SOL 7.5/2MG/5/120 ML',
      'sku', 'FC-69A3C416',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'WEXPEC 1 SOL 7.5/2MG/5/120 ML — Ticket 440393',
      'costo', 16.65,
      'precio', 22.48,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  1,
  'LB2633',
  '2028-02-01',
  16.65,
  null

    );
  end if;
end $$;

-- idempotente FC-F817BC3A
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-F817BC3A') then
    perform producto_id, lote_id from create_producto_with_lote(

  jsonb_build_object(
      'nombre', 'SIBICOS 1 CMA 1/100/20 G',
      'sku', 'FC-F817BC3A',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'SIBICOS 1 CMA 1/100/20 G — Ticket 440393',
      'costo', 33.65,
      'precio', 45.43,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  2,
  '262040',
  '2028-04-30',
  33.65,
  null

    );
  end if;
end $$;

-- idempotente FC-447B30F9
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-447B30F9') then
    perform producto_id, lote_id from create_producto_with_lote(

  jsonb_build_object(
      'nombre', 'BUDESONIDA 5 AMP 0.250MG/2ML',
      'sku', 'FC-447B30F9',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'BUDESONIDA 5 AMP 0.250MG/2ML — Ticket 440393',
      'costo', 131.38,
      'precio', 177.37,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  1,
  'C26F206',
  '2028-02-01',
  131.38,
  null

    );
  end if;
end $$;

-- idempotente FC-1CF27DC9
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-1CF27DC9') then
    perform producto_id, lote_id from create_producto_with_lote(

  jsonb_build_object(
      'nombre', 'DISON DEX 1 FA 5/2 MG',
      'sku', 'FC-1CF27DC9',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'DISON DEX 1 FA 5/2 MG — Ticket 440393',
      'costo', 36.86,
      'precio', 49.77,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  1,
  '26040978',
  '2028-04-30',
  36.86,
  null

    );
  end if;
end $$;

-- idempotente FC-3CAA7C5C
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-3CAA7C5C') then
    perform producto_id, lote_id from create_producto_with_lote(

  jsonb_build_object(
      'nombre', 'CINARIZINA 60 TAB 75 MG',
      'sku', 'FC-3CAA7C5C',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'CINARIZINA 60 TAB 75 MG — Ticket 440393',
      'costo', 35.05,
      'precio', 47.32,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  2,
  '2605279',
  '2028-05-30',
  35.05,
  null

    );
  end if;
end $$;

-- idempotente FC-E6B50AC3
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-E6B50AC3') then
    perform producto_id, lote_id from create_producto_with_lote(

  jsonb_build_object(
      'nombre', 'CELECOXIB 10 CAPS 200MG',
      'sku', 'FC-E6B50AC3',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'CELECOXIB 10 CAPS 200MG — Ticket 440393',
      'costo', 34.82,
      'precio', 47.01,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  2,
  '6EM120A',
  '2028-05-01',
  34.82,
  null

    );
  end if;
end $$;

-- idempotente FC-6B2ADEE9
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-6B2ADEE9') then
    perform producto_id, lote_id from create_producto_with_lote(

  jsonb_build_object(
      'nombre', 'PRCTAISOL 1 SUSP/AER 200 DOSIS 12.80 G',
      'sku', 'FC-6B2ADEE9',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'PRCTAISOL 1 SUSP/AER 200 DOSIS 12.80 G — Ticket 440393',
      'costo', 96.21,
      'precio', 129.89,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  1,
  'C635',
  '2029-04-01',
  96.21,
  null

    );
  end if;
end $$;

-- idempotente FC-DB4A39AE
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-DB4A39AE') then
    perform producto_id, lote_id from create_producto_with_lote(

  jsonb_build_object(
      'nombre', 'CALCIO EFE 12 COMP 500 MG',
      'sku', 'FC-DB4A39AE',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'CALCIO EFE 12 COMP 500 MG — Ticket 440393',
      'costo', 39.07,
      'precio', 52.75,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  1,
  '29911',
  '2028-05-01',
  39.07,
  null

    );
  end if;
end $$;

-- idempotente FC-FA3D96E6
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-FA3D96E6') then
    perform producto_id, lote_id from create_producto_with_lote(

  jsonb_build_object(
      'nombre', 'BECATRIM N CALCITRIOL 30 CAPS 0.25 MCG',
      'sku', 'FC-FA3D96E6',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'BECATRIM N CALCITRIOL 30 CAPS 0.25 MCG — Ticket 440393',
      'costo', 47.13,
      'precio', 63.63,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  1,
  'U0265',
  '2028-03-01',
  47.13,
  null

    );
  end if;
end $$;

-- idempotente FC-63975795
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-63975795') then
    perform producto_id, lote_id from create_producto_with_lote(

  jsonb_build_object(
      'nombre', 'GENTAMICINA 25 COMP 1 MG',
      'sku', 'FC-63975795',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'GENTAMICINA 25 COMP 1 MG — Ticket 440393',
      'costo', 17.58,
      'precio', 23.74,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  3,
  'U26M335',
  '2028-03-01',
  17.58,
  null

    );
  end if;
end $$;

-- idempotente FC-C6C20517
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-C6C20517') then
    perform producto_id, lote_id from create_producto_with_lote(

  jsonb_build_object(
      'nombre', 'BUDIMIN 20 TAB 1 MG',
      'sku', 'FC-C6C20517',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'BUDIMIN 20 TAB 1 MG — Ticket 440393',
      'costo', 31.31,
      'precio', 42.27,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  1,
  '257237',
  '2027-12-31',
  31.31,
  null

    );
  end if;
end $$;

-- idempotente FC-58DB24C4
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-58DB24C4') then
    perform producto_id, lote_id from create_producto_with_lote(

  jsonb_build_object(
      'nombre', 'BITENVER 30 TAB 24 MG',
      'sku', 'FC-58DB24C4',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'BITENVER 30 TAB 24 MG — Ticket 440393',
      'costo', 62.78,
      'precio', 84.76,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  1,
  '261052',
  '2028-02-01',
  62.78,
  null

    );
  end if;
end $$;

-- idempotente FC-1FFBB505
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-1FFBB505') then
    perform producto_id, lote_id from create_producto_with_lote(

  jsonb_build_object(
      'nombre', 'SUPRATEX DAC 1 SOL 300/600 MG 120 ML',
      'sku', 'FC-1FFBB505',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'SUPRATEX DAC 1 SOL 300/600 MG 120 ML — Ticket 440393',
      'costo', 42.14,
      'precio', 56.89,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  1,
  'SK2102',
  '2027-11-01',
  42.14,
  null

    );
  end if;
end $$;

-- idempotente FC-A909ABC0
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-A909ABC0') then
    perform producto_id, lote_id from create_producto_with_lote(

  jsonb_build_object(
      'nombre', 'ODIVITOR 10 TAB 20 MG',
      'sku', 'FC-A909ABC0',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'ODIVITOR 10 TAB 20 MG — Ticket 440393',
      'costo', 13.77,
      'precio', 18.59,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  3,
  '251614',
  '2029-03-01',
  13.77,
  null

    );
  end if;
end $$;

-- idempotente FC-82F88FED
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-82F88FED') then
    perform producto_id, lote_id from create_producto_with_lote(

  jsonb_build_object(
      'nombre', 'CAPTOPRIL 30 TAB 25 MG',
      'sku', 'FC-82F88FED',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'CAPTOPRIL 30 TAB 25 MG — Ticket 440393',
      'costo', 7.95,
      'precio', 10.74,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  5,
  '6AN062A',
  '2028-01-01',
  7.95,
  null

    );
  end if;
end $$;

-- idempotente FC-6C2878CF
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-6C2878CF') then
    perform producto_id, lote_id from create_producto_with_lote(

  jsonb_build_object(
      'nombre', 'BUDENOVA SUSP 125 MG/ML 5 AMP 2ML',
      'sku', 'FC-6C2878CF',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'BUDENOVA SUSP 125 MG/ML 5 AMP 2ML — Ticket 440393',
      'costo', 130.24,
      'precio', 175.83,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  1,
  '25XY004',
  '2027-12-01',
  130.24,
  null

    );
  end if;
end $$;

-- idempotente FC-3B001F9B
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-3B001F9B') then
    perform producto_id, lote_id from create_producto_with_lote(

  jsonb_build_object(
      'nombre', 'AMLODIPINO 30 TAB 5 MG',
      'sku', 'FC-3B001F9B',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'AMLODIPINO 30 TAB 5 MG — Ticket 440393',
      'costo', 9.04,
      'precio', 12.21,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  3,
  '5EM451B',
  '2027-05-01',
  9.04,
  null

    );
  end if;
end $$;

-- idempotente FC-B25094C4
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-B25094C4') then
    perform producto_id, lote_id from create_producto_with_lote(

  jsonb_build_object(
      'nombre', 'LESACLOR 1 SUSP 200MG/5/125 ML',
      'sku', 'FC-B25094C4',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'LESACLOR 1 SUSP 200MG/5/125 ML — Ticket 440393',
      'costo', 44.43,
      'precio', 59.99,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  1,
  'SK2106',
  '2027-11-01',
  44.43,
  null

    );
  end if;
end $$;

-- idempotente FC-26EA40A4
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-26EA40A4') then
    perform producto_id, lote_id from create_producto_with_lote(

  jsonb_build_object(
      'nombre', 'RAMCINET 10 TAB 10 MG',
      'sku', 'FC-26EA40A4',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'RAMCINET 10 TAB 10 MG — Ticket 440393',
      'costo', 19.65,
      'precio', 26.53,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  6,
  'RRC179',
  '2028-01-31',
  19.65,
  null

    );
  end if;
end $$;

-- idempotente FC-885F2723
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-885F2723') then
    perform producto_id, lote_id from create_producto_with_lote(

  jsonb_build_object(
      'nombre', 'CARBAMAZEPINA 20 TAB 200 MG',
      'sku', 'FC-885F2723',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'CARBAMAZEPINA 20 TAB 200 MG — Ticket 440393',
      'costo', 18.11,
      'precio', 24.45,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  3,
  '7220526',
  '2029-05-01',
  18.11,
  null

    );
  end if;
end $$;

-- idempotente FC-DF8ADDAB
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-DF8ADDAB') then
    perform producto_id, lote_id from create_producto_with_lote(

  jsonb_build_object(
      'nombre', 'ERISPAN 1 FA 4MG/3 ML',
      'sku', 'FC-DF8ADDAB',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'ERISPAN 1 FA 4MG/3 ML — Ticket 440393',
      'costo', 22.15,
      'precio', 29.91,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  1,
  '256110',
  '2027-10-01',
  22.15,
  null

    );
  end if;
end $$;

-- idempotente FC-50AC2C82
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-50AC2C82') then
    perform producto_id, lote_id from create_producto_with_lote(

  jsonb_build_object(
      'nombre', 'ERISPAN 1 FA 8MG/2 ML',
      'sku', 'FC-50AC2C82',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'ERISPAN 1 FA 8MG/2 ML — Ticket 440393',
      'costo', 24.45,
      'precio', 33.01,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  1,
  '256664',
  '2027-11-01',
  24.45,
  null

    );
  end if;
end $$;

-- idempotente FC-281E0F22
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-281E0F22') then
    perform producto_id, lote_id from create_producto_with_lote(

  jsonb_build_object(
      'nombre', 'BUDESONIDA 1 SUSP NEB AMP 0.500MG',
      'sku', 'FC-281E0F22',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'BUDESONIDA 1 SUSP NEB AMP 0.500MG — Ticket 440393',
      'costo', 153.72,
      'precio', 207.53,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  1,
  'C26E206',
  '2028-01-01',
  153.72,
  null

    );
  end if;
end $$;

-- idempotente FC-9F67BB73
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-9F67BB73') then
    perform producto_id, lote_id from create_producto_with_lote(

  jsonb_build_object(
      'nombre', 'AMIFARIN 1 SUSP 250MG 60 ML',
      'sku', 'FC-9F67BB73',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'AMIFARIN 1 SUSP 250MG 60 ML — Ticket 440393',
      'costo', 27.0,
      'precio', 36.46,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  1,
  'S6117',
  '2028-01-01',
  27.0,
  null

    );
  end if;
end $$;

-- idempotente FC-4FD413D2
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-4FD413D2') then
    perform producto_id, lote_id from create_producto_with_lote(

  jsonb_build_object(
      'nombre', 'HASPEN 3 AMP 20 MG/1 ML',
      'sku', 'FC-4FD413D2',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'HASPEN 3 AMP 20 MG/1 ML — Ticket 440393',
      'costo', 23.53,
      'precio', 31.77,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  1,
  '6S032',
  '2028-05-05',
  23.53,
  null

    );
  end if;
end $$;

-- idempotente FC-0BDE9283
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-0BDE9283') then
    perform producto_id, lote_id from create_producto_with_lote(

  jsonb_build_object(
      'nombre', 'CLOPHIVEN 200 DOSIS 50 MCG/15 G',
      'sku', 'FC-0BDE9283',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'CLOPHIVEN 200 DOSIS 50 MCG/15 G — Ticket 440393',
      'costo', 56.51,
      'precio', 76.29,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  1,
  'CLOPHIVEN',
  '2029-05-19',
  56.51,
  null

    );
  end if;
end $$;

-- idempotente FC-97BEFA1A
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-97BEFA1A') then
    perform producto_id, lote_id from create_producto_with_lote(

  jsonb_build_object(
      'nombre', 'AMLODIPINO 100 TAB 5 MG',
      'sku', 'FC-97BEFA1A',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'AMLODIPINO 100 TAB 5 MG — Ticket 440393',
      'costo', 32.52,
      'precio', 43.91,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  1,
  '5MM301A',
  '2027-12-31',
  32.52,
  null

    );
  end if;
end $$;

-- idempotente FC-DEAF33B0
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-DEAF33B0') then
    perform producto_id, lote_id from create_producto_with_lote(

  jsonb_build_object(
      'nombre', 'BACTIVER 1 SUSP 40/200/5/120 ML',
      'sku', 'FC-DEAF33B0',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'BACTIVER 1 SUSP 40/200/5/120 ML — Ticket 440393',
      'costo', 21.28,
      'precio', 28.73,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  1,
  '262631',
  '2028-05-01',
  21.28,
  null

    );
  end if;
end $$;

-- idempotente FC-77FE5C83
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-77FE5C83') then
    perform producto_id, lote_id from create_producto_with_lote(

  jsonb_build_object(
      'nombre', 'SONBLEFAM S 1 CMA 100 G/40 G',
      'sku', 'FC-77FE5C83',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'SONBLEFAM S 1 CMA 100 G/40 G — Ticket 440393',
      'costo', 32.41,
      'precio', 43.76,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  1,
  '26061504',
  '2028-06-30',
  32.41,
  null

    );
  end if;
end $$;

-- idempotente FC-C636D8EA
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-C636D8EA') then
    perform producto_id, lote_id from create_producto_with_lote(

  jsonb_build_object(
      'nombre', 'CEFTRIAXONA I.M. 1 FA 1G/3.5 ML',
      'sku', 'FC-C636D8EA',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'CEFTRIAXONA I.M. 1 FA 1G/3.5 ML — Ticket 440393',
      'costo', 9.8,
      'precio', 13.24,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  2,
  'J25G109',
  '2027-03-31',
  9.8,
  null

    );
  end if;
end $$;

-- idempotente FC-44B6751A
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-44B6751A') then
    perform producto_id, lote_id from create_producto_with_lote(

  jsonb_build_object(
      'nombre', 'LAUR AQUITO 500/100/30/4 MG 3 AMP',
      'sku', 'FC-44B6751A',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'LAUR AQUITO 500/100/30/4 MG 3 AMP — Ticket 440393',
      'costo', 59.63,
      'precio', 80.51,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  1,
  'B26031S',
  '2028-01-01',
  59.63,
  null

    );
  end if;
end $$;

-- idempotente FC-9B93AC4C
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-9B93AC4C') then
    perform producto_id, lote_id from create_producto_with_lote(

  jsonb_build_object(
      'nombre', 'BENEVENTOL 1 SUSP 100MG/5ML/50 ML',
      'sku', 'FC-9B93AC4C',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'BENEVENTOL 1 SUSP 100MG/5ML/50 ML — Ticket 440393',
      'costo', 97.6,
      'precio', 131.76,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  1,
  '256866',
  '2027-12-01',
  97.6,
  null

    );
  end if;
end $$;

-- idempotente FC-2001A890
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-2001A890') then
    perform producto_id, lote_id from create_producto_with_lote(

  jsonb_build_object(
      'nombre', 'AMPIGRIN AD 3 AMP 500/500/100/30MG/3 ML',
      'sku', 'FC-2001A890',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'AMPIGRIN AD 3 AMP 500/500/100/30MG/3 ML — Ticket 440393',
      'costo', 81.71,
      'precio', 110.31,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  2,
  '26240110',
  '2028-03-31',
  81.71,
  null

    );
  end if;
end $$;

-- idempotente FC-DE106642
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-DE106642') then
    perform producto_id, lote_id from create_producto_with_lote(

  jsonb_build_object(
      'nombre', 'AMPIGRIN INF 3 AMP 250/200/100/30MG/3 ML',
      'sku', 'FC-DE106642',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'AMPIGRIN INF 3 AMP 250/200/100/30MG/3 ML — Ticket 440393',
      'costo', 73.57,
      'precio', 99.32,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  1,
  '26240043',
  '2028-02-01',
  73.57,
  null

    );
  end if;
end $$;

-- idempotente FC-BE76D409
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-BE76D409') then
    perform producto_id, lote_id from create_producto_with_lote(

  jsonb_build_object(
      'nombre', 'AMCEF I.M. 1 FA 1G/3.5 ML',
      'sku', 'FC-BE76D409',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'AMCEF I.M. 1 FA 1G/3.5 ML — Ticket 440393',
      'costo', 19.72,
      'precio', 26.63,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  10,
  'J25N044',
  '2027-11-01',
  19.72,
  null

    );
  end if;
end $$;

-- idempotente FC-07F04F88
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-07F04F88') then
    perform producto_id, lote_id from create_producto_with_lote(

  jsonb_build_object(
      'nombre', 'AMCEF I.M. 1 FA 500MG/2 ML',
      'sku', 'FC-07F04F88',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'AMCEF I.M. 1 FA 500MG/2 ML — Ticket 440393',
      'costo', 19.43,
      'precio', 26.24,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  2,
  'J25D063',
  '2028-03-01',
  19.43,
  null

    );
  end if;
end $$;

-- idempotente FC-357D4A17
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-357D4A17') then
    perform producto_id, lote_id from create_producto_with_lote(

  jsonb_build_object(
      'nombre', 'CEFTAZIDIMA 1 FA 1G/3 ML',
      'sku', 'FC-357D4A17',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'CEFTAZIDIMA 1 FA 1G/3 ML — Ticket 440393',
      'costo', 45.42,
      'precio', 61.32,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  2,
  'J25D018',
  '2028-03-01',
  45.42,
  null

    );
  end if;
end $$;

-- idempotente FC-5D9DFA3D
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-5D9DFA3D') then
    perform producto_id, lote_id from create_producto_with_lote(

  jsonb_build_object(
      'nombre', 'NORQUINOL 20 TAB 400 MG',
      'sku', 'FC-5D9DFA3D',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'NORQUINOL 20 TAB 400 MG — Ticket 440393',
      'costo', 48.87,
      'precio', 65.98,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  2,
  'SK2094',
  '2027-11-30',
  48.87,
  null

    );
  end if;
end $$;

-- idempotente FC-E9C38DC4
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-E9C38DC4') then
    perform producto_id, lote_id from create_producto_with_lote(

  jsonb_build_object(
      'nombre', 'CIPROFLOXACINO G.I. 14 TAB 500 MG',
      'sku', 'FC-E9C38DC4',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'CIPROFLOXACINO G.I. 14 TAB 500 MG — Ticket 440393',
      'costo', 22.92,
      'precio', 30.95,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  5,
  'U26F042',
  '2028-02-01',
  22.92,
  null

    );
  end if;
end $$;

-- idempotente FC-347A49C7
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-347A49C7') then
    perform producto_id, lote_id from create_producto_with_lote(

  jsonb_build_object(
      'nombre', 'AMIKACINA 1 AMP 100 MG/2 ML',
      'sku', 'FC-347A49C7',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'AMIKACINA 1 AMP 100 MG/2 ML — Ticket 440393',
      'costo', 19.46,
      'precio', 26.28,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  1,
  '25T515',
  '2027-10-01',
  19.46,
  null

    );
  end if;
end $$;

-- idempotente FC-E4BE37BE
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-E4BE37BE') then
    perform producto_id, lote_id from create_producto_with_lote(

  jsonb_build_object(
      'nombre', 'ATORVASTATINA 10 TAB 40 MG',
      'sku', 'FC-E4BE37BE',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'ATORVASTATINA 10 TAB 40 MG — Ticket 440393',
      'costo', 26.35,
      'precio', 35.58,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  2,
  'U26E117',
  '2028-05-01',
  26.35,
  null

    );
  end if;
end $$;

-- idempotente FC-1751468C
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-1751468C') then
    perform producto_id, lote_id from create_producto_with_lote(

  jsonb_build_object(
      'nombre', 'FLOSPET 8 TAB 400 MG',
      'sku', 'FC-1751468C',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'FLOSPET 8 TAB 400 MG — Ticket 440393',
      'costo', 27.33,
      'precio', 36.9,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  1,
  '5J1920',
  '2027-10-31',
  27.33,
  null

    );
  end if;
end $$;

-- idempotente FC-6898B64F
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-6898B64F') then
    perform producto_id, lote_id from create_producto_with_lote(

  jsonb_build_object(
      'nombre', 'BIOERTER 1 SUSP 250 MG/100 ML',
      'sku', 'FC-6898B64F',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'BIOERTER 1 SUSP 250 MG/100 ML — Ticket 440393',
      'costo', 47.7,
      'precio', 64.4,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  1,
  '0226330',
  '2026-02-01',
  47.7,
  null

    );
  end if;
end $$;

-- idempotente FC-CD261CD5
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-CD261CD5') then
    perform producto_id, lote_id from create_producto_with_lote(

  jsonb_build_object(
      'nombre', 'DOLIPROFEN 10 TAB 800 MG',
      'sku', 'FC-CD261CD5',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'DOLIPROFEN 10 TAB 800 MG — Ticket 440393',
      'costo', 22.41,
      'precio', 30.26,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  5,
  '26140712',
  '2028-03-09',
  22.41,
  null

    );
  end if;
end $$;

-- idempotente FC-5C8C9C11
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-5C8C9C11') then
    perform producto_id, lote_id from create_producto_with_lote(

  jsonb_build_object(
      'nombre', 'GELUBRIN 10 CAPS 600 MG',
      'sku', 'FC-5C8C9C11',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'GELUBRIN 10 CAPS 600 MG — Ticket 440393',
      'costo', 21.95,
      'precio', 29.64,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  5,
  'U0397',
  '2028-04-10',
  21.95,
  null

    );
  end if;
end $$;

-- idempotente FC-A23F290E
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-A23F290E') then
    perform producto_id, lote_id from create_producto_with_lote(

  jsonb_build_object(
      'nombre', 'ZITRIASOL 15 CAP 100 MG',
      'sku', 'FC-A23F290E',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'ZITRIASOL 15 CAP 100 MG — Ticket 440393',
      'costo', 34.61,
      'precio', 46.73,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  2,
  'SD26112',
  '2028-04-30',
  34.61,
  null

    );
  end if;
end $$;

-- idempotente FC-5885E577
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-5885E577') then
    perform producto_id, lote_id from create_producto_with_lote(

  jsonb_build_object(
      'nombre', 'PABESORAG 28 TAB 150/12.5 MG',
      'sku', 'FC-5885E577',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'PABESORAG 28 TAB 150/12.5 MG — Ticket 440393',
      'costo', 60.47,
      'precio', 81.64,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  1,
  '610426',
  '2028-04-01',
  60.47,
  null

    );
  end if;
end $$;

-- idempotente FC-3D0F54B7
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-3D0F54B7') then
    perform producto_id, lote_id from create_producto_with_lote(

  jsonb_build_object(
      'nombre', 'IBUPRO-CAFE 10 CAPS 400 MG/100 MG',
      'sku', 'FC-3D0F54B7',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'IBUPRO-CAFE 10 CAPS 400 MG/100 MG — Ticket 440393',
      'costo', 30.06,
      'precio', 40.59,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  2,
  'M26052',
  '2028-03-30',
  30.06,
  null

    );
  end if;
end $$;

-- idempotente FC-F7A2CACF
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-F7A2CACF') then
    perform producto_id, lote_id from create_producto_with_lote(

  jsonb_build_object(
      'nombre', 'INDARZONA 30 CAPS 25/0.5 MG',
      'sku', 'FC-F7A2CACF',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'INDARZONA 30 CAPS 25/0.5 MG — Ticket 440393',
      'costo', 56.3,
      'precio', 76.01,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  2,
  'SB01DC',
  '2028-04-01',
  56.3,
  null

    );
  end if;
end $$;

-- idempotente FC-50D044FF
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-50D044FF') then
    perform producto_id, lote_id from create_producto_with_lote(

  jsonb_build_object(
      'nombre', 'WERMY 15 CAPS 300 MG',
      'sku', 'FC-50D044FF',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'WERMY 15 CAPS 300 MG — Ticket 440393',
      'costo', 24.51,
      'precio', 33.09,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  2,
  '260373',
  '2028-04-01',
  24.51,
  null

    );
  end if;
end $$;

-- idempotente FC-E535DE28
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-E535DE28') then
    perform producto_id, lote_id from create_producto_with_lote(

  jsonb_build_object(
      'nombre', 'DIURMESSEL 20 TAB 40 MG',
      'sku', 'FC-E535DE28',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'DIURMESSEL 20 TAB 40 MG — Ticket 440393',
      'costo', 9.31,
      'precio', 12.57,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  5,
  'SB2664',
  '2028-02-01',
  9.31,
  null

    );
  end if;
end $$;

-- idempotente FC-1321B34F
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-1321B34F') then
    perform producto_id, lote_id from create_producto_with_lote(

  jsonb_build_object(
      'nombre', 'HIDROXON 30 TAB 10 MG',
      'sku', 'FC-1321B34F',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'HIDROXON 30 TAB 10 MG — Ticket 440393',
      'costo', 34.6,
      'precio', 46.72,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  1,
  'SK2109',
  '2028-11-01',
  34.6,
  null

    );
  end if;
end $$;

-- idempotente FC-1AE9D7E6
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-1AE9D7E6') then
    perform producto_id, lote_id from create_producto_with_lote(

  jsonb_build_object(
      'nombre', 'COLLUCORT 1 CMA 1% 60 G',
      'sku', 'FC-1AE9D7E6',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'COLLUCORT 1 CMA 1% 60 G — Ticket 440393',
      'costo', 47.85,
      'precio', 64.6,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  2,
  '26340160',
  '2028-10-30',
  47.85,
  null

    );
  end if;
end $$;

-- idempotente FC-3E863E37
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-3E863E37') then
    perform producto_id, lote_id from create_producto_with_lote(

  jsonb_build_object(
      'nombre', 'TRATIDRI 1 GEL 500/50 MG 60 G',
      'sku', 'FC-3E863E37',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'TRATIDRI 1 GEL 500/50 MG 60 G — Ticket 440393',
      'costo', 47.47,
      'precio', 64.09,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  1,
  '261001',
  '2028-02-01',
  47.47,
  null

    );
  end if;
end $$;

-- idempotente FC-9ABFB996
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-9ABFB996') then
    perform producto_id, lote_id from create_producto_with_lote(

  jsonb_build_object(
      'nombre', 'ELAPHTERON 20 TAB 100 MG',
      'sku', 'FC-9ABFB996',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'ELAPHTERON 20 TAB 100 MG — Ticket 440393',
      'costo', 30.77,
      'precio', 41.54,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  1,
  'B26050',
  '2029-02-28',
  30.77,
  null

    );
  end if;
end $$;

-- idempotente FC-9A37D44A
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-9A37D44A') then
    perform producto_id, lote_id from create_producto_with_lote(

  jsonb_build_object(
      'nombre', 'AMDORYL 14 CAPS 30 MG',
      'sku', 'FC-9A37D44A',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'AMDORYL 14 CAPS 30 MG — Ticket 440393',
      'costo', 26.11,
      'precio', 35.25,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  2,
  '260066',
  '2028-02-01',
  26.11,
  null

    );
  end if;
end $$;

-- idempotente FC-1BF03D35
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-1BF03D35') then
    perform producto_id, lote_id from create_producto_with_lote(

  jsonb_build_object(
      'nombre', 'ACETONIDO DE FLUOCINOLONA CMA',
      'sku', 'FC-1BF03D35',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'ACETONIDO DE FLUOCINOLONA CMA — Ticket 440393',
      'costo', 18.44,
      'precio', 24.9,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  1,
  '2601201',
  '2028-01-01',
  18.44,
  null

    );
  end if;
end $$;

-- idempotente FC-5BC5F234
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-5BC5F234') then
    perform producto_id, lote_id from create_producto_with_lote(

  jsonb_build_object(
      'nombre', 'FLUCONAZOL 1 CAPS 150 MG',
      'sku', 'FC-5BC5F234',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'FLUCONAZOL 1 CAPS 150 MG — Ticket 440393',
      'costo', 12.92,
      'precio', 17.45,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  2,
  'U25N344',
  '2027-11-30',
  12.92,
  null

    );
  end if;
end $$;

-- idempotente FC-A2B284E0
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-A2B284E0') then
    perform producto_id, lote_id from create_producto_with_lote(

  jsonb_build_object(
      'nombre', 'HIALURONATO DE SODIO 4MG 10 ML',
      'sku', 'FC-A2B284E0',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'HIALURONATO DE SODIO 4MG 10 ML — Ticket 440393',
      'costo', 113.89,
      'precio', 153.76,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  1,
  '26161P',
  '2028-03-11',
  113.89,
  null

    );
  end if;
end $$;

-- idempotente FC-2E79C2D8
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-2E79C2D8') then
    perform producto_id, lote_id from create_producto_with_lote(

  jsonb_build_object(
      'nombre', 'HIERRO DEX 3 AMP 100 MG/2 ML',
      'sku', 'FC-2E79C2D8',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'HIERRO DEX 3 AMP 100 MG/2 ML — Ticket 440393',
      'costo', 61.33,
      'precio', 82.8,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  1,
  'B25T405',
  '2027-10-01',
  61.33,
  null

    );
  end if;
end $$;

-- idempotente FC-28A424E5
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-28A424E5') then
    perform producto_id, lote_id from create_producto_with_lote(

  jsonb_build_object(
      'nombre', 'DIZIVER 20 TAB 25 MG',
      'sku', 'FC-28A424E5',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'DIZIVER 20 TAB 25 MG — Ticket 440393',
      'costo', 8.15,
      'precio', 11.01,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  3,
  '261313',
  '2028-02-01',
  8.15,
  null

    );
  end if;
end $$;

-- idempotente FC-52D2A43A
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-52D2A43A') then
    perform producto_id, lote_id from create_producto_with_lote(

  jsonb_build_object(
      'nombre', 'ZUKEDIB 30 TAB 2 MG',
      'sku', 'FC-52D2A43A',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'ZUKEDIB 30 TAB 2 MG — Ticket 440393',
      'costo', 29.08,
      'precio', 39.26,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  1,
  'R25126048',
  '2028-01-13',
  29.08,
  null

    );
  end if;
end $$;

-- idempotente FC-3D0ED22B
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-3D0ED22B') then
    perform producto_id, lote_id from create_producto_with_lote(

  jsonb_build_object(
      'nombre', 'ZUKEDIB 30 TAB 4 MG',
      'sku', 'FC-3D0ED22B',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'ZUKEDIB 30 TAB 4 MG — Ticket 440393',
      'costo', 27.98,
      'precio', 37.78,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  1,
  'R2506781',
  '2027-06-30',
  27.98,
  null

    );
  end if;
end $$;

-- idempotente FC-04D83B46
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-04D83B46') then
    perform producto_id, lote_id from create_producto_with_lote(

  jsonb_build_object(
      'nombre', 'PRALEX 28 TAB 10 MG',
      'sku', 'FC-04D83B46',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'PRALEX 28 TAB 10 MG — Ticket 440393',
      'costo', 42.85,
      'precio', 57.85,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  2,
  '6D064G',
  '2028-02-01',
  42.85,
  null

    );
  end if;
end $$;

-- idempotente FC-D11D586A
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-D11D586A') then
    perform producto_id, lote_id from create_producto_with_lote(

  jsonb_build_object(
      'nombre', 'VALGAB 3 IBE 50MG/6ML',
      'sku', 'FC-D11D586A',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'VALGAB 3 IBE 50MG/6ML — Ticket 440393',
      'costo', 19.41,
      'precio', 26.21,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  1,
  'L2K501',
  '2027-11-01',
  19.41,
  null

    );
  end if;
end $$;

-- idempotente FC-53506FA4
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-53506FA4') then
    perform producto_id, lote_id from create_producto_with_lote(

  jsonb_build_object(
      'nombre', 'ENALAPRIL 30 TAB 10 MG',
      'sku', 'FC-53506FA4',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'ENALAPRIL 30 TAB 10 MG — Ticket 440393',
      'costo', 8.09,
      'precio', 10.93,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  5,
  '6N50A',
  '2028-03-01',
  8.09,
  null

    );
  end if;
end $$;

-- idempotente FC-F7DB080D
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-F7DB080D') then
    perform producto_id, lote_id from create_producto_with_lote(

  jsonb_build_object(
      'nombre', 'OVISEN 28 TAB 20 MG',
      'sku', 'FC-F7DB080D',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'OVISEN 28 TAB 20 MG — Ticket 440393',
      'costo', 20.33,
      'precio', 27.45,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  1,
  'SC2617',
  '2028-03-01',
  20.33,
  null

    );
  end if;
end $$;

-- idempotente FC-FD92D114
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-FD92D114') then
    perform producto_id, lote_id from create_producto_with_lote(

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
  end if;
end $$;

-- idempotente FC-57925EF3
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-57925EF3') then
    perform producto_id, lote_id from create_producto_with_lote(

  jsonb_build_object(
      'nombre', 'REGLUSAN 50 TAB 5 MG',
      'sku', 'FC-57925EF3',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'REGLUSAN 50 TAB 5 MG — Ticket 440393',
      'costo', 8.88,
      'precio', 11.99,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  5,
  '710026',
  '2029-02-01',
  8.88,
  null

    );
  end if;
end $$;

-- idempotente FC-AA7B0686
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-AA7B0686') then
    perform producto_id, lote_id from create_producto_with_lote(

  jsonb_build_object(
      'nombre', 'DROSQUIM AD 1 IBE 300/160/200 ML',
      'sku', 'FC-AA7B0686',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'DROSQUIM AD 1 IBE 300/160/200 ML — Ticket 440393',
      'costo', 70.74,
      'precio', 95.5,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  1,
  '26DP32',
  '2028-04-01',
  70.74,
  null

    );
  end if;
end $$;

-- idempotente FC-B3B8F9BB
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-B3B8F9BB') then
    perform producto_id, lote_id from create_producto_with_lote(

  jsonb_build_object(
      'nombre', 'DESROTAN 10 TAB 180 MG',
      'sku', 'FC-B3B8F9BB',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'DESROTAN 10 TAB 180 MG — Ticket 440393',
      'costo', 47.31,
      'precio', 63.87,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  1,
  'RD065',
  '2028-03-31',
  47.31,
  null

    );
  end if;
end $$;

-- idempotente FC-EADF1484
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-EADF1484') then
    perform producto_id, lote_id from create_producto_with_lote(

  jsonb_build_object(
      'nombre', 'DIOSMINA HESPERIDINA 20 TAB 450/50 MG',
      'sku', 'FC-EADF1484',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'DIOSMINA HESPERIDINA 20 TAB 450/50 MG — Ticket 440393',
      'costo', 39.41,
      'precio', 53.21,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  3,
  'C50366',
  '2028-05-01',
  39.41,
  null

    );
  end if;
end $$;

-- idempotente FC-262F2A30
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-262F2A30') then
    perform producto_id, lote_id from create_producto_with_lote(

  jsonb_build_object(
      'nombre', 'IRBESARTAN 14 TAB 150 MG',
      'sku', 'FC-262F2A30',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'IRBESARTAN 14 TAB 150 MG — Ticket 440393',
      'costo', 43.98,
      'precio', 59.38,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  1,
  'U25U621',
  '2027-09-01',
  43.98,
  null

    );
  end if;
end $$;

-- idempotente FC-1DAD5EF1
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-1DAD5EF1') then
    perform producto_id, lote_id from create_producto_with_lote(

  jsonb_build_object(
      'nombre', 'TUSILEN AD 1 IBE 240/30/50MG/100/118 ML',
      'sku', 'FC-1DAD5EF1',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'TUSILEN AD 1 IBE 240/30/50MG/100/118 ML — Ticket 440393',
      'costo', 24.22,
      'precio', 32.7,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  1,
  '2513407',
  '2029-10-20',
  24.22,
  null

    );
  end if;
end $$;

-- idempotente FC-BDB2E087
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-BDB2E087') then
    perform producto_id, lote_id from create_producto_with_lote(

  jsonb_build_object(
      'nombre', 'IRBESARTAN 14 TAB 300 MG',
      'sku', 'FC-BDB2E087',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'IRBESARTAN 14 TAB 300 MG — Ticket 440393',
      'costo', 70.49,
      'precio', 95.17,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  1,
  'U26E239',
  '2028-01-01',
  70.49,
  null

    );
  end if;
end $$;

-- idempotente FC-759A5EF9
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-759A5EF9') then
    perform producto_id, lote_id from create_producto_with_lote(

  jsonb_build_object(
      'nombre', 'WERMY 30 CAPS 300 MG',
      'sku', 'FC-759A5EF9',
      'codigo_barras', NULL,
      'categoria', 'GENERAL',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'WERMY 30 CAPS 300 MG — Ticket 440393',
      'costo', 24.89,
      'precio', 33.61,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
  2,
  '260486',
  '2028-05-01',
  24.89,
  null

    );
  end if;
end $$;

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

-- 112558 L8 CREMA ROJA VITACILINA ANTIARRUGAS 100GR
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-76000253'
     or codigo_barras = '7506376000253'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7506376000253', id from public.productos where codigo_barras = '7506376000253'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- 112558 L9 DIAPRO CONFORT MED C/10
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-16800803'
     or codigo_barras = '7501116800803'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7501116800803', id from public.productos where codigo_barras = '7501116800803'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- 112558 L10 DABAN ALCOHOL AZUL 125ML.
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-86901100'
     or codigo_barras = '7501186901100'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7501186901100', id from public.productos where codigo_barras = '7501186901100'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- 112558 L11 ALCOHOL AZUL 1LT
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-68901131'
     or codigo_barras = '7501868901131'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7501868901131', id from public.productos where codigo_barras = '7501868901131'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- 112558 L12 DIBAR ALCOHOL AZUL 250ML
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-68901117'
     or codigo_barras = '7501868901117'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7501868901117', id from public.productos where codigo_barras = '7501868901117'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- 112558 L13 ALCOHOL AZUL 500ML
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-68901124'
     or codigo_barras = '7501868901124'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7501868901124', id from public.productos where codigo_barras = '7501868901124'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- 112558 L14 BOLO EUROBION TAB C/20
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-98223704'
     or codigo_barras = '7501298223704'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7501298223704', id from public.productos where codigo_barras = '7501298223704'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- 112558 L15 LIO 236ML CHTE
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-33950100'
     or codigo_barras = '7501033950100'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7501033950100', id from public.productos where codigo_barras = '7501033950100'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- 112558 L16 BASUYE LIQ 236ML FSA
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-33950063'
     or codigo_barras = '7501033950063'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7501033950063', id from public.productos where codigo_barras = '7501033950063'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- 112558 L17 ENSURE LIQ 236ML VNLLA
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-33950070'
     or codigo_barras = '7501033950070'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7501033950070', id from public.productos where codigo_barras = '7501033950070'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- 112558 L18 LUCERNA LIQ 237ML
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-33956133'
     or codigo_barras = '7501033956133'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7501033956133', id from public.productos where codigo_barras = '7501033956133'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- 112558 L19 GLUCERNA SR LIQ 237ML FRESA
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-33956140'
     or codigo_barras = '7501033956140'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7501033956140', id from public.productos where codigo_barras = '7501033956140'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- 112558 L20 GOTERO CRISTAL
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-07521317'
     or codigo_barras = '7501507521317'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7501507521317', id from public.productos where codigo_barras = '7501507521317'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- 112558 L21 NATURELLA FLUJO MOD C/ALAS C/8
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-01157296'
     or codigo_barras = '7501001157296'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7501001157296', id from public.productos where codigo_barras = '7501001157296'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- 112558 L22 NATURELLA NOCHE CON ALAS C/8
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-01405335'
     or codigo_barras = '7501001405335'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7501001405335', id from public.productos where codigo_barras = '7501001405335'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- 112558 L23 EDIASURE LIQ 236ML CHTE
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-33951008'
     or codigo_barras = '7501033951008'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7501033951008', id from public.productos where codigo_barras = '7501033951008'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- 112558 L24 PEDIASURE LIQ 236ML FSA
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-33954245'
     or codigo_barras = '7501033954245'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7501033954245', id from public.productos where codigo_barras = '7501033954245'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- 112558 L25 PEDIASURE LIQ 236ML VNLLA
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-33950209'
     or codigo_barras = '7501033950209'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7501033950209', id from public.productos where codigo_barras = '7501033950209'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- 112558 L26 SABA BUENAS NOCHES
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-19006623'
     or codigo_barras = '7501019006623'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7501019006623', id from public.productos where codigo_barras = '7501019006623'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- 112558 L27 TB 3 SURT
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-65054135'
     or codigo_barras = '7501065054135'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7501065054135', id from public.productos where codigo_barras = '7501065054135'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- 112558 L28 FASELINE PURO 42G
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-56323066'
     or codigo_barras = '7501056323066'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7501056323066', id from public.productos where codigo_barras = '7501056323066'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- 112558 L29 VASELINE PURO 85G
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-56323059'
     or codigo_barras = '7501056323059'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7501056323059', id from public.productos where codigo_barras = '7501056323059'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- 112558 L30 VAPORUB POM 12G C12 LATAS
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-01246730'
     or codigo_barras = '7501001246730'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7501001246730', id from public.productos where codigo_barras = '7501001246730'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- 112558 L31 VICK NAPORUB UNG 100G
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-02012475'
     or codigo_barras = '7590002012475'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7590002012475', id from public.productos where codigo_barras = '7590002012475'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- 112558 L32 VICK VAPORUB UNG 50G
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-02012468'
     or codigo_barras = '7590002012468'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7590002012468', id from public.productos where codigo_barras = '7590002012468'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- idempotente FC-1FBF5206
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-1FBF5206') then
    perform producto_id, lote_id from create_producto_with_lote(

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
  end if;
end $$;

-- idempotente FC-2E5B7248
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-2E5B7248') then
    perform producto_id, lote_id from create_producto_with_lote(

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
  end if;
end $$;

-- idempotente FC-D12CA0FA
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-D12CA0FA') then
    perform producto_id, lote_id from create_producto_with_lote(

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
  end if;
end $$;

-- idempotente FC-62034164
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-62034164') then
    perform producto_id, lote_id from create_producto_with_lote(

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
  end if;
end $$;

-- idempotente FC-3676D5DC
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-3676D5DC') then
    perform producto_id, lote_id from create_producto_with_lote(

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
  end if;
end $$;

-- idempotente FC-5A697CC2
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-5A697CC2') then
    perform producto_id, lote_id from create_producto_with_lote(

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
  end if;
end $$;

-- idempotente FC-39036C88
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-39036C88') then
    perform producto_id, lote_id from create_producto_with_lote(

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
  end if;
end $$;

-- idempotente FC-DFF99C3F
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-DFF99C3F') then
    perform producto_id, lote_id from create_producto_with_lote(

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
  end if;
end $$;

-- idempotente FC-931B4809
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-931B4809') then
    perform producto_id, lote_id from create_producto_with_lote(

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
  end if;
end $$;

-- idempotente FC-D4AC123B
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-D4AC123B') then
    perform producto_id, lote_id from create_producto_with_lote(

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
  end if;
end $$;

-- idempotente FC-38CAFE6B
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-38CAFE6B') then
    perform producto_id, lote_id from create_producto_with_lote(

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
  end if;
end $$;

-- idempotente FC-926099D3
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-926099D3') then
    perform producto_id, lote_id from create_producto_with_lote(

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
  end if;
end $$;

-- idempotente FC-E69F2E63
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-E69F2E63') then
    perform producto_id, lote_id from create_producto_with_lote(

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
  end if;
end $$;

-- idempotente FC-25E452B6
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-25E452B6') then
    perform producto_id, lote_id from create_producto_with_lote(

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
  end if;
end $$;

-- idempotente FC-127F5753
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-127F5753') then
    perform producto_id, lote_id from create_producto_with_lote(

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
  end if;
end $$;

-- idempotente FC-D3D28E20
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-D3D28E20') then
    perform producto_id, lote_id from create_producto_with_lote(

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
  end if;
end $$;

-- idempotente FC-69387811
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-69387811') then
    perform producto_id, lote_id from create_producto_with_lote(

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
  end if;
end $$;

-- idempotente FC-A680F97E
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-A680F97E') then
    perform producto_id, lote_id from create_producto_with_lote(

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
  end if;
end $$;

-- idempotente FC-C4530823
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-C4530823') then
    perform producto_id, lote_id from create_producto_with_lote(

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
  end if;
end $$;

-- idempotente FC-D037156B
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-D037156B') then
    perform producto_id, lote_id from create_producto_with_lote(

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
  end if;
end $$;

-- idempotente FC-B8D7C997
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-B8D7C997') then
    perform producto_id, lote_id from create_producto_with_lote(

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
  end if;
end $$;

-- idempotente FC-CB5C11ED
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-CB5C11ED') then
    perform producto_id, lote_id from create_producto_with_lote(

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
  end if;
end $$;

-- idempotente FC-A871D831
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-A871D831') then
    perform producto_id, lote_id from create_producto_with_lote(

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
  end if;
end $$;

-- idempotente FC-578F060C
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-578F060C') then
    perform producto_id, lote_id from create_producto_with_lote(

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
  end if;
end $$;

-- idempotente FC-FBD776D2
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-FBD776D2') then
    perform producto_id, lote_id from create_producto_with_lote(

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
  end if;
end $$;

-- idempotente FC-5EF90195
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-5EF90195') then
    perform producto_id, lote_id from create_producto_with_lote(

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
  end if;
end $$;

-- idempotente FC-9A1C64E7
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-9A1C64E7') then
    perform producto_id, lote_id from create_producto_with_lote(

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
  end if;
end $$;

-- idempotente FC-47AAF23B
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-47AAF23B') then
    perform producto_id, lote_id from create_producto_with_lote(

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
  end if;
end $$;

-- idempotente FC-FFC25DD1
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-FFC25DD1') then
    perform producto_id, lote_id from create_producto_with_lote(

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
  end if;
end $$;

-- idempotente FC-614E4F82
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-614E4F82') then
    perform producto_id, lote_id from create_producto_with_lote(

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
  end if;
end $$;

-- idempotente FC-C22EBFE6
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-C22EBFE6') then
    perform producto_id, lote_id from create_producto_with_lote(

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
  end if;
end $$;

-- idempotente FC-BCF59548
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-BCF59548') then
    perform producto_id, lote_id from create_producto_with_lote(

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
  end if;
end $$;

-- idempotente FC-9507CD66
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-9507CD66') then
    perform producto_id, lote_id from create_producto_with_lote(

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
  end if;
end $$;

-- idempotente FC-FEAECBF1
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-FEAECBF1') then
    perform producto_id, lote_id from create_producto_with_lote(

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
  end if;
end $$;

-- idempotente FC-9827438F
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-9827438F') then
    perform producto_id, lote_id from create_producto_with_lote(

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
  end if;
end $$;

-- idempotente FC-EFB599B5
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-EFB599B5') then
    perform producto_id, lote_id from create_producto_with_lote(

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
  end if;
end $$;

-- idempotente FC-08DB70CB
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-08DB70CB') then
    perform producto_id, lote_id from create_producto_with_lote(

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
  end if;
end $$;

-- idempotente FC-89F00320
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-89F00320') then
    perform producto_id, lote_id from create_producto_with_lote(

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
  end if;
end $$;

-- idempotente FC-FD718DF3
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-FD718DF3') then
    perform producto_id, lote_id from create_producto_with_lote(

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
  end if;
end $$;

-- idempotente FC-0ACC5B6A
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-0ACC5B6A') then
    perform producto_id, lote_id from create_producto_with_lote(

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
  end if;
end $$;

-- idempotente FC-5D59ED54
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-5D59ED54') then
    perform producto_id, lote_id from create_producto_with_lote(

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
  end if;
end $$;

-- idempotente FC-E5BA49B2
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-E5BA49B2') then
    perform producto_id, lote_id from create_producto_with_lote(

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
  end if;
end $$;

-- idempotente FC-895EA161
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-895EA161') then
    perform producto_id, lote_id from create_producto_with_lote(

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
  end if;
end $$;

-- idempotente FC-33B15A58
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-33B15A58') then
    perform producto_id, lote_id from create_producto_with_lote(

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
  end if;
end $$;

-- idempotente FC-66055303
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-66055303') then
    perform producto_id, lote_id from create_producto_with_lote(

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
  end if;
end $$;

-- idempotente FC-DF92D3CF
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-DF92D3CF') then
    perform producto_id, lote_id from create_producto_with_lote(

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
  end if;
end $$;

-- idempotente FC-757DEC8A
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-757DEC8A') then
    perform producto_id, lote_id from create_producto_with_lote(

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
  end if;
end $$;

-- idempotente FC-108AB6B6
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-108AB6B6') then
    perform producto_id, lote_id from create_producto_with_lote(

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
  end if;
end $$;

-- idempotente FC-22ECC02C
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-22ECC02C') then
    perform producto_id, lote_id from create_producto_with_lote(

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
  end if;
end $$;

-- idempotente FC-23B68FA1
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-23B68FA1') then
    perform producto_id, lote_id from create_producto_with_lote(

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
  end if;
end $$;

-- idempotente FC-87621652
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-87621652') then
    perform producto_id, lote_id from create_producto_with_lote(

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
  end if;
end $$;

-- idempotente FC-2E70DB7E
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-2E70DB7E') then
    perform producto_id, lote_id from create_producto_with_lote(

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
  end if;
end $$;

-- idempotente FC-A166D66F
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-A166D66F') then
    perform producto_id, lote_id from create_producto_with_lote(

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
  end if;
end $$;

-- idempotente FC-7B88B47E
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-7B88B47E') then
    perform producto_id, lote_id from create_producto_with_lote(

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
  end if;
end $$;

-- idempotente FC-F349C6DD
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-F349C6DD') then
    perform producto_id, lote_id from create_producto_with_lote(

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
  end if;
end $$;

-- idempotente FC-D751525D
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-D751525D') then
    perform producto_id, lote_id from create_producto_with_lote(

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
  end if;
end $$;

-- idempotente FC-4F05124E
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-4F05124E') then
    perform producto_id, lote_id from create_producto_with_lote(

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
  end if;
end $$;

-- idempotente FC-85632ABD
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-85632ABD') then
    perform producto_id, lote_id from create_producto_with_lote(

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
  end if;
end $$;

-- idempotente FC-0906E3E1
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-0906E3E1') then
    perform producto_id, lote_id from create_producto_with_lote(

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
  end if;
end $$;

-- idempotente FC-4C3B3B9C
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-4C3B3B9C') then
    perform producto_id, lote_id from create_producto_with_lote(

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
  end if;
end $$;

-- idempotente FC-1812D26D
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-1812D26D') then
    perform producto_id, lote_id from create_producto_with_lote(

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
  end if;
end $$;

-- idempotente FC-EC96A027
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-EC96A027') then
    perform producto_id, lote_id from create_producto_with_lote(

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
  end if;
end $$;

-- idempotente FC-3B7A358D
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-3B7A358D') then
    perform producto_id, lote_id from create_producto_with_lote(

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
  end if;
end $$;

-- idempotente FC-16C9352F
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-16C9352F') then
    perform producto_id, lote_id from create_producto_with_lote(

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
  end if;
end $$;

-- idempotente FC-70F50FD7
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-70F50FD7') then
    perform producto_id, lote_id from create_producto_with_lote(

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
  end if;
end $$;

-- idempotente FC-D33D7A48
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-D33D7A48') then
    perform producto_id, lote_id from create_producto_with_lote(

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
  end if;
end $$;

-- idempotente FC-00E8A9C7
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-00E8A9C7') then
    perform producto_id, lote_id from create_producto_with_lote(

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
  end if;
end $$;

-- idempotente FC-D4342B8E
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-D4342B8E') then
    perform producto_id, lote_id from create_producto_with_lote(

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
  end if;
end $$;

-- idempotente FC-CF0AF2F6
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-CF0AF2F6') then
    perform producto_id, lote_id from create_producto_with_lote(

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
  end if;
end $$;

-- idempotente FC-5CA1622C
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-5CA1622C') then
    perform producto_id, lote_id from create_producto_with_lote(

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
  end if;
end $$;

-- idempotente FC-D0A49FC8
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-D0A49FC8') then
    perform producto_id, lote_id from create_producto_with_lote(

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
  end if;
end $$;

-- idempotente FC-EB5DCEBE
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-EB5DCEBE') then
    perform producto_id, lote_id from create_producto_with_lote(

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
  end if;
end $$;

-- idempotente FC-DA34D88D
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-DA34D88D') then
    perform producto_id, lote_id from create_producto_with_lote(

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
  end if;
end $$;

-- idempotente FC-BE2ACF63
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-BE2ACF63') then
    perform producto_id, lote_id from create_producto_with_lote(

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
  end if;
end $$;

-- idempotente FC-D259E551
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-D259E551') then
    perform producto_id, lote_id from create_producto_with_lote(

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
  end if;
end $$;

-- idempotente FC-2782A4D6
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-2782A4D6') then
    perform producto_id, lote_id from create_producto_with_lote(

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
  end if;
end $$;

-- idempotente FC-E3CFD0A7
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-E3CFD0A7') then
    perform producto_id, lote_id from create_producto_with_lote(

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
  end if;
end $$;

-- idempotente FC-39E059E2
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-39E059E2') then
    perform producto_id, lote_id from create_producto_with_lote(

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
  end if;
end $$;

-- idempotente FC-DF39BB27
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-DF39BB27') then
    perform producto_id, lote_id from create_producto_with_lote(

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
  end if;
end $$;

-- idempotente FC-79C61297
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-79C61297') then
    perform producto_id, lote_id from create_producto_with_lote(

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
  end if;
end $$;

-- idempotente FC-EC93AE62
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-EC93AE62') then
    perform producto_id, lote_id from create_producto_with_lote(

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
  end if;
end $$;

-- idempotente FC-223B5D76
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-223B5D76') then
    perform producto_id, lote_id from create_producto_with_lote(

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
  end if;
end $$;

-- idempotente FC-86606791
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-86606791') then
    perform producto_id, lote_id from create_producto_with_lote(

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
  end if;
end $$;

-- idempotente FC-6D9926C2
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-6D9926C2') then
    perform producto_id, lote_id from create_producto_with_lote(

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
  end if;
end $$;

-- idempotente FC-2E7C6CD6
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-2E7C6CD6') then
    perform producto_id, lote_id from create_producto_with_lote(

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
  end if;
end $$;

-- idempotente FC-D3FB53E9
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-D3FB53E9') then
    perform producto_id, lote_id from create_producto_with_lote(

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
  end if;
end $$;

-- idempotente FC-E3C83D59
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-E3C83D59') then
    perform producto_id, lote_id from create_producto_with_lote(

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
  end if;
end $$;

-- idempotente FC-99F357DC
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-99F357DC') then
    perform producto_id, lote_id from create_producto_with_lote(

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
  end if;
end $$;

-- idempotente FC-23CE9602
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-23CE9602') then
    perform producto_id, lote_id from create_producto_with_lote(

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
  end if;
end $$;

-- idempotente FC-CAABC42B
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-CAABC42B') then
    perform producto_id, lote_id from create_producto_with_lote(

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
  end if;
end $$;

-- idempotente FC-E94C79BA
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-E94C79BA') then
    perform producto_id, lote_id from create_producto_with_lote(

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
  end if;
end $$;

-- idempotente FC-D75138BB
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-D75138BB') then
    perform producto_id, lote_id from create_producto_with_lote(

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
  end if;
end $$;

-- idempotente FC-6E084251
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-6E084251') then
    perform producto_id, lote_id from create_producto_with_lote(

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
  end if;
end $$;

-- idempotente FC-30F56906
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-30F56906') then
    perform producto_id, lote_id from create_producto_with_lote(

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
  end if;
end $$;

-- idempotente FC-046D8251
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-046D8251') then
    perform producto_id, lote_id from create_producto_with_lote(

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
  end if;
end $$;

-- idempotente FC-D69881BF
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-D69881BF') then
    perform producto_id, lote_id from create_producto_with_lote(

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
  end if;
end $$;

-- idempotente FC-C3B611F3
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-C3B611F3') then
    perform producto_id, lote_id from create_producto_with_lote(

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
  end if;
end $$;

-- idempotente FC-98518364
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-98518364') then
    perform producto_id, lote_id from create_producto_with_lote(

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
  end if;
end $$;

-- idempotente FC-F89008C6
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-F89008C6') then
    perform producto_id, lote_id from create_producto_with_lote(

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
  end if;
end $$;

-- idempotente FC-355851E7
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-355851E7') then
    perform producto_id, lote_id from create_producto_with_lote(

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
  end if;
end $$;

-- idempotente FC-C8B741F6
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-C8B741F6') then
    perform producto_id, lote_id from create_producto_with_lote(

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
  end if;
end $$;

-- idempotente FC-3B0C76C8
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-3B0C76C8') then
    perform producto_id, lote_id from create_producto_with_lote(

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
  end if;
end $$;

-- idempotente FC-BE0A0E46
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-BE0A0E46') then
    perform producto_id, lote_id from create_producto_with_lote(

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
  end if;
end $$;

-- idempotente FC-ED3B0AD4
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-ED3B0AD4') then
    perform producto_id, lote_id from create_producto_with_lote(

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
  end if;
end $$;

-- idempotente FC-83941A95
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-83941A95') then
    perform producto_id, lote_id from create_producto_with_lote(

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
  end if;
end $$;

-- idempotente FC-E9FA700D
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-E9FA700D') then
    perform producto_id, lote_id from create_producto_with_lote(

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
  end if;
end $$;

-- idempotente FC-BE977010
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-BE977010') then
    perform producto_id, lote_id from create_producto_with_lote(

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
  end if;
end $$;

-- idempotente FC-35A0F20F
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-35A0F20F') then
    perform producto_id, lote_id from create_producto_with_lote(

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
  end if;
end $$;

-- idempotente FC-AE88EDDC
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-AE88EDDC') then
    perform producto_id, lote_id from create_producto_with_lote(

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
  end if;
end $$;

-- idempotente FC-EE6593B4
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-EE6593B4') then
    perform producto_id, lote_id from create_producto_with_lote(

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
  end if;
end $$;

-- idempotente FC-93322783
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-93322783') then
    perform producto_id, lote_id from create_producto_with_lote(

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
  end if;
end $$;

-- idempotente FC-20C90A6D
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-20C90A6D') then
    perform producto_id, lote_id from create_producto_with_lote(

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
  end if;
end $$;

-- idempotente FC-7607DDA7
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-7607DDA7') then
    perform producto_id, lote_id from create_producto_with_lote(

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
  end if;
end $$;

-- idempotente FC-8C9A304D
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-8C9A304D') then
    perform producto_id, lote_id from create_producto_with_lote(

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
  end if;
end $$;

-- idempotente FC-BA60704A
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-BA60704A') then
    perform producto_id, lote_id from create_producto_with_lote(

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
  end if;
end $$;

-- idempotente FC-8EF34E83
do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-8EF34E83') then
    perform producto_id, lote_id from create_producto_with_lote(

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
  end if;
end $$;

-- FL-080826 L1 Desenfriolito Tab C/24 2 Pack Bayer Otc $ 93.80 De
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-76040610'
     or codigo_barras = '7502276040610'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7502276040610', id from public.productos where codigo_barras = '7502276040610'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- FL-080826 L2 Noche Tab C/12 Descto: 6.0K Tempra , Xt Noche Tab 
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-60101231'
     or codigo_barras = '7506460101231'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7506460101231', id from public.productos where codigo_barras = '7506460101231'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- FL-080826 L3 Graneodin E Naranja Tab C/16 Rb Health 135.10 Gran
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-87154871'
     or codigo_barras = '75010587154871'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '75010587154871', id from public.productos where codigo_barras = '75010587154871'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- FL-080826 L4 Lubricante Soft Lub Pleasüre 56.7 Gr Health 1 $ 10
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-60101521'
     or codigo_barras = '7506460101521'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7506460101521', id from public.productos where codigo_barras = '7506460101521'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- FL-080826 L5 Dtc (Rojo) 20 Descto: 2.0% Afrin Spray (Rojo) Afri
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-06134531'
     or codigo_barras = '75010506134531'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '75010506134531', id from public.productos where codigo_barras = '75010506134531'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- FL-080826 L6 Pomada 100 Gr Descto: 2.0% Bepanthen Pomada Bepant
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-08427330'
     or codigo_barras = '7501008427330'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7501008427330', id from public.productos where codigo_barras = '7501008427330'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- FL-080826 L7 Tempra 24 Hrs Cab C/12 Rb Health $ Tempra 24 Hrs C
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-58792792'
     or codigo_barras = '7501058792792'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7501058792792', id from public.productos where codigo_barras = '7501058792792'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- FL-080826 L8 Eomelubrina Tab C/10 | Opella $ 73.70 Descto: 2.0%
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-50002301'
     or codigo_barras = '75011650002301'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '75011650002301', id from public.productos where codigo_barras = '75011650002301'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- FL-080826 L9 Histiacil Ne Jar Adto 150 Mi | Opella $ 124.40 $ 1
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-28979502'
     or codigo_barras = '7501328979502'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7501328979502', id from public.productos where codigo_barras = '7501328979502'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- FL-080826 L10 Histiacil Ne Jar Ine 150 Ml | Opella 1 $ 125.80 $ 
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-89794961'
     or codigo_barras = '75013289794961'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '75013289794961', id from public.productos where codigo_barras = '75013289794961'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- FL-080826 L11 Bisolvon Jbe Ine 120 Ml | Lăb Hormona $ 147.90 Des
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-79071241'
     or codigo_barras = '75010379071241'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '75010379071241', id from public.productos where codigo_barras = '75010379071241'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- FL-080826 L12 Nailex Desenterrador Unas 12 Ml Nailex Desenterrad
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-47624171'
     or codigo_barras = '75022347624171'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '75022347624171', id from public.productos where codigo_barras = '75022347624171'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- FL-080826 L13 "Lasico Enz C/. Dwightnd Descto: 15.0% "Lasico Dwi
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-80950139'
     or codigo_barras = '7501080950139'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7501080950139', id from public.productos where codigo_barras = '7501080950139'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- FL-080826 L14 Tribedoce Tab /30 Nvo Bruluart 5 $ 18.00 Tribedoce
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-88947797'
     or codigo_barras = '75022088947797'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '75022088947797', id from public.productos where codigo_barras = '75022088947797'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- FL-080826 L15 Performance Tab Descto: 2.0% Centrum C/30 Pg Pere 
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-50959781'
     or codigo_barras = '75010650959781'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '75010650959781', id from public.productos where codigo_barras = '75010650959781'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- FL-080826 L16 È Tre & Ice C/3 Dwightnd Descto: 15.0% Cond Trojan
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-80953017'
     or codigo_barras = '7501080953017'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7501080953017', id from public.productos where codigo_barras = '7501080953017'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- FL-080826 L17 Tempra 500 Mg Lab C/10 Rb Health $ 48.80 Descto: 6
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-54521161'
     or codigo_barras = '75010954521161'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '75010954521161', id from public.productos where codigo_barras = '75010954521161'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- FL-080826 L18 Hipoglos Pac Turo 45 Gr | Andromaco 1 $ 71.00 Desc
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-95201021'
     or codigo_barras = '75012895201021'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '75012895201021', id from public.productos where codigo_barras = '75012895201021'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- FL-080826 L19 Tabcin Eferv Tab C/12 | Bayer Ot C Descto: 2.0% 38
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-08485316'
     or codigo_barras = '7501008485316'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7501008485316', id from public.productos where codigo_barras = '7501008485316'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- FL-080826 L20 Centrum Silver Tab C/30 Pg Pere 1 Centrum Silver T
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-65095947'
     or codigo_barras = '7501065095947'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7501065095947', id from public.productos where codigo_barras = '7501065095947'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- FL-080826 L21 /10 | Rb Healte Sal De Uvas $ 37.90 Descto: 2.0% $
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-95451096'
     or codigo_barras = '7501095451096'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7501095451096', id from public.productos where codigo_barras = '7501095451096'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- FL-080826 L22 Sanfer Descto: 8.04 Syncol Tab $ 107.40 $ 107.40 8
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-79400556'
     or codigo_barras = '7501079400556'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7501079400556', id from public.productos where codigo_barras = '7501079400556'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- FL-080826 L23 Lubricante Sico Sens Calor 50 Ml | Rb Health 1 $ 1
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-58793249'
     or codigo_barras = '7501058793249'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7501058793249', id from public.productos where codigo_barras = '7501058793249'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- FL-080826 L24 Sal De Uvas Ixh C/50 | Rb Healti 1 $ 163.50 Descto
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-95467264'
     or codigo_barras = '7501095467264'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7501095467264', id from public.productos where codigo_barras = '7501095467264'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- FL-080826 L25 Lubricante Ico Cereza 50 Ml Rb Health 1 $ 101.90 I
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-87932321'
     or codigo_barras = '75010587932321'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '75010587932321', id from public.productos where codigo_barras = '75010587932321'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- FL-080826 L26 Tab C/100 Descto: 2.0% Alka-Seltzer Bayer C/100 Al
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-08443026'
     or codigo_barras = '7501008443026'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7501008443026', id from public.productos where codigo_barras = '7501008443026'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- FL-080826 L27 Tylenol Tab Kenvue 1 $ 50.00 Descto: 2.0% $ 49.00 
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-75354321'
     or codigo_barras = '75010075354321'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '75010075354321', id from public.productos where codigo_barras = '75010075354321'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- FL-080826 L28 Aspirina Tab 80 2 Paci Bayer Onc 1 $ 124.80 Aspiri
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-08491074'
     or codigo_barras = '7501008491074'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7501008491074', id from public.productos where codigo_barras = '7501008491074'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- FL-080826 L29 (A) Treda Tab €/20 Sanfer 2 $ 152.00 $ 304.00 Desc
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-70612368'
     or codigo_barras = '7501070612368'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7501070612368', id from public.productos where codigo_barras = '7501070612368'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- FL-080826 L30 Anara Tab C/20 Chinoin 1 $ 162.60 Descto: 2.0% $ 1
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-88508929'
     or codigo_barras = '7501088508929'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7501088508929', id from public.productos where codigo_barras = '7501088508929'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- FL-080826 L31 Forte Tab C/24 Descto: 2.0% Caf Iaspirina Forte C/
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-84335531'
     or codigo_barras = '75010084335531'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '75010084335531', id from public.productos where codigo_barras = '75010084335531'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- FL-080826 L32 Sr I Lab Ting Crema 28 Hormona $ 73.60 Sr I Ting C
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-23001331'
     or codigo_barras = '75010723001331'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '75010723001331', id from public.productos where codigo_barras = '75010723001331'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- FL-080826 L33 Scabisan Crema Er I Chinoin 1 $ 194.60 Descto: 2.0
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-85592111'
     or codigo_barras = '75010885592111'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '75010885592111', id from public.productos where codigo_barras = '75010885592111'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- FL-080826 L34 Boost Tar C/50 Descto: 2.0% Alka-Seltzer Bayer Boo
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-84999001'
     or codigo_barras = '75010084999001'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '75010084999001', id from public.productos where codigo_barras = '75010084999001'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- FL-080826 L35 Bepanthen Multiusos Pomada Otc 30 Bepanthen Multiu
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-08498798'
     or codigo_barras = '7501008498798'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7501008498798', id from public.productos where codigo_barras = '7501008498798'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- FL-080826 L36 Cafiaspirina Tar C/100 2 Pace Bayer Otc 221.90 Des
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-08491096'
     or codigo_barras = '7501008491096'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7501008491096', id from public.productos where codigo_barras = '7501008491096'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- FL-080826 L37 Iv Neomelubrina Jbe 100 Ml I Opella 121.00 Neomelu
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-50003151'
     or codigo_barras = '75011650003151'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '75011650003151', id from public.productos where codigo_barras = '75011650003151'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- FL-080826 L38 (A) Loxcel Adto Tab C/1 | Lab Hormona 2 $ 78.00 De
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-24227339'
     or codigo_barras = '7502224227339'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7502224227339', id from public.productos where codigo_barras = '7502224227339'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- FL-080826 L39 Herklin Shai 20 Ml Armstroni 1 $ 128.80 Descto: 2.
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-98100381'
     or codigo_barras = '75010898100381'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '75010898100381', id from public.productos where codigo_barras = '75010898100381'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- FL-080826 L40 Supos Adto C/10 Otc Descto: 7.0% Senosiain Senosia
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-14704156'
     or codigo_barras = '7501314704156'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7501314704156', id from public.productos where codigo_barras = '7501314704156'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- FL-080826 L41 Supos Ine C/10 Descto: 7.0% Senosiain Supos C/10 S
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-14704163'
     or codigo_barras = '7501314704163'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7501314704163', id from public.productos where codigo_barras = '7501314704163'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- FL-080826 L42 Lactopram 430 Mg Cap C/20 Progela 29.30 Descto: La
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-08344488'
     or codigo_barras = '7503008344488'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7503008344488', id from public.productos where codigo_barras = '7503008344488'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- FL-080826 L43 / 30 | Pg Pere Descto: 2.0% Centrum Tab $ 152.20 P
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-65095718'
     or codigo_barras = '7501065095718'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7501065095718', id from public.productos where codigo_barras = '7501065095718'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- FL-080826 L44 Soft Lub Lubricante Original 56.7 Soft Lubricante 
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-01015141'
     or codigo_barras = '75064601015141'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '75064601015141', id from public.productos where codigo_barras = '75064601015141'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- FL-080826 L45 Aspirina Eferv Tab C/12 Bayer Otc Aspirina Eferv C
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-08496701'
     or codigo_barras = '7501008496701'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7501008496701', id from public.productos where codigo_barras = '7501008496701'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- FL-080826 L46 Tarmin 2 Mg /12 Tab Bruluagsa Descto: 2.05 6. Tarm
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-88915491'
     or codigo_barras = '75022088915491'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '75022088915491', id from public.productos where codigo_barras = '75022088915491'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- FL-080826 L47 Descto: 2.0% Afrodit 400 Ui 46.00 $ $ 45.08 Afrodi
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-08344747'
     or codigo_barras = '7503008344747'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7503008344747', id from public.productos where codigo_barras = '7503008344747'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- FL-080826 L48 Ky6 Tab C/10 Bruluart 5 $ 9.50 $ 9.31 $ 47.50 Brul
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-08895196'
     or codigo_barras = '7502208895196'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7502208895196', id from public.productos where codigo_barras = '7502208895196'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- FL-080826 L49 Herklin Ne Sham 60 Ml | Armstrong 1 $ 81.00 Herkli
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-89810021'
     or codigo_barras = '7501089810021'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7501089810021', id from public.productos where codigo_barras = '7501089810021'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- FL-080826 L50 Lubricante Piel Con Piel 50 Mi Health 1 $ 102.50 L
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-60101378'
     or codigo_barras = '7506460101378'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7506460101378', id from public.productos where codigo_barras = '7506460101378'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- FL-080826 L51 Desenfriol D Dab C/30 | Bayer Otc $ 63.00 Descto: 
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-60403681'
     or codigo_barras = '75022760403681'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '75022760403681', id from public.productos where codigo_barras = '75022760403681'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- FL-080826 L52 Iv Cilocid 5 Mg Tab C/20 | Bruluari 7.40 Descto: 2
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-88923551'
     or codigo_barras = '75022088923551'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '75022088923551', id from public.productos where codigo_barras = '75022088923551'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- FL-080826 L53 Ab Pis. Descto: 2.0% Agrifen Tab 5. $ 19.50 Ab Pis
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-25116810'
     or codigo_barras = '7501125116810'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7501125116810', id from public.productos where codigo_barras = '7501125116810'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- FL-080826 L54 Vick Drops Tengibre Pastillas C/20 Vick Drops Teng
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-35246309'
     or codigo_barras = '7500435246309'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7500435246309', id from public.productos where codigo_barras = '7500435246309'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- FL-080826 L55 Ecuperador Una Lab Pisa Descto: 2.0% Aile Marilla 
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-47640531'
     or codigo_barras = '75022347640531'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '75022347640531', id from public.productos where codigo_barras = '75022347640531'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- FL-080826 L56 Saridon Tab 120 Bayer Oto $ 64.75 Saridon Tab
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-84095411'
     or codigo_barras = '75010084095411'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '75010084095411', id from public.productos where codigo_barras = '75010084095411'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- FL-080826 L57 Jr. Jbe Ine 60 Mant Chinotes Chinoin Jr. Jbe Mant 
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-85097661'
     or codigo_barras = '75010885097661'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '75010885097661', id from public.productos where codigo_barras = '75010885097661'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- FL-080826 L58 Afrin Spray No Drip Extra Humectante Afrin Spray D
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-06247327'
     or codigo_barras = '75010506247327'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '75010506247327', id from public.productos where codigo_barras = '75010506247327'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- FL-080826 L59 Flanax 550 Mc Tab C/12 | Bayér Otc 203.00 Descto: 
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-84973401'
     or codigo_barras = '75010084973401'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '75010084973401', id from public.productos where codigo_barras = '75010084973401'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- FL-080826 L60 Gr 5.58 Bayer Descto: 2.0% Flanax Gel 40 Otc Gr 5.
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-08426944'
     or codigo_barras = '7501008426944'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7501008426944', id from public.productos where codigo_barras = '7501008426944'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- FL-080826 L61 Iv Sot.O-Neurobion Dc Ete Jga Sot.O-Neurobion Prel
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-82176351'
     or codigo_barras = '75012982176351'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '75012982176351', id from public.productos where codigo_barras = '75012982176351'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- FL-080826 L62 Iri Amp 50.000 Mexico Descto: Mexico Iv Bedoyecta 
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-30133021'
     or codigo_barras = '75011230133021'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '75011230133021', id from public.productos where codigo_barras = '75011230133021'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- FL-080826 L63 Iv Dolo-Neurobion Dc Jga Preli C/3 3 Ml | Pg Healt
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-98217659'
     or codigo_barras = '7501298217659'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7501298217659', id from public.productos where codigo_barras = '7501298217659'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- FL-080826 L64 Crema Dent Colgate Max Clean 120 Ml Colgate Palmol
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-66888171'
     or codigo_barras = '75095466888171'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '75095466888171', id from public.productos where codigo_barras = '75095466888171'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- FL-080826 L65 90 Crema Dent Aot.Cate Me P Crema Dent Aot.Cate
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-66873531'
     or codigo_barras = '75095466873531'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '75095466873531', id from public.productos where codigo_barras = '75095466873531'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- FL-080826 L66 Sigital Protec Desato: 2.0% Termometro Degasa 42.1
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-86708021'
     or codigo_barras = '75010486708021'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '75010486708021', id from public.productos where codigo_barras = '75010486708021'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- FL-080826 L67 Tela Adhesiva Quirmex 2.5Cmxsm | Quirmex Descto: 2
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-03406600'
     or codigo_barras = '7503003406600'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7503003406600', id from public.productos where codigo_barras = '7503003406600'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- FL-080826 L68 Tela Adhesiva Quirmex 1.25Cmx5M | Quirmex 19.00 De
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-03406501'
     or codigo_barras = '7503003406501'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '7503003406501', id from public.productos where codigo_barras = '7503003406501'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- FL-080826 L69 Tela Adhesiva Quirmex 2.5Cmxi̇m | Quirmex 5 $ 11.7
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-34063651'
     or codigo_barras = '75030034063651'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '75030034063651', id from public.productos where codigo_barras = '75030034063651'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- FL-080826 L70 Tela Adhesiva Quirmex 1.25Cmx1M | Quirmex 5 5.40 $
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-34062421'
     or codigo_barras = '75030034062421'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '75030034062421', id from public.productos where codigo_barras = '75030034062421'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- FL-080826 L71 Crema Deni Colgate Trip Xtra B 50 Ml 1 Colgate Pai
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-60689091'
     or codigo_barras = '75095460689091'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '75095460689091', id from public.productos where codigo_barras = '75095460689091'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

-- FL-080826 L72 Panuelos Kleenex Pack C/8 1 Kimberly Clark $ 33.30
do $$
declare v_pid bigint;
begin
  select id into v_pid from public.productos
  where sku = 'FC-73629981'
     or codigo_barras = '75010173629981'
  limit 1;
  if v_pid is null then
    perform producto_id, lote_id from create_producto_with_lote(
      
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
    )
    );
    insert into _fc_carga_map (codigo_barras, producto_id)
    select '75010173629981', id from public.productos where codigo_barras = '75010173629981'
    on conflict (codigo_barras) do nothing;
  end if;
end $$;

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
