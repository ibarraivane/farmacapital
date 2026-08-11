-- ============================================================================
-- CARGAR faltantes — Bodega 440393 + IFC + SKU sin barcode (EJECUTAR 1, 2 y SKU-only de 3)
-- 209 bloques · Mercurio, medicamentos Bodega, etc.
-- Lote 1/9 · commit parcial (un error no revierte lotes anteriores)
-- PASO 0 previo: sql/patch_cargar_faltantes_0_fix_rpcs.sql
-- ============================================================================

begin;

create temp table if not exists _fc_carga_map (
  codigo_barras text primary key,
  producto_id bigint
) on commit preserve rows;

insert into _fc_carga_map (codigo_barras, producto_id)
select codigo_barras, id from public.productos
where codigo_barras is not null and btrim(codigo_barras) <> ''
on conflict (codigo_barras) do nothing;



-- idempotente FC-C721E8D7
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-C721E8D7') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      '2028-01-03'::date,
      18.77,
      null::bigint,
      null::text) f;
end $$;


-- idempotente FC-B25B4654
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-B25B4654') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      '2028-04-01'::date,
      28.87,
      null::bigint,
      null::text) f;
end $$;


-- idempotente FC-ACA2A2F6
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-ACA2A2F6') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      '2027-10-31'::date,
      21.46,
      null::bigint,
      null::text) f;
end $$;


-- idempotente FC-174824A0
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-174824A0') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      '2029-05-01'::date,
      12.38,
      null::bigint,
      null::text) f;
end $$;


-- idempotente FC-D5AC44CA
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-D5AC44CA') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      '2028-04-01'::date,
      45.78,
      null::bigint,
      null::text) f;
end $$;


-- idempotente FC-9A4E4C31
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-9A4E4C31') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      '2027-01-01'::date,
      88.42,
      null::bigint,
      null::text) f;
end $$;


-- idempotente FC-40CE757D
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-40CE757D') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      '2028-02-01'::date,
      62.48,
      null::bigint,
      null::text) f;
end $$;


-- idempotente FC-B18E386A
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-B18E386A') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      '2028-10-01'::date,
      44.44,
      null::bigint,
      null::text) f;
end $$;


-- idempotente FC-1DA570E3
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-1DA570E3') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      '2028-02-01'::date,
      9.75,
      null::bigint,
      null::text) f;
end $$;


-- idempotente FC-A455EE80
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-A455EE80') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      '2027-02-01'::date,
      74.58,
      null::bigint,
      null::text) f;
end $$;


-- idempotente FC-E374F23E
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-E374F23E') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      '2027-09-01'::date,
      48.48,
      null::bigint,
      null::text) f;
end $$;


-- idempotente FC-8FB65B79
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-8FB65B79') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      '2028-05-01'::date,
      81.67,
      null::bigint,
      null::text) f;
end $$;


-- idempotente FC-2EDC6E3B
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-2EDC6E3B') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      '2027-09-01'::date,
      82.09,
      null::bigint,
      null::text) f;
end $$;


-- idempotente FC-C101D5B1
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-C101D5B1') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      '2028-04-30'::date,
      97.51,
      null::bigint,
      null::text) f;
end $$;


-- idempotente FC-7AF7ACB5
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-7AF7ACB5') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      '2028-02-01'::date,
      24.98,
      null::bigint,
      null::text) f;
end $$;


-- idempotente FC-CF18C740
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-CF18C740') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      '2028-01-01'::date,
      30.54,
      null::bigint,
      null::text) f;
end $$;


-- idempotente FC-E4EFC4C2
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-E4EFC4C2') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      '2027-10-01'::date,
      137.92,
      null::bigint,
      null::text) f;
end $$;


-- idempotente FC-6EAD98A9
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-6EAD98A9') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      '2029-01-01'::date,
      47.97,
      null::bigint,
      null::text) f;
end $$;


-- idempotente FC-CF719C07
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-CF719C07') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      '2028-05-01'::date,
      26.82,
      null::bigint,
      null::text) f;
end $$;


-- idempotente FC-60F627D5
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-60F627D5') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      '2027-11-01'::date,
      52.57,
      null::bigint,
      null::text) f;
end $$;


-- idempotente FC-48F732CF
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-48F732CF') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      '2028-03-01'::date,
      29.56,
      null::bigint,
      null::text) f;
end $$;


-- idempotente FC-72C28BC1
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-72C28BC1') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      '2027-06-01'::date,
      45.41,
      null::bigint,
      null::text) f;
end $$;


-- idempotente FC-443C330E
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-443C330E') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      '2027-12-31'::date,
      144.13,
      null::bigint,
      null::text) f;
end $$;


-- idempotente FC-492D652F
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-492D652F') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      '2028-02-01'::date,
      43.35,
      null::bigint,
      null::text) f;
end $$;


-- idempotente FC-86A95D07
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-86A95D07') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      '2028-12-01'::date,
      44.53,
      null::bigint,
      null::text) f;
end $$;


commit;

select 1 as lote_ok, 9 as lotes_total;

