/**
 * Lista canónica de `productos.categoria`.
 * Inventario, POS, tienda y dashboard deben usar estas funciones
 * (no comparar el texto crudo).
 */

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

/** Categorías clínicas: el principio activo es el rubro de compra / reabasto. */
export const CATEGORIAS_CON_PRINCIPIO_ACTIVO = Object.freeze([
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
]);

const CATEGORIAS_SIN_PRINCIPIO_ACTIVO = new Set([
  "Dispositivo médico",
  "Botiquín",
  "Higiene",
  "Bebidas",
  "Básicos",
  "Abarrotes",
  "Minisuper",
  "Cuidado personal",
]);

/** Medicamento / suplemento: hay que capturar principio activo. Jabón y abarrotes no. */
export function categoriaRequierePrincipioActivo(raw) {
  const c = categoriaCanon(raw);
  if (!c || CATEGORIAS_SIN_PRINCIPIO_ACTIVO.has(c)) return false;
  return CATEGORIAS_CON_PRINCIPIO_ACTIVO.includes(c);
}

export function productoTienePrincipioActivo(p) {
  if (String(p?.principio_activo || "").trim()) return true;
  return Boolean(String(p?.denominacion_generica || "").trim());
}

/**
 * ¿Este renglón debe llevar principio activo?
 * Sí en categorías clínicas. En «Otro», sí si es genérico o ya tiene forma farmacéutica.
 */
export function productoRequierePrincipioActivo(p) {
  if (!p || typeof p !== "object") return false;
  if (categoriaRequierePrincipioActivo(p.categoria)) return true;
  const cat = categoriaCanon(p.categoria);
  if (CATEGORIAS_SIN_PRINCIPIO_ACTIVO.has(cat)) return false;
  const tipo = String(p.tipo || "")
    .toLowerCase()
    .normalize("NFD")
    .replace(/[\u0300-\u036f]/g, "");
  if (tipo === "generico") return true;
  return Boolean(String(p.forma_farmaceutica || "").trim());
}

export function productoFaltaPrincipioActivo(p) {
  return productoRequierePrincipioActivo(p) && !productoTienePrincipioActivo(p);
}
