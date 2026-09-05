-- Farmaceutica La Mejor · venta 84791 · 05-sep-2026
-- Central de Abastos · Selene Guadalupe OORS851113FF1 · TEL 5600-2019
-- Envío a domicilio: Yareth Figueroa · 5643304106
-- 4 renglones · total pagado $736.72
-- Costo = precio NETO (después del descuento del ticket).
-- El ticket no trae lote ni caducidad: Recibir captura MMAA de la caja.
-- 0000 es inválido. Stock al confirmar pistola.
--
-- 1 alta (Bocasan) · 3 ya estaban (Dualgos, ML-PRIM, Nediclon).
-- ML-PRIM: el ticket imprimió 5114210000000 (checksum inválido) → se usa
--   el EAN de caja 7502227426982.
-- Dualgos / Nediclon: el ticket trae EAN distinto al del catálogo; se
--   enlaza por SKU y se deja el EAN del ticket para la pistola.
-- SIN bloques dollar-quote (do $$). Idempotente mientras siga en borrador.
-- Pegar TODO este archivo en Supabase → SQL Editor → Run.

begin;

create temp table _fc_flm84791 (
  linea integer primary key,
  ean text not null,
  ean_alt text,
  sku text not null,
  nombre text not null,
  snap text not null,
  qty integer not null,
  costo numeric(12,2) not null,
  precio numeric(12,2) not null,
  tipo text not null,
  categoria text not null,
  marca text,
  presentacion text,
  principio_activo text,
  concentracion text,
  forma_farmaceutica text,
  subcategoria text,
  receta boolean not null,
  es_alta boolean not null
) on commit drop;

insert into _fc_flm84791 (
  linea, ean, ean_alt, sku, nombre, snap, qty, costo, precio,
  tipo, categoria, marca, presentacion, principio_activo, concentracion,
  forma_farmaceutica, subcategoria, receta, es_alta
) values
  (1, '7501417515949', null, 'FC-41751594',
   'Bocasan Premium enjuague bucal polvo menta 24 sobres 1.75 g',
   'BOCASAN POLVO C/24 SOBRES', 2, 127.30, 169,
   'marca', 'Cuidado personal', 'Bocasan', 'Caja con 24 sobres de 1.75 g + vaso dosificador',
   'Perborato de sodio / Bitartrato de sodio', '1.75 g',
   'Polvo', 'Higiene bucal', false, true),
  (2, '7501836003393', '7501836009661', 'FC-36009661',
   'Dualgos paracetamol/ibuprofeno 325/200 mg C/20',
   'DUALGOS PARACET/IBUPR C/20', 5, 39.01, 63,
   'marca', 'Analgésico', 'Liferpal MD', 'Caja con 20 tabletas',
   'Paracetamol / Ibuprofeno', '325 mg / 200 mg',
   'Tableta', null, false, false),
  (3, '7502227426982', null, 'FC-27427392',
   'ML-PRIM metocarbamol/ibuprofeno 375/200 mg C/12',
   'ML-PRIM C/12 CAPS', 5, 47.79, 76,
   'marca', 'Analgésico', 'ML-PRIM', 'Caja con 12 cápsulas',
   'Metocarbamol / Ibuprofeno', '375 mg / 200 mg',
   'Cápsula', 'Relajante muscular', true, false),
  (4, '7501537194178', '7501537102845', 'EQ-BRU053',
   'Nediclon diclofenaco 100 mg C/20',
   'NEDICLON T 100MG C20 VI', 3, 16.04, 26,
   'marca', 'Analgésico', 'Bruluart', 'Caja con 20 tabletas de liberación prolongada',
   'Diclofenaco sódico', '100 mg',
   'Tableta', null, true, false);

