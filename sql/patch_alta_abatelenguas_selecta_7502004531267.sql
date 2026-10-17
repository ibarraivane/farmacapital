-- Alta anaquel: Abatelenguas de madera Selecta C/500
-- EAN caja 7502004531267 · lote 02/25 · cad. feb 2030 (impreso en etiqueta)
-- Distinto de Ambiderm bajo pedido (FC-88830907 / Ewafra).
-- Idempotente. Stock = 1 paquete (ajustar si hay más bolsas).
-- Foto: public/catalogo-propia/abatelenguas-madera-selecta-500-7502004531267.jpg
--   (imagen_url tras deploy). Precio ancla retail ~$160 (MedartMX); costo pendiente de ticket.

begin;

do $$
declare
  v_pid bigint;
  v_lid bigint;
  v_sum integer;
  v_ean text := '7502004531267';
  v_sku text := 'FC-04531267';
  v_stock integer := 1;
  v_lote text := '02/25';
  v_cad date := date '2030-02-28';
begin
  -- Liberar EAN si otro SKU lo tenía
  update public.productos
     set codigo_barras = null
   where codigo_barras = v_ean
     and sku is distinct from v_sku;

  select id into v_pid
    from public.productos
   where codigo_barras = v_ean
      or sku = v_sku
   limit 1;

  if v_pid is null then
    select f.producto_id, f.lote_id into v_pid, v_lid
      from public.create_producto_with_lote(
        jsonb_build_object(
          'nombre', 'Abatelenguas de madera',
          'sku', v_sku,
          'codigo_barras', v_ean,
          'categoria', 'Botiquín',
          'tipo', 'marca',
          'descripcion', 'Selecta · paquete 500 piezas en empaques de 25 · REG 1445C2016SSA · alta física 2026-10-08',
          'precio', 160,
          'stock_minimo', 1,
          'activo', true,
          'requiere_receta', false
        ),
        v_stock,
        v_lote,
        v_cad,
        null::numeric,
        null::bigint
      ) f;
    raise notice 'ALTA Abatelenguas Selecta id %', v_pid;
  else
    raise notice 'Ya existía id % — actualizo ficha y stock', v_pid;
  end if;

  update public.productos set
    sku = v_sku,
    codigo_barras = v_ean,
    nombre = 'Abatelenguas de madera',
    marca = 'Selecta',
    presentacion = 'Paquete con 500 piezas (empaques de 25)',
    forma_farmaceutica = 'Dispositivo',
    categoria = 'Botiquín',
    subcategoria = 'Material de curación',
    tipo = 'marca',
    precio = coalesce(nullif(precio, 0), 160),
    activo = true,
    bajo_pedido = false,
    imagen_url = coalesce(
      nullif(btrim(imagen_url), ''),
      'https://www.farmacapital.mx/catalogo-propia/abatelenguas-madera-selecta-500-7502004531267.jpg'
    )
  where id = v_pid;

  -- Stock vía lotes → v_stock
  select coalesce(sum(cantidad_actual), 0) into v_sum
    from public.lotes
   where producto_id = v_pid and coalesce(activo, true);

  if v_sum is distinct from v_stock then
    select id into v_lid
      from public.lotes
     where producto_id = v_pid
     order by coalesce(activo, true) desc, coalesce(cantidad_actual, 0) desc, id desc
     limit 1;

    if v_lid is null then
      insert into public.lotes (
        producto_id, numero_lote, cantidad_inicial, cantidad_actual,
        fecha_caducidad, costo_unitario, activo
      ) values (
        v_pid, v_lote, v_stock, v_stock, v_cad, null, true
      );
    else
      update public.lotes
         set cantidad_actual = 0, activo = false
       where producto_id = v_pid and id <> v_lid
         and coalesce(activo, true) and coalesce(cantidad_actual, 0) > 0;

      update public.lotes
         set cantidad_actual = v_stock,
             activo = true,
             numero_lote = coalesce(nullif(btrim(numero_lote), ''), v_lote),
             fecha_caducidad = coalesce(fecha_caducidad, v_cad),
             cantidad_inicial = greatest(coalesce(cantidad_inicial, 0), v_stock)
       where id = v_lid;
    end if;

    insert into public.movimientos_inventario (producto_id, tipo, cantidad, motivo)
    values (
      v_pid, 'ajuste', v_stock,
      'Alta física Abatelenguas Selecta 7502004531267 · stock ' || v_stock
    );
  end if;
end $$;

commit;

select p.sku, p.nombre, p.marca, p.presentacion, p.stock, p.precio,
       p.codigo_barras, p.categoria, p.bajo_pedido, p.imagen_url
  from public.productos p
 where p.sku = 'FC-04531267'
    or p.codigo_barras = '7502004531267';
