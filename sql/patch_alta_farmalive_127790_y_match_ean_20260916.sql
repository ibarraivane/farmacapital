-- ============================================================================
-- Recibir: 25 EANs sin catálogo (Farmalive 127790) + match pistola
--
-- Recuadro rojo de Recibir. Gargax 650240028335 y QG5 650240069277
-- son los renglones amarillos «Pendiente de alta».
-- Teatrical 650240013850 y Ensure 7501033954061 YA están: el ticket
-- trae 12 dígitos / el catálogo 13. fc_match no los veía.
--
-- Stock 0 hasta Recibir + MMAA de la caja. Sin inventar caducidad.
-- SKU = FC- + últimos 8 del EAN (skuAltaRecepcion).
-- Fichas: Fahorro / Farmatodo / DISA / Sanborns — no el código del PDF.
-- Fotos en public/catalogo-propia/ → tras el deploy quedan en
--   https://www.farmacapital.mx/catalogo-propia/…
-- Pegar TODO en Supabase → SQL Editor → Run.
-- ============================================================================

begin;

-- Ticket 12 dígitos (Genomma/OCR) ↔ catálogo con dígito verificador.
create or replace function public.fc_match_codigo_barras(p_scan text, p_stored text)
returns boolean
language sql
immutable
parallel safe
as $$
  with n as (
    select
      regexp_replace(coalesce(p_scan, ''), '\D', '', 'g') as scan,
      regexp_replace(coalesce(p_stored, ''), '\D', '', 'g') as stored
  )
  select
    case
      when n.scan = '' or n.stored = '' then false
      when n.scan = n.stored then true
      when length(n.scan) >= 12 and length(n.stored) >= 12
        and right(n.scan, 12) = right(n.stored, 12) then true
      when length(n.scan) = 12 and length(n.stored) = 13
        and n.stored = '0' || n.scan then true
      when length(n.stored) = 12 and length(n.scan) = 13
        and n.scan = '0' || n.stored then true
      when length(n.scan) >= 8 and length(n.stored) = length(n.scan) + 1
        and n.stored like n.scan || '_' then true
      when length(n.stored) >= 8 and length(n.scan) = length(n.stored) + 1
        and n.scan like n.stored || '_' then true
      when n.scan in ('7501868900233', '7501868990023')
       and n.stored in ('7501868900233', '7501868990023') then true
      when n.scan in ('747589705123', '714706903205')
       and n.stored in ('747589705123', '714706903205') then true
      else false
    end
  from n;
$$;

grant execute on function public.fc_match_codigo_barras(text, text) to anon, authenticated, service_role;

create temp table _fc_alta_fl127790 (
  ean text primary key,
  sku text not null,
  nombre text not null,
  marca text not null,
  presentacion text not null,
  forma_farmaceutica text,
  categoria text not null,
  subcategoria text,
  descripcion text not null,
  precio numeric(12,2) not null,
  foto text
) on commit drop;

