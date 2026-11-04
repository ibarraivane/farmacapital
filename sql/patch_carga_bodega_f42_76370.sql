-- ============================================================================
-- Bodega F-42 / Citymark · Caja 1/76370 · 2026-10-30 16:54 · $1,192.28 → cola Recibir
--
-- Ticket térmico Citymark Ejidos del Moral. P.U. ya con IVA (suma = total tarjeta).
-- 12 renglones · 27 piezas. Stock al escanear + MMAA. No inventar 0000.
-- Nombres de mostrador, no del ticket. Fotos en catalogo-propia/.
-- SIN do $$. Idempotente mientras el ticket siga en borrador.
-- Pegar TODO en Supabase → SQL Editor → Run.
-- ============================================================================

begin;

create temp table _fc_bf42_76370 (
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

insert into _fc_bf42_76370 (
  linea, ean, sku, nombre, snap, qty, costo, precio, tipo, categoria,
  subcategoria, forma, marca, laboratorio, presentacion, principio_activo,
  concentracion, receta, imagen
) values
(1, '070942507240', 'FC-42507240',
 'GUM cera ortodoncia menta',
 'CERA DENT GUM P/ORTODON MENT',
 2, 56.51, 71, 'marca', 'Cuidado personal',
 'Bucal', 'Cera', 'GUM', 'Sunstar',
 'Caja con 5 barras', null, null, false,
 'https://www.farmacapital.mx/catalogo-propia/gum-cera-ortodoncia-menta-070942507240.jpg'),
(2, '7502221012303', 'FC-21012303',
 'Claris toallas desmaquillantes aloe',
 'TAS HUM CLARIS DESMAQ ALOE C/40',
 4, 18.86, 24, 'marca', 'Cuidado personal',
 'Desmaquillante', 'Toallas húmedas', 'Claris', 'Betone',
 'Caja con 40 piezas', null, null, false,
 'https://www.farmacapital.mx/catalogo-propia/claris-toallas-desmaquillantes-aloe-40-7502221012303.jpg'),
(3, '7506306217669', 'FC-06217669',
 'Pond''s gel limpiador facial sandía',
 'GEL LIM PONDS FAC 2EN1 SAND 200ML',
 1, 104.83, 132, 'marca', 'Cuidado personal',
 'Limpieza facial', 'Gel', 'Pond''s', 'Unilever',
 'Botella 200 ml', null, null, false,
 'https://www.farmacapital.mx/catalogo-propia/ponds-gel-limpiador-sandia-200ml-7506306217669.jpg'),
(4, '7506306248175', 'FC-06248175',
 'Pond''s gel limpiador facial Vs Manchas',
 'GEL LIMP PONDS VS MANCHA2-1 200ML',
 1, 107.21, 135, 'marca', 'Cuidado personal',
 'Limpieza facial', 'Gel', 'Pond''s', 'Unilever',
 'Botella 200 ml', 'Vitamina C', null, false,
 'https://www.farmacapital.mx/catalogo-propia/ponds-gel-limpiador-vs-manchas-200ml-7506306248175.jpg'),
(5, '7501565603345', 'FC-65603345',
 'Venda enyesada Galia 20 cm',
 'VENDA ENYESADA GALIA 20 CM X 2.75 M',
 1, 36.69, 46, 'marca', 'Botiquín',
 'Material de curación', 'Venda', 'Galia', 'Gal Tex',
 '20 cm × 2.75 m', null, null, false,
 'https://www.farmacapital.mx/catalogo-propia/galia-venda-enyesada-20cm-7501565603345.jpg'),
(6, '7502304290307', 'FC-04290307',
 'GUM kit ortodoncia Bob Esponja',
 'KIT GUM ORTODONCIA BOB ESPONJA',
 1, 105.65, 133, 'marca', 'Cuidado personal',
 'Bucal', 'Kit', 'GUM', 'Sunstar',
 'Kit (cepillo, cera, interdentales, protector)', null, null, false,
 'https://www.farmacapital.mx/catalogo-propia/gum-kit-ortodoncia-bob-esponja-7502304290307.jpg'),
(7, '070942125352', 'FC-42125352',
 'GUM kit ortodoncia 6 piezas',
 'KIT DE ORTODONCIA GUM 6PZAS',
 1, 130.02, 163, 'marca', 'Cuidado personal',
 'Bucal', 'Kit', 'GUM', 'Sunstar',
 'Kit con 6 piezas', null, null, false,
 'https://www.farmacapital.mx/catalogo-propia/gum-kit-ortodoncia-6pzas-070942125352.jpg'),
(8, '070942304542', 'FC-42304542',
 'GUM hilo dental + enhebrador',
 'HILO DENT GUM + ENHEBRADOR 22.9M',
 1, 97.54, 122, 'marca', 'Cuidado personal',
 'Bucal', 'Hilo dental', 'GUM', 'Sunstar',
 '22.9 m con enhebrador', null, null, false,
 'https://www.farmacapital.mx/catalogo-propia/gum-hilo-dental-enhebrador-22.9m-070942304542.jpg'),
(9, '7501565603338', 'FC-65603338',
 'Venda enyesada Galia 15 cm',
 'VENDA GALIA ENYESADA 15CMX2.75M N',
 4, 26.79, 34, 'marca', 'Botiquín',
 'Material de curación', 'Venda', 'Galia', 'Gal Tex',
 '15 cm × 2.75 m', null, null, false,
 'https://www.farmacapital.mx/catalogo-propia/galia-venda-enyesada-15cm-7501565603338.jpg'),
(10, '7501565603314', 'FC-65603314',
 'Venda enyesada Galia 5 cm',
 'VENDA ENYESADA GALIA 5 CM X 2.75 M',
 8, 14.21, 18, 'marca', 'Botiquín',
 'Material de curación', 'Venda', 'Galia', 'Gal Tex',
 '5 cm × 2.75 m', null, null, false,
 'https://www.farmacapital.mx/catalogo-propia/galia-venda-enyesada-5cm-7501565603314.jpg'),
(11, '7800005064020', 'FC-05064020',
 'Oral-B Super Floss',
 'HILO DENT ORAL-B SUPER-FLOSS C/50',
 2, 70.02, 88, 'marca', 'Cuidado personal',
 'Bucal', 'Hilo dental', 'Oral-B', 'P&G',
 'Caja con 50 hilos', null, null, false,
 'https://www.farmacapital.mx/catalogo-propia/oral-b-super-floss-50-7800005064020.jpg'),
(12, '7501026462078', 'FC-26462078',
 'Ternura chupón flor-balón con miel',
 'TERNURA FLOR-BALON 18 PZS CHUPON CON MIEL',
 1, 61.02, 77, 'marca', 'Cuidado personal',
 'Bebé', 'Chupón', 'Ternura', 'Carter',
 'Exhibidor con 18 piezas', null, null, false,
 'https://www.farmacapital.mx/catalogo-propia/ternura-chupon-flor-balon-miel-18-7501026462078.jpg');

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
  'Alta Bodega F-42 76370 · 2026-10-30 · listo para pistola',
  t.costo,
  t.precio,
  0, 1, true, t.receta,
  t.marca, t.presentacion, t.forma, t.principio_activo, t.concentracion,
  t.laboratorio, t.imagen, t.imagen
from _fc_bf42_76370 t
where public.fc_buscar_producto_escaneo(t.ean) is null
  and public.fc_buscar_producto_escaneo(t.sku) is null
  and not exists (
    select 1 from public.productos p
    where p.codigo_barras = t.ean or p.sku = t.sku
  );

update public.productos p
set
  costo = t.costo,
  precio = case
    when coalesce(p.precio, 0) <= 1 then t.precio
    else p.precio
  end,
  codigo_barras = coalesce(nullif(btrim(p.codigo_barras), ''), t.ean)
from _fc_bf42_76370 t
where p.id = public.fc_buscar_producto_escaneo(t.ean)
  and (
    p.costo is distinct from t.costo
    or coalesce(p.precio, 0) <= 1
    or nullif(btrim(p.codigo_barras), '') is null
  );

update public.productos p
set
  nombre = case
    when length(trim(coalesce(p.nombre, ''))) < 8
      or p.nombre ~* '^(CERA DENT|TAS HUM|GEL LIM|VENDA |KIT |HILO DENT|TERNURA )'
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
from _fc_bf42_76370 t
where p.id = public.fc_buscar_producto_escaneo(t.ean);

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'Bodega F-42',
  '76370',
  '2026-10-30',
  1192.28,
  'borrador',
  'Ticket Citymark / Bodega F-42 Caja 1/76370 · 30-oct-2026 16:54 · GUM ortodoncia · Pond''s · Galia · Oral-B Super Floss · Ternura · $1,192.28 · cola Recibir; stock al confirmar pistola + MMAA'
where not exists (
  select 1 from public.recepciones
  where folio = '76370' and coalesce(proveedor, '') ilike '%bodega%f-42%'
);

update public.recepciones
set
  total_ticket = 1192.28,
  fecha = '2026-10-30',
  proveedor = 'Bodega F-42',
  notas = 'Ticket Citymark / Bodega F-42 Caja 1/76370 · 30-oct-2026 16:54 · GUM ortodoncia · Pond''s · Galia · Oral-B Super Floss · Ternura · $1,192.28 · cola Recibir; stock al confirmar pistola + MMAA',
  updated_at = now()
where folio = '76370'
  and coalesce(proveedor, '') ilike '%bodega%f-42%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = '76370'
  and coalesce(r.proveedor, '') ilike '%bodega%f-42%'
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
from _fc_bf42_76370 t
join public.recepciones r
  on r.folio = '76370'
 and coalesce(r.proveedor, '') ilike '%bodega%f-42%'
 and r.estado = 'borrador'
left join lateral (
  select public.fc_buscar_producto_escaneo(t.ean) as pid
) v on true
order by t.linea;

commit;

-- select folio, proveedor, total_ticket, estado from recepciones where folio = '76370';
-- select codigo_escaneado, nombre_snapshot, cantidad, costo_estimado, pendiente_alta
-- from recepcion_items where recepcion_id = (select id from recepciones where folio = '76370' limit 1)
-- order by id;
