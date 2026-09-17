/**
 * Rutas públicas de la tienda (/catalogo, /cuenta, …) ↔ ids internos de página.
 * No deben chocar con slugs del admin (pos, consultorio, inventario, caja, …).
 */
import {
  rubroDeQuery,
  rubroDesdeAliasSeccion,
  seccionConseguirDeQuery,
} from "../lib/bajoPedido";

export const TITULOS_TIENDA = Object.freeze({
  dermocosmetica: "Dermocosmética | FarmaCapital",
  vitaminas: "Vitaminas y suplementos | FarmaCapital",
  dispositivos: "Dispositivos médicos | FarmaCapital",
  "pedidos-especiales": "Pedidos especiales | FarmaCapital",
});
export const TITULO_TIENDA_DEFAULT = "FarmaCapital · Farmacia en línea";

const CONSEGUIR_SLUGS = new Set(["conseguir", "te-lo-conseguimos"]);
const DERMA_SLUGS = new Set(["dermocosmetica", "dermocosmeticas"]);
const DISPOSITIVOS_SLUGS = new Set(["dispositivos", "dispositivo", "dispositivo-medico", "dispositivos-medicos"]);
const PEDIDOS_SLUGS = new Set(["pedidos-especiales", "pedido-especial"]);

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
  "auth-callback",
  "cuenta",
  "puntos",
  "faq",
  "privacidad",
  "terminos",
  "envios",
  "terminos-puntos",
  "tarjeta",
  "dermocosmetica",
  "vitaminas",
  "dispositivos",
  "pedidos-especiales",
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
  { id: "tarjeta", label: "Flyer / tarjeta WhatsApp" },
  { id: "dermocosmetica", label: "Dermocosmética" },
  { id: "vitaminas", label: "Vitaminas y suplementos" },
  { id: "dispositivos", label: "Dispositivos médicos" },
  { id: "pedidos-especiales", label: "Pedidos especiales" },
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
  "auth-callback": "auth/callback",
  cuenta: "cuenta",
  puntos: "puntos",
  faq: "preguntas",
  privacidad: "privacidad",
  terminos: "terminos",
  envios: "envios",
  "terminos-puntos": "terminos-puntos",
  tarjeta: "tarjeta",
  dermocosmetica: "dermocosmetica",
  vitaminas: "vitaminas",
  dispositivos: "dispositivos",
  "pedidos-especiales": "pedidos-especiales",
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
  "auth/callback": "auth-callback",
  auth: "auth-callback",
  cuenta: "cuenta",
  puntos: "puntos",
  preguntas: "faq",
  faq: "faq",
  privacidad: "privacidad",
  terminos: "terminos",
  envios: "envios",
  "terminos-puntos": "terminos-puntos",
  tarjeta: "tarjeta",
  flyer: "tarjeta",
  hola: "tarjeta",
  dermocosmetica: "dermocosmetica",
  dermocosmeticas: "dermocosmetica",
  vitaminas: "vitaminas",
  dispositivos: "dispositivos",
  dispositivo: "dispositivos",
  "dispositivo-medico": "dispositivos",
  "dispositivos-medicos": "dispositivos",
  "pedidos-especiales": "pedidos-especiales",
  "pedido-especial": "pedidos-especiales",
  conseguir: "pedidos-especiales",
  "te-lo-conseguimos": "pedidos-especiales",
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
  const parts = p.split("/").filter(Boolean).map((s) => s.toLowerCase());
  if (!parts.length) return "home";
  // OAuth: /auth/callback (dos segmentos)
  if (parts[0] === "auth" && (parts[1] === "callback" || !parts[1])) {
    return "auth-callback";
  }
  const seg = parts[0] || "";
  return resolveTiendaPage(seg) || "home";
}

function firstPathSlug(pathname) {
  const p = String(pathname || "").replace(/\/+$/, "") || "/";
  const parts = p.split("/").filter(Boolean).map((s) => s.toLowerCase());
  return parts[0] || "";
}

function normPathForCompare(path) {
  const [rawPath, rawQs = ""] = String(path || "").split("?");
  const clean = (rawPath.replace(/\/+$/, "") || "/") + (rawQs ? `?${rawQs}` : "");
  return clean;
}

