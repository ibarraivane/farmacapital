-- ============================================================================
-- FARMA CAPITAL — Vendas físicas mostrador (fotos 25-sep-2026)
--
-- 1) Venda-stick Codifarma 7.5 cm × 4.5 m (auto-adherente)
--    Rojo  7506484500140 → FC-84500140 (alta nueva; el IFC 83552 es 2"/5 cm)
--    Piel  7506484500157 → enlaza FC-IFC-82912P (ticket IFC 123443 sin EAN)
--    Azul  7506484500164 → enlaza FC-IFC-82912A
--
-- 2) Quirmex venda elástica premium 7.5 cm × 5 m
--    EAN 7503003406730 → YA existe FC-34067301; corrige ficha (nombre era
--    solo «Quirmex», presentacion «5 CM» errónea, PA vaselina inventada).
--
-- 3) Dibar venda elástica 7.5 cm colores C/24
--    EAN 7501868950207 · lote 5C025C02 · fab MAR-2025 · cad MAR-2030
--    Enlaza FC-IFC-83733 (ticket IFC 125448 sin EAN). Venta por pieza.
--
-- Stock: 1 rollo c/u Venda-stick (físico). Quirmex no toca stock.
-- Dibar: recibe 1 paquete C/24 si aún no hay stock/lote.
-- Pegar TODO en Supabase → SQL Editor → Run.
-- ============================================================================

begin;

-- ---------------------------------------------------------------------------
-- Helper local: upsert Venda-stick por EAN (+ opcional SKU IFC sin EAN)
-- ---------------------------------------------------------------------------
do $$
declare
  r record;
  v_pid bigint;
  v_lid bigint;
  v_sku text;
  v_foto text;
begin
  for r in
    select * from (values
      (
        '7506484500140'::text,
        'FC-84500140'::text,
        null::text,
        'Venda-stick auto-adherente 7.5 cm × 4.5 m rojo'::text,
        'rojo'::text,
        45.00::numeric,
        72::numeric,
        'https://www.farmacapital.mx/catalogo-propia/venda-stick-rojo-7-5cm-7506484500140.jpg'::text
      ),
      (
        '7506484500157',
        'FC-84500157',
        'FC-IFC-82912P',
        'Venda-stick auto-adherente 7.5 cm × 4.5 m piel',
        'piel',
        45.00,
        72,
        'https://www.farmacapital.mx/catalogo-propia/venda-stick-piel-7-5cm-7506484500157.jpg'
      ),
      (
        '7506484500164',
        'FC-84500164',
        'FC-IFC-82912A',
        'Venda-stick auto-adherente 7.5 cm × 4.5 m azul',
        'azul',
        47.50,
        76,
        'https://www.farmacapital.mx/catalogo-propia/venda-stick-azul-7-5cm-7506484500164.jpg'
      )
    ) as t(ean, sku_ean, sku_ifc, nombre, color, costo, precio, foto)
  loop
    v_sku := r.sku_ean;
    if exists (
      select 1 from public.productos p
      where p.sku = v_sku
        and coalesce(p.codigo_barras, '') <> ''
        and coalesce(p.codigo_barras, '') <> r.ean
    ) then
      v_sku := 'FC-ND-' || right(r.ean, 8);
    end if;

    select p.id into v_pid
    from public.productos p
    where p.codigo_barras = r.ean
       or p.sku = v_sku
       or (r.sku_ifc is not null and p.sku = r.sku_ifc)
    order by case
      when p.codigo_barras = r.ean then 0
      when p.sku = v_sku then 1
      when r.sku_ifc is not null and p.sku = r.sku_ifc then 2
      else 3
    end, p.id
    limit 1;

    if v_pid is null then
      select f.producto_id, f.lote_id into v_pid, v_lid
      from public.create_producto_with_lote(
        jsonb_build_object(
          'nombre', r.nombre,
          'sku', v_sku,
          'codigo_barras', r.ean,
          'categoria', 'Botiquín',
          'tipo', 'marca',
          'descripcion', format(
            'Codifarma Venda-stick · cohesiva auto-adherente · 7.5 cm (3") × 4.5 m · color %s · EAN %s · foto mostrador 2026-09-25',
            r.color, r.ean
          ),
          'costo', r.costo,
          'precio', r.precio,
          'stock_minimo', 1,
          'activo', true,
          'requiere_receta', false
        ),
        1,
        'S/L',
        null::date,
        r.costo,
        null::bigint
      ) f;
      raise notice 'Venda-stick % creado id % lote %', r.color, v_pid, v_lid;
    else
      -- Producto ya existía (IFC sin EAN u otro): no inventar segundo stock si ya hay.
      if coalesce((select stock from public.productos where id = v_pid), 0) = 0
         and coalesce((select stock_unidades from public.productos where id = v_pid), 0) = 0
         and not exists (
           select 1 from public.lotes l
           where l.producto_id = v_pid and coalesce(l.cantidad_actual, 0) > 0
         )
      then
        select f.lote_id into v_lid
        from public.receive_merchandise_lote(
          v_pid, 1, 'S/L', null::date, r.costo, null, null::bigint
        ) f;
        raise notice 'Venda-stick % id %: se recibió 1 rollo (lote %)', r.color, v_pid, v_lid;
      else
        raise notice 'Venda-stick % ya existe id %; no se duplica stock', r.color, v_pid;
      end if;
    end if;

    update public.productos set
      codigo_barras = r.ean,
      sku = case
        when sku like 'FC-IFC-%' then sku  -- conserva SKU IFC si venía del ticket
        else coalesce(nullif(btrim(sku), ''), v_sku)
      end,
      nombre = r.nombre,
      marca = 'Venda-stick',
      presentacion = '7.5 cm × 4.5 m',
      concentracion = '7.5 cm',
      forma_farmaceutica = 'Venda cohesiva',
      categoria = 'Botiquín',
      subcategoria = 'Material de curación',
      tipo = 'marca',
      requiere_receta = false,
      costo = case when coalesce(costo, 0) <= 0.01 then r.costo else costo end,
      precio = case when coalesce(precio, 0) <= 0.01 then r.precio else precio end,
      imagen_url = coalesce(nullif(btrim(imagen_url), ''), r.foto),
      imagen_mobile_url = coalesce(nullif(btrim(imagen_mobile_url), ''), r.foto),
      activo = true,
      descripcion = coalesce(
        nullif(btrim(descripcion), ''),
        format('Codifarma Venda-stick · 7.5 cm × 4.5 m · %s · EAN %s', r.color, r.ean)
      )
    where id = v_pid;
  end loop;
