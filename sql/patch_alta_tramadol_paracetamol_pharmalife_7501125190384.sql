-- ============================================================================
-- FARMA CAPITAL — Alta Tramadol / Paracetamol Pharmalife
--
-- Empaque (fotos de mostrador, 18-oct-2026):
--   Tramadol, Paracetamol · tableta · 37.5 mg / 325 mg
--   Caja con 20 tabletas · vía oral · marca PHARMAlife
--   Hecho en México por Laboratorios PiSA, S.A. de C.V.
--   EAN 7501125190384 · SKU FC-25190384
--
-- Entrada: 5 cajas. Caducidad dicha en mostrador: «feb 28» = MMAA 0228
--   → último día de febrero 2028 (2028-02-29; 2028 es bisiesto).
--   Las fotos no muestran número de lote: el alta deja el lote inicial
--   del sistema (INICIAL-…). No se inventa lote de fábrica ni registro sanitario.
--
-- Sin costo en la caja: costo y precio quedan vacíos. No se copia ancla
--   de otra farmacia. Antes de cobrar, poner costo y precio (genérico +60%
--   sobre costo).
--
-- CONTROLADO fracción III (tramadol): solo mostrador, con receta. No va a
--   la tienda web.
--
-- Foto: public/catalogo-propia/tramadol-paracetamol-pharmalife-37-5-325-c20.jpg
--   (frente de la caja de mostrador).
--   URL tras deploy: https://www.farmacapital.mx/catalogo-propia/tramadol-paracetamol-pharmalife-37-5-325-c20.jpg
--
-- Idempotente. Pegar en Supabase → SQL Editor → Run (archivo completo).
-- ============================================================================

begin;

alter table public.productos
  add column if not exists controlado boolean not null default false;
alter table public.productos
  add column if not exists grupo_controlado text;
alter table public.productos
  add column if not exists visible_tienda boolean not null default true;
alter table public.productos
  add column if not exists laboratorio text;

do $$
declare
  v_pid bigint;
  v_lid bigint;
  v_ya bigint;
  v_ean text := '7501125190384';
  v_sku text := 'FC-25190384';
  v_cad date := '2028-02-29';
  v_foto text := 'https://www.farmacapital.mx/catalogo-propia/tramadol-paracetamol-pharmalife-37-5-325-c20.jpg';
begin
  v_ya := public.fc_buscar_producto_escaneo(v_ean);

  select p.id into v_pid
  from public.productos p
  where p.codigo_barras = v_ean
     or p.sku = v_sku
     or p.id = v_ya
  order by case
    when p.codigo_barras = v_ean then 0
    when p.sku = v_sku then 1
    else 2
  end, p.id
  limit 1;

  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from public.create_producto_with_lote(
      jsonb_build_object(
        'nombre', 'Tramadol / Paracetamol 37.5 mg / 325 mg',
        'sku', v_sku,
        'codigo_barras', v_ean,
        'categoria', 'Analgésico',
        'tipo', 'generico',
        'descripcion', 'Alta mostrador · Pharmalife · caja con 20 tabletas · Laboratorios PiSA · EAN 7501125190384 · caducidad feb 2028 · controlado fracción III',
        'stock_minimo', 1,
        'activo', true,
        'requiere_receta', true,
        'controlado', true,
        'grupo_controlado', 'III',
        'visible_tienda', false
      ),
      5,
      null,
      v_cad,
      null,
      null::bigint
    ) f;
    raise notice 'Tramadol/Paracetamol Pharmalife creado id % lote % (5 cajas, cad %)', v_pid, v_lid, v_cad;
  elsif exists (
    select 1 from public.lotes l
    where l.producto_id = v_pid
      and l.fecha_caducidad = v_cad
      and coalesce(l.activo, true)
      and coalesce(l.cantidad_actual, 0) > 0
  ) then
    raise notice 'Tramadol/Paracetamol Pharmalife ya existe (id %) con caducidad %; no se duplican las 5 cajas.', v_pid, v_cad;
  else
    select f.lote_id into v_lid
    from public.receive_merchandise_lote(
      v_pid, 5, null, v_cad, null, 'mostrador', null::bigint
    ) f;
    raise notice 'Tramadol/Paracetamol Pharmalife ya existía id %; se recibieron 5 cajas lote % cad %', v_pid, v_lid, v_cad;
  end if;

  update public.productos set
    nombre = 'Tramadol / Paracetamol 37.5 mg / 325 mg',
    sku = case when sku is null or btrim(sku) = '' then v_sku else sku end,
    codigo_barras = v_ean,
    marca = 'Pharmalife',
    presentacion = 'Caja con 20 tabletas',
    concentracion = '37.5 mg / 325 mg',
    principio_activo = 'Tramadol / Paracetamol',
    forma_farmaceutica = 'Tabletas',
    categoria = 'Analgésico',
    subcategoria = 'Analgésico oral',
    laboratorio = 'Laboratorios PiSA',
    tipo = 'generico',
    requiere_receta = true,
    controlado = true,
    grupo_controlado = 'III',
    visible_tienda = false,
    activo = true,
    imagen_url = coalesce(nullif(btrim(imagen_url), ''), v_foto)
  where id = v_pid;
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
  p.laboratorio,
  p.categoria,
  p.costo,
  p.precio,
  p.stock,
  p.requiere_receta,
  p.controlado,
  p.grupo_controlado,
  p.visible_tienda,
  p.imagen_url,
  l.numero_lote,
  l.fecha_caducidad,
  l.cantidad_actual
from public.productos p
left join public.lotes l on l.producto_id = p.id and coalesce(l.activo, true) = true
where p.codigo_barras = '7501125190384'
   or p.sku = 'FC-25190384'
order by p.id desc, l.id desc
limit 5;
