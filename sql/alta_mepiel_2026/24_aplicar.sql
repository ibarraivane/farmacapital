-- 24 — pasa staging a productos + referencia mepiel.
-- No pisa anaquel (stock > 0) ni un precio que el dueño ya haya publicado.
-- Si el EAN ya está en Dermaexpress u otro mayoreo, el costo se queda con el más barato.
-- Si el SKU FC-… ya existe (otro producto), este alta usa FC-MP- + el EAN.
-- Si este archivo falló, córrelo otra vez. No vuelvas a correr el 00.
begin;

do $$
begin
  if to_regclass('public._fc_mepiel_stg') is null then
    raise exception 'Falta la tabla temporal de ME Piel. Avisa antes de volver a correr el 00.';
  end if;
end $$;

with base as (
  select distinct on (ean) *
  from public._fc_mepiel_stg
  where nullif(btrim(ean), '') is not null
  order by ean, costo nulls last
),
ranked as (
  select b.*,
         row_number() over (partition by b.sku order by b.ean) as rn
  from base b
),
listos as (
  select r.*,
         case
           when r.rn = 1
            and not exists (select 1 from public.productos p where p.sku = r.sku)
             then r.sku
           when not exists (
             select 1 from public.productos p where p.sku = 'FC-MP-' || r.ean
           ) then 'FC-MP-' || r.ean
           else 'FC-MP-' || r.ean || '-' || r.rn::text
         end as sku_final
  from ranked r
  where public.fc_buscar_producto_escaneo(r.ean) is null
    and not exists (
      select 1 from public.productos p where p.codigo_barras = r.ean
    )
)
insert into public.productos (
  nombre, sku, codigo_barras, categoria, tipo, descripcion,
  costo, precio, stock, stock_minimo, activo, requiere_receta,
  marca, presentacion, subcategoria, imagen_url, bajo_pedido,
  concentracion, forma_farmaceutica
)
select
  l.nombre,
  l.sku_final,
  nullif(l.ean, ''),
  l.categoria,
  'marca',
  'Bajo pedido · mepiel'
    || coalesce(' · ' || nullif(l.linea, ''), '')
    || coalesce(' · oferta ' || nullif(l.oferta, ''), ''),
  l.costo,
  0,
  0, 1, true, false,
  l.marca, l.presentacion, l.subcategoria, nullif(l.imagen_url, ''), true,
  nullif(l.concentracion, ''), nullif(l.forma, '')
from listos l
on conflict (sku) do nothing;

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
  from public._fc_mepiel_stg t
 where coalesce(p.stock, 0) = 0
   and coalesce(p.precio, 0) <= 0.01
   and (
     p.codigo_barras = t.ean
     or p.id = public.fc_buscar_producto_escaneo(t.ean)
   );

delete from public.producto_precios_referencia r
 using public._fc_mepiel_stg t
 join public.productos p
   on p.codigo_barras = t.ean
   or p.id = public.fc_buscar_producto_escaneo(t.ean)
 where r.producto_id = p.id
   and r.fuente = 'mepiel'
   and r.origen = 'import_xlsx'
   and r.fecha = current_date;

insert into public.producto_precios_referencia
  (producto_id, fuente, tipo, precio, sku_externo, origen, notas)
select distinct on (p.id)
  p.id, 'mepiel', 'compra', t.costo, t.ean, 'import_xlsx',
  'Lista ME Piel 2026 · precio cliente c/IVA'
    || coalesce(' · PVP c/IVA ' || t.techo::text, '')
    || coalesce(' · oferta ' || nullif(t.oferta, ''), '')
  from public._fc_mepiel_stg t
  join public.productos p
    on p.codigo_barras = t.ean
    or p.id = public.fc_buscar_producto_escaneo(t.ean)
 where t.costo is not null and t.costo > 0
 order by p.id, t.costo;

drop table if exists public._fc_mepiel_stg;
commit;

select
  count(*) filter (where coalesce(bajo_pedido, false)) as bajo_pedido,
  count(*) filter (
    where coalesce(bajo_pedido, false)
      and descripcion ilike '%mepiel%'
  ) as alta_mepiel_nueva
from public.productos;
