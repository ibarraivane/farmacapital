import {
  aplicarReglaPrecioUnidad,
  blistersPorCaja,
  calcPrecioBlister,
  calcPrecioUnidad,
  precioBlisterIntermedio,
  normalizarStockAbierto,
  piezasComprometidas,
  margenBrutoPct,
  piezasPorBlisterDefault,
  precioBlisterParaVenta,
  precioBlisterQueNoQuedo,
  precioCapturadoOSugerido,
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

test("blister es el punto medio entre la fracción de la caja y la pieza", () => {
  // Caja $120 / 30 = $4. Pieza sugerida $8. Tira de 10: entre $40 y $80 → $60.
  expect(calcPrecioUnidad(120, 80, 30, "Analgésico", "marca")).toBe(8);
  expect(precioBlisterIntermedio(120, 8, 30, 10)).toBe(60);
  expect(calcPrecioBlister(120, 80, 30, 10, "Analgésico", "marca")).toBe(60);
  // Amox: caja $37, pieza $10, tira de 6. Fracción $18.50, tope la caja → $28.
  expect(precioBlisterIntermedio(37, 10, 12, 6)).toBe(28);
  expect(calcPrecioBlister(37, 18.36, 12, 6, "Antibiótico", "generico", 10)).toBe(28);
});

test("POS cobra el precio de blister guardado, o el intermedio si está en 0", () => {
  expect(precioBlisterParaVenta({ ...cajaBlister, precio_blister: 40 })).toBe(40);
  expect(precioBlisterParaVenta({ ...cajaBlister, precio_unidad: 8, precio_blister: 0 })).toBe(60);
  expect(precioBlisterParaVenta({ ...cajaBlister, venta_unidad: false, precio_blister: 40 })).toBe(0);
});

test("caja que ya se vende por pieza parte en tiras de 10, de 7 o a la mitad", () => {
  expect(piezasPorBlisterDefault(30)).toBe(10);
  expect(piezasPorBlisterDefault(20)).toBe(10);
  expect(piezasPorBlisterDefault(100)).toBe(10);
  expect(piezasPorBlisterDefault(28)).toBe(7);
  expect(piezasPorBlisterDefault(21)).toBe(7);
  expect(piezasPorBlisterDefault(8)).toBe(4);
  expect(piezasPorBlisterDefault(12)).toBe(6);
  expect(piezasPorBlisterDefault(10)).toBe(5);
  expect(piezasPorBlisterDefault(15)).toBe(5);
  expect(piezasPorBlisterDefault(3)).toBe(0);
  expect(piezasPorBlisterDefault(7)).toBe(0);
  expect(piezasPorBlisterDefault(1)).toBe(0);
});

test("pastillas sueltas se rearman en blisters y el resto cortado", () => {
  // Caja de 12, tira de 6. 11 piezas ya cortadas = 1 tira entera + 5.
  expect(normalizarStockAbierto(0, 11, 6)).toEqual({ stock_blisters: 1, stock_unidades: 5, pool: 11 });
  expect(normalizarStockAbierto(2, 0, 6)).toEqual({ stock_blisters: 2, stock_unidades: 0, pool: 12 });
  expect(normalizarStockAbierto(1, 6, 6)).toEqual({ stock_blisters: 2, stock_unidades: 0, pool: 12 });
  expect(piezasComprometidas(5, 1, 6)).toBe(11);
  const guardado = aplicarReglaPrecioUnidad({
    ...cajaBlister,
    precio_unidad: 8,
    precio_blister: 60,
    stock_blisters: 0,
    stock_unidades: 25,
  });
  expect(guardado.stock_blisters).toBe(2);
  expect(guardado.stock_unidades).toBe(5);
});

test("abrir caja con blister suma tiras; sin blister suma piezas", () => {
  expect(unidadesAlAbrirCaja(cajaBlister)).toEqual({ stock: "blisters", cantidad: 3 });
  expect(unidadesAlAbrirCaja({ ...gasa })).toEqual({ stock: "unidades", cantidad: 100 });
  expect(aplicarReglaPrecioUnidad({ ...cajaBlister, precio_unidad: 8, precio_blister: 0 }).precio_blister).toBe(60);
  expect(aplicarReglaPrecioUnidad({ ...cajaBlister, precio_unidad: 8, precio_blister: 40 }).precio_blister).toBe(40);
  expect(precioCapturadoOSugerido(20, 32)).toBe(20);
  expect(precioCapturadoOSugerido(0, 32)).toBe(32);
  expect(precioCapturadoOSugerido("", 7)).toBe(7);
  expect(precioBlisterQueNoQuedo({ venta_unidad: true, precio_blister: 20 }, { precio_blister: 32 })).toBe(32);
  expect(precioBlisterQueNoQuedo({ venta_unidad: true, precio_blister: 20 }, { precio_blister: 20 })).toBe(null);
  expect(precioBlisterQueNoQuedo({ venta_unidad: true, precio_blister: 20 }, null)).toBe(null);
  expect(aplicarReglaPrecioUnidad({ ...cajaBlister, piezas_por_blister: 0, stock_blisters: 2 }).stock_blisters).toBe(0);
});
