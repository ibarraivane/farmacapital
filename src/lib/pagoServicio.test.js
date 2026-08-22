import { compensacionMpDe, compensacionMpDeFila, costoLiquidacionDe, utilidadServicio } from "./pagoServicio";

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
});
