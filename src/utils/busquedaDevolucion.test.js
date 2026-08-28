import { parseBusquedaDevolucion, queryRpcDevolucion } from "./busquedaDevolucion";

describe("parseBusquedaDevolucion", () => {
  test("folio VTA identifica el pedido, no un teléfono", () => {
    expect(parseBusquedaDevolucion("VTA-00000123")).toEqual({ tipo: "id", id: 123, q: "VTA-00000123" });
    expect(queryRpcDevolucion("VTA-00000123")).toBe("123");
  });

  test("teléfono de 10 dígitos no se trata como ID", () => {
    expect(parseBusquedaDevolucion("5537275035")).toEqual({
      tipo: "tel",
      tel10: "5537275035",
      q: "5537275035",
    });
    expect(parseBusquedaDevolucion("52 55 3727 5035").tipo).toBe("tel");
  });

  test("ID corto del ticket", () => {
    expect(parseBusquedaDevolucion("42")).toEqual({ tipo: "id", id: 42, q: "42" });
  });
});
