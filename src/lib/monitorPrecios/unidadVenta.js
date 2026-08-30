/**
 * Unidad de venta comparable (botella vs pack, ml vs polvo).
 * Sin esto, "Ensure 236 ml" se cruza con un 6-pack de $400.
 */

"use strict";

const { colapsar } = require("./normalizador");

const PACK_MIN = 2;
const PACK_MAX = 48;
/** Rappi marca ~10–40%. 2.8× el mostrador, sin mismo empaque, es otro SKU. */
const RATIO_OTRO_EMPAQUE = 2.8;
/** Ni en cadena cara una botella de $65 sale a $300. Eso es pack. */
const RATIO_ABSURDO = 4.5;
const VOL_TOL = 1.08;

function textoProductoUnidad(producto) {
  return [producto && producto.nombre, producto && producto.presentacion, producto && producto.concentracion]
    .filter(Boolean)
    .join(" ");
}

function extraerMl(norm) {
  const ml = norm.match(/(\d+(?:[.,]\d+)?)\s*m(?:l|ls)\b/);
  if (ml) return Number(String(ml[1]).replace(",", "."));
  const lit = norm.match(/(\d+(?:[.,]\d+)?)\s*(?:litros?|l)\b/);
  if (lit) return Number(String(lit[1]).replace(",", ".")) * 1000;
  return null;
}

function extraerGramos(norm) {
  if (/\d\s*m(?:g|cg)\b/.test(norm) && !/\d\s*(?:kg|g|gr|gramos)\b/.test(norm)) return null;
  const kg = norm.match(/(\d+(?:[.,]\d+)?)\s*kg\b/);
  if (kg) return Number(String(kg[1]).replace(",", ".")) * 1000;
  const g = norm.match(/(\d+(?:[.,]\d+)?)\s*(?:gramos|gr|g)\b/);
  if (!g) return null;
  const n = Number(String(g[1]).replace(",", "."));
  return n > 0 && n < 20000 ? n : null;
}

const SABOR_GRUPOS = [
  ["vainilla", "vanilla", "vnlla"],
  ["chocolate", "chte", "choco"],
  ["fresa", "fsa", "strawberry"],
  ["cafe", "coffee"],
  ["coco"],
  ["uva"],
  ["kiwi"],
  ["manzana"],
  ["naranja"],
  ["limon", "lima"],
  ["mora"],
  ["mango"],
];

function extraerSabor(norm) {
  for (const grupo of SABOR_GRUPOS) {
    if (grupo.some((w) => new RegExp(`(?:^|\\s)${w}(?:\\s|$)`).test(norm))) return grupo[0];
  }
  return null;
}

function extraerLinea(norm, ml, g) {
  if (/\b(polvo|powder|next gen)\b/.test(norm) || (g != null && ml == null)) return "polvo";
  if (/\b(advance|hmb)\b/.test(norm)) return "advance";
  if (/\bclinical\b/.test(norm)) return "clinical";
  if (/\bplus\b/.test(norm) || /\b10\s*plus\b/.test(norm)) return "plus";
  return "regular";
}

function extraerPiezasPack(norm) {
  const reglasPack = [
    /\b(\d{1,2})\s*-?\s*packs?\b/,
    /\bpacks?\s*(?:de\s+)?(\d{1,2})\b/,
    /\bcaja\s+con\s+(\d{1,2})\b/,
    /\b(\d{1,2})\s*(?:pzas?|piezas?|unidades|uds)\b/,
    /\b(\d{1,2})\s*x\s*\d+(?:[.,]\d+)?\s*m(?:l|ls)\b/,
    /\bx\s*(\d{1,2})(?:\b|$)/,
  ];
  for (const re of reglasPack) {
    const m = norm.match(re);
    if (!m) continue;
    const n = parseInt(m[1], 10);
    if (n >= PACK_MIN && n <= PACK_MAX) return { piezas: n, origenPiezas: "pack" };
  }
  if (!extraerMl(norm)) {
    const tabs = norm.match(/\b(\d{1,3})\s*(?:tabs?|tabletas?|capsulas?|caps?|comprimidos?)\b/);
    if (tabs) {
      const n = parseInt(tabs[1], 10);
      if (n >= PACK_MIN && n <= 200) return { piezas: n, origenPiezas: "caja_med" };
    }
    const caja = norm.match(/\bc\s*\/\s*(\d{1,3})\b/);
    if (caja) {
      const n = parseInt(caja[1], 10);
      if (n >= PACK_MIN && n <= 200) return { piezas: n, origenPiezas: "caja_med" };
    }
  }
  return { piezas: null, origenPiezas: null };
}

