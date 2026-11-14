-- Equilibrio · ticket 444836 · 2026-09-18 10:27 · pedido online
-- Cliente 307513 LUIS ANGEL PALILLERO VENTURA · Pasillo EF Loc E-43.
-- Total $1,303.20 (subtotal $1,293.48 + IVA $9.72 de las cánulas).
-- Lote de fábrica sí. Caducidad NO: Recibir pide MMAA de la caja.
-- Costo = P.U. En JAY253/JAY267 el P.U. es sin IVA; el costo es el total/qty.
-- SOF066, JAY253 y JAY267: sin EAN confirmado. Toca el renglón; no esperes el beep.
-- Betahistina AMSA (7501349029965) no es Bitenver (7502009747373).
-- Laritol C/20 (7502009742828) no es Laritol C/10 (7502009740435).
-- 10 alta(s) con stock 0 si el EAN no está. El resto solo costo (PVP si estaba en 0).
-- TODO foto: las altas nuevas no traen packshot en este SQL. No usar placeholder de otra cadena.
-- SIN bloques dollar-quote. Idempotente mientras el ticket siga en borrador.
-- Pegar TODO este archivo en Supabase → SQL Editor → Run.

begin;

create temp table _fc_eq_444836 (
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
  ya boolean not null,
  lote text
) on commit drop;