end $$;

-- ---------------------------------------------------------------------------
-- Quirmex 7.5 cm × 5 m — solo ficha (ya está en inventario)
-- ---------------------------------------------------------------------------
update public.productos set
  nombre = 'Quirmex venda elástica premium 7.5 cm × 5 m',
  marca = 'Quirmex',
  presentacion = '7.5 cm × 5 m',
  concentracion = '7.5 cm',
  forma_farmaceutica = 'Venda elástica',
  categoria = 'Botiquín',
  subcategoria = 'Material de curación',
  tipo = 'marca',
  -- PA estaba mal (vaselina/lanolina no aplica a venda de algodón)
  principio_activo = case
    when principio_activo ilike '%vaselina%' or principio_activo ilike '%lanolina%'
      then null
    else principio_activo
  end,
  imagen_url = coalesce(
    nullif(btrim(imagen_url), ''),
    'https://www.farmacapital.mx/catalogo-propia/quirmex-venda-elastica-premium-7-5cm-7503003406730.jpg'
  ),
  imagen_mobile_url = coalesce(
    nullif(btrim(imagen_mobile_url), ''),
    'https://www.farmacapital.mx/catalogo-propia/quirmex-venda-elastica-premium-7-5cm-7503003406730.jpg'
  ),
  descripcion = coalesce(
    nullif(btrim(descripcion), ''),
    'Quirmex Premium · tejido plano 60% algodón 40% poliéster · 7.5 cm × 5 m estirada · EAN 7503003406730'
  )
where codigo_barras = '7503003406730'
   or sku = 'FC-34067301';

-- ---------------------------------------------------------------------------
-- Dibar colores C/24 — EAN de etiqueta + lote de caja + venta por pieza
-- ---------------------------------------------------------------------------
do $$
declare
  v_pid bigint;
  v_lid bigint;
  v_ean text := '7501868950207';
  v_foto text := 'https://www.farmacapital.mx/catalogo-propia/dibar-venda-elastica-7-5cm-colores-c24-7501868950207.jpg';
