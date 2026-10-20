-- ═══════════════════════════════════════════════════════════════
-- TICKETS 19-OCT-2026 · PEGAR EN SUPABASE (uno por uno o todo)
-- Ver LEERME_tickets_20261019.md
-- ═══════════════════════════════════════════════════════════════


-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- INICIO: patch_carga_cityfarma_s333074.sql
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
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


-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- INICIO: patch_carga_sahuayo_428641.sql
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Sahuayo · ticket 428641 · 2026-10-19 04:35 · Central de Abastos Iztapalapa
-- 2 pzas · total $43.30 (IVA incluido).
-- PZA NUVEL D.A AC.IDEAL 50M → roll-on Aclarado Ideal 50 mL EAN 7501082730258.
-- Sin lote ni caducidad. No inventar 0000.
-- 1 alta(s) stock 0. 0 ya estaban: solo costo / ficha vacía, no PVP.
-- Nombres de ficha, no del ticket. Fotos en public/catalogo-propia/ (tras deploy).
-- SIN bloques dollar-quote. Idempotente mientras el ticket siga en borrador.
-- Pegar TODO este archivo en Supabase → SQL Editor → Run.

begin;

create temp table _fc_sh_428641 (
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

insert into _fc_sh_428641 (
  linea, ean, sku, nombre, snap, qty, costo, precio, tipo, categoria,
  subcategoria, forma, marca, laboratorio, presentacion, principio_activo,
  concentracion, receta, ya, imagen, foto_file, lote
) values
  (1, '7501082730258', 'FC-82730258', 'Nuvel Aclarado Ideal roll-on', 'PZA NUVEL D.A AC.IDEAL 50M 1/50', 2, 21.65, 28, 'marca', 'Cuidado personal', 'Desodorante', 'Roll-on', 'Nuvel', 'Nuvel', 'Frasco 50 mL', null, null, false, false, null, null, null);

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
  'Alta Sahuayo 428641 · 2026-10-19 · listo para pistola',
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
  from _fc_sh_428641
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
  from _fc_sh_428641
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
  from _fc_sh_428641
  order by ean, linea
) t
where p.id = coalesce(
  public.fc_buscar_producto_escaneo(t.ean),
  public.fc_buscar_producto_escaneo(t.sku)
);

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'Sahuayo',
  '428641',
  '2026-10-19',
  43.30,
  'borrador',
  'Ticket Sahuayo 428641 · Central de Abastos · 19-oct-2026 04:35 · Nuvel Aclarado Ideal roll-on 50 mL ×2 · cola Recibir; stock al confirmar pistola'
where not exists (
  select 1 from public.recepciones
  where folio = '428641'
    and coalesce(proveedor, '') ilike '%sahuayo%'
);

update public.recepciones
set
  total_ticket = 43.30,
  fecha = '2026-10-19',
  proveedor = 'Sahuayo',
  notas = 'Ticket Sahuayo 428641 · Central de Abastos · 19-oct-2026 04:35 · Nuvel Aclarado Ideal roll-on 50 mL ×2 · cola Recibir; stock al confirmar pistola',
  updated_at = now()
where folio = '428641'
  and coalesce(proveedor, '') ilike '%sahuayo%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = '428641'
  and coalesce(r.proveedor, '') ilike '%sahuayo%'
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
from _fc_sh_428641 t
join public.recepciones r
  on r.folio = '428641'
 and coalesce(r.proveedor, '') ilike '%sahuayo%'
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
from _fc_sh_428641 t
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
where r.folio = '428641'
  and coalesce(r.proveedor, '') ilike '%sahuayo%'
group by r.id, r.folio, r.proveedor, r.estado, r.total_ticket;

select
  t.linea,
  t.ean,
  t.nombre,
  t.qty,
  t.costo,
  case when public.fc_buscar_producto_escaneo(t.ean) is null then 'PENDIENTE_ALTA' else 'OK' end as match,
  t.ya as marcado_ya
from _fc_sh_428641 t
order by t.linea;

commit;


-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- INICIO: patch_carga_equilibrio_448644.sql
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Equilibrio · ticket 448644 · 2026-10-19 · sucursal Iztapalapa 2
-- Pedido online. Total $1,059.65 · 8 renglones / 29 pzas.
-- Claves EQF → EAN ficha/Levic. Lote de fábrica sí.
-- Caducidad NO: MMAA de la caja. 0000 inválido.
-- Renglón ácido ascórbico: nombre cortado en foto (Kaomycin/Eye-Mo); asignado AMSA 6 amp 1 g/10 mL EAN 7501349022119 · lote U0227. Confirmar en caja.
-- AMS365 Zolmitriptano → EAN Ultra/AMSA 7502216805446 (2 tab 2.5 mg).
-- 2 alta(s) stock 0. 6 ya estaban: solo costo / ficha vacía, no PVP.
-- Nombres de ficha, no del ticket. Fotos en public/catalogo-propia/ (tras deploy).
-- SIN bloques dollar-quote. Idempotente mientras el ticket siga en borrador.
-- Pegar TODO este archivo en Supabase → SQL Editor → Run.

begin;

