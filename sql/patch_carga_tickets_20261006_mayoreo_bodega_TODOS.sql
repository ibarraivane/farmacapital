-- ═══════════════════════════════════════════════════════════════
-- TICKETS 06-OCT-2026 (tarde) · Farma Mayoreo + Bodega F-42
-- Ver LEERME_tickets_20261006_mayoreo_bodega.md
-- ═══════════════════════════════════════════════════════════════


-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- INICIO: patch_carga_farmamayoreo_308422.sql
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Farma Mayoreo · ID VENTA 308422 · 2026-10-06 16:34 · caja 0 · Rosalba M.
-- RFC FMA180119D55 · sucursal FARMAMAYOREO CENTRAL (Canal de Apatlaco, CEDA).
-- Pago tarjeta. SUBTOTAL $2,099.84 + IVA $286.13 = TOTAL $2,385.97.
-- Los P.U. ya traen IVA (suma de renglones = total). 18 renglones / 58 pzas.
-- Fichas Go-UPC / Farmatodo / marca, no el recorte del térmico.
-- Lote de fábrica sí (si no se repite el Lt. del renglón de arriba).
-- Caducidad NO: Recibir pide MMAA de la caja. 0000 es inválido.
-- Nivea Soft EAN canónico 7501054549819 (ticket térmico confunde 3/5).
-- Fixodent Original EAN 5000174305449.
-- Tempra SOL PED → solución pediátrica uva 30 ml (Farmatodo).
-- 10 alta(s) stock 0. 8 ya estaban: solo costo / ficha vacía, no PVP.
-- Nombres de ficha, no del ticket. Fotos en public/catalogo-propia/ (tras deploy).
-- SIN bloques dollar-quote. Idempotente mientras el ticket siga en borrador.
-- Pegar TODO este archivo en Supabase → SQL Editor → Run.

begin;

create temp table _fc_fm308422 (
  linea integer primary key,
  ean text not null,
  sku text not null,
  nombre text not null,
  snap text not null,
  qty integer not null,
  costo numeric(12,2) not null,
  precio numeric(12,2) not null,
  tipo text not null,
  categoria text not null,
  subcategoria text,
  forma text,
  marca text,
  laboratorio text,
  presentacion text,
  principio_activo text,
  concentracion text,
  receta boolean not null,
  ya boolean not null,
  imagen text,
  foto_file text,
  lote text
) on commit drop;

