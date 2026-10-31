-- ============================================================================
-- Alta FreeStyle Optium tiras glucosa C/50 · EAN 093815996491 · REF 99649-75
--
-- Caja Abbott en mostrador: «No está en el sistema». El pistola no matchea
-- porque el único renglón parecido (FC-01896386, bajo pedido ewafra) nació
-- SIN codigo_barras, con typo «Rectivas» y sin foto.
--
-- Ficha de la caja / Abbott: FreeStyle Optium · 50 tiras · compatible
-- FreeStyle Optium Neo / FreeStyle Libre / Libre 2 · sin codificación.
-- GS1: (01)00093815996491 · LOT 45001 90174 · EXP 2027-10-31 (MMAA en caja,
-- no se inventa aquí).
--
-- SKU canónico FC-15996491 (últimos 8 del EAN). Si ya existe FC-01896386,
-- se le pega el EAN y se corrige la ficha (no se duplica).
-- Costo ancla mayoreo ewafra $408.33 · PVP $511 (+25% marca, ceil).
-- Stock 0 hasta Recibir + MMAA. SIN do $$. Idempotente.
-- Foto tras deploy:
--   https://www.farmacapital.mx/catalogo-propia/freestyle-optium-tiras-50-093815996491.jpg
-- ============================================================================

begin;

-- 1) Enlazar EAN a la fila bajo pedido huérfana (si existe)
update public.productos p
set
  nombre = 'FreeStyle Optium',
  marca = 'FreeStyle',
  laboratorio = coalesce(nullif(trim(p.laboratorio), ''), 'Abbott'),
  presentacion = 'Caja con 50 tiras',
  forma_farmaceutica = coalesce(nullif(trim(p.forma_farmaceutica), ''), 'Tira reactiva'),
  categoria = coalesce(nullif(trim(p.categoria), ''), 'Dispositivo médico'),
  subcategoria = coalesce(nullif(trim(p.subcategoria), ''), 'Glucosa'),
  tipo = coalesce(nullif(trim(p.tipo), ''), 'marca'),
  codigo_barras = '093815996491',
  costo = case when coalesce(p.costo, 0) <= 0.01 then 408.33 else p.costo end,
  precio = case when coalesce(p.precio, 0) <= 1 then 511 else p.precio end,
  imagen_url = coalesce(nullif(trim(p.imagen_url), ''),
    'https://www.farmacapital.mx/catalogo-propia/freestyle-optium-tiras-50-093815996491.jpg'),
  imagen_mobile_url = coalesce(nullif(trim(p.imagen_mobile_url), ''),
    'https://www.farmacapital.mx/catalogo-propia/freestyle-optium-tiras-50-093815996491.jpg'),
  descripcion = coalesce(nullif(trim(p.descripcion), ''),
    'Abbott FreeStyle Optium · tiras glucosa C/50 · REF 99649-75 · EAN 093815996491 · Optium Neo / Libre / Libre 2 · sin codificación'),
  activo = true,
  stock_minimo = greatest(coalesce(p.stock_minimo, 0), 1)
where p.sku = 'FC-01896386'
  and (
    coalesce(nullif(btrim(p.codigo_barras), ''), '') = ''
    or p.codigo_barras in ('093815996491', '93815996491', '00093815996491')
  )
  and not exists (
    select 1 from public.productos x
    where x.id <> p.id
      and x.codigo_barras in ('093815996491', '93815996491', '00093815996491')
  );

-- 2) Alta canónica si aún no hay match por pistola
insert into public.productos (
  nombre, sku, codigo_barras, categoria, subcategoria, tipo, descripcion,
  costo, precio, stock, stock_minimo, activo, requiere_receta,
  marca, presentacion, forma_farmaceutica, laboratorio,
  imagen_url, imagen_mobile_url
)
select
  'FreeStyle Optium',
  case
    when exists (
      select 1 from public.productos p
      where p.sku = 'FC-15996491'
        and coalesce(p.codigo_barras, '') is distinct from '093815996491'
    ) then 'FC-ND-15996491'
    else 'FC-15996491'
  end,
  '093815996491',
  'Dispositivo médico',
  'Glucosa',
  'marca',
  'Abbott FreeStyle Optium · tiras glucosa C/50 · REF 99649-75 · EAN 093815996491 · Optium Neo / Libre / Libre 2 · sin codificación',
  408.33,
  511,
  0,
  1,
  true,
  false,
  'FreeStyle',
  'Caja con 50 tiras',
  'Tira reactiva',
  'Abbott',
  'https://www.farmacapital.mx/catalogo-propia/freestyle-optium-tiras-50-093815996491.jpg',
  'https://www.farmacapital.mx/catalogo-propia/freestyle-optium-tiras-50-093815996491.jpg'
