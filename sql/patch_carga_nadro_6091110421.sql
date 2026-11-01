-- Factura Nadro folio 6091110421 (2026-10-13) — altas + cola Recibir.
-- CFDI 13-oct-2026 · total $720.23 · 11 piezas · 6 renglones
-- SIN bloques dollar-quote (do $$). El SQL Editor de Supabase los corta.
-- 5 altas stock 0. Amcef IM 500 mg ya en catálogo (FC-07F04F88).
-- Ficha desde iNadro / retailer (no código del ticket). LGEN no es marca.
-- Just Omega EAN 7503024083439 (foto OCR …438 inválido). Metformina 7502226293929.
-- Ticket borrador. Stock al escanear + MMAA de la caja. No inventar 0000.
-- Idempotente mientras el ticket siga en borrador.
-- Pegar TODO este archivo en Supabase → SQL Editor → Run.
-- Fotos: tras deploy, pegar sql/patch_fotos_nadro_6091110421.sql

begin;

create temp table _fc_nd6091110421 (
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
  receta boolean not null,
  alta_nueva boolean not null
) on commit drop;

insert into _fc_nd6091110421
  (linea, ean, sku, nombre, snap, qty, costo, precio, tipo, categoria, subcategoria,
   marca, presentacion, forma, laboratorio, principio_activo, receta, alta_nueva)
values
  (1, '7501349012011', 'FC-49012011', 'Amcef IV ceftriaxona 1 g', 'AMCEF CEFTRIA 1G SI FA 10ML LGEN', 1, 19.80, 32, 'generico', 'Medicamentos', 'Antibióticos', 'Amcef', 'Frasco ámpula + diluyente 10 ml', 'Solución inyectable', 'AMSA', 'Ceftriaxona 1 g', true, true),
  (2, '7501349011007', 'FC-07F04F88', 'Amcef IM ceftriaxona 500 mg', 'AMCEF IM CEFT500MG SI FA 2ML LGEN', 4, 16.10, 26, 'generico', 'Medicamentos', 'Antibióticos', 'Amcef', 'Frasco ámpula + diluyente 2 ml', 'Solución inyectable', 'AMSA', 'Ceftriaxona 500 mg', true, false),
  (3, '7501022112274', 'FC-22112274', 'C-Boost Omega 3 + vitaminas C, E y D', 'C-BOOST SUP ALIM OMEGA3 FCO 90GOM', 1, 118.18, 148, 'marca', 'Vitaminas', 'Omega 3', 'C-Boost', 'Frasco 90 gomitas', 'Gomita', 'Grisi', 'Omega 3 / vitaminas C, E y D', false, true),
  (4, '7501853805253', 'FC-53805253', 'Glowy SKN colágeno biotina ácido hialurónico', 'COLAG/BIOTA HIA S ALIM FSA 14GOM', 2, 49.01, 62, 'marca', 'Vitaminas', 'Colágeno', 'Natural Health', 'Bolsa 14 gomitas', 'Gomita', 'Natural Health', 'Colágeno / biotina / ácido hialurónico', false, true),
  (5, '7503024083439', 'FC-24083439', 'Just Omega 3 DHA EPA', 'JUST OMEGA3 S ALIM DHA EPA 120 GOM', 1, 188.48, 236, 'marca', 'Vitaminas', 'Omega 3', 'Olnatura Just', 'Frasco 120 gomitas', 'Gomita', 'Olnatura', 'Omega 3 DHA / EPA', false, true),
  (6, '7502226293929', 'FC-26293929', 'Metformina LP 500 mg', 'METFORMINA LP 500 MG 30 TAB LGEN', 2, 77.82, 125, 'generico', 'Medicamentos', 'Antidiabéticos', 'Alpharma', 'Frasco 30 tabletas', 'Tableta de liberación prolongada', 'Alpharma', 'Metformina 500 mg', true, true);