insert into _fc_fm308422 (
  linea, ean, sku, nombre, snap, qty, costo, precio, tipo, categoria,
  subcategoria, forma, marca, laboratorio, presentacion, principio_activo,
  concentracion, receta, ya, imagen, foto_file, lote
) values
  (1, '7501082731323', 'FC-82731323', 'Nuvel Beauty antitranspirante roll-on', 'DESODORANTE ROLL', 4, 11.96, 15, 'marca', 'Cuidado personal', 'Desodorante', 'Roll-on', 'Nuvel', null, '55 ml', null, null, false, false, 'https://www.farmacapital.mx/catalogo-propia/nuvel-beauty-rollon-55ml-7501082731323.jpg', 'catalogo-propia/nuvel-beauty-rollon-55ml-7501082731323.jpg', '019123'),
  (2, '7501082731286', 'FC-82731286', 'Nuvel Addiction antitranspirante roll-on', 'DESODORANTE ROLL', 2, 11.96, 15, 'marca', 'Cuidado personal', 'Desodorante', 'Roll-on', 'Nuvel', null, '55 ml', null, null, false, false, 'https://www.farmacapital.mx/catalogo-propia/nuvel-addiction-rollon-55ml-7501082731286.jpg', 'catalogo-propia/nuvel-addiction-rollon-55ml-7501082731286.jpg', '613203'),
  (3, '7500462933746', 'FC-62933746', 'Inha-Rub ungüento', 'ADN INHA RUB UNG', 3, 23.98, 39, 'generico', 'Medicamentos', 'Resfriado', 'Ungüento', 'ADN Pharma', 'ADN Pharma', 'Tarro 40 g', 'Alcanfor / mentol / eucalipto', null, false, false, 'https://www.farmacapital.mx/catalogo-propia/adn-inha-rub-40g-7500462933746.jpg', 'catalogo-propia/adn-inha-rub-40g-7500462933746.jpg', '2601VP34'),
  (4, '7501054549819', 'FC-54549819', 'Nivea Soft Milk', 'NIVEA CREMA SOFT', 3, 27.81, 35, 'marca', 'Cuidado personal', 'Crema corporal', 'Crema', 'Nivea', 'Beiersdorf', '100 ml', null, null, false, true, null, null, null),
  (5, '7501044205725', 'FC-44205725', 'Olorex talco para pies mentol', 'TALCO OLOREX CON', 2, 19.98, 25, 'marca', 'Cuidado personal', 'Talco', 'Talco', 'Olorex', null, '80 g', null, null, false, false, 'https://www.farmacapital.mx/catalogo-propia/olorex-talco-mentol-80g-7501044205725.jpg', 'catalogo-propia/olorex-talco-mentol-80g-7501044205725.jpg', 'TB14E26'),
  (6, '7501044205718', 'FC-44205718', 'Olorex talco para pies clásico', 'TALCO OLOREX ORI', 2, 19.98, 25, 'marca', 'Cuidado personal', 'Talco', 'Talco', 'Olorex', null, '80 g', null, null, false, false, 'https://www.farmacapital.mx/catalogo-propia/olorex-talco-clasico-80g-7501044205718.jpg', 'catalogo-propia/olorex-talco-clasico-80g-7501044205718.jpg', 'MG3026'),
  (7, '7501058714312', 'FC-58714312', 'Tempra solución pediátrica uva', 'TEMPRA SOL PED 3', 2, 155.98, 195, 'marca', 'Medicamentos', 'Analgésico', 'Solución', 'Tempra', 'RB Health', 'Frasco 30 ml', 'Paracetamol', '100 mg/ml', false, true, 'https://www.farmacapital.mx/catalogo-propia/tempra-solucion-pediatrica-uva-30ml-7501058714312.jpg', 'catalogo-propia/tempra-solucion-pediatrica-uva-30ml-7501058714312.jpg', 'ABJ8273'),
  (8, '7896009499180', 'FC-09499180', 'Sensodyne Limpieza Profunda', 'C D SENSODYNE LI', 2, 39.98, 50, 'marca', 'Cuidado personal', 'Higiene bucal', 'Crema dental', 'Sensodyne', 'Haleon', 'Tubo 50 g', null, null, false, false, 'https://www.farmacapital.mx/catalogo-propia/sensodyne-limpieza-profunda-50g-7896009499180.jpg', 'catalogo-propia/sensodyne-limpieza-profunda-50g-7896009499180.jpg', 'KD9L'),
  (9, '7896009498091', 'FC-09498091', 'Sensodyne Protección Completa', 'SENSODYNE PROTEC', 1, 66.98, 84, 'marca', 'Cuidado personal', 'Higiene bucal', 'Crema dental', 'Sensodyne', 'Haleon', 'Tubo 90 g', null, null, false, true, null, null, 'VT6A'),
  (10, '5000174305449', 'FC-74305449', 'Fixodent Original adhesivo dental', 'FIXODENT ORIGINA', 2, 89.98, 113, 'marca', 'Cuidado personal', 'Higiene bucal', 'Crema adhesiva', 'Fixodent', 'P&G', 'Tubo 40 ml', null, null, false, true, 'https://www.farmacapital.mx/catalogo-propia/fixodent-original-40ml-5000174305449.jpg', 'catalogo-propia/fixodent-original-40ml-5000174305449.jpg', '5072028890'),
  (11, '7506346604726', 'FC-46604726', 'Vaso coprocultivo estéril Kohn', 'VASO COPRO ESTER', 13, 4.50, 6, 'marca', 'Botiquín', 'Material de curación', 'Vaso', 'Kohn', null, '100 ml', null, null, false, false, 'https://www.farmacapital.mx/catalogo-propia/kohn-vaso-copro-100ml-7506346604726.jpg', 'catalogo-propia/kohn-vaso-copro-100ml-7506346604726.jpg', '1460726'),
  (12, '7501054549796', 'FC-54549796', 'Nivea Milk Nutritiva', 'NIVEA CREMA MILK', 3, 25.97, 33, 'marca', 'Cuidado personal', 'Crema corporal', 'Crema', 'Nivea', 'Beiersdorf', '100 ml', null, null, false, true, null, null, null),
  (13, '7501058793232', 'FC-58793232', 'Sico lubricante cereza', 'SICO LUBRICANTE', 3, 97.98, 123, 'marca', 'Cuidado personal', 'Salud sexual', 'Lubricante', 'Sico', 'RB Health', '50 ml', null, null, false, true, null, null, 'A3G9728'),
  (14, '7501058793249', 'FC-58793249', 'Sico lubricante sensación calor', 'SICO LUBRICANTE', 3, 96.98, 122, 'marca', 'Cuidado personal', 'Salud sexual', 'Lubricante', 'Sico', 'RB Health', '50 ml', null, null, false, true, null, null, 'A3H4789'),
  (15, '7500435169035', 'FC-35169035', 'Herbal Essences mousse rizo', 'HERBAL ESSENCES', 10, 58.98, 74, 'marca', 'Cuidado personal', 'Cabello', 'Mousse', 'Herbal Essences', 'P&G', '210 ml', null, null, false, true, null, null, '6164C24591102233'),
  (16, '7506306210103', 'FC-06210103', 'eGo Force desodorante aerosol', 'DES EGO FORCE 24', 1, 42.99, 54, 'marca', 'Cuidado personal', 'Desodorante', 'Aerosol', 'eGo', 'Unilever', '150 ml', null, null, false, false, 'https://www.farmacapital.mx/catalogo-propia/ego-force-aerosol-150ml-7506306210103.jpg', 'catalogo-propia/ego-force-aerosol-150ml-7506306210103.jpg', '262107'),
  (17, '7506306221765', 'FC-06221765', 'eGo Ultra Fresh desodorante aerosol', 'DES EGO ULTRA FR', 1, 42.99, 54, 'marca', 'Cuidado personal', 'Desodorante', 'Aerosol', 'eGo', 'Unilever', '150 ml', null, null, false, false, 'https://www.farmacapital.mx/catalogo-propia/ego-ultra-fresh-aerosol-150ml-7506306221765.jpg', 'catalogo-propia/ego-ultra-fresh-aerosol-150ml-7506306221765.jpg', 'CODWZH'),
  (18, '7506306210080', 'FC-06210080', 'eGo Sport desodorante aerosol', 'DES EGO AEROSOL', 1, 42.99, 54, 'marca', 'Cuidado personal', 'Desodorante', 'Aerosol', 'eGo', 'Unilever', '150 ml', null, null, false, false, 'https://www.farmacapital.mx/catalogo-propia/ego-sport-aerosol-150ml-7506306210080.jpg', 'catalogo-propia/ego-sport-aerosol-150ml-7506306210080.jpg', '26219');

