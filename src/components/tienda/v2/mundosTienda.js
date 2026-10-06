/**
 * «Mundos» de la tienda: las puertas de entrada del inicio.
 *
 * Cada mundo es una `vitrina_seccion` ya publicada (Nutrición deportiva,
 * Dermocosmética, Medicamentos, Higiene y cuidado personal, Vitaminas y
 * bienestar, Botiquín y equipo médico). El disco lleva la foto de un producto
 * real de esa sección.
 *
 * No uses el primero del catálogo: por `id` salen inyectables, OBAO, genéricos
 * baratos y el tiraleche. Fija SKUs en `FOTO_MUNDO`. Si no están, gana una
 * marca/producto reconocible (proteína, colágeno, Dove, botiquín).
 *
 * Es lógica pura: no importa React ni la tienda, para poder probarla.
 */
import { SECCIONES_VITRINA } from "../../../constants/vitrinaTienda";

const TONO = Object.freeze({
  "nutricion-deportiva": "jade",
  dermocosmetica: "crema",
  medicamentos: "azul",
  higiene: "terra",
  vitaminas: "miel",
  botiquin: "tinta",
});

/** SKUs preferidos, en orden. El primero que tenga foto gana ese disco. */
export const FOTO_MUNDO = Object.freeze({
  "nutricion-deportiva": Object.freeze(["FC-27054804", "FC-37273377", "FC-27051254"]),
  dermocosmetica: Object.freeze(["FC-75904292", "FC-75782357", "FC-75797641"]),
  medicamentos: Object.freeze(["FC-54521161", "FC-08491074", "FC-08895196"]),
  higiene: Object.freeze(["FC-06248052", "FC-38891190", "FC-09419324", "FC-40171550"]),
  vitaminas: Object.freeze(["FC-22112250", "FC-9741524", "FC-66031116", "FC-31003741"]),
  botiquin: Object.freeze(["FC-89592876", "FC-86708021", "FC-19332016"]),
});

const PREFERIR = Object.freeze({
  "nutricion-deportiva": [
    /proteina/,
    /whey/,
    /birdman/,
    /optimum/,
    /creatina/,
    /isolate/,
    /pre.?entreno/,
  ],
  dermocosmetica: [
    /cerave/,
    /la roche/,
    /anthelios/,
    /eucerin/,
    /bioderma/,
    /isdin/,
    /avene/,
    /cetaphil/,
  ],
  medicamentos: [/tempra/, /aspirina/, /advil/, /tylenol/, /flanax/, /motrin/],
  higiene: [/dove/, /sensodyne/, /colgate/, /rexona/, /head.?shoulders/, /oral.?b/],
  vitaminas: [/colagen/, /collagen/, /centrum/, /pharmaton/],
  botiquin: [/\bbotiquin\b/, /tegaderm/, /termometr/, /baumanometr/, /tensolastic/],
});

const EVITAR = Object.freeze({
  "nutricion-deportiva": [/inyect/, /ampollet/, /hierro dextr/, /pancreatina/],
  dermocosmetica: [],
  medicamentos: [/inyect/, /ampollet/],
  higiene: [/obao/, /savile/, /encendedor/],
  vitaminas: [],
  botiquin: [/tiraleche/, /gotero/, /encendedor/, /perilla/, /fc producto/],
});

export const MUNDOS = Object.freeze(
  SECCIONES_VITRINA.map((s) => Object.freeze({
    id: s.id,
    titulo: s.nombre,
    tono: TONO[s.id] || "azul",
    seccion: s.nombre,
    destino: Object.freeze({ seccion: s.nombre }),
    fotoSkus: FOTO_MUNDO[s.id] || Object.freeze([]),
  }))
);

function buena(p) {
  return Number(p?.stock) > 0 && Number(p?.precio) > 0.01;
}

function blobProducto(p) {
  return `${p?.nombre || ""} ${p?.marca || ""} ${p?.sku || ""}`
    .toLowerCase()
    .normalize("NFD")
    .replace(/[\u0300-\u036f]/g, "");
}

function skuNorm(p) {
  return String(p?.sku || "").trim().toUpperCase();
}

/**
 * Qué tan bien representa el producto a su mundo. Negativo = no usar (OBAO,
 * tiraleche, inyectable). SKU fijado gana; si no, proteína / colágeno / Dove.
 */
export function puntajeFotoMundo(p, mundoId) {
  const blob = blobProducto(p);
  const evitar = EVITAR[mundoId] || [];
  if (evitar.some((re) => re.test(blob))) return -1000;

  let n = 0;
  const skus = FOTO_MUNDO[mundoId] || [];
  const idx = skus.indexOf(skuNorm(p));
  if (idx >= 0) n += 1000 - idx;

  const preferir = PREFERIR[mundoId] || [];
  if (preferir.some((re) => re.test(blob))) n += 100;
  // El kit (nombre «botiquín») gana a Tegaderm / termómetro, aunque esos SKU estén fijos.
  if (mundoId === "botiquin" && /\bbotiquin\b/.test(blob) && !/fc producto/.test(blob)) n += 1500;
  if (buena(p)) n += 10;
  return n;
}

function mejor(actual, candidato, tieneFoto, mundoId) {
  if (!tieneFoto(candidato)) return actual;
  const sc = puntajeFotoMundo(candidato, mundoId);
  if (sc < 0) return actual;
  if (!actual) return candidato;
  const sa = puntajeFotoMundo(actual, mundoId);
  if (sc !== sa) return sc > sa ? candidato : actual;
  return buena(candidato) && !buena(actual) ? candidato : actual;
}

/**
 * Una sola pasada por el catálogo: cuántos productos tiene cada mundo y qué
 * producto con foto lo representa en el mosaico.
 *
 * @param {object[]} productos
 * @param {{ seccionDe: (p:object)=>string, tieneFoto: (p:object)=>boolean }} deps
 * @returns {Record<string, { n: number, producto: object|null }>}
 */
export function resumirMundos(productos, { seccionDe, tieneFoto }) {
  const resumen = Object.fromEntries(MUNDOS.map((m) => [m.id, { n: 0, producto: null }]));
  const porSeccion = new Map(MUNDOS.map((m) => [m.seccion, m]));

  for (const p of productos || []) {
    if (!p || p.activo === false) continue;
    const mundo = porSeccion.get(seccionDe(p));
    if (!mundo) continue;
    const r = resumen[mundo.id];
    r.n += 1;
    r.producto = mejor(r.producto, p, tieneFoto, mundo.id);
  }
  return resumen;
}

/**
 * Mundos que se muestran: los que tienen productos. Mientras carga el catálogo
 * (o si llegó vacío) se muestran todos para que el inicio no «salte» cuando
 * llegan los datos.
 */
export function mundosVisibles(resumen, { cargando = false, hayCatalogo = true } = {}) {
  return MUNDOS.filter((m) => cargando || !hayCatalogo || resumen[m.id]?.n > 0);
}
