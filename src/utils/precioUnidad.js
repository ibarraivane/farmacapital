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

/**
 * Stock de caja abierta: tiras enteras + el resto cortado.
 * 11 piezas con tira de 6 → 1 blister y 5 piezas. Una tira completa cuenta como blister.
 */
export function normalizarStockAbierto(stockBlisters, stockUnidades, piezasPorBlister) {
  const ppb = parseInt(piezasPorBlister, 10) || 0;
  const b = Math.max(0, parseInt(stockBlisters, 10) || 0);
  const u = Math.max(0, parseInt(stockUnidades, 10) || 0);
  if (ppb < 2) return { stock_blisters: b, stock_unidades: u, pool: u };
  const pool = b * ppb + u;
  return {
    stock_blisters: Math.floor(pool / ppb),
    stock_unidades: pool % ppb,
    pool,
  };
}

/** Pool de la caja abierta. Sin blister configurado, el pool son solo las piezas. */
export function poolAbierto(producto) {
  const ppb = parseInt(producto?.piezas_por_blister, 10) || 0;
  const vende = blistersPorCaja(producto?.unidades_por_caja, ppb) >= 2;
  return normalizarStockAbierto(
    producto?.stock_blisters,
    producto?.stock_unidades,
    vende ? ppb : 0,
  );
}

/** Piezas que ya ocupa el carrito entre sueltas y tiras. */
export function piezasComprometidas(qtyUnidad, qtyBlister, piezasPorBlister) {
  const u = Math.max(0, parseInt(qtyUnidad, 10) || 0);
  const b = Math.max(0, parseInt(qtyBlister, 10) || 0);
  const ppb = parseInt(piezasPorBlister, 10) || 0;
  if (ppb < 2) return u;
  return u + b * ppb;
}

/** Venta por blister solo dentro de la venta por pieza, y solo si la caja parte bien. */
export function productoVendeBlister(producto) {
  if (!producto?.venta_unidad) return false;
  return blistersPorCaja(producto.unidades_por_caja, producto.piezas_por_blister) >= 2;
}

/**
 * Precio del blister, peso entero: punto medio entre la fracción de la caja
 * y el tope (esas piezas sueltas, sin llegar al precio de la caja).
 * Por unidad queda más caro que la caja y más barato que la pieza.
 * La tira sale más cara que una pieza y más barata que la caja.
 */
export function precioBlisterIntermedio(precioCaja, precioUnidad, unidadesPorCaja, piezasPorBlister) {
  const n = blistersPorCaja(unidadesPorCaja, piezasPorBlister);
  if (n < 2) return 0;
  const caja = Number(precioCaja) || 0;
  const pieza = Number(precioUnidad) || 0;
  const upc = parseInt(unidadesPorCaja, 10) || 0;
  const ppb = parseInt(piezasPorBlister, 10) || 0;
  if (caja <= 0 || pieza <= 0 || upc <= 0) return 0;

  const prorrateo = (caja * ppb) / upc;
  const techo = Math.min(pieza * ppb, caja);
  let precio = Math.round((prorrateo + techo) / 2);
  let piso = Math.floor(prorrateo) + 1;
  if (ppb > 1) piso = Math.max(piso, Math.floor(pieza) + 1);
  let maximo = Math.min(Math.ceil(caja) - 1, Math.floor(pieza * ppb - 1e-9));
  if (piso > maximo) {
    piso = Math.floor(prorrateo) + 1;
    maximo = Math.ceil(caja) - 1;
    if (piso > maximo) return 0;
    return piso;
  }
  if (precio < piso) precio = piso;
  if (precio > maximo) precio = maximo;
  return precio;
}

/** Sugerido del blister a partir del precio de pieza que sí se cobra. */
export function calcPrecioBlister(precio, costo, unidadesPorCaja, piezasPorBlister, categoria = "", tipo = "", precioUnidad) {
  const n = blistersPorCaja(unidadesPorCaja, piezasPorBlister);
  if (n < 2) return 0;
  const pieza = Math.ceil(parseFloat(precioUnidad) || 0)
    || calcPrecioUnidad(precio, costo, unidadesPorCaja, categoria, tipo);
  return precioBlisterIntermedio(precio, pieza, unidadesPorCaja, piezasPorBlister);
}

export function sugerirPrecioBlister(precio, costo, unidadesPorCaja, piezasPorBlister, categoria = "", tipo = "", precioUnidad) {
  return calcPrecioBlister(precio, costo, unidadesPorCaja, piezasPorBlister, categoria, tipo, precioUnidad);
}

/** Precio efectivo del blister: el guardado. La regla solo sugiere. */
export function precioBlisterParaVenta(producto) {
  if (!productoVendeBlister(producto)) return 0;
  const guardado = Math.ceil(parseFloat(producto.precio_blister) || 0);
  if (guardado > 0) return guardado;
  return precioBlisterIntermedio(
    producto.precio,
    precioUnidadParaVenta(producto),
    producto.unidades_por_caja,
    producto.piezas_por_blister,
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
  const pieza = manual > 0 ? manual : sugerido;
  const sugeridoBlister = blisters >= 2
    ? precioBlisterIntermedio(fields.precio, pieza, upc, ppb)
    : 0;
  const abierto = normalizarStockAbierto(
    fields.stock_blisters,
    fields.stock_unidades,
    blisters >= 2 ? ppb : 0,
  );
  return {
    ...fields,
    unidades_por_caja: upc,
    precio_unidad: pieza,
    piezas_por_blister: blisters >= 2 ? ppb : 0,
    precio_blister: blisters >= 2 ? (manualBlister > 0 ? manualBlister : sugeridoBlister) : 0,
    stock_blisters: blisters >= 2 ? abierto.stock_blisters : 0,
    stock_unidades: blisters >= 2 ? abierto.stock_unidades : (parseInt(fields.stock_unidades, 10) || 0),
  };
}

/**
 * El precio que escribió el dueño gana. La regla solo llena el campo vacío.
 */
export function precioCapturadoOSugerido(capturado, sugerido) {
  const actual = Math.ceil(parseFloat(capturado) || 0);
  if (actual > 0) return actual;
  return Math.ceil(parseFloat(sugerido) || 0);
}

/**
 * Tras Guardar: el precio que quedó en la fila, si no es el que se envió.
 * null si no hay fila o si sí se guardó.
 */
export function precioBlisterQueNoQuedo(enviado, fila) {
  if (!enviado?.venta_unidad || !fila) return null;
  const esperado = Math.ceil(parseFloat(enviado.precio_blister) || 0);
  const quedo = Math.ceil(parseFloat(fila.precio_blister) || 0);
  return quedo === esperado ? null : quedo;
}
