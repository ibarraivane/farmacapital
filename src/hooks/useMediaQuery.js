import { useState, useEffect } from "react";

/** Coincide con window.matchMedia (p. ej. "(max-width: 768px)"). SSR: false hasta montar. */
export function useMediaQuery(query) {
  const [matches, setMatches] = useState(() =>
    typeof window !== "undefined" ? window.matchMedia(query).matches : false
  );
  useEffect(() => {
    const mq = window.matchMedia(query);
    const sync = () => setMatches(mq.matches);
    sync();
    mq.addEventListener("change", sync);
    window.addEventListener("resize", sync);
    window.addEventListener("orientationchange", sync);
    const vv = window.visualViewport;
    vv?.addEventListener("resize", sync);
    return () => {
      mq.removeEventListener("change", sync);
      window.removeEventListener("resize", sync);
      window.removeEventListener("orientationchange", sync);
      vv?.removeEventListener("resize", sync);
    };
  }, [query]);
  return matches;
}

/**
 * Teléfono (≤767px) o tablet táctil (≤1024px sin hover): usar imagen móvil en banners si existe.
 * Evita que Safari/iOS se quede en “desktop” por lecturas tardías del viewport.
 */
export function useNarrowForBannerImage() {
  return useMediaQuery(
    "(max-width: 767px), ((max-width: 1024px) and (hover: none))"
  );
}