-- ============================================================================
-- CARGAR faltantes — Bodega 440393 + IFC + SKU sin barcode (EJECUTAR 1, 2 y SKU-only de 3)
-- 209 bloques · Mercurio, medicamentos Bodega, etc.
-- Lote 2/9 · commit parcial (un error no revierte lotes anteriores)
-- PASO 0 previo: sql/patch_cargar_faltantes_0_fix_rpcs.sql
-- ============================================================================

begin;

create temp table if not exists _fc_carga_map (
  codigo_barras text primary key,
  producto_id bigint
) on commit preserve rows;

insert into _fc_carga_map (codigo_barras, producto_id)
select codigo_barras, id from public.productos
where codigo_barras is not null and btrim(codigo_barras) <> ''
on conflict (codigo_barras) do nothing;



-- idempotente FC-697EEAD0
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-697EEAD0') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      '2028-06-30'::date,
      62.48,
      null::bigint,
      null::text) f;
end $$;


-- idempotente FC-830BF3FB
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-830BF3FB') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      '2028-03-01'::date,
      34.45,
      null::bigint,
      null::text) f;
end $$;


-- idempotente FC-F3E734A0
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-F3E734A0') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      '2028-06-01'::date,
      63.44,
      null::bigint,
      null::text) f;
end $$;


-- idempotente FC-74A5ABEE
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-74A5ABEE') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      '2028-06-30'::date,
      13.69,
      null::bigint,
      null::text) f;
end $$;


-- idempotente FC-AEA8C8DA
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-AEA8C8DA') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      '2030-06-01'::date,
      24.28,
      null::bigint,
      null::text) f;
end $$;


-- idempotente FC-2005DD57
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-2005DD57') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      '2028-01-01'::date,
      39.84,
      null::bigint,
      null::text) f;
end $$;


-- idempotente FC-B4477A00
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-B4477A00') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      '2028-04-01'::date,
      30.04,
      null::bigint,
      null::text) f;
end $$;


-- idempotente FC-85BDBD3D
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-85BDBD3D') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      '2027-11-01'::date,
      25.42,
      null::bigint,
      null::text) f;
end $$;


-- idempotente FC-7AA38F97
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-7AA38F97') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      '2027-12-01'::date,
      31.2,
      null::bigint,
      null::text) f;
end $$;


-- idempotente FC-9538F7D6
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-9538F7D6') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      '2028-10-01'::date,
      81.18,
      null::bigint,
      null::text) f;
end $$;


-- idempotente FC-01B2F362
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-01B2F362') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      '2027-10-01'::date,
      49.85,
      null::bigint,
      null::text) f;
end $$;


-- idempotente FC-50587FA6
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-50587FA6') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      '2027-12-01'::date,
      13.93,
      null::bigint,
      null::text) f;
end $$;


-- idempotente FC-B72A6420
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-B72A6420') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      '2027-11-01'::date,
      27.06,
      null::bigint,
      null::text) f;
end $$;


-- idempotente FC-D9391288
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-D9391288') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      '2027-11-26'::date,
      68.5,
      null::bigint,
      null::text) f;
end $$;


-- idempotente FC-41339950
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-41339950') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      '2028-02-01'::date,
      59.45,
      null::bigint,
      null::text) f;
end $$;


-- idempotente FC-E6112F15
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-E6112F15') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      '2028-03-01'::date,
      63.32,
      null::bigint,
      null::text) f;
end $$;


-- idempotente FC-F183C6E9
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-F183C6E9') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      '2028-02-01'::date,
      19.44,
      null::bigint,
      null::text) f;
end $$;


-- idempotente FC-A0D320D1
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-A0D320D1') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      '2027-09-01'::date,
      18.37,
      null::bigint,
      null::text) f;
end $$;


-- idempotente FC-95779436
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-95779436') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      '2028-06-30'::date,
      19.07,
      null::bigint,
      null::text) f;
end $$;


-- idempotente FC-4C621D07
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-4C621D07') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      '2027-03-01'::date,
      18.03,
      null::bigint,
      null::text) f;
end $$;


-- idempotente FC-022543CD
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-022543CD') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      '2028-02-01'::date,
      37.22,
      null::bigint,
      null::text) f;
end $$;


-- idempotente FC-64EB83AA
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-64EB83AA') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      '2027-05-01'::date,
      18.07,
      null::bigint,
      null::text) f;
end $$;


-- idempotente FC-D210172A
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-D210172A') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      '2027-06-01'::date,
      25.48,
      null::bigint,
      null::text) f;
end $$;


-- idempotente FC-7F90064A
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-7F90064A') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      '2027-09-01'::date,
      20.37,
      null::bigint,
      null::text) f;
end $$;


-- idempotente FC-F82A6E4B
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-F82A6E4B') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      '2028-01-01'::date,
      27.05,
      null::bigint,
      null::text) f;
end $$;


commit;

select 2 as lote_ok, 9 as lotes_total;

-- ============================================================================
-- CARGAR faltantes — Bodega 440393 + IFC + SKU sin barcode (EJECUTAR 1, 2 y SKU-only de 3)
-- 209 bloques · Mercurio, medicamentos Bodega, etc.
-- Lote 3/9 · commit parcial (un error no revierte lotes anteriores)
-- PASO 0 previo: sql/patch_cargar_faltantes_0_fix_rpcs.sql
-- ============================================================================

