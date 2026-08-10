-- ============================================================
-- FarmaCapital — CARGA INVENTARIO TICKETS (2026-08-08)
--
-- PRE-REQUISITO (solo una vez):
--   sql/patch_fix_create_producto_carga_tickets.sql
--
-- Ejecutar EN ORDEN: _EJECUTAR_1 → _2 → _3 → _4
-- Role: postgres | Primary Database
-- ============================================================

begin;

create temp table if not exists _fc_carga_map (
  codigo_barras text primary key,
  producto_id bigint
) on commit drop;

insert into _fc_carga_map (codigo_barras, producto_id)
select codigo_barras, id from public.productos
where codigo_barras is not null and btrim(codigo_barras) <> ''
on conflict (codigo_barras) do nothing;



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

-- 440393 L2 LEVOFLOXACINO 7 TAB 500 MG (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
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

-- 440393 L3 CINA 7 TAB 750 MG (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
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

-- 440393 L4 ALOPURINOL 20 TAB 300 MG (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
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

-- 440393 L5 VERNISEN 6 TAB 200 MG (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
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

-- 440393 L6 AMIFARIN 20 CAPS 500 MG (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
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

-- 440393 L7 CLINDAMICINA FA 600MG/4ML (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
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

-- 440393 L8 CEFALVER 12 TAB 1 G (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
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

-- 440393 L9 CEFAROXIL 15 TAB 500/30 MG (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
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

-- 440393 L10 CLOXAN 20 COMP 30 MG (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
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

-- 440393 L11 CEFAGEN 1 SUSP 250MG/5/50 ML (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
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

-- 440393 L12 CEFAGEN 1 SUSP 125MG/5/50 ML (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
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

-- 440393 L13 KLARIX 1 SUSP 250MG/5ML 60 ML (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
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

-- 440393 L14 CEFAGEN 10 TAB 250 MG (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
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

-- 440393 L15 BISOPROLOL 30 TAB 2.5 MG (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
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

-- 440393 L16 CHARLYN 3 TAB 500 MG (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
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

-- 440393 L17 CLINDAMICINA 16 CAP 300 MG (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
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

-- 440393 L18 FASICLOR 15 CAPS 500 MG (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
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

-- 440393 L19 CEPOBROM 12 CAPS 500/0.782 MG (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
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

-- 440393 L20 DICLOFEN 12 CAPS 500 MG (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
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

-- 440393 L21 GENTAMICINA 5 AMP 160MG/2ML (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
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

-- 440393 L22 EPICIN 20 CAPS 500 MG (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
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

-- 440393 L23 KNORICIN 1 SUSP 125MG/5/60 ML (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
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

-- 440393 L24 CEFAGEN 10 TAB 500 MG (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
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

-- 440393 L25 CEFALVER 20 CAPS 500 MG (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
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

-- 440393 L26 TROPHARMA 20 TAB 500 MG (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
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

-- 440393 L27 KURTOSIL 1 CMA 20/1 MG (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
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

-- 440393 L28 DIVILTAC 1 FA 150/10MG/1 ML (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
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

-- 440393 L29 FASICLOR 1 SUSP 375MG/5/50 ML (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
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

-- 440393 L30 CIPROFLOXACINO 12 TAB 250 MG (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
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

-- 440393 L31 NAMIFEN 20 TAB 500 MG (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
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

-- 440393 L32 CEFALEXINA 20 CAPS 500 MG (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
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

-- 440393 L33 PENTIBROXIL 16 CAPS 500/30 MG (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
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

-- 440393 L34 ACROXIL-C 1 SUSP 250MG/5/60 ML (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
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

-- 440393 L35 PENTIVER 1 SUSP 500MG/5/60 ML (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
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

-- 440393 L36 FASICLOR 1 SUSP 250MG/5/75 ML (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
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

-- 440393 L37 FASICLOR 1 SUSP 125MG/5/75 ML (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
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

-- 440393 L38 MEXAPIN 1 SUSP 125MG/5/60 ML (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
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

-- 440393 L39 PENTIVER 1 SUSP 250MG/5/90 ML (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
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

-- 440393 L40 AZITROMICINA 1 SUSP 200MG/5/15 ML (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
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

-- 440393 L41 CLARITROMICINA 10 TAB 500 MG (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
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

-- 440393 L42 NALIXONE 20 TAB 500/50 MG (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
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

-- 440393 L43 PENIPOT 1 FA 800,000 UI (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
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

-- 440393 L44 AMOXICILINA 12 CAPS 500 MG (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
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

-- 440393 L45 ACIDO ACETILSALICILICO EF 20 TAB 300 MG (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
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

-- 440393 L46 VANMOXOL 1 SUSP 250/15MG/5/90 ML (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
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

-- 440393 L47 VALCLAN 10 TAB 500/125 MG (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
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

-- 440393 L48 BENCIL/BENZ COMPL 1 FA 1,2 U 3 ML (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
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

-- 440393 L49 AMPICILINA 1 FA 1G/5 ML (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
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

-- 440393 L50 AMPICILINA 1 FA 500MG/2 ML (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
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

-- 440393 L51 AMPICILINA 10 TAB 1 G (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
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

-- 440393 L52 CLAMOXIN 10 TAB 500/125 MG (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
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

-- 440393 L53 ACIDO ACETILSALICILICO 30 TAB 100MG (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
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

-- 440393 L54 CLAMOXIN 12H JR 1 SUSP 400/57MG/5/50 ML (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
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

-- 440393 L55 ACROXIL-C 12 CAPS 500/8 MG (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
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

-- 440393 L56 VANDIL 1 SUSP 250MG/5/75 ML (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
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

-- 440393 L57 ACIDO URSODESOXICOLICO 50 CAP 250 MG (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
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

-- 440393 L58 VALCLAN 10 TAB 875/125 MG (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
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

-- 440393 L59 PENIPOT 1 FA 400,000 UI (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
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

-- 440393 L60 CLAMOXIN 12H 10 TAB 875/125 MG (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
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

-- 440393 L61 CLAMOXIN 1 SUSP 250/62.5MG/5/60 ML (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
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

-- 440393 L62 BENEVENTOL 3 CAPS 400 MG (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
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

-- 440393 L63 GIMALXINA 1 SUSP 250MG/5/75 ML (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
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

-- 440393 L64 CLAMOXIN S 1 SUSP 600/42.9MG/50 ML (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
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

-- 440393 L65 CLAMOXIN 1 SUSP 125/31.25MG/5/60 ML (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
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

-- 440393 L66 CLAMOXIN 12H PED 1 SUSP 200/28.5MG/40 ML (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
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

-- 440393 L67 ACEMETACINA 14 CAPS 90 MG (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
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

-- 440393 L68 ASPITAK-P 30 COMP 100 MG (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
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

-- 440393 L69 BENEVENTOL 6 CAPS 400 MG (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
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

-- 440393 L70 LESACLOR (MACLOV) 35 TAB 400 MG (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
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

-- 440393 L71 AMOXICILINA 1 SUSP 500MG/5/75 ML (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
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

-- 440393 L72 GIMALXINA 12 CAPS 500 MG (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
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

-- 440393 L73 ACICLOVIR 35 TAB 400 MG (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
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

-- 440393 L74 OXIVAG 4 TAB 70 MG (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
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

-- 440393 L75 AMIKACINA 2 AMP 500MG/2 ML (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
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

-- 440393 L76 AMIKACINA 1 AMP 500MG/2 ML (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
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

-- 440393 L78 BACTIVER 20 TAB 400/80 MG (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
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

-- 440393 L79 BACTIVER F 16 TAB 160/800 MG (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
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

-- 440393 L80 REDALIP 30 TAB 200 MG (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
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

-- 440393 L81 LINCOMICINA 600MG/2ML 6 AMPOLLETAS (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
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

-- 440393 L82 CLOXAN 1 SOL 300MG/120ML (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
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

-- 440393 L83 CELESBITAN 1 FA C/BER 6MG/2 ML (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
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

-- 440393 L84 CEFOTAXIMA I.M. 1 FA 1G/4 ML (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
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

-- 440393 L85 AMLODIPINO 100 TAB 5 MG (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
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

-- 440393 L86 DEGORTZIN 1 SOL 100 MG/50 ML (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
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

-- 440393 L87 WEXPEC 1 SOL 7.5/2MG/5/120 ML (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
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

-- 440393 L88 SIBICOS 1 CMA 1/100/20 G (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
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

-- 440393 L89 BUDESONIDA 5 AMP 0.250MG/2ML (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
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

-- 440393 L90 DISON DEX 1 FA 5/2 MG (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
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

-- 440393 L91 CINARIZINA 60 TAB 75 MG (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
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

-- 440393 L92 CELECOXIB 10 CAPS 200MG (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
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

-- 440393 L93 PRCTAISOL 1 SUSP/AER 200 DOSIS 12.80 G (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
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

-- 440393 L94 CALCIO EFE 12 COMP 500 MG (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
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

-- 440393 L95 BECATRIM N CALCITRIOL 30 CAPS 0.25 MCG (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
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

-- 440393 L96 GENTAMICINA 25 COMP 1 MG (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
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

-- 440393 L97 BUDIMIN 20 TAB 1 MG (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
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

-- 440393 L98 BITENVER 30 TAB 24 MG (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
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

-- 440393 L99 SUPRATEX DAC 1 SOL 300/600 MG 120 ML (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
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

-- 440393 L100 ODIVITOR 10 TAB 20 MG (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
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

-- 440393 L101 CAPTOPRIL 30 TAB 25 MG (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
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

-- 440393 L102 BUDENOVA SUSP 125 MG/ML 5 AMP 2ML (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
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

-- 440393 L103 AMLODIPINO 30 TAB 5 MG (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
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

-- 440393 L104 LESACLOR 1 SUSP 200MG/5/125 ML (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
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

-- 440393 L105 RAMCINET 10 TAB 10 MG (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
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

-- 440393 L106 CARBAMAZEPINA 20 TAB 200 MG (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
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

-- 440393 L107 ERISPAN 1 FA 4MG/3 ML (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
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

-- 440393 L108 ERISPAN 1 FA 8MG/2 ML (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
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

-- 440393 L109 BUDESONIDA 1 SUSP NEB AMP 0.500MG (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
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

-- 440393 L110 AMIFARIN 1 SUSP 250MG 60 ML (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
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

-- 440393 L111 HASPEN 3 AMP 20 MG/1 ML (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
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

-- 440393 L112 CLOPHIVEN 200 DOSIS 50 MCG/15 G (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
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

-- 440393 L113 AMLODIPINO 100 TAB 5 MG (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
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

-- 440393 L114 BACTIVER 1 SUSP 40/200/5/120 ML (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
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

-- 440393 L115 SONBLEFAM S 1 CMA 100 G/40 G (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
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

-- 440393 L116 CEFTRIAXONA I.M. 1 FA 1G/3.5 ML (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
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

-- 440393 L117 LAUR AQUITO 500/100/30/4 MG 3 AMP (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
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

-- 440393 L118 BENEVENTOL 1 SUSP 100MG/5ML/50 ML (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
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

-- 440393 L119 AMPIGRIN AD 3 AMP 500/500/100/30MG/3 ML (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
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

-- 440393 L120 AMPIGRIN INF 3 AMP 250/200/100/30MG/3 ML (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
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

-- 440393 L121 AMCEF I.M. 1 FA 1G/3.5 ML (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
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

-- 440393 L122 AMCEF I.M. 1 FA 500MG/2 ML (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
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

-- 440393 L123 CEFTAZIDIMA 1 FA 1G/3 ML (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
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

-- 440393 L124 NORQUINOL 20 TAB 400 MG (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
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

-- 440393 L125 CIPROFLOXACINO G.I. 14 TAB 500 MG (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
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

-- 440393 L126 AMIKACINA 1 AMP 100 MG/2 ML (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
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

-- 440393 L127 ATORVASTATINA 10 TAB 40 MG (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
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

-- 440393 L128 FLOSPET 8 TAB 400 MG (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
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

-- 440393 L129 BIOERTER 1 SUSP 250 MG/100 ML (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
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

-- 440393 L130 DOLIPROFEN 10 TAB 800 MG (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
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

-- 440393 L131 GELUBRIN 10 CAPS 600 MG (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
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

-- 440393 L132 ZITRIASOL 15 CAP 100 MG (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
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

-- 440393 L133 PABESORAG 28 TAB 150/12.5 MG (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
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

-- 440393 L134 IBUPRO-CAFE 10 CAPS 400 MG/100 MG (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
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

-- 440393 L135 INDARZONA 30 CAPS 25/0.5 MG (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
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

-- 440393 L136 WERMY 15 CAPS 300 MG (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
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

-- 440393 L137 DIURMESSEL 20 TAB 40 MG (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
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

-- 440393 L138 HIDROXON 30 TAB 10 MG (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
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

-- 440393 L139 COLLUCORT 1 CMA 1% 60 G (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
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

-- 440393 L140 TRATIDRI 1 GEL 500/50 MG 60 G (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
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

-- 440393 L141 ELAPHTERON 20 TAB 100 MG (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
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

-- 440393 L142 AMDORYL 14 CAPS 30 MG (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
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

-- 440393 L143 ACETONIDO DE FLUOCINOLONA CMA (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
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

-- 440393 L144 FLUCONAZOL 1 CAPS 150 MG (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
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

-- 440393 L145 HIALURONATO DE SODIO 4MG 10 ML (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
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

-- 440393 L146 HIERRO DEX 3 AMP 100 MG/2 ML (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
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

-- 440393 L147 DIZIVER 20 TAB 25 MG (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
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

-- 440393 L148 ZUKEDIB 30 TAB 2 MG (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
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

-- 440393 L149 ZUKEDIB 30 TAB 4 MG (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
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

-- 440393 L150 PRALEX 28 TAB 10 MG (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
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

-- 440393 L151 VALGAB 3 IBE 50MG/6ML (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
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

-- 440393 L152 ENALAPRIL 30 TAB 10 MG (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
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

-- 440393 L153 OVISEN 28 TAB 20 MG (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
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

-- 440393 L155 REGLUSAN 50 TAB 5 MG (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
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

-- 440393 L156 DROSQUIM AD 1 IBE 300/160/200 ML (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
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

-- 440393 L157 DESROTAN 10 TAB 180 MG (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
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

-- 440393 L158 DIOSMINA HESPERIDINA 20 TAB 450/50 MG (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
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

-- 440393 L159 IRBESARTAN 14 TAB 150 MG (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
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

-- 440393 L160 TUSILEN AD 1 IBE 240/30/50MG/100/118 ML (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
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

-- 440393 L161 IRBESARTAN 14 TAB 300 MG (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
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

-- 440393 L162 WERMY 30 CAPS 300 MG (sin barcode)
select producto_id, lote_id from create_producto_with_lote(
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

-- 77827 L1 Desod Obao R-Nat Coco R-On 65G
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7509552844825' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7509552844825';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
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
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7509552844825', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-77827-1', NULL, 29.55, 'Bodega F-42 Ejidos del Moral', null
    );
  end if;
end $$;

-- 77827 L2 Desod Obao Game 48Hr R-On 65G N
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7509552933307' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7509552933307';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
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
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7509552933307', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-77827-2', NULL, 24.71, 'Bodega F-42 Ejidos del Moral', null
    );
  end if;
end $$;

-- 77827 L3 Desod Obad P/Del R-On 65G
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7501027250612' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7501027250612';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
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
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7501027250612', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-77827-3', NULL, 24.71, 'Bodega F-42 Ejidos del Moral', null
    );
  end if;
end $$;

-- 77827 L4 Desod Obao Clas R-On 65G
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7501027286017' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7501027286017';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
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
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7501027286017', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-77827-4', NULL, 45.83, 'Bodega F-42 Ejidos del Moral', null
    );
  end if;
end $$;

-- 77827 L5 Desod Obao Men Tatto Aqua R-On 65G
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7509552876406' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7509552876406';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
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
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7509552876406', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-77827-5', NULL, 45.83, 'Bodega F-42 Ejidos del Moral', null
    );
  end if;
end $$;

-- 77827 L6 Desod Axe Men Young Spy 150Ml
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '750630622622' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '750630622622';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
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
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('750630622622', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-77827-6', NULL, 45.83, 'Bodega F-42 Ejidos del Moral', null
    );
  end if;
end $$;

-- 77827 L7 Desod Axe Icechi E-Frio Spy 150Ml
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7506306213906' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7506306213906';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
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
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7506306213906', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-77827-7', NULL, 25.83, 'Bodega F-42 Ejidos del Moral', null
    );
  end if;
end $$;

-- 77827 L8 Desod Rexona Men Marine Spy 150Ml
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7791293037806' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7791293037806';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
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
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7791293037806', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-77827-8', NULL, 62.83, 'Bodega F-42 Ejidos del Moral', null
    );
  end if;
end $$;

-- 77827 L9 Desod Obao Men Tato Rebel R-On65
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '750955280956' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '750955280956';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
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
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('750955280956', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-77827-9', NULL, 54.68, 'Bodega F-42 Ejidos del Moral', null
    );
  end if;
end $$;

-- 77827 L10 Desod Axe Excite Seco Spy 152Ml
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7791293025919' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7791293025919';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
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
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7791293025919', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-77827-10', NULL, 45.83, 'Bodega F-42 Ejidos del Moral', null
    );
  end if;
end $$;

-- 77827 L11 Desod Rexona Men V8 Tun Spy 90G
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7791293022567' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7791293022567';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
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
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7791293022567', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-77827-11', NULL, 51.5, 'Bodega F-42 Ejidos del Moral', null
    );
  end if;
end $$;

-- 77827 L12 Desod Axe Intense 48H Spy 150Ml
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7506306244795' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7506306244795';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
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
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7506306244795', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-77827-12', NULL, 54.68, 'Bodega F-42 Ejidos del Moral', null
    );
  end if;
end $$;

-- 77827 L13 Desod Rexona 48H Happy-M Stick 45G
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '75076009' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '75076009';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
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
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('75076009', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-77827-13', NULL, 53.5, 'Bodega F-42 Ejidos del Moral', null
    );
  end if;
end $$;

-- 77827 L14 Desod Axe Men Dark Temp Spy150Ml
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7791293025797' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7791293025797';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
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
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7791293025797', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-77827-14', NULL, 53.5, 'Bodega F-42 Ejidos del Moral', null
    );
  end if;
end $$;

-- 77827 L15 Desod Rexona Men Sport Spy 150Ml
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7791293038223' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7791293038223';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
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
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7791293038223', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-77827-15', NULL, 45.83, 'Bodega F-42 Ejidos del Moral', null
    );
  end if;
end $$;

-- 77827 L16 Desod Rexona Bamboo 48H Stick 45G
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '75062897' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '75062897';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
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
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('75062897', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-77827-16', NULL, 45.83, 'Bodega F-42 Ejidos del Moral', null
    );
  end if;
end $$;

-- 77827 L17 Desod Axe Men Epic-F 48H Spy 150Ml
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7506306245686' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7506306245686';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
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
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7506306245686', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-77827-17', NULL, 45.83, 'Bodega F-42 Ejidos del Moral', null
    );
  end if;
end $$;

-- 77827 L18 Desod Axe Men Gold Temp
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7791293025865' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7791293025865';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
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
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7791293025865', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-77827-18', NULL, 45.83, 'Bodega F-42 Ejidos del Moral', null
    );
  end if;
end $$;

-- 77827 L19 Jbn Grisi Neutro 150 G
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7501022105207' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7501022105207';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
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
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7501022105207', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 3, 'TK-77827-19', NULL, 20.14, 'Bodega F-42 Ejidos del Moral', null
    );
  end if;
end $$;

-- 77827 L20 Jbn Dove Barra Blanca
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '067238891190' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '067238891190';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
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
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('067238891190', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 2, 'TK-77827-20', NULL, 60.54, 'Bodega F-42 Ejidos del Moral', null
    );
  end if;
end $$;

-- 77827 L21 Desod Rexona Pom-Dry48H Stick45G
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '75062927' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '75062927';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
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
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('75062927', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-77827-21', NULL, 30.21, 'Bodega F-42 Ejidos del Moral', null
    );
  end if;
end $$;

-- 77827 L22 Jbn Asepxia Bicarbon Sod 100G
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '650240036965' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '650240036965';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
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
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('650240036965', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-77827-22', NULL, 14.45, 'Bodega F-42 Ejidos del Moral', null
    );
  end if;
end $$;

-- 77827 L23 Jbn Asexia Exfol 100G
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '650240004643' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '650240004643';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
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
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('650240004643', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-77827-23', NULL, 38.66, 'Bodega F-42 Ejidos del Moral', null
    );
  end if;
end $$;

-- 77827 L24 Jbn Grisi Avena 125G
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7501022150801' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7501022150801';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
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
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7501022150801', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-77827-24', NULL, 15.02, 'Bodega F-42 Ejidos del Moral', null
    );
  end if;
end $$;

-- 77827 L25 Jbn Escudo Antibact 110Gr
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7506425605514' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7506425605514';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
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
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7506425605514', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 2, 'TK-77827-25', NULL, 26.75, 'Bodega F-42 Ejidos del Moral', null
    );
  end if;
end $$;

-- 77827 L26 Azufre Jabon C Miel 80
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7503014119032' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7503014119032';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
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
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7503014119032', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-77827-26', NULL, 30.21, 'Bodega F-42 Ejidos del Moral', null
    );
  end if;
end $$;

-- 77827 L28 Jbn Dove Barra Karite Vainill 135G
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7506306230507' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7506306230507';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
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
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7506306230507', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-77827-28', NULL, 30.21, 'Bodega F-42 Ejidos del Moral', null
    );
  end if;
end $$;

-- 77827 L29 Jbn Grisi Leche De Burra 125G
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7501022150092' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7501022150092';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
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
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7501022150092', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-77827-29', NULL, 42.82, 'Bodega F-42 Ejidos del Moral', null
    );
  end if;
end $$;

-- 77827 L30 Jbn Grisi Corp Diabecare 125 G
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7501022111352' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7501022111352';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
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
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7501022111352', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-77827-30', NULL, 35.61, 'Bodega F-42 Ejidos del Moral', null
    );
  end if;
end $$;

-- 77827 L31 Desod Rex Mot-Sen Sport Stick
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '75069223' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '75069223';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
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
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('75069223', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-77827-31', NULL, 16.7, 'Bodega F-42 Ejidos del Moral', null
    );
  end if;
end $$;

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

-- 77827 L33 Jbn Liq Blumen Coconut Para 221Ml
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7506267905186' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7506267905186';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
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
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7506267905186', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-77827-33', NULL, 128.57, 'Bodega F-42 Ejidos del Moral', null
    );
  end if;
end $$;

-- 77827 L34 Jbn Palmol N-Bal Dermo Limp 120G
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7509546683133' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7509546683133';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
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
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7509546683133', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 2, 'TK-77827-34', NULL, 8.96, 'Bodega F-42 Ejidos del Moral', null
    );
  end if;
end $$;

-- 77827 L35 Desod Dove Dermac Sk-C 48H Spy150Ml
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7506306241206' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7506306241206';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
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
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7506306241206', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 2, 'TK-77827-35', NULL, 54.12, 'Bodega F-42 Ejidos del Moral', null
    );
  end if;
end $$;

-- 77827 L36 Jbn Escudo Rosa Prot Y Cuid 110G
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7501943489004' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7501943489004';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
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
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7501943489004', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 2, 'TK-77827-36', NULL, 40.73, 'Bodega F-42 Ejidos del Moral', null
    );
  end if;
end $$;

-- 77827 L37 Agua Mic Garnier De Rosas 400 Ml
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '3600542326414' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '3600542326414';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
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
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('3600542326414', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-77827-37', NULL, 27.75, 'Bodega F-42 Ejidos del Moral', null
    );
  end if;
end $$;

-- 77827 L38 Agua Mic Vitacilina Ros-Sab 500Mln
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7506376000284' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7506376000284';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
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
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7506376000284', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-77827-38', NULL, 21.08, 'Bodega F-42 Ejidos del Moral', null
    );
  end if;
end $$;

-- 77827 L39 Desmaq Bifasico Oil Nuvel 125Ml
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7501082790504' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7501082790504';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
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
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7501082790504', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-77827-39', NULL, 16.7, 'Bodega F-42 Ejidos del Moral', null
    );
  end if;
end $$;

-- 77827 L40 Agua Mice Natural-G Bifasic 120Ml
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7502245722547' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7502245722547';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
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
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7502245722547', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-77827-40', NULL, 37.72, 'Bodega F-42 Ejidos del Moral', null
    );
  end if;
end $$;

-- 77827 L41 Jbn Liq Blumen Cherry Bloss 221Ml
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7506267905131' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7506267905131';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
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
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7506267905131', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-77827-41', NULL, 17.78, 'Bodega F-42 Ejidos del Moral', null
    );
  end if;
end $$;

-- 77827 L42 Tas Hum Claris Desmaq Aloe C/40
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7502221012303' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7502221012303';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
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
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7502221012303', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 2, 'TK-77827-42', NULL, 14.78, 'Bodega F-42 Ejidos del Moral', null
    );
  end if;
end $$;

-- 77827 L43 Jabon De Proteina De Arroz Y Concha Nacar 8
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7505514121782' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7505514121782';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
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
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7505514121782', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-77827-43', NULL, 167.69, 'Bodega F-42 Ejidos del Moral', null
    );
  end if;
end $$;

-- 77827 L44 Jbn Escudo Azul Rey 135G
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7506425652716' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7506425652716';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
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
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7506425652716', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 2, 'TK-77827-44', NULL, 73.65, 'Bodega F-42 Ejidos del Moral', null
    );
  end if;
end $$;

-- 77827 L45 Deo Aero Dove Tono Uniforme 150Ml 3Pack
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7506306248052' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7506306248052';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
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
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7506306248052', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-77827-45', NULL, 147.3, 'Bodega F-42 Ejidos del Moral', null
    );
  end if;
end $$;

-- 77827 L46 Deo Dove Spy Invisible Dry 150Ml C3
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7506306248045' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7506306248045';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
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
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7506306248045', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-77827-46', NULL, 129.46, 'Bodega F-42 Ejidos del Moral', null
    );
  end if;
end $$;

-- 77827 L47 Jbn Liq Palmol Aquarium 221Ml
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7501035911208' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7501035911208';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
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
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7501035911208', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-77827-47', NULL, 45.83, 'Bodega F-42 Ejidos del Moral', null
    );
  end if;
end $$;

-- 77827 L48 Desod Nivea Pearlb Mspy150Ml
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '4005808837311' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '4005808837311';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
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
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('4005808837311', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 2, 'TK-77827-48', NULL, 12.54, 'Bodega F-42 Ejidos del Moral', null
    );
  end if;
end $$;

-- 77827 L49 Deo Axe Spy 150Ml 48H Anarchy Fresh Love Fo
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7506306209862' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7506306209862';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
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
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7506306209862', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-77827-49', NULL, 16.87, 'Bodega F-42 Ejidos del Moral', null
    );
  end if;
end $$;

-- 77827 L50 Jbn Liq Escudo Blanco Neut 225Ml
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7501943489165' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7501943489165';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
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
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7501943489165', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-77827-50', NULL, 45.83, 'Bodega F-42 Ejidos del Moral', null
    );
  end if;
end $$;

-- 77827 L51 Jaloma Agua De Rosas 130Ml Spray
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '759684900280' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '759684900280';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
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
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('759684900280', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-77827-51', NULL, 23.79, 'Bodega F-42 Ejidos del Moral', null
    );
  end if;
end $$;

-- 77827 L52 Desod Axe Wom Anarchy Spy 150Ml
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7506306226852' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7506306226852';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
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
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7506306226852', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-77827-52', NULL, 88.8, 'Bodega F-42 Ejidos del Moral', null
    );
  end if;
end $$;

-- 77827 L53 Jbn Lio Palmol Flor Czo-Rsa 221Ml
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7509546657035' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7509546657035';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
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
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7509546657035', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-77827-53', NULL, 45.83, 'Bodega F-42 Ejidos del Moral', null
    );
  end if;
end $$;

-- 77827 L54 Loc Limp Ponds Bio-Hydra Dual 200Ml
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7501056330378' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7501056330378';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
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
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7501056330378', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-77827-54', NULL, 28.1, 'Bodega F-42 Ejidos del Moral', null
    );
  end if;
end $$;

-- 77827 L55 Deo Mexsana P/Pies Spy 150Ml
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7502276040436' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7502276040436';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
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
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7502276040436', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-77827-55', NULL, 49.29, 'Bodega F-42 Ejidos del Moral', null
    );
  end if;
end $$;

-- 77827 L56 Tco Desod Odolex
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7501361113000' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7501361113000';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
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
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7501361113000', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-77827-56', NULL, 31.77, 'Bodega F-42 Ejidos del Moral', null
    );
  end if;
end $$;

-- 77827 L57 Odolex Naturals 300Gr Talco Desodorante
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7501361123009' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7501361123009';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
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
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7501361123009', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-77827-57', NULL, 23.99, 'Bodega F-42 Ejidos del Moral', null
    );
  end if;
end $$;

-- 77827 L58 Tiraleche De Cristal 1 Pza
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7501441500096' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7501441500096';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
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
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7501441500096', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-77827-58', NULL, 80.46, 'Bodega F-42 Ejidos del Moral', null
    );
  end if;
end $$;

-- 77827 L59 Sh Pert Plus Ac-Oliva 400Ml
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '810120500201' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '810120500201';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
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
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('810120500201', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-77827-59', NULL, 64.12, 'Bodega F-42 Ejidos del Moral', null
    );
  end if;
end $$;

-- 77827 L60 Ting Polvo 85G
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7501072300171' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7501072300171';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
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
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7501072300171', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-77827-60', NULL, 43.58, 'Bodega F-42 Ejidos del Moral', null
    );
  end if;
end $$;

-- 77827 L61 Ico Desod Rexona Effi Fresh 200G
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7506306217461' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7506306217461';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
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
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7506306217461', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-77827-61', NULL, 43.58, 'Bodega F-42 Ejidos del Moral', null
    );
  end if;
end $$;

-- 77827 L62 Quita Esm Nuvel Humec 125Ml
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7501082740011' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7501082740011';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
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
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7501082740011', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-77827-62', NULL, 43.58, 'Bodega F-42 Ejidos del Moral', null
    );
  end if;
end $$;

-- 77827 L63 Cra Fructis Pei B-Dano Quim 300Ml
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7509552910971' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7509552910971';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
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
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7509552910971', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-77827-63', NULL, 78.22, 'Bodega F-42 Ejidos del Moral', null
    );
  end if;
end $$;

-- 77827 L64 Cra Fructis Pei Oil-R L-Coco 300Ml
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '7509552816297' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '7509552816297';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
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
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('7509552816297', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-77827-64', NULL, 63.05, 'Bodega F-42 Ejidos del Moral', null
    );
  end if;
end $$;

-- 77827 L66 Sh Int Lomecan V 200Ml
do $$
declare v_pid bigint; v_lid bigint;
begin
  select id into v_pid from public.productos where codigo_barras = '650240025839' limit 1;
  if v_pid is null then
    select producto_id into v_pid from _fc_carga_map where codigo_barras = '650240025839';
  end if;
  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from create_producto_with_lote(
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
    ) f;
    insert into _fc_carga_map (codigo_barras, producto_id)
    values ('650240025839', v_pid)
    on conflict (codigo_barras) do update set producto_id = excluded.producto_id;
  else
    perform lote_id from receive_merchandise_lote(
      v_pid, 1, 'TK-77827-66', NULL, 17.2, 'Bodega F-42 Ejidos del Moral', null
    );
  end if;
end $$;
commit;
