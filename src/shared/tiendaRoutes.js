/**
 * Rutas públicas de la tienda (/catalogo, /cuenta, …) ↔ ids internos de página.
 * No deben chocar con slugs del admin (pos, consultorio, inventario, caja, …).
 */

export const TIENDA_PAGE_IDS = [
  "home",
  "catalogo",
  "promo",
  "detalle",
  "carrito",
  "checkout",
  "cita",
  "login",
  "registro",
  "reset-password",
  "cuenta",
  "puntos",
  "faq",
  "privacidad",
  "terminos",
  "envios",
  "terminos-puntos",
];

/** Destinos válidos para banners (CTA). detalle/checkout/reset no se eligen a mano. */
export const TIENDA_BANNER_DESTINOS = [
  { id: "home", label: "Inicio" },
  { id: "catalogo", label: "Catálogo" },
  { id: "promo", label: "Promociones" },
  { id: "cita", label: "Agendar cita" },
  { id: "puntos", label: "Programa de puntos" },
  { id: "cuenta", label: "Mi cuenta" },
  { id: "carrito", label: "Carrito" },
  { id: "faq", label: "Preguntas frecuentes" },
  { id: "registro", label: "Crear cuenta" },
  { id: "login", label: "Iniciar sesión" },
  { id: "privacidad", label: "Aviso de privacidad" },
  { id: "terminos", label: "Términos y condiciones" },
  { id: "envios", label: "Política de envíos" },
  { id: "terminos-puntos", label: "Términos de puntos" },
];

const PAGE_TO_SLUG = {
  home: "",
  catalogo: "catalogo",
  promo: "promociones",
  detalle: "producto",
  carrito: "carrito",
  checkout: "checkout",
  cita: "cita",
  login: "login",
  registro: "registro",
  "reset-password": "recuperar",
  cuenta: "cuenta",
  puntos: "puntos",
  faq: "preguntas",
  privacidad: "privacidad",
  terminos: "terminos",
  envios: "envios",
  "terminos-puntos": "terminos-puntos",
};

const SLUG_TO_PAGE = {
  "": "home",
  catalogo: "catalogo",
  catalog: "catalogo",
  shop: "catalogo",
  promociones: "promo",
  promo: "promo",
  ofertas: "promo",
  producto: "detalle",
  detalle: "detalle",
  carrito: "carrito",
  checkout: "checkout",
  pago: "checkout",
  cita: "cita",
  citas: "cita",
  consulta: "cita",
  "consulta-medica": "cita",
  login: "login",
  entrar: "login",
  registro: "registro",
  recuperar: "reset-password",
  cuenta: "cuenta",
  puntos: "puntos",
  preguntas: "faq",
  faq: "faq",
  privacidad: "privacidad",
  terminos: "terminos",
  envios: "envios",
  "terminos-puntos": "terminos-puntos",
};

/**
 * @param {string} raw
 * @returns {string|null} id de página o null si no es de la tienda
 */
export function resolveTiendaPage(raw) {
  const s = String(raw || "").trim().toLowerCase()
    .replace(/^\/+/, "")
    .replace(/\/+$/, "");
  if (!s) return "home";
  if (TIENDA_PAGE_IDS.includes(s)) return s;
  if (SLUG_TO_PAGE[s]) return SLUG_TO_PAGE[s];
  const noAccents = s.normalize("NFD").replace(/[\u0300-\u036f]/g, "");
  if (SLUG_TO_PAGE[noAccents]) return SLUG_TO_PAGE[noAccents];
  return null;
}

/**
 * @param {string} pathname
 * @returns {string} id de página (home si no hay match)
 */
export function tiendaPathnameToPageId(pathname) {
  const p = String(pathname || "").replace(/\/+$/, "") || "/";
  if (/^\/admin(\/|$)/i.test(p)) return null;
  if (/^\/r(\/|$)/i.test(p)) return null;
  const seg = p.split("/").filter(Boolean)[0]?.toLowerCase() || "";
  if (!seg) return "home";
  return resolveTiendaPage(seg) || "home";
}

/**
 * @param {string} pageId
 * @param {{ rx?: boolean, reset?: string, search?: string, productId?: string|number }} [opts]
 */
export function pageIdToTiendaPath(pageId, opts = {}) {
  const resolved = resolveTiendaPage(pageId) || "home";
  const slug = PAGE_TO_SLUG[resolved];
  const path = slug ? `/${slug}` : "/";
  const params = new URLSearchParams();
  if (opts.rx) params.set("rx", "1");
  if (opts.reset) params.set("reset", String(opts.reset));
  if (opts.search) params.set("q", String(opts.search));
  if (opts.productId != null && String(opts.productId).trim()) {
    params.set("id", String(opts.productId).trim());
  }
  const qs = params.toString();
  return qs ? `${path}?${qs}` : path;
}

/** Id de producto en `/producto?id=…` (sobrevive recarga). */
export function tiendaProductIdFromSearch(search) {
  try {
    return String(new URLSearchParams(search || "").get("id") || "").trim();
  } catch {
    return "";
  }
}

export function tiendaPathSuggestsReceta(pathname, search) {
  try {
    const q = new URLSearchParams(search || "");
    if (q.get("rx") === "1") return true;
  } catch (_) { /* noop */ }
  return /receta/i.test(String(pathname || ""));
}
