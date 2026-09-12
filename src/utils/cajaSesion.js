import { supabase } from "../supabase";
import { denominacionesLimpias } from "../constants/caja";
import { getSessionToken, esErrorSesionEmpleado } from "../utils";
import { parseRpcJsonObject } from "./rpcJson";

function resultadoAuth(errorMsg) {
  const msg = errorMsg || "Sesión expirada.";
  return { sesion: null, error: msg, auth: esErrorSesionEmpleado(msg) || msg === "Sesión expirada." };
}

export async function fetchSesionCajaAbierta() {
  const tok = getSessionToken();
  if (!tok) return resultadoAuth("Sesión expirada.");
  const { data, error } = await supabase.rpc("empleado_sesion_caja_abierta", {
    p_session_token: tok,
  });
  if (error) {
    const msg = error.message || "No se pudo verificar la caja.";
    return { sesion: null, error: msg, auth: esErrorSesionEmpleado(msg) };
  }
  // jsonb a veces llega como string: sin parse, .abierta falla y Mi Día
  // cae al turno del perfil (vespertino) y deja fuera las ventas de la mañana.
  const sesion = parseRpcJsonObject(data);
  if (!sesion.abierta) return { sesion: null, error: null, auth: false };
  return { sesion, error: null, auth: false };
}

export async function abrirSesionCaja({ denoms, nota }) {
  const tok = getSessionToken();
  if (!tok) return resultadoAuth("Sesión expirada.");
  const { data, error } = await supabase.rpc("abrir_sesion_caja", {
    p_session_token: tok,
    p_denominaciones: denominacionesLimpias(denoms),
    p_nota: (nota || "").trim() || null,
  });
  if (error) {
    const msg = error.message || "No se pudo abrir caja.";
    return { sesion: null, error: msg, auth: esErrorSesionEmpleado(msg) };
  }
  const out = parseRpcJsonObject(data);
  if (out.success === false) return { sesion: null, error: out.error || "No se pudo abrir caja.", auth: false };
  return { sesion: out, error: null, auth: false };
}

export function esVendedor(usuario) {
  return usuario?.rol === "vendedor";
}

export async function fetchJornadaHoy() {
  const tok = getSessionToken();
  if (!tok) return { jornada: null, error: "Sesión expirada.", auth: true };
  const { data, error } = await supabase.rpc("empleado_jornada_hoy", {
    p_session_token: tok,
  });
  if (error) {
    const msg = error.message || "No se pudo cargar la jornada.";
    return { jornada: null, error: msg, auth: esErrorSesionEmpleado(msg) };
  }
  const jornada = parseRpcJsonObject(data);
  return { jornada: Object.keys(jornada).length ? jornada : null, error: null, auth: false };
}
