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

-- Una foto por (producto, url): tickets con 2 renglones del mismo EAN
-- (promo 2+1) no deben insertar dos veces la misma URL.
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
from (
  select distinct on (ean, imagen) *
  from _fc_nd_6091329944
  where imagen is not null
  order by ean, imagen, linea
) t
join public.productos p on p.id = coalesce(
  public.fc_buscar_producto_escaneo(t.ean),
  public.fc_buscar_producto_escaneo(t.sku)
)
where not exists (
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
