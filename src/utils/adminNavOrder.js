import { NAV_ADMIN } from "../constants";

/** Fusiona orden guardado con la lista canónica actual (nuevos módulos al final). */
export function mergeAdminNavOrder(saved) {
  if (!Array.isArray(saved) || !saved.length) return [...NAV_ADMIN];
  const canon = new Set(NAV_ADMIN);
  const out = [];
  const seen = new Set();
  for (const id of saved) {
    if (canon.has(id) && !seen.has(id)) {
      out.push(id);
      seen.add(id);
    }
  }
  for (const id of NAV_ADMIN) {
    if (!seen.has(id)) out.push(id);
  }
  return out;
}

export function loadAdminNavOrder(usuario) {
  if (!usuario?.id) return mergeAdminNavOrder(null);
  try {
    const key = `farmax_admin_nav_order_${String(usuario.id)}`;
    const raw = localStorage.getItem(key);
    if (!raw) return mergeAdminNavOrder(null);
    return mergeAdminNavOrder(JSON.parse(raw));
  } catch {
    return mergeAdminNavOrder(null);
  }
}

export function saveAdminNavOrder(usuario, order) {
  if (!usuario?.id || !Array.isArray(order)) return;
  try {
    const key = `farmax_admin_nav_order_${String(usuario.id)}`;
    localStorage.setItem(key, JSON.stringify(order));
  } catch (_) { /* quota / private mode */ }
}

export function clearAdminNavOrder(usuario) {
  if (!usuario?.id) return;
  try {
    localStorage.removeItem(`farmax_admin_nav_order_${String(usuario.id)}`);
  } catch (_) { /* noop */ }
}

/** Reordena moviendo fromId a la posición de toId. */
export function reorderNavIds(ids, fromId, toId) {
  if (fromId === toId) return ids;
  const arr = [...ids];
  const fi = arr.indexOf(fromId);
  const ti = arr.indexOf(toId);
  if (fi < 0 || ti < 0) return ids;
  const [item] = arr.splice(fi, 1);
  arr.splice(ti, 0, item);
  return arr;
}
