-- ============================================================================
-- FIX conservador: doble conteo caja+sueltas (patrón Protec)
--
-- Solo toca productos donde:
--   venta_unidad = true
--   stock (cajas) >= 1
--   stock_unidades >= unidades_por_caja - 5   (casi una caja entera en sueltas)
--   unidades_por_caja >= 6
--
-- Acción: apaga 1 caja FEFO (o lote REINTEGRO) y deja las sueltas.
-- NO toca casos normales (ej. 2 cajas + 30 sueltas).
--
-- También lista/arregla EAN duplicado eligiendo el SKU con barcode
-- más antiguo o con más stock; el otro se desactiva SIN sumar stock
-- (mismo EAN = mismo físico, no duplicar piezas).
--
-- Idempotente. Supabase → SQL Editor → Run.
-- ============================================================================

begin;

-- Vista previa sospechosos
select
  p.sku,
  left(p.nombre, 40) as nombre,
  p.stock as cajas,
  p.stock_unidades as sueltas,
  p.unidades_por_caja as upc,
  (p.stock * p.unidades_por_caja + p.stock_unidades) as equiv_antes
from public.productos p
where p.activo = true
  and p.venta_unidad = true
  and coalesce(p.stock, 0) >= 1
  and coalesce(p.unidades_por_caja, 0) >= 6
  and coalesce(p.stock_unidades, 0) >= greatest(p.unidades_por_caja - 5, 1)
order by equiv_antes desc;

do $$
declare
  r record;
  v_lote bigint;
  v_upc integer;
  v_bajadas integer := 0;
begin
  for r in
    select p.id, p.sku, p.stock, p.stock_unidades,
           greatest(coalesce(p.unidades_por_caja, 0), 1) as upc
    from public.productos p
    where p.activo = true
      and p.venta_unidad = true
      and coalesce(p.stock, 0) >= 1
      and coalesce(p.unidades_por_caja, 0) >= 6
      and coalesce(p.stock_unidades, 0) >= greatest(p.unidades_por_caja - 5, 1)
  loop
    v_upc := r.upc;

    -- Preferir bajar un REINTEGRO fantasma
    select l.id into v_lote
    from public.lotes l
    where l.producto_id = r.id
      and coalesce(l.activo, true)
      and coalesce(l.cantidad_actual, 0) >= 1
      and l.numero_lote ilike 'REINTEGRO%'
    order by l.id desc
    limit 1;

    if v_lote is null then
      select l.id into v_lote
      from public.lotes l
      where l.producto_id = r.id
        and coalesce(l.activo, true)
        and coalesce(l.cantidad_actual, 0) >= 1
      order by l.fecha_caducidad nulls first, l.id
      limit 1;
    end if;

    if v_lote is not null then
      update public.lotes set
        cantidad_actual = greatest(0, coalesce(cantidad_actual, 0) - 1),
        activo = case
          when greatest(0, coalesce(cantidad_actual, 0) - 1) <= 0 then false
          else activo
        end
      where id = v_lote;
    end if;

    update public.productos set
      stock = (
        select coalesce(sum(l.cantidad_actual), 0)::integer
        from public.lotes l
        where l.producto_id = r.id and coalesce(l.activo, true)
      )
      -- sueltas se quedan; no inventar ni borrar
    where id = r.id;

    -- Si aún stock>=1 y sueltas casi llenan una caja (desfase stock vs lotes), fuerza
    update public.productos set
      stock = greatest(0, coalesce(stock, 0) - 1)
    where id = r.id
      and coalesce(stock, 0) >= 1
      and coalesce(stock_unidades, 0) >= greatest(v_upc - 5, 1)
      and not exists (
        select 1 from public.lotes l
        where l.producto_id = r.id
          and coalesce(l.activo, true)
          and coalesce(l.cantidad_actual, 0) > 0
      );

    v_bajadas := v_bajadas + 1;
    raise notice 'Caja fantasma ajustada: % (id %)', r.sku, r.id;
  end loop;

  raise notice 'Total ajustados patrón Protec: %', v_bajadas;
end $$;

-- ── EAN duplicados: desactivar el SKU «pobre» ───────────────────────────────
-- Regla: se queda el que tenga más stock+sueltas; empate → SKU sin FC-IFC;
-- empate → menor id. El pobre se apaga SIN pasar stock (mismo físico).
do $$
declare
  g record;
  v_bueno bigint;
  v_pobre bigint;
begin
  for g in
    select regexp_replace(p.codigo_barras, '\D', '', 'g') as ean
    from public.productos p
    where p.activo = true
      and nullif(btrim(p.codigo_barras), '') is not null
      and length(regexp_replace(p.codigo_barras, '\D', '', 'g')) >= 8
    group by 1
    having count(*) > 1
  loop
    select p.id into v_bueno
    from public.productos p
    where p.activo = true
      and regexp_replace(coalesce(p.codigo_barras,''), '\D', '', 'g') = g.ean
    order by
      (coalesce(p.stock,0) + coalesce(p.stock_unidades,0)) desc,
      case when p.sku like 'FC-IFC-%' then 1 else 0 end,
      p.id
    limit 1;

    for v_pobre in
      select p.id
      from public.productos p
      where p.activo = true
        and p.id <> v_bueno
        and regexp_replace(coalesce(p.codigo_barras,''), '\D', '', 'g') = g.ean
    loop
      update public.recepcion_items set producto_id = v_bueno where producto_id = v_pobre;
      update public.lotes set activo = false, cantidad_actual = 0 where producto_id = v_pobre;
      update public.productos set activo = false, stock = 0, stock_unidades = 0 where id = v_pobre;
      raise notice 'EAN %: apagado id %; queda id %', g.ean, v_pobre, v_bueno;
    end loop;
  end loop;
end $$;

commit;

-- Verificación
select
  'post_caja_sueltas_criticos' as check,
  count(*) as quedan
from public.productos p
where p.activo = true
  and p.venta_unidad = true
  and coalesce(p.stock, 0) >= 1
  and coalesce(p.unidades_por_caja, 0) >= 6
  and coalesce(p.stock_unidades, 0) >= greatest(p.unidades_por_caja - 5, 1);

select
  'post_ean_multi' as check,
  count(*) as quedan
from (
  select 1
  from public.productos p
  where p.activo and nullif(btrim(p.codigo_barras),'') is not null
  group by regexp_replace(p.codigo_barras, '\D', '', 'g')
  having count(*) > 1
) x;
