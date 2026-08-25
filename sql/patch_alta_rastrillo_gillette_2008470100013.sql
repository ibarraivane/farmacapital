-- Gillette Prestobarba 3 rastrillo desechable 1 pza
-- Codigo de barras INTERNO (no es GTIN de P&G):
--   EAN-13  2008470100013   prefijo 20 = uso en tienda / sticker propio
--   SKU     FC-70100013     cola de 8 del EAN (mismo criterio que el resto)
--
-- No hay rastrillo Gillette en catalogo. El empaque suelto casi nunca
-- trae EAN escaneable; no se inventa un 750... de GS1 Mexico.
-- Si el paquete SI tiene codigo de fabrica, sustituye codigo_barras
-- y no uses este interno.
--
-- Costo de referencia ~$16 (mayorista Prestobarba UltraGrip / pza).
-- Precio = ceil(16 * 1.6) = $26. Ajusta si es Mach3 / Venus / tira.
-- Stock inicial 1 para poder venderlo; corrige cantidad en Lotes.
-- INSERT ONLY. Ejecutar en Supabase SQL Editor (archivo completo).

begin;

do $$
declare
  v_pid bigint;
  v_lid bigint;
begin
  if exists (
    select 1 from public.productos p
    where p.codigo_barras = '2008470100013'
       or p.sku = 'FC-70100013'
       or (
         p.nombre ilike '%gillette%'
         and p.nombre ilike '%rastrillo%'
       )
       or (
         p.nombre ilike '%prestobarba%'
         and p.nombre ilike '%1 pza%'
       )
  ) then
    raise notice 'Rastrillo Gillette ya existe; no se inserta (INSERT ONLY).';
    return;
  end if;

  select f.producto_id, f.lote_id into v_pid, v_lid
  from public.create_producto_with_lote(
    jsonb_build_object(
      'nombre', 'Gillette Prestobarba 3 rastrillo desechable 1 pza',
      'sku', 'FC-70100013',
      'codigo_barras', '2008470100013',
      'categoria', 'Cuidado personal',
      'tipo', 'marca',
      'descripcion', 'Codigo interno FarmaCapital 2008470100013 (prefijo 20, no GTIN P&G). Pegar sticker. Distinto de tiras / Mach3 / Venus.',
      'costo', 16,
      'precio', 26,
      'stock_minimo', 2,
      'activo', true,
      'requiere_receta', false
    ),
    1,
    'S/L',
    null::date,
    16,
    null::bigint
  ) f;

  update public.productos set
    marca = 'Gillette',
    presentacion = '1 pieza desechable 3 hojas',
    forma_farmaceutica = 'Rastrillo',
    subcategoria = 'Afeitado',
    requiere_receta = false
  where id = v_pid;

  raise notice 'Rastrillo Gillette creado id % lote %', v_pid, v_lid;
end $$;

commit;

select
  p.id,
  p.sku,
  p.nombre,
  p.codigo_barras,
  p.categoria,
  p.marca,
  p.presentacion,
  p.costo,
  p.precio,
  p.stock,
  l.numero_lote,
  l.fecha_caducidad,
  l.cantidad_actual
from public.productos p
left join public.lotes l on l.producto_id = p.id and coalesce(l.activo, true) = true
where p.sku = 'FC-70100013'
   or p.codigo_barras = '2008470100013'
order by p.id desc
limit 3;
