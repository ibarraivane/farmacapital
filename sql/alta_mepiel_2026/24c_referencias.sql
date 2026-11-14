-- 24c — anota el precio cliente con IVA como referencia de compra ME Piel.
begin;

do $$
begin
  if to_regclass('public._fc_mepiel_stg') is null then
    raise exception 'Falta la tabla temporal de ME Piel. No vuelvas a correr el 00.';
  end if;
end $$;

delete from public.producto_precios_referencia r
 using (
   select distinct ean
   from public._fc_mepiel_stg
   where nullif(btrim(ean), '') is not null
 ) t
 join public.productos p on p.codigo_barras = t.ean
 where r.producto_id = p.id
   and r.fuente = 'mepiel'
   and r.origen = 'import_csv'
   and r.fecha = current_date;

insert into public.producto_precios_referencia
  (producto_id, fuente, tipo, precio, sku_externo, origen, notas)
select distinct on (p.id)
  p.id, 'mepiel', 'compra', t.costo, t.ean, 'import_csv',
  'Lista ME Piel 2026 · precio cliente c/IVA'
    || coalesce(' · PVP c/IVA ' || t.techo::text, '')
    || coalesce(' · oferta ' || nullif(t.oferta, ''), '')
  from (
    select distinct on (ean) *
    from public._fc_mepiel_stg
    where nullif(btrim(ean), '') is not null
      and costo is not null
      and costo > 0
    order by ean, costo nulls last
  ) t
  join public.productos p on p.codigo_barras = t.ean
 order by p.id, t.costo;

commit;

select 'referencias' as paso, count(*) as de_hoy
from public.producto_precios_referencia
where fuente = 'mepiel' and fecha = current_date;
