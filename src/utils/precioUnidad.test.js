import {
  aplicarReglaPrecioUnidad,
  calcPrecioUnidad,
  precioUnidadParaVenta,
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
