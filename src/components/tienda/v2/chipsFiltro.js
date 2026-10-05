/**
 * Lógica de los chips de filtro del catálogo (marcas o categorías).
 *
 * Problema: Dermocosmética llega a ~48 marcas y Nutrición a ~127. Mostrarlas
 * todas como botones inunda la pantalla. Regla: se ven pocas, las que más
 * producto tienen, y el resto vive detrás de «Ver todas» con buscador.
 *
 * Es pura (sin React) para poder probarla y reusarla con cualquier lista.
 */

export const MAX_CHIPS_VISIBLES = 8;

/** Opciones que nunca se esconden (siempre la primera: quitar el filtro). */
const FIJAS = ["Todos"];

/**
 * Reparte las opciones en las que se ven como chip y las que quedan en el panel.
 *
 * - «Todos» siempre visible y primero.
 * - Las demás se rankean por cantidad de productos (`conteos`); sin conteos
 *   se respeta el orden en que llegan.
 * - La opción seleccionada SIEMPRE queda visible, aunque no esté entre las
 *   más grandes: si no, el usuario filtraría y no vería qué filtro trae puesto.
 * - Los visibles conservan el orden original de la lista.
 *
 * @returns {{ visibles: string[], ocultas: string[] }}
 */
export function repartirChips(opciones, { valor = "", conteos = {}, max = MAX_CHIPS_VISIBLES } = {}) {
  const lista = [...new Set((opciones || []).filter(Boolean))];
  if (lista.length <= max) return { visibles: lista, ocultas: [] };

  const fijas = lista.filter((o) => FIJAS.includes(o));
  const resto = lista.filter((o) => !FIJAS.includes(o));
  const cupo = Math.max(1, max - fijas.length);

  const orden = new Map(resto.map((o, i) => [o, i]));
  const porPeso = [...resto].sort(
    (a, b) => (conteos[b] || 0) - (conteos[a] || 0) || orden.get(a) - orden.get(b)
  );

  let elegidas = porPeso.slice(0, cupo);
  if (valor && resto.includes(valor) && !elegidas.includes(valor)) {
    elegidas = [...elegidas.slice(0, cupo - 1), valor];
  }

  const set = new Set(elegidas);
  return {
    visibles: [...fijas, ...resto.filter((o) => set.has(o))],
    ocultas: resto.filter((o) => !set.has(o)),
  };
}

function sinAcentos(s) {
  return String(s ?? "").normalize("NFD").replace(/[\u0300-\u036f]/g, "");
}

/** Para comparar «Avène» con «avene» al buscar dentro del panel. */
export function claveBusqueda(s) {
  return sinAcentos(s).toLowerCase().trim();
}

/**
 * Agrupa por letra inicial, A–Z, para el panel «Ver todas».
 * Lo que no empieza con letra (p. ej. «3M») va al grupo «#», al final.
 *
 * @returns {{ letra: string, items: string[] }[]}
 */
export function agruparPorInicial(opciones) {
  const ordenadas = [...(opciones || [])].sort((a, b) =>
    sinAcentos(a).localeCompare(sinAcentos(b), "es", { sensitivity: "base" })
  );
  const grupos = new Map();
  for (const o of ordenadas) {
    const l = sinAcentos(o).trim().charAt(0).toUpperCase();
    const letra = /[A-Z]/.test(l) ? l : "#";
    if (!grupos.has(letra)) grupos.set(letra, []);
    grupos.get(letra).push(o);
  }
  const claves = [...grupos.keys()].sort((a, b) => (a === "#") - (b === "#") || a.localeCompare(b));
  return claves.map((letra) => ({ letra, items: grupos.get(letra) }));
}

/** Filtra las opciones del panel por lo que escribió la persona. */
export function filtrarOpciones(opciones, texto) {
  const q = claveBusqueda(texto);
  if (!q) return opciones || [];
  return (opciones || []).filter((o) => claveBusqueda(o).includes(q));
}