-- Una fila por EAN (mismo producto con 2 lotes no debe insertar 2 veces el SKU).
insert into public.productos (
  nombre, sku, codigo_barras, categoria, subcategoria, tipo, descripcion,
  costo, precio, stock, stock_minimo, activo, requiere_receta,
  marca, presentacion, forma_farmaceutica, principio_activo, concentracion,
  laboratorio, imagen_url, imagen_mobile_url
)
select
  t.nombre,
  case
    when exists (
      select 1 from public.productos p
      where p.sku = t.sku and coalesce(p.codigo_barras, '') <> t.ean
    ) then 'FC-ND-' || right(t.ean, 8)
    else t.sku
  end,
  t.ean,
  t.categoria,
  t.subcategoria,
  t.tipo,
  'Alta Farma Mayoreo 308422 · 2026-10-06 · listo para pistola',
  t.costo,
  t.precio,
  0,
  1,
  true,
  t.receta,
  t.marca,
  t.presentacion,
  t.forma,
  t.principio_activo,
  t.concentracion,
  t.laboratorio,
  t.imagen,
  t.imagen
from (
  select distinct on (ean) *
  from _fc_fm308422
  order by ean, linea
) t
where public.fc_buscar_producto_escaneo(t.ean) is null
  and public.fc_buscar_producto_escaneo(t.sku) is null;

-- Ya existían: costo. PVP solo si estaba en 0.
update public.productos p
set
  costo = t.costo,
  precio = case
    when coalesce(p.precio, 0) <= 0 then t.precio
    else p.precio
  end
