/** Principio activo: captura, inferencia desde el nombre y filtro de compras/reabasto. */

import { normalizeForSearch } from "../utils";
import { productoTienePrincipioActivo } from "../constants/categoriasProducto";

const PARENTESIS_NO_PA = new Set([
  "hombre", "mujer", "men", "women", "woman", "unisex", "dama", "caballero",
  "adulto", "adultos", "infantil", "infantiles", "nino", "ninos", "nina", "ninas",
  "bebe", "bebes", "familiar", "junior", "senior", "pediatrico", "pediatrica",
  "grande", "chico", "mediano", "nuevo", "nueva", "original", "clasico", "clasica",
  "inyectable", "tabletas", "tableta", "capsulas", "capsula", "comprimidos",
  "crema", "gel", "spray", "solucion", "jarabe", "suspension", "gotas",
  "unguento", "pomada", "sobres", "ampolletas",
]);

export function esSoloConcentracionPrincipio(s) {
  const t = String(s ?? "").trim();
  if (!t) return false;
  return /^(\d+(?:[.,]\d+)?\s*(?:mg|g|gr|gm|mcg|µg|ug|ml|mcl|%|iu|ui|meq)\b|\d+(?:[.,]\d+)?\s*-\s*\d+(?:[.,]\d+)?\s*(?:mg|g)?)$/i.test(t);
}

function titleCasePa(s) {
  return String(s || "")
    .replace(/\s+/g, " ")
    .trim()
    .split(/(\s+|[/+])/)
    .map((part) => {
      if (!part || /^[\s/+]$/.test(part)) return part;
      const lower = part.toLowerCase();
      if (["de", "del", "y", "e", "la", "el"].includes(lower)) return lower;
      return part.charAt(0).toUpperCase() + part.slice(1).toLowerCase();
    })
    .join("");
}

/**
 * Muchos medicamentos ya declaran el genérico en el nombre:
 * «Eferox (Cefalexina)» o «Infamid (Metamizol + Dexametasona)».
 */
export function inferirPrincipioActivoDesdeNombre(nombre) {
  const text = String(nombre || "");
  const re = /\(([^)]{3,80})\)/g;
  let m;
  while ((m = re.exec(text))) {
    const inner = m[1].replace(/\s+/g, " ").trim();
    if (!inner || esSoloConcentracionPrincipio(inner)) continue;
    const norm = normalizeForSearch(inner);
    if (!norm || PARENTESIS_NO_PA.has(norm)) continue;
    if (/^\d/.test(inner)) continue;
    return titleCasePa(inner);
  }
  return "";
}

/** Texto usable para buscar / mostrar. No inventa si no hay dato ni paréntesis. */
export function textoPrincipioActivo(p) {
  const pa = String(p?.principio_activo || "").trim();
  if (pa && !esSoloConcentracionPrincipio(pa)) return pa;
  const dg = String(p?.denominacion_generica || "").trim();
  if (dg) return dg;
  return inferirPrincipioActivoDesdeNombre(p?.nombre) || "";
}

/** Valor a persistir al guardar: capturado, genérico o inferido del nombre. */
export function completarPrincipioActivo(p) {
  return textoPrincipioActivo(p) || "";
}

export function opcionesPrincipioActivo(productos) {
  const map = new Map();
  for (const p of productos || []) {
    const raw = textoPrincipioActivo(p);
    if (!raw) continue;
    const clave = normalizeForSearch(raw);
    if (!clave) continue;
    if (!map.has(clave)) map.set(clave, raw);
  }
  return [...map.entries()]
    .sort((a, b) => a[1].localeCompare(b[1], "es"))
    .map(([clave, label]) => ({ clave, label }));
}

export function productoPasaFiltroPrincipioActivo(p, filtro) {
  if (!filtro || filtro === "todos") return true;
  const hay = normalizeForSearch(textoPrincipioActivo(p));
  if (filtro === "sin") return !hay && !productoTienePrincipioActivo(p);
  const q = normalizeForSearch(filtro);
  if (!q) return true;
  if (!hay) return false;
  return hay === q || hay.includes(q) || q.includes(hay);
}
