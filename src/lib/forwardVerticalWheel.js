/**
 * Bandas con overflow-x:auto son scrollports. En Chrome/Edge de escritorio
 * la rueda vertical se queda en la banda aunque overflow-y sea hidden:
 * la página no baja. Si el gesto es sobre todo vertical, lo pasamos al documento.
 */

export const TIENDA_H_SCROLL_SELECTOR = [
  ".farmacapital-productos-strip",
  ".farmacapital-home-services-scroll",
  ".farmacapital-home-promos-scroll",
].join(", ");

export function shouldForwardVerticalWheel(e) {
  if (!e) return false;
  const dy = Number(e.deltaY) || 0;
  const dx = Number(e.deltaX) || 0;
  return dy !== 0 && Math.abs(dy) > Math.abs(dx);
}

export function forwardVerticalWheelToPage(e, scrollPage) {
  if (!shouldForwardVerticalWheel(e)) return false;
  const dy = Number(e.deltaY) || 0;
  const move = typeof scrollPage === "function"
    ? scrollPage
    : (y) => {
      if (typeof window !== "undefined") window.scrollBy(0, y);
    };
  move(dy);
  return true;
}

export function attachForwardVerticalWheel(el) {
  if (!el || typeof el.addEventListener !== "function") return () => {};
  const onWheel = (e) => {
    forwardVerticalWheelToPage(e);
  };
  el.addEventListener("wheel", onWheel, { passive: true });
  return () => el.removeEventListener("wheel", onWheel);
}

/** En captura: cualquier banda horizontal de la tienda suelta la rueda vertical. */
export function attachTiendaHorizontalStripWheel(root = typeof document !== "undefined" ? document : null) {
  if (!root || typeof root.addEventListener !== "function") return () => {};
  const onWheel = (e) => {
    const t = e.target;
    if (!t || typeof t.closest !== "function") return;
    if (!t.closest(TIENDA_H_SCROLL_SELECTOR)) return;
    forwardVerticalWheelToPage(e);
  };
  root.addEventListener("wheel", onWheel, { passive: true, capture: true });
  return () => root.removeEventListener("wheel", onWheel, { capture: true });
}
