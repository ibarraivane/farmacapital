-- Farmaceuticos Tenorio · folio 3838940 · 2026-11-02 07:43
-- Cliente 20077 Palillero Ventura Luis Angel. Ref 2150638. Ruta Puebla. 1 caja.
-- Subtotal 1148.52 + IVA 0.00 = 1148.52. Costo = importe / cantidad.
-- Lote de la factura. Caducidad null: MMAA de la caja. No inventar 0000.
-- Gelubrin ya existía (FC-5C8C9C11). Altas: Raypid, Doxon C/10 y C/20,
-- Dexketoprofeno sobres (marca no confirmada), Aliren.
-- 5 alta(s) stock 0. 1 ya estaban: solo costo / ficha vacía, no PVP.
-- Nombres de ficha, no del ticket. Fotos en public/catalogo-propia/ (tras deploy).
-- SIN bloques dollar-quote. Idempotente mientras el ticket siga en borrador.
-- Pegar TODO este archivo en Supabase → SQL Editor → Run.

begin;

create temp table _fc_tn_3838940 (
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

insert into _fc_tn_3838940 (
  linea, ean, sku, nombre, snap, qty, costo, precio, tipo, categoria,
  subcategoria, forma, marca, laboratorio, presentacion, principio_activo,
  concentracion, receta, ya, imagen, foto_file, lote
) values
  (1, '7503027446279', 'FC-5C8C9C11', 'Gelubrin 600 mg', 'GELUBRIN 600MG CAP C/10 *PRO*', 30, 18.11, 29, 'generico', 'Antiinflamatorio', null, 'Cápsulas', 'Gelubrin', 'Progela', 'Caja con 10 cápsulas', 'Ibuprofeno', '600 mg', false, true, 'https://www.farmacapital.mx/catalogo-propia/gelubrin-600-7503027446279.jpg', 'catalogo-propia/gelubrin-600-7503027446279.jpg', 'U0591'),
  (2, '7502003386547', 'FC-03386547', 'Raypid 600 mg', 'GEMFIBROZILO 600MG TAB C/14 *RAY*', 2, 89.19, 143, 'generico', 'Medicamentos', 'Lípidos', 'Tabletas', 'Raypid', 'Rayere', 'Caja con 14 tabletas', 'Gemfibrozilo', '600 mg', true, false, 'https://www.farmacapital.mx/catalogo-propia/raypid-600-c14-7502003386547.jpg', 'catalogo-propia/raypid-600-c14-7502003386547.jpg', '26104'),
  (3, '7502009746222', 'FC-09746222', 'Doxon 25 mg', 'DEXKETOPROFENO 25MG TAB C/10 *MVE*', 2, 59.00, 95, 'generico', 'Analgésico', null, 'Tabletas', 'Doxon', 'Maver', 'Caja con 10 tabletas', 'Dexketoprofeno', '25 mg', true, false, 'https://www.farmacapital.mx/catalogo-propia/doxon-25mg-c10-7502009746222.jpg', 'catalogo-propia/doxon-25mg-c10-7502009746222.jpg', '263460'),
  (4, '7502009748844', 'FC-09748844', 'Doxon 25 mg', 'DEXKETOPROFENO 25MG TAB C/20 *MVE*', 1, 113.77, 183, 'generico', 'Analgésico', null, 'Tabletas', 'Doxon', 'Maver', 'Caja con 20 tabletas', 'Dexketoprofeno', '25 mg', true, false, null, null, '262635'),
  (5, '7503045798336', 'FC-45798336', 'Dexketoprofeno 25 mg/10 ml', 'DEXKETOPROFENO 25MG/10ML SOBRES', 1, 80.96, 130, 'generico', 'Analgésico', null, 'Solución', null, null, 'Sobres', 'Dexketoprofeno', '25 mg/10 ml', true, false, null, null, '266319'),
  (6, '7501300420541', 'FC-00420541', 'Aliren 50/3/300 mg', 'ALIREN 50/3/300MG CAP C/24 *SGF*', 1, 114.11, 143, 'marca', 'Medicamentos', 'Respiratorio', 'Cápsulas', 'Aliren', 'Siegfried Rhein', 'Caja con 24 cápsulas', 'Amantadina / clorfenamina / paracetamol', '50/3/300 mg', false, false, 'https://www.farmacapital.mx/catalogo-propia/aliren-50-3-300-c24-7501300420541.jpg', 'catalogo-propia/aliren-50-3-300-c24-7501300420541.jpg', '261358');

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
  'Alta Farmaceuticos Tenorio 3838940 · 2026-11-02 · listo para pistola',
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
  from _fc_tn_3838940
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
  from _fc_tn_3838940
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
  from _fc_tn_3838940
  order by ean, linea
) t
where p.id = coalesce(
  public.fc_buscar_producto_escaneo(t.ean),
  public.fc_buscar_producto_escaneo(t.sku)
);

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'Farmaceuticos Tenorio',
  '3838940',
  '2026-11-02',
  1148.52,
  'borrador',
  'Factura Farmaceuticos Tenorio folio 3838940 · 02-nov-2026 07:43 · cliente 20077 Palillero Ventura · ref 2150638 · ruta Puebla · 1 caja · cola Recibir, stock al confirmar pistola y MMAA'
where not exists (
  select 1 from public.recepciones
  where folio = '3838940'
    and coalesce(proveedor, '') ilike '%tenorio%'
);

update public.recepciones
set
  total_ticket = 1148.52,
  fecha = '2026-11-02',
  proveedor = 'Farmaceuticos Tenorio',
  notas = 'Factura Farmaceuticos Tenorio folio 3838940 · 02-nov-2026 07:43 · cliente 20077 Palillero Ventura · ref 2150638 · ruta Puebla · 1 caja · cola Recibir, stock al confirmar pistola y MMAA',
  updated_at = now()
where folio = '3838940'
  and coalesce(proveedor, '') ilike '%tenorio%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = '3838940'
  and coalesce(r.proveedor, '') ilike '%tenorio%'
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
from _fc_tn_3838940 t
join public.recepciones r
  on r.folio = '3838940'
 and coalesce(r.proveedor, '') ilike '%tenorio%'
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
from _fc_tn_3838940 t
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
where r.folio = '3838940'
  and coalesce(r.proveedor, '') ilike '%tenorio%'
group by r.id, r.folio, r.proveedor, r.estado, r.total_ticket;

select
  t.linea,
  t.ean,
  t.nombre,
  t.qty,
  t.costo,
  case when public.fc_buscar_producto_escaneo(t.ean) is null then 'PENDIENTE_ALTA' else 'OK' end as match,
  t.ya as marcado_ya
from _fc_tn_3838940 t
order by t.linea;

commit;
