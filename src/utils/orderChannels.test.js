import { canalIngresoPedido } from "./orderChannels";

describe("canalIngresoPedido", () => {
  test("Rappi y tienda web son online", () => {
    expect(canalIngresoPedido("online")).toBe("online");
  });
  test("mostrador y tipos vacíos van a física", () => {
    expect(canalIngresoPedido("tienda_fisica")).toBe("fisica");
    expect(canalIngresoPedido("")).toBe("fisica");
    expect(canalIngresoPedido("rappi")).toBe("fisica");
  });
  test("consulta y recarga no se mezclan con mostrador", () => {
    expect(canalIngresoPedido("consulta")).toBe("consulta");
    expect(canalIngresoPedido("recarga")).toBe("servicio");
  });
});