from (
  select distinct on (ean) *
  from _fc_fm308422
  order by ean, linea
) t
where p.id = coalesce(
  public.fc_buscar_producto_escaneo(t.ean),
  public.fc_buscar_producto_escaneo(t.sku)
)
  and (
    p.costo is distinct from t.costo
    or coalesce(p.precio, 0) <= 0
  );

-- Ficha vacía / foto si falta. No pisa una foto que ya esté.
update public.productos p
set
  nombre = case
    when length(trim(coalesce(p.nombre, ''))) < 8 then t.nombre
    else p.nombre
  end,
  marca = coalesce(nullif(trim(p.marca), ''), t.marca),
  presentacion = coalesce(nullif(trim(p.presentacion), ''), t.presentacion),
  principio_activo = coalesce(nullif(trim(p.principio_activo), ''), t.principio_activo),
  concentracion = coalesce(nullif(trim(p.concentracion), ''), t.concentracion),
  laboratorio = coalesce(nullif(trim(p.laboratorio), ''), t.laboratorio),
  subcategoria = coalesce(nullif(trim(p.subcategoria), ''), t.subcategoria),
  forma_farmaceutica = coalesce(nullif(trim(p.forma_farmaceutica), ''), t.forma),
  imagen_url = coalesce(nullif(trim(p.imagen_url), ''), t.imagen),
  imagen_mobile_url = coalesce(nullif(trim(p.imagen_mobile_url), ''), t.imagen),
  codigo_barras = coalesce(nullif(trim(p.codigo_barras), ''), t.ean)
from (
  select distinct on (ean) *
  from _fc_fm308422
  order by ean, linea
) t
where p.id = coalesce(
  public.fc_buscar_producto_escaneo(t.ean),
  public.fc_buscar_producto_escaneo(t.sku)
);

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'Farma Mayoreo',
  '308422',
  '2026-10-06',
  2385.97,
  'borrador',
  'Ticket Farma Mayoreo 308422 · 06-oct-2026 · CEDA · tarjeta $2,385.97 · cola Recibir; stock al confirmar pistola · lote de fábrica en el papel; MMAA de la caja'
where not exists (
  select 1 from public.recepciones
  where folio = '308422'
    and coalesce(proveedor, '') ilike '%farma mayoreo%'
);

update public.recepciones
set
  total_ticket = 2385.97,
  fecha = '2026-10-06',
  proveedor = 'Farma Mayoreo',
  notas = 'Ticket Farma Mayoreo 308422 · 06-oct-2026 · CEDA · tarjeta $2,385.97 · cola Recibir; stock al confirmar pistola · lote de fábrica en el papel; MMAA de la caja',
  updated_at = now()
where folio = '308422'
  and coalesce(proveedor, '') ilike '%farma mayoreo%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = '308422'
  and coalesce(r.proveedor, '') ilike '%farma mayoreo%'
  and r.estado = 'borrador';

insert into public.recepcion_items (
  recepcion_id, producto_id, codigo_escaneado, nombre_snapshot,
  cantidad, fecha_caducidad, numero_lote, costo_estimado, pendiente_alta,
  origen, confirmado, lote_distinto, lote_id
)
select
  r.id,
  v.pid,
  t.ean,
  t.nombre,
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
    )
  ),
  null
from _fc_fm308422 t
join public.recepciones r
  on r.folio = '308422'
 and coalesce(r.proveedor, '') ilike '%farma mayoreo%'
 and r.estado = 'borrador'
left join lateral (
  select coalesce(
    public.fc_buscar_producto_escaneo(t.ean),
    public.fc_buscar_producto_escaneo(t.sku)
  ) as pid
) v on true
order by t.linea;

insert into public.producto_imagenes
  (producto_id, url, storage_path, posicion, es_principal, origen)
select
  p.id,
  t.imagen,
  t.foto_file,
  coalesce((
    select max(i.posicion) from public.producto_imagenes i
    where i.producto_id = p.id
  ), 0) + 1,
  not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id and coalesce(i.es_principal, false)
  ),
  'propia'
from _fc_fm308422 t
join public.productos p on p.id = coalesce(
  public.fc_buscar_producto_escaneo(t.ean),
  public.fc_buscar_producto_escaneo(t.sku)
)
where t.imagen is not null
  and not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id
      and (i.url = t.imagen or i.storage_path = t.foto_file)
  );

