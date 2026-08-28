-- Elevit 1 comprimidos C/30 · Bayer (antes, durante y después del embarazo)
-- EAN de la caja (fotos): 7501008497623
-- Lote impreso: 476244 · cad OCT-27 → 2027-10-01
-- 1 caja · costo compra $350 · PMP impreso $569.04
-- PVP $560 = ceil(350*1.6), $9 bajo el PMP. No 1.2×: el costo no está pegado al público.
--
-- INSERT ONLY si no existe. Si ya está el SKU, recibe el lote 476244 (no duplica).
-- Ejecutar en Supabase SQL Editor (archivo completo).
-- No escribir productos.proveedor (esa columna no existe).

begin;

do $$
declare
  v_pid bigint;
  v_lid bigint;
begin
  select p.id into v_pid
  from public.productos p
  where p.codigo_barras = '7501008497623'
     or p.sku = 'FC-08497623'
     or (
       p.nombre ilike '%elevit%'
       and p.nombre not ilike '%2 %'
       and p.nombre not ilike '%3 %'
     )
  order by case when p.codigo_barras = '7501008497623' then 0 else 1 end, p.id
  limit 1;

  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from public.create_producto_with_lote(
      jsonb_build_object(
        'nombre', 'Elevit 1 comprimidos C/30',
        'sku', 'FC-08497623',
        'codigo_barras', '7501008497623',
        'categoria', 'Vitaminas',
        'tipo', 'marca',
        'descripcion', 'Bayer Elevit 1 · prenatal (antes, durante y después del embarazo) · C/30 · lote 476244 · PMP caja $569.04 · costo $350',
        'costo', 350,
        'precio', 560,
        'stock_minimo', 1,
        'activo', true,
        'requiere_receta', false
      ),
      1,
      '476244',
      '2027-10-01'::date,
      350,
      null::bigint
    ) f;
    raise notice 'Elevit 1 C/30 creado id % lote %', v_pid, v_lid;
  else
    if exists (
      select 1 from public.lotes l
      where l.producto_id = v_pid
        and l.numero_lote = '476244'
        and coalesce(l.activo, true)
    ) then
      raise notice 'Elevit 1 C/30 ya existe (id %) y lote 476244; no se vuelve a recibir.', v_pid;
    else
      select f.lote_id into v_lid
      from public.receive_merchandise_lote(
        v_pid, 1, '476244', '2027-10-01'::date, 350,
        null, null::bigint
      ) f;
      raise notice 'Elevit 1 C/30 ya existía id %; se recibió lote %', v_pid, v_lid;
    end if;

    update public.productos set
      costo = 350,
      precio = 560,
      stock_minimo = greatest(coalesce(stock_minimo, 0), 1)
    where id = v_pid;
  end if;

  update public.productos set
    marca = 'Bayer',
    presentacion = 'Caja con 30 comprimidos',
    forma_farmaceutica = 'Comprimido',
    categoria = 'Vitaminas',
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
  p.costo,
  p.precio,
  round((p.precio - p.costo) / nullif(p.precio, 0) * 100, 1) as margen_pct,
  p.stock,
  l.numero_lote,
  l.fecha_caducidad,
  l.cantidad_actual
from public.productos p
left join public.lotes l on l.producto_id = p.id and coalesce(l.activo, true) = true
where p.codigo_barras = '7501008497623'
   or p.sku = 'FC-08497623'
order by p.sku, l.fecha_caducidad;
