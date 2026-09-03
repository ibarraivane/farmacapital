-- La Roche-Posay Anthelios que Nadro sí vende y no estaban en catálogo.
-- Stock 0: el lote y la caducidad los pone Recibir al escanear la caja.
-- Precio = Precio público Nadro ($521.98) redondeado. Costo de factura pendiente.
-- INSERT ONLY por EAN. Pegar en Supabase → SQL Editor → Run.

begin;

do $$
declare
  r record;
  v_pid bigint;
  v_sku text;
  v_creados int := 0;
  v_existian int := 0;
begin
  for r in
    select * from (values
      (
        '3337875797597',
        'FC-75797597',
        'La Roche Anthelios UV Mune 400 fluido invisible FPS50+ 50 ml',
        'Fluido',
        'https://nadro.vtexassets.com/arquivos/ids/198650/3337875797597_01.jpg'
      ),
      (
        '3337875797641',
        'FC-75797641',
        'La Roche Anthelios UV Mune 400 fluido con color FPS50+ 50 ml',
        'Fluido',
        'https://nadro.vtexassets.com/arquivos/ids/198911/3337875797641_01.jpg'
      ),
      (
        '3337875847292',
        'FC-75847292',
        'La Roche Anthelios UV Mune 400 oil control FPS50+ 50 ml',
        'Fluido',
        'https://nadro.vtexassets.com/arquivos/ids/202776/3337875847292_01.jpg'
      ),
      (
        '3337875847087',
        'FC-75847087',
        'La Roche Anthelios UV Mune 400 oil control con color FPS50+ 50 ml',
        'Fluido',
        'https://nadro.vtexassets.com/arquivos/ids/204494/3337875847087_01.jpg'
      )
    ) as t(ean, sku, nombre, forma, foto)
  loop
    v_pid := public.fc_buscar_producto_escaneo(r.ean);
    if v_pid is not null then
      v_existian := v_existian + 1;
      continue;
    end if;

    v_sku := r.sku;
    if exists (
      select 1 from public.productos p
      where p.sku = v_sku
        and coalesce(p.codigo_barras, '') <> r.ean
    ) then
      v_sku := 'FC-ND-' || right(r.ean, 8);
    end if;

    insert into public.productos (
      nombre, sku, codigo_barras, categoria, tipo, descripcion,
      costo, precio, stock, stock_minimo, activo, requiere_receta,
      marca, presentacion, forma_farmaceutica, subcategoria, imagen_url
    ) values (
      r.nombre,
      v_sku,
      r.ean,
      'Cuidado personal',
      'marca',
      'Alta Nadro Anthelios · 2026-09-03 · listo para pistola · falta costo de factura',
      0.01,
      522,
      0,
      1,
      true,
      false,
      'La Roche-Posay',
      '50 ml',
      r.forma,
      'Protector solar',
      r.foto
    )
    returning id into v_pid;

    insert into public.producto_imagenes
      (producto_id, url, posicion, es_principal, origen)
    values (v_pid, r.foto, 1, true, 'distribuidor');

    v_creados := v_creados + 1;
  end loop;

  raise notice 'Anthelios Nadro: creados=% ya_estaban=%', v_creados, v_existian;
end
$$;

commit;

select
  p.sku,
  p.codigo_barras as ean,
  p.nombre,
  p.marca,
  p.precio,
  p.costo,
  p.stock,
  p.imagen_url
from public.productos p
where p.codigo_barras in (
  '3337875797597',
  '3337875797641',
  '3337875847292',
  '3337875847087'
)
order by p.nombre;
