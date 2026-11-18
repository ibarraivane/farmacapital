-- Vivradoxil (doxiciclina Alpharma 100 mg, caja con 10 tabletas).
--
-- Es un solo producto partido en dos SKUs:
--   FC-26291857  EAN de la caja 7502226291857
--                alta del ticket Equilibrio 445246 (21-sep-2026),
--                renglón ALP0559 DOXICICLINA 10 TAB 100 MG, lote 2511579.
--   EQ-ALP90241  código corto de mayoreo 75017156 (no es el código de la caja).
--                La ficha ya decía Vivradoxil. Misma caducidad 11/2027.
--
-- Se queda FC-26291857, con el nombre de mostrador.
-- El lote del viejo se mueve solo si el bueno no tiene ya ese número de lote
-- o, si el viejo no trae lote, esa misma caducidad. Si el bueno está en 0,
-- se mueve todo: las piezas no se tiran.
-- No inventa caducidad ni piezas. Idempotente.
--
-- Pegar en Supabase → SQL Editor → Run.

begin;

do $$
begin
  if not exists (select 1 from public.productos where sku = 'FC-26291857') then
    raise exception 'No existe FC-26291857 (Vivradoxil, EAN 7502226291857).';
  end if;
  if exists (
    select 1
    from public.productos
    where sku is distinct from 'FC-26291857'
      and coalesce(activo, true)
      and regexp_replace(coalesce(codigo_barras, ''), '\D', '', 'g') = '7502226291857'
  ) then
    raise exception 'El EAN 7502226291857 está en otro producto activo. No se fusiona.';
  end if;
end $$;

-- Si un inactivo se quedó con el EAN, lo suelta para no chocar el UNIQUE.
update public.productos
   set codigo_barras = null
 where sku is distinct from 'FC-26291857'
   and regexp_replace(coalesce(codigo_barras, ''), '\D', '', 'g') = '7502226291857'
   and activo is not true;

update public.productos bueno
   set nombre = 'Vivradoxil 100 mg',
       marca = 'Alpharma',
       laboratorio = coalesce(nullif(btrim(bueno.laboratorio), ''), 'Alpharma'),
       presentacion = 'Caja con 10 tabletas',
       principio_activo = 'Doxiciclina',
       denominacion_generica = 'Doxiciclina',
       denominacion_distintiva = 'Vivradoxil',
       concentracion = '100 mg',
       forma_farmaceutica = 'Tabletas',
       categoria = 'Antibiótico',
       tipo = 'generico',
       requiere_receta = true,
       codigo_barras = '7502226291857',
       costo = case
         when coalesce(bueno.costo, 0) > 0 then bueno.costo
         else coalesce(viejo.costo, bueno.costo)
       end,
       precio = case
         when coalesce(bueno.precio, 0) > 0 then bueno.precio
         else coalesce(viejo.precio, bueno.precio)
       end,
       imagen_url = coalesce(nullif(btrim(bueno.imagen_url), ''), nullif(btrim(viejo.imagen_url), '')),
       imagen_mobile_url = coalesce(
         nullif(btrim(bueno.imagen_mobile_url), ''),
         nullif(btrim(viejo.imagen_mobile_url), ''),
         nullif(btrim(bueno.imagen_url), ''),
         nullif(btrim(viejo.imagen_url), '')
       ),
       descripcion = case
         when coalesce(bueno.descripcion, '') ilike '%7502226291857%' then bueno.descripcion
         when coalesce(btrim(bueno.descripcion), '') = '' then
           'Vivradoxil, doxiciclina Alpharma. EAN 7502226291857. Ticket Equilibrio ALP0559. El código 75017156 no es el de la caja.'
         else btrim(bueno.descripcion)
              || ' EAN 7502226291857. El código 75017156 no es el de la caja.'
       end
  from public.productos viejo
 where bueno.sku = 'FC-26291857'
   and viejo.sku = 'EQ-ALP90241';

