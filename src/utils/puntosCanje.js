const STORAGE_KEY = "farmacapital_canje_activo";

export const CANJES_PUNTOS = [
  { pts: 20, tipo: "descuento", valor: 10, ben: "$10 descuento en FarmaCapital" },
  { pts: 50, tipo: "envio", valor: 0, ben: "Envío gratis" },
  { pts: 100, tipo: "descuento", valor: 50, ben: "$50 de descuento" },
  { pts: 160, tipo: "consulta", valor: 0, ben: "Consulta médica gratis" },
  { pts: 200, tipo: "producto", valor: 0, ben: "Producto gratis" },
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
