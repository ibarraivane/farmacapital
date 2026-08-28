-- Ajuste Levic · factura A 9012100253 (pedido 1020554215) · 25-ago-2026
--
-- Qué pasó: la mercancía se escaneó a mano en la recepción 14 ANTES de que
-- cargara el ticket del pedido (recepción 15). Resultado:
--   · 5 renglones ya entraron a stock, pero con el costo viejo del catálogo
--     y con lote inventado (RX-A9012100253-nnnn) en vez del lote de fábrica.
--   · 6 renglones se quedaron en "pendiente de alta" y NO entraron.
--   · la recepción 15 trae los 11 del pedido, así que 3 de ellos se
--     duplicarían si se escanean tal cual.
--   · la recepción 13 quedó vacía.
--
-- Este patch: limpia la 13, corrige costos y lotes de lo que ya entró,
-- da de alta los 7 que faltan en catálogo (stock 0) y deja la recepción 15
-- SÓLO con lo que falta entrar, con el lote real de la factura.
--
-- La caducidad NO se escribe aquí: sale de la caja al escanear (regla de piso).
-- Idempotente. Pegar en Supabase.

begin;

-- ───────────────────────────────────────────────────────────────
-- 1) Borrador vacío que quedó tirado
-- ───────────────────────────────────────────────────────────────
delete from public.recepciones r
where r.id = 13
  and r.estado = 'borrador'
  and not exists (select 1 from public.recepcion_items i where i.recepcion_id = r.id);

-- ───────────────────────────────────────────────────────────────
-- 2) Lo que YA entró por la recepción 14: costo real de la factura
--    y número de lote de fábrica. No se toca la cantidad ni la
--    caducidad: esa la puso la caja y la caja manda.
-- ───────────────────────────────────────────────────────────────
do $$
declare
  r record;
begin
  for r in
    select * from (values
      -- producto_id, costo factura, lote factura (null = viene en la hoja 2)
      (144::bigint,  13.61::numeric, null::text),      -- AMS165 Fluconazol 1 caps 150 mg
      (1197,          9.28,          'B25S501'),       -- AMS253 Dexametasona 1 FA 8mg/2ml
      (682,         148.89,          'BFF029')         -- CHI030 Neuralin iny 2 amp
    ) as t(pid, costo, lote)
  loop
    update public.lotes
    set costo_unitario = r.costo,
        numero_lote = coalesce(r.lote, numero_lote)
    where producto_id = r.pid
      and numero_lote like 'RX-A9012100253-%';

    update public.productos
    set costo = r.costo
    where id = r.pid;
  end loop;
end $$;

-- ───────────────────────────────────────────────────────────────
-- 3) Altas de catálogo (stock 0 — las piezas entran al escanear)
--    Precio de arranque = techo(costo x 1.6). REVISAR en Metas y Precios:
--    en marca con descuento fuerte ese factor se pasa (ver notas).
-- ───────────────────────────────────────────────────────────────
do $$
declare
  r record;
  v_pid bigint;
  n integer := 0;
begin
  for r in
    select * from (values
      ('7501349020139', 'FC-LV-AMS495', 'Fluconazol 10 cáps 100 mg',
       'Medicamentos', 'generico', 18.29::numeric, 30::numeric, true,
       'AMSA', 'Caja con 10 cápsulas', 'Fluconazol', '100 mg',
       'Factura Levic A9012100253 · clave AMS495 · lote U25S200 · precio público de lista 439.00'),
      ('7502209857032', 'FC-LV-BEA420', 'Fluconazol 10 cáps 100 mg beadvance',
       'Medicamentos', 'generico', 17.35, 28, true,
       'beadvance', 'Caja con 10 cápsulas', 'Fluconazol', '100 mg',
       'Factura Levic A9012100253 · clave BEA420 · lote SK25305 · precio público de lista 250.00'),
      ('650240029165', 'FC-LV-GNO016', 'Lomecan Duo 3 óvulos y crema 200 mg',
       'Medicamentos', 'marca', 176.10, 282, false,
       'Genomma Lab', 'Caja con 3 óvulos y crema', 'Clotrimazol', '200 mg',
       'Factura Levic A9012100253 · clave GNO016 · lote 5083016901 · OJO precio público de factura 191.42, el arranque 282 se pasa'),
      ('7501058714312', 'FC-LV-LIV177', 'Tempra gotas uva 10 g 30 mL',
       'Medicamentos', 'marca', 168.72, 270, false,
       'Tempra', 'Frasco 30 mL', 'Paracetamol', '100 mg/mL',
       'Factura Levic A9012100253 · clave LIV177 · lote ABH5077 · sin descuento en factura, revisar precio'),
      ('7502227879610', 'FC-LV-RAM156', 'Duet Flexenol NF 16 tab 275/300 mg',
       'Medicamentos', 'marca', 30.06, 112, false,
       'RAAM', 'Caja con 16 tabletas', 'Naproxeno/Paracetamol', '275/300 mg',
       'Factura Levic A9012100253 · clave RAM156 · lote RDF102 · precio público de factura 112.00'),
      ('7501300407047', 'FC-LV-SIE060', 'Febrax 15 tab 275/300 mg',
       'Medicamentos', 'marca', 204.38, 328, false,
       'Siegfried Rhein', 'Caja con 15 tabletas', 'Naproxeno/Paracetamol', '275/300 mg',
       'Factura Levic A9012100253 · clave SIE060 · lote 252104 · sin descuento en factura, revisar precio'),
      ('7501300407054', 'FC-LV-SIE061', 'Febrax supositorios caja c/5 100/200 mg',
       'Medicamentos', 'marca', 128.75, 206, false,
       'Siegfried Rhein', 'Caja con 5 supositorios', 'Naproxeno/Paracetamol', '100/200 mg',
       'Factura Levic A9012100253 · clave SIE061 · lote 260433 · sin descuento en factura, revisar precio')
    ) as t(ean, sku, nombre, categoria, tipo, costo, precio, receta,
           marca, presentacion, principio, concentracion, notas)
  loop
    v_pid := public.fc_buscar_producto_escaneo(r.ean);
    if v_pid is not null then
      continue;  -- ya existe, no duplicar
    end if;

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
        'stock_minimo', 1,
        'activo', true,
        'requiere_receta', r.receta
      ),
      0, null, null::date, r.costo, null::bigint
    ) f;

    update public.productos set
      marca = r.marca,
      presentacion = r.presentacion,
      principio_activo = coalesce(principio_activo, r.principio),
      concentracion = coalesce(concentracion, r.concentracion)
    where id = v_pid;

    n := n + 1;
  end loop;

  raise notice 'Altas nuevas: %', n;
