-- Conteo físico Raquel (WhatsApp) · 2026-10-07 lote 3
-- Pregabalina pistola sin EAN · Pabesorag 8→11 · Roxidolin sin lotes→1
-- Idempotente. No inventa caducidad.
-- Ver LEERME_ajuste_conteo_raquel_lote3_20261007.md

begin;

-- ---------------------------------------------------------------------------
-- Pregabalina 150 mg AMSA C/28 · EQ-AMS234 · EAN caja 7501349022935
-- Raquel: «no está con el código escaneado, solo aparece con nombre» · 1 pza
-- ---------------------------------------------------------------------------
update public.productos p
   set codigo_barras = null
 where p.codigo_barras = '7501349022935'
   and p.sku is distinct from 'EQ-AMS234';

update public.productos
   set codigo_barras = '7501349022935',
       -- Dosis en nombre; C/28 en presentación (nombre-ficha-partida)
       nombre = 'Pregabalina 150 mg',
       marca = coalesce(nullif(btrim(marca), ''), 'AMSA'),
       presentacion = 'Caja con 28 cápsulas',
       concentracion = '150 mg',
       principio_activo = coalesce(nullif(btrim(principio_activo), ''), 'Pregabalina'),
       forma_farmaceutica = coalesce(nullif(btrim(forma_farmaceutica), ''), 'Cápsulas'),
       tipo = coalesce(nullif(btrim(tipo), ''), 'generico'),
       activo = true
 where sku = 'EQ-AMS234';

-- ---------------------------------------------------------------------------
-- Stock vía lotes (mismo patrón que lote 2)
-- ---------------------------------------------------------------------------
do $$
declare
  r record;
  v_pid bigint;
  v_lote bigint;
  v_sum integer;
  v_costo numeric;
  v_motivo text := 'Conteo físico Raquel WhatsApp 2026-10-07 lote 3';
begin
  for r in
    select * from (values
      ('EQ-AMS234',   1),   -- Pregabalina 150 mg AMSA (pistola + 1 pza)
      ('FC-5885E577', 11),  -- Pabesorag 150/12.5 · sistema 8, físico 11
      ('FC-27870259', 1)    -- Roxidolin Doxiciclina 100 mg · SIN LOTES → 1
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
        v_pid, 'INV-CONTEO-20261007-R3', r.nuevo_stock, r.nuevo_stock,
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

commit;

select p.sku, p.nombre, p.stock, p.codigo_barras, p.presentacion, p.precio,
       coalesce((
         select sum(l.cantidad_actual)
           from public.lotes l
          where l.producto_id = p.id and coalesce(l.activo, true)
       ), 0) as stock_lotes
  from public.productos p
 where p.sku in ('EQ-AMS234', 'FC-5885E577', 'FC-27870259')
    or p.codigo_barras = '7501349022935'
 order by p.sku;
