/**
 * Marcas de dermocosmética que vendemos directo de laboratorio.
 * La vitrina pública «Dermocosmética» solo debe mostrar estas
 * (SVR en anaquel; Alastin / Medik8 por encargo con PVP).
 */
export const MARCAS_LABORATORIO_DERMO = Object.freeze(["svr", "alastin", "medik8"]);

export function esMarcaLaboratorioDermo(marca) {
  return MARCAS_LABORATORIO_DERMO.includes(String(marca || "").trim().toLowerCase());
}
