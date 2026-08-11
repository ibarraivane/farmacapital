import {
  inventarioProductMatchesBusqueda,
  inventarioSearchRelevanceRank,
  tiendaProductMatchesBusqueda,
} from "./fuzzySearch";

const tensolastic7 = {
  id: 1,
  activo: true,
  nombre: "Tensolastic Plus Venda Elasti",
  presentacion: "7 CM x 5 M",
  marca: "Protec",
  sku: "FC-48690909",
  codigo_barras: "7501048690909",
  descripcion: "Protec Tensolastic Plus 7Cmx5M Venda Elasti — Ticket 77827",
};

const loxcelGarbage = {
  id: 2,
  activo: true,
  nombre:
    "(A) Loxcel Adto Tab C/1 | Lab Hormona 2 $ 78.00 Descto: 6.0% $ 73.32 Adto Tab C/1 | Lab Hormona 2",
  sku: "FC-24227339",
  codigo_barras: "7502224227339",
  descripcion: "Protec Tensolastic Plus 7Cmx5M Venda Elasti — Ticket 77827",
  presentacion: "C/1",
};

const centrum = {
  id: 3,
  activo: true,
  nombre: "Centrum Tab",
  presentacion: "",
  sku: "FC-65095718",
  codigo_barras: "7501065095718",
};

describe("catalog search dimensions", () => {
  test("Tensolastic 7 cm matches venda 7 cm", () => {
    expect(inventarioProductMatchesBusqueda(tensolastic7, "Tensolastic 7 cm")).toBe(true);
    expect(tiendaProductMatchesBusqueda(tensolastic7, "Tensolastic 7 cm")).toBe(true);
  });

  test("OCR garbage with prices does not match Tensolastic 7 cm", () => {
    expect(inventarioProductMatchesBusqueda(loxcelGarbage, "Tensolastic 7 cm")).toBe(false);
  });

  test("descripcion OCR compartida no hace match en inventario", () => {
    expect(inventarioProductMatchesBusqueda(loxcelGarbage, "Tensolastic 7 cm")).toBe(false);
  });

  test("Centrum no matchea por substring cm", () => {
    expect(inventarioProductMatchesBusqueda(centrum, "Tensolastic 7 cm")).toBe(false);
  });

  test("Tensolastic 7 cm rankea antes que ruido", () => {
    expect(inventarioSearchRelevanceRank(tensolastic7, "Tensolastic 7 cm")).toBeLessThan(
      inventarioSearchRelevanceRank(loxcelGarbage, "Tensolastic 7 cm")
    );
  });

  test("busqueda por SKU sigue funcionando", () => {
    expect(inventarioProductMatchesBusqueda(tensolastic7, "FC-48690909")).toBe(true);
    expect(inventarioProductMatchesBusqueda(tensolastic7, "7501048690909")).toBe(true);
  });

  test("pañal no matchea lubricante íntimo por marca piel con piel", () => {
    const lubricante = {
      id: 99,
      activo: true,
      nombre: "Lubricante íntimo",
      marca: "Piel con Piel",
      categoria: "Higiene",
      sku: "FC-60101378",
      codigo_barras: "7506460101378",
    };
    const panal = {
      id: 100,
      activo: true,
      nombre: "Pañal Diapro Grande",
      categoria: "Higiene",
      sku: "FC-43475816",
      codigo_barras: "7501943475014",
    };
    expect(inventarioProductMatchesBusqueda(lubricante, "pañal")).toBe(false);
    expect(inventarioProductMatchesBusqueda(panal, "pañal")).toBe(true);
    expect(inventarioSearchRelevanceRank(panal, "pañal")).toBeLessThan(20);
  });
});
