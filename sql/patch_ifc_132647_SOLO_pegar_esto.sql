-- =============================================================================
-- PEGAR TODO ESTE ARCHIVO en Supabase → SQL Editor → Run
-- IFC F8 Tienda folio 132647 · 07-nov-2026 · $215.50 · 2 renglones / 11 pzas
-- Merge a GitHub NO crea la tarjeta. Este Run sí.
-- Sin bloques dollar-quote. Sin galería extra. Idempotente en borrador.
-- Al final: VERIFICACION con folio 132647 en borrador.
-- Luego: tablet Recibir → recargar → tarjeta IFC F8 · 132647.
-- =============================================================================

-- IFC F8 Tienda · ticket 132647 · 2026-11-07 14:27 · cliente LUIS · MENUDEO · Total $215.50 · 2 renglones / 11 pzas. P.PUBLICO = costo. EANs canónicos (no código IFC del papel). Sin lote. Caducidad NO: MMAA de la caja.
-- 0 alta(s) stock 0. 2 ya estaban: solo costo / ficha vacía, no PVP.
-- Nombres de ficha, no del ticket. Fotos en public/catalogo-propia/ (tras deploy).
-- SIN bloques dollar-quote. Idempotente mientras el ticket siga en borrador.
-- Pegar TODO este archivo en Supabase → SQL Editor → Run.

begin;

create temp table _fc_ifc_132647 (
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

insert into _fc_ifc_132647 (
  linea, ean, sku, nombre, snap, qty, costo, precio, tipo, categoria,
  subcategoria, forma, marca, laboratorio, presentacion, principio_activo,
  concentracion, receta, ya, imagen, foto_file, lote
) values
  (1, '3311000001292', 'FC-00001292', 'Aceite de ricino Mercurio', 'MERCURIO ACEITE RICINO C/25 1120627 84529', 8, 9.50, 12, 'marca', 'Cuidado personal', null, 'Aceite', 'Mercurio', 'Mercurio', 'Frasco (pieza de C/25)', 'Aceite de ricino', null, false, true, null, null, null),
  (2, '7501048640829', 'FC-46640629', 'Venda de yeso Protec 20 cm', 'PROTEC VENDA YESO 20CM C/12 14036300025 84129', 3, 46.50, 59, 'marca', 'Botiquín', 'Material de curación', 'Venda', 'Protec', 'Degasa', '1 pieza 20 cm × 2.75 m (caja C/12)', null, null, false, true, null, null, null);

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
  'Alta IFC F8 Tienda 132647 · 2026-11-07 · listo para pistola',
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
  from _fc_ifc_132647
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
  from _fc_ifc_132647
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
  from _fc_ifc_132647
  order by ean, linea
) t
where p.id = coalesce(
  public.fc_buscar_producto_escaneo(t.ean),
  public.fc_buscar_producto_escaneo(t.sku)
);

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'IFC F8 Tienda',
  '132647',
  '2026-11-07',
  215.50,
  'borrador',
  'Ticket IFC F8 folio 132647 · CJ 01 · cliente LUIS · 07-nov-2026 14:27 · 11 pzas · $215.50 · MENUDEO · MMAA de la caja · cola Recibir'
where not exists (
  select 1 from public.recepciones
  where folio = '132647'
    and coalesce(proveedor, '') ilike '%ifc%'
);

update public.recepciones
set
  total_ticket = 215.50,
  fecha = '2026-11-07',
  proveedor = 'IFC F8 Tienda',
  notas = 'Ticket IFC F8 folio 132647 · CJ 01 · cliente LUIS · 07-nov-2026 14:27 · 11 pzas · $215.50 · MENUDEO · MMAA de la caja · cola Recibir',
  updated_at = now()
where folio = '132647'
  and coalesce(proveedor, '') ilike '%ifc%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = '132647'
  and coalesce(r.proveedor, '') ilike '%ifc%'
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
from _fc_ifc_132647 t
join public.recepciones r
  on r.folio = '132647'
 and coalesce(r.proveedor, '') ilike '%ifc%'
 and r.estado = 'borrador'
left join lateral (
  select coalesce(
    public.fc_buscar_producto_escaneo(t.ean),
    public.fc_buscar_producto_escaneo(t.sku)
  ) as pid
) v on true
order by t.linea;

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
where r.folio = '132647'
  and coalesce(r.proveedor, '') ilike '%ifc%'
group by r.id, r.folio, r.proveedor, r.estado, r.total_ticket;

select
  t.linea,
  t.ean,
  t.nombre,
  t.qty,
  t.costo,
  case when public.fc_buscar_producto_escaneo(t.ean) is null then 'PENDIENTE_ALTA' else 'OK' end as match,
  t.ya as marcado_ya
from _fc_ifc_132647 t
order by t.linea;

commit;

-- VERIFICACION
select
  r.proveedor,
  r.folio,
  r.estado,
  r.total_ticket,
  count(i.*) as renglones,
  coalesce(sum(i.cantidad), 0) as piezas,
  count(*) filter (where not coalesce(i.confirmado, false)) as sin_confirmar
from public.recepciones r
left join public.recepcion_items i on i.recepcion_id = r.id
where r.folio = '132647'
  and coalesce(r.proveedor, '') ilike '%ifc%'
group by r.id, r.proveedor, r.folio, r.estado, r.total_ticket;
