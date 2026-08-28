import { tiendaProductMatchesBusqueda, inventarioProductMatchesBusqueda } from "./fuzzySearch";

const products = [
  { id: 1, nombre: "Toallitas húmedas Huggies", marca: "Huggies", presentacion: "C/80", activo: true },
  { id: 2, nombre: "Toallitas húmedas Huggies Cuidado Humectante", marca: "Huggies", presentacion: "C/80", activo: true },
  { id: 3, nombre: "Toallitas Humedas Huggies Cuidado Puro", marca: "Huggies", presentacion: "C/80", activo: true },
];

describe("POS busca Huggies", () => {
  test.each(["huggies", "Huggies", "HUGGIES", "toallitas huggies"])("%s matchea en tienda/POS", (q) => {
    const hits = products.filter((p) => tiendaProductMatchesBusqueda(p, q));
    expect(hits.length).toBe(3);
  });

  test("inventario también matchea huggies", () => {
    expect(products.every((p) => inventarioProductMatchesBusqueda(p, "huggies"))).toBe(true);
  });
});
