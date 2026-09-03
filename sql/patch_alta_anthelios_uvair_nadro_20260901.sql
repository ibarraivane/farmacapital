-- ============================================================================
-- FARMA CAPITAL — Anthelios UV Air 40 ml del ticket Nadro 20260901
--
-- Renglón 13: BLOQ ANTHE UVAIR 50+ FLU INV 40ML
-- EAN 3337875917810 · costo $372.20 · precio $497 · stock 0 hasta Recibir
-- Ficha de iNadro (metaTagDescription), no el código del PDF.
--
-- Esto NO es una de las 4 altas inventadas de UV Mune 400 50 ml ($522).
-- Esas se quedan apagadas. Este es el de la caja que llegó con Nadro.
--
-- Si la fila ya existe (EAN, SKU o nombre de ticket), la reactiva y
-- completa marca/foto. Si no, la crea. Stock 0: el lote lo pone Recibir.
-- Después: sql/patch_recibir_anthelios_uvair_nadro_20260901.sql
-- Pegar en Supabase → SQL Editor → Run.
-- ============================================================================

begin;

do $$
declare
  v_pid bigint;
  v_sku text := 'FC-75917810';
  v_ean text := '3337875917810';
  v_foto text := 'https://nadro.vtexassets.com/arquivos/ids/218211/3337875917810_01.jpg';
  v_inventados text[] := array[
    '3337875797597',
    '3337875797641',
    '3337875847292',
    '3337875847087'
  ];
begin
  v_pid := public.fc_buscar_producto_escaneo(v_ean);

  if v_pid is null then
    select p.id into v_pid
      from public.productos p
     where p.sku = v_sku
       and coalesce(p.codigo_barras, '') not in (
             '3337875797597', '3337875797641', '3337875847292', '3337875847087'
           )
     limit 1;
  end if;

  if v_pid is null then
    select p.id into v_pid
      from public.productos p
     where (
             p.nombre ilike '%BLOQ ANTHE UVAIR%'
          or p.nombre ilike '%Anthelios UV Air%'
           )
       and coalesce(p.codigo_barras, '') <> all (v_inventados)
     limit 1;
  end if;

  if v_pid is not null then
    if exists (
      select 1 from public.productos p
       where p.id = v_pid
         and p.codigo_barras = any (v_inventados)
    ) then
      raise exception 'No se toca un SKU inventado de UV Mune 400 50 ml';
    end if;

    update public.productos
       set activo = true,
           nombre = 'La Roche-Posay Anthelios UV Air FPS 50+ Protector Solar Ligero 40 ml',
           marca = 'La Roche-Posay',
           presentacion = '40 ml',
           categoria = 'Cuidado personal',
           subcategoria = 'Protector solar',
           forma_farmaceutica = 'Fluido',
           tipo = 'marca',
           requiere_receta = false,
           codigo_barras = v_ean,
           imagen_url = coalesce(nullif(imagen_url, ''), v_foto),
           costo = case when coalesce(costo, 0) <= 0.01 then 372.20 else costo end,
           precio = case when coalesce(precio, 0) <= 1 then 497 else precio end,
           descripcion = trim(both ' ·' from concat_ws(
             ' · ',
             nullif(trim(both ' ·' from coalesce(descripcion, '')), ''),
             'Nadro 20260901 BLOQ ANTHE UVAIR 50+ FLU INV 40ML · ficha iNadro'
           ))
     where id = v_pid;
  else
    if exists (
      select 1 from public.productos p
       where p.sku = v_sku
         and coalesce(p.codigo_barras, '') <> v_ean
    ) then
      v_sku := 'FC-ND-75917810';
    end if;

    insert into public.productos (
      nombre, sku, codigo_barras, categoria, tipo, descripcion,
      costo, precio, stock, stock_minimo, activo, requiere_receta,
      marca, presentacion, forma_farmaceutica, subcategoria, imagen_url
    ) values (
      'La Roche-Posay Anthelios UV Air FPS 50+ Protector Solar Ligero 40 ml',
      v_sku,
      v_ean,
      'Cuidado personal',
      'marca',
      'Nadro 20260901 · BLOQ ANTHE UVAIR 50+ FLU INV 40ML · ficha iNadro',
      372.20,
      497,
      0,
      1,
      true,
      false,
      'La Roche-Posay',
      '40 ml',
      'Fluido',
      'Protector solar',
      v_foto
    )
    returning id into v_pid;
  end if;

  if not exists (
    select 1 from public.producto_imagenes i
     where i.producto_id = v_pid
       and i.url = v_foto
  ) then
    insert into public.producto_imagenes
      (producto_id, url, posicion, es_principal, origen)
    values (v_pid, v_foto, 1, true, 'distribuidor');
  end if;

  raise notice 'Anthelios UV Air 40 ml listo id=% sku=%', v_pid, v_sku;
end
$$;

commit;

select
  p.sku,
  p.codigo_barras as ean,
  p.nombre,
  p.marca,
  p.presentacion,
  p.activo,
  p.stock,
  p.precio,
  p.costo
from public.productos p
where p.codigo_barras in (
  '3337875917810',
  '3337875797597',
  '3337875797641',
  '3337875847292',
  '3337875847087'
)
   or p.nombre ilike '%Anthelios UV Air%'
   or p.nombre ilike '%BLOQ ANTHE UVAIR%'
order by p.codigo_barras;
