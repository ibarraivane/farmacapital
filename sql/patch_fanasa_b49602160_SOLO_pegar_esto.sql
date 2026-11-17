-- ============================================================================
-- Ticket Fanasa B49602160 → cola Recibir (borrador)
--
-- Factura 17-nov-2026 · FARMACAPITAL LA CAPI · $1,049.42 · 2 pzas
-- 1) EAN 7501293201936 · Histofil 4000 UI · Medix · costo $325.90 (tasa 0%)
-- 2) EAN 7502235760177 · Turnover Íntimo 30 ml · Exeltis · costo $623.72 (+ IVA 16%)
-- PVP sugerido marca +25% sobre costo farmacia. Stock 0 hasta pistola + MMAA.
-- SIN bloques dollar-quote. Idempotente mientras el ticket siga en borrador.
-- Pegar TODO en Supabase → SQL Editor → Run.
-- Fotos (tras deploy): catalogo-propia/histofil-4000-ui-60-tab.jpg
--                      catalogo-propia/turnover-intimo-30ml.jpg
-- ============================================================================

begin;

create temp table _fc_tk_fanasa_b49602160 (
  ticket text not null,
  linea integer not null,
  ean text,
  sku text,
  nombre text not null,
  snap text not null,
  qty integer not null,
  costo numeric(12,2) not null,
  precio numeric(12,2),
  tipo text,
  categoria text,
  subcategoria text,
  forma text,
  marca text,
  laboratorio text,
  presentacion text,
  principio_activo text,
  concentracion text,
  receta boolean,
  es_alta boolean not null default false,
  imagen text,
  primary key (ticket, linea)
) on commit drop;

insert into _fc_tk_fanasa_b49602160 (
  ticket, linea, ean, sku, nombre, snap, qty, costo, precio, tipo, categoria,
  subcategoria, forma, marca, laboratorio, presentacion, principio_activo,
  concentracion, receta, es_alta, imagen
) values
('fanasa', 1, '7501293201936', 'FC-93201936',
 'Histofil 4000 UI',
 '51180400 HISTOFIL COLECALCIFEROL 4000 UI 60 TAB | MED',
 1, 325.90, 408, 'marca', 'Medicamentos', 'Vitaminas', 'Tableta dispersable',
 'Histofil', 'Productos Medix', 'Caja con frasco con 60 tabletas',
 'Colecalciferol', '4000 UI', false, true,
 'https://www.farmacapital.mx/catalogo-propia/histofil-4000-ui-60-tab.jpg'),
('fanasa', 2, '7502235760177', 'FC-35760177',
 'Turnover Íntimo',
 '51241200 TURNOVER INTIMO CON 6 APLICADORES DESEC 1 CRE 30 ml | EXT',
 1, 623.72, 780, 'marca', 'Cuidado personal', 'Salud íntima', 'Crema vaginal',
 'Turnover', 'Exeltis', 'Tubo 30 ml con 6 aplicadores desechables de 5 ml',
 'Polinucleótidos', '0.2%', false, true,
 'https://www.farmacapital.mx/catalogo-propia/turnover-intimo-30ml.jpg');

-- ═══════════════════════════════════════════════════════════
-- Alta (solo si aún no existe)
-- ═══════════════════════════════════════════════════════════
insert into public.productos (
  nombre, sku, codigo_barras, categoria, subcategoria, tipo, descripcion,
  costo, precio, stock, stock_minimo, activo, requiere_receta,
  marca, presentacion, forma_farmaceutica, principio_activo, concentracion,
  laboratorio, imagen_url, imagen_mobile_url
)
select
  t.nombre,
  case
    when t.sku is not null and exists (
      select 1 from public.productos p
      where p.sku = t.sku and coalesce(p.codigo_barras, '') is distinct from coalesce(t.ean, '')
    ) then 'FC-ND-' || right(coalesce(t.ean, t.sku), 8)
    when t.sku is not null then t.sku
    else 'FC-' || right(t.ean, 8)
  end,
  t.ean,
  coalesce(t.categoria, 'Medicamentos'),
  t.subcategoria,
  coalesce(t.tipo, 'generico'),
  'Alta ticket Fanasa B49602160 · 17-nov-2026 · listo para pistola',
  case when t.costo >= 1 then t.costo else null end,
  coalesce(
    t.precio,
    case
      when t.costo >= 1 then ceil(t.costo * case when t.tipo = 'marca' then 1.25 else 1.60 end)
      else null
    end
  ),
  0, 1, true, coalesce(t.receta, false),
  t.marca, t.presentacion, t.forma, t.principio_activo, t.concentracion, t.laboratorio,
  t.imagen, t.imagen
from (
  select distinct on (coalesce(ean, sku)) *
  from _fc_tk_fanasa_b49602160
  where es_alta
  order by coalesce(ean, sku), linea
) t
where (t.ean is null or public.fc_buscar_producto_escaneo(t.ean) is null)
  and (t.sku is null or public.fc_buscar_producto_escaneo(t.sku) is null)
  and not exists (
    select 1 from public.productos p
    where (t.ean is not null and p.codigo_barras = t.ean)
       or (t.sku is not null and p.sku = t.sku)
  );

