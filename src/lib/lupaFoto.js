/** Diámetro del círculo que sigue al cursor en la ficha (escritorio). */
export const LUPA_LENTE_PX = 148;
/** Cuánto se agranda la foto dentro de la lente. */
export const LUPA_ZOOM = 2.5;

/**
 * Índice de foto usable. Fuera de rango se queda en la primera o la última.
 * @param {number} n
 * @param {number} total
 */
export function indiceEnRango(n, total) {
  const i = Math.trunc(Number(n));
  if (!Number.isFinite(i) || total <= 0) return 0;
  if (i < 0) return 0;
  if (i >= total) return total - 1;
  return i;
}

/**
 * Lupa circular centrada en el cursor, sobre el rectángulo pintado de la foto.
 * Devuelve null si la foto es más chica que la lente o el cursor se salió.
 *
 * @param {{ left: number, top: number, width: number, height: number }} rect
 * @param {number} clientX
 * @param {number} clientY
 * @param {{ lente?: number, zoom?: number }} [opts]
 */
export function posicionLupa(rect, clientX, clientY, opts = {}) {
  const lente = opts.lente ?? LUPA_LENTE_PX;
  const zoom = opts.zoom ?? LUPA_ZOOM;
  const width = Number(rect?.width) || 0;
  const height = Number(rect?.height) || 0;
  if (width < lente + 4 || height < lente + 4) return null;
  const x = clientX - Number(rect.left);
  const y = clientY - Number(rect.top);
  if (!Number.isFinite(x) || !Number.isFinite(y)) return null;
  if (x < 0 || y < 0 || x > width || y > height) return null;
  return {
    left: x - lente / 2,
    top: y - lente / 2,
    backgroundSize: `${width * zoom}px ${height * zoom}px`,
    backgroundPosition: `${lente / 2 - x * zoom}px ${lente / 2 - y * zoom}px`,
  };
}

/**
 * Pinta o esconde la lente. El nodo ya está en el DOM (opacity 0) para no
 * montarlo en cada movimiento del mouse.
 * @param {HTMLElement | null | undefined} el
 * @param {ReturnType<typeof posicionLupa>} pos
 * @param {string} [src]
 */
export function aplicarLente(el, pos, src) {
  if (!el) return;
  if (!pos) {
    el.style.opacity = "0";
    return;
  }
  const segura = String(src || "").replace(/"/g, "%22");
  el.style.opacity = "1";
  el.style.left = `${pos.left}px`;
  el.style.top = `${pos.top}px`;
  el.style.backgroundImage = segura ? `url("${segura}")` : "none";
  el.style.backgroundSize = pos.backgroundSize;
  el.style.backgroundPosition = pos.backgroundPosition;
}
