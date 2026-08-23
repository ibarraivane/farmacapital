import { compensacionMpDe, compensacionMpDeFila, costoLiquidacionDe, esMismoDiaMexico, fechaLocalMexico, labelMetodoServicio, parseSaldoConfig, recargoEsValido, tituloTicketServicio, utilidadServicio } from "./pagoServicio";

describe("pagoServicio", () => {
  test("compensación MP es 1% redondeado a centavos", () => {
    expect(compensacionMpDe(100)).toBe(1);
    expect(compensacionMpDe(50)).toBe(0.5);
    expect(compensacionMpDe(33)).toBe(0.33);
    expect(compensacionMpDe(0)).toBe(0);
  });

  test("costo de liquidación es el monto bruto", () => {
    expect(costoLiquidacionDe(100)).toBe(100);
    expect(costoLiquidacionDe("200.4")).toBe(200.4);
  });

  test("utilidad suma recargo de farmacia + compensación MP", () => {
    expect(utilidadServicio({ comision: 5, compensacionMp: 1 })).toBe(6);
  });

  test("fila usa compensacion_mp si viene; si no, estima 1%", () => {
    expect(compensacionMpDeFila({ monto_servicio: 100, compensacion_mp: 1.4 })).toBe(1.4);
    expect(compensacionMpDeFila({ monto_servicio: 100 })).toBe(1);
  });

  test("recargo en cero o vacío no es válido", () => {
    expect(recargoEsValido(5)).toBe(true);
    expect(recargoEsValido(0)).toBe(false);
    expect(recargoEsValido("")).toBe(false);
    expect(recargoEsValido(null)).toBe(false);
  });

  test("saldo de recargas avisa solo si ya lo cargó el admin y está bajo el mínimo", () => {
    expect(parseSaldoConfig([]).configurado).toBe(false);
    expect(parseSaldoConfig([]).bajo).toBe(false);
    expect(parseSaldoConfig([
      { clave: "saldo_mp_recargas", valor: "320" },
      { clave: "saldo_mp_recargas_minimo", valor: "500" },
    ]).bajo).toBe(true);
    expect(parseSaldoConfig([
      { clave: "saldo_mp_recargas", valor: "800" },
    ]).bajo).toBe(false);
  });

  test("el ticket de recarga se titula RECARGA + operadora", () => {
    expect(tituloTicketServicio("recarga", "Telcel")).toBe("RECARGA TELCEL");
    expect(tituloTicketServicio("luz", "CFE")).toBe("PAGO CFE");
    expect(labelMetodoServicio("tarjeta")).toBe("Tarjeta Point");
  });

  test("el día de la farmacia es el de Ciudad de México", () => {
    const medianocheMexicoComoUtc = new Date("2026-08-22T06:00:00.000Z");
    expect(fechaLocalMexico(medianocheMexicoComoUtc)).toBe("2026-08-22");
    expect(esMismoDiaMexico("2026-08-22T18:00:00.000Z", "2026-08-22")).toBe(true);
    expect(esMismoDiaMexico("2026-08-22T05:00:00.000Z", "2026-08-22")).toBe(false);
  });
});
