-- ============================================================================
-- FARMACAPITAL — Pharmaton Complete tabletas C/100
-- EAN 3664798062243 · Opella (marca Pharmaton) · foto caja mostrador
--
-- Distinto de FC-8062229 / 3664798062229 (Pharmaton Complete C/30).
-- Stock 2 · lote 3514 · cad NOV/26 → 2026-11-30 (fin de mes MMAA).
-- Ticket Farmalive 97 traía este EAN como promo $0.01 — no es costo real.
-- Sin costo de compra usable. PVP ancla $459 (Benavides / Guadalajara ~458–459;
-- PMP caja ~$611.60).
--
-- INSERT / receive lote. Si ya existe el EAN, solo recibe 3514 si falta.
-- Pegar TODO en Supabase → SQL Editor → Run.
-- Foto: tras deploy → patch_fotos_pharmaton_complete_100_3664798062243.sql
-- ============================================================================

begin;

do $$
declare
  v_pid bigint;
  v_lid bigint;
  v_sku text := 'FC-98062243';
  v_ean text := '3664798062243';
begin
  select p.id into v_pid
  from public.productos p
  where p.codigo_barras = v_ean
     or p.sku in ('FC-98062243', 'FC-ND-98062243')
  order by case when p.codigo_barras = v_ean then 0 else 1 end, p.id
  limit 1;

  -- No confundir con C/30
  if v_pid is null then
    select p.id into v_pid
    from public.productos p
    where p.nombre ilike '%pharmaton%complete%'
      and (
        p.presentacion ilike '%c/100%'
        or p.presentacion ilike '%100 tableta%'
        or p.nombre ilike '%c/100%'
      )
      and coalesce(p.codigo_barras, '') not in ('3664798062229')
    order by p.id
    limit 1;
  end if;

  if v_pid is null then
    if exists (
      select 1 from public.productos p
      where p.sku = v_sku
        and coalesce(p.codigo_barras, '') <> v_ean
    ) then
      v_sku := 'FC-ND-98062243';
    end if;

    select f.producto_id, f.lote_id into v_pid, v_lid
    from public.create_producto_with_lote(
      jsonb_build_object(
        'nombre', 'Pharmaton Complete tabletas C/100',
        'sku', v_sku,
        'codigo_barras', v_ean,
        'categoria', 'Vitaminas',
        'tipo', 'marca',
        'descripcion', 'Pharmaton Complete · suplemento alimenticio con Ginseng G115® + vitaminas y minerales · 100 tabletas de 773 mg · Opella · EAN 3664798062243 · foto mostrador lote 3514 cad NOV/26 · ticket Farmalive 97 promo $0.01 (no costo real) · PVP ancla Benavides $459',
        'costo', null,
        'precio', 459,
        'stock_minimo', 1,
        'activo', true,
        'requiere_receta', false
      ),
      2,
      '3514',
      '2026-11-30'::date,
      null,
      null::bigint
    ) f;
    raise notice 'Pharmaton Complete C/100 creado id % lote %', v_pid, v_lid;
  else
    if exists (
      select 1 from public.lotes l
      where l.producto_id = v_pid
        and l.numero_lote = '3514'
        and coalesce(l.activo, true)
    ) then
      raise notice 'Pharmaton Complete C/100 ya existe (id %) y lote 3514; no se vuelve a recibir.', v_pid;
    else
      select f.lote_id into v_lid
      from public.receive_merchandise_lote(
        v_pid, 2, '3514', '2026-11-30'::date, null,
        null, null::bigint
      ) f;
      raise notice 'Pharmaton Complete C/100 ya existía id %; se recibió lote %', v_pid, v_lid;
    end if;

    update public.productos set
      precio = case when coalesce(precio, 0) <= 1 then 459 else precio end,
      stock_minimo = greatest(coalesce(stock_minimo, 0), 1),
      activo = true
    where id = v_pid;
  end if;

  update public.productos set
    nombre = 'Pharmaton Complete tabletas C/100',
    marca = 'Pharmaton',
    laboratorio = coalesce(nullif(btrim(laboratorio), ''), 'Opella'),
    presentacion = 'Caja con 100 tabletas de 773 mg',
    forma_farmaceutica = 'Tableta',
    principio_activo = 'Multivitaminas + Ginseng G115',
    subcategoria = 'Multivitamínico / suplemento',
    categoria = 'Vitaminas',
    tipo = 'marca',
    requiere_receta = false,
    codigo_barras = v_ean
  where id = v_pid;

  -- Si Farmalive 97 sigue en borrador con este EAN pendiente, márcalo
  -- confirmado para no volver a sumar stock al escanear.
  select l.id into v_lid
  from public.lotes l
  where l.producto_id = v_pid
    and l.numero_lote = '3514'
    and coalesce(l.activo, true)
  order by l.id desc
  limit 1;

  update public.recepcion_items i
  set
    producto_id = v_pid,
    confirmado = true,
    pendiente_alta = false,
    numero_lote = coalesce(nullif(btrim(i.numero_lote), ''), '3514'),
    fecha_caducidad = coalesce(i.fecha_caducidad, '2026-11-30'::date),
    lote_id = coalesce(i.lote_id, v_lid),
    nombre_snapshot = 'Pharmaton Complete tabletas C/100'
  from public.recepciones r
  where i.recepcion_id = r.id
    and r.folio = '97'
    and coalesce(r.proveedor, '') ilike '%farmalive%'
    and r.estado = 'borrador'
    and (
      coalesce(i.codigo_escaneado, '') = v_ean
      or i.nombre_snapshot ilike '%PHARMATON COMPLETE%C/100%'
    )
    and coalesce(i.confirmado, false) = false;
end $$;

commit;

select
  p.id,
  p.sku,
  p.codigo_barras as ean,
  p.nombre,
  p.marca,
  p.laboratorio,
  p.presentacion,
  p.principio_activo,
  p.categoria,
  p.costo,
  p.precio,
  p.stock,
  l.numero_lote,
  l.fecha_caducidad,
  l.cantidad_actual
from public.productos p
left join public.lotes l
  on l.producto_id = p.id and coalesce(l.activo, true) = true
where p.codigo_barras in ('3664798062243', '3664798062229')
   or p.sku in ('FC-98062243', 'FC-ND-98062243', 'FC-8062229', 'FC-98062229')
order by p.codigo_barras, p.sku, l.fecha_caducidad;
