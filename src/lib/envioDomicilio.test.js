import {
  calcularCostoEnvio,
  checkoutPuedePedirEnvio,
  estimarEnvioDesdeCoords,
  etiquetaEstadoEnvioCliente,
  getEnvioConfigCliente,
  haversineKm,
  minutosRestantesCotizacion,
  proveedorSugerido,
} from "./envioDomicilio";

describe("envioDomicilio cliente", () => {
  test("tabla inicial 0-2 / 2-4 / 4-5 y radio 5", () => {
    expect(calcularCostoEnvio({ distanciaKm: 1.2, subtotal: 50 }).costo).toBe(30);
    expect(calcularCostoEnvio({ distanciaKm: 3, subtotal: 230 }).costo).toBe(0);
    expect(calcularCostoEnvio({ distanciaKm: 4.5, subtotal: 100 }).costo).toBe(65);
    expect(calcularCostoEnvio({ distanciaKm: 5.01, radioMaximoKm: 5 }).ok).toBe(false);
    expect(calcularCostoEnvio({ distanciaKm: 8, radioMaximoKm: 0 }).ok).toBe(true);
  });

  test("checkout de domicilio solo pide dirección; el vendedor cotiza después", () => {
    expect(checkoutPuedePedirEnvio({ entrega: "pickup", direccionOk: true })).toBe(true);
    expect(checkoutPuedePedirEnvio({ entrega: "cdmx", direccionOk: true })).toBe(true);
    expect(checkoutPuedePedirEnvio({ entrega: "cdmx", direccionOk: false })).toBe(false);
  });

  test("sucursal a sí misma es 0 km", () => {
    const cfg = getEnvioConfigCliente();
    expect(haversineKm(cfg.sucursalLat, cfg.sucursalLng, cfg.sucursalLat, cfg.sucursalLng)).toBe(0);
    const est = estimarEnvioDesdeCoords({
      lat: cfg.sucursalLat,
      lng: cfg.sucursalLng,
      subtotal: 50,
      config: cfg,
    });
    expect(est.ok).toBe(true);
  });

  test("SLA restante no es negativo", () => {
    const past = new Date(Date.now() - 60_000).toISOString();
    expect(minutosRestantesCotizacion(past)).toBe(0);
    expect(proveedorSugerido("Roma")).toBe("didi");
  });

  test("etiqueta de cuenta: cobrado en checkout, no segundo link", () => {
    expect(etiquetaEstadoEnvioCliente({ estado: "cotizado", cobrado_en_checkout: true }, "approved")).toBe("Envío pagado");
    expect(etiquetaEstadoEnvioCliente({ estado: "cotizado", cobrado_en_checkout: true }, "pending")).toBe("Envío en el total");
    expect(etiquetaEstadoEnvioCliente({ estado: "link_enviado" }, "approved")).toBe("Listo para pagar envío");
    expect(etiquetaEstadoEnvioCliente({ estado: "en_ruta" })).toBe("En ruta");
  });
});
