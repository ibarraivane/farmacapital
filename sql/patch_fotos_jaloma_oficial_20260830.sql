-- Packshots oficiales de jaloma.com.mx (tienda WooCommerce, 2026-08-30).
-- Solo SKUs cuyo nombre y presentación coinciden con la ficha oficial.
-- No inventa fotos ni usa otra presentación.
--
-- Omitido a propósito:
--   FC-84900280 Jaloma Agua de Rosas (EAN 7596849002808):
--   la tienda oficial solo publica 250 ml; ese EAN aparece en retail como 130 ml.
--
-- Idempotente: no pisa imagen_url si ya hay foto; no duplica la URL oficial.

begin;

create temporary table jaloma_oficial (
  producto_id integer primary key,
  sku         text not null,
  foto        text not null
) on commit drop;

insert into jaloma_oficial (producto_id, sku, foto) values
  (1129, 'FMX-307574', 'https://jaloma.com.mx/wp-content/uploads/2025/04/Copia-de-115493.png'),
  (1102, 'FMX-301516', 'https://jaloma.com.mx/wp-content/uploads/2025/04/Copia-de-115488.png'),
  (278,  'FC-84437151', 'https://jaloma.com.mx/wp-content/uploads/2025/03/Acetona-frasco-120-ml.png'),
  (734,  'FC-84154058', 'https://jaloma.com.mx/wp-content/uploads/2025/04/Copia-de-115409.png'),
  (732,  'FC-84273094', 'https://jaloma.com.mx/wp-content/uploads/2025/04/Copia-de-Copia-de-Kiuts-Multiaplicadores-tarro-18x50-pz.png');

update public.productos p
set
  imagen_url = o.foto,
  imagen_mobile_url = o.foto
from jaloma_oficial o
where p.id = o.producto_id
  and p.sku = o.sku
  and coalesce(nullif(trim(p.imagen_url), ''), '') = '';

-- La galería manda sobre imagen_url. Oficial como principal (POS)
-- y posición 0 para que salga primero en Tienda si esa plaza está libre.
insert into public.producto_imagenes (
  producto_id, url, posicion, es_principal, origen
)
select
  o.producto_id,
  o.foto,
  case
    when exists (
      select 1 from public.producto_imagenes x
      where x.producto_id = o.producto_id and x.posicion = 0
    ) then (
      select coalesce(max(x.posicion), 0) + 1
      from public.producto_imagenes x
      where x.producto_id = o.producto_id
    )
    else 0
  end,
  false,
  'distribuidor'
from jaloma_oficial o
where not exists (
  select 1
  from public.producto_imagenes x
  where x.producto_id = o.producto_id
    and x.url = o.foto
);

update public.producto_imagenes gi
set es_principal = (gi.url = o.foto)
from jaloma_oficial o
where gi.producto_id = o.producto_id;

commit;
