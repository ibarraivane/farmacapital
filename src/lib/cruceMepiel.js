/**
 * Cruce de una lista Mepiel contra productos que ya tienen EAN
 * (Dermaexpress y el resto del catálogo). No da de alta EAN nuevos.
 */
const { gtinValido, sqlNum, sqlTexto, urlImagenPublicaTienda } = require("./catalogoBajoPedido");

function normalizarFilaMepiel(row) {
  const ean = gtinValido(row.ean || row.codigo_barras || row.codigo || row.sku || row.barcode);
  const costo = Number(String(row.costo || row.costo_mayoreo || row.precio_mayoreo || row.precio || "").replace(/[$,\s]/g, ""));
  const nombre = String(row.nombre || row.name || row.descripcion || "").trim();
  const imagen = urlImagenPublicaTienda(row.imagen_url || row.imagen || row.image || "");
  return {
    ean,
    costo: Number.isFinite(costo) && costo > 0 ? Math.round(costo * 100) / 100 : null,
    nombre,
    imagen_url: imagen,
  };
}

function cruzarMepiel({ filas, eanConocidos }) {
  const conocidos = new Set((eanConocidos || []).map((e) => gtinValido(e)).filter(Boolean));
  const vistos = new Set();
  const enCatalogo = [];
  const pendientes = [];
  for (const raw of filas || []) {
    const fila = normalizarFilaMepiel(raw);
    if (!fila.ean) {
      pendientes.push({ ...fila, motivo: "sin_ean" });
      continue;
    }
    if (vistos.has(fila.ean)) {
      pendientes.push({ ...fila, motivo: "ean_repetido_en_lista" });
      continue;
    }
    vistos.add(fila.ean);
    if (!conocidos.has(fila.ean)) {
      pendientes.push({ ...fila, motivo: "ean_no_esta_en_catalogo" });
      continue;
    }
    enCatalogo.push(fila);
  }
  return { enCatalogo, pendientes };
}

function sqlReferenciaMepiel(enCatalogo) {
  const utiles = (enCatalogo || []).filter((f) => f.ean && f.costo);
  if (!utiles.length) return "";
  const values = utiles.map((f) => `(${sqlTexto(f.ean)}, ${sqlNum(f.costo)}, ${f.imagen_url ? sqlTexto(f.imagen_url) : "null"})`).join(",\n");
  return `-- Referencia de compra Mepiel para productos que ya tienen ese EAN.
-- No crea productos. No pisa codigo_barras ni una foto existente.

begin;

create temp table _fc_mepiel_ean (
  ean text primary key,
  costo numeric not null,
  imagen_url text
) on commit drop;

insert into _fc_mepiel_ean (ean, costo, imagen_url) values
${values};

insert into public.producto_precios_referencia
  (producto_id, fuente, tipo, precio, sku_externo, origen, notas)
select p.id, 'mepiel', 'compra', m.costo, m.ean, 'import_csv', 'mayoreo mepiel'
  from _fc_mepiel_ean m
  join public.productos p on p.codigo_barras = m.ean
 where not exists (
   select 1 from public.producto_precios_referencia r
    where r.producto_id = p.id and r.fuente = 'mepiel' and r.fecha = current_date
 );

update public.productos p
   set imagen_url = m.imagen_url
  from _fc_mepiel_ean m
 where p.codigo_barras = m.ean
   and coalesce(m.imagen_url, '') <> ''
   and coalesce(nullif(trim(p.imagen_url), ''), '') = '';

commit;
`;
}

module.exports = {
  cruzarMepiel,
  normalizarFilaMepiel,
  sqlReferenciaMepiel,
};
