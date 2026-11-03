-- Levic · factura interna A 9012545305 · CFDI 2026-10-26
-- Folio fiscal B57229E5-7DBB-4B9F-A23E-B1D28E33B872 (OCR foto) · PUE efectivo $1844.92
-- Receptor LUIS ANGEL PALILLERO VENTURA · 12 renglones · 59 pzas (TOT 59 hoja 1).
-- Subtotal CFDI $1750.53 + IVA $94.39 (Cintapore $20.07 + Microdacyn $74.32) = $1844.92.
-- Costo = Precio neto. Lote de fabrica en el papel (excepto AMSA: MMAA de la caja).
-- Caducidad del papel NO se escribe: Recibir captura MMAA de la caja. 0000 invalido.
-- BEA215 en papel = caja AMSA Diclofenaco iny 75 mg/3 mL C/2 (EAN 7501349025929 / EQ-AMS362).
-- SIN bloques dollar-quote (Supabase los corta). Sin galeria extra.
-- Idempotente mientras el ticket siga en borrador.
-- Pegar TODO este archivo en Supabase - SQL Editor - Run.

begin;

create temp table _fc_rx_levic9012545305 (
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
  imagen text,
  foto_file text
) on commit drop;

insert into _fc_rx_levic9012545305 (
  linea, clave, ean, sku, nombre, snap, qty, costo, precio, tipo, categoria,
  forma, marca, presentacion, principio_activo, concentracion, receta,
  stock_minimo, lote, imagen, foto_file
) values
  (1, 'ALP0598', '7503004908721', 'FC-1BF03D35', 'Acetonido de fluocinolona Alpharma crema 0.01%', 'ACETONIDO DE FLUOCINOLONA CMA 40/01/100G', 5, 19.79, 32, 'generico', 'Medicamentos', 'Crema', 'Alpharma', 'Tubo 40 g', 'Acetonido de fluocinolona', '0.01%', true, 2, '2605164', null, null),
  (2, 'ALP0673', '7502226294476', 'EQ-ALP0673', 'Acetonido de fluocinolona Alpharma crema 0.01%', 'ACETONIDO DE FLUOCINOLONA CMA 20/01/100G', 5, 11.46, 19, 'generico', 'Medicamentos', 'Crema', 'Alpharma', 'Tubo 20 g', 'Acetonido de fluocinolona', '0.01%', true, 2, '2609272', 'https://www.farmacapital.mx/catalogo-propia/acetonido-fluocinolona-alpharma-20g-7502226294476.jpg', 'catalogo-propia/acetonido-fluocinolona-alpharma-20g-7502226294476.jpg'),
  (3, 'BEA215', '7501349025929', 'EQ-AMS362', 'Diclofenaco 75 mg/3 ml C/2 ampolletas AMSA', 'DICLOFENACO 2 FA 75MG/3 ML | AMSA (factura BEA215; caja AMSA)', 5, 7.67, 13, 'generico', 'Medicamentos', 'Solucion inyectable', 'AMSA', 'Caja con 2 ampolletas de 3 ml', 'Diclofenaco sodico', '75 mg/3 ml', true, 2, null, null, null),
  (4, 'BIO149', '7501573906407', 'FC-73906407', 'Lozamir-V clotrimazol crema 2%', 'LOZAMIR V C/3 APLICS 1 CMA 2% 20G', 5, 22.52, 29, 'marca', 'Medicamentos', 'Crema', 'Biomep', 'Tubo 20 g con 3 aplicadores', 'Clotrimazol', '2%', true, 2, 'CE2607', null, null),
  (5, 'BIO213', '7501573909859', 'FC-73909859', 'Sarox omeprazol 20 mg', 'SAROX 28 CAPS 20 MG', 5, 15.00, 19, 'marca', 'Medicamentos', 'Capsulas', 'Biomep', 'Caja con 28 capsulas', 'Omeprazol', '20 mg', true, 2, 'SG2653', null, null),
  (6, 'BRU053', '7501537102845', 'EQ-BRU053', 'Nediclon diclofenaco 100 mg', 'NEDICLON 20 GRAG 100 MG', 20, 8.84, 15, 'generico', 'Medicamentos', 'Grageas', 'Bruluart', 'Caja con 20 grageas de liberacion prolongada', 'Diclofenaco', '100 mg', true, 4, '807352', null, null),
  (7, 'BRU070', '7501537102067', 'EQ-BRU070', 'Soltrim trimetoprima/sulfametoxazol 40/200', 'SOLTRIM 1 SUSP 40/200/5/120 ML', 2, 28.00, 35, 'marca', 'Medicamentos', 'Suspension', 'Bruluart', 'Frasco suspension 120 mL', 'Trimetoprima / Sulfametoxazol', '40 mg / 200 mg / 5 mL', true, 2, '2605486', 'https://www.farmacapital.mx/catalogo-propia/soltrim-suspension-40-200-120ml-bruluart-7501537102067.jpg', 'catalogo-propia/soltrim-suspension-40-200-120ml-bruluart-7501537102067.jpg'),
  (8, 'CHI029', '7501088545658', 'EQ-CHI029', 'Mydocalm-A paracetamol/tolperisona 300/50 mg', 'MYDOCALM A 30 CAPS 300 MG/50 MG', 1, 363.75, 455, 'marca', 'Medicamentos', 'Capsulas', 'Chinoin', 'Caja con 30 capsulas', 'Paracetamol / Tolperisona', '300 mg / 50 mg', true, 1, 'BFC021', 'https://www.farmacapital.mx/catalogo-propia/mydocalm-a-paracetamol-tolperisona-300-50-30-caps-7501088545658.jpg', 'catalogo-propia/mydocalm-a-paracetamol-tolperisona-300-50-30-caps-7501088545658.jpg'),
  (9, 'COD106', '7506484500034', 'FC-84500034', 'Cintapore micropore piel', 'CINTAPORE PIEL 12 PZAS 2.5 CM X 5 M', 1, 125.43, 157, 'marca', 'Botiquin', 'Cinta', 'Codifarma', 'Caja con 12 rollos 2.5 cm x 5 m', null, null, false, 1, '2804022', 'https://www.farmacapital.mx/catalogo-propia/cintapore-piel-2.5x5.jpg', 'catalogo-propia/cintapore-piel-2.5x5.jpg'),
  (10, 'FAC0059', '7502006920021', 'FC-06920021', 'Motilaxil-T picosulfato de sodio 5 mg', 'MOTILAXIL 20 TAB 5 MG', 5, 17.95, 23, 'marca', 'Medicamentos', 'Tabletas', 'Farmacos Continentales', 'Caja con 20 tabletas', 'Picosulfato de sodio', '5 mg', false, 2, 'ITG265092', null, null),
  (11, 'RAM092', '7502227874417', 'EQ-RAM092', 'Raamcedo aceclofenaco 100 mg', 'RAAMCEDO 10 TAB 100 MG', 2, 46.04, 58, 'marca', 'Medicamentos', 'Tabletas', 'Raam', 'Caja con 10 tabletas', 'Aceclofenaco', '100 mg', true, 2, 'RMD033', 'https://www.farmacapital.mx/catalogo-propia/raamcedo-aceclofenaco-100mg-10-raam-7502227874417.jpg', 'catalogo-propia/raamcedo-aceclofenaco-100mg-10-raam-7502227874417.jpg'),
  (12, 'SFE159', '7503006698316', 'FC-06698316', 'Microdacyn 60 solucion antiseptica 120 ml', 'MICRODACYN 1 SOL 120 ML', 3, 154.84, 194, 'marca', 'Botiquin', 'Solucion', 'Microdacyn', 'Frasco spray 120 mL', 'Acido hipocloroso', null, false, 2, '209GD984', 'https://www.farmacapital.mx/catalogo-propia/microdacyn-60-solucion-120ml.jpg', 'catalogo-propia/microdacyn-60-solucion-120ml.jpg');

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
  'Factura Levic 9012545305 · clave ' || t.clave || ' · lote ' || coalesce(t.lote, 'caja'),
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
from _fc_rx_levic9012545305 t
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
from _fc_rx_levic9012545305 t
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
from _fc_rx_levic9012545305 t
where p.id = coalesce(
  public.fc_buscar_producto_escaneo(nullif(t.ean, '')),
  public.fc_buscar_producto_escaneo(t.sku)
);

