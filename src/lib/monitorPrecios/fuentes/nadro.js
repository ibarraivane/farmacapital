/**
 * Catálogo iNadro (VTEX i22.nadro.mx).
 * Fotos y ficha: públicas, por EAN.
 * Precio de compra (lo que te cobran): solo con sesión de cliente.
 * El $100 / $0 sin login es placeholder, no se guarda.
 */

"use strict";

const { fichaCatalogoDesdeNadro } = require("../../fichaProveedor");

const UA = "FarmaCapitalPricingBot/1.0 (+https://www.farmacapital.mx)";
const SEARCH = "https://i22.nadro.mx/api/io/_v/api/intelligent-search/product_search";
const PRODUCT = "https://i22.nadro.mx/v1/api/proxy/getproductbyid";

function digits(s) {
  return String(s || "").replace(/\D/g, "");
}

function moneyFrom(s) {
  const n = parseFloat(String(s || "").replace(/[$,\s]/g, ""));
  return Number.isFinite(n) && n > 0 ? Math.round(n * 100) / 100 : null;
}

/** "1,000" → 1000 · "717.06" → 717.06 · no usa el $100 de vitrina. */
function parseMoneyMx(s) {
  const t = String(s || "").replace(/\$/g, "").trim();
  if (!t) return null;
  if (/\.\d{3},\d{1,2}$/.test(t)) return moneyFrom(t.replace(/\./g, "").replace(",", "."));
  if (/,\d{3}(\.\d+)?$/.test(t)) return moneyFrom(t.replace(/,/g, ""));
  if (/,\d{1,2}$/.test(t) && !t.includes(".")) return moneyFrom(t.replace(",", "."));
  return moneyFrom(t);
}

function extraerPrecioFarmaciaTexto(texto) {
  const t = String(texto || "").replace(/\s+/g, " ");
  const farm = t.match(/Farmacia:\s*\$?\s*([\d.,]+)/i);
  const pub = t.match(/P[uú]blico:\s*\$?\s*([\d.,]+)/i);
  const farmacia = farm ? parseMoneyMx(farm[1]) : null;
  const publico = pub ? parseMoneyMx(pub[1]) : null;
  if (!(farmacia > 0)) return null;
  // El portal sin precio de cliente pinta $100. Un costo real de $100.00 es raro;
  // no se escribe hasta ver otro número.
  if (farmacia === 100) return null;
  return { farmacia, publico };
}

function itemDe(prod) {
  return (prod && Array.isArray(prod.items) && prod.items[0]) || {};
}

function eanDe(prod) {
  return digits(itemDe(prod).ean);
}

function imagenesDe(prod) {
  const imgs = itemDe(prod).images || [];
  const out = [];
  for (const im of imgs) {
    const u = String(im && (im.imageUrl || im.imagePath) || "").trim();
    if (u && !/placeholder|placehold/i.test(u)) out.push(u.split("?")[0]);
  }
  return out;
}

function esPrecioPlaceholderNadro(offer) {
  if (!offer) return true;
  const p = Number(offer.Price);
  const list = Number(offer.ListPrice);
  const qty = Number(offer.AvailableQuantity);
  if (!(p > 0)) return true;
  if (p === 100 && list === 100 && qty >= 1000) return true;
  return false;
}

function precioVtexCreible(prod) {
  const sellers = itemDe(prod).sellers || [];
  for (const s of sellers) {
    const offer = s && s.commertialOffer;
    if (esPrecioPlaceholderNadro(offer)) continue;
    const n = Number(offer.Price);
    if (n > 0) return n;
  }
  return null;
}

function precioPublicoDe(prod) {
  const raw = prod && (prod["Precio público"] || prod["Precio publico"]);
  if (Array.isArray(raw) && raw[0]) return moneyFrom(raw[0]);
  if (typeof raw === "string") return moneyFrom(raw);
  return null;
}

function extraerProductoNadro(prod) {
  if (!prod || typeof prod !== "object") return null;
  const ean = eanDe(prod);
  const nombre = String(prod.productName || prod.productTitle || "").trim();
  if (!nombre) return null;
  const hit = {
    fuente: "nadro",
    tipo: "compra",
    productId: String(prod.productId || ""),
    sap: String(prod.productReference || prod.productReferenceCode || ""),
    nombre,
    ean: ean || null,
    imagenes: imagenesDe(prod),
    precioCompra: precioVtexCreible(prod),
    precioPublico: precioPublicoDe(prod),
    marca: String(prod.brand || "").trim() || null,
    link: String(prod.link || "").trim() || null,
    linkText: String(prod.linkText || "").trim() || null,
    description: String(prod.description || "").trim() || null,
    metaTagDescription: String(prod.metaTagDescription || "").trim() || null,
    categories: Array.isArray(prod.categories) ? prod.categories : [],
  };
  hit.ficha = fichaCatalogoDesdeNadro(hit);
  return hit;
}

function elegirPorEan(products, ean) {
  const q = digits(ean);
  if (!q || !Array.isArray(products)) return null;
  const exactos = products.filter((p) => eanDe(p) === q);
  return extraerProductoNadro(exactos[0] || null);
}

async function fetchJson(fetchImpl, url, ms) {
  const impl = fetchImpl || fetch;
  const ctrl = new AbortController();
  const t = setTimeout(() => ctrl.abort(), ms || 6000);
  try {
    const r = await impl(url, {
      signal: ctrl.signal,
      headers: { "User-Agent": UA, Accept: "application/json" },
    });
    if (!r.ok) return null;
    return await r.json();
  } catch {
    return null;
  } finally {
    clearTimeout(t);
  }
}

async function buscarNadroPorEan(fetchImpl, ean) {
  const q = digits(ean);
  if (q.length < 8) return null;
  const data = await fetchJson(
    fetchImpl,
    `${SEARCH}?q=${encodeURIComponent(q)}&count=8`,
    7000
  );
  const hit = elegirPorEan(data && data.products, q);
  if (!hit) return null;
  if (hit.productId) {
    const extra = await fetchJson(fetchImpl, `${PRODUCT}?productID=${encodeURIComponent(hit.productId)}`, 5000);
    const row = Array.isArray(extra) ? extra[0] : extra;
    if (row) {
      hit.precioPublico = precioPublicoDe(row) || hit.precioPublico;
      if (!hit.marca && row.brand) hit.marca = String(row.brand).trim();
      if (!hit.metaTagDescription && row.metaTagDescription) {
        hit.metaTagDescription = String(row.metaTagDescription).trim();
      }
      if (!hit.description && row.description) {
        hit.description = String(row.description).trim();
      }
      if ((!hit.categories || !hit.categories.length) && Array.isArray(row.categories)) {
        hit.categories = row.categories;
      }
      if (!hit.linkText && row.linkText) hit.linkText = String(row.linkText).trim();
      hit.ficha = fichaCatalogoDesdeNadro(hit);
    }
  }
  return hit;
}

module.exports = {
  SEARCH,
  digits,
  moneyFrom,
  esPrecioPlaceholderNadro,
  extraerProductoNadro,
  extraerPrecioFarmaciaTexto,
  parseMoneyMx,
  elegirPorEan,
  buscarNadroPorEan,
};
