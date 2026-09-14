import { desgloseMixto, parseMontoPago, mensajeErrorMixto } from "./pagoMixto.js";

describe("pagoMixto", () => {
  test("parseMontoPago acepta $ y comas", () => {
    expect(parseMontoPago("$120.50")).toBe(120.5);
    expect(parseMontoPago("1,200.00")).toBe(1200);
  });

  test("desgloseMixto parte la cuenta", () => {
    expect(desgloseMixto(100, "40")).toEqual({ ok: true, efectivo: 40, tarjeta: 60 });
    expect(desgloseMixto(99.99, "50")).toEqual({ ok: true, efectivo: 50, tarjeta: 49.99 });
  });

  test("desgloseMixto rechaza extremos", () => {
    expect(desgloseMixto(100, "0").ok).toBe(false);
    expect(desgloseMixto(100, "100").reason).toBe("todo_efectivo");
    expect(desgloseMixto(100, "").reason).toBe("efectivo_invalido");
  });

  test("mensajeErrorMixto es usable en mostrador", () => {
    expect(mensajeErrorMixto("todo_efectivo", 80, (n) => `$${n}`)).toMatch(/Efectivo/);
  });
});
