-- =============================================================================
-- PEGAR TODO ESTE ARCHIVO en Supabase → SQL Editor → Run
-- Levic · factura A 9012722225 · 19-nov-2026 → cola Recibir.
-- Recibo de cobro R001191571 · efectivo $782.61.
-- Merge a GitHub NO crea la tarjeta. Sin bloques dollar-quote. Sin producto_imagenes.
-- Caducidad null: MMAA de la caja. No inventar 0000.
-- Al final: VERIFICACION con folio 9012722225 en borrador.
-- Luego: tablet Recibir → recargar.
-- =============================================================================


-- ========== LEVIC 9012722225 ==========
-- Levic · factura interna A 9012722225 · CFDI 2026-11-19
-- Recibo cobro R001191571 · PUE efectivo $782.61
-- Receptor LUIS ANGEL PALILLERO VENTURA · 7 renglones · 16 pzas (TOT 16).
-- Subtotal CFDI ~$700.61 + IVA $82.00 (solo Cintapore) = $782.61.
-- Costo = Precio neto. Lote de fabrica en el papel.
-- Caducidad del papel NO se escribe: Recibir captura MMAA de la caja. 0000 invalido.
-- SIN bloques dollar-quote (Supabase los corta). Sin galeria extra.
-- Idempotente mientras el ticket siga en borrador.
-- Pegar TODO este archivo en Supabase → SQL Editor → Run.

begin;

create temp table _fc_rx_levic9012722225 (
  linea integer primary key,
  clave text not null,
  ean text,
  sku text not null,
  nombre text not null,
  snap text not null,
  qty integer not null,
  costo numeric(12,2) not null,
  precio numeric(12,2) not null,
  tipo text not null,
  categoria text not null,
  forma text,
  marca text,
  presentacion text,
  principio_activo text,
  concentracion text,
  receta boolean not null,
  stock_minimo integer not null,
  lote text,
  imagen text
) on commit drop;

insert into _fc_rx_levic9012722225 (
  linea, clave, ean, sku, nombre, snap, qty, costo, precio, tipo, categoria,
  forma, marca, presentacion, principio_activo, concentracion, receta,
  stock_minimo, lote, imagen
) values
  (1, 'BEA462', '7506624900519', 'FC-C636D8EA', 'Ceftriaxona IM 1 g', 'CEFTRIAXONA I.M. 1 FA 1G/3.5 ML', 5, 15.56, 25, 'generico', 'Medicamentos', 'Solucion inyectable', 'beadvance', 'Frasco ampula con diluyente 3.5 ml', 'Ceftriaxona', '1 g', true, 2, '0126180', null),
  (2, 'COD103', '7506484500003', 'FC-84500003', 'Cintapore micropore blanco', 'CINTAPORE BLANCO 24 PZAS 1.25 CM X 5 M', 1, 129.99, 163, 'marca', 'Botiquin', 'Cinta', 'Codifarma', 'Caja con 24 rollos 1.25 cm x 5 m', null, null, false, 1, null, 'https://www.farmacapital.mx/catalogo-propia/micropore-blanca-1.25x5-3m.jpg'),
  (3, 'COD104', '7506484500010', 'FC-84500010', 'Cintapore micropore blanco', 'CINTAPORE BLANCO 12 PZAS 2.5 CM X 5 M', 1, 113.78, 143, 'marca', 'Botiquin', 'Cinta', 'Codifarma', 'Caja con 12 rollos 2.5 cm x 5 m', null, null, false, 1, '2804012', 'https://www.farmacapital.mx/catalogo-propia/micropore-blanca-2.5x5-3m.jpg'),
  (4, 'COD105', '7506484500027', 'FC-84500027', 'Cintapore micropore piel', 'CINTAPORE PIEL 24 PZAS 1.25 CM X 5 M', 1, 143.32, 180, 'marca', 'Botiquin', 'Cinta', 'Codifarma', 'Caja con 24 rollos 1.25 cm x 5 m', null, null, false, 1, '2804021', 'https://www.farmacapital.mx/catalogo-propia/cintapore-piel-1.25x5.jpg'),
  (5, 'COD106', '7506484500034', 'FC-84500034', 'Cintapore micropore piel', 'CINTAPORE PIEL 12 PZAS 2.5 CM X 5 M', 1, 125.43, 157, 'marca', 'Botiquin', 'Cinta', 'Codifarma', 'Caja con 12 rollos 2.5 cm x 5 m', null, null, false, 1, '2804022', 'https://www.farmacapital.mx/catalogo-propia/cintapore-piel-2.5x5.jpg'),
  (6, 'AD001', '7501842900099', 'FC-42900099', 'Adopren 400 mg', 'ADOPREN 10 TAB 400 MG', 5, 12.13, 20, 'generico', 'Medicamentos', 'Tabletas', 'Adopren', 'Caja con 10 tabletas', 'Ibuprofeno', '400 mg', true, 2, 'G01018A', null),
  (7, 'LOE132', '7502211789277', 'EQ-LOE132', 'Faribrox TM Adulto', 'FARIBROX TM ADULTO 1 JBE 225/225MG/100/1', 2, 24.83, 32, 'marca', 'Medicamentos', 'Jarabe', 'Loeffler', 'Frasco 150 ml', 'Ambroxol / Dextrometorfano', '225/225 mg/100 ml', false, 2, 'R2603146', null);

