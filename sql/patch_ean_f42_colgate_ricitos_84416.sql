-- Bodega F-42 84416 (30-sep-2026).
-- Las 2 piezas de cada uno YA están en el anaquel, en el SKU del ticket.
-- Este patch NO suma otras 2. Pega el código de la caja en ese stock
-- y apaga el alta de foto (stock 0) para que la pistola no abra el vacío.
--
-- Colgate Total enjuague Encías Saludables 250 ml
--   Caja: 7509546666969
--   Ticket OCR: 7509546666959 (check digit mal) · SKU FC-46666959 · stock 2 · $57.79 / $73
--   Foto 02-oct: FC-46666969 · mismo EAN bueno · stock 0 · sin costo
--
-- Jabón Ricitos de Oro Bio-Pure 90 g
--   Caja: 037836050725
--   Ticket renglón 46 sin EAN (se cortó en la foto) · FC-F42-JBNGRISIRICITOSO · stock 2 · $22.33 / $28
--   Foto 02-oct: FC-36050725 · ese UPC · stock 0 · sin costo
--
-- No inventa caducidad. No toca cantidad, confirmado ni lote_id del renglón.
-- Idempotente. Pegar entero en Supabase → SQL Editor → Run.

begin;

do $$
declare
  v_anaquel bigint;
  v_foto bigint;
  v_foto_stock integer;
  v_img text;
  v_img_m text;
