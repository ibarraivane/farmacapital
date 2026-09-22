-- Cityfarma Iztapalapa · orden S324509 · 2026-09-21 16:52
-- Ticket térmico. Subtotal $2,663.37 + IVA 16% $191.74 = $2,855.11.
-- Erbitrax C/28 EAN 7502211783787 · Vessel Due-F 8020030091252 alta.
-- Sin lote ni caducidad (MMAA de la caja). No inventar 0000.
-- 3 alta(s) stock 0. 5 ya estaban: solo costo / ficha vacía, no PVP.
-- Nombres de ficha, no del ticket. Fotos en public/catalogo-propia/ (tras deploy).
-- SIN bloques dollar-quote. Idempotente mientras el ticket siga en borrador.
-- Pegar TODO este archivo en Supabase → SQL Editor → Run.

begin;

create temp table _fc_cf_s324509 (
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

insert into _fc_cf_s324509 (
  linea, ean, sku, nombre, snap, qty, costo, precio, tipo, categoria,
  subcategoria, forma, marca, laboratorio, presentacion, principio_activo,
  concentracion, receta, ya, imagen, foto_file, lote
) values
  (1, '4015630082988', 'FC-30082988', 'Accu-Chek Active glucómetro', 'ACCU CHEK EQ ACTIVE', 1, 499.99, 625, 'marca', 'Dispositivo médico', 'Diagnóstico', 'Aparato', 'Accu-Chek', 'Roche', '1 pieza', null, null, false, true, 'https://www.farmacapital.mx/catalogo-propia/medidor-accu-chek-active-4015630082988.jpg', 'medidor-accu-chek-active-4015630082988.jpg', null),
  (2, '4015630018277', 'FC-30018277', 'Accu-Chek Softclix lancetas C/25', 'ACCU CHEK SOFTCLIX C', 2, 72.42, 91, 'marca', 'Dispositivo médico', 'Lancetas', 'Lancetas', 'Accu-Chek', 'Roche', 'Caja con 25 lancetas', null, null, false, true, 'https://www.farmacapital.mx/catalogo-propia/lanceta-accu-chek-softclix-25pzas-4015630018277.jpg', 'lanceta-accu-chek-softclix-25pzas-4015630018277.jpg', null),
  (3, '799192067426', 'FC-92067426', 'Accu-Chek Instant kit 50 tiras + 25 lancetas', 'ACCU-CHEK EQ INSTANT', 1, 681.33, 852, 'marca', 'Dispositivo médico', 'Diagnóstico', 'Kit', 'Accu-Chek', 'Roche', 'Kit glucómetro', null, null, false, true, 'https://www.farmacapital.mx/catalogo-propia/glucometro-accu-check-instant-kit-con-50-tiras-y-799192067426.jpg', 'glucometro-accu-check-instant-kit-con-50-tiras-y-799192067426.jpg', null),
  (4, '7502211783787', 'FC-11783787', 'Erbitrax-T terbinafina 250 mg C/28', 'ERBITRAX T 250MG C28', 2, 112.50, 180, 'generico', 'Medicamentos', null, 'Tableta', 'Erbitrax-T', 'Loeffler', 'Caja con 28 tabletas', 'Terbinafina', '250 mg', true, false, null, null, null),
  (5, '7501165009486', 'FC-65009486', 'Lactacyd Pro-Bio shampoo íntimo 200 mL', 'LACTACYD PRO BIO SH', 1, 63.95, 80, 'marca', 'Cuidado personal', 'Higiene íntima', 'Shampoo', 'Lactacyd', 'Sanofi', 'Frasco 200 mL', null, null, false, false, null, null, null),
  (6, '7501065008459', 'FL-5008459', 'Theraflu TD rojo resfriado severo C/10', 'THERAFLU TD ROJO C10', 2, 170.23, 213, 'marca', 'Medicamentos', 'Resfriado', 'Sobres', 'Theraflu', 'Haleon', 'Caja con 10 sobres', null, null, false, true, null, null, null),
  (7, '7501065008473', 'FC-5008473', 'Theraflu TD limón resfriado severo C/10', 'THERAFLU VERDE C10 S', 2, 161.77, 203, 'marca', 'Medicamentos', 'Resfriado', 'Sobres', 'Theraflu', 'Haleon', 'Caja con 10 sobres', null, null, false, true, null, null, null),
  (8, '8020030091252', 'FC-30091252', 'Vessel Due-F sulodexida 250 LRU C/50', 'VESSEL DUE F 250 CAP', 1, 576.00, 922, 'generico', 'Medicamentos', null, 'Cápsula', 'Vessel Due-F', 'AlfaSigma', 'Caja con 50 cápsulas', 'Sulodexida', '250 LRU', true, false, null, null, null);

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
  'Alta Cityfarma Iztapalapa S324509 · 2026-09-21 · listo para pistola',
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
  from _fc_cf_s324509
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
  from _fc_cf_s324509
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
  from _fc_cf_s324509
  order by ean, linea
) t
where p.id = coalesce(
  public.fc_buscar_producto_escaneo(t.ean),
  public.fc_buscar_producto_escaneo(t.sku)
);

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'Cityfarma Iztapalapa',
  'S324509',
  '2026-09-21',
  2855.11,
  'borrador',
  'Ticket Cityfarma S324509 · 21-sep-2026 · foto térmica · Pendiente de pago $2,855.11 · cola Recibir; stock al confirmar pistola'
where not exists (
  select 1 from public.recepciones
  where folio = 'S324509'
    and coalesce(proveedor, '') ilike '%cityfarma%'
);

update public.recepciones
set
  total_ticket = 2855.11,
  fecha = '2026-09-21',
  proveedor = 'Cityfarma Iztapalapa',
  notas = 'Ticket Cityfarma S324509 · 21-sep-2026 · foto térmica · Pendiente de pago $2,855.11 · cola Recibir; stock al confirmar pistola',
  updated_at = now()
where folio = 'S324509'
  and coalesce(proveedor, '') ilike '%cityfarma%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = 'S324509'
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
from _fc_cf_s324509 t
join public.recepciones r
  on r.folio = 'S324509'
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
from _fc_cf_s324509 t
join public.productos p on p.id = public.fc_buscar_producto_escaneo(t.ean)
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
where r.folio = 'S324509'
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
from _fc_cf_s324509 t
order by t.linea;

commit;
