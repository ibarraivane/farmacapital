-- ============================================================================
-- INSERT ONLY — productos faltantes de tickets PDF
-- 3 bloques · NO actualiza filas existentes
-- Incluye marca, presentación, PA, forma (solo productos nuevos)
-- Precio inicial = costo ticket × 1.35 (solo filas nuevas)
-- PASO 0 previo (si aplica): sql/patch_cargar_faltantes_0_fix_rpcs.sql
-- ============================================================================

begin;


-- [1] FL-080826 · 3543122250276 · Derman Crema 50 g
-- PA: Ácido undecilénico + Undecilenato de zinc | Pres: 50 G
do $$
declare v_pid bigint; v_lid bigint;
begin
  -- NO tocar productos que ya existen (respeta tus cambios de nombre/precio)
  if exists (
    select 1 from public.productos
    where codigo_barras = '3543122250276' or sku = 'FC-22250276'
  ) then
    return;
  end if;

  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(
    jsonb_build_object(
      'nombre', 'Derman Crema 50 g',
      'sku', 'FC-22250276',
      'codigo_barras', '3543122250276',
      'categoria', 'Medicamentos',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'Derman Crema 50 g — Ticket FL-080826 (insert-only)',
      'costo', 45.60,
      'precio', 61.57,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
    1,
    'TK-FL-080826-1',
    NULL::date,
    45.60,
    null::bigint,
    null::text
  ) f;

  -- Campos de catálogo (solo fila recién creada)
  update public.productos set
    marca = 'Derman',
    presentacion = '50 G',
    principio_activo = 'Ácido undecilénico + Undecilenato de zinc',
    concentracion = '18/5 G/100G',
    forma_farmaceutica = 'CREMA'
  where id = v_pid;
end $$;

-- [2] 112558 · 7501033954245 · Pediasure
-- PA: Suplemento nutricional | Pres: 236 ML
do $$
declare v_pid bigint; v_lid bigint;
begin
  -- NO tocar productos que ya existen (respeta tus cambios de nombre/precio)
  if exists (
    select 1 from public.productos
    where codigo_barras = '7501033954245' or sku = 'FC-33954245'
  ) then
    return;
  end if;

  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(
    jsonb_build_object(
      'nombre', 'Pediasure',
      'sku', 'FC-33954245',
      'codigo_barras', '7501033954245',
      'categoria', 'Abarrotes',
      'tipo', 'GENERICO',
      'descripcion', 'Pediasure — Ticket 112558 (insert-only)',
      'costo', 44.00,
      'precio', 59.41,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', false
    ),
    2,
    'TK-112558-2',
    NULL::date,
    44.00,
    null::bigint,
    null::text
  ) f;

  -- Campos de catálogo (solo fila recién creada)
  update public.productos set
    marca = 'Pediasure',
    presentacion = '236 ML',
    principio_activo = 'Suplemento nutricional',
    concentracion = NULL,
    forma_farmaceutica = 'LIQUIDO'
  where id = v_pid;
end $$;

-- [3] FL-080826 · 7501537163266 · Tribedoce Compuesto Amp C/3
-- PA: Diclofenaco + Complejo B (Tiamina, Piridoxina, Cianocobalami | Pres: Amp C/3
do $$
declare v_pid bigint; v_lid bigint;
begin
  -- NO tocar productos que ya existen (respeta tus cambios de nombre/precio)
  if exists (
    select 1 from public.productos
    where codigo_barras = '7501537163266' or sku = 'FC-37163266'
  ) then
    return;
  end if;

  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(
    jsonb_build_object(
      'nombre', 'Tribedoce Compuesto Amp C/3',
      'sku', 'FC-37163266',
      'codigo_barras', '7501537163266',
      'categoria', 'Medicamentos',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'Tribedoce Compuesto Amp C/3 — Ticket FL-080826 (insert-only)',
      'costo', 54.10,
      'precio', 73.04,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', true
    ),
    2,
    'TK-FL-080826-3',
    NULL::date,
    54.10,
    null::bigint,
    null::text
  ) f;

  -- Campos de catálogo (solo fila recién creada)
  update public.productos set
    marca = 'Bruluart',
    presentacion = 'Amp C/3',
    principio_activo = 'Diclofenaco + Complejo B (Tiamina, Piridoxina, Cianocobalamina)',
    concentracion = '75/5/100 mg',
    forma_farmaceutica = 'SOLUCION INYECTABLE'
  where id = v_pid;
end $$;
commit;

-- Verificación: cuántos se insertaron depende de lo que ya tengas en Supabase
select count(*) as total_productos from public.productos;