-- Diagnóstico
select
  r.folio,
  r.proveedor,
  r.estado,
  r.total_ticket,
  count(i.*) as renglones,
  sum(i.cantidad) as piezas,
  bool_or(i.pendiente_alta) as tiene_pendiente_alta
from public.recepciones r
left join public.recepcion_items i on i.recepcion_id = r.id
where r.folio = '308422'
  and coalesce(r.proveedor, '') ilike '%farma mayoreo%'
group by r.id, r.folio, r.proveedor, r.estado, r.total_ticket;

select
  t.linea,
  t.ean,
  t.nombre,
  t.qty,
  t.costo,
  case when public.fc_buscar_producto_escaneo(t.ean) is null then 'PENDIENTE_ALTA' else 'OK' end as match,
  t.ya as marcado_ya
from _fc_fm308422 t
order by t.linea;

commit;


-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- INICIO: patch_carga_bodega_f42_83450.sql
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Bodega F-42 Ejidos del Moral · Caja 2/83450 · 2026-10-06 16:59
-- Ticket térmico. Subtotal $556.49 + impuestos $85.18 = $641.67.
-- Costo = P.U. impreso (suma renglones ≈ total con impuestos).
-- Sin lote ni caducidad (MMAA de la caja). No inventar 0000.
-- 7 renglones / 14 pzas. Fichas Go-UPC / Farmatodo, no el ticket.
-- 5 alta(s) stock 0. 2 ya estaban: solo costo / ficha vacía, no PVP.
-- Nombres de ficha, no del ticket. Fotos en public/catalogo-propia/ (tras deploy).
-- SIN bloques dollar-quote. Idempotente mientras el ticket siga en borrador.
-- Pegar TODO este archivo en Supabase → SQL Editor → Run.

begin;

create temp table _fc_bf42_83450 (
  linea integer primary key,
  ean text not null,
  sku text not null,
  nombre text not null,
  snap text not null,
  qty integer not null,
  costo numeric(12,2) not null,
  precio numeric(12,2) not null,
  tipo text not null,
  categoria text not null,
  subcategoria text,
  forma text,
  marca text,
  laboratorio text,
  presentacion text,
  principio_activo text,
  concentracion text,
  receta boolean not null,
  ya boolean not null,
  imagen text,
  foto_file text,
  lote text
) on commit drop;

insert into _fc_bf42_83450 (
  linea, ean, sku, nombre, snap, qty, costo, precio, tipo, categoria,
  subcategoria, forma, marca, laboratorio, presentacion, principio_activo,
  concentracion, receta, ya, imagen, foto_file, lote
) values
  (1, '7501943494220', 'FC-43494220', 'Kotex Unika nocturna con alas', 'TAS SANIT KOTEX UNIKA NOC C/10', 1, 24.14, 31, 'marca', 'Cuidado personal', 'Higiene femenina', 'Toalla', 'Kotex', 'Kimberly-Clark', 'Paquete con 10 piezas', null, null, false, false, 'https://www.farmacapital.mx/catalogo-propia/kotex-unika-nocturna-c10-7501943494220.jpg', 'catalogo-propia/kotex-unika-nocturna-c10-7501943494220.jpg', null),
  (2, '7501022182796', 'FC-22182796', 'Grisi jabón barra neutro', 'GRISI 150GR JBN BARRA NEUTRO PACK3', 2, 34.86, 44, 'marca', 'Cuidado personal', 'Higiene', 'Jabón', 'Grisi', null, 'Pack 3 barras 150 g', null, null, false, false, 'https://www.farmacapital.mx/catalogo-propia/grisi-jabon-neutro-pack3-7501022182796.jpg', 'catalogo-propia/grisi-jabon-neutro-pack3-7501022182796.jpg', null),
  (3, '7501048352005', 'FC-48352005', 'Protec toallitas con alcohol', 'TAS PROTEC C/ALCOHOL 100 PZS', 2, 69.06, 87, 'marca', 'Botiquín', 'Material de curación', 'Toallitas', 'Protec', null, 'Bote con 100 piezas', null, null, false, false, 'https://www.farmacapital.mx/catalogo-propia/protec-toallitas-alcohol-100-7501048352005.jpg', 'catalogo-propia/protec-toallitas-alcohol-100-7501048352005.jpg', null),
  (4, '7501007528939', 'FC-07528939', 'Lubriderm Reparación Intensiva', 'CRA LUBRIDERM THINT PSEC120ML', 2, 31.58, 40, 'marca', 'Cuidado personal', 'Crema corporal', 'Crema', 'Lubriderm', 'J&J', '120 ml', null, null, false, true, null, null, null),
  (5, '7702035469151', 'FC-35469151', 'Lubriderm UV FPS 15', 'CRA LUBRIDERM UV FPS15 120ML', 2, 34.41, 44, 'marca', 'Cuidado personal', 'Crema corporal', 'Crema', 'Lubriderm', 'J&J', '120 ml', null, 'FPS 15', false, true, null, null, null),
  (6, '3614225108778', 'FC-25108778', 'Koleston Castaño Aterciopelado 477', 'TIN KOLESTON CRA GLOSS CAST ATERCIO 477', 1, 54.07, 68, 'marca', 'Cuidado personal', 'Cabello', 'Tinte', 'Koleston', 'Wella', 'Kit crema', null, null, false, false, 'https://www.farmacapital.mx/catalogo-propia/koleston-castano-aterciopelado-477-3614225108778.jpg', 'catalogo-propia/koleston-castano-aterciopelado-477-3614225108778.jpg', null),
  (7, '7506339390278', 'FC-39390278', 'Old Spice Leña spray corporal', 'DESOD OLD SPICE LENA SPY 150ML', 4, 55.91, 70, 'marca', 'Cuidado personal', 'Desodorante', 'Aerosol', 'Old Spice', 'P&G', '150 ml', null, null, false, false, 'https://www.farmacapital.mx/catalogo-propia/old-spice-lena-spray-150ml-7506339390278.jpg', 'catalogo-propia/old-spice-lena-spray-150ml-7506339390278.jpg', null);