create temp table _fc_eq_448644 (
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

insert into _fc_eq_448644 (
  linea, ean, sku, nombre, snap, qty, costo, precio, tipo, categoria,
  subcategoria, forma, marca, laboratorio, presentacion, principio_activo,
  concentracion, receta, ya, imagen, foto_file, lote
) values
  (1, '7502211780359', 'FC-11780359', 'Aflusil ibuprofeno suspensión', 'LOE001 AFLUSIL 1 SUSP 2G/120ML', 3, 19.20, 31, 'generico', 'Medicamentos', null, 'Suspensión', 'Aflusil', 'Loeffler', 'Frasco 120 mL', 'Ibuprofeno', '2 g/120 mL', false, true, null, null, 'R2602932'),
  (2, '0780083141929', 'FC-83141929', 'Dolprin ibuprofeno suspensión', 'COL039 DOLPRIN 1 SUSP 100MG/5/120 ML', 3, 27.33, 44, 'generico', 'Medicamentos', null, 'Suspensión', 'Dolprin', 'Collins', 'Frasco 120 mL', 'Ibuprofeno', '100 mg/5 mL', false, true, null, null, '26141339'),
  (3, '7502009740206', 'FC-6519183A', 'Clamoxin amoxicilina/clavulanato suspensión', 'MAV011 CLAMOXIN 1 SUSP 125/31.25MG/5/60 ML', 3, 27.82, 45, 'generico', 'Medicamentos', null, 'Suspensión', 'Clamoxin', 'Maver', 'Frasco 60 mL', 'Amoxicilina / ácido clavulánico', '125/31.25 mg/5 mL', true, true, null, null, '262274'),
  (4, '7501258207010', 'FC-58207010', 'Oxital-C 2 g', 'SER141 OXITAL C 10 COMP 2G', 5, 61.20, 77, 'marca', 'Medicamentos', null, 'Tableta efervescente', 'Oxital-C', 'Serral', 'Tubo con 10 tabletas', 'Ácido ascórbico', '2 g', false, true, null, null, '260140'),
  (5, '7501349025844', 'EQ-AMS237', 'Telmisartán 40 mg', 'AMS237 TELMISARTAN 28 TAB 40 MG', 3, 34.06, 55, 'generico', 'Medicamentos', null, 'Tableta', 'AMSA', 'AMSA', 'Caja con 28 tabletas', 'Telmisartán', '40 mg', true, true, null, null, 'U26A262'),
  (6, '7501258206723', 'EQ-SER093', 'Oxital-C 1 g', 'SER093 OXITAL C 10 COMP 1G', 5, 45.11, 73, 'generico', 'Medicamentos', null, 'Tableta efervescente', 'Oxital-C', 'Serral', 'Tubo con 10 tabletas', 'Ácido ascórbico', '1 g', false, true, null, null, '260400'),
  (7, '7501349022119', 'FC-49022119', 'Ácido ascórbico 1 g/10 mL', 'ACIDO ASCORBICO 6 AMP 1G/10 ML', 5, 28.39, 46, 'generico', 'Medicamentos', null, 'Solución inyectable', 'AMSA', 'AMSA', 'Caja con 6 ampolletas', 'Ácido ascórbico', '1 g/10 mL', false, false, null, null, 'U0227'),
  (8, '7502216805446', 'EQ-AMS365', 'Zolmitriptano 2.5 mg', 'AMS365 ZOLMITRIPTANO 2 TAB 2.5 MG', 2, 30.46, 49, 'generico', 'Medicamentos', null, 'Tableta dispersable', 'AMSA', 'Ultra / AMSA', 'Caja con 2 tabletas', 'Zolmitriptano', '2.5 mg', true, false, null, null, 'U26A344');

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
  'Alta Equilibrio 448644 · 2026-10-19 · listo para pistola',
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
  from _fc_eq_448644
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
  from _fc_eq_448644
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
  from _fc_eq_448644
  order by ean, linea
) t
where p.id = coalesce(
  public.fc_buscar_producto_escaneo(t.ean),
  public.fc_buscar_producto_escaneo(t.sku)
);

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'Equilibrio',
  '448644',
  '2026-10-19',
  1059.65,
  'borrador',
  'Ticket Equilibrio 448644 · pedido online Iztapalapa 2 · 19-oct-2026 · 29 pzas · $1,059.65 · cola Recibir; stock al confirmar pistola + MMAA'
where not exists (
  select 1 from public.recepciones
  where folio = '448644'
    and coalesce(proveedor, '') ilike '%equilibrio%'
);

update public.recepciones
set
  total_ticket = 1059.65,
  fecha = '2026-10-19',
  proveedor = 'Equilibrio',
  notas = 'Ticket Equilibrio 448644 · pedido online Iztapalapa 2 · 19-oct-2026 · 29 pzas · $1,059.65 · cola Recibir; stock al confirmar pistola + MMAA',
  updated_at = now()
where folio = '448644'
  and coalesce(proveedor, '') ilike '%equilibrio%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = '448644'
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
from _fc_eq_448644 t
join public.recepciones r
  on r.folio = '448644'
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
from _fc_eq_448644 t
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
where r.folio = '448644'
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
from _fc_eq_448644 t
order by t.linea;

commit;


