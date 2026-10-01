-- Equilibrio Farmacéutico · ticket 446466 · 2026-09-30 16:57 · Iztapalapa 2
-- Cliente 307513 Luis Angel · 71 artículos · total $2,532.66.
-- Costo = P.U. neto post-descuento. Lote de fábrica sí. Caducidad NO.
-- Piezas ticket (suma qty): 71. Total $2532.66.
-- 2 alta(s) stock 0. 12 ya estaban: solo costo / ficha vacía, no PVP.
-- Sin EAN (match por SKU): EQ-AVT195, EQ-DEN073, EQ-SER181.
-- Costo = P.U. unitario del ticket (NUNCA el importe del renglón).
-- Caducidad NO del papel: MMAA de la caja. No inventar 0000.
-- Nombres de ficha, no del ticket. Fotos en public/catalogo-propia/ (tras deploy).
-- SIN bloques dollar-quote. Idempotente mientras el ticket siga en borrador.
-- Pegar TODO este archivo en Supabase → SQL Editor → Run.

begin;

create temp table _fc_eq_446466 (
  linea integer primary key,
  ean text,
  sku text not null,
  nombre text not null,
  snap text not null,
  qty integer not null,
  costo numeric(12,3) not null,
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

insert into _fc_eq_446466 (
  linea, ean, sku, nombre, snap, qty, costo, precio, tipo, categoria,
  subcategoria, forma, marca, laboratorio, presentacion, principio_activo,
  concentracion, receta, ya, imagen, foto_file, lote
) values
  (1, '7501349012943', 'FC-5BC5F234', 'Fluconazol 150 mg C/1', 'AMS165 FLUCONAZOL 1 CAPS 150 MG', 20, 13.07, 21, 'generico', 'Medicamentos', null, 'Cápsula', 'AMSA', 'AMSA', 'Caja con 1 cápsula', 'Fluconazol', '150 mg', true, true, null, null, 'U25N344'),
  (2, null, 'EQ-AVT195', 'Tusilen adulto jarabe 118 ml', 'AVT195 TUSILEN AD 1 JBE 240/30/50MG/100/118 ML', 3, 25.86, 33, 'marca', 'Medicamentos', null, 'Jarabe', 'Tusilen', 'Avitus', 'Frasco 118 ml', null, '240/30/50 mg/100 ml', false, false, null, null, '26195002'),
  (3, null, 'EQ-DEN073', 'Delaphil 20 mg C/4', 'DEN073 DELAPHIL 4 TAB 20 MG', 10, 23.65, 38, 'generico', 'Medicamentos', null, 'Tableta', 'Delaphil', null, 'Caja con 4 tabletas', null, '20 mg', true, true, null, null, '26F009'),
  (4, '780083140922', 'FC-83140922', 'Ampigrin adulto 3 ámpulas', 'COL009 AMPIGRIN AD 3 AMP 500/500/100/30MG/3 ML', 2, 81.01, 102, 'marca', 'Medicamentos', null, 'Inyectable', 'Ampigrin', 'Collins', '3 ámpulas', null, '500/500/100/30 mg/3 ml', true, true, 'https://www.farmacapital.mx/catalogo-propia/ampigrin-ad-3amp.jpg', 'catalogo-propia/ampigrin-ad-3amp.jpg', '26240138'),
  (5, '7501563380637', 'EQ-RAD100', 'Fenazopiridina 100 mg C/20', 'RAD100 FENAZOPIRIDINA 1 FCO 20 TAB 100 MG', 5, 21.09, 34, 'generico', 'Medicamentos', null, 'Tableta', 'Randall', 'Randall', 'Frasco 20 tabletas', 'Fenazopiridina', '100 mg', false, true, null, null, '30224'),
  (6, null, 'EQ-SER181', 'Ruquimox 200 mg C/20', 'SER181 RUQUIMOX 20 TAB 200 MG', 2, 166.16, 266, 'generico', 'Medicamentos', null, 'Tableta', 'Ruquimox', null, 'Caja con 20 tabletas', null, '200 mg', true, false, null, null, '260525'),
  (7, '7501075722543', 'EQ-NOV163', 'Pabesorag 150/12.5 mg C/28', 'NOV163 PABESORAG 28 TAB 150/12.5 MG', 6, 60.48, 97, 'generico', 'Medicamentos', null, 'Tableta', 'Pabesorag', 'Novag', 'Caja con 28 tabletas', null, '150/12.5 mg', true, true, null, null, 'B10436'),
  (8, '7502009745140', 'FC-09745140', 'Clamoxin S suspensión 600/42.9 mg 50 ml', 'MAV226 CLAMOXIN S 1 SUSP 600/42.90MG/50 ML', 2, 48.07, 77, 'generico', 'Medicamentos', null, 'Suspensión', 'Clamoxin', 'MAVI', 'Frasco 50 ml', 'Amoxicilina / ácido clavulánico', '600/42.9 mg/5 ml', true, true, null, null, '256773'),
  (9, '7502009740503', 'FC-09740503', 'Clamoxin 12H JR suspensión 400/57 mg 50 ml', 'MAV014 CLAMOXIN 12H JR 1 SUSP 400/57MG/5/50 ML', 2, 37.17, 60, 'generico', 'Medicamentos', null, 'Suspensión', 'Clamoxin', 'MAVI', 'Frasco 50 ml', 'Amoxicilina / ácido clavulánico', '400/57 mg/5 ml', true, true, null, null, '260568'),
  (10, '7502009740497', 'FC-09740497', 'Clamoxin 12H PED suspensión 200/28.5 mg', 'MAV013 CLAMOXIN 12H PED 1 SUSP 200/28.5MG/40', 2, 25.99, 42, 'generico', 'Medicamentos', null, 'Suspensión', 'Clamoxin', 'MAVI', 'Frasco', 'Amoxicilina / ácido clavulánico', '200/28.5 mg/5 ml', true, true, null, null, '257267'),
  (11, '780083142308', 'FC-83142308', 'Tempire paracetamol gotas 100 mg/ml 30 ml', 'COL090 TEMPIRE 1 GOT 100MG/30 ML', 3, 20.00, 25, 'marca', 'Medicamentos', null, 'Gotas', 'Tempire', 'Collins', 'Frasco 30 ml', 'Paracetamol', '100 mg/ml', false, true, null, null, '26141514'),
  (12, '7501349020535', 'EQ-AMS424', 'Irbesartán 300 mg C/14 AMSA', 'AMS424 IRBESARTAN 14 TAB 300 MG', 3, 77.88, 125, 'generico', 'Medicamentos', null, 'Tableta', 'AMSA', 'AMSA', 'Caja con 14 tabletas', 'Irbesartán', '300 mg', true, true, null, null, 'U26E329'),
  (13, '7502009740992', 'FC-5F30F9D4', 'Clamoxin amoxicilina/clavulánico 500/125 mg C/10', 'MAV111 CLAMOXIN 10 TAB 500/125 MG', 5, 48.51, 78, 'generico', 'Medicamentos', null, 'Tableta', 'Clamoxin', 'MAVI', 'Caja con 10 tabletas', 'Amoxicilina / ácido clavulánico', '500/125 mg', true, true, null, null, '262924'),
  (14, '7502247373495', 'EQ-LAN057', 'Bacat atorvastatina 20 mg C/30', 'LAN057 BACAT 30 TAB 20 MG', 6, 39.31, 63, 'generico', 'Medicamentos', null, 'Tableta', 'Bacat', null, 'Caja con 30 tabletas', 'Atorvastatina', '20 mg', true, true, 'https://www.farmacapital.mx/catalogo-propia/bacat-atorvastatina-20mg-c30-7502247373495.jpg', 'catalogo-propia/bacat-atorvastatina-20mg-c30-7502247373495.jpg', 'L26G0410A');

insert into public.productos (
  nombre, sku, codigo_barras, categoria, subcategoria, tipo, descripcion,
  costo, precio, stock, stock_minimo, activo, requiere_receta,
  marca, presentacion, forma_farmaceutica, principio_activo, concentracion,
  laboratorio, imagen_url, imagen_mobile_url
)
select
  t.nombre,
  case
    when nullif(btrim(t.ean), '') is not null and exists (
      select 1 from public.productos p
      where p.sku = t.sku and coalesce(p.codigo_barras, '') <> t.ean
    ) then 'FC-ND-' || right(t.ean, 8)
    else t.sku
  end,
  nullif(btrim(t.ean), ''),
  t.categoria,
  t.subcategoria,
  t.tipo,
  'Alta Equilibrio Farmacéutico 446466 · 2026-09-30 · listo para pistola',
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
  select distinct on (coalesce(nullif(btrim(ean), ''), sku)) *
  from _fc_eq_446466
  order by coalesce(nullif(btrim(ean), ''), sku), linea
) t
where (
    nullif(btrim(t.ean), '') is null
    or public.fc_buscar_producto_escaneo(t.ean) is null
  )
  and public.fc_buscar_producto_escaneo(t.sku) is null;

