/**
 * Auditoría de stock fantasma / discrepancias de anaquel.
 *
 * Caso 2-oct-2026: Bepanthen Protectora 30 g (FC-08427330) con 30232.
 * Movimientos Recibir Cityfarma S327411:
 *   entrada 3 (RX-…-5028) + entrada 30229 (RX-…-5029) = 30232.
 * En JS, si `productos.stock` llega como texto: "30" + 232 === "30232".
 * El gramaje de la ficha (30 g) se pegó a otro número; no son tubos reales.
 */

import { STOCK_ABSURDO_MAX, stockAbsurdoInventario, stockVisibleInventario } from "./inventarioHubData";

/** Suma piezas sin concatenar strings. "30" + 232 debe ser 262, no 30232. */
export function stockSumaPiezas(actual, adicional) {
  const a = Math.trunc(Number(actual));
  const b = Math.trunc(Number(adicional));
  const left = Number.isFinite(a) ? a : 0;
  const right = Number.isFinite(b) ? b : 0;
  return left + right;
}

/** Primer gramaje/volumen de la ficha: "30 G 5%" → "30". */
export function digitosGramajeFicha(...textos) {
  for (const raw of textos) {
    const m = String(raw || "").match(/(\d+(?:[.,]\d+)?)\s*(g|gr|gramos?|ml|mililitros?)\b/i);
    if (!m) continue;
    const n = parseInt(String(m[1]).replace(",", ""), 10);
    if (Number.isFinite(n) && n > 0) return String(n);
  }
  return null;
}

/**
 * El stock parece el gramaje pegado a otro entero.
 * 30232 + "30 G 5%" → { gramaje: 30, resto: 232 }.
 */
export function concatenacionGramaje(stock, ...textos) {
  const n = Math.trunc(Number(stock));
  if (!Number.isFinite(n) || n < 100) return null;
  const digits = digitosGramajeFicha(...textos);
  if (!digits) return null;
  const s = String(n);
  if (!s.startsWith(digits) || s.length <= digits.length) return null;
  const resto = parseInt(s.slice(digits.length), 10);
  if (!Number.isFinite(resto) || resto <= 0) return null;
  return { gramaje: Number(digits), resto };
}

/**
 * @returns {null | { tipo: string, piezas: number, detalle?: string }}
 */
export function clasificarStockSospechoso(p, stockOverride) {
  const piezas = stockOverride != null ? Number(stockOverride) : stockVisibleInventario(p);
  const n = Math.trunc(Number(piezas) || 0);
  if (n <= 0) return null;

  if (stockAbsurdoInventario(n)) {
    const concat = concatenacionGramaje(n, p?.presentacion, p?.nombre);
    return {
      tipo: concat ? "concat_gramaje" : "absurdo",
      piezas: n,
      detalle: concat
        ? `${concat.gramaje} (gramaje) + ${concat.resto} concatenados → ${n}`
        : `Más de ${STOCK_ABSURDO_MAX} piezas`,
    };
  }

  const concat = concatenacionGramaje(n, p?.presentacion, p?.nombre);
  if (concat) {
    return {
      tipo: "concat_gramaje",
      piezas: n,
      detalle: `${concat.gramaje} (gramaje) + ${concat.resto} concatenados → ${n}`,
    };
  }

  return null;
}

export function esStockSospechoso(p, stockOverride) {
  return clasificarStockSospechoso(p, stockOverride) != null;
}
