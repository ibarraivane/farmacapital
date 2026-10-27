/**
 * Fotos de tarjeta: el packshot de Storage suele ser 600–1200 px.
 * En un recuadro de ~152 px Safari decodifica el bitmap completo (~2–6 MB).
 * La API render de Supabase entrega un thumb de verdad.
 * 480 px cubre pantalla 3× (152×3) sin bajar el JPEG original.
 */

import { urlImagenPublicaTienda } from "../lib/imagenCompetencia";

export { esUrlImagenCompetencia, urlImagenPublicaTienda } from "../lib/imagenCompetencia";

export const TIENDA_CARD_THUMB_PX = 480;
export const CATALOGO_PAGE_SIZE = 36;
export const PRODUCTOS_CACHE_KEY = "farmacapital_productos_cache";

const STORAGE_OBJECT_PUBLIC = "/storage/v1/object/public/";
const STORAGE_RENDER_PUBLIC = "/storage/v1/render/image/public/";
const SKIP_THUMB_EXT = /\.(svg|gif)(\?|#|$)/i;

/*
 * Miniaturas pregeneradas (sin Image Transformations de Supabase).
 *
 * /render/image cobra por cada imagen distinta que se ve en el mes; con el
 * catálogo completo son miles. En su lugar, un job (api/_lib/miniaturasJob.js)
 * guarda una copia WebP de 480 px junto a cada foto:
 *
 *   productos/rappi/7501/1.webp  →  productos/_miniaturas/480/rappi/7501/1.webp.webp
 *
 * y la tarjeta la pide como objeto público normal. Si la miniatura todavía no
 * existe (foto recién subida), instalarRespaldoMiniaturas() cambia esa <img> a
 * la original antes de que corra su onError.
 *
 * Apagado por defecto: sin REACT_APP_MINIATURAS=1 las URLs son las de siempre.
 */
export const MINIATURAS_ACTIVAS = process.env.REACT_APP_MINIATURAS === "1";
export const BUCKET_MINIATURAS = "productos";
export const MINIATURA_PREFIJO = "_miniaturas/480/";
const EXT_CON_MINIATURA = /\.(jpe?g|png|webp|avif)$/i;
const PARAMS_RENDER = ["width", "height", "resize", "quality", "format"];
const RUTA_MINIATURAS = `${STORAGE_OBJECT_PUBLIC}${BUCKET_MINIATURAS}/${MINIATURA_PREFIJO}`;

/** Ruta de Storage (sin bucket) de la miniatura de un objeto. Misma regla que el job. */
export function rutaMiniatura(nombreObjeto) {
  const nombre = String(nombreObjeto || "").replace(/^\/+/, "");
  if (!nombre || nombre.startsWith(MINIATURA_PREFIJO)) return "";
  if (!EXT_CON_MINIATURA.test(nombre)) return "";
  return `${MINIATURA_PREFIJO}${nombre}.webp`;
}

/** URL pública sin transformar: miniatura si aplica, si no la original. */
function urlSinTransformar(parsed) {
  let path = parsed.pathname || "";
  if (path.includes(STORAGE_RENDER_PUBLIC)) {
    path = path.replace(STORAGE_RENDER_PUBLIC, STORAGE_OBJECT_PUBLIC);
    PARAMS_RENDER.forEach((k) => parsed.searchParams.delete(k));
  }
  if (!path.includes(STORAGE_OBJECT_PUBLIC)) return parsed.toString();

  const [antes, despues] = path.split(STORAGE_OBJECT_PUBLIC);
  const bucketPrefijo = `${BUCKET_MINIATURAS}/`;
  if (despues.startsWith(bucketPrefijo)) {
    const miniatura = rutaMiniatura(despues.slice(bucketPrefijo.length));
    if (miniatura) {
      parsed.pathname = `${antes}${STORAGE_OBJECT_PUBLIC}${bucketPrefijo}${miniatura}`;
      return parsed.toString();
    }
  }
  parsed.pathname = path;
  return parsed.toString();
}

/** De una URL de miniatura, la URL de la foto original. "" si no es miniatura. */
export function urlOriginalDeMiniatura(rawUrl) {
  const url = String(rawUrl || "");
  if (!url.includes(RUTA_MINIATURAS)) return "";
  let parsed;
  try {
    parsed = new URL(url);
  } catch {
    return "";
  }
  const path = parsed.pathname;
  if (!path.includes(RUTA_MINIATURAS) || !/\.webp$/i.test(path)) return "";
  parsed.pathname = path
    .replace(RUTA_MINIATURAS, `${STORAGE_OBJECT_PUBLIC}${BUCKET_MINIATURAS}/`)
    .replace(/\.webp$/i, "");
  return parsed.toString();
}

/**
 * Red de seguridad: si una <img> de miniatura falla (aún no se genera), carga
 * la original en esa misma <img> y frena el evento para que el onError del
 * componente no la marque como rota ni salte a la siguiente foto.
 * Escucha en captura sobre window, así corre antes que los listeners de React.
 */
export function instalarRespaldoMiniaturas(win = typeof window !== "undefined" ? window : null) {
  if (!win || win.__fcRespaldoMiniaturas) return false;
  win.__fcRespaldoMiniaturas = true;
  win.addEventListener(
    "error",
    (e) => {
      const img = e.target;
      if (!img || img.tagName !== "IMG") return;
      const actual = img.currentSrc || img.src || "";
      const original = urlOriginalDeMiniatura(actual);
      if (!original) return;
      if (img.dataset && img.dataset.fcMiniaturaFallo === actual) return;
      if (img.dataset) img.dataset.fcMiniaturaFallo = actual;
      e.stopImmediatePropagation();
      img.src = original;
    },
    true
  );
  return true;
}

function clampThumbWidth(width) {
  const n = Number(width);
  if (!Number.isFinite(n)) return TIENDA_CARD_THUMB_PX;
  return Math.max(64, Math.min(1200, Math.round(n)));
}

/**
 * Reescribe una URL pública de Supabase Storage a /render/image con width.
 * Deja intactas URLs externas (Nadro, marca), data/blob, GIF y SVG.
 * Bloquea hotlinks a Del Ahorro (ver imagenCompetencia).
 */
export function tiendaCardImageUrl(rawUrl, width = TIENDA_CARD_THUMB_PX, opciones = {}) {
  const usarMiniaturas = opciones.miniaturas ?? MINIATURAS_ACTIVAS;
  const url = urlImagenPublicaTienda(rawUrl);
  if (!url) return "";
  if (/^(data:|blob:)/i.test(url)) return url;
  if (SKIP_THUMB_EXT.test(url)) return url;
  if (!/^https?:\/\//i.test(url)) return url;

  let parsed;
  try {
    parsed = new URL(url);
  } catch {
    return url;
  }

  if (!/\.supabase\.co$/i.test(parsed.hostname)) return url;

  // Con miniaturas encendidas nunca se emite /render/image.
  if (usarMiniaturas) return urlSinTransformar(parsed);

  const path = parsed.pathname || "";
  if (path.includes(STORAGE_OBJECT_PUBLIC)) {
    parsed.pathname = path.replace(STORAGE_OBJECT_PUBLIC, STORAGE_RENDER_PUBLIC);
  } else if (!path.includes(STORAGE_RENDER_PUBLIC)) {
    return url;
  }

  parsed.searchParams.set("width", String(clampThumbWidth(width)));
  if (!parsed.searchParams.get("resize")) {
    parsed.searchParams.set("resize", "contain");
  }
  return parsed.toString();
}

/** Borra el dump viejo del catálogo (1.5 MB síncronos) si todavía está en el aparato. */
export function clearStaleProductosCache(storage = typeof localStorage !== "undefined" ? localStorage : null) {
  if (!storage) return false;
  try {
    if (storage.getItem(PRODUCTOS_CACHE_KEY) == null) return false;
    storage.removeItem(PRODUCTOS_CACHE_KEY);
    return true;
  } catch {
    return false;
  }
}
