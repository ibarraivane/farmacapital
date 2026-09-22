import {
  canalIngresoPedido,
  mapUiEntregaToRpc,
  productoPermitidoEnTiendaWeb,
  productoPermitidoEnvioDomicilio,
  validarCarritoParaEntrega,
  pedidoCuentaEnVentas,
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

describe("pedidoCuentaEnVentas", () => {
  test("completado siempre cuenta", () => {
    expect(pedidoCuentaEnVentas({ estado: "completado", tipo: "tienda_fisica" })).toBe(true);
  });
  test("online listo con vendedora cuenta (surtido)", () => {
    expect(pedidoCuentaEnVentas({ estado: "listo", tipo: "online", atendido_por: 3 })).toBe(true);
  });
  test("online pendiente o listo sin vendedora no cuenta", () => {
    expect(pedidoCuentaEnVentas({ estado: "pendiente", tipo: "online", payment_status: "approved" })).toBe(false);
    expect(pedidoCuentaEnVentas({ estado: "listo", tipo: "online", atendido_por: null })).toBe(false);
  });
});

describe("mapUiEntregaToRpc", () => {
  test("domicilio usa mensajería (no un proveedor de marca)", () => {
    const m = mapUiEntregaToRpc("cdmx");
    expect(m.tipo_entrega).toBe("envio");
    expect(m.fulfillment_type).toBe(FULFILLMENT_TYPE.COURIER);
  });
  test("repartidor propio solo si se indica", () => {
    const m = mapUiEntregaToRpc("cdmx", { proveedor: "propio" });
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

  test("antibiótico en línea sí entra; a domicilio no (default)", () => {
    const amoxi = { activo: true, nombre: "Amoxicilina 500", categoria: "Antibiótico" };
    expect(productoPermitidoEnTiendaWeb(amoxi)).toBe(true);
    expect(productoPermitidoEnvioDomicilio(amoxi)).toBe(false);
  });

  test("antibiótico con canal suspendido no entra al carrito", () => {
    const amoxi = { activo: true, nombre: "Amoxicilina 500", categoria: "Antibiótico" };
    expect(productoPermitidoEnTiendaWeb(amoxi, { politica: { canal: "suspendido" } })).toBe(false);
  });
});

describe("validarCarritoParaEntrega · antibióticos", () => {
  const amoxi = { id: 1, activo: true, nombre: "Amoxicilina 500", categoria: "Antibiótico" };
  const stockMap = new Map([[1, amoxi]]);

  test("bloquea domicilio y permite pick-up", () => {
    expect(validarCarritoParaEntrega([{ id: 1, nombre: amoxi.nombre }], "cdmx", stockMap).ok).toBe(false);
    expect(validarCarritoParaEntrega([{ id: 1, nombre: amoxi.nombre }], "pickup", stockMap).ok).toBe(true);
  });
});
