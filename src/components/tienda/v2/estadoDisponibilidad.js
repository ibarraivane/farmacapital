import { esCategoriaAntibiotico } from "../../../constants/categoriasProducto";
import { esBajoPedido } from "../../../lib/bajoPedido";

export const ESTADOS_DISPONIBILIDAD = Object.freeze({
  SUCURSAL: "sucursal",
  ENCARGO: "encargo",
});

export function stockEfectivoProducto(prod) {
  const n = Number(prod?.stock);
  return Number.isFinite(n) ? n : 0;
}

/** Antibiótico con receta: la política actual no permite envío. */
export function productoSoloRecoger(prod) {
  return Boolean(prod?.requiere_receta) && esCategoriaAntibiotico(prod?.categoria);
}

/**
 * Estado de la tarjeta ChatGPT: sucursal (verde) o por encargo (azul).
 * Si no hay existencia ni encargo, no se pinta el renglón (el precio puede decir Consultar).
 */
export function clasificarDisponibilidad(prod) {
  if (prod == null) return null;
  if (esBajoPedido(prod)) {
    return {
      estado: ESTADOS_DISPONIBILIDAD.ENCARGO,
      label: "Por encargo",
      inStock: false,
    };
  }
  if (stockEfectivoProducto(prod) > 0) {
    return {
      estado: ESTADOS_DISPONIBILIDAD.SUCURSAL,
      label: productoSoloRecoger(prod)
        ? "Disponible en sucursal · Solo recoger"
        : "Disponible en sucursal",
      inStock: true,
    };
  }
  return null;
}
