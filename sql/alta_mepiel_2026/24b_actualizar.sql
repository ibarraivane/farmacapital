-- 24b — a los que ya existían les guarda el costo de ME Piel si es más barato.
-- No toca anaquel (stock > 0) ni un precio ya publicado.
begin;

do $$
begin
  if to_regclass('public._fc_mepiel_stg') is null then
    raise exception 'Falta la tabla temporal de ME Piel. No vuelvas a correr el 00.';
  end if;
end $$;

update public.productos p
   set bajo_pedido = true,
       activo = true,
       costo = case
         when p.costo is null or p.costo <= 0 then t.costo
         when t.costo < p.costo then t.costo
         else p.costo
       end,
       marca = coalesce(nullif(trim(p.marca), ''), t.marca),
       presentacion = coalesce(nullif(trim(p.presentacion), ''), nullif(t.presentacion, '')),
       concentracion = coalesce(nullif(trim(p.concentracion), ''), nullif(t.concentracion, '')),
       forma_farmaceutica = coalesce(nullif(trim(p.forma_farmaceutica), ''), nullif(t.forma, '')),
       imagen_url = coalesce(nullif(trim(p.imagen_url), ''), nullif(t.imagen_url, '')),
       subcategoria = coalesce(nullif(trim(p.subcategoria), ''), t.subcategoria)
  from (
    select distinct on (ean) *
    from public._fc_mepiel_stg
    where nullif(btrim(ean), '') is not null
    order by ean, costo nulls last
  ) t
 where p.codigo_barras = t.ean
   and coalesce(p.stock, 0) = 0
   and coalesce(p.precio, 0) <= 0.01;

commit;

select 'actualizar' as paso;
