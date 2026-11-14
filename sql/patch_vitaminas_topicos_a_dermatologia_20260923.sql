-- ============================================================================
-- FarmaCapital — 2026-09-23
-- Vitaminas = lo que se toma (tableta, cápsula, jarabe, gomita, polvo).
-- El parche del 21-sep marcó «Vitaminas» a todo nombre con vitamina C/E,
-- y los sérums / cremas / geles de Dermaexpress cayeron en esa pestaña.
--
-- Este script solo mueve piel → Cuidado personal / Dermatología
-- e higiene (Dove con vitamina E) → Higiene.
-- No toca Alphastan, Centrum, Scott, Onedrop ni cápsulas.
-- No inventa precio, foto ni código.
--
-- Pegar en Supabase → SQL Editor → Run. El script completo, de una vez.
-- ============================================================================

begin;

create temp table _fc_vit_mover on commit drop as
select
  p.id,
  p.nombre,
  p.marca,
  p.presentacion,
  p.subcategoria as sub_antes,
  case
    when n.t ~ '(^|[^a-z0-9])(shampoo|acondicionador|desodorante|antitranspirante|pantene|sedal|dove|crema dental|pasta dental|enjuague bucal)([^a-z0-9]|$)'
      then 'Higiene'
    else 'Cuidado personal'
  end as cat_nueva
from public.productos p
join (
  select
    id,
    lower(regexp_replace(
      translate(
        coalesce(nombre, '') || ' ' ||
        coalesce(marca, '') || ' ' ||
        coalesce(principio_activo, '') || ' ' ||
        coalesce(forma_farmaceutica, '') || ' ' ||
        coalesce(presentacion, '') || ' ' ||
        coalesce(subcategoria, ''),
        'áéíóúüñÁÉÍÓÚÜÑ',
        'aeiouunAEIOUUN'
      ),
      '\s+',
      ' ',
      'g'
    )) as t
  from public.productos
) n on n.id = p.id
where p.categoria = 'Vitaminas'
  and n.t !~ '(^|[^a-z0-9])(tabletas?|tabs?|capsulas?|caps|comprimidos?|grageas?|gomitas?|efervescentes?|jarabes?|polvos?|sobres?|ampolletas?|softgels?|masticables?|perlas?|porcion(es)?|suplementos?)([^a-z0-9]|$)'
  and (
    p.subcategoria ~* '^dermatolog'
    or n.t ~ '(^|[^a-z0-9])(shampoo|acondicionador|desodorante|antitranspirante|pantene|sedal|dove|crema dental|pasta dental|enjuague bucal)([^a-z0-9]|$)'
    or n.t ~ '(^|[^a-z0-9])(serums?|cremas?|gel(es)?|mascarillas?|limpiador(es)?|locion(es)?|fluidos?|fluidbase|fps[0-9]*|spf[0-9]*|protector solar|bloqueador|exfoliantes?|tonicos?|balsamos?|pomadas?|unguentos?|desmaquillantes?|agua micelar|peeling|retinol|activo puro|liftactiv|geneskin|pigmentbio|depiderm|actine|facial|contorno)([^a-z0-9]|$)'
    or (
      n.t ~ '(^|[^a-z0-9])aceite([^a-z0-9]|$)'
      and n.t !~ 'aceite de (pescado|higado|coco|onagra|primula|krill|lino|oliva|germen)'
    )
  );

update public.productos p
   set categoria = m.cat_nueva,
       subcategoria = case
         when m.cat_nueva = 'Higiene' then p.subcategoria
         when coalesce(btrim(p.subcategoria), '') = ''
           or p.subcategoria ~* '^vitamin'
           then 'Dermatología'
         else p.subcategoria
       end
  from _fc_vit_mover m
 where p.id = m.id
   and (
     p.categoria is distinct from m.cat_nueva
     or (
       m.cat_nueva = 'Cuidado personal'
       and (
         coalesce(btrim(p.subcategoria), '') = ''
         or p.subcategoria ~* '^vitamin'
       )
     )
   );

select cat_nueva, count(*) as n
  from _fc_vit_mover
 group by 1
 order by 1;

select nombre, marca, presentacion, sub_antes, cat_nueva
  from _fc_vit_mover
 order by cat_nueva, nombre;

commit;
