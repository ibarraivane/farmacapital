/**
 * Lista canónica de `productos.categoria`.
 * Inventario, POS, tienda y dashboard deben usar estas funciones
 * (no comparar el texto crudo).
 */

import { inferirCategoriaCatalogo } from "./inferirCategoriaCatalogo";

export const CATEGORIAS_PRODUCTO = Object.freeze([
  "Analgésico",
  "Antiinflamatorio",
  "Antibiótico",
  "Gastro",
  "Diabetes",
  "Hipertensión",
  "Alergia",
  "Vitaminas",
  "Suplemento",
  "Herbolario",
  "Hidratación",
  "Cardiovascular",
  "Hormonales",
  "Respiratorio",
  "Dispositivo médico",
  "Botiquín",
  "Higiene",
  "Bebidas",
  "Básicos",
  "Abarrotes",
  "Minisuper",
  "Cuidado personal",
  "Otro",
]);

/** Alias históricos / CSV / tienda → valor canónico. Clave ya normalizada. */
const CATEGORIA_ALIAS = {
  digestivo: "Gastro",
  gastro: "Gastro",
  botiquin: "Botiquín",
  curacion: "Botiquín",
  "material de curacion": "Botiquín",
  hospitalario: "Botiquín",
  suplementos: "Suplemento",
  bebes: "Higiene",
  bebe: "Higiene",
  general: "Otro",
  producto: "Otro",
  productos: "Otro",
  antibiotico: "Antibiótico",
  antibioticos: "Antibiótico",
  analgesico: "Analgésico",
  analgesicos: "Analgésico",
  hipertension: "Hipertensión",
  hidratacion: "Hidratación",
  "hidratacion / electrolitos": "Hidratación",
  electrolitos: "Hidratación",
  "dispositivo medico": "Dispositivo médico",
  dispositivo: "Dispositivo médico",
  "cuidado personal": "Cuidado personal",
};

export function normalizeCategoriaKey(s) {
  return String(s ?? "")
    .trim()
    .normalize("NFD")
    .replace(/[\u0300-\u036f]/g, "")
    .toLowerCase()
    .replace(/\s+/g, " ");
}

/** Valor de menú / reportes. Vacío si no hay texto. */
export function categoriaCanon(raw) {
  const n = normalizeCategoriaKey(raw);
  if (!n) return "";
  if (CATEGORIA_ALIAS[n]) return CATEGORIA_ALIAS[n];
  const hit = CATEGORIAS_PRODUCTO.find((c) => normalizeCategoriaKey(c) === n);
  if (hit) return hit;
  return String(raw).trim();
}

export function categoriasCoinciden(a, b) {
  const ca = categoriaCanon(a);
  const cb = categoriaCanon(b);
  return Boolean(ca) && ca === cb;
}

/**
 * Suero oral / electrolitos. El parser de ticket los metió en Higiene o GENERAL.
 */
export function esProductoHidratacionOral(p) {
  return inferirCategoriaCatalogo(p) === "Hidratación";
}

/**
 * Categoría de vitrina e inventario: infiere por ficha si hay señal clara.
 * Si no, deja la categoría canónica (o el cubo Otro).
 */
export function categoriaVitrina(p) {
  return inferirCategoriaCatalogo(p) || categoriaCanon(p?.categoria) || "Otro";
}

export function categoriaVitrinaPasaFiltro(p, filtro) {
  if (!filtro || filtro === "todas" || filtro === "Todos") return true;
  return categoriasCoinciden(categoriaVitrina(p), filtro);
}

/** Rubros de mostrador. Nutrición es «Suplemento»; esto es el resto de la farmacia. */
export const CATEGORIAS_MEDICAMENTO = Object.freeze([
  "Analgésico",
  "Antiinflamatorio",
  "Antibiótico",
  "Gastro",
  "Diabetes",
  "Hipertensión",
  "Alergia",
  "Cardiovascular",
  "Hormonales",
  "Respiratorio",
]);

export const AREA_MEDICAMENTOS = "Medicamentos";
export const AREA_DERMOCOSMETICA = "Dermocosmética";
export const AREA_NUTRICION = "Nutrición";
export const AREA_DISPOSITIVOS = "Dispositivos médicos";
export const AREA_BOTIQUIN = "Botiquín";
export const AREA_FARMACIA = "Farmacia";

/** Suplementos y vitaminas. El suero y el herbolario se quedan en Farmacia. */
export const CATEGORIAS_NUTRICION = Object.freeze(["Suplemento", "Vitaminas"]);

/** Aparatos. El material de curación es su propia área. */
export const CATEGORIAS_DISPOSITIVOS = Object.freeze(["Dispositivo médico"]);

