import {
  CATEGORIAS_PRODUCTO,
  categoriaCanon,
  categoriasCoinciden,
  categoriaPasaFiltro,
  esCategoriaAntibiotico,
  esMedicamentoControlado,
  opcionesCategoriaSelect,
  categoriaRequierePrincipioActivo,
  productoFaltaPrincipioActivo,
  productoRequierePrincipioActivo,
} from "./categoriasProducto";

describe("categoriasProducto", () => {
  test("la lista canónica incluye las clínicas y el minisúper", () => {
    expect(CATEGORIAS_PRODUCTO).toContain("Analgésico");
    expect(CATEGORIAS_PRODUCTO).toContain("Antibiótico");
    expect(CATEGORIAS_PRODUCTO).toContain("Minisuper");
  });

  test("unifica alias viejos", () => {
    expect(categoriaCanon("Digestivo")).toBe("Gastro");
    expect(categoriaCanon("Botiquin")).toBe("Botiquín");
    expect(categoriaCanon("Suplementos")).toBe("Suplemento");
    expect(categoriaCanon("Bebés")).toBe("Higiene");
    expect(categoriaCanon("GENERAL")).toBe("Otro");
    expect(categoriaCanon("Antibiotico")).toBe("Antibiótico");
  });

  test("filtro y POS no dependen del acento", () => {
    expect(categoriasCoinciden("Antibiótico", "antibiotico")).toBe(true);
    expect(esCategoriaAntibiotico("antibiotico")).toBe(true);
    expect(esMedicamentoControlado({ categoria: "Antibiótico" })).toBe(false);
    expect(esMedicamentoControlado({ controlado: true })).toBe(true);
    expect(esMedicamentoControlado({ grupo_controlado: "II" })).toBe(true);
    expect(categoriaPasaFiltro("Digestivo", "Gastro")).toBe(true);
    expect(categoriaPasaFiltro("Alergia", "Gastro")).toBe(false);
  });

  test("el select conserva un valor huérfano para no pisarlo al abrir", () => {
    const opts = opcionesCategoriaSelect("Producto");
    expect(opts[0]).toBe("Producto");
    expect(opts).toContain("Analgésico");
  });

  test("el principio activo es obligatorio en medicamento, no en higiene", () => {
    expect(categoriaRequierePrincipioActivo("Antibiótico")).toBe(true);
    expect(categoriaRequierePrincipioActivo("Vitaminas")).toBe(true);
    expect(categoriaRequierePrincipioActivo("Higiene")).toBe(false);
    expect(productoRequierePrincipioActivo({ categoria: "Otro", tipo: "generico" })).toBe(true);
    expect(productoFaltaPrincipioActivo({ categoria: "Gastro", principio_activo: "" })).toBe(true);
  });
});
