/**
 * Lecturas del catálogo.
 *
 * Suplementos y dermatología (bajo_pedido) siguen en `productos`. No se bajan
 * en la consulta del anaquel: la tienda, el POS y el inventario piden solo el
 * medicamento, y la vitrina aparte cuando hace falta.
 */

export const PAGE_CATALOGO = 1000;

/** PostgREST: null y false son anaquel. true es la vitrina. */
export const FILTRO_ANAQUEL = "bajo_pedido.eq.false,bajo_pedido.is.null";

export function aplicarModoCatalogo(q, modo = "anaquel") {
  if (!q) return q;
  if (modo === "vitrina") return q.eq("bajo_pedido", true);
  if (modo === "todos") return q;
  return q.or(FILTRO_ANAQUEL);
}

/**
 * Páginas de productos activos.
 * modo "anaquel" omite la vitrina. "vitrina" trae solo esa. limite 0 = todas.
 */
export async function traerProductosActivos(client, {
  modo = "anaquel",
  select = "*",
  limite = 0,
  pageSize = PAGE_CATALOGO,
  order = "id",
} = {}) {
  const filas = [];
  const tope = limite > 0 ? limite : Infinity;
  for (let desde = 0; filas.length < tope; desde += pageSize) {
    const pedidas = Math.min(pageSize, tope - filas.length);
    let q = client.from("productos").select(select).eq("activo", true);
    q = aplicarModoCatalogo(q, modo);
    const { data, error } = await q.order(order).order("id").range(desde, desde + pedidas - 1);
    if (error) return { data: null, error };
    const lote = data || [];
    filas.push(...lote);
    if (lote.length < pedidas) break;
  }
  return { data: limite > 0 ? filas.slice(0, limite) : filas, error: null };
}

/**
 * Un producto por id (enlace directo). El catálogo de inicio es una muestra;
 * el deep-link no puede depender de `productos.find` sobre esa lista corta.
 */
export async function traerProductoPorId(client, id, { select = "*" } = {}) {
  const key = String(id || "").trim();
  if (!key) return { data: null, error: null };
  const numeric = /^\d+$/.test(key);
  const { data, error } = await client
    .from("productos")
    .select(select)
    .eq("id", numeric ? Number(key) : key)
    .maybeSingle();
  return { data: data || null, error: error || null };
}
