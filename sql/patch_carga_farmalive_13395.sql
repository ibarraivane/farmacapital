-- Farmalive · ticket 13395 · 2026-09-24 16:52 · Club Iztapalapa 1
-- Total $1,359.31 · 18 artículos / 46 unidades · tarjeta crédito.
-- Foto partida (inicio + pie). Costo = P.U. neto post-descuento.
-- Suerox naranja-mango: EAN botella 7501048607214 (no el 650… interno).
-- Sin lote ni caducidad (MMAA de la caja). No inventar 0000.
-- 11 alta(s) stock 0. 7 ya estaban: solo costo / ficha vacía, no PVP.
-- Nombres de ficha, no del ticket. Fotos en public/catalogo-propia/ (tras deploy).
-- SIN bloques dollar-quote. Idempotente mientras el ticket siga en borrador.
-- Pegar TODO este archivo en Supabase → SQL Editor → Run.

begin;

create temp table _fc_fl_13395 (
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

insert into _fc_fl_13395 (
  linea, ean, sku, nombre, snap, qty, costo, precio, tipo, categoria,
  subcategoria, forma, marca, laboratorio, presentacion, principio_activo,
  concentracion, receta, ya, imagen, foto_file, lote
) values
  (1, '6502400721541', 'FC-00721541', 'Suerox Vitamins manzana y limón 630 mL', 'SUEROX VITAMINS MANZANA V-LIMON 630 ML | GENOMMA LAB', 2, 14.73, 24, 'generico', 'Bebidas', 'Electrolitos', 'Bebida', 'Suerox', 'Genomma Lab', 'Botella 630 mL', null, null, false, true, null, null, null),
  (2, '6502400663068', 'FC-40066306', 'Suerox 8 iones fresa 630 mL', 'SUEROX 8 IONES FRESA 630 ML | GENOMMA LAB', 2, 14.73, 24, 'generico', 'Bebidas', 'Electrolitos', 'Bebida', 'Suerox', 'Genomma Lab', 'Botella 630 mL', null, null, false, true, null, null, null),
  (3, '7501048607214', 'FC-00721471', 'Suerox Vitamins naranja-mango 630 mL', 'SUEROX VITAMINS NARANJA-MANGO 630 ML | GENOMMA LAB', 2, 14.73, 24, 'generico', 'Bebidas', 'Electrolitos', 'Bebida', 'Suerox', 'Genomma Lab', 'Botella 630 mL', null, null, false, true, null, null, null),
  (4, '7501033956690', 'FC-33956690', 'Pedialyte SR45 fresa 500 mL', 'PEDIALYTE SR45 FRESA 500 ML | ABBOTT', 2, 23.81, 30, 'marca', 'Bebidas', 'Electrolitos', 'Suero oral', 'Pedialyte', 'Abbott', 'Frasco 500 mL', null, null, false, true, null, null, null),
  (5, '7501033954740', 'FC-33954740', 'Pedialyte SR60 manzana 500 mL', 'PEDIALYTE SR60 MANZANA 500 ML | ABBOTT', 2, 23.81, 30, 'marca', 'Bebidas', 'Electrolitos', 'Suero oral', 'Pedialyte', 'Abbott', 'Frasco 500 mL', null, null, false, true, null, null, null),
  (6, '7501033956775', 'FC-33956775', 'Pedialyte SR60 uva 500 mL', 'PEDIALYTE SR60 UVA 500 ML | ABBOTT', 2, 23.81, 30, 'marca', 'Bebidas', 'Electrolitos', 'Suero oral', 'Pedialyte', 'Abbott', 'Frasco 500 mL', null, null, false, true, null, null, null),
  (7, '7509546058962', 'FC-46058962', 'Caprice Naturals sábila spray 316 mL', 'SPRAY CAPRICE NATURALS SABILA 316 ML | COLGATE PALMOLIVE', 1, 48.80, 61, 'marca', 'Cuidado personal', 'Capilar', 'Spray', 'Caprice', 'Colgate-Palmolive', '316 mL', null, null, false, false, null, null, null),
  (8, '7509546058979', 'FC-46058979', 'Caprice algas spray 316 mL', 'SPRAY CAPRICE ALGAS 316 ML | COLGATE PALMOLIVE', 2, 48.80, 61, 'marca', 'Cuidado personal', 'Capilar', 'Spray', 'Caprice', 'Colgate-Palmolive', '316 mL', null, null, false, false, null, null, null),
  (9, '7509546058986', 'FC-46058986', 'Caprice kiwi lavanda spray 316 mL', 'SPRAY CAPRICE KIWI LAVANDA 316 ML | COLGATE PALMOLIVE', 2, 48.80, 61, 'marca', 'Cuidado personal', 'Capilar', 'Spray', 'Caprice', 'Colgate-Palmolive', '316 mL', null, null, false, false, null, null, null),
  (10, '7509546059006', 'FC-46059006', 'Caprice granada spray 316 mL', 'SPRAY CAPRICE GRANADA 316 ML | COLGATE PALMOLIVE', 2, 48.80, 61, 'marca', 'Cuidado personal', 'Capilar', 'Spray', 'Caprice', 'Colgate-Palmolive', '316 mL', null, null, false, false, null, null, null),
  (11, '7891024179925', 'FC-24179925', 'Colgate PerioGard enjuague bucal 250 mL', 'ENJ BUCAL COLGATE PERIO GARD 250 ML | COLGATE PALMOLIVE', 1, 182.28, 228, 'marca', 'Cuidado personal', 'Bucal', 'Enjuague', 'Colgate', 'Colgate-Palmolive', '250 mL', null, null, false, false, null, null, null),
  (12, '7502275701659', 'FC-75701659', 'Cubrebocas Alfa Medical kids azul C/10', 'CUBREBOCAS ALFA MEDICAL KIDS AZUL C/10 | ALFA MEDICAL', 2, 22.05, 28, 'marca', 'Botiquín', 'Material de curación', 'Cubrebocas', 'Alfa Medical', null, 'C/10', null, null, false, false, null, null, null),
  (13, '7501048780235', 'FC-48780235', 'Cubrebocas Protec plegado C/10', 'CUBREBOCAS PROTEC PLEGADO C/10 | DEGASA', 1, 18.03, 23, 'marca', 'Botiquín', 'Material de curación', 'Cubrebocas', 'Protec', 'Degasa', 'C/10', null, null, false, false, null, null, null),
  (14, '7502275701642', 'FC-75701642', 'Cubrebocas Alfa Medical kids rosa C/10', 'CUBREBOCAS KIDS ROSA BOLSA C/10 | ALFA MEDICAL', 2, 22.05, 28, 'marca', 'Botiquín', 'Material de curación', 'Cubrebocas', 'Alfa Medical', null, 'C/10', null, null, false, false, null, null, null),
  (15, '7501868902008', 'FC-68902008', 'Venda Dibar 5 cm', 'VENDA DIBAR 5 CM | DIBAR', 3, 7.15, 9, 'marca', 'Botiquín', 'Material de curación', 'Venda', 'Dibar', null, '5 cm', null, null, false, false, null, null, null),
  (16, '7702018072439', 'FC-18072439', 'Gillette Simply Venus 3 mujer C/1', 'RASTRILLO GILLETTE SIMPLY VENUS 3 MUJ C/1 | PG PERF', 4, 18.23, 23, 'marca', 'Cuidado personal', 'Afeitado', 'Rastrillo', 'Gillette', 'P&G', 'C/1', null, null, false, false, null, null, null),
  (17, '7500435011303', 'FC-35011303', 'Gillette Prestobarba Ultra Grip3 C/1', 'RASTRILLO PRESTOBARBA ULTRA GRIP3 C/1 | PG PERF', 12, 20.78, 26, 'marca', 'Cuidado personal', 'Afeitado', 'Rastrillo', 'Gillette', 'P&G', 'C/1', null, null, false, false, null, null, null),
  (18, '7702018874729', 'FC-18874729', 'Gillette Prestobarba3 hombre 2-pack', 'RAST GILLETTE PRESTOBARBA3 HOMBRE 2PACK | PG PERF', 2, 77.13, 97, 'marca', 'Cuidado personal', 'Afeitado', 'Rastrillo', 'Gillette', 'P&G', '2-pack', null, null, false, true, null, null, null);

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
  'Alta Farmalive 13395 · 2026-09-24 · listo para pistola',
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
  from _fc_fl_13395
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
  from _fc_fl_13395
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
  from _fc_fl_13395
  order by ean, linea
) t
where p.id = coalesce(
  public.fc_buscar_producto_escaneo(t.ean),
  public.fc_buscar_producto_escaneo(t.sku)
);

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'Farmalive',
  '13395',
  '2026-09-24',
  1359.31,
  'borrador',
  'Ticket Farmalive 13395 · Club Iztapalapa 1 · 24-sep-2026 16:52 · precio neto (2–5% desc.) · Suerox naranja-mango EAN botella 7501048607214 · cola Recibir; stock al confirmar pistola + MMAA'