-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- INICIO: patch_carga_farmalive_14814.sql
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Farmalive · ticket 14814 · 2026-10-19 17:05 · Club Iztapalapa 1
-- 18 renglones / 42 unidades. Papel: subtotal $1,725.63 − desc. $60.64 = $1,664.99.
-- Costo = P.U. neto del renglón a 2 decimales → suma SQL $1,664.96.
-- Tukol-D / Prudence con renglón promo $0.01 (regalo). Genomma EAN como en ticket.
-- Alli-Triple ticket 12 dígitos 650240053610 (canónico catálogo).
-- 11 alta(s) stock 0. 7 ya estaban: solo costo / ficha vacía, no PVP.
-- Nombres de ficha, no del ticket. Fotos en public/catalogo-propia/ (tras deploy).
-- SIN bloques dollar-quote. Idempotente mientras el ticket siga en borrador.
-- Pegar TODO este archivo en Supabase → SQL Editor → Run.

begin;

create temp table _fc_fl_14814 (
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

insert into _fc_fl_14814 (
  linea, ean, sku, nombre, snap, qty, costo, precio, tipo, categoria,
  subcategoria, forma, marca, laboratorio, presentacion, principio_activo,
  concentracion, receta, ya, imagen, foto_file, lote
) values
  (1, '7506306234062', 'FC-06234062', 'Sedal Anti Nudos crema para peinar', 'CRE PEINAR SEDAL ANTI NUDOS 300 ML | UNILEVER', 3, 37.53, 47, 'marca', 'Cuidado personal', 'Cabello', 'Crema', 'Sedal', 'Unilever', 'Frasco 300 mL', null, null, false, true, null, null, null),
  (2, '7501008491003', 'FC-08491003', 'Desenfriol D tabletas 2-pack', 'DESENFRIOL D TAB C/30 2PACK | BAYER OTC', 1, 103.68, 130, 'marca', 'Respiratorio', null, 'Tableta', 'Desenfriol', 'Bayer', '2 cajas con 30 tabletas', 'Clorfenamina / fenilefrina / paracetamol', null, false, false, null, null, null),
  (3, '7501001168889', 'FC-01168889', 'Vick Pyrena sobres 8+2', 'VICK PYRENA SOB 8+2 | PG OTC', 1, 162.68, 204, 'marca', 'Respiratorio', null, 'Sobre', 'Vick Pyrena', 'P&G', 'Caja con 8+2 sobres', 'Paracetamol / fenilefrina', null, false, false, null, null, null),
  (4, '7501022105207', 'FC-22105207', 'Jabón Grisi Neutro', 'JABON GRISI NEUTRO 150 GR | GRISI HNOS', 3, 19.21, 25, 'marca', 'Higiene', null, 'Jabón', 'Grisi', 'Grisi', 'Barra 150 g', null, null, false, true, null, null, null),
  (5, '650240053610', 'FC-053610', 'Alli-Triple', 'ALLI-TRIPLE TAB C/10 | GENOMMA LAB', 3, 58.80, 74, 'marca', 'Medicamentos', null, 'Tableta', 'Alli-Triple', 'Genomma Lab', 'Caja con 10 tabletas', 'Naproxeno sódico', null, false, true, null, null, null),
  (6, '7506339394719', 'FC-39394719', 'Naturella Nocturno con alas', 'TOA SANIT NATURELLA NOCTURNO C/A C/8 | PG PERF', 2, 21.43, 27, 'marca', 'Cuidado personal', 'Higiene femenina', 'Toalla', 'Naturella', 'P&G', 'Paquete con 8 toallas', null, null, false, false, null, null, null),
  (7, '7590002046234', 'FC-02046234', 'Naturella pantiprotectores manzanilla', 'PANTIPROTECTORES NATURELLA MANZ C/40 | PG PERF', 1, 38.54, 49, 'marca', 'Cuidado personal', 'Higiene femenina', 'Pantiprotector', 'Naturella', 'P&G', 'Paquete con 40', null, null, false, false, null, null, null),
  (8, '7506309895208', 'FC-09895208', 'Naturella manzanilla regular con alas', 'TOA SANIT NATURELLA MANZ REG C/ALAS C/8 | PG PERF', 1, 9.78, 13, 'marca', 'Cuidado personal', 'Higiene femenina', 'Toalla', 'Naturella', 'P&G', 'Paquete con 8 toallas', null, null, false, false, null, null, null),
  (9, '7506552900322', 'FC-29003221', 'Vaso recolector Quirmex', 'VASO RECOLECTOR QUIRMEX | QUIRMEX', 8, 3.53, 5, 'marca', 'Botiquín', 'Material de curación', 'Vaso', 'Quirmex', 'Quirmex', '1 pieza 120 mL', null, null, false, true, null, null, null),
  (10, '7501008499795', 'FC-08499795', 'Afrin No Drip Niños', 'AFRIN NO DRIP INF SPRAY 15 ML | BAYER OTC', 3, 103.20, 129, 'marca', 'Respiratorio', null, 'Spray nasal', 'Afrin', 'Bayer', 'Frasco 15 mL', 'Oximetazolina', null, false, true, null, null, null),
  (11, '650240080159', 'FC-40080159', 'Suerox Mineral mora azul', 'SUEROX MINERAL MORA AZUL 355 ML | GENOMMA LAB', 2, 14.73, 19, 'marca', 'Bebidas', 'Electrolitos', 'Bebida', 'Suerox', 'Genomma Lab', 'Botella 355 mL', null, null, false, false, null, null, null),
  (12, '7503003406754', 'FC-03406754', 'Venda Quirmex 15 cm', 'VENDA QUIRMEX 15 CM | QUIRMEX', 2, 10.97, 14, 'marca', 'Botiquín', 'Material de curación', 'Venda', 'Quirmex', 'Quirmex', 'Rollo 15 cm', null, null, false, false, null, null, null),
  (13, '7501868902404', 'FC-68902404', 'Venda Dibar 20 cm', 'VENDA DIBAR 20 CM | DIBAR', 2, 22.44, 29, 'marca', 'Botiquín', 'Material de curación', 'Venda', 'Dibar', 'Dibar', 'Rollo 20 cm', null, null, false, false, null, null, null),
  (14, '7501019032424', 'FC-19032424', 'Tampones Saba Super', 'TAMPONES SABA SUPER C/10 | ESSITY', 1, 47.43, 60, 'marca', 'Cuidado personal', 'Higiene femenina', 'Tampón', 'Saba', 'Essity', 'Caja con 10', null, null, false, true, null, null, null),
  (15, '7502214982811', 'FC-14982811', 'Condones Prudence surtido', 'COND PRUDENCE SURTIDO C/5 | DKT MEXICO', 4, 44.10, 56, 'marca', 'Cuidado personal', 'Salud sexual', 'Condón', 'Prudence', 'DKT México', 'Caja con 5', null, null, false, false, null, null, null),
  (16, '7502214982811', 'FC-14982811', 'Condones Prudence surtido', 'COND PRUDENCE SURTIDO C/5 | DKT MEXICO', 1, 0.01, 1, 'marca', 'Cuidado personal', 'Salud sexual', 'Condón', 'Prudence', 'DKT México', 'Caja con 5', null, null, false, false, null, null, null),
  (17, '6502400315191', 'FC-00315191', 'Tukol-D 0% azúcar jarabe adulto', 'TUKOL-D 0% AZUCAR JBE ADTO 120 ML | GENOMMA LAB', 2, 151.41, 190, 'marca', 'Respiratorio', null, 'Jarabe', 'Tukol-D', 'Genomma Lab', 'Frasco 120 mL', 'Guaifenesina / dextrometorfano', null, false, false, null, null, null),
  (18, '6502400107128', 'FC-40010712', 'Tukol-D jarabe adulto', 'TUKOL-D JBE ADTO 125 ML | GENOMMA LAB', 2, 0.01, 1, 'marca', 'Respiratorio', null, 'Jarabe', 'Tukol-D', 'Genomma Lab', 'Frasco 125 mL', 'Guaifenesina / dextrometorfano', null, false, true, null, null, null);

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
  'Alta Farmalive 14814 · 2026-10-19 · listo para pistola',
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
  from _fc_fl_14814
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
  from _fc_fl_14814
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
  from _fc_fl_14814
  order by ean, linea
) t
where p.id = coalesce(
  public.fc_buscar_producto_escaneo(t.ean),
  public.fc_buscar_producto_escaneo(t.sku)
);

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'Farmalive',
  '14814',
  '2026-10-19',
  1664.96,
  'borrador',
  'Ticket Farmalive 14814 · Club Iztapalapa 1 · 19-oct-2026 17:05 · cliente FARMACAPITAL · descuentos por renglón · papel TOTAL $1,664.99 / suma P.U. neto $1,664.96 · cola Recibir; stock al confirmar pistola + MMAA'
