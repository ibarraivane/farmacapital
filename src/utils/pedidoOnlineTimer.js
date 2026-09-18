/** Tiempo en cola / hasta envío para pedidos online del POS. */

export function formatDuracionCorta(ms) {
  const n = Math.max(0, Number(ms) || 0);
  const s = Math.floor(n / 1000);
  const d = Math.floor(s / 86400);
  const h = Math.floor((s % 86400) / 3600);
  const m = Math.floor((s % 3600) / 60);
  if (d > 0) return `${d}d ${h}h`;
  if (h > 0) return `${h}h ${m}m`;
  return `${Math.max(1, m)} min`;
}

function ts(value) {
  const t = Date.parse(value);
  return Number.isFinite(t) ? t : null;
}

export function pedidoOnlineYaEnviado(p) {
  const delivery = String(p?.delivery_status || "").toLowerCase();
  const envio = p?.logistics_meta?.envio && typeof p.logistics_meta.envio === "object"
    ? p.logistics_meta.envio
    : {};
  const envioEstado = String(envio.estado || "").toLowerCase();
  if (["in_route", "picked_up", "delivered"].includes(delivery)) return true;
  if (envioEstado === "en_ruta") return true;
  const entrega = String(p?.tipo_entrega || "").toLowerCase();
  const estado = String(p?.estado || "").toLowerCase();
  if (entrega === "recoger" && (estado === "listo" || estado === "completado")) return true;
  return false;
}

export function cronometroPedidoOnline(p, now = Date.now()) {
  const start = ts(p?.created_at);
  if (start == null) {
    return { ms: 0, label: "—", running: false, tone: "ok", enviado: false };
  }
  const envio = p?.logistics_meta?.envio && typeof p.logistics_meta.envio === "object"
    ? p.logistics_meta.envio
    : {};
  const enviado = pedidoOnlineYaEnviado(p);
  const end = enviado
    ? (ts(envio.en_ruta_at) || ts(envio.despachado_at) || ts(p?.atendido_at) || now)
    : now;
  const ms = Math.max(0, end - start);
  let tone = "ok";
  if (!enviado && ms > 4 * 3600000) tone = "late";
  else if (!enviado && ms > 60 * 60000) tone = "warn";
  return {
    ms,
    label: enviado ? `Enviado en ${formatDuracionCorta(ms)}` : `${formatDuracionCorta(ms)} en espera`,
    running: !enviado,
    tone,
    enviado,
  };
}
