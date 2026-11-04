-- ============================================================================
-- Farmalive Club Iztapalapa 1 · ticket 11104 · 2026-10-30 · $496.47 → cola Recibir
--
-- Costo = P.U. neto con descuento 2%. 14 unidades · tarjeta.
-- Altas nuevas: Vitacilina Facial PDRN + Exosomas (ficha oficial vitacilina.mx).
-- Glucerna / Electrolit ya en catálogo: costo ticket, no baja PVP bueno.
-- Stock al escanear + MMAA. No inventar 0000.
-- SIN do $$. Idempotente mientras el ticket siga en borrador.
-- Pegar TODO en Supabase → SQL Editor → Run.
-- ============================================================================

begin;

create temp table _fc_fl11104 (
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
  receta boolean not null default false,
  imagen text
) on commit drop;

insert into _fc_fl11104 (
  linea, ean, sku, nombre, snap, qty, costo, precio, tipo, categoria,
  subcategoria, forma, marca, laboratorio, presentacion, principio_activo,
  concentracion, receta, imagen
) values
(1, '7502250343232', 'FC-50343232',
 'Vitacilina Facial PDRN',
 'CRE VITACILINA FACIAL PDRN 100 GR | KSK',
 1, 97.90, 123, 'marca', 'Cuidado personal',
 'Facial', 'Crema', 'Vitacilina', 'KSK',
 'Tarro 100 g', 'PDRN / ácido hialurónico', null, false,
 'https://www.farmacapital.mx/catalogo-propia/vitacilina-facial-pdrn-100g-7502250343232.jpg'),
(2, '7502250343249', 'FC-50343249',
 'Vitacilina Facial Exosomas',
 'CRE VITACILINA FACIAL EXOSOMAS 100 GR | KSK',
 1, 97.90, 123, 'marca', 'Cuidado personal',
 'Facial', 'Crema', 'Vitacilina', 'KSK',
 'Tarro 100 g', 'Exosomas / retinol', null, false,
 'https://www.farmacapital.mx/catalogo-propia/vitacilina-facial-exosomas-100g-7502250343249.jpg'),
(3, '7501033956126', 'FC-33956126',
 'Glucerna líquido vainilla',
 'GLUCERNA LIQ VAINILLA 237 ML | ABBOTT',
 2, 52.33, 66, 'marca', 'Suplementos',
 null, 'Líquido', 'Glucerna', 'Abbott',
 'Frasco 237 mL', null, null, false,
 'https://www.farmacapital.mx/catalogo-propia/glucerna-liquido-vainilla-237ml-7501033956126.jpg'),
(4, '7501125144851', 'FC-51448511',
 'Electrolit Uva',
 'ELECTROLIT UVA 625 ML | LAB PISA',
 2, 19.60, 25, 'marca', 'Bebidas',
 'Electrolitos', 'Suero oral', 'Electrolit', 'Pisa',
 'Botella 625 mL', null, null, false,
 'https://www.farmacapital.mx/catalogo-propia/electrolit-uva-625ml-7501125144851.jpg'),
(5, '7501125187179', 'FC-25187179',
 'Electrolit Guayaba',
 'ELECTROLIT GUAYABA 625 ML | LAB PISA',
 2, 19.60, 25, 'marca', 'Bebidas',
 'Electrolitos', 'Suero oral', 'Electrolit', 'Pisa',
 'Botella 625 mL', null, null, false,
 'https://www.farmacapital.mx/catalogo-propia/electrolit-guayaba-625ml-7501125187179.jpg'),
(6, '7503046131224', 'FC-46131224',
 'Electrolit Ponche de frutas',
 'ELECTROLIT PONCHE FRUTAS 625 ML | LAB PISA',
 2, 19.60, 25, 'marca', 'Bebidas',
 'Electrolitos', 'Suero oral', 'Electrolit', 'Pisa',
 'Botella 625 mL', null, null, false,
 'https://www.farmacapital.mx/catalogo-propia/electrolit-ponche-frutas-625ml-7503046131224.jpg'),
(7, '7501125103582', 'FC-25103582',
 'Electrolit Piña',
 'ELECTROLIT PIÑA 625 ML | LAB PISA',
 2, 19.60, 25, 'marca', 'Bebidas',
 'Electrolitos', 'Suero oral', 'Electrolit', 'Pisa',
 'Botella 625 mL', null, null, false,
 'https://www.farmacapital.mx/catalogo-propia/electrolit-pina-625ml-7501125103582.jpg'),
