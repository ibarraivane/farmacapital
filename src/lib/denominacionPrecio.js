/** Mínima denominación del precio de venta en inventario: 0.5 centavos ($0.005). */
export const PASO_PRECIO_VENTA = 0.005;

const PASO_MILESIMAS = 5;

/**
 * Milésimas enteras (1 peso = 1000). Null si no es un número.
 * El texto se parte en dígitos para no arrastrar error de float.
 */
export function milesimasPrecio(valor) {
  if (valor == null || valor === "") return null;
  if (typeof valor === "number") {
    if (!Number.isFinite(valor)) return null;
    return Math.round(valor * 1000);
  }
  const s = String(valor).trim().replace(/\s/g, "").replace(",", ".");
  if (!s) return null;
  const m = /^([+-])?(\d+)(?:\.(\d*))?$/.exec(s);
  if (!m) return null;
  const sign = m[1] === "-" ? -1 : 1;
  const whole = Number(m[2]);
  if (!Number.isFinite(whole)) return null;
  const frac = m[3] || "";
  const head = (frac + "000").slice(0, 3);
  const tail = frac.slice(3);
  let mil = whole * 1000 + Number(head);
  if (tail[0] >= "5") mil += 1;
  return sign * mil;
}

function pesosDesdeMilesimas(mil) {
  const sign = mil < 0 ? "-" : "";
  const abs = Math.abs(mil);
  const whole = Math.floor(abs / 1000);
  const frac = String(abs % 1000).padStart(3, "0");
  return Number(`${sign}${whole}.${frac}`);
}

/**
 * Precio de venta al múltiplo de $0.005 más cercano, en milésimas enteras.
 * Residuo 0–2 de 5 milésimas baja; 3–4 sube. 10.002 → 10.000 · 10.003 → 10.005.
 * Vacío, inválido o negativo → null. Cero se queda en cero.
 */
export function snapPrecioVenta(valor) {
  const mil = milesimasPrecio(valor);
  if (mil == null || mil < 0) return null;
  if (mil === 0) return 0;
  const rem = mil % PASO_MILESIMAS;
  const snapped = rem <= 2 ? mil - rem : mil + (PASO_MILESIMAS - rem);
  return pesosDesdeMilesimas(snapped);
}

/**
 * Precio en inventario: 2 decimales, y 3 si el medio centavo no es cero.
 * 10 → $10.00 · 10.5 → $10.50 · 10.005 → $10.005.
 */
export function fmtPrecioInventario(n) {
  const mil = milesimasPrecio(n);
  if (mil == null) return "—";
  const sign = mil < 0 ? "-" : "";
  const abs = Math.abs(mil);
  const whole = Math.floor(abs / 1000);
  const frac = abs % 1000;
  if (frac % 10 === 0) {
    return `${sign}$${whole}.${String(frac / 10).padStart(2, "0")}`;
  }
  return `${sign}$${whole}.${String(frac).padStart(3, "0")}`;
}

/** Mismas cifras que fmtPrecioInventario, sin el signo de pesos. */
export function cifrasPrecioInventario(n) {
  const shown = fmtPrecioInventario(n);
  if (shown === "—") return "";
  return shown.replace("$", "");
}
