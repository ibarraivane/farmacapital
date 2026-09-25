-- Oral-B enjuagues: NO son el mismo producto (EANs distintos).
--
--   FC-51037878  EAN 7891051037878  Complete 4 en 1 (con flúor)
--   FC-43517980  EAN 7500435179980  100% menta (sin alcohol, sensibles)
--
-- Farmalive los vendió como 2 renglones (tickets 11590, 97, 14173).
-- Inventario mostraba 6+3=9; físico reportado = 4 botellas en total.
--
-- Este patch:
--   1) Nombres claros + foto correcta por línea (no se fusionan).
--   2) Ajusta stock/lotes a conteo físico (default 3 Complete + 1×100%).
--      Si al escanear sale otro reparto, cambiá v_stock_complete / v_stock_100.
--
-- Idempotente. Supabase → SQL Editor → Run.

begin;

-- ── Vista previa ────────────────────────────────────────────────────────────
select
  p.sku,
  left(p.nombre, 48) as nombre,
  p.codigo_barras as ean,
  p.activo,
  p.stock,
  p.precio,
  p.costo,
  (
    select count(*)::int from public.lotes l
    where l.producto_id = p.id and coalesce(l.activo, true)
      and coalesce(l.cantidad_actual, 0) > 0
  ) as lotes_vivos,
  (
    select coalesce(sum(l.cantidad_actual), 0)::int from public.lotes l
    where l.producto_id = p.id and coalesce(l.activo, true)
  ) as en_lotes
from public.productos p
where p.sku in ('FC-51037878', 'FC-43517980', 'FC-35179980')
   or regexp_replace(coalesce(p.codigo_barras, ''), '\D', '', 'g')
      in ('7891051037878', '7500435179980')
order by p.sku;

do $$
declare
  -- Conte físico total = 4. Reparto default proporcional al stock que había (6:3).
  -- Escaneá cada botella y ajustá si hace falta (deben sumar 4).
  v_stock_complete integer := 3;  -- EAN 7891051037878
  v_stock_100      integer := 1;  -- EAN 7500435179980

  v_complete bigint;
  v_cien bigint;
  v_en_lotes integer;
  r record;
