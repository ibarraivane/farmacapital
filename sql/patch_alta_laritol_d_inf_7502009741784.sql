-- Laritol D infantil jarabe 50 mL · Maver (loratadina + fenilefrina)
-- EAN de la caja (fotos): 7502009741784
-- Lote impreso: 262393 · cad ABR-28 → 2028-04-01
-- 1 frasco · PMP caja $132.00 · costo Equilibrio 440393 MAV118 = $26.44
-- PVP $43 = ceil(26.44*1.6). El PMP da margen de sobra; no uses 1.2×.
--
-- NO es Laritol 10 mg tabs (7502009740435) ni Laritol D tabs C/10 (7502009743856 / EQ-MAV182).
-- El lote 262393 + PMP $132 empatan el renglón MAV118 del ticket Equilibrio, no el de tabletas.
--
-- INSERT ONLY si no existe. Si ya está EQ-MAV118, le pone el EAN y recibe el lote (no duplica).
-- Ejecutar en Supabase SQL Editor (archivo completo).

begin;

do $$
declare
  v_pid bigint;
  v_lid bigint;
begin
  select p.id into v_pid
  from public.productos p
  where p.codigo_barras = '7502009741784'
     or p.sku = 'EQ-MAV118'
     or (
       p.nombre ilike '%laritol%d%'
       and (
         p.nombre ilike '%jbe%'
         or p.nombre ilike '%jarabe%'
         or p.nombre ilike '%inf%'
       )
     )
  order by case
    when p.codigo_barras = '7502009741784' then 0
    when p.sku = 'EQ-MAV118' then 1
    else 2
  end, p.id
  limit 1;

  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from public.create_producto_with_lote(
      jsonb_build_object(
        'nombre', 'Laritol D infantil jarabe 50 mL',
        'sku', 'EQ-MAV118',
        'codigo_barras', '7502009741784',
        'categoria', 'Alergia',
        'tipo', 'marca',
        'descripcion', 'Ticket Equilibrio 440393 · MAV118 · LARITOL D INF 1 JBE 100/50MG/5/50 ML · EAN 7502009741784 · lote 262393 · PMP $132',
        'costo', 26.44,
        'precio', 43,
        'stock_minimo', 1,
        'activo', true,
        'requiere_receta', false
      ),
      1,
      '262393',
      '2028-04-01'::date,
      26.44,
      null::bigint
    ) f;
    raise notice 'Laritol D inf jbe 50 mL creado id % lote %', v_pid, v_lid;
  else
    if exists (
      select 1 from public.lotes l
      where l.producto_id = v_pid
        and l.numero_lote = '262393'
        and coalesce(l.activo, true)
    ) then
      raise notice 'Laritol D inf ya existe (id %) y lote 262393; no se vuelve a recibir.', v_pid;
    else
      select f.lote_id into v_lid
      from public.receive_merchandise_lote(
        v_pid, 1, '262393', '2028-04-01'::date, 26.44,
        null, null::bigint
      ) f;
      raise notice 'Laritol D inf ya existía id %; se recibió lote %', v_pid, v_lid;
    end if;

    update public.productos set
      codigo_barras = coalesce(nullif(codigo_barras, ''), '7502009741784'),
      costo = 26.44,
      precio = 43,
      stock_minimo = greatest(coalesce(stock_minimo, 0), 1)
    where id = v_pid
      and (codigo_barras is null or codigo_barras = '' or codigo_barras = '7502009741784');
  end if;

  update public.productos set
    sku = coalesce(nullif(sku, ''), 'EQ-MAV118'),
    marca = 'Maver',
    presentacion = 'Frasco 50 mL',
    principio_activo = 'Loratadina / Fenilefrina',
    concentracion = '100 mg / 50 mg / 5 mL',
    forma_farmaceutica = 'Jarabe',
    categoria = 'Alergia',
    tipo = 'marca',
    requiere_receta = false
  where id = v_pid;
end $$;

commit;

select
  p.sku,
  p.nombre,
  p.codigo_barras,
  p.categoria,
  p.marca,
  p.presentacion,
  p.costo,
  p.precio,
  round((p.precio - p.costo) / nullif(p.precio, 0) * 100, 1) as margen_pct,
  p.stock,
  l.numero_lote,
  l.fecha_caducidad,
  l.cantidad_actual
from public.productos p
left join public.lotes l on l.producto_id = p.id and coalesce(l.activo, true) = true
where p.codigo_barras in ('7502009741784', '7502009743856', '7502009740435')
   or p.sku in ('EQ-MAV118', 'EQ-MAV182', 'EQ-MAV039')
order by p.sku, l.fecha_caducidad;
