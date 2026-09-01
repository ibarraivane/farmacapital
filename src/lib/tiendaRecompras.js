/** Compra de nuevo / sugeridos a partir de pedidos del cliente + catálogo vivo. */

function fold(s) {
  return String(s || "")
    .normalize("NFD")
    .replace(/[\u0300-\u036f]/g, "")
    .toLowerCase()
    .replace(/\s+/g, " ")
    .trim();
}

function catalogIndexes(catalogo) {
  const byId = new Map();
  const byName = new Map();
  for (const p of catalogo || []) {
    if (!p || p.id == null) continue;
    byId.set(String(p.id), p);
    const n = fold(p.nombre);
    if (n && !byName.has(n)) byName.set(n, p);
  }
  return { byId, byName };
}

function resolveItemProduct(it, byId, byName) {
  const pid = it?.producto_id ?? it?.productos?.id ?? it?.productos?.producto_id;
  if (pid != null && byId.has(String(pid))) return byId.get(String(pid));
  const nom = fold(it?.productos?.nombre || it?.nombre);
  if (nom && byName.has(nom)) return byName.get(nom);
  return null;
}

/**
 * Productos que el cliente ya compró, más recientes primero.
 * Omite cancelados y lo que ya no está en catálogo.
 */
export function recomprasFromPedidos(pedidos, catalogo) {
  const { byId, byName } = catalogIndexes(catalogo);
  const seen = new Map();
  for (const pedido of pedidos || []) {
    if (String(pedido?.estado || "").toLowerCase() === "cancelado") continue;
    const at = pedido.created_at || "";
    for (const it of pedido.pedido_items || []) {
      const prod = resolveItemProduct(it, byId, byName);
      if (!prod || prod.activo === false) continue;
      const id = String(prod.id);
      const qty = Math.max(1, Number(it.cantidad) || 1);
      const prev = seen.get(id);
      if (!prev) {
        seen.set(id, { prod, lastAt: at, times: 1, lastQty: qty });
      } else {
        prev.times += 1;
        if (String(at) > String(prev.lastAt)) {
          prev.lastAt = at;
          prev.lastQty = qty;
        }
      }
    }
  }
  return [...seen.values()].sort((a, b) => String(b.lastAt).localeCompare(String(a.lastAt)));
}

/**
 * Sugeridos: misma categoría que lo que ya compró, que aún no tiene.
 */
export function sugeridosFromRecompras(recompras, catalogo, { limit = 6, permitido } = {}) {
  const bought = new Set((recompras || []).map((r) => String(r.prod.id)));
  const cats = new Set(
    (recompras || []).map((r) => fold(r.prod?.categoria)).filter(Boolean)
  );
  const ok = typeof permitido === "function" ? permitido : () => true;
  const out = [];
  for (const p of catalogo || []) {
    if (!p || p.activo === false) continue;
    if (bought.has(String(p.id))) continue;
    if (cats.size && !cats.has(fold(p.categoria))) continue;
    if (!ok(p)) continue;
    out.push(p);
    if (out.length >= limit) break;
  }
  return out;
}
