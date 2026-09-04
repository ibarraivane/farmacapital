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
  return [
    producto && producto.nombre,
    producto && producto.nombre_rappi,
    producto && producto.nombre_partner,
    producto && producto.presentacion,
    producto && producto.concentracion,
    producto && producto.forma_farmaceutica,
  ]
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

function extraerMgs(texto) {
  const t = colapsar(String(texto || ""));
  const out = [];
  const re = /(\d+(?:[.,]\d+)?)\s*mg\b/g;
  let m;
  while ((m = re.exec(t))) {
    const n = Number(String(m[1]).replace(",", "."));
    if (Number.isFinite(n) && n > 0) out.push(n);
  }
  return out;
}

function mismaConcentracionMg(oursTexto, theirsTexto) {
  const a = extraerMgs(oursTexto);
  const b = extraerMgs(theirsTexto);
  if (!a.length || !b.length) return true;
  if (a.length === 1 && b.length === 1) return Math.abs(a[0] - b[0]) <= 0.51;
  const big = a.length >= b.length ? a : b;
  const small = a.length >= b.length ? b : a;
  return small.every((x) => big.some((y) => Math.abs(x - y) <= 0.51));
}

function extraerPiezasPack(norm) {
  const reglasPack = [
    /\b(\d{1,2})\s*-?\s*packs?\b/,
    /\bpacks?\s*(?:de\s+)?(\d{1,2})\b/,
    /\b(\d{1,2})\s*x\s*\d+(?:[.,]\d+)?\s*m(?:l|ls)\b/,
  ];
  for (const re of reglasPack) {
    const m = norm.match(re);
    if (!m) continue;
    const n = parseInt(m[1], 10);
    if (n >= PACK_MIN && n <= PACK_MAX) return { piezas: n, origenPiezas: "pack" };
  }
  if (extraerMl(norm)) {
    const pzasLiq = norm.match(/\b(\d{1,2})\s*(?:pzas?|piezas?|unidades|unds?|uds)\b/);
    if (pzasLiq) {
      const n = parseInt(pzasLiq[1], 10);
      if (n >= PACK_MIN && n <= PACK_MAX) return { piezas: n, origenPiezas: "pack" };
    }
    return { piezas: null, origenPiezas: null };
  }
  const reglasCaja = [
    /\bcaja\s+con\s+(\d{1,3})\b/,
    /\bcaja\s+x\s*(\d{1,3})\b/,
    /\bx\s*(\d{1,3})\b/,
    /\b(\d{1,3})\s*(?:pzas?|piezas?|unidades|unds?|uds)\b/,
    /\b(\d{1,3})\s*(?:tabs?|tabletas?|capsulas?|caps?|comprimidos?)\b/,
    /\bc\s*\/\s*(\d{1,3})\b/,
  ];
  for (const re of reglasCaja) {
    const m = norm.match(re);
    if (!m) continue;
    const n = parseInt(m[1], 10);
    if (n >= PACK_MIN && n <= 200) return { piezas: n, origenPiezas: "caja_med" };
  }
  return { piezas: null, origenPiezas: null };
}

function extraerForma(norm) {
  if (/\b(cremas?|geles?|\bgel\b|unguentos?|pomadas?|parches?)\b/.test(norm)) return "topico";
  if (/\b(suspensiones?|jarabes?|soluciones?|gotas|aerosol|inhal)\b/.test(norm)) return "liquido";
  if (/\b(tabs?|tabletas?|comprimidos?|capsulas?|caps?|ovulos?|unds?)\b/.test(norm)) return "solido";
  return null;
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
    forma: extraerForma(norm),
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
  if (a.forma && b.forma && a.forma !== b.forma) return false;
  return true;
}

/** XL-3 → xl3; no partir en "xl" (2 letras no identifican la marca). */
function colapsarMarca(texto) {
  return colapsar(String(texto || "").replace(/-/g, ""));
}

function marcaBusqueda(producto) {
  const marca = colapsarMarca(producto && producto.marca);
  if (marca && marca.length >= 3) return marca.split(/\s+/)[0];
  const nom = colapsarMarca(producto && producto.nombre);
  return (nom && nom.split(/\s+/).find((t) => t.length >= 3)) || null;
}

function ofertaTieneMarca(normOferta, marca) {
  if (!marca) return true;
  const hay = normOferta || "";
  if (new RegExp(`(?:^|\\s)${marca}(?:\\s|$)`).test(hay)) return true;
  // Oferta "XL-3 VR" colapsa a "xl 3 vr"; nuestra marca es xl3.
  if (/^[a-z]+\d+$/.test(marca)) {
    const spaced = marca.replace(/(\d+)/g, " $1").trim();
    if (spaced !== marca && new RegExp(`(?:^|\\s)${spaced}(?:\\s|$)`).test(hay)) return true;
  }
  return false;
}

function tokensPrincipioActivo(producto) {
  const raw = colapsar(producto && producto.principio_activo);
  if (!raw) return [];
  return raw.split(/[^a-z0-9]+/).filter((w) => w.length >= 5);
}

function ofertaTienePrincipio(normOferta, producto) {
  const hay = normOferta || "";
  // Similares escribe PA con / (trimetoprima/sulfametoxazol); \s no basta.
  return tokensPrincipioActivo(producto).some((w) => new RegExp(`\\b${w}\\b`).test(hay));
}

