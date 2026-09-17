-- ============================================================================
-- FARMA CAPITAL — Alta Ketorolaco / Tramadol AMSA inyectable
--
-- EAN: 7501349029040
-- Caja: Ketorolaco 10 mg + Tramadol 25 mg / 1 mL · solución inyectable
-- Presentación: caja con 3 ampolletas (AMSA / Antibióticos de México)
-- Reg. San.: 230M2018 SSA IV
-- Lote caja: B26F627 · Caducidad: 2028-02-28
-- Entrada: 2 piezas · costo $100 · venta $350
--
-- Nota: la caja imprime PMP $280.00; el precio de venta pedido es $350.
-- CONTROLADO Fracción III (tramadol · COFEPRIS jul-2026): solo mostrador con receta.
-- Foto packshot: public/catalogo-propia/ketorolaco-tramadol-amsa-10-25-iny-3amp.jpg
--   (URL tras deploy: https://www.farmacapital.mx/catalogo-propia/ketorolaco-tramadol-amsa-10-25-iny-3amp.jpg)
--
-- Nadro i22 no devolvió ficha para este EAN; datos tomados del empaque + ficha
-- comercial AMSA (3 ampolletas 10/25 mg/mL).
--
-- INSERT ONLY. Pegar en Supabase → SQL Editor → Run (archivo completo).
-- ============================================================================

begin;

-- Columnas de controlado (pueden faltar en prod antiguas).
alter table public.productos
  add column if not exists controlado boolean not null default false;
alter table public.productos
  add column if not exists grupo_controlado text;

do $$
declare
  v_pid bigint;
  v_lid bigint;
  v_sku text := 'FC-49029040';
  v_ean text := '7501349029040';
  v_costo numeric := 100;
  v_precio numeric := 350;
  v_foto text := 'https://www.farmacapital.mx/catalogo-propia/ketorolaco-tramadol-amsa-10-25-iny-3amp.jpg';
begin
  if exists (
    select 1 from public.productos p
    where p.codigo_barras = v_ean
       or p.sku = v_sku
       or (
         p.nombre ilike '%ketorolaco%'
         and p.nombre ilike '%tramadol%'
         and (p.nombre ilike '%inyect%' or p.nombre ilike '%ampol%')
         and (p.nombre ilike '%10%' and p.nombre ilike '%25%')
       )
  ) then
    raise notice 'Ketorolaco/Tramadol AMSA inyectable ya existe; no se inserta (INSERT ONLY).';
    return;
  end if;

  select f.producto_id, f.lote_id into v_pid, v_lid
  from public.create_producto_with_lote(
    jsonb_build_object(
      'nombre', 'Ketorolaco / Tramadol solución inyectable 10 mg - 25 mg / 1 mL AMSA',
      'sku', v_sku,
      'codigo_barras', v_ean,
      'categoria', 'Analgésico',
      'tipo', 'generico',
      'descripcion', 'AMSA · caja con 3 ampolletas de 1 mL · Ketorolaco trometamina 10 mg + Clorhidrato de tramadol 25 mg / mL · Reg. 230M2018 SSA IV · EAN 7501349029040 · requiere receta',
      'costo', v_costo,
      'precio', v_precio,
      'stock_minimo', 1,
      'activo', true,
      'requiere_receta', true,
      'controlado', true,
      'grupo_controlado', 'III',
      'visible_tienda', false
    ),
    2,                       -- 2 piezas (cajas)
    'B26F627',
    '2028-02-28'::date,
    v_costo,
    null::bigint
  ) f;

  update public.productos set
    marca = 'AMSA',
    presentacion = 'Caja con 3 ampolletas de 1 mL',
    concentracion = '10 mg / 25 mg / 1 mL',
    principio_activo = 'Ketorolaco / Tramadol',
    forma_farmaceutica = 'Solución inyectable',
    subcategoria = 'Analgésico inyectable',
    laboratorio = 'AMSA / Antibióticos de México',
    requiere_receta = true,
    controlado = true,
    grupo_controlado = 'III',
    visible_tienda = false,
    imagen_url = coalesce(nullif(imagen_url, ''), v_foto)
  where id = v_pid;

  raise notice 'Ketorolaco/Tramadol AMSA creado id % lote % (2 pzas, costo %, precio %)', v_pid, v_lid, v_costo, v_precio;
end $$;

commit;

select
  p.id,
  p.sku,
  p.nombre,
  p.codigo_barras,
  p.marca,
  p.presentacion,
  p.principio_activo,
  p.concentracion,
  p.forma_farmaceutica,
  p.categoria,
  p.costo,
  p.precio,
  p.stock,
  p.requiere_receta,
  p.imagen_url,
  l.numero_lote,
  l.fecha_caducidad,
  l.cantidad_actual
from public.productos p
left join public.lotes l on l.producto_id = p.id and coalesce(l.activo, true) = true
where p.codigo_barras = '7501349029040'
   or p.sku = 'FC-49029040'
order by p.id desc, l.id desc
limit 5;
