import { supabase } from "../supabase";
import { denominacionesLimpias } from "../constants/caja";
import { getSessionToken, esErrorSesionEmpleado } from "../utils";

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
  if (!data || data.abierta !== true) return { sesion: null, error: null, auth: false };
  return { sesion: data, error: null, auth: false };
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
  if (data?.success === false) return { sesion: null, error: data.error || "No se pudo abrir caja.", auth: false };
  return { sesion: data, error: null, auth: false };
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
  return { jornada: data || null, error: null, auth: false };
}
