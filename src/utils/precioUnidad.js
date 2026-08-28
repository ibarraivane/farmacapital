/** Regla de precio por pieza suelta: margen mayor que caja + penalización vs paquete. */

import { recargoCategoriaEsHigiene } from "../constants/categoriasProducto";

export const PENALIZACION_CAJA = 1.12; // Σ piezas ≥ 12% sobre precio caja

function recargoPorCategoria(categoria = "", tipo = "") {
  const t = String(tipo || "").toLowerCase();
  if (normalizeCategoriaLegacyGeneral(categoria) || t === "generico") return 0.75;
  if (recargoCategoriaEsHigiene(categoria)) return 0.55;
  return 0.5;
}

function normalizeCategoriaLegacyGeneral(categoria) {
  return String(categoria || "").trim().toLowerCase() === "general";
}

/** Precio mínimo sugerido por pieza (entero hacia arriba). */
export function calcPrecioUnidad(precio, costo, unidadesPorCaja, categoria = "", tipo = "") {
  const u = parseInt(unidadesPorCaja, 10) || 0;
  if (u <= 0) return 0;
  const pv = parseFloat(precio) || 0;
  const co = parseFloat(costo) || 0;
  const cu = co / u;
  const rec = recargoPorCategoria(categoria, tipo);
  const porCosto = Math.ceil(cu * (1 + rec));
  const porUtil = Math.ceil(cu + (cu < 20 ? 5 : 8));
  const porPenalty = Math.ceil((pv * PENALIZACION_CAJA) / u);
  return Math.max(porCosto, porUtil, porPenalty);
}

/** Alias histórico. */
export function sugerirPrecioUnidad(precio, costo, unidadesPorCaja, categoria = "", tipo = "") {
  return calcPrecioUnidad(precio, costo, unidadesPorCaja, categoria, tipo);
}

/** Precio efectivo en POS: el que guardó el dueño. La regla solo sugiere. */
export function precioUnidadParaVenta(producto) {
  if (!producto?.venta_unidad) return 0;
  const guardado = Math.ceil(parseFloat(producto.precio_unidad) || 0);
  if (guardado > 0) return guardado;
  return calcPrecioUnidad(
    producto.precio,
    producto.costo,
    producto.unidades_por_caja,
    producto.categoria,
    producto.tipo,
  );
}

export function margenBrutoPct(precioVenta, costo) {
  const pv = parseFloat(precioVenta) || 0;
  const co = parseFloat(costo) || 0;
  if (pv <= 0) return 0;
  return Math.round(((pv - co) / pv) * 1000) / 10;
}

/** Aplica regla al guardar producto con venta_unidad. */
export function aplicarReglaPrecioUnidad(fields) {
  if (!fields?.venta_unidad) {
    return { ...fields, precio_unidad: 0, unidades_por_caja: 0 };
  }
  const upc = parseInt(fields.unidades_por_caja, 10) || 0;
  const manual = Math.ceil(parseFloat(fields.precio_unidad) || 0);
  const sugerido = calcPrecioUnidad(fields.precio, fields.costo, upc, fields.categoria, fields.tipo);
  return {
    ...fields,
    unidades_por_caja: upc,
    precio_unidad: manual > 0 ? manual : sugerido,
  };
}
