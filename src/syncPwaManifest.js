import { adminPathnameToPageId } from "./shared/adminRoutes";

/**
 * ¿Estamos en el shell del panel (ruta /admin o alias /pos, /consultorio, etc.)?
 * Debe coincidir con la lógica de `App.jsx` para que el manifest PWA coincida con la app visible.
 */
export function isAdminWebAppShell() {
  if (typeof window === "undefined") return false;
  const path = window.location.pathname;
  return path.startsWith("/admin") || adminPathnameToPageId(path) != null;
}

/**
 * Ajusta <link rel="manifest"> y metadatos móviles según Tienda (/) vs Admin (/admin…).
 * Necesario porque el panel usa pushState sin re-montar `App`.
 */
export function syncPwaManifestLink() {
  if (typeof document === "undefined") return;

  const adminShell = isAdminWebAppShell();
  const raw = process.env.PUBLIC_URL != null ? String(process.env.PUBLIC_URL) : "";
  const base = raw.replace(/\/$/, "");
  const file = adminShell ? "manifest-admin.json" : "manifest.json";
  const href = base ? `${base}/${file}` : `/${file}`;

  let link = document.querySelector('link[rel="manifest"]');
  if (!link) {
    link = document.createElement("link");
    link.rel = "manifest";
    document.head.appendChild(link);
  }
  if (link.getAttribute("href") !== href) {
    link.setAttribute("href", href);
  }

  const title = adminShell ? "Farmax Admin" : "Farmax Tienda";
  document.querySelector('meta[name="apple-mobile-web-app-title"]')?.setAttribute("content", title);
  document.querySelector('meta[name="application-name"]')?.setAttribute("content", title);
}

/**
 * Engancha pushState/replaceState/popstate para mantener el manifest alineado con la URL.
 */
export function attachPwaManifestHistorySync() {
  if (typeof window === "undefined" || typeof history === "undefined") return () => {};

  syncPwaManifestLink();

  const wrap = (orig) =>
    function patched(...args) {
      const ret = orig.apply(this, args);
      syncPwaManifestLink();
      return ret;
    };

  const push = history.pushState;
  const rep = history.replaceState;
  history.pushState = wrap(push);
  history.replaceState = wrap(rep);

  const onPop = () => syncPwaManifestLink();
  window.addEventListener("popstate", onPop);

  return () => {
    history.pushState = push;
    history.replaceState = rep;
    window.removeEventListener("popstate", onPop);
  };
}