-- Si el viejo ya no está, igual corrige la ficha del bueno.
update public.productos
   set nombre = 'Vivradoxil 100 mg',
       marca = 'Alpharma',
       laboratorio = coalesce(nullif(btrim(laboratorio), ''), 'Alpharma'),
       presentacion = 'Caja con 10 tabletas',
       principio_activo = 'Doxiciclina',
       denominacion_generica = 'Doxiciclina',
       denominacion_distintiva = 'Vivradoxil',
       concentracion = '100 mg',
       forma_farmaceutica = 'Tabletas',
       categoria = 'Antibiótico',
       tipo = 'generico',
       requiere_receta = true,
       codigo_barras = '7502226291857'
 where sku = 'FC-26291857'
   and nombre is distinct from 'Vivradoxil 100 mg';

-- Foto del viejo, solo si el bueno no tiene galería.
insert into public.producto_imagenes
  (producto_id, url, storage_path, posicion, es_principal, origen)
select
  bueno.id,
  i.url,
  i.storage_path,
  i.posicion,
  i.es_principal,
  case
    when i.origen in ('rappi', 'distribuidor', 'propia', 'gs1', 'otro') then i.origen
    else 'propia'
  end
from public.producto_imagenes i
join public.productos viejo on viejo.id = i.producto_id and viejo.sku = 'EQ-ALP90241'
join public.productos bueno on bueno.sku = 'FC-26291857'
where nullif(btrim(i.url), '') is not null
  and not exists (
  select 1 from public.producto_imagenes x where x.producto_id = bueno.id
)
  and not exists (
    select 1 from public.producto_imagenes x
    where x.producto_id = bueno.id
      and x.url is not distinct from i.url
  );

create temporary table _fc_vivra_lotes (
  lote_id bigint primary key,
  accion text not null,
  numero_lote text,
  fecha_caducidad date,
  cantidad numeric
) on commit drop;

insert into _fc_vivra_lotes (lote_id, accion, numero_lote, fecha_caducidad, cantidad)
select
  l.id,
  case
    when coalesce(kb.piezas, 0) = 0 then 'mover'
    when nullif(btrim(l.numero_lote), '') is not null
         and exists (
           select 1
           from public.lotes b
           where b.producto_id = bueno.id
             and coalesce(b.activo, true)
             and coalesce(b.cantidad_actual, 0) > 0
             and upper(btrim(b.numero_lote)) = upper(btrim(l.numero_lote))
         ) then 'duplicado'
    when nullif(btrim(l.numero_lote), '') is null
         and l.fecha_caducidad is not null
         and exists (
           select 1
           from public.lotes b
           where b.producto_id = bueno.id
             and coalesce(b.activo, true)
             and coalesce(b.cantidad_actual, 0) > 0
             and b.fecha_caducidad = l.fecha_caducidad
         ) then 'duplicado'
    else 'mover'
  end,
  l.numero_lote,
  l.fecha_caducidad,
  l.cantidad_actual
from public.lotes l
join public.productos viejo on viejo.id = l.producto_id and viejo.sku = 'EQ-ALP90241'
join public.productos bueno on bueno.sku = 'FC-26291857'
left join lateral (
  select coalesce(sum(x.cantidad_actual), 0) as piezas
  from public.lotes x
  where x.producto_id = bueno.id
    and coalesce(x.activo, true)
    and coalesce(x.cantidad_actual, 0) > 0
) kb on true
where coalesce(l.activo, true)
  and coalesce(l.cantidad_actual, 0) > 0;

update public.lotes l
   set producto_id = bueno.id
  from _fc_vivra_lotes d
  join public.productos bueno on bueno.sku = 'FC-26291857'
 where l.id = d.lote_id
   and d.accion = 'mover';

update public.lotes l
   set activo = false
  from _fc_vivra_lotes d
 where l.id = d.lote_id
   and d.accion = 'duplicado';

