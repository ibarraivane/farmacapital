-- Altas Nadro 6091110421 + enlazar renglones pendientes de alta.
-- El ticket ya está en Recibir; faltan 5 productos en catálogo.
-- Amcef IM 500 mg (7501349011007 / FC-07F04F88) ya está verde — no se toca.
-- SIN do $$. Pegar TODO → Supabase SQL Editor → Run.
-- Fotos: tras deploy, sql/patch_fotos_nadro_6091110421.sql

begin;

create temp table _fc_alta_nd609 (
  ean text primary key,
  sku text not null,
  nombre text not null,
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
  receta boolean not null
) on commit drop;

insert into _fc_alta_nd609
  (ean, sku, nombre, costo, precio, tipo, categoria, subcategoria,
   marca, presentacion, forma, laboratorio, principio_activo, receta)
values
  ('7501349012011', 'FC-49012011', 'Amcef IV ceftriaxona 1 g', 19.80, 32, 'generico', 'Medicamentos', 'Antibióticos',
   'Amcef', 'Frasco ámpula + diluyente 10 ml', 'Solución inyectable', 'AMSA', 'Ceftriaxona 1 g', true),
  ('7501022112274', 'FC-22112274', 'C-Boost Omega 3 + vitaminas C, E y D', 118.18, 148, 'marca', 'Vitaminas', 'Omega 3',
   'C-Boost', 'Frasco 90 gomitas', 'Gomita', 'Grisi', 'Omega 3 / vitaminas C, E y D', false),
  ('7501853805253', 'FC-53805253', 'Glowy SKN colágeno biotina ácido hialurónico', 49.01, 62, 'marca', 'Vitaminas', 'Colágeno',
   'Natural Health', 'Bolsa 14 gomitas', 'Gomita', 'Natural Health', 'Colágeno / biotina / ácido hialurónico', false),
  ('7503024083439', 'FC-24083439', 'Just Omega 3 DHA EPA', 188.48, 236, 'marca', 'Vitaminas', 'Omega 3',
   'Olnatura Just', 'Frasco 120 gomitas', 'Gomita', 'Olnatura', 'Omega 3 DHA / EPA', false),
  ('7502226293929', 'FC-26293929', 'Metformina LP 500 mg', 77.82, 125, 'generico', 'Medicamentos', 'Antidiabéticos',
   'Alpharma', 'Frasco 30 tabletas', 'Tableta de liberación prolongada', 'Alpharma', 'Metformina 500 mg', true);

-- Altas (solo si el EAN no existe).
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
  'Alta Nadro 6091110421 · listo para pistola',
  t.costo,
  t.precio,
  0,
  1,
  true,
  t.receta
from _fc_alta_nd609 t
where public.fc_buscar_producto_escaneo(t.ean) is null;

-- Ficha de mostrador.
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
  requiere_receta = t.receta,
  costo = t.costo,
  precio = case when coalesce(p.precio, 0) <= 0 then t.precio else p.precio end
from _fc_alta_nd609 t
where p.id = public.fc_buscar_producto_escaneo(t.ean);

-- Enlazar renglones del ticket (quita “sin registrar”).
update public.recepcion_items i
set
  producto_id = public.fc_buscar_producto_escaneo(i.codigo_escaneado),
  pendiente_alta = false
from public.recepciones r
where i.recepcion_id = r.id
  and r.folio = '6091110421'
  and coalesce(r.proveedor, '') ilike '%nadro%'
  and coalesce(i.pendiente_alta, false)
  and i.codigo_escaneado in (
    '7501349012011', '7501022112274', '7501853805253',
    '7503024083439', '7502226293929'
  )
  and public.fc_buscar_producto_escaneo(i.codigo_escaneado) is not null;

commit;

select
  i.codigo_escaneado as ean,
  left(i.nombre_snapshot, 40) as snap,
  i.pendiente_alta,
  i.confirmado,
  p.sku,
  left(p.nombre, 40) as nombre_catalogo
from public.recepcion_items i
join public.recepciones r on r.id = i.recepcion_id
left join public.productos p on p.id = i.producto_id
where r.folio = '6091110421' and coalesce(r.proveedor, '') ilike '%nadro%'
order by i.id;