where not exists (
  select 1 from public.recepciones
  where folio = '14814'
    and coalesce(proveedor, '') ilike '%farmalive%'
);

update public.recepciones
set
  total_ticket = 1664.96,
  fecha = '2026-10-19',
  proveedor = 'Farmalive',
  notas = 'Ticket Farmalive 14814 · Club Iztapalapa 1 · 19-oct-2026 17:05 · cliente FARMACAPITAL · descuentos por renglón · papel TOTAL $1,664.99 / suma P.U. neto $1,664.96 · cola Recibir; stock al confirmar pistola + MMAA',
  updated_at = now()
where folio = '14814'
  and coalesce(proveedor, '') ilike '%farmalive%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = '14814'
  and coalesce(r.proveedor, '') ilike '%farmalive%'
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
from _fc_fl_14814 t
join public.recepciones r
  on r.folio = '14814'
 and coalesce(r.proveedor, '') ilike '%farmalive%'
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
from _fc_fl_14814 t
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
where r.folio = '14814'
  and coalesce(r.proveedor, '') ilike '%farmalive%'
group by r.id, r.folio, r.proveedor, r.estado, r.total_ticket;

select
  t.linea,
  t.ean,
  t.nombre,
  t.qty,
  t.costo,
  case when public.fc_buscar_producto_escaneo(t.ean) is null then 'PENDIENTE_ALTA' else 'OK' end as match,
  t.ya as marcado_ya
from _fc_fl_14814 t
order by t.linea;

commit;


