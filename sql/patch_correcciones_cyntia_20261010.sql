-- Correcciones Cyntia WhatsApp · 2026-10-10
-- 1) Reaplicar N–Z / Oxatech que no quedaron del 7-oct
-- 2) Miércoles: Panclasa 2→1, Zagapsol EAN pistola, Gabapentina EAN+foto cruzados,
--    Miriam llevó C/15 ($45) → stock 0
-- Idempotente vía lotes. No inventa caducidad.
-- Ver LEERME_correcciones_cyntia_20261010.md

begin;

---------------------------------------------------------------------------
-- Zagapsol: EAN de caja física (FarmaSmart / pistola). Levic traía 0231.
---------------------------------------------------------------------------
update public.productos
   set codigo_barras = '7502209858152',
       activo = true,
       descripcion = case
         when coalesce(descripcion, '') ilike '%7502209850231%' then descripcion
         when coalesce(nullif(btrim(descripcion), ''), '') = '' then
           'Zagapsol Avitus · EAN caja 7502209858152 · EAN Levic 7502209850231'
         else descripcion || ' · EAN Levic 7502209850231'
       end
 where sku = 'EQ-AVT218'
   and (codigo_barras is distinct from '7502209858152'
        or codigo_barras is null);

---------------------------------------------------------------------------
-- Oxatech: olanzapina requiere receta (POS lo marcaba venta libre)
---------------------------------------------------------------------------
update public.productos
   set requiere_receta = true,
       principio_activo = coalesce(nullif(btrim(principio_activo), ''), 'Olanzapina')
 where sku = 'EQ-MAV198';

---------------------------------------------------------------------------
-- Gabapentina Wermy: EAN + foto estaban cruzados (texto sí era correcto)
-- Farmacity: 7502240450773 = C/15 · 7502240450780 = C/30
---------------------------------------------------------------------------
do $$
declare
  v_15 bigint;
  v_30 bigint;
  v_tmp text := 'TMP-SWAP-WERMY-' || to_char(clock_timestamp(), 'YYYYMMDDHH24MISS');
  v_url_15 text := 'https://qyabhoftqfmqwpqcsdrb.supabase.co/storage/v1/object/public/productos/rappi/7502240450773/1.webp';
  v_url_30 text := 'https://qyabhoftqfmqwpqcsdrb.supabase.co/storage/v1/object/public/productos/rappi/7502240450780/1.webp';
begin
  select id into v_15 from public.productos where sku = 'FC-50D044FF' limit 1;
  select id into v_30 from public.productos where sku = 'FC-759A5EF9' limit 1;

  if v_15 is null or v_30 is null then
    raise notice 'SKIP Gabapentina: falta FC-50D044FF o FC-759A5EF9';
    return;
  end if;

  -- Si ya están bien, no tocar EAN/foto
  if exists (
       select 1 from public.productos
        where id = v_15 and codigo_barras = '7502240450773'
     )
     and exists (
       select 1 from public.productos
        where id = v_30 and codigo_barras = '7502240450780'
     )
  then
    raise notice 'OK Gabapentina EANs ya correctos';
  else
    -- unique(codigo_barras): pasar por temporal
    update public.productos set codigo_barras = v_tmp where id = v_15;
    update public.productos
       set codigo_barras = '7502240450780',
           imagen_url = v_url_30,
           presentacion = 'Caja con 30 cápsulas',
           nombre = case
             when nombre ilike '%gabapentina%' then nombre
             else 'Gabapentina 300 mg'
           end,
           principio_activo = 'Gabapentina',
           concentracion = '300 mg',
           forma_farmaceutica = 'Cápsulas',
           marca = 'Wermy'
     where id = v_30;
    update public.productos
       set codigo_barras = '7502240450773',
           imagen_url = v_url_15,
           presentacion = 'Caja con 15 cápsulas',
           nombre = case
             when nombre ilike '%gabapentina%' then nombre
             else 'Gabapentina 300 mg'
           end,
           principio_activo = 'Gabapentina',
           concentracion = '300 mg',
           forma_farmaceutica = 'Cápsulas',
           marca = 'Wermy'
     where id = v_15;
    raise notice 'SWAP Gabapentina EAN+imagen_url';
  end if;

  -- Galería: apuntar cada SKU a su packshot Rappi
  update public.producto_imagenes
     set url = v_url_15,
         storage_path = 'rappi/7502240450773/1.webp',
         es_principal = true
   where producto_id = v_15
     and (url is distinct from v_url_15 or storage_path is distinct from 'rappi/7502240450773/1.webp');

  update public.producto_imagenes
     set url = v_url_30,
         storage_path = 'rappi/7502240450780/1.webp',
         es_principal = true
   where producto_id = v_30
     and (url is distinct from v_url_30 or storage_path is distinct from 'rappi/7502240450780/1.webp');

  -- Asegurar imagen_url aunque el EAN ya estuviera bien
  update public.productos set imagen_url = v_url_15 where id = v_15 and imagen_url is distinct from v_url_15;
  update public.productos set imagen_url = v_url_30 where id = v_30 and imagen_url is distinct from v_url_30;
