import {
  precioOnlineMp,
  precioAnclaUsable,
  cargoFijoMp,
  totalConCargoMp,
  TASA_MP_ONLINE,
  FIJO_MP_CON_IVA,
} from "./precioOnlineMp";

const espejo = require("../../api/_lib/precioOnlineMp");

test("tasa 3.49% + IVA en tarjeta; $4+IVA una vez al pagar", () => {
  expect(TASA_MP_ONLINE).toBeCloseTo(0.0349 * 1.16, 6);
  expect(cargoFijoMp()).toBe(4.64);
  expect(espejo.cargoFijoMp()).toBe(4.64);
  expect(FIJO_MP_CON_IVA).toBeCloseTo(4.64, 6);
});

test("ceil a peso: Skittles $10 → $11; el $4 no se mete en cada SKU", () => {
  const casos = [
    [10, 11],
    [100, 105],
    [459, 479],
    [25, 27],
    [42, 44],
    [389, 406],
    [899, 937],
    [1, 2],
    [95.9516, 100],
  ];
  for (const [ancla, web] of casos) {
    expect(precioOnlineMp(ancla)).toBe(web);
    expect(espejo.precioOnlineMp(ancla)).toBe(web);
    expect(web * (1 - TASA_MP_ONLINE)).toBeGreaterThanOrEqual(ancla - 0.005);
  }
});

test("1 o 5 productos: el cargo fijo se suma una sola vez", () => {
  const unit = precioOnlineMp(10);
  expect(unit).toBe(11);
  expect(totalConCargoMp(unit)).toBe(15.64);
  expect(totalConCargoMp(unit * 5)).toBe(59.64);
  expect(espejo.totalConCargoMp(unit * 5)).toBe(59.64);
});

test("placeholder <= $0.01 no se paga en línea", () => {
  expect(precioAnclaUsable(0.01)).toBe(false);
  expect(precioOnlineMp(0.01)).toBeNull();
  expect(totalConCargoMp(0)).toBeNull();
});
