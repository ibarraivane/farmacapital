import { supabase } from "../supabase";
import { denominacionesLimpias } from "../constants/caja";

export async function fetchSesionCajaAbierta() {
  const tok = sessionStorage.getItem("farmacapital_session_token");
  if (!tok) return { sesion: null, error: "Sesión expirada." };
  const { data, error } = await supabase.rpc("empleado_sesion_caja_abierta", {
    p_session_token: tok,
  });
  if (error) return { sesion: null, error: error.message };
  if (!data || data.abierta !== true) return { sesion: null, error: null };
  return { sesion: data, error: null };
}

export async function abrirSesionCaja({ denoms, nota }) {
  const tok = sessionStorage.getItem("farmacapital_session_token");
  if (!tok) return { sesion: null, error: "Sesión expirada." };
  const { data, error } = await supabase.rpc("abrir_sesion_caja", {
    p_session_token: tok,
    p_denominaciones: denominacionesLimpias(denoms),
    p_nota: (nota || "").trim() || null,
  });
  if (error) return { sesion: null, error: error.message };
  if (data?.success === false) return { sesion: null, error: data.error || "No se pudo abrir caja." };
  return { sesion: data, error: null };
}

export function esVendedor(usuario) {
  return usuario?.rol === "vendedor";
}

export async function fetchJornadaHoy() {
  const tok = sessionStorage.getItem("farmacapital_session_token");
  if (!tok) return { jornada: null, error: "Sesión expirada." };
  const { data, error } = await supabase.rpc("empleado_jornada_hoy", {
    p_session_token: tok,
  });
  if (error) return { jornada: null, error: error.message };
  return { jornada: data || null, error: null };
}
