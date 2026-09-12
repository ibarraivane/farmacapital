/** Holgura en px: no mostrar flecha por 1 px de overflow. */
export const STRIP_ARROW_SLACK = 8;

/**
 * Si la banda puede ir atrás / adelante según el scroll actual.
 * @param {{ scrollLeft?: number, scrollWidth?: number, clientWidth?: number } | null} el
 * @param {number} [slack]
 */
export function stripArrowState(el, slack = STRIP_ARROW_SLACK) {
  if (!el) return { canPrev: false, canNext: false };
  const max = Math.max(0, Number(el.scrollWidth) - Number(el.clientWidth));
  if (max <= slack) return { canPrev: false, canNext: false };
  const left = Number(el.scrollLeft) || 0;
  return {
    canPrev: left > slack,
    canNext: left < max - slack,
  };
}

/**
 * Nuevo `scrollLeft` al avanzar o retroceder una página (~el ancho visible).
 * Así en laptop se ven ~5 productos y la flecha revela el siguiente grupo.
 * @param {{ scrollLeft?: number, scrollWidth?: number, clientWidth?: number } | null} el
 * @param {number} dir  1 = siguientes, -1 = anteriores
 */
export function stripPageScrollLeft(el, dir) {
  if (!el) return 0;
  const page = Math.max(Number(el.clientWidth) || 0, 1);
  const max = Math.max(0, Number(el.scrollWidth) - Number(el.clientWidth));
  const next = (Number(el.scrollLeft) || 0) + (dir < 0 ? -page : page);
  return Math.max(0, Math.min(max, next));
}
