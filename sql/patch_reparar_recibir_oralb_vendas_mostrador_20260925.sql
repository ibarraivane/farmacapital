-- ============================================================================
-- REPARAR Recibir: tickets 24-sep + Oral-B + Suerox + vendas/Protec mostrador
--
-- Qué arregla (si ya corriste las cargas o si faltaban):
-- 1) Oral-B Stages: productos + renglones Farma Mayoreo 306277 con EAN de caja
--    3014260279264 (Disney/Pixar ×2) y 3014260278922 (Frozen ×1).
-- 2) Suerox naranja-mango: EAN botella 7501048607214 (no el 650… interno).
-- 3) Dibar colores / Venda-stick: pega EAN real en recepcion_items de borradores.
-- 4) Crea pedido vivo «Mostrador 25-sep» con Protec + Venda-stick + Quirmex + Dibar
--    para que sí aparezcan en la cola Recibir al escanear.
--
-- NO sustituye las cargas grandes. Si Farma Mayoreo / Farmalive / Cityfarma
-- NO salen en la lista, corre antes:
--   sql/patch_carga_tickets_20260924_TODOS.sql
-- (o cada patch_carga_* del LEERME_tickets_20260924.md)
--
-- Luego: sql/patch_alta_protec_… y sql/patch_alta_vendas_… (si aún no).
-- Pegar ESTE archivo completo en Supabase → SQL Editor → Run.
-- ============================================================================

begin;

-- ---------------------------------------------------------------------------
-- 1) Oral-B Stages — asegurar ficha + EAN (por si la carga no corrió)
-- ---------------------------------------------------------------------------
insert into public.productos (
  nombre, sku, codigo_barras, categoria, subcategoria, tipo, descripcion,
  costo, precio, stock, stock_minimo, activo, requiere_receta,
  marca, presentacion, forma_farmaceutica, laboratorio
)
select
  v.nombre, v.sku, v.ean, 'Cuidado personal', 'Bucal', 'marca',
  'Oral-B Stages · EAN caja · Farma Mayoreo 306277',
  v.costo, v.precio, 0, 1, true, false,
  'Oral-B', '1 pieza', 'Cepillo', 'P&G'
from (values
  ('Oral-B Stages cepillo dental infantil 3+ Disney/Pixar', 'FC-60279264', '3014260279264', 51.83::numeric, 65::numeric),
  ('Oral-B Stages cepillo dental infantil 3+ Frozen', 'FC-60278922', '3014260278922', 50.97, 64)
) as v(nombre, sku, ean, costo, precio)
where public.fc_buscar_producto_escaneo(v.ean) is null
  and not exists (select 1 from public.productos p where p.sku = v.sku);

update public.productos set
  codigo_barras = '3014260279264',
  nombre = 'Oral-B Stages cepillo dental infantil 3+ Disney/Pixar',
  marca = 'Oral-B',
  presentacion = coalesce(nullif(btrim(presentacion), ''), '1 pieza'),
  forma_farmaceutica = coalesce(nullif(btrim(forma_farmaceutica), ''), 'Cepillo'),
  categoria = 'Cuidado personal',
  subcategoria = 'Bucal',
  laboratorio = coalesce(nullif(btrim(laboratorio), ''), 'P&G'),
  activo = true,
  updated_at = now()
where sku = 'FC-60279264'
   or codigo_barras = '3014260279264'
   or (nombre ilike '%oral%b%stages%' and nombre ilike '%princesas%')
   or (nombre ilike '%oral%b%stages%' and nombre ilike '%disney%');

update public.productos set
  codigo_barras = '3014260278922',
  nombre = 'Oral-B Stages cepillo dental infantil 3+ Frozen',
  marca = 'Oral-B',
  presentacion = coalesce(nullif(btrim(presentacion), ''), '1 pieza'),
  forma_farmaceutica = coalesce(nullif(btrim(forma_farmaceutica), ''), 'Cepillo'),
  categoria = 'Cuidado personal',
  subcategoria = 'Bucal',
  laboratorio = coalesce(nullif(btrim(laboratorio), ''), 'P&G'),
  activo = true,
  updated_at = now()
where sku = 'FC-60278922'
   or codigo_barras = '3014260278922'
   or (nombre ilike '%oral%b%stages%' and nombre ilike '%frozen%');

