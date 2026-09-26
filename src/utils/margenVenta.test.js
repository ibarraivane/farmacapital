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

test("venta de blister usa el costo de la tira, no el de la caja ni el de la pieza", () => {
  const prod = {
    categoria: "Analgésico",
    costo: 80,
    precio: 120,
    precio_unidad: 8,
    precio_blister: 45,
    venta_unidad: true,
    unidades_por_caja: 30,
    piezas_por_blister: 10,
  };
  const blister = { precio_unitario: 45, cantidad: 2, modo_venta: "blister", productos: prod };
  expect(lineaEsVentaUnidad(blister)).toBe(false);
  expect(costoLineaVenta(blister)).toBeCloseTo((80 / 3) * 2, 3);

  const inferido = { precio_unitario: 45, cantidad: 1, productos: prod };
  expect(costoLineaVenta(inferido)).toBeCloseTo(80 / 3, 3);

  const pieza = { precio_unitario: 8, cantidad: 1, productos: prod };
  expect(lineaEsVentaUnidad(pieza)).toBe(true);
  expect(costoLineaVenta(pieza)).toBeCloseTo(80 / 30, 3);
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
