-- Corrección post-merge #447 · relectura N–Z del chat Cyntia
-- Metamizol AMSA físico 2 (no 1); Nysmoson físico 2 (no 1); Neuralin físico 1.
-- Nysmoson y Neomicina/Kaolín ya existen (no alta). Idempotente vía lotes.

begin;

do $$
declare
  r record;
  v_pid bigint;
  v_lote bigint;
  v_sum integer;
  v_costo numeric;
  v_motivo text := 'Conteo Cyntia fix N-Z 2026-10-07';
begin
  for r in
    select * from (values
      ('EQ-SON153',   2),  -- Nysmoson's-V: «no estan» plural → 2; ya es EQ-SON153
      ('FC-9022126',  2),  -- Metamizol AMSA EAN 7501349022126
      ('FC-8505126',  1)   -- Neuralin: sistema 2, físico 1
    ) as t(sku, nuevo_stock)
  loop
    select id, costo into v_pid, v_costo
      from public.productos
     where sku = r.sku
        or (r.sku = 'FC-9022126' and codigo_barras = '7501349022126')
     limit 1;

    if v_pid is null then
      raise notice 'SKIP %: aún no está (correr altas #447 primero si aplica)', r.sku;
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
        v_pid, 'INV-CONTEO-20261007-NZ', r.nuevo_stock, r.nuevo_stock,
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

select p.sku, p.nombre, p.stock, p.codigo_barras
  from public.productos p
 where p.sku in ('EQ-SON153', 'FC-9022126', 'FC-8505126')
    or p.codigo_barras = '7501349022126'
 order by p.sku;
