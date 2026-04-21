/**
 * Pedidos creados desde la tienda en línea (checkout) que siguen pendientes de surtir.
 * Histórico: algunas filas no tenían `tipo`; se infiere por método de pago web.
 */
export const METODOS_PAGO_TIENDA_WEB = ["tarjeta", "mercadopago"];

export function esPedidoTiendaWebPendiente(p) {
  if (!p || p.estado !== "pendiente") return false;
  if (p.tipo === "online") return true;
  if (p.tipo != null && String(p.tipo).trim() !== "") return false;
  const m = String(p.metodo_pago || "");
  return m === "tarjeta" || m === "mercadopago";
}

/**
 * Tres consultas simples en lugar de un .or(and(...)) que PostgREST a veces
 * rechaza con 400 (failed to parse logic tree).
 */
function queriesPendientesTiendaTriple(supabase, selectSpec, extra = {}) {
  const { order, limit } = extra;
  const base = () => {
    let q1 = supabase.from("pedidos").select(selectSpec).eq("estado", "pendiente").eq("tipo", "online");
    let q2 = supabase.from("pedidos").select(selectSpec).eq("estado", "pendiente").is("tipo", null).in("metodo_pago", METODOS_PAGO_TIENDA_WEB);
    let q3 = supabase.from("pedidos").select(selectSpec).eq("estado", "pendiente").eq("tipo", "").in("metodo_pago", METODOS_PAGO_TIENDA_WEB);
    if (order) {
      q1 = q1.order("created_at", order);
      q2 = q2.order("created_at", order);
      q3 = q3.order("created_at", order);
    }
    if (limit != null) {
      q1 = q1.limit(limit);
      q2 = q2.limit(limit);
      q3 = q3.limit(limit);
    }
    return [q1, q2, q3];
  };
  return base();
}

/** HEAD count exact para badges / KPIs. */
export async function countPedidosTiendaPendientesHead(supabase) {
  const qs = [
    supabase.from("pedidos").select("id", { count: "exact", head: true }).eq("estado", "pendiente").eq("tipo", "online"),
    supabase.from("pedidos").select("id", { count: "exact", head: true }).eq("estado", "pendiente").is("tipo", null).in("metodo_pago", METODOS_PAGO_TIENDA_WEB),
    supabase.from("pedidos").select("id", { count: "exact", head: true }).eq("estado", "pendiente").eq("tipo", "").in("metodo_pago", METODOS_PAGO_TIENDA_WEB),
  ];
  const results = await Promise.all(qs);
  let total = 0;
  let error = null;
  for (const r of results) {
    if (r.error) {
      error = error || r.error;
      continue;
    }
    total += r.count ?? 0;
  }
  return { count: total, error };
}

/**
 * Filas con el mismo criterio que esPedidoTiendaWebPendiente (dedupe por id).
 * @param {object} opts — perBranchLimit filas por rama antes de fusionar; maxRows tope final.
 */
export async function fetchPedidosTiendaPendientesMerged(supabase, selectSpec, opts = {}) {
  const perBranchLimit = opts.perBranchLimit ?? 120;
  const maxRows = opts.maxRows ?? 250;
  const qs = queriesPendientesTiendaTriple(supabase, selectSpec, {
    order: { ascending: false },
    limit: perBranchLimit,
  });
  const results = await Promise.all(qs);
  let error = null;
  const byId = new Map();
  for (const r of results) {
    if (r.error) {
      error = error || r.error;
      continue;
    }
    for (const row of r.data || []) byId.set(row.id, row);
  }
  let data = [...byId.values()].filter(esPedidoTiendaWebPendiente);
  data.sort((a, b) => new Date(b.created_at || 0) - new Date(a.created_at || 0));
  if (data.length > maxRows) data = data.slice(0, maxRows);
  return { data, error };
}