begin
  -- ── Colgate ──────────────────────────────────────────────────────────────
  select p.id
    into v_anaquel
  from public.productos p
  where p.costo is not null
    and p.sku in ('FC-46666959', 'FC-46666969')
  order by case when p.sku = 'FC-46666959' then 0 else 1 end, p.id
  limit 1;

  if v_anaquel is null then
    raise exception 'No está el Colgate del ticket F-42 (FC-46666959 con costo)';
  end if;

  select p.id, coalesce(p.stock, 0), p.imagen_url, p.imagen_mobile_url
    into v_foto, v_foto_stock, v_img, v_img_m
  from public.productos p
  where p.sku in ('FC-46666969', 'FC-46666969-FOTO')
    and p.id is distinct from v_anaquel
  order by p.id
  limit 1;

  if coalesce(v_foto_stock, 0) > 0 then
    raise exception 'El alta de foto del Colgate ya tiene stock; no lo sumo al del ticket';
  end if;

  if v_foto is not null then
    update public.productos
       set sku = 'FC-46666969-FOTO',
           codigo_barras = null,
           activo = false,
           visible_tienda = false,
           stock = 0
     where id = v_foto;
  end if;

  update public.productos
     set sku = 'FC-46666969',
         codigo_barras = '7509546666969',
         nombre = 'Colgate Total Prevención Activa Encías Saludables',
         marca = 'Colgate',
         presentacion = '250 ml',
         forma_farmaceutica = 'Enjuague bucal',
         categoria = 'Higiene',
         subcategoria = 'Higiene bucal',
         laboratorio = 'COLGATE-PALMOLIVE',
         imagen_url = coalesce(nullif(btrim(imagen_url), ''), nullif(btrim(v_img), ''),
           'https://www.farmacapital.mx/catalogo-propia/colgate-total-encias-prevencion-activa-250ml-7509546666969.jpg'),
         imagen_mobile_url = coalesce(nullif(btrim(imagen_mobile_url), ''), nullif(btrim(v_img_m), ''), nullif(btrim(v_img), ''),
           'https://www.farmacapital.mx/catalogo-propia/colgate-total-encias-prevencion-activa-250ml-7509546666969.jpg'),
         descripcion = 'Ticket Bodega F-42 84416 · 30-sep-2026 · 2 piezas ya en anaquel · EAN caja 7509546666969 (OCR 7509546666959).'
   where id = v_anaquel;

  update public.recepcion_items i
     set codigo_escaneado = '7509546666969',
         producto_id = v_anaquel,
         nombre_snapshot = 'Colgate Total Prevención Activa Encías Saludables',
         pendiente_alta = false
    from public.recepciones r
   where i.recepcion_id = r.id
     and r.folio = '84416'
     and coalesce(r.proveedor, '') ilike '%F-42%'
     and (
       i.producto_id = v_anaquel
       or i.producto_id is not distinct from v_foto
       or coalesce(i.codigo_escaneado, '') in ('7509546666959', '7509546666969')
       or i.nombre_snapshot ilike '%ENC-SAL%'
       or i.nombre_snapshot ilike '%Encías Saludables%'
     );

  -- ── Ricitos Bio-Pure 90 g ────────────────────────────────────────────────
  v_anaquel := null;
  v_foto := null;
  v_foto_stock := null;
  v_img := null;
  v_img_m := null;

  select p.id
    into v_anaquel
  from public.productos p
  where p.costo is not null
    and p.sku in ('FC-F42-JBNGRISIRICITOSO', 'FC-36050725')
  order by case when p.sku = 'FC-F42-JBNGRISIRICITOSO' then 0 else 1 end, p.id
  limit 1;

  if v_anaquel is null then
    raise exception 'No está el jabón Ricitos del ticket F-42 (FC-F42-JBNGRISIRICITOSO con costo)';
  end if;

  select p.id, coalesce(p.stock, 0), p.imagen_url, p.imagen_mobile_url
    into v_foto, v_foto_stock, v_img, v_img_m
  from public.productos p
  where p.sku in ('FC-36050725', 'FC-36050725-FOTO')
    and p.id is distinct from v_anaquel
  order by p.id
  limit 1;

  if coalesce(v_foto_stock, 0) > 0 then
    raise exception 'El alta de foto del jabón Ricitos ya tiene stock; no lo sumo al del ticket';
  end if;

  if v_foto is not null then
    update public.productos
       set sku = 'FC-36050725-FOTO',
           codigo_barras = null,
           activo = false,
           visible_tienda = false,
           stock = 0
     where id = v_foto;
  end if;

  update public.productos
     set sku = 'FC-36050725',
         codigo_barras = '037836050725',
         nombre = 'Ricitos de Oro Bio-Pure',
         marca = 'Ricitos de Oro',
         presentacion = '90 g',
         forma_farmaceutica = 'Jabón',
         categoria = 'Bebés',
         subcategoria = 'Higiene bebé',
         laboratorio = 'GRISI',
         imagen_url = coalesce(nullif(btrim(imagen_url), ''), nullif(btrim(v_img), ''),
           'https://www.farmacapital.mx/catalogo-propia/ricitos-de-oro-bio-pure-jabon-90g-037836050725.jpg'),
         imagen_mobile_url = coalesce(nullif(btrim(imagen_mobile_url), ''), nullif(btrim(v_img_m), ''), nullif(btrim(v_img), ''),
           'https://www.farmacapital.mx/catalogo-propia/ricitos-de-oro-bio-pure-jabon-90g-037836050725.jpg'),
         descripcion = 'Ticket Bodega F-42 84416 · 30-sep-2026 · 2 piezas ya en anaquel · UPC 037836050725 (renglón 46 venía sin EAN).'
   where id = v_anaquel;

  update public.recepcion_items i
     set codigo_escaneado = '037836050725',
         producto_id = v_anaquel,
         nombre_snapshot = 'Ricitos de Oro Bio-Pure',
         pendiente_alta = false
    from public.recepciones r
   where i.recepcion_id = r.id
     and r.folio = '84416'
     and coalesce(r.proveedor, '') ilike '%F-42%'
     and (
       i.producto_id = v_anaquel
       or i.producto_id is not distinct from v_foto
       or coalesce(i.codigo_escaneado, '') in ('037836050725', '0037836050725')
       or i.nombre_snapshot ilike '%BIOPURE 90%'
       or i.nombre_snapshot ilike '%Bio-Pure%'
     );
end $$;

-- Verificación: stock 2, costo del ticket, EAN de la caja. El -FOTO queda apagado.
select p.sku, p.codigo_barras, p.nombre, p.stock, p.costo, p.precio, p.activo
  from public.productos p
 where p.sku in (
   'FC-46666969', 'FC-46666969-FOTO', 'FC-46666959',
   'FC-36050725', 'FC-36050725-FOTO', 'FC-F42-JBNGRISIRICITOSO'
 )
 order by p.sku;

select r.folio, r.estado, i.cantidad, i.confirmado, i.codigo_escaneado, i.nombre_snapshot, p.sku, p.stock
  from public.recepcion_items i
  join public.recepciones r on r.id = i.recepcion_id
  left join public.productos p on p.id = i.producto_id
 where r.folio = '84416'
   and coalesce(r.proveedor, '') ilike '%F-42%'
   and (
     coalesce(i.codigo_escaneado, '') in ('7509546666969', '7509546666959', '037836050725')
     or i.nombre_snapshot ilike '%Encías Saludables%'
     or i.nombre_snapshot ilike '%Bio-Pure%'
     or i.nombre_snapshot ilike '%BIOPURE 90%'
   )
 order by i.codigo_escaneado;

commit;
