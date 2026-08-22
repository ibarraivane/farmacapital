-- Cubrebocas tricapa desechable C/100
-- Codigo INTERNO (sticker, prefijo 20). No inventar un 750… de GS1.
--   EAN-13  2008500100013
--   SKU     FC-00100013     cola de 8 del EAN
-- Pegar etiqueta en la caja. Si la caja YA trae EAN de fabrica, no uses este.
--
-- 1 caja comprada. Se vende por pieza (como guantes / curitas).
-- Costo caja supuesto $80 → PVP caja ceil(80*1.6) = $128 · pieza $6.
-- Ajusta costo/precio si pagaron otro monto. No hay caducidad en la caja: lote sin fecha.
-- INSERT ONLY. Ejecutar en Supabase SQL Editor (archivo completo).

begin;

do $$
declare
  v_pid bigint;
  v_lid bigint;
begin
  if exists (
    select 1 from public.productos p
    where p.codigo_barras = '2008500100013'
       or p.sku = 'FC-00100013'
       or p.nombre ilike '%cubrebocas%c/100%'
  ) then
    raise notice 'Cubrebocas C/100 ya existe; no se inserta (INSERT ONLY).';
    return;
  end if;

  select f.producto_id, f.lote_id into v_pid, v_lid
  from public.create_producto_with_lote(
    jsonb_build_object(
      'nombre', 'Cubrebocas tricapa desechable C/100',
      'sku', 'FC-00100013',
      'codigo_barras', '2008500100013',
      'categoria', 'Dispositivo médico',
      'tipo', 'generico',
      'descripcion', 'Caja C/100 · venta por pieza · codigo INTERNO 2008500100013 (prefijo 20, sticker). Sin EAN de fabrica.',
      'costo', 80,
      'precio', 128,
      'stock_minimo', 1,
      'activo', true,
      'requiere_receta', false
    ),
    1,
    'S/L',
    null::date,
    80,
    null::bigint
  ) f;

  update public.productos set
    presentacion = 'Caja C/100',
    forma_farmaceutica = 'Cubrebocas',
    subcategoria = 'Protección',
    venta_unidad = true,
    unidades_por_caja = 100,
    precio_unidad = 6,
    stock_unidades = 0,
    requiere_receta = false
  where id = v_pid;

  raise notice 'Cubrebocas C/100 creado id % lote %', v_pid, v_lid;
end $$;

commit;

select
  p.id,
  p.sku,
  p.nombre,
  p.codigo_barras,
  p.categoria,
  p.presentacion,
  p.costo,
  p.precio,
  p.precio_unidad,
  p.venta_unidad,
  p.unidades_por_caja,
  p.stock,
  l.numero_lote,
  l.fecha_caducidad,
  l.cantidad_actual
from public.productos p
left join public.lotes l
  on l.producto_id = p.id
 and coalesce(l.activo, true) = true
where p.sku = 'FC-00100013'
   or p.codigo_barras = '2008500100013';