function extraerUnidadVenta(texto) {
  const norm = colapsar(String(texto || "").replace(/\+/g, " plus "));
  const ml = extraerMl(norm);
  const g = extraerGramos(norm);
  const pack = extraerPiezasPack(norm);
  return {
    texto: norm,
    ml,
    g,
    piezas: pack.piezas,
    origenPiezas: pack.origenPiezas,
    sabor: extraerSabor(norm),
    linea: extraerLinea(norm, ml, g),
  };
}

function extraerUnidadProducto(producto) {
  return extraerUnidadVenta(textoProductoUnidad(producto));
}

function cerca(a, b, tol) {
  const x = Number(a);
  const y = Number(b);
  if (!(x > 0) || !(y > 0)) return false;
  return Math.max(x, y) / Math.min(x, y) <= (tol || VOL_TOL);
}

function mismaUnidadVenta(a, b) {
  if (!a || !b) return false;
  const aLiq = a.ml != null;
  const bLiq = b.ml != null;
  const aSol = a.g != null && !aLiq;
  const bSol = b.g != null && !bLiq;
  if (aLiq && bSol) return false;
  if (bLiq && aSol) return false;
  if (aLiq && bLiq && !cerca(a.ml, b.ml)) return false;
  if (a.g != null && b.g != null && !cerca(a.g, b.g)) return false;

  const pa = a.piezas;
  const pb = b.piezas;
  if (pa != null && pb != null && pa !== pb) return false;
  if (b.origenPiezas === "pack" && a.origenPiezas !== "pack") return false;
  if (a.origenPiezas === "pack" && b.origenPiezas !== "pack") return false;
  if (pb >= PACK_MIN && (pa == null || pa === 1) && (aLiq || aSol)) return false;
  if (pa >= PACK_MIN && (pb == null || pb === 1) && (bLiq || bSol)) return false;
  if (a.sabor && b.sabor && a.sabor !== b.sabor) return false;
  if (a.linea && b.linea && a.linea !== b.linea) return false;
  return true;
}

function marcaBusqueda(producto) {
  const marca = colapsar(producto && producto.marca);
  if (marca && marca.length >= 4) return marca.split(/\s+/)[0];
  const nom = colapsar(producto && producto.nombre);
  return (nom && nom.split(/\s+/).find((t) => t.length >= 4)) || null;
}

function ofertaTieneMarca(normOferta, marca) {
  if (!marca) return true;
  return new RegExp(`(?:^|\\s)${marca}(?:\\s|$)`).test(normOferta || "");
}

function diagnosticoRefRappi(producto, refRow) {
  const precio = parseFloat(refRow && refRow.precio);
  if (!Number.isFinite(precio) || precio <= 0) {
    return { ok: false, motivo: "sin_precio" };
  }
  const ours = extraerUnidadProducto(producto);
  const nombre = (refRow && (refRow.nombre_fuente || refRow.nombre || refRow.notas)) || "";
  const theirs = extraerUnidadVenta(nombre);

  const marca = marcaBusqueda(producto);
  if (marca && theirs.texto && new RegExp(`no se encontro marca\\s+${marca}`).test(theirs.texto)) {
    return { ok: false, motivo: "otra_marca", nombre, ours, theirs };
  }
  if (marca && theirs.texto && !ofertaTieneMarca(theirs.texto, marca)) {
    return { ok: false, motivo: "otra_marca", nombre, ours, theirs };
  }
  if (theirs.texto && !mismaUnidadVenta(ours, theirs)) {
    return { ok: false, motivo: "otro_empaque", nombre, ours, theirs };
  }

  const nuestro = parseFloat(producto && producto.precio);
  const mismoEmpaqueConfirmado =
    mismaUnidadVenta(ours, theirs)
    && ((ours.ml != null && theirs.ml != null) || (ours.g != null && theirs.g != null) || (ours.piezas != null && theirs.piezas != null))
    && (ours.piezas || 1) === (theirs.piezas || 1);

  if (nuestro > 0 && precio / nuestro >= RATIO_ABSURDO) {
    return { ok: false, motivo: "precio_otro_empaque", nombre, ours, theirs };
  }
  if (nuestro > 0 && precio / nuestro >= RATIO_OTRO_EMPAQUE && !mismoEmpaqueConfirmado) {
    return { ok: false, motivo: "precio_otro_empaque", nombre, ours, theirs };
  }
  return { ok: true, motivo: null, nombre, ours, theirs };
}

function ofertaRappiComparable(producto, oferta) {
  return diagnosticoRefRappi(producto, oferta).ok;
}

module.exports = {
  RATIO_OTRO_EMPAQUE,
  RATIO_ABSURDO,
  extraerUnidadVenta,
  extraerUnidadProducto,
  extraerSabor,
  extraerLinea,
  marcaBusqueda,
  mismaUnidadVenta,
  diagnosticoRefRappi,
  ofertaRappiComparable,
  textoProductoUnidad,
};
