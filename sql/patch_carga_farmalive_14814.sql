-- Farmalive · ticket 14814 · 2026-10-19 17:05 · Club Iztapalapa 1
-- 18 renglones / 42 unidades. Papel: subtotal $1,725.63 − desc. $60.64 = $1,664.99.
-- Costo = P.U. neto del renglón a 2 decimales → suma SQL $1,664.96.
-- Tukol-D / Prudence con renglón promo $0.01 (regalo). Genomma EAN como en ticket.
-- Alli-Triple ticket 12 dígitos 650240053610 (canónico catálogo).
-- 11 alta(s) stock 0. 7 ya estaban: solo costo / ficha vacía, no PVP.
-- Nombres de ficha, no del ticket. Fotos en public/catalogo-propia/ (tras deploy).
-- SIN bloques dollar-quote. Idempotente mientras el ticket siga en borrador.
-- Pegar TODO este archivo en Supabase → SQL Editor → Run.

begin;

create temp table _fc_fl_14814 (
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

insert into _fc_fl_14814 (
  linea, ean, sku, nombre, snap, qty, costo, precio, tipo, categoria,
  subcategoria, forma, marca, laboratorio, presentacion, principio_activo,
  concentracion, receta, ya, imagen, foto_file, lote
) values
  (1, '7506306234062', 'FC-06234062', 'Sedal Anti Nudos crema para peinar', 'CRE PEINAR SEDAL ANTI NUDOS 300 ML | UNILEVER', 3, 37.53, 47, 'marca', 'Cuidado personal', 'Cabello', 'Crema', 'Sedal', 'Unilever', 'Frasco 300 mL', null, null, false, true, null, null, null),
  (2, '7501008491003', 'FC-08491003', 'Desenfriol D tabletas 2-pack', 'DESENFRIOL D TAB C/30 2PACK | BAYER OTC', 1, 103.68, 130, 'marca', 'Respiratorio', null, 'Tableta', 'Desenfriol', 'Bayer', '2 cajas con 30 tabletas', 'Clorfenamina / fenilefrina / paracetamol', null, false, false, null, null, null),
  (3, '7501001168889', 'FC-01168889', 'Vick Pyrena sobres 8+2', 'VICK PYRENA SOB 8+2 | PG OTC', 1, 162.68, 204, 'marca', 'Respiratorio', null, 'Sobre', 'Vick Pyrena', 'P&G', 'Caja con 8+2 sobres', 'Paracetamol / fenilefrina', null, false, false, null, null, null),
  (4, '7501022105207', 'FC-22105207', 'Jabón Grisi Neutro', 'JABON GRISI NEUTRO 150 GR | GRISI HNOS', 3, 19.21, 25, 'marca', 'Higiene', null, 'Jabón', 'Grisi', 'Grisi', 'Barra 150 g', null, null, false, true, null, null, null),
  (5, '650240053610', 'FC-053610', 'Alli-Triple', 'ALLI-TRIPLE TAB C/10 | GENOMMA LAB', 3, 58.80, 74, 'marca', 'Medicamentos', null, 'Tableta', 'Alli-Triple', 'Genomma Lab', 'Caja con 10 tabletas', 'Naproxeno sódico', null, false, true, null, null, null),
  (6, '7506339394719', 'FC-39394719', 'Naturella Nocturno con alas', 'TOA SANIT NATURELLA NOCTURNO C/A C/8 | PG PERF', 2, 21.43, 27, 'marca', 'Cuidado personal', 'Higiene femenina', 'Toalla', 'Naturella', 'P&G', 'Paquete con 8 toallas', null, null, false, false, null, null, null),
  (7, '7590002046234', 'FC-02046234', 'Naturella pantiprotectores manzanilla', 'PANTIPROTECTORES NATURELLA MANZ C/40 | PG PERF', 1, 38.54, 49, 'marca', 'Cuidado personal', 'Higiene femenina', 'Pantiprotector', 'Naturella', 'P&G', 'Paquete con 40', null, null, false, false, null, null, null),
  (8, '7506309895208', 'FC-09895208', 'Naturella manzanilla regular con alas', 'TOA SANIT NATURELLA MANZ REG C/ALAS C/8 | PG PERF', 1, 9.78, 13, 'marca', 'Cuidado personal', 'Higiene femenina', 'Toalla', 'Naturella', 'P&G', 'Paquete con 8 toallas', null, null, false, false, null, null, null),
  (9, '7506552900322', 'FC-29003221', 'Vaso recolector Quirmex', 'VASO RECOLECTOR QUIRMEX | QUIRMEX', 8, 3.53, 5, 'marca', 'Botiquín', 'Material de curación', 'Vaso', 'Quirmex', 'Quirmex', '1 pieza 120 mL', null, null, false, true, null, null, null),
  (10, '7501008499795', 'FC-08499795', 'Afrin No Drip Niños', 'AFRIN NO DRIP INF SPRAY 15 ML | BAYER OTC', 3, 103.20, 129, 'marca', 'Respiratorio', null, 'Spray nasal', 'Afrin', 'Bayer', 'Frasco 15 mL', 'Oximetazolina', null, false, true, null, null, null),
  (11, '650240080159', 'FC-40080159', 'Suerox Mineral mora azul', 'SUEROX MINERAL MORA AZUL 355 ML | GENOMMA LAB', 2, 14.73, 19, 'marca', 'Bebidas', 'Electrolitos', 'Bebida', 'Suerox', 'Genomma Lab', 'Botella 355 mL', null, null, false, false, null, null, null),
  (12, '7503003406754', 'FC-03406754', 'Venda Quirmex 15 cm', 'VENDA QUIRMEX 15 CM | QUIRMEX', 2, 10.97, 14, 'marca', 'Botiquín', 'Material de curación', 'Venda', 'Quirmex', 'Quirmex', 'Rollo 15 cm', null, null, false, false, null, null, null),
  (13, '7501868902404', 'FC-68902404', 'Venda Dibar 20 cm', 'VENDA DIBAR 20 CM | DIBAR', 2, 22.44, 29, 'marca', 'Botiquín', 'Material de curación', 'Venda', 'Dibar', 'Dibar', 'Rollo 20 cm', null, null, false, false, null, null, null),
  (14, '7501019032424', 'FC-19032424', 'Tampones Saba Super', 'TAMPONES SABA SUPER C/10 | ESSITY', 1, 47.43, 60, 'marca', 'Cuidado personal', 'Higiene femenina', 'Tampón', 'Saba', 'Essity', 'Caja con 10', null, null, false, true, null, null, null),
  (15, '7502214982811', 'FC-14982811', 'Condones Prudence surtido', 'COND PRUDENCE SURTIDO C/5 | DKT MEXICO', 4, 44.10, 56, 'marca', 'Cuidado personal', 'Salud sexual', 'Condón', 'Prudence', 'DKT México', 'Caja con 5', null, null, false, false, null, null, null),
  (16, '7502214982811', 'FC-14982811', 'Condones Prudence surtido', 'COND PRUDENCE SURTIDO C/5 | DKT MEXICO', 1, 0.01, 1, 'marca', 'Cuidado personal', 'Salud sexual', 'Condón', 'Prudence', 'DKT México', 'Caja con 5', null, null, false, false, null, null, null),
  (17, '6502400315191', 'FC-00315191', 'Tukol-D 0% azúcar jarabe adulto', 'TUKOL-D 0% AZUCAR JBE ADTO 120 ML | GENOMMA LAB', 2, 151.41, 190, 'marca', 'Respiratorio', null, 'Jarabe', 'Tukol-D', 'Genomma Lab', 'Frasco 120 mL', 'Guaifenesina / dextrometorfano', null, false, false, null, null, null),
  (18, '6502400107128', 'FC-40010712', 'Tukol-D jarabe adulto', 'TUKOL-D JBE ADTO 125 ML | GENOMMA LAB', 2, 0.01, 1, 'marca', 'Respiratorio', null, 'Jarabe', 'Tukol-D', 'Genomma Lab', 'Frasco 125 mL', 'Guaifenesina / dextrometorfano', null, false, true, null, null, null);

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
  'Alta Farmalive 14814 · 2026-10-19 · listo para pistola',
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
  from _fc_fl_14814
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
  from _fc_fl_14814
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
  from _fc_fl_14814
  order by ean, linea
) t
where p.id = coalesce(
  public.fc_buscar_producto_escaneo(t.ean),
  public.fc_buscar_producto_escaneo(t.sku)
);

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'Farmalive',
  '14814',
  '2026-10-19',
  1664.96,
  'borrador',
  'Ticket Farmalive 14814 · Club Iztapalapa 1 · 19-oct-2026 17:05 · cliente FARMACAPITAL · descuentos por renglón · papel TOTAL $1,664.99 / suma P.U. neto $1,664.96 · cola Recibir; stock al confirmar pistola + MMAA'
