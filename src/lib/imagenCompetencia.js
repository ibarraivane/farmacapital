/**
 * Imágenes de competencia (Del Ahorro / Fahorro) — nunca en catálogo ni marketing.
 *
 * Caso real 2026-09-17: Fahorro responde su logo rosa «A» (500×500, 6334 bytes)
 * cuando el EAN no tiene packshot. Eso llegó a /conseguir como foto de Atoderm.
 *
 * Política:
 * - Packshot real del producto: OK (idealmente en catalogo-propia/).
 * - Logo / placeholder de otra farmacia: NUNCA guardar ni mostrar.
 * - Hotlink a fahorro.com / production-media.fahorro.com: NUNCA en tienda.
 */

export const PLACEHOLDER_FAHORRO_MD5 = "59370f17d7cac03761209f4b0cf46374";
/** Tamaño exacto del PNG rosa «A» que sirve Fahorro sin foto. */
export const PLACEHOLDER_FAHORRO_BYTES = 6334;

const HOSTS_IMAGEN_COMPETENCIA = [
  /(^|\.)fahorro\.com$/i,
];

/** True si la URL apunta al CDN / sitio de Del Ahorro. */
export function esUrlImagenCompetencia(rawUrl) {
  const url = String(rawUrl || "").trim();
  if (!url || !/^https?:\/\//i.test(url)) return false;
  let host;
  try {
    host = new URL(url).hostname;
  } catch {
    return false;
  }
  return HOSTS_IMAGEN_COMPETENCIA.some((re) => re.test(host));
}

/**
 * URL segura para tienda / marketing. Vacío si es host de competencia
 * (la UI cae al ícono Package o sin imagen).
 */
export function urlImagenPublicaTienda(rawUrl) {
  const url = String(rawUrl || "").trim();
  if (!url) return "";
  if (esUrlImagenCompetencia(url)) return "";
  return url;
}

/**
 * Detecta el placeholder de Del Ahorro (logo «A») por hash o por firma
 * tamaño + 500×500. Usar al bajar o antes de subir a Storage / catalogo-propia.
 *
 * @param {{ byteLength?: number, width?: number, height?: number, md5?: string }} meta
 */
export function esPlaceholderImagenCompetencia(meta = {}) {
  const md5 = String(meta.md5 || "").toLowerCase();
  if (md5 && md5 === PLACEHOLDER_FAHORRO_MD5) return true;

  const bytes = Number(meta.byteLength);
  const w = Number(meta.width);
  const h = Number(meta.height);
  if (bytes === PLACEHOLDER_FAHORRO_BYTES) return true;
  // Mismo asset u otra variante chica del logo: 500×500 y &lt; 10 KB
  if (Number.isFinite(w) && Number.isFinite(h) && w === 500 && h === 500 && Number.isFinite(bytes) && bytes > 0 && bytes < 10_000) {
    return true;
  }
  return false;
}

export function mensajeRechazoImagenCompetencia() {
  return "Esa imagen es el logo/placeholder de otra farmacia (Del Ahorro). Sube el packshot del producto o déjalo sin foto.";
}