-- Costo de ticket en ficha ya existente (no baja PVP bueno).
update public.productos p
set
  costo = t.costo,
  precio = case
    when coalesce(p.precio, 0) <= 1 and t.precio is not null then t.precio
    when coalesce(p.precio, 0) <= 1 then ceil(t.costo * case when coalesce(t.tipo,'generico') = 'marca' then 1.25 else 1.60 end)
    else p.precio
  end,
  codigo_barras = coalesce(nullif(btrim(p.codigo_barras), ''), t.ean)
from (
  select distinct on (coalesce(ean, sku)) *
  from _fc_tk_fanasa_b49602160
  where costo >= 1
  order by coalesce(ean, sku), linea
) t
where p.id = coalesce(
  case when t.ean is not null then public.fc_buscar_producto_escaneo(t.ean) end,
  case when t.sku is not null then public.fc_buscar_producto_escaneo(t.sku) end
);

-- Ficha vacía / foto si falta. No pisa una foto que ya esté.
update public.productos p
set
  nombre = case
    when length(trim(coalesce(p.nombre, ''))) < 8
      or upper(trim(coalesce(p.nombre, ''))) like 'HISTOFIL COLECALCIFEROL%'
      or upper(trim(coalesce(p.nombre, ''))) like 'TURNOVER INTIMO CON%'
      then t.nombre
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
  select distinct on (coalesce(ean, sku)) *
  from _fc_tk_fanasa_b49602160
  order by coalesce(ean, sku), linea
) t
where p.id = coalesce(
  case when t.ean is not null then public.fc_buscar_producto_escaneo(t.ean) end,
  case when t.sku is not null then public.fc_buscar_producto_escaneo(t.sku) end
);

-- ═══════════════════════════════════════════════════════════
-- Recepción Fanasa B49602160
-- ═══════════════════════════════════════════════════════════
insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'Fanasa',
  'B49602160',
  '2026-11-17',
  1049.42,
  'borrador',
  'Factura Fanasa B49602160 · 17-nov-2026 · pedido 57257271 · Histofil 4000 UI + Turnover Íntimo ×1 c/u · $1,049.42 · cola Recibir; stock al confirmar pistola + MMAA'
where not exists (
  select 1 from public.recepciones
  where folio = 'B49602160'
    and coalesce(proveedor, '') ilike '%fanasa%'
);

update public.recepciones
set
  total_ticket = 1049.42,
  fecha = '2026-11-17',
  proveedor = 'Fanasa',
  notas = 'Factura Fanasa B49602160 · 17-nov-2026 · pedido 57257271 · Histofil 4000 UI + Turnover Íntimo ×1 c/u · $1,049.42 · cola Recibir; stock al confirmar pistola + MMAA',
  updated_at = now()
where folio = 'B49602160'
  and coalesce(proveedor, '') ilike '%fanasa%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = 'B49602160'
  and coalesce(r.proveedor, '') ilike '%fanasa%'
  and r.estado = 'borrador';

insert into public.recepcion_items (
  recepcion_id, producto_id, codigo_escaneado, nombre_snapshot,
  cantidad, fecha_caducidad, numero_lote, costo_estimado, pendiente_alta,
  origen, confirmado, lote_distinto, lote_id
)
select
  r.id,
  v.pid,
  nullif(btrim(t.ean), ''),
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
from _fc_tk_fanasa_b49602160 t
join public.recepciones r
  on r.folio = 'B49602160'
 and coalesce(r.proveedor, '') ilike '%fanasa%'
 and r.estado = 'borrador'
left join lateral (
  select coalesce(
    case when nullif(btrim(t.ean), '') is not null
      then public.fc_buscar_producto_escaneo(nullif(btrim(t.ean), '')) end,
    case when nullif(btrim(t.sku), '') is not null
      then public.fc_buscar_producto_escaneo(nullif(btrim(t.sku), '')) end
  ) as pid
) v on true
where t.ticket = 'fanasa'
order by t.linea;

commit;

-- VERIFICACION
select
  r.proveedor,
  r.folio,
  r.estado,
  r.total_ticket,
  count(i.*) as renglones,
  count(*) filter (where i.pendiente_alta) as sin_alta,
  count(*) filter (where not coalesce(i.confirmado, false)) as sin_confirmar
from public.recepciones r
left join public.recepcion_items i on i.recepcion_id = r.id
where r.folio = 'B49602160'
  and coalesce(r.proveedor, '') ilike '%fanasa%'
group by r.id, r.proveedor, r.folio, r.estado, r.total_ticket;

select
  r.folio,
  i.codigo_escaneado as ean,
  left(i.nombre_snapshot, 70) as nombre,
  i.cantidad,
  i.costo_estimado,
  i.pendiente_alta,
  i.producto_id,
  p.nombre as ficha,
  p.sku,
  p.precio
from public.recepcion_items i
join public.recepciones r on r.id = i.recepcion_id
left join public.productos p on p.id = i.producto_id
where r.folio = 'B49602160'
  and r.estado = 'borrador'
  and coalesce(r.proveedor, '') ilike '%fanasa%'
order by i.id;
