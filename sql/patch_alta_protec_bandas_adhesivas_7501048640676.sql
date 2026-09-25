-- ============================================================================
-- FARMA CAPITAL — Alta mostrador: Protec bandas adhesivas 22 mm C/100
--
-- EAN-13 caja: 7501048640676
-- SKU: FC-48640676 (últimos 8 del EAN)
-- Ref. Degasa / caja: 0503500-R01 · lote 503500048 · fab 2026-03 · cad 2029-03
--
-- Ficha de la caja (no del PDF): Protec · Bandas adhesivas · tela elástica ·
-- 22 mm · color piel · hipoalergénico · libre de látex · C/100.
-- Distinto de FC-89975530 (bajo pedido Ewafra 503500, sin EAN).
--
-- Venta por pieza (como curitas / cubrebocas / agujas).
-- Costo ancla Ewafra $41.67/caja · marca +25% → PVP caja $53.
-- Pieza: $1 (ya vendieron una). Costo/pza ~$0.42 → margen ok.
--   (La regla POS de pieza suelta sugeriría ~$6; el dueño fija $1.)
-- Retail caja ~$34–$72 (Prixz/Vitau/Medart).
--
-- Stock: 1 caja física ya abierta (−1 vendida fuera del sistema) → 99 piezas.
-- Ejecutar en Supabase SQL Editor (archivo completo).
-- Foto: public/catalogo-propia/protec-bandas-adhesivas-22mm-c100-7501048640676.jpg
--       (URL activa tras deploy)
-- ============================================================================

begin;

do $$
declare
  v_pid bigint;
  v_lid bigint;
  v_sku text := 'FC-48640676';
  v_ean text := '7501048640676';
  v_foto text := 'https://www.farmacapital.mx/catalogo-propia/protec-bandas-adhesivas-22mm-c100-7501048640676.jpg';
begin
  if exists (
    select 1 from public.productos p
    where p.sku = v_sku
      and coalesce(p.codigo_barras, '') <> ''
      and coalesce(p.codigo_barras, '') <> v_ean
  ) then
    v_sku := 'FC-ND-48640676';
  end if;

  select p.id into v_pid
  from public.productos p
  where p.codigo_barras = v_ean
     or p.sku in ('FC-48640676', 'FC-ND-48640676')
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
        'nombre', 'Protec bandas adhesivas tela elástica 22 mm',
        'sku', v_sku,
        'codigo_barras', v_ean,
        'categoria', 'Botiquín',
        'tipo', 'marca',
        'descripcion', 'Caja C/100 · venta por pieza · circular 22 mm · color piel · libre de látex · Degasa · EAN 7501048640676 · lote 503500048 · cad 2029-03',
        'costo', 41.67,
        'precio', 53,
        'stock_minimo', 1,
        'activo', true,
        'requiere_receta', false
      ),
      1,
      '503500048',
      '2029-03-31'::date,
      41.67,
      null::bigint
    ) f;
    raise notice 'Protec bandas adhesivas creado id % lote % (1 caja)', v_pid, v_lid;
  else
    if not exists (
      select 1 from public.lotes l
      where l.producto_id = v_pid
        and l.numero_lote = '503500048'
        and coalesce(l.activo, true)
    ) and coalesce((select stock from public.productos where id = v_pid), 0) = 0
      and coalesce((select stock_unidades from public.productos where id = v_pid), 0) = 0
    then
      select f.lote_id into v_lid
      from public.receive_merchandise_lote(
        v_pid, 1, '503500048', '2029-03-31'::date, 41.67,
        null, null::bigint
      ) f;
      raise notice 'Protec ya existía id %; se recibió lote % (1 caja)', v_pid, v_lid;
    else
      raise notice 'Protec ya existe id %; no se duplica stock/lote', v_pid;
    end if;
  end if;

  update public.productos set
    codigo_barras = coalesce(nullif(codigo_barras, ''), v_ean),
    nombre = 'Protec bandas adhesivas tela elástica 22 mm',
    marca = 'Protec',
    presentacion = 'Caja C/100',
    concentracion = '22 mm',
    forma_farmaceutica = 'Apósito adhesivo',
    categoria = 'Botiquín',
    subcategoria = 'Material de curación',
    tipo = 'marca',
    requiere_receta = false,
    venta_unidad = true,
    unidades_por_caja = 100,
    precio_unidad = 1,
    costo = case when coalesce(costo, 0) <= 0.01 then 41.67 else costo end,
    precio = case when coalesce(precio, 0) <= 0.01 then 53 else precio end,
    imagen_url = coalesce(nullif(btrim(imagen_url), ''), v_foto),
    imagen_mobile_url = coalesce(nullif(btrim(imagen_mobile_url), ''), v_foto),
    activo = true
  where id = v_pid;

  -- Venta por pieza exige stock_unidades. Sin esto el POS dice
  -- «piezas sueltas insuficientes» aunque haya 1 caja C/100.
  -- Caja ya abierta en mostrador: −1 vendida fuera del sistema → 99 sueltas.
  if coalesce((select stock_unidades from public.productos where id = v_pid), 0) = 0 then
    if exists (
      select 1 from public.lotes l
      where l.producto_id = v_pid
        and coalesce(l.activo, true)
        and coalesce(l.cantidad_actual, 0) >= 1
    ) then
      update public.lotes set
        cantidad_actual = greatest(0, coalesce(cantidad_actual, 0) - 1),
        activo = case
          when greatest(0, coalesce(cantidad_actual, 0) - 1) <= 0 then false
          else activo
        end
      where id = (
        select l.id from public.lotes l
        where l.producto_id = v_pid
          and coalesce(l.activo, true)
          and coalesce(l.cantidad_actual, 0) >= 1
        order by case when l.numero_lote = '503500048' then 0 else 1 end,
                 l.fecha_caducidad nulls first, l.id
        limit 1
      );
    end if;

    update public.productos set
      stock = (
        select coalesce(sum(l.cantidad_actual), 0)::integer
        from public.lotes l
        where l.producto_id = v_pid
          and coalesce(l.activo, true)
      ),
      stock_unidades = 99
    where id = v_pid;

    raise notice 'Caja abierta: stock_unidades=99 (100−1 vendida fuera del sistema)';
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
  p.concentracion,
  p.forma_farmaceutica,
  p.categoria,
  p.subcategoria,
  p.costo,
  p.precio,
  p.precio_unidad,
  p.venta_unidad,
  p.unidades_por_caja,
  p.stock,
  p.stock_unidades,
  left(p.imagen_url, 90) as foto,
  l.numero_lote,
  l.fecha_caducidad,
  l.cantidad_actual as cajas_en_lote,
  l.activo as lote_activo
from public.productos p
left join public.lotes l
  on l.producto_id = p.id
where p.codigo_barras = '7501048640676'
   or p.sku in ('FC-48640676', 'FC-ND-48640676')
order by p.id, l.id;
