/**
 * Lecturas del catálogo.
 *
 * Suplementos y dermatología (bajo_pedido) siguen en `productos`. No se bajan
 * en la consulta del anaquel: la tienda, el POS y el inventario piden solo el
 * medicamento, y la vitrina aparte cuando hace falta.
 */

export const PAGE_CATALOGO = 1000;

/**
 * Columnas que la llave pública puede leer.
 * `costo` no va: un `select=*` (o cualquier select que lo incluya) responde
 * 42501 «permission denied for table productos».
 */
export const PRODUCTOS_SELECT_PUBLICO = [
  "id", "nombre", "sku", "codigo_barras", "categoria", "subcategoria", "descripcion", "tipo",
  "presentacion", "marca", "principio_activo", "concentracion", "forma_farmaceutica",
  "denominacion_generica", "denominacion_distintiva", "laboratorio", "ubicacion_texto",
  "precio", "precio_marca", "precio_unidad", "precio_blister", "descuento_pct", "descuento_mxn",
  "stock", "stock_minimo", "stock_unidades", "stock_blisters", "activo", "visible_tienda",
  "bajo_pedido", "requiere_receta", "controlado", "grupo_controlado", "venta_unidad",
  "unidades_por_caja", "piezas_por_blister", "imagen_url", "imagen_mobile_url",
  "created_at", "updated_at",
].join(",");

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
  select = PRODUCTOS_SELECT_PUBLICO,
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
