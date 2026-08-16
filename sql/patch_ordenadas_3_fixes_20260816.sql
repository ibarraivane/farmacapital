-- ============================================================================
-- FARMA CAPITAL — 3 correcciones de la carpeta ordenadas (16-ago-2026)
--
-- No toca el resto del catálogo. Solo:
--   1. Renombra FC-24901059: deja de ser el fantasma [REVISAR-EAN] Novag
--      y pasa a beadvance Senósidos A-B 8.6 mg (EAN 7506624901059).
--   2. Renombra FC-75717914: K-PEC → Nineka (el frasco de la foto 0063 y
--      el lote 460056 del ticket son Nineka, no K-PEC). Si el precio sigue
--      en 0, le pone el provisional ceil(costo*1.6).
--   3. Da de alta Dexpantenol crema 5% 30 g Maver Tattoo (7502009749421),
--      que no estaba. Costo, lote y cantidad salen de Equilibrio MAV401.
--      No es el Pamedan (7502009745997): misma crema, otra caja.
--
-- Idempotente. No va en transacción: si algo truena a la mitad, lo demás
-- ya quedó. Se puede correr otra vez.
-- ============================================================================

-- ---------------------------------------------------------------------------
-- 1) beadvance: quitar el nombre de cuarentena
-- ---------------------------------------------------------------------------
update public.productos
set
  nombre = 'beadvance Senósidos A-B 8.6 mg',
  descripcion = 'Novag Infancia · Caja con 20 tabletas · EAN 7506624901059 · antes [REVISAR-EAN] Producto Novag Reg. 410M2016'
where codigo_barras = '7506624901059'
  and nombre like '[REVISAR-EAN]%';

-- ---------------------------------------------------------------------------
-- 2) Nineka: el EAN y el costo ya eran de ella; el nombre no
-- ---------------------------------------------------------------------------
update public.productos
set
  nombre = 'Nineka suspensión neomicina/caolín/pectina',
  descripcion = 'Novag · Frasco 75 mL con vaso dosificador · EAN 7501075717914 · el lote 460056 del ticket Equilibrio es Nineka, no K-PEC',
  precio = case when coalesce(precio, 0) = 0 then ceil(costo * 1.6) else precio end
where codigo_barras = '7501075717914'
  and nombre ilike '%k-pec%';

-- ---------------------------------------------------------------------------
-- 3) Alta Dexpantenol Tattoo · Equilibrio MAV401
--    2 pzas · lote 252304 · cad 2027-05-01 · costo 14.12
-- ---------------------------------------------------------------------------
do $alta$
declare
  v_pid   bigint;
  v_sku   text;
  v_sufijo integer := 0;
  v_cols  text;
  v_vals  text;
  v_set   text;
begin
  select id into v_pid
  from public.productos
  where codigo_barras = '7502009749421'
  limit 1;

  if v_pid is null then
    v_sku := 'FC-09749421';
    while exists (select 1 from public.productos where sku = v_sku) loop
      v_sufijo := v_sufijo + 1;
      v_sku := 'FC-09749421-' || v_sufijo;
    end loop;

    insert into public.productos
      (nombre, sku, codigo_barras, categoria, tipo, descripcion,
       costo, precio, stock, stock_minimo, activo, requiere_receta)
    values
      ('Dexpantenol crema 5% 30 g (Maver Tattoo)',
       v_sku, '7502009749421', 'Medicamentos', 'marca',
       'Maver · Caja con tubo 30 g · EAN 7502009749421 · ticket Equilibrio MAV401 · no es Pamedan',
       14.12, ceil(14.12 * 1.6), 0, 1, true, false)
    returning id into v_pid;

    raise notice 'Dexpantenol Tattoo CREADO · id % sku %', v_pid, v_sku;
  else
    update public.productos
       set costo = 14.12,
           precio = case when coalesce(precio, 0) = 0 then ceil(14.12 * 1.6) else precio end,
           activo = true
     where id = v_pid
       and coalesce(costo, 0) = 0;
    raise notice 'Dexpantenol Tattoo ya existía · id %', v_pid;
  end if;

  -- columnas opcionales, si este ambiente las tiene
  v_set := null;
  if exists (select 1 from information_schema.columns
             where table_schema = 'public' and table_name = 'productos'
               and column_name = 'marca') then
    v_set := concat_ws(', ', v_set, 'marca = coalesce(marca, ''Maver'')');
  end if;
  if exists (select 1 from information_schema.columns
             where table_schema = 'public' and table_name = 'productos'
               and column_name = 'presentacion') then
    v_set := concat_ws(', ', v_set, 'presentacion = coalesce(presentacion, ''Caja con tubo 30 g'')');
  end if;
  if exists (select 1 from information_schema.columns
             where table_schema = 'public' and table_name = 'productos'
               and column_name = 'principio_activo') then
    v_set := concat_ws(', ', v_set, 'principio_activo = coalesce(principio_activo, ''Dexpantenol 5%'')');
  end if;
  if exists (select 1 from information_schema.columns
             where table_schema = 'public' and table_name = 'productos'
               and column_name = 'proveedor') then
    v_set := concat_ws(', ', v_set, 'proveedor = coalesce(proveedor, ''EQUILIBRIO FARMACEUTICO'')');
  end if;
  if v_set is not null then
    execute format('update public.productos set %s where id = %s', v_set, v_pid);
  end if;

  if not exists (
    select 1 from public.lotes
    where producto_id = v_pid and numero_lote = '252304'
  ) then
    v_cols := 'producto_id, numero_lote, cantidad_actual, fecha_caducidad, costo_unitario';
    v_vals := v_pid || ', ''252304'', 2, ''2027-05-01''::date, 14.12';

    if exists (select 1 from information_schema.columns
               where table_schema = 'public' and table_name = 'lotes'
                 and column_name = 'cantidad_inicial') then
      v_cols := v_cols || ', cantidad_inicial';
      v_vals := v_vals || ', 2';
    end if;
    if exists (select 1 from information_schema.columns
               where table_schema = 'public' and table_name = 'lotes'
                 and column_name = 'activo') then
      v_cols := v_cols || ', activo';
      v_vals := v_vals || ', true';
    end if;

    execute format('insert into public.lotes (%s) values (%s)', v_cols, v_vals);
    raise notice 'Dexpantenol Tattoo · lote 252304 x2';
  end if;

  update public.productos p
  set stock = coalesce((
    select sum(l.cantidad_actual)
    from public.lotes l
    where l.producto_id = p.id and coalesce(l.activo, true)
  ), 0)
  where p.id = v_pid;
end
$alta$;

-- ---------------------------------------------------------------------------
-- Comprobación
-- ---------------------------------------------------------------------------
select sku, nombre, codigo_barras, costo, precio, stock, activo
from public.productos
where codigo_barras in ('7506624901059', '7501075717914', '7502009749421')
order by codigo_barras;