-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- INICIO: patch_carga_nadro_6091278111.sql
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Nadro · folio 6091278111 · 2026-10-18 · NADRO MÉXICO SUR
-- Entrega FARMACAPITAL. 13 pzas · total conceptos $1,008.73 (IVA 0%).
-- DEXAL = ceftibuteno (Maver), no ceftriaxona. Timolol Exakta EAN corto 75049612.
-- Fosfomicina susp EAN 7506513601039 (PVO 7506513601053).
-- Sin caducidad en cola (MMAA de la caja). No inventar 0000.
-- 9 alta(s) stock 0. 0 ya estaban: solo costo / ficha vacía, no PVP.
-- Nombres de ficha, no del ticket. Fotos en public/catalogo-propia/ (tras deploy).
-- SIN bloques dollar-quote. Idempotente mientras el ticket siga en borrador.
-- Pegar TODO este archivo en Supabase → SQL Editor → Run.

begin;

create temp table _fc_nd_6091278111 (
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

insert into _fc_nd_6091278111 (
  linea, ean, sku, nombre, snap, qty, costo, precio, tipo, categoria,
  subcategoria, forma, marca, laboratorio, presentacion, principio_activo,
  concentracion, receta, ya, imagen, foto_file, lote
) values
  (1, '7502009745352', 'FC-09745352', 'Dexal ceftibuteno 400 mg', 'DEXAL 400 MG 5 CAPS LGEN', 1, 210.45, 337, 'generico', 'Medicamentos', null, 'Cápsula', 'Dexal', 'Maver', 'Caja con 5 cápsulas', 'Ceftibuteno', '400 mg', true, false, null, null, null),
  (2, '7503049078291', 'FC-49078291', 'Dexlansoprazol 60 mg', 'DEXLANSOPRAZOL 60 MG 7 CAPS LGEN', 1, 94.12, 151, 'generico', 'Medicamentos', null, 'Cápsula', null, 'Avivia', 'Caja con 7 cápsulas', 'Dexlansoprazol', '60 mg', true, false, null, null, null),
  (3, '7502231321709', 'FC-31321709', 'Dorzolamida 20 mg/mL solución oftálmica', 'DORZOLAMIDA 20MG/ML SOL OFT LGEN', 1, 66.08, 106, 'generico', 'Medicamentos', null, 'Solución oftálmica', null, 'Microgrp', 'Frasco gotero', 'Dorzolamida', '20 mg/mL', true, false, null, null, null),
  (4, '7506513601053', 'FC-13601053', 'Fosfomicina polvo para solución 3 g', 'FOSFOMICINA PVO P/SOL 3 G LGEN', 1, 158.93, 255, 'generico', 'Medicamentos', null, 'Polvo', null, 'Avivia', 'Sobre 3 g', 'Fosfomicina trometamol', '3 g', true, false, null, null, null),
  (5, '7506513601039', 'FC-13601039', 'Fosfomicina suspensión 120 mL', 'FOSFOMICINA SUSP FCO 120 ML LGEN', 1, 174.24, 279, 'generico', 'Medicamentos', null, 'Suspensión', null, 'Avivia', 'Frasco 120 mL', 'Fosfomicina', null, true, false, null, null, null),
  (6, '7501349025387', 'FC-49025387', 'Gentamicina 80 mg/2 mL', 'GENTAMICINA 80MG 5 INY 2ML LGEN', 3, 8.47, 14, 'generico', 'Medicamentos', null, 'Solución inyectable', 'AMSA', 'AMSA', 'Caja con 5 ampolletas', 'Gentamicina', '80 mg/2 mL', true, false, null, null, null),
  (7, '7506449300372', 'FC-49300372', 'Guaifenesina/oxeladina jarabe', 'GUAIFE/OXOLA 2/1G JBE 140ML LGEN', 1, 31.76, 51, 'generico', 'Medicamentos', null, 'Jarabe', null, 'ADN Pharma', 'Frasco 140 mL', 'Guaifenesina / oxeladina', '2 g/1 g', false, false, null, null, null),
  (8, '7501075727159', 'FC-75727159', 'Moxifloxacino 400 mg', 'MOXIFLOXACINO 400 MG 7 TAB LGEN', 2, 92.65, 149, 'generico', 'Medicamentos', null, 'Tableta', null, 'Novag', 'Caja con 7 tabletas', 'Moxifloxacino', '400 mg', true, false, null, null, null),
  (9, '75049612', 'FC-75049612', 'Timolol 0.50% solución oftálmica', 'TIMOL 0.50% FCO GOT 5ML SOL LGEN', 2, 31.22, 50, 'generico', 'Medicamentos', null, 'Solución oftálmica', 'Exakta', 'Exakta', 'Frasco gotero 5 mL', 'Timolol', '0.50%', true, false, null, null, null);

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
  'Alta Nadro 6091278111 · 2026-10-18 · listo para pistola',
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
  from _fc_nd_6091278111
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
  from _fc_nd_6091278111
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
  from _fc_nd_6091278111
  order by ean, linea
) t
where p.id = coalesce(
  public.fc_buscar_producto_escaneo(t.ean),
  public.fc_buscar_producto_escaneo(t.sku)
);

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'Nadro',
  '6091278111',
  '2026-10-18',
  1008.73,
  'borrador',
  'Factura Nadro 6091278111 · 18-oct-2026 · entrega FarmaCapital · 9 renglones LGEN · $1,008.73 · cola Recibir; stock al confirmar pistola + MMAA'
