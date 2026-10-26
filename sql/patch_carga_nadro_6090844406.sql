-- Factura Nadro folio 6090844406 (2026-10-06) — altas + cola Recibir.
-- CFDI 06-oct-2026 · total $343.20 · 2 piezas
-- SIN bloques dollar-quote (do $$). El SQL Editor de Supabase los corta.
-- 2 altas stock 0 (Mictrobil, Exakta latanoprost).
-- Ficha desde iNadro (no código del ticket). MICROGRP/LGEN no son marca de mostrador.
-- Ticket borrador. Stock al escanear + MMAA de la caja. No inventar 0000.
-- Idempotente mientras el ticket siga en borrador.
-- Pegar TODO este archivo en Supabase → SQL Editor → Run.
-- Fotos: tras deploy, pegar sql/patch_fotos_nadro_6090844406.sql

begin;

create temp table _fc_nd6090844406 (
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
  marca text,
  presentacion text,
  forma text,
  laboratorio text,
  principio_activo text,
  concentracion text,
  receta boolean not null,
  alta_nueva boolean not null,
  imagen text
) on commit drop;

insert into _fc_nd6090844406
  (linea, ean, sku, nombre, snap, qty, costo, precio, tipo, categoria, subcategoria,
   marca, presentacion, forma, laboratorio, principio_activo, concentracion, receta, alta_nueva, imagen)
values
  (1, '7502231320696', 'FC-31320696', 'Mictrobil bimatoprost 0.3 mg', 'BIMATOPROST 0.3MG SOL 3 ML LGEN', 1, 209.38, 336, 'generico', 'Medicamentos', 'Oftalmología', 'Mictrobil', 'Frasco gotero 3 ml', 'Solución oftálmica', 'Micro Pharmaceuticals', 'Bimatoprost', '0.3 mg/ml', true, true, 'https://www.farmacapital.mx/catalogo-propia/mictrobil-bimatoprost-0.3mg-3ml-7502231320696.jpg'),
  (2, '75055813', 'FC-75055813', 'Exakta latanoprost 0.05 mg', 'LATANOPR .05MG OFTA 3ML GTS LGEN', 1, 133.82, 215, 'generico', 'Medicamentos', 'Oftalmología', 'Exakta', 'Frasco gotero 3 ml', 'Solución oftálmica', 'Opko', 'Latanoprost', '0.05 mg/ml', true, true, 'https://www.farmacapital.mx/catalogo-propia/exakta-latanoprost-0.05mg-3ml-75055813.jpg');

-- Altas nuevas (solo si el EAN no existe).
insert into public.productos (
  nombre, sku, codigo_barras, categoria, tipo, descripcion,
  costo, precio, stock, stock_minimo, activo, requiere_receta,
  marca, presentacion, forma_farmaceutica, principio_activo, concentracion,
  laboratorio, subcategoria, imagen_url, imagen_mobile_url
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
  t.tipo,
  'Alta Nadro 6090844406 · 2026-10-06 · listo para pistola',
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
  t.subcategoria,
  t.imagen,
  t.imagen
from _fc_nd6090844406 t
where t.alta_nueva
  and public.fc_buscar_producto_escaneo(t.ean) is null;

-- Ficha de mostrador (marca real, no casa Nadro LGEN/MICROGRP como marca).
update public.productos p set
  marca = coalesce(nullif(btrim(t.marca), ''), p.marca),
  presentacion = t.presentacion,
  forma_farmaceutica = t.forma,
  principio_activo = t.principio_activo,
  concentracion = t.concentracion,
  subcategoria = t.subcategoria,
  laboratorio = coalesce(nullif(btrim(t.laboratorio), ''), nullif(btrim(p.laboratorio), ''), t.laboratorio),
  nombre = t.nombre,
  categoria = t.categoria,
  tipo = t.tipo,
  requiere_receta = t.receta,
  imagen_url = coalesce(nullif(btrim(p.imagen_url), ''), t.imagen),
  imagen_mobile_url = coalesce(nullif(btrim(p.imagen_mobile_url), ''), t.imagen)
from _fc_nd6090844406 t
where p.id = public.fc_buscar_producto_escaneo(t.ean);

-- Costos del ticket (PVP solo si estaba en 0).
update public.productos p
set
  costo = t.costo,
  precio = case
    when coalesce(p.precio, 0) <= 0 then t.precio
    else p.precio
  end
from _fc_nd6090844406 t
where p.id = public.fc_buscar_producto_escaneo(t.ean)
  and (
    p.costo is distinct from t.costo
    or coalesce(p.precio, 0) <= 0
  );

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'Nadro',
  '6090844406',
  '2026-10-06',
  343.20,
  'borrador',
  'Factura Nadro 6090844406 · 06-10-26 · EAN iNadro · cola Recibir; stock al confirmar pistola'
where not exists (
  select 1 from public.recepciones
  where folio = '6090844406' and coalesce(proveedor, '') ilike '%nadro%'
);

update public.recepciones
set
  total_ticket = 343.20,
  fecha = '2026-10-06',
  proveedor = 'Nadro',
  notas = 'Factura Nadro 6090844406 · 06-10-26 · EAN iNadro · cola Recibir; stock al confirmar pistola',
  updated_at = now()
where folio = '6090844406'
  and coalesce(proveedor, '') ilike '%nadro%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = '6090844406'
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
  t.snap,
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
from _fc_nd6090844406 t
join public.recepciones r
  on r.folio = '6090844406'
 and coalesce(r.proveedor, '') ilike '%nadro%'
 and r.estado = 'borrador'
left join lateral (
  select coalesce(
    public.fc_buscar_producto_escaneo(t.ean),
    public.fc_buscar_producto_escaneo(t.sku)
  ) as pid
) v on true
order by t.linea;

commit;

select
  i.id,
  i.codigo_escaneado as ean,
  left(i.nombre_snapshot, 48) as nombre,
  i.cantidad,
  i.costo_estimado,
  case when i.pendiente_alta then 'ALTA NUEVA' else 'YA EXISTE' end as estado,
  p.sku,
  left(p.nombre, 48) as nombre_catalogo
from public.recepcion_items i
join public.recepciones r on r.id = i.recepcion_id
left join public.productos p on p.id = i.producto_id
where r.folio = '6090844406' and coalesce(r.proveedor, '') ilike '%nadro%'
order by i.id;
