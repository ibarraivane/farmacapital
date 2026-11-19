-- =============================================================================
-- PEGAR TODO en Supabase → SQL Editor → Run
-- Nadro factura 6092466807 · 18-nov-2026 · CFDI $1,510.40 · 9 renglones / 39 pzas
-- UUID 0E8C7067-245A-418C-8809-52CED8374888 · PUE efectivo · La Capu
-- Subtotal $1,423.73 + IVA $86.67 = total.
-- EANs canónicos (OCR CFDI): Bresaltec 7506022327635 · Histofil 7501293203268
--   Bicarbonato 759684901058 · Mertodol 759684313257 · Bronco Rub 714706800900
-- Caducidad null (MMAA de la caja). Sin dollar-quote. Sin producto_imagenes.
-- Idempotente mientras el ticket siga en borrador.
-- =============================================================================

begin;

create temp table _fc_nd6092466807 (
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
  concentracion text,
  receta boolean not null,
  alta_nueva boolean not null
) on commit drop;

insert into _fc_nd6092466807
  (linea, ean, sku, nombre, snap, qty, costo, precio, tipo, categoria, subcategoria,
   marca, presentacion, forma, laboratorio, principio_activo, concentracion,
   receta, alta_nueva)
values
  (1, '759684901058', 'FC-84901058',
   'Bicarbonato de sodio Jaloma',
   'BIC-SODIO JALOMA 100 G',
   2, 8.04, 11, 'marca', 'Botiquin', null,
   'Jaloma', 'Polvo 100 g', 'Polvo', 'Jaloma',
   'Bicarbonato de sodio', null,
   false, true),
  (2, '7506022327635', 'FC-22327635',
   'Bresaltec 100 mcg',
   'BRESALTEC 100mcg INH200DOSIS LGEN',
   2, 41.65, 67, 'generico', 'Medicamentos', 'Respiratorio',
   'Bresaltec', 'Inhalador 200 dosis', 'Aerosol', 'Biosyntec',
   'Salbutamol', '100 mcg',
   false, true),
  (3, '714706800900', 'FC-50003314',
   'Bronco Rub unguento 40 g',
   'BRONCO RUB 40 G UNG',
   1, 32.26, 41, 'marca', 'Botiquin', 'Respiratorio',
   'Bronco Rub', 'Tarro 40 g', 'Unguento', null,
   null, null,
   false, false),
  (4, '7501008433515', 'FC-08433515',
   'Cafiaspirina',
   'CAFIASPIRINA 100 TAB',
   1, 130.50, 164, 'marca', 'Medicamentos', 'Analgesico',
   'Cafiaspirina', 'Caja con 100 tabletas', 'Tabletas', 'Bayer',
   'Acido acetilsalicilico / cafeina', null,
   false, true),
  (5, '3543122250276', 'FC-12225027',
   'Derman crema 50 g',
   'DERMAN 50 G CRA',
   2, 49.71, 63, 'marca', 'Medicamentos', 'Dermatologia',
   'Derman', 'Tubo 50 g', 'Crema', null,
   'Acido undecilenico / undecilenato de zinc', null,
   false, false),
  (6, '7501349024540', 'EQ-AMS275',
   'Ezetimiba/Simvastatina 10/20 mg',
   'EZETIMIS/SIMVAS 10/20MG 28TAB LGEN',
   2, 92.66, 149, 'generico', 'Medicamentos', 'Cardiovascular',
   'AMSA', 'Caja con 28 tabletas', 'Tabletas', 'AMSA',
   'Ezetimiba / Simvastatina', '10 mg / 20 mg',
   true, false),
  (7, '7501293203268', 'FC-93203268',
   'Histofil 8000 UI',
   'HISTOFIL 8000 UI FCO 30 TAB',
   1, 351.25, 440, 'marca', 'Medicamentos', 'Vitaminas',
   'Histofil', 'Frasco con 30 tabletas', 'Tabletas', 'Medix',
   'Colecalciferol', '8000 UI',
   true, true),
  (8, '7702018072439', 'FC-18072439',
   'Gillette Simply Venus',
   'MAQ GTTE SIMPLYVENUS3 DESCH1PZ S',
   8, 16.75, 21, 'marca', 'Cuidado personal', 'Afeitado',
   'Gillette', 'Maquina desechable 1 pza', 'Maquina', 'P&G',
   null, null,
   false, true),
  (9, '759684313257', 'FC-84313257',
   'Mertodol blanco con atomizador',
   'MERTODOL BCO JALOMA C/ATO 40ML S',
   20, 19.58, 25, 'marca', 'Botiquin', 'Antiseptico',
   'Jaloma', '40 ml con atomizador', 'Solucion', 'Jaloma',
   'Cloruro de benzalconio', '0.13%',
   false, true);

insert into public.productos (
  nombre, sku, codigo_barras, categoria, tipo, descripcion,
  costo, precio, stock, stock_minimo, activo, requiere_receta,
  marca, presentacion, forma_farmaceutica, principio_activo, concentracion,
  laboratorio, subcategoria
)
select
  t.nombre,
  case
    when not exists (select 1 from public.productos x where x.sku = t.sku)
      then t.sku
    when not exists (
      select 1 from public.productos x
      where x.sku = ('FC-ND-' || right(t.ean, 8))
    ) then 'FC-ND-' || right(t.ean, 8)
    else 'FC-T' || lpad(t.linea::text, 2, '0') || '-' || right(t.ean, 8)
  end,
  t.ean,
  t.categoria,
  t.tipo,
  'Alta Nadro 6092466807 · 18-nov-2026 · listo para pistola',
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
  t.subcategoria
