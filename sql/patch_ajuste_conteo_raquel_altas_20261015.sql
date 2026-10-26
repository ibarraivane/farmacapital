-- Altas desde conteo Raquel (WhatsApp) · 2026-10-15
-- Productos que no aparecían al escanear / no se podían recibir.
-- Idempotente. No inventa caducidad.
-- Ver LEERME_ajuste_conteo_raquel_20261015.md

begin;

do $$
declare
  v_pid bigint;
  v_lid bigint;
  v_sum integer;
  v_costo numeric;
  v_lote bigint;
  v_motivo text := 'Conteo Raquel WhatsApp 2026-10-15';
begin
  ---------------------------------------------------------------------------
  -- 1) Colgate Kids Conejo cepillo C/2 · EAN 7509546073453 · físico 2
  --    «NO APARECEN EN SISTEMA AL ESCANEAR»
  ---------------------------------------------------------------------------
  select id into v_pid
    from public.productos
   where codigo_barras = '7509546073453'
      or sku = 'FC-46073453'
   limit 1;

  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
      from public.create_producto_with_lote(
        jsonb_build_object(
          'nombre', 'Colgate Kids Conejo',
          'sku', 'FC-46073453',
          'codigo_barras', '7509546073453',
          'categoria', 'Higiene',
          'tipo', 'marca',
          'descripcion', v_motivo || ' · cepillo dental kids conejo 5+ · blister C/2 · ancla retail ~$43',
          'precio', 45,
          'stock_minimo', 2,
          'activo', true,
          'requiere_receta', false
        ),
        2,
        'INV-CONTEO-20261015-R',
        null::date,
        null::numeric,
        null::bigint
      ) f;

    update public.productos set
      marca = 'Colgate',
      presentacion = 'Blister con 2 cepillos',
      forma_farmaceutica = 'Cepillo dental',
      subcategoria = 'Higiene bucal'
    where id = v_pid;

    raise notice 'ALTA Colgate Kids Conejo id %', v_pid;
  else
    select costo into v_costo from public.productos where id = v_pid;
    update public.productos set
      sku = coalesce(nullif(btrim(sku), ''), 'FC-46073453'),
      codigo_barras = '7509546073453',
      nombre = coalesce(nullif(btrim(nombre), ''), 'Colgate Kids Conejo'),
      marca = coalesce(nullif(btrim(marca), ''), 'Colgate'),
      presentacion = coalesce(nullif(btrim(presentacion), ''), 'Blister con 2 cepillos'),
      forma_farmaceutica = coalesce(nullif(btrim(forma_farmaceutica), ''), 'Cepillo dental'),
      categoria = coalesce(nullif(btrim(categoria), ''), 'Higiene'),
      activo = true,
      precio = case when coalesce(precio, 0) <= 1 then 45 else precio end
    where id = v_pid;

    select coalesce(sum(cantidad_actual), 0) into v_sum
      from public.lotes where producto_id = v_pid and coalesce(activo, true);
    if v_sum is distinct from 2 then
      select id into v_lote from public.lotes
       where producto_id = v_pid
       order by coalesce(activo, true) desc, coalesce(cantidad_actual, 0) desc, id desc
       limit 1;
      if v_lote is null then
        insert into public.lotes (
          producto_id, numero_lote, cantidad_inicial, cantidad_actual,
          fecha_caducidad, costo_unitario, activo
        ) values (v_pid, 'INV-CONTEO-20261015-R', 2, 2, null, v_costo, true);
      else
        update public.lotes set cantidad_actual = 0, activo = false
         where producto_id = v_pid and id <> v_lote
           and coalesce(activo, true) and coalesce(cantidad_actual, 0) > 0;
        update public.lotes
           set cantidad_actual = 2, activo = true,
               cantidad_inicial = greatest(coalesce(cantidad_inicial, 0), 2)
         where id = v_lote;
      end if;
      insert into public.movimientos_inventario (producto_id, tipo, cantidad, motivo)
      values (v_pid, 'ajuste', 2, v_motivo || ' · Colgate Kids Conejo → 2');
    end if;
    raise notice 'Colgate Kids Conejo ya existía id %', v_pid;
  end if;

  ---------------------------------------------------------------------------
  -- 2) Metformina LP Alpharma 500 mg C/30 · EAN 7502226293929
  --    Recibir: «NO está registrado». Costo form $77.82. «Tampoco son 2» → 1.
  ---------------------------------------------------------------------------
  select id into v_pid
    from public.productos
   where codigo_barras = '7502226293929'
      or sku = 'FC-26293929'
   limit 1;

  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
      from public.create_producto_with_lote(
        jsonb_build_object(
          'nombre', 'Metformina LP 500 mg',
          'sku', 'FC-26293929',
          'codigo_barras', '7502226293929',
          'categoria', 'Medicamentos',
          'tipo', 'generico',
          'descripcion', v_motivo || ' · Alpharma · Caja con 30 tabletas LP · no estaba en catálogo',
          'costo', 77.82,
          'precio', round((77.82 * 1.60)::numeric, 2),
          'stock_minimo', 2,
          'activo', true,
          'requiere_receta', true
        ),
        1,
        'INV-CONTEO-20261015-R',
        null::date,
        77.82,
        null::bigint
      ) f;

    update public.productos set
      marca = 'Alpharma',
      presentacion = 'Caja con 30 tabletas',
      concentracion = '500 mg',
      principio_activo = 'Metformina',
      forma_farmaceutica = 'Tabletas de liberación prolongada',
      subcategoria = 'Diabetes',
      laboratorio = 'Alpharma'
    where id = v_pid;

    raise notice 'ALTA Metformina LP Alpharma id %', v_pid;
  else
    update public.productos set
      sku = coalesce(nullif(btrim(sku), ''), 'FC-26293929'),
      codigo_barras = '7502226293929',
      nombre = coalesce(nullif(btrim(nombre), ''), 'Metformina LP 500 mg'),
      marca = coalesce(nullif(btrim(marca), ''), 'Alpharma'),
      presentacion = 'Caja con 30 tabletas',
      concentracion = '500 mg',
      principio_activo = 'Metformina',
      forma_farmaceutica = 'Tabletas de liberación prolongada',
      tipo = 'generico',
      costo = coalesce(nullif(costo, 0), 77.82),
      precio = case
        when coalesce(precio, 0) <= 1 then round((77.82 * 1.60)::numeric, 2)
        else precio
      end,
      activo = true,
      requiere_receta = true
    where id = v_pid;

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
        ) values (v_pid, 'INV-CONTEO-20261015-R', 1, 1, null, v_costo, true);
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
      values (v_pid, 'ajuste', 1, v_motivo || ' · Metformina LP → 1');
    end if;
    raise notice 'Metformina LP ya existía id %', v_pid;
  end if;

  ---------------------------------------------------------------------------
  -- 3) Amcef IV Ceftriaxona 1 g / 10 ml · EAN 7501349012011
  --    Distinto de Amcef IM 1 g (7501349012004 / FC-BE76D409).
  --    Form Recibir: costo $19.80. Físico ~1 caja en fotos.
  ---------------------------------------------------------------------------
  select id into v_pid
    from public.productos
   where codigo_barras = '7501349012011'
      or sku = 'FC-49012011'
   limit 1;

  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
      from public.create_producto_with_lote(
        jsonb_build_object(
          'nombre', 'Amcef IV Ceftriaxona 1 g',
          'sku', 'FC-49012011',
          'codigo_barras', '7501349012011',
          'categoria', 'Medicamentos',
          'tipo', 'generico',
          'descripcion', v_motivo || ' · AMSA · solución IV 1 g / diluyente 10 ml · no estaba registrado',
          'costo', 19.80,
          'precio', round((19.80 * 1.60)::numeric, 2),
          'stock_minimo', 2,
          'activo', true,
          'requiere_receta', true
        ),
        1,
        'INV-CONTEO-20261015-R',
        null::date,
        19.80,
        null::bigint
      ) f;

    update public.productos set
      marca = 'Amcef',
      presentacion = '1 frasco ámpula + diluyente 10 ml',
      concentracion = '1 g / 10 ml',
      principio_activo = 'Ceftriaxona',
      forma_farmaceutica = 'Solución inyectable',
      subcategoria = 'Antibiótico',
      laboratorio = 'AMSA'
    where id = v_pid;

    raise notice 'ALTA Amcef IV 1 g id %', v_pid;
  else
    update public.productos set
      sku = coalesce(nullif(btrim(sku), ''), 'FC-49012011'),
      codigo_barras = '7501349012011',
      nombre = 'Amcef IV Ceftriaxona 1 g',
      marca = 'Amcef',
      presentacion = coalesce(nullif(btrim(presentacion), ''), '1 frasco ámpula + diluyente 10 ml'),
      concentracion = '1 g / 10 ml',
      principio_activo = 'Ceftriaxona',
      forma_farmaceutica = 'Solución inyectable',
      tipo = 'generico',
      costo = coalesce(nullif(costo, 0), 19.80),
      precio = case
        when coalesce(precio, 0) <= 1 then round((19.80 * 1.60)::numeric, 2)
        else precio
      end,
      activo = true,
      requiere_receta = true
    where id = v_pid;
    raise notice 'Amcef IV 1 g ya existía id %', v_pid;
  end if;

  ---------------------------------------------------------------------------
  -- 4) Tabcin efervescente exhibidor C/60 (324 mg) · EAN 7501008485378
  --    Ya aparece en POS como FC-08485378 · alta si falta.
  ---------------------------------------------------------------------------
  select id into v_pid
    from public.productos
   where codigo_barras = '7501008485378'
      or sku = 'FC-08485378'
   limit 1;

  if v_pid is null then
    select f.producto_id into v_pid
      from public.create_producto_with_lote(
        jsonb_build_object(
          'nombre', 'Tabcin efervescente',
          'sku', 'FC-08485378',
          'codigo_barras', '7501008485378',
          'categoria', 'Medicamentos',
          'tipo', 'marca',
          'descripcion', v_motivo || ' · Bayer · exhibidor 60 tabletas 324/8/2 mg · venta por pieza',
          'precio', 190,
          'stock_minimo', 1,
          'activo', true,
          'requiere_receta', false
        ),
        0,
        null,
        null::date,
        null::numeric,
        null::bigint
      ) f;

    update public.productos set
      marca = 'Tabcin',
      presentacion = 'Exhibidor con 60 tabletas',
      concentracion = '324 mg / 8 mg / 2 mg',
      principio_activo = 'Ácido acetilsalicílico + Fenilefrina + Clorfenamina',
      forma_farmaceutica = 'Tabletas efervescentes',
      subcategoria = 'Antigripal',
      laboratorio = 'Bayer'
    where id = v_pid;

    raise notice 'ALTA Tabcin exhibidor 324 mg id %', v_pid;
  else
    update public.productos set
      codigo_barras = coalesce(nullif(btrim(codigo_barras), ''), '7501008485378'),
      nombre = coalesce(nullif(btrim(nombre), ''), 'Tabcin efervescente'),
      marca = coalesce(nullif(btrim(marca), ''), 'Tabcin'),
      presentacion = coalesce(nullif(btrim(presentacion), ''), 'Exhibidor con 60 tabletas'),
      activo = true
    where id = v_pid;
  end if;

  ---------------------------------------------------------------------------
  -- 5) Tabcin efervescente exhibidor C/60 (500 mg) · EAN 7501008495339
  --    Caja roja · «ambas a venta por piezas»
  ---------------------------------------------------------------------------
  select id into v_pid
    from public.productos
   where codigo_barras = '7501008495339'
      or sku = 'FC-08495339'
   limit 1;

  if v_pid is null then
    select f.producto_id into v_pid
      from public.create_producto_with_lote(
        jsonb_build_object(
          'nombre', 'Tabcin efervescente 500 mg',
          'sku', 'FC-08495339',
          'codigo_barras', '7501008495339',
          'categoria', 'Medicamentos',
          'tipo', 'marca',
          'descripcion', v_motivo || ' · Bayer · exhibidor 60 tabletas 500/8/2 mg · venta por pieza',
          'precio', 190,
          'stock_minimo', 1,
          'activo', true,
          'requiere_receta', false
        ),
        0,
        null,
        null::date,
        null::numeric,
        null::bigint
      ) f;

    update public.productos set
      marca = 'Tabcin',
      presentacion = 'Exhibidor con 60 tabletas',
      concentracion = '500 mg / 8 mg / 2 mg',
      principio_activo = 'Ácido acetilsalicílico + Fenilefrina + Clorfenamina',
      forma_farmaceutica = 'Tabletas efervescentes',
      subcategoria = 'Antigripal',
      laboratorio = 'Bayer'
    where id = v_pid;

    raise notice 'ALTA Tabcin exhibidor 500 mg id %', v_pid;
  else
    update public.productos set
      codigo_barras = coalesce(nullif(btrim(codigo_barras), ''), '7501008495339'),
      nombre = coalesce(nullif(btrim(nombre), ''), 'Tabcin efervescente 500 mg'),
      marca = coalesce(nullif(btrim(marca), ''), 'Tabcin'),
      presentacion = coalesce(nullif(btrim(presentacion), ''), 'Exhibidor con 60 tabletas'),
      concentracion = coalesce(nullif(btrim(concentracion), ''), '500 mg / 8 mg / 2 mg'),
      activo = true
    where id = v_pid;
  end if;
end $$;

commit;

select sku, left(nombre, 42) as nombre, codigo_barras, costo, precio, stock, requiere_receta
  from public.productos
 where sku in (
   'FC-46073453','FC-26293929','FC-49012011','FC-08485378','FC-08495339'
 )
    or codigo_barras in (
   '7509546073453','7502226293929','7501349012011','7501008485378','7501008495339'
 )
 order by sku;
