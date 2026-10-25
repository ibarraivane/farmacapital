-- HS Comercial T610241957 · EAN desde fotos de caja (24-oct-2026)
-- Solo rellena codigo_barras si el producto aún no tiene (o está vacío).
-- No pisa un EAN distinto ya cargado. No toca stock ni caducidad.
--
-- Mapa (foto → SKU):
--   Bocadin bolsa 50 pzas     025046501052  → FC-HS-BOCADIN50
--   Chiki Botella (Alvher)    799583006003  → FC-HS-CHIKIBOT40
--   Orbit 4's Menta 40 pzs    7502271913353 → FC-LV-ORBITMEN40
--   Skittles Original 10×22g  7502226816937 → FC-HS-SKITTLES220
--   M&M's Chocolate 6 pack    7502271917641 → FC-HS-MMCAFE6
--   Kit Kat Chunky 6×40 g     7501058626554 → FC-HS-KITCHUNKY6
--
-- Skittles: el pack es 10 sobres de 22 g (CONT. NET. 220 g), no 10×220 g.
-- Chiki: marca en caja ALVHER (ticket decía alv.).
-- Pegar TODO en Supabase → SQL Editor → Run.

begin;

-- Si algún EAN ya vive en otro SKU, soltarlo para no chocar UNIQUE.
update public.productos p
set codigo_barras = null
where nullif(btrim(p.codigo_barras), '') in (
  '025046501052',
  '0025046501052',
  '799583006003',
  '0799583006003',
  '7502271913353',
  '7502226816937',
  '7502271917641',
  '7501058626554'
)
and p.sku not in (
  'FC-HS-BOCADIN50',
  'FC-HS-CHIKIBOT40',
  'FC-LV-ORBITMEN40',
  'FC-HS-SKITTLES220',
  'FC-HS-MMCAFE6',
  'FC-HS-KITCHUNKY6'
);

create temp table _fc_hs_ean (
  sku text primary key,
  ean text not null,
  marca text,
  nombre text,
  presentacion text
) on commit drop;

insert into _fc_hs_ean (sku, ean, marca, nombre, presentacion) values
  ('FC-HS-BOCADIN50', '025046501052', 'Bimbo', 'Bocadin',
   'Bolsa 50 piezas (525 g)'),
  ('FC-HS-CHIKIBOT40', '799583006003', 'Alvher', 'Chiki Botella',
   'Botella (bolsa mayoreo 40)'),
  ('FC-LV-ORBITMEN40', '7502271913353', 'Orbit', 'Orbit 4''s Menta',
   'Pack 4 pastillas (exhibidor 40)'),
  ('FC-HS-SKITTLES220', '7502226816937', 'Skittles', 'Skittles Original',
   'Caja 10 sobres 22 g (220 g)'),
  ('FC-HS-MMCAFE6', '7502271917641', 'M&M''s', 'M&M''s Chocolate',
   '6 pack 37.8 g (226.8 g)'),
  ('FC-HS-KITCHUNKY6', '7501058626554', 'Kit Kat', 'Kit Kat Chunky',
   'Caja 6 barras 40 g');

update public.productos p
set
  codigo_barras = e.ean,
  marca = coalesce(nullif(btrim(p.marca), ''), e.marca),
  nombre = case
    when p.sku = 'FC-HS-SKITTLES220' then e.nombre
    when p.sku = 'FC-HS-CHIKIBOT40' then e.nombre
    else p.nombre
  end,
  presentacion = coalesce(e.presentacion, p.presentacion)
from _fc_hs_ean e
where p.sku = e.sku
  and (
    nullif(btrim(p.codigo_barras), '') is null
    or nullif(btrim(p.codigo_barras), '') in (
      e.ean,
      '0' || e.ean,
      ltrim(e.ean, '0')
    )
  );

-- Marca Alvher / ficha Skittles aunque el EAN ya estuviera.
update public.productos p
set
  marca = e.marca,
  nombre = e.nombre,
  presentacion = e.presentacion
from _fc_hs_ean e
where p.sku = e.sku
  and p.sku in ('FC-HS-CHIKIBOT40', 'FC-HS-SKITTLES220', 'FC-HS-MMCAFE6', 'FC-HS-KITCHUNKY6');

-- Cola Recibir viva: dejar el EAN en codigo_escaneado para la pistola.
update public.recepcion_items i
set codigo_escaneado = e.ean
from public.recepciones r,
     public.productos p,
     _fc_hs_ean e
where i.recepcion_id = r.id
  and p.id = i.producto_id
  and e.sku = p.sku
  and r.folio = 'T610241957'
  and coalesce(r.proveedor, '') ilike '%hs comercial%'
  and r.estado = 'borrador'
  and nullif(btrim(i.codigo_escaneado), '') is null;

commit;

select
  p.sku,
  p.codigo_barras as ean,
  left(p.nombre, 28) as nombre,
  left(p.marca, 12) as marca,
  left(p.presentacion, 36) as presentacion,
  case
    when nullif(btrim(p.codigo_barras), '') is null then 'SIN EAN'
    else 'OK'
  end as estado
from public.productos p
where p.sku in (
  'FC-HS-BOCADIN50',
  'FC-HS-CHIKIBOT40',
  'FC-LV-ORBITMEN40',
  'FC-HS-SKITTLES220',
  'FC-HS-MMCAFE6',
  'FC-HS-KITCHUNKY6'
)
order by p.sku;
