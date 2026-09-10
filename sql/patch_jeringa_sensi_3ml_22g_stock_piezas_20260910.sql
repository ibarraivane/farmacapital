-- Cajas C/N de botiquín que en mostrador se venden POR PIEZA
--
-- Producción 10-sep-2026 · Jeringa Sensi 3 mL 22G negra (FC-22300775):
--   Caja Farma MX C/100. Ficha con stock=1 y stock_unidades=100,
--   venta_unidad=false. El POS cobra contra lotes: vendieron 1 y quedó 0.
--
-- Misma trampa (caja contada como 1, se vende suelta):
--   5 mL / 10 mL negras, 3 mL verde.
--
-- Mismo criterio, ya se vendían sueltas con el botón Unidad (al escanear
-- el POS cobraba la CAJA). Se pasa el SKU a pieza:
--   cubrebocas C/100, gasa Lox10 C/100, Tegaderm C/50, guante C/100.
--
-- NO toca: Aspirina/Alka/tabletas (caja abierta), curitas (2 cajas + 93
-- sueltas, ambiguo), hisopos/cotonetes (se vende el tarro), insulina y
-- jeringas que ya están en piezas (99 / 97 / 50).
--
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
  v_motivo text;
begin
  for r in
    select * from (values
      -- sku, ean, piezas, precio pieza, costo pieza, lote, cad, tocar_lote
      (
        'FC-22300775'::text, '7506022300775'::text, 99,
        8::numeric, 1.40::numeric,
        '2506885602'::text, '2030-06-01'::date, true
      ),
      (
        'FMX-506386', '7506022300843', 100,
        7, 1.48,
        '2504864004', '2030-04-15', true
      ),
      (
        'FMX-307657', '7506022300690', 100,
        8, 2.18,
        '2504864301', '2030-04-01', true
      ),
      (
        'FMX-506388', '7506022300751', 100,
        7, 1.40,
        '2506885503', '2030-06-06', true
      ),
      (
        'FC-00100013', '2008500100013', 98,
        6, 0.80,
        null, null, true
      ),
      (
        'FC-68900134', '7501868900134', 96,
        3, 1.09,
        null, null, true
      ),
      (
        'FC-89592876', '4001895928765', 50,
        20, 11.59,
        null, null, true
      ),
      (
        'FMX-300644', '7501048920556', 96,
        3, 1.61,
        null, null, false
      )
    ) as t(sku, ean, target, precio, costo, lote, cad, tocar_lote)
  loop
    select p.id, coalesce(p.stock, 0), coalesce(p.stock_unidades, 0)
      into v_pid, v_stock, v_su
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

    v_motivo := 'Corregir C/N a piezas · ' || r.sku || ' · 20260910';

    -- Ficha siempre a pieza (aunque el lote ya esté bien, p.ej. guante 96).
    update public.productos
    set
      stock_unidades = 0,
      venta_unidad = false,
      unidades_por_caja = 0,
      precio_unidad = 0,
      precio = r.precio,
      costo = r.costo
    where id = v_pid
      and (
        coalesce(venta_unidad, false)
        or coalesce(stock_unidades, 0) <> 0
        or coalesce(unidades_por_caja, 0) <> 0
        or coalesce(precio_unidad, 0) <> 0
        or coalesce(precio, 0) is distinct from r.precio
        or coalesce(costo, 0) is distinct from r.costo
      );

    if not r.tocar_lote then
      raise notice 'FICHA % id % (lote ya en % piezas)', r.sku, v_pid, v_sum;
      continue;
    end if;

    if v_sum >= r.target then
      raise notice 'SKIP lote %: ya hay % piezas', r.sku, v_sum;
      continue;
    end if;

    -- Trampa: 0–1 en lote y muchas sueltas, o ya vendieron la “caja” (stock 0).
    if not (v_stock <= 1 and v_sum <= 1 and v_su >= 20) then
      raise notice 'SKIP %: stock=% lotes=% sueltas=% — no parece la trampa',
        r.sku, v_stock, v_sum, v_su;
      continue;
    end if;

    if exists (
      select 1 from public.movimientos_inventario m
      where m.producto_id = v_pid and m.motivo = v_motivo
    ) then
      raise notice 'SKIP %: movimiento ya existe', r.sku;
      continue;
    end if;

    v_lid := null;
    if r.lote is not null then
      select l.id into v_lid
      from public.lotes l
      where l.producto_id = v_pid and l.numero_lote = r.lote
      order by l.id
      limit 1;
    end if;

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
        v_pid,
        coalesce(r.lote, 'REINTEGRO-' || to_char(now(), 'YYYYMMDD')),
        r.target, r.target, r.cad, r.costo, true
      ) returning id into v_lid;
    else
      update public.lotes
      set
        cantidad_actual = r.target,
        cantidad_inicial = greatest(coalesce(cantidad_inicial, 0), r.target),
        activo = true,
        fecha_caducidad = coalesce(fecha_caducidad, r.cad),
        costo_unitario = coalesce(nullif(costo_unitario, 0), r.costo),
        numero_lote = case
          when r.lote is not null and coalesce(btrim(numero_lote), '') = '' then r.lote
          else numero_lote
        end
      where id = v_lid;
    end if;

    insert into public.movimientos_inventario (producto_id, tipo, cantidad, motivo)
    values (v_pid, 'ajuste', r.target, v_motivo);

    raise notice 'OK % id % lote % → % piezas @ $%', r.sku, v_pid, v_lid, r.target, r.precio;
  end loop;
end $$;

commit;

-- Resultado de lo corregido
select
  p.sku,
  p.nombre,
  p.venta_unidad,
  p.stock,
  p.stock_unidades,
  p.costo,
  p.precio,
  l.numero_lote,
  l.cantidad_actual
from public.productos p
left join public.lotes l
  on l.producto_id = p.id and coalesce(l.activo, true)
where p.sku in (
  'FC-22300775', 'FMX-506386', 'FMX-307657', 'FMX-506388',
  'FC-00100013', 'FC-68900134', 'FC-89592876', 'FMX-300644',
  'FC-22300881', 'FMX-506389', 'FMX-307658'
)
order by p.nombre, l.id;

-- Otros C/N de mostrador: no se tocaron (caja de tabletas, tarro, o ambiguo)
select
  p.sku,
  p.nombre,
  p.presentacion,
  p.venta_unidad,
  p.unidades_por_caja,
  p.stock,
  p.stock_unidades,
  p.precio,
  p.precio_unidad
from public.productos p
where p.activo
  and (
    p.sku in ('FC-03476594', 'FC-84272103', 'FC-34064021')
    or (
      coalesce(p.venta_unidad, false)
      and coalesce(p.unidades_por_caja, 0) >= 20
      and coalesce(p.stock, 0) <= 2
      and p.sku not in (
        'FC-22300775', 'FMX-506386', 'FMX-307657', 'FMX-506388',
        'FC-00100013', 'FC-68900134', 'FC-89592876', 'FMX-300644'
      )
    )
  )
order by p.nombre;
