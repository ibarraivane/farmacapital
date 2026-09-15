import {
  calcularCostoEnvio,
  checkoutPuedePedirEnvio,
  estimarEnvioDesdeCoords,
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
    expect(calcularCostoEnvio({ distanciaKm: 5.01 }).ok).toBe(false);
  });

  test("checkout bloquea fuera de radio y permite pickup", () => {
    expect(checkoutPuedePedirEnvio({ entrega: "pickup", direccionOk: true })).toBe(true);
    expect(checkoutPuedePedirEnvio({
      entrega: "cdmx",
      direccionOk: true,
      estimacion: { ok: false, error: "fuera_radio" },
    })).toBe(false);
    expect(checkoutPuedePedirEnvio({
      entrega: "cdmx",
      direccionOk: true,
      estimacion: { ok: true, costo: 30 },
    })).toBe(true);
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
    expect(est.costo).toBe(30);
  });

  test("SLA restante no es negativo", () => {
    const past = new Date(Date.now() - 60_000).toISOString();
    expect(minutosRestantesCotizacion(past)).toBe(0);
    expect(proveedorSugerido("Roma")).toBe("didi");
  });
});
