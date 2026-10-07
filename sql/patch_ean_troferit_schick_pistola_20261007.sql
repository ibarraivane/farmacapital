-- ============================================================================
-- FARMACAPITAL — EAN pistola: Troferit + Schick (07-oct-2026)
--
-- 1) Troferit 30 mg C/15 (Cityfarma S329263)
--    Ticket tipografió 7501088576495 (checksum GS1 inválido).
--    Caja Chinoín / retailers: 7501088575495.
--    SKU se queda FC-88576495 (historial).
--
-- 2) Schick Xtreme 3 Piel Sensible bolsa/display ×12 (Grupo Zorro T01696085)
--    Ticket cargó 7502274881475; el empaque Edgewell escanea 6937266702079.
--    Par de alias. NO mezclar con pieza suelta 7591066701015.
--
-- 3) Alta idempotente de la pieza suelta 7591066701015 (si aún falta).
--
-- 4) fc_match_codigo_barras: pares nuevos para POS / Recibir en servidor.
--
-- ORDEN: 1) merge/deploy (JS EAN_PARES)  2) pegar este SQL en Supabase → Run.
-- SIN bloques $$. Pegar TODO.
-- ============================================================================

begin;

-- ── Troferit: EAN de la caja ───────────────────────────────────────────────
update public.productos
   set codigo_barras = null
 where codigo_barras = '7501088575495'
   and sku is distinct from 'FC-88576495';

update public.productos p
set
  codigo_barras = '7501088575495',
  marca = coalesce(nullif(btrim(p.marca), ''), 'Troferit'),
  laboratorio = coalesce(nullif(btrim(p.laboratorio), ''), 'Chinoin'),
  presentacion = coalesce(nullif(btrim(p.presentacion), ''), 'Caja con 15 tabletas'),
  concentracion = coalesce(nullif(btrim(p.concentracion), ''), '30 mg'),
  principio_activo = coalesce(nullif(btrim(p.principio_activo), ''), 'Dropropizina'),
  forma_farmaceutica = coalesce(nullif(btrim(p.forma_farmaceutica), ''), 'Tableta'),
  requiere_receta = true,
  activo = true,
  descripcion = case
    when p.descripcion ilike '%7501088575495%'
     and p.descripcion ilike '%7501088576495%' then p.descripcion
    when coalesce(btrim(p.descripcion), '') = '' then
      'Troferit 30 mg · Dropropizina · Chinoin · EAN caja 7501088575495 · tipógrafo ticket Cityfarma 7501088576495.'
    else
      btrim(p.descripcion) || ' EAN caja 7501088575495 · tipógrafo ticket 7501088576495.'
  end
where p.sku = 'FC-88576495'
   or p.codigo_barras in ('7501088576495', '7501088575495');

update public.recepcion_items i
set codigo_escaneado = '7501088575495'
from public.recepciones r
where i.recepcion_id = r.id
  and r.folio = 'S329263'
  and coalesce(r.proveedor, '') ilike '%cityfarma%'
  and i.codigo_escaneado = '7501088576495';

-- ── Schick bolsa/display ×12 ───────────────────────────────────────────────
update public.productos p
set
  nombre = case
    when p.nombre ilike '%piel sensible%' then p.nombre
    when p.nombre ilike '%schick%xtreme%' or p.nombre ilike '%schick%'
      then 'Schick Xtreme 3 Piel Sensible'
    else p.nombre
  end,
  marca = coalesce(nullif(btrim(p.marca), ''), 'Schick'),
  laboratorio = coalesce(nullif(btrim(p.laboratorio), ''), 'Edgewell'),
  presentacion = coalesce(nullif(btrim(p.presentacion), ''), 'Bolsa / display con 12 rastrillos'),
  forma_farmaceutica = coalesce(nullif(btrim(p.forma_farmaceutica), ''), 'Rastrillo'),
  categoria = coalesce(nullif(btrim(p.categoria), ''), 'Cuidado personal'),
  subcategoria = coalesce(nullif(btrim(p.subcategoria), ''), 'Afeitado'),
  tipo = 'marca',
  activo = true,
  -- Ojo: no meter el EAN de la pieza suelta en descripción; fc_buscar_producto_escaneo
  -- lo leería y el beep de 1 máquina abriría la bolsa ×12.
  descripcion = case
    when p.descripcion ilike '%6937266702079%'
     and p.descripcion ilike '%7502274881475%' then p.descripcion
    when coalesce(btrim(p.descripcion), '') = '' then
      'Schick Xtreme 3 Piel Sensible · bolsa/display 12 pzas · EAN bolsa ticket 7502274881475 · EAN display Edgewell 6937266702079 · no confundir con empaque individual.'
    else
      btrim(p.descripcion) || ' EAN bolsa ticket 7502274881475 · EAN display Edgewell 6937266702079 · no confundir con empaque individual.'
  end
where p.sku = 'FC-274881475'
   or p.codigo_barras in ('7502274881475', '6937266702079');

-- Si alguien dio de alta el display como SKU aparte, quitarle el EAN (UNIQUE)
-- y dejar el canónico en FC-274881475.
update public.productos
   set codigo_barras = null
 where codigo_barras = '6937266702079'
   and sku is distinct from 'FC-274881475';

-- codigo_barras canónico: el del ticket Zorro (historial). Display va por alias.
update public.productos
set codigo_barras = '7502274881475'
where sku = 'FC-274881475'
  and coalesce(nullif(btrim(codigo_barras), ''), '') in ('', '6937266702079');