insert into _fc_alta_fl127790 values
  (
    '650240028335', 'FC-40028335',
    'Gargax benzocaína 2.5% solución bucofaríngea 60 ml',
    'Genomma', 'Frasco 60 ml', 'Solución',
    'Medicamentos', 'Garganta',
    'Farmalive 127790 · Fahorro/Sanborns Gargax 60 ml EAN 650240028335',
    149, 'https://www.farmacapital.mx/catalogo-propia/gargax-solucion-60ml.jpg'
  ),
  (
    '650240069277', 'FC-40069277',
    'QG5 alivio para la colitis 30 tabletas',
    'Genomma', 'Caja con 30 tabletas', 'Tableta',
    'Medicamentos', 'Digestivo',
    'Farmalive 127790 · Fahorro QG5 colitis C/30 EAN 650240069277 · Psidium guajava',
    284, 'https://www.farmacapital.mx/catalogo-propia/qg5-30-tabletas.jpg'
  ),
  (
    '7501065013767', 'FC-65013767',
    'Advil ibuprofeno 200 mg C/12',
    'Advil', 'Caja con 12 cápsulas', 'Cápsula',
    'Medicamentos', 'Analgésico',
    'Farmalive 127790 · DISA/Sanorim Advil 200 mg C/12 EAN 7501065013767',
    55, null
  ),
  (
    '7502214982446', 'FC-14982446',
    'Prudence Terremoto anillo vibrador + condón',
    'Prudence', '1 anillo + 1 condón', 'Dispositivo',
    'Cuidado personal', 'Salud sexual',
    'Farmalive 127790 · Fahorro/DISA Prudence Terremoto EAN 7502214982446',
    171, 'https://www.farmacapital.mx/catalogo-propia/prudence-anillo-terremoto.jpg'
  ),
  (
    '7502214986031', 'FC-14986031',
    'Prudence gel lubricante íntimo Natural 100 ml',
    'Prudence', 'Frasco 100 ml', 'Gel',
    'Cuidado personal', 'Salud sexual',
    'Farmalive 127790 · Fahorro Prudence gel Natural 100 ml EAN 7502214986031',
    168, 'https://www.farmacapital.mx/catalogo-propia/prudence-gel-natural-100ml.jpg'
  ),
  (
    '650240036187', 'FC-40036187',
    'Kaopectate antidiarreico 10 tabletas',
    'Kaopectate', 'Caja con 10 tabletas', 'Tableta',
    'Medicamentos', 'Digestivo',
    'Farmalive 127790 · Fahorro Kaopectate C/10 EAN 650240036187',
    81, 'https://www.farmacapital.mx/catalogo-propia/kaopectate-10-tabletas.jpg'
  ),
  (
    '3600542641074', 'FC-42641074',
    'Garnier Pure Active Pimple Patch 22 parches',
    'Garnier', 'Caja 22 parches', 'Parche',
    'Cuidado personal', 'Acné',
    'Farmalive 127790 · Fahorro Garnier Pimple Patch 22 EAN 3600542641074',
    119, 'https://www.farmacapital.mx/catalogo-propia/garnier-pimple-patch-22.jpg'
  ),
  (
    '7501122962816', 'FC-22962816',
    'Espavén Alcalino suspensión 360 ml',
    'Espavén', 'Frasco 360 ml', 'Suspensión',
    'Medicamentos', 'Digestivo',
    'Farmalive 127790 · Farmatodo Espavén Alcalino 360 ml EAN 7501122962816',
    89, 'https://www.farmacapital.mx/catalogo-propia/espaven-alcalino-360ml.jpg'
  ),
  (
    '3614225108785', 'FC-25108785',
    'Koleston tinte permanente 50 Castaño Claro',
    'Koleston', 'Kit 1 aplicación', 'Crema',
    'Cuidado personal', 'Tinte',
    'Farmalive 127790 · Farmatodo Koleston 50 Castaño Claro EAN 3614225108785',
    87, 'https://www.farmacapital.mx/catalogo-propia/koleston-50-castano-claro.jpg'
  ),
  (
    '7501098603867', 'FC-98603867',
    'Losec A 20 mg C/14 cápsulas',
    'Losec A', 'Caja con 14 cápsulas', 'Cápsula',
    'Medicamentos', 'Digestivo',
    'Farmalive 127790 · Fahorro Losec A 20 mg C/14 EAN 7501098603867 · omeprazol',
    109, 'https://www.farmacapital.mx/catalogo-propia/losec-a-20-14.jpg'
  ),
  (
    '7501369200085', 'FC-69200085',
    'Estomaquil polvo 3 g C/10 sobres',
    'Higia', 'Caja con 10 sobres', 'Polvo',
    'Medicamentos', 'Digestivo',
    'Farmalive 127790 · Fahorro Estomaquil C/10 EAN 7501369200085 · distinto de C/20 7501369200016',
    88, null
  ),
  (
    '7502214983207', 'FC-14983207',
    'Prudence Lub lubricante comestible Uva 75 ml',
    'Prudence', 'Frasco 75 ml', 'Gel',
    'Cuidado personal', 'Salud sexual',
    'Farmalive 127790 · Fahorro Prudence Uva 75 ml EAN 7502214983207',
    100, 'https://www.farmacapital.mx/catalogo-propia/prudence-lub-uva-75ml.jpg'
  ),
  (
    '7501065028785', 'FC-65028785',
    'Mejoral 500 mg C/12 tabletas',
    'Mejoral', 'Caja con 12 tabletas', 'Tableta',
    'Medicamentos', 'Analgésico',
    'Farmalive 127790 · Haleon Mejoral 500 mg C/12 EAN 7501065028785 · foto pendiente',
    45, null
  ),
  (
    '020800600347', 'FC-00600347',
    'Tampax Super Plus tampones C/10',
    'Tampax', 'Caja con 10', 'Tampones',
    'Higiene', 'Higiene menstrual',
    'Farmalive 127790 · Fahorro Tampax Super Plus C/10 EAN 020800600347',
    59, 'https://www.farmacapital.mx/catalogo-propia/tampax-super-plus-10.jpg'
  ),
  (
    '7501108763468', 'FC-08763468',
    'Advil ibuprofeno 200 mg C/20 cápsulas',
    'Advil', 'Caja con 20 cápsulas', 'Cápsula',
    'Medicamentos', 'Analgésico',
    'Farmalive 127790 · Farmalisto Advil 200 mg C/20 EAN 7501108763468',
    116, 'https://www.farmacapital.mx/catalogo-propia/advil-200-20-caps.jpg'
  ),
  (
    '7501065065322', 'FC-65065322',
    'Advil 12 horas 600 mg C/6 tabletas',
    'Advil', 'Caja con 6 tabletas', 'Tableta',
    'Medicamentos', 'Analgésico',
    'Farmalive 127790 · WeCare Advil 12H 600 mg C/6 EAN 7501065065322 · foto pendiente',
    89, null
  ),
  (
    '7506460101460', 'FC-60101460',
    'Sico Play Retardante condones C/3',
    'Sico', 'Caja con 3', 'Condón',
    'Cuidado personal', 'Salud sexual',
    'Farmalive 127790 · Prixz/GDL Sico Play Retardante C/3 EAN 7506460101460 · foto pendiente',
    74, null
  );

