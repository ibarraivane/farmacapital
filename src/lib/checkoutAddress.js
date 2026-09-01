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

function titleCaseMx(s) {
  const t = String(s || "").replace(/\s+/g, " ").trim();
  if (!t) return "";
  return t.charAt(0).toUpperCase() + t.slice(1);
}

/**
 * Arma destino desde lo que el cliente escribió, sin depender del mapa.
 * "Av Insurgentes Sur 300 roma norte 06700" → calle/número/colonia/CP.
 */
export function parseTypedMxAddress(raw) {
  let s = String(raw || "").replace(/[.,;]+/g, " ").replace(/\s+/g, " ").trim();
  if (s.length < 8) return null;
  s = s
    .replace(/\b(ciudad de m[eé]xico|cdmx|m[eé]xico\s*d\.?\s*f\.?|mexico)\b/gi, " ")
    .replace(/\s+/g, " ")
    .trim();

  let cp = "";
  const cpM = s.match(/\b(\d{5})\b/);
  if (cpM) {
    cp = cpM[1];
    s = s.replace(cpM[0], " ").replace(/\s+/g, " ").trim();
  }

  const mid = s.match(/^(.{3,}?)\s+(\d+[A-Za-z]?(?:-\d*[A-Za-z]?)?|s\/?n)\s+(.+)$/i);
  if (mid) {
    const colonia = cleanCheckoutColonia(mid[3].replace(/\s+\d{1,4}$/g, "").trim());
    return {
      calle: titleCaseMx(mid[1]),
      numero: mid[2].replace(/\s+/g, ""),
      colonia,
      cp,
    };
  }

  const split = splitCalleYNumero(s);
  if (split.numero && split.calle.length >= 5) {
    return {
      calle: titleCaseMx(split.calle),
      numero: split.numero,
      colonia: "",
      cp,
    };
  }
  return null;
}

/** Una línea de destino: calle, número, colonia, CP. */
export function formatDestinoLabel({ calle, numero, colonia, cp } = {}) {
  const street = composeCheckoutCalle(calle, numero);
  const col = cleanCheckoutColonia(colonia);
  const zip = String(cp || "").replace(/\D/g, "").slice(0, 5);
  return [street, col, zip.length === 5 ? zip : ""].filter(Boolean).join(", ");
}

/** Destino listo para cotizar: calle+número, colonia y CP. */
export function isCheckoutDestinoListo({ calle, numero, colonia, cp } = {}) {
  const street = composeCheckoutCalle(calle, numero);
  return (
    street.length >= 5 &&
    checkoutNumeroOk(numero) &&
    cleanCheckoutColonia(colonia).length >= 3 &&
    String(cp || "").replace(/\D/g, "").length === 5
  );
}

function coordsFromSug(sug) {
  if (sug?.lat == null || sug?.lng == null) return { lat: null, lng: null };
  const lat = Number(sug.lat);
  const lng = Number(sug.lng);
  if (!Number.isFinite(lat) || !Number.isFinite(lng) || (lat === 0 && lng === 0)) {
    return { lat: null, lng: null };
  }
  return { lat, lng };
}

/** Aplica una sugerencia del buscador al estado del checkout. */
export function applyDestinoSuggestion(sug, prev = {}) {
  const coords = coordsFromSug(sug);
  if (sug?.calle && sug?.numero) {
    return {
      ...prev,
      calle: String(sug.calle).replace(/\s+/g, " ").trim(),
      numero: String(sug.numero).replace(/\s+/g, "").trim(),
      colonia: cleanCheckoutColonia(sug.colonia || ""),
      cp: String(sug.cp || "").replace(/\D/g, "").slice(0, 5),
      ...coords,
    };
  }
  const rawCalle = String(sug?.calle || sug?.label || "").replace(/\s+/g, " ").trim();
  const split = splitCalleYNumero(rawCalle);
  return {
    ...prev,
    calle: split.calle || rawCalle || prev.calle || "",
    numero: split.numero || prev.numero || "",
    colonia: cleanCheckoutColonia(sug?.colonia || prev.colonia || ""),
    cp: String(sug?.cp || prev.cp || "").replace(/\D/g, "").slice(0, 5),
    ...coords,
  };
}
