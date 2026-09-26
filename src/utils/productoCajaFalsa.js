/** Caja de catálogo que en el mostrador se vende suelta (pote, C/1, jeringa). */

import { precioUnidadParaVenta, productoVendeBlister } from "./precioUnidad";

function num(v) {
  const n = Number(v);
  return Number.isFinite(n) ? n : 0;
}

function textoFicha(p) {
  return `${p?.nombre || ""} ${p?.presentacion || ""} ${p?.forma_farmaceutica || ""}`.toLowerCase();
}

/** Frasco / pote: C/50 suele ser gramos, no 50 piezas. */
function esFrascoOPote(p) {
  const t = textoFicha(p);
  if (/\b(oxido|óxido|mercurio)\b/.test(t)) return true;
  if (/\b(frasco|pote|tarro)\b/.test(t)) return true;
  return false;
}

/** Presentación de una sola pieza (no un empaque C/N). */
function presentacionEsPieza(p) {
  const t = textoFicha(p);
  const pres = String(p?.presentacion || "").trim();
  if (/^pieza\b/i.test(pres)) return true;
  return /\b(c\/\s*1|1\s*pza|1\s*pieza|1\s*unidad)\b/i.test(t);
}

/**
 * True si el flag venta_unidad abre un botón Caja que no corresponde:
 * el precio de “caja” es casi el de una pieza (pote de 60, chupón, jeringa).
 * No toca cajas reales (Alka-Seltzer, Aspirina, Dolo C/3, Saba C/8).
 */
export function productoCajaEsFalsa(p) {
  if (!p?.venta_unidad) return false;
  const upc = num(p.unidades_por_caja);
  const caja = num(p.precio);
  const uni = num(p.precio_unidad);
  if (upc < 2 || uni <= 0 || caja <= 0) return false;
  if (esFrascoOPote(p)) return false;

  const ratio = caja / uni;
  if (upc <= 4 && ratio >= 2) return false;
  if (presentacionEsPieza(p) && ratio <= 1.6) return true;
  if (ratio <= 1.5 && upc >= 6) return true;
  return false;
}

export function stockMostradorPos(p, stockCajas) {
  if (productoCajaEsFalsa(p)) {
    const sueltas = num(p.stock_unidades);
    if (sueltas > 0) return sueltas;
  }
  return num(stockCajas);
}

/**
 * Agotado solo cuando no queda caja, blister ni pieza suelta.
 * Con la caja ya abierta, el letrero cuenta las piezas (no “0 en stock”).
 */
export function existenciaMostradorPos(p, stockCajas) {
  const cajas = Math.max(0, Math.floor(num(stockCajas)));
  const sueltas = Math.max(0, Math.floor(num(p?.stock_unidades)));
  const blisters = Math.max(0, Math.floor(num(p?.stock_blisters)));
  const vendeBlister = productoVendeBlister(p);

  if (productoCajaEsFalsa(p)) {
    const visible = Math.max(0, Math.floor(stockMostradorPos(p, cajas)));
    if (visible <= 0) return { agotado: true, etiqueta: "Agotado", texto: "Agotado" };
    return { agotado: false, etiqueta: `${visible} disp.`, texto: `${visible} en stock` };
  }

  const vendePieza = Boolean(p?.venta_unidad);
  const sinCajas = cajas <= 0;
  const sinPiezas = !vendePieza || sueltas <= 0;
  const sinBlisters = !vendeBlister || blisters <= 0;
  if (sinCajas && sinPiezas && sinBlisters) {
    return { agotado: true, etiqueta: "Agotado", texto: "Agotado" };
  }
  if (sinCajas && sueltas > 0) {
    return { agotado: false, etiqueta: `${sueltas} pzas`, texto: `${sueltas} piezas` };
  }
  if (sinCajas && blisters > 0) {
    return { agotado: false, etiqueta: `${blisters} blister`, texto: `${blisters} blister(s)` };
  }
  return { agotado: false, etiqueta: `${cajas} disp.`, texto: `${cajas} en stock` };
}