begin
  if v_stock_complete + v_stock_100 <> 4 then
    raise exception 'Complete(%) + 100%%(%) debe sumar 4 (físico reportado)',
      v_stock_complete, v_stock_100;
  end if;

  select id into v_complete
  from public.productos
  where sku = 'FC-51037878'
     or regexp_replace(coalesce(codigo_barras, ''), '\D', '', 'g') = '7891051037878'
  order by case when sku = 'FC-51037878' then 0 else 1 end, id
  limit 1;

  select id into v_cien
  from public.productos
  where sku = 'FC-43517980'
     or regexp_replace(coalesce(codigo_barras, ''), '\D', '', 'g') = '7500435179980'
  order by case when sku = 'FC-43517980' then 0 else 1 end, id
  limit 1;

  if v_complete is null or v_cien is null then
    raise exception 'Falta ficha Complete (id %) o 100%% (id %)', v_complete, v_cien;
  end if;

  -- Si quedó un tercer SKU con el mismo EAN (alta Farmalive 97), apagarlo.
  for r in
    select p.id,
           regexp_replace(coalesce(p.codigo_barras, ''), '\D', '', 'g') as ean
    from public.productos p
    where p.id not in (v_complete, v_cien)
      and p.activo = true
      and regexp_replace(coalesce(p.codigo_barras, ''), '\D', '', 'g')
          in ('7891051037878', '7500435179980')
  loop
    update public.recepcion_items i
       set producto_id = case
             when r.ean = '7891051037878' then v_complete
             else v_cien
           end
     where i.producto_id = r.id;
    update public.lotes set activo = false, cantidad_actual = 0 where producto_id = r.id;
    update public.productos set activo = false, stock = 0, stock_unidades = 0 where id = r.id;
    raise notice 'Apagado SKU fantasma id % ean %', r.id, r.ean;
  end loop;

  -- Fichas claras (botellas distintas)
  update public.productos set
    nombre = 'Oral-B Complete 4 en 1 enjuague 250 ml',
    marca = 'Oral-B',
    presentacion = '250 ml',
    forma_farmaceutica = coalesce(nullif(btrim(forma_farmaceutica), ''), 'Enjuague'),
    codigo_barras = '7891051037878',
    categoria = coalesce(nullif(btrim(categoria), ''), 'Cuidado personal'),
    subcategoria = coalesce(nullif(btrim(subcategoria), ''), 'Higiene bucal'),
    descripcion = coalesce(
      nullif(btrim(descripcion), ''),
      'Complete 4 en 1 · con flúor · EAN 7891051037878 · distinto del Oral-B 100%'
    ),
    imagen_url = coalesce(
      nullif(btrim(imagen_url), ''),
      'https://www.farmacapital.mx/catalogo-propia/oral-b-enjuague-complet-250ml.jpg'
    ),
    costo = case when coalesce(costo, 0) <= 0 then 47.75 else costo end,
    precio = case when coalesce(precio, 0) < 60 then 65 else precio end,
    activo = true,
    stock = v_stock_complete,
    stock_unidades = 0
  where id = v_complete;

  update public.productos set
    nombre = 'Oral-B 100% menta refrescante 250 ml',
    marca = 'Oral-B',
    presentacion = '250 ml',
    forma_farmaceutica = coalesce(nullif(btrim(forma_farmaceutica), ''), 'Enjuague'),
    codigo_barras = '7500435179980',
    categoria = coalesce(nullif(btrim(categoria), ''), 'Cuidado personal'),
    subcategoria = coalesce(nullif(btrim(subcategoria), ''), 'Higiene bucal'),
    descripcion = coalesce(
      nullif(btrim(descripcion), ''),
      '100% menta · sin alcohol · sensibles · EAN 7500435179980 · distinto del Complete'
    ),
    imagen_url = 'https://www.farmacapital.mx/catalogo-propia/oral-b-enjuague-100-250ml.jpg',
    costo = case when coalesce(costo, 0) <= 0 then 49.29 else costo end,
    precio = case when coalesce(precio, 0) < 60 then 65 else precio end,
    activo = true,
    stock = v_stock_100,
    stock_unidades = 0
  where id = v_cien;

  -- Normalizar lotes Complete → un solo lote con v_stock_complete
  select coalesce(sum(cantidad_actual), 0)::integer into v_en_lotes
  from public.lotes
  where producto_id = v_complete and coalesce(activo, true);

  if v_stock_complete <= 0 then
    update public.lotes set activo = false, cantidad_actual = 0 where producto_id = v_complete;
  elsif v_en_lotes <= 0 then
    insert into public.lotes (
      producto_id, numero_lote, fecha_caducidad,
      cantidad_inicial, cantidad_actual, activo
    ) values (
      v_complete, 'AJ-ORALB-COMPLETE-20260925', '2030-01-31'::date,
      v_stock_complete, v_stock_complete, true
    );
  else
    update public.lotes l
       set cantidad_actual = case
             when l.id = (
               select l2.id from public.lotes l2
               where l2.producto_id = v_complete and coalesce(l2.activo, true)
               order by coalesce(l2.cantidad_actual, 0) desc, l2.id
               limit 1
             ) then v_stock_complete
             else 0
           end,
           activo = case
             when l.id = (
               select l2.id from public.lotes l2
               where l2.producto_id = v_complete and coalesce(l2.activo, true)
               order by coalesce(l2.cantidad_actual, 0) desc, l2.id
               limit 1
             ) then true
             else false
           end,
           fecha_caducidad = coalesce(l.fecha_caducidad, '2030-01-31'::date)
     where l.producto_id = v_complete;
  end if;

  -- Normalizar lotes 100%
  select coalesce(sum(cantidad_actual), 0)::integer into v_en_lotes
  from public.lotes
  where producto_id = v_cien and coalesce(activo, true);

  if v_stock_100 <= 0 then
    update public.lotes set activo = false, cantidad_actual = 0 where producto_id = v_cien;
  elsif v_en_lotes <= 0 then
    insert into public.lotes (
      producto_id, numero_lote, fecha_caducidad,
      cantidad_inicial, cantidad_actual, activo
    ) values (
      v_cien, 'AJ-ORALB-100-20260925', '2030-01-31'::date,
      v_stock_100, v_stock_100, true
    );
  else
    update public.lotes l
       set cantidad_actual = case
             when l.id = (
               select l2.id from public.lotes l2
               where l2.producto_id = v_cien and coalesce(l2.activo, true)
               order by coalesce(l2.cantidad_actual, 0) desc, l2.id
               limit 1
             ) then v_stock_100
             else 0
           end,
           activo = case
             when l.id = (
               select l2.id from public.lotes l2
               where l2.producto_id = v_cien and coalesce(l2.activo, true)
               order by coalesce(l2.cantidad_actual, 0) desc, l2.id
               limit 1
             ) then true
             else false
           end,
           fecha_caducidad = coalesce(l.fecha_caducidad, '2030-01-31'::date)
     where l.producto_id = v_cien;
  end if;

  raise notice 'Oral-B: Complete id=% stock=%; 100%% id=% stock=%',
    v_complete, v_stock_complete, v_cien, v_stock_100;
end $$;

commit;

select
  p.sku,
  left(p.nombre, 48) as nombre,
  p.codigo_barras as ean,
  p.activo,
  p.stock,
  p.precio,
  p.costo,
  left(p.imagen_url, 60) as imagen,
  l.numero_lote,
  l.cantidad_actual,
  l.activo as lote_activo
from public.productos p
left join public.lotes l on l.producto_id = p.id
where p.sku in ('FC-51037878', 'FC-43517980', 'FC-35179980')
   or regexp_replace(coalesce(p.codigo_barras, ''), '\D', '', 'g')
      in ('7891051037878', '7500435179980')
order by p.sku, l.id;
