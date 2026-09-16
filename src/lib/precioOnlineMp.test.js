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

test("tarjeta solo 3.49%+IVA; Servicio $5 una vez por pedido", () => {
  expect(TASA_MP_ONLINE).toBeCloseTo(0.0349 * 1.16, 6);
  expect(cargoPlataformaOnline()).toBe(5);
  expect(espejo.cargoPlataformaOnline()).toBe(5);
  expect(CONCEPTO_CARGO_PLATAFORMA).toBe("Servicio");
});

test("Skittles $10 → $11; 1 pieza $16, 5 piezas $60", () => {
  expect(precioOnlineMp(10)).toBe(11);
  expect(precioOnlineMp(42)).toBe(44);
  expect(espejo.precioOnlineMp(10)).toBe(11);
  expect(totalPedidoConPlataforma(11)).toBe(16);
  expect(totalPedidoConPlataforma(55)).toBe(60);
  expect(espejo.totalPedidoConPlataforma(11)).toBe(16);
  expect(netoTrasMp(16)).toBeGreaterThanOrEqual(10);
});

test("placeholder <= $0.01 no se paga en línea", () => {
  expect(precioAnclaUsable(0.01)).toBe(false);
  expect(precioOnlineMp(0.01)).toBeNull();
  expect(totalPedidoConPlataforma(0)).toBeNull();
});
