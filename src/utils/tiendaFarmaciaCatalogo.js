import { productoPermitidoEnTiendaWeb } from "./orderChannels";
import { productoEsCajaAbiertaMostrador } from "./cajaAbiertaMostrador";

export { descripcionPublicaTienda, productoEsCajaAbiertaMostrador } from "./cajaAbiertaMostrador";

/**
 * Categorías cargadas como minisuper / abarrotes en inventario.
 * No se muestran en la tienda web de farmacia; la app de minisuper podrá usar otra lista o `linea_negocio` en BD.
 * Ajustá esta lista si agregás categorías de súper con otro nombre.
 */
export const CATEGORIAS_MINISUPER_EXCLUIDAS_TIENDA_FARMACIA = Object.freeze([
  "Bebidas",
  "Básicos",
  "Abarrotes",
  "Minisuper",
]);

/** Normaliza categoría para comparar (tilde, mayúsculas, espacios). */
function normalizeCategoriaKey(s) {
  return String(s ?? "")
    .trim()
    .normalize("NFD")
    .replace(/[\u0300-\u036f]/g, "")
    .toLowerCase();
}

const SET_MINISUPER_NORM = new Set(
  CATEGORIAS_MINISUPER_EXCLUIDAS_TIENDA_FARMACIA.map(normalizeCategoriaKey)
);

/** True si el producto se considera línea minisuper y se oculta en la tienda farmacia. */
export function productoEsCategoriaMinisuperTienda(p) {
  return SET_MINISUPER_NORM.has(normalizeCategoriaKey(p?.categoria));
}

/** Misma regla que tienda web, pero sin minisuper ni cajas que se venden por pieza en mostrador. */
export function productoPermitidoEnTiendaFarmaciaWeb(p) {
  if (!productoPermitidoEnTiendaWeb(p)) return false;
  if (productoEsCategoriaMinisuperTienda(p)) return false;
  if (productoEsCajaAbiertaMostrador(p)) return false;
  return true;
}

/** Mensaje para checkout / validación cuando un ítem no puede venderse en esta tienda. */
export function razonBloqueoProductoTiendaFarmacia(row) {
  if (productoEsCategoriaMinisuperTienda(row)) {
    return "Artículo de minisuper: no está en la tienda farmacia en línea por ahora. Disponible en sucursal.";
  }
  if (productoEsCajaAbiertaMostrador(row)) {
    return "Se vende por pieza en la farmacia, no por caja en línea.";
  }
  return "No disponible en tienda en línea (receta, controlado u oculto).";
}
