/** Limpia colonia CDMX en el checkout (sin Col. ni alcaldía). */

const CDMX_ALCALDIAS = [
  "alvaro obregon",
  "azcapotzalco",
  "benito juarez",
  "coyoacan",
  "cuajimalpa",
  "cuauhtemoc",
  "gustavo a madero",
  "iztacalco",
  "iztapalapa",
  "magdalena contreras",
  "la magdalena contreras",
  "miguel hidalgo",
  "milpa alta",
  "tlahuac",
  "tlalpan",
  "venustiano carranza",
  "xochimilco",
];

function foldMx(s) {
  return String(s || "")
    .normalize("NFD")
    .replace(/[\u0300-\u036f]/g, "")
    .toLowerCase()
    .replace(/\s+/g, " ")
    .trim();
}

/** "Col del Valle Sur, Benito Juárez" → "Del Valle Sur" */
export function cleanCheckoutColonia(raw) {
  let s = String(raw || "").replace(/\s+/g, " ").trim();
  if (!s) return "";
  const parts = s.split(",").map((p) => p.trim()).filter(Boolean);
  if (parts.length >= 2) {
    const rest = foldMx(parts.slice(1).join(" "));
    const isAlcaldia =
      /ciudad de mexico|\bcdmx\b|\bdf\b/.test(rest) ||
      CDMX_ALCALDIAS.some((a) => rest.includes(a) || a.includes(rest));
    if (isAlcaldia) s = parts[0];
  }
  s = s.replace(/^(colonia|col\.?)\s+/i, "").trim();
  if (s) s = s.charAt(0).toUpperCase() + s.slice(1);
  return s;
}
