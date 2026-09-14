-- Fotos frente + faltantes 2026-09-14
-- 1) Ketorolaco/Tramadol AMSA: el JPG de catalogo-propia se reemplazó por el
--    frente de la caja (mismo path). Pegar SQL NO es necesario para ese SKU
--    si ya apunta a catalogo-propia/ketorolaco-tramadol-amsa-10-25-iny-3amp.jpg
--    — sí hace falta el deploy de Vercel.
-- 2) Hioscina AMSA: se cambia Nadro (caja de canto) por Farmatodo frente.
-- 3) Productos sin imagen con packshot de frente por EAN (Farmatodo / Nadro).
-- 4) Segunda pasada: Pharmaton Nadro C/100, Pirinovag/Calazin/Culminax/
--    Eucalin/Reomatolum en catalogo-propia, Gelcavit Platinum/Colors/Q-10 Nadro.
--
-- ORDEN: 1) merge/deploy  2) pegar este SQL en Supabase.
-- Galería: inserta es_principal=false y luego rota la principal
-- (evita ux_producto_imagenes_una_principal).
-- origen de producto_imagenes SOLO admite
-- rappi | distribuidor | propia | gs1 | otro
-- (farmatodo/nadro → distribuidor).
-- Idempotente: no duplica la misma URL.

begin;

create temporary table tmp_foto_frente (
  sku text not null,
  ean text,
  url text not null,
  origen text not null,
  forzar boolean not null default false
) on commit drop;

insert into tmp_foto_frente (sku, ean, url, origen, forzar)
values
  -- reemplazo de lado → frente
  ('EQ-AMS075', '7501349024045',
   'https://gruporfp.vteximg.com.br/arquivos/ids/7008309/7501349024045_01.jpg',
   'distribuidor', true),
  -- faltantes medicamentos
  ('FC-63310269', '7501563310269',
   'https://gruporfp.vteximg.com.br/arquivos/ids/7006977/7501563310269_01.jpg',
   'distribuidor', false),
  ('FC-27870259', '7502227870259',
   'https://nadro.vtexassets.com/arquivos/ids/242647/7502227870259_01.jpg',
   'distribuidor', false),
  ('FC-42700643', '7506442700643',
   'https://gruporfp.vteximg.com.br/arquivos/ids/7013995/7506442700643_01.jpg',
   'distribuidor', false),
  ('FC-49022492', '7501349022492',
   'https://nadro.vtexassets.com/arquivos/ids/213677/7501349022492_01.jpg',
   'distribuidor', false),
  ('FC-42700629', '7506442700629',
   'https://nadro.vtexassets.com/arquivos/ids/215208/7506442700629_01.jpg',
   'distribuidor', false),
  ('FC-LV-GNO016', '6502400291650',
   'https://nadro.vtexassets.com/arquivos/ids/199866/650240029165_01.jpg',
   'distribuidor', false),
  ('FC-40036354', '6502400363548',
   'https://gruporfp.vteximg.com.br/arquivos/ids/7005425/650240036354_01.jpg',
   'distribuidor', false),
  ('FC-00315021', '6502400315021',
   'https://gruporfp.vteximg.com.br/arquivos/ids/7005995/650240031502_01.jpg',
   'distribuidor', false),
  -- cuidado / identificables
  ('FC-75073114', '75073114',
   'https://nadro.vtexassets.com/arquivos/ids/203236/75073114_01.jpg',
   'distribuidor', false),
  ('FC-00661391', '6502400661391',
   'https://gruporfp.vteximg.com.br/arquivos/ids/7010364/650240066139_01.jpg',
   'distribuidor', false),
  ('FC-00024798', '056100024798',
   'https://gruporfp.vteximg.com.br/arquivos/ids/7007967/056100024798_01.jpg',
   'distribuidor', false),
  ('FC-86494286', '7501086494286',
   'https://gruporfp.vteximg.com.br/arquivos/ids/6996705/7501086494286_01.jpg',
   'distribuidor', false),
  ('FC-03477270', '7702003477270',
   'https://gruporfp.vteximg.com.br/arquivos/ids/6998470/7702003477270_01.jpg',
   'distribuidor', false),
  ('FC-19039355', '7501019039355',
   'https://nadro.vtexassets.com/arquivos/ids/171546/7501019039355_01.jpg',
   'distribuidor', false),
  -- segunda pasada: Nadro exacto + internet (frente de caja/frasco)
  ('FC-98062243', '3664798062243',
   'https://nadro.vtexassets.com/arquivos/ids/218373/3664798062243_01.jpg',
   'distribuidor', false),
  ('EQ-NOV176', '7501075727517',
   'https://www.farmacapital.mx/catalogo-propia/pirinovag-500mg-10tab.jpg',
   'propia', false),
  ('FMX-502046', '637420223803',
   'https://www.farmacapital.mx/catalogo-propia/calazin-suspension-180ml.jpg',
   'propia', false),
  ('FC-09747786', '7502009747786',
   'https://www.farmacapital.mx/catalogo-propia/culminax-pediatrico-150ml.jpg',
   'propia', false),
  ('FMX-500998', null,
   'https://nadro.vtexassets.com/arquivos/ids/242566/7501130713851_01.jpg',
   'distribuidor', false),
  ('FMX-501000', null,
   'https://nadro.vtexassets.com/arquivos/ids/242105/7501130713547_01.jpg',
   'distribuidor', false),
  ('FMX-501003', null,
   'https://nadro.vtexassets.com/arquivos/ids/242085/7501130711642_01.jpg',
   'distribuidor', false),
  ('FMX-501619', null,
   'https://www.farmacapital.mx/catalogo-propia/eucalin-miel-120ml.jpg',
   'propia', false),
  ('FC-2E5B7248', null,
   'https://www.farmacapital.mx/catalogo-propia/reomatolum-del-viejito.jpg',
   'propia', false);

create temporary table tmp_foto_match (
  producto_id bigint primary key,
  sku text not null,
  url text not null,
  origen text not null
) on commit drop;

insert into tmp_foto_match (producto_id, sku, url, origen)
select distinct on (p.id)
  p.id, m.sku, m.url, m.origen
from public.productos p
join tmp_foto_frente m on p.sku = m.sku
where m.forzar
   or p.imagen_url is null
   or btrim(p.imagen_url) = ''
order by p.id;

-- 1) Portada
update public.productos p
set imagen_url = m.url,
    imagen_mobile_url = m.url
from tmp_foto_match m
where p.id = m.producto_id;

-- 2) Insertar como NO principal
insert into public.producto_imagenes
  (producto_id, url, storage_path, posicion, es_principal, origen)
select
  m.producto_id,
  m.url,
  null,
  coalesce((select max(i.posicion) from public.producto_imagenes i where i.producto_id = m.producto_id), 0) + 1,
  false,
  case
    when m.origen in ('rappi', 'distribuidor', 'propia', 'gs1', 'otro') then m.origen
    else 'distribuidor'
  end
from tmp_foto_match m
where not exists (
  select 1 from public.producto_imagenes i
  where i.producto_id = m.producto_id and i.url = m.url
);

-- 3) Rotar principal
update public.producto_imagenes i
set es_principal = false
where i.producto_id in (select producto_id from tmp_foto_match)
  and i.es_principal
  and i.url not in (select url from tmp_foto_match);

update public.producto_imagenes i
set es_principal = true
where i.producto_id in (select producto_id from tmp_foto_match)
  and i.url in (select url from tmp_foto_match)
  and not i.es_principal;

commit;
