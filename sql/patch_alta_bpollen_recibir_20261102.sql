-- ============================================================================
-- FARMACAPITAL — Alta BPOllen 5% y 2.5% (Recibir · sin registrar)
--
-- Pantalla Recibir: 2 productos sin registrar en catálogo
--   7502002461306 × 1 · BPOllen gel 5% tubo 60 g · Farmapiel
--   7502002461290 × 1 · BPOllen gel 2.5% tubo 60 g · Farmapiel
--
-- Stock 0 hasta escanear + MMAA de la caja. No inventa caducidad.
-- Costo/PVP ancla DermaExpress (marca +25% al costo). Si el renglón
-- ya trae costo_estimado, se respeta al enlazar.
-- Ficha packshot DermaExpress → catalogo-propia/ (imagen_url tras deploy).
-- Idempotente. Pegar TODO en Supabase → SQL Editor → Run.
-- ============================================================================

begin;

do $$
declare
  r record;
  v_pid bigint;
  v_sku text;
  v_creados int := 0;
  v_existian int := 0;
  v_enlazados int := 0;
  v_costo numeric;
  v_precio numeric;
begin
  for r in
    select * from (values
      (
        '7502002461306',
        'FC-02461306',
        'BPOllen peróxido de benzoílo 5%',
        'BPOllen',
        'Farmapiel',
        'Tubo 60 g',
        'Gel',
        'Peróxido de benzoílo',
        '5%',
        'Dermatología',
        'Acné',
        275.00::numeric,
        344::numeric,
        'https://www.farmacapital.mx/catalogo-propia/bpollen-gel-5pct-60g-7502002461306.jpg'
      ),
      (
        '7502002461290',
        'FC-02461290',
        'BPOllen peróxido de benzoílo 2.5%',
        'BPOllen',
        'Farmapiel',
        'Tubo 60 g',
        'Gel',
        'Peróxido de benzoílo',
        '2.5%',
        'Dermatología',
        'Acné',
        280.00::numeric,
        350::numeric,
        'https://www.farmacapital.mx/catalogo-propia/bpollen-gel-2_5pct-60g-7502002461290.jpg'
      )
    ) as t(
      ean, sku, nombre, marca, laboratorio, presentacion, forma,
      principio, concentracion, categoria, subcategoria, costo, precio, imagen
    )
  loop
    v_pid := public.fc_buscar_producto_escaneo(r.ean);
    if v_pid is null then
      v_pid := public.fc_buscar_producto_escaneo(r.sku);
    end if;

    if v_pid is not null then
      v_existian := v_existian + 1;
      update public.productos p
      set
        nombre = case
          when length(trim(coalesce(p.nombre, ''))) < 8 then r.nombre
          else p.nombre
        end,
        marca = coalesce(nullif(trim(p.marca), ''), r.marca),
        laboratorio = coalesce(nullif(trim(p.laboratorio), ''), r.laboratorio),
        presentacion = coalesce(nullif(trim(p.presentacion), ''), r.presentacion),
        forma_farmaceutica = coalesce(nullif(trim(p.forma_farmaceutica), ''), r.forma),
        principio_activo = coalesce(nullif(trim(p.principio_activo), ''), r.principio),
        concentracion = coalesce(nullif(trim(p.concentracion), ''), r.concentracion),
        categoria = coalesce(nullif(trim(p.categoria), ''), r.categoria),
        subcategoria = coalesce(nullif(trim(p.subcategoria), ''), r.subcategoria),
        tipo = coalesce(nullif(trim(p.tipo), ''), 'marca'),
        codigo_barras = coalesce(nullif(trim(p.codigo_barras), ''), r.ean),
        costo = case
          when coalesce(p.costo, 0) <= 0 then r.costo
          else p.costo
        end,
        precio = case
          when coalesce(p.precio, 0) <= 0 then r.precio
          else p.precio
        end,
        imagen_url = coalesce(nullif(trim(p.imagen_url), ''), r.imagen),
        imagen_mobile_url = coalesce(nullif(trim(p.imagen_mobile_url), ''), r.imagen),
        activo = true
      where p.id = v_pid;
    else
      v_sku := r.sku;
      if exists (
        select 1 from public.productos p
        where p.sku = v_sku
          and coalesce(p.codigo_barras, '') <> r.ean
      ) then
        v_sku := 'FC-ND-' || right(r.ean, 8);
      end if;

      insert into public.productos (
        nombre, sku, codigo_barras, categoria, subcategoria, tipo, descripcion,
        costo, precio, stock, stock_minimo, activo, requiere_receta,
        marca, laboratorio, presentacion, forma_farmaceutica,
        principio_activo, concentracion, imagen_url, imagen_mobile_url
      ) values (
        r.nombre,
        v_sku,
        r.ean,
        r.categoria,
        r.subcategoria,
        'marca',
        'Alta Recibir BPOllen · 2026-11-02 · listo para pistola · EAN ' || r.ean,
        r.costo,
        r.precio,
        0,
        1,
        true,
        false,
        r.marca,
        r.laboratorio,
        r.presentacion,
        r.forma,
        r.principio,
        r.concentracion,
        r.imagen,
        r.imagen
      )
      returning id into v_pid;
      v_creados := v_creados + 1;
    end if;
  end loop;

  -- Enlaza renglones grises de cualquier ticket vivo con estos EAN.
  update public.recepcion_items i
  set
    producto_id = public.fc_buscar_producto_escaneo(i.codigo_escaneado),
    pendiente_alta = false,
    nombre_snapshot = case
      when i.codigo_escaneado = '7502002461306'
        then 'BPOllen peróxido de benzoílo 5%'
      when i.codigo_escaneado = '7502002461290'
        then 'BPOllen peróxido de benzoílo 2.5%'
      else i.nombre_snapshot
    end
  where coalesce(i.pendiente_alta, false)
    and i.codigo_escaneado in ('7502002461306', '7502002461290')
    and public.fc_buscar_producto_escaneo(i.codigo_escaneado) is not null
    and coalesce(i.confirmado, false) = false;

  get diagnostics v_enlazados = row_count;

  -- Si el ítem ya traía costo de ticket, pásalo a la ficha (no pisa PVP).
  for r in
    select distinct on (i.codigo_escaneado)
      i.codigo_escaneado as ean,
      i.costo_estimado as costo
    from public.recepcion_items i
    where i.codigo_escaneado in ('7502002461306', '7502002461290')
      and coalesce(i.costo_estimado, 0) > 0
    order by i.codigo_escaneado, i.id desc
  loop
    v_costo := r.costo;
    v_precio := ceil(v_costo * 1.25);
    update public.productos p
    set
      costo = v_costo,
      precio = case
        when coalesce(p.precio, 0) <= 0 then v_precio
        else p.precio
      end
    where p.id = public.fc_buscar_producto_escaneo(r.ean);
  end loop;

  raise notice 'BPOllen: creados=% ya_estaban=% renglones_enlazados=%',
    v_creados, v_existian, v_enlazados;
end
$$;

commit;

select
  p.sku,
  p.codigo_barras as ean,
  p.nombre,
  p.marca,
  p.presentacion,
  p.concentracion,
  p.costo,
  p.precio,
  p.stock,
  p.imagen_url
from public.productos p
where p.codigo_barras in ('7502002461306', '7502002461290')
   or p.sku in ('FC-02461306', 'FC-02461290', 'FC-ND-02461306', 'FC-ND-02461290')
order by p.codigo_barras;

select
  r.folio,
  r.proveedor,
  r.estado,
  i.codigo_escaneado as ean,
  i.nombre_snapshot,
  i.cantidad,
  i.pendiente_alta,
  i.producto_id,
  i.fecha_caducidad,
  i.confirmado
from public.recepcion_items i
join public.recepciones r on r.id = i.recepcion_id
where i.codigo_escaneado in ('7502002461306', '7502002461290')
order by r.id desc, i.id;