where not exists (
  select 1 from public.recepciones
  where folio = '6091278111'
    and coalesce(proveedor, '') ilike '%nadro%'
);

update public.recepciones
set
  total_ticket = 1008.73,
  fecha = '2026-10-18',
  proveedor = 'Nadro',
  notas = 'Factura Nadro 6091278111 · 18-oct-2026 · entrega FarmaCapital · 9 renglones LGEN · $1,008.73 · cola Recibir; stock al confirmar pistola + MMAA',
  updated_at = now()
where folio = '6091278111'
  and coalesce(proveedor, '') ilike '%nadro%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = '6091278111'
  and coalesce(r.proveedor, '') ilike '%nadro%'
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
from _fc_nd_6091278111 t
join public.recepciones r
  on r.folio = '6091278111'
 and coalesce(r.proveedor, '') ilike '%nadro%'
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
from _fc_nd_6091278111 t
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
where r.folio = '6091278111'
  and coalesce(r.proveedor, '') ilike '%nadro%'
group by r.id, r.folio, r.proveedor, r.estado, r.total_ticket;

select
  t.linea,
  t.ean,
  t.nombre,
  t.qty,
  t.costo,
  case when public.fc_buscar_producto_escaneo(t.ean) is null then 'PENDIENTE_ALTA' else 'OK' end as match,
  t.ya as marcado_ya
from _fc_nd_6091278111 t
order by t.linea;

commit;


-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- INICIO: patch_carga_nadro_6091329944.sql
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Nadro · folio 6091329944 · 2026-10-19 · NADRO MÉXICO SUR
-- Entrega FARMACAPITAL (LA CAPI). 13 pzas · total $1,615.56 (subtotal $1,562.94 + IVA 16% $52.62).
-- Tena Pants / Predoblado: costo = total concepto c/IVA ($117.47 y $88.01) para cuadrar factura.
-- LGEN Lacosamida 100 mg 28 tab. Sin caducidad en cola (MMAA caja).
-- 4 alta(s) stock 0. 2 ya estaban: solo costo / ficha vacía, no PVP.
-- Nombres de ficha, no del ticket. Fotos en public/catalogo-propia/ (tras deploy).
-- SIN bloques dollar-quote. Idempotente mientras el ticket siga en borrador.
-- Pegar TODO este archivo en Supabase → SQL Editor → Run.

begin;

create temp table _fc_nd_6091329944 (
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

insert into _fc_nd_6091329944 (
  linea, ean, sku, nombre, snap, qty, costo, precio, tipo, categoria,
  subcategoria, forma, marca, laboratorio, presentacion, principio_activo,
  concentracion, receta, ya, imagen, foto_file, lote
) values
  (1, '7501088509773', 'FC-8509773', 'Antiflu-Des', 'ANTIFLU-DES 24 CAPS', 2, 146.59, 184, 'marca', 'Medicamentos', 'Antigripal', 'Cápsula', 'Antiflu-Des', 'Chinoin', 'Caja con 24 cápsulas', 'Amantadina / clorfenamina / paracetamol', null, false, true, null, null, null),
  (2, '7501088509766', 'FC-8509766', 'Antiflu-Des Junior', 'ANTIFLU-DES JR SOL 60 ML', 2, 111.86, 140, 'marca', 'Medicamentos', 'Antigripal', 'Solución', 'Antiflu-Des', 'Chinoin', 'Frasco 60 mL', 'Amantadina / clorfenamina / paracetamol', null, false, false, null, null, null),
  (3, '7501019064807', 'FC-19064807', 'Tena Pants Comfort grande', 'CALZ TENA PANTS COMFORT GDE C/13', 1, 117.47, 147, 'marca', 'Higiene', 'Incontinencia', 'Pants', 'Tena', 'Essity', 'Bolsa con 13 pants talla grande', null, null, false, false, null, null, null),
  (4, '7501065060891', 'FC-65060891', 'Contac Ultra', 'CONTAC ULTRA 12 TAB', 3, 30.54, 39, 'marca', 'Medicamentos', 'Antigripal', 'Tableta', 'Contac', 'Haleon', 'Caja con 12 tabletas', 'Paracetamol / fenilefrina / clorfenamina', null, false, true, null, null, null),
  (5, '7506442701039', 'FC-42701039', 'Lacosamida 100 mg', 'LACOSAMIDA 100MG 28 TAB LGEN', 2, 312.77, 501, 'generico', 'Medicamentos', null, 'Tableta', null, null, 'Caja con 28 tabletas', 'Lacosamida', '100 mg', true, false, null, null, null),
  (6, '7501019051401', 'FC-19051401', 'Tena pañal predoblado unitario', 'PAÑAL TENA PREDOBLADO UNIT C/10', 3, 88.01, 111, 'marca', 'Higiene', 'Incontinencia', 'Pañal', 'Tena', 'Essity', 'Bolsa con 10 piezas', null, null, false, false, null, null, null);

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
  'Alta Nadro 6091329944 · 2026-10-19 · listo para pistola',
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
  from _fc_nd_6091329944
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
  from _fc_nd_6091329944
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
  from _fc_nd_6091329944
  order by ean, linea
) t
where p.id = coalesce(
  public.fc_buscar_producto_escaneo(t.ean),
  public.fc_buscar_producto_escaneo(t.sku)
);

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'Nadro',
  '6091329944',
  '2026-10-19',
  1615.56,
  'borrador',
  'Factura Nadro 6091329944 · 19-oct-2026 · entrega FarmaCapital · 6 renglones / 13 pzas · $1,615.56 · cola Recibir; stock al confirmar pistola + MMAA'