export function precioMostradorPos(p) {
  if (productoCajaEsFalsa(p)) {
    const uni = precioUnidadParaVenta(p);
    if (uni > 0) return uni;
  }
  return num(p?.precio);
}

/**
 * Caja cerrada de verdad (Amox C/12), no pote ni “caja” que en mostrador es una pieza.
 * Misma regla que sql/patch_venta_pieza_abre_caja_20260926.sql.
 */
export function puedeAbrirCajaParaPiezas(p) {
  if (!p?.venta_unidad) return false;
  if (productoVendeBlister(p)) return false; // la caja suelta blisters, no piezas
  const upc = Math.floor(num(p.unidades_por_caja));
  if (upc < 2) return false;
  if (esFrascoOPote(p)) return false;
  if (productoCajaEsFalsa(p)) return false;
  const caja = num(p.precio);
  const uni = num(p.precio_unidad);
  if (uni > 0 && caja > 0 && caja / uni < 1.8) return false;
  return true;
}

/** Piezas que se pueden vender: sueltas más lo que sale de abrir cajas cerradas. */
export function piezasSueltasDisponibles(p, stockCajas) {
  const sueltas = Math.max(0, Math.floor(num(p?.stock_unidades)));
  if (!puedeAbrirCajaParaPiezas(p)) return sueltas;
  const cajas = Math.max(0, Math.floor(num(stockCajas)));
  const upc = Math.max(2, Math.floor(num(p.unidades_por_caja)));
  return sueltas + cajas * upc;
}

/** Cuántas cajas hay que abrir para cubrir `piezasPedidas`. */
export function cajasAAbrirParaPiezas(p, stockCajas, piezasPedidas) {
  const sueltas = Math.max(0, Math.floor(num(p?.stock_unidades)));
  const pedidas = Math.max(0, Math.floor(num(piezasPedidas)));
  if (pedidas <= sueltas) return 0;
  if (!puedeAbrirCajaParaPiezas(p)) return 0;
  const upc = Math.max(2, Math.floor(num(p.unidades_por_caja)));
  const cajas = Math.max(0, Math.floor(num(stockCajas)));
  if (cajas <= 0) return 0;
  return Math.min(cajas, Math.ceil((pedidas - sueltas) / upc));
}

export function esErrorPiezasSueltas(msg) {
  const t = String(msg || "").toLowerCase();
  return t.includes("piezas sueltas") || t.includes("stock_unidades insuficiente");
}

export function productoIdEnErrorStock(msg) {
  const m = String(msg || "").match(/producto\s+(\d+)/i);
  return m ? m[1] : null;
}

/** Déficit que mandó la base. Null si el texto no lo trae. */
export function faltanPiezasEnError(msg) {
  const t = String(msg || "");
  const faltan = t.match(/faltan\s+(\d+)/i);
  if (faltan) return Number(faltan[1]);
  const stock = t.match(/stock\s+(\d+)/i);
  const sol = t.match(/solicitado\s+(\d+)/i);
  if (stock && sol) return Math.max(0, Number(sol[1]) - Number(stock[1]));
  return null;
}

/**
 * Tras el rechazo del cobro, cuántas cajas abrir de ese producto para reintentar.
 * El caso de la foto: Amox, faltan 2, caja de 12, hay 3 cajas → se abre 1.
 */
export function cajasAAbrirPorError(producto, cajasDisponibles, msg) {
  if (!puedeAbrirCajaParaPiezas(producto)) return 0;
  const cajas = Math.max(0, Math.floor(num(cajasDisponibles)));
  if (cajas <= 0) return 0;
  const faltan = faltanPiezasEnError(msg);
  if (faltan == null || faltan <= 0) return 1;
  const upc = Math.max(2, Math.floor(num(producto.unidades_por_caja)));
  return Math.min(cajas, Math.max(1, Math.ceil(faltan / upc)));
}