-- ── 1) Alta Bocasan (stock 0) + costo/ficha de los que ya estaban ──
insert into public.productos (
  nombre, sku, codigo_barras, categoria, tipo, descripcion,
  costo, precio, stock, stock_minimo, activo, requiere_receta,
  marca, presentacion, principio_activo, concentracion,
  forma_farmaceutica, subcategoria
)
select
  t.nombre,
  case
    when exists (
      select 1 from public.productos p
      where p.sku = t.sku and coalesce(p.codigo_barras, '') <> t.ean
        and coalesce(p.codigo_barras, '') is distinct from coalesce(t.ean_alt, '')
    ) then 'FC-FLM-' || right(t.ean, 8)
    else t.sku
  end,
  t.ean,
  t.categoria,
  t.tipo,
  'Alta Farmaceutica La Mejor 84791 · 2026-09-05 · listo para pistola',
  t.costo,
  t.precio,
  0,
  2,
  true,
  t.receta,
  t.marca,
  t.presentacion,
  t.principio_activo,
  t.concentracion,
  t.forma_farmaceutica,
  t.subcategoria
from _fc_flm84791 t
where t.es_alta
  and public.fc_buscar_producto_escaneo(t.ean) is null
  and public.fc_buscar_producto_escaneo(t.sku) is null;

update public.productos p
set
  costo = t.costo,
  precio = case
    when coalesce(p.precio, 0) <= 0 then t.precio
    when coalesce(p.precio, 0) < (t.costo * 1.25) then t.precio
    else p.precio
  end,
  marca = coalesce(nullif(p.marca, ''), t.marca),
  presentacion = coalesce(nullif(p.presentacion, ''), t.presentacion),
  principio_activo = coalesce(nullif(p.principio_activo, ''), t.principio_activo),
  concentracion = coalesce(nullif(p.concentracion, ''), t.concentracion),
  forma_farmaceutica = coalesce(nullif(p.forma_farmaceutica, ''), t.forma_farmaceutica),
  subcategoria = coalesce(nullif(p.subcategoria, ''), t.subcategoria),
  categoria = coalesce(nullif(p.categoria, ''), t.categoria),
  requiere_receta = t.receta
from _fc_flm84791 t
where p.id = coalesce(
  public.fc_buscar_producto_escaneo(t.ean),
  public.fc_buscar_producto_escaneo(t.ean_alt),
  public.fc_buscar_producto_escaneo(t.sku)
);

-- ── 2) Cola Recibir (borrador, sin sumar piezas) ──────────────────
insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'Farmaceutica La Mejor',
  '84791',
  '2026-09-05',
  736.72,
  'borrador',
  'Ticket Farmaceutica La Mejor 84791 · 05-09-2026 · envío Yareth Figueroa 5643304106 · Central de Abastos · cola Recibir; stock al confirmar pistola · MMAA de la caja'
where not exists (
  select 1 from public.recepciones
  where folio = '84791' and coalesce(proveedor, '') ilike '%la mejor%'
);

update public.recepciones
set
  total_ticket = 736.72,
  fecha = '2026-09-05',
  proveedor = 'Farmaceutica La Mejor',
  notas = 'Ticket Farmaceutica La Mejor 84791 · 05-09-2026 · envío Yareth Figueroa 5643304106 · Central de Abastos · cola Recibir; stock al confirmar pistola · MMAA de la caja'
where folio = '84791'
  and coalesce(proveedor, '') ilike '%la mejor%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = '84791'
  and coalesce(r.proveedor, '') ilike '%la mejor%'
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
from _fc_flm84791 t
join public.recepciones r
  on r.folio = '84791'
 and coalesce(r.proveedor, '') ilike '%la mejor%'
 and r.estado = 'borrador'
left join lateral (
  select coalesce(
    public.fc_buscar_producto_escaneo(t.ean),
    public.fc_buscar_producto_escaneo(t.ean_alt),
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
  case when i.pendiente_alta then 'ALTA NUEVA' else 'YA EXISTE' end as estado
from public.recepcion_items i
join public.recepciones r on r.id = i.recepcion_id
where r.folio = '84791' and coalesce(r.proveedor, '') ilike '%la mejor%'
order by i.id;
