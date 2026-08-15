-- ============================================================================
-- PATCH INVENTARIO COMPLETO — ejecutar una sola vez en Supabase SQL Editor
-- Generado: 2026-08-14 19:34
-- Incluye: barcodes, metadata, renombres, campos vacíos, inserts faltantes
-- NO toca precio, costo ni stock salvo productos NUEVOS (insert-only)
-- ============================================================================

begin;

-- ── 1. Barcodes corregidos (errores patch OCR anterior) ──

-- FC-12225027: OCR mezcló Tempra+Derman (7501354312225027). Código real Derman 50 g: 3543122250276
update public.productos p set codigo_barras = '3543122250276' where p.sku = 'FC-12225027' and p.activo = true and coalesce(p.codigo_barras, '') <> '3543122250276' and not exists (select 1 from public.productos o where o.codigo_barras = '3543122250276' and o.id <> p.id);

-- FC-71829601: Tribedoce 50000 Amp C/5 — OCR 75015015371829601; patch anterior dejó 7501501537161 (incorrecto)
update public.productos p set codigo_barras = '7501537182960' where p.sku = 'FC-71829601' and p.activo = true and coalesce(p.codigo_barras, '') <> '7501537182960' and not exists (select 1 from public.productos o where o.codigo_barras = '7501537182960' and o.id <> p.id);

-- ── 2. Metadata corregida (PA, presentación, etc.) ──

-- FC-12225027 · Derman Crema 50 g
update public.productos set nombre = 'Derman Crema 50 g', marca = 'Derman', presentacion = '50 G', principio_activo = 'Ácido undecilénico + Undecilenato de zinc', concentracion = '18/5 G/100G', forma_farmaceutica = 'CREMA', categoria = 'Medicamentos', tipo = 'MEDICAMENTO' where sku = 'FC-12225027' and activo = true;

-- FC-71829601 · Tribedoce 50000 UI Amp C/5
update public.productos set nombre = 'Tribedoce 50000 UI Amp C/5', marca = 'Bruluart', presentacion = 'Amp C/5', principio_activo = 'Hidroxocobalamina + Tiamina + Piridoxina', concentracion = '50000 UI / 100 mg / 50 mg', forma_farmaceutica = 'AMPOLLETA', categoria = 'Medicamentos', tipo = 'MEDICAMENTO' where sku = 'FC-71829601' and activo = true;

-- ── 3. Renombres legibles (delta) ──

update public.productos set nombre = 'Crema Nivea manos antiarrugas' where sku = 'FC-00701992' and activo = true;
update public.productos set nombre = 'Afrin Adulto spray 20 mL' where sku = 'FC-06134531' and activo = true;
update public.productos set nombre = 'Dove aerosol tono uniforme caléndula y vitamina E' where sku = 'FC-06248052' and activo = true;
update public.productos set nombre = 'Tabcin efervescente' where sku = 'FC-08485316' and activo = true;
update public.productos set nombre = 'Cafiaspirina tartrato C/100' where sku = 'FC-08491096' and activo = true;
update public.productos set nombre = 'Aspirina efervescente C/12' where sku = 'FC-08496701' and activo = true;
update public.productos set nombre = 'Derman Crema 50 g' where sku = 'FC-12225027' and activo = true;
update public.productos set nombre = 'Hucius cápsulas' where sku = 'FC-1812D26D' and activo = true;
update public.productos set nombre = 'Tusilen adulto jarabe' where sku = 'FC-1DAD5EF1' and activo = true;
update public.productos set nombre = 'Shampoo Pert Aceite oliva' where sku = 'FC-20500201' and activo = true;
update public.productos set nombre = 'Vick Drops jengibre pastillas C/20' where sku = 'FC-35246309' and activo = true;
update public.productos set nombre = 'Talco para bebé Mennen azul chico' where sku = 'FC-35908116' and activo = true;
update public.productos set nombre = 'Talco para bebé Mennen azul' where sku = 'FC-35908130' and activo = true;
update public.productos set nombre = 'Talco para bebé Mennen rosa' where sku = 'FC-35908147' and activo = true;
update public.productos set nombre = 'Shampoo Ricitos de Oro Biopure' where sku = 'FC-36032776' and activo = true;
update public.productos set nombre = 'Shampoo Ricitos de Oro Agua De Coco' where sku = 'FC-36033735' and activo = true;
update public.productos set nombre = 'Next tabletas C/10' where sku = 'FC-40010538' and activo = true;
update public.productos set nombre = 'XL-3 VR C/24' where sku = 'FC-40017100' and activo = true;
update public.productos set nombre = 'Genoprazol tabletas C/7' where sku = 'FC-40036354' and activo = true;
update public.productos set nombre = 'Gelcavit-9M cápsulas C/30' where sku = 'FC-4F05124E' and activo = true;
update public.productos set nombre = 'Ajolotius jengibre pastillas' where sku = 'FC-52400212' and activo = true;
update public.productos set nombre = 'Crema para peinar Sedal reconstructor instantáneo' where sku = 'FC-56342258' and activo = true;
update public.productos set nombre = 'Ajolotius menta eucalipto pastillas' where sku = 'FC-62746643' and activo = true;
update public.productos set nombre = 'Aderogyl ampolletas C/4' where sku = 'FC-80596011' and activo = true;
update public.productos set nombre = 'Talco Nuvel Pura para bebé' where sku = 'FC-82790016' and activo = true;
update public.productos set nombre = 'Cinta micropore blanca 2.5 cm x 5 m' where sku = 'FC-84500522' and activo = true;
update public.productos set nombre = 'Cinta micropore blanca 2.5 cm x 9.1 m' where sku = 'FC-84500607' and activo = true;
update public.productos set nombre = 'Drosquim adulto jarabe 300/160' where sku = 'FC-AA7B0686' and activo = true;
update public.productos set nombre = 'Valnait cápsulas valeriana' where sku = 'FC-BE2ACF63' and activo = true;
update public.productos set nombre = 'Valgab 3 jarabe 6 mL' where sku = 'FC-D11D586A' and activo = true;
update public.productos set nombre = 'Animalin fórmula líquida 30 mL' where sku = 'FC-D751525D' and activo = true;
update public.productos set nombre = 'Alevarin cápsulas C/45' where sku = 'FC-DF39BB27' and activo = true;

