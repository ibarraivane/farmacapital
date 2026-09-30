-- Pedido Nadro folio 6090551411 (2026-09-28) — altas + cola Recibir.
-- Factura CFDI UUID 63A7365A-98A6-4068-83F3-1897395A2AE8 · total $440.18
-- Subtotal renglones $379.47 + IVA $60.71.
-- SIN bloques dollar-quote (do $$). El SQL Editor de Supabase los corta.
-- 3 altas stock 0 + 1 ya en catálogo (chupón FC-26462078).
-- Ficha iNadro / retailers (no código del ticket).
-- EANs pistola: chupón 7501026462245 (factura imprimió 5462245); Hypafix 4042809591446 (factura 1448).
-- Ticket borrador. Stock al escanear + MMAA de la caja. No inventar 0000.
-- Idempotente mientras el ticket siga en borrador.
-- Pegar TODO este archivo en Supabase → SQL Editor → Run.
-- Fotos: tras deploy, pegar sql/patch_fotos_nadro_6090551411.sql

begin;

create temp table _fc_nd6090551411 (
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
  receta boolean not null,
  alta_nueva boolean not null
) on commit drop;

insert into _fc_nd6090551411
  (linea, ean, sku, nombre, snap, qty, costo, precio, tipo, categoria, subcategoria,
   marca, presentacion, forma, laboratorio, principio_activo, receta, alta_nueva)
values
  (1, '7501026462245', 'FC-26462078', 'Chupón Ternura flor y balón con miel', 'CHUPON TERNURA FLOR/BALON MIEL S', 18, 3.10, 4, 'marca', 'Bebés', 'Chupones', 'Ternura', '1 pieza', 'Chupón', 'M.A. Carter', null, false, false),
  (2, '4042809591446', 'FC-09591446', 'Leukoplast Hypafix', 'LEUKOPLAST HYPAFIX 10 CM X 2M', 1, 71.63, 90, 'marca', 'Botiquín', 'Material de curación', 'Leukoplast', '10 cm x 2 m', 'Lamina adhesiva', 'Essity', null, false, true),
  (3, '650240032431', 'FC-40032431', 'Asepxia polvo compacto Canela', 'MJE ASEPXIA PVO COM TONO CANELA 10G', 1, 126.02, 158, 'marca', 'Cuidado personal', 'Maquillaje', 'Asepxia', '10 g', 'Polvo compacto', 'Genomma Lab', null, false, true),
  (4, '650240032455', 'FC-40032455', 'Asepxia BB polvo compacto Natural Mate', 'MJE ASEPXIABBPVOCOMPNATMA 10G', 1, 126.02, 158, 'marca', 'Cuidado personal', 'Maquillaje', 'Asepxia', '10 g', 'Polvo compacto', 'Genomma Lab', null, false, true);

-- Altas nuevas (solo si el EAN no existe).
insert into public.productos (
  nombre, sku, codigo_barras, categoria, tipo, descripcion,
  costo, precio, stock, stock_minimo, activo, requiere_receta
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
  'Alta Nadro 6090551411 · 2026-09-28 · listo para pistola',
  t.costo,
  t.precio,
  0,
  1,
  true,
  t.receta
from _fc_nd6090551411 t
where t.alta_nueva
  and public.fc_buscar_producto_escaneo(t.ean) is null;

-- Ficha de mostrador (marca real, no casa Nadro CARTER/ESSITY/GENOMMALAB como marca).
update public.productos p set
  marca = t.marca,
  presentacion = t.presentacion,
  forma_farmaceutica = t.forma,
  principio_activo = t.principio_activo,
  subcategoria = t.subcategoria,
  laboratorio = coalesce(nullif(btrim(p.laboratorio), ''), t.laboratorio),
  nombre = t.nombre,
  categoria = t.categoria,
  tipo = t.tipo,
  requiere_receta = t.receta
from _fc_nd6090551411 t
where p.id = public.fc_buscar_producto_escaneo(t.ean);

-- Costos del ticket (PVP solo si estaba en 0).
update public.productos p
set
  costo = t.costo,
  precio = case
    when coalesce(p.precio, 0) <= 0 then t.precio
    else p.precio
  end
from _fc_nd6090551411 t
where p.id = public.fc_buscar_producto_escaneo(t.ean)
  and (
    p.costo is distinct from t.costo
    or coalesce(p.precio, 0) <= 0
  );

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'Nadro',
  '6090551411',
  '2026-09-28',
  440.18,
  'borrador',
  'Pedido Nadro 6090551411 · CFDI 28-09-26 · EAN iNadro · cola Recibir; stock al confirmar pistola · chupón/Hypafix DV corregido'
where not exists (
  select 1 from public.recepciones
  where folio = '6090551411' and coalesce(proveedor, '') ilike '%nadro%'
);

-- Reabrir aunque no esté en borrador (si un run previo dejó estado raro).
update public.recepciones
set
  estado = 'borrador',
  cerrado_en = null,
  total_ticket = 440.18,
  fecha = '2026-09-28',
  proveedor = 'Nadro',
  notas = 'Pedido Nadro 6090551411 · CFDI 28-09-26 · EAN iNadro · cola Recibir; stock al confirmar pistola · chupón/Hypafix DV corregido',
  updated_at = now()
where folio = '6090551411'
  and coalesce(proveedor, '') ilike '%nadro%';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = '6090551411'
  and coalesce(r.proveedor, '') ilike '%nadro%';

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
from _fc_nd6090551411 t
join public.recepciones r
  on r.folio = '6090551411'
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
where r.folio = '6090551411' and coalesce(r.proveedor, '') ilike '%nadro%'
order by i.id;