where not exists (
  select 1 from public.recepciones
  where folio = '6091329944'
    and coalesce(proveedor, '') ilike '%nadro%'
);

update public.recepciones
set
  total_ticket = 1615.56,
  fecha = '2026-10-19',
  proveedor = 'Nadro',
  notas = 'Factura Nadro 6091329944 · 19-oct-2026 · entrega FarmaCapital · 6 renglones / 13 pzas · $1,615.56 · cola Recibir; stock al confirmar pistola + MMAA',
  updated_at = now()
where folio = '6091329944'
  and coalesce(proveedor, '') ilike '%nadro%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = '6091329944'
  and coalesce(r.proveedor, '') ilike '%nadro%'
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
from _fc_nd_6091329944 t
join public.recepciones r
  on r.folio = '6091329944'
 and coalesce(r.proveedor, '') ilike '%nadro%'
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
from _fc_nd_6091329944 t
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
where r.folio = '6091329944'
  and coalesce(r.proveedor, '') ilike '%nadro%'
group by r.id, r.folio, r.proveedor, r.estado, r.total_ticket;

select
  t.linea,
  t.ean,
  t.nombre,
  t.qty,
  t.costo,
  case when public.fc_buscar_producto_escaneo(t.ean) is null then 'PENDIENTE_ALTA' else 'OK' end as match,
  t.ya as marcado_ya
from _fc_nd_6091329944 t
order by t.linea;

commit;


-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- INICIO: patch_carga_compra_huggies_e4_250.sql
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Compra directa · folio FOTO-441767 · 2026-10-20
-- Foto caja + código de barras. Sin ticket de proveedor.
-- Huggies Supreme Protección Delicada Etapa 4 · 36 pañales · unisex 9–12 kg · EAN 7501943441767 · Clave KC 94082.
-- Costo reportado $250.00. Sin lote/caducidad en cola (MMAA caja).
-- 1 alta(s) stock 0. 0 ya estaban: solo costo / ficha vacía, no PVP.
-- Nombres de ficha, no del ticket. Fotos en public/catalogo-propia/ (tras deploy).
-- SIN bloques dollar-quote. Idempotente mientras el ticket siga en borrador.
-- Pegar TODO este archivo en Supabase → SQL Editor → Run.

begin;

create temp table _fc_cd_hug_e4 (
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

insert into _fc_cd_hug_e4 (
  linea, ean, sku, nombre, snap, qty, costo, precio, tipo, categoria,
  subcategoria, forma, marca, laboratorio, presentacion, principio_activo,
  concentracion, receta, ya, imagen, foto_file, lote
) values
  (1, '7501943441767', 'FC-43441767', 'Huggies Supreme Etapa 4', 'HUGGIES SUPREME E4 36 PZ 9-12KG', 1, 250.00, 313, 'marca', 'Higiene', 'Bebé', 'Pañal', 'Huggies', 'Kimberly-Clark', 'Bolsa con 36 pañales unisex (9 a 12 kg)', null, null, false, false, 'https://www.farmacapital.mx/catalogo-propia/panales-huggies-supreme-etapa-4-36-7501943441767.jpg', 'catalogo-propia/panales-huggies-supreme-etapa-4-36-7501943441767.jpg', null);

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
  'Alta Compra directa FOTO-441767 · 2026-10-20 · listo para pistola',
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
  from _fc_cd_hug_e4
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
  from _fc_cd_hug_e4
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
  from _fc_cd_hug_e4
  order by ean, linea
) t
where p.id = coalesce(
  public.fc_buscar_producto_escaneo(t.ean),
  public.fc_buscar_producto_escaneo(t.sku)
);

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'Compra directa',
  'FOTO-441767',
  '2026-10-20',
  250.00,
  'borrador',
  'Compra directa · foto caja Huggies Supreme Etapa 4 · 20-oct-2026 · EAN 7501943441767 · 1 pza · costo $250.00 · cola Recibir; stock al confirmar pistola + MMAA'
where not exists (
  select 1 from public.recepciones
  where folio = 'FOTO-441767'
    and coalesce(proveedor, '') ilike '%compra directa%'
);

update public.recepciones
set
  total_ticket = 250.00,
  fecha = '2026-10-20',
  proveedor = 'Compra directa',
  notas = 'Compra directa · foto caja Huggies Supreme Etapa 4 · 20-oct-2026 · EAN 7501943441767 · 1 pza · costo $250.00 · cola Recibir; stock al confirmar pistola + MMAA',
  updated_at = now()
where folio = 'FOTO-441767'
  and coalesce(proveedor, '') ilike '%compra directa%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = 'FOTO-441767'
  and coalesce(r.proveedor, '') ilike '%compra directa%'
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
from _fc_cd_hug_e4 t
join public.recepciones r
  on r.folio = 'FOTO-441767'
 and coalesce(r.proveedor, '') ilike '%compra directa%'
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
from _fc_cd_hug_e4 t
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
where r.folio = 'FOTO-441767'
  and coalesce(r.proveedor, '') ilike '%compra directa%'
