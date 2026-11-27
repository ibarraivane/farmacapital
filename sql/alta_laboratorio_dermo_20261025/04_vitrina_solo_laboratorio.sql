-- ============================================================================
-- Dermocosmética = solo laboratorio (SVR / Alastin / Medik8).
-- Saca de esa vitrina marcas de anaquel/listas web (Eucerin, CeraVe, LRP,
-- Palmolive, Quirmex, etc.) y las manda a Higiene. Corre DESPUÉS de las altas
-- 01–03b (o solo, si el catálogo lab ya está cargado).
-- ============================================================================

-- Conteo previo
select
  count(*) filter (
    where vitrina_seccion = 'Dermocosmética'
      and lower(btrim(coalesce(marca, ''))) not in ('svr', 'alastin', 'medik8')
  ) as dermo_a_sacar,
  count(*) filter (
    where lower(btrim(coalesce(marca, ''))) in ('svr', 'alastin', 'medik8')
      and coalesce(activo, false)
  ) as lab_activos
from public.productos;

begin;

-- 1) Lab → Dermocosmética (Solar si el nombre lo indica)
update public.productos
   set vitrina_seccion = 'Dermocosmética',
       vitrina_subseccion = case
         when nombre ~* '(solar|fps|spf|fotoprotec|sunscreen|heliocare|sun secure|hydratint|silkshield)'
           then 'Solar'
         else null
       end
 where coalesce(activo, false)
   and lower(btrim(coalesce(marca, ''))) in ('svr', 'alastin', 'medik8');

-- 2) Todo lo demás que seguía en Dermocosmética → Higiene
update public.productos
   set vitrina_seccion = 'Higiene y cuidado personal',
       vitrina_subseccion = case
         when nombre ~* '(shampoo|champ(u|ú)|acondicionador|gel .*cabello|cera |tinte|koleston)'
           then 'Cabello'
         when nombre ~* '(desodorante|antitranspirante)'
           then 'Desodorantes'
         when nombre ~* '(pasta dental|cepillo dent|enjuague bucal|hilo dental)'
           then 'Higiene bucal'
         when nombre ~* '(rastrillo|afeitar|rasurar|navaja)'
           then 'Afeitado'
         when nombre ~* '(pa(ñ|n)al|bebe|beb(é|e)|toallitas)'
           then 'Bebé'
         when nombre ~* '(cond(o|ó)n|preservativo|lubricante (i|í)ntimo)'
           then 'Salud sexual'
         else coalesce(nullif(btrim(vitrina_subseccion), ''), 'Cuidado diario')
       end
 where coalesce(activo, false)
   and vitrina_seccion = 'Dermocosmética'
   and lower(btrim(coalesce(marca, ''))) not in ('svr', 'alastin', 'medik8');

commit;

select
  marca,
  count(*) as n,
  count(*) filter (where vitrina_subseccion = 'Solar') as solar
from public.productos
where coalesce(activo, false)
  and vitrina_seccion = 'Dermocosmética'
group by marca
order by marca;