begin;

create temp table if not exists _fc_carga_map (
  codigo_barras text primary key,
  producto_id bigint
) on commit preserve rows;

insert into _fc_carga_map (codigo_barras, producto_id)
select codigo_barras, id from public.productos
where codigo_barras is not null and btrim(codigo_barras) <> ''
on conflict (codigo_barras) do nothing;



-- idempotente FC-5F30F9D4
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-5F30F9D4') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      '2028-04-01'::date,
      48.48,
      null::bigint,
      null::text) f;
end $$;


-- idempotente FC-7D1D9857
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-7D1D9857') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      '2028-01-01'::date,
      14.85,
      null::bigint,
      null::text) f;
end $$;


-- idempotente FC-516C2E89
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-516C2E89') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      '2028-01-01'::date,
      36.79,
      null::bigint,
      null::text) f;
end $$;


-- idempotente FC-05965071
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-05965071') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      '2028-02-01'::date,
      24.05,
      null::bigint,
      null::text) f;
end $$;


-- idempotente FC-930E0B1B
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-930E0B1B') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      '2028-04-01'::date,
      20.58,
      null::bigint,
      null::text) f;
end $$;


-- idempotente FC-405A75E3
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-405A75E3') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      '2028-02-01'::date,
      217.23,
      null::bigint,
      null::text) f;
end $$;


-- idempotente FC-D06E54FE
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-D06E54FE') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      '2028-01-01'::date,
      51.18,
      null::bigint,
      null::text) f;
end $$;


-- idempotente FC-3A4583F3
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-3A4583F3') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      '2027-06-01'::date,
      14.07,
      null::bigint,
      null::text) f;
end $$;


-- idempotente FC-F22C72BE
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-F22C72BE') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      '2028-01-01'::date,
      55.03,
      null::bigint,
      null::text) f;
end $$;


-- idempotente FC-F48FF7EF
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-F48FF7EF') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      '2028-01-01'::date,
      35.62,
      null::bigint,
      null::text) f;
end $$;


-- idempotente FC-4BD80686
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-4BD80686') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      '2027-10-01'::date,
      88.17,
      null::bigint,
      null::text) f;
end $$;


-- idempotente FC-974EE5FD
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-974EE5FD') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      '2030-04-21'::date,
      27.09,
      null::bigint,
      null::text) f;
end $$;


-- idempotente FC-0E0A9E42
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-0E0A9E42') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      '2027-11-01'::date,
      47.99,
      null::bigint,
      null::text) f;
end $$;


-- idempotente FC-6519183A
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-6519183A') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      '2028-02-01'::date,
      27.89,
      null::bigint,
      null::text) f;
end $$;


-- idempotente FC-DDFBABDF
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-DDFBABDF') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      '2028-01-01'::date,
      25.94,
      null::bigint,
      null::text) f;
end $$;


-- idempotente FC-C9F4ACCC
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-C9F4ACCC') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      '2029-03-30'::date,
      39.44,
      null::bigint,
      null::text) f;
end $$;


-- idempotente FC-17376CAE
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-17376CAE') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      '2028-05-01'::date,
      19.72,
      null::bigint,
      null::text) f;
end $$;


-- idempotente FC-369D1689
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-369D1689') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      '2027-10-01'::date,
      51.43,
      null::bigint,
      null::text) f;
end $$;


-- idempotente FC-B69FCBF4
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-B69FCBF4') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      '2028-10-01'::date,
      146.11,
      null::bigint,
      null::text) f;
end $$;


-- idempotente FC-F4E9C71F
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-F4E9C71F') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      '2028-06-30'::date,
      72.03,
      null::bigint,
      null::text) f;
end $$;


-- idempotente FC-428A228F
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-428A228F') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      '2029-03-31'::date,
      23.57,
      null::bigint,
      null::text) f;
end $$;


-- idempotente FC-FD845E68
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-FD845E68') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      '2029-02-01'::date,
      23.68,
      null::bigint,
      null::text) f;
end $$;


-- idempotente FC-B2123139
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-B2123139') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      '2028-02-01'::date,
      64.09,
      null::bigint,
      null::text) f;
end $$;


-- idempotente FC-11294615
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-11294615') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      '2028-02-01'::date,
      31.94,
      null::bigint,
      null::text) f;
end $$;


-- idempotente FC-1FEA2FB7
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-1FEA2FB7') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      '2027-10-01'::date,
      29.21,
      null::bigint,
      null::text) f;
end $$;


commit;

select 3 as lote_ok, 9 as lotes_total;

-- ============================================================================
-- CARGAR faltantes — Bodega 440393 + IFC + SKU sin barcode (EJECUTAR 1, 2 y SKU-only de 3)
-- 209 bloques · Mercurio, medicamentos Bodega, etc.
-- Lote 4/9 · commit parcial (un error no revierte lotes anteriores)
-- PASO 0 previo: sql/patch_cargar_faltantes_0_fix_rpcs.sql
-- ============================================================================

begin;

create temp table if not exists _fc_carga_map (
  codigo_barras text primary key,
  producto_id bigint
) on commit preserve rows;

