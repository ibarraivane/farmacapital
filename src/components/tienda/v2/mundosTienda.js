/**
 * «Mundos» de la tienda: las puertas de entrada del inicio.
 *
 * Cada mundo es una `vitrina_seccion` ya publicada (Nutrición deportiva,
 * Dermocosmética, Medicamentos, Higiene y cuidado personal, Vitaminas y
 * bienestar, Botiquín y equipo médico). El disco lleva la foto de un producto
 * real de esa sección.
 *
 * Si una foto sale fea o queda mal recortada, fija el producto en `FOTO_MUNDO`
 * con su id. Si no hay id, se elige sola: la primera con imagen y, si se puede,
 * con existencia y precio.
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

/** id de producto → foto fija de ese disco. Vacío = elección automática. */
export const FOTO_MUNDO = Object.freeze({});

export const MUNDOS = Object.freeze(
  SECCIONES_VITRINA.map((s) => Object.freeze({
    id: s.id,
    titulo: s.nombre,
    tono: TONO[s.id] || "azul",
    seccion: s.nombre,
    destino: Object.freeze({ seccion: s.nombre }),
    fotoId: FOTO_MUNDO[s.id] || null,
  }))
);

function buena(p) {
  return Number(p?.stock) > 0 && Number(p?.precio) > 0.01;
}

function mejor(actual, candidato, tieneFoto, fotoId) {
  if (!tieneFoto(candidato)) return actual;
  if (fotoId != null && String(candidato?.id) === String(fotoId)) return candidato;
  if (actual && fotoId != null && String(actual.id) === String(fotoId)) return actual;
  if (!actual) return candidato;
  // Con foto y con existencia gana a una con foto pero agotada; entre iguales, la primera (estable).
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
    r.producto = mejor(r.producto, p, tieneFoto, mundo.fotoId);
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
