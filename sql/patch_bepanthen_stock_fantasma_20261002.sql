-- Bepanthen Pomada Protectora Contra Rozaduras (FC-08427330 / id 445)
-- Stock fantasma en prod: 30232 (único producto ≥1000 al 2-oct-2026).
-- EAN actual: 7501008427347 (tubo 30 g). Costo Cityfarma 64.37.
-- Precio 160 era del Bepanthen 100 g; Multiusos 30 g con el mismo costo está en $80.
--
-- Ajusta lotes (no solo productos.stock: el trigger lo vuelve a pisar).
-- Idempotente si la suma activa ya es v_conteo.
--
-- Dueño 2-oct-2026: en anaquel hay CERO tubos. Default = 0.

begin;

do $$
declare
  v_conteo integer := 0;  -- tubos reales en anaquel (dueño: cero)
  v_pid bigint;
  v_lote bigint;
  v_sum integer;
  v_costo numeric;
  v_precio numeric := 80; -- mismo PVP que Multiusos 30 g (costo 64.37 + ~25%)
begin
  select id, costo into v_pid, v_costo
    from public.productos
   where sku = 'FC-08427330'
      or id = 445
   order by case when sku = 'FC-08427330' then 0 else 1 end
   limit 1;

  if v_pid is null then
    raise exception 'No está FC-08427330 (Bepanthen Pomada Protectora)';
  end if;

  if v_conteo is null or v_conteo < 0 then
    raise exception 'v_conteo inválido';
  end if;

  -- PVP: no dejar el ancla del 100 g si el EAN es el tubo 30 g.
  update public.productos
     set precio = v_precio,
         price_needs_review = false,
         presentacion = coalesce(nullif(btrim(presentacion), ''), '30 G 5%'),
         codigo_barras = coalesce(nullif(btrim(codigo_barras), ''), '7501008427347')
   where id = v_pid
     and (
       coalesce(precio, 0) >= 150
       or coalesce(price_needs_review, false)
     );

  select coalesce(sum(l.cantidad_actual), 0) into v_sum
    from public.lotes l
   where l.producto_id = v_pid
     and coalesce(l.activo, true);

  if v_sum = v_conteo then
    raise notice 'Stock de lotes ya es %. No se tocan cantidades.', v_conteo;
    return;
  end if;

  select l.id into v_lote
    from public.lotes l
   where l.producto_id = v_pid
   order by coalesce(l.activo, true) desc,
            coalesce(l.cantidad_actual, 0) desc,
            l.id desc
   limit 1;

  if v_lote is null then
    if v_conteo = 0 then
      update public.productos set stock = 0 where id = v_pid;
      insert into public.movimientos_inventario (producto_id, tipo, cantidad, motivo)
      values (
        v_pid, 'ajuste', 0,
        'Conteo 2-oct-2026: Bepanthen Protectora 30 g sin piezas. Antes stock fantasma 30232.'
      );
      return;
    end if;

    insert into public.lotes (
      producto_id, numero_lote, cantidad_inicial, cantidad_actual,
      fecha_caducidad, costo_unitario, activo
    ) values (
      v_pid, 'INV-CONTEO-20261002', v_conteo, v_conteo,
      null, v_costo, true
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
       set cantidad_actual = v_conteo,
           activo = (v_conteo > 0),
           cantidad_inicial = greatest(coalesce(cantidad_inicial, 0), v_conteo),
           costo_unitario = coalesce(costo_unitario, v_costo)
     where id = v_lote;
  end if;

  insert into public.movimientos_inventario (
    producto_id, tipo, cantidad, motivo
  ) values (
    v_pid, 'ajuste', v_conteo,
    format(
      'Conteo 2-oct-2026: Bepanthen Protectora 30 g → %s tubos. Antes stock fantasma 30232. No inventa caducidad.',
      v_conteo
    )
  );
end $$;

commit;

select
  p.sku,
  p.codigo_barras,
  p.nombre,
  p.presentacion,
  p.stock,
  p.costo,
  p.precio,
  l.id as lote_id,
  l.numero_lote,
  l.cantidad_actual,
  l.fecha_caducidad,
  l.activo
from public.productos p
left join public.lotes l on l.producto_id = p.id
where p.sku = 'FC-08427330'
   or p.id = 445
order by l.activo desc nulls last, coalesce(l.cantidad_actual, 0) desc, l.id;
