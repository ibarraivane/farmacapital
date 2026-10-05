/**
 * Clic de navegación SPA: solo intercepta el clic izquierdo sin modificadores.
 * Ctrl/Cmd/Shift/clic medio y «abrir en pestaña nueva» siguen el href.
 */
export function clickNavegacionTienda(e) {
  if (!e) return false;
  if (e.defaultPrevented) return false;
  if (e.button != null && e.button !== 0) return false;
  if (e.metaKey || e.ctrlKey || e.shiftKey || e.altKey) return false;
  e.preventDefault();
  return true;
}
