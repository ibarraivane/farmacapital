-- Equilibrio · ticket 446721 · 2026-10-02 · sucursal Iztapalapa 2
-- Pedido online. Total $970.74 · 6 renglones / 22 pzas.
-- Claves EQF → EAN Levic: MAI158→785118754242 · MAV073→7503000422498 ·
-- MAV167→7502009742392 · MAV134→7502009741487 · MAV401→7502009749421.
-- Redalip 2 lotes (260148×3 + 260149×1). Lote sí. Caducidad NO (MMAA caja).
-- 0 alta(s) stock 0. 6 ya estaban: solo costo / ficha vacía, no PVP.
-- Nombres de ficha, no del ticket. Fotos en public/catalogo-propia/ (tras deploy).
-- SIN bloques dollar-quote. Idempotente mientras el ticket siga en borrador.
-- Pegar TODO este archivo en Supabase → SQL Editor → Run.

begin;

create temp table _fc_eq_446721 (
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

insert into _fc_eq_446721 (
  linea, ean, sku, nombre, snap, qty, costo, precio, tipo, categoria,
  subcategoria, forma, marca, laboratorio, presentacion, principio_activo,
  concentracion, receta, ya, imagen, foto_file, lote
) values
  (1, '785118754242', 'FC-1FFBB505', 'Supratex DAC ambroxol/levodropropizina', 'MAI158 SUPRATEX DAC 1 SOL 300/600 MG 120 ML', 3, 42.80, 69, 'generico', 'Medicamentos', null, 'Solución', 'Supratex', 'MAVI', 'Frasco 120 mL', 'Ambroxol / levodropropizina', '300/600 mg', false, true, 'https://www.farmacapital.mx/catalogo-propia/supratex-dac-120ml-785118754242.jpg', 'catalogo-propia/supratex-dac-120ml-785118754242.jpg', '5K2102'),
  (2, '7503000422498', 'FC-6074BB64', 'Redalip bezafibrato 200 mg', 'MAV073 REDALIP 30 TAB 200 MG', 3, 25.21, 41, 'generico', 'Medicamentos', null, 'Tableta', 'Redalip', 'MAVI', 'Caja con 30 tabletas', 'Bezafibrato', '200 mg', true, true, null, null, '260148'),
  (3, '7503000422498', 'FC-6074BB64', 'Redalip bezafibrato 200 mg', 'MAV073 REDALIP 30 TAB 200 MG', 1, 25.21, 41, 'generico', 'Medicamentos', null, 'Tableta', 'Redalip', 'MAVI', 'Caja con 30 tabletas', 'Bezafibrato', '200 mg', true, true, null, null, '260149'),
  (4, '7502009742392', 'EQ-MAV167', 'Doltrix clonixinato/hioscina 125/10 mg', 'MAV167 DOLTRIX 20 TAB 125/10 MG', 5, 71.69, 115, 'generico', 'Medicamentos', null, 'Tableta', 'Doltrix', 'Maver', 'Caja con 20 tabletas', 'Clonixinato de lisina / butilhioscina', '125/10 mg', true, true, 'https://www.farmacapital.mx/catalogo-propia/doltrix-125-10-c20-7502009742392.jpg', 'catalogo-propia/doltrix-125-10-c20-7502009742392.jpg', '263123'),
  (5, '7502009741487', 'EQ-MAV134', 'Doltrix clonixinato/hioscina 250/10 mg', 'MAV134 DOLTRIX 10 TAB 250/10 MG', 5, 56.46, 91, 'generico', 'Medicamentos', null, 'Tableta', 'Doltrix', 'Maver', 'Caja con 10 tabletas', 'Clonixinato de lisina / butilhioscina', '250/10 mg', true, true, 'https://www.farmacapital.mx/catalogo-propia/doltrix-250-10-c10-7502009741487.jpg', 'catalogo-propia/doltrix-250-10-c10-7502009741487.jpg', '263116'),
  (6, '7502009749421', 'FC-09749421', 'Dexpantenol crema 5%', 'MAV401 DEXPANTENOL 1 CMA 5% 30 G', 5, 20.15, 33, 'generico', 'Dermocosmético', null, 'Crema', 'Maver', 'Maver', 'Tubo 30 g', 'Dexpantenol', '5%', false, true, 'https://www.farmacapital.mx/catalogo-propia/dexpantenol-5-30g-7502009749421.jpg', 'catalogo-propia/dexpantenol-5-30g-7502009749421.jpg', '264542');

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
  'Alta Equilibrio 446721 · 2026-10-02 · listo para pistola',
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
  from _fc_eq_446721
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
  from _fc_eq_446721
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
  from _fc_eq_446721
  order by ean, linea
) t
where p.id = coalesce(
  public.fc_buscar_producto_escaneo(t.ean),
  public.fc_buscar_producto_escaneo(t.sku)
);

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'Equilibrio',
  '446721',
  '2026-10-02',
  970.74,
  'borrador',
  'Ticket Equilibrio 446721 · Iztapalapa 2 · pedido online · cliente 307513 Palillero · 02-oct-2026 · lote de fábrica en papel · cola Recibir; stock al confirmar pistola + MMAA'
where not exists (
  select 1 from public.recepciones
  where folio = '446721'
    and coalesce(proveedor, '') ilike '%equilibrio%'
);

update public.recepciones
set
  total_ticket = 970.74,
  fecha = '2026-10-02',
  proveedor = 'Equilibrio',
  notas = 'Ticket Equilibrio 446721 · Iztapalapa 2 · pedido online · cliente 307513 Palillero · 02-oct-2026 · lote de fábrica en papel · cola Recibir; stock al confirmar pistola + MMAA',
  updated_at = now()
where folio = '446721'
  and coalesce(proveedor, '') ilike '%equilibrio%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = '446721'
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
from _fc_eq_446721 t
join public.recepciones r
  on r.folio = '446721'
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
from _fc_eq_446721 t
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
where r.folio = '446721'
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
from _fc_eq_446721 t
order by t.linea;

commit;
