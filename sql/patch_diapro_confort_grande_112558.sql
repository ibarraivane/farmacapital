-- ============================================================================
-- ALTA Diapro Confort Grande C/10 · ticket 112558 · El Surtidor · 08-08-2026
-- Línea omitida en carga original (OCR: "LA O CONFORTESC 15 CAO" / 7501943475…)
--
-- Ticket: 2 pzas × $99.00 = $198.00 total · sin descuento
-- EAN retail: 7501943475014
-- Ejecutar UNA vez en Supabase SQL Editor.
-- ============================================================================

begin;

do $$
declare
  v_pid bigint;
  v_lid bigint;
  v_lote_existente bigint;
  v_qty integer := 2;
  v_costo numeric(10,2) := 99.00;
  v_precio numeric(10,2) := 149;
  v_lote text := 'TK-112558-8G';
begin
  select id into v_pid
  from public.productos
  where sku = 'FC-43475014'
     or codigo_barras = '7501943475014'
  limit 1;

  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from public.create_producto_with_lote(
      jsonb_build_object(
        'nombre', 'Diapro Confort Gde C/10',
        'sku', 'FC-43475014',
        'codigo_barras', '7501943475014',
        'marca', 'Diapro',
        'presentacion', 'C/10',
        'categoria', 'Cuidado personal',
        'tipo', 'marca',
        'proveedor', 'El Surtidor de su Farmacia',
        'descripcion', 'Diapro Confort Gde C/10 — ticket 112558',
        'costo', v_costo,
        'precio', v_precio,
        'stock_minimo', 2,
        'activo', true,
        'requiere_receta', false
      ),
      v_qty,
      v_lote,
      null,
      v_costo,
      null
    ) f;

    update public.productos set
      marca = 'Diapro',
      presentacion = 'C/10',
      proveedor = 'El Surtidor de su Farmacia'
    where id = v_pid;
  else
    update public.productos set
      nombre = 'Diapro Confort Gde C/10',
      sku = 'FC-43475014',
      codigo_barras = '7501943475014',
      marca = 'Diapro',
      presentacion = 'C/10',
      categoria = 'Cuidado personal',
      tipo = 'marca',
      proveedor = coalesce(nullif(btrim(proveedor), ''), 'El Surtidor de su Farmacia'),
      costo = v_costo,
      precio = v_precio,
      descripcion = 'Diapro Confort Gde C/10 — ticket 112558',
      activo = true
    where id = v_pid;

    select l.id into v_lote_existente
    from public.lotes l
    where l.producto_id = v_pid
      and coalesce(l.activo, true)
      and l.numero_lote = v_lote
    order by l.id desc
    limit 1;

    if v_lote_existente is null then
      perform lote_id from public.receive_merchandise_lote(
        v_pid, v_qty, v_lote, null, v_costo, 'El Surtidor de su Farmacia', null
      );
    else
      update public.lotes set
        cantidad_actual = v_qty,
        costo_unitario = v_costo
      where id = v_lote_existente;

      update public.lotes set cantidad_actual = 0
      where producto_id = v_pid
        and id <> v_lote_existente
        and coalesce(activo, true)
        and coalesce(cantidad_actual, 0) <> 0;
    end if;

    update public.productos p set stock = coalesce((
      select sum(l.cantidad_actual)
      from public.lotes l
      where l.producto_id = p.id and coalesce(l.activo, true)
    ), 0)
    where p.id = v_pid;
  end if;
end $$;

-- Verificación
select
  p.sku,
  p.codigo_barras,
  p.nombre,
  p.marca,
  p.presentacion,
  p.costo,
  p.precio,
  p.stock,
  l.numero_lote,
  l.cantidad_actual,
  l.costo_unitario,
  case
    when p.sku = 'FC-43475014'
     and p.codigo_barras = '7501943475014'
     and p.stock = 2
     and p.costo = 99.00
     and l.numero_lote = 'TK-112558-8G'
     and l.cantidad_actual = 2
    then 'OK'
    else 'REVISAR'
  end as estado
from public.productos p
left join public.lotes l on l.producto_id = p.id
  and l.numero_lote = 'TK-112558-8G'
  and coalesce(l.activo, true)
where p.sku = 'FC-43475014'
   or p.codigo_barras = '7501943475014';

commit;