insert into _fc_carga_map (codigo_barras, producto_id)
select codigo_barras, id from public.productos
where codigo_barras is not null and btrim(codigo_barras) <> ''
on conflict (codigo_barras) do nothing;



-- idempotente FC-AE5EEDF7
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-AE5EEDF7') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      '2028-01-01'::date,
      48.65,
      null::bigint,
      null::text) f;
end $$;


-- idempotente FC-F8691496
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-F8691496') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      '2028-03-01'::date,
      16.89,
      null::bigint,
      null::text) f;
end $$;


-- idempotente FC-6074BB64
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-6074BB64') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      '2027-04-01'::date,
      21.01,
      null::bigint,
      null::text) f;
end $$;


-- idempotente FC-E826D304
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-E826D304') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      '2027-12-31'::date,
      47.85,
      null::bigint,
      null::text) f;
end $$;


-- idempotente FC-4F737E93
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-4F737E93') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      NULL::date,
      44.04,
      null::bigint,
      null::text) f;
end $$;


-- idempotente FC-DB3B2584
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-DB3B2584') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      '2028-06-01'::date,
      16.91,
      null::bigint,
      null::text) f;
end $$;


-- idempotente FC-22B18244
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-22B18244') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      '2027-10-01'::date,
      31.06,
      null::bigint,
      null::text) f;
end $$;


-- idempotente FC-4A0245DA
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-4A0245DA') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      '2027-11-09'::date,
      32.52,
      null::bigint,
      null::text) f;
end $$;


-- idempotente FC-29670370
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-29670370') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      '2028-03-31'::date,
      35.71,
      null::bigint,
      null::text) f;
end $$;


-- idempotente FC-69A3C416
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-69A3C416') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      '2028-02-01'::date,
      16.65,
      null::bigint,
      null::text) f;
end $$;


-- idempotente FC-F817BC3A
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-F817BC3A') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      '2028-04-30'::date,
      33.65,
      null::bigint,
      null::text) f;
end $$;


-- idempotente FC-447B30F9
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-447B30F9') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      '2028-02-01'::date,
      131.38,
      null::bigint,
      null::text) f;
end $$;


-- idempotente FC-1CF27DC9
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-1CF27DC9') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      '2028-04-30'::date,
      36.86,
      null::bigint,
      null::text) f;
end $$;


-- idempotente FC-3CAA7C5C
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-3CAA7C5C') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      '2028-05-30'::date,
      35.05,
      null::bigint,
      null::text) f;
end $$;


-- idempotente FC-E6B50AC3
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-E6B50AC3') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      '2028-05-01'::date,
      34.82,
      null::bigint,
      null::text) f;
end $$;


-- idempotente FC-6B2ADEE9
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-6B2ADEE9') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      '2029-04-01'::date,
      96.21,
      null::bigint,
      null::text) f;
end $$;


-- idempotente FC-DB4A39AE
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-DB4A39AE') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      '2028-05-01'::date,
      39.07,
      null::bigint,
      null::text) f;
end $$;


-- idempotente FC-FA3D96E6
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-FA3D96E6') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      '2028-03-01'::date,
      47.13,
      null::bigint,
      null::text) f;
end $$;


-- idempotente FC-63975795
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-63975795') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      '2028-03-01'::date,
      17.58,
      null::bigint,
      null::text) f;
end $$;


-- idempotente FC-C6C20517
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-C6C20517') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      '2027-12-31'::date,
      31.31,
      null::bigint,
      null::text) f;
end $$;


-- idempotente FC-58DB24C4
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-58DB24C4') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      '2028-02-01'::date,
      62.78,
      null::bigint,
      null::text) f;
end $$;


-- idempotente FC-1FFBB505
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-1FFBB505') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      '2027-11-01'::date,
      42.14,
      null::bigint,
      null::text) f;
end $$;


-- idempotente FC-A909ABC0
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-A909ABC0') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      '2029-03-01'::date,
      13.77,
      null::bigint,
      null::text) f;
end $$;


-- idempotente FC-82F88FED
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-82F88FED') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      '2028-01-01'::date,
      7.95,
      null::bigint,
      null::text) f;
end $$;


-- idempotente FC-6C2878CF
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-6C2878CF') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      '2027-12-01'::date,
      130.24,
      null::bigint,
      null::text) f;
end $$;


commit;

select 4 as lote_ok, 9 as lotes_total;

-- ============================================================================
-- CARGAR faltantes — Bodega 440393 + IFC + SKU sin barcode (EJECUTAR 1, 2 y SKU-only de 3)
-- 209 bloques · Mercurio, medicamentos Bodega, etc.
-- Lote 5/9 · commit parcial (un error no revierte lotes anteriores)
-- PASO 0 previo: sql/patch_cargar_faltantes_0_fix_rpcs.sql
-- ============================================================================

begin;

create temp table if not exists _fc_carga_map (
  codigo_barras text primary key,
  producto_id bigint
) on commit preserve rows;

insert into _fc_carga_map (codigo_barras, producto_id)
select codigo_barras, id from public.productos
where codigo_barras is not null and btrim(codigo_barras) <> ''
on conflict (codigo_barras) do nothing;



-- idempotente FC-3B001F9B
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-3B001F9B') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      '2027-05-01'::date,
      9.04,
      null::bigint,
      null::text) f;
