-- ============================================================================
-- FARMA CAPITAL — Alta foto mostrador 2026-11-01
--
-- 1) Arabela cepillo y peine para cejas
--    Empaque: «(I) ARABELA CEPILLO Y PEINE PARA CEJAS» · CLAVE K199B
--    Sin EAN en bolsa → SKU FC-48519024 (reloj; no inventar letras)
--    2 pzas · costo $7 · PVP $15 (precio dueño; no fórmula +25/+60)
--
-- 2) Huggies Gold shampoo Manzanilla y Miel 200 ml
--    EAN 7501943417434 · SKU FC-43417434
--    1 pza · costo $30 · PVP $50 (precio dueño)
--
-- Sin inventar caducidad (lote S/L, fecha null).
-- Fotos en public/catalogo-propia/ (van con el deploy).
-- INSERT ONLY. Pegar TODO en Supabase → SQL Editor → Run (tras merge/deploy
-- para que las URLs de foto respondan; el alta de filas no depende del CDN).
-- ============================================================================

begin;

do $$
declare
  v_pid bigint;
  v_lid bigint;
  v_url_arabela text :=
    'https://www.farmacapital.mx/catalogo-propia/arabela-cepillo-peine-cejas-k199b.jpg';
  v_url_huggies text :=
    'https://www.farmacapital.mx/catalogo-propia/huggies-gold-shampoo-manzanilla-miel-200ml-7501943417434.jpg';
begin
  -- ── Arabela cepillo y peine para cejas ───────────────────────────────
  if exists (
    select 1 from public.productos p
    where p.sku = 'FC-48519024'
       or (
         p.marca ilike 'arabela'
         and p.nombre ilike '%peine%cejas%'
       )
       or (
         p.nombre ilike '%arabela%'
         and p.nombre ilike '%peine%cejas%'
       )
  ) then
    raise notice 'Arabela cepillo/peine cejas ya existe; no se inserta.';
  else
    select f.producto_id, f.lote_id into v_pid, v_lid
    from public.create_producto_with_lote(
      jsonb_build_object(
        'nombre', 'Cepillo y peine para cejas',
        'sku', 'FC-48519024',
        'codigo_barras', null,
        'categoria', 'Higiene',
        'tipo', 'marca',
        'descripcion',
          'Alta foto 2026-11-01 · Arabela cepillo y peine para cejas · CLAVE K199B · plástico y metal · 1 pieza · hecho en China · sin EAN en bolsa · compra 2×$7 · PVP $15',
        'costo', 7,
        'precio', 15,
        'stock_minimo', 1,
        'activo', true,
        'requiere_receta', false,
        'marca', 'Arabela',
        'presentacion', '1 pieza',
        'forma_farmaceutica', 'Cepillo'
      ),
      2,
      'S/L',
      null::date,
      7,
      null::bigint
    ) f;

    update public.productos set
      marca = 'Arabela',
      presentacion = '1 pieza',
      forma_farmaceutica = 'Cepillo',
      subcategoria = 'Cejas',
      laboratorio = 'Arabela',
      imagen_url = v_url_arabela,
      imagen_mobile_url = v_url_arabela,
      disponible = 'inmediato',
      visible_tienda = true,
      requiere_receta = false
    where id = v_pid;

    insert into public.producto_imagenes
      (producto_id, url, storage_path, posicion, es_principal, origen)
    select
      v_pid,
      v_url_arabela,
      'catalogo-propia/arabela-cepillo-peine-cejas-k199b.jpg',
      1,
      true,
      'propia'
    where not exists (
      select 1 from public.producto_imagenes i
      where i.producto_id = v_pid and i.url = v_url_arabela
    );

    raise notice 'Arabela peine cejas creado id % lote % stock 2 PVP 15', v_pid, v_lid;
  end if;

  -- ── Huggies Gold Manzanilla y Miel 200 ml ────────────────────────────
  if exists (
    select 1 from public.productos p
    where p.codigo_barras in ('7501943417434', '07501943417434')
       or p.sku in ('FC-43417434', 'FC-ND-43417434')
  ) then
    raise notice 'Huggies Gold 7501943417434 ya existe; no se inserta.';
  else
    select f.producto_id, f.lote_id into v_pid, v_lid
    from public.create_producto_with_lote(
      jsonb_build_object(
        'nombre', 'Huggies Gold Manzanilla y Miel',
        'sku', 'FC-43417434',
        'codigo_barras', '7501943417434',
        'categoria', 'Bebés',
        'tipo', 'marca',
        'descripcion',
          'Alta foto 2026-11-01 · Huggies Gold shampoo para bebé Manzanilla y Miel 200 ml · sin lágrimas · EAN 7501943417434 · Kimberly-Clark · compra $30 · PVP $50',
        'costo', 30,
        'precio', 50,
        'stock_minimo', 1,
        'activo', true,
        'requiere_receta', false,
        'marca', 'Huggies',
        'presentacion', '200 ml',
        'forma_farmaceutica', 'Shampoo'
      ),
      1,
      'S/L',
      null::date,
      30,
      null::bigint
    ) f;

    update public.productos set
      marca = 'Huggies',
      presentacion = '200 ml',
      forma_farmaceutica = 'Shampoo',
      subcategoria = 'Cuidado del bebé',
      laboratorio = 'Kimberly-Clark',
      imagen_url = v_url_huggies,
      imagen_mobile_url = v_url_huggies,
      disponible = 'inmediato',
      visible_tienda = true,
      requiere_receta = false
    where id = v_pid;

    insert into public.producto_imagenes
      (producto_id, url, storage_path, posicion, es_principal, origen)
    select
      v_pid,
      v_url_huggies,
      'catalogo-propia/huggies-gold-shampoo-manzanilla-miel-200ml-7501943417434.jpg',
      1,
      true,
      'propia'
    where not exists (
      select 1 from public.producto_imagenes i
      where i.producto_id = v_pid and i.url = v_url_huggies
    );

    raise notice 'Huggies Gold shampoo creado id % lote % stock 1 PVP 50', v_pid, v_lid;
  end if;
end $$;

commit;

select
  p.id,
  p.sku,
  p.codigo_barras as ean,
  p.nombre,
  p.marca,
  p.presentacion,
  p.forma_farmaceutica,
  p.subcategoria,
  p.categoria,
  p.tipo,
  p.costo,
  p.precio,
  round((p.precio - p.costo) / nullif(p.precio, 0) * 100, 1) as margen_pct,
  p.stock,
  left(p.imagen_url, 96) as foto,
  l.numero_lote,
  l.fecha_caducidad,
  l.cantidad_actual,
  l.costo_unitario
from public.productos p
left join public.lotes l
  on l.producto_id = p.id and coalesce(l.activo, true) = true
where p.sku in ('FC-48519024', 'FC-43417434', 'FC-ND-43417434')
   or p.codigo_barras = '7501943417434'
order by p.sku;
