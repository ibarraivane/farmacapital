/**
 * Cruce Birdman: SKU de mayoreo → EAN e imagen de la ficha pública b2b.
 * El SKU FC- no cambia (ya está dado de alta sin código de barras).
 */
const {
  elegirPackshotShopify,
  filaBirdman,
  gtinValido,
  sqlTexto,
} = require("./catalogoBajoPedido");

function imagenShopify(url) {
  return elegirPackshotShopify({
    media: [{ media_type: "image", width: 1000, src: url || "" }],
  });
}

function cruzarBirdman({ catalogo, fichas }) {
  const porSku = new Map();
  for (const f of fichas || []) {
    const clave = String(f.sku || "").trim().toUpperCase();
    if (clave) porSku.set(clave, f);
  }

  const filas = [];
  for (const row of catalogo || []) {
    const base = filaBirdman(row);
    if (!base) continue;
    const externo = String(row.sku || "").trim();
    const ficha = porSku.get(externo.toUpperCase());
    const ean = gtinValido(ficha?.barcode || ficha?.ean || row.ean || row.codigo_barras);
    const imagen = imagenShopify(ficha?.imagen_url || row.imagen_url);
    filas.push({
      sku: base.sku,
      sku_externo: externo,
      nombre: base.nombre,
      ean,
      imagen_url: imagen,
      barcode_crudo: String(ficha?.barcode || ficha?.ean || ""),
    });
  }

  const conteo = new Map();
  for (const f of filas) {
    if (!f.ean) continue;
    conteo.set(f.ean, (conteo.get(f.ean) || 0) + 1);
  }
  for (const f of filas) {
    if (f.ean && conteo.get(f.ean) > 1) {
      f.nota = "ean_repetido";
      f.ean = "";
    } else if (!f.ean && f.barcode_crudo) {
      f.nota = "ean_invalido";
    } else if (!f.ean) {
      f.nota = "sin_ean";
    } else {
      f.nota = "";
    }
  }
  return filas;
}

function sqlPatchBirdman(filas) {
  const utiles = (filas || []).filter((f) => f.sku && f.sku_externo && (f.ean || f.imagen_url));
  if (!utiles.length) throw new Error("No hay filas Birdman con EAN o imagen");
  const values = utiles.map((f) => `(${sqlTexto(f.sku)}, ${sqlTexto(f.sku_externo)}, ${f.ean ? sqlTexto(f.ean) : "null"}, ${f.imagen_url ? sqlTexto(f.imagen_url) : "null"})`).join(",\n");

  return `-- Códigos de barras y fotos de suplementos Birdman (mayoreo).
-- Cruce exacto por SKU de b2b.birdman.com (variant.barcode + packshot).
-- No cambia el SKU FC-. No pisa un código o una foto que ya existan.
-- No asigna un EAN que ya tenga otro producto.

begin;

create temp table _fc_birdman_ean (
  sku text not null,
  sku_externo text not null,
  ean text,
  imagen_url text
) on commit drop;

insert into _fc_birdman_ean (sku, sku_externo, ean, imagen_url) values
${values};

-- Tabla real: un WITH solo vive en el enunciado que le sigue.
create temp table _fc_birdman_destino on commit drop as
select distinct on (b.sku_externo)
  b.sku_externo, b.ean, b.imagen_url, p.id
from _fc_birdman_ean b
join public.productos p
  on p.sku = b.sku
  or p.descripcion = 'Bajo pedido · birdman · ' || b.sku_externo
order by b.sku_externo, (p.sku = b.sku) desc, p.id;

update public.productos p
   set codigo_barras = d.ean
  from _fc_birdman_destino d
 where p.id = d.id
   and d.ean is not null
   and coalesce(nullif(trim(p.codigo_barras), ''), '') = ''
   and not exists (
     select 1 from public.productos o
     where o.codigo_barras = d.ean
       and o.id <> p.id
   );

update public.productos p
   set imagen_url = d.imagen_url
  from _fc_birdman_destino d
 where p.id = d.id
   and coalesce(d.imagen_url, '') <> ''
   and coalesce(nullif(trim(p.imagen_url), ''), '') = '';

select
  (select count(*) from _fc_birdman_ean where ean is not null) as ean_en_lista,
  (select count(*) from _fc_birdman_ean where coalesce(imagen_url, '') <> '') as fotos_en_lista,
  (select count(*) from public.productos p
     join _fc_birdman_ean b
       on p.sku = b.sku
       or p.descripcion = 'Bajo pedido · birdman · ' || b.sku_externo
    where p.codigo_barras is not null and b.ean is not null and p.codigo_barras = b.ean) as ean_puestos;

commit;
`;
}

module.exports = {
  cruzarBirdman,
  imagenShopify,
  sqlPatchBirdman,
};
