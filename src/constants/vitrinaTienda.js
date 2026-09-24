/**
 * Menú público de la tienda. No es productos.categoria.
 * Un producto sin vitrina_seccion no entra aquí.
 */

export const SECCIONES_VITRINA = Object.freeze([
  { id: "nutricion-deportiva", nombre: "Nutrición deportiva", filtro: "marca" },
  { id: "dermocosmetica", nombre: "Dermocosmética", filtro: "marca" },
  { id: "medicamentos", nombre: "Medicamentos", filtro: "subseccion" },
  { id: "higiene", nombre: "Higiene y cuidado personal", filtro: "subseccion" },
  { id: "vitaminas", nombre: "Vitaminas y bienestar", filtro: "subseccion" },
  { id: "botiquin", nombre: "Botiquín y equipo médico", filtro: "subseccion" },
]);

export const SUBSECCIONES = Object.freeze({
  "Nutrición deportiva": Object.freeze([]),
  "Dermocosmética": Object.freeze(["Solar"]),
  Medicamentos: Object.freeze([
    "Dolor y fiebre",
    "Gripa y tos",
    "Digestión",
    "Alergia",
    "Diabetes",
    "Presión y corazón",
    "Piel",
    "Antibióticos",
    "Otros",
  ]),
  "Higiene y cuidado personal": Object.freeze([
    "Cabello",
    "Desodorantes",
    "Higiene bucal",
    "Afeitado",
    "Bebé",
    "Salud sexual",
    "Cuidado diario",
  ]),
  "Vitaminas y bienestar": Object.freeze([
    "Vitaminas",
    "Herbolarios",
    "Nutrición clínica",
    "Probióticos",
  ]),
  "Botiquín y equipo médico": Object.freeze([
    "Curación",
    "Termómetros y baumanómetros",
    "Glucómetros",
    "Pruebas",
  ]),
});

/** Slugs del menú anterior → sección nueva. */
const SLUGS_VIEJOS = Object.freeze({
  nutricion: "Nutrición deportiva",
  suplemento: "Nutrición deportiva",
  suplementos: "Nutrición deportiva",
  dermocosmeticos: "Dermocosmética",
  "cuidado-personal": "Dermocosmética",
  "dispositivos-medicos": "Botiquín y equipo médico",
  "dispositivo-medico": "Botiquín y equipo médico",
  dispositivos: "Botiquín y equipo médico",
  farmacia: "",
});

function normSlug(raw) {
  return String(raw || "")
    .trim()
    .toLowerCase()
    .normalize("NFD")
    .replace(/[\u0300-\u036f]/g, "");
}

export function slugSeccion(nombre) {
  const n = String(nombre || "").trim();
  return SECCIONES_VITRINA.find((s) => s.nombre === n)?.id || "";
}

export function seccionPorSlug(raw) {
  const key = normSlug(raw);
  if (!key) return "";
  if (Object.prototype.hasOwnProperty.call(SLUGS_VIEJOS, key)) return SLUGS_VIEJOS[key];
  const hit = SECCIONES_VITRINA.find((s) => s.id === key || normSlug(s.nombre) === key);
  return hit?.nombre || "";
}

/** Sección pública guardada en el producto. Vacío si no está clasificado. */
export function seccionDe(prod) {
  const s = String(prod?.vitrina_seccion || "").trim();
  return SECCIONES_VITRINA.some((x) => x.nombre === s) ? s : "";
}

export function productoVisibleEnSeccion(prod, seccion) {
  const s = seccionDe(prod);
  return Boolean(s) && s === seccion;
}

function marcaIgual(marca, chip) {
  return String(marca || "").trim().localeCompare(String(chip || "").trim(), "es", { sensitivity: "base" }) === 0;
}

/**
 * Página de sección: solo productos con esa vitrina_seccion.
 * Búsqueda por nombre, sin sección activa, incluye también los sin clasificar.
 */
export function productoEnVitrina(prod, { seccion = "", chip = "", busqueda = "" } = {}) {
  if (!prod || prod.activo === false) return false;
  const q = String(busqueda || "").trim();
  const propia = seccionDe(prod);
  const sec = seccionPorSlug(seccion) || (SECCIONES_VITRINA.some((s) => s.nombre === seccion) ? seccion : "");
  if (q && !sec) return true;
  if (!propia) return false;
  if (sec && propia !== sec) return false;
  if (!chip || chip === "Todos" || chip === sec) return true;
  if (chip === "Solar") return prod.vitrina_subseccion === "Solar";
  const def = SECCIONES_VITRINA.find((s) => s.nombre === (sec || propia));
  if (def?.filtro === "marca" && !(SUBSECCIONES[def.nombre] || []).includes(chip)) {
    return marcaIgual(prod.marca, chip);
  }
  return prod.vitrina_subseccion === chip;
}

export function chipsDeSeccion(seccion, productos) {
  const nombre = seccionPorSlug(seccion) || seccion;
  const def = SECCIONES_VITRINA.find((s) => s.nombre === nombre);
  if (!def) return ["Todos"];
  const enSeccion = (productos || []).filter((p) => seccionDe(p) === nombre);
  if (def.filtro === "marca") {
    const marcas = [...new Set(enSeccion.map((p) => String(p.marca || "").trim()).filter(Boolean))]
      .sort((a, b) => a.localeCompare(b, "es", { sensitivity: "base" }));
    return ["Todos", ...(SUBSECCIONES[nombre] || []), ...marcas];
  }
  const presentes = new Set(enSeccion.map((p) => p.vitrina_subseccion).filter(Boolean));
  return ["Todos", ...(SUBSECCIONES[nombre] || []).filter((s) => presentes.has(s))];
}
