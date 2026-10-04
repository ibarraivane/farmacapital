-- ============================================================================
-- FARMACAPITAL — Bepanthen pomada protectora contra rozaduras 100 g
-- EAN caja (foto): 7501008427330 · Bayer / Bepanthen · Dexpanthenol 5%
--
-- Ticket Farmalive 9861 (y FL-080826):
--   BEPANTHEN POMADA 100 GR · lista $134.50 · desc 2% → costo neto $131.81
-- Stock mostrador: 2 cajas. PVP dueño $203.
--   margen sobre venta ≈ 35.1% · recargo sobre costo ≈ 54%
--   (piso marca +25% al costo sería ~$165; se respeta el PVP pedido).
--
-- NO confundir con:
--   7501008427347 Bepanthen pomada 30 g (histórico pegó mal FC-08427330)
--   7501008498798 Bepanthen Multiusos 30 g (FC-08498798)
--
-- SKU: FC-08427330 (últimos 8 del EAN).
-- Si ese SKU ya pertenece a otro EAN → FC-ND-08427330.
-- Sin lote/caducidad en foto: lote S/L, caducidad NULL (no inventar).
-- Pegar TODO en Supabase → SQL Editor → Run.
-- Foto: tras deploy → patch_foto_bepanthen_pomada_100g_7501008427330.sql
-- ============================================================================

begin;

do $$
declare
  v_pid bigint;
  v_lid bigint;
  v_sku text := 'FC-08427330';
  v_ean text := '7501008427330';
  v_costo numeric := 131.81;
  v_precio numeric := 203;
  v_qty integer := 2;
  v_lote text := 'S/L';
begin
  select p.id into v_pid
  from public.productos p
  where p.codigo_barras = v_ean
  order by p.id
  limit 1;

  if v_pid is null then
    if exists (
      select 1 from public.productos p
      where p.sku = v_sku
        and coalesce(p.codigo_barras, '') <> v_ean
    ) then
      v_sku := 'FC-ND-08427330';
    end if;

    select f.producto_id, f.lote_id into v_pid, v_lid
    from public.create_producto_with_lote(
      jsonb_build_object(
        'nombre', 'Bepanthen',
        'sku', v_sku,
        'codigo_barras', v_ean,
        'categoria', 'Cuidado personal',
        'tipo', 'marca',
        'descripcion', 'Bepanthen pomada protectora contra rozaduras · Dexpanthenol 5% cutánea · caja con tubo 100 g · Bayer · EAN 7501008427330 · ticket Farmalive costo neto $131.81 (lista $134.50 −2%) · PVP $203 · 2 cajas mostrador',
        'costo', v_costo,
        'precio', v_precio,
        'stock_minimo', 1,
        'activo', true,
        'requiere_receta', false
      ),
      v_qty,
      v_lote,
      null::date,
      v_costo,
      null::bigint
    ) f;
    raise notice 'Bepanthen 100 g creado id % sku % lote %', v_pid, v_sku, v_lid;
  else
    if exists (
      select 1 from public.lotes l
      where l.producto_id = v_pid
        and l.numero_lote = v_lote
        and coalesce(l.activo, true)
        and coalesce(l.cantidad_actual, 0) >= v_qty
    ) then
      raise notice 'Bepanthen 100 g ya existe (id %) con lote S/L ≥2; no se vuelve a recibir.', v_pid;
    elsif exists (
      select 1 from public.lotes l
      where l.producto_id = v_pid
        and l.numero_lote = v_lote
        and coalesce(l.activo, true)
    ) then
      update public.lotes l
      set
        cantidad_actual = v_qty,
        cantidad_inicial = greatest(coalesce(l.cantidad_inicial, 0), v_qty),
        costo_unitario = coalesce(l.costo_unitario, v_costo)
      where l.producto_id = v_pid
        and l.numero_lote = v_lote
        and coalesce(l.activo, true);
      update public.productos
      set stock = (
        select coalesce(sum(cantidad_actual), 0)
        from public.lotes
        where producto_id = v_pid and coalesce(activo, true)
      )
      where id = v_pid;
      raise notice 'Bepanthen 100 g id %: lote S/L ajustado a % pzas', v_pid, v_qty;
    else
      select f.lote_id into v_lid
      from public.receive_merchandise_lote(
        v_pid, v_qty, v_lote, null::date, v_costo,
        null, null::bigint
      ) f;
      raise notice 'Bepanthen 100 g ya existía id %; se recibió lote % (% pzas)', v_pid, v_lid, v_qty;
    end if;
  end if;

  update public.productos set
    nombre = 'Bepanthen',
    marca = 'Bepanthen',
    laboratorio = coalesce(nullif(btrim(laboratorio), ''), 'Bayer'),
    presentacion = 'Caja con tubo 100 g',
    forma_farmaceutica = 'Pomada',
    principio_activo = 'Dexpanthenol',
    concentracion = '5%',
    subcategoria = 'Pomada protectora / rozaduras',
    categoria = 'Cuidado personal',
    tipo = 'marca',
    requiere_receta = false,
    codigo_barras = v_ean,
    costo = v_costo,
    precio = v_precio,
    stock_minimo = greatest(coalesce(stock_minimo, 0), 1),
    activo = true,
    imagen_url = coalesce(
      nullif(btrim(imagen_url), ''),
      'https://www.farmacapital.mx/catalogo-propia/bepanthen-pomada-100g-7501008427330.jpg'
    )
  where id = v_pid;
end $$;

commit;

select
  p.id,
  p.sku,
  p.codigo_barras as ean,
  p.nombre,
  p.marca,
  p.laboratorio,
  p.presentacion,
  p.forma_farmaceutica,
  p.principio_activo,
  p.concentracion,
  p.categoria,
  p.costo,
  p.precio,
  round((p.precio - p.costo) / nullif(p.precio, 0) * 100, 1) as margen_pct,
  round((p.precio / nullif(p.costo, 0) - 1) * 100, 1) as recargo_pct,
  p.stock,
  left(coalesce(p.imagen_url, ''), 100) as imagen,
  l.numero_lote,
  l.fecha_caducidad,
  l.cantidad_actual
from public.productos p
left join public.lotes l
  on l.producto_id = p.id and coalesce(l.activo, true) = true
where p.codigo_barras in ('7501008427330', '7501008427347', '7501008498798')
   or p.sku in ('FC-08427330', 'FC-ND-08427330', 'FC-08498798', 'FC-08427347')
order by p.codigo_barras, p.sku, l.fecha_caducidad nulls last;