-- Si se habia ligado EAN Beadvance a EQ-BEA215 por error, soltarlo.
update public.productos
set codigo_barras = null
where sku = 'EQ-BEA215'
  and codigo_barras in ('7501342802145', '7501349025929');

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'Levic',
  '9012545305',
  '2026-10-26',
  1844.92,
  'borrador',
  'Factura Levic A 9012545305 · CFDI B57229E5-7DBB-4B9F-A23E-B1D28E33B872 · BEA215 en papel pero caja AMSA iny 7501349025929 · cola Recibir; MMAA de la caja'
where not exists (
  select 1 from public.recepciones
  where folio = '9012545305' and coalesce(proveedor, '') ilike '%levic%'
);

update public.recepciones
set
  total_ticket = 1844.92,
  fecha = '2026-10-26',
  proveedor = 'Levic',
  notas = 'Factura Levic A 9012545305 · CFDI B57229E5-7DBB-4B9F-A23E-B1D28E33B872 · BEA215 en papel pero caja AMSA iny 7501349025929 · cola Recibir; MMAA de la caja',
  updated_at = now()
where folio = '9012545305'
  and coalesce(proveedor, '') ilike '%levic%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = '9012545305'
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
from _fc_rx_levic9012545305 t
join public.recepciones r
  on r.folio = '9012545305'
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
where r.folio = '9012545305' and coalesce(r.proveedor, '') ilike '%levic%'
order by i.id;
