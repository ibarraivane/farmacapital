-- Affective Cover Pro protector desechable unitalla C/16
-- UPC empaque (fotos): 0 13117 00134 1  →  013117001341
-- EAN-13 equivalente: 0013117001341 (el POS empareja 12 vs 13 con 0)
-- SKU: FC-11700134 (cola de 8 del UPC)
--
-- No es pañal Diapro (FC-43475014 / FC-16800803). Es salvacama Ontex/Affective.
-- Walmart.mx ~$146. Superaki mayorista $113 (2 pzas $101, 3 pzas $96.50).
-- No se usa ceil(costo*1.6)=$181: queda $35 arriba de Walmart y no se vende.
-- PVP $145 (1 peso bajo Walmart). Margen ~22% como Diapro Grande.
-- Si el paquete se compró EN Walmart, cambia costo a 146 y no restockees ahí.
--
-- INSERT ONLY. Ejecutar en Supabase SQL Editor (archivo completo).

begin;

do $$
declare
  v_pid bigint;
  v_lid bigint;
begin
  if exists (
    select 1 from public.productos p
    where p.codigo_barras in ('013117001341', '0013117001341', '13117001341')
       or p.sku = 'FC-11700134'
       or (
         p.nombre ilike '%affective%'
         and p.nombre ilike '%cover pro%'
       )
  ) then
    raise notice 'Affective Cover Pro C/16 ya existe; no se inserta (INSERT ONLY).';
    return;
  end if;

  select f.producto_id, f.lote_id into v_pid, v_lid
  from public.create_producto_with_lote(
    jsonb_build_object(
      'nombre', 'Affective Cover Pro protector desechable unitalla C/16',
      'sku', 'FC-11700134',
      'codigo_barras', '013117001341',
      'categoria', 'Higiene',
      'tipo', 'marca',
      'descripcion', 'Salvacama Ontex/Affective 90x60 cm C/16 · UPC 013117001341 · incontinencia moderada/severa · unisex. Ref. Walmart $146 · costo Superaki $113.',
      'costo', 113,
      'precio', 145,
      'stock_minimo', 1,
      'activo', true,
      'requiere_receta', false
    ),
    1,
    'S/L',
    null::date,
    113,
    null::bigint
  ) f;

  update public.productos set
    marca = 'Affective',
    presentacion = 'Bolsa con 16 protectores 90 x 60 cm',
    forma_farmaceutica = 'Protector desechable',
    subcategoria = 'Incontinencia',
    requiere_receta = false
  where id = v_pid;

  raise notice 'Affective Cover Pro C/16 creado id % lote %', v_pid, v_lid;
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
  round((p.precio - p.costo) / nullif(p.precio, 0) * 100, 1) as margen_pct,
  p.stock,
  l.numero_lote,
  l.cantidad_actual
from public.productos p
left join public.lotes l on l.producto_id = p.id and coalesce(l.activo, true) = true
where p.sku = 'FC-11700134'
   or p.codigo_barras in ('013117001341', '0013117001341')
order by p.id desc
limit 3;
