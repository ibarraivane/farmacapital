import { supabase } from "../supabase";
import { denominacionesLimpias } from "../constants/caja";
import { getSessionToken, esErrorSesionEmpleado } from "../utils";
import { parseRpcJsonObject } from "./rpcJson";

function resultadoAuth(errorMsg) {
  const msg = errorMsg || "Sesión expirada.";
  return { sesion: null, error: msg, auth: esErrorSesionEmpleado(msg) || msg === "Sesión expirada." };
}

/** Postgres/Supabase cortó la consulta (8s). No es que la caja se haya cerrado. */
export function esErrorTimeoutPostgres(msg) {
  return /statement timeout|lock timeout|canceling statement/i.test(String(msg || ""));
}

function sleep(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

const MSG_TIMEOUT_CAJA = "La caja tardó en responder";

export async function fetchSesionCajaAbierta({ intentos = 3, esperar = sleep } = {}) {
  const tok = getSessionToken();
  if (!tok) return resultadoAuth("Sesión expirada.");
  let ultimo = "No se pudo verificar la caja.";
  for (let i = 0; i < intentos; i += 1) {
    const { data, error } = await supabase.rpc("empleado_sesion_caja_abierta", {
      p_session_token: tok,
    });
    if (!error) {
      const sesion = parseRpcJsonObject(data);
      if (!sesion.abierta) return { sesion: null, error: null, auth: false };
      return { sesion, error: null, auth: false };
    }
    ultimo = error.message || ultimo;
    if (esErrorSesionEmpleado(ultimo)) return { sesion: null, error: ultimo, auth: true };
    if (!esErrorTimeoutPostgres(ultimo) || i === intentos - 1) {
      return {
        sesion: null,
        error: esErrorTimeoutPostgres(ultimo) ? MSG_TIMEOUT_CAJA : ultimo,
        auth: false,
      };
    }
    await esperar(350 * (i + 1));
  }
  return { sesion: null, error: MSG_TIMEOUT_CAJA, auth: false };
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

/**
 * Ya hubo caja hoy y no cubre los dos turnos: un reinicio a mitad del cierre
 * no debe pedir abrir el otro (el fondo y la hora de entrada se perderían).
 */
export function yaTuvoCajaYNoCubreAmbos(jornada) {
  if (!jornada || jornada.cubre_ambos) return false;
  const turnos = Array.isArray(jornada.turnos_hoy) ? jornada.turnos_hoy : [];
  return turnos.length >= 1;
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
