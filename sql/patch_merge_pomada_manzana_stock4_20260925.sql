-- Mercurio pomada manzana: unificar duplicado y fijar stock físico = 4.
--
-- Qué pasó:
--   · 05-sep IFC 122576 → alta FC-MER-MANZANA (pomada 50 g, $9.50, foto foto).
--   · 24-sep IFC 125445 trajo otra vez «POMADA MANZANA C/25 … 82943» SIN EAN.
--     El generador inventó FC-IFC-82943 en vez de reusar FC-MER-MANZANA.
--   · «C/25» en el ticket = caja mayoreo de 25 pomadas; cada venta es
--     1 pomada de 50 g (no «25 piezas» sueltas).
--
-- Estado raro en Inventario (screenshot):
--   FC-MER-MANZANA  stock 2  · $16
--   FC-IFC-82943    stock 4  · $12
--   Físico real: 4 pomadas.
--
-- Fix:
--   1) Queda FC-MER-MANZANA: nombre limpio, presentacion 50 g, PVP $16, stock 4.
--   2) Mueve lotes vivos del IFC → MER (o crea lote SC-0130 si no hay).
--   3) Apaga FC-IFC-82943 (stock 0). Relinka recepciones 125445 / manzana.
--
-- Idempotente. Supabase → SQL Editor → Run.

begin;

select
  p.sku,
  left(p.nombre, 42) as nombre,
  p.activo,
  p.stock,
  p.precio,
  p.costo,
  p.presentacion,
  (
    select string_agg(l.numero_lote || ':' || coalesce(l.cantidad_actual,0)::text, ', ')
    from public.lotes l where l.producto_id = p.id
  ) as lotes
from public.productos p
where p.sku in ('FC-MER-MANZANA', 'FC-IFC-82943')
order by p.sku;

do $$
declare
  v_bueno bigint;
  v_pobre bigint;
  v_stock_fisico integer := 4;  -- conteo de mostrador
  v_en_lotes integer;