/**
 * Anaquel conocido: se cruza por el nombre (Contac ≠ el triple de Similares).
 * Laboratorio / INN (Bactiver, Clamoxin, Amoxicilina AMSA): por el genérico.
 * No uses tipo=marca: en el catálogo casi todo está así, también los de lab.
 */
const MARCAS_MERCADO =
  /\b(ensure|pediasure|glucerna|electrolit|pedialyte|contac|xl3|desenfriol|flanax|saridon|centrum|sensodyne|histiacil|silka|cafiaspirina|aspirina|tempra|tylenol|advil|buscapina|tabcin|agrifen|vicks?|neurobion|afrin|alkaseltzer|alka seltzer|lomecan|bepanthen|mertiolate|hipoglos|neomelubrina|neo melubrina|aderogyl|riopan|theraflu|rinomar|tums|bisolvon|tukol|tukold|antiflu|syncol|graneodin|vitacilina|asepxia|mexsana|picot|microdacyn|nasalub|iodex|ting|next)\b/;

function textoMarcaMercado(producto) {
  return colapsarMarca([producto && producto.marca, producto && producto.nombre].filter(Boolean).join(" "));
}

function esMarcaComercialMercado(producto) {
  const blob = textoMarcaMercado(producto);
  return Boolean(blob) && MARCAS_MERCADO.test(blob);
}

function esMarcaPatente(producto) {
  return esMarcaComercialMercado(producto);
}

function eanNorm(value) {
  return String(value || "").replace(/\D/g, "");
}

function mismoEanProductoOferta(producto, refRow) {
  const local = eanNorm(producto && (producto.codigo_barras || producto.ean));
  const oferta = eanNorm(refRow && (refRow.ean || refRow.codigo_barras));
  if (local.length < 8 || oferta.length < 8) return false;
  return local === oferta;
}

function diagnosticoRefRappi(producto, refRow) {
  const precio = parseFloat(refRow && refRow.precio);
  if (!Number.isFinite(precio) || precio <= 0) {
    return { ok: false, motivo: "sin_precio" };
  }
  const ours = extraerUnidadProducto(producto);
  const nombre = (refRow && (refRow.nombre_fuente || refRow.nombre || refRow.notas)) || "";
  const theirs = extraerUnidadVenta(nombre);

  if (mismoEanProductoOferta(producto, refRow)) {
    return { ok: true, motivo: null, nombre, ours, theirs };
  }

  const marca = marcaBusqueda(producto);
  if (marca && theirs.texto && new RegExp(`no se encontro marca\\s+${marca}`).test(theirs.texto)) {
    return { ok: false, motivo: "otra_marca", nombre, ours, theirs };
  }
  const tieneMarca = ofertaTieneMarca(theirs.texto, marca);
  const tienePa = ofertaTienePrincipio(theirs.texto, producto);
  if (marca && theirs.texto && !tieneMarca) {
    if (esMarcaPatente(producto) || !tienePa) {
      return { ok: false, motivo: "otra_marca", nombre, ours, theirs };
    }
  }
  if (theirs.texto && !mismaConcentracionMg(textoProductoUnidad(producto), nombre)) {
    return { ok: false, motivo: "otra_concentracion", nombre, ours, theirs };
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

function nombreGondola(refRow) {
  const n = String((refRow && (refRow.nombre_fuente || refRow.nombre)) || "").trim();
  if (!n) return "";
  if (/^(promedio mercado|rastreo_automatico)$/i.test(n)) return "";
  return n;
}

/**
 * Un $ suelto no confirma la caja (Gentamicina 5 amp ≠ una ampolleta a $45).
 * Similares + anaquel: el genérico por PA no cuenta.
 */
function diagnosticoRefCadena(producto, fuente, refRow) {
  const d = diagnosticoRefRappi(producto, refRow);
  if (!d.ok) return d;
  const f = String(fuente || "");
  if (f === "fahorro" || f === "otros_venta") {
    if (!nombreGondola(refRow) && !mismoEanProductoOferta(producto, refRow)) {
      return { ...d, ok: false, motivo: "sin_ficha" };
    }
  }
  if (f === "similares" && esMarcaPatente(producto)) {
    const marca = marcaBusqueda(producto);
    if (marca && !ofertaTieneMarca(d.theirs && d.theirs.texto, marca)) {
      return { ...d, ok: false, motivo: "otra_marca" };
    }
  }
  return d;
}

function motivoEsOtroEmpaque(motivo) {
  return motivo === "otro_empaque" || motivo === "precio_otro_empaque";
}

module.exports = {
  RATIO_OTRO_EMPAQUE,
  RATIO_ABSURDO,
  extraerUnidadVenta,
  extraerUnidadProducto,
  extraerSabor,
  extraerLinea,
  extraerForma,
  extraerMgs,
  marcaBusqueda,
  tokensPrincipioActivo,
  esMarcaPatente,
  esMarcaComercialMercado,
  ofertaTieneMarca,
  mismaUnidadVenta,
  mismaConcentracionMg,
  diagnosticoRefRappi,
  diagnosticoRefCadena,
  ofertaRappiComparable,
  motivoEsOtroEmpaque,
  textoProductoUnidad,
};
