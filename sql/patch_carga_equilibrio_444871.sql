-- Equilibrio · ticket 444871 · 2026-09-18 12:33 · pedido online
-- Cliente 307513 LUIS ANGEL PALILLERO VENTURA · Sucursal Iztapalapa 2 · Pasillo EF Loc E-43.
-- Total $220.94 · IVA $0.00 · 2 renglones · 12 piezas.
-- Costo = P.U. (el descuento del papel ya está aplicado). No uses el precio de lista.
--   EXA045 lista $235.70 menos 79.14% = $49.17
--   WER040 lista $337.79 menos 96.37% = $12.26
-- Lote de fábrica sí. Caducidad NO: Recibir pide el MMAA de la caja. No pongas 0000.
--   EXA045 lote 26087P (el papel dice 04/03/2028)
--   WER040 lote 251351 (el papel dice 01/12/2027)
-- Fichas, no el código del térmico:
--   EXA045 = neomicina 3.5 mg + polimixina B 5000 U + bacitracina 400 U / g,
--     ungüento oftálmico tubo 3.5 g. Equilibrio lo vende como Exakta.
--     Sufarmed trae el mismo código de barras 75050764 como Opko (registro 257M2006).
--   WER040 = Punab losartán potásico 50 mg C/30, Wermar, EAN 7502240450070
--     (Sufarmed, registro 008M2008). No es Cozaar ni Alderan.
-- Los dos ya están en catálogo (EQ-EXA045 y EQ-WER040). Este SQL no duplica.
-- PVP solo si el actual es 0: ungüento genérico +60% → $79; Punab marca +25% → $16.
-- TODO foto: no pisa imagen_url. Si el tubo o la caja no tienen packshot, no uses logo de otra farmacia.
-- SIN bloques dollar-quote. Idempotente mientras el ticket siga en borrador.
-- Pegar TODO este archivo en Supabase → SQL Editor → Run.

begin;

create temp table _fc_eq_444871 (
  linea integer primary key,
  ean text,
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
  lote text
) on commit drop;

insert into _fc_eq_444871 (
  linea, ean, sku, nombre, snap, qty, costo, precio, tipo, categoria, subcategoria, forma, marca, laboratorio, presentacion, principio_activo, concentracion, receta, lote
) values
  (1, '75050764', 'EQ-EXA045', 'Neomicina/polimixina B/bacitracina ungüento oftálmico 3.5 g Exakta', 'EXA045 NEOMICINA POLIMIXINA-B BACITRACINA UNG', 2, 49.17, 79, 'generico', 'Antibiótico', 'Oftálmico', 'Ungüento', 'Exakta', 'Opko', 'Tubo 3.5 g', 'Neomicina + polimixina B + bacitracina', '3.5 mg / 5000 U / 400 U por g', true, '26087P'),
  (2, '7502240450070', 'EQ-WER040', 'Punab losartán 50 mg C/30 Wermar', 'WER040 PUNAB 30 TAB 50 MG', 10, 12.26, 16, 'marca', 'Medicamentos', 'Cardiovascular', 'Tableta', 'Punab', 'Wermar', 'Caja con 30 tabletas', 'Losartán potásico', '50 mg', true, '251351');

-- Engancha el EAN al SKU que ya existe, sin pisar un código distinto.
update public.productos p
set codigo_barras = t.ean
from _fc_eq_444871 t
where p.sku = t.sku
  and coalesce(btrim(p.codigo_barras), '') = ''
  and not exists (
    select 1 from public.productos o
    where public.fc_match_codigo_barras(t.ean, o.codigo_barras)
      and o.id <> p.id
  );

insert into public.productos (
  nombre, sku, codigo_barras, categoria, subcategoria, tipo, descripcion,
  costo, precio, stock, stock_minimo, activo, requiere_receta,
  marca, presentacion, forma_farmaceutica, principio_activo, concentracion,
  laboratorio
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
  'Alta Equilibrio 444871 · 2026-09-18 · TODO foto · listo para pistola',
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
  t.laboratorio
from _fc_eq_444871 t
where public.fc_buscar_producto_escaneo(t.ean) is null
  and public.fc_buscar_producto_escaneo(t.sku) is null;

update public.productos p
set
  costo = t.costo,
  precio = case
    when coalesce(p.precio, 0) <= 0 then t.precio
    else p.precio
  end
from _fc_eq_444871 t
where p.id = coalesce(
    public.fc_buscar_producto_escaneo(t.ean),
    public.fc_buscar_producto_escaneo(t.sku)
  )
  and (
    p.costo is distinct from t.costo
    or coalesce(p.precio, 0) <= 0
  );

update public.productos p
set
  nombre = case
    when p.nombre ilike '%NEOMICINA POLIMIXINA%'
      or p.nombre ilike '%PUNAB 30 TAB%'
      or length(trim(coalesce(p.nombre, ''))) < 8
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
  categoria = case
    when coalesce(btrim(p.categoria), '') in ('', 'Otro', 'General') then t.categoria
    else p.categoria
  end
from _fc_eq_444871 t
where p.id = coalesce(
    public.fc_buscar_producto_escaneo(t.ean),
    public.fc_buscar_producto_escaneo(t.sku)
  );

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'Equilibrio',
  '444871',
  '2026-09-18',
  220.94,
  'borrador',
  'Ticket Equilibrio 444871 · Iztapalapa 2 · 18-sep-2026 12:33 · pedido online · cliente 307513 · cola Recibir; stock al confirmar pistola'
where not exists (
  select 1 from public.recepciones
  where folio = '444871'
    and coalesce(proveedor, '') ilike '%equilibrio%'
);

update public.recepciones
set
  total_ticket = 220.94,
  fecha = '2026-09-18',
  proveedor = 'Equilibrio',
  notas = 'Ticket Equilibrio 444871 · Iztapalapa 2 · 18-sep-2026 12:33 · pedido online · cliente 307513 · cola Recibir; stock al confirmar pistola',
  updated_at = now()
where folio = '444871'
  and coalesce(proveedor, '') ilike '%equilibrio%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = '444871'
  and coalesce(r.proveedor, '') ilike '%equilibrio%'
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
from _fc_eq_444871 t
join public.recepciones r
  on r.folio = '444871'
 and coalesce(r.proveedor, '') ilike '%equilibrio%'
 and r.estado = 'borrador'
left join lateral (
  select coalesce(
    public.fc_buscar_producto_escaneo(t.ean),
    public.fc_buscar_producto_escaneo(t.sku)
  ) as pid
) v on true
order by t.linea;

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
where r.folio = '444871'
  and coalesce(r.proveedor, '') ilike '%equilibrio%'
group by r.id, r.folio, r.proveedor, r.estado, r.total_ticket;

commit;