-- ── 4. Campos vacíos (solo rellena NULL/vacío) ──

update public.productos set
  presentacion = CASE WHEN presentacion IS NULL OR btrim(presentacion) = '' THEN '15 mL' ELSE presentacion END,
  principio_activo = CASE WHEN principio_activo IS NULL OR btrim(principio_activo) = '' THEN 'Oximetazolina clorhidrato' ELSE principio_activo END,
  concentracion = CASE WHEN concentracion IS NULL OR btrim(concentracion) = '' THEN '0.05%' ELSE concentracion END,
  forma_farmaceutica = CASE WHEN forma_farmaceutica IS NULL OR btrim(forma_farmaceutica) = '' THEN 'Solución nasal' ELSE forma_farmaceutica END
where sku = 'FC-06247327'
  and (
    (codigo_barras is null or btrim(codigo_barras) = '')
    or (presentacion is null or btrim(presentacion) = '')
    or (principio_activo is null or btrim(principio_activo) = '')
    or (marca is null or btrim(marca) = '')
    or (forma_farmaceutica is null or btrim(forma_farmaceutica) = '')
  );
update public.productos set
  concentracion = CASE WHEN concentracion IS NULL OR btrim(concentracion) = '' THEN '0.05%' ELSE concentracion END
where sku = 'FC-06134531'
  and (
    (codigo_barras is null or btrim(codigo_barras) = '')
    or (presentacion is null or btrim(presentacion) = '')
    or (principio_activo is null or btrim(principio_activo) = '')
    or (marca is null or btrim(marca) = '')
    or (forma_farmaceutica is null or btrim(forma_farmaceutica) = '')
  );
update public.productos set
  principio_activo = CASE WHEN principio_activo IS NULL OR btrim(principio_activo) = '' THEN 'Latex' ELSE principio_activo END
where sku = 'FC-49853867'
  and (
    (codigo_barras is null or btrim(codigo_barras) = '')
    or (presentacion is null or btrim(presentacion) = '')
    or (principio_activo is null or btrim(principio_activo) = '')
    or (marca is null or btrim(marca) = '')
    or (forma_farmaceutica is null or btrim(forma_farmaceutica) = '')
  );
update public.productos set
  principio_activo = CASE WHEN principio_activo IS NULL OR btrim(principio_activo) = '' THEN 'Cefalexina' ELSE principio_activo END