begin
  select id into v_bueno from public.productos where sku = 'FC-MER-MANZANA' limit 1;
  select id into v_pobre from public.productos where sku = 'FC-IFC-82943' limit 1;

  if v_bueno is null then
    -- Por si borraron el canónico: renombra el IFC.
    if v_pobre is null then
      raise exception 'No existe FC-MER-MANZANA ni FC-IFC-82943';
    end if;
    update public.productos set
      sku = 'FC-MER-MANZANA',
      nombre = 'Mercurio pomada manzana',
      presentacion = '50 g',
      forma_farmaceutica = 'Pomada',
      marca = 'Mercurio',
      precio = 16,
      costo = 9.50,
      stock = v_stock_fisico,
      stock_minimo = 2,
      activo = true
    where id = v_pobre;
    v_bueno := v_pobre;
    v_pobre := null;
    raise notice 'Canónico recreado desde FC-IFC-82943 → id %', v_bueno;
  end if;

  -- Ficha canónica
  update public.productos set
    nombre = 'Mercurio pomada manzana',
    marca = 'Mercurio',
    presentacion = '50 g',
    forma_farmaceutica = coalesce(nullif(btrim(forma_farmaceutica), ''), 'Pomada'),
    costo = case when coalesce(costo, 0) <= 0 then 9.50 else costo end,
    precio = case
      when coalesce(precio, 0) < 14 then 16
      else precio
    end,
    stock_minimo = greatest(coalesce(stock_minimo, 0), 2),
    activo = true,
    imagen_url = coalesce(
      nullif(btrim(imagen_url), ''),
      (
        select nullif(btrim(p2.imagen_url), '')
        from public.productos p2
        where p2.sku = 'FC-IFC-82943'
        limit 1
      ),
      'https://www.farmacapital.mx/catalogo-propia/mercurio-pomada-manzana-50g.jpg'
    )
  where id = v_bueno;

  -- Relink recepción → canónico
  if v_pobre is not null then
    update public.recepcion_items i
       set producto_id = v_bueno,
           pendiente_alta = false,
           nombre_snapshot = coalesce(nullif(btrim(nombre_snapshot), ''), 'Mercurio pomada manzana')
     where i.producto_id = v_pobre;
  end if;

  update public.recepcion_items i
     set producto_id = v_bueno,
         pendiente_alta = false
    from public.recepciones r
   where i.recepcion_id = r.id
     and coalesce(r.proveedor, '') ilike '%ifc%'
     and i.nombre_snapshot ilike '%manzana%'
     and i.producto_id is distinct from v_bueno;

  -- Mover lotes vivos del pobre → bueno (sin sumar de más: luego normalizamos a 4)
  if v_pobre is not null then
    update public.lotes l
       set producto_id = v_bueno
     where l.producto_id = v_pobre
       and coalesce(l.activo, true)
       and coalesce(l.cantidad_actual, 0) > 0;

    update public.lotes l
       set activo = false,
           cantidad_actual = 0
     where l.producto_id = v_pobre;
  end if;

  -- Normalizar lotes del bueno a exactamente 4 piezas físicas
  select coalesce(sum(cantidad_actual), 0)::integer into v_en_lotes
  from public.lotes
  where producto_id = v_bueno
    and coalesce(activo, true);

  if v_en_lotes <= 0 then
    insert into public.lotes (
      producto_id, numero_lote, fecha_caducidad,
      cantidad_inicial, cantidad_actual, activo
    ) values (
      v_bueno,
      'SC-0130-MANZANA',
      '2030-01-31'::date,  -- pomada sin MMAA legible · 01.2030
      v_stock_fisico,
      v_stock_fisico,
      true
    );
  elsif v_en_lotes <> v_stock_fisico then
    -- Un solo lote activo con las 4; apaga el resto
    update public.lotes l
       set cantidad_actual = case
             when l.id = (
               select l2.id from public.lotes l2
               where l2.producto_id = v_bueno
                 and coalesce(l2.activo, true)
               order by coalesce(l2.cantidad_actual, 0) desc, l2.id
               limit 1
             ) then v_stock_fisico
             else 0
           end,
           activo = case
             when l.id = (
               select l2.id from public.lotes l2
               where l2.producto_id = v_bueno
                 and coalesce(l2.activo, true)
               order by coalesce(l2.cantidad_actual, 0) desc, l2.id
               limit 1
             ) then true
             else false
           end,
           fecha_caducidad = coalesce(l.fecha_caducidad, '2030-01-31'::date)
     where l.producto_id = v_bueno;
  else
    update public.lotes
       set fecha_caducidad = coalesce(fecha_caducidad, '2030-01-31'::date)
     where producto_id = v_bueno
       and coalesce(activo, true)
       and coalesce(cantidad_actual, 0) > 0
       and fecha_caducidad is null;
  end if;

  update public.productos set
    stock = v_stock_fisico,
    stock_unidades = 0
  where id = v_bueno;

  -- Apagar duplicado
  if v_pobre is not null and v_pobre <> v_bueno then
    update public.productos set
      activo = false,
      stock = 0,
      stock_unidades = 0,
      stock_minimo = 0
    where id = v_pobre;
  end if;

  raise notice 'Pomada manzana: bueno id=% stock=4; pobre apagado id=%',
    v_bueno, v_pobre;
end $$;

commit;

select
  p.sku,
  left(p.nombre, 42) as nombre,
  p.activo,
  p.stock,
  p.precio,
  p.costo,
  p.presentacion,
  p.forma_farmaceutica,
  l.numero_lote,
  l.cantidad_actual,
  l.fecha_caducidad,
  l.activo as lote_activo
from public.productos p
left join public.lotes l on l.producto_id = p.id
where p.sku in ('FC-MER-MANZANA', 'FC-IFC-82943')
order by p.sku, l.id;
