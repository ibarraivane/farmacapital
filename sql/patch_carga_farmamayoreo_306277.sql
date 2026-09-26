-- Farma Mayoreo · ID VENTA 306277 · 2026-09-24 16:35 · Central de Abastos
-- Ticket térmico partido (3 fotos). Subtotal $2,841.58 + impuestos $136.85 = $2,978.43.
-- P.U. ya trae IVA (suma renglones = total). Kotex Unika EAN 7506425625536 (línea sobreimpresa).
-- Oral-B Stages: Toy Story+Princesas comparten EAN 3014260279264 (×2); Frozen es 3014260278922 (×1).
-- Lote de fábrica del papel cuando es legible. Caducidad NO: MMAA de la caja. 0000 inválido.
-- 23 alta(s) stock 0. 7 ya estaban: solo costo / ficha vacía, no PVP.
-- Nombres de ficha, no del ticket. Fotos en public/catalogo-propia/ (tras deploy).
-- SIN bloques dollar-quote. Idempotente mientras el ticket siga en borrador.
-- Pegar TODO este archivo en Supabase → SQL Editor → Run.

begin;

create temp table _fc_fm_306277 (
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

insert into _fc_fm_306277 (
  linea, ean, sku, nombre, snap, qty, costo, precio, tipo, categoria,
  subcategoria, forma, marca, laboratorio, presentacion, principio_activo,
  concentracion, receta, ya, imagen, foto_file, lote
) values
  (1, '3014260279264', 'FC-60279264', 'Oral-B Stages cepillo dental infantil 3+ Disney/Pixar', 'ORAL B CEPILLO S', 2, 51.83, 65, 'marca', 'Cuidado personal', 'Bucal', 'Cepillo', 'Oral-B', 'P&G', '1 pieza', null, null, false, false, null, null, '6041833520'),
  (2, '3014260278922', 'FC-60278922', 'Oral-B Stages cepillo dental infantil 3+ Frozen', 'ORAL B CEPILLO F', 1, 50.97, 64, 'marca', 'Cuidado personal', 'Bucal', 'Cepillo', 'Oral-B', 'P&G', '1 pieza', null, null, false, false, null, null, '6037833520'),
  (3, '7501050623766', 'FC-05062376', 'Afrin No Drip solución nasal 15 mL', 'AFRIN NODRIP CSE', 2, 107.90, 135, 'marca', 'Medicamentos', null, 'Solución nasal', 'Afrin', 'Bayer', 'Frasco 15 mL', 'Oximetazolina', null, false, true, null, null, '2601390'),
  (4, '7501050624732', 'FC-06247327', 'Afrin No Drip spray nasal extra humectante 15 mL', 'AFRIN NODRIP SPR', 2, 101.98, 128, 'marca', 'Medicamentos', null, 'Spray nasal', 'Afrin', 'Bayer', 'Frasco 15 mL', 'Oximetazolina', null, false, true, null, null, '251279EA'),
  (5, '7500435246309', 'FC-35246309', 'Vick Drops jengibre pastillas C/20', 'VICK DROPS SABOR', 1, 37.98, 48, 'marca', 'Botiquín', null, 'Pastilla', 'Vick', 'P&G', 'C/20', null, null, false, true, null, null, '516202'),
  (6, '7509546072272', 'FC-46072272', 'Colgate Kids pasta dental', 'COLGATE CD KIDS', 1, 24.98, 32, 'marca', 'Cuidado personal', 'Bucal', 'Pasta dental', 'Colgate', null, 'Tubo', null, null, false, false, null, null, '516202'),
  (7, '7891024034095', 'FC-24034095', 'Colgate Kids pasta dental (import)', 'COLGATE CD KIDS', 1, 20.95, 27, 'marca', 'Cuidado personal', 'Bucal', 'Pasta dental', 'Colgate', null, 'Tubo', null, null, false, false, null, null, '4268'),
  (8, '7501054550150', 'FC-54550150', 'Curitas animales apósitos adhesivos', 'CURITAS ANIMALES', 1, 45.98, 58, 'marca', 'Botiquín', 'Material de curación', 'Apósito', 'Curitas', 'Johnson & Johnson', 'Caja', null, null, false, false, null, null, '4268'),
  (9, '7501048623044', 'FC-48623044', 'Pads faciales Protec con glicerina', 'PADS FACIALES PR', 1, 28.50, 36, 'marca', 'Cuidado personal', 'Higiene', 'Pads', 'Protec', null, 'Bolsa', null, null, false, false, null, null, '52647'),
  (10, '7501943490598', 'FC-43490598', 'Jabón líquido Escudo para manos', 'JBN LIQ ESCUDO P', 4, 28.00, 35, 'marca', 'Cuidado personal', 'Higiene', 'Jabón líquido', 'Escudo', 'P&G', null, null, null, false, true, 'https://www.farmacapital.mx/catalogo-propia/escudo-jabon-liquido.jpg', 'catalogo-propia/escudo-jabon-liquido.jpg', null),
  (11, '7590002037843', 'FC-02037843', 'Vick Pyrena miel jarabe', 'VICK PYRENA MIEL', 2, 89.98, 113, 'marca', 'Medicamentos', null, 'Jarabe', 'Vick', 'P&G', 'Frasco', null, null, false, false, null, null, '60494354U0'),
  (12, '7501125100116', 'FC-25100116', 'Solución CS Pisa cloruro de sodio 0.9% 250 mL', 'SOLUCION CLORURO', 4, 26.90, 44, 'generico', 'Medicamentos', null, 'Solución', 'CS Pisa', 'Pisa', 'Frasco 250 mL', 'Cloruro de sodio', '0.9%', false, true, null, null, 'P26Y317'),
  (13, '7501125115479', 'FC-25115479', 'Solución CS Pisa cloruro de sodio 0.9% 100 mL', 'SOLUCION CLORURO', 3, 22.98, 37, 'generico', 'Medicamentos', null, 'Solución', 'CS Pisa', 'Pisa', 'Frasco 100 mL', 'Cloruro de sodio', '0.9%', false, false, null, null, 'V26J530'),
  (14, '7503017500769', 'FC-17500769', 'Jabón líquido para manos (variante A)', 'JABON LIQUIDO PA', 1, 16.91, 22, 'marca', 'Cuidado personal', 'Higiene', 'Jabón líquido', null, null, 'Botella', null, null, false, false, null, null, '437032'),
  (15, '7503017500776', 'FC-17500776', 'Jabón líquido para manos (variante B)', 'JABON LIQUIDO PA', 1, 16.91, 22, 'marca', 'Cuidado personal', 'Higiene', 'Jabón líquido', null, null, 'Botella', null, null, false, false, null, null, '439036'),
  (16, '7503017500783', 'FC-17500783', 'Jabón líquido para manos (variante C)', 'JABON LIQUIDO PA', 1, 16.91, 22, 'marca', 'Cuidado personal', 'Higiene', 'Jabón líquido', null, null, 'Botella', null, null, false, false, null, null, '438033'),
  (17, '7501088509766', 'FC-85097661', 'Antiflu-Des Junior jarabe infantil 60 mL', 'ANTIFLUDES SOL J', 3, 124.98, 157, 'marca', 'Medicamentos', null, 'Jarabe', 'Antiflu-Des', 'Chinoin', 'Frasco 60 mL', null, null, false, true, null, null, 'BFB081'),
  (18, '7501065085191', 'FC-65085191', 'Voltaren Emulgel diclofenaco 1% 50 g', 'VOLTAREN EMULGEL', 1, 76.98, 97, 'marca', 'Medicamentos', null, 'Gel', 'Voltaren', 'GSK', 'Tubo 50 g', 'Diclofenaco', '1%', false, false, null, null, 'UC2L'),
  (19, '7501088509810', 'FL-8509810', 'Antiflu-Des pediátrico solución 30 mL', 'ANTIFLUDES SOL P', 1, 138.98, 174, 'marca', 'Medicamentos', null, 'Solución', 'Antiflu-Des', 'Chinoin', 'Frasco 30 mL', null, null, false, true, 'https://www.farmacapital.mx/catalogo-propia/antiflu-des-pediatrico-30ml.jpg', 'catalogo-propia/antiflu-des-pediatrico-30ml.jpg', 'BEK114'),
  (20, '7501065024688', 'FC-65024688', 'Voltaren Dolo 25 mg C/20', 'VOLTAREN DOLO 25', 1, 195.98, 245, 'marca', 'Medicamentos', null, 'Tableta', 'Voltaren', 'GSK', 'Caja con 20 tabletas', 'Diclofenaco', '25 mg', false, false, null, null, '35826'),
  (21, '7501065085528', 'FC-65085528', 'Voltaren Emulgel diclofenaco 1% 100 g', 'VOLTAREN EMULGEL', 1, 111.98, 140, 'marca', 'Medicamentos', null, 'Gel', 'Voltaren', 'GSK', 'Tubo 100 g', 'Diclofenaco', '1%', false, false, null, null, 'F19T'),
  (22, '7509546068558', 'FC-46068558', 'Colgate cepillo dental', 'COLGATE CEPILLO', 2, 45.98, 58, 'marca', 'Cuidado personal', 'Bucal', 'Cepillo', 'Colgate', null, '1 pieza', null, null, false, false, null, null, null),
  (23, '7509546079493', 'FC-46079493', 'Colgate cepillos dentales (pack)', 'COLGATE CEPILLOS', 2, 30.97, 39, 'marca', 'Cuidado personal', 'Bucal', 'Cepillo', 'Colgate', null, 'Pack', null, null, false, false, null, null, null),
  (24, '7509546066776', 'FC-46066776', 'Colgate crema dental', 'COLGATE CREMA DE', 3, 45.98, 58, 'marca', 'Cuidado personal', 'Bucal', 'Pasta dental', 'Colgate', null, 'Tubo', null, null, false, false, null, null, null),
  (25, '7500435246293', 'FC-35246293', 'Vick Drops caramelo mentol pastillas', 'DROPS CARAMELO M', 2, 37.98, 48, 'marca', 'Botiquín', null, 'Pastilla', 'Vick', 'P&G', 'Caja', null, null, false, false, null, null, '505700'),
  (26, '7500435246286', 'FC-35246286', 'Vick Drops caramelo mentol pastillas (lote B)', 'DROPS CARAMELO M', 2, 37.98, 48, 'marca', 'Botiquín', null, 'Pastilla', 'Vick', 'P&G', 'Caja', null, null, false, false, null, null, '514101'),
  (27, '7501943493940', 'FC-43493940', 'Toallitas húmedas Escudo', 'TAS HUMEDAS ESC', 3, 12.98, 17, 'marca', 'Cuidado personal', 'Higiene', 'Toallitas', 'Escudo', 'P&G', 'Paquete', null, null, false, false, null, null, null),
  (28, '7506425625536', 'FC-25625536', 'Kotex Unika tampones regular C/12', 'KOTEX TAMPONES R', 2, 32.50, 41, 'marca', 'Cuidado personal', 'Higiene íntima', 'Tampones', 'Kotex', null, 'Caja con 12', null, null, false, false, null, null, null),
  (29, '7501417515956', 'FC-17515956', 'Bocasan Econopack polvo', 'BOCASAN ECONOPA', 2, 60.95, 77, 'marca', 'Cuidado personal', 'Bucal', 'Polvo', 'Bocasan', null, 'Caja', null, null, false, false, null, null, '25D03'),
  (30, '7506195102640', 'FC-95102640', 'Vick Pyrena manzana jarabe', 'VICK PYRENA MANZ', 2, 78.98, 99, 'marca', 'Medicamentos', null, 'Jarabe', 'Vick', 'P&G', 'Frasco', null, null, false, false, null, null, '008435400');

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
  'Alta Farma Mayoreo 306277 · 2026-09-24 · listo para pistola',
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
  from _fc_fm_306277
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
  from _fc_fm_306277
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
  from _fc_fm_306277
  order by ean, linea
) t
where p.id = coalesce(
  public.fc_buscar_producto_escaneo(t.ean),
  public.fc_buscar_producto_escaneo(t.sku)
);

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'Farma Mayoreo',
  '306277',
  '2026-09-24',
  2978.43,
  'borrador',
  'Ticket Farma Mayoreo 306277 · Central · 24-sep-2026 16:35 · tarjeta · 30 arts / 55 pzas · foto en 3 partes (sobreimpresión en Colgate/Kotex) · cola Recibir; stock al confirmar pistola'
