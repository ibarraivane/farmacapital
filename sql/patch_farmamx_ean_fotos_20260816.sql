-- ============================================================================
-- FARMA CAPITAL — Farma MX: EAN de fotos + altas que el ticket saltó
--
-- La carga 108588 no creó estas líneas (había varios con el mismo arranque
-- de nombre). Las fotos ya traen el código de barras.
--
-- Precio = ceil(costo*1.6), provisional. Ibarra corrige a mano.
-- Idempotente. No va en transacción.
-- ============================================================================

-- 1) Aceite manzanilla: ya existe FMX-301516, pero con otro EAN
update public.productos
set
  codigo_barras = '759684154881',
  nombre = 'Aceite bebé Jaloma manzanilla y caléndula 120 ml'
where sku = 'FMX-301516'
  and coalesce(codigo_barras, '') in ('', '759684154157');

-- 2) Altas nuevas (solo si no está el SKU ni el EAN)
do $alta$
declare
  r record;
  v_pid bigint;
  v_sku text;
  v_cols text;
  v_vals text;
begin
  for r in
    select * from (values
      -- sku, ean, nombre, costo, qty, lote, cad
      ('FMX-301139', '7506484500539',
       'Cintapore cinta microporosa 1.25 cm x 5 m piel',
       5.77, 5, '251102-1', '2030-11-01'::date),
      ('FMX-503473', '7502259890096',
       'Lactiv Kids tabletas masticables uva C/30',
       28.48, 1, '260915', '2028-02-01'::date),
      ('FMX-307574', '759684154935',
       'Aceite bebé Jaloma lavanda 120 ml',
       17.98, 1, '0158001', '2028-03-01'::date),
      ('FMX-501200', '7502009740305',
       'Laritol loratadina solución 1 mg/ml 60 ml',
       20.67, 1, '263503', '2028-06-01'::date),
      ('FMX-506779', '7506022316615',
       'Catéter Sumitex 20G x 33 mm rosa',
       9.26, 3, '3211825F', '2030-05-31'::date)
    ) as t(sku, ean, nombre, costo, qty, lote, cad)
  loop
    select id into v_pid from public.productos
     where sku = r.sku or codigo_barras = r.ean
     limit 1;

    if v_pid is null then
      insert into public.productos
        (nombre, sku, codigo_barras, categoria, tipo, descripcion,
         costo, precio, stock, stock_minimo, activo, requiere_receta)
      values
        (r.nombre, r.sku, r.ean, 'Medicamentos', 'marca',
         'Farma MX CAICA1CA108588 · clave ' || replace(r.sku, 'FMX-', '')
           || ' · EAN de foto · precio provisional ceil(costo*1.6)',
         r.costo, ceil(r.costo * 1.6),
         0, 1, true, false)
      returning id into v_pid;
      raise notice 'CREADO % id %', r.sku, v_pid;
    else
      update public.productos
         set codigo_barras = coalesce(nullif(codigo_barras, ''), r.ean)
       where id = v_pid
         and coalesce(codigo_barras, '') = '';
      raise notice 'YA EXISTÍA % id %', r.sku, v_pid;
    end if;

    if r.lote is not null and not exists (
      select 1 from public.lotes
      where producto_id = v_pid and numero_lote = r.lote
    ) then
      v_cols := 'producto_id, numero_lote, cantidad_actual, fecha_caducidad, costo_unitario';
      v_vals := v_pid || ', ' || quote_literal(r.lote) || ', ' || r.qty
                || ', ' || quote_literal(r.cad::text) || '::date, ' || r.costo;
      if exists (select 1 from information_schema.columns
                 where table_schema = 'public' and table_name = 'lotes'
                   and column_name = 'cantidad_inicial') then
        v_cols := v_cols || ', cantidad_inicial';
        v_vals := v_vals || ', ' || r.qty;
      end if;
      if exists (select 1 from information_schema.columns
                 where table_schema = 'public' and table_name = 'lotes'
                   and column_name = 'activo') then
        v_cols := v_cols || ', activo';
        v_vals := v_vals || ', true';
      end if;
      execute format('insert into public.lotes (%s) values (%s)', v_cols, v_vals);
    end if;
  end loop;

  -- segundo lote del aceite lavanda (el ticket trajo dos)
  select id into v_pid from public.productos where sku = 'FMX-307574' limit 1;
  if v_pid is not null and not exists (
    select 1 from public.lotes where producto_id = v_pid and numero_lote = '0161683'
  ) then
    v_cols := 'producto_id, numero_lote, cantidad_actual, fecha_caducidad, costo_unitario';
    v_vals := v_pid || ', ''0161683'', 1, ''2028-06-01''::date, 17.98';
    if exists (select 1 from information_schema.columns
               where table_schema = 'public' and table_name = 'lotes'
                 and column_name = 'cantidad_inicial') then
      v_cols := v_cols || ', cantidad_inicial';
      v_vals := v_vals || ', 1';
    end if;
    if exists (select 1 from information_schema.columns
               where table_schema = 'public' and table_name = 'lotes'
                 and column_name = 'activo') then
      v_cols := v_cols || ', activo';
      v_vals := v_vals || ', true';
    end if;
    execute format('insert into public.lotes (%s) values (%s)', v_cols, v_vals);
  end if;
end
$alta$;

-- Stock = suma de lotes de estos SKU
update public.productos p
set stock = coalesce(t.total, p.stock)
from (
  select l.producto_id, sum(l.cantidad_actual) as total
  from public.lotes l
  where coalesce(l.activo, true)
  group by l.producto_id
) t
where p.id = t.producto_id
  and p.sku in ('FMX-301139','FMX-503473','FMX-307574','FMX-501200','FMX-506779','FMX-301516');

-- Comprobación
select sku, nombre, codigo_barras, costo, precio, stock
from public.productos
where sku in ('FMX-301139','FMX-503473','FMX-307574','FMX-501200','FMX-506779','FMX-301516')
order by sku;
