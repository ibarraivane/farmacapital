import {
  aplicarReglaPrecioUnidad,
  blistersPorCaja,
  calcPrecioBlister,
  calcPrecioUnidad,
  margenBrutoPct,
  precioBlisterParaVenta,
  precioUnidadParaVenta,
  productoVendeBlister,
  unidadesAlAbrirCaja,
} from "./precioUnidad";

const gasa = {
  venta_unidad: true,
  unidades_por_caja: 100,
  precio: 164,
  costo: 108.88,
  categoria: "Botiquín",
  tipo: "marca",
};

test("regla sugiere $7 para gasa C/100", () => {
  expect(calcPrecioUnidad(gasa.precio, gasa.costo, 100, gasa.categoria, gasa.tipo)).toBe(7);
});

test("guardar $3 no lo sube a la regla", () => {
  expect(aplicarReglaPrecioUnidad({ ...gasa, precio_unidad: 3 }).precio_unidad).toBe(3);
});

test("POS cobra el precio que se guardó", () => {
  expect(precioUnidadParaVenta({ ...gasa, precio_unidad: 3 })).toBe(3);
});

test("si no hay precio, usa la regla", () => {
  expect(aplicarReglaPrecioUnidad({ ...gasa, precio_unidad: 0 }).precio_unidad).toBe(7);
  expect(precioUnidadParaVenta({ ...gasa, precio_unidad: 0 })).toBe(7);
});

test("margen de pieza es sobre el precio, no sobre el costo", () => {
  expect(margenBrutoPct(130, 100)).toBe(23.1);
  expect(margenBrutoPct(0, 100)).toBe(0);
});

const cajaBlister = {
  venta_unidad: true,
  unidades_por_caja: 30,
  piezas_por_blister: 10,
  precio: 120,
  costo: 80,
  categoria: "Analgésico",
  tipo: "marca",
};

test("30 tabletas en blister de 10 parten en 3; 28 no", () => {
  expect(blistersPorCaja(30, 10)).toBe(3);
  expect(blistersPorCaja(28, 10)).toBe(0);
  expect(blistersPorCaja(30, 0)).toBe(0);
  expect(blistersPorCaja(30, 1)).toBe(0);
  expect(blistersPorCaja(10, 10)).toBe(0);
  expect(productoVendeBlister(cajaBlister)).toBe(true);
  expect(productoVendeBlister({ ...cajaBlister, venta_unidad: false })).toBe(false);
  expect(productoVendeBlister({ ...cajaBlister, piezas_por_blister: 10, unidades_por_caja: 28 })).toBe(false);
});

test("blister usa la regla de pieza con divisor 3: caja $120 → blister $45", () => {
  expect(calcPrecioBlister(120, 80, 30, 10, "Analgésico", "marca")).toBe(45);
  expect(calcPrecioUnidad(120, 80, 30, "Analgésico", "marca")).toBe(8);
});

test("POS cobra el precio de blister guardado, o la regla si está en 0", () => {
  expect(precioBlisterParaVenta({ ...cajaBlister, precio_blister: 40 })).toBe(40);
  expect(precioBlisterParaVenta({ ...cajaBlister, precio_blister: 0 })).toBe(45);
  expect(precioBlisterParaVenta({ ...cajaBlister, venta_unidad: false, precio_blister: 40 })).toBe(0);
});

test("abrir caja con blister suma tiras; sin blister suma piezas", () => {
  expect(unidadesAlAbrirCaja(cajaBlister)).toEqual({ stock: "blisters", cantidad: 3 });
  expect(unidadesAlAbrirCaja({ ...gasa })).toEqual({ stock: "unidades", cantidad: 100 });
  expect(aplicarReglaPrecioUnidad({ ...cajaBlister, precio_unidad: 8, precio_blister: 0 }).precio_blister).toBe(45);
  expect(aplicarReglaPrecioUnidad({ ...cajaBlister, precio_unidad: 8, precio_blister: 40 }).precio_blister).toBe(40);
  expect(aplicarReglaPrecioUnidad({ ...cajaBlister, piezas_por_blister: 0, stock_blisters: 2 }).stock_blisters).toBe(0);
});
