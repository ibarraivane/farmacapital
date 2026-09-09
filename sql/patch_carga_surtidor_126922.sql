-- El Surtidor · venta 126922 · 2026-09-08 · Luis · F48 Central de Abastos
-- Ticket térmico Alfredo Murillo Guzmán (El Surtidor de su Farmacia).
-- Total ticket $474.59 (Aspirina con 33.5% desc → costo 134.99).
-- 2 altas stock 0. 7 ya estaban (ticket 112558): solo costo, no PVP.
-- Ensure FSA 7501033950063: si quedó como Pediasure, se renombra a Ensure fresa.
-- Saba: OCR del ticket truncó el EAN a 750101906116; ficha YZA Largo 16 = 7501019068713.
-- Sin lote ni caducidad (MMAA de la caja). No inventar 0000.
-- Nombres de ficha, no del ticket. Fotos en public/catalogo-propia/ (tras deploy).
-- SIN bloques dollar-quote. Idempotente mientras el ticket siga en borrador.
-- Pegar TODO este archivo en Supabase → SQL Editor → Run.

begin;

create temp table _fc_sur_126922 (
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
  foto_file text
) on commit drop;

insert into _fc_sur_126922 (
  linea, ean, sku, nombre, snap, qty, costo, precio, tipo, categoria,
  subcategoria, forma, marca, laboratorio, presentacion, principio_activo,
  concentracion, receta, ya, imagen, foto_file
) values
  (1, '7501318612655', 'FC-18612655', 'Aspirina Protect 100 mg C/28', 'ASPIRINA PROTEC TAB C/28 100MG', 1, 134.99, 203, 'marca', 'Analgésico', 'Antiagregante', 'Tabletas', 'Aspirina', 'BAYER', 'Caja con 28 tabletas de liberación retardada', 'Ácido acetilsalicílico', '100 mg', false, false, 'https://www.farmacapital.mx/catalogo-propia/aspirina-protect-100mg-28.jpg', 'catalogo-propia/aspirina-protect-100mg-28.jpg'),
  (2, '7501868901131', 'FC-68901131', 'Alcohol etílico Dibar azul 71.6° 1 L', 'DIBAR ALCOHOL AZUL 1LT', 2, 41.00, 62, 'marca', 'Botiquín', 'Alcohol', 'Alcohol etílico', 'Dibar', 'DIBAR', 'Frasco 1 L', 'Alcohol etílico', '71.6°', false, true, null, null),
  (3, '7501868901117', 'FC-68901117', 'Alcohol etílico Dibar azul 71.6° 250 ml', 'DIBAR ALCOHOL AZUL 250ML', 2, 11.30, 17, 'marca', 'Botiquín', 'Alcohol', 'Alcohol etílico', 'Dibar', 'DIBAR', 'Frasco 250 ml', 'Alcohol etílico', '71.6°', false, true, null, null),
  (4, '7501868901124', 'FC-68901124', 'Alcohol etílico Dibar azul 71.6° 500 ml', 'DIBAR ALCOHOL AZUL 500ML', 2, 24.00, 36, 'marca', 'Botiquín', 'Alcohol', 'Alcohol etílico', 'Dibar', 'DIBAR', 'Frasco 500 ml', 'Alcohol etílico', '71.6°', false, true, 'https://www.farmacapital.mx/catalogo-propia/dibar-azul-500ml.jpg', 'catalogo-propia/dibar-azul-500ml.jpg'),
  (5, '7501033950100', 'FC-33950100', 'Ensure líquido 236 ml chocolate', 'ENSURE LIQ 236ML CHTE', 1, 42.00, 63, 'marca', 'Suplemento', 'Líquido', 'Líquido', 'Ensure', 'ABBOTT', 'Tetra 236 ml', 'Suplemento nutricional', null, false, true, null, null),
  (6, '7501033950063', 'FC-33950063', 'Ensure líquido 236 ml fresa', 'ENSURE LIQ 236ML FSA', 1, 42.00, 63, 'marca', 'Suplemento', 'Líquido', 'Líquido', 'Ensure', 'ABBOTT', 'Tetra 236 ml', 'Suplemento nutricional', null, false, true, null, null),
  (7, '7501033951008', 'FC-33951008', 'Pediasure líquido 236 ml chocolate', 'PEDIASURE LIQ 236ML CHTE', 1, 44.00, 66, 'marca', 'Suplemento', 'Líquido', 'Líquido', 'Pediasure', 'ABBOTT', 'Tetra 236 ml', 'Suplemento nutricional', null, false, true, null, null),
  (8, '7501033950209', 'FC-33950209', 'Pediasure líquido 236 ml vainilla', 'PEDIASURE LIQ 236ML VNLLA', 1, 44.00, 66, 'marca', 'Suplemento', 'Líquido', 'Líquido', 'Pediasure', 'ABBOTT', 'Tetra 236 ml', 'Suplemento nutricional', null, false, true, null, null),
  (9, '7501019068713', 'FC-19068713', 'Saba pantiprotectores diarios largo C/16', 'SABA PANTY PROTEC LARGO C/16 CHICO', 1, 15.00, 23, 'marca', 'Higiene', 'Protectores diarios', 'Protectores diarios', 'Saba', 'ESSITY', 'Paquete con 16 protectores largos', null, null, false, false, 'https://www.farmacapital.mx/catalogo-propia/saba-panty-largo-16.jpg', 'catalogo-propia/saba-panty-largo-16.jpg');