/**
 * URL ⇄ { page, seccion, rubro }. Única resolución de /conseguir, categorías y pedidos.
 * @param {string} pathname
 * @param {string} [search]
 */
export function resolveTiendaLocation(pathname, search = "") {
  const slug = firstPathSlug(pathname);
  const qs = typeof search === "string" ? search : "";
  let q = "";
  try {
    q = new URLSearchParams(qs.startsWith("?") ? qs : `?${qs}`).get("q") || "";
  } catch {
    q = "";
  }

  let page = "home";
  let seccion = "";
  let rubro = "";
  let searchOut = "";

  if (CONSEGUIR_SLUGS.has(slug)) {
    seccion = seccionConseguirDeQuery(qs);
    if (seccion === "dermatologia") {
      page = "dermocosmetica";
    } else if (seccion === "nutricion") {
      page = "vitaminas";
      rubro = rubroDeQuery(qs) || rubroDesdeAliasSeccion(qs);
    } else if (seccion === "dispositivos") {
      page = "dispositivos";
    } else {
      page = "pedidos-especiales";
      searchOut = q;
    }
  } else if (DERMA_SLUGS.has(slug)) {
    page = "dermocosmetica";
    seccion = "dermatologia";
  } else if (slug === "vitaminas") {
    page = "vitaminas";
    seccion = "nutricion";
    rubro = rubroDeQuery(qs);
  } else if (DISPOSITIVOS_SLUGS.has(slug)) {
    page = "dispositivos";
    seccion = "dispositivos";
  } else if (PEDIDOS_SLUGS.has(slug)) {
    page = "pedidos-especiales";
    searchOut = q;
  } else {
    page = tiendaPathnameToPageId(pathname) || "home";
    if (page === "pedidos-especiales") searchOut = q;
  }

  const canonicalPath = pageIdToTiendaPath(page, {
    rubro: page === "vitaminas" ? rubro : undefined,
    search: page === "pedidos-especiales" ? searchOut : undefined,
  });
  const current = `${String(pathname || "").replace(/\/+$/, "") || "/"}${qs && !String(qs).startsWith("?") ? `?${qs}` : qs}`;
  const shouldReplace = normPathForCompare(current) !== normPathForCompare(canonicalPath);

  return { page, seccion, rubro, search: searchOut, canonicalPath, shouldReplace };
}

/**
 * @param {string} pageId
 * @param {{ rx?: boolean, reset?: string, search?: string, productId?: string|number, seccion?: string, rubro?: string }} [opts]
 */
export function pageIdToTiendaPath(pageId, opts = {}) {
  let resolved = resolveTiendaPage(pageId) || "home";
  if (resolved === "conseguir") resolved = "pedidos-especiales";
  if (opts.seccion && (pageId === "conseguir" || resolved === "pedidos-especiales")) {
    const loc = resolveTiendaLocation("/conseguir", `?seccion=${opts.seccion}${opts.rubro ? `&rubro=${opts.rubro}` : ""}${opts.search ? `&q=${opts.search}` : ""}`);
    resolved = loc.page;
    if (loc.page === "vitaminas" && loc.rubro && !opts.rubro) {
      opts = { ...opts, rubro: loc.rubro };
    }
    if (loc.page === "pedidos-especiales" && loc.search && !opts.search) {
      opts = { ...opts, search: loc.search };
    }
  }
  const slug = PAGE_TO_SLUG[resolved];
  const path = slug ? `/${slug}` : "/";
  const params = new URLSearchParams();
  if (opts.rx) params.set("rx", "1");
  if (opts.reset) params.set("reset", String(opts.reset));
  if (resolved === "pedidos-especiales" && opts.search) params.set("q", String(opts.search));
  if (resolved !== "pedidos-especiales" && resolved !== "dermocosmetica" && resolved !== "vitaminas" && resolved !== "dispositivos" && opts.search) {
    params.set("q", String(opts.search));
  }
  if (resolved === "vitaminas" && opts.rubro) params.set("rubro", String(opts.rubro));
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