end $$;


-- idempotente FC-B25094C4
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-B25094C4') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      '2027-11-01'::date,
      44.43,
      null::bigint,
      null::text) f;
end $$;


-- idempotente FC-26EA40A4
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-26EA40A4') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      '2028-01-31'::date,
      19.65,
      null::bigint,
      null::text) f;
end $$;


-- idempotente FC-885F2723
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-885F2723') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      '2029-05-01'::date,
      18.11,
      null::bigint,
      null::text) f;
end $$;


-- idempotente FC-DF8ADDAB
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-DF8ADDAB') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      '2027-10-01'::date,
      22.15,
      null::bigint,
      null::text) f;
end $$;


-- idempotente FC-50AC2C82
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-50AC2C82') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      '2027-11-01'::date,
      24.45,
      null::bigint,
      null::text) f;
end $$;


-- idempotente FC-281E0F22
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-281E0F22') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      '2028-01-01'::date,
      153.72,
      null::bigint,
      null::text) f;
end $$;


-- idempotente FC-9F67BB73
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-9F67BB73') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      '2028-01-01'::date,
      27.0,
      null::bigint,
      null::text) f;
end $$;


-- idempotente FC-4FD413D2
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-4FD413D2') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      '2028-05-05'::date,
      23.53,
      null::bigint,
      null::text) f;
end $$;


-- idempotente FC-0BDE9283
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-0BDE9283') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      '2029-05-19'::date,
      56.51,
      null::bigint,
      null::text) f;
end $$;


-- idempotente FC-97BEFA1A
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-97BEFA1A') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      '2027-12-31'::date,
      32.52,
      null::bigint,
      null::text) f;
end $$;


-- idempotente FC-DEAF33B0
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-DEAF33B0') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      '2028-05-01'::date,
      21.28,
      null::bigint,
      null::text) f;
end $$;


-- idempotente FC-77FE5C83
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-77FE5C83') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      '2028-06-30'::date,
      32.41,
      null::bigint,
      null::text) f;
end $$;


-- idempotente FC-C636D8EA
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-C636D8EA') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      '2027-03-31'::date,
      9.8,
      null::bigint,
      null::text) f;
end $$;


-- idempotente FC-44B6751A
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-44B6751A') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      '2028-01-01'::date,
      59.63,
      null::bigint,
      null::text) f;
end $$;


-- idempotente FC-9B93AC4C
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-9B93AC4C') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      '2027-12-01'::date,
      97.6,
      null::bigint,
      null::text) f;
end $$;


-- idempotente FC-2001A890
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-2001A890') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      '2028-03-31'::date,
      81.71,
      null::bigint,
      null::text) f;
end $$;


-- idempotente FC-DE106642
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-DE106642') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      '2028-02-01'::date,
      73.57,
      null::bigint,
      null::text) f;
end $$;


-- idempotente FC-BE76D409
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-BE76D409') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      '2027-11-01'::date,
      19.72,
      null::bigint,
      null::text) f;
end $$;


-- idempotente FC-07F04F88
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-07F04F88') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      '2028-03-01'::date,
      19.43,
      null::bigint,
      null::text) f;
end $$;


-- idempotente FC-357D4A17
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-357D4A17') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      '2028-03-01'::date,
      45.42,
      null::bigint,
      null::text) f;
end $$;


-- idempotente FC-5D9DFA3D
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-5D9DFA3D') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      '2027-11-30'::date,
      48.87,
      null::bigint,
      null::text) f;
end $$;


-- idempotente FC-E9C38DC4
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-E9C38DC4') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      '2028-02-01'::date,
      22.92,
      null::bigint,
      null::text) f;
end $$;


-- idempotente FC-347A49C7
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-347A49C7') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      '2027-10-01'::date,
      19.46,
      null::bigint,
      null::text) f;
end $$;


-- idempotente FC-E4BE37BE
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-E4BE37BE') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      '2028-05-01'::date,
      26.35,
      null::bigint,
      null::text) f;
end $$;


commit;

select 5 as lote_ok, 9 as lotes_total;

-- ============================================================================
-- CARGAR faltantes — Bodega 440393 + IFC + SKU sin barcode (EJECUTAR 1, 2 y SKU-only de 3)
-- 209 bloques · Mercurio, medicamentos Bodega, etc.
-- Lote 6/9 · commit parcial (un error no revierte lotes anteriores)
-- PASO 0 previo: sql/patch_cargar_faltantes_0_fix_rpcs.sql
-- ============================================================================

begin;

create temp table if not exists _fc_carga_map (
  codigo_barras text primary key,
  producto_id bigint
) on commit preserve rows;

insert into _fc_carga_map (codigo_barras, producto_id)
select codigo_barras, id from public.productos
where codigo_barras is not null and btrim(codigo_barras) <> ''
on conflict (codigo_barras) do nothing;



-- idempotente FC-1751468C
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-1751468C') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      '2027-10-31'::date,
      27.33,
      null::bigint,
      null::text) f;
end $$;


-- idempotente FC-6898B64F
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-6898B64F') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      '2026-02-01'::date,
      47.7,
      null::bigint,
      null::text) f;
end $$;


