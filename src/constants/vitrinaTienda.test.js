import {
  SECCIONES_VITRINA,
  chipsDeSeccion,
  productoEnVitrina,
  productoVisibleEnSeccion,
  seccionDe,
  seccionPorSlug,
  slugSeccion,
} from "./vitrinaTienda";

const bioderma = {
  activo: true,
  nombre: "Sensibio",
  marca: "Bioderma",
  vitrina_seccion: "Dermocosmética",
  vitrina_subseccion: null,
};
const solar = {
  activo: true,
  nombre: "Fusion Water",
  marca: "Isdin",
  vitrina_seccion: "Dermocosmética",
  vitrina_subseccion: "Solar",
};
const suelto = { activo: true, nombre: "Ovisen", categoria: "Otro", vitrina_seccion: null };

describe("vitrina de la tienda", () => {
  test("sin sección no aparece en una página de sección", () => {
    expect(seccionDe(suelto)).toBe("");
    expect(productoVisibleEnSeccion(suelto, "Medicamentos")).toBe(false);
    for (const s of SECCIONES_VITRINA) {
      expect(productoEnVitrina(suelto, { seccion: s.nombre })).toBe(false);
    }
  });

  test("la búsqueda por nombre sí lo encuentra", () => {
    expect(productoEnVitrina(suelto, { busqueda: "ovisen" })).toBe(true);
  });

  test("receta y medicamento no se listan en belleza", () => {
    const fluox = {
      activo: true,
      requiere_receta: true,
      vitrina_seccion: "Medicamentos",
      vitrina_subseccion: "Otros",
    };
    expect(productoEnVitrina(fluox, { seccion: "Dermocosmética" })).toBe(false);
    expect(productoEnVitrina(fluox, { seccion: "Nutrición deportiva" })).toBe(false);
    expect(productoEnVitrina(fluox, { seccion: "Medicamentos" })).toBe(true);
  });

  test("chips de dermocosmética: Solar y marcas", () => {
    expect(chipsDeSeccion("Dermocosmética", [bioderma, solar])).toEqual(["Todos", "Solar", "Bioderma", "Isdin"]);
    expect(productoEnVitrina(solar, { seccion: "Dermocosmética", chip: "Solar" })).toBe(true);
    expect(productoEnVitrina(bioderma, { seccion: "Dermocosmética", chip: "Solar" })).toBe(false);
    expect(productoEnVitrina(solar, { seccion: "Dermocosmética", chip: "Isdin" })).toBe(true);
  });

  test("slugs viejos redirigen a la sección nueva", () => {
    expect(seccionPorSlug("nutricion")).toBe("Nutrición deportiva");
    expect(seccionPorSlug("suplementos")).toBe("Nutrición deportiva");
    expect(slugSeccion(seccionPorSlug("nutricion"))).toBe("nutricion-deportiva");
    expect(seccionPorSlug("dermocosmeticos")).toBe("Dermocosmética");
    expect(seccionPorSlug("dispositivos-medicos")).toBe("Botiquín y equipo médico");
    expect(seccionPorSlug("farmacia")).toBe("");
    expect(slugSeccion("Medicamentos")).toBe("medicamentos");
  });

  test("el menú sale de SECCIONES_VITRINA", () => {
    expect(SECCIONES_VITRINA.map((s) => s.nombre)).toEqual([
      "Nutrición deportiva",
      "Dermocosmética",
      "Medicamentos",
      "Higiene y cuidado personal",
      "Vitaminas y bienestar",
      "Botiquín y equipo médico",
    ]);
    expect(SECCIONES_VITRINA.some((s) => s.nombre === "Farmacia" || s.nombre === "Otro")).toBe(false);
  });
});
