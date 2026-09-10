-- Jeringa Sensi Medical 3 mL 22G x 32 mm negra (FC-22300775 / EAN 7506022300775)
--
-- Qué pasó (producción 10-sep-2026):
--   El SKU es la PIEZA (como la insulina 1 mL, que ya está en 99).
--   Farma MX 108588 compró 1 caja C/100 ($155 → $1.40 c/u).
--   En ficha quedó stock=1 (la caja) y stock_unidades=100, con venta_unidad=false.
--   El POS, sin venta_unidad, cobra contra lotes/stock. Vendieron 1 pieza
--   y el lote 1→0. Las 100 de stock_unidades no las mira nadie.
--   Por eso el mostrador ve 0 y la caja sigue llena.
--
-- Este patch:
--   1) Restaura el lote a 99 piezas (100 de la caja − 1 vendida).
--   2) Apaga stock_unidades / venta_unidad (el SKU ya es la pieza).
--   3) Corrige la misma trampa en 5 mL negra y 10 mL negra (aún no vendidas).
--
-- No toca la 3 mL verde (FMX-506388): esa sí tiene venta_unidad=true.
-- Idempotente. Pegar TODO en Supabase → SQL Editor → Run.

begin;

do $$
declare
  r record;
  v_pid bigint;
  v_lid bigint;
  v_sum int;
  v_stock int;
  v_su int;
  v_vu boolean;
  v_motivo text;
begin
  for r in
    select * from (values
      -- sku, ean, piezas objetivo, lote ticket, cad, costo pieza, motivo
      (
        'FC-22300775'::text, '7506022300775'::text, 99,
        '2506885602'::text, '2030-06-01'::date, 1.40::numeric,
        'Caja C/100 Farma MX 108588: 1 vendida, quedan 99 piezas'::text
      ),
      (
        'FMX-506386', '7506022300843', 100,
        '2504864004', '2030-04-15', 1.48,
        'Caja C/100 Farma MX 108588: SKU es la pieza, no la caja'
      ),
      (
        'FMX-307657', '7506022300690', 100,
        '2504864301', '2030-04-01', 2.18,
        'Caja C/100 Farma MX 108588: SKU es la pieza, no la caja'
      )
    ) as t(sku, ean, target, lote, cad, costo, motivo)
  loop
    select p.id, coalesce(p.stock, 0), coalesce(p.stock_unidades, 0), coalesce(p.venta_unidad, false)
      into v_pid, v_stock, v_su, v_vu
    from public.productos p
    where p.sku = r.sku or p.codigo_barras = r.ean
    order by case when p.sku = r.sku then 0 else 1 end, p.id
    limit 1;

    if v_pid is null then
      raise notice 'SKIP %: no está en catálogo', r.sku;
      continue;
    end if;

    select coalesce(sum(l.cantidad_actual), 0)::int into v_sum
    from public.lotes l
    where l.producto_id = v_pid
      and coalesce(l.activo, true);

    if v_sum >= r.target then
      update public.productos
      set
        stock_unidades = 0,
        venta_unidad = false,
        unidades_por_caja = 0,
        precio_unidad = 0
      where id = v_pid
        and (
          coalesce(stock_unidades, 0) <> 0
          or coalesce(venta_unidad, false)
          or coalesce(unidades_por_caja, 0) <> 0
          or coalesce(precio_unidad, 0) <> 0
        );
      raise notice 'SKIP %: ya hay % piezas en lotes', r.sku, v_sum;
      continue;
    end if;

    -- Solo la trampa: caja contada como 1 (o ya vendida a 0) y 100 sueltas huérfanas.
    if not (
      v_stock <= 1
      and v_sum <= 1
      and (v_su >= 90 or v_vu is false)
    ) then
      raise notice 'SKIP %: stock=% lotes=% sueltas=% — no parece la trampa caja/pieza',
        r.sku, v_stock, v_sum, v_su;
      continue;
    end if;

    v_motivo := 'Corregir C/100 a piezas · ' || r.sku || ' · 20260910';

    if exists (
      select 1 from public.movimientos_inventario m
      where m.producto_id = v_pid and m.motivo = v_motivo
    ) then
      raise notice 'SKIP %: movimiento % ya existe', r.sku, v_motivo;
      continue;
    end if;

    select l.id into v_lid
    from public.lotes l
    where l.producto_id = v_pid
      and l.numero_lote = r.lote
    order by l.id
    limit 1;

    if v_lid is null then
      select l.id into v_lid
      from public.lotes l
      where l.producto_id = v_pid
      order by l.id desc
      limit 1;
    end if;

    if v_lid is null then
      insert into public.lotes (
        producto_id, numero_lote, cantidad_inicial, cantidad_actual,
        fecha_caducidad, costo_unitario, activo
      ) values (
        v_pid, r.lote, r.target, r.target, r.cad, r.costo, true
      ) returning id into v_lid;
    else
      update public.lotes
      set
        cantidad_actual = r.target,
        cantidad_inicial = greatest(coalesce(cantidad_inicial, 0), r.target),
        activo = true,
        fecha_caducidad = coalesce(fecha_caducidad, r.cad),
        costo_unitario = coalesce(nullif(costo_unitario, 0), r.costo),
        numero_lote = coalesce(nullif(btrim(numero_lote), ''), r.lote)
      where id = v_lid;
    end if;

    update public.productos
    set
      stock_unidades = 0,
      venta_unidad = false,
      unidades_por_caja = 0,
      precio_unidad = 0
    where id = v_pid;

    insert into public.movimientos_inventario (producto_id, tipo, cantidad, motivo)
    values (v_pid, 'ajuste', r.target, v_motivo);

    raise notice 'OK % id % lote % → % piezas', r.sku, v_pid, v_lid, r.target;
  end loop;
end $$;

commit;

select
  p.sku,
  p.nombre,
  p.codigo_barras,
  p.venta_unidad,
  p.unidades_por_caja,
  p.stock,
  p.stock_unidades,
  p.costo,
  p.precio,
  l.numero_lote,
  l.fecha_caducidad,
  l.cantidad_actual,
  l.activo
from public.productos p
left join public.lotes l
  on l.producto_id = p.id
where p.sku in ('FC-22300775', 'FMX-506386', 'FMX-307657', 'FC-22300881', 'FMX-506388')
   or p.codigo_barras in ('7506022300775', '7506022300843', '7506022300690')
order by p.nombre, l.id;
