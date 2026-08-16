import { costoLineaVenta, ingresoLineaVenta, lineaEsVentaUnidad } from "./margenVenta";

const aspirina = {
  precio_unitario: 8,
  cantidad: 2,
  productos: {
    categoria: "Analgésico",
    costo: 35.18,
    precio: 48,
    precio_unidad: 8,
    venta_unidad: true,
    unidades_por_caja: 12,
  },
};

test("Pedido 27: dos tabletas no usan el costo de dos cajas", () => {
  expect(lineaEsVentaUnidad(aspirina)).toBe(true);
  expect(ingresoLineaVenta(aspirina)).toBe(16);
  expect(costoLineaVenta(aspirina)).toBeCloseTo(5.8633, 3);
});

test("venta de caja usa el costo completo", () => {
  const caja = {
    precio_unitario: 48,
    cantidad: 2,
    modo_venta: "caja",
    productos: aspirina.productos,
  };
  expect(lineaEsVentaUnidad(caja)).toBe(false);
  expect(costoLineaVenta(caja)).toBeCloseTo(70.36, 2);
});
