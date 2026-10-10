-- Correcciones Raquel WhatsApp · 2026-10-10
-- Incluye lote 3 (Pregabalina EAN, Pabesorag 11, Roxidolin 1) + resto del chat.
-- Altas: Rumoquin N.F. C/30, Sucralfato Alivoato/Suanca C/40.
-- Fotos: DESPUÉS del deploy de este PR (catalogo-propia/).
-- Idempotente. No inventa caducidad.
-- Ver LEERME_correcciones_conteo_raquel_20261010.md

begin;

---------------------------------------------------------------------------
-- Pregabalina 150 mg AMSA · EQ-AMS234 · EAN caja 7501349022935
---------------------------------------------------------------------------
update public.productos p
   set codigo_barras = null
 where p.codigo_barras = '7501349022935'
   and p.sku is distinct from 'EQ-AMS234';

update public.productos
   set codigo_barras = '7501349022935',
       nombre = 'Pregabalina 150 mg',
       marca = coalesce(nullif(btrim(marca), ''), 'AMSA'),
       presentacion = 'Caja con 28 cápsulas',
       concentracion = '150 mg',
       principio_activo = coalesce(nullif(btrim(principio_activo), ''), 'Pregabalina'),
       forma_farmaceutica = coalesce(nullif(btrim(forma_farmaceutica), ''), 'Cápsulas'),
       tipo = coalesce(nullif(btrim(tipo), ''), 'generico'),
       requiere_receta = true,
       activo = true
 where sku = 'EQ-AMS234';

---------------------------------------------------------------------------
-- Rosel Pediátrico: EAN duplicado + foto de la caja de 60 ml
-- Canónico EQ-WER053; FC-40451015 pierde el EAN y el stock se consolida.
---------------------------------------------------------------------------
update public.productos
   set codigo_barras = null,
       activo = false
 where sku = 'FC-40451015'
   and codigo_barras = '7502240451015';

update public.productos
   set codigo_barras = '7502240451015',
       imagen_url = 'https://www.farmacapital.mx/catalogo-propia/rosel-pediatrico-30ml-7502240451015.jpg',
       nombre = 'Rosel Pediátrico',
       marca = coalesce(nullif(btrim(marca), ''), 'Wermar'),
       presentacion = 'Frasco 30 ml con gotero',
       concentracion = '2.5 / 0.100 / 15 g / 30 ml',
       principio_activo = 'Amantadina / Clorfenamina / Paracetamol',
       forma_farmaceutica = 'Solución',
       activo = true
 where sku = 'EQ-WER053';

-- Galería principal Pediátrico
do $$
declare
  v_pid bigint;
  v_url text := 'https://www.farmacapital.mx/catalogo-propia/rosel-pediatrico-30ml-7502240451015.jpg';
  v_path text := 'catalogo-propia/rosel-pediatrico-30ml-7502240451015.jpg';
  v_pos integer;
begin
  select id into v_pid from public.productos where sku = 'EQ-WER053' limit 1;
  if v_pid is null then return; end if;

  update public.producto_imagenes
     set es_principal = false
   where producto_id = v_pid and es_principal
     and url is distinct from v_url;

  if exists (select 1 from public.producto_imagenes where producto_id = v_pid and url = v_url) then
    update public.producto_imagenes
       set es_principal = true, origen = 'propia', storage_path = v_path
     where producto_id = v_pid and url = v_url;
  else
    select coalesce(max(posicion), -1) + 1 into v_pos
      from public.producto_imagenes where producto_id = v_pid;
    insert into public.producto_imagenes
      (producto_id, url, storage_path, posicion, es_principal, origen)
    values (v_pid, v_url, v_path, v_pos, true, 'propia');
  end if;
end $$;

---------------------------------------------------------------------------
-- Sertralina: antidepresivo → receta
---------------------------------------------------------------------------
update public.productos
   set requiere_receta = true,
       principio_activo = coalesce(nullif(btrim(principio_activo), ''), 'Sertralina')
 where sku = 'EQ-AMS323';

---------------------------------------------------------------------------
-- Altas: Rumoquin N.F. + Sucralfato Alivoato
---------------------------------------------------------------------------
do $$
declare
  v_pid bigint;
  v_lid bigint;
  v_sum integer;
  v_costo numeric;
  v_lote bigint;