end $$;

-- ───────────────────────────────────────────────────────────────
-- 4) Recepción 15: fuera lo que ya entró por la 14, y lote real
--    de la factura en lo que sigue pendiente.
-- ───────────────────────────────────────────────────────────────
do $$
declare
  v_id bigint;
  r record;
begin
  select id into v_id
  from public.recepciones
  where folio = '1020554215' and coalesce(proveedor, '') ilike '%levic%' and estado = 'borrador'
  order by id desc limit 1;

  if v_id is null then
    raise notice 'No hay borrador 1020554215 — nada que ajustar';
    return;
  end if;

  -- ya entraron por la recepción 14: no volver a sumarlos
  delete from public.recepcion_items
  where recepcion_id = v_id
    and codigo_escaneado in ('7501349012943', '7501349027329', '7501088505126')
    and coalesce(confirmado, false) = false;

  -- lote de fábrica de la factura + reenganchar el producto ya dado de alta
  for r in
    select * from (values
      ('7501349020139', 'U25S200'),
      ('7502209857032', 'SK25305'),
      ('650240029165',  '5083016901'),
      ('7501058714312', 'ABH5077'),
      ('7502227879610', 'RDF102'),
      ('7501300407047', '252104'),
      ('7501300407054', '260433'),
      ('7501482200016', '61168')
    ) as t(ean, lote)
  loop
    update public.recepcion_items i
    set numero_lote = r.lote,
        producto_id = coalesce(i.producto_id, public.fc_buscar_producto_escaneo(r.ean)),
        pendiente_alta = (coalesce(i.producto_id, public.fc_buscar_producto_escaneo(r.ean)) is null)
    where i.recepcion_id = v_id
      and i.codigo_escaneado = r.ean;
  end loop;

  -- Omeprazol Aktyzar: el lote 61168 ya existe (agotado). Se le engancha
  -- para que sume ahí en vez de abrir una segunda fila con el mismo número.
  update public.recepcion_items i
  set lote_id = l.id
  from public.lotes l
  where i.recepcion_id = v_id
    and i.codigo_escaneado = '7501482200016'
    and l.producto_id = i.producto_id
    and l.numero_lote = '61168'
    and i.lote_id is null;

  -- la cabecera queda con el folio de la factura; el pedido va en notas
  update public.recepciones
  set folio = 'A9012100253',
      total_ticket = null,
      notas = 'Factura Levic A9012100253 · pedido 1020554215 · resto de la entrada; lo demás entró en la recepción 14',
      updated_at = now()
  where id = v_id;

  raise notice 'Recepcion % ajustada', v_id;
end $$;

commit;

-- ─────────────── Comprobación ───────────────
select
  i.id,
  i.codigo_escaneado as ean,
  left(i.nombre_snapshot, 38) as nombre,
  i.cantidad,
  i.numero_lote,
  i.costo_estimado,
  i.producto_id,
  case when i.pendiente_alta then 'FALTA ALTA' else 'listo para pistola' end as estado
from public.recepcion_items i
join public.recepciones r on r.id = i.recepcion_id
where r.id = (select id from public.recepciones
              where folio = 'A9012100253' and estado = 'borrador'
              order by id desc limit 1)
order by i.id;
