-- ============================================================================
-- Recibir: 6 EANs que siguen en rojo (Farmalive 127790) + tickets reabiertos
--
-- Qué pasó:
--   1) El patch anterior enlazó pendiente_alta en CUALQUIER ticket.
--      Altas viejas (ya recibidas, solo faltaba catálogo) se volvieron
--      grises «por recibir» y esos pedidos regresaron a la cola.
--   2) Quedan 6 códigos en el recuadro rojo:
--        650240079009 ×3  ·  650240078996 ×3  (Genomma; nombre del ticket)
--        7501088599926 ×1 (nombre del ticket; no inventar Gotinal)
--        7501033954061 ×1 Ensure chocolate — YA está (FC-33950100)
--        7501008849949 ×1 Aspirina tabletas C/40 3-pack Bayer
--        7501008499245 ×10 Aspirina GO 500 mg C/10 sobres Bayer
--
-- Esto:
--   1) Cierra otra vez lo ya recibido (estado pendiente_alta, sin MMAA
--      pendiente). No toca Farmalive 127790 ni Equilibrio 20260914.
--   2) Da de alta Aspirina GO / Aspirina 3-pack. Enlaza Ensure.
--      Genomma y el EAN Chinoin: alta con el nombre de mostrador del
--      renglón (no el código del PDF).
--   3) Enlaza SOLO Farmalive 127790 (y Equilibrio Ensure/Teatrical).
--
-- Stock 0 hasta Recibir + MMAA de ESTA caja. Sin inventar caducidad.
-- SKU = FC- + últimos 8 del EAN. Foto Aspirina GO: catalogo-propia/
-- Pegar TODO en Supabase → SQL Editor → Run. Idempotente.
-- ============================================================================

begin;

-- 1) Tickets ya recibidos que el UPDATE global reabrió como «por recibir».
--    estado=pendiente_alta = lo escaneable ya estaba verde; solo
--    quedaban altas. No inventa MMAA. No toca Farmalive 127790
--    ni Equilibrio 20260914 (siguen con cajas pendientes).
update public.recepciones r
set
  estado = 'confirmada',
  cerrado_en = coalesce(r.cerrado_en, r.updated_at)
where r.estado = 'pendiente_alta'
  and not (r.folio = '127790' and coalesce(r.proveedor, '') ilike '%farmalive%')
  and r.folio is distinct from '20260914'
  and exists (
    select 1 from public.recepcion_items i
    where i.recepcion_id = r.id and coalesce(i.confirmado, false)
  )
  and not exists (
    select 1 from public.recepcion_items i
    where i.recepcion_id = r.id
      and not coalesce(i.confirmado, false)
      and (i.fecha_caducidad is not null or i.lote_id is not null)
  );

-- 2) Ensure chocolate ya está. Si quedó inactivo, fc_buscar no lo ve.
update public.productos
set activo = true
where (sku = 'FC-33950100' or codigo_barras = '7501033954061')
  and coalesce(activo, true) is distinct from true;

create temp table _fc_alta_fl127790_6 (
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

insert into _fc_alta_fl127790_6 values
  (
    '7501008499245', 'FC-08499245',
    'Aspirina GO 500 mg granulado naranja C/10 sobres',
    'Aspirina', 'Caja con 10 sobres', 'Granulado',
    'Medicamentos', 'Analgésico',
    'Farmalive 127790 · Fahorro/Sanborns Aspirina GO 500 mg C/10 EAN 7501008499245',
    99, 'https://www.farmacapital.mx/catalogo-propia/aspirina-go-500-10-sobres.jpg'
  ),
  (
    '7501008849949', 'FC-08849949',
    'Aspirina tabletas 500 mg C/40 3-pack',
    'Aspirina', '3 cajas con 40 tabletas', 'Tableta',
    'Medicamentos', 'Analgésico',
    'Farmalive 127790 · ticket Aspirina C/40 3-pack Bayer · EAN 7501008849949 · foto pendiente',
    165, null
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
from _fc_alta_fl127790_6 t
where public.fc_buscar_producto_escaneo(t.ean) is null
  and not exists (
    select 1 from public.productos p
    where p.codigo_barras = t.ean
       or (p.sku = t.sku and coalesce(p.codigo_barras, '') = t.ean)
  );

-- Genomma 650240079009 / 650240078996 y 7501088599926:
-- el ticket ya trajo nombre de mostrador. No inventar marca casa ni Gotinal.
insert into public.productos (
  nombre, sku, codigo_barras, categoria, tipo, descripcion,
  costo, precio, stock, stock_minimo, activo, requiere_receta, marca
)
select distinct on (digitos)
  coalesce(nullif(btrim(i.nombre_snapshot), ''), 'Producto ' || digitos),
  case
    when exists (
      select 1 from public.productos p
      where p.sku = 'FC-' || right(digitos, 8)
        and coalesce(p.codigo_barras, '') <> digitos
    ) then 'FC-ND-' || right(digitos, 8)
    else 'FC-' || right(digitos, 8)
  end,
  digitos,
  'Otro',
  'marca',
  'Alta Recibir Farmalive 127790 · EAN ' || digitos || ' · ficha desde renglón del ticket',
  null,
  greatest(coalesce(i.costo_estimado, 0) * 1.25, 1),
  0,
  1,
  true,
  false,
  case
    when i.nombre_snapshot ilike '%teatrical%' then 'Teatrical'
    when i.nombre_snapshot ilike '%cicatricure%' then 'Cicatricure'
    when i.nombre_snapshot ilike '%suerox%' then 'Suerox'
    when i.nombre_snapshot ilike '%asepxia%' then 'Asepxia'
    when i.nombre_snapshot ilike '%xl-3%' or i.nombre_snapshot ilike '%xl3%' then 'XL-3'
    when i.nombre_snapshot ilike '%genomma%' then 'Genomma'
    when i.nombre_snapshot ilike '%chinoin%' then 'Chinoin'
    else ''
  end
from (
  select
    i.*,
    regexp_replace(coalesce(i.codigo_escaneado, ''), '\D', '', 'g') as digitos
  from public.recepcion_items i
  join public.recepciones r on r.id = i.recepcion_id
  where coalesce(r.proveedor, '') ilike '%farmalive%'
    and r.folio = '127790'
    and coalesce(i.pendiente_alta, false)
    and i.producto_id is null
    and regexp_replace(coalesce(i.codigo_escaneado, ''), '\D', '', 'g') in (
      '650240079009', '650240078996', '7501088599926'
    )
) i
where public.fc_buscar_producto_escaneo(i.digitos) is null
  and not exists (
    select 1 from public.productos p
    where p.codigo_barras = i.digitos
  )
order by digitos, i.id;

insert into public.producto_imagenes
  (producto_id, url, storage_path, posicion, es_principal, origen)
select
  p.id,
  t.foto,
  'catalogo-propia/' || regexp_replace(t.foto, '^.*/', ''),
  coalesce((select max(i.posicion) from public.producto_imagenes i where i.producto_id = p.id), 0) + 1,
  false,
  'propia'
from _fc_alta_fl127790_6 t
join public.productos p
  on public.fc_match_codigo_barras(t.ean, p.codigo_barras)
where t.foto is not null
  and not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id
      and i.url = t.foto
  );

-- 3) Enlazar SOLO el ticket vivo. Por EAN exacto / 12 vs 13 / nombre.
update public.recepcion_items i
set
  producto_id = coalesce(
    public.fc_buscar_producto_escaneo(i.codigo_escaneado),
    (
      select p.id from public.productos p
      where public.fc_match_codigo_barras(
        regexp_replace(coalesce(i.codigo_escaneado, ''), '\D', '', 'g'),
        p.codigo_barras
      )
      order by p.id
      limit 1
    )
  ),
  pendiente_alta = false
