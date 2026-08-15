-- Regla precio por pieza en plataforma (Supabase)
-- Ejecutar UNA vez en SQL Editor después de los patches de catálogo.
--
-- 1) Función calc_precio_unidad_sugerido (misma lógica que src/utils/precioUnidad.js)
-- 2) Trigger: al guardar producto con venta_unidad, precio_unidad >= regla
-- 3) Recalcula todos los productos venta_unidad activos
-- 4) POS: create_sale_transaction_v2 usa la regla si precio_unidad falta

begin;

-- ── 1. Función de cálculo ──
create or replace function public.calc_precio_unidad_sugerido(
  p_costo numeric,
  p_precio_caja numeric,
  p_upc integer,
  p_categoria text default '',
  p_tipo text default ''
)
returns numeric
language plpgsql
immutable
as $$
declare
  v_cu numeric;
  v_recargo numeric := 0.50;
  v_por_costo numeric;
  v_por_util numeric;
  v_por_penalty numeric;
begin
  if p_upc is null or p_upc <= 0 then
    return 0;
  end if;

  v_cu := coalesce(p_costo, 0) / p_upc;

  if lower(coalesce(p_categoria, '')) = 'general'
     or lower(coalesce(p_tipo, '')) in ('generico', 'generico') then
    v_recargo := 0.75;
  elsif lower(coalesce(p_categoria, '')) in ('higiene', 'cuidado personal', 'bebés', 'bebes') then
    v_recargo := 0.55;
  end if;

  v_por_costo := ceil(v_cu * (1 + v_recargo));
  v_por_util := ceil(v_cu + case when v_cu < 20 then 5 else 8 end);
  v_por_penalty := ceil(coalesce(p_precio_caja, 0) * 1.12 / p_upc);

  return greatest(v_por_costo, v_por_util, v_por_penalty);
end;
$$;

-- Precio efectivo en venta (guardado vs regla)
create or replace function public.precio_unidad_efectivo(
  p_costo numeric,
  p_precio_caja numeric,
  p_upc integer,
  p_categoria text,
  p_tipo text,
  p_precio_unidad_guardado numeric
)
returns numeric
language sql
immutable
as $$
  select greatest(
    coalesce(nullif(p_precio_unidad_guardado, 0), 0),
    public.calc_precio_unidad_sugerido(
      p_costo, p_precio_caja, p_upc, p_categoria, p_tipo
    )
  );
$$;

-- ── 2. Trigger en productos ──
create or replace function public.trg_enforce_precio_unidad()
returns trigger
language plpgsql
as $$
begin
  if coalesce(new.venta_unidad, false)
     and coalesce(new.unidades_por_caja, 0) > 0 then
    new.precio_unidad := public.precio_unidad_efectivo(
      new.costo,
      new.precio,
      new.unidades_por_caja,
      new.categoria,
      new.tipo,
      new.precio_unidad
    );
  elsif not coalesce(new.venta_unidad, false) then
    new.precio_unidad := 0;
    new.unidades_por_caja := 0;
  end if;
  return new;
end;
$$;

drop trigger if exists trg_productos_enforce_precio_unidad on public.productos;
create trigger trg_productos_enforce_precio_unidad
  before insert or update of costo, precio, unidades_por_caja, venta_unidad,
    precio_unidad, categoria, tipo
  on public.productos
  for each row
  execute function public.trg_enforce_precio_unidad();

-- ── 3. Recalcular catálogo actual ──
update public.productos p
set precio_unidad = public.precio_unidad_efectivo(
  p.costo,
  p.precio,
  p.unidades_por_caja,
  p.categoria,
  p.tipo,
  p.precio_unidad
)
where coalesce(p.venta_unidad, false) = true
  and coalesce(p.unidades_por_caja, 0) > 0
  and coalesce(p.activo, true) = true;

commit;

grant execute on function public.calc_precio_unidad_sugerido(numeric, numeric, integer, text, text)
  to anon, authenticated;
grant execute on function public.precio_unidad_efectivo(numeric, numeric, integer, text, text, numeric)
  to anon, authenticated;

-- Paso 2 (mismo SQL Editor, después del commit): ejecutar también
--   sql/patch_create_sale_precio_unidad_regla.sql
-- para que el POS cobre la regla al vender piezas sueltas.

-- Verificación
select sku, nombre, precio, costo, unidades_por_caja, precio_unidad,
  public.calc_precio_unidad_sugerido(costo, precio, unidades_por_caja, categoria, tipo) as min_regla
from public.productos
where coalesce(venta_unidad, false) = true and coalesce(activo, true) = true
order by nombre;
