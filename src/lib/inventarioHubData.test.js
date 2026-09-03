import {
  agruparLotesPorProducto,
  filasJson,
  PRODUCTOS_SELECT_HUB,
  PRODUCTOS_SELECT_LOTES,
  productoIdDeLote,
} from "./inventarioHubData";

test("reabasto y lotes cargan principio activo para buscar por ese rubro", () => {
  expect(PRODUCTOS_SELECT_HUB).toMatch(/principio_activo/);
  expect(PRODUCTOS_SELECT_HUB).toMatch(/denominacion_generica/);
  expect(PRODUCTOS_SELECT_LOTES).toMatch(/principio_activo/);
});

test("agrupa lotes aunque producto_id venga string o anidado", () => {
  const grouped = agruparLotesPorProducto([
    { id: 1, producto_id: "1262", cantidad_actual: 1, activo: true },
    { id: 2, productos: { id: 1262 }, cantidad_actual: 0, activo: true },
    { id: 3, producto_id: 1263, cantidad_actual: 1, activo: true },
  ]);
  expect(grouped[1262]).toHaveLength(2);
  expect(grouped[1263]).toHaveLength(1);
  expect(productoIdDeLote({ producto_id: "1262" })).toBe(1262);
});

test("filasJson acepta string o envoltura", () => {
  expect(filasJson('[{"id":1}]')).toEqual([{ id: 1 }]);
  expect(filasJson({ data: [{ id: 2 }] })).toEqual([{ id: 2 }]);
  expect(filasJson(null)).toEqual([]);
});
