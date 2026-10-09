/**
 * Lecturas del catálogo.
 *
 * Suplementos y dermatología (bajo_pedido) siguen en `productos`. No se bajan
 * en la consulta del anaquel: la tienda, el POS y el inventario piden solo el
 * medicamento, y la vitrina aparte cuando hace falta.
 *
 * La tienda pública no filtra `visible_tienda` en el query (null sigue
 * visible). Un servicio de salud (`tipo = servicio`) se quita aquí aunque
 * alguien lo marque visible: no se vende en línea.
 */
import { esServicio } from "./servicioSalud";

export const PAGE_CATALOGO = 400;

/**
 * Columnas que pinta la tienda. `select *` detoasta descripciones y ficha
 * y en producción cancela con 57014 (statement timeout).
 */
export const COLUMNAS_TIENDA = [
  "id",
  "nombre",
  "sku",
  "codigo_barras",
  "marca",
  "presentacion",
  "concentracion",
  "principio_activo",
  "denominacion_distintiva",
  "denominacion_generica",
  "forma_farmaceutica",
  "categoria",
  "subcategoria",
  "vitrina_seccion",
  "vitrina_subseccion",
  "precio",
  "precio_marca",
  "descuento_pct",
  "stock",
  "activo",
  "bajo_pedido",
  "imagen_url",
  "imagen_mobile_url",
  "requiere_receta",
  "controlado",
  "grupo_controlado",
  "visible_tienda",
  "venta_unidad",
  "tipo",
].join(",");

/** 57014 y el timeout del gateway: se puede reintentar. */
export function esErrorTimeoutCatalogo(error) {
  const code = String(error?.code || "");
  const msg = String(error?.message || error || "").toLowerCase();
  return code === "57014"
    || msg.includes("statement timeout")
    || msg.includes("canceling statement")
    || msg.includes("upstream request timeout")
    || msg === "timeout";
}

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
  select = COLUMNAS_TIENDA,
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
    const crudo = data || [];
    // El corte de página usa el lote crudo: si se descarta un servicio, la
    // página sigue llena y hay que pedir la siguiente.
    filas.push(...crudo.filter((row) => !esServicio(row)));
    if (crudo.length < pedidas) break;
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
  if (error || !data || esServicio(data)) return { data: null, error: error || null };
  return { data, error: null };
}
