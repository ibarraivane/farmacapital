-- Factura Nadro folio E090246807 (2026-09-20) — altas + cola Recibir.
-- CFDI 20-sep-2026 · total $1421.75 · 8 piezas
-- SIN bloques dollar-quote (do $$). El SQL Editor de Supabase los corta.
-- 2 altas stock 0 (Excelsior, Mifepristona). Pharmacaine ya en catálogo (EQ-QUM014).
-- Ficha desde iNadro (no código del ticket). DKT MEXICO no es marca de mostrador.
-- Ticket borrador. Stock al escanear + MMAA de la caja. No inventar 0000.
-- Idempotente mientras el ticket siga en borrador.
-- Pegar TODO este archivo en Supabase → SQL Editor → Run.
-- Fotos: tras deploy, pegar sql/patch_fotos_nadro_e090246807.sql

begin;

create temp table _fc_nd090246807 (
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

insert into _fc_nd090246807
  (linea, ean, sku, nombre, snap, qty, costo, precio, tipo, categoria, subcategoria,
   marca, presentacion, forma, laboratorio, principio_activo, receta, alta_nueva)
values
  (1, '7501022112106', 'FC-22112106', 'Excelsior pomada callos y verrugas 8 g', 'EXCELSIOR POM 8 G', 3, 50.69, 68, 'marca', 'Medicamentos OTC', 'Tratamientos dermatológicos', 'Grisi', 'Tubo 8 g', 'Pomada', 'Grisi', 'Ácido salicílico', false, true),
  (2, '7502223111202', 'EQ-QUM014', 'Pharmacaine lidocaína 10% spray 115 ml', 'LIDOCAINA 10% SPRAY 115 ML LGEN', 3, 134.34, 336, 'generico', 'Medicamentos', 'Anestésicos locales', 'Pharmacaine', 'Frasco atomizador 115 ml', 'Solución tópica', 'Quimpharma', 'Lidocaína 10%', true, false),
  (3, '7502214986659', 'FC-14986659', 'Mifepristona 200 mg caja con 1 tableta', 'MIFEPRISTONA 200MG CJA 1 TAB', 2, 433.33, 1084, 'generico', 'Medicamentos', 'Ginecología', null, 'Caja con 1 tableta', 'Tableta', null, 'Mifepristona 200 mg', true, true);

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
  'Alta Nadro E090246807 · 2026-09-20 · listo para pistola',
  t.costo,
  t.precio,
  0,
  1,
  true,
  t.receta
from _fc_nd090246807 t
where t.alta_nueva
  and public.fc_buscar_producto_escaneo(t.ean) is null;

-- Ficha de mostrador (marca real, no casa Nadro LGEN/TENORIO como marca).
update public.productos p set
  marca = coalesce(nullif(btrim(t.marca), ''), p.marca),
  presentacion = t.presentacion,
  forma_farmaceutica = t.forma,
  principio_activo = t.principio_activo,
  subcategoria = t.subcategoria,
  laboratorio = coalesce(nullif(btrim(t.laboratorio), ''), nullif(btrim(p.laboratorio), ''), t.laboratorio),
  nombre = t.nombre,
  categoria = t.categoria,
  tipo = t.tipo,
  requiere_receta = t.receta
from _fc_nd090246807 t
where p.id = public.fc_buscar_producto_escaneo(t.ean);

-- Costos del ticket (PVP solo si estaba en 0).
update public.productos p
set
  costo = t.costo,
  precio = case
    when coalesce(p.precio, 0) <= 0 then t.precio
    else p.precio
  end
from _fc_nd090246807 t
where p.id = public.fc_buscar_producto_escaneo(t.ean)
  and (
    p.costo is distinct from t.costo
    or coalesce(p.precio, 0) <= 0
  );

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'Nadro',
  'E090246807',
  '2026-09-20',
  1421.75,
  'borrador',
  'Factura Nadro E090246807 · 20-09-26 · EAN iNadro · cola Recibir; stock al confirmar pistola'
where not exists (
  select 1 from public.recepciones
  where folio = 'E090246807' and coalesce(proveedor, '') ilike '%nadro%'
);

update public.recepciones
set
  total_ticket = 1421.75,
  fecha = '2026-09-20',
  proveedor = 'Nadro',
  notas = 'Factura Nadro E090246807 · 20-09-26 · EAN iNadro · cola Recibir; stock al confirmar pistola',
  updated_at = now()
where folio = 'E090246807'
  and coalesce(proveedor, '') ilike '%nadro%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = 'E090246807'
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
from _fc_nd090246807 t
join public.recepciones r
  on r.folio = 'E090246807'
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
where r.folio = 'E090246807' and coalesce(r.proveedor, '') ilike '%nadro%'
order by i.id;