-- Renglones vivos Farma Mayoreo: fuerza EAN de caja + nombre + lote Frozen
update public.recepcion_items i
set
  codigo_escaneado = case
    when i.nombre_snapshot ilike '%frozen%'
      or i.codigo_escaneado in ('3014260278922', '5226833520')
      or i.numero_lote in ('6037833520', '5226833520')
      then '3014260278922'
    when i.nombre_snapshot ilike '%oral%b%cepillo%s%'
      or i.nombre_snapshot ilike '%disney%'
      or i.nombre_snapshot ilike '%princesas%'
      or i.nombre_snapshot ilike '%pixar%'
      or i.codigo_escaneado = '3014260279264'
      or i.numero_lote = '6041833520'
      then '3014260279264'
    else i.codigo_escaneado
  end,
  nombre_snapshot = case
    when i.nombre_snapshot ilike '%frozen%'
      or i.codigo_escaneado in ('3014260278922', '5226833520')
      or i.numero_lote in ('6037833520', '5226833520')
      then 'Oral-B Stages cepillo dental infantil 3+ Frozen'
    when i.nombre_snapshot ilike '%oral%b%cepillo%'
      or i.nombre_snapshot ilike '%disney%'
      or i.nombre_snapshot ilike '%princesas%'
      or i.codigo_escaneado = '3014260279264'
      then 'Oral-B Stages cepillo dental infantil 3+ Disney/Pixar'
    else i.nombre_snapshot
  end,
  numero_lote = case
    when i.nombre_snapshot ilike '%frozen%'
      or i.codigo_escaneado in ('3014260278922', '5226833520')
      or i.numero_lote in ('6037833520', '5226833520')
      then '6037833520'
    when i.codigo_escaneado = '3014260279264'
      or i.numero_lote = '6041833520'
      then coalesce(nullif(btrim(i.numero_lote), ''), '6041833520')
    else i.numero_lote
  end,
  producto_id = coalesce(
    i.producto_id,
    public.fc_buscar_producto_escaneo(
      case
        when i.nombre_snapshot ilike '%frozen%'
          or i.codigo_escaneado in ('3014260278922', '5226833520')
          then '3014260278922'
        else '3014260279264'
      end
    )
  ),
  pendiente_alta = false,
  confirmado = false
from public.recepciones r
where i.recepcion_id = r.id
  and r.estado = 'borrador'
  and (
    i.codigo_escaneado in ('3014260279264', '3014260278922', '5226833520')
    or i.numero_lote in ('6041833520', '6037833520', '5226833520')
    or i.nombre_snapshot ilike '%oral%b%stages%'
    or i.nombre_snapshot ilike 'ORAL B CEPILLO%'
    or i.nombre_snapshot ilike '%oral-b stages%'
    or (
      coalesce(r.proveedor, '') ilike '%farma mayoreo%'
      and r.folio = '306277'
      and i.nombre_snapshot ilike '%oral%b%'
    )
  );

-- ---------------------------------------------------------------------------
-- 2) Suerox naranja-mango — EAN botella (por si el patch suelto no corrió)
-- ---------------------------------------------------------------------------
update public.productos set
  codigo_barras = '7501048607214',
  nombre = 'Suerox Vitamins naranja-mango 630 mL',
  descripcion = case
    when descripcion ilike '%7501048607214%' then descripcion
    else coalesce(nullif(btrim(descripcion), '') || ' · ', '')
      || 'EAN botella 7501048607214 · alias Farmalive 6502400721471'
  end,
  updated_at = now()
where sku = 'FC-00721471'
   or codigo_barras in ('6502400721471', '7501048607214');

update public.recepcion_items i
set
  codigo_escaneado = '7501048607214',
  nombre_snapshot = 'Suerox Vitamins naranja-mango 630 mL',
  producto_id = coalesce(
    i.producto_id,
    public.fc_buscar_producto_escaneo('7501048607214'),
    public.fc_buscar_producto_escaneo('FC-00721471')
  ),
  pendiente_alta = false
from public.recepciones r
where i.recepcion_id = r.id
  and r.estado = 'borrador'
  and (
    i.codigo_escaneado in ('6502400721471', '650240072147', '7501048607214')
    or i.nombre_snapshot ilike '%suerox%naranja%mango%'
  );

