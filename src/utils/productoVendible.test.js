import { parseDinero, productoEsVendible, productoPrecioLista } from "./productoVendible";

describe("parseDinero", () => {
  test("acepta punto y coma", () => {
    expect(parseDinero("15.5")).toBe(15.5);
    expect(parseDinero("15,5")).toBe(15.5);
    expect(parseDinero(" 3 ")).toBe(3);
  });
  test("vacío o basura", () => {
    expect(Number.isNaN(parseDinero(""))).toBe(true);
    expect(Number.isNaN(parseDinero("x"))).toBe(true);
  });
});

describe("vendible", () => {
  test("gasa $19 se puede vender; $0.01 no", () => {
    expect(productoEsVendible({ precio: 19 })).toBe(true);
    expect(productoEsVendible({ precio: 0.01 })).toBe(false);
    expect(productoPrecioLista({ precio: "19,00" })).toBe(19);
  });
});
