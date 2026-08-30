-- ============================================================================
-- Precio de oferta al público (mismo criterio que src/lib/precioOferta.js)
-- Fecha: 2026-08-30
--
-- `productos.precio` = precio normal.
-- Si hay descuento_pct o una campaña vigente, el cobro es el menor.
--
-- El checkout online (cliente_crear_pedido_online) sigue leyendo productos.precio
-- hasta que se sustituya por public.precio_oferta_publico(id) en las dos sumas
-- de línea. La tienda ya muestra y manda a Mercado Pago el precio oferta.
-- ============================================================================

create or replace function public.precio_oferta_publico(p_producto_id bigint)
returns numeric
language sql
stable
security invoker
set search_path = public, pg_temp
as $$
  with base as (
    select
      round(coalesce(p.precio, 0))::numeric as lista,
      coalesce(p.descuento_pct, 0)::numeric as pct
    from public.productos p
    where p.id = p_producto_id
  ),
  cand_prod as (
    select round(b.lista * (1 - least(99.99, greatest(0, b.pct)) / 100.0)) as oferta
    from base b
    where b.lista > 0 and b.pct > 0 and b.pct < 100
  ),
  cand_promo as (
    select
      case
        when pr.tipo = 'descuento_pct' and pr.valor > 0 and pr.valor < 100
          then round(b.lista * (1 - pr.valor / 100.0))
        when pr.tipo = 'descuento_fijo' and pr.valor > 0
          then round(b.lista - pr.valor)
        else null
      end as oferta
    from base b
    join public.promocion_productos pp on pp.producto_id = p_producto_id
    join public.promociones pr on pr.id = pp.promocion_id
    where pr.activa = true
      and (pr.fecha_inicio is null or pr.fecha_inicio <= (timezone('America/Mexico_City', now()))::date)
      and (pr.fecha_fin is null or pr.fecha_fin >= (timezone('America/Mexico_City', now()))::date)
  ),
  todos as (
    select oferta from cand_prod
    union all
    select oferta from cand_promo
  )
  select coalesce(
    (select min(oferta) from todos where oferta is not null and oferta > 0 and oferta < (select lista from base)),
    (select lista from base)
  );
$$;

comment on function public.precio_oferta_publico(bigint) is
  'Precio a mostrar/cobrar: menor entre lista, descuento_pct del producto y campañas % / $ vigentes.';

grant execute on function public.precio_oferta_publico(bigint) to anon, authenticated;
