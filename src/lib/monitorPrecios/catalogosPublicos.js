/**
 * Catálogos públicos (APIs de tienda, no login). No inventa precios.
 * Exprezo / Zorro no tiene catálogo público: esa columna se actualiza importando la lista.
 */

"use strict";

const { esMarcaPatente } = require("./unidadVenta");

const UA = "FarmaCapitalPricingBot/1.0 (+https://www.farmacapital.mx)";

const URLS = {
  abarrotero: (cat) =>
    `https://abarrotero.com/wp-json/wc/store/v1/products?category=${cat}&per_page=50&page=1`,
  scorpion: "https://www.scorpion.com.mx/tienda/higiene-y-cuidado-personal.html",
  mayoreototal: "https://mayoreototal.mx/products.json?limit=80&page=1",
  similares: (q) =>
    `https://www.farmaciasdesimilares.com/api/catalog_system/pub/products/search/${encodeURIComponent(q)}?_from=0&_to=4`,
  fahorro: (q) =>
    `https://www.fahorro.com/api/catalog_system/pub/products/search/${encodeURIComponent(q)}?_from=0&_to=4`,
};

function moneyFrom(s) {
  const n = parseFloat(String(s || "").replace(/[$,\s]/g, ""));
  return Number.isFinite(n) && n > 0 ? n : null;
}

async function fetchText(fetchImpl, url, ms) {
  const ctrl = new AbortController();
  const t = setTimeout(() => ctrl.abort(), ms || 5000);
  try {
    const r = await fetchImpl(url, {
      signal: ctrl.signal,
      headers: { "User-Agent": UA, Accept: "application/json,text/html;q=0.9" },
    });
    if (!r.ok) return null;
    return await r.text();
  } catch {
    return null;
  } finally {
    clearTimeout(t);
  }
}

function extraerAbarroteroJson(raw) {
  let arr;
  try { arr = JSON.parse(raw); } catch { return []; }
  if (!Array.isArray(arr)) return [];
  const out = [];
  for (const p of arr) {
    const minor = Number(p.prices?.currency_minor_unit || 0);
    const precio = Number(p.prices?.sale_price || p.prices?.price) / (10 ** minor);
    const caja = String(p.name || "").match(/caja\s+con\s+(\d+)/i);
    const n = caja ? Number(caja[1]) : 1;
    if (!(precio > 0)) continue;
    out.push({
      fuente: "abarrotero",
      tipo: "compra",
      nombre: String(p.name || "").replace(/&#8211;/g, "—"),
      precio: n > 1 ? precio / n : precio,
    });
  }
  return out;
}

function extraerScorpionHtml(html) {
  const out = [];
  const re = /<a class="product-item-link" href="[^"]+">\s*([^<]+?)\s*<\/a>[\s\S]{0,2500}?<h4>\s*Pieza\s*<\/h4>\s*<div class="price"><span class="price">\$([0-9.,]+)/gi;
  let m;
  while ((m = re.exec(html))) {
    const precio = moneyFrom(m[2]);
    if (!precio) continue;
    out.push({ fuente: "scorpion", tipo: "compra", nombre: m[1].trim(), precio });
  }
  return out;
}

function extraerMayoreoTotal(raw) {
  let payload;
  try { payload = JSON.parse(raw); } catch { return []; }
  const out = [];
  for (const prod of payload.products || []) {
    const title = String(prod.title || "").trim();
    for (const v of prod.variants || []) {
      const precio = moneyFrom(v.price);
      if (!precio || !title) continue;
      const varTitle = v.title && v.title !== "Default Title" ? ` ${v.title}` : "";
      out.push({
        fuente: "mayoreototal",
        tipo: "compra",
        nombre: `${title}${varTitle}`.trim(),
        precio,
        ean: String(v.barcode || "").replace(/\D/g, "") || null,
      });
    }
  }
  return out;
}

function extraerVtex(raw, fuente) {
  let arr;
  try { arr = JSON.parse(raw); } catch { return []; }
  if (!Array.isArray(arr)) return [];
  const out = [];
  for (const it of arr.slice(0, 8)) {
    const sku = (it.items || [])[0] || {};
    const sellers = sku.sellers || [];
    const precio = Number(sellers[0]?.commertialOffer?.Price);
    const nombre = String(it.productName || it.productTitle || "").trim();
    const ean = String(sku.ean || (sku.referenceId || []).find((x) => x?.Key === "EAN")?.Value || "")
      .replace(/\D/g, "");
    if (!nombre || !(precio > 0)) continue;
    out.push({
      fuente,
      tipo: "venta",
      nombre,
      precio,
      ean: ean || null,
    });
  }
  return out;
}

function terminoBusqueda(producto) {
  if (esMarcaPatente(producto)) {
    const marca = String(producto.marca || "").trim();
    if (marca.length >= 3) return marca.split(/\s+/)[0];
    const nomMarca = String(producto.nombre || "").trim();
    if (nomMarca) return nomMarca.split(/\s+/)[0];
  }
  const pa = String(producto.principio_activo || "").trim();
  if (pa && pa.length >= 4 && !/desodorante|shampoo|jabon|panal/i.test(pa)) {
    return pa.split(/\s+/).slice(0, 3).join(" ");
  }
  const nom = String(producto.nombre || "").trim();
  return nom.split(/\s+/).slice(0, 3).join(" ");
}

async function recolectarCompraPublica(fetchImpl) {
  const [abar1, abar2, scorpHtml, mayoRaw] = await Promise.all([
    fetchText(fetchImpl, URLS.abarrotero(6873), 5000),
    fetchText(fetchImpl, URLS.abarrotero(8221), 5000),
    fetchText(fetchImpl, URLS.scorpion, 6000),
    fetchText(fetchImpl, URLS.mayoreototal, 5000),
  ]);
  return [
    ...(abar1 ? extraerAbarroteroJson(abar1) : []),
    ...(abar2 ? extraerAbarroteroJson(abar2) : []),
    ...(scorpHtml ? extraerScorpionHtml(scorpHtml) : []),
    ...(mayoRaw ? extraerMayoreoTotal(mayoRaw) : []),
  ];
}

async function buscarVentaCadena(fetchImpl, fuente, query) {
  const url = fuente === "similares" ? URLS.similares(query) : URLS.fahorro(query);
  const raw = await fetchText(fetchImpl, url, 2500);
  if (!raw) return [];
  return extraerVtex(raw, fuente);
}

module.exports = {
  URLS,
  extraerAbarroteroJson,
  extraerScorpionHtml,
  extraerMayoreoTotal,
  extraerVtex,
  terminoBusqueda,
  recolectarCompraPublica,
  buscarVentaCadena,
};
