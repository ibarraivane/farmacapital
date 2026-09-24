import fs from "fs";
import path from "path";
import { CATEGORIAS_MEDICAMENTO, SECCIONES_BELLEZA, clasificarVitrina } from "./clasificarVitrina";

const SQL = fs.readFileSync(
  path.join(__dirname, "../../sql/patch_vitrina_seccion_20260924.sql"),
  "utf8"
);

function cls(p) {
  return clasificarVitrina({ activo: true, ...p });
}

describe("clasificarVitrina", () => {
  test("receta, controlado y categoría de medicamento se quedan en Medicamentos", () => {
    for (const categoria of CATEGORIAS_MEDICAMENTO) {
      const r = cls({
        categoria,
        marca: "Nivea",
        nombre: "Shampoo solar FPS 50",
      });
      expect(r.vitrina_seccion).toBe("Medicamentos");
      expect(SECCIONES_BELLEZA).not.toContain(r.vitrina_seccion);
    }
    expect(cls({ categoria: "Cuidado personal", requiere_receta: true, marca: "Isdin", nombre: "Fusion Water FPS 50" }).vitrina_seccion).toBe("Medicamentos");
    expect(cls({ categoria: "Otro", controlado: true, nombre: "Ovisen" }).vitrina_seccion).toBe("Medicamentos");
    expect(cls({ categoria: "Suplemento", grupo_controlado: "II", marca: "Mutant" }).vitrina_seccion).toBe("Medicamentos");
  });

  test("no infiere receta por la sustancia", () => {
    const ovisen = { categoria: "Otro", nombre: "Ovisen", principio_activo: "Fluoxetina", requiere_receta: false };
    expect(cls(ovisen).vitrina_seccion).toBeNull();
    expect(cls(ovisen).requiere_receta).toBeUndefined();
    expect(cls({ categoria: "Otro", nombre: "Ceftazidima 1 g", principio_activo: "Ceftazidima" }).vitrina_seccion).toBeNull();
    expect(cls({ categoria: "Antibiótico", nombre: "Ceftazidima 1 g" })).toEqual({
      vitrina_seccion: "Medicamentos",
      vitrina_subseccion: "Antibióticos",
    });
  });

  test("dermocosmética por marca, solar por el nombre, higiene masiva aparte", () => {
    expect(cls({ categoria: "Cuidado personal", marca: "Bioderma", nombre: "Sensibio H2O" })).toEqual({
      vitrina_seccion: "Dermocosmética",
      vitrina_subseccion: null,
    });
    expect(cls({ categoria: "Cuidado personal", marca: "Heliocare", nombre: "360 gel FPS 50" }).vitrina_subseccion).toBe("Solar");
    expect(cls({ categoria: "Cuidado personal", marca: "Nivea", nombre: "Crema lata" })).toEqual({
      vitrina_seccion: "Higiene y cuidado personal",
      vitrina_subseccion: "Cuidado diario",
    });
    expect(cls({ categoria: "Dermocosmético", marca: "Avène", nombre: "Cleanance" }).vitrina_seccion).toBe("Dermocosmética");
  });

  test("suplemento deportivo no se parte por el nombre; la clínica sí", () => {
    expect(cls({ categoria: "Suplemento", marca: "Cobra Labs", nombre: "The Curse Watermelon" })).toEqual({
      vitrina_seccion: "Nutrición deportiva",
      vitrina_subseccion: null,
    });
    expect(cls({ categoria: "Suplemento", marca: "Optimum Nutrition", nombre: "ISO 100 Cookies & Cream" }).vitrina_seccion).toBe("Nutrición deportiva");
    expect(cls({ categoria: "Suplemento", marca: "Abbott", nombre: "Ensure Advance" })).toEqual({
      vitrina_seccion: "Vitaminas y bienestar",
      vitrina_subseccion: "Nutrición clínica",
    });
    expect(cls({ categoria: "Suplementos", marca: "Otra", nombre: "Pediasure" }).vitrina_subseccion).toBe("Nutrición clínica");
  });

  test("vitaminas, higiene y botiquín", () => {
    expect(cls({ categoria: "Herbolario", nombre: "Té" }).vitrina_subseccion).toBe("Herbolarios");
    expect(cls({ categoria: "Vitaminas", nombre: "Probiótico lactobacilos" }).vitrina_subseccion).toBe("Probióticos");
    expect(cls({ categoria: "Vitaminas", nombre: "Vitamina C" }).vitrina_subseccion).toBe("Vitaminas");
    expect(cls({ categoria: "Higiene", nombre: "Shampoo anticaspa" }).vitrina_subseccion).toBe("Cabello");
    expect(cls({ categoria: "Bebés", nombre: "Pañal talla 3" }).vitrina_subseccion).toBe("Bebé");
    expect(cls({ categoria: "Dispositivo médico", nombre: "Termómetro digital" }).vitrina_seccion).toBe("Botiquín y equipo médico");
    expect(cls({ categoria: "Pruebas", nombre: "Prueba de embarazo" })).toEqual({
      vitrina_seccion: "Botiquín y equipo médico",
      vitrina_subseccion: "Pruebas",
    });
  });

  test("Otro, inactivo y minisuper quedan sin sección", () => {
    expect(cls({ categoria: "Otro", nombre: "Gel" }).vitrina_seccion).toBeNull();
    expect(cls({ categoria: "Abarrotes", nombre: "Refresco" }).vitrina_seccion).toBeNull();
    expect(clasificarVitrina({ activo: false, categoria: "Analgésico", nombre: "Paracetamol" }).vitrina_seccion).toBeNull();
  });

  test("la suma de secciones más pendientes cierra el total", () => {
    const filas = [
      { categoria: "Analgésico", nombre: "Ibuprofeno" },
      { categoria: "Suplemento", marca: "Mutant", nombre: "Mass" },
      { categoria: "Cuidado personal", marca: "Isdin", nombre: "Fusion" },
      { categoria: "Otro", nombre: "Sin ficha" },
      { categoria: "Higiene", nombre: "Desodorante roll on" },
    ].map((p) => cls(p));
    const conSeccion = filas.filter((r) => r.vitrina_seccion).length;
    const sinSeccion = filas.filter((r) => !r.vitrina_seccion).length;
    expect(conSeccion + sinSeccion).toBe(filas.length);
  });
});

describe("sql de vitrina", () => {
  test("agrega columnas y no toca categoria ni requiere_receta", () => {
    expect(SQL).toMatch(/add column if not exists vitrina_seccion/);
    expect(SQL).toMatch(/add column if not exists vitrina_subseccion/);
    expect(SQL).not.toMatch(/set\s+categoria\s*=/i);
    const updatesVivos = SQL
      .split("\n")
      .filter((line) => !line.trim().startsWith("--"))
      .join("\n");
    expect(updatesVivos).not.toMatch(/set\s+requiere_receta/i);
    expect(SQL).toMatch(/where id in \(\s*\/\* IDs aprobados \*\/\s*\)/);
  });
});
