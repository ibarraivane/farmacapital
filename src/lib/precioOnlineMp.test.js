import {
  precioOnlineMp,
  precioAnclaUsable,
  cargoPlataformaOnline,
  totalPedidoConPlataforma,
  esEntregaConServicio,
  TASA_MP_ONLINE,
  CONCEPTO_CARGO_PLATAFORMA,
} from "./precioOnlineMp";

const espejo = require("../../api/_lib/precioOnlineMp");

test("tarjeta solo 3.49%+IVA; Servicio $5 solo en domicilio", () => {
  expect(TASA_MP_ONLINE).toBeCloseTo(0.0349 * 1.16, 6);
  expect(CONCEPTO_CARGO_PLATAFORMA).toBe("Servicio");
  expect(esEntregaConServicio("cdmx")).toBe(true);
  expect(esEntregaConServicio("envio")).toBe(true);
  expect(esEntregaConServicio("pickup")).toBe(false);
  expect(esEntregaConServicio("recoger")).toBe(false);
  expect(cargoPlataformaOnline("envio")).toBe(5);
  expect(cargoPlataformaOnline("cdmx")).toBe(5);
  expect(cargoPlataformaOnline("pickup")).toBe(0);
  expect(cargoPlataformaOnline("recoger")).toBe(0);
  expect(espejo.cargoPlataformaOnline("recoger")).toBe(0);
});

test("Skittles: pick-up $11; domicilio $11 + $5 = $16", () => {
  expect(precioOnlineMp(10)).toBe(11);
  expect(totalPedidoConPlataforma(11, "pickup")).toBe(11);
  expect(totalPedidoConPlataforma(11, "recoger")).toBe(11);
  expect(totalPedidoConPlataforma(11, "cdmx")).toBe(16);
  expect(totalPedidoConPlataforma(55, "envio")).toBe(60);
  expect(espejo.totalPedidoConPlataforma(11, "pickup")).toBe(11);
});

test("placeholder <= $0.01 no se paga en línea", () => {
  expect(precioAnclaUsable(0.01)).toBe(false);
  expect(precioOnlineMp(0.01)).toBeNull();
  expect(totalPedidoConPlataforma(0)).toBeNull();
});