-- ── Pieza suelta Schick (si aún no está) ───────────────────────────────────
insert into public.productos (
  nombre, sku, codigo_barras, categoria, subcategoria, tipo, descripcion,
  marca, presentacion, forma_farmaceutica, laboratorio,
  costo, precio, imagen_url, imagen_mobile_url,
  stock, stock_minimo, activo, requiere_receta
)
select
  'Schick Xtreme 3 Piel Sensible',
  case
    when exists (
      select 1 from public.productos p
      where p.sku = 'FC-66701015'
        and coalesce(p.codigo_barras, '') <> '7591066701015'
    ) then 'FC-ND-66701015'
    else 'FC-66701015'
  end,
  '7591066701015',
  'Higiene',
  'Afeitado',
  'marca',
  'Schick Xtreme 3 Piel Sensible · 3 hojas flexibles · empaque individual 1 máquina · Edgewell · EAN 7591066701015 · PVP $23 · sin costo de compra',
  'Schick',
  '1 máquina',
  'Rastrillo',
  'EDGEWELL',
  null,
  23,
  'https://www.farmacapital.mx/catalogo-propia/schick-xtreme3-piel-sensible-1pza-7591066701015.jpg',
  'https://www.farmacapital.mx/catalogo-propia/schick-xtreme3-piel-sensible-1pza-7591066701015.jpg',
  0,
  2,
  true,
  false
where public.fc_buscar_producto_escaneo('7591066701015') is null
  and public.fc_buscar_producto_escaneo('FC-66701015') is null
  and not exists (
    select 1 from public.productos p
    where p.codigo_barras = '7591066701015'
       or p.sku in ('FC-66701015', 'FC-ND-66701015')
  );

update public.productos p
set
  nombre = 'Schick Xtreme 3 Piel Sensible',
  marca = 'Schick',
  presentacion = coalesce(nullif(btrim(p.presentacion), ''), '1 máquina'),
  forma_farmaceutica = coalesce(nullif(btrim(p.forma_farmaceutica), ''), 'Rastrillo'),
  categoria = coalesce(nullif(btrim(p.categoria), ''), 'Higiene'),
  subcategoria = coalesce(nullif(btrim(p.subcategoria), ''), 'Afeitado'),
  tipo = 'marca',
  laboratorio = coalesce(nullif(btrim(p.laboratorio), ''), 'EDGEWELL'),
  requiere_receta = false,
  activo = true,
  codigo_barras = '7591066701015',
  precio = case when coalesce(p.precio, 0) <= 1 then 23 else p.precio end,
  imagen_url = coalesce(nullif(btrim(p.imagen_url), ''),
    'https://www.farmacapital.mx/catalogo-propia/schick-xtreme3-piel-sensible-1pza-7591066701015.jpg'),
  imagen_mobile_url = coalesce(nullif(btrim(p.imagen_mobile_url), ''),
    'https://www.farmacapital.mx/catalogo-propia/schick-xtreme3-piel-sensible-1pza-7591066701015.jpg')
where p.codigo_barras = '7591066701015'
   or p.sku in ('FC-66701015', 'FC-ND-66701015');

-- ── Match pistola (servidor) ───────────────────────────────────────────────
create or replace function public.fc_match_codigo_barras(p_scan text, p_stored text)
returns boolean
language sql
immutable
parallel safe
as $$
  with n as (
    select
      regexp_replace(coalesce(p_scan, ''), '\D', '', 'g') as scan,
      regexp_replace(coalesce(p_stored, ''), '\D', '', 'g') as stored
  )
  select
    case
      when n.scan = '' or n.stored = '' then false
      when n.scan = n.stored then true
      when length(n.scan) >= 12 and length(n.stored) >= 12
        and right(n.scan, 12) = right(n.stored, 12) then true
      when length(n.scan) = 12 and length(n.stored) = 13
        and n.stored = '0' || n.scan then true
      when length(n.stored) = 12 and length(n.scan) = 13
        and n.scan = '0' || n.stored then true
      when length(n.scan) >= 8 and length(n.stored) = length(n.scan) + 1
        and n.stored like n.scan || '_' then true
      when length(n.stored) >= 8 and length(n.scan) = length(n.stored) + 1
        and n.scan like n.stored || '_' then true
      when length(n.scan) = 13 and length(n.stored) = 12
        and n.scan like '6502400%' and n.stored like '650240%'
        and substring(n.scan from 8) = substring(n.stored from 7) then true
      when length(n.stored) = 13 and length(n.scan) = 12
        and n.stored like '6502400%' and n.scan like '650240%'
        and substring(n.stored from 8) = substring(n.scan from 7) then true
      when n.scan in ('7501868900233', '7501868990023')
       and n.stored in ('7501868900233', '7501868990023') then true
      when n.scan in ('747589705123', '714706903205')
       and n.stored in ('747589705123', '714706903205') then true
      when n.scan in ('650240079009', '6502400079009', '6502400070009')
       and n.stored in ('650240079009', '6502400079009', '6502400070009') then true
      when n.scan in ('650240078996', '6502400078996')
       and n.stored in ('650240078996', '6502400078996') then true
      when n.scan in ('7501088575495', '7501088576495')
       and n.stored in ('7501088575495', '7501088576495') then true
      when n.scan in ('7502274881475', '6937266702079')
       and n.stored in ('7502274881475', '6937266702079') then true
      else false
    end
  from n;
$$;

grant execute on function public.fc_match_codigo_barras(text, text) to anon, authenticated, service_role;

commit;

select
  p.sku,
  p.codigo_barras as ean,
  p.nombre,
  p.marca,
  p.presentacion,
  p.stock,
  p.precio
from public.productos p
where p.sku in ('FC-88576495', 'FC-274881475', 'FC-66701015', 'FC-ND-66701015')
   or p.codigo_barras in (
     '7501088575495', '7501088576495',
     '7502274881475', '6937266702079',
     '7591066701015'
   )
order by p.sku, p.id;
