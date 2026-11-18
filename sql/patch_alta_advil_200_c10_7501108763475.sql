-- Advil ibuprofeno 200 mg · caja con 10 cápsulas (blíster).
-- EAN de la caja (foto de mostrador): 7501108763475
-- SKU: FC- + últimos 8 = FC-08763475
--
-- No es la ficha de 20:
--   FC-08763468 · 7501108763468 · caja con frasco de 20.
--   Farmalisto nombra ese código como C/20. El ticket Farmalive 12790
--   (PR347, 15-sep-2026) decía C/10 «Compra 3» y se le pegó el EAN de 20.
--   Esta alta no mueve el stock de esa ficha ni le cambia el nombre.
--
-- Compra: pack $138.18 / 3 = costo $46.06.
-- Precio: recargo de marca +25% sobre costo → $58
--   (46.06 × 1.25 = 57.58, se redondea hacia arriba).
--   Margen real sobre $58 = 20.6%. No es «margen 25%».
--
-- Stock 0. Sin lote y sin caducidad: eso lo pone la caja en Recibir.
-- Foto: public/catalogo-propia/advil-200-10-caps.jpg
--   (packshot Farmaenvíos del EAN 7501108763475, caja con 10, no el frasco).
--   La URL de la foto sirve después del deploy.
--
-- Idempotente. SIN do $$. Pegar TODO en Supabase → SQL Editor → Run.

begin;

insert into public.productos (
  nombre, sku, codigo_barras, categoria, subcategoria, tipo, descripcion,
  marca, presentacion, principio_activo, concentracion, forma_farmaceutica,
  costo, precio, imagen_url, imagen_mobile_url,
  stock, stock_minimo, activo, requiere_receta
)
select
  'Advil ibuprofeno 200 mg C/10 cápsulas',
  case
    when exists (
      select 1 from public.productos p
      where p.sku = 'FC-08763475'
        and coalesce(p.codigo_barras, '') <> '7501108763475'
    ) then 'FC-ND-08763475'
    else 'FC-08763475'
  end,
  '7501108763475',
  'Medicamentos',
  'Analgésico',
  'marca',
  'Farmalive 12790 PR347 · caja con 10 cápsulas EAN 7501108763475 · no es el frasco C/20 7501108763468 · costo $46.06 (pack $138.18 / 3) · recargo marca +25%',
  'Advil',
  'Caja con 10 cápsulas',
  'Ibuprofeno',
  '200 mg',
  'Cápsula',
  46.06,
  58,
  'https://www.farmacapital.mx/catalogo-propia/advil-200-10-caps.jpg',
  'https://www.farmacapital.mx/catalogo-propia/advil-200-10-caps.jpg',
  0,
  1,
  true,
  false
where public.fc_buscar_producto_escaneo('7501108763475') is null
  and not exists (
    select 1 from public.productos p
    where p.codigo_barras = '7501108763475'
       or (
         p.sku in ('FC-08763475', 'FC-ND-08763475')
         and coalesce(p.codigo_barras, '') = '7501108763475'
       )
  );

insert into public.producto_imagenes (
  producto_id, url, storage_path, posicion, es_principal, origen
)
select
  p.id,
  'https://www.farmacapital.mx/catalogo-propia/advil-200-10-caps.jpg',
  'catalogo-propia/advil-200-10-caps.jpg',
  0,
  true,
  'propia'
from public.productos p
where p.codigo_barras = '7501108763475'
  and not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id
      and i.url like '%advil-200-10-caps%'
  );

insert into public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, nombre_fuente, confianza, origen, notas
)
select
  p.id,
  'ultima_compra',
  'compra',
  46.06,
  date '2026-09-15',
  'Farmalive',
  100,
  'manual',
  'Farmalive 12790 · PR347 C/10 EAN 7501108763475 · pack $138.18 / 3 = $46.06. No es FC-08763468 (frasco C/20).'
from public.productos p
where p.codigo_barras = '7501108763475'
  and not exists (
    select 1 from public.producto_precios_referencia r
    where r.producto_id = p.id
      and r.fuente = 'ultima_compra'
      and r.precio = 46.06
      and r.fecha = date '2026-09-15'
  );

-- Si el ticket sigue en borrador, el renglón trae el EAN de 20.
-- Cámbialo para que la pistola de estas cajas sí abra el renglón.
-- No toca un ticket ya confirmado ni el stock de FC-08763468.
update public.recepcion_items i
set
  codigo_escaneado = '7501108763475',
  producto_id = p.id,
  nombre_snapshot = 'Advil ibuprofeno 200 mg cápsulas C/10'
from public.recepciones r
join public.productos p
  on p.codigo_barras = '7501108763475'
where i.recepcion_id = r.id
  and coalesce(r.proveedor, '') ilike '%farmalive%'
  and r.folio in ('12790', '127790')
  and r.estado = 'borrador'
  and regexp_replace(coalesce(i.codigo_escaneado, ''), '\D', '', 'g') = '7501108763468';

commit;

select
  p.sku,
  p.codigo_barras as ean,
  p.nombre,
  p.presentacion,
  p.costo,
  p.precio,
  p.stock,
  round((p.precio - p.costo) / nullif(p.precio, 0) * 100, 1) as margen_pct
from public.productos p
where p.codigo_barras in ('7501108763475', '7501108763468')
   or p.sku in ('FC-08763475', 'FC-ND-08763475', 'FC-08763468')
order by p.codigo_barras;
