/** Regla de precio por pieza suelta: margen mayor que caja + penalización vs paquete. */

import { recargoCategoriaEsHigiene } from "../constants/categoriasProducto";
import { margenSobreVentaPct } from "../lib/margenMarkup";

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

/**
 * Blisters enteros por caja. 0 si no parte la caja en al menos 2 tiras
 * de 2 piezas o más (30/10 → 3, 28/10 → 0, 10/10 → 0).
 */
export function blistersPorCaja(unidadesPorCaja, piezasPorBlister) {
  const upc = parseInt(unidadesPorCaja, 10) || 0;
  const ppb = parseInt(piezasPorBlister, 10) || 0;
  if (ppb < 2 || upc < 2 || upc % ppb !== 0) return 0;
  const n = upc / ppb;
  return n >= 2 ? n : 0;
}

/**
 * Tira por defecto para una caja que ya se vende por pieza.
 * 10 si salen 2 o más tiras; si no, 7; si no, la mitad cuando es par;
 * si no, la tira más grande que igual parte en 2 o más. 0 si no se puede (C/3, C/5, C/7).
 */
export function piezasPorBlisterDefault(unidadesPorCaja) {
  const upc = parseInt(unidadesPorCaja, 10) || 0;
  if (upc < 4) return 0;
  if (blistersPorCaja(upc, 10) >= 2) return 10;
  if (blistersPorCaja(upc, 7) >= 2) return 7;
  if (upc % 2 === 0 && blistersPorCaja(upc, upc / 2) >= 2) return upc / 2;
  for (let ppb = Math.floor(upc / 2); ppb >= 2; ppb -= 1) {
    if (blistersPorCaja(upc, ppb) >= 2) return ppb;
  }
  return 0;
}

/** Venta por blister solo dentro de la venta por pieza, y solo si la caja parte bien. */
export function productoVendeBlister(producto) {
  if (!producto?.venta_unidad) return false;
  return blistersPorCaja(producto.unidades_por_caja, producto.piezas_por_blister) >= 2;
}

/** Misma regla que la pieza, con divisor = blisters por caja (no piezas). */
export function calcPrecioBlister(precio, costo, unidadesPorCaja, piezasPorBlister, categoria = "", tipo = "") {
  const n = blistersPorCaja(unidadesPorCaja, piezasPorBlister);
  if (n < 2) return 0;
  return calcPrecioUnidad(precio, costo, n, categoria, tipo);
}

export function sugerirPrecioBlister(precio, costo, unidadesPorCaja, piezasPorBlister, categoria = "", tipo = "") {
  return calcPrecioBlister(precio, costo, unidadesPorCaja, piezasPorBlister, categoria, tipo);
}

/** Precio efectivo del blister: el guardado. La regla solo sugiere. */
export function precioBlisterParaVenta(producto) {
  if (!productoVendeBlister(producto)) return 0;
  const guardado = Math.ceil(parseFloat(producto.precio_blister) || 0);
  if (guardado > 0) return guardado;
  return calcPrecioBlister(
    producto.precio,
    producto.costo,
    producto.unidades_por_caja,
    producto.piezas_por_blister,
    producto.categoria,
    producto.tipo,
  );
}

/**
 * Qué suma abrir una caja. Con blister configurado, blisters; si no, piezas.
 * `unidades_por_caja` vacío cuenta como 1, igual que abrir_caja_lote.
 */
export function unidadesAlAbrirCaja(producto) {
  const n = blistersPorCaja(producto?.unidades_por_caja, producto?.piezas_por_blister);
  if (n >= 2) return { stock: "blisters", cantidad: n };
  const upc = parseInt(producto?.unidades_por_caja, 10);
  return { stock: "unidades", cantidad: Number.isFinite(upc) && upc > 0 ? upc : 1 };
}

/** modo_venta del renglón de carrito (caja, unidad o blister). */
export function modoVentaDeLinea(item) {
  if (item?.esBlister) return "blister";
  if (item?.esUnidad) return "unidad";
  return "caja";
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
  return margenSobreVentaPct(precioVenta, costo) ?? 0;
}

/** Aplica regla al guardar producto con venta_unidad. El blister es opcional. */
export function aplicarReglaPrecioUnidad(fields) {
  if (!fields?.venta_unidad) {
    return {
      ...fields,
      precio_unidad: 0,
      unidades_por_caja: 0,
      piezas_por_blister: 0,
      precio_blister: 0,
      stock_blisters: 0,
    };
  }
  const upc = parseInt(fields.unidades_por_caja, 10) || 0;
  const manual = Math.ceil(parseFloat(fields.precio_unidad) || 0);
  const sugerido = calcPrecioUnidad(fields.precio, fields.costo, upc, fields.categoria, fields.tipo);
  const ppb = parseInt(fields.piezas_por_blister, 10) || 0;
  const blisters = blistersPorCaja(upc, ppb);
  const manualBlister = Math.ceil(parseFloat(fields.precio_blister) || 0);
  const sugeridoBlister = blisters >= 2
    ? calcPrecioUnidad(fields.precio, fields.costo, blisters, fields.categoria, fields.tipo)
    : 0;
  return {
    ...fields,
    unidades_por_caja: upc,
    precio_unidad: manual > 0 ? manual : sugerido,
    piezas_por_blister: blisters >= 2 ? ppb : 0,
    precio_blister: blisters >= 2 ? (manualBlister > 0 ? manualBlister : sugeridoBlister) : 0,
    stock_blisters: blisters >= 2 ? (parseInt(fields.stock_blisters, 10) || 0) : 0,
  };
}