-- Altas nuevas (solo si el EAN no existe).
insert into public.productos (
  nombre, sku, codigo_barras, categoria, tipo, descripcion,
  costo, precio, stock, stock_minimo, activo, requiere_receta
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
  t.tipo,
  'Alta Nadro 6091110421 · 2026-10-13 · listo para pistola',
  t.costo,
  t.precio,
  0,
  1,
  true,
  t.receta
from _fc_nd6091110421 t
where t.alta_nueva
  and public.fc_buscar_producto_escaneo(t.ean) is null;

-- Enlazar EAN a SKU ya existente (Amcef IM) si faltaba código de barras.
update public.productos p
set codigo_barras = t.ean
from _fc_nd6091110421 t
where not t.alta_nueva
  and p.sku = t.sku
  and (
    p.codigo_barras is null
    or btrim(p.codigo_barras) = ''
    or p.codigo_barras = t.ean
  )
  and public.fc_buscar_producto_escaneo(t.ean) is null;

-- Ficha de mostrador (marca real, no casa Nadro LGEN).
update public.productos p set
  marca = coalesce(nullif(btrim(t.marca), ''), p.marca),
  presentacion = t.presentacion,
  forma_farmaceutica = t.forma,
  principio_activo = t.principio_activo,
  subcategoria = t.subcategoria,
  laboratorio = coalesce(nullif(btrim(t.laboratorio), ''), nullif(btrim(p.laboratorio), ''), t.laboratorio),
  nombre = t.nombre,
  categoria = t.categoria,
  tipo = t.tipo,
  requiere_receta = t.receta
from _fc_nd6091110421 t
where p.id = coalesce(
  public.fc_buscar_producto_escaneo(t.ean),
  public.fc_buscar_producto_escaneo(t.sku)
);

-- Costos del ticket (PVP solo si estaba en 0).
update public.productos p
set
  costo = t.costo,
  precio = case
    when coalesce(p.precio, 0) <= 0 then t.precio
    else p.precio
  end
from _fc_nd6091110421 t
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
  '6091110421',
  '2026-10-13',
  720.23,
  'borrador',
  'Factura Nadro 6091110421 · 13-10-26 · CFDI foto · cola Recibir; stock al confirmar pistola · Just/Metformina EAN verificador'
where not exists (
  select 1 from public.recepciones
  where folio = '6091110421' and coalesce(proveedor, '') ilike '%nadro%'
);

update public.recepciones
set
  total_ticket = 720.23,
  fecha = '2026-10-13',
  proveedor = 'Nadro',
  notas = 'Factura Nadro 6091110421 · 13-10-26 · CFDI foto · cola Recibir; stock al confirmar pistola · Just/Metformina EAN verificador',
  updated_at = now()
where folio = '6091110421'
  and coalesce(proveedor, '') ilike '%nadro%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = '6091110421'
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
  (
    v.pid is not null and exists (
      select 1 from public.lotes l
      where l.producto_id = v.pid
        and coalesce(l.activo, true)
        and coalesce(l.cantidad_actual, 0) > 0
    )
  ),
  null
from _fc_nd6091110421 t
join public.recepciones r
  on r.folio = '6091110421'
 and coalesce(r.proveedor, '') ilike '%nadro%'
 and r.estado = 'borrador'
left join lateral (
  select coalesce(
    public.fc_buscar_producto_escaneo(t.ean),
    public.fc_buscar_producto_escaneo(t.sku)
  ) as pid
) v on true
order by t.linea;

commit;

select
  i.id,
  i.codigo_escaneado as ean,
  left(i.nombre_snapshot, 48) as nombre,
  i.cantidad,
  i.costo_estimado,
  case when i.pendiente_alta then 'ALTA NUEVA' else 'YA EXISTE' end as estado,
  p.sku,
  left(p.nombre, 48) as nombre_catalogo
from public.recepcion_items i
join public.recepciones r on r.id = i.recepcion_id
left join public.productos p on p.id = i.producto_id
where r.folio = '6091110421' and coalesce(r.proveedor, '') ilike '%nadro%'
order by i.id;
