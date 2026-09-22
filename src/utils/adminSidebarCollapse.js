export const ADMIN_SIDEBAR_WIDTH_PX = 220;
export const ADMIN_SIDEBAR_COLLAPSE_KEY = "farmacapital_admin_sidebar_collapsed";

/** Preferencia de escritorio: barra de módulos minimizada (como el menú ☰ del celular). */
export function loadAdminSidebarCollapsed(storage = typeof localStorage !== "undefined" ? localStorage : null) {
  try {
    return storage?.getItem(ADMIN_SIDEBAR_COLLAPSE_KEY) === "1";
  } catch {
    return false;
  }
}

export function saveAdminSidebarCollapsed(collapsed, storage = typeof localStorage !== "undefined" ? localStorage : null) {
  try {
    storage?.setItem(ADMIN_SIDEBAR_COLLAPSE_KEY, collapsed ? "1" : "0");
  } catch {
    /* quota / private mode */
  }
}

/** Overlay fuera de canvas: celular, o escritorio con la barra minimizada. */
export function adminSidebarIsOverlay({ isMobile, collapsed }) {
  return Boolean(isMobile || collapsed);
}

export function adminMainMarginLeftPx({ isMobile, collapsed }) {
  return adminSidebarIsOverlay({ isMobile, collapsed }) ? 0 : ADMIN_SIDEBAR_WIDTH_PX;
}
