-- Equilibrio · ticket 446088 · 2026-09-28 14:55 · sucursal Iztapalapa 2
-- Pedido online. Total $3,149.38 · 22 renglones / 106 pzas. IVA $0.
-- Costo = P.U. neto (después de D/D6). Claves EQF → EAN Levic/ficha.
-- Ticket OCR BI0064 = BIO064 Cloxan sol. 7501573902706.
-- Sin EAN público aún: WER053 DEN073 BEA463 AMS458 ALP0241 JAY239
-- GEP050 STR029 → alta por SKU EQ-*; ligar EAN de caja al escanear.
-- Lote de fábrica sí. Caducidad NO: MMAA de la caja. 0000 inválido.
-- 11 alta(s) stock 0. 11 ya estaban: solo costo / ficha vacía, no PVP.
-- Sin EAN (match por SKU): EQ-WER053, EQ-DEN073, EQ-BEA463, EQ-AMS458, EQ-ALP0241, EQ-JAY239, EQ-GEP050, EQ-STR029.
-- Nombres de ficha, no del ticket. Fotos en public/catalogo-propia/ (tras deploy).
-- SIN bloques dollar-quote. Idempotente mientras el ticket siga en borrador.
-- Pegar TODO este archivo en Supabase → SQL Editor → Run.

begin;

create temp table _fc_eq_446088 (
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
  imagen text,
  foto_file text,
  lote text
) on commit drop;

