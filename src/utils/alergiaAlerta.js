/**
 * C2 — Alerta de alergias al recetar.
 * Cruza el texto libre de alergias del expediente con el nombre del medicamento.
 * No es un diccionario de principios activos: es una red de seguridad clínica.
 */

const IGNORAR = new Set([
  "no", "si", "sí", "na", "n/a", "ninguna", "ninguno", "ningunas", "ningunos",
  "desconoce", "desconocido", "niega", "sin", "alergias", "alergia",
]);

export function tokensAlergia(texto) {
  return String(texto || "")
    .split(/[,;/\n|]+/)
    .map((t) => t.trim().toLowerCase())
    .filter((t) => t.length >= 3 && !IGNORAR.has(t));
}

/**
 * @returns {string[]} tokens de alergia que cruzan con el nombre del medicamento
 */
export function alergiasQueCruzan(alergiasTexto, medicamentoNombre) {
  const nom = String(medicamentoNombre || "").toLowerCase().trim();
  if (!nom) return [];
  return tokensAlergia(alergiasTexto).filter((tok) => {
    if (nom.includes(tok)) return true;
    const first = nom.split(/\s+/)[0] || "";
    return first.length >= 4 && tok.includes(first);
  });
}

export function mensajeAlertaAlergia(cruces) {
  if (!cruces?.length) return "";
  return `Posible alergia: el paciente reportó «${cruces.join(", ")}». Confirma antes de recetar.`;
}
