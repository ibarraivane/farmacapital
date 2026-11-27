-- Farmalive Club Iztapalapa 1 · ticket 12949 · 18-sep-2026 11:08
-- Cliente 10000516 FARMACAPITAL · atendió Cesia Noemi Serrano Lopez.
-- Subtotal $1,839.40 − descuento $109.31 = $1,730.09 tarjeta.
-- 13 renglones / 40 piezas. Costo = P.U. ya con descuento.
-- El papel no trae lote. No inventar MMAA ni 0000.
-- Pañal Diapro predoblado 7501943474895 no es el Diapro Med 7501943474994.
-- Ampigrin PFC cápsulas 780083148676 no es el jarabe 780083148577.
-- Rosel sol ped 30 ml 7502240451015 no es el Rosel 60 ml 7502240450230.
-- Los P.U. redondean 1 centavo en Rosel sol, Vylkor, Rosel caps y Saba;
-- el total del ticket se queda en $1,730.09.
-- 7 alta(s) con stock 0 si el EAN no está. El resto solo costo (PVP si estaba en 0).
-- TODO foto: las altas nuevas no traen packshot en este SQL. No usar placeholder de otra cadena.
-- SIN bloques dollar-quote. Idempotente mientras el ticket siga en borrador.
-- Pegar TODO este archivo en Supabase → SQL Editor → Run.

begin;

create temp table _fc_fl_12949 (
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
  ya boolean not null
) on commit drop;

insert into _fc_fl_12949 (
  linea, ean, sku, nombre, snap, qty, costo, precio, tipo, categoria, subcategoria, forma, marca, laboratorio, presentacion, principio_activo, concentracion, receta, ya
) values

  (1, '7502234762417', 'FC-47624171', 'Nailex desenterrador de uñas 12 ml', 'NAILEX DESENTERRADOR UÑAS 12 ML | LAB PISA', 2, 54.49, 69, 'marca', 'Cuidado personal', 'Uñas', 'Solución', 'Nailex', 'Pisa', 'Frasco 12 ml', null, null, false, true),
  (2, '7501943474895', 'FC-43474895', 'Pañal Diapro predoblado C/10', 'PAÑAL DIAPRO PREDOBLADO C/10 | KIMBERLY CLARK', 2, 76.93, 97, 'marca', 'Higiene', 'Pañales', 'Pañal', 'Diapro', 'Kimberly Clark', 'Bolsa con 10 pañales predoblados', null, null, false, false),
  (3, '7501095452178', 'FC-95452178', 'Tempra infantil paracetamol 80 mg C/30', 'TEMPRA INF 80 MG TAB C/30 | RB HEALTH', 2, 97.41, 122, 'marca', 'Analgésico', 'Infantil', 'Tableta', 'Tempra', 'RB Health', 'Caja con 30 tabletas', 'Paracetamol', '80 mg', false, false),
  (4, '7502240451015', 'FC-40451015', 'Rosel solución pediátrica 30 ml', 'ROSEL SOL PED 30 ML | WERMAR', 2, 26.51, 34, 'marca', 'Respiratorio', 'Infantil', 'Solución', 'Rosel', 'Wermar', 'Frasco 30 ml', 'Amantadina + clorfenamina + paracetamol', null, false, false),
  (5, '7503003738879', 'FC-03738879', 'Rosel-T tabletas C/15', 'ROSEL-T TAB C/15 | WERMAR', 4, 19.81, 25, 'marca', 'Respiratorio', null, 'Tableta', 'Rosel-T', 'Wermar', 'Caja con 15 tabletas', 'Amantadina + clorfenamina + paracetamol', null, false, true),
  (6, '7501537164713', 'FC-37164713', 'Tribedoce Compuesto grageas C/30', 'IV TRIBEDOCE COMPUESTO GRA C/30 | BRULUART', 4, 40.48, 51, 'marca', 'Vitaminas', null, 'Gragea', 'Tribedoce', 'Bruluart', 'Caja con 30 grageas', 'Complejo B + diclofenaco', null, false, true),
  (7, '780083148676', 'FC-83148676', 'Ampigrin PFC cápsulas C/24', 'AMPIGRIN PFC CAPS C/24 | COLLINS', 2, 28.83, 37, 'marca', 'Respiratorio', null, 'Cápsula', 'Ampigrin', 'Collins', 'Caja con 24 cápsulas', 'Amantadina + clorfenamina + paracetamol', null, false, false),
  (8, '650240072925', 'FC-40072925', 'Lakesia solución 3 ml', 'LAKESIA SOLUCION 3 ML | GENOMMA LAB', 2, 149.55, 187, 'marca', 'Cuidado personal', 'Uñas', 'Solución', 'Lakesia', 'Genomma Lab', 'Frasco 3 ml', null, null, false, false),
  (9, '7502227870716', 'FC-27870716', 'Vylkor ondansetrón 8 mg C/10', 'VYLKOR 8 MG TAB C/10 | RAAM', 3, 55.53, 70, 'marca', 'Gastro', 'Antiemético', 'Tableta', 'Vylkor', 'Raam', 'Caja con 10 tabletas', 'Ondansetrón', '8 mg', true, false),
  (10, '7503003738404', 'EQ-WER025', 'Rosel cápsulas C/24', 'ROSEL CAPS C/24 | WERMAR', 3, 25.58, 32, 'marca', 'Respiratorio', null, 'Cápsula', 'Rosel', 'Wermar', 'Caja con 24 cápsulas', 'Amantadina + clorfenamina + paracetamol', null, false, true),
  (11, '7502240450902', 'FC-40450902', 'Wernicros oseltamivir 75 mg C/10', 'WERNICROS 75 MG C/10 CAP | WERMAR', 2, 116.25, 146, 'marca', 'Antiviral', null, 'Cápsula', 'Wernicros', 'Wermar', 'Caja con 10 cápsulas', 'Oseltamivir', '75 mg', true, false),
  (12, '7502208891549', 'FC-88915491', 'Tarmin 2 mg tabletas C/12', 'TARMIN 2 MG C/12 TAB | BRULUAGSA', 8, 5.72, 8, 'marca', 'Gastro', null, 'Tableta', 'Tarmin', 'Bruluagsa', 'Caja con 12 tabletas', 'Loperamida', '2 mg', false, true),
  (13, '7501019068911', 'FC-19068911', 'Protectores Saba tradicional largo C/28', 'PROTECTORES SABA TRADICIONAL LARGO C/28 | SCA', 4, 24.99, 32, 'marca', 'Higiene', null, 'Protector', 'Saba', 'Essity', 'Bolsa con 28 protectores', null, null, false, true);