from public.recepciones r
where i.recepcion_id = r.id
  and r.folio = '127790'
  and coalesce(r.proveedor, '') ilike '%farmalive%'
  and coalesce(i.pendiente_alta, false)
  and i.producto_id is null
  and coalesce(
    public.fc_buscar_producto_escaneo(i.codigo_escaneado),
    (
      select p.id from public.productos p
      where public.fc_match_codigo_barras(
        regexp_replace(coalesce(i.codigo_escaneado, ''), '\D', '', 'g'),
        p.codigo_barras
      )
      limit 1
    )
  ) is not null;

-- Ensure / Aspirinas / Genomma por EAN o nombre del renglón amarillo.
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
    (
      regexp_replace(coalesce(i.codigo_escaneado, ''), '\D', '', 'g') in (
        '7501033954061', '7501008499245', '7501008849949',
        '650240079009', '650240078996', '7501088599926'
      )
      and public.fc_match_codigo_barras(
        regexp_replace(coalesce(i.codigo_escaneado, ''), '\D', '', 'g'),
        p.codigo_barras
      )
    )
    or (i.nombre_snapshot ilike '%aspirina%go%' and p.codigo_barras = '7501008499245')
    or (
      i.nombre_snapshot ilike '%aspirina%'
      and i.nombre_snapshot ilike '%3-pack%'
      and p.codigo_barras = '7501008849949'
    )
    or (
      i.nombre_snapshot ilike '%ensure%'
      and i.nombre_snapshot ilike '%choco%'
      and p.codigo_barras = '7501033954061'
    )
  );

-- Equilibrio: Ensure / Teatrical que el match 12↔13 no enlazó.
update public.recepcion_items i
set
  producto_id = coalesce(i.producto_id, public.fc_buscar_producto_escaneo(i.codigo_escaneado)),
  pendiente_alta = false
from public.recepciones r
where i.recepcion_id = r.id
  and r.folio = '20260914'
  and coalesce(i.pendiente_alta, false)
  and i.producto_id is null
  and public.fc_buscar_producto_escaneo(i.codigo_escaneado) is not null;

commit;

select
  r.folio,
  r.proveedor,
  r.estado,
  count(*) as renglones,
  count(*) filter (where i.pendiente_alta) as siguen_pendiente_alta,
  count(*) filter (where not i.confirmado) as sin_confirmar,
  count(*) filter (where i.confirmado) as confirmados
from public.recepciones r
join public.recepcion_items i on i.recepcion_id = r.id
where r.folio in ('127790', '20260914')
   or r.estado in ('borrador', 'pendiente_alta', 'pendiente_caducidad')
group by r.folio, r.proveedor, r.estado
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
  and (
    coalesce(i.pendiente_alta, false)
    or regexp_replace(coalesce(i.codigo_escaneado, ''), '\D', '', 'g') in (
      '650240079009', '650240078996', '7501088599926',
      '7501033954061', '7501008849949', '7501008499245'
    )
    or i.nombre_snapshot ilike '%aspirina%'
  )
order by i.pendiente_alta desc, i.id;
