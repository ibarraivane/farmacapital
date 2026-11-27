-- Conteo físico Raquel (WhatsApp) · 2026-10-15
-- Stock vía lotes + barcodes de pistola.
-- Idempotente. No inventa caducidad.
-- Ver LEERME_ajuste_conteo_raquel_20261015.md

begin;

-- Curitas León: EAN de 13 dígitos (pistola)
update public.productos p
   set codigo_barras = null
 where p.codigo_barras in ('7501054530718', '75010545307181')
   and p.sku is distinct from 'FC-45307181';

update public.productos
   set codigo_barras = '7501054530718',
       nombre = coalesce(nullif(btrim(nombre), ''), 'Curitas Parche León Árnica'),
       marca = coalesce(nullif(btrim(marca), ''), 'Curitas'),
       presentacion = coalesce(nullif(btrim(presentacion), ''), '1 parche'),
       activo = true
 where sku = 'FC-45307181';

-- Venda elástica Quirmex 7.5 cm: EAN de la caja (13 dígitos)
update public.productos p
   set codigo_barras = null
 where p.codigo_barras in ('7503003406730', '75030034067301')
   and p.sku is distinct from 'FC-34067301';

update public.productos
   set codigo_barras = '7503003406730',
       nombre = 'Venda elástica Quirmex Premium 7.5 cm',
       marca = 'Quirmex',
       presentacion = 'Rollo 7.5 cm',
       forma_farmaceutica = coalesce(nullif(btrim(forma_farmaceutica), ''), 'Venda elástica'),
       categoria = coalesce(nullif(btrim(categoria), ''), 'Botiquín'),
       subcategoria = coalesce(nullif(btrim(subcategoria), ''), 'Material de curación'),
       tipo = coalesce(nullif(btrim(tipo), ''), 'marca'),
       precio = case when coalesce(precio, 0) < 5 then 7 else precio end,
       venta_unidad = false,
       unidades_por_caja = 0,
       precio_unidad = 0,
       activo = true
 where sku = 'FC-34067301'
    or codigo_barras in ('7503003406730', '75030034067301');

-- Amcef IM 500 mg: EAN de pistola
update public.productos p
   set codigo_barras = null
 where p.codigo_barras = '7501349011007'
   and p.sku is distinct from 'FC-07F04F88';

update public.productos
   set codigo_barras = '7501349011007',
       nombre = 'Amcef IM Ceftriaxona 500 mg',
       marca = 'Amcef',
       presentacion = '1 frasco ámpula',
       concentracion = '500 mg / 2 ml',
       principio_activo = 'Ceftriaxona',
       forma_farmaceutica = 'Solución inyectable',
       categoria = coalesce(nullif(btrim(categoria), ''), 'Medicamentos'),
       subcategoria = 'Antibiótico',
       tipo = coalesce(nullif(btrim(tipo), ''), 'generico'),
       activo = true
 where sku = 'FC-07F04F88';

-- Amcef IM 1 g: EAN de pistola (distinto del IV 7501349012011)
update public.productos p
   set codigo_barras = null
 where p.codigo_barras = '7501349012004'
   and p.sku is distinct from 'FC-BE76D409';

update public.productos
   set codigo_barras = '7501349012004',
       nombre = 'Amcef IM Ceftriaxona 1 g',
       marca = 'Amcef',
       presentacion = '1 frasco ámpula',
       concentracion = '1 g / 3.5 ml',
       principio_activo = 'Ceftriaxona',
       forma_farmaceutica = 'Solución inyectable',
       categoria = coalesce(nullif(btrim(categoria), ''), 'Medicamentos'),
       subcategoria = 'Antibiótico',
       tipo = coalesce(nullif(btrim(tipo), ''), 'generico'),
       activo = true
 where sku = 'FC-BE76D409';

-- Lumboxen ficha
update public.productos
   set nombre = coalesce(nullif(btrim(nombre), ''), 'Lumboxen Parche'),
       marca = coalesce(nullif(btrim(marca), ''), 'Lumboxen'),
       presentacion = coalesce(nullif(btrim(presentacion), ''), 'Parche gel x1'),
       principio_activo = coalesce(nullif(btrim(principio_activo), ''),
         'Capsaicina + Alcanfor + Mentol + Salicilato de metilo'),
       activo = true
 where sku = 'FC-09749209';

do $$
declare
  r record;
  v_pid bigint;
  v_lote bigint;
  v_sum integer;
  v_costo numeric;
  v_motivo text := 'Conteo físico Raquel WhatsApp 2026-10-15';
