-- ============================================================================
-- FARMA CAPITAL — 2026-09-04
-- Dos piezas: Gerber Frutas Mixtas (Exprezo) + Palmolive Neutro Balance (suelta)
--
-- Gerber Etapa 2 Frutas Mixtas 100 g · EAN 7506475102490
--   Familia Exprezo 1279718. Alta + renglón en Recibir.
--   Si 1279718 sigue abierto → se agrega ahí.
--   Si ya cerró → folio vivo 20260904-EXPREZO-FM.
--   Stock 0 hasta pistola + MMAA de la tapa (no se inventa caducidad).
--   Costo lista Exprezo $10.92 · PVP $15 (margen marca 25% s/venta).
--
-- Palmolive Neutro Balance Humectación Diaria 400 ml · EAN 7501035906341
--   No está en ningún ticket. Alta + entrada a stock 1 pza.
--   Caducidad/lote de la botella: EXP 05/2028 · LOT 6151MX112121.
--   Costo mayoreo ref. $65 · PVP $87 (margen marca 25% s/venta).
--
-- Idempotente. Supabase → SQL Editor → Run.
-- Fotos: public/catalogo-propia/ (van con el deploy de este PR).
-- ============================================================================

begin;

do $$
declare
  v_pid_g bigint;
  v_pid_p bigint;
  v_rid bigint;
  v_estado text;
  v_item bigint;
  v_lid bigint;
  v_sku_g text := 'FC-75102490';
  v_sku_p text := 'FC-35906341';
  v_ean_g text := '7506475102490';
  v_ean_p text := '7501035906341';
  v_foto_g text := 'https://www.farmacapital.mx/catalogo-propia/gerber-etapa2-frutas-mixtas-100g.jpg';
  v_foto_p text := 'https://www.farmacapital.mx/catalogo-propia/palmolive-neutro-balance-humectacion-diaria-400ml.jpg';
  v_costo_g numeric := 10.92;
  v_precio_g numeric := 15;
  v_costo_p numeric := 65.00;
  v_precio_p numeric := 87;
  v_lote_p text := '6151MX112121';
  v_cad_p date := '2028-05-31';
