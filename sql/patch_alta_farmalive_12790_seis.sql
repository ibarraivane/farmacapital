-- Farmalive 12790: las 6 amarillas no están en catálogo.
-- El SQL del ticket solo abrió la cola. No insertó productos.
-- FC-33950100 es Ensure 236 ml (7501033950100), no este de 237 ml.
-- Marca +25% al costo. Stock 0. No inventa caducidad.
-- TODO foto: Teatrical 19 g, Gotinal, Aspirina 3-pack, Ensure 237 ml.
-- No usar placeholder de otra cadena.
-- Pegar TODO este archivo en Supabase → SQL Editor → Run.
-- Recargar Recibir. Las 6 pasan a gris. Escanea y pon el MMAA de la caja.

begin;

create temp table _fc_alta_12790_6 (
  ean text primary key,
  ticket text not null,
  sku text not null,
  nombre text not null,
  marca text not null,
  laboratorio text not null,
  presentacion text not null,
  forma_farmaceutica text not null,
  categoria text not null,
  subcategoria text not null,
  principio_activo text,
  concentracion text,
  costo numeric(12,2) not null,
  precio numeric(12,2) not null
) on commit drop;

insert into _fc_alta_12790_6 values
  (
    '6502400079009', '650240079009',
    'FC-00079009',
    'Crema Teatrical rosa lanolina 19 g',
    'Teatrical', 'Genomma', 'Tarro 19 g', 'Crema',
    'Cuidado personal', 'Facial', 'Lanolina', null,
    15.11, 19
  ),
  (
    '6502400078996', '650240078996',
    'FC-00078996',
    'Crema Teatrical azul 19 g',
    'Teatrical', 'Genomma', 'Tarro 19 g', 'Crema',
    'Cuidado personal', 'Facial', null, null,
    15.11, 19
  ),
  (
    '7501088509926', '7501088509926',
    'FC-88509926',
    'Gotinal adulto nafazolina 1 mg/ml spray 15 ml',
    'Gotinal', 'Chinoin', 'Atomizador 15 ml', 'Spray nasal',
    'Respiratorio', 'Descongestionante', 'Nafazolina', '1 mg/ml',
    127.30, 160
  ),
  (
    '7501033954061', '7501033954061',
    'FC-33954061',
    'Ensure líquido chocolate 237 ml',
    'Ensure', 'Abbott', 'Botella 237 ml', 'Líquido',
    'Suplemento', 'Nutrición', null, null,
    42.63, 54
  ),
  (
    '7501008499429', '7501008499429',
    'FC-08499429',
    'Aspirina tabletas 500 mg C/40 3-pack',
    'Aspirina', 'Bayer', '3 cajas con 40 tabletas', 'Tableta',
    'Analgésico', 'Dolor', 'Ácido acetilsalicílico', '500 mg',
    115.15, 144
  ),
  (
    '7501008499245', '7501008499245',
    'FC-08499245',
    'Aspirina GO 500 mg granulado naranja C/10 sobres',
    'Aspirina', 'Bayer', 'Caja con 10 sobres', 'Granulado',
    'Analgésico', 'Dolor', 'Ácido acetilsalicílico', '500 mg',
    58.80, 74
  );

insert into public.productos (
  nombre, sku, codigo_barras, categoria, subcategoria, tipo, descripcion,
  costo, precio, stock, stock_minimo, activo, requiere_receta,
  marca, laboratorio, presentacion, forma_farmaceutica,
  principio_activo, concentracion
)
select
  t.nombre,
  case
    when exists (
      select 1 from public.productos p
      where p.sku = t.sku
        and coalesce(p.codigo_barras, '') <> t.ean
        and not public.fc_match_codigo_barras(t.ean, p.codigo_barras)
    ) then 'FC-ND-' || right(t.ean, 8)
    else t.sku
  end,
  t.ean,
  t.categoria,
  t.subcategoria,
  'marca',
  'Alta Farmalive 12790 · ' || t.nombre || ' · EAN ' || t.ean || ' · ticket ' || t.ticket || ' · foto pendiente',
  t.costo,
  t.precio,
  0,
  1,
  true,
  false,
  t.marca,
  t.laboratorio,
  t.presentacion,
  t.forma_farmaceutica,
  t.principio_activo,
  t.concentracion