insert into _fc_eq_446088 (
  linea, ean, sku, nombre, snap, qty, costo, precio, tipo, categoria,
  subcategoria, forma, marca, laboratorio, presentacion, principio_activo,
  concentracion, receta, ya, imagen, foto_file, lote
) values
  (1, null, 'EQ-WER053', 'Rosel Pediatric solución 30 ml', 'WER053 ROSEL PED 1 SOL 2.5/10/15G 30ML', 3, 28.48, 46, 'generico', 'Medicamentos', null, 'Solución', 'Rosel', 'Wermar', 'Frasco 30 ml', 'Amantadina / clorfenamina / paracetamol', '2.5/0.100/15 g / 30 ml', false, false, null, null, '260603'),
  (2, '7502009745478', 'EQ-MAV236', 'Ideliver Pro duloxetina 60 mg C/14', 'MAV236 IDELIVER PRO 14 TAB 60 MG', 4, 59.82, 96, 'generico', 'Medicamentos', null, 'Tableta', 'Ideliver Pro', 'Maver', 'Caja con 14 tabletas', 'Duloxetina', '60 mg', true, true, null, null, '264227'),
  (3, '7502009744877', 'FC-A909ABC0', 'Odivitor atorvastatina 20 mg C/10', 'MAV212 ODIVITOR 10 TAB 20 MG', 5, 13.77, 23, 'generico', 'Medicamentos', null, 'Tableta', 'Odivitor', 'Maver', 'Caja con 10 tabletas', 'Atorvastatina', '20 mg', true, true, null, null, '261644'),
  (4, '7502009745485', 'EQ-MAV237', 'Ideliver Pro duloxetina 30 mg C/7', 'MAV237 IDELIVER PRO 7 TAB 30 MG', 5, 30.16, 49, 'generico', 'Medicamentos', null, 'Tableta', 'Ideliver Pro', 'Maver', 'Caja con 7 tabletas', 'Duloxetina', '30 mg', true, false, null, null, '256611'),
  (5, '7502209858206', 'EQ-AVT201', 'Alphalock tamsulosina 0.4 mg C/20', 'AVT201 ALPHALOCK 20 CAPS 0.4 MG', 5, 35.41, 57, 'generico', 'Medicamentos', null, 'Cápsula', 'Alphalock', 'Avitus', 'Caja con 20 cápsulas', 'Tamsulosina', '0.4 mg', true, false, null, null, 'SC26069'),
  (6, null, 'EQ-DEN073', 'Delaphil 20 mg C/4', 'DEN073 DELAPHIL 4 TAB 20 MG', 5, 23.65, 38, 'generico', 'Medicamentos', null, 'Tableta', 'Delaphil', null, 'Caja con 4 tabletas', null, '20 mg', true, false, null, null, '26F009'),
  (7, null, 'EQ-BEA463', 'Tamsulosina 0.4 mg C/30', 'BEA463 TAMSULOSINA 30 CAPS 0.4 MG', 3, 46.19, 74, 'generico', 'Medicamentos', null, 'Cápsula', 'beadvance', 'beadvance', 'Caja con 30 cápsulas', 'Tamsulosina', '0.4 mg', true, false, null, null, 'SC26101'),
  (8, null, 'EQ-AMS458', 'Ácido alendrónico 70 mg C/4', 'AMS458 ACIDO ALENDRONICO 4 TAB 70 MG', 4, 29.26, 47, 'generico', 'Medicamentos', null, 'Tableta', 'AMSA', 'AMSA', 'Caja con 4 tabletas', 'Ácido alendrónico', '70 mg', true, false, null, null, 'U26A137'),
  (9, '7501349025943', 'EQ-AMS232', 'Pregabalina 75 mg C/28', 'AMS232 PREGABALINA 28 CAPS 75 MG', 3, 38.02, 61, 'generico', 'Medicamentos', null, 'Cápsula', 'AMSA', 'AMSA', 'Caja con 28 cápsulas', 'Pregabalina', '75 mg', true, true, null, null, 'U26J066'),
  (10, '7502223112193', 'FMX-502386', 'Guaxoquim jarabe adulto 140 ml', 'QUM019 GUAXOQUIM AD 1 JBE 100/50MG/5/140 ML', 3, 39.17, 49, 'marca', 'Medicamentos', null, 'Jarabe', 'Guaxoquim', 'Quimphar', 'Frasco 140 ml', null, '100/50 mg/5 ml', false, true, null, null, '26BN38'),
  (11, null, 'EQ-ALP0241', 'Vivradoxil doxiciclina 100 mg C/10', 'ALP0241 VIVRADOXIL 10 TAB 100 MG', 2, 29.13, 47, 'generico', 'Medicamentos', null, 'Tableta', 'Alpharma', 'Alpharma', 'Caja con 10 tabletas', 'Doxiciclina', '100 mg', true, false, null, null, '2604467'),
  (12, '7501573902706', 'FC-4F737E93', 'Cloxan ambroxol solución 120 ml', 'BI0064 CLOXAN 1 SOL 300MG/120ML', 3, 12.12, 16, 'marca', 'Medicamentos', null, 'Solución', 'Cloxan', 'Bioresearch', 'Frasco 120 ml', 'Ambroxol', '300 mg/120 ml', false, true, null, null, 'LE262B'),
  (13, '7501644707490', 'EQ-QUI127', 'Levonorgestrel / etinilestradiol 0.15/0.03 mg C/28', 'QUI127 LEVONORGES ETINILEST 28 TAB 0.15/0.03MG', 2, 24.54, 40, 'generico', 'Medicamentos', null, 'Tableta', 'Quifa', 'Quifa', 'Caja con 28 tabletas', 'Levonorgestrel / etinilestradiol', '0.15/0.03 mg', true, true, null, null, '26F010'),
  (14, null, 'EQ-JAY239', 'Zensif ceftriaxona I.M. 1 g', 'JAY239 ZENSIF I.M. 1 FA 1G/3.5 ML', 10, 9.47, 16, 'generico', 'Medicamentos', null, 'Inyectable', 'Zensif', 'Jayor', 'Frasco ámpula 1 g / 3.5 ml', 'Ceftriaxona', '1 g', true, false, null, null, '3125180'),
  (15, '7501573900337', 'FC-1DA570E3', 'Cloxan ambroxol 30 mg C/20', 'BIO016 CLOXAN 20 COMP 30 MG', 4, 9.53, 12, 'marca', 'Medicamentos', null, 'Comprimidos', 'Cloxan', 'Bioresearch', 'Caja con 20 comprimidos', 'Ambroxol', '30 mg', false, true, null, null, 'SB2642'),
  (16, '7502211784005', 'EQ-LOE058', 'Feniffler-T fenitoína 100 mg C/50', 'LOE058 FENIFFLER-T 50 TAB 100 MG', 2, 20.56, 33, 'generico', 'Medicamentos', null, 'Tableta', 'Feniffler-T', 'Loeffler', 'Frasco 50 tabletas', 'Fenitoína', '100 mg', true, true, null, null, 'R2511437'),
  (17, '7501384505271', 'FMX-307626', 'Bromuro de pinaverio Alpharma 100 mg C/14', 'SOE017 BROMURO DE PINAVERIO 14 TAB 100 MG', 5, 18.78, 31, 'generico', 'Medicamentos', null, 'Tableta', 'Alpharma', 'Alpharma', 'Caja con 14 tabletas', 'Bromuro de pinaverio', '100 mg', true, true, null, null, '172066'),
  (18, '7501478317421', 'EQ-VIT073', 'Bocetix levocetirizina solución 150 ml', 'VIT073 BOCETIX 1 SOL 50 MG 150 ML', 3, 73.28, 118, 'generico', 'Medicamentos', null, 'Solución', 'Bocetix', 'Vitae', 'Frasco 150 ml', 'Levocetirizina', '50 mg / 150 ml', false, true, 'https://www.farmacapital.mx/catalogo-propia/bocetix-levocetirizina-150ml.jpg', 'catalogo-propia/bocetix-levocetirizina-150ml.jpg', 'T2604224'),
  (19, '7501547522220', 'EQ-STR007', 'Trociletas cereza 1.45 mg C/10', 'STR007 TROCILETAS CEREZA 10 TAB 1.45 MG', 10, 27.61, 35, 'marca', 'Medicamentos', null, 'Tableta', 'Trociletas', 'Streger', 'Caja con 10 tabletas', 'Cloruro de cetilpiridinio', '1.45 mg', false, false, null, null, 'SN01IN'),
  (20, null, 'EQ-GEP050', 'Esgaro 5 mg C/10', 'GEP050 ESGARO 10 CAPS 5 MG', 5, 54.57, 88, 'generico', 'Medicamentos', null, 'Cápsula', 'Esgaro', null, 'Caja con 10 cápsulas', null, '5 mg', true, false, null, null, '260910'),
  (21, '7501547522145', 'EQ-STR008', 'Trociletas-B limón 2.5/10 mg C/12', 'STR008 TROCILETAS-B LIMON 12 TAB 2.5/10 MG', 10, 32.11, 41, 'marca', 'Medicamentos', null, 'Tableta', 'Trociletas', 'Streger', 'Caja con 12 tabletas', 'Cloruro de cetilpiridinio / benzocaína', '2.5/10 mg', false, true, null, null, 'SN02SD'),
  (22, null, 'EQ-STR029', 'Trociletas cereza 1.45 mg C/12', 'STR029 TROCILETAS CEREZA 12 TAB 1.45 MG', 10, 32.11, 41, 'marca', 'Medicamentos', null, 'Tableta', 'Trociletas', 'Streger', 'Caja con 12 tabletas', 'Cloruro de cetilpiridinio', '1.45 mg', false, false, null, null, 'IU02SR');

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
  'Alta Equilibrio 446088 · 2026-09-28 · listo para pistola',
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
  from _fc_eq_446088
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
  from _fc_eq_446088
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
  from _fc_eq_446088
  order by coalesce(nullif(btrim(ean), ''), sku), linea
) t
where p.id = coalesce(
  case when nullif(btrim(t.ean), '') is not null
    then public.fc_buscar_producto_escaneo(t.ean) end,
  public.fc_buscar_producto_escaneo(t.sku)
);

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'Equilibrio',
  '446088',
  '2026-09-28',
  3149.38,
  'borrador',
  'Ticket Equilibrio 446088 · Iztapalapa 2 · pedido online · cliente 307513 Palillero · 28-sep-2026 · lote de fábrica en papel · cola Recibir; stock al confirmar pistola + MMAA · sin EAN: WER053 DEN073 BEA463 AMS458 ALP0241 JAY239 GEP050 STR029'
where not exists (
  select 1 from public.recepciones
  where folio = '446088'
    and coalesce(proveedor, '') ilike '%equilibrio%'
);

update public.recepciones
set
  total_ticket = 3149.38,
  fecha = '2026-09-28',
  proveedor = 'Equilibrio',
  notas = 'Ticket Equilibrio 446088 · Iztapalapa 2 · pedido online · cliente 307513 Palillero · 28-sep-2026 · lote de fábrica en papel · cola Recibir; stock al confirmar pistola + MMAA · sin EAN: WER053 DEN073 BEA463 AMS458 ALP0241 JAY239 GEP050 STR029',
  updated_at = now()
where folio = '446088'
  and coalesce(proveedor, '') ilike '%equilibrio%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = '446088'
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
        and l.numero_lote is distinct from t.lote
    )
  ),
  null
from _fc_eq_446088 t
join public.recepciones r
  on r.folio = '446088'
 and coalesce(r.proveedor, '') ilike '%equilibrio%'
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
  from _fc_eq_446088
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
where r.folio = '446088'
  and coalesce(r.proveedor, '') ilike '%equilibrio%'
order by i.id;