where sku = 'FC-DB4A39AE'
  and (
    (codigo_barras is null or btrim(codigo_barras) = '')
    or (presentacion is null or btrim(presentacion) = '')
    or (principio_activo is null or btrim(principio_activo) = '')
    or (marca is null or btrim(marca) = '')
    or (forma_farmaceutica is null or btrim(forma_farmaceutica) = '')
  );
update public.productos set
  principio_activo = CASE WHEN principio_activo IS NULL OR btrim(principio_activo) = '' THEN 'SULFAMETOXAZOL + TRIMETOPRIMA' ELSE principio_activo END
where sku = 'FC-F8691496'
  and (
    (codigo_barras is null or btrim(codigo_barras) = '')
    or (presentacion is null or btrim(presentacion) = '')
    or (principio_activo is null or btrim(principio_activo) = '')
    or (marca is null or btrim(marca) = '')
    or (forma_farmaceutica is null or btrim(forma_farmaceutica) = '')
  );
update public.productos set
  forma_farmaceutica = CASE WHEN forma_farmaceutica IS NULL OR btrim(forma_farmaceutica) = '' THEN 'Material de curación' ELSE forma_farmaceutica END
where sku = 'FC-86708021'
  and (
    (codigo_barras is null or btrim(codigo_barras) = '')
    or (presentacion is null or btrim(presentacion) = '')
    or (principio_activo is null or btrim(principio_activo) = '')
    or (marca is null or btrim(marca) = '')
    or (forma_farmaceutica is null or btrim(forma_farmaceutica) = '')
  );

-- ── 5. Productos faltantes (INSERT ONLY) ──

-- omitido insert duplicado barcode 3543122250276 (ya existe FC-12225027)

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

-- [M1] FC-37164713 · 7501537164713 · Tribedoce Compuesto grageas C/30
do $$
declare v_pid bigint; v_lid bigint;
begin
  if exists (
    select 1 from public.productos
    where codigo_barras = '7501537164713' or sku = 'FC-37164713'
  ) then
    return;
  end if;

  select f.producto_id, f.lote_id into v_pid, v_lid
  from create_producto_with_lote(
    jsonb_build_object(
      'nombre', 'Tribedoce Compuesto grageas C/30',
      'sku', 'FC-37164713',
      'codigo_barras', '7501537164713',
      'categoria', 'Medicamentos',
      'tipo', 'MEDICAMENTO',
      'descripcion', 'Tribedoce Compuesto grageas C/30 — Alta manual — EAN 7501537164713 (grageas oral). Ajustar costo/precio/stock en inventario.',
      'costo', 0.00,
      'precio', 0.00,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', true
    ),
    0,
    'MAN-FC-37164713',
    NULL::date,
    0.00,
    null::bigint,
    null::text
  ) f;

  update public.productos set
    marca = 'Bruluart',
    presentacion = 'C/30 grageas',
    principio_activo = 'Diclofenaco + Complejo B (Tiamina, Piridoxina, Cianocobalamina)',
    concentracion = '50/50/1/50 mg',
    forma_farmaceutica = 'GRAGEAS'
  where id = v_pid;
end $$;

-- [M2] FC-37163266 · 7501537163266 · Tribedoce Compuesto Amp C/3
do $$
declare v_pid bigint; v_lid bigint;
begin
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
      'descripcion', 'Tribedoce Compuesto Amp C/3 — Ticket FarmaLive COMPUESTO 4266C/3 — IV TRIBEDOCE AMP ×2 cajas, costo unit s/IVA $54.10',
      'costo', 54.10,
      'precio', 73.04,
      'stock_minimo', 5,
      'activo', true,
      'requiere_receta', true
    ),
    2,
    'MAN-FC-37163266',
    NULL::date,
    54.10,
    null::bigint,
    null::text
  ) f;

  update public.productos set
    marca = 'Bruluart',
    presentacion = 'Amp C/3',
    principio_activo = 'Diclofenaco + Complejo B (Tiamina, Piridoxina, Cianocobalamina)',
    concentracion = '75/5/100 mg',
    forma_farmaceutica = 'SOLUCION INYECTABLE'
  where id = v_pid;
end $$;

commit;

-- Verificación rápida
select sku, nombre, codigo_barras, principio_activo, presentacion
from public.productos where sku in ('FC-12225027', 'FC-37164713', 'FC-71829601') and activo = true;

select count(*) filter (where presentacion is null or btrim(presentacion) = '') as sin_pres,
       count(*) filter (where principio_activo is null or btrim(principio_activo) = '') as sin_pa
from public.productos where activo = true;
