/**
 * Consumibles típicos en consultorio de medicina general / curación (no catálogo completo de medicamentos).
 * Se filtran por categorías de inventario y, en respaldo, por palabras clave en el nombre.
 */
import { CONSULTA_PRECIO_DEFAULT } from "./consultaConstants";

/** Categorías sugeridas en inventario para marcar productos como material de consulta. */
export const CATEGORIAS_CONSUMIBLE_CONSULTORIO_SUGERIDAS = [
  "Botiquín",
  "Curación",
  "Material de curación",
  "Hospitalario",
];

const PALABRAS_CLAVE = /(gasa|gazas|venda|vendas|curita|apósito|micropore|esparadrapo|jeringa|aguja|guante|guantes|algod[oó]n|hisopo|alcohol|agua oxigenada|per[oó]xido|soluci[oó]n salina|campo|compresa|tapabocas|cubrebocas|mascarilla|nebuliz|cat[eé]ter|torunda|clorhexidina|povidona|yodo|bistur[ií]|sutura|hilo|latex|nitrilo)/i;

/**
 * @param {import("@supabase/supabase-js").SupabaseClient} supabase
 * @returns {Promise<{ id:number, nombre:string, stock:number, precio:number, categoria:string }[]>}
 */
export async function fetchProductosConsumiblesConsultorio(supabase) {
  let categorias = ["Botiquín"];
  try {
    const { data: cfg } = await supabase.from("configuracion").select("clave,valor").eq("clave", "consumibles_categorias").maybeSingle();
    if (cfg?.valor) {
      const j = JSON.parse(cfg.valor);
      if (Array.isArray(j) && j.length) categorias = j.map(String);
    }
  } catch {
    /* default */
  }

  const { data: rows, error } = await supabase
    .from("productos")
    .select("id,nombre,stock,precio,categoria")
    .eq("activo", true)
    .order("nombre");

  if (error || !rows?.length) return [];

  const porCategoria = rows.filter((p) => categorias.includes(p.categoria));
  if (porCategoria.length > 0) return porCategoria;

  return rows.filter((p) => PALABRAS_CLAVE.test(p.nombre || ""));
}

/** Precio público consulta desde configuración (fallback 80). */
export async function fetchPrecioConsultaConfig(supabase) {
  try {
    const { data } = await supabase.from("configuracion").select("valor").eq("clave", "precio_consulta").maybeSingle();
    const n = parseFloat(data?.valor);
    return Number.isFinite(n) && n > 0 ? n : CONSULTA_PRECIO_DEFAULT;
  } catch {
    return CONSULTA_PRECIO_DEFAULT;
  }
}
