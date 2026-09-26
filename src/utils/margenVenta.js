/** Costo de una línea de venta: caja, blister o pieza suelta. */

import { blistersPorCaja } from "./precioUnidad";

function num(v, fallback = 0) {
  const n = parseFloat(v);
  return Number.isFinite(n) ? n : fallback;
}

function int(v, fallback = 1) {
  const n = parseInt(v, 10);
  return Number.isFinite(n) ? n : fallback;
}

/**
 * True si el renglón se cobró como blister (tira), no como caja ni pieza.
 * Usa modo_venta si viene; si no, compara el precio cobrado con precio_blister.
 */
export function lineaEsVentaBlister(item) {
  const modo = String(item?.modo_venta || item?.productos?.modo_venta || "").toLowerCase();
  if (modo === "blister") return true;
  if (modo === "unidad" || modo === "caja") return false;

  const prod = item?.productos || {};
  const blisters = blistersPorCaja(prod.unidades_por_caja, prod.piezas_por_blister);
  if (blisters < 2) return false;
  const cobrado = num(item?.precio_unitario);
  const precioBlister = num(prod.precio_blister);
  if (cobrado <= 0 || precioBlister <= 0) return false;
  return Math.abs(cobrado - precioBlister) <= 1;
}

/**
 * True si el renglón se cobró como pieza, no como caja ni blister.
 * Usa modo_venta si viene del RPC; si no, compara precio cobrado vs caja/unidad.
 */
export function lineaEsVentaUnidad(item) {
  if (lineaEsVentaBlister(item)) return false;
  const modo = String(item?.modo_venta || item?.productos?.modo_venta || "").toLowerCase();
  if (modo === "unidad") return true;
  if (modo === "caja" || modo === "blister") return false;

  const prod = item?.productos || {};
  if (!prod.venta_unidad) return false;
  const upc = int(prod.unidades_por_caja, 0);
  if (upc <= 1) return false;

  const cobrado = num(item?.precio_unitario);
  const precioCaja = num(prod.precio);
  const precioUnidad = num(prod.precio_unidad);
  if (cobrado <= 0) return false;
  if (precioUnidad > 0 && Math.abs(cobrado - precioUnidad) <= 1) return true;
  if (precioCaja > 0 && cobrado < precioCaja * 0.45) return true;
  return false;
}

/** Costo unitario (por renglón) ya ajustado a caja, blister o pieza. */
export function costoUnitarioLinea(item) {
  const prod = item?.productos || {};
  const costoCaja = num(prod.costo);
  if (lineaEsVentaBlister(item) && costoCaja > 0) {
    const blisters = blistersPorCaja(prod.unidades_por_caja, prod.piezas_por_blister);
    if (blisters >= 2) return costoCaja / blisters;
  }
  const upc = int(prod.unidades_por_caja, 0);
  if (lineaEsVentaUnidad(item) && upc > 1 && costoCaja > 0) {
    return costoCaja / upc;
  }
  return costoCaja;
}

export function costoLineaVenta(item) {
  return costoUnitarioLinea(item) * int(item?.cantidad, 1);
}

export function ingresoLineaVenta(item) {
  return num(item?.precio_unitario) * int(item?.cantidad, 1);
}