insert into public.productos (
  nombre, sku, codigo_barras, categoria, subcategoria, tipo, descripcion,
  costo, precio, stock, stock_minimo, activo, requiere_receta,
  marca, presentacion, forma_farmaceutica, principio_activo, concentracion,
  laboratorio
)
select
  t.nombre,
  case
    when t.ean is not null and exists (
      select 1 from public.productos p
      where p.sku = t.sku and coalesce(p.codigo_barras, '') <> t.ean
    ) then 'FC-ND-' || right(t.ean, 8)
    else t.sku
  end,
  t.ean,
  t.categoria,
  t.subcategoria,
  t.tipo,
  'Alta Farmalive 12949 · 2026-09-18 · listo para pistola',
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
from _fc_fl_12949 t
where (
    t.ean is not null and public.fc_buscar_producto_escaneo(t.ean) is null
  ) or (
    t.ean is null and public.fc_buscar_producto_escaneo(t.sku) is null
  );

update public.productos p
set
  costo = t.costo,
  precio = case
    when coalesce(p.precio, 0) <= 0 then t.precio
    else p.precio
  end
from _fc_fl_12949 t
where p.id = coalesce(
    case when t.ean is not null then public.fc_buscar_producto_escaneo(t.ean) else null end,
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
  principio_activo = coalesce(nullif(trim(p.principio_activo), ''), t.principio_activo),
  concentracion = coalesce(nullif(trim(p.concentracion), ''), t.concentracion),
  laboratorio = coalesce(nullif(trim(p.laboratorio), ''), t.laboratorio),
  subcategoria = coalesce(nullif(trim(p.subcategoria), ''), t.subcategoria),
  forma_farmaceutica = coalesce(nullif(trim(p.forma_farmaceutica), ''), t.forma)
from _fc_fl_12949 t
where p.id = coalesce(
    case when t.ean is not null then public.fc_buscar_producto_escaneo(t.ean) else null end,
    public.fc_buscar_producto_escaneo(t.sku)
  );

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'Farmalive',
  '12949',
  '2026-09-18',
  1730.09,
  'borrador',
  'Ticket Farmalive 12949 · Club Iztapalapa 1 · 18-sep-2026 11:08 · tarjeta $1,730.09 · cliente FARMACAPITAL · 13 renglones / 40 pzas · costo = precio neto después del descuento · cola Recibir'
where not exists (
  select 1 from public.recepciones
  where folio = '12949'
    and coalesce(proveedor, '') ilike '%farmalive%'
);

update public.recepciones
set
  total_ticket = 1730.09,
  fecha = '2026-09-18',
  proveedor = 'Farmalive',
  notas = 'Ticket Farmalive 12949 · Club Iztapalapa 1 · 18-sep-2026 11:08 · tarjeta $1,730.09 · cliente FARMACAPITAL · 13 renglones / 40 pzas · costo = precio neto después del descuento · cola Recibir',
  updated_at = now()
where folio = '12949'
  and coalesce(proveedor, '') ilike '%farmalive%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = '12949'
  and coalesce(r.proveedor, '') ilike '%farmalive%'
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
from _fc_fl_12949 t
join public.recepciones r
  on r.folio = '12949'
 and coalesce(r.proveedor, '') ilike '%farmalive%'
 and r.estado = 'borrador'
left join lateral (
  select coalesce(
    case when nullif(btrim(t.ean), '') is not null
      then public.fc_buscar_producto_escaneo(t.ean) else null end,
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
where r.folio = '12949'
  and coalesce(r.proveedor, '') ilike '%farmalive%'
group by r.id, r.folio, r.proveedor, r.estado, r.total_ticket;

commit;
