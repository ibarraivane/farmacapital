-- Levic · facturas 7-oct-2026 (Recibir)
-- A 9012408964 · CFDI 7115A734-52CC-424A-87BD-64F71345CABC · $124.98 · 2 pzas
-- A 9012409830 · CFDI 7ABC32D2-2D97-4641-B24D-697952E61F12 · hoja 1 de 2 · 16 pzas · $994.47
--   (hoja 1: subtotal $990.96 + IVA Aceite Olivo $3.51). TODO hoja 2.
-- Receptor LUIS ANGEL PALILLERO VENTURA · PUE efectivo · Agente 305 YAIR RAMIREZ
-- Costo = Precio neto. Lote de fábrica del papel. Caducidad NO se escribe (MMAA de la caja).
-- Nombres de mostrador (no el código interno del PDF).
-- Idempotente. Pegar en Supabase SQL Editor.

begin;

-- ═══════════════════════════════════════════════════════════════════════════
-- Ticket 1 · A 9012408964 · Risperidona 2 mg C/40 ×2
-- ═══════════════════════════════════════════════════════════════════════════
do $$
declare
  r record;
  v_pid bigint;
  n_alta integer := 0;
  n_costo integer := 0;
begin
  for r in
    select * from (values
      ('7501384543983', 'FC-84543983', 'Risperidona 2 mg', 'Medicamentos', 'generico',
       62.49::numeric, 100.00, 2, 'Alpharma', 'Caja con 40 tabletas', 'Risperidona', '2 mg',
       true, 'Factura Levic 9012408964 · clave ALP0708 · lote 9210826', false)
    ) as t(ean, sku, nombre, categoria, tipo, costo, precio, stock_minimo,
           marca, presentacion, principio, concentracion, receta, notas, es_alta)
  loop
    v_pid := public.fc_buscar_producto_escaneo(r.ean);
    if v_pid is null then
      v_pid := public.fc_buscar_producto_escaneo(r.sku);
    end if;

    if v_pid is null then
      select f.producto_id into v_pid
      from public.create_producto_with_lote(
        jsonb_build_object(
          'nombre', r.nombre,
          'sku', r.sku,
          'codigo_barras', r.ean,
          'categoria', r.categoria,
          'tipo', r.tipo,
          'descripcion', r.notas,
          'costo', r.costo,
          'precio', r.precio,
          'stock_minimo', r.stock_minimo,
          'activo', true,
          'requiere_receta', r.receta
        ),
        0, null, null::date, r.costo, null::bigint
      ) f;
      n_alta := n_alta + 1;
    else
      update public.productos set
        costo = r.costo,
        stock_minimo = greatest(coalesce(stock_minimo, 0), r.stock_minimo),
        codigo_barras = coalesce(nullif(codigo_barras, ''), r.ean)
      where id = v_pid;
      n_costo := n_costo + 1;
    end if;

    update public.productos set
      marca = coalesce(nullif(marca, ''), r.marca),
      presentacion = coalesce(nullif(presentacion, ''), r.presentacion),
      principio_activo = coalesce(nullif(principio_activo, ''), r.principio),
      concentracion = coalesce(nullif(concentracion, ''), r.concentracion),
      forma_farmaceutica = coalesce(nullif(forma_farmaceutica, ''), 'Tabletas')
    where id = v_pid;
  end loop;

  raise notice 'Levic 9012408964: % altas, % costos (stock = Recibir)', n_alta, n_costo;
end $$;

do $$
declare
  v_id bigint;
  r record;
  v_pid bigint;
begin
  select id into v_id
  from public.recepciones
  where folio = '9012408964' and coalesce(proveedor, '') ilike '%levic%'
  order by id desc
  limit 1;

  if v_id is not null and (select estado from public.recepciones where id = v_id) <> 'borrador' then
    raise notice 'Recepcion Levic 9012408964 ya cerrada (id %)', v_id;
  else
    if v_id is null then
      insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
      values (
        'Levic', '9012408964', '2026-10-07', 124.98, 'borrador',
        'Factura Levic A 9012408964 · CFDI 7115A734-52CC-424A-87BD-64F71345CABC · pedido 833094441 · PUE efectivo · cola Recibir; stock al confirmar pistola · lote de fábrica en el papel; MMAA de la caja'
      )
      returning id into v_id;
    else
      delete from public.recepcion_items where recepcion_id = v_id;
      update public.recepciones
         set total_ticket = 124.98, fecha = '2026-10-07', proveedor = 'Levic',
             notas = 'Factura Levic A 9012408964 · CFDI 7115A734-52CC-424A-87BD-64F71345CABC · pedido 833094441 · PUE efectivo · cola Recibir; stock al confirmar pistola · lote de fábrica en el papel; MMAA de la caja',
             updated_at = now()
       where id = v_id;
    end if;

    for r in
      select * from (values
        ('7501384543983', 'Risperidona 2 mg', 2, 62.49::numeric, 'FC-84543983', '9210826')
      ) as t(ean, nombre, qty, costo, sku, lote)
    loop
      v_pid := public.fc_buscar_producto_escaneo(r.ean);
      if v_pid is null then
        v_pid := public.fc_buscar_producto_escaneo(r.sku);
      end if;

      insert into public.recepcion_items (
        recepcion_id, producto_id, codigo_escaneado, nombre_snapshot,
        cantidad, fecha_caducidad, numero_lote, costo_estimado, pendiente_alta,
        origen, confirmado, lote_distinto, lote_id
      ) values (
        v_id, v_pid, r.ean, r.nombre, r.qty, null, r.lote, r.costo,
        (v_pid is null), 'pdf', false,
        (v_pid is not null and exists (
          select 1 from public.lotes l
          where l.producto_id = v_pid and coalesce(l.activo, true)
            and coalesce(l.cantidad_actual, 0) > 0
            and l.numero_lote is distinct from r.lote
        )),
        null
      );
    end loop;

    raise notice 'Recepcion Levic 9012408964 lista id=% — escanear caja por caja', v_id;
  end if;