update public.productos p
set
  costo = t.costo,
  precio = case
    when coalesce(p.precio, 0) <= 0 then t.precio
    else p.precio
  end
from (
  select distinct on (coalesce(nullif(btrim(ean), ''), sku)) *
  from _fc_eq_446466
  order by coalesce(nullif(btrim(ean), ''), sku), linea
) t
where p.id = coalesce(
  case when nullif(btrim(t.ean), '') is not null
    then public.fc_buscar_producto_escaneo(t.ean) end,
  public.fc_buscar_producto_escaneo(t.sku)
)
  and (
    p.costo is distinct from t.costo
    or coalesce(p.precio, 0) <= 0
  );

update public.productos p
set
  marca = coalesce(nullif(trim(p.marca), ''), t.marca),
  presentacion = coalesce(nullif(trim(p.presentacion), ''), t.presentacion),
  principio_activo = coalesce(nullif(trim(p.principio_activo), ''), t.principio_activo),
  concentracion = coalesce(nullif(trim(p.concentracion), ''), t.concentracion),
  laboratorio = coalesce(nullif(trim(p.laboratorio), ''), t.laboratorio),
  subcategoria = coalesce(nullif(trim(p.subcategoria), ''), t.subcategoria),
  forma_farmaceutica = coalesce(nullif(trim(p.forma_farmaceutica), ''), t.forma),
  imagen_url = coalesce(nullif(trim(p.imagen_url), ''), t.imagen),
  imagen_mobile_url = coalesce(nullif(trim(p.imagen_mobile_url), ''), t.imagen),
  codigo_barras = coalesce(
    nullif(trim(p.codigo_barras), ''),
    nullif(btrim(t.ean), '')
  )
