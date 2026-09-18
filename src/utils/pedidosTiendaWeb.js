import { parseRpcJsonArray } from "./rpcJson.js";

/**
 * Pedidos creados desde la tienda en línea (checkout) que siguen pendientes de surtir.
 * Histórico: algunas filas no tenían `tipo`; se infiere por método de pago web.
 *
 * P0 (RLS): las lecturas pasan por RPC con sesión de empleado (`farmacapital_session_token`).
 */
export const METODOS_PAGO_TIENDA_WEB = ["tarjeta", "mercadopago"];

/** Falta `pedidos.costo_envio` (SQL no corrido). No tumba el mostrador. */
export function esErrorColumnaCostoEnvio(err) {
  const m = String(err?.message || err || "");
  return /costo_envio/i.test(m) && /does not exist|no existe/i.test(m);
}

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

  const estado = String(p?.estado || "").toLowerCase().trim();
  const surtido = estado === "listo" || estado === "completado";
  const pagado = status === "approved" || Boolean(p?.paid_at);

  if (pagado) {
    if (provider === "bbva" || metodo === "tarjeta") {
      return { label: "Pagado · BBVA", col: accent, kind: "approved_bbva" };
    }
    return { label: "Pagado · Mercado Pago", col: accent, kind: "approved_mp" };
  }
  // Historial RPC viejo no manda payment_status: un surtido no es «pago por confirmar».
  if (surtido && !status && (metodo === "mercadopago" || metodo === "tarjeta")) {
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

/** Cola POS / dashboard: pagados por surtir + domicilio aún sin cobro (para cotizar). */
export function pedidoEnColaOnline(p) {
  return esPedidoTiendaWebPendiente(p) || esPedidoEnvioPorCotizar(p);
}

function sessionTokenEmpleado(explicit) {
  return (
    explicit ??
    (typeof sessionStorage !== "undefined" ? sessionStorage.getItem("farmacapital_session_token") : null)
  );
}

export function fusionarColaOnline(primario, extra) {
  const rows = Array.isArray(primario) ? primario.filter(pedidoEnColaOnline) : [];
  const seen = new Set(rows.map((r) => r?.id).filter((id) => id != null));
  for (const r of extra || []) {
    if (r?.id == null || seen.has(r.id) || !pedidoEnColaOnline(r)) continue;
    rows.push(r);
    seen.add(r.id);
  }
  rows.sort((a, b) => new Date(b.created_at || 0) - new Date(a.created_at || 0));
  return rows;
}

export function hidratarPagoDesdeTransacciones(histRows, txRows) {
  const byId = new Map((txRows || []).map((p) => [p.id, p]));
  return (histRows || []).map((r) => {
    const full = byId.get(r.id);
    if (!full) return r;
    return {
      ...r,
      payment_status: r.payment_status ?? full.payment_status ?? null,
      payment_provider: r.payment_provider ?? full.payment_provider ?? null,
      paid_at: r.paid_at ?? full.paid_at ?? null,
      metodo_pago: r.metodo_pago ?? full.metodo_pago,
      tipo_entrega: r.tipo_entrega ?? full.tipo_entrega,
      logistics_meta: r.logistics_meta ?? full.logistics_meta,
    };
  });
}

function rangoColaOnline(dias = 45) {
  return {
    p_created_desde: new Date(Date.now() - dias * 86400000).toISOString(),
    p_created_hasta: new Date().toISOString(),
  };
}

async function fetchPedidosTransaccionesCola(supabase, tok, opts = {}) {
  const rango = rangoColaOnline(opts.dias ?? 45);
  const { data, error } = await supabase.rpc("empleado_listar_pedidos_transacciones", {
    p_session_token: tok,
    ...rango,
    p_limite: opts.limite ?? 300,
  });
  if (error) return { data: [], error };
  return { data: parseRpcJsonArray(data), error: null };
}

/** HEAD count exact para badges / KPIs (requiere sesión empleado). */
export async function countPedidosTiendaPendientesHead(supabase, sessionToken = null) {
  const tok = sessionTokenEmpleado(sessionToken);
  if (!tok) return { count: 0, error: null };
  const { data, error } = await fetchPedidosTiendaPendientesMerged(supabase, null, {
    sessionToken: tok,
    maxRows: 300,
  });
  if (error && !(data && data.length)) return { count: 0, error };
  return { count: (data || []).length, error: null };
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
  const [colaRes, txRes] = await Promise.all([
    supabase.rpc("empleado_listar_pedidos_tienda_web_pendientes", {
      p_session_token: tok,
      p_limit: maxRows,
    }),
    fetchPedidosTransaccionesCola(supabase, tok, { limite: maxRows }),
  ]);
  const rows = fusionarColaOnline(parseRpcJsonArray(colaRes.data), txRes.data);
  const error = rows.length ? null : (colaRes.error || txRes.error || null);
  return { data: rows, error };
}

/** Cola + historial POS. Transacciones cubre domicilio sin pago si el RPC viejo lo omite. */
export async function fetchPedidosOnlineMostrador(supabase, sessionToken, opts = {}) {
  const tok = sessionTokenEmpleado(sessionToken);
  if (!tok) return { cola: [], hist: [], error: null, colaError: null, histError: null };
  const maxRows = opts.maxRows ?? 300;
  const [colaRes, histRes, txRes] = await Promise.all([
    supabase.rpc("empleado_listar_pedidos_tienda_web_pendientes", {
      p_session_token: tok,
      p_limit: maxRows,
    }),
    supabase.rpc("empleado_listar_pedidos_online_historial", {
      p_session_token: tok,
      p_limite: opts.histLimit ?? 20,
    }),
    fetchPedidosTransaccionesCola(supabase, tok, { limite: maxRows }),
  ]);
  const cola = fusionarColaOnline(parseRpcJsonArray(colaRes.data), txRes.data);
  const hist = hidratarPagoDesdeTransacciones(parseRpcJsonArray(histRes.data), txRes.data);
  const colaError = cola.length ? null : colaRes.error || null;
  return { cola, hist, error: colaError || histRes.error || null, colaError, histError: histRes.error || null };
}