end $$;

-- ═══════════════════════════════════════════════════════════════════════════
-- Ticket 2 · A 9012409830 · hoja 1 de 2 (16 pzas) · TODO hoja 2
-- ═══════════════════════════════════════════════════════════════════════════
do $$
declare
  r record;
  v_pid bigint;
  n_alta integer := 0;
  n_costo integer := 0;
begin
  for r in
    select * from (values
      -- existentes (solo costo)
      ('7501573902928', 'EQ-BIO081', 'Ketoconazol crema 2%', 'Dermocosmético', 'generico',
       15.80::numeric, 26.00, 2, 'Biomep', 'Tubo 30 g', 'Ketoconazol', '2%',
       false, 'Factura Levic 9012409830 · clave BIO081 · lote CG2610', false),
      ('7502009748448', 'EQ-MAV392', 'Cetilver gel 8%', 'Medicamentos', 'marca',
       40.43, 51.00, 2, 'Cetilver', 'Tubo 10 g', 'Pirfenidona', '8%',
       true, 'Factura Levic 9012409830 · clave MAV392 · lote 263698', false),
      ('7502001162600', 'EQ-SON193', 'Poral ótico', 'Medicamentos', 'marca',
       35.11, 44.00, 2, 'SON''S', 'Frasco gotero 10 mL',
       'Hidrocortisona / Cloranfenicol / Benzocaína', null,
       true, 'Factura Levic 9012409830 · clave SON193 · lote 26092296', false),
      -- altas nuevas
      ('8904103340310', 'EQ-GAM030', 'Rebless 2.5 mg', 'Medicamentos', 'marca',
       630.84, 789.00, 1, 'Rebless', 'Caja con 28 tabletas', 'Rivaroxabán', '2.5 mg',
       true, 'Factura Levic 9012409830 · clave GAM030 · lote B2IOY001 · Gabame', true),
      ('759684031052', 'EQ-JAL021', 'Aceite de olivo Jaloma', 'Cuidado personal', 'marca',
       7.31, 10.00, 2, 'Jaloma', 'Botella 60 ml', 'Aceite de olivo', null,
       false, 'Factura Levic 9012409830 · clave JAL021 · lote 0136905', true),
      ('7501471888393', 'EQ-TEC0550', 'Tiarotec 5 mg', 'Medicamentos', 'marca',
       39.16, 49.00, 2, 'Tiarotec', 'Caja con 20 tabletas', 'Tiamazol', '5 mg',
       true, 'Factura Levic 9012409830 · clave TEC0550 · lote 441133 · Tecnofarma', true)
    ) as t(ean, sku, nombre, categoria, tipo, costo, precio, stock_minimo,
           marca, presentacion, principio, concentracion, receta, notas, es_alta)
  loop
    v_pid := public.fc_buscar_producto_escaneo(r.ean);
    if v_pid is null then
      v_pid := public.fc_buscar_producto_escaneo(r.sku);
    end if;

    if v_pid is null then
      select f.producto_id into v_pid
      from public.create_producto_with_lote(
        jsonb_build_object(
          'nombre', r.nombre,
          'sku', r.sku,
          'codigo_barras', r.ean,
          'categoria', r.categoria,
          'tipo', r.tipo,
          'descripcion', r.notas,
          'costo', r.costo,
          'precio', r.precio,
          'stock_minimo', r.stock_minimo,
          'activo', true,
          'requiere_receta', r.receta
        ),
        0, null, null::date, r.costo, null::bigint
      ) f;
      n_alta := n_alta + 1;
    else
      update public.productos set
        costo = r.costo,
        stock_minimo = greatest(coalesce(stock_minimo, 0), r.stock_minimo),
        codigo_barras = coalesce(nullif(codigo_barras, ''), r.ean)
      where id = v_pid;
      n_costo := n_costo + 1;
    end if;

    update public.productos set
      marca = coalesce(nullif(marca, ''), r.marca),
      presentacion = coalesce(nullif(presentacion, ''), r.presentacion),
      principio_activo = coalesce(nullif(principio_activo, ''), r.principio),
      concentracion = coalesce(nullif(concentracion, ''), r.concentracion)
    where id = v_pid;
  end loop;

  raise notice 'Levic 9012409830 hoja1: % altas, % costos (stock = Recibir)', n_alta, n_costo;