-- idempotente FC-CD261CD5
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-CD261CD5') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      '2028-03-09'::date,
      22.41,
      null::bigint,
      null::text) f;
end $$;


-- idempotente FC-5C8C9C11
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-5C8C9C11') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      '2028-04-10'::date,
      21.95,
      null::bigint,
      null::text) f;
end $$;


-- idempotente FC-A23F290E
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-A23F290E') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      '2028-04-30'::date,
      34.61,
      null::bigint,
      null::text) f;
end $$;


-- idempotente FC-5885E577
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-5885E577') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      '2028-04-01'::date,
      60.47,
      null::bigint,
      null::text) f;
end $$;


-- idempotente FC-3D0F54B7
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-3D0F54B7') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      '2028-03-30'::date,
      30.06,
      null::bigint,
      null::text) f;
end $$;


-- idempotente FC-F7A2CACF
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-F7A2CACF') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      '2028-04-01'::date,
      56.3,
      null::bigint,
      null::text) f;
end $$;


-- idempotente FC-50D044FF
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-50D044FF') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      '2028-04-01'::date,
      24.51,
      null::bigint,
      null::text) f;
end $$;


-- idempotente FC-E535DE28
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-E535DE28') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      '2028-02-01'::date,
      9.31,
      null::bigint,
      null::text) f;
end $$;


-- idempotente FC-1321B34F
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-1321B34F') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      '2028-11-01'::date,
      34.6,
      null::bigint,
      null::text) f;
end $$;


-- idempotente FC-1AE9D7E6
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-1AE9D7E6') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      '2028-10-30'::date,
      47.85,
      null::bigint,
      null::text) f;
end $$;


-- idempotente FC-3E863E37
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-3E863E37') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      '2028-02-01'::date,
      47.47,
      null::bigint,
      null::text) f;
end $$;


-- idempotente FC-9ABFB996
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-9ABFB996') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      '2029-02-28'::date,
      30.77,
      null::bigint,
      null::text) f;
end $$;


-- idempotente FC-9A37D44A
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-9A37D44A') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      '2028-02-01'::date,
      26.11,
      null::bigint,
      null::text) f;
end $$;


-- idempotente FC-1BF03D35
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-1BF03D35') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      '2028-01-01'::date,
      18.44,
      null::bigint,
      null::text) f;
end $$;


-- idempotente FC-5BC5F234
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-5BC5F234') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      '2027-11-30'::date,
      12.92,
      null::bigint,
      null::text) f;
end $$;


-- idempotente FC-A2B284E0
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-A2B284E0') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      '2028-03-11'::date,
      113.89,
      null::bigint,
      null::text) f;
end $$;


-- idempotente FC-2E79C2D8
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-2E79C2D8') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      '2027-10-01'::date,
      61.33,
      null::bigint,
      null::text) f;
end $$;


-- idempotente FC-28A424E5
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-28A424E5') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      '2028-02-01'::date,
      8.15,
      null::bigint,
      null::text) f;
end $$;


-- idempotente FC-52D2A43A
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-52D2A43A') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      '2028-01-13'::date,
      29.08,
      null::bigint,
      null::text) f;
end $$;


-- idempotente FC-3D0ED22B
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-3D0ED22B') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      '2027-06-30'::date,
      27.98,
      null::bigint,
      null::text) f;
end $$;


-- idempotente FC-04D83B46
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-04D83B46') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      '2028-02-01'::date,
      42.85,
      null::bigint,
      null::text) f;
end $$;


-- idempotente FC-D11D586A
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-D11D586A') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      '2027-11-01'::date,
      19.41,
      null::bigint,
      null::text) f;
end $$;


-- idempotente FC-53506FA4
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-53506FA4') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      '2028-03-01'::date,
      8.09,
      null::bigint,
      null::text) f;
end $$;


commit;

select 6 as lote_ok, 9 as lotes_total;

-- ============================================================================
-- CARGAR faltantes — Bodega 440393 + IFC + SKU sin barcode (EJECUTAR 1, 2 y SKU-only de 3)
-- 209 bloques · Mercurio, medicamentos Bodega, etc.
-- Lote 7/9 · commit parcial (un error no revierte lotes anteriores)
-- PASO 0 previo: sql/patch_cargar_faltantes_0_fix_rpcs.sql
-- ============================================================================

begin;

create temp table if not exists _fc_carga_map (
  codigo_barras text primary key,
  producto_id bigint
) on commit preserve rows;

insert into _fc_carga_map (codigo_barras, producto_id)
select codigo_barras, id from public.productos
where codigo_barras is not null and btrim(codigo_barras) <> ''
on conflict (codigo_barras) do nothing;



-- idempotente FC-F7DB080D
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-F7DB080D') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      '2028-03-01'::date,
      20.33,
      null::bigint,
      null::text) f;
end $$;


-- idempotente FC-57925EF3
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-57925EF3') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      '2029-02-01'::date,
      8.88,
      null::bigint,
      null::text) f;
end $$;


-- idempotente FC-AA7B0686
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-AA7B0686') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      '2028-04-01'::date,
      70.74,
      null::bigint,
      null::text) f;
end $$;


-- idempotente FC-B3B8F9BB
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-B3B8F9BB') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      '2028-03-31'::date,
      47.31,
      null::bigint,
      null::text) f;
