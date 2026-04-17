// ═══════════════════════════════════════════════════════════
// FARMAX — Sistema de Folios Secuenciales
// Formato: VTA-00000001 (sin duplicados, atómico)
// ═══════════════════════════════════════════════════════════
import { supabase } from "../supabase";

/**
 * Obtiene el siguiente folio secuencial de forma atómica
 * Usa función PostgreSQL para garantizar unicidad
 * @param {string} tipo - "ventas" | "facturas" | "devoluciones"
 * @returns {Promise<string>} - Ej: "VTA-00000001"
 */
export async function getSiguienteFolio(tipo = "ventas") {
  try {
    // Usar función RPC de Supabase (atómica, sin duplicados)
    const { data, error } = await supabase.rpc("get_next_folio", {
      folio_id: tipo
    });
    if (error) throw error;
    return data; // "VTA-00000001"
  } catch(e) {
    console.error("[Farmax] Error generando folio:", e);
    // Fallback: usar timestamp si falla la DB
    return `VTA-${Date.now()}`;
  }
}

/**
 * Formatea un número de folio manualmente
 * @param {number} numero
 * @param {string} prefijo - "VTA" | "FAC" | "DEV"
 * @returns {string} - "VTA-00000001"
 */
export function formatearFolio(numero, prefijo = "VTA") {
  return `${prefijo}-${String(numero).padStart(8, "0")}`;
}

/**
 * Obtiene el último folio registrado (solo lectura)
 * @param {string} tipo
 * @returns {Promise<string>}
 */
export async function getUltimoFolio(tipo = "ventas") {
  try {
    const { data, error } = await supabase
      .from("folios")
      .select("ultimo_numero, prefijo")
      .eq("id", tipo)
      .single();
    if (error || !data) return "VTA-00000000";
    return formatearFolio(data.ultimo_numero, data.prefijo);
  } catch(e) {
    return "VTA-00000000";
  }
}