insert into public.productos (
  nombre, sku, codigo_barras, categoria, tipo, descripcion,
  costo, precio, stock, stock_minimo, activo, requiere_receta,
  marca, presentacion, forma_farmaceutica, principio_activo, concentracion,
  imagen_url, imagen_mobile_url
)
select
  t.nombre,
  case
    when exists (
      select 1 from public.productos p
      where p.sku = t.sku
        and coalesce(p.codigo_barras, '') is distinct from coalesce(t.ean, '')
    ) then 'FC-ND-' || right(coalesce(t.ean, replace(t.sku, 'EQ-', '')), 8)
    else t.sku
  end,
  nullif(t.ean, ''),
  t.categoria,
  t.tipo,
  'Factura Levic 9012722225 · clave ' || t.clave || ' · lote ' || coalesce(t.lote, 'caja'),
  t.costo,
  t.precio,
  0,
  t.stock_minimo,
  true,
  t.receta,
  t.marca,
  t.presentacion,
  t.forma,
  t.principio_activo,
  t.concentracion,
  t.imagen,
  t.imagen
from _fc_rx_levic9012722225 t
where coalesce(
        public.fc_buscar_producto_escaneo(nullif(t.ean, '')),
        public.fc_buscar_producto_escaneo(t.sku)
      ) is null;

update public.productos p
set
  costo = t.costo,
  stock_minimo = greatest(coalesce(p.stock_minimo, 0), t.stock_minimo),
  codigo_barras = coalesce(nullif(p.codigo_barras, ''), nullif(t.ean, '')),
  precio = case when coalesce(p.precio, 0) <= 0 then t.precio else p.precio end
from _fc_rx_levic9012722225 t
where p.id = coalesce(
  public.fc_buscar_producto_escaneo(nullif(t.ean, '')),
  public.fc_buscar_producto_escaneo(t.sku)
);

update public.productos p
set
  marca = coalesce(nullif(trim(p.marca), ''), t.marca),
  presentacion = coalesce(nullif(trim(p.presentacion), ''), t.presentacion),
  principio_activo = coalesce(nullif(trim(p.principio_activo), ''), t.principio_activo),
  concentracion = coalesce(nullif(trim(p.concentracion), ''), t.concentracion),
  forma_farmaceutica = coalesce(nullif(trim(p.forma_farmaceutica), ''), t.forma),
  imagen_url = coalesce(nullif(trim(p.imagen_url), ''), t.imagen),
  imagen_mobile_url = coalesce(nullif(trim(p.imagen_mobile_url), ''), t.imagen)
from _fc_rx_levic9012722225 t
where p.id = coalesce(
  public.fc_buscar_producto_escaneo(nullif(t.ean, '')),
  public.fc_buscar_producto_escaneo(t.sku)
);

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'Levic',
  '9012722225',
  '2026-11-19',
  782.61,
  'borrador',
  'Factura Levic A 9012722225 · recibo R001191571 · PUE efectivo · cola Recibir; MMAA de la caja'
where not exists (
  select 1 from public.recepciones
  where folio = '9012722225' and coalesce(proveedor, '') ilike '%levic%'
);

update public.recepciones
set
  total_ticket = 782.61,
  fecha = '2026-11-19',
  proveedor = 'Levic',
  notas = 'Factura Levic A 9012722225 · recibo R001191571 · PUE efectivo · cola Recibir; MMAA de la caja',
  updated_at = now()
where folio = '9012722225'
  and coalesce(proveedor, '') ilike '%levic%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = '9012722225'
  and coalesce(r.proveedor, '') ilike '%levic%'
  and r.estado = 'borrador';

insert into public.recepcion_items (
  recepcion_id, producto_id, codigo_escaneado, nombre_snapshot,
  cantidad, fecha_caducidad, numero_lote, costo_estimado, pendiente_alta,
  origen, confirmado, lote_distinto, lote_id
)
select
  r.id,
  v.pid,
  coalesce(nullif(t.ean, ''), t.sku),
  t.snap,
  t.qty,
  null,
  t.lote,
  t.costo,
  (v.pid is null),
  'pdf',
  false,
  (
    v.pid is not null and exists (
      select 1 from public.lotes l
      where l.producto_id = v.pid
        and coalesce(l.activo, true)
        and coalesce(l.cantidad_actual, 0) > 0
        and (t.lote is null or l.numero_lote is distinct from t.lote)
    )
  ),
  null
from _fc_rx_levic9012722225 t
join public.recepciones r
  on r.folio = '9012722225'
 and coalesce(r.proveedor, '') ilike '%levic%'
 and r.estado = 'borrador'
left join lateral (
  select coalesce(
    public.fc_buscar_producto_escaneo(nullif(t.ean, '')),
    public.fc_buscar_producto_escaneo(t.sku)
  ) as pid
) v on true
order by t.linea;

commit;

-- VERIFICACION
select
  r.folio,
  r.proveedor,
  r.estado,
  r.fecha,
  r.total_ticket,
  count(i.*) as renglones,
  sum(i.cantidad) as pzas,
  count(*) filter (where i.pendiente_alta) as sin_confirmar_alta,
  count(*) filter (where i.producto_id is null) as sin_producto
from public.recepciones r
left join public.recepcion_items i on i.recepcion_id = r.id
where r.folio = '9012722225'
  and coalesce(r.proveedor, '') ilike '%levic%'
group by r.id, r.folio, r.proveedor, r.estado, r.fecha, r.total_ticket;

select
  i.id,
  i.codigo_escaneado as ean,
  left(i.nombre_snapshot, 56) as nombre,
  i.cantidad,
  i.costo_estimado,
  i.numero_lote,
  case when i.pendiente_alta then 'ALTA NUEVA' else 'YA EXISTE' end as estado,
  p.sku
from public.recepcion_items i
join public.recepciones r on r.id = i.recepcion_id
left join public.productos p on p.id = i.producto_id
where r.folio = '9012722225' and coalesce(r.proveedor, '') ilike '%levic%'
order by i.id;