end $$;

do $$
declare
  v_id bigint;
  r record;
  v_pid bigint;
begin
  select id into v_id
  from public.recepciones
  where folio = '9012409830' and coalesce(proveedor, '') ilike '%levic%'
  order by id desc
  limit 1;

  if v_id is not null and (select estado from public.recepciones where id = v_id) <> 'borrador' then
    raise notice 'Recepcion Levic 9012409830 ya cerrada (id %)', v_id;
  else
    if v_id is null then
      insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
      values (
        'Levic', '9012409830', '2026-10-07', 994.47, 'borrador',
        'Factura Levic A 9012409830 · CFDI 7ABC32D2-2D97-4641-B24D-697952E61F12 · hoja 1 de 2 (16 pzas · $990.96 + IVA aceite $3.51 = $994.47) · TODO hoja 2 · cola Recibir; stock al confirmar pistola · lote de fábrica en el papel; MMAA de la caja · TODO foto Rebless/Aceite/Tiarotec'
      )
      returning id into v_id;
    else
      delete from public.recepcion_items where recepcion_id = v_id;
      update public.recepciones
         set total_ticket = 994.47, fecha = '2026-10-07', proveedor = 'Levic',
             notas = 'Factura Levic A 9012409830 · CFDI 7ABC32D2-2D97-4641-B24D-697952E61F12 · hoja 1 de 2 (16 pzas · $990.96 + IVA aceite $3.51 = $994.47) · TODO hoja 2 · cola Recibir; stock al confirmar pistola · lote de fábrica en el papel; MMAA de la caja · TODO foto Rebless/Aceite/Tiarotec',
             updated_at = now()
       where id = v_id;
    end if;

    for r in
      select * from (values
        ('7501573902928', 'Ketoconazol crema 2%', 5, 15.80::numeric, 'EQ-BIO081', 'CG2610'),
        ('8904103340310', 'Rebless 2.5 mg', 1, 630.84, 'EQ-GAM030', 'B2IOY001'),
        ('759684031052', 'Aceite de olivo Jaloma', 3, 7.31, 'EQ-JAL021', '0136905'),
        ('7502009748448', 'Cetilver gel 8%', 1, 40.43, 'EQ-MAV392', '263698'),
        ('7502001162600', 'Poral ótico', 4, 35.11, 'EQ-SON193', '26092296'),
        ('7501471888393', 'Tiarotec 5 mg', 2, 39.16, 'EQ-TEC0550', '441133')
      ) as t(ean, nombre, qty, costo, sku, lote)
    loop
      v_pid := public.fc_buscar_producto_escaneo(r.ean);
      if v_pid is null then
        v_pid := public.fc_buscar_producto_escaneo(r.sku);
      end if;

      insert into public.recepcion_items (
        recepcion_id, producto_id, codigo_escaneado, nombre_snapshot,
        cantidad, fecha_caducidad, numero_lote, costo_estimado, pendiente_alta,
        origen, confirmado, lote_distinto, lote_id
      ) values (
        v_id, v_pid, r.ean, r.nombre, r.qty, null, r.lote, r.costo,
        (v_pid is null), 'pdf', false,
        (v_pid is not null and exists (
          select 1 from public.lotes l
          where l.producto_id = v_pid and coalesce(l.activo, true)
            and coalesce(l.cantidad_actual, 0) > 0
            and l.numero_lote is distinct from r.lote
        )),
        null
      );
    end loop;

    raise notice 'Recepcion Levic 9012409830 hoja1 lista id=% — falta hoja 2', v_id;
  end if;
end $$;

commit;

select r.folio, i.codigo_escaneado as ean, left(i.nombre_snapshot, 40) as nombre,
       i.cantidad, i.costo_estimado, i.numero_lote,
       case when i.pendiente_alta then 'ALTA NUEVA' else 'YA EXISTE' end as estado
  from public.recepcion_items i
  join public.recepciones r on r.id = i.recepcion_id
 where r.folio in ('9012408964', '9012409830')
   and coalesce(r.proveedor, '') ilike '%levic%'
 order by r.folio, i.id;