begin
  -- ── 1) Gerber Frutas Mixtas ────────────────────────────────────────
  v_pid_g := public.fc_buscar_producto_escaneo(v_ean_g);

  if v_pid_g is null then
    select p.id into v_pid_g
      from public.productos p
     where p.sku = v_sku_g
        or p.nombre ilike 'Gerber Etapa 2 Frutas Mixtas 100 g'
     limit 1;
  end if;

  if v_pid_g is null then
    if exists (
      select 1 from public.productos p
       where p.sku = v_sku_g
         and coalesce(p.codigo_barras, '') <> v_ean_g
    ) then
      v_sku_g := 'FC-EX-75102490';
    end if;

    insert into public.productos (
      nombre, sku, codigo_barras, categoria, tipo, descripcion,
      costo, precio, stock, stock_minimo, activo, requiere_receta,
      marca, presentacion, subcategoria, imagen_url, imagen_mobile_url
    ) values (
      'Gerber Etapa 2 Frutas Mixtas 100 g',
      v_sku_g,
      v_ean_g,
      'Bebés',
      'marca',
      'Alta 2026-09-04 · pieza Exprezo (familia 1279718) · stock al escanear',
      v_costo_g,
      v_precio_g,
      0,
      1,
      true,
      false,
      'Gerber',
      'Frasco 100 g',
      'Papilla',
      v_foto_g,
      v_foto_g
    )
    returning id into v_pid_g;
  else
    update public.productos
       set activo = true,
           nombre = 'Gerber Etapa 2 Frutas Mixtas 100 g',
           marca = coalesce(nullif(marca, ''), 'Gerber'),
           presentacion = coalesce(nullif(presentacion, ''), 'Frasco 100 g'),
           categoria = coalesce(nullif(categoria, ''), 'Bebés'),
           subcategoria = coalesce(nullif(subcategoria, ''), 'Papilla'),
           tipo = 'marca',
           codigo_barras = v_ean_g,
           costo = case when coalesce(costo, 0) <= 0.01 then v_costo_g else costo end,
           precio = case when coalesce(precio, 0) <= 1 then v_precio_g else precio end,
           imagen_url = coalesce(nullif(imagen_url, ''), v_foto_g),
           imagen_mobile_url = coalesce(nullif(imagen_mobile_url, ''), v_foto_g)
     where id = v_pid_g;
  end if;

  if not exists (
    select 1 from public.producto_imagenes i
     where i.producto_id = v_pid_g and i.url = v_foto_g
  ) then
    insert into public.producto_imagenes
      (producto_id, url, storage_path, posicion, es_principal, origen)
    values (
      v_pid_g, v_foto_g,
      'catalogo-propia/gerber-etapa2-frutas-mixtas-100g.jpg',
      1, true, 'propia'
    );
  end if;

  -- Recibir: Exprezo 1279718 si vivo; si no, folio 20260904-EXPREZO-FM
  select r.id, r.estado into v_rid, v_estado
    from public.recepciones r
   where r.folio = '1279718'
     and coalesce(r.proveedor, '') ilike '%exprezo%'
   order by case
              when r.estado in ('borrador', 'pendiente_alta', 'parcial', 'pendiente_caducidad')
              then 0 else 1
            end,
            r.id desc
   limit 1;

  if v_rid is not null
     and v_estado not in ('borrador', 'pendiente_alta', 'parcial', 'pendiente_caducidad') then
    v_rid := null;
  end if;

  if v_rid is null then
    select r.id, r.estado into v_rid, v_estado
      from public.recepciones r
     where r.folio = '20260904-EXPREZO-FM'
       and coalesce(r.proveedor, '') ilike '%exprezo%'
     order by r.id desc
     limit 1;

    if v_rid is not null
       and v_estado not in ('borrador', 'pendiente_alta', 'parcial', 'pendiente_caducidad') then
      v_rid := null;
    end if;

    if v_rid is null then
      insert into public.recepciones
        (proveedor, folio, fecha, total_ticket, estado, notas)
      values (
        'Exprezo',
        '20260904-EXPREZO-FM',
        current_date,
        v_costo_g,
        'borrador',
        'Gerber Frutas Mixtas suelta · familia Exprezo 1279718 · 1 pza · stock al escanear'
      )
      returning id into v_rid;
    end if;
  end if;

  select i.id into v_item
    from public.recepcion_items i
   where i.recepcion_id = v_rid
     and (
           i.codigo_escaneado = v_ean_g
        or i.producto_id = v_pid_g
        or i.nombre_snapshot ilike '%Frutas Mixtas%100%'
         )
   order by i.id
   limit 1;

  if v_item is null then
    insert into public.recepcion_items (
      recepcion_id, producto_id, codigo_escaneado, nombre_snapshot,
      cantidad, fecha_caducidad, numero_lote, costo_estimado, pendiente_alta,
      origen, confirmado, lote_distinto, lote_id
    ) values (
      v_rid, v_pid_g, v_ean_g,
      'Gerber Etapa 2 Frutas Mixtas 100 g',
      1, null, null, v_costo_g, false,
      'scan', false, false, null
    );
  else
    update public.recepcion_items
       set producto_id = v_pid_g,
           codigo_escaneado = v_ean_g,
           pendiente_alta = false,
           nombre_snapshot = 'Gerber Etapa 2 Frutas Mixtas 100 g',
           costo_estimado = coalesce(nullif(costo_estimado, 0), v_costo_g)
     where id = v_item
       and coalesce(confirmado, false) = false;
  end if;

  raise notice 'Gerber Frutas Mixtas producto=% recepcion=% — escanear tapa (MMAA)',
    v_pid_g, v_rid;

  -- ── 2) Palmolive Neutro Balance (entrada directa) ──────────────────
  v_pid_p := public.fc_buscar_producto_escaneo(v_ean_p);

  if v_pid_p is null then
    select p.id into v_pid_p
      from public.productos p
     where p.sku = v_sku_p
        or p.nombre ilike 'Palmolive Neutro Balance Humectación Diaria crema corporal 400 ml'
     limit 1;
  end if;

  if v_pid_p is null then
    if exists (
      select 1 from public.productos p
       where p.sku = v_sku_p
         and coalesce(p.codigo_barras, '') <> v_ean_p
    ) then
      v_sku_p := 'FC-NB-35906341';
    end if;

    insert into public.productos (
      nombre, sku, codigo_barras, categoria, tipo, descripcion,
      costo, precio, stock, stock_minimo, activo, requiere_receta,
      marca, presentacion, subcategoria, imagen_url, imagen_mobile_url
    ) values (
      'Palmolive Neutro Balance Humectación Diaria crema corporal 400 ml',
      v_sku_p,
      v_ean_p,
      'Cuidado personal',
      'marca',
      'Alta 2026-09-04 · pieza sin ticket · entrada directa · EXP 05/2028 LOT 6151MX112121',
      v_costo_p,
      v_precio_p,
      0,
      1,
      true,
      false,
      'Palmolive',
      'Frasco 400 ml',
      'Crema corporal',
      v_foto_p,
      v_foto_p
    )
    returning id into v_pid_p;
  else
    update public.productos
       set activo = true,
           nombre = 'Palmolive Neutro Balance Humectación Diaria crema corporal 400 ml',
           marca = coalesce(nullif(marca, ''), 'Palmolive'),
           presentacion = coalesce(nullif(presentacion, ''), 'Frasco 400 ml'),
           categoria = coalesce(nullif(categoria, ''), 'Cuidado personal'),
           subcategoria = coalesce(nullif(subcategoria, ''), 'Crema corporal'),
           tipo = 'marca',
           codigo_barras = v_ean_p,
           costo = case when coalesce(costo, 0) <= 0.01 then v_costo_p else costo end,
           precio = case when coalesce(precio, 0) <= 1 then v_precio_p else precio end,
           imagen_url = coalesce(nullif(imagen_url, ''), v_foto_p),
           imagen_mobile_url = coalesce(nullif(imagen_mobile_url, ''), v_foto_p)
     where id = v_pid_p;
  end if;

  if not exists (
    select 1 from public.producto_imagenes i
     where i.producto_id = v_pid_p and i.url = v_foto_p
  ) then
    insert into public.producto_imagenes
      (producto_id, url, storage_path, posicion, es_principal, origen)
    values (
      v_pid_p, v_foto_p,
      'catalogo-propia/palmolive-neutro-balance-humectacion-diaria-400ml.jpg',
      1, true, 'propia'
    );
  end if;

  -- Stock 1 con lote/caducidad de la botella (no inventados)
  select l.id into v_lid
    from public.lotes l
   where l.producto_id = v_pid_p
     and l.numero_lote = v_lote_p
     and coalesce(l.activo, true)
   limit 1;

  if v_lid is null then
    begin
      insert into public.lotes (
        producto_id, numero_lote, cantidad_inicial, cantidad_actual,
        costo_unitario, fecha_caducidad, fecha_recepcion, activo
      ) values (
        v_pid_p, v_lote_p, 1, 1, v_costo_p, v_cad_p, current_date, true
      )
      returning id into v_lid;
    exception
      when undefined_column then
        insert into public.lotes (
          producto_id, numero_lote, cantidad_inicial, cantidad_actual,
          costo_unitario, fecha_caducidad, activo
        ) values (
          v_pid_p, v_lote_p, 1, 1, v_costo_p, v_cad_p, true
        )
        returning id into v_lid;
    end;

    -- Alinear stock al sum de lotes (por si hay trigger PEPS).
    update public.productos p
       set stock = (
         select coalesce(sum(l.cantidad_actual), 0)::int
           from public.lotes l
          where l.producto_id = p.id and coalesce(l.activo, true)
       )
     where p.id = v_pid_p;

    begin
      insert into public.movimientos_inventario (
        producto_id, tipo, cantidad, motivo, documento_referencia
      ) values (
        v_pid_p,
        'entrada',
        1,
        'Entrada pieza suelta Palmolive Neutro Balance · sin ticket · LOT 6151MX112121 EXP 05/2028',
        '20260904-SUELTOS-PALM'
      );
    exception
      when undefined_column or undefined_table then
        null;
    end;
  end if;

  raise notice 'Palmolive Neutro Balance producto=% lote=% stock listo', v_pid_p, v_lid;
end
$$;

commit;

-- Verificación
select
  p.sku,
  p.codigo_barras as ean,
  left(p.nombre, 52) as nombre,
  p.marca,
  p.costo,
  p.precio,
  p.stock,
  (select coalesce(sum(l.cantidad_actual), 0)
     from public.lotes l
    where l.producto_id = p.id and coalesce(l.activo, true)) as piezas_lote
from public.productos p
where p.codigo_barras in ('7506475102490', '7501035906341')
order by p.nombre;

select
  r.folio,
  r.proveedor,
  r.estado,
  i.codigo_escaneado as ean,
  left(i.nombre_snapshot, 48) as nombre,
  i.cantidad,
  i.confirmado,
  i.pendiente_alta
from public.recepciones r
join public.recepcion_items i on i.recepcion_id = r.id
where i.codigo_escaneado = '7506475102490'
   or i.nombre_snapshot ilike '%Frutas Mixtas%100%'
order by r.id desc, i.id
limit 5;
