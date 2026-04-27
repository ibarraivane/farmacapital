import { productoPermitidoEnTiendaWeb } from "./orderChannels";

/**
 * Categorías cargadas como minisuper / abarrotes en inventario.
 * No se muestran en la tienda web de farmacia; la app de minisuper podrá usar otra lista o `linea_negocio` en BD.
 * Ajustá esta lista si agregás categorías de súper con otro nombre.
 */
export const CATEGORIAS_MINISUPER_EXCLUIDAS_TIENDA_FARMACIA = Object.freeze([
  "Bebidas",
  "Básicos",
]);

const SET_MINISUPER = new Set(CATEGORIAS_MINISUPER_EXCLUIDAS_TIENDA_FARMACIA);

/** True si el producto se considera línea minisuper y se oculta en la tienda farmacia. */
export function productoEsCategoriaMinisuperTienda(p) {
  const c = String(p?.categoria ?? "").trim();
  return SET_MINISUPER.has(c);
}

/** Misma regla que tienda web, pero sin artículos de categoría minisuper (hasta app dedicada). */
export function productoPermitidoEnTiendaFarmaciaWeb(p) {
  if (!productoPermitidoEnTiendaWeb(p)) return false;
  if (productoEsCategoriaMinisuperTienda(p)) return false;
  return true;
}

/** Mensaje para checkout / validación cuando un ítem no puede venderse en esta tienda. */
export function razonBloqueoProductoTiendaFarmacia(row) {
  if (productoEsCategoriaMinisuperTienda(row)) {
    return "Artículo de minisuper: no está en la tienda farmacia en línea por ahora. Disponible en sucursal.";
  }
  return "No disponible en tienda en línea (receta, controlado u oculto).";
}