-- ---------------------------------------------------------------------------
-- 3) Pegar EAN reales en renglones IFC / borradores (Dibar + Venda-stick)
-- ---------------------------------------------------------------------------
update public.recepcion_items i
set
  codigo_escaneado = '7501868950207',
  nombre_snapshot = 'Dibar venda elástica 7.5 cm colores C/24',
  producto_id = coalesce(
    i.producto_id,
    public.fc_buscar_producto_escaneo('7501868950207'),
    public.fc_buscar_producto_escaneo('FC-IFC-83733')
  ),
  pendiente_alta = false,
  numero_lote = coalesce(nullif(btrim(i.numero_lote), ''), '5C025C02')
from public.recepciones r
where i.recepcion_id = r.id
  and r.estado = 'borrador'
  and (
    i.codigo_escaneado in ('7501868950207', 'FC-IFC-83733')
    or i.nombre_snapshot ilike '%dibar%venda%color%'
    or i.nombre_snapshot ilike '%venda%7.5%color%'
    or i.producto_id in (
      select p.id from public.productos p
      where p.sku in ('FC-IFC-83733', 'FC-68950207')
         or p.codigo_barras = '7501868950207'
    )
  );

update public.recepcion_items i
set
  codigo_escaneado = case
    when i.nombre_snapshot ilike '%piel%'
      or i.codigo_escaneado in ('7506484500157', 'FC-IFC-82912P')
      then '7506484500157'
    when i.nombre_snapshot ilike '%azul%'
      or i.codigo_escaneado in ('7506484500164', 'FC-IFC-82912A')
      then '7506484500164'
    when i.nombre_snapshot ilike '%rojo%'
      or i.codigo_escaneado in ('7506484500140', 'FC-IFC-83552')
      then case
        -- 83552 es 2"/5 cm; solo pisa EAN si el renglón ya era 7.5 / 3"
        when i.nombre_snapshot ilike '%3%pulg%' or i.nombre_snapshot ilike '%7.5%'
          then '7506484500140'
        else i.codigo_escaneado
      end
    else i.codigo_escaneado
  end,
  producto_id = coalesce(
    i.producto_id,
    public.fc_buscar_producto_escaneo('7506484500157'),
    public.fc_buscar_producto_escaneo('7506484500164'),
    public.fc_buscar_producto_escaneo('7506484500140')
  )
from public.recepciones r
where i.recepcion_id = r.id
  and r.estado = 'borrador'
  and (
    i.codigo_escaneado in (
      '7506484500140', '7506484500157', '7506484500164',
      'FC-IFC-82912P', 'FC-IFC-82912A'
    )
    or i.nombre_snapshot ilike '%venda%stick%'
    or i.nombre_snapshot ilike '%venda-stick%'
  );

-- Quirmex: fuerza EAN en renglones mal fichados
update public.recepcion_items i
set
  codigo_escaneado = '7503003406730',
  nombre_snapshot = 'Quirmex venda elástica premium 7.5 cm × 5 m',
  producto_id = coalesce(
    i.producto_id,
    public.fc_buscar_producto_escaneo('7503003406730'),
    public.fc_buscar_producto_escaneo('FC-34067301')
  )
from public.recepciones r
where i.recepcion_id = r.id
  and r.estado = 'borrador'
  and (
    i.codigo_escaneado in ('7503003406730', '75030034067301')
    or (i.nombre_snapshot ilike '%quirmex%venda%' and i.nombre_snapshot ilike '%7.5%')
    or i.producto_id in (
      select p.id from public.productos p where p.sku = 'FC-34067301'
    )
  );

-- ---------------------------------------------------------------------------
-- 4) Pedido vivo «Mostrador 25-sep» — Protec + Venda-stick + Dibar + Quirmex
--    (solo si los productos ya existen en catálogo)
-- ---------------------------------------------------------------------------
insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'Mostrador',
  'MOSTRADOR-20260925',
  '2026-09-25',
  null,
  'borrador',
  'Altas físicas 25-sep · Protec bandas + Venda-stick + Quirmex + Dibar colores · escanear EAN de caja'