from (
  select distinct on (coalesce(nullif(btrim(ean), ''), sku)) *
  from _fc_eq_446466
  order by coalesce(nullif(btrim(ean), ''), sku), linea
) t
where p.id = coalesce(
  case when nullif(btrim(t.ean), '') is not null
    then public.fc_buscar_producto_escaneo(t.ean) end,
  public.fc_buscar_producto_escaneo(t.sku)
);

insert into public.proveedores (nombre, activo)
select 'Equilibrio Farmacéutico', true
where not exists (
  select 1 from public.proveedores
  where lower(btrim(nombre)) = lower('Equilibrio Farmacéutico')
);

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'Equilibrio Farmacéutico',
  '446466',
  '2026-09-30',
  2532.66,
  'borrador',
  'Equilibrio 446466 · 30-sep-2026 · P.U. post-dto · MMAA de la caja'
where not exists (
  select 1 from public.recepciones
  where folio = '446466'
    and coalesce(proveedor, '') ilike '%Equilibrio%'
);

update public.recepciones
set
  total_ticket = 2532.66,
  fecha = '2026-09-30',
  proveedor = 'Equilibrio Farmacéutico',
  notas = 'Equilibrio 446466 · 30-sep-2026 · P.U. post-dto · MMAA de la caja',
  updated_at = now()
where folio = '446466'
  and coalesce(proveedor, '') ilike '%Equilibrio%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = '446466'
  and coalesce(r.proveedor, '') ilike '%Equilibrio%'
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
        and l.numero_lote is distinct from t.lote
    )
  ),
  null
from _fc_eq_446466 t
join public.recepciones r
  on r.folio = '446466'
 and coalesce(r.proveedor, '') ilike '%Equilibrio%'
 and r.estado = 'borrador'
left join lateral (
  select coalesce(
    case when nullif(btrim(t.ean), '') is not null
      then public.fc_buscar_producto_escaneo(t.ean) end,
    public.fc_buscar_producto_escaneo(t.sku)
  ) as pid
) v on true
order by t.linea;

insert into public.producto_imagenes
  (producto_id, url, storage_path, posicion, es_principal, origen)
select
  p.id,
  t.imagen,
  t.foto_file,
  coalesce((
    select max(i.posicion) from public.producto_imagenes i
    where i.producto_id = p.id
  ), 0) + 1,
  not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id and i.es_principal
  ),
  'propia'
from (
  select distinct on (coalesce(nullif(btrim(ean), ''), sku)) *
  from _fc_eq_446466
  order by coalesce(nullif(btrim(ean), ''), sku), linea
) t
join public.productos p on p.id = coalesce(
  case when nullif(btrim(t.ean), '') is not null
    then public.fc_buscar_producto_escaneo(t.ean) end,
  public.fc_buscar_producto_escaneo(t.sku)
)
where t.imagen is not null
  and not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id and i.url = t.imagen
  );

commit;

select
  i.id,
  i.codigo_escaneado as ean,
  left(i.nombre_snapshot, 52) as nombre,
  i.cantidad,
  i.costo_estimado,
  i.numero_lote,
  case when i.pendiente_alta then 'ALTA NUEVA' else 'YA EXISTE' end as estado
from public.recepcion_items i
join public.recepciones r on r.id = i.recepcion_id
where r.folio = '446466'
  and coalesce(r.proveedor, '') ilike '%Equilibrio%'
order by i.id;
