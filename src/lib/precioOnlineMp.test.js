import {
  precioOnlineMp,
  precioAnclaUsable,
  cargoPlataformaOnline,
  totalPedidoConPlataforma,
  TASA_MP_ONLINE,
  CONCEPTO_CARGO_PLATAFORMA,
} from "./precioOnlineMp";

const espejo = require("../../api/_lib/precioOnlineMp");

function netoTrasMp(cobrado) {
  return cobrado - (cobrado * 0.0349 + 4) * 1.16;
}

test("tarjeta solo 3.49%+IVA; $4+IVA una vez por pedido", () => {
  expect(TASA_MP_ONLINE).toBeCloseTo(0.0349 * 1.16, 6);
  expect(cargoPlataformaOnline()).toBe(4.64);
  expect(espejo.cargoPlataformaOnline()).toBe(4.64);
  expect(CONCEPTO_CARGO_PLATAFORMA).toMatch(/Pedido en línea/);
});

test("Skittles $10 → $11 en tarjeta; 1 pieza $15.64, 5 piezas $59.64", () => {
  expect(precioOnlineMp(10)).toBe(11);
  expect(precioOnlineMp(42)).toBe(44);
  expect(precioOnlineMp(459)).toBe(479);
  expect(precioOnlineMp(25)).toBe(27);
  expect(espejo.precioOnlineMp(10)).toBe(11);
  expect(totalPedidoConPlataforma(11)).toBe(15.64);
  expect(totalPedidoConPlataforma(55)).toBe(59.64);
  expect(espejo.totalPedidoConPlataforma(11)).toBe(15.64);
  expect(netoTrasMp(15.64)).toBeGreaterThanOrEqual(10 - 0.05);
});

test("placeholder <= $0.01 no se paga en línea", () => {
  expect(precioAnclaUsable(0.01)).toBe(false);
  expect(precioOnlineMp(0.01)).toBeNull();
  expect(totalPedidoConPlataforma(0)).toBeNull();
});
