/** Caja de catálogo que en el mostrador se vende suelta (pote, C/1, jeringa). */

import { precioUnidadParaVenta } from "./precioUnidad";

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

export function precioMostradorPos(p) {
  if (productoCajaEsFalsa(p)) {
    const uni = precioUnidadParaVenta(p);
    if (uni > 0) return uni;
  }
  return num(p?.precio);
}
