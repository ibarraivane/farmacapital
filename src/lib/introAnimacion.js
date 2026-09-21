export const INTRO_STORAGE_KEY = "farmacapital_intro_vista";

export function prefersReducedMotion(win = typeof window !== "undefined" ? window : null) {
  try {
    return Boolean(win?.matchMedia?.("(prefers-reduced-motion: reduce)")?.matches);
  } catch {
    return false;
  }
}

export function leerIntroYaVista(storage) {
  try {
    const s = storage || (typeof sessionStorage !== "undefined" ? sessionStorage : null);
    return s?.getItem(INTRO_STORAGE_KEY) === "1";
  } catch {
    return false;
  }
}

export function marcarIntroVista(storage) {
  try {
    const s = storage || (typeof sessionStorage !== "undefined" ? sessionStorage : null);
    s?.setItem(INTRO_STORAGE_KEY, "1");
    return true;
  } catch {
    return false;
  }
}

/** Solo la primera visita de la sesión, y nunca con movimiento reducido. */
export function debeMostrarIntro({ storage, win } = {}) {
  if (prefersReducedMotion(win)) return false;
  try {
    const s = storage || (typeof sessionStorage !== "undefined" ? sessionStorage : null);
    if (!s) return false;
    return s.getItem(INTRO_STORAGE_KEY) !== "1";
  } catch {
    return false;
  }
}
