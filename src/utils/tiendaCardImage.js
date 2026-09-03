/**
 * Fotos de tarjeta: el packshot de Storage suele ser 600–1200 px.
 * En un recuadro de ~152 px Safari decodifica el bitmap completo (~2–6 MB).
 * La API render de Supabase entrega un thumb de verdad.
 */

export const TIENDA_CARD_THUMB_PX = 320;
export const CATALOGO_PAGE_SIZE = 36;
export const PRODUCTOS_CACHE_KEY = "farmacapital_productos_cache";

const STORAGE_OBJECT_PUBLIC = "/storage/v1/object/public/";
const STORAGE_RENDER_PUBLIC = "/storage/v1/render/image/public/";
const SKIP_THUMB_EXT = /\.(svg|gif)(\?|#|$)/i;

function clampThumbWidth(width) {
  const n = Number(width);
  if (!Number.isFinite(n)) return TIENDA_CARD_THUMB_PX;
  return Math.max(64, Math.min(1200, Math.round(n)));
}

/**
 * Reescribe una URL pública de Supabase Storage a /render/image con width.
 * Deja intactas URLs externas (Nadro, marca), data/blob, GIF y SVG.
 */
export function tiendaCardImageUrl(rawUrl, width = TIENDA_CARD_THUMB_PX) {
  const url = String(rawUrl || "").trim();
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
