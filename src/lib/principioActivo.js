/** Principio activo: captura, inferencia desde el nombre/marca y filtro de compras/reabasto. */

import { normalizeForSearch } from "../utils";
import {
  productoRequierePrincipioActivo,
  productoTienePrincipioActivo,
} from "../constants/categoriasProducto";

const PARENTESIS_NO_PA = new Set([
  "hombre", "mujer", "men", "women", "woman", "unisex", "dama", "caballero",
  "adulto", "adultos", "infantil", "infantiles", "nino", "ninos", "nina", "ninas",
  "bebe", "bebes", "familiar", "junior", "senior", "pediatrico", "pediatrica",
  "grande", "chico", "mediano", "nuevo", "nueva", "original", "clasico", "clasica",
  "inyectable", "tabletas", "tableta", "capsulas", "capsula", "comprimidos",
  "crema", "gel", "spray", "solucion", "jarabe", "suspension", "gotas",
  "unguento", "pomada", "sobres", "ampolletas",
]);

/** Marcas comerciales → principio activo. Solo las que no se inventan. */
export const MARCA_PRINCIPIO_ACTIVO = {
  tylenol: "Paracetamol",
  agrifen: "Paracetamol / Cafeína / Clorfenamina",
  afrin: "Oximetazolina",
  flanax: "Naproxeno",
  saridon: "Paracetamol / Propifenazona / Cafeína",
  neurobion: "Tiamina / Piridoxina / Cianocobalamina",
  tabcin: "Ácido acetilsalicílico / Fenilefrina / Clorfenamina",
  zukedib: "Glimepirida",
  erbitrax: "Terbinafina",
  valnait: "Valeriana",
  scabisan: "Permetrina",
  lesaclor: "Cefaclor",
  cefaroxil: "Cefadroxilo",
  cefalver: "Cefalexina",
  acroxil: "Amoxicilina / Ácido clavulánico",
  "acroxil-c": "Amoxicilina / Ácido clavulánico",
  ampigrin: "Ampicilina / Dicloxacilina",
  bactiver: "Sulfametoxazol / Trimetoprima",
  cina: "Ciprofloxacino",
  eferox: "Cefalexina",
  "ibupro-cafe": "Ibuprofeno / Cafeína",
  aspitak: "Ácido acetilsalicílico",
  "aspitak-p": "Ácido acetilsalicílico",
  vitacilina: "Neomicina / Bacitracina",
  gelcavit: "Multivitamínico",
  animalin: "Multivitamínico",
  fasiclor: "Cefaclor",
  cefagen: "Cefalexina",
  klarix: "Claritromicina",
  charlyn: "Ciprofloxacino",
  cepobrom: "Cefadroxilo",
  diclofen: "Diclofenaco",
  epicin: "Eritromicina",
  knoricin: "Nitrofurantoína",
  clamoxin: "Amoxicilina / Ácido clavulánico",
  gimalxina: "Amoxicilina",
  valclan: "Amoxicilina / Ácido clavulánico",
  histiacil: "Dextrometorfano",
};

const MARCAS_SIN_PA = new Set([
  "pantene", "sedal", "axe", "caprice", "listerine", "ponds", "nan", "colgate",
  "herbal essences", "nutribela", "sico", "gum", "huggies", "kleenex",
]);

const GENERICOS_CONOCIDOS = new Set([
  "amlodipino", "aciclovir", "celecoxib", "budesonida", "ceftriaxona",
  "cefotaxima", "lincomicina", "ursodesoxicolico", "acetilsalicilico",
  "fluocinolona", "calcitriol", "paracetamol", "ibuprofeno", "naproxeno",
  "amoxicilina", "diclofenaco", "metformina", "omeprazol", "losartan",
  "hierro", "cefalexina", "ciprofloxacino", "ketoconazol", "metronidazol",
  "dexametasona", "prednisona", "loratadina", "cetirizina", "ambroxol",
]);

const SUFIJO_GENERICO = /(oxacino|micina|mycin|pril|sartan|statin|prazol|dipina|azol|cillin|afil|coxib|sonida|xona|ovir|moxino)$/i;

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

function claveMarca(s) {
  return normalizeForSearch(s).replace(/[^a-z0-9]+/g, "-").replace(/^-|-$/g, "");
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

function tokenGenerico(token) {
  const n = normalizeForSearch(token);
  if (!n || n.length < 5) return "";
  if (GENERICOS_CONOCIDOS.has(n) || SUFIJO_GENERICO.test(n)) return titleCasePa(token);
  return "";
}

function paDesdeMarcaONombre(p) {
  const marca = claveMarca(p?.marca || "");
  if (marca && MARCAS_SIN_PA.has(marca.replace(/-/g, " "))) return "";
  if (marca && MARCA_PRINCIPIO_ACTIVO[marca]) return MARCA_PRINCIPIO_ACTIVO[marca];

  const nombreClave = claveMarca((p?.nombre || "").split(/\s+/)[0] || "");
  if (nombreClave && MARCA_PRINCIPIO_ACTIVO[nombreClave]) return MARCA_PRINCIPIO_ACTIVO[nombreClave];

  const tokens = String(p?.nombre || "").split(/[\s,/]+/).filter(Boolean);
  for (const t of tokens.slice(0, 4)) {
    if (PARENTESIS_NO_PA.has(normalizeForSearch(t))) continue;
    if (esSoloConcentracionPrincipio(t)) continue;
    const gen = tokenGenerico(t);
    if (gen) return gen;
  }
  return "";
}

/** Infere PA sin inventar en jabón/shampoo. */
export function inferirPrincipioActivo(p) {
  const fromParen = inferirPrincipioActivoDesdeNombre(p?.nombre);
  if (fromParen) return fromParen;
  const marcaNorm = normalizeForSearch(p?.marca || "");
  if (MARCAS_SIN_PA.has(marcaNorm)) return "";
  const nombreNorm = normalizeForSearch(p?.nombre || "");
  if ([...MARCAS_SIN_PA].some((m) => nombreNorm.includes(m))) return "";
  return paDesdeMarcaONombre(p) || "";
}

/** Texto usable para buscar / mostrar. */
export function textoPrincipioActivo(p) {
  const pa = String(p?.principio_activo || "").trim();
  if (pa && !esSoloConcentracionPrincipio(pa)) return pa;
  const dg = String(p?.denominacion_generica || "").trim();
  if (dg) return dg;
  return inferirPrincipioActivo(p) || "";
}

/** Valor a persistir al guardar: capturado, genérico o inferido. */
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
  if (filtro === "sin") {
    return !hay && !productoTienePrincipioActivo(p) && !inferirPrincipioActivo(p);
  }
  const q = normalizeForSearch(filtro);
  if (!q) return true;
  if (!hay) return false;
  return hay === q || hay.includes(q) || q.includes(hay);
}

export function productoAunSinPrincipio(p) {
  return productoRequierePrincipioActivo(p) && !textoPrincipioActivo(p);
}