where not exists (
  select 1 from public.recepciones
  where folio = '306277'
    and coalesce(proveedor, '') ilike '%farma mayoreo%'
);

update public.recepciones
set
  total_ticket = 2978.43,
  fecha = '2026-09-24',
  proveedor = 'Farma Mayoreo',
  notas = 'Ticket Farma Mayoreo 306277 · Central · 24-sep-2026 16:35 · tarjeta · 30 arts / 55 pzas · foto en 3 partes (sobreimpresión en Colgate/Kotex) · cola Recibir; stock al confirmar pistola',
  updated_at = now()
where folio = '306277'
  and coalesce(proveedor, '') ilike '%farma mayoreo%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = '306277'
  and coalesce(r.proveedor, '') ilike '%farma mayoreo%'
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
from _fc_fm_306277 t
join public.recepciones r
  on r.folio = '306277'
 and coalesce(r.proveedor, '') ilike '%farma mayoreo%'
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
from _fc_fm_306277 t
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
where r.folio = '306277'
  and coalesce(r.proveedor, '') ilike '%farma mayoreo%'
group by r.id, r.folio, r.proveedor, r.estado, r.total_ticket;

select
  t.linea,
  t.ean,
  t.nombre,
  t.qty,
  t.costo,
  case when public.fc_buscar_producto_escaneo(t.ean) is null then 'PENDIENTE_ALTA' else 'OK' end as match,
  t.ya as marcado_ya
from _fc_fm_306277 t
order by t.linea;

commit;
