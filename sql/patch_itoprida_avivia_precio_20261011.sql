-- Itoprida Avivia 50 mg · caja con 30 tabletas
-- EAN 7503049078205 · SKU FC-49078205
--
-- El conteo Cyntia (7-oct-2026) lo dio de alta con precio 0, por eso
-- Inventario dice «No vendible». Stock y caducidad no se tocan.
--
-- Costo: no hay ticket de esta caja. Ancla el Lapriver itoprida 50 mg
-- C/30 (EAN 7502009747328), Equilibrio 14-sep-2026, $60.51. Mismo
-- principio y misma presentación. No es el precio público Nadro ($395).
-- Genérico: recargo +60% sobre el costo → 60.51 × 1.60 = 96.82 → $97.
--
-- Ficha de la caja (Nadro / packshot): marca Avivia, no «Avivid» ni LGEN.
-- Registro 442M2023 SSA IV: la caja pide receta. No es controlado.
--
-- Foto: public/catalogo-propia/itoprida-50-mg-c-30-avivia-7503049078205.jpg
-- Orden: 1) deploy de este commit  2) pegar este SQL en Supabase.
-- Si corres el SQL antes, el precio ya queda y la foto da 404 hasta el deploy.
-- Idempotente: no pisa un costo o un precio que ya hayan capturado,
-- ni una foto distinta.

begin;

do $$
declare
  v_pid bigint;
  v_precio numeric;
  v_costo numeric;
  v_url text := 'https://www.farmacapital.mx/catalogo-propia/itoprida-50-mg-c-30-avivia-7503049078205.jpg';
  v_pos integer;
begin
  select id, precio, costo
    into v_pid, v_precio, v_costo
    from public.productos
   where codigo_barras = '7503049078205'
      or sku = 'FC-49078205'
   order by case when codigo_barras = '7503049078205' then 0 else 1 end
   limit 1;

  if v_pid is null then
    raise exception 'No está Itoprida Avivia (FC-49078205 / 7503049078205). Corre antes el alta del conteo.';
  end if;

  update public.productos set
    nombre = 'Itoprida 50 mg',
    marca = 'Avivia',
    presentacion = 'Caja con 30 tabletas',
    concentracion = '50 mg',
    principio_activo = 'Itoprida',
    forma_farmaceutica = 'Tabletas',
    categoria = 'Medicamentos',
    subcategoria = 'Gastro',
    tipo = 'generico',
    requiere_receta = true,
    costo = case when coalesce(costo, 0) <= 0 then 60.51 else costo end,
    precio = case when coalesce(precio, 0) <= 0.01 then 97 else precio end,
    imagen_url = case
      when imagen_url is null or btrim(imagen_url) = '' then v_url
      else imagen_url
    end,
    imagen_mobile_url = case
      when imagen_mobile_url is null or btrim(imagen_mobile_url) = '' then v_url
      else imagen_mobile_url
    end,
    descripcion = case
      when descripcion is null
        or descripcion ilike '%Conteo Cyntia%'
        or descripcion ilike '%Avivid%'
      then 'Itoprida 50 mg, caja con 30 tabletas. Avivia Pharma. Registro 442M2023 SSA IV.'
      else descripcion
    end
  where id = v_pid;

  update public.lotes
     set costo_unitario = 60.51
   where producto_id = v_pid
     and coalesce(activo, true)
     and coalesce(cantidad_actual, 0) > 0
     and coalesce(costo_unitario, 0) <= 0;

  if not exists (
    select 1 from public.producto_imagenes
     where producto_id = v_pid and url = v_url
  ) then
    select coalesce(max(posicion), -1) + 1 into v_pos
      from public.producto_imagenes
     where producto_id = v_pid;
    insert into public.producto_imagenes
      (producto_id, url, storage_path, posicion, es_principal, origen)
    values (
      v_pid,
      v_url,
      'catalogo-propia/itoprida-50-mg-c-30-avivia-7503049078205.jpg',
      v_pos,
      false,
      'distribuidor'
    );
  end if;

  if not exists (
    select 1 from public.producto_imagenes
     where producto_id = v_pid
       and coalesce(es_principal, false)
       and url <> v_url
  ) then
    update public.producto_imagenes
       set es_principal = true
     where producto_id = v_pid
       and url = v_url
       and not coalesce(es_principal, false);
  end if;

  raise notice 'Itoprida Avivia id % · precio previo % · costo previo %', v_pid, v_precio, v_costo;
end
$$;

commit;

select p.sku, p.nombre, p.marca, p.presentacion, p.costo, p.precio,
       p.requiere_receta, p.stock,
       left(coalesce(p.imagen_url, ''), 80) as imagen
  from public.productos p
 where p.codigo_barras = '7503049078205'
    or p.sku = 'FC-49078205';