insert into public.productos (
  nombre, sku, codigo_barras, categoria, tipo, descripcion,
  costo, precio, stock, stock_minimo, activo, requiere_receta,
  marca, presentacion, forma_farmaceutica, subcategoria,
  imagen_url, imagen_mobile_url
)
select
  t.nombre,
  case
    when exists (
      select 1 from public.productos p
      where p.sku = t.sku
        and coalesce(p.codigo_barras, '') <> t.ean
    ) then 'FC-ND-' || right(t.ean, 8)
    else t.sku
  end,
  t.ean,
  t.categoria,
  'marca',
  t.descripcion,
  null,
  t.precio,
  0,
  1,
  true,
  false,
  t.marca,
  t.presentacion,
  t.forma_farmaceutica,
  t.subcategoria,
  t.foto,
  t.foto
from _fc_alta_fl127790 t
where public.fc_buscar_producto_escaneo(t.ean) is null
  and not exists (
    select 1 from public.productos p
    where p.codigo_barras = t.ean
       or (p.sku = t.sku and coalesce(p.codigo_barras, '') = t.ean)
  );

-- Lo que el ticket ya nombró (Genomma 650240079009 / 650240078996, etc.)
-- y aún no tiene ficha: alta con el nombre de mostrador del renglón.
insert into public.productos (
  nombre, sku, codigo_barras, categoria, tipo, descripcion,
  costo, precio, stock, stock_minimo, activo, requiere_receta
)
select distinct on (i.codigo_escaneado)
  coalesce(nullif(btrim(i.nombre_snapshot), ''), 'Producto ' || i.codigo_escaneado),
  case
    when exists (
      select 1 from public.productos p
      where p.sku = 'FC-' || right(regexp_replace(i.codigo_escaneado, '\D', '', 'g'), 8)
        and coalesce(p.codigo_barras, '') <> regexp_replace(i.codigo_escaneado, '\D', '', 'g')
    ) then 'FC-ND-' || right(regexp_replace(i.codigo_escaneado, '\D', '', 'g'), 8)
    else 'FC-' || right(regexp_replace(i.codigo_escaneado, '\D', '', 'g'), 8)
  end,
  regexp_replace(i.codigo_escaneado, '\D', '', 'g'),
  'Otro',
  'marca',
  'Alta Recibir Farmalive 127790 · EAN ' || i.codigo_escaneado || ' · ficha desde renglón del ticket',
  null,
  coalesce(i.costo_estimado, 0) * 1.25,
  0,
  1,
  true,
  false