where public.fc_buscar_producto_escaneo('093815996491') is null
  and public.fc_buscar_producto_escaneo('93815996491') is null
  and public.fc_buscar_producto_escaneo('FC-15996491') is null
  and public.fc_buscar_producto_escaneo('FC-01896386') is null
  and not exists (
    select 1 from public.productos p
    where p.codigo_barras in ('093815996491', '93815996491', '00093815996491')
       or p.sku in ('FC-15996491', 'FC-ND-15996491', 'FC-01896386')
  );

-- 3) Completar ficha si el EAN ya quedó enlazado (cualquiera de los SKUs)
update public.productos p
set
  nombre = 'FreeStyle Optium',
  marca = coalesce(nullif(trim(p.marca), ''), 'FreeStyle'),
  laboratorio = coalesce(nullif(trim(p.laboratorio), ''), 'Abbott'),
  presentacion = coalesce(nullif(trim(p.presentacion), ''), 'Caja con 50 tiras'),
  forma_farmaceutica = coalesce(nullif(trim(p.forma_farmaceutica), ''), 'Tira reactiva'),
  categoria = coalesce(nullif(trim(p.categoria), ''), 'Dispositivo médico'),
  subcategoria = coalesce(nullif(trim(p.subcategoria), ''), 'Glucosa'),
  tipo = coalesce(nullif(trim(p.tipo), ''), 'marca'),
  codigo_barras = '093815996491',
  costo = case when coalesce(p.costo, 0) <= 0.01 then 408.33 else p.costo end,
  precio = case when coalesce(p.precio, 0) <= 1 then 511 else p.precio end,
  imagen_url = coalesce(nullif(trim(p.imagen_url), ''),
    'https://www.farmacapital.mx/catalogo-propia/freestyle-optium-tiras-50-093815996491.jpg'),
  imagen_mobile_url = coalesce(nullif(trim(p.imagen_mobile_url), ''),
    'https://www.farmacapital.mx/catalogo-propia/freestyle-optium-tiras-50-093815996491.jpg'),
  activo = true,
  stock_minimo = greatest(coalesce(p.stock_minimo, 0), 1)
where p.id = public.fc_buscar_producto_escaneo('093815996491')
   or p.sku in ('FC-15996491', 'FC-ND-15996491', 'FC-01896386');

-- 4) Enlazar renglones grises de Recibir con este EAN / REF
update public.recepcion_items i
set
  producto_id = public.fc_buscar_producto_escaneo('093815996491'),
  pendiente_alta = false,
  nombre_snapshot = coalesce(nullif(btrim(i.nombre_snapshot), ''),
    'FREESTYLE OPTIUM TIRAS C/50'),
  costo_estimado = coalesce(i.costo_estimado, 408.33)
where i.producto_id is null
  and coalesce(i.pendiente_alta, true)
  and (
    coalesce(i.codigo_escaneado, '') in ('093815996491', '93815996491', '00093815996491')
    or i.nombre_snapshot ilike '%OPTIUM%TIRA%'
    or i.nombre_snapshot ilike '%FREE%STYLE%OPTIUM%'
    or i.nombre_snapshot ilike '%99649-75%'
  )
  and public.fc_buscar_producto_escaneo('093815996491') is not null;

commit;

select
  p.id,
  p.sku,
  p.codigo_barras as ean,
  p.nombre,
  p.marca,
  p.laboratorio,
  p.presentacion,
  p.costo,
  p.precio,
  p.stock,
  p.imagen_url
from public.productos p
where p.codigo_barras in ('093815996491', '93815996491', '00093815996491')
   or p.sku in ('FC-15996491', 'FC-ND-15996491', 'FC-01896386');
