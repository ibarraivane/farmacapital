const STORAGE_KEY = "farmacapital_canje_activo";

/**
 * Puntos FarmaCapital — escala estilo Monedero del Ahorro:
 * - 1 punto = $1 de descuento (dinero electrónico).
 * - Se gana 1 punto por cada $100 de compra (1% efectivo).
 * Antes: 1 pt / $10 y canje a $0.10 (mismo 1%, otra escala).
 */
export const PESOS_POR_PUNTO = 1;
export const PESOS_PARA_UN_PUNTO = 100;

/** Puntos que otorga una compra por el monto pagado (floor, sin fracciones). */
export function puntosGanados(monto) {
  const n = Number(monto);
  if (!Number.isFinite(n) || n <= 0) return 0;
  return Math.floor(n / PESOS_PARA_UN_PUNTO);
}

export function pesosDePuntos(pts) {
  const n = Number(pts);
  if (!Number.isFinite(n) || n <= 0) return 0;
  return Math.floor(n * PESOS_POR_PUNTO);
}

export const CANJES_PUNTOS = [
  { pts: 10, tipo: "descuento", valor: 10, ben: "$10 descuento en FarmaCapital" },
  { pts: 25, tipo: "envio", valor: 0, ben: "Envío gratis" },
  { pts: 50, tipo: "descuento", valor: 50, ben: "$50 de descuento" },
  { pts: 80, tipo: "consulta", valor: 0, ben: "Consulta médica gratis" },
  { pts: 100, tipo: "producto", valor: 0, ben: "Producto gratis" },
];

export function canjePorPuntos(pts) {
  return CANJES_PUNTOS.find((c) => c.pts === Number(pts)) || null;
}

export function leerCanjeActivo() {
  try {
    const raw = sessionStorage.getItem(STORAGE_KEY);
    if (!raw) return null;
    const parsed = JSON.parse(raw);
    if (!parsed || !canjePorPuntos(parsed.pts)) return null;
    return parsed;
  } catch {
    return null;
  }
}

export function guardarCanjeActivo(canje) {
  try {
    if (!canje) {
      sessionStorage.removeItem(STORAGE_KEY);
      return;
    }
    sessionStorage.setItem(STORAGE_KEY, JSON.stringify({
      ...canje,
      codigo: canje.codigo || `FC-${canje.pts}-${Date.now().toString(36).toUpperCase()}`,
      at: Date.now(),
    }));
  } catch (_) { /* noop */ }
}

export function limpiarCanjeActivo() {
  guardarCanjeActivo(null);
}