(8, '7501125104688', 'FC-25104688',
 'Electrolit Naranja-Mandarina',
 'ELECTROLIT NJA/MANDARINA 625 ML | LAB PISA',
 2, 19.60, 25, 'marca', 'Bebidas',
 'Electrolitos', 'Suero oral', 'Electrolit', 'Pisa',
 'Botella 625 mL', null, null, false,
 'https://www.farmacapital.mx/catalogo-propia/electrolit-naranja-mandarina-625ml-7501125104688.jpg');

-- Altas (solo si EAN / SKU no existen)
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
      where p.sku = t.sku and coalesce(p.codigo_barras, '') is distinct from t.ean
    ) then 'FC-ND-' || right(t.ean, 8)
    else t.sku
  end,
  t.ean,
  t.categoria,
  t.subcategoria,
  t.tipo,
  'Alta Farmalive 11104 · 2026-10-30 · listo para pistola',
  t.costo,
  t.precio,
  0, 1, true, t.receta,
  t.marca, t.presentacion, t.forma, t.principio_activo, t.concentracion,
  t.laboratorio, t.imagen, t.imagen
from _fc_fl11104 t
where public.fc_buscar_producto_escaneo(t.ean) is null
  and public.fc_buscar_producto_escaneo(t.sku) is null
  and not exists (
    select 1 from public.productos p
    where p.codigo_barras = t.ean or p.sku = t.sku
  );

-- Costos del ticket (no baja PVP bueno)
update public.productos p
set
  costo = t.costo,
  precio = case
    when coalesce(p.precio, 0) <= 1 then t.precio
    else p.precio
  end,
  codigo_barras = coalesce(nullif(btrim(p.codigo_barras), ''), t.ean)
from _fc_fl11104 t
where p.id = public.fc_buscar_producto_escaneo(t.ean)
  and (
    p.costo is distinct from t.costo
    or coalesce(p.precio, 0) <= 1
    or nullif(btrim(p.codigo_barras), '') is null
  );

-- Completar ficha / foto si falta
update public.productos p
set
  nombre = case
    when length(trim(coalesce(p.nombre, ''))) < 8
      or p.nombre ~* '^(CRE |GLUCERNA LIQ|ELECTROLIT )'
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
  categoria = coalesce(nullif(trim(p.categoria), ''), t.categoria),
  imagen_url = coalesce(nullif(trim(p.imagen_url), ''), t.imagen),
  imagen_mobile_url = coalesce(nullif(trim(p.imagen_mobile_url), ''), t.imagen),
  codigo_barras = coalesce(nullif(trim(p.codigo_barras), ''), t.ean)
from _fc_fl11104 t
where p.id = public.fc_buscar_producto_escaneo(t.ean);

-- Recepción borrador
insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'Farmalive',
  '11104',
  '2026-10-30',
  496.47,
  'borrador',
  'Ticket Farmalive 11104 · Club Iztapalapa 1 · 30-oct-2026 15:24 · Vitacilina Facial PDRN/Exosomas · Glucerna · Electrolit ×5 sabores · $496.47 · descto 2% · cola Recibir; stock al confirmar pistola + MMAA'
where not exists (
  select 1 from public.recepciones
  where folio = '11104' and coalesce(proveedor, '') ilike '%farmalive%'
);

update public.recepciones
set
  total_ticket = 496.47,
  fecha = '2026-10-30',
  proveedor = 'Farmalive',
  notas = 'Ticket Farmalive 11104 · Club Iztapalapa 1 · 30-oct-2026 15:24 · Vitacilina Facial PDRN/Exosomas · Glucerna · Electrolit ×5 sabores · $496.47 · descto 2% · cola Recibir; stock al confirmar pistola + MMAA',
  updated_at = now()
where folio = '11104'
  and coalesce(proveedor, '') ilike '%farmalive%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = '11104'
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
from _fc_fl11104 t
join public.recepciones r
  on r.folio = '11104'
 and coalesce(r.proveedor, '') ilike '%farmalive%'
 and r.estado = 'borrador'
left join lateral (
  select public.fc_buscar_producto_escaneo(t.ean) as pid
) v on true
order by t.linea;

commit;

-- select folio, proveedor, total_ticket, estado from recepciones where folio = '11104';
-- select codigo_escaneado, nombre_snapshot, cantidad, costo_estimado, pendiente_alta
-- from recepcion_items where recepcion_id = (select id from recepciones where folio = '11104' limit 1)
-- order by id;