end $$;


-- idempotente FC-EADF1484
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-EADF1484') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      '2028-05-01'::date,
      39.41,
      null::bigint,
      null::text) f;
end $$;


-- idempotente FC-262F2A30
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-262F2A30') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      '2027-09-01'::date,
      43.98,
      null::bigint,
      null::text) f;
end $$;


-- idempotente FC-1DAD5EF1
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-1DAD5EF1') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      '2029-10-20'::date,
      24.22,
      null::bigint,
      null::text) f;
end $$;


-- idempotente FC-BDB2E087
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-BDB2E087') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      '2028-01-01'::date,
      70.49,
      null::bigint,
      null::text) f;
end $$;


-- idempotente FC-759A5EF9
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-759A5EF9') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      '2028-05-01'::date,
      24.89,
      null::bigint,
      null::text) f;
end $$;


-- idempotente FC-1FBF5206
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-1FBF5206') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      NULL::date,
      20.0,
      null::bigint,
      null::text) f;
end $$;


-- idempotente FC-2E5B7248
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-2E5B7248') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      NULL::date,
      11.0,
      null::bigint,
      null::text) f;
end $$;


-- idempotente FC-62034164
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-62034164') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      NULL::date,
      6.0,
      null::bigint,
      null::text) f;
end $$;


-- idempotente FC-3676D5DC
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-3676D5DC') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      NULL::date,
      6.0,
      null::bigint,
      null::text) f;
end $$;


-- idempotente FC-5A697CC2
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-5A697CC2') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      NULL::date,
      8.0,
      null::bigint,
      null::text) f;
end $$;


-- idempotente FC-39036C88
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-39036C88') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      NULL::date,
      12.0,
      null::bigint,
      null::text) f;
end $$;


-- idempotente FC-DFF99C3F
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-DFF99C3F') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      NULL::date,
      7.0,
      null::bigint,
      null::text) f;
end $$;


-- idempotente FC-931B4809
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-931B4809') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      NULL::date,
      8.0,
      null::bigint,
      null::text) f;
end $$;


-- idempotente FC-D4AC123B
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-D4AC123B') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      NULL::date,
      8.0,
      null::bigint,
      null::text) f;
end $$;


-- idempotente FC-38CAFE6B
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-38CAFE6B') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      NULL::date,
      8.0,
      null::bigint,
      null::text) f;
end $$;


-- idempotente FC-926099D3
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-926099D3') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      NULL::date,
      9.0,
      null::bigint,
      null::text) f;
end $$;


-- idempotente FC-E69F2E63
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-E69F2E63') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      NULL::date,
      11.0,
      null::bigint,
      null::text) f;
end $$;


-- idempotente FC-25E452B6
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-25E452B6') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      NULL::date,
      7.5,
      null::bigint,
      null::text) f;
end $$;


-- idempotente FC-127F5753
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-127F5753') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      NULL::date,
      7.5,
      null::bigint,
      null::text) f;
end $$;


-- idempotente FC-D3D28E20
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-D3D28E20') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      NULL::date,
      11.5,
      null::bigint,
      null::text) f;
end $$;


-- idempotente FC-69387811
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-69387811') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      NULL::date,
      8.0,
      null::bigint,
      null::text) f;
end $$;


commit;

select 7 as lote_ok, 9 as lotes_total;

-- ============================================================================
-- CARGAR faltantes — Bodega 440393 + IFC + SKU sin barcode (EJECUTAR 1, 2 y SKU-only de 3)
-- 209 bloques · Mercurio, medicamentos Bodega, etc.
-- Lote 8/9 · commit parcial (un error no revierte lotes anteriores)
-- PASO 0 previo: sql/patch_cargar_faltantes_0_fix_rpcs.sql
-- ============================================================================

begin;

create temp table if not exists _fc_carga_map (
  codigo_barras text primary key,
  producto_id bigint
) on commit preserve rows;

insert into _fc_carga_map (codigo_barras, producto_id)
select codigo_barras, id from public.productos
where codigo_barras is not null and btrim(codigo_barras) <> ''
on conflict (codigo_barras) do nothing;



-- idempotente FC-A680F97E
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-A680F97E') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      NULL::date,
      11.0,
      null::bigint,
      null::text) f;
end $$;


-- idempotente FC-C4530823
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-C4530823') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      NULL::date,
      54.0,
      null::bigint,
      null::text) f;
end $$;


-- idempotente FC-D037156B
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-D037156B') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      NULL::date,
      73.5,
      null::bigint,
      null::text) f;
end $$;


-- idempotente FC-B8D7C997
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-B8D7C997') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      NULL::date,
      48.0,
      null::bigint,
      null::text) f;
end $$;


-- idempotente FC-CB5C11ED
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-CB5C11ED') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      NULL::date,
      51.5,
      null::bigint,
      null::text) f;
end $$;


-- idempotente FC-A871D831
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-A871D831') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      NULL::date,
      22.5,
      null::bigint,
      null::text) f;
end $$;


-- idempotente FC-578F060C
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-578F060C') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      NULL::date,
      53.0,
      null::bigint,
      null::text) f;
end $$;


