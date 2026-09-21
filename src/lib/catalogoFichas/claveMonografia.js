/**
 * Normalización de clave de monografía y vía.
 * Una clave es sustancia (o combinación) + vía.
 * Formato: minúsculas, sin acentos, ' + ' entre sustancias.
 */

export const VIAS = Object.freeze([
  "oral",
  "topica",
  "oftalmica",
  "otica",
  "nasal",
  "vaginal",
  "inyectable",
  "inhalada",
]);

function fold(s) {
  return String(s ?? "")
    .normalize("NFD")
    .replace(/[\u0300-\u036f]/g, "")
    .toLowerCase()
    .replace(/['’`´]/g, "")
    .trim();
}

function limpiarSustancia(part) {
  return fold(part)
    .replace(/\b(acido|hydrochloride|hcl|base|sodico|potasico|magnesico)\b/g, (m) => {
      if (m === "acido") return "acido";
      return m;
    })
    .replace(/[^a-z0-9]+/g, " ")
    .replace(/\s+/g, " ")
    .trim();
}

/**
 * Normaliza principio activo / combinación.
 * Acepta "Amoxicilina / Ácido clavulánico", "amoxicilina+acido clavulanico".
 */
export function normalizarClaveMonografia(raw) {
  const folded = fold(raw);
  if (!folded) return "";
  const parts = folded
    .split(/\s*(?:\+|\/|&| y )\s*/i)
    .map(limpiarSustancia)
    .filter(Boolean);
  return parts.join(" + ");
}

  const FORMA_A_VIA = [
  [/oftal|colirio|ojo/i, "oftalmica"],
  [/otic|oido/i, "otica"],
  [/nasal|nariz/i, "nasal"],
  [/vagin/i, "vaginal"],
  [/inyect|ampolleta|ampolla|im\b|iv\b|subcut/i, "inyectable"],
  [/inhal|aerosol|nebuliz|spray pulmonar/i, "inhalada"],
  [/crema|gel|unguent|pomada|locion|topica|cutane|parche|champu|shampoo/i, "topica"],
];

/** Deriva vía desde forma farmacéutica (y, si hace falta, presentación). */
export function viaDesdeForma(forma, presentacion = "") {
  const blob = fold(`${forma || ""} ${presentacion || ""}`);
  for (const [re, via] of FORMA_A_VIA) {
    if (re.test(blob)) return via;
  }
  return "oral";
}

export function viaValida(via) {
  return VIAS.includes(String(via || "").trim());
}

export function parMonografia(principioActivo, forma, presentacion) {
  return {
    clave: normalizarClaveMonografia(principioActivo),
    via: viaDesdeForma(forma, presentacion),
  };
}
