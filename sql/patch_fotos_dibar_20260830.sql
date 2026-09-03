-- Packshots Dibar confirmados en la etiqueta (2026-08-30).
-- laboratoriosdibar.com es sitio de maquila: no tiene tienda ni fotos por ml.
-- Solo entra un renglón si el empaque muestra el mismo producto y la misma talla.
-- No se reusa el frasco de 1 L en 125/250/500.
--
-- Confirmados (etiqueta leída):
--   FC-86901100 Alcohol azul 71.6 125 ml — Zafir, tapa azul,
--     «CONTENIDO NETO 125 ml». Es el SKU del recuadro vacío junto al 1 L.
--   FC-8910003  Algodón plisado 100 g — Velasco, «CONT. NET. 100 g».
--   FC-68910041 Algodón 25 g — Velasco, «CONT. NET. 25 g».
--     El nombre y la presentación en vivo son 25g; la descripción
--     «Algodón 5 g C/12» es basura de parseo, no otro producto.
--
-- Omitido a propósito (página vista, no hay packshot usable):
--   FC-68901124 Alcohol azul 500 ml: Promexsa / Omega reusan otra talla
--     o no muestran 500 ml en la etiqueta.
--   FC-68900264 / FC-68900226 / FC-68990023 Alcohol rojo 125/250/500 ml:
--     Promexsa publica la foto del 1 L (etiqueta 1000 ml).
--   FC-89100101 Algodón 200 g: IMM sí dice 200 g pero con marca de agua.
--   FC-68900127 Gasa 10×10 PAQ 10: Curitek sí es 10 piezas 10×10,
--     pero la foto va con marca de agua «Curitek».
--   FC-68901117 / FC-68901131 / FC-68960257 / FC-68910034 / FC-68900134:
--     ya tienen foto (Rappi o distribuidor/dibar/ae1-1000ml.jpg).
--
-- Idempotente: no pisa imagen_url si ya hay foto; no duplica la URL.

begin;

create temporary table dibar_20260830 (
  producto_id integer primary key,
  sku         text not null,
  foto        text not null
) on commit drop;

insert into dibar_20260830 (producto_id, sku, foto) values
  (346, 'FC-86901100', 'https://cdn.shopify.com/s/files/1/0561/7457/5705/files/ENFERMERIA-2024-09-12T170628.466.png?v=1726182397'),
  (693, 'FC-8910003',  'https://pmvelasco.mx/cdn/shop/files/ALGODONPLISADO-100G-DIBAR.jpg?v=1732313200'),
  (372, 'FC-68910041', 'https://pmvelasco.mx/cdn/shop/files/ALGODONPLISADO-25G-DIBAR.jpg?v=1732313335');

update public.productos p
set
  imagen_url = d.foto,
  imagen_mobile_url = d.foto
from dibar_20260830 d
where p.id = d.producto_id
  and p.sku = d.sku
  and coalesce(nullif(trim(p.imagen_url), ''), '') = '';

-- La galería manda sobre imagen_url. Distribuidor como principal (POS)
-- y posición 0 para que salga primero en Tienda si esa plaza está libre.
insert into public.producto_imagenes (
  producto_id, url, posicion, es_principal, origen
)
select
  d.producto_id,
  d.foto,
  case
    when exists (
      select 1 from public.producto_imagenes x
      where x.producto_id = d.producto_id and x.posicion = 0
    ) then (
      select coalesce(max(x.posicion), 0) + 1
      from public.producto_imagenes x
      where x.producto_id = d.producto_id
    )
    else 0
  end,
  false,
  'distribuidor'
from dibar_20260830 d
where not exists (
  select 1
  from public.producto_imagenes x
  where x.producto_id = d.producto_id
    and x.url = d.foto
);

update public.producto_imagenes gi
set es_principal = (gi.url = d.foto)
from dibar_20260830 d
where gi.producto_id = d.producto_id;

commit;
