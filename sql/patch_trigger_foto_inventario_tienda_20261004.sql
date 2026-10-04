-- Conecta la foto de inventario con la de la tienda.
--
-- La tienda publicada lee primero producto_imagenes, no productos.imagen_url.
-- El parche anterior alineó las fotos que ya estaban distintas en ese
-- instante. El siguiente guardado (Bocetix, 15:56) escribió la ficha y
-- dejó la galería vieja: la tienda no cambió.
--
-- Este trigger corre en cada UPDATE de imagen_url. La foto de la ficha
-- queda como la única de la galería. Si la quitan, la galería se borra.
-- No toca un guardado que manda la misma URL (el desktop.jpg viejo sigue
-- con su foto Rappi).
--
-- Ejecutar en Supabase SQL Editor. Idempotente.

begin;

create or replace function public.fn_enlazar_foto_tienda()
returns trigger
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_url text := btrim(coalesce(new.imagen_url, ''));
  v_base text;
begin
  if tg_op = 'UPDATE'
     and new.imagen_url is not distinct from old.imagen_url then
    return new;
  end if;

  if v_url = '' then
    delete from public.producto_imagenes where producto_id = new.id;
    return new;
  end if;

  v_base := split_part(v_url, '?', 1);

  if exists (
    select 1
      from public.producto_imagenes
     where producto_id = new.id
    having count(*) = 1
       and bool_or(es_principal)
       and bool_or(split_part(btrim(url), '?', 1) = v_base)
  ) then
    update public.producto_imagenes
       set url = v_url,
           es_principal = true,
           updated_at = now()
     where producto_id = new.id;
    return new;
  end if;

  delete from public.producto_imagenes where producto_id = new.id;
  insert into public.producto_imagenes (producto_id, url, posicion, es_principal, origen)
  values (new.id, v_url, 1, true, 'propia');
  return new;
end;
$$;

drop trigger if exists trg_enlazar_foto_tienda on public.productos;
create trigger trg_enlazar_foto_tienda
  after update of imagen_url
  on public.productos
  for each row
  execute procedure public.fn_enlazar_foto_tienda();

-- Lo que ya se guardó y la tienda sigue mostrando distinto.
-- No pisa desktop.jpg ni hotlinks de Del Ahorro.
do $$
declare
  r record;
begin
  for r in
    select p.id, btrim(p.imagen_url) as url
      from public.productos p
      join public.producto_imagenes i
        on i.producto_id = p.id
       and i.es_principal
     where coalesce(btrim(p.imagen_url), '') <> ''
       and split_part(btrim(p.imagen_url), '?', 1)
           is distinct from split_part(btrim(i.url), '?', 1)
       and btrim(p.imagen_url) !~ '/productos/[0-9]+/(desktop|mobile)\.(jpe?g|png|webp)(\?.*)?$'
       and btrim(p.imagen_url) !~* 'fahorro\.com'
  loop
    delete from public.producto_imagenes where producto_id = r.id;
    insert into public.producto_imagenes (producto_id, url, posicion, es_principal, origen)
    values (r.id, r.url, 1, true, 'propia');
  end loop;
end $$;

commit;