-- Alinear EAN del ticket al SKU conocido (evita duplicar Ensure/Dibar del 112558).
update public.productos p
set codigo_barras = t.ean
from _fc_sur_126922 t
where p.sku = t.sku
  and t.ya
  and coalesce(nullif(trim(p.codigo_barras), ''), '') is distinct from t.ean
  and not exists (
    select 1 from public.productos o
    where o.codigo_barras = t.ean and o.id <> p.id
  );

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
    ) then 'FC-SUR-' || right(t.ean, 8)
    else t.sku
  end,
  t.ean,
  t.categoria,
  t.subcategoria,
  t.tipo,
  'Alta El Surtidor 126922 · 2026-09-08 · listo para pistola',
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
from _fc_sur_126922 t
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
from _fc_sur_126922 t
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
  marca = coalesce(nullif(trim(p.marca), ''), t.marca),
  presentacion = coalesce(nullif(trim(p.presentacion), ''), t.presentacion),
  principio_activo = coalesce(nullif(trim(p.principio_activo), ''), t.principio_activo),
  concentracion = coalesce(nullif(trim(p.concentracion), ''), t.concentracion),
  laboratorio = coalesce(nullif(trim(p.laboratorio), ''), t.laboratorio),
  subcategoria = coalesce(nullif(trim(p.subcategoria), ''), t.subcategoria),
  imagen_url = coalesce(nullif(trim(p.imagen_url), ''), t.imagen),
  imagen_mobile_url = coalesce(nullif(trim(p.imagen_mobile_url), ''), t.imagen)
from _fc_sur_126922 t
where p.id = coalesce(
    public.fc_buscar_producto_escaneo(t.ean),
    public.fc_buscar_producto_escaneo(t.sku)
  );

-- Ensure FSA: en 112558 el SKU FC-33950063 quedó mal como Pediasure fresa.
update public.productos p
set
  nombre = t.nombre,
  marca = t.marca,
  presentacion = coalesce(nullif(trim(p.presentacion), ''), t.presentacion),
  categoria = t.categoria,
  subcategoria = t.subcategoria
from _fc_sur_126922 t
where p.id = coalesce(
    public.fc_buscar_producto_escaneo(t.ean),
    public.fc_buscar_producto_escaneo(t.sku)
  )
  and t.ean = '7501033950063'
  and (
    p.nombre ~* 'pedia'
    or coalesce(p.marca, '') ~* 'pedia'
  );

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'El Surtidor',
  '126922',
  '2026-09-08',
  474.59,
  'borrador',
  'Ticket El Surtidor 126922 · 2026-09-08 · Luis F48 · cola Recibir; stock al confirmar pistola'
where not exists (
  select 1 from public.recepciones
  where folio = '126922' and coalesce(proveedor, '') ilike '%surtidor%'
);

update public.recepciones
set
  total_ticket = 474.59,
  fecha = '2026-09-08',
  proveedor = 'El Surtidor'
where folio = '126922'
  and coalesce(proveedor, '') ilike '%surtidor%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = '126922'
  and coalesce(r.proveedor, '') ilike '%surtidor%'
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
  null,
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
from _fc_sur_126922 t
join public.recepciones r
  on r.folio = '126922'
 and coalesce(r.proveedor, '') ilike '%surtidor%'
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
    where i.producto_id = p.id and i.es_principal
  ),
  'propia'
from _fc_sur_126922 t
join public.productos p on p.id = coalesce(
  public.fc_buscar_producto_escaneo(t.ean),
  public.fc_buscar_producto_escaneo(t.sku)
)
where t.imagen is not null
  and not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id and i.url = t.imagen
  );

commit;

select
  i.id,
  i.codigo_escaneado as ean,
  left(i.nombre_snapshot, 52) as nombre,
  i.cantidad,
  i.costo_estimado,
  case when i.pendiente_alta then 'ALTA NUEVA' else 'YA EXISTE' end as estado
from public.recepcion_items i
join public.recepciones r on r.id = i.recepcion_id
where r.folio = '126922' and coalesce(r.proveedor, '') ilike '%surtidor%'
order by i.id;

select
  p.sku,
  p.codigo_barras as ean,
  left(p.nombre, 52) as nombre,
  p.marca,
  p.presentacion,
  p.costo,
  p.precio,
  p.stock,
  left(coalesce(p.imagen_url, ''), 56) as foto
from public.productos p
where p.codigo_barras in (
  '7501318612655',
  '7501868901131',
  '7501868901117',
  '7501868901124',
  '7501033950100',
  '7501033950063',
  '7501033951008',
  '7501033950209',
  '7501019068713'
)
order by p.nombre;
