import {
  canalIngresoPedido,
  mapUiEntregaToRpc,
  productoPermitidoEnTiendaWeb,
  FULFILLMENT_TYPE,
} from "./orderChannels";

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

describe("mapUiEntregaToRpc", () => {
  test("CDMX usa Uber Direct", () => {
    const m = mapUiEntregaToRpc("cdmx");
    expect(m.tipo_entrega).toBe("envio");
    expect(m.fulfillment_type).toBe(FULFILLMENT_TYPE.UBER_DIRECT);
  });
  test("si Uber no cotiza, el envío lo coordina la farmacia", () => {
    const m = mapUiEntregaToRpc("cdmx", { uberQuoted: false });
    expect(m.tipo_entrega).toBe("envio");
    expect(m.fulfillment_type).toBe(FULFILLMENT_TYPE.OWN_DELIVERY);
  });
  test("pick-up sigue en tienda", () => {
    expect(mapUiEntregaToRpc("pickup").tipo_entrega).toBe("recoger");
  });
});

describe("productoPermitidoEnTiendaWeb", () => {
  test("con receta (no controlado) sí entra al carrito", () => {
    expect(
      productoPermitidoEnTiendaWeb({
        activo: true,
        requiere_receta: true,
        controlado: false,
        nombre: "Exkruthera",
      }),
    ).toBe(true);
  });
  test("controlado no se vende online", () => {
    expect(
      productoPermitidoEnTiendaWeb({
        activo: true,
        requiere_receta: true,
        controlado: true,
      }),
    ).toBe(false);
    expect(
      productoPermitidoEnTiendaWeb({
        activo: true,
        grupo_controlado: "II",
      }),
    ).toBe(false);
  });
  test("inactivo u oculto no se vende", () => {
    expect(productoPermitidoEnTiendaWeb({ activo: false })).toBe(false);
    expect(productoPermitidoEnTiendaWeb({ activo: true, visible_tienda: false })).toBe(false);
  });
});
