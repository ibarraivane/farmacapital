-- Ficha partida: empaque/volumen empotrado en nombre → presentacion
-- si presentacion está vacía. NO toca marca ni principio_activo.
-- NO quita mg / dosis del nombre (400 mg vs 600 mg no pueden colapsar).
-- Idempotente. Revisar el SELECT de control antes de aplicar en producción.

begin;

-- 1) C/24 · C/24 tabletas al final del nombre
update public.productos p
set
  presentacion = btrim((regexp_match(p.nombre, '(c/\s*[0-9]+(?:\s+(?:tabletas?|tabs?|c[aá]psulas?|capsulas?|caps?))?)\s*$', 'i'))[1]),
  nombre = btrim(regexp_replace(p.nombre, '\s+c/\s*[0-9]+(?:\s+(?:tabletas?|tabs?|c[aá]psulas?|capsulas?|caps?))?\s*$', '', 'i'))
where coalesce(btrim(p.presentacion), '') = ''
  and p.nombre ~* '\sc/\s*[0-9]+(?:\s+(?:tabletas?|tabs?|c[aá]psulas?|capsulas?|caps?))?\s*$'
  and length(btrim(regexp_replace(p.nombre, '\s+c/\s*[0-9]+(?:\s+(?:tabletas?|tabs?|c[aá]psulas?|capsulas?|caps?))?\s*$', '', 'i'))) >= 2;

-- 2) 20 tabletas / 10 cápsulas al final (no la dosis en mg)
update public.productos p
set
  presentacion = btrim((regexp_match(p.nombre, '([0-9]+\s+(?:tabletas?|tabs?|c[aá]psulas?|capsulas?|caps?|comprimidos?))\s*$', 'i'))[1]),
  nombre = btrim(regexp_replace(p.nombre, '\s+[0-9]+\s+(?:tabletas?|tabs?|c[aá]psulas?|capsulas?|caps?|comprimidos?)\s*$', '', 'i'))
where coalesce(btrim(p.presentacion), '') = ''
  and p.nombre ~* '\s[0-9]+\s+(?:tabletas?|tabs?|c[aá]psulas?|capsulas?|caps?|comprimidos?)\s*$'
  and length(btrim(regexp_replace(p.nombre, '\s+[0-9]+\s+(?:tabletas?|tabs?|c[aá]psulas?|capsulas?|caps?|comprimidos?)\s*$', '', 'i'))) >= 2;

-- 3) 40 ml / 120 g al final. Nunca mg.
update public.productos p
set
  presentacion = btrim((regexp_match(p.nombre, '([0-9]+(?:[.,][0-9]+)?\s*(?:ml|l|g|gr))\s*$', 'i'))[1]),
  nombre = btrim(regexp_replace(p.nombre, '\s+[0-9]+(?:[.,][0-9]+)?\s*(?:ml|l|g|gr)\s*$', '', 'i'))
where coalesce(btrim(p.presentacion), '') = ''
  and p.nombre ~* '\s[0-9]+(?:[.,][0-9]+)?\s*(?:ml|l|g|gr)\s*$'
  and p.nombre !~* '\s[0-9]+(?:[.,][0-9]+)?\s*mg\s*$'
  and length(btrim(regexp_replace(p.nombre, '\s+[0-9]+(?:[.,][0-9]+)?\s*(?:ml|l|g|gr)\s*$', '', 'i'))) >= 2;

-- 4) Altas nuevas: persistir ficha partida en create_producto_with_lote
create or replace function public.create_producto_with_lote(
  p_producto_data jsonb,
  p_cantidad_inicial integer default 0,
  p_numero_lote text default null,
  p_fecha_caducidad date default null,
  p_costo_unitario numeric default null,
  p_user_id bigint default null,
  p_proveedor_tienda text default null
)
returns table(producto_id bigint, lote_id bigint)
language plpgsql
security definer
set search_path = public
as $$
declare
  v_producto_id bigint;
  v_lote_id bigint := null;
  v_lote_numero text;
  v_proveedor_id bigint;
  v_proveedor_nombre text;
begin
  if p_producto_data is null then
    raise exception 'producto_data requerido';
  end if;
  if (p_producto_data->>'nombre') is null or btrim(p_producto_data->>'nombre') = '' then
    raise exception 'nombre requerido';
  end if;

  v_proveedor_nombre := coalesce(
    nullif(btrim(p_proveedor_tienda), ''),
    nullif(btrim(p_producto_data->>'proveedor_tienda'), '')
  );
  v_proveedor_id := public.fc_resolver_proveedor_tienda(v_proveedor_nombre);

  insert into public.productos (
    nombre,
    sku,
    precio,
    costo,
    stock,
    stock_minimo,
    stock_unidades,
    categoria,
    tipo,
    descripcion,
    codigo_barras,
    requiere_receta,
    activo,
    marca,
    presentacion,
    principio_activo,
    concentracion,
    forma_farmaceutica
  ) values (
    p_producto_data->>'nombre',
    p_producto_data->>'sku',
    nullif(p_producto_data->>'precio', '')::numeric,
    nullif(p_producto_data->>'costo', '')::numeric,
    0,
    coalesce(nullif(p_producto_data->>'stock_minimo', '')::integer, 5),
    coalesce(nullif(p_producto_data->>'stock_unidades', '')::integer, 0),
    coalesce(nullif(p_producto_data->>'categoria', ''), 'GENERAL'),
    coalesce(nullif(p_producto_data->>'tipo', ''), 'GENERICO'),
    p_producto_data->>'descripcion',
    nullif(p_producto_data->>'codigo_barras', ''),
    coalesce(nullif(p_producto_data->>'requiere_receta', '')::boolean, false),
    coalesce(nullif(p_producto_data->>'activo', '')::boolean, true),
    nullif(btrim(p_producto_data->>'marca'), ''),
    nullif(btrim(p_producto_data->>'presentacion'), ''),
    nullif(btrim(p_producto_data->>'principio_activo'), ''),
    nullif(btrim(p_producto_data->>'concentracion'), ''),
    nullif(btrim(p_producto_data->>'forma_farmaceutica'), '')
  ) returning id into v_producto_id;

  if coalesce(p_cantidad_inicial, 0) > 0 then
    v_lote_numero := coalesce(
      p_numero_lote,
      'INICIAL-' || to_char(now(), 'YYYYMMDD-HH24MISS')
    );

    insert into public.lotes (
      producto_id, numero_lote, cantidad_inicial, cantidad_actual,
      fecha_caducidad, costo_unitario, proveedor_id, activo
    ) values (
      v_producto_id,
      v_lote_numero,
      p_cantidad_inicial, p_cantidad_inicial,
      p_fecha_caducidad,
      coalesce(p_costo_unitario, nullif(p_producto_data->>'costo', '')::numeric),
      v_proveedor_id,
      true
    ) returning id into v_lote_id;

    insert into public.movimientos_inventario (
      producto_id, tipo, cantidad, motivo, usuario_id
    ) values (
      v_producto_id, 'entrada', p_cantidad_inicial,
      'Alta de producto con stock inicial',
      p_user_id::integer
    );
  end if;

  return query select v_producto_id, v_lote_id;
end;
$$;

commit;
