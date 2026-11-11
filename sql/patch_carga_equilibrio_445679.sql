-- Equilibrio · ticket 445679 · 2026-09-24 17:28 · sucursal Iztapalapa 2
-- Pedido online. Subtotal $832.78 + IVA $42.74 = $875.52 · 10 renglones / 22 pzas.
-- Foto partida (inicio + continuación). P.U. = costo neto post-descuento.
-- Lote de fábrica sí. Caducidad NO: Recibir pide MMAA de la caja. 0000 inválido.
-- 0 alta(s) stock 0. 10 ya estaban: solo costo / ficha vacía, no PVP.
-- Nombres de ficha, no del ticket. Fotos en public/catalogo-propia/ (tras deploy).
-- SIN bloques dollar-quote. Idempotente mientras el ticket siga en borrador.
-- Pegar TODO este archivo en Supabase → SQL Editor → Run.

begin;

create temp table _fc_eq_445679 (
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

insert into _fc_eq_445679 (
  linea, ean, sku, nombre, snap, qty, costo, precio, tipo, categoria,
  subcategoria, forma, marca, laboratorio, presentacion, principio_activo,
  concentracion, receta, ya, imagen, foto_file, lote
) values
  (1, '7502214985805', 'FC-14985805', 'Prudence Chicle condones C/5', 'DKT040 PRUDENCE CHICLE 1 CAJA 5 PZAS', 2, 46.57, 59, 'marca', 'Cuidado personal', 'Higiene', 'Condón', 'Prudence', 'DKT', 'Caja con 5 piezas', null, null, false, true, null, null, 'PB563201'),
  (2, '7503004908738', 'FC-04908738', 'Lidocaína unguento 5% tubo 35 g', 'ALP0380 LIDOCAINA 1 UNG 5% 35 G', 4, 23.33, 38, 'generico', 'Medicamentos', null, 'Ungüento', 'Alpharma', 'Alpharma', 'Tubo 35 g', 'Lidocaína', '5%', false, true, null, null, '2606516'),
  (3, '7501075723137', 'FC-75723137', 'Novakosid senósidos A-B 8.6 mg C/20', 'NOV138 NOVAKOSID 20 TAB 8.6 MG', 5, 13.93, 23, 'generico', 'Medicamentos', null, 'Tableta', 'Novakosid', 'Novag', 'Caja con 20 tabletas', 'Senósidos A-B', '8.6 mg', false, true, null, null, '540286'),
  (4, '7502009748912', 'EQ-MAV380', 'Esomeprazol 40 mg C/14', 'MAV380 ESOMEPRAZOL 14 TAB 40 MG', 2, 51.65, 83, 'generico', 'Medicamentos', null, 'Tableta', 'Maver', 'Maver', 'Caja con 14 tabletas', 'Esomeprazol', '40 mg', true, true, null, null, '263687'),
  (5, '0780083144302', 'FC-83144302', 'Collifrin Adulto oximetazolina 0.05% 20 mL', 'COL145 COLLIFRIN ADULTO 1 SOL 50MG/20 ML', 3, 33.69, 54, 'generico', 'Medicamentos', null, 'Solución nasal', 'Collifrin', 'Collins', 'Frasco 20 mL', 'Oximetazolina', '0.05%', false, true, null, null, '26140881'),
  (6, '7502214982491', 'FC-49824911', 'Prudence Uva condones C/3', 'DKT009 PRUDENCE UVA 1 CJA 3 PZAS', 1, 34.48, 44, 'marca', 'Cuidado personal', 'Higiene', 'Condón', 'Prudence', 'DKT', 'Caja con 3 piezas', null, null, false, true, null, null, 'PG577501'),
  (7, '7502214980275', 'FC-4980275', 'Prudence Soda condones C/3', 'DKT063 PRUDENCE SODA 1 CJA 3 PZA', 1, 32.96, 42, 'marca', 'Cuidado personal', 'Higiene', 'Condón', 'Prudence', 'DKT', 'Caja con 3 piezas', null, null, false, true, null, null, 'BC503404'),
  (8, '7502214982514', 'FC-14982514', 'Prudence Chocolate condones C/3', 'DKT008 PRUDENCE CHOCOLATE 1 CJA 3 PZAS', 1, 34.14, 43, 'marca', 'Cuidado personal', 'Higiene', 'Condón', 'Prudence', 'DKT', 'Caja con 3 piezas', null, null, false, true, null, null, 'BCH508001'),
  (9, '7502214983207', 'FC-14983207', 'Prudence lubricante uva 75 mL', 'DKT023 LUBRICANTE UVA 1 GEL 75 ML', 1, 72.42, 91, 'marca', 'Cuidado personal', 'Higiene', 'Gel', 'Prudence', 'DKT', 'Frasco 75 mL', null, null, false, true, 'https://www.farmacapital.mx/catalogo-propia/prudence-lub-uva-75ml.jpg', 'catalogo-propia/prudence-lub-uva-75ml.jpg', '3P186057'),
  (10, '7502009749292', 'EQ-MAV415', 'Esomeprazol 40 mg C/28', 'MAV415 ESOMEPRAZOL 28 TAB 40 MG', 2, 99.15, 159, 'generico', 'Medicamentos', null, 'Tableta', 'Maver', 'Maver', 'Caja con 28 tabletas', 'Esomeprazol', '40 mg', true, true, null, null, '263551');

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
  'Alta Equilibrio 445679 · 2026-09-24 · listo para pistola',
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
  from _fc_eq_445679
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
  from _fc_eq_445679
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
  from _fc_eq_445679
  order by ean, linea
) t
where p.id = coalesce(
  public.fc_buscar_producto_escaneo(t.ean),
  public.fc_buscar_producto_escaneo(t.sku)
);

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'Equilibrio',
  '445679',
  '2026-09-24',
  875.52,
  'borrador',
  'Ticket Equilibrio 445679 · Iztapalapa 2 · 24-sep-2026 17:28 · pedido online · cliente 307513 · cola Recibir; stock al confirmar pistola'
where not exists (
  select 1 from public.recepciones
  where folio = '445679'
    and coalesce(proveedor, '') ilike '%equilibrio%'
);

update public.recepciones
set
  total_ticket = 875.52,
  fecha = '2026-09-24',
  proveedor = 'Equilibrio',
  notas = 'Ticket Equilibrio 445679 · Iztapalapa 2 · 24-sep-2026 17:28 · pedido online · cliente 307513 · cola Recibir; stock al confirmar pistola',
  updated_at = now()
where folio = '445679'
  and coalesce(proveedor, '') ilike '%equilibrio%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = '445679'
  and coalesce(r.proveedor, '') ilike '%equilibrio%'
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
from _fc_eq_445679 t
join public.recepciones r
  on r.folio = '445679'
 and coalesce(r.proveedor, '') ilike '%equilibrio%'
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
from _fc_eq_445679 t
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
where r.folio = '445679'
  and coalesce(r.proveedor, '') ilike '%equilibrio%'
group by r.id, r.folio, r.proveedor, r.estado, r.total_ticket;

select
  t.linea,
  t.ean,
  t.nombre,
  t.qty,
  t.costo,
  case when public.fc_buscar_producto_escaneo(t.ean) is null then 'PENDIENTE_ALTA' else 'OK' end as match,
  t.ya as marcado_ya
from _fc_eq_445679 t
order by t.linea;

commit;