-- Una fila por EAN (mismo producto con 2 lotes no debe insertar 2 veces el SKU).
insert into public.productos (
  nombre, sku, codigo_barras, categoria, subcategoria, tipo, descripcion,
  costo, precio, stock, stock_minimo, activo, requiere_receta,
  marca, presentacion, forma_farmaceutica, principio_activo, concentracion,
  laboratorio, imagen_url, imagen_mobile_url
)
select
  t.nombre,
  case
    when exists (
      select 1 from public.productos p
      where p.sku = t.sku and coalesce(p.codigo_barras, '') <> t.ean
    ) then 'FC-ND-' || right(t.ean, 8)
    else t.sku
  end,
  t.ean,
  t.categoria,
  t.subcategoria,
  t.tipo,
  'Alta Bodega F-42 Ejidos del Moral 83450 · 2026-10-06 · listo para pistola',
  t.costo,
  t.precio,
  0,
  1,
  true,
  t.receta,
  t.marca,
  t.presentacion,
  t.forma,
  t.principio_activo,
  t.concentracion,
  t.laboratorio,
  t.imagen,
  t.imagen
from (
  select distinct on (ean) *
  from _fc_bf42_83450
  order by ean, linea
) t
where public.fc_buscar_producto_escaneo(t.ean) is null
  and public.fc_buscar_producto_escaneo(t.sku) is null;

-- Ya existían: costo. PVP solo si estaba en 0.
update public.productos p
set
  costo = t.costo,
  precio = case
    when coalesce(p.precio, 0) <= 0 then t.precio
    else p.precio
  end
from (
  select distinct on (ean) *
  from _fc_bf42_83450
  order by ean, linea
) t
where p.id = coalesce(
  public.fc_buscar_producto_escaneo(t.ean),
  public.fc_buscar_producto_escaneo(t.sku)
)
  and (
    p.costo is distinct from t.costo
    or coalesce(p.precio, 0) <= 0
  );

