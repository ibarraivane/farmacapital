import {
  CATEGORIAS_PRODUCTO,
  categoriaCanon,
  categoriasCoinciden,
  categoriaPasaFiltro,
  categoriaVitrina,
  categoriaVitrinaPasaFiltro,
  chipsAreaTienda,
  esDermocosmeticoCatalogo,
  esMedicamentoCatalogo,
  productoPasaAreaTienda,
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

  test("Medicamentos y Dermocosmética no arrastran nutrición ni la vitrina entera", () => {
    const ibuprofeno = { nombre: "Ibuprofeno 400 mg", categoria: "Analgésico" };
    const ensure = { nombre: "Ensure vainilla", categoria: "Suplemento" };
    const eucerin = { nombre: "Eucerin pH5", categoria: "Cuidado personal", subcategoria: "Dermatología" };
    const whey = { nombre: "Whey Gold", categoria: "Suplemento", subcategoria: "Proteína", bajo_pedido: true };
    expect(esMedicamentoCatalogo(ibuprofeno)).toBe(true);
    expect(esMedicamentoCatalogo(ensure)).toBe(false);
    expect(productoPasaAreaTienda(ibuprofeno, "Medicamentos")).toBe(true);
    expect(productoPasaAreaTienda(ensure, "Medicamentos")).toBe(false);
    expect(productoPasaAreaTienda(eucerin, "Medicamentos")).toBe(false);
    expect(esDermocosmeticoCatalogo(eucerin)).toBe(true);
    expect(productoPasaAreaTienda(eucerin, "Dermocosmética")).toBe(true);
    expect(productoPasaAreaTienda(whey, "Dermocosmética")).toBe(false);
    expect(productoPasaAreaTienda(ensure, "Nutrición")).toBe(true);
    const vitamina = { nombre: "Vitamina C 500 mg", categoria: "Vitaminas" };
    const suero = { nombre: "Electrolit Uva", categoria: "Hidratación" };
    const tensiometro = { nombre: "Tensiómetro de brazo", categoria: "Dispositivo médico" };
    const gasa = { nombre: "Gasa estéril", categoria: "Botiquín" };
    const shampoo = { nombre: "Shampoo neutro", categoria: "Higiene" };
    expect(productoPasaAreaTienda(vitamina, "Nutrición")).toBe(true);
    expect(productoPasaAreaTienda(suero, "Nutrición")).toBe(false);
    expect(productoPasaAreaTienda(suero, "Farmacia")).toBe(true);
    expect(productoPasaAreaTienda(shampoo, "Farmacia")).toBe(true);
    expect(productoPasaAreaTienda(tensiometro, "Dispositivos médicos")).toBe(true);
    expect(productoPasaAreaTienda(gasa, "Dispositivos médicos")).toBe(false);
    expect(productoPasaAreaTienda(gasa, "Botiquín")).toBe(true);
    expect(productoPasaAreaTienda(ibuprofeno, "Dispositivos médicos")).toBe(false);
    expect(productoPasaAreaTienda(ensure, "Farmacia")).toBe(false);
    expect(chipsAreaTienda([ibuprofeno, ensure, eucerin], "Medicamentos")).toEqual(["Medicamentos", "Antiinflamatorio"]);
    expect(chipsAreaTienda([tensiometro, gasa], "Dispositivos médicos")).toEqual(["Dispositivos médicos"]);
    expect(chipsAreaTienda([gasa], "Botiquín")).toEqual(["Botiquín"]);
  });

  test("el select conserva un valor huérfano para no pisarlo al abrir", () => {
    const opts = opcionesCategoriaSelect("Producto");
    expect(opts[0]).toBe("Producto");
    expect(opts).toContain("Analgésico");
  });
});