insert into _fc_eq_444836 (
  linea, ean, sku, nombre, snap, qty, costo, precio, tipo, categoria, subcategoria, forma, marca, laboratorio, presentacion, principio_activo, concentracion, receta, ya, lote
) values

  (1, '780083140922', 'FC-2001A890', 'Ampigrin AD ampicilina/dicloxacilina 3 amp', 'COL009 AMPIGRIN AD 3 AMP 500/500/100/30MG/3 ML', 2, 81.01, 102, 'marca', 'Antibiótico', 'Inyectable', 'Solución inyectable', 'Ampigrin', 'Collins', 'Caja con 3 frascos ámpula + 3 diluyentes 3 ml', 'Ampicilina + dicloxacilina', '500/500/100/30 mg', true, true, '26240110'),
  (2, '7503001007069', 'EQ-WAN013', 'Vandix amoxicilina 250 mg/5 ml suspensión 75 ml', 'WAN013 VANDIX 1 SUSP 250MG/5/75 ML', 2, 20.12, 26, 'marca', 'Antibiótico', null, 'Suspensión', 'Vandix', 'Wandel', 'Frasco 75 ml', 'Amoxicilina', '250 mg/5 ml', true, true, 'S6253'),
  (3, '7502009747281', 'FC-09747281', 'Dolver ibuprofeno 800 mg C/10 Maver', 'MAV343 DOLVER 10 TAB 800 MG', 4, 20.79, 26, 'marca', 'Analgésico', 'Dolor', 'Tableta', 'Dolver', 'Maver', 'Caja con 10 tabletas', 'Ibuprofeno', '800 mg', false, false, '261654'),
  (4, '7503027446279', 'FC-5C8C9C11', 'Gelubrin ibuprofeno 600 mg C/10', 'PGE057 GELUBRIN 10 CAPS 600 MG', 4, 21.91, 28, 'marca', 'Analgésico', 'Dolor', 'Cápsula', 'Gelubrin', 'Progela', 'Caja con 10 cápsulas', 'Ibuprofeno', '600 mg', false, true, 'U0397'),
  (5, '7502009740435', 'EQ-MAV039', 'Laritol loratadina 10 mg C/10 Maver', 'MAV039 LARITOL 10 TAB 10 MG', 2, 7.01, 9, 'marca', 'Alergia', null, 'Tableta', 'Laritol', 'Maver', 'Caja con 10 tabletas', 'Loratadina', '10 mg', false, true, '260197'),
  (6, '7503008344785', 'EQ-PGE033', 'Gelubrin ibuprofeno 400 mg C/10', 'PGE033 GELUBRIN 10 CAPS 400 MG', 2, 15.11, 19, 'marca', 'Analgésico', 'Dolor', 'Cápsula', 'Gelubrin', 'Progela', 'Caja con 10 cápsulas', 'Ibuprofeno', '400 mg', false, true, 'U0126'),
  (7, '0780083144302', 'FC-83144302', 'Collifrin adulto oximetazolina 0.05% 20 ml', 'COL145 COLLIFRIN ADULTO 1 SOL 50MG/20 ML', 2, 33.69, 43, 'marca', 'Respiratorio', 'Descongestionante', 'Solución nasal', 'Collifrin', 'Collins', 'Frasco gotero 20 ml', 'Oximetazolina', '0.05%', false, true, '26140881'),
  (8, '7501125100116', 'FC-25100116', 'Solución CS Pisa cloruro de sodio 0.9% 250 ml', 'PIS103 SOLUCION CLORURO DE SODIO 0.9%/250 ML', 2, 26.50, 43, 'generico', 'Medicamentos', 'Soluciones', 'Solución parenteral', 'CS Pisa', 'Pisa', 'Frasco 250 ml', 'Cloruro de sodio', '0.9%', false, true, 'P25D312'),
  (9, '7501482200016', 'FC-82200016', 'Aktyzar omeprazol 20 mg frasco C/120', 'SOF054 OMEPRAZOL (AKTYZAR) 120 CAPS 20MG', 3, 46.90, 59, 'marca', 'Gastro', null, 'Cápsula', 'Aktyzar', 'Solfran', 'Frasco con 120 cápsulas', 'Omeprazol', '20 mg', false, true, '61422'),
  (10, null, 'EQ-SOF066', 'Aktyzar omeprazol 20 mg C/14', 'SOF066 OMEPRAZOL (AKTYZAR) 14 CAPS 20MG', 3, 8.00, 10, 'marca', 'Gastro', null, 'Cápsula', 'Aktyzar', 'Solfran', 'Caja con 14 cápsulas', 'Omeprazol', '20 mg', false, false, '61167'),
  (11, '7502211780359', 'FC-11780359', 'Aflusil ibuprofeno suspensión 2 g/100 ml 120 ml', 'LOE001 AFLUSIL 1 SUSP 2G/120ML', 3, 19.37, 25, 'marca', 'Analgésico', 'Dolor', 'Suspensión', 'Aflusil', 'Loeffler', 'Frasco 120 ml', 'Ibuprofeno', '2 g/100 ml', false, true, 'R2602932'),
  (12, '7502211784241', 'FC-11784241', 'Doflatem diclofenaco suspensión 120 ml', 'LOE079 DOFLATEM 1 SUSP 0.18G/100/120 ML', 2, 80.29, 101, 'marca', 'Analgésico', 'Dolor', 'Suspensión', 'Doflatem', 'Loeffler', 'Frasco 120 ml', 'Diclofenaco', '0.18 g/100 ml', true, false, 'R2509187B'),
  (13, '7502009742828', 'FC-09742828', 'Laritol loratadina 10 mg C/20 Maver', 'MAV258 LARITOL 20 TAB 10 MG', 2, 8.26, 11, 'marca', 'Alergia', null, 'Tableta', 'Laritol', 'Maver', 'Caja con 20 tabletas', 'Loratadina', '10 mg', false, false, '263132'),
  (14, '7501349029965', 'FC-49029965', 'Betahistina 24 mg C/30 AMSA', 'AMS474 BETAHISTINA 30 TAB 24 MG', 1, 62.04, 100, 'generico', 'Medicamentos', 'Neurología', 'Tableta', 'AMSA', 'AMSA', 'Caja con 30 tabletas', 'Betahistina', '24 mg', true, false, 'U26E251'),
  (15, '7502009747373', 'FC-58DB24C4', 'Bitenver betahistina 24 mg C/30 Maver', 'MAV350 BITENVER 30 TAB 24 MG', 2, 61.49, 77, 'marca', 'Medicamentos', 'Neurología', 'Tableta', 'Bitenver', 'Maver', 'Caja con 30 tabletas', 'Betahistina', '24 mg', true, true, '261052'),
  (16, '7501537102449', 'FC-37102449', 'Soltrim sulfametoxazol/trimetoprima 80/400 mg C/20', 'BRU068 SOLTRIM 20 TAB 80/400 MG', 2, 12.39, 16, 'marca', 'Antibiótico', null, 'Tableta', 'Soltrim', 'Bruluart', 'Caja con 20 tabletas', 'Sulfametoxazol + trimetoprima', '400/80 mg', true, false, '606278'),
  (17, '7501349024328', 'FC-49024328', 'Ketorolaco sublingual 30 mg C/4 AMSA', 'AMS496 KETOROLACO SL 4 TAB 30 MG', 10, 5.73, 10, 'generico', 'Analgésico', 'Dolor', 'Tableta sublingual', 'AMSA', 'AMSA', 'Caja con 4 tabletas sublinguales', 'Ketorolaco', '30 mg', true, false, 'U26F370'),
  (18, '7501573909965', 'FC-73909965', 'Doselmin ketorolaco 10 mg C/10 Biomep', 'BIO216 DOSELMIN 10 TAB 10 MG', 5, 5.61, 8, 'marca', 'Analgésico', 'Dolor', 'Tableta', 'Doselmin', 'Biomep', 'Caja con 10 tabletas', 'Ketorolaco', '10 mg', true, false, 'SA2621'),
  (19, null, 'EQ-JAY253', 'Cánula nasal para oxígeno pediátrica', 'JAY253 CANULA NASAL P/OXIGENO PED 1 PUNTAS', 2, 17.54, 29, 'generico', 'Dispositivos', 'Oxígeno', 'Dispositivo', null, null, 'Pieza, puntas nasales pediátricas', null, null, false, false, '2505884701'),
  (20, null, 'EQ-JAY267', 'Puntas nasales para oxígeno adulto', 'JAY267 PUNTAS P/OXIGENO AD 1 PUNTAS NASALES', 2, 17.69, 29, 'generico', 'Dispositivos', 'Oxígeno', 'Dispositivo', null, null, 'Pieza, puntas nasales adulto', null, null, false, false, '2507900301');

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
  'Alta Equilibrio 444836 · 2026-09-18 · listo para pistola',
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
from _fc_eq_444836 t
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
from _fc_eq_444836 t
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
from _fc_eq_444836 t
where p.id = coalesce(
    case when t.ean is not null then public.fc_buscar_producto_escaneo(t.ean) else null end,
    public.fc_buscar_producto_escaneo(t.sku)
  );

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'Equilibrio',
  '444836',
  '2026-09-18',
  1303.20,
  'borrador',
  'Ticket Equilibrio 444836 · Iztapalapa · 18-sep-2026 10:27 · pedido online · cliente 307513 · cola Recibir; stock al confirmar pistola · cánulas con IVA incluido en el costo'
where not exists (
  select 1 from public.recepciones
  where folio = '444836'
    and coalesce(proveedor, '') ilike '%equilibrio%'
);

update public.recepciones
set
  total_ticket = 1303.20,
  fecha = '2026-09-18',
  proveedor = 'Equilibrio',
  notas = 'Ticket Equilibrio 444836 · Iztapalapa · 18-sep-2026 10:27 · pedido online · cliente 307513 · cola Recibir; stock al confirmar pistola · cánulas con IVA incluido en el costo',
  updated_at = now()
where folio = '444836'
  and coalesce(proveedor, '') ilike '%equilibrio%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = '444836'
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
from _fc_eq_444836 t
join public.recepciones r
  on r.folio = '444836'
 and coalesce(r.proveedor, '') ilike '%equilibrio%'
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
where r.folio = '444836'
  and coalesce(r.proveedor, '') ilike '%equilibrio%'
group by r.id, r.folio, r.proveedor, r.estado, r.total_ticket;

commit;
