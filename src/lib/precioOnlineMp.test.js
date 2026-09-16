import { precioOnlineMp, precioAnclaUsable, TASA_MP_ONLINE } from "./precioOnlineMp";

const espejo = require("../../api/_lib/precioOnlineMp");

test("tasa fija Checkout MX 3.49% + IVA", () => {
  expect(TASA_MP_ONLINE).toBeCloseTo(0.0349 * 1.16, 6);
  expect(espejo.TASA_MP_ONLINE).toBe(TASA_MP_ONLINE);
});

test("ceil a peso entero y a la farmacia le queda al menos el ancla", () => {
  const casos = [[10, 11], [100, 105], [459, 479], [25, 27], [42, 44], [389, 406], [899, 937], [1, 2], [95.9516, 100]];
  for (const [ancla, web] of casos) {
    expect(precioOnlineMp(ancla)).toBe(web);
    expect(espejo.precioOnlineMp(ancla)).toBe(web);
    expect(web * (1 - TASA_MP_ONLINE)).toBeGreaterThanOrEqual(ancla - 0.005);
  }
});

test("placeholder <= $0.01 no se paga en línea", () => {
  expect(precioAnclaUsable(0.01)).toBe(false);
  expect(precioAnclaUsable(0.02)).toBe(true);
  expect(precioOnlineMp(0.01)).toBeNull();
  expect(precioOnlineMp(0)).toBeNull();
  expect(precioOnlineMp("abc")).toBeNull();
});
