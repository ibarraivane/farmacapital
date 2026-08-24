/**
 * Cruce oferta pública ↔ catálogo. Sin IA. No usa el primer resultado a ciegas.
 */

"use strict";

const { scoreNombre, gtinCoincide } = require("./similitud");
const { colapsar } = require("./normalizador");

const UMBRAL = 0.72;

function textoProducto(p) {
  return [p.marca, p.nombre, p.presentacion, p.principio_activo].filter(Boolean).join(" ");
}

function matchOferta(oferta, productos) {
  if (!oferta || !(Number(oferta.precio) > 0)) return null;
  if (oferta.ean) {
    const hit = productos.find((p) => gtinCoincide(p.codigo_barras, oferta.ean));
    if (hit) {
      return { producto: hit, confianza: 0.99, metodo: "GTIN" };
    }
  }
  let best = null;
  let bestScore = 0;
  const nombreOferta = oferta.nombre || "";
  for (const p of productos) {
    const pa = colapsar(p.principio_activo || "");
    if (pa.length >= 5) {
      const hay = colapsar(nombreOferta);
      if (!hay.includes(pa.split(" ")[0])) continue;
    }
    const score = scoreNombre(textoProducto(p), nombreOferta);
    if (score > bestScore) {
      bestScore = score;
      best = p;
    }
  }
  if (!best || bestScore < UMBRAL) return null;
  return { producto: best, confianza: bestScore, metodo: "NOMBRE" };
}

function matchMejorCandidato(producto, candidatos) {
  let best = null;
  let bestScore = 0;
  for (const c of candidatos || []) {
    const m = matchOferta(c, [producto]);
    if (m && m.confianza > bestScore) {
      bestScore = m.confianza;
      best = { ...c, confianza: m.confianza, metodo: m.metodo };
    }
  }
  return best;
}

function mediana(valores) {
  const xs = (valores || []).map(Number).filter((n) => Number.isFinite(n) && n > 0).sort((a, b) => a - b);
  if (!xs.length) return null;
  const mid = Math.floor(xs.length / 2);
  if (xs.length % 2 === 1) return xs[mid];
  return Math.round(((xs[mid - 1] + xs[mid]) / 2) * 100) / 100;
}

/** Otros = promedio de lo extra (no es copiar Similares o Del Ahorro a solas). */
function precioOtrosMercado(preciosPorFuente) {
  const extras = Object.entries(preciosPorFuente || {})
    .filter(([id, n]) => id !== "fahorro" && id !== "similares" && Number(n) > 0)
    .map(([, n]) => Number(n));
  if (extras.length) return mediana(extras);
  const cadenas = ["fahorro", "similares"]
    .map((id) => Number(preciosPorFuente?.[id]))
    .filter((n) => n > 0);
  if (cadenas.length >= 2) return mediana(cadenas);
  return null;
}

module.exports = {
  UMBRAL,
  matchOferta,
  matchMejorCandidato,
  mediana,
  precioOtrosMercado,
};
