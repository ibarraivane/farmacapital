/**
 * Lectura de `productos` con costo, solo para personal con sesión.
 *
 * La llave anon no debe poder hacer `select=costo` ni `select=*`.
 * Mientras el RPC no esté en la base, `via` queda en "ausente" y quien llama
 * sigue con la consulta directa de siempre.
 */

import { supabase } from "../supabase";

const STAFF_PAGE = 1000;

export function esRpcStaffAusente(error) {
  if (!error) return false;
  const msg = `${error.code || ""} ${error.message || ""} ${error.details || ""} ${error.hint || ""}`;
  return error.code === "PGRST202"
    || error.code === "42883"
    || /could not find the function/i.test(msg)
    || /function [\w.]+\s+does not exist/i.test(msg);
}

export function filasProductosStaff(data) {
  if (Array.isArray(data)) return data;
  if (data && typeof data === "object" && Array.isArray(data.productos)) return data.productos;
  if (typeof data === "string") {
    try {
      return filasProductosStaff(JSON.parse(data));
    } catch {
      return [];
    }
  }
  return [];
}

async function fetchRpcStaff({ sessionToken, soloActivos, desde }) {
  const filas = [];
  let offset = 0;
  for (;;) {
    const { data, error } = await supabase.rpc("empleado_listar_productos_staff", {
      p_session_token: sessionToken,
      p_solo_activos: !!soloActivos,
      p_desde: desde || null,
      p_offset: offset,
      p_limit: STAFF_PAGE,
    });
    if (error) {
      if (esRpcStaffAusente(error) && offset === 0) return { status: "ausente" };
      return { status: "error", error };
    }
    const page = filasProductosStaff(data);
    filas.push(...page);
    if (page.length < STAFF_PAGE) return { status: "ok", data: filas };
    offset += STAFF_PAGE;
  }
}

/**
 * Productos con costo para inventario, recibir, reabasto y referencias.
 * Con sesión usa el RPC (sobrevive al revoke de `costo`).
 * Si el RPC todavía no existe, corre `fallbackQuery`.
 */
export async function fetchProductosConCosto({
  sessionToken,
  soloActivos = false,
  desde = null,
  fallbackQuery,
} = {}) {
  if (sessionToken) {
    const rpc = await fetchRpcStaff({ sessionToken, soloActivos, desde });
    if (rpc.status === "ok") return { data: rpc.data, error: null, via: "rpc" };
    if (rpc.status === "error") return { data: null, error: rpc.error, via: "rpc" };
  }
  if (typeof fallbackQuery !== "function") {
    return { data: null, error: new Error("sin sesion de empleado"), via: "tabla" };
  }
  const fb = await fallbackQuery();
  return { data: fb?.data ?? null, error: fb?.error ?? null, via: "tabla" };
}