begin
  -- 1) Rumoquin N.F. C/30 · EAN 7506494600038 · físico 1
  select id into v_pid
    from public.productos
   where codigo_barras = '7506494600038'
      or sku = 'FC-94600038'
   limit 1;

  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
      from public.create_producto_with_lote(
        jsonb_build_object(
          'nombre', 'Rumoquin N.F.',
          'sku', 'FC-94600038',
          'codigo_barras', '7506494600038',
          'categoria', 'Medicamentos',
          'tipo', 'marca',
          'descripcion', 'Conteo Raquel 2026-10-10 · Schoen · Metocarbamol/Indometacina/Betametasona · Caja con frasco 30 tabletas · no estaba en sistema · TODO foto',
          'precio', 149,
          'stock_minimo', 1,
          'activo', true,
          'requiere_receta', true
        ),
        1,
        'INV-CONTEO-20261010-R',
        null::date,
        null::numeric,
        null::bigint
      ) f;

    update public.productos set
      marca = 'Schoen',
      presentacion = 'Caja con frasco con 30 tabletas',
      concentracion = '215 / 25 / 0.75 mg',
      principio_activo = 'Metocarbamol / Indometacina / Betametasona',
      forma_farmaceutica = 'Tabletas',
      subcategoria = 'Músculo-esquelético'
    where id = v_pid;

    raise notice 'ALTA Rumoquin N.F. C/30 id % · TODO foto', v_pid;
  else
    select costo into v_costo from public.productos where id = v_pid;
    select coalesce(sum(cantidad_actual), 0) into v_sum
      from public.lotes where producto_id = v_pid and coalesce(activo, true);
    if v_sum is distinct from 1 then
      select id into v_lote from public.lotes
       where producto_id = v_pid
       order by coalesce(activo, true) desc, coalesce(cantidad_actual, 0) desc, id desc
       limit 1;
      if v_lote is null then
        insert into public.lotes (
          producto_id, numero_lote, cantidad_inicial, cantidad_actual,
          fecha_caducidad, costo_unitario, activo
        ) values (v_pid, 'INV-CONTEO-20261010-R', 1, 1, null, v_costo, true);
      else
        update public.lotes set cantidad_actual = 0, activo = false
         where producto_id = v_pid and id <> v_lote
           and coalesce(activo, true) and coalesce(cantidad_actual, 0) > 0;
        update public.lotes
           set cantidad_actual = 1, activo = true,
               cantidad_inicial = greatest(coalesce(cantidad_inicial, 0), 1)
         where id = v_lote;
      end if;
      insert into public.movimientos_inventario (producto_id, tipo, cantidad, motivo)
      values (v_pid, 'ajuste', 1, 'Conteo Raquel 2026-10-10 · Rumoquin N.F. → 1');
    end if;
    update public.productos
       set codigo_barras = coalesce(nullif(btrim(codigo_barras), ''), '7506494600038'),
           activo = true
     where id = v_pid;
    raise notice 'Rumoquin ya existía id %', v_pid;
  end if;

  -- 2) Sucralfato Alivoato/Suanca 1 g C/40 · EAN 7503002772508 · físico 3
  select id into v_pid
    from public.productos
   where codigo_barras = '7503002772508'
      or sku = 'FC-02772508'
   limit 1;

  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
      from public.create_producto_with_lote(
        jsonb_build_object(
          'nombre', 'Sucralfato 1 g',
          'sku', 'FC-02772508',
          'codigo_barras', '7503002772508',
          'categoria', 'Medicamentos',
          'tipo', 'generico',
          'descripcion', 'Conteo Raquel 2026-10-10 · Alivoato / Suanca · Caja con 40 tabletas · no estaba en sistema',
          'precio', 90,
          'stock_minimo', 2,
          'activo', true,
          'requiere_receta', false
        ),
        3,
        'INV-CONTEO-20261010-R',
        null::date,
        null::numeric,
        null::bigint
      ) f;

    update public.productos set
      marca = 'Alivoato',
      presentacion = 'Caja con 40 tabletas',
      concentracion = '1 g',
      principio_activo = 'Sucralfato',
      forma_farmaceutica = 'Tabletas',
      subcategoria = 'Gastro',
      imagen_url = 'https://www.farmacapital.mx/catalogo-propia/sucralfato-alivoato-1g-c40-7503002772508.jpg'
    where id = v_pid;

    if not exists (
      select 1 from public.producto_imagenes
       where producto_id = v_pid
         and url = 'https://www.farmacapital.mx/catalogo-propia/sucralfato-alivoato-1g-c40-7503002772508.jpg'
    ) then
      insert into public.producto_imagenes
        (producto_id, url, storage_path, posicion, es_principal, origen)
      values (
        v_pid,
        'https://www.farmacapital.mx/catalogo-propia/sucralfato-alivoato-1g-c40-7503002772508.jpg',
        'catalogo-propia/sucralfato-alivoato-1g-c40-7503002772508.jpg',
        0, true, 'propia'
      );
    end if;

    raise notice 'ALTA Sucralfato Alivoato C/40 id %', v_pid;
  else
    select costo into v_costo from public.productos where id = v_pid;
    select coalesce(sum(cantidad_actual), 0) into v_sum
      from public.lotes where producto_id = v_pid and coalesce(activo, true);
    if v_sum is distinct from 3 then
      select id into v_lote from public.lotes
       where producto_id = v_pid
       order by coalesce(activo, true) desc, coalesce(cantidad_actual, 0) desc, id desc
       limit 1;
      if v_lote is null then
        insert into public.lotes (
          producto_id, numero_lote, cantidad_inicial, cantidad_actual,
          fecha_caducidad, costo_unitario, activo
        ) values (v_pid, 'INV-CONTEO-20261010-R', 3, 3, null, v_costo, true);
      else
        update public.lotes set cantidad_actual = 0, activo = false
         where producto_id = v_pid and id <> v_lote
           and coalesce(activo, true) and coalesce(cantidad_actual, 0) > 0;
        update public.lotes
           set cantidad_actual = 3, activo = true,
               cantidad_inicial = greatest(coalesce(cantidad_inicial, 0), 3)
         where id = v_lote;
      end if;
      insert into public.movimientos_inventario (producto_id, tipo, cantidad, motivo)
      values (v_pid, 'ajuste', 3, 'Conteo Raquel 2026-10-10 · Sucralfato Alivoato → 3');
    end if;
    update public.productos
       set codigo_barras = coalesce(nullif(btrim(codigo_barras), ''), '7503002772508'),
           imagen_url = coalesce(imagen_url, 'https://www.farmacapital.mx/catalogo-propia/sucralfato-alivoato-1g-c40-7503002772508.jpg'),
           activo = true
     where id = v_pid;
    raise notice 'Sucralfato Alivoato ya existía id %', v_pid;
  end if;
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
  v_motivo text := 'Correcciones Raquel WhatsApp 2026-10-10';
