import {
  precioOnlineMp,
  precioAnclaUsable,
  cargoFijoMp,
  totalConCargoMp,
  TASA_MP_ONLINE,
  FIJO_MP_CON_IVA,
} from "./precioOnlineMp";

const espejo = require("../../api/_lib/precioOnlineMp");

function netoTrasMp(cobrado) {
  return cobrado - (cobrado * 0.0349 + 4) * 1.16;
}

test("tasa 3.49% + IVA y $4 + IVA van en la tarjeta", () => {
  expect(TASA_MP_ONLINE).toBeCloseTo(0.0349 * 1.16, 6);
  expect(cargoFijoMp()).toBe(4.64);
  expect(espejo.cargoFijoMp()).toBe(4.64);
  expect(FIJO_MP_CON_IVA).toBeCloseTo(4.64, 6);
});

test("ceil a peso: Skittles $10 → $16 (cubre % + $4 + IVA)", () => {
  const casos = [
    [10, 16],
    [42, 49],
    [25, 31],
    [100, 110],
    [459, 484],
    [389, 411],
    [899, 942],
    [1, 6],
  ];
  for (const [ancla, web] of casos) {
    expect(precioOnlineMp(ancla)).toBe(web);
    expect(espejo.precioOnlineMp(ancla)).toBe(web);
    expect(netoTrasMp(web)).toBeGreaterThanOrEqual(ancla - 0.02);
  }
});

test("$11 no cubre el $4: una pieza a $16 sí deja el ancla", () => {
  expect(netoTrasMp(11)).toBeLessThan(10);
  expect(netoTrasMp(16)).toBeGreaterThanOrEqual(10);
});

test("checkout solo suma tarjetas: no se vuelve a cobrar el $4", () => {
  const unit = precioOnlineMp(10);
  expect(unit).toBe(16);
  expect(totalConCargoMp(unit)).toBe(16);
  expect(totalConCargoMp(unit * 5)).toBe(80);
  expect(espejo.totalConCargoMp(unit * 5)).toBe(80);
});

test("placeholder <= $0.01 no se paga en línea", () => {
  expect(precioAnclaUsable(0.01)).toBe(false);
  expect(precioOnlineMp(0.01)).toBeNull();
  expect(totalConCargoMp(0)).toBeNull();
});