begin
  for r in
    select * from (values
      ('FC-09749209', 1),   -- Lumboxen parche
      ('FC-45307181', 2),   -- Curitas León
      ('FC-EXP-OPT48', 39), -- Optims sobres
      ('FC-84500140', 2),   -- Venda cohesiva 7.5
      ('FC-03406181', 3),   -- Micropore Quirmex
      ('FC-84500807', 2),   -- Micropore blanca Nexcare (ese tamaño)
      ('FC-85800198', 1),   -- Bebín
      ('FC-43454811', 2),   -- Huggies toallitas
      ('FC-42507240', 1),   -- GUM cera
      ('FC-06719932', 1),   -- Oral-B Complete 2x1
      ('FC-86494286', 2),   -- Oral-B suave
      ('FC-07F04F88', 4),   -- Amcef IM 500 mg
      ('FC-34067301', 12)   -- Venda elástica Quirmex
    ) as t(sku, nuevo_stock)
  loop
    select id, costo into v_pid, v_costo
      from public.productos
     where sku = r.sku
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
        v_pid, 'INV-CONTEO-20261015-R', r.nuevo_stock, r.nuevo_stock,
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
    values (
      v_pid, 'ajuste', r.nuevo_stock,
      v_motivo || ' · ' || r.sku || ' → ' || r.nuevo_stock
    );

    raise notice 'AJUSTE %: % → %', r.sku, v_sum, r.nuevo_stock;
  end loop;
end $$;

-- Lysol 354 g: el que en POS dice Aerosol 354 g (Raquel: 5 → 3).
-- No tocar los grandes (475 g) — dijo que los 4 están bien.
do $$
declare
  v_pid bigint;
  v_lote bigint;
  v_sum integer;
  v_costo numeric;
  v_nuevo integer := 3;
  v_motivo text := 'Conteo físico Raquel WhatsApp 2026-10-15 · Lysol 354 g → 3';
begin
  select id, costo into v_pid, v_costo
    from public.productos
   where activo is not false
     and (
       sku in ('FC-09601018', 'FC-ND-09601018')
       or (
         (nombre ilike '%lysol%' or marca ilike '%lysol%')
         and (
           presentacion ilike '%354%'
           or nombre ilike '%354%'
           or (sku = 'FC-58796882' and coalesce(precio, 0) between 130 and 150)
         )
       )
     )
   order by case
     when presentacion ilike '%354%' or nombre ilike '%354%' then 0
     when sku like '%09601018%' then 1
     else 2
   end
   limit 1;

  if v_pid is null then
    raise notice 'SKIP Lysol 354 g: no encontrado';
    return;
  end if;

  -- Si por error es el de 475 g, no tocar
  if exists (
    select 1 from public.productos
     where id = v_pid
       and (presentacion ilike '%475%' or nombre ilike '%475%')
       and presentacion not ilike '%354%'
       and nombre not ilike '%354%'
  ) then
    raise notice 'SKIP Lysol: el candidato es 475 g (grandes OK)';
    return;
  end if;

  select coalesce(sum(l.cantidad_actual), 0) into v_sum
    from public.lotes l
   where l.producto_id = v_pid and coalesce(l.activo, true);

  if v_sum = v_nuevo then
    raise notice 'OK Lysol 354 g ya en %', v_nuevo;
    return;
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
      v_pid, 'INV-CONTEO-20261015-R', v_nuevo, v_nuevo, null, v_costo, true
    );
  else
    update public.lotes
       set cantidad_actual = 0, activo = false
     where producto_id = v_pid
       and id <> v_lote
       and coalesce(activo, true)
       and coalesce(cantidad_actual, 0) > 0;
    update public.lotes
       set cantidad_actual = v_nuevo,
           activo = true,
           cantidad_inicial = greatest(coalesce(cantidad_inicial, 0), v_nuevo)
     where id = v_lote;
  end if;

  insert into public.movimientos_inventario (producto_id, tipo, cantidad, motivo)
  values (v_pid, 'ajuste', v_nuevo, v_motivo);

  raise notice 'AJUSTE Lysol 354 g id %: % → %', v_pid, v_sum, v_nuevo;
end $$;

commit;

select p.sku, left(p.nombre, 48) as nombre, p.codigo_barras, p.stock, p.precio
  from public.productos p
 where p.sku in (
   'FC-09749209','FC-45307181','FC-EXP-OPT48','FC-84500140','FC-03406181',
   'FC-84500807','FC-85800198','FC-43454811','FC-42507240','FC-06719932',
   'FC-86494286','FC-07F04F88','FC-BE76D409','FC-34067301','FC-58796882',
   'FC-09601018'
 )
 order by p.sku;
