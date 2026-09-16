import { parseRpcJsonArray } from "./rpcJson";

/**
 * Pedidos creados desde la tienda en línea (checkout) que siguen pendientes de surtir.
 * Histórico: algunas filas no tenían `tipo`; se infiere por método de pago web.
 *
 * P0 (RLS): las lecturas pasan por RPC con sesión de empleado (`farmacapital_session_token`).
 */
export const METODOS_PAGO_TIENDA_WEB = ["tarjeta", "mercadopago"];

/** Pickup web confirmado, pendiente de cobro en tienda (terminal BBVA). */
export const METODO_PENDIENTE_TIENDA = "pendiente_tienda";
export const PAYMENT_STATUS_PENDING_STORE = "pending_store";

/** Pago confirmado para surtir en POS (alineado a fn_pedido_online_pago_confirmado en Supabase). */
export function pedidoOnlinePagoConfirmado(p) {
  if (!p) return false;
  const metodo = String(p.metodo_pago || "").toLowerCase().trim();
  const status = String(p.payment_status || "").toLowerCase().trim();
  const tipo = String(p.tipo || "").toLowerCase().trim();
  if (tipo && tipo !== "online") return true;
  // Pickup: puede surtirse / aparecer en cola sin MP approved
  if (metodo === METODO_PENDIENTE_TIENDA) return true;
  if (metodo === "mercadopago" || metodo === "tarjeta") return status === "approved";
  if (metodo === "efectivo") return true;
  if (status) return status === "approved";
  return false;
}

/** Pickup online aún no cobrado en mostrador. */
export function esPedidoPickupPendienteCobro(p) {
  if (!p) return false;
  const metodo = String(p.metodo_pago || "").toLowerCase().trim();
  const status = String(p.payment_status || "").toLowerCase().trim();
  const entrega = String(p.tipo_entrega || "").toLowerCase().trim();
  if (entrega && entrega !== "recoger") return false;
  if (metodo === METODO_PENDIENTE_TIENDA) return true;
  return status === PAYMENT_STATUS_PENDING_STORE;
}

/**
 * Etiqueta de pago para POS / Mis pedidos.
 * @returns {{ label: string, col: string, kind: 'pending_store'|'approved_bbva'|'approved_mp'|'pending_mp'|'other' }}
 */
export function etiquetaPagoPedidoOnline(p, colors = {}) {
  const accent = colors.accent || "#16a34a";
  const amber = colors.amber || "#d97706";
  const blue = colors.blue || "#1E3ABA";
  const muted = colors.muted || "#64748b";

  if (esPedidoPickupPendienteCobro(p)) {
    return { label: "Pendiente cobro en tienda", col: amber, kind: "pending_store" };
  }
  const status = String(p?.payment_status || "").toLowerCase().trim();
  const provider = String(p?.payment_provider || "").toLowerCase().trim();
  const metodo = String(p?.metodo_pago || "").toLowerCase().trim();

  if (status === "approved") {
    if (provider === "bbva" || metodo === "tarjeta") {
      return { label: "Pagado · BBVA", col: accent, kind: "approved_bbva" };
    }
    return { label: "Pagado · Mercado Pago", col: accent, kind: "approved_mp" };
  }
  if (String(p?.tipo_entrega || "").toLowerCase() === "envio" && status !== "approved") {
    const es = String(p?.logistics_meta?.envio?.estado || "").toLowerCase();
    if (es === "cotizado" || es === "link_enviado") {
      return { label: "Listo para pagar", col: blue, kind: "ready_to_pay" };
    }
    return { label: "Esperando cotización de envío", col: amber, kind: "pending_quote" };
  }
  if (metodo === "mercadopago" || ["pending", "in_process", "initiated"].includes(status)) {
    return { label: "Pago por confirmar", col: amber, kind: "pending_mp" };
  }
  if (status) return { label: `Pago ${status}`, col: muted, kind: "other" };
  return { label: "Sin pago online", col: muted, kind: "other" };
}

/** Pedido a domicilio aún sin pagar: el vendedor debe verlo para cotizar. */
export function esPedidoEnvioPorCotizar(p) {
  if (!p) return false;
  if (String(p.estado || "").toLowerCase() === "cancelado") return false;
  if (String(p.tipo_entrega || "").toLowerCase() !== "envio") return false;
  if (String(p.payment_status || "").toLowerCase() === "approved") return false;
  return String(p.estado || "").toLowerCase() === "pendiente";
}

export function envioListoParaLiquidar(p) {
  if (!esPedidoEnvioPorCotizar(p)) return false;
  const es = String(p?.logistics_meta?.envio?.estado || "").toLowerCase();
  return es === "cotizado" || es === "link_enviado";
}

export function esPedidoTiendaWebPendiente(p) {
  if (!p || p.estado !== "pendiente") return false;
  if (!pedidoOnlinePagoConfirmado(p)) return false;
  if (p.tipo === "online") return true;
  if (p.tipo != null && String(p.tipo).trim() !== "") return false;
  const m = String(p.metodo_pago || "");
  return m === "tarjeta" || m === "mercadopago" || m === METODO_PENDIENTE_TIENDA;
}

function sessionTokenEmpleado(explicit) {
  return (
    explicit ??
    (typeof sessionStorage !== "undefined" ? sessionStorage.getItem("farmacapital_session_token") : null)
  );
}

/** HEAD count exact para badges / KPIs (requiere sesión empleado). */
export async function countPedidosTiendaPendientesHead(supabase, sessionToken = null) {
  const tok = sessionTokenEmpleado(sessionToken);
  if (!tok) return { count: 0, error: null };
  const { data, error } = await supabase.rpc("empleado_contar_pedidos_tienda_web_pendientes", {
    p_session_token: tok,
  });
  if (error) return { count: 0, error };
  return { count: Number(data) || 0, error: null };
}

/**
 * Filas pendientes tienda web (dedupe server-side). Requiere sesión empleado.
 * @param {object} supabase
 * @param {string} [_selectSpecUnused] legacy PostgREST select (ignorado; el RPC fija columnas)
 * @param {object} opts — sessionToken opcional; perBranchLimit/maxRows → p_limit efectivo
 */
export async function fetchPedidosTiendaPendientesMerged(supabase, _selectSpecUnused, opts = {}) {
  const tok = sessionTokenEmpleado(opts.sessionToken);
  const maxRows = opts.maxRows ?? 250;
  if (!tok) return { data: [], error: null };
  const { data, error } = await supabase.rpc("empleado_listar_pedidos_tienda_web_pendientes", {
    p_session_token: tok,
    p_limit: maxRows,
  });
  if (error) return { data: [], error };
  let rows = parseRpcJsonArray(data);
  rows = rows.filter(esPedidoTiendaWebPendiente);
  rows.sort((a, b) => new Date(b.created_at || 0) - new Date(a.created_at || 0));
  return { data: rows, error: null };
}
