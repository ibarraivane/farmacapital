-- 24a lote 2 de 4 — da de alta los productos que aún no están.
-- No vuelvas a correr 00 ni 01…23.
-- Solo compara código de barras y SKU. No llama fc_buscar_producto_escaneo.
begin;

do $$
begin
  if to_regclass('public._fc_mepiel_stg') is null then
    raise exception 'Falta la tabla temporal de ME Piel. No vuelvas a correr el 00.';
  end if;
end $$;

create index if not exists _fc_mepiel_stg_ean_idx on public._fc_mepiel_stg (ean);

with base as (
  select distinct on (ean) s.*
  from public._fc_mepiel_stg s
  where nullif(btrim(s.ean), '') is not null
  order by s.ean, s.costo nulls last
),
ranked as (
  select b.*,
         row_number() over (partition by b.sku order by b.ean) as rn
  from base b
)
insert into public.productos (
  nombre, sku, codigo_barras, categoria, tipo, descripcion,
  costo, precio, stock, stock_minimo, activo, requiere_receta,
  marca, presentacion, subcategoria, imagen_url, bajo_pedido,
  concentracion, forma_farmaceutica
)
select
  r.nombre,
  case
    when r.rn = 1 and ps.id is null then r.sku
    when pm.id is null then 'FC-MP-' || r.ean
    else 'FC-MP-' || r.ean || '-' || r.rn::text
  end,
  r.ean,
  r.categoria,
  'marca',
  'Bajo pedido · mepiel'
    || coalesce(' · ' || nullif(r.linea, ''), '')
    || coalesce(' · oferta ' || nullif(r.oferta, ''), ''),
  r.costo,
  0,
  0, 1, true, false,
  r.marca, r.presentacion, r.subcategoria, nullif(r.imagen_url, ''), true,
  nullif(r.concentracion, ''), nullif(r.forma, '')
from ranked r
left join public.productos pe on pe.codigo_barras = r.ean
left join public.productos ps on ps.sku = r.sku
left join public.productos pm on pm.sku = ('FC-MP-' || r.ean)
where pe.id is null
  and ((mod(hashtext(r.ean), 4) + 4) % 4) = 2
on conflict (sku) do nothing;

commit;

select 'lote 2' as paso;
