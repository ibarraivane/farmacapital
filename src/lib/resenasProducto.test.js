import {
  productoAceptaResena,
  motivoSinResena,
  promedioResenas,
  textoPromedio,
  CATEGORIAS_CON_RESENA,
} from "./resenasProducto";

const P = (extra) => ({ id: 1, nombre: "Producto", ...extra });

describe("qué productos aceptan reseñas", () => {
  test("dermocosmética, higiene y suplementos sí", () => {
    expect(productoAceptaResena(P({ categoria: "Cuidado personal" }))).toBe(true);
    expect(productoAceptaResena(P({ categoria: "Higiene" }))).toBe(true);
    expect(productoAceptaResena(P({ categoria: "Suplemento" }))).toBe(true);
    expect(productoAceptaResena(P({ categoria: "Vitaminas" }))).toBe(true);
  });

  test("los alias del inventario también", () => {
    expect(productoAceptaResena(P({ categoria: "Suplementos" }))).toBe(true);
    expect(productoAceptaResena(P({ categoria: "Dermocosmético" }))).toBe(true);
    expect(productoAceptaResena(P({ categoria: "Bebés" }))).toBe(true);
  });

  test("ningún medicamento lleva estrellas", () => {
    ["Medicamentos", "Analgésico", "Antibiótico", "Gastro", "Diabetes",
     "Hipertensión", "Alergia", "Respiratorio", "Cardiovascular", "Hormonales",
     "Antiinflamatorio", "Hidratación", "Antiviral", "Ginecología", "Pruebas",
    ].forEach((categoria) => {
      expect(productoAceptaResena(P({ categoria }))).toBe(false);
    });
  });

  test("la receta y lo controlado mandan sobre la categoría", () => {
    expect(productoAceptaResena(P({ categoria: "Cuidado personal", requiere_receta: true }))).toBe(false);
    expect(motivoSinResena(P({ categoria: "Higiene", requiere_receta: true }))).toBe("Requiere receta médica");
    expect(productoAceptaResena(P({ categoria: "Suplemento", controlado: true }))).toBe(false);
    expect(productoAceptaResena(P({ categoria: "Suplemento", grupo_controlado: "III" }))).toBe(false);
  });

  test("una categoría desconocida queda bloqueada, no abierta", () => {
    expect(productoAceptaResena(P({ categoria: "Otro" }))).toBe(false);
    expect(productoAceptaResena(P({ categoria: "GENERAL" }))).toBe(false);
    expect(productoAceptaResena(P({ categoria: "Categoría que no existe todavía" }))).toBe(false);
    expect(productoAceptaResena(P({}))).toBe(false);
    expect(productoAceptaResena(null)).toBe(false);
  });

  test("la lista blanca no trae ningún medicamento", () => {
    const prohibidas = /medicament|analg|antibi|antiinflam|gastro|diabetes|hipertens|alergia|respirat|cardio|hormon/i;
    CATEGORIAS_CON_RESENA.forEach((c) => expect(c).not.toMatch(prohibidas));
  });
});

describe("promedio", () => {
  const r = (estrellas, estado = "aprobada") => ({ estrellas, estado });

  test("solo cuenta las aprobadas", () => {
    expect(promedioResenas([r(5), r(4), r(1, "pendiente"), r(1, "rechazada")]))
      .toEqual({ promedio: 4.5, total: 2 });
  });

  test("sin reseñas aprobadas no inventa estrellas", () => {
    expect(promedioResenas([])).toBeNull();
    expect(promedioResenas([r(5, "pendiente")])).toBeNull();
    expect(promedioResenas(null)).toBeNull();
  });

  test("recorta valores fuera de rango y redondea a un decimal", () => {
    expect(promedioResenas([r(9), r(0), r(4)])).toEqual({ promedio: 3.3, total: 3 });
  });

  test("el texto accesible dice el promedio y cuántas", () => {
    expect(textoPromedio(promedioResenas([r(5)]))).toBe("5 de 5 · 1 reseña");
    expect(textoPromedio(promedioResenas([r(5), r(4)]))).toBe("4.5 de 5 · 2 reseñas");
    expect(textoPromedio(null)).toBe("Sin reseñas todavía");
  });
});