from _fc_nd6092466807 t
where t.alta_nueva
  and public.fc_buscar_producto_escaneo(t.ean) is null
  and public.fc_buscar_producto_escaneo(t.sku) is null
  and not exists (
    select 1 from public.productos p
    where nullif(btrim(p.codigo_barras), '') = t.ean
  )
  and not exists (
    select 1 from public.productos p
    where p.sku = t.sku
      and (
        nullif(btrim(p.codigo_barras), '') is null
        or nullif(btrim(p.codigo_barras), '') = t.ean
      )
  );

update public.productos p set
  marca = coalesce(nullif(trim(p.marca), ''), t.marca),
  presentacion = coalesce(nullif(trim(p.presentacion), ''), t.presentacion),
  forma_farmaceutica = coalesce(nullif(trim(p.forma_farmaceutica), ''), t.forma),
  principio_activo = coalesce(nullif(trim(p.principio_activo), ''), t.principio_activo),
  concentracion = coalesce(nullif(trim(p.concentracion), ''), t.concentracion),
  subcategoria = coalesce(nullif(trim(p.subcategoria), ''), t.subcategoria),
  laboratorio = coalesce(nullif(trim(p.laboratorio), ''), t.laboratorio),
  nombre = case
    when length(trim(coalesce(p.nombre, ''))) < 8 then t.nombre
    else p.nombre
  end,
  categoria = coalesce(nullif(trim(p.categoria), ''), t.categoria),
  tipo = coalesce(nullif(trim(p.tipo), ''), t.tipo),
  requiere_receta = t.receta,
  codigo_barras = coalesce(nullif(btrim(p.codigo_barras), ''), t.ean),
  updated_at = now()
from _fc_nd6092466807 t
where p.id = coalesce(
  public.fc_buscar_producto_escaneo(t.ean),
  public.fc_buscar_producto_escaneo(t.sku)
);

update public.productos p
set
  costo = t.costo,
  precio = case
    when coalesce(p.precio, 0) <= 0 then t.precio
    else p.precio
  end,
  updated_at = now()
from _fc_nd6092466807 t
where p.id = coalesce(
  public.fc_buscar_producto_escaneo(t.ean),
  public.fc_buscar_producto_escaneo(t.sku)
)
  and (
    p.costo is distinct from t.costo
    or coalesce(p.precio, 0) <= 0
  );

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'Nadro',
  '6092466807',
  '2026-11-18',
  1510.40,
  'borrador',
  'Factura Nadro 6092466807 · 18-nov-2026 · CFDI $1,510.40 · UUID 0E8C7067… · PUE efectivo · La Capu · 9 renglones / 39 pzas · cola Recibir; stock al confirmar pistola · MMAA de la caja'
where not exists (
  select 1 from public.recepciones
  where folio = '6092466807' and coalesce(proveedor, '') ilike '%nadro%'
);

update public.recepciones
set
  total_ticket = 1510.40,
  fecha = '2026-11-18',
  proveedor = 'Nadro',
  notas = 'Factura Nadro 6092466807 · 18-nov-2026 · CFDI $1,510.40 · UUID 0E8C7067… · PUE efectivo · La Capu · 9 renglones / 39 pzas · cola Recibir; stock al confirmar pistola · MMAA de la caja',
  updated_at = now()
where folio = '6092466807'
  and coalesce(proveedor, '') ilike '%nadro%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = '6092466807'
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
  false,
  null
from _fc_nd6092466807 t
join public.recepciones r
  on r.folio = '6092466807'
 and coalesce(r.proveedor, '') ilike '%nadro%'
 and r.estado = 'borrador'
left join lateral (
  select coalesce(
    public.fc_buscar_producto_escaneo(t.ean),
    public.fc_buscar_producto_escaneo(t.sku),
    (
      select p2.id from public.productos p2
      where nullif(btrim(p2.codigo_barras), '') = t.ean
      order by p2.id
      limit 1
    ),
    (
      select p2.id from public.productos p2
      where p2.sku = t.sku
      order by p2.id
      limit 1
    )
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
  count(*) filter (where i.confirmado is not true) as sin_confirmar,
  bool_or(i.pendiente_alta) as tiene_pendiente_alta
from public.recepciones r
left join public.recepcion_items i on i.recepcion_id = r.id
where r.folio = '6092466807'
  and coalesce(r.proveedor, '') ilike '%nadro%'
group by r.id, r.folio, r.proveedor, r.estado, r.total_ticket;

select
  i.codigo_escaneado as ean,
  left(i.nombre_snapshot, 48) as snap,
  i.cantidad,
  i.costo_estimado,
  case when i.pendiente_alta then 'ALTA NUEVA' else 'YA EXISTE' end as estado,
  p.sku,
  left(p.nombre, 40) as nombre_catalogo
from public.recepcion_items i
join public.recepciones r on r.id = i.recepcion_id
left join public.productos p on p.id = i.producto_id
where r.folio = '6092466807'
  and coalesce(r.proveedor, '') ilike '%nadro%'
order by i.id;

commit;
