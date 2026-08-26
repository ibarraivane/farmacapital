import {
  precioMostradorPos,
  productoCajaEsFalsa,
  stockMostradorPos,
} from "./productoCajaFalsa";

test("Jaloma pomada: el pote de 60 no es una caja", () => {
  expect(
    productoCajaEsFalsa({
      venta_unidad: true,
      unidades_por_caja: 60,
      precio: 8,
      precio_unidad: 6,
      nombre: "Jaloma pomada labios sabores 3 g",
      presentacion: "3 g",
      forma_farmaceutica: "Pomada",
    }),
  ).toBe(true);
});

test("venda Quirmex: cada rollo, no la caja de 12", () => {
  expect(
    productoCajaEsFalsa({
      venta_unidad: true,
      unidades_por_caja: 12,
      precio: 8.16,
      precio_unidad: 6,
      nombre: "Quirmex venda elastica premium 5 cm x 5 m",
      presentacion: "5 CM x 5 M",
    }),
  ).toBe(true);
});

test("Chupón y jeringa C/1 también son pieza", () => {
  expect(
    productoCajaEsFalsa({
      venta_unidad: true,
      unidades_por_caja: 18,
      precio: 6,
      precio_unidad: 6,
      nombre: "Chupón con miel Ternura",
      presentacion: "1 PZA",
    }),
  ).toBe(true);
  expect(
    productoCajaEsFalsa({
      venta_unidad: true,
      unidades_por_caja: 100,
      precio: 1,
      precio_unidad: 1,
      nombre: "Aguja-Hipodermica-Sensimedical 22G",
      presentacion: "C/1",
    }),
  ).toBe(true);
});

test("no marca cajas reales de mostrador", () => {
  expect(
    productoCajaEsFalsa({
      venta_unidad: true,
      unidades_por_caja: 100,
      precio: 347,
      precio_unidad: 8,
      nombre: "Alka-Seltzer",
    }),
  ).toBe(false);
  expect(
    productoCajaEsFalsa({
      venta_unidad: true,
      unidades_por_caja: 3,
      precio: 543,
      precio_unidad: 218,
      nombre: "Dolo-Neurobion solucion inyectable C/3",
      presentacion: "C/3 jeringas prellenadas 3 mL",
    }),
  ).toBe(false);
  expect(
    productoCajaEsFalsa({
      venta_unidad: true,
      unidades_por_caja: 8,
      precio: 19.29,
      precio_unidad: 7,
      nombre: "Saba buenas noches",
      presentacion: "C/8",
    }),
  ).toBe(false);
});

test("óxido de zinc C/50 es frasco, no 50 piezas", () => {
  expect(
    productoCajaEsFalsa({
      venta_unidad: true,
      unidades_por_caja: 50,
      precio: 14,
      precio_unidad: 7,
      nombre: "Mercurio Oxido De Zinc",
      presentacion: "C/50",
      forma_farmaceutica: "Pomada",
    }),
  ).toBe(false);
});

test("sin venta_unidad no aplica", () => {
  expect(productoCajaEsFalsa({ venta_unidad: false, precio: 6, precio_unidad: 6, unidades_por_caja: 60 })).toBe(false);
});

test("stock y precio de mostrador usan la pieza", () => {
  const jaloma = {
    venta_unidad: true,
    unidades_por_caja: 60,
    precio: 8,
    precio_unidad: 6,
    stock_unidades: 60,
    nombre: "Jaloma pomada labios sabores 3 g",
    presentacion: "3 g",
  };
  expect(stockMostradorPos(jaloma, 1)).toBe(60);
  expect(precioMostradorPos(jaloma)).toBe(6);
});
