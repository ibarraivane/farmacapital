/** Regla de precio por pieza suelta: margen mayor que caja + penalización vs paquete. */

import { recargoCategoriaEsHigiene } from "../constants/categoriasProducto";
import { snapPrecioVenta } from "../lib/denominacionPrecio";
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

/** Piezas de cada blister a partir de cuántos blisters trae la caja. 0 si no parte entero. */
export function piezasDesdeBlistersPorCaja(unidadesPorCaja, blisters) {
  const upc = parseInt(unidadesPorCaja, 10) || 0;
  const n = parseInt(blisters, 10) || 0;
  if (n < 2 || upc < 4 || upc % n !== 0) return 0;
  const ppb = upc / n;
  return ppb >= 2 ? ppb : 0;
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

/**
 * Caja mixta: trae dos tamaños (parches Alfa Med, 5 grandes y 5 chicos).
 * El renglón de “blister” guarda el chico; no es una tira de tabletas.
 */
export function esCajaDosTamanos(producto) {
  if (producto?.venta_dos_tamanos === true) return true;
  const texto = `${producto?.nombre || ""} ${producto?.presentacion || ""}`;
  return /\b(2|dos)\s*tamañ/i.test(texto);
}

/** Venta por blister solo dentro de la venta por pieza, y solo si la caja parte bien. */
export function productoVendeBlister(producto) {
  if (!producto?.venta_unidad || esCajaDosTamanos(producto)) return false;
  return blistersPorCaja(producto.unidades_por_caja, producto.piezas_por_blister) >= 2;
}

/** El chico se vende suelto. `piezas_por_blister` es cuántos chicos trae la caja. */
export function productoVendeTamanoChico(producto) {
  if (!producto?.venta_unidad || !esCajaDosTamanos(producto)) return false;
  return (parseInt(producto.piezas_por_blister, 10) || 0) >= 1;
}

/** Sufijo del renglón en el mostrador: grande/chico o unidad/blister. */
export function sufijoVentaSuelta(producto, modo) {
  const dos = esCajaDosTamanos(producto);
  if (modo === "blister") return dos ? "chico" : "blister";
  if (modo === "unidad" || modo === true) return dos ? "grande" : "unidad";
  return "caja";
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

/** Precio efectivo del blister o del tamaño chico: el guardado. La regla solo sugiere. */
export function precioBlisterParaVenta(producto) {
  const guardado = Math.ceil(parseFloat(producto?.precio_blister) || 0);
  if (productoVendeTamanoChico(producto)) {
    if (guardado > 0) return guardado;
    const chicos = parseInt(producto.piezas_por_blister, 10) || 0;
    if (chicos < 1) return 0;
    return calcPrecioUnidad(
      producto.precio,
      producto.costo,
      chicos,
      producto.categoria,
      producto.tipo,
    );
  }
  if (!productoVendeBlister(producto)) return 0;
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
  if (esCajaDosTamanos(producto)) {
    const grandes = parseInt(producto?.unidades_por_caja, 10) || 0;
    const chicos = parseInt(producto?.piezas_por_blister, 10) || 0;
    if (grandes >= 1 && chicos >= 1) {
      return { stock: "ambos", cantidad: grandes, grandes, chicos };
    }
  }
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

/**
 * Precio manual de pieza en pasos de $0.50. 0 si viene vacío, cero o negativo.
 * $1.50 se queda. $1.20 → $1.00. $1.30 → $1.50.
 */
export function precioUnidadManual(valor) {
  const snapped = snapPrecioVenta(valor);
  if (snapped == null || snapped <= 0) return 0;
  return snapped;
}

/** Precio efectivo en POS: el que guardó el dueño, en $0.50. La regla solo sugiere. */
export function precioUnidadParaVenta(producto) {
  if (!producto?.venta_unidad) return 0;
  const guardado = precioUnidadManual(producto.precio_unidad);
  if (guardado > 0) return guardado;
  return calcPrecioUnidad(
    producto.precio,
    producto.costo,
    producto.unidades_por_caja,
    producto.categoria,
    producto.tipo,
  );
}

/** Importe de piezas sueltas: unitario en $0.50 × cantidad. No redondea a peso entero. */
export function cobroUnidad(precio, qty = 1) {
  const unit = precioUnidadManual(precio);
  const q = parseInt(qty, 10) || 0;
  if (unit <= 0 || q <= 0) return 0;
  return (Math.round(unit * 100) * q) / 100;
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
  const manual = precioUnidadManual(fields.precio_unidad);
  const sugerido = calcPrecioUnidad(fields.precio, fields.costo, upc, fields.categoria, fields.tipo);
  const ppb = parseInt(fields.piezas_por_blister, 10) || 0;
  const manualBlister = Math.ceil(parseFloat(fields.precio_blister) || 0);
  if (esCajaDosTamanos(fields)) {
    const chicos = ppb >= 1 ? ppb : 0;
    const sugeridoChico = chicos >= 1
      ? calcPrecioUnidad(fields.precio, fields.costo, chicos, fields.categoria, fields.tipo)
      : 0;
    return {
      ...fields,
      unidades_por_caja: upc,
      precio_unidad: manual > 0 ? manual : sugerido,
      piezas_por_blister: chicos,
      precio_blister: chicos >= 1 ? (manualBlister > 0 ? manualBlister : sugeridoChico) : 0,
      stock_blisters: chicos >= 1 ? (parseInt(fields.stock_blisters, 10) || 0) : 0,
    };
  }
  const blisters = blistersPorCaja(upc, ppb);
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
