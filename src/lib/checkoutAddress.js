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

/**
 * Separa "Cerrada Bartolache 1750" → { calle: "Cerrada Bartolache", numero: "1750" }.
 * Si no hay número al final, numero queda vacío.
 */
export function splitCalleYNumero(calleRaw) {
  const full = String(calleRaw || "").replace(/\s+/g, " ").trim();
  if (!full) return { calle: "", numero: "" };
  const m = full.match(/^(.*?)[\s,]+(\d+[A-Za-z]?(?:-\d*[A-Za-z]?)?|s\/?n)$/i);
  if (m && m[1].trim().length >= 3) {
    return { calle: m[1].trim(), numero: m[2].replace(/\s+/g, "").trim() };
  }
  return { calle: full, numero: "" };
}

/** Une calle + número exterior sin duplicar si ya venía en la calle. */
export function composeCheckoutCalle(calle, numero) {
  const c = String(calle || "").replace(/\s+/g, " ").trim();
  const n = String(numero || "").replace(/\s+/g, " ").trim();
  if (!c) return n;
  if (!n) return c;
  const fold = (s) => foldMx(s).replace(/\s+/g, "");
  if (fold(c).endsWith(fold(n))) return c;
  return `${c} ${n}`.trim();
}

/** Número exterior usable (1750, 12-B, S/N). */
export function checkoutNumeroOk(numero) {
  const n = String(numero || "").replace(/\s+/g, " ").trim();
  if (!n) return false;
  if (/^s\/?n$/i.test(n)) return true;
  return /\d/.test(n) && n.length <= 12;
}
