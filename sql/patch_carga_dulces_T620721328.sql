-- Mayorista de Dulces Iztapalapa · nota T620721328 · 2026-10-02 16:41
-- HS Comercial (www.hscomercial.com.mx). Total tarjeta $335.20.
-- Chupa Chups Mini 6/240: 1 bolsa → 240 pzas mostrador · EAN 076350614570.
-- Vero Mix Clásico 6/1.5kg: 1 bolsa 1.5 kg · sin EAN en papel (no inventar).
-- Sin lote ni caducidad. No inventar 0000.
-- 2 alta(s) stock 0. 0 ya estaban.
-- Nombres de ficha, no del ticket. Vero Mix sin EAN hasta escanear la bolsa.
-- SIN bloques dollar-quote. Idempotente mientras el ticket siga en borrador.
-- Pegar TODO este archivo en Supabase → SQL Editor → Run.

begin;

create temp table _fc_dulces_t620721328 (
  linea integer primary key,
  ean text,
  sku text not null,
  nombre text not null,
  snap text not null,
  qty integer not null,
  costo numeric(12,4) not null,
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

insert into _fc_dulces_t620721328 (
  linea, ean, sku, nombre, snap, qty, costo, precio, tipo, categoria,
  subcategoria, forma, marca, laboratorio, presentacion, principio_activo,
  concentracion, receta, ya, imagen, foto_file, lote
) values
  (1, '076350614570', 'FC-50614570', 'Chupa Chups Mini paleta', 'ch.MINI paleta Chupa Chups 6/240pzs', 240, 0.7779, 2, 'marca', 'Impulso', null, 'Paleta', 'Chupa Chups', 'Perfetti', 'Bolsa 240 piezas', null, null, false, false, null, null, null),
  (2, null, 'FC-HS-VEROMIX15', 'Vero Mix Clásico surtido', 'vero MIX Clasico 6/1.5kg', 1, 148.5000, 186, 'marca', 'Impulso', null, 'Surtido', 'Vero', 'Vero', 'Bolsa 1.5 kg', null, null, false, false, null, null, null);

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
      where p.sku = t.sku
        and coalesce(p.codigo_barras, '') <> coalesce(t.ean, '')
    ) then 'FC-ND-' || right(coalesce(nullif(t.ean, ''), t.sku), 8)
    else t.sku
  end,
  nullif(t.ean, ''),
  t.categoria,
  t.subcategoria,
  t.tipo,
  'Alta Mayorista de Dulces T620721328 · 2026-10-02 · listo para pistola',
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
  select distinct on (sku) *
  from _fc_dulces_t620721328
  order by sku, linea
) t
where public.fc_buscar_producto_escaneo(t.sku) is null
  and (
    nullif(t.ean, '') is null
    or public.fc_buscar_producto_escaneo(t.ean) is null
  );

update public.productos p
set
  costo = t.costo,
  precio = case
    when coalesce(p.precio, 0) <= 0 then t.precio
    else p.precio
  end
from (
  select distinct on (sku) *
  from _fc_dulces_t620721328
  order by sku, linea
) t
where p.id = coalesce(
  case when nullif(t.ean, '') is not null
    then public.fc_buscar_producto_escaneo(t.ean) end,
  public.fc_buscar_producto_escaneo(t.sku)
)
  and (
    p.costo is distinct from t.costo
    or coalesce(p.precio, 0) <= 0
  );

update public.productos p
set
  nombre = case
    when length(trim(coalesce(p.nombre, ''))) < 8 then t.nombre
    else p.nombre
  end,
  marca = coalesce(nullif(trim(p.marca), ''), t.marca),
  presentacion = coalesce(nullif(trim(p.presentacion), ''), t.presentacion),
  forma_farmaceutica = coalesce(nullif(trim(p.forma_farmaceutica), ''), t.forma),
  laboratorio = coalesce(nullif(trim(p.laboratorio), ''), t.laboratorio),
  codigo_barras = coalesce(nullif(trim(p.codigo_barras), ''), nullif(t.ean, ''))
from (
  select distinct on (sku) *
  from _fc_dulces_t620721328
  order by sku, linea
) t
where p.id = coalesce(
  case when nullif(t.ean, '') is not null
    then public.fc_buscar_producto_escaneo(t.ean) end,
  public.fc_buscar_producto_escaneo(t.sku)
);

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'Mayorista de Dulces',
  'T620721328',
  '2026-10-02',
  335.20,
  'borrador',
  'Nota Mayorista de Dulces T620721328 · SUC Iztapalapa II · HS Comercial · 02-oct-2026 · Chupa Chups Mini 240 pzas + Vero Mix 1.5 kg · cola Recibir; stock al confirmar pistola'
where not exists (
  select 1 from public.recepciones
  where folio = 'T620721328'
    and coalesce(proveedor, '') ilike '%dulces%'
);

update public.recepciones
set
  total_ticket = 335.20,
  fecha = '2026-10-02',
  proveedor = 'Mayorista de Dulces',
  notas = 'Nota Mayorista de Dulces T620721328 · SUC Iztapalapa II · HS Comercial · 02-oct-2026 · Chupa Chups Mini 240 pzas + Vero Mix 1.5 kg · cola Recibir; stock al confirmar pistola',
  updated_at = now()
where folio = 'T620721328'
  and coalesce(proveedor, '') ilike '%dulces%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = 'T620721328'
  and coalesce(r.proveedor, '') ilike '%dulces%'
  and r.estado = 'borrador';

insert into public.recepcion_items (
  recepcion_id, producto_id, codigo_escaneado, nombre_snapshot,
  cantidad, fecha_caducidad, numero_lote, costo_estimado, pendiente_alta,
  origen, confirmado, lote_distinto, lote_id
)
select
  r.id,
  v.pid,
  nullif(t.ean, ''),
  t.nombre,
  t.qty,
  null,
  null,
  t.costo,
  (v.pid is null),
  'pdf',
  false,
  false,
  null
from _fc_dulces_t620721328 t
join public.recepciones r
  on r.folio = 'T620721328'
 and coalesce(r.proveedor, '') ilike '%dulces%'
 and r.estado = 'borrador'
left join lateral (
  select coalesce(
    case when nullif(t.ean, '') is not null
      then public.fc_buscar_producto_escaneo(t.ean) end,
    public.fc_buscar_producto_escaneo(t.sku)
  ) as pid
) v on true
order by t.linea;

select
  r.folio, r.proveedor, r.estado, r.total_ticket,
  count(i.*) as renglones, sum(i.cantidad) as piezas
from public.recepciones r
left join public.recepcion_items i on i.recepcion_id = r.id
where r.folio = 'T620721328'
  and coalesce(r.proveedor, '') ilike '%dulces%'
group by r.id, r.folio, r.proveedor, r.estado, r.total_ticket;

commit;