-- idempotente FC-FBD776D2
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-FBD776D2') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      NULL::date,
      170.0,
      null::bigint,
      null::text) f;
end $$;


-- idempotente FC-5EF90195
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-5EF90195') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      NULL::date,
      55.0,
      null::bigint,
      null::text) f;
end $$;


-- idempotente FC-9A1C64E7
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-9A1C64E7') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      NULL::date,
      14.5,
      null::bigint,
      null::text) f;
end $$;


-- idempotente FC-47AAF23B
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-47AAF23B') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      NULL::date,
      69.0,
      null::bigint,
      null::text) f;
end $$;


-- idempotente FC-FFC25DD1
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-FFC25DD1') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      NULL::date,
      19.5,
      null::bigint,
      null::text) f;
end $$;


-- idempotente FC-614E4F82
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-614E4F82') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      NULL::date,
      18.5,
      null::bigint,
      null::text) f;
end $$;


-- idempotente FC-C22EBFE6
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-C22EBFE6') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      NULL::date,
      16.0,
      null::bigint,
      null::text) f;
end $$;


-- idempotente FC-BCF59548
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-BCF59548') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      NULL::date,
      15.5,
      null::bigint,
      null::text) f;
end $$;


-- idempotente FC-9507CD66
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-9507CD66') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      NULL::date,
      65.0,
      null::bigint,
      null::text) f;
end $$;


-- idempotente FC-FEAECBF1
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-FEAECBF1') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      NULL::date,
      9.5,
      null::bigint,
      null::text) f;
end $$;


-- idempotente FC-9827438F
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-9827438F') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      NULL::date,
      9.5,
      null::bigint,
      null::text) f;
end $$;


-- idempotente FC-EFB599B5
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-EFB599B5') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      NULL::date,
      9.5,
      null::bigint,
      null::text) f;
end $$;


-- idempotente FC-08DB70CB
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-08DB70CB') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      NULL::date,
      11.5,
      null::bigint,
      null::text) f;
end $$;


-- idempotente FC-89F00320
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-89F00320') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      NULL::date,
      10.5,
      null::bigint,
      null::text) f;
end $$;


-- idempotente FC-FD718DF3
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-FD718DF3') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      NULL::date,
      11.5,
      null::bigint,
      null::text) f;
end $$;


-- idempotente FC-0ACC5B6A
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-0ACC5B6A') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      NULL::date,
      9.0,
      null::bigint,
      null::text) f;
end $$;


-- idempotente FC-5D59ED54
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-5D59ED54') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      NULL::date,
      34.0,
      null::bigint,
      null::text) f;
end $$;


-- idempotente FC-66055303
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-66055303') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      NULL::date,
      15.18,
      null::bigint,
      null::text) f;
end $$;


commit;

select 8 as lote_ok, 9 as lotes_total;

-- ============================================================================
-- CARGAR faltantes — Bodega 440393 + IFC + SKU sin barcode (EJECUTAR 1, 2 y SKU-only de 3)
-- 209 bloques · Mercurio, medicamentos Bodega, etc.
-- Lote 9/9 · commit parcial (un error no revierte lotes anteriores)
-- PASO 0 previo: sql/patch_cargar_faltantes_0_fix_rpcs.sql
-- ============================================================================

begin;

create temp table if not exists _fc_carga_map (
  codigo_barras text primary key,
  producto_id bigint
) on commit preserve rows;

insert into _fc_carga_map (codigo_barras, producto_id)
select codigo_barras, id from public.productos
where codigo_barras is not null and btrim(codigo_barras) <> ''
on conflict (codigo_barras) do nothing;



-- idempotente FC-D751525D
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-D751525D') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      NULL::date,
      22.65,
      null::bigint,
      null::text) f;
end $$;


-- idempotente FC-4F05124E
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-4F05124E') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      NULL::date,
      66.3,
      null::bigint,
      null::text) f;
end $$;


-- idempotente FC-1812D26D
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-1812D26D') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      NULL::date,
      78.16,
      null::bigint,
      null::text) f;
end $$;


-- idempotente FC-00E8A9C7
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-00E8A9C7') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      NULL::date,
      74.27,
      null::bigint,
      null::text) f;
end $$;


-- idempotente FC-DA34D88D
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-DA34D88D') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      NULL::date,
      5.54,
      null::bigint,
      null::text) f;
end $$;


-- idempotente FC-BE2ACF63
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-BE2ACF63') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      NULL::date,
      4.56,
      null::bigint,
      null::text) f;
end $$;


-- idempotente FC-DF39BB27
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-DF39BB27') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      NULL::date,
      68.88,
      null::bigint,
      null::text) f;
end $$;


-- idempotente FC-C8B741F6
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-C8B741F6') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      NULL::date,
      10.45,
      null::bigint,
      null::text) f;
end $$;


-- idempotente FC-BE0A0E46
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (select 1 from public.productos where sku = 'FC-BE0A0E46') then
    return;
  end if;
  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(

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
      NULL::date,
      9.26,
      null::bigint,
      null::text) f;
end $$;


commit;

select 9 as lote_ok, 9 as lotes_total;

-- Al terminar todos los lotes de este archivo:
select count(*) as productos_fc from public.productos where sku like 'FC-%';
