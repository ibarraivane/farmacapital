-- Packshots oficiales de ficha de fabricante (2026-08-30).
-- Jaloma, Hinds, Nivea, Labello, Garnier.
-- Solo SKUs cuya ficha oficial coincide en producto y presentación,
-- o el EAN va en la URL / en el archivo oficial.
-- No inventa fotos ni usa otra presentación.
--
-- Omitido a propósito (página vista, no hay packshot usable):
--   FC-84900280 Jaloma Agua de Rosas (EAN 7596849002808, 130 ml):
--     jaloma.com.mx solo publica 250 ml.
--   FC-42270027 Nivea Facial 7 en 1 (EAN 42270027, 200 ml):
--     nivea.com.mx titula 7 en 1 pero el packshot de la ficha sigue
--     siendo «Facial 5 en uno Cuidado Tono Natural».
--   FC-54558682 Nivea Milk 400 ml (EAN 7501054558682):
--     la ficha oficial de 400 ml lleva otro EAN (7501054504535).
--   FC-54354677 Nivea Men: nombre genérico, EAN no está en nivea.com.mx.
--   Dove Original 135 g: ficha dove.com/mx con el EAN, CDN bloquea el GET.
--   Grisi manos, Ricitos, Xiomara, Rexona, Axe, Lubriderm 120 ml,
--     Listerine, Sensodyne, Suerox, Teatrical, Pantene, Gillette:
--     no hay ficha oficial con misma presentación o EAN.
--
-- Idempotente: no pisa imagen_url si ya hay foto; no duplica la URL oficial.

begin;

create temporary table oficial_20260830 (
  producto_id integer primary key,
  sku         text not null,
  foto        text not null
) on commit drop;

insert into oficial_20260830 (producto_id, sku, foto) values
  (1129, 'FMX-307574',  'https://jaloma.com.mx/wp-content/uploads/2025/04/Copia-de-115493.png'),
  (1102, 'FMX-301516',  'https://jaloma.com.mx/wp-content/uploads/2025/04/Copia-de-115488.png'),
  (278,  'FC-84437151', 'https://jaloma.com.mx/wp-content/uploads/2025/03/Acetona-frasco-120-ml.png'),
  (734,  'FC-84154058', 'https://jaloma.com.mx/wp-content/uploads/2025/04/Copia-de-115409.png'),
  (732,  'FC-84273094', 'https://jaloma.com.mx/wp-content/uploads/2025/04/Copia-de-Copia-de-Kiuts-Multiaplicadores-tarro-18x50-pz.png'),
  (716,  'FC-36041259', 'https://www.hinds.com.mx/img/Products/crema-hinds-Hinds-clasica-90ml.jpg'),
  (582,  'FC-36041273', 'https://www.hinds.com.mx/img/Products/hinds-Hinds-clasica-400ml.jpg'),
  (711,  'FC-36041297', 'https://www.hinds.com.mx/img/Products/inspiracion-Hinds-inspiracion-90ml.jpg'),
  (710,  'FC-36041341', 'https://www.hinds.com.mx/img/Products/natural-Hinds-natural-90ml.jpg'),
  (697,  'FC-36041389', 'https://www.hinds.com.mx/img/Products/almendras-Hinds-almendras-90ml.jpg'),
  (286,  'FC-20501673', 'https://www.hinds.com.mx/img/Products/agave-azul-400-Presentaciones-375x485-400ml-Frente.jpg'),
  (300,  'FC-36041402', 'https://www.hinds.com.mx/img/Products/almendras-Hinds-almendras-500ml.jpg'),
  (310,  'FC-42417644', 'https://img.nivea.com/-/media/miscellaneous/media-center-items/2/1/8/5454d550789e4a1a837fc18c5ed7449c-screen.jpg'),
  (327,  'FC-00701992', 'https://img.nivea.com/-/media/miscellaneous/media-center-items/8/8/1/2fb5dee803a3409d9ef3090c77565554-screen.jpg'),
  (291,  'FC-00942760', 'https://img.nivea.com/-/media/miscellaneous/media-center-items/2/f/0/b17ec5c776b640839d518c1d19c26800-web_1010x1180_transparent_png.png'),
  (705,  'FC-90031475', 'https://img.nivea.com/-/media/miscellaneous/media-center-items/f/2/8/019e046d060d7515b26da2839a8961c8-web_1010x1180_transparent_png.png'),
  (198,  'FC-42326414', 'https://www.garnier.com.mx/-/media/project/loreal/brand-sites/garnier/usa/mx/es-mx/prd-facecare/agua-de-rosas-todo-en-1/3600542326414_1.jpg');

update public.productos p
set
  imagen_url = o.foto,
  imagen_mobile_url = o.foto
from oficial_20260830 o
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
from oficial_20260830 o
where not exists (
  select 1
  from public.producto_imagenes x
  where x.producto_id = o.producto_id
    and x.url = o.foto
);

update public.producto_imagenes gi
set es_principal = (gi.url = o.foto)
from oficial_20260830 o
where gi.producto_id = o.producto_id;

commit;
