/**
 * Columnas de `productos` que la tienda web puede pedir con la llave anon.
 * Sin `costo`: ese dato es de mostrador y no debe salir en el catálogo público.
 *
 * `select=*` falla en cuanto se revoca el privilegio de la columna (PostgREST
 * trata `*` como todas las columnas, incluida la prohibida).
 */

export const PRODUCTOS_COLUMNAS_TIENDA = Object.freeze([
  "id",
  "nombre",
  "sku",
  "codigo_barras",
  "categoria",
  "subcategoria",
  "stock",
  "stock_minimo",
  "activo",
  "marca",
  "presentacion",
  "principio_activo",
  "forma_farmaceutica",
  "precio",
  "descuento_pct",
  "imagen_url",
  "imagen_mobile_url",
  "descripcion",
  "tipo",
  "denominacion_generica",
  "denominacion_distintiva",
  "concentracion",
  "requiere_receta",
  "controlado",
  "grupo_controlado",
  "visible_tienda",
  "bajo_pedido",
  "vitrina_seccion",
  "vitrina_subseccion",
  "venta_unidad",
  "unidades_por_caja",
  "updated_at",
]);

export const PRODUCTOS_SELECT_TIENDA = PRODUCTOS_COLUMNAS_TIENDA.join(",");

/** True si el select de PostgREST pide `costo` o el comodín `*`. */
export function selectIncluyeCosto(select) {
  if (select == null) return false;
  const s = String(select).trim();
  if (s === "*") return true;
  return s.split(",").some((col) => col.trim().replace(/"/g, "") === "costo");
}