-- Ficha vacía / foto si falta. No pisa una foto que ya esté.
update public.productos p
set
  nombre = case
    when length(trim(coalesce(p.nombre, ''))) < 8 then t.nombre
    else p.nombre
  end,
  marca = coalesce(nullif(trim(p.marca), ''), t.marca),
  presentacion = coalesce(nullif(trim(p.presentacion), ''), t.presentacion),
  principio_activo = coalesce(nullif(trim(p.principio_activo), ''), t.principio_activo),
  concentracion = coalesce(nullif(trim(p.concentracion), ''), t.concentracion),
  laboratorio = coalesce(nullif(trim(p.laboratorio), ''), t.laboratorio),
  subcategoria = coalesce(nullif(trim(p.subcategoria), ''), t.subcategoria),
  forma_farmaceutica = coalesce(nullif(trim(p.forma_farmaceutica), ''), t.forma),
  imagen_url = coalesce(nullif(trim(p.imagen_url), ''), t.imagen),
  imagen_mobile_url = coalesce(nullif(trim(p.imagen_mobile_url), ''), t.imagen),
  codigo_barras = coalesce(nullif(trim(p.codigo_barras), ''), t.ean)
from (
  select distinct on (ean) *
  from _fc_bf42_83450
  order by ean, linea
) t
where p.id = coalesce(
  public.fc_buscar_producto_escaneo(t.ean),
  public.fc_buscar_producto_escaneo(t.sku)
);

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'Bodega F-42 Ejidos del Moral',
  '83450',
  '2026-10-06',
  641.67,
  'borrador',
  'Ticket Bodega F-42 Caja 2/83450 · 06-oct-2026 · foto térmica · tarjeta $641.67 · cola Recibir; stock al confirmar pistola'
where not exists (
  select 1 from public.recepciones
  where folio = '83450'
    and coalesce(proveedor, '') ilike '%bodega f-42%'
);

update public.recepciones
set
  total_ticket = 641.67,
  fecha = '2026-10-06',
  proveedor = 'Bodega F-42 Ejidos del Moral',
  notas = 'Ticket Bodega F-42 Caja 2/83450 · 06-oct-2026 · foto térmica · tarjeta $641.67 · cola Recibir; stock al confirmar pistola',
  updated_at = now()
where folio = '83450'
  and coalesce(proveedor, '') ilike '%bodega f-42%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = '83450'
  and coalesce(r.proveedor, '') ilike '%bodega f-42%'
  and r.estado = 'borrador';

insert into public.recepcion_items (
  recepcion_id, producto_id, codigo_escaneado, nombre_snapshot,
  cantidad, fecha_caducidad, numero_lote, costo_estimado, pendiente_alta,
  origen, confirmado, lote_distinto, lote_id
)
select
  r.id,
  v.pid,
  t.ean,
  t.nombre,
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
    )
  ),
  null
from _fc_bf42_83450 t
join public.recepciones r
  on r.folio = '83450'
 and coalesce(r.proveedor, '') ilike '%bodega f-42%'
 and r.estado = 'borrador'
left join lateral (
  select coalesce(
    public.fc_buscar_producto_escaneo(t.ean),
    public.fc_buscar_producto_escaneo(t.sku)
  ) as pid
) v on true
order by t.linea;

insert into public.producto_imagenes
  (producto_id, url, storage_path, posicion, es_principal, origen)
select
  p.id,
  t.imagen,
  t.foto_file,
  coalesce((
    select max(i.posicion) from public.producto_imagenes i
    where i.producto_id = p.id
  ), 0) + 1,
  not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id and coalesce(i.es_principal, false)
  ),
  'propia'
from _fc_bf42_83450 t
join public.productos p on p.id = coalesce(
  public.fc_buscar_producto_escaneo(t.ean),
  public.fc_buscar_producto_escaneo(t.sku)
)
where t.imagen is not null
  and not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id
      and (i.url = t.imagen or i.storage_path = t.foto_file)
  );

-- Diagnóstico
select
  r.folio,
  r.proveedor,
  r.estado,
  r.total_ticket,
  count(i.*) as renglones,
  sum(i.cantidad) as piezas,
  bool_or(i.pendiente_alta) as tiene_pendiente_alta
from public.recepciones r
left join public.recepcion_items i on i.recepcion_id = r.id
where r.folio = '83450'
  and coalesce(r.proveedor, '') ilike '%bodega f-42%'
group by r.id, r.folio, r.proveedor, r.estado, r.total_ticket;

select
  t.linea,
  t.ean,
  t.nombre,
  t.qty,
  t.costo,
  case when public.fc_buscar_producto_escaneo(t.ean) is null then 'PENDIENTE_ALTA' else 'OK' end as match,
  t.ya as marcado_ya
from _fc_bf42_83450 t
order by t.linea;

commit;
