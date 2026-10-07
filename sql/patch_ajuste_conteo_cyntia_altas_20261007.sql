-- Altas desde conteo Cyntia (WhatsApp) · 2026-10-07
-- Piezas físicas que no estaban / no se encontraban al escanear.
-- Idempotente: si ya existe EAN o SKU, solo ajusta stock vía lote.
-- Precio: ancla similar / ticket hermano; costo null hasta compra.
-- Foto: pendiente (TODO packshot) — no se cierra el alta visual.
-- Ver LEERME_ajuste_conteo_cyntia_20261007.md

begin;

do $$
declare
  v_pid bigint;
  v_lid bigint;
  v_sum integer;
  v_costo numeric;
  v_lote bigint;
begin
  ---------------------------------------------------------------------------
  -- 1) Irbesartán AMSA 150 mg C/14 · EAN 7501349022434 · físico 3
  --    Distinto de FC-49022492 (C/28 Lgen) y de Camber + HCTZ.
  ---------------------------------------------------------------------------
  select id into v_pid
    from public.productos
   where codigo_barras = '7501349022434'
      or sku = 'FC-9022434'
   limit 1;

  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
      from public.create_producto_with_lote(
        jsonb_build_object(
          'nombre', 'Irbesartán 150 mg',
          'sku', 'FC-9022434',
          'codigo_barras', '7501349022434',
          'categoria', 'Medicamentos',
          'tipo', 'generico',
          'descripcion', 'Conteo Cyntia 2026-10-07 · AMSA · Caja con 14 tabletas · no estaba en sistema',
          'precio', 71,
          'stock_minimo', 2,
          'activo', true,
          'requiere_receta', false
        ),
        3,
        'INV-CONTEO-20261007',
        null::date,
        null::numeric,
        null::bigint
      ) f;

    update public.productos set
      marca = 'AMSA',
      presentacion = 'Caja con 14 tabletas',
      concentracion = '150 mg',
      principio_activo = 'Irbesartán',
      forma_farmaceutica = 'Tabletas',
      subcategoria = 'Cardiovascular'
    where id = v_pid;

    raise notice 'ALTA Irbesartán AMSA C/14 id %', v_pid;
  else
    -- ya existe: llevar stock a 3
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
        ) values (v_pid, 'INV-CONTEO-20261007', 3, 3, null, v_costo, true);
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
      values (v_pid, 'ajuste', 3, 'Conteo Cyntia 2026-10-07 · Irbesartán AMSA C/14 → 3');
    end if;
    raise notice 'Irbesartán AMSA C/14 ya existía id %', v_pid;
  end if;

  ---------------------------------------------------------------------------
  -- 2) Itoprida Avivid 50 mg · EAN 7503049078205 · físico 3
  --    Distinto de Lapriver Itoprida (7502009747328).
  ---------------------------------------------------------------------------
  select id into v_pid
    from public.productos
   where codigo_barras = '7503049078205'
      or sku = 'FC-49078205'
   limit 1;

  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
      from public.create_producto_with_lote(
        jsonb_build_object(
          'nombre', 'Itoprida 50 mg',
          'sku', 'FC-49078205',
          'codigo_barras', '7503049078205',
          'categoria', 'Medicamentos',
          'tipo', 'generico',
          'descripcion', 'Conteo Cyntia 2026-10-07 · Avivid · no estaba en sistema',
          'precio', 0,
          'stock_minimo', 2,
          'activo', true,
          'requiere_receta', false
        ),
        3,
        'INV-CONTEO-20261007',
        null::date,
        null::numeric,
        null::bigint
      ) f;

    update public.productos set
      marca = 'Avivid',
      presentacion = 'Caja con tabletas',
      concentracion = '50 mg',
      principio_activo = 'Itoprida',
      forma_farmaceutica = 'Tabletas',
      subcategoria = 'Gastro'
    where id = v_pid;

    raise notice 'ALTA Itoprida Avivid id % · TODO precio/foto', v_pid;
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
        ) values (v_pid, 'INV-CONTEO-20261007', 3, 3, null, v_costo, true);
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
      values (v_pid, 'ajuste', 3, 'Conteo Cyntia 2026-10-07 · Itoprida Avivid → 3');
    end if;
    raise notice 'Itoprida Avivid ya existía id %', v_pid;
  end if;

  ---------------------------------------------------------------------------
  -- 3) Ketorolaco Trometamina Advance 10 mg C/10 · EAN 7501342802213 · físico 6
  ---------------------------------------------------------------------------
  select id into v_pid
    from public.productos
   where codigo_barras = '7501342802213'
      or sku = 'FC-42802213'
   limit 1;

  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
      from public.create_producto_with_lote(
        jsonb_build_object(
          'nombre', 'Ketorolaco Trometamina 10 mg',
          'sku', 'FC-42802213',
          'codigo_barras', '7501342802213',
          'categoria', 'Medicamentos',
          'tipo', 'generico',
          'descripcion', 'Conteo Cyntia 2026-10-07 · Advance / Novag · Caja con 10 tabletas · no estaba en sistema',
          'precio', 35,
          'stock_minimo', 3,
          'activo', true,
          'requiere_receta', false
        ),
        6,
        'INV-CONTEO-20261007',
        null::date,
        null::numeric,
        null::bigint
      ) f;

    update public.productos set
      marca = 'Advance',
      presentacion = 'Caja con 10 tabletas',
      concentracion = '10 mg',
      principio_activo = 'Ketorolaco trometamina',
      forma_farmaceutica = 'Tabletas',
      subcategoria = 'Analgésico'
    where id = v_pid;

    raise notice 'ALTA Ketorolaco Advance 10 mg C/10 id % · TODO foto', v_pid;
  else
    select costo into v_costo from public.productos where id = v_pid;
    select coalesce(sum(cantidad_actual), 0) into v_sum
      from public.lotes where producto_id = v_pid and coalesce(activo, true);
    if v_sum is distinct from 6 then
      select id into v_lote from public.lotes
       where producto_id = v_pid
       order by coalesce(activo, true) desc, coalesce(cantidad_actual, 0) desc, id desc
       limit 1;
      if v_lote is null then
        insert into public.lotes (
          producto_id, numero_lote, cantidad_inicial, cantidad_actual,
          fecha_caducidad, costo_unitario, activo
        ) values (v_pid, 'INV-CONTEO-20261007', 6, 6, null, v_costo, true);
      else
        update public.lotes set cantidad_actual = 0, activo = false
         where producto_id = v_pid and id <> v_lote
           and coalesce(activo, true) and coalesce(cantidad_actual, 0) > 0;
        update public.lotes
           set cantidad_actual = 6, activo = true,
               cantidad_inicial = greatest(coalesce(cantidad_inicial, 0), 6)
         where id = v_lote;
      end if;
      insert into public.movimientos_inventario (producto_id, tipo, cantidad, motivo)
      values (v_pid, 'ajuste', 6, 'Conteo Cyntia 2026-10-07 · Ketorolaco Advance → 6');
    end if;
    raise notice 'Ketorolaco Advance ya existía id %', v_pid;
  end if;

  ---------------------------------------------------------------------------
  -- 4) Metamizol sódico AMSA 1 g/2 ml C/3 amp · EAN 7501349022126 · físico 1
  --    Distinto de Alpharma EQ-ALP0628 (EAN 7502226293776).
  ---------------------------------------------------------------------------
  select id into v_pid
    from public.productos
   where codigo_barras = '7501349022126'
      or sku = 'FC-9022126'
   limit 1;

  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
      from public.create_producto_with_lote(
        jsonb_build_object(
          'nombre', 'Metamizol sódico 1 g / 2 mL',
          'sku', 'FC-9022126',
          'codigo_barras', '7501349022126',
          'categoria', 'Medicamentos',
          'tipo', 'generico',
          'descripcion', 'Conteo Cyntia 2026-10-07 · AMSA / PiSA · Caja con 3 ampolletas · no estaba en sistema',
          'precio', 32,
          'stock_minimo', 2,
          'activo', true,
          'requiere_receta', true
        ),
        1,
        'INV-CONTEO-20261007',
        null::date,
        null::numeric,
        null::bigint
      ) f;

    update public.productos set
      marca = 'AMSA',
      presentacion = 'Caja con 3 ampolletas',
      concentracion = '1 g / 2 mL',
      principio_activo = 'Metamizol sódico',
      forma_farmaceutica = 'Solución inyectable',
      subcategoria = 'Analgésico',
      requiere_receta = true
    where id = v_pid;

    raise notice 'ALTA Metamizol AMSA C/3 amp id % · TODO foto', v_pid;
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
        ) values (v_pid, 'INV-CONTEO-20261007', 1, 1, null, v_costo, true);
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
      values (v_pid, 'ajuste', 1, 'Conteo Cyntia 2026-10-07 · Metamizol AMSA → 1');
    end if;
    raise notice 'Metamizol AMSA ya existía id %', v_pid;
  end if;
end $$;

commit;

select p.sku, p.nombre, p.marca, p.presentacion, p.codigo_barras,
       p.precio, p.stock, p.requiere_receta
  from public.productos p
 where p.sku in ('FC-9022434', 'FC-49078205', 'FC-42802213', 'FC-9022126')
    or p.codigo_barras in (
      '7501349022434', '7503049078205', '7501342802213', '7501349022126'
    )
 order by p.sku;