where not exists (
  select 1 from public.recepciones
  where folio = 'MOSTRADOR-20260925'
    and coalesce(proveedor, '') ilike '%mostrador%'
);

-- Limpia renglones del borrador mostrador y reinserta (idempotente)
delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = 'MOSTRADOR-20260925'
  and coalesce(r.proveedor, '') ilike '%mostrador%'
  and r.estado = 'borrador';

insert into public.recepcion_items (
  recepcion_id, producto_id, codigo_escaneado, nombre_snapshot,
  cantidad, fecha_caducidad, numero_lote, costo_estimado, pendiente_alta,
  origen, confirmado, lote_distinto, lote_id
)
select
  r.id,
  p.id,
  v.ean,
  v.nombre,
  v.qty,
  v.cad::date,
  v.lote,
  v.costo,
  false,
  'csv',
  false,
  false,
  null
from public.recepciones r
cross join (values
  ('7501048640676', 'Protec bandas adhesivas tela elástica 22 mm', 1, '503500048', '2029-03-31', 41.67::numeric),
  ('7506484500140', 'Venda-stick auto-adherente 7.5 cm × 4.5 m rojo', 1, null, null, 45.00),
  ('7506484500157', 'Venda-stick auto-adherente 7.5 cm × 4.5 m piel', 1, null, null, 45.00),
  ('7506484500164', 'Venda-stick auto-adherente 7.5 cm × 4.5 m azul', 1, null, null, 47.50),
  ('7503003406730', 'Quirmex venda elástica premium 7.5 cm × 5 m', 1, null, null, 6.80),
  ('7501868950207', 'Dibar venda elástica 7.5 cm colores C/24', 1, '5C025C02', '2030-03-31', 318.00)
) as v(ean, nombre, qty, lote, cad, costo)
join lateral (
  select x.id
  from public.productos x
  where x.codigo_barras = v.ean
     or x.sku = case v.ean
       when '7501048640676' then 'FC-48640676'
       when '7506484500140' then 'FC-84500140'
       when '7506484500157' then 'FC-IFC-82912P'
       when '7506484500164' then 'FC-IFC-82912A'
       when '7503003406730' then 'FC-34067301'
       when '7501868950207' then 'FC-IFC-83733'
     end
  order by case when x.codigo_barras = v.ean then 0 else 1 end, x.id
  limit 1
) p on true
where r.folio = 'MOSTRADOR-20260925'
  and coalesce(r.proveedor, '') ilike '%mostrador%'
  and r.estado = 'borrador';

update public.recepciones set
  updated_at = now(),
  notas = 'Altas físicas 25-sep · Protec + Venda-stick + Quirmex + Dibar · escanear EAN de caja'
where folio = 'MOSTRADOR-20260925'
  and coalesce(proveedor, '') ilike '%mostrador%';

commit;

-- ---------------------------------------------------------------------------
-- Diagnóstico: qué hay vivo en Recibir
-- ---------------------------------------------------------------------------
select
  r.proveedor,
  r.folio,
  r.estado,
  count(i.*) as renglones,
  count(*) filter (where not coalesce(i.confirmado, false)) as sin_confirmar,
  count(*) filter (where i.codigo_escaneado in (
    '3014260279264', '3014260278922', '7501048607214',
    '7501048640676', '7506484500140', '7506484500157', '7506484500164',
    '7503003406730', '7501868950207'
  )) as renglones_clave
from public.recepciones r
left join public.recepcion_items i on i.recepcion_id = r.id
where r.estado in ('borrador', 'parcial', 'pendiente_alta', 'pendiente_caducidad')
group by r.id, r.proveedor, r.folio, r.estado
order by r.updated_at desc nulls last
limit 30;

select
  p.sku,
  p.codigo_barras as ean,
  left(p.nombre, 52) as nombre,
  p.activo
from public.productos p
where p.codigo_barras in (
    '3014260279264', '3014260278922', '7501048607214',
    '7501048640676', '7506484500140', '7506484500157', '7506484500164',
    '7503003406730', '7501868950207'
  )
   or p.sku in (
    'FC-60279264', 'FC-60278922', 'FC-00721471',
    'FC-48640676', 'FC-84500140', 'FC-IFC-82912P', 'FC-IFC-82912A',
    'FC-34067301', 'FC-IFC-83733'
  )
order by p.sku;