where not exists (
  select 1 from public.recepciones
  where folio = '14814'
    and coalesce(proveedor, '') ilike '%farmalive%'
);

update public.recepciones
set
  total_ticket = 1664.96,
  fecha = '2026-10-19',
  proveedor = 'Farmalive',
  notas = 'Ticket Farmalive 14814 · Club Iztapalapa 1 · 19-oct-2026 17:05 · cliente FARMACAPITAL · descuentos por renglón · papel TOTAL $1,664.99 / suma P.U. neto $1,664.96 · cola Recibir; stock al confirmar pistola + MMAA',
  updated_at = now()
where folio = '14814'
  and coalesce(proveedor, '') ilike '%farmalive%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = '14814'
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
from _fc_fl_14814 t
join public.recepciones r
  on r.folio = '14814'
 and coalesce(r.proveedor, '') ilike '%farmalive%'
 and r.estado = 'borrador'
left join lateral (
  select coalesce(
    public.fc_buscar_producto_escaneo(t.ean),
    public.fc_buscar_producto_escaneo(t.sku)
  ) as pid
) v on true
order by t.linea;

-- Una foto por (producto, url): tickets con 2 renglones del mismo EAN
-- (promo 2+1) no deben insertar dos veces la misma URL.
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
from (
  select distinct on (ean, imagen) *
  from _fc_fl_14814
  where imagen is not null
  order by ean, imagen, linea
) t
join public.productos p on p.id = coalesce(
  public.fc_buscar_producto_escaneo(t.ean),
  public.fc_buscar_producto_escaneo(t.sku)
)
where not exists (
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
where r.folio = '14814'
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
from _fc_fl_14814 t
order by t.linea;

commit;
