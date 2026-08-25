/**
 * Cómo identificar la venta a devolver:
 *  - Folio del ticket: VTA-00000123 o #FC-0123
 *  - ID numérico corto del pedido
 *  - Teléfono MX (10 dígitos; con o sin 52)
 */

export function parseBusquedaDevolucion(raw) {
  const q = String(raw || "").trim();
  if (!q) return { tipo: "vacio", q: "" };

  const folio = q.match(/^(?:VTA-|#?FC-)(\d+)$/i);
  if (folio) {
    const id = Number(folio[1]);
    return Number.isFinite(id) && id > 0 ? { tipo: "id", id, q } : { tipo: "texto", q };
  }

  const digits = q.replace(/\D/g, "");
  if (digits.length >= 10) {
    return { tipo: "tel", tel10: digits.slice(-10), q };
  }
  if (/^\d{1,8}$/.test(q)) {
    const id = Number(q);
    return Number.isFinite(id) && id > 0 ? { tipo: "id", id, q } : { tipo: "texto", q };
  }
  return { tipo: "texto", q };
}

/** Texto que se manda al RPC (folio → id; el teléfono se manda completo). */
export function queryRpcDevolucion(raw) {
  const parsed = parseBusquedaDevolucion(raw);
  if (parsed.tipo === "id") return String(parsed.id);
  return parsed.q;
}
