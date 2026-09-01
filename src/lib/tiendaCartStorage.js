/** Carrito de la tienda: se guarda en el navegador (invitado o cuenta). */

const GUEST_KEY = "farmacapital_cart_guest";

export function cartStorageKey(user) {
  const id = user?.id;
  if (id != null && String(id).trim() !== "") return `farmacapital_cart_${id}`;
  return GUEST_KEY;
}

function slimLine(c) {
  return {
    id: c.id,
    qty: Math.max(1, Number(c.qty) || 1),
    nombre: c.nombre,
    precio: Number(c.precio) || 0,
    imagen_url: c.imagen_url || null,
    stock: c.stock,
    activo: c.activo,
    descuento_pct: c.descuento_pct,
    categoria: c.categoria,
    requiere_receta: c.requiere_receta,
    tipo: c.tipo,
    presentacion: c.presentacion,
    precio_marca: c.precio_marca,
  };
}

export function loadStoredCart(user) {
  try {
    const raw = localStorage.getItem(cartStorageKey(user));
    if (!raw) return [];
    const arr = JSON.parse(raw);
    if (!Array.isArray(arr)) return [];
    return arr
      .filter((x) => x && x.id != null && Number(x.qty) > 0)
      .map((x) => slimLine(x));
  } catch {
    return [];
  }
}

export function saveStoredCart(user, cart) {
  try {
    const lines = (cart || []).filter((c) => c && c.id != null && Number(c.qty) > 0).map(slimLine);
    localStorage.setItem(cartStorageKey(user), JSON.stringify(lines));
  } catch {
    /* private mode */
  }
}

export function clearStoredCart(user) {
  try {
    localStorage.removeItem(cartStorageKey(user));
  } catch {
    /* noop */
  }
}

/** Junta dos carritos: misma línea suma cantidades. */
export function mergeCartLines(a, b) {
  const map = new Map();
  for (const line of [...(a || []), ...(b || [])]) {
    if (!line || line.id == null) continue;
    const id = String(line.id);
    const prev = map.get(id);
    const qty = Math.max(1, Number(line.qty) || 1);
    if (!prev) map.set(id, slimLine({ ...line, qty }));
    else {
      const stock = Number(prev.stock ?? line.stock);
      const nextQty = (Number(prev.qty) || 0) + qty;
      map.set(id, slimLine({
        ...prev,
        ...line,
        qty: Number.isFinite(stock) && stock > 0 ? Math.min(nextQty, stock) : nextQty,
      }));
    }
  }
  return [...map.values()];
}
