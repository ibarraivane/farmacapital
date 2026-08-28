-- Ampigrin PFC jarabe infantil 60 mL · Collins
-- EAN/UPC de la caja (fotos): 780083148577  (también 0780083148577)
-- Lote impreso: 26140890 · cad ABR-28 → 2028-04-01
-- 1 frasco · PMP caja $162.63 · costo Equilibrio 440393 COL213 = $24.91
-- PVP $40 = ceil(24.91*1.6). PMP da margen de sobra.
--
-- NO es Culminax (Maver). NO es Ampigrin AD/INF inyectable
--   (780083140922 / 780083140939).
-- El lote 26140890 + PMP $162.63 empatan COL213 del ticket Equilibrio.
-- Receta: sí (ampicilina en jarabe).
--
-- INSERT ONLY si no existe. Si ya está EQ-COL213, le pone el EAN y recibe el lote.
-- Ejecutar en Supabase SQL Editor (archivo completo).

begin;

do $$
declare
  v_pid bigint;
  v_lid bigint;
begin
  select p.id into v_pid
  from public.productos p
  where p.codigo_barras in ('780083148577', '0780083148577')
     or p.sku = 'EQ-COL213'
     or (
       p.nombre ilike '%ampigrin%pfc%'
       or (p.nombre ilike '%ampigrin%' and p.nombre ilike '%jbe%')
       or (p.nombre ilike '%ampigrin%' and p.nombre ilike '%jarabe%')
     )
  order by case
    when p.codigo_barras in ('780083148577', '0780083148577') then 0
    when p.sku = 'EQ-COL213' then 1
    else 2
  end, p.id
  limit 1;

  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
    from public.create_producto_with_lote(
      jsonb_build_object(
        'nombre', 'Ampigrin PFC jarabe infantil 60 mL',
        'sku', 'EQ-COL213',
        'codigo_barras', '780083148577',
        'categoria', 'Antibiótico',
        'tipo', 'marca',
        'descripcion', 'Ticket Equilibrio 440393 · COL213 · AMPIGRIN PFC 1 JBE 3/0.50/0.02 G 60 ML · UPC 780083148577 · lote 26140890 · PMP $162.63 · Collins. ≠ Ampigrin AD/INF inyectable.',
        'costo', 24.91,
        'precio', 40,
        'stock_minimo', 1,
        'activo', true,
        'requiere_receta', true
      ),
      1,
      '26140890',
      '2028-04-01'::date,
      24.91,
      null::bigint
    ) f;
    raise notice 'Ampigrin PFC jbe 60 mL creado id % lote %', v_pid, v_lid;
  else
    if exists (
      select 1 from public.lotes l
      where l.producto_id = v_pid
        and l.numero_lote = '26140890'
        and coalesce(l.activo, true)
    ) then
      raise notice 'Ampigrin PFC ya existe (id %) y lote 26140890; no se vuelve a recibir.', v_pid;
    else
      select f.lote_id into v_lid
      from public.receive_merchandise_lote(
        v_pid, 1, '26140890', '2028-04-01'::date, 24.91,
        null, null::bigint
      ) f;
      raise notice 'Ampigrin PFC ya existía id %; se recibió lote %', v_pid, v_lid;
    end if;

    update public.productos set
      codigo_barras = coalesce(nullif(codigo_barras, ''), '780083148577'),
      costo = 24.91,
      precio = 40,
      stock_minimo = greatest(coalesce(stock_minimo, 0), 1)
    where id = v_pid
      and (codigo_barras is null or codigo_barras in ('', '780083148577', '0780083148577'));
  end if;

  update public.productos set
    sku = coalesce(nullif(sku, ''), 'EQ-COL213'),
    marca = 'Collins',
    presentacion = 'Frasco 60 mL',
    concentracion = '3 g / 0.50 g / 0.02 g / 60 mL',
    forma_farmaceutica = 'Jarabe',
    categoria = 'Antibiótico',
    tipo = 'marca',
    requiere_receta = true
  where id = v_pid;
end $$;

commit;

select
  p.sku,
  p.nombre,
  p.codigo_barras,
  p.categoria,
  p.requiere_receta,
  p.costo,
  p.precio,
  round((p.precio - p.costo) / nullif(p.precio, 0) * 100, 1) as margen_pct,
  p.stock,
  l.numero_lote,
  l.fecha_caducidad,
  l.cantidad_actual
from public.productos p
left join public.lotes l on l.producto_id = p.id and coalesce(l.activo, true) = true
where p.codigo_barras in ('780083148577', '0780083148577', '780083140922', '780083140939')
   or p.sku in ('EQ-COL213', 'FC-2001A890', 'FC-DE106642')
order by p.sku, l.fecha_caducidad;