end $$;

---------------------------------------------------------------------------
-- Stock por lotes
---------------------------------------------------------------------------
do $$
declare
  r record;
  v_pid bigint;
  v_lote bigint;
  v_sum integer;
  v_costo numeric;
  v_motivo text := 'Correcciones Cyntia WhatsApp 2026-10-10';
begin
  for r in
    select * from (values
      ('EQ-SON153',   2),  -- Nysmoson: «no estan» → 2
      ('FC-9022126',  2),  -- Metamizol AMSA físico 2
      ('FC-8505126',  1),  -- Neuralin físico 1
      ('EQ-MAV198',   1),  -- Oxatech físico 1 (antes SKU mal EQ-MAV196)
      ('FC-71800265', 1),  -- Panclasa físico 1
      ('FC-50D044FF', 0),  -- Gabapentina C/15: Miriam se la llevó ($45)
      ('FC-759A5EF9', 2)   -- Gabapentina C/30: físico 2
    ) as t(sku, nuevo_stock)
  loop
    select id, costo into v_pid, v_costo
      from public.productos
     where sku = r.sku
        or (r.sku = 'FC-9022126' and codigo_barras = '7501349022126')
     limit 1;

    if v_pid is null then
      raise notice 'SKIP %: no está en productos', r.sku;
      continue;
    end if;

    select coalesce(sum(l.cantidad_actual), 0) into v_sum
      from public.lotes l
     where l.producto_id = v_pid
       and coalesce(l.activo, true);

    if v_sum = r.nuevo_stock then
      raise notice 'OK % ya en %', r.sku, r.nuevo_stock;
      continue;
    end if;

    -- Objetivo 0: vaciar lotes activos (no inventar lote vacío)
    if r.nuevo_stock = 0 then
      update public.lotes
         set cantidad_actual = 0,
             activo = false
       where producto_id = v_pid
         and coalesce(activo, true)
         and coalesce(cantidad_actual, 0) > 0;

      insert into public.movimientos_inventario (producto_id, tipo, cantidad, motivo)
      values (v_pid, 'ajuste', 0,
              v_motivo || ' · ' || r.sku || ' → 0 (Miriam C/15 $45)');

      raise notice 'AJUSTE %: % → 0', r.sku, v_sum;
      continue;
    end if;

    select l.id into v_lote
      from public.lotes l
     where l.producto_id = v_pid
     order by coalesce(l.activo, true) desc,
              coalesce(l.cantidad_actual, 0) desc,
              l.id desc
     limit 1;

    if v_lote is null then
      insert into public.lotes (
        producto_id, numero_lote, cantidad_inicial, cantidad_actual,
        fecha_caducidad, costo_unitario, activo
      ) values (
        v_pid, 'INV-CORRECCION-20261010', r.nuevo_stock, r.nuevo_stock,
        null, v_costo, true
      );
    else
      update public.lotes
         set cantidad_actual = 0, activo = false
       where producto_id = v_pid
         and id <> v_lote
         and coalesce(activo, true)
         and coalesce(cantidad_actual, 0) > 0;

      update public.lotes
         set cantidad_actual = r.nuevo_stock,
             activo = true,
             cantidad_inicial = greatest(coalesce(cantidad_inicial, 0), r.nuevo_stock)
       where id = v_lote;
    end if;

    insert into public.movimientos_inventario (producto_id, tipo, cantidad, motivo)
    values (v_pid, 'ajuste', r.nuevo_stock,
            v_motivo || ' · ' || r.sku || ' → ' || r.nuevo_stock);

    raise notice 'AJUSTE %: % → %', r.sku, v_sum, r.nuevo_stock;
  end loop;
end $$;

commit;

select p.sku, p.nombre, p.stock, p.codigo_barras,
       left(coalesce(p.imagen_url, ''), 70) as img,
       p.requiere_receta, p.presentacion
  from public.productos p
 where p.sku in (
   'EQ-SON153', 'FC-9022126', 'FC-8505126', 'EQ-MAV198', 'FC-71800265',
   'FC-50D044FF', 'FC-759A5EF9', 'EQ-AVT218'
 )
    or p.codigo_barras in (
   '7502209858152', '7502209850231', '7502240450773', '7502240450780',
   '7501349022126'
 )
 order by p.sku;