where not exists (
  select 1 from public.recepciones
  where folio = '13395'
    and coalesce(proveedor, '') ilike '%farmalive%'
);

update public.recepciones
set
  total_ticket = 1359.31,
  fecha = '2026-09-24',
  proveedor = 'Farmalive',
  notas = 'Ticket Farmalive 13395 · Club Iztapalapa 1 · 24-sep-2026 16:52 · precio neto (2–5% desc.) · Suerox naranja-mango EAN botella 7501048607214 · cola Recibir; stock al confirmar pistola + MMAA',
  updated_at = now()
where folio = '13395'
  and coalesce(proveedor, '') ilike '%farmalive%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = '13395'
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
from _fc_fl_13395 t
join public.recepciones r
  on r.folio = '13395'
 and coalesce(r.proveedor, '') ilike '%farmalive%'
 and r.estado = 'borrador'
left join lateral (
  select coalesce(
    public.fc_buscar_producto_escaneo(t.ean),
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
    where i.producto_id = p.id and coalesce(i.es_principal, false)
  ),
  'propia'
from _fc_fl_13395 t
join public.productos p on p.id = coalesce(
  public.fc_buscar_producto_escaneo(t.ean),
  public.fc_buscar_producto_escaneo(t.sku)
)
where t.imagen is not null
  and not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id
      and (i.url = t.imagen or i.storage_path = t.foto_file)
  );

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
where r.folio = '13395'
  and coalesce(r.proveedor, '') ilike '%farmalive%'
group by r.id, r.folio, r.proveedor, r.estado, r.total_ticket;

select
  t.linea,
  t.ean,
  t.nombre,
  t.qty,
  t.costo,
  case when public.fc_buscar_producto_escaneo(t.ean) is null then 'PENDIENTE_ALTA' else 'OK' end as match,
  t.ya as marcado_ya
from _fc_fl_13395 t
order by t.linea;

commit;
