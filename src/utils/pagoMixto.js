/**
 * Desglose de pago mixto (efectivo + tarjeta) sobre el monto por cobrar.
 * Ambos tramos deben ser > 0 y sumar exactamente aCobrar.
 */

export function parseMontoPago(s) {
  const x = String(s ?? "").replace(/,/g, "").trim().replace(/^\$/, "");
  const n = parseFloat(x);
  return Number.isFinite(n) ? Math.round(n * 100) / 100 : NaN;
}

/**
 * @param {number} aCobrar monto pendiente tras crédito
 * @param {string|number} montoEfectivoStr parte en efectivo
 * @returns {{ ok: true, efectivo: number, tarjeta: number } | { ok: false, reason: string }}
 */
export function desgloseMixto(aCobrar, montoEfectivoStr) {
  const total = Math.round(Number(aCobrar) * 100) / 100;
  if (!Number.isFinite(total) || total <= 0) {
    return { ok: false, reason: "sin_cobro" };
  }
  const ef = parseMontoPago(montoEfectivoStr);
  if (!Number.isFinite(ef)) {
    return { ok: false, reason: "efectivo_invalido" };
  }
  if (ef <= 0) {
    return { ok: false, reason: "efectivo_cero" };
  }
  if (ef >= total) {
    return { ok: false, reason: "todo_efectivo" };
  }
  const tarjeta = Math.round((total - ef) * 100) / 100;
  if (tarjeta <= 0) {
    return { ok: false, reason: "tarjeta_cero" };
  }
  if (Math.round((ef + tarjeta) * 100) / 100 !== total) {
    return { ok: false, reason: "no_cuadra" };
  }
  return { ok: true, efectivo: ef, tarjeta };
}

export function mensajeErrorMixto(reason, aCobrar, $ = (n) => `$${Number(n).toFixed(2)}`) {
  switch (reason) {
    case "efectivo_invalido":
    case "efectivo_cero":
      return "Indica cuánto de la cuenta va en efectivo (mayor a cero).";
    case "todo_efectivo":
      return `Si todo es efectivo (${$(aCobrar)}), usa el método Efectivo.`;
    case "tarjeta_cero":
      return "La parte en tarjeta debe ser mayor a cero.";
    case "no_cuadra":
      return "Efectivo + tarjeta no cuadran con el total por cobrar.";
    default:
      return "Revisa los montos del pago mixto.";
  }
}
