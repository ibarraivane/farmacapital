'use strict';

/**
 * Candidatos de imagen por EAN. Solo fuentes abiertas o del fabricante.
 * No usa fotos de otras farmacias.
 */

const UA = 'FarmaCapitalCatalog/1.0 (own inventory image match; polite 1 req/product)';

const OPENFACTS = [
  { origen: 'openfacts', host: 'https://world.openfoodfacts.org', licencia: 'CC BY-SA' },
  { origen: 'openfacts', host: 'https://world.openbeautyfacts.org', licencia: 'CC BY-SA' },
  { origen: 'openfacts', host: 'https://world.openproductsfacts.org', licencia: 'CC BY-SA' },
];

function digits(s) {
  return String(s || '').replace(/\D/g, '');
}

function pad13(ean) {
  const e = digits(ean);
  if (e.length >= 8 && e.length < 13) return e.padStart(13, '0');
  return e;
}

async function fetchJson(url, fetchFn) {
  const resp = await fetchFn(url, {
    headers: { 'User-Agent': UA, Accept: 'application/json' },
  });
  if (!resp.ok) return null;
  return resp.json().catch(() => null);
}

function pickImage(product) {
  if (!product) return '';
  return (
    product.image_front_url
    || product.image_url
    || product.image_front_small_url
    || ''
  );
}

async function buscarOpenFacts(ean, fetchFn = fetch) {
  const code = pad13(ean);
  if (code.length < 8) return [];
  const out = [];
  for (const src of OPENFACTS) {
    try {
      const data = await fetchJson(`${src.host}/api/v2/product/${code}.json`, fetchFn);
      const img = pickImage(data && data.product);
      if (img) {
        out.push({
          url: img,
          origen: src.origen,
          licencia: src.licencia,
          coincide_ean: true,
          notas: data.product.product_name || src.host,
          fuente_url: `${src.host}/product/${code}`,
        });
      }
    } catch {
      /* siguiente fuente */
    }
  }
  return out;
}

async function buscarImagenesPorEan(ean, fetchFn = fetch) {
  return buscarOpenFacts(ean, fetchFn);
}

module.exports = {
  pad13,
  buscarOpenFacts,
  buscarImagenesPorEan,
};
