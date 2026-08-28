-- Aguja hipodérmica SensiMedical 22G x 32 mm negra
-- Caja C/100 (se vende por pieza). EAN fotos: 7506022304124
-- Lote impreso: 2411816005 · fab 30-NOV-2024 · cad 30-NOV-2029
-- Ticket Farma MX 108588 · clave 504321 · 100 pza · $0.55 c/u · $55 caja
-- PVP $1 = ceil(0.55*1.6).
--
-- NO es jeringa 3/5/10 mL (esos traen aguja, otro EAN y otro registro SSA).
-- Reg. caja de agujas: 1014C2017 SSA. Jeringas: 0681C2017 SSA.
--
-- Si ya existe FMX-504321 con este lote, solo le pega el EAN (no duplica stock).
-- Ejecutar en Supabase SQL Editor (archivo completo).

begin;

do $$
declare
  v_pid bigint;
  v_lid bigint;
begin
  select p.id into v_pid
  from public.productos p
  where p.codigo_barras = '7506022304124'
     or p.sku in ('FMX-504321', 'FC-22304124')
     or (
       p.nombre ilike '%aguja%'
       and p.nombre ilike '%22%'
       and p.nombre ilike '%32%'
       and p.nombre not ilike '%jeringa%'
     )
  order by case
    when p.codigo_barras = '7506022304124' then 0
    when p.sku = 'FMX-504321' then 1
    else 2
  end, p.id
  limit 1;

  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from public.create_producto_with_lote(
      jsonb_build_object(
        'nombre', 'Aguja hipodérmica SensiMedical 22G x 32 mm',
        'sku', 'FMX-504321',
        'codigo_barras', '7506022304124',
        'categoria', 'Dispositivo médico',
        'tipo', 'marca',
        'descripcion', 'Caja C/100 · venta por pieza · negra · estéril OE · Jayor · EAN 7506022304124 · lote 2411816005 · Reg. 1014C2017 SSA · ≠ jeringas 22G',
        'costo', 0.55,
        'precio', 1,
        'stock_minimo', 20,
        'activo', true,
        'requiere_receta', false
      ),
      100,
      '2411816005',
      '2029-11-30'::date,
      0.55,
      null::bigint
    ) f;
    raise notice 'Aguja 22G x 32 mm creada id % lote % (100 pza)', v_pid, v_lid;
  else
    if exists (
      select 1 from public.lotes l
      where l.producto_id = v_pid
        and l.numero_lote = '2411816005'
        and coalesce(l.activo, true)
    ) then
      update public.lotes set
        fecha_caducidad = '2029-11-30'::date
      where producto_id = v_pid
        and numero_lote = '2411816005'
        and (fecha_caducidad is null or fecha_caducidad <> '2029-11-30'::date);
      raise notice 'Aguja 22G ya existe (id %) y lote 2411816005; no se vuelve a recibir.', v_pid;
    else
      select f.lote_id into v_lid
      from public.receive_merchandise_lote(
        v_pid, 100, '2411816005', '2029-11-30'::date, 0.55,
        null, null::bigint
      ) f;
      raise notice 'Aguja 22G ya existía id %; se recibió lote % (100 pza)', v_pid, v_lid;
    end if;
  end if;

  update public.productos set
    codigo_barras = coalesce(nullif(codigo_barras, ''), '7506022304124'),
    marca = 'SensiMedical',
    presentacion = 'Caja con 100 piezas · venta por pieza',
    forma_farmaceutica = 'Aguja hipodérmica',
    categoria = 'Dispositivo médico',
    tipo = 'marca',
    requiere_receta = false
  where id = v_pid;

  update public.productos set
    costo = 0.55,
    precio = 1
  where id = v_pid
    and coalesce(costo, 0) <= 0.01;
end $$;

commit;

select
  p.sku,
  p.nombre,
  p.codigo_barras,
  p.categoria,
  p.presentacion,
  p.costo,
  p.precio,
  p.stock,
  l.numero_lote,
  l.fecha_caducidad,
  l.cantidad_actual
from public.productos p
left join public.lotes l on l.producto_id = p.id and coalesce(l.activo, true) = true
where p.codigo_barras in ('7506022304124', '7506022300775', '7506022300843')
   or p.sku in ('FMX-504321', 'FC-22304124', 'FC-22300775', 'FMX-506386')
order by p.sku, l.fecha_caducidad;