from _fc_alta_12790_6 t
where public.fc_buscar_producto_escaneo(t.ean) is null
  and public.fc_buscar_producto_escaneo(t.ticket) is null
  and not exists (
    select 1 from public.productos p
    where p.codigo_barras in (t.ean, t.ticket)
       or public.fc_match_codigo_barras(t.ean, p.codigo_barras)
       or public.fc_match_codigo_barras(t.ticket, p.codigo_barras)
  );

update public.productos p
set
  costo = t.costo,
  precio = case when coalesce(p.precio, 0) <= 0 then t.precio else p.precio end,
  activo = true,
  marca = coalesce(nullif(btrim(p.marca), ''), t.marca),
  laboratorio = coalesce(nullif(btrim(p.laboratorio), ''), t.laboratorio),
  presentacion = coalesce(nullif(btrim(p.presentacion), ''), t.presentacion),
  forma_farmaceutica = coalesce(nullif(btrim(p.forma_farmaceutica), ''), t.forma_farmaceutica),
  principio_activo = coalesce(nullif(btrim(p.principio_activo), ''), t.principio_activo),
  concentracion = coalesce(nullif(btrim(p.concentracion), ''), t.concentracion)
from _fc_alta_12790_6 t
where public.fc_match_codigo_barras(t.ean, p.codigo_barras)
   or public.fc_match_codigo_barras(t.ticket, p.codigo_barras)
   or p.codigo_barras in (t.ean, t.ticket);

update public.recepcion_items i
set
  producto_id = p.id,
  pendiente_alta = false
from public.recepciones r,
     _fc_alta_12790_6 t,
     public.productos p
where i.recepcion_id = r.id
  and coalesce(r.proveedor, '') ilike '%farmalive%'
  and regexp_replace(coalesce(r.folio, ''), '\D', '', 'g') in ('12790', '127790', '127900')
  and not coalesce(i.confirmado, false)
  and (
    public.fc_match_codigo_barras(t.ean, p.codigo_barras)
    or p.codigo_barras in (t.ean, t.ticket)
  )
  and (
    regexp_replace(coalesce(i.codigo_escaneado, ''), '\D', '', 'g') in (t.ean, t.ticket)
    or (
      t.ticket = '650240079009'
      and i.nombre_snapshot ilike '%teatrical%'
      and i.nombre_snapshot ilike '%rosa%'
      and i.nombre_snapshot ilike '%19%'
    )
    or (
      t.ticket = '650240078996'
      and i.nombre_snapshot ilike '%teatrical%'
      and i.nombre_snapshot ilike '%azul%'
      and i.nombre_snapshot ilike '%19%'
    )
    or (
      t.ean = '7501088509926'
      and i.nombre_snapshot ilike '%gotinal%'
    )
    or (
      t.ean = '7501033954061'
      and i.nombre_snapshot ilike '%ensure%'
      and i.nombre_snapshot ilike '%choco%'
    )
    or (
      t.ean = '7501008499429'
      and i.nombre_snapshot ilike '%aspirina%'
      and i.nombre_snapshot ilike '%3-pack%'
    )
    or (
      t.ean = '7501008499245'
      and i.nombre_snapshot ilike '%aspirina%'
      and i.nombre_snapshot ilike '%go%'
    )
  );

select
  t.ticket,
  t.nombre,
  p.sku,
  p.codigo_barras,
  p.precio,
  i.pendiente_alta,
  i.cantidad
from _fc_alta_12790_6 t
left join public.productos p
  on public.fc_match_codigo_barras(t.ean, p.codigo_barras)
  or p.codigo_barras in (t.ean, t.ticket)
left join public.recepcion_items i
  on i.producto_id = p.id
left join public.recepciones r
  on r.id = i.recepcion_id
 and coalesce(r.proveedor, '') ilike '%farmalive%'
 and regexp_replace(coalesce(r.folio, ''), '\D', '', 'g') in ('12790', '127790', '127900')
order by t.nombre;

commit;
