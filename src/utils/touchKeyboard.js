/** Tablet / celular: el teclado no sale si el input se enfocó por código, no por toque. */

export function isCoarsePointer() {
  if (typeof window === "undefined" || typeof window.matchMedia !== "function") return false;
  return window.matchMedia("(pointer: coarse)").matches || window.matchMedia("(hover: none)").matches;
}

/** Quita readonly en el mismo toque, antes del focus (React setState llega tarde). */
export function unlockInputForTouchKeyboard(el) {
  if (!el || el.disabled) return;
  if (el.getAttribute("readonly") != null) el.removeAttribute("readonly");
}

export function lockInputAfterTouchKeyboard(el) {
  if (!el || !isCoarsePointer()) return;
  el.setAttribute("readonly", "readonly");
}

export function armInputForTouchKeyboard(el) {
  if (!el || !isCoarsePointer()) return;
  el.setAttribute("readonly", "readonly");
}
