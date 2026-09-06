-- Fotos + ficha correcta · Amifarin, Cina, Ácido Acetilsalicílico Avivia.
-- Archivos en public/catalogo-propia/ — correr DESPUÉS del deploy de Vercel.
-- Si corres antes, las URLs dan 404.
--
-- Fuentes (misma presentación / EAN):
--   Amifarin 500 mg c/20 Wandel · EAN 7503001007113 · Farmacia París / Phemedica
--   Cina Levofloxacino 750 mg c/7 Landsteiner · EAN 7502225092486 · Sanorim
--   Ácido Acetilsalicílico Avivia 100 mg c/30 · EAN 7502216804869 · EQF AVI005
--
-- También corrige el nombre erróneo «Cina (Ciprofloxacino)» → Levofloxacino.

begin;

-- ── Amifarin 20 cáps 500 mg (FC-D5AC44CA) ─────────────────────
update public.productos
set
  imagen_url = 'https://www.farmacapital.mx/catalogo-propia/amifarin-500mg-20caps.jpg',
  imagen_mobile_url = 'https://www.farmacapital.mx/catalogo-propia/amifarin-500mg-20caps.jpg',
  marca = 'Wandel',
  principio_activo = coalesce(nullif(trim(principio_activo), ''), 'Dicloxacilina'),
  categoria = case when coalesce(categoria, '') in ('', 'Otro') then 'Antibiótico' else categoria end,
  tipo = 'generico',
  codigo_barras = coalesce(nullif(trim(codigo_barras), ''), '7503001007113')
where sku = 'FC-D5AC44CA';

insert into public.producto_imagenes
  (producto_id, url, storage_path, posicion, es_principal, origen)
select
  p.id,
  'https://www.farmacapital.mx/catalogo-propia/amifarin-500mg-20caps.jpg',
  'catalogo-propia/amifarin-500mg-20caps.jpg',
  coalesce((select max(posicion) from public.producto_imagenes i where i.producto_id = p.id), 0) + 1,
  true,
  'propia'
from public.productos p
where p.sku = 'FC-D5AC44CA'
  and not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id
      and i.url like '%catalogo-propia/amifarin-500mg-20caps%'
  );

update public.producto_imagenes i
set es_principal = (i.url like '%catalogo-propia/amifarin-500mg-20caps%')
where i.producto_id = (select id from public.productos where sku = 'FC-D5AC44CA' limit 1);

-- ── Cina Levofloxacino 750 mg c/7 (FC-B25B4654) ───────────────
update public.productos
set
  nombre = 'Cina (Levofloxacino)',
  marca = 'Landsteiner',
  principio_activo = 'Levofloxacino',
  presentacion = coalesce(nullif(trim(presentacion), ''), '7 TABLETAS'),
  concentracion = coalesce(nullif(trim(concentracion), ''), '750 MG'),
  forma_farmaceutica = coalesce(nullif(trim(forma_farmaceutica), ''), 'TABLETAS'),
  categoria = 'Antibiótico',
  tipo = 'generico',
  descripcion = 'Cina (Levofloxacino) 750 mg caja con 7 tabletas',
  imagen_url = 'https://www.farmacapital.mx/catalogo-propia/cina-levofloxacino-750mg-7tab.jpg',
  imagen_mobile_url = 'https://www.farmacapital.mx/catalogo-propia/cina-levofloxacino-750mg-7tab.jpg',
  codigo_barras = coalesce(nullif(trim(codigo_barras), ''), '7502225092486')
where sku = 'FC-B25B4654';

insert into public.producto_imagenes
  (producto_id, url, storage_path, posicion, es_principal, origen)
select
  p.id,
  'https://www.farmacapital.mx/catalogo-propia/cina-levofloxacino-750mg-7tab.jpg',
  'catalogo-propia/cina-levofloxacino-750mg-7tab.jpg',
  coalesce((select max(posicion) from public.producto_imagenes i where i.producto_id = p.id), 0) + 1,
  true,
  'propia'
from public.productos p
where p.sku = 'FC-B25B4654'
  and not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id
      and i.url like '%catalogo-propia/cina-levofloxacino-750mg-7tab%'
  );

update public.producto_imagenes i
set es_principal = (i.url like '%catalogo-propia/cina-levofloxacino-750mg-7tab%')
where i.producto_id = (select id from public.productos where sku = 'FC-B25B4654' limit 1);

-- ── Ácido Acetilsalicílico Avivia 100 mg c/30 (FC-7D1D9857) ───
update public.productos
set
  nombre = 'Ácido Acetilsalicílico',
  marca = 'Avivia',
  principio_activo = coalesce(nullif(trim(principio_activo), ''), 'Ácido acetilsalicílico'),
  presentacion = coalesce(nullif(trim(presentacion), ''), '30 TABLETAS'),
  concentracion = coalesce(nullif(trim(concentracion), ''), '100 MG'),
  forma_farmaceutica = coalesce(nullif(trim(forma_farmaceutica), ''), 'TABLETAS'),
  categoria = case when coalesce(categoria, '') in ('', 'Otro') then 'Analgésico' else categoria end,
  tipo = 'generico',
  descripcion = 'Ácido Acetilsalicílico Avivia 100 mg caja con 30 tabletas',
  imagen_url = 'https://www.farmacapital.mx/catalogo-propia/acido-acetilsalicilico-avivia-100mg-30tab.jpg',
  imagen_mobile_url = 'https://www.farmacapital.mx/catalogo-propia/acido-acetilsalicilico-avivia-100mg-30tab.jpg',
  codigo_barras = coalesce(nullif(trim(codigo_barras), ''), '7502216804869')
where sku = 'FC-7D1D9857';

insert into public.producto_imagenes
  (producto_id, url, storage_path, posicion, es_principal, origen)
select
  p.id,
  'https://www.farmacapital.mx/catalogo-propia/acido-acetilsalicilico-avivia-100mg-30tab.jpg',
  'catalogo-propia/acido-acetilsalicilico-avivia-100mg-30tab.jpg',
  coalesce((select max(posicion) from public.producto_imagenes i where i.producto_id = p.id), 0) + 1,
  true,
  'propia'
from public.productos p
where p.sku = 'FC-7D1D9857'
  and not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id
      and i.url like '%catalogo-propia/acido-acetilsalicilico-avivia-100mg-30tab%'
  );

update public.producto_imagenes i
set es_principal = (i.url like '%catalogo-propia/acido-acetilsalicilico-avivia-100mg-30tab%')
where i.producto_id = (select id from public.productos where sku = 'FC-7D1D9857' limit 1);

commit;

select sku, nombre, marca, codigo_barras, left(coalesce(imagen_url, ''), 72) as foto
from public.productos
where sku in ('FC-D5AC44CA', 'FC-B25B4654', 'FC-7D1D9857')
order by sku;
