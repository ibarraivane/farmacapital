-- El Surtidor de su Farmacia · venta 136447 · 28-sep-2026
-- Alfredo Murillo Guzmán · Bodega F48 · Central de Abastos Iztapalapa
-- Total ticket $1,584.67 · costo = total de renglón / qty (ya con descuento).
-- 1 alta stock 0 (Thealoz Duo). 4 ya estaban: solo costo / ficha vacía, no PVP.
-- Glucerna vainilla: ticket truncó a 7501033952 → EAN pistola 7501033956126.
-- Sin lote ni caducidad (MMAA de la caja). No inventar 0000.
-- Nombres de ficha, no del ticket. Fotos en public/catalogo-propia/ (tras deploy).
-- SIN bloques dollar-quote. Idempotente mientras el ticket siga en borrador.
-- Pegar TODO este archivo en Supabase → SQL Editor → Run.

begin;

create temp table _fc_sur136447 (
  linea integer primary key,
  ean text not null,
  ean_ticket text,
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

insert into _fc_sur136447 (
  linea, ean, ean_ticket, sku, nombre, snap, qty, costo, precio, tipo, categoria,
  subcategoria, forma, marca, laboratorio, presentacion, principio_activo,
  concentracion, receta, ya, imagen, foto_file, lote
) values
  (1, '7501573900337', '7501573900337', 'FC-1DA570E3',
   'Cloxan Ambroxol 30 mg',
   'CLOXAN TAB C/20 AMBROXOL',
   2, 13.38, 17, 'marca', 'Medicamentos', 'Respiratorio', 'Comprimidos',
   'Cloxan', 'Bioresearch', '20 comprimidos',
   'Ambroxol', '30 mg', false, true,
   null, null, null),
  (2, '7501033956133', '7501033956133', 'FC-33956133',
   'Glucerna líquido chocolate',
   'GLUCERNA LIQ 237ML CHOCOLATE',
   3, 47.50, 60, 'marca', 'Suplemento', 'Nutrición diabetes', 'Líquido',
   'Glucerna', 'Abbott', 'Botella 237 ml',
   null, null, false, true,
   'https://www.farmacapital.mx/catalogo-propia/glucerna-liquido-chocolate-237ml-7501033956133.jpg',
   'catalogo-propia/glucerna-liquido-chocolate-237ml-7501033956133.jpg', null),
  (3, '7501033956126', '7501033952', 'FC-33956126',
   'Glucerna líquido vainilla',
   'GLUCERNA LIQ 237ML VAINILLA',
   4, 47.50, 60, 'marca', 'Suplemento', 'Nutrición diabetes', 'Líquido',
   'Glucerna', 'Abbott', 'Botella 237 ml',
   null, null, false, true,
   'https://www.farmacapital.mx/catalogo-propia/glucerna-liquido-vainilla-237ml-7501033956126.jpg',
   'catalogo-propia/glucerna-liquido-vainilla-237ml-7501033956126.jpg', null),
  (4, '7501033956140', '7501033956140', 'FC-33956140',
   'Glucerna líquido fresa',
   'GLUCERNA SR LIQ 237ML FRESA',
   3, 47.50, 60, 'marca', 'Suplemento', 'Nutrición diabetes', 'Líquido',
   'Glucerna', 'Abbott', 'Botella 237 ml',
   null, null, false, true,
   'https://www.farmacapital.mx/catalogo-propia/glucerna-liquido-fresa-237ml-7501033956140.jpg',
   'catalogo-propia/glucerna-liquido-fresa-237ml-7501033956140.jpg', null),
  (5, '3662042003059', '3662042003059', 'FC-42003059',
   'Thealoz Duo',
   'THEALOZ DUO GTS 10ML',
   2, 541.45, 677, 'marca', 'Oftálmico', 'Sequedad ocular', 'Gotas oftálmicas',
   'Thealoz Duo', 'Théa', 'Frasco 10 ml',
   'Trehalosa / hialuronato de sodio', '3%', false, false,
   'https://www.farmacapital.mx/catalogo-propia/thealoz-duo-gotas-10ml-3662042003059.jpg',
   'catalogo-propia/thealoz-duo-gotas-10ml-3662042003059.jpg', null);

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
  'Alta El Surtidor 136447 · 2026-09-28 · listo para pistola',
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
from _fc_sur136447 t
where public.fc_buscar_producto_escaneo(t.ean) is null
  and public.fc_buscar_producto_escaneo(t.sku) is null
  and (
    t.ean_ticket is null
    or public.fc_buscar_producto_escaneo(t.ean_ticket) is null
  );

-- Ya existían: costo. PVP solo si estaba en 0.
update public.productos p
set
  costo = t.costo,
  precio = case
    when coalesce(p.precio, 0) <= 0 then t.precio
    else p.precio
  end
from _fc_sur136447 t
where p.id = coalesce(
    public.fc_buscar_producto_escaneo(t.ean),
    public.fc_buscar_producto_escaneo(t.sku),
    public.fc_buscar_producto_escaneo(t.ean_ticket)
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
    when p.nombre ~* '^(cloxan|glucerna|thealoz)$' then t.nombre
    else p.nombre
  end,
  marca = coalesce(nullif(trim(p.marca), ''), t.marca),
  presentacion = coalesce(nullif(trim(p.presentacion), ''), t.presentacion),
  principio_activo = coalesce(nullif(trim(p.principio_activo), ''), t.principio_activo),
  concentracion = coalesce(nullif(trim(p.concentracion), ''), t.concentracion),
  laboratorio = coalesce(nullif(trim(p.laboratorio), ''), t.laboratorio),
  subcategoria = coalesce(nullif(trim(p.subcategoria), ''), t.subcategoria),
  forma_farmaceutica = coalesce(nullif(trim(p.forma_farmaceutica), ''), t.forma),
  categoria = coalesce(nullif(trim(p.categoria), ''), t.categoria),
  imagen_url = coalesce(nullif(trim(p.imagen_url), ''), t.imagen),
  imagen_mobile_url = coalesce(nullif(trim(p.imagen_mobile_url), ''), t.imagen),
  codigo_barras = case
    when coalesce(nullif(trim(p.codigo_barras), ''), '') = '' then t.ean
    when p.codigo_barras = t.ean_ticket and t.ean is distinct from t.ean_ticket then t.ean
    else p.codigo_barras
  end
from _fc_sur136447 t
where p.id = coalesce(
    public.fc_buscar_producto_escaneo(t.ean),
    public.fc_buscar_producto_escaneo(t.sku),
    public.fc_buscar_producto_escaneo(t.ean_ticket)
  );

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'El Surtidor de su Farmacia',
  '136447',
  '2026-09-28',
  1584.67,
  'borrador',
  'Ticket El Surtidor venta 136447 · Bodega F48 · Luis · 28-sep-2026 · $1,584.67 · Glucerna vainilla ticket 7501033952→7501033956126 · cola Recibir; stock al confirmar pistola + MMAA'
where not exists (
  select 1 from public.recepciones
  where folio = '136447'
    and coalesce(proveedor, '') ilike '%surtidor%'
);

update public.recepciones
set
  total_ticket = 1584.67,
  fecha = '2026-09-28',
  proveedor = 'El Surtidor de su Farmacia',
  notas = 'Ticket El Surtidor venta 136447 · Bodega F48 · Luis · 28-sep-2026 · $1,584.67 · Glucerna vainilla ticket 7501033952→7501033956126 · cola Recibir; stock al confirmar pistola + MMAA',
  updated_at = now()
where folio = '136447'
  and coalesce(proveedor, '') ilike '%surtidor%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = '136447'
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
from _fc_sur136447 t
join public.recepciones r
  on r.folio = '136447'
 and coalesce(r.proveedor, '') ilike '%surtidor%'
 and r.estado = 'borrador'
left join lateral (
  select coalesce(
    public.fc_buscar_producto_escaneo(t.ean),
    public.fc_buscar_producto_escaneo(t.sku),
    public.fc_buscar_producto_escaneo(t.ean_ticket)
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
from _fc_sur136447 t
join public.productos p on p.id = coalesce(
  public.fc_buscar_producto_escaneo(t.ean),
  public.fc_buscar_producto_escaneo(t.sku),
  public.fc_buscar_producto_escaneo(t.ean_ticket)
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
where r.folio = '136447'
  and coalesce(r.proveedor, '') ilike '%surtidor%'
group by r.id, r.folio, r.proveedor, r.estado, r.total_ticket;

select
  t.linea,
  t.ean,
  t.ean_ticket,
  left(t.nombre, 40) as nombre,
  t.qty,
  t.costo,
  case
    when public.fc_buscar_producto_escaneo(t.ean) is not null then 'OK'
    when public.fc_buscar_producto_escaneo(t.sku) is not null then 'OK_SKU'
    when public.fc_buscar_producto_escaneo(t.ean_ticket) is not null then 'OK_TICKET'
    else 'PENDIENTE_ALTA'
  end as match,
  t.ya as marcado_ya
from _fc_sur136447 t
order by t.linea;

commit;