/** Lo que no es fármaco, piel, nutrición ni aparato. */
export const CATEGORIAS_FARMACIA = Object.freeze([
  "Higiene",
  "Bebidas",
  "Básicos",
  "Abarrotes",
  "Herbolario",
  "Hidratación",
  "Otro",
]);

export const AREAS_TIENDA = Object.freeze([
  { id: AREA_MEDICAMENTOS, categorias: CATEGORIAS_MEDICAMENTO },
  { id: AREA_DERMOCOSMETICA, categorias: Object.freeze(["Cuidado personal"]) },
  { id: AREA_NUTRICION, categorias: CATEGORIAS_NUTRICION },
  { id: AREA_DISPOSITIVOS, categorias: CATEGORIAS_DISPOSITIVOS },
  { id: AREA_BOTIQUIN, categorias: Object.freeze(["Botiquín"]) },
  { id: AREA_FARMACIA, categorias: CATEGORIAS_FARMACIA },
]);

function normArea(s) {
  return String(s ?? "")
    .trim()
    .normalize("NFD")
    .replace(/[\u0300-\u036f]/g, "")
    .toLowerCase();
}

export function esMedicamentoCatalogo(p) {
  return CATEGORIAS_MEDICAMENTO.includes(categoriaVitrina(p));
}

/** Cuidado personal y fichas marcadas como dermatología. Sin vitaminas ni proteína. */
export function esDermocosmeticoCatalogo(p) {
  if (categoriaVitrina(p) === "Cuidado personal") return true;
  const sub = normArea(p?.subcategoria);
  const cat = normArea(p?.categoria);
  return sub.startsWith("dermatolog") || cat.startsWith("dermatolog") || cat.startsWith("dermo");
}

/** Área del menú que corresponde al filtro activo, o null si es el catálogo entero. */
export function areaDeFiltro(filtro) {
  const f = filtro === "Cuidado personal" ? AREA_DERMOCOSMETICA : filtro;
  const directa = AREAS_TIENDA.find((a) => a.id === f);
  if (directa) return directa;
  return AREAS_TIENDA.find((a) => a.categorias.includes(f)) || null;
}

/**
 * Filtro del catálogo de la tienda. Las áreas del menú agrupan varias
 * filas de productos.categoria; una categoría suelta sigue filtrando igual.
 */
export function productoPasaAreaTienda(p, filtro) {
  if (!filtro || filtro === "todas" || filtro === "Todos") return true;
  if (filtro === AREA_DERMOCOSMETICA || filtro === "Cuidado personal") return esDermocosmeticoCatalogo(p);
  const area = AREAS_TIENDA.find((a) => a.id === filtro);
  if (area) return area.categorias.includes(categoriaVitrina(p));
  return categoriaVitrinaPasaFiltro(p, filtro);
}

/** Chips del catálogo: dentro de un área, solo las categorías de esa área. */
export function chipsAreaTienda(pool, filtro) {
  const area = areaDeFiltro(filtro);
  if (!area) {
    const presentes = new Set((pool || []).map((p) => categoriaVitrina(p)).filter(Boolean));
    return ["Todos", ...CATEGORIAS_PRODUCTO.filter((c) => presentes.has(c))];
  }
  if (area.categorias.length <= 1) return [area.id];
  const presentes = new Set(
    (pool || [])
      .filter((p) => area.categorias.includes(categoriaVitrina(p)))
      .map((p) => categoriaVitrina(p))
  );
  return [area.id, ...area.categorias.filter((c) => presentes.has(c))];
}

export function esCategoriaAntibiotico(raw) {
  return categoriaCanon(raw) === "Antibiótico";
}

/** Fracción controlada COFEPRIS. La receta sí detiene la venta. Antibiótico no. */
export function esMedicamentoControlado(p) {
  if (!p || typeof p !== "object") return false;
  if (p.controlado === true) return true;
  return Boolean(String(p.grupo_controlado || "").trim());
}

export function categoriaPasaFiltro(raw, filtro) {
  if (!filtro || filtro === "todas" || filtro === "Todos") return true;
  return categoriasCoinciden(raw, filtro);
}

/** Opciones del <select>: canónicas + el valor actual si es huérfano. */
export function opcionesCategoriaSelect(valorActual) {
  const list = [...CATEGORIAS_PRODUCTO];
  const raw = String(valorActual || "").trim();
  if (raw && !list.includes(raw)) list.unshift(raw);
  return list;
}

export function recargoCategoriaEsHigiene(raw) {
  const c = categoriaCanon(raw);
  return c === "Higiene" || c === "Cuidado personal";
}
