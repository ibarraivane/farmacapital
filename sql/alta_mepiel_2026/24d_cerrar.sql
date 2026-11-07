-- 24d — cierra la carga y borra la tabla temporal.
begin;
drop table if exists public._fc_mepiel_stg;
commit;

select
  count(*) filter (where coalesce(bajo_pedido, false)) as bajo_pedido,
  count(*) filter (
    where coalesce(bajo_pedido, false)
      and descripcion ilike '%mepiel%'
  ) as alta_mepiel_nueva
from public.productos;
