-- Topron C/16 (FC-88579615) · 2026-10-24
-- Pegar en Supabase → SQL Editor.
--
-- Problema: stock = 1 caja (correcto) pero stock_unidades = 16
-- (sueltas fantasma = C/16 metido como “caja abierta”). El POS pintaba
-- «16 pzas» aunque en anaquel solo hay una caja cerrada.
--
-- Qué hace:
-- 1) Pone stock_unidades / stock_blisters en 0.
-- 2) Deja exactamente 1 caja en lotes activos (reactiva o crea si hace falta).
-- 3) El trigger resincroniza productos.stock = 1.
--
-- Idempotente. No inventa caducidad (usa 2028-02-28 solo si hay que crear lote
-- y ya existía esa fecha en restauraciones previas; si hay lote, no toca la fecha).

begin;

do $$
declare
  v_pid bigint;
  v_lote bigint;
  v_sum integer;
  v_costo numeric;
  v_sueltas integer;
  v_motivo text := 'Corrección Topron: caja cerrada, sin sueltas fantasma 2026-10-24';
begin
  select id, costo, coalesce(stock_unidades, 0)
    into v_pid, v_costo, v_sueltas
    from public.productos
   where sku = 'FC-88579615'
      or codigo_barras in ('7501088579615', '75010885796150')
   order by case when sku = 'FC-88579615' then 0 else 1 end
   limit 1;

  if v_pid is null then
    raise exception 'Topron FC-88579615 no está en productos';
  end if;

  update public.productos
     set stock_unidades = 0,
         stock_blisters = 0
   where id = v_pid
     and (coalesce(stock_unidades, 0) <> 0 or coalesce(stock_blisters, 0) <> 0);

  select coalesce(sum(l.cantidad_actual), 0) into v_sum
    from public.lotes l
   where l.producto_id = v_pid
     and coalesce(l.activo, true);

  if v_sum = 1 then
    raise notice 'OK Topron: lotes ya en 1; sueltas limpiadas (antes %)', v_sueltas;
  else
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
        v_pid, 'INV-TOPRON-20261024', 1, 1,
        '2028-02-28'::date, v_costo, true
      )
      returning id into v_lote;
    else
      update public.lotes
         set cantidad_actual = 0,
             activo = false
       where producto_id = v_pid
         and id <> v_lote
         and coalesce(activo, true)
         and coalesce(cantidad_actual, 0) > 0;

      update public.lotes
         set cantidad_actual = 1,
             activo = true,
             cantidad_inicial = greatest(coalesce(cantidad_inicial, 0), 1)
       where id = v_lote;
    end if;

    insert into public.movimientos_inventario (
      producto_id, tipo, cantidad, motivo
    ) values (
      v_pid, 'ajuste', 1, v_motivo || ' · lotes ' || v_sum || ' → 1'
    );

    raise notice 'AJUSTE Topron: lotes % → 1; sueltas % → 0', v_sum, v_sueltas;
  end if;
end $$;

commit;

-- Verificación
select p.id, p.sku, p.nombre, p.stock, p.stock_unidades, p.stock_blisters,
       p.venta_unidad, p.unidades_por_caja, p.precio, p.precio_unidad,
       coalesce(sum(l.cantidad_actual) filter (where coalesce(l.activo, true)), 0) as lotes_activos
  from public.productos p
  left join public.lotes l on l.producto_id = p.id
 where p.sku = 'FC-88579615'
    or p.codigo_barras = '7501088579615'
 group by p.id;
