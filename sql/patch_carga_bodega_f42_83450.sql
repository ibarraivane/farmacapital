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
