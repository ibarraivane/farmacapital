import {
  CATEGORIAS_GASTO,
  CATEGORIA_COMPRA_INVENTARIO,
  esCompraInventario,
  gastoAfectaPl,
  etiquetaCategoriaGasto,
} from "./categoriasGasto";

describe("categoriasGasto", () => {
  test("incluye compra_inventario para el flujo (no es pérdida)", () => {
    expect(CATEGORIAS_GASTO).toContain("compra_inventario");
    expect(CATEGORIAS_GASTO).toContain("nomina");
    expect(CATEGORIAS_GASTO).toContain("renta");
  });

  test("compra de medicamento nunca afecta P&L", () => {
    expect(esCompraInventario(CATEGORIA_COMPRA_INVENTARIO)).toBe(true);
    expect(gastoAfectaPl("compra_inventario", true)).toBe(false);
    expect(gastoAfectaPl("renta", true)).toBe(true);
    expect(gastoAfectaPl("renta", false)).toBe(false);
  });

  test("etiqueta de mostrador, no el código interno", () => {
    expect(etiquetaCategoriaGasto("compra_inventario")).toBe("Compra de medicamento");
    expect(etiquetaCategoriaGasto("nomina")).toBe("Nómina");
  });
});
