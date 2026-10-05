/**
 * Enlace directo `/producto?id=…`.
 * El montaje no debe mandar al catálogo en silencio si falta el id o el producto.
 */

export function resolverFichaDeepLink({
  productId = "",
  productos = [],
  loading = false,
  fetching = false,
  saved = null,
} = {}) {
  const id = String(productId || "").trim();
  if (saved?.id && (!id || String(saved.id) === id)) {
    return { status: "ready", prod: saved };
  }
  if (id && Array.isArray(productos) && productos.length) {
    const found = productos.find((p) => String(p?.id) === id);
    if (found) return { status: "ready", prod: found };
  }
  if (loading || fetching) return { status: "loading", prod: null };
  return { status: "missing", prod: null };
}