begin
  for r in
    select * from (values
      ('EQ-AMS234',   1),   -- Pregabalina pistola + 1 pza
      ('FC-5885E577', 11),  -- Pabesorag sistema 8, físico 11
      ('FC-27870259', 1),   -- Roxidolin SIN LOTES → 1
      ('EQ-WER025',   4),   -- Rosel cápsulas 3 → 4
      ('EQ-WER053',   4),   -- Rosel Pediátrico 3 → 4 (consolida dup)
      ('FC-40451015', 0),   -- dup Pediátrico
      ('FC-75354321', 4),   -- Tylenol C/10 físico 4
      ('EQ-AMS323',   2)    -- Sertralina 3 → 2
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

    if r.nuevo_stock = 0 then
      update public.lotes
         set cantidad_actual = 0, activo = false
       where producto_id = v_pid
         and coalesce(activo, true)
         and coalesce(cantidad_actual, 0) > 0;
      insert into public.movimientos_inventario (producto_id, tipo, cantidad, motivo)
      values (v_pid, 'ajuste', 0, v_motivo || ' · ' || r.sku || ' → 0');
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
        v_pid, 'INV-CONTEO-20261010-R', r.nuevo_stock, r.nuevo_stock,
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

select p.sku, p.nombre, p.stock, p.codigo_barras, p.activo,
       left(coalesce(p.imagen_url, ''), 70) as img, p.requiere_receta
  from public.productos p
 where p.sku in (
   'EQ-AMS234','FC-5885E577','FC-27870259','FC-94600038','EQ-WER025',
   'EQ-WER053','FC-40451015','FC-75354321','EQ-AMS323','FC-02772508'
 )
    or p.codigo_barras in (
   '7501349022935','7506494600038','7503002772508','7502240451015'
 )
 order by p.sku;
