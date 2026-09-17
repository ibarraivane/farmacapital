/**
 * Recargo (markup) vs margen bruto.
 *
 * “Aumentar 30%” se calcula sobre el costo.
 * “Margen 30%” se calcula sobre el precio de venta.
 *
 * $100 → $130: recargo 30%, margen 23.1%.
 * Margen real 30%: $100 ÷ 0.70 = $142.86.
 */

export function numPrecio(v) {
  const n = parseFloat(v);
  return Number.isFinite(n) ? n : null;
}

/** (precio − costo) / costo × 100. “Le agregaste 30% al costo.” */
export function markupSobreCostoPct(precio, costo) {
  const p = numPrecio(precio);
  const c = numPrecio(costo);
  if (p == null || c == null || p <= 0 || c <= 0) return null;
  return Math.round(((p - c) / c) * 1000) / 10;
}

/** (precio − costo) / precio × 100. Margen real sobre lo cobrado. */
export function margenSobreVentaPct(precio, costo) {
  const p = numPrecio(precio);
  const c = numPrecio(costo);
  if (p == null || c == null || p <= 0 || c <= 0) return null;
  return Math.round(((p - c) / p) * 1000) / 10;
}

export function precioDesdeMarkup(costo, markupPct, { ceil = false } = {}) {
  const c = numPrecio(costo);
  const m = numPrecio(markupPct);
  if (c == null || c <= 0 || m == null || m < 0) return null;
  const raw = c * (1 + m / 100);
  return ceil ? Math.ceil(raw) : raw;
}

export function precioDesdeMargenBruto(costo, margenPct, { ceil = false } = {}) {
  const c = numPrecio(costo);
  const m = numPrecio(margenPct);
  if (c == null || c <= 0 || m == null || m < 0 || m >= 100) return null;
  const raw = c / (1 - m / 100);
  return ceil ? Math.ceil(raw) : raw;
}

/** +30% al costo → 23.1% de margen. */
export function margenPctDesdeMarkupPct(markupPct) {
  const m = numPrecio(markupPct);
  if (m == null || m < 0) return null;
  return Math.round((m / (100 + m)) * 1000) / 10;
}

/** Margen 30% → hay que agregar 42.9% al costo. */
export function markupPctDesdeMargenPct(margenPct) {
  const m = numPrecio(margenPct);
  if (m == null || m < 0 || m >= 100) return null;
  return Math.round((m / (100 - m)) * 1000) / 10;
}

export function resumenRecargoYMargen(precio, costo) {
  const recargoPct = markupSobreCostoPct(precio, costo);
  const margenPct = margenSobreVentaPct(precio, costo);
  return {
    recargoPct,
    margenPct,
    recargoLabel: recargoPct == null ? "—" : `${recargoPct.toFixed(1)}%`,
    margenLabel: margenPct == null ? "—" : `${margenPct.toFixed(1)}%`,
  };
}

/**
 * Texto de ayuda para ficha / alta.
 * Sin costo usa $250, el ejemplo de mostrador.
 */
export function ayudaRecargoVsMargen(costo) {
  const parsed = numPrecio(costo);
  const base = parsed != null && parsed > 0 ? parsed : 250;
  const genericoPrecio = precioDesdeMarkup(base, 60, { ceil: true });
  const patentePrecio = precioDesdeMarkup(base, 25, { ceil: true });
  const margen30Precio = precioDesdeMargenBruto(base, 30, { ceil: true });
  return {
    costo: base,
    usoEjemplo: parsed == null || parsed <= 0,
    genericoPrecio,
    patentePrecio,
    margen30Precio,
    genericoMargenPct: margenSobreVentaPct(genericoPrecio, base),
    patenteMargenPct: margenSobreVentaPct(patentePrecio, base),
    recargo30Precio: precioDesdeMarkup(base, 30, { ceil: true }),
    recargo30MargenPct: margenPctDesdeMarkupPct(30),
  };
}
