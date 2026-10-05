import { createContext, useContext } from "react";

/** URL de «Imagen próximamente» (configuracion.placeholder_producto_url). */
export const TiendaPlaceholderCtx = createContext("");

export function usePlaceholderProducto() {
  return useContext(TiendaPlaceholderCtx);
}
