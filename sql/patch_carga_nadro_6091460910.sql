-- Factura Nadro folio 6091460910 (2026-10-22) — altas + cola Recibir.
-- CFDI 22-oct-2026 · total $1626.29 · 4 piezas
-- SIN bloques dollar-quote (do $$). El SQL Editor de Supabase los corta.
-- 2 altas stock 0 (Danzen 10 mg, Danzen 5 mg). Mifepristona ya en catálogo (FC-14986659).
-- Ficha iNadro (no código del ticket). DKT MEXICO no es marca de mostrador.
-- EAN papel con dígito inválido → pistola iNadro (Danzen 10 / Mifepristona).
-- Precio = recargo sobre costo (+25% marca / +60% genérico).
-- Ticket borrador. Stock al escanear + MMAA de la caja. No inventar 0000.
-- Idempotente mientras el ticket siga en borrador.
-- Pegar TODO este archivo en Supabase → SQL Editor → Run.
-- Fotos: tras deploy, pegar sql/patch_fotos_nadro_6091460910.sql

begin;

create temp table _fc_nd6091460910 (
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

insert into _fc_nd6091460910
  (linea, ean, sku, nombre, snap, qty, costo, precio, tipo, categoria, subcategoria,
   marca, presentacion, forma, laboratorio, principio_activo, receta, alta_nueva)
values
  (1, '7501385491085', 'FC-85491085', 'Danzen 10 mg', 'DANZEN 10 MG 20 TAB', 1, 373.31, 467, 'marca', 'Medicamentos', 'Antiinflamatorio', 'Danzen', 'Caja con 20 tabletas', 'Tableta', 'Sanfer', 'Serratiopeptidasa', true, true),
  (2, '7501385420061', 'FC-85420061', 'Danzen 5 mg', 'DANZEN 5 MG 30 TAB', 1, 290.02, 363, 'marca', 'Medicamentos', 'Antiinflamatorio', 'Danzen', 'Caja con 30 tabletas', 'Tableta', 'Sanfer', 'Serratiopeptidasa', true, true),
  (3, '7502214986659', 'FC-14986659', 'Mifepristona 200 mg', 'MIFEPRISTONA 200MG CJA 1 TAB', 2, 481.48, 771, 'generico', 'Medicamentos', 'Ginecología', null, 'Caja con 1 tableta', 'Tableta', null, 'Mifepristona', true, false);

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
  'Alta Nadro 6091460910 · 2026-10-22 · listo para pistola',
  t.costo,
  t.precio,
  0,
  1,
  true,
  t.receta
from _fc_nd6091460910 t
where t.alta_nueva
  and public.fc_buscar_producto_escaneo(t.ean) is null;

-- Ficha de mostrador (marca real, no casa Nadro / DKT MEXICO como marca).
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
from _fc_nd6091460910 t
where p.id = public.fc_buscar_producto_escaneo(t.ean);

-- Costos del ticket (PVP solo si estaba en 0).
update public.productos p
set
  costo = t.costo,
  precio = case
    when coalesce(p.precio, 0) <= 0 then t.precio
    else p.precio
  end
from _fc_nd6091460910 t
where p.id = public.fc_buscar_producto_escaneo(t.ean)
  and (
    p.costo is distinct from t.costo
    or coalesce(p.precio, 0) <= 0
  );

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'Nadro',
  '6091460910',
  '2026-10-22',
  1626.29,
  'borrador',
  'Factura Nadro 6091460910 · 22-10-26 · EAN iNadro · cola Recibir; stock al confirmar pistola'
where not exists (
  select 1 from public.recepciones
  where folio = '6091460910' and coalesce(proveedor, '') ilike '%nadro%'
);

update public.recepciones
set
  total_ticket = 1626.29,
  fecha = '2026-10-22',
  proveedor = 'Nadro',
  notas = 'Factura Nadro 6091460910 · 22-10-26 · EAN iNadro · cola Recibir; stock al confirmar pistola',
  updated_at = now()
where folio = '6091460910'
  and coalesce(proveedor, '') ilike '%nadro%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = '6091460910'
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
from _fc_nd6091460910 t
join public.recepciones r
  on r.folio = '6091460910'
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
where r.folio = '6091460910' and coalesce(r.proveedor, '') ilike '%nadro%'
order by i.id;