-- Lo que quede en el viejo (cantidad 0 o el duplicado) no sigue en caducidad.
update public.lotes l
   set activo = false
  from public.productos viejo
 where viejo.sku = 'EQ-ALP90241'
   and l.producto_id = viejo.id
   and coalesce(l.activo, true);

update public.productos p
   set stock = coalesce((
         select sum(l.cantidad_actual)
         from public.lotes l
         where l.producto_id = p.id
           and coalesce(l.activo, true)
       ), 0)
 where p.sku = 'FC-26291857';

do $vincular$
declare
  v_bueno bigint;
  v_viejo bigint;
begin
  select id into v_bueno from public.productos where sku = 'FC-26291857';
  select id into v_viejo from public.productos where sku = 'EQ-ALP90241';
  if v_viejo is null or v_bueno is null then
    return;
  end if;

  if to_regclass('public.movimientos_inventario') is not null then
    update public.movimientos_inventario
       set producto_id = v_bueno
     where producto_id = v_viejo;
  end if;

  if to_regclass('public.pedido_items') is not null then
    update public.pedido_items
       set producto_id = v_bueno
     where producto_id = v_viejo;
  end if;

  if to_regclass('public.compra_items') is not null then
    update public.compra_items
       set producto_id = v_bueno
     where producto_id = v_viejo;
  end if;

  if to_regclass('public.recepcion_items') is not null then
    update public.recepcion_items
       set producto_id = v_bueno,
           nombre_snapshot = case
             when nombre_snapshot ilike '%doxiciclina%alpharma%'
               or nombre_snapshot ilike '%vivradoxil%'
               or nombre_snapshot ilike '%ALP0559%'
               then 'Vivradoxil 100 mg'
             else nombre_snapshot
           end
     where producto_id = v_viejo
        or (
          producto_id = v_bueno
          and (
            nombre_snapshot ilike '%doxiciclina%alpharma%'
            or nombre_snapshot ilike '%ALP0559%'
          )
        );
  end if;
end
$vincular$;

update public.productos
   set activo = false,
       stock = 0,
       codigo_barras = null,
       visible_tienda = false,
       descripcion = case
         when coalesce(descripcion, '') ilike '%fusionado en FC-26291857%' then descripcion
         when coalesce(btrim(descripcion), '') = '' then
           'Fusionado en FC-26291857 (mismo Vivradoxil). Código corto 75017156 no es el EAN.'
         else btrim(descripcion)
              || ' Fusionado en FC-26291857 (mismo Vivradoxil). Código corto 75017156 no es el EAN.'
       end
 where sku = 'EQ-ALP90241'
   and (
     activo is distinct from false
     or codigo_barras is not null
     or coalesce(stock, 0) <> 0
   );

-- Verificación. El bueno queda activo con el EAN; el viejo, apagado y sin código.
select
  p.sku,
  p.nombre,
  p.codigo_barras,
  p.marca,
  p.presentacion,
  p.principio_activo,
  p.concentracion,
  p.activo,
  p.stock,
  (
    select string_agg(
      coalesce(nullif(btrim(l.numero_lote), ''), 'sin lote')
      || ' · '
      || coalesce(to_char(l.fecha_caducidad, 'MM/YYYY'), 'sin cad')
      || ' · '
      || coalesce(l.cantidad_actual, 0)::text
      || case when coalesce(l.activo, true) then '' else ' (apagado)' end,
      ' | '
      order by l.id
    )
    from public.lotes l
    where l.producto_id = p.id
  ) as lotes,
  (
    select string_agg(d.accion || ' ' || coalesce(d.cantidad, 0)::text, ', ')
    from _fc_vivra_lotes d
  ) as decision_lotes_viejos
from public.productos p
where p.sku in ('FC-26291857', 'EQ-ALP90241')
order by p.activo desc, p.sku;

commit;
