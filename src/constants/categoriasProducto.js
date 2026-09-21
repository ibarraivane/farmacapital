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

function blobCategoriaProducto(p) {
  return `${p?.nombre || ""} ${p?.marca || ""} ${p?.forma_farmaceutica || ""} ${p?.principio_activo || ""}`
    .normalize("NFD")
    .replace(/[\u0300-\u036f]/g, "")
    .toLowerCase();
}

/**
 * Suero oral / electrolitos de mostrador. El parser de ticket los metió
 * en Higiene o GENERAL; en vitrina van a Hidratación.
 */
export function esProductoHidratacionOral(p) {
  const t = blobCategoriaProducto(p);
  if (!t.trim()) return false;
  if (/\b(electrolit|electrolid|pedialyte|suerox|oralit|voldratol)\b/.test(t)) return true;
  if (/\bsuero oral\b/.test(t)) return true;
  if (/\belectrolitos\b/.test(t)) return true;
  return false;
}

/** Categoría que ve el cliente (corrige sueros mal etiquetados). */
export function categoriaVitrina(p) {
  if (esProductoHidratacionOral(p)) return "Hidratación";
  return categoriaCanon(p?.categoria);
}

export function categoriaVitrinaPasaFiltro(p, filtro) {
  if (!filtro || filtro === "todas" || filtro === "Todos") return true;
  return categoriasCoinciden(categoriaVitrina(p), filtro);
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
