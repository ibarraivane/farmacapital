/**
 * Rutas públicas del panel (/admin/…) ↔ ids internos de navegación (NAV_ITEMS).
 * Slugs legibles en español; se aceptan alias técnicos (p. ej. pos, cons, dash).
 */

const SLUG_TO_PAGE = {
  consultorio: "cons",
  cons: "cons",
  "punto-de-venta": "pos",
  pos: "pos",
  ventas: "dash",
  dash: "dash",
  expedientes: "exp_dr",
  exp_dr: "exp_dr",
  "mi-consultorio": "cons_dr",
  cons_dr: "cons_dr",
  "agenda-consultas": "agenda",
  agenda: "agenda",
  transacciones: "dash",
  trans: "dash",
  "pedidos-online": "ped_online",
  ped_online: "ped_online",
  inventario: "inv",
  "ingreso-inventario": "inv",
  manual: "ayuda",
  ayuda: "ayuda",
  /** Cobro de consultas vive en POS → pestaña Consultas (sin módulo aparte). */
  "cobrar-consulta": "pos",
  cons_cobro: "pos",
  /** Slugs técnicos (manifest PWA, enlaces directos) */
  inv: "inv",
  caja: "caja",
};

/** Slug canónico en la barra de direcciones para cada módulo (solo los que pediste + cobrar consulta). */
const PAGE_TO_SLUG = {
  cons: "consultorio",
  pos: "punto-de-venta",
  dash: "ventas",
  exp_dr: "expedientes",
  cons_dr: "mi-consultorio",
  agenda: "agenda-consultas",
  ped_online: "pedidos-online",
  inv: "inventario",
  ayuda: "manual",
};

/**
 * @param {string} pathname ej. /admin/consultorio, /consultorio o /admin
 * @returns {string|null} id de página o null → usar sesión/default
 */
export function adminPathnameToPageId(pathname) {
  let p = String(pathname || "").replace(/\/+$/, "") || "/";
  if (!/^\/admin(\/|$)/i.test(p)) {
    const seg0 = p.split("/").filter(Boolean)[0]?.toLowerCase();
    if (seg0 && SLUG_TO_PAGE[seg0]) {
      p = `/admin/${seg0}`;
    }
  }
  const seg = p
    .replace(/^\/admin\/?/i, "")
    .split("/")
    .filter(Boolean)[0]
    ?.toLowerCase();
  if (!seg) return null;
  return SLUG_TO_PAGE[seg] ?? null;
}

/**
 * @param {string} pageId ej. cons, pos
 * @returns {string} ruta bajo /admin (sin host)
 */
export function pageIdToAdminPath(pageId) {
  if (!pageId) return "/admin";
  const slug = PAGE_TO_SLUG[pageId];
  if (slug) return `/admin/${slug}`;
  return `/admin/${encodeURIComponent(pageId)}`;
}

/** Si la URL legible es transacciones, abrir Dashboard en esa pestaña. */
export function pathnameSuggestsDashTab(pathname) {
  const p = String(pathname || "").toLowerCase();
  if (p.includes("transacciones") || p.endsWith("/trans")) return "transacciones";
  return null;
}

/** Si la URL legible es “cobrar consulta”, abrir POS en pestaña Consultas. */
export function pathnameSuggestsPosTab(pathname) {
  const p = String(pathname || "").toLowerCase();
  if (p.includes("cobrar-consulta")) return "consultas";
  return null;
}
