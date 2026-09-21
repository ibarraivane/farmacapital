import {
  precioOnlineMp,
  precioAnclaUsable,
  cargoPlataformaOnline,
  totalPedidoConPlataforma,
  esEntregaPickup,
  TASA_MP_ONLINE,
  CARGO_SERVICIO_MXN,
  CONCEPTO_CARGO_PLATAFORMA,
} from "./precioOnlineMp";

const espejo = require("../../api/_lib/precioOnlineMp");

function netoTrasMp(cobrado) {
  return cobrado - (cobrado * 0.0349 + 4) * 1.16;
}

test("tarjeta solo 3.49%+IVA; sin Servicio al cliente", () => {
  expect(TASA_MP_ONLINE).toBeCloseTo(0.0349 * 1.16, 6);
  expect(CARGO_SERVICIO_MXN).toBe(0);
  expect(cargoPlataformaOnline()).toBe(0);
  expect(cargoPlataformaOnline({ entrega: "cdmx" })).toBe(0);
  expect(cargoPlataformaOnline({ entrega: "pickup" })).toBe(0);
  expect(cargoPlataformaOnline({ tipo_entrega: "recoger" })).toBe(0);
  expect(espejo.cargoPlataformaOnline({ entrega: "pickup" })).toBe(0);
  expect(espejo.cargoPlataformaOnline({ entrega: "cdmx" })).toBe(0);
  expect(espejo.CARGO_SERVICIO_MXN).toBe(0);
  expect(CONCEPTO_CARGO_PLATAFORMA).toBe("Servicio");
  expect(esEntregaPickup("pickup")).toBe(true);
  expect(esEntregaPickup("recoger")).toBe(true);
  expect(esEntregaPickup("cdmx")).toBe(false);
});

test("el % + IVA siempre cierra a peso entero (sin centavos)", () => {
  for (const ancla of [1, 7.5, 10, 25, 42, 99.9, 100, 459]) {
    const web = precioOnlineMp(ancla);
    expect(Number.isInteger(web)).toBe(true);
  }
});

test("Skittles $10 → $11; pick-up y envío sin +$5 de Servicio", () => {
  expect(precioOnlineMp(10)).toBe(11);
  expect(precioOnlineMp(42)).toBe(44);
  expect(espejo.precioOnlineMp(10)).toBe(11);
  expect(totalPedidoConPlataforma(11, { entrega: "pickup" })).toBe(11);
  expect(totalPedidoConPlataforma(11, { entrega: "cdmx" })).toBe(11);
  expect(totalPedidoConPlataforma(55, { entrega: "cdmx" })).toBe(55);
  expect(espejo.totalPedidoConPlataforma(11, { entrega: "pickup" })).toBe(11);
  expect(espejo.totalPedidoConPlataforma(11)).toBe(11);
  expect(netoTrasMp(11)).toBeLessThan(10);
});

test("placeholder <= $0.01 no se paga en línea", () => {
  expect(precioAnclaUsable(0.01)).toBe(false);
  expect(precioOnlineMp(0.01)).toBeNull();
  expect(totalPedidoConPlataforma(0)).toBeNull();
});
