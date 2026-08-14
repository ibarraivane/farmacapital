-- ============================================================================
-- ALTA Dove Exfoliación Suave 135 g · ticket 77827 · Bodega F-42 Ejidos del Moral
-- Línea omitida en patch_cargar_faltantes_tickets.sql (OCR: UBN DOVE EXFOLIAC DIARIA135G)
--
-- Ticket: 13 pzas × $30.54 costo · EAN 7501056371159
-- SKU: FC-56371159
-- Ejecutar UNA vez en Supabase SQL Editor.
-- Ajusta v_qty, v_costo y v_precio abajo si ya corregiste cantidades manualmente.
-- ============================================================================

begin;

do $$
declare
  v_pid bigint;
  v_lid bigint;
  v_lote_existente bigint;
  v_qty integer := 13;
  v_costo numeric(10,2) := 30.54;
  v_precio numeric(10,2) := 48.86;
  v_lote text := 'TK-77827-20E';
begin
  select id into v_pid
  from public.productos
  where sku = 'FC-56371159'
     or codigo_barras = '7501056371159'
  limit 1;

  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from public.create_producto_with_lote(
      jsonb_build_object(
        'nombre', 'Dove Exfoliación Suave 135 g',
        'sku', 'FC-56371159',
        'codigo_barras', '7501056371159',
        'marca', 'Dove',
        'presentacion', '135 G',
        'forma_farmaceutica', 'Jabón',
        'categoria', 'Higiene',
        'tipo', 'marca',
        'proveedor', 'Bodega F-42 Ejidos del Moral',
        'descripcion', 'Dove Exfoliación Suave 135 g — ticket 77827',
        'costo', v_costo,
        'precio', v_precio,
        'stock_minimo', 3,
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
      marca = 'Dove',
      presentacion = '135 G',
      forma_farmaceutica = 'Jabón',
      categoria = 'Higiene',
      tipo = 'marca',
      proveedor = 'Bodega F-42 Ejidos del Moral'
    where id = v_pid;
  else
    update public.productos set
      nombre = 'Dove Exfoliación Suave 135 g',
      sku = 'FC-56371159',
      codigo_barras = '7501056371159',
      marca = 'Dove',
      presentacion = '135 G',
      forma_farmaceutica = 'Jabón',
      categoria = 'Higiene',
      tipo = 'marca',
      proveedor = coalesce(nullif(btrim(proveedor), ''), 'Bodega F-42 Ejidos del Moral'),
      costo = v_costo,
      precio = v_precio,
      descripcion = 'Dove Exfoliación Suave 135 g — ticket 77827',
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
        v_pid, v_qty, v_lote, null, v_costo, 'Bodega F-42 Ejidos del Moral', null
      );
    else
      update public.lotes set
        cantidad_actual = v_qty,
        costo_unitario = v_costo
      where id = v_lote_existente;
    end if;

    update public.productos p set stock = coalesce((
      select sum(l.cantidad_actual)
      from public.lotes l
      where l.producto_id = p.id and coalesce(l.activo, true)
    ), 0)
    where p.id = v_pid;
  end if;
end $$;

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
    when p.sku = 'FC-56371159'
     and p.codigo_barras = '7501056371159'
     and p.stock = 13
     and p.costo = 30.54
     and l.numero_lote = 'TK-77827-20E'
     and l.cantidad_actual = 13
    then 'OK'
    else 'REVISAR (ajusta qty/costo si ya los tenías distintos)'
  end as estado
from public.productos p
left join public.lotes l on l.producto_id = p.id
  and l.numero_lote = 'TK-77827-20E'
  and coalesce(l.activo, true)
where p.sku = 'FC-56371159'
   or p.codigo_barras = '7501056371159';

commit;
