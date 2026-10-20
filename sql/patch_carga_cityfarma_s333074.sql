-- Cityfarma Iztapalapa · orden S333074 · 2026-10-19 17:15
-- Ticket térmico. Subtotal $2,465.99 · IVA 16% $80 · total líneas $2,545.99.
-- Nebulizador Omron EAN 073796803216 (ya en catálogo).
-- Vessel Due-F / Neuralin / Oxital-C ya. Eskapar y Zolufen alta.
-- Sin caducidad (MMAA de la caja). No inventar 0000.
-- 5 alta(s) stock 0. 4 ya estaban: solo costo / ficha vacía, no PVP.
-- Nombres de ficha, no del ticket. Fotos en public/catalogo-propia/ (tras deploy).
-- SIN bloques dollar-quote. Idempotente mientras el ticket siga en borrador.
-- Pegar TODO este archivo en Supabase → SQL Editor → Run.

begin;

create temp table _fc_cf_s333074 (
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

insert into _fc_cf_s333074 (
  linea, ean, sku, nombre, snap, qty, costo, precio, tipo, categoria,
  subcategoria, forma, marca, laboratorio, presentacion, principio_activo,
  concentracion, receta, ya, imagen, foto_file, lote
) values
  (1, '7501089809490', 'FC-89809490', 'Eskapar nifuroxazida 200 mg', 'ESKAPAR 200 MG C 16', 2, 114.61, 144, 'marca', 'Gastro', 'Antidiarreico', 'Cápsula', 'Eskapar', 'Armstrong', 'Caja con 16 cápsulas', 'Nifuroxazida', '200 mg', false, false, null, null, '25070018'),
  (2, '7501089809445', 'FC-89809445', 'Eskapar Compuesto', 'ESKAPAR COMP C 20 20', 2, 197.83, 248, 'marca', 'Gastro', 'Antidiarreico', 'Cápsula', 'Eskapar', 'Armstrong', 'Caja con 20 cápsulas', 'Nifuroxazida / atropina / homatropina', null, false, false, null, null, '26020038'),
  (3, '7502216805798', 'FC-16805798', 'Espironolactona 25 mg', 'ESPIRONOLACTONA 25 M', 1, 48.33, 78, 'generico', 'Medicamentos', null, 'Tableta', null, null, 'Caja con tabletas', 'Espironolactona', '25 mg', true, false, null, null, '6GM269A'),
  (4, '7501563381160', 'FC-63381160', 'Espironolactona 25 mg', 'ESPIRONOLACTONA 25MG', 5, 26.99, 44, 'generico', 'Medicamentos', null, 'Tableta', 'Randall', 'Randall', 'Caja con tabletas', 'Espironolactona', '25 mg', true, false, null, null, '30600'),
  (5, '073796803216', 'FC-96803216', 'Nebulizador de compresor Omron Elite NE-C803', 'NEBULIZADOR DE COMPR', 1, 580.00, 725, 'marca', 'Dispositivo médico', 'Respiratorio', 'Aparato', 'Omron', 'Omron', '1 pieza', null, null, false, true, 'https://www.farmacapital.mx/catalogo-propia/nebulizador-de-compresor-omron-elite-ne-c803-100-073796803216.jpg', 'catalogo-propia/nebulizador-de-compresor-omron-elite-ne-c803-100-073796803216.jpg', '202402LF'),
  (6, '7501088505126', 'FC-8505126', 'Neuralin solución inyectable', 'NEURALIN C 1 AMP', 3, 146.31, 183, 'marca', 'Medicamentos', null, 'Ampolleta', 'Neuralin', 'Chinoin', 'Caja con 1 ampolleta', 'Tiamina / piridoxina / cianocobalamina', '200 mg/100 mg/5 mg', true, true, null, null, 'BFF042'),
  (7, '7501258207010', 'FC-58207010', 'Oxital-C 2 g', 'OXITAL C 2G AC ASCOR', 1, 63.50, 80, 'marca', 'Medicamentos', null, 'Tableta efervescente', 'Oxital-C', 'Serral', 'Tubo con 10 tabletas', 'Ácido ascórbico', '2 g', false, true, null, null, '260548'),
  (8, '8020030091252', 'FC-30091252', 'Vessel Due-F sulodexida 250 LRU', 'VESSEL DUE F 250 CAP', 1, 576.00, 922, 'generico', 'Medicamentos', null, 'Cápsula', 'Vessel Due-F', 'AlfaSigma', 'Caja con 50 cápsulas', 'Sulodexida', '250 LRU', true, true, null, null, '31440'),
  (9, '7502223553477', 'FC-23553477', 'Zolufen fluoxetina 20 mg', 'ZOLUFEN 20MG CAP C30', 5, 15.88, 26, 'generico', 'Medicamentos', null, 'Cápsula', 'Zolufen', null, 'Caja con 30 cápsulas', 'Fluoxetina', '20 mg', true, false, null, null, 'Z26013A');

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
  'Alta Cityfarma Iztapalapa S333074 · 2026-10-19 · listo para pistola',
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
  from _fc_cf_s333074
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
  from _fc_cf_s333074
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
  from _fc_cf_s333074
  order by ean, linea
) t
where p.id = coalesce(
  public.fc_buscar_producto_escaneo(t.ean),
  public.fc_buscar_producto_escaneo(t.sku)
);

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'Cityfarma Iztapalapa',
  'S333074',
  '2026-10-19',
  2545.99,
  'borrador',
  'Ticket Cityfarma S333074 · 19-oct-2026 17:15 · foto térmica · surtido sin certificar · total líneas $2,545.99 (subtotal $2,465.99 + IVA 16% $80 del nebulizador Omron) · cola Recibir; stock al confirmar pistola + MMAA'
where not exists (
  select 1 from public.recepciones
  where folio = 'S333074'
    and coalesce(proveedor, '') ilike '%cityfarma%'
);

update public.recepciones
set
  total_ticket = 2545.99,
  fecha = '2026-10-19',
  proveedor = 'Cityfarma Iztapalapa',
  notas = 'Ticket Cityfarma S333074 · 19-oct-2026 17:15 · foto térmica · surtido sin certificar · total líneas $2,545.99 (subtotal $2,465.99 + IVA 16% $80 del nebulizador Omron) · cola Recibir; stock al confirmar pistola + MMAA',
  updated_at = now()
where folio = 'S333074'
  and coalesce(proveedor, '') ilike '%cityfarma%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = 'S333074'
  and coalesce(r.proveedor, '') ilike '%cityfarma%'
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
from _fc_cf_s333074 t
join public.recepciones r
  on r.folio = 'S333074'
 and coalesce(r.proveedor, '') ilike '%cityfarma%'
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
from _fc_cf_s333074 t
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
where r.folio = 'S333074'
  and coalesce(r.proveedor, '') ilike '%cityfarma%'
group by r.id, r.folio, r.proveedor, r.estado, r.total_ticket;

select
  t.linea,
  t.ean,
  t.nombre,
  t.qty,
  t.costo,
  case when public.fc_buscar_producto_escaneo(t.ean) is null then 'PENDIENTE_ALTA' else 'OK' end as match,
  t.ya as marcado_ya
from _fc_cf_s333074 t
order by t.linea;

commit;
