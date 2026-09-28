/**
 * Vista del inventario de anaquel.
 *
 * Suplementos, dermatología y el resto de la vitrina (`bajo_pedido`) no están
 * en el medicamento que se vende hoy. En Inventario van apagados: no inflan
 * Activos ni la tabla. El interruptor los vuelve a mostrar. La tienda
 * «Te lo conseguimos» no usa esta vista.
 */
import { esBajoPedido } from "./bajoPedido";

export const STORAGE_MOSTRAR_VITRINA = "farmacapital_inv_mostrar_vitrina";

/** Apagados hasta que alguien prenda el interruptor en este navegador. */
export function leerMostrarVitrina(storage) {
  try {
    return storage?.getItem(STORAGE_MOSTRAR_VITRINA) === "1";
  } catch {
    return false;
  }
}

export function guardarMostrarVitrina(storage, on) {
  try {
    storage?.setItem(STORAGE_MOSTRAR_VITRINA, on ? "1" : "0");
  } catch {
    /* storage bloqueado */
  }
}

/**
 * true si el renglón entra a la tabla y a los conteos de Inventario.
 * El filtro «Bajo pedido» los pide a propósito, aunque el interruptor esté apagado.
 */
export function pasaVistaInventario(p, { mostrarVitrina = false, filtroAlerta = "todos" } = {}) {
  if (mostrarVitrina || filtroAlerta === "bajo_pedido") return true;
  return !esBajoPedido(p);
}