group by r.id, r.folio, r.proveedor, r.estado, r.total_ticket;

select
  t.linea,
  t.ean,
  t.nombre,
  t.qty,
  t.costo,
  case when public.fc_buscar_producto_escaneo(t.ean) is null then 'PENDIENTE_ALTA' else 'OK' end as match,
  t.ya as marcado_ya
from _fc_cd_hug_e4 t
order by t.linea;

commit;


-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- INICIO: patch_carga_levic_9012489145.sql
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Levic · folio A 9012489145 · 2026-10-18 · CFDI 4.0
-- Entrega a FarmaCapital. 2 pzas · total $558.72 (IVA 0%).
-- Costo = precio neto. MAV352 Dexal susp EAN 7502009747335 · WES008 Fossin EAN 7501300450012.
-- Lote de fábrica sí. Caducidad del papel NO (MMAA de la caja). 0000 inválido.
-- 2 alta(s) stock 0. 0 ya estaban: solo costo / ficha vacía, no PVP.
-- Nombres de ficha, no del ticket. Fotos en public/catalogo-propia/ (tras deploy).
-- SIN bloques dollar-quote. Idempotente mientras el ticket siga en borrador.
-- Pegar TODO este archivo en Supabase → SQL Editor → Run.

begin;

create temp table _fc_lv_9012489145 (
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

insert into _fc_lv_9012489145 (
  linea, ean, sku, nombre, snap, qty, costo, precio, tipo, categoria,
  subcategoria, forma, marca, laboratorio, presentacion, principio_activo,
  concentracion, receta, ya, imagen, foto_file, lote
) values
  (1, '7502009747335', 'FC-09747335', 'Dexal ceftibuteno', 'MAV352 DEXAL 1 SUSP 30 ML', 1, 166.22, 208, 'marca', 'Medicamentos', 'Antibiótico', 'Suspensión', 'Dexal', 'Maver', 'Frasco polvo para 30 mL', 'Ceftibuteno', '36 mg/mL', true, false, 'https://www.farmacapital.mx/catalogo-propia/dexal-ceftibuteno-suspension-30ml-7502009747335.jpg', 'catalogo-propia/dexal-ceftibuteno-suspension-30ml-7502009747335.jpg', '256898'),
  (2, '7501300450012', 'FC-30045001', 'Fossin fosfomicina 500 mg', 'WES008 FOSSIN 12 CAPS 500 MG', 1, 392.50, 491, 'marca', 'Medicamentos', 'Antibiótico', 'Cápsula', 'Fossin', 'Weser Pharma', 'Caja con 12 cápsulas', 'Fosfomicina', '500 mg', true, false, 'https://www.farmacapital.mx/catalogo-propia/fossin-fosfomicina-500mg-12caps-7501300450012.jpg', 'catalogo-propia/fossin-fosfomicina-500mg-12caps-7501300450012.jpg', '261380');

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
  'Alta Levic 9012489145 · 2026-10-18 · listo para pistola',
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
  from _fc_lv_9012489145
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
  from _fc_lv_9012489145
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
  from _fc_lv_9012489145
  order by ean, linea
) t
where p.id = coalesce(
  public.fc_buscar_producto_escaneo(t.ean),
  public.fc_buscar_producto_escaneo(t.sku)
);

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'Levic',
  '9012489145',
  '2026-10-18',
  558.72,
  'borrador',
  'Factura Levic A 9012489145 · 18-oct-2026 · UUID 4F8597D0-76C7-4026-B18F-C43769D9EE39 · 2 renglones / 2 pzas · $558.72 · cola Recibir; stock al confirmar pistola + MMAA'
where not exists (
  select 1 from public.recepciones
  where folio = '9012489145'
    and coalesce(proveedor, '') ilike '%levic%'
);

update public.recepciones
set
  total_ticket = 558.72,
  fecha = '2026-10-18',
  proveedor = 'Levic',
  notas = 'Factura Levic A 9012489145 · 18-oct-2026 · UUID 4F8597D0-76C7-4026-B18F-C43769D9EE39 · 2 renglones / 2 pzas · $558.72 · cola Recibir; stock al confirmar pistola + MMAA',
  updated_at = now()
where folio = '9012489145'
  and coalesce(proveedor, '') ilike '%levic%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = '9012489145'
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
from _fc_lv_9012489145 t
join public.recepciones r
  on r.folio = '9012489145'
 and coalesce(r.proveedor, '') ilike '%levic%'
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
from _fc_lv_9012489145 t
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
where r.folio = '9012489145'
  and coalesce(r.proveedor, '') ilike '%levic%'
group by r.id, r.folio, r.proveedor, r.estado, r.total_ticket;

select
  t.linea,
  t.ean,
  t.nombre,
  t.qty,
  t.costo,
  case when public.fc_buscar_producto_escaneo(t.ean) is null then 'PENDIENTE_ALTA' else 'OK' end as match,
  t.ya as marcado_ya
from _fc_lv_9012489145 t
order by t.linea;

commit;
