-- ============================================================================
-- FarmaCapital — 2026-09-21
-- Electrolit / Pedialyte / Suerox / suero oral: el parser de ticket los
-- dejó en Higiene o GENERAL. En mostrador y tienda van a Hidratación.
--
-- Pegar en Supabase → SQL Editor → Run.
-- ============================================================================

begin;

update public.productos
   set categoria = 'Hidratación'
 where categoria is distinct from 'Hidratación'
   and (
        lower(btrim(coalesce(marca, '')))
          ~ '^(electrolit|electrolid|pedialyte|suerox|oralit|voldratol)$'
     or coalesce(nombre, '')
          ~* '(^|[^[:alnum:]])(electrolit|electrolid|pedialyte|suerox|oralit|voldratol|electrolitos|suero oral)'
     or coalesce(forma_farmaceutica, '') ~* 'suero oral'
     or coalesce(principio_activo, '') ~* '(electrolitos|suero oral)'
   );

commit;

select categoria, count(*) as n
  from public.productos
 where coalesce(nombre, '') ~* '(electrolit|pedialyte|suerox|oralit|voldratol|electrolitos|suero oral)'
    or lower(btrim(coalesce(marca, '')))
         ~ '^(electrolit|pedialyte|suerox|oralit|voldratol)$'
 group by 1
 order by 2 desc;
