-- Palmolive Optims sobre 10 ml: foto de pieza (+ exhibidor en galería).
-- DESPUÉS de que Vercel publique este commit (JPGs en
-- public/catalogo-propia/). Si corres el SQL antes, las URLs dan 404.
--
-- No toca stock ni caducidad. Precio se deja en $3 (margen ~48% con
-- costo 75.30/48 ≈ 1.57). Referencias: Básicos tira ≈ $2.80/sobre;
-- L'miau vende el par 2x1 a $4.

begin;

update public.productos
   set imagen_url = 'https://www.farmacapital.mx/catalogo-propia/palmolive-optims-sobre-10ml.jpg',
       imagen_mobile_url = 'https://www.farmacapital.mx/catalogo-propia/palmolive-optims-sobre-10ml.jpg'
 where sku = 'FC-EXP-OPT48'
    or codigo_barras = '7509546015699';

-- Galería: pieza principal, exhibidor de apoyo.
do $$
declare
  v_pid integer;
  v_url_pieza text := 'https://www.farmacapital.mx/catalogo-propia/palmolive-optims-sobre-10ml.jpg';
  v_url_box text := 'https://www.farmacapital.mx/catalogo-propia/palmolive-optims-exhibidor-48.jpg';
  v_pos integer;
begin
  select id into v_pid
    from public.productos
   where sku = 'FC-EXP-OPT48'
      or codigo_barras = '7509546015699'
   order by case when sku = 'FC-EXP-OPT48' then 0 else 1 end
   limit 1;

  if v_pid is null then
    raise exception 'No está el Optims (FC-EXP-OPT48 / 7509546015699). Corre antes patch_optims_venta_pieza_20260904.sql';
  end if;

  update public.producto_imagenes
     set es_principal = false
   where producto_id = v_pid
     and es_principal;

  -- Pieza
  if exists (
    select 1 from public.producto_imagenes
     where producto_id = v_pid and url = v_url_pieza
  ) then
    update public.producto_imagenes
       set es_principal = true,
           origen = 'propia',
           storage_path = 'catalogo-propia/palmolive-optims-sobre-10ml.jpg'
     where producto_id = v_pid and url = v_url_pieza;
  else
    select coalesce(max(posicion), -1) + 1 into v_pos
      from public.producto_imagenes where producto_id = v_pid;
    insert into public.producto_imagenes
      (producto_id, url, storage_path, posicion, es_principal, origen)
    values
      (v_pid, v_url_pieza, 'catalogo-propia/palmolive-optims-sobre-10ml.jpg',
       v_pos, true, 'propia');
  end if;

  -- Exhibidor (no principal)
  if not exists (
    select 1 from public.producto_imagenes
     where producto_id = v_pid and url = v_url_box
  ) then
    select coalesce(max(posicion), -1) + 1 into v_pos
      from public.producto_imagenes where producto_id = v_pid;
    insert into public.producto_imagenes
      (producto_id, url, storage_path, posicion, es_principal, origen)
    values
      (v_pid, v_url_box, 'catalogo-propia/palmolive-optims-exhibidor-48.jpg',
       v_pos, false, 'propia');
  end if;
end
$$;

commit;

select p.sku, left(p.nombre, 48) as nombre, p.codigo_barras as ean,
       p.costo, p.precio,
       round(((p.precio - p.costo) / nullif(p.precio, 0)) * 100, 1) as margen_pct,
       left(p.imagen_url, 72) as imagen
  from public.productos p
 where p.sku = 'FC-EXP-OPT48'
    or p.codigo_barras = '7509546015699';
