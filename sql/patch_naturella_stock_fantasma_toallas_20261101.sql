-- Naturella Noche / Flujo: POS mostraba «0 cajas · 0 blisters · 8 piezas»
-- sin bolsa abierta en anaquel. Qué pasó:
-- 1) Alguien tocó Pieza/Abrir caja → abrir_caja sumó unidades_por_caja (8) a
--    stock_unidades y bajó la bolsa cerrada.
-- 2) El backfill de blisters (C/8 → piezas_por_blister=4) inventó botón Blister
--    en toallas; no son tiras de medicina.
--
-- Este patch: pone a 0 las piezas fantasma de Naturella (conteo físico = 0),
-- limpia blister en toallas Naturella/Saba/Kotex/Always, y endurece
-- abrir_caja_lote para que toallas nunca abran a blisters. Idempotente.
-- Ejecutar en Supabase SQL Editor.

begin;

-- Fantasma Naturella: 8 piezas sueltas sin bolsa abierta.
update public.productos
   set stock_unidades = 0,
       stock_blisters = 0,
       piezas_por_blister = 0,
       precio_blister = 0
 where sku in ('FC-01405335', 'FC-01157296')
   and (
     coalesce(stock_unidades, 0) <> 0
     or coalesce(stock_blisters, 0) <> 0
     or coalesce(piezas_por_blister, 0) <> 0
     or coalesce(precio_blister, 0) <> 0
   );

-- Toallas / marcas de bolsa: nunca blister de medicina.
update public.productos p
   set piezas_por_blister = 0,
       precio_blister = 0,
       stock_blisters = 0
 where (
     coalesce(p.piezas_por_blister, 0) <> 0
     or coalesce(p.precio_blister, 0) <> 0
     or coalesce(p.stock_blisters, 0) <> 0
   )
   and (
     lower(coalesce(p.forma_farmaceutica, '')) ~ 'toallas?\s+sanitari'
     or lower(coalesce(p.nombre, '') || ' ' || coalesce(p.marca, '') || ' ' || coalesce(p.presentacion, ''))
        ~ '(naturella|saba|kotex|always|nosotras|pantiprotector|toallas?\s+femenin)'
   );

create or replace function public.es_empaque_toallas_sin_blister(
  p_nombre text,
  p_marca text,
  p_presentacion text,
  p_forma text,
  p_categoria text
)
returns boolean
language sql
immutable
as $$
  select
    lower(coalesce(p_forma, '')) ~ 'toallas?\s+sanitari'
    or lower(
      coalesce(p_nombre, '') || ' ' ||
      coalesce(p_marca, '') || ' ' ||
      coalesce(p_presentacion, '') || ' ' ||
      coalesce(p_categoria, '')
    ) ~ '(naturella|saba|kotex|always|nosotras|pantiprotector|toallas?\s+femenin|toallas?\s+sanitari)';
$$;

comment on function public.es_empaque_toallas_sin_blister(text, text, text, text, text) is
  'True si el producto es bolsa de toallas/protectores: no usa blisters de medicina.';

-- abrir_caja_lote: toallas siempre sueltan piezas, nunca blisters (ppb sucio).
create or replace function public.abrir_caja_lote(
  p_producto_id bigint,
  p_user_id bigint
)
returns table(stock_nuevo integer, stock_unidades_nuevo integer, stock_blisters_nuevo integer)
language plpgsql
security definer
set search_path = public
as $$
declare
  v_upc integer;
  v_ppb integer;
  v_blisters integer;
  v_stock_unidades_actual integer;
  v_stock_blisters_actual integer;
  v_producto_stock integer;
  v_lote_id bigint;
  v_lote_cantidad integer;
  v_es_toalla boolean;
begin
  if p_producto_id is null then raise exception 'producto_id requerido'; end if;
  if p_user_id is null then raise exception 'user_id requerido'; end if;

  select
    greatest(coalesce(p.unidades_por_caja, 1), 1),
    coalesce(p.piezas_por_blister, 0),
    coalesce(p.stock_unidades, 0),
    coalesce(p.stock_blisters, 0),
    coalesce(p.stock, 0),
    public.es_empaque_toallas_sin_blister(
      p.nombre, p.marca, p.presentacion, p.forma_farmaceutica, p.categoria
    )
  into v_upc, v_ppb, v_stock_unidades_actual, v_stock_blisters_actual, v_producto_stock, v_es_toalla
  from public.productos p
  where p.id = p_producto_id
  for update;

  if not found then
    raise exception 'producto % no existe', p_producto_id;
  end if;

  if v_producto_stock <= 0 then
    raise exception 'producto % no tiene cajas disponibles', p_producto_id;
  end if;

  select f.lote_id, f.cantidad_disponible
    into v_lote_id, v_lote_cantidad
  from public.get_lote_fefo(p_producto_id) f;

  if not found or coalesce(v_lote_cantidad, 0) < 1 then
    raise exception 'sin lotes disponibles para producto %', p_producto_id;
  end if;

  update public.lotes
  set
    cantidad_actual = greatest(0, coalesce(cantidad_actual, 0) - 1),
    activo = case
      when greatest(0, coalesce(cantidad_actual, 0) - 1) <= 0 then false
      else activo
    end
  where id = v_lote_id;

  if v_es_toalla then
    v_ppb := 0;
  end if;
  v_blisters := public.blisters_por_caja(v_upc, v_ppb);

  if v_blisters >= 2 then
    update public.productos
    set stock_blisters = v_stock_blisters_actual + v_blisters
    where id = p_producto_id;

    insert into public.movimientos_inventario (
      producto_id, tipo, cantidad, motivo, usuario_id
    ) values (
      p_producto_id, 'ajuste', 1,
      format('Abrir caja (+%s blisters)', v_blisters),
      p_user_id
    );
  else
    update public.productos
    set stock_unidades = v_stock_unidades_actual + v_upc
    where id = p_producto_id;

    insert into public.movimientos_inventario (
      producto_id, tipo, cantidad, motivo, usuario_id
    ) values (
      p_producto_id, 'ajuste', 1,
      format('Abrir caja (+%s unidades sueltas)', v_upc),
      p_user_id
    );
  end if;

  return query
  select p.stock, p.stock_unidades, p.stock_blisters
  from public.productos p
  where p.id = p_producto_id;
end;
$$;

revoke execute on function public.abrir_caja_lote(bigint, bigint)
  from public, anon, authenticated;

commit;

select sku, nombre, stock, stock_unidades, stock_blisters,
       unidades_por_caja, piezas_por_blister, precio, precio_unidad, precio_blister,
       venta_unidad, presentacion, forma_farmaceutica
  from public.productos
 where sku in ('FC-01405335', 'FC-01157296', 'FC-19006623')
 order by sku;
