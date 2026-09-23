/**
 * Qué productos pueden llevar estrellas y reseñas de clientes.
 *
 * Regla de negocio, no de diseño: la publicidad de medicamentos está regulada
 * y una reseña de cliente es una afirmación publicada bajo el responsable
 * sanitario de la farmacia. Por eso aquí NO se decide por lista negra sino por
 * lista blanca: lo que no está permitido explícitamente, no lleva reseñas.
 * Una categoría nueva en el inventario entra bloqueada hasta que alguien la
 * agregue a mano a esta lista.
 *
 * Ninguna reseña se publica sola: todas nacen en estado "pendiente" y la
 * farmacia las aprueba. Esta función solo dice si el producto puede recibirlas.
 */
import { categoriaVitrina, normalizeCategoriaKey, esMedicamentoControlado } from "../constants/categoriasProducto";

/** Categorías que sí aceptan reseñas. Nada de esto es medicamento. */
export const CATEGORIAS_CON_RESENA = Object.freeze([
  "Cuidado personal",
  "Dermocosmético",
  "Higiene",
  "Bebés",
  "Suplemento",
  "Vitaminas",
  "Herbolario",
  "Botiquín",
  "Curación",
  "Dispositivo médico",
]);

const PERMITIDAS = new Set(CATEGORIAS_CON_RESENA.map(normalizeCategoriaKey));
// Alias que el inventario trae escritos de otra forma.
["dermocosmetica", "dermocosmeticos", "suplementos", "dispositivos", "bebe"].forEach((k) => PERMITIDAS.add(k));

/** Motivo por el que un producto no acepta reseñas. "" si sí las acepta. */
export function motivoSinResena(prod) {
  if (!prod || typeof prod !== "object") return "Producto no válido";
  if (prod.requiere_receta) return "Requiere receta médica";
  if (esMedicamentoControlado(prod)) return "Medicamento controlado";
  const cat = categoriaVitrina(prod);
  if (!PERMITIDAS.has(normalizeCategoriaKey(cat))) {
    return `Categoría sin reseñas: ${cat || "sin categoría"}`;
  }
  return "";
}

/** ¿Este producto puede mostrar y recibir estrellas? */
export function productoAceptaResena(prod) {
  return motivoSinResena(prod) === "";
}

/**
 * Promedio a partir de las reseñas ya aprobadas.
 * Devuelve null cuando todavía no hay ninguna: media estrella inventada es peor
 * que no mostrar nada.
 */
export function promedioResenas(resenas) {
  const validas = (Array.isArray(resenas) ? resenas : []).filter(
    (r) => r && r.estado === "aprobada" && Number.isFinite(Number(r.estrellas))
  );
  if (!validas.length) return null;
  const suma = validas.reduce((s, r) => s + Math.min(5, Math.max(1, Math.round(Number(r.estrellas)))), 0);
  return { promedio: Math.round((suma / validas.length) * 10) / 10, total: validas.length };
}

/** Texto accesible del promedio, para el aria-label de las estrellas. */
export function textoPromedio(resumen) {
  if (!resumen) return "Sin reseñas todavía";
  const n = resumen.total;
  return `${resumen.promedio} de 5 · ${n} ${n === 1 ? "reseña" : "reseñas"}`;
}
