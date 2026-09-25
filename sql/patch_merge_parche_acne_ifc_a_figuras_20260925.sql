-- Parches acné: FC-IFC-PARCHE-ACNE → FC-07020003 (figuras).
--
-- Qué pasó:
--   · Catálogo ya tenía FC-07020003 «Parches para acne hidrocoloide figuras»
--     EAN 20250702003 (stock 1).
--   · IFC 125445 trajo «PARCHES P/ACNE FIGS HIDROCOLOIDE» ×6 @ $16.50 SIN EAN.
--     El generador inventó FC-IFC-PARCHE-ACNE en vez de reusar figuras.
--   · FC-07020004 (panda) es otra presentación → no se toca.
--
-- Fix:
--   1) Queda FC-07020003 (figuras + EAN). Stock físico = 7 (1 + 6).
--   2) Mueve lotes / relinka recepción IFC 125445.
--   3) Apaga FC-IFC-PARCHE-ACNE.
--
-- Idempotente. Supabase → SQL Editor → Run.

begin;

select
  p.sku,
  left(p.nombre, 48) as nombre,
  p.activo,
  p.stock,
  p.precio,
  p.costo,
  p.codigo_barras as ean,
  p.presentacion,
  (
    select string_agg(l.numero_lote || ':' || coalesce(l.cantidad_actual, 0)::text, ', ')
    from public.lotes l where l.producto_id = p.id
  ) as lotes
from public.productos p
where p.sku in ('FC-07020003', 'FC-07020004', 'FC-IFC-PARCHE-ACNE')
order by p.sku;

do $$
declare
  v_bueno bigint;
  v_pobre bigint;
  v_stock_fisico integer;
  v_en_lotes integer;
  v_stock_bueno integer := 0;
  v_stock_pobre integer := 0;
begin
  select id, coalesce(stock, 0)
    into v_bueno, v_stock_bueno
  from public.productos
  where sku = 'FC-07020003'
  limit 1;

  select id, coalesce(stock, 0)
    into v_pobre, v_stock_pobre
  from public.productos
  where sku = 'FC-IFC-PARCHE-ACNE'
  limit 1;

  if v_bueno is null then
    if v_pobre is null then
      raise exception 'No existe FC-07020003 ni FC-IFC-PARCHE-ACNE';
    end if;
    -- Canónico desapareció: promovemos el IFC a figuras con EAN.
    update public.productos set
      sku = 'FC-07020003',
      nombre = 'Parches para acné hidrocoloide figuras',
      codigo_barras = coalesce(nullif(btrim(codigo_barras), ''), '20250702003'),
      presentacion = coalesce(nullif(btrim(presentacion), ''), 'Pieza'),
      forma_farmaceutica = coalesce(nullif(btrim(forma_farmaceutica), ''), 'Parche'),
      categoria = coalesce(nullif(btrim(categoria), ''), 'Cuidado personal'),
      costo = case when coalesce(costo, 0) <= 0 then 16.50 else costo end,
      precio = case when coalesce(precio, 0) <= 0 then 21 else precio end,
      activo = true
    where id = v_pobre;
    v_bueno := v_pobre;
    v_pobre := null;
    v_stock_bueno := v_stock_pobre;
    v_stock_pobre := 0;
    raise notice 'Canónico recreado desde IFC → id %', v_bueno;
  end if;

  -- Stock físico = suma de ambos (1 figuras + 6 IFC), sin inventar.
  if v_pobre is not null and exists (
    select 1 from public.productos where id = v_pobre and activo = true
  ) then
    v_stock_fisico := greatest(v_stock_bueno, 0) + greatest(v_stock_pobre, 0);
  else
    -- Ya mergeado antes: no tocar stock del bueno.
    select coalesce(stock, 0) into v_stock_fisico
    from public.productos where id = v_bueno;
  end if;

  if v_stock_fisico < 1 then
    v_stock_fisico := greatest(v_stock_bueno, 1);
  end if;

  update public.productos set
    nombre = 'Parches para acné hidrocoloide figuras',
    codigo_barras = coalesce(nullif(btrim(codigo_barras), ''), '20250702003'),
    presentacion = coalesce(nullif(btrim(presentacion), ''), 'Pieza'),
    forma_farmaceutica = coalesce(nullif(btrim(forma_farmaceutica), ''), 'Parche'),
    categoria = coalesce(nullif(btrim(categoria), ''), 'Cuidado personal'),
    costo = case
      when coalesce(costo, 0) <= 0 then 16.50
      when coalesce(costo, 0) > 16.50 then costo
      else 16.50
    end,
    precio = case
      when coalesce(precio, 0) < 21 then 21
      else precio
    end,
    activo = true,
    descripcion = coalesce(
      nullif(btrim(descripcion), ''),
      'Ticket IFC 125445 · PARCHES P/ACNE FIGS HIDROCOLOIDE'
    )
  where id = v_bueno;

  if v_pobre is not null then
    update public.recepcion_items i
       set producto_id = v_bueno,
           pendiente_alta = false,
           codigo_escaneado = coalesce(
             nullif(btrim(i.codigo_escaneado), ''),
             '20250702003'
           ),
           nombre_snapshot = coalesce(
             nullif(btrim(nombre_snapshot), ''),
             'Parches para acné hidrocoloide figuras'
           )
     where i.producto_id = v_pobre;

    update public.recepcion_items i
       set producto_id = v_bueno,
           pendiente_alta = false,
           codigo_escaneado = coalesce(
             nullif(btrim(i.codigo_escaneado), ''),
             '20250702003'
           )
      from public.recepciones r
     where i.recepcion_id = r.id
       and coalesce(r.proveedor, '') ilike '%ifc%'
       and (
         i.nombre_snapshot ilike '%parche%acne%'
         or i.nombre_snapshot ilike '%parche%acné%'
         or i.nombre_snapshot ilike '%p/acne%figs%'
         or i.nombre_snapshot ilike '%figs%hidrocoloide%'
       )
       and i.producto_id is distinct from v_bueno;

    -- Mover lotes vivos
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
      'IFC-125445-PARCHE-FIGS',
      '2030-01-31'::date,
      v_stock_fisico,
      v_stock_fisico,
      true
    );
  elsif v_en_lotes <> v_stock_fisico then
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

  if v_pobre is not null and v_pobre <> v_bueno then
    update public.productos set
      activo = false,
      stock = 0,
      stock_unidades = 0,
      stock_minimo = 0
    where id = v_pobre;
  end if;

  raise notice 'Parche figuras: bueno id=% stock=%; pobre apagado id=%',
    v_bueno, v_stock_fisico, v_pobre;
end $$;

commit;

select
  p.sku,
  left(p.nombre, 48) as nombre,
  p.activo,
  p.stock,
  p.precio,
  p.costo,
  p.codigo_barras as ean,
  l.numero_lote,
  l.cantidad_actual,
  l.fecha_caducidad,
  l.activo as lote_activo
from public.productos p
left join public.lotes l on l.producto_id = p.id
where p.sku in ('FC-07020003', 'FC-07020004', 'FC-IFC-PARCHE-ACNE')
order by p.sku, l.id;
