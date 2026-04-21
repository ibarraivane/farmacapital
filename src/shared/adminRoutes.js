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
  "cobrar-consulta": "cons_cobro",
  cons_cobro: "cons_cobro",
};

/** Slug canónico en la barra de direcciones para cada módulo (solo los que pediste + cobrar consulta). */
const PAGE_TO_SLUG = {
  cons: "consultorio",
  pos: "punto-de-venta",
  dash: "ventas",
  exp_dr: "expedientes",
  cons_dr: "mi-consultorio",
  cons_cobro: "cobrar-consulta",
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
