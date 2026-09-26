const STORAGE_KEY = "farmacapital_canje_activo";

/** 1 punto por cada $10 de compra. El canje vale $0.10 por punto (1%), no $0.50. */
export const PESOS_POR_PUNTO = 0.1;

export function pesosDePuntos(pts) {
  const n = Number(pts);
  if (!Number.isFinite(n) || n <= 0) return 0;
  return Math.floor(n * PESOS_POR_PUNTO);
}

export const CANJES_PUNTOS = [
  { pts: 100, tipo: "descuento", valor: 10, ben: "$10 descuento en FarmaCapital" },
  { pts: 250, tipo: "envio", valor: 0, ben: "Envío gratis" },
  { pts: 500, tipo: "descuento", valor: 50, ben: "$50 de descuento" },
  { pts: 800, tipo: "consulta", valor: 0, ben: "Consulta médica gratis" },
  { pts: 1000, tipo: "producto", valor: 0, ben: "Producto gratis" },
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
