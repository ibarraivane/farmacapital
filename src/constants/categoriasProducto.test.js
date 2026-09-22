import {
  CATEGORIAS_PRODUCTO,
  categoriaCanon,
  categoriasCoinciden,
  categoriaPasaFiltro,
  categoriaVitrina,
  categoriaVitrinaPasaFiltro,
  esCategoriaAntibiotico,
  esMedicamentoControlado,
  esProductoHidratacionOral,
  opcionesCategoriaSelect,
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
    expect(categoriaCanon("Hidratación / electrolitos")).toBe("Hidratación");
    expect(categoriaCanon("Electrolitos")).toBe("Hidratación");
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

  test("electrolitos van a Hidratación aunque el ticket los haya puesto en Higiene", () => {
    const electrolit = { nombre: "Electrolit Uva", marca: "Electrolit", categoria: "Higiene" };
    const pedialyte = { nombre: "Pedialyte fresa", marca: "Pedialyte", categoria: "Otro" };
    const suerox = { nombre: "Suerox 8 Iones Coco 630 ML", marca: "Suerox", categoria: "GENERAL" };
    const shampoo = { nombre: "Pantene Brillo Extremo", marca: "Pantene", categoria: "Higiene" };
    expect(esProductoHidratacionOral(electrolit)).toBe(true);
    expect(categoriaVitrina(electrolit)).toBe("Hidratación");
    expect(categoriaVitrina(pedialyte)).toBe("Hidratación");
    expect(categoriaVitrina(suerox)).toBe("Hidratación");
    expect(categoriaVitrinaPasaFiltro(electrolit, "Hidratación")).toBe(true);
    expect(categoriaVitrinaPasaFiltro(electrolit, "Higiene")).toBe(false);
    expect(categoriaVitrina(shampoo)).toBe("Higiene");
    expect(categoriaVitrinaPasaFiltro(shampoo, "Hidratación")).toBe(false);
  });

  test("el select conserva un valor huérfano para no pisarlo al abrir", () => {
    const opts = opcionesCategoriaSelect("Producto");
    expect(opts[0]).toBe("Producto");
    expect(opts).toContain("Analgésico");
  });
});
