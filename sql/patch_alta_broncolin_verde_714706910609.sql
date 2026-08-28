-- Broncolin Etiqueta Verde jarabe oral 140 mL
-- EAN/UPC de la botella (fotos): 714706910609
-- Lote impreso: JEVZ03466 · cad JUN-29 → 2029-06-01
-- 1 frasco · PMP botella $145.50 · costo Farmalive 9861 = $74.28
-- PVP $119 = ceil(74.28*1.6). Bajo el PMP.
--
-- NO es Broncolin Etiqueta Azul (714706100307 / FC-70100307).
-- NO es Bicoestol pastillas ni paletas.
--
-- INSERT ONLY si no existe (también reconoce SKU viejo FL-6910609).
-- Ejecutar en Supabase SQL Editor (archivo completo).

begin;

do $$
declare
  v_pid bigint;
  v_lid bigint;
begin
  select p.id into v_pid
  from public.productos p
  where p.codigo_barras in ('714706910609', '0714706910609')
     or p.sku in ('FC-06910609', 'FL-6910609')
     or (
       p.nombre ilike '%broncolin%'
       and p.nombre ilike '%verde%'
     )
  order by case
    when p.codigo_barras in ('714706910609', '0714706910609') then 0
    when p.sku in ('FC-06910609', 'FL-6910609') then 1
    else 2
  end, p.id
  limit 1;

  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from public.create_producto_with_lote(
      jsonb_build_object(
        'nombre', 'Broncolin Etiqueta Verde jarabe oral 140 mL',
        'sku', 'FC-06910609',
        'codigo_barras', '714706910609',
        'categoria', 'Herbolario',
        'tipo', 'marca',
        'descripcion', 'Remedio herbolario · eucalipto, gordolobo, saúco · lote JEVZ03466 · PMP $145.50 · costo Farmalive $74.28 · ≠ Etiqueta Azul 714706100307',
        'costo', 74.28,
        'precio', 119,
        'stock_minimo', 1,
        'activo', true,
        'requiere_receta', false
      ),
      1,
      'JEVZ03466',
      '2029-06-01'::date,
      74.28,
      null::bigint
    ) f;
    raise notice 'Broncolin Verde 140 mL creado id % lote %', v_pid, v_lid;
  else
    if exists (
      select 1 from public.lotes l
      where l.producto_id = v_pid
        and l.numero_lote = 'JEVZ03466'
        and coalesce(l.activo, true)
    ) then
      raise notice 'Broncolin Verde ya existe (id %) y lote JEVZ03466; no se vuelve a recibir.', v_pid;
    else
      select f.lote_id into v_lid
      from public.receive_merchandise_lote(
        v_pid, 1, 'JEVZ03466', '2029-06-01'::date, 74.28,
        null, null::bigint
      ) f;
      raise notice 'Broncolin Verde ya existía id %; se recibió lote %', v_pid, v_lid;
    end if;

    update public.productos set
      codigo_barras = coalesce(nullif(codigo_barras, ''), '714706910609'),
      costo = 74.28,
      precio = 119,
      stock_minimo = greatest(coalesce(stock_minimo, 0), 1)
    where id = v_pid
      and (codigo_barras is null or codigo_barras in ('', '714706910609', '0714706910609'));
  end if;

  update public.productos set
    sku = case when sku in ('FL-6910609', '') or sku is null then 'FC-06910609' else sku end,
    marca = 'Broncolin',
    presentacion = 'Frasco 140 mL',
    forma_farmaceutica = 'Jarabe',
    categoria = 'Herbolario',
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
  p.costo,
  p.precio,
  round((p.precio - p.costo) / nullif(p.precio, 0) * 100, 1) as margen_pct,
  p.stock,
  l.numero_lote,
  l.fecha_caducidad,
  l.cantidad_actual
from public.productos p
left join public.lotes l on l.producto_id = p.id and coalesce(l.activo, true) = true
where p.codigo_barras in ('714706910609', '0714706910609', '714706100307')
   or p.sku in ('FC-06910609', 'FL-6910609', 'FC-70100307')
order by p.sku, l.fecha_caducidad;
