-- Pedido Nadro folio 000004568 (2026-09-13) — altas + cola Recibir.
-- Fotos ticket · total $526.22
-- Garnier: ticket imprimió EAN inválido 7509552875481 → pistola 7509552875461.
-- SIN bloques dollar-quote (do $$). El SQL Editor de Supabase los corta.
-- 5 altas stock 0. Ficha desde iNadro (no código del ticket).
-- Ticket borrador. Stock al escanear + MMAA de la caja. No inventar 0000.
-- Idempotente mientras el ticket siga en borrador.
-- Pegar TODO este archivo en Supabase → SQL Editor → Run.
-- Fotos: tras deploy, pegar sql/patch_fotos_nadro_000004568.sql

begin;

create temp table _fc_nd000004568 (
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

insert into _fc_nd000004568
  (linea, ean, sku, nombre, snap, qty, costo, precio, tipo, categoria, subcategoria,
   marca, presentacion, forma, laboratorio, principio_activo, receta, alta_nueva)
values
  (1, '7501446000553', 'FC-46000553', 'A.F. Valdecasas ácido fólico 5 mg 50 tabletas', 'ACIDO-FOLICO 5 MG 50 TAB', 1, 45.80, 62, 'marca', 'Medicamentos', 'Vitaminas', 'Valdecasas', 'Caja con frasco 50 tabletas', 'Tableta', 'Valdecasas', 'Ácido fólico 5 mg', true, true),
  (2, '7501022112250', 'FC-22112250', 'C-Boost colágeno + biotina + ácido hialurónico 90 gomitas', 'C-BOOST SUP ALIM COLAGENO FCO90GOM', 1, 109.91, 147, 'marca', 'Vitaminas y suplementos', 'Colágeno', 'C-Boost', 'Frasco con 90 gomitas', 'Gomita', 'Grisi', 'Colágeno / biotina / ácido hialurónico', false, true),
  (3, '7502009746321', 'FC-09746321', 'Nisolver (prednisolona) 1 mg/ml solución oral 100 ml', 'PREDNIS 1MG/1ML SOL FCO100ML LGEN', 1, 80.14, 201, 'generico', 'Medicamentos', 'Hormonas', 'Nisolver', 'Caja con frasco 100 ml', 'Solución oral', 'Maver', 'Prednisolona 1 mg/ml', true, true),
  (4, '7509552875461', 'FC-52875461', 'Garnier Express Aclara sérum anti-imperfecciones 4% 30 ml', 'SERUM GARNIER EXPRES BOOS 4% 30ML', 1, 129.78, 174, 'marca', 'Cuidado personal', 'Cuidado de la piel', 'Garnier', '30 ml', 'Sérum', 'L''Oréal', null, false, true),
  (5, '7501587010404', 'FC-87010404', 'Vivioptal oral 30 cápsulas', 'VIVIOPTAL 30 CAPS', 1, 160.59, 215, 'marca', 'Vitaminas y suplementos', 'Multivitamínicos', 'Vivioptal', 'Caja con 30 cápsulas', 'Cápsula', 'Bomuca', null, false, true);

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
  'Alta Nadro 000004568 · 2026-09-13 · listo para pistola',
  t.costo,
  t.precio,
  0,
  1,
  true,
  t.receta
from _fc_nd000004568 t
where t.alta_nueva
  and public.fc_buscar_producto_escaneo(t.ean) is null;

-- Ficha de mostrador (marca real, no casa Nadro FRABEL/LGEN/BOMUCA como marca).
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
from _fc_nd000004568 t
where p.id = public.fc_buscar_producto_escaneo(t.ean);

-- Costos del ticket (PVP solo si estaba en 0).
update public.productos p
set
  costo = t.costo,
  precio = case
    when coalesce(p.precio, 0) <= 0 then t.precio
    else p.precio
  end
from _fc_nd000004568 t
where p.id = public.fc_buscar_producto_escaneo(t.ean)
  and (
    p.costo is distinct from t.costo
    or coalesce(p.precio, 0) <= 0
  );

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'Nadro',
  '000004568',
  '2026-09-13',
  526.22,
  'borrador',
  'Pedido Nadro 000004568 · fotos 13-09-26 · EAN iNadro · cola Recibir; stock al confirmar pistola · Garnier EAN corregido 5461'
where not exists (
  select 1 from public.recepciones
  where folio = '000004568' and coalesce(proveedor, '') ilike '%nadro%'
);

update public.recepciones
set
  total_ticket = 526.22,
  fecha = '2026-09-13',
  proveedor = 'Nadro',
  notas = 'Pedido Nadro 000004568 · fotos 13-09-26 · EAN iNadro · cola Recibir; stock al confirmar pistola · Garnier EAN corregido 5461',
  updated_at = now()
where folio = '000004568'
  and coalesce(proveedor, '') ilike '%nadro%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = '000004568'
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
from _fc_nd000004568 t
join public.recepciones r
  on r.folio = '000004568'
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
where r.folio = '000004568' and coalesce(r.proveedor, '') ilike '%nadro%'
order by i.id;
