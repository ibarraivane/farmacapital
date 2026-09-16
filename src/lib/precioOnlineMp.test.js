import {
  precioOnlineMp,
  precioAnclaUsable,
  TASA_MP_ONLINE,
  FIJO_MP_MXN,
  IVA_MP,
  FIJO_MP_CON_IVA,
} from "./precioOnlineMp";

const espejo = require("../../api/_lib/precioOnlineMp");

test("tasa fija Checkout MX 3.49% + $4 + IVA, sin línea extra en checkout", () => {
  expect(TASA_MP_ONLINE).toBeCloseTo(0.0349 * 1.16, 6);
  expect(FIJO_MP_MXN).toBe(4);
  expect(IVA_MP).toBe(1.16);
  expect(FIJO_MP_CON_IVA).toBeCloseTo(4.64, 6);
  expect(espejo.TASA_MP_ONLINE).toBe(TASA_MP_ONLINE);
  expect(espejo.FIJO_MP_CON_IVA).toBe(FIJO_MP_CON_IVA);
});

test("ceil a peso entero y a la farmacia le queda al menos el ancla tras 3.49%+$4+IVA", () => {
  const casos = [
    [10, 16],
    [100, 110],
    [459, 484],
    [25, 31],
    [42, 49],
    [389, 411],
    [899, 942],
    [1, 6],
    [95.9516, 105],
  ];
  for (const [ancla, web] of casos) {
    expect(precioOnlineMp(ancla)).toBe(web);
    expect(espejo.precioOnlineMp(ancla)).toBe(web);
    const neto = web * (1 - TASA_MP_ONLINE) - FIJO_MP_CON_IVA;
    expect(neto).toBeGreaterThanOrEqual(ancla - 0.005);
  }
});

test("el checkout solo suma precios de tarjeta: 2 Skittles = 2 × $16, sin +$4 extra", () => {
  const unit = precioOnlineMp(10);
  expect(unit).toBe(16);
  expect(unit * 2).toBe(32);
});

test("placeholder <= $0.01 no se paga en línea", () => {
  expect(precioAnclaUsable(0.01)).toBe(false);
  expect(precioAnclaUsable(0.02)).toBe(true);
  expect(precioOnlineMp(0.01)).toBeNull();
  expect(precioOnlineMp(0)).toBeNull();
  expect(precioOnlineMp("abc")).toBeNull();
});
