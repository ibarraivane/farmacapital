/**
 * Pedidos creados desde la tienda en línea (checkout) que siguen pendientes de surtir.
 * Histórico: algunas filas no tenían `tipo`; se infiere por método de pago web.
 *
 * P0 (RLS): las lecturas pasan por RPC con sesión de empleado (`farmacapital_session_token`).
 */
export const METODOS_PAGO_TIENDA_WEB = ["tarjeta", "mercadopago"];

export function esPedidoTiendaWebPendiente(p) {
  if (!p || p.estado !== "pendiente") return false;
  if (p.tipo === "online") return true;
  if (p.tipo != null && String(p.tipo).trim() !== "") return false;
  const m = String(p.metodo_pago || "");
  return m === "tarjeta" || m === "mercadopago";
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
  let rows = Array.isArray(data) ? data : [];
  rows = rows.filter(esPedidoTiendaWebPendiente);
  rows.sort((a, b) => new Date(b.created_at || 0) - new Date(a.created_at || 0));
  return { data: rows, error: null };
}