from public.recepcion_items i
join public.recepciones r on r.id = i.recepcion_id
where coalesce(r.proveedor, '') ilike '%farmalive%'
  and r.folio = '127790'
  and coalesce(i.pendiente_alta, false)
  and i.producto_id is null
  and length(regexp_replace(coalesce(i.codigo_escaneado, ''), '\D', '', 'g')) >= 8
  and public.fc_buscar_producto_escaneo(i.codigo_escaneado) is null
  and not exists (
    select 1 from public.productos p
    where public.fc_match_codigo_barras(i.codigo_escaneado, p.codigo_barras)
  )
order by i.codigo_escaneado, i.id;

insert into public.producto_imagenes
  (producto_id, url, storage_path, posicion, es_principal, origen)
select
  p.id,
  t.foto,
  'catalogo-propia/' || regexp_replace(t.foto, '^.*/', ''),
  coalesce((select max(i.posicion) from public.producto_imagenes i where i.producto_id = p.id), 0) + 1,
  false,
  'propia'
from _fc_alta_fl127790 t
join public.productos p
  on public.fc_match_codigo_barras(t.ean, p.codigo_barras)
where t.foto is not null
  and not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id
      and i.url = t.foto
  );

update public.producto_imagenes i
set es_principal = false
from _fc_alta_fl127790 t
join public.productos p
  on public.fc_match_codigo_barras(t.ean, p.codigo_barras)
where i.producto_id = p.id
  and t.foto is not null
  and coalesce(i.es_principal, false)
  and i.url is distinct from t.foto;

update public.producto_imagenes i
set es_principal = true
from _fc_alta_fl127790 t
join public.productos p
  on public.fc_match_codigo_barras(t.ean, p.codigo_barras)
where i.producto_id = p.id
  and t.foto is not null
  and i.url = t.foto
  and not coalesce(i.es_principal, false);

-- Enlaza grises de cualquier ticket vivo (Farmalive 127790 + Teatrical/Ensure).
update public.recepcion_items i
set
  producto_id = public.fc_buscar_producto_escaneo(i.codigo_escaneado),
  pendiente_alta = false
where coalesce(i.pendiente_alta, false)
  and (i.producto_id is null)
  and nullif(btrim(i.codigo_escaneado), '') is not null
  and public.fc_buscar_producto_escaneo(i.codigo_escaneado) is not null;

-- Gargax / QG5 del ticket a veces vienen sin EAN en codigo_escaneado.
update public.recepcion_items i
set
  producto_id = p.id,
  pendiente_alta = false,
  codigo_escaneado = coalesce(nullif(btrim(i.codigo_escaneado), ''), p.codigo_barras)
from public.recepciones r,
     public.productos p
where i.recepcion_id = r.id
  and r.folio = '127790'
  and coalesce(r.proveedor, '') ilike '%farmalive%'
  and coalesce(i.pendiente_alta, false)
  and i.producto_id is null
  and (
    (i.nombre_snapshot ilike '%gargax%' and p.codigo_barras = '650240028335')
    or (i.nombre_snapshot ilike '%qg5%' and p.codigo_barras = '650240069277')
  );

commit;

select
  r.folio,
  r.proveedor,
  count(*) as renglones,
  count(*) filter (where i.pendiente_alta) as siguen_pendiente_alta,
  count(*) filter (where i.producto_id is not null) as con_producto
from public.recepciones r
join public.recepcion_items i on i.recepcion_id = r.id
where r.folio in ('127790', '20260914')
group by r.folio, r.proveedor
order by r.folio;

select
  i.codigo_escaneado as ean,
  left(i.nombre_snapshot, 48) as ticket,
  case when i.pendiente_alta then 'SIGUE PENDIENTE' else 'OK' end as estado,
  left(p.nombre, 48) as catalogo
from public.recepcion_items i
join public.recepciones r on r.id = i.recepcion_id
left join public.productos p on p.id = i.producto_id
where r.folio = '127790'
  and coalesce(r.proveedor, '') ilike '%farmalive%'
order by i.pendiente_alta desc, i.id;
