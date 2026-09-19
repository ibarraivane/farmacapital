/**
 * Posición del catálogo al ir a un producto y volver.
 * El catálogo se desmonta (SPA por `page`); sin esto, "atrás" abre arriba
 * y pierde el "Cargar más".
 */

export const CATALOGO_SCROLL_KEY = "farmacapital_catalogo_scroll";
export const CATALOGO_VISIBLES_KEY = "farmacapital_catalogo_visibles";
export const CATALOGO_PRODUCTO_KEY = "farmacapital_catalogo_producto";
export const CATALOGO_RESTORE_KEY = "farmacapital_catalogo_restore";

function ssGet(key) {
  try {
    return sessionStorage.getItem(key);
  } catch {
    return null;
  }
}

function ssSet(key, value) {
  try {
    sessionStorage.setItem(key, value);
    return true;
  } catch {
    return false;
  }
}

function ssDel(key) {
  try {
    sessionStorage.removeItem(key);
  } catch {
    /* noop */
  }
}

export function leerScrollCatalogo() {
  const y = Number(ssGet(CATALOGO_SCROLL_KEY));
  return Number.isFinite(y) && y > 0 ? Math.round(y) : 0;
}

export function guardarScrollCatalogo(y) {
  const n = Number(y);
  if (!Number.isFinite(n) || n <= 0) {
    ssDel(CATALOGO_SCROLL_KEY);
    return 0;
  }
  const rounded = Math.round(n);
  ssSet(CATALOGO_SCROLL_KEY, String(rounded));
  return rounded;
}

export function leerVisiblesCatalogo(pageSize) {
  const min = Math.max(1, Number(pageSize) || 1);
  const n = Number(ssGet(CATALOGO_VISIBLES_KEY));
  if (!Number.isFinite(n) || n < min) return min;
  return Math.round(n);
}

export function guardarVisiblesCatalogo(n, pageSize) {
  const min = Math.max(1, Number(pageSize) || 1);
  const v = Math.max(min, Math.round(Number(n) || min));
  ssSet(CATALOGO_VISIBLES_KEY, String(v));
  return v;
}

export function leerProductoCatalogo() {
  return String(ssGet(CATALOGO_PRODUCTO_KEY) || "").trim();
}

export function guardarProductoCatalogo(id) {
  const s = id == null ? "" : String(id).trim();
  if (!s) {
    ssDel(CATALOGO_PRODUCTO_KEY);
    return "";
  }
  ssSet(CATALOGO_PRODUCTO_KEY, s);
  return s;
}

export function hayRestoreCatalogo() {
  return ssGet(CATALOGO_RESTORE_KEY) === "1";
}

export function marcarRestoreCatalogo() {
  ssSet(CATALOGO_RESTORE_KEY, "1");
  return true;
}

export function limpiarRestoreCatalogo() {
  ssDel(CATALOGO_RESTORE_KEY);
}

/** Quita scroll, producto, restore y visibles (visita nueva al catálogo). */
export function resetearPosicionCatalogo() {
  ssDel(CATALOGO_SCROLL_KEY);
  ssDel(CATALOGO_PRODUCTO_KEY);
  ssDel(CATALOGO_RESTORE_KEY);
  ssDel(CATALOGO_VISIBLES_KEY);
}

/**
 * Al abrir /catalogo: restaurar si venías del producto;
 * "results" deja que la búsqueda haga scroll al listado;
 * el resto va arriba (carrito, menú, home).
 */
export function intentScrollCatalogo({ fromPage, catalogoScroll } = {}) {
  if (catalogoScroll === "results" || catalogoScroll === "top" || catalogoScroll === "restore") {
    return catalogoScroll;
  }
  return fromPage === "detalle" ? "restore" : "top";
}

export function snapshotSalidaCatalogo({ scrollY, productId } = {}) {
  guardarScrollCatalogo(scrollY);
  if (productId != null && String(productId).trim()) {
    guardarProductoCatalogo(productId);
  }
}

export function aplicarPosicionCatalogo({
  y = 0,
  productId = "",
  scrollTo,
  findProducto,
} = {}) {
  const go = typeof scrollTo === "function"
    ? scrollTo
    : (top) => {
      try { window.scrollTo(0, top); } catch { /* jsdom */ }
    };

  const find = typeof findProducto === "function"
    ? findProducto
    : (id) => {
      if (typeof document === "undefined" || !id) return null;
      const raw = String(id);
      try {
        const esc = typeof CSS !== "undefined" && CSS.escape ? CSS.escape(raw) : raw;
        return document.querySelector(`[data-catalogo-producto="${esc}"]`);
      } catch {
        return document.querySelector(`[data-catalogo-producto="${raw}"]`);
      }
    };

  const el = productId ? find(productId) : null;
  if (el && typeof el.scrollIntoView === "function") {
    el.scrollIntoView({ block: "center", inline: "nearest" });
    return "producto";
  }
  const top = Number(y);
  if (Number.isFinite(top) && top > 0) {
    go(top);
    return "scroll";
  }
  go(0);
  return "top";
}