begin
  select p.id into v_pid
  from public.productos p
  where p.codigo_barras = v_ean
     or p.sku in ('FC-IFC-83733', 'FC-68950207')
  order by case
    when p.codigo_barras = v_ean then 0
    when p.sku = 'FC-IFC-83733' then 1
    else 2
  end, p.id
  limit 1;

  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from public.create_producto_with_lote(
      jsonb_build_object(
        'nombre', 'Dibar venda elástica 7.5 cm colores C/24',
        'sku', 'FC-68950207',
        'codigo_barras', v_ean,
        'categoria', 'Botiquín',
        'tipo', 'marca',
        'descripcion', 'Ticket IFC 125448 / etiqueta · C/24 surtido · media compresión tejido plano · 60% algodón 40% poliéster · Reg. 2159C2015 SSA · lote 5C025C02',
        'costo', 318.00,
        'precio', 398,
        'stock_minimo', 1,
        'activo', true,
        'requiere_receta', false
      ),
      1,
      '5C025C02',
      '2030-03-31'::date,
      318.00,
      null::bigint
    ) f;
    raise notice 'Dibar colores C/24 creado id % lote %', v_pid, v_lid;
  else
    if not exists (
      select 1 from public.lotes l
      where l.producto_id = v_pid
        and l.numero_lote = '5C025C02'
        and coalesce(l.activo, true)
        and coalesce(l.cantidad_actual, 0) > 0
    ) and coalesce((select stock from public.productos where id = v_pid), 0) = 0
      and coalesce((select stock_unidades from public.productos where id = v_pid), 0) = 0
    then
      select f.lote_id into v_lid
      from public.receive_merchandise_lote(
        v_pid, 1, '5C025C02', '2030-03-31'::date, 318.00,
        null, null::bigint
      ) f;
      raise notice 'Dibar colores id %: recibido lote 5C025C02 (%)', v_pid, v_lid;
    else
      -- Asegura caducidad en lote si ya estaba
      update public.lotes set
        fecha_caducidad = coalesce(fecha_caducidad, '2030-03-31'::date)
      where producto_id = v_pid
        and numero_lote = '5C025C02'
        and fecha_caducidad is null;
      raise notice 'Dibar colores ya existe id %; no se duplica stock', v_pid;
    end if;
  end if;

  update public.productos set
    codigo_barras = v_ean,
    nombre = 'Dibar venda elástica 7.5 cm colores C/24',
    marca = 'Dibar',
    presentacion = 'Paquete C/24',
    concentracion = '7.5 cm',
    forma_farmaceutica = 'Venda elástica',
    categoria = 'Botiquín',
    subcategoria = 'Material de curación',
    tipo = 'marca',
    requiere_receta = false,
    venta_unidad = true,
    unidades_por_caja = 24,
    precio_unidad = 20,  -- sugerido: ceil(costo/24×1.5)≈20; caja $398
    costo = case when coalesce(costo, 0) <= 0.01 then 318.00 else costo end,
    precio = case when coalesce(precio, 0) <= 0.01 then 398 else precio end,
    imagen_url = coalesce(nullif(btrim(imagen_url), ''), v_foto),
    imagen_mobile_url = coalesce(nullif(btrim(imagen_mobile_url), ''), v_foto),
    activo = true,
    descripcion = 'Dibar · 7.5 cm colores surtido C/24 · media compresión · 60% algodón 40% poliéster · Reg. 2159C2015 SSA · EAN 7501868950207 · lote 5C025C02 · cad 2030-03'
  where id = v_pid;
end $$;

commit;

select
  p.sku,
  p.codigo_barras as ean,
  left(p.nombre, 56) as nombre,
  p.marca,
  p.presentacion,
  p.costo,
  p.precio,
  p.precio_unidad,
  p.venta_unidad,
  p.unidades_por_caja,
  p.stock,
  p.stock_unidades,
  left(coalesce(p.imagen_url, ''), 70) as foto,
  l.numero_lote,
  l.fecha_caducidad,
  l.cantidad_actual
from public.productos p
left join public.lotes l
  on l.producto_id = p.id
 and coalesce(l.activo, true)
where p.codigo_barras in (
    '7506484500140', '7506484500157', '7506484500164',
    '7503003406730', '7501868950207'
  )
   or p.sku in (
    'FC-84500140', 'FC-84500157', 'FC-84500164',
    'FC-IFC-82912P', 'FC-IFC-82912A', 'FC-IFC-83733',
    'FC-68950207', 'FC-34067301'
  )
order by p.sku, l.id;
