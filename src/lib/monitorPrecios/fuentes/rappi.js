/**
 * Precios públicos de Rappi (página de búsqueda).
 * No login. No inventa precios. El súper se etiqueta aparte.
 */

"use strict";

const { colapsar } = require("../normalizador");
const { scoreNombre } = require("../similitud");
const { matchMejorCandidato } = require("../matchCatalogo");
const { ofertaRappiComparable } = require("../unidadVenta");

const UA = "FarmaCapitalPricingBot/1.0 (+https://www.farmacapital.mx)";

function moneyFrom(v) {
  const n = typeof v === "number" ? v : parseFloat(String(v || "").replace(/[$,\s]/g, ""));
  return Number.isFinite(n) && n > 0 ? Math.round(n * 100) / 100 : null;
}

function norm(s) {
  return String(s || "")
    .toLowerCase()
    .normalize("NFD")
    .replace(/\p{M}/gu, "");
}

function clasificarTiendaRappi(nombre) {
  const s = norm(nombre);
  if (!s) return null;
  if (/chedraui|chedrahui|walmart|bodega aurrera|soriana|superama|la comer|city club|\bheb\b|mercado extra/.test(s)) {
    return "rappi_super";
  }
  if (/guadalajara|\bgdl\b/.test(s)) return "rappi_gdl";
  if (/farmatodo/.test(s)) return "rappi_farmatodo";
  if (/benavides/.test(s)) return "rappi_benavides";
  if (/selecto|la paz|san pablo|farmac/.test(s)) return "rappi_otros";
  return null;
}

function extraerNextData(html) {
  const raw = String(html || "");
  const m = raw.match(/<script id="__NEXT_DATA__" type="application\/json">([\s\S]*?)<\/script>/);
  if (!m) return null;
  try {
    return JSON.parse(m[1]);
  } catch {
    return null;
  }
}

function productosDeStore(store) {
  const list = store && Array.isArray(store.products) ? store.products : [];
  const out = [];
  for (const p of list) {
    const precio = moneyFrom(p && (p.price != null ? p.price : p.realPrice));
    const nombre = String((p && (p.name || p.productName || p.title)) || "").trim();
    if (!precio || !nombre) continue;
    out.push({
      nombre,
      precio,
      ean: String((p && (p.ean || p.barcode || p.gtin)) || "").replace(/\D/g, "") || null,
    });
  }
  return out;
}

function extraerOfertasRappi(html) {
  const data = extraerNextData(html);
  const fallback = data && data.props && data.props.pageProps && data.props.pageProps.fallback;
  if (!fallback || typeof fallback !== "object") return [];

  const out = [];
  for (const payload of Object.values(fallback)) {
    const stores = payload && Array.isArray(payload.stores) ? payload.stores : [];
    for (const store of stores) {
      const tienda = String((store && (store.storeName || store.brandName)) || "").trim();
      const fuente = clasificarTiendaRappi(tienda);
      if (!fuente) continue;
      for (const prod of productosDeStore(store)) {
        out.push({
          fuente,
          tipo: "venta",
          tienda,
          nombre: prod.nombre,
          precio: prod.precio,
          ean: prod.ean,
        });
      }
    }
  }
  return out;
}

function agruparOfertasRappi(ofertas) {
  const best = {};
  for (const ofe of ofertas || []) {
    if (!ofe || !ofe.fuente || !(ofe.precio > 0)) continue;
    const prev = best[ofe.fuente];
    if (!prev || ofe.precio < prev.precio) best[ofe.fuente] = ofe;
  }
  return best;
}

function terminoCortoRappi(producto) {
  const nom = String(producto && producto.nombre || "")
    .replace(/\s+/g, " ")
    .trim();
  const tokens = nom.split(" ").filter((t) => t.length >= 2 && !/^c\/\d+/i.test(t));
  if (tokens.length) return tokens.slice(0, 3).join(" ").slice(0, 40);
  return terminoBusquedaRappi(producto);
}

function terminoBusquedaRappi(producto) {
  const rappi = String(producto && producto.nombre_rappi || "").replace(/\s+/g, " ").trim();
  if (rappi.length >= 4) return rappi.slice(0, 80);
  const nom = String(producto && producto.nombre || "")
    .replace(/\s+/g, " ")
    .trim();
  if (nom.length >= 4) return nom.split(" ").slice(0, 4).join(" ").slice(0, 80);
  return String(producto && (producto.codigo_barras || producto.ean) || "").replace(/\D/g, "").slice(0, 14);
}

function candidatosMismaUnidad(producto, candidatos) {
  return (candidatos || []).filter((c) => ofertaRappiComparable(producto, c));
}

/** Si el job ya busca este SKU, no descartar por umbral de catálogo. */
function matchOfertaRappi(producto, candidatos) {
  const comparables = candidatosMismaUnidad(producto, candidatos);
  const hit = matchMejorCandidato(producto, comparables);
  if (hit) return hit;
  const token = colapsar(producto && producto.nombre)
    .split(/\s+/)
    .find((t) => t.length >= 4);
  if (!token) return null;
  let best = null;
  let bestScore = 0;
  for (const c of comparables) {
    const hay = colapsar(c.nombre || "");
    if (!hay.includes(token)) continue;
    const s = Math.max(scoreNombre(producto.nombre, c.nombre), 0.55);
    if (s > bestScore) {
      bestScore = s;
      best = c;
    }
  }
  if (!best) return null;
  return { ...best, confianza: bestScore, metodo: "NOMBRE_RAPPI" };
}

function urlBusquedaRappi(query) {
  return `https://www.rappi.com.mx/search?query=${encodeURIComponent(query)}`;
}

async function fetchHtmlRappi(fetchImpl, query, ms) {
  const impl = fetchImpl || fetch;
  const ctrl = new AbortController();
  const t = setTimeout(() => ctrl.abort(), ms || 4000);
  try {
    const r = await impl(`${urlBusquedaRappi(query)}&_=${Date.now()}`, {
      signal: ctrl.signal,
      cache: "no-store",
      headers: {
        "User-Agent": UA,
        Accept: "text/html,application/json;q=0.9",
        "Cache-Control": "no-cache",
      },
    });
    if (!r.ok) return null;
    return await r.text();
  } catch {
    return null;
  } finally {
    clearTimeout(t);
  }
}

module.exports = {
  clasificarTiendaRappi,
  extraerOfertasRappi,
  agruparOfertasRappi,
  terminoBusquedaRappi,
  terminoCortoRappi,
  matchOfertaRappi,
  urlBusquedaRappi,
  fetchHtmlRappi,
};
