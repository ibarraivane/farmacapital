import {
  agruparLotesPorProducto,
  filasJson,
  loteObjetivoProveedor,
  patchProductoSinColumnaProveedor,
  productoIdDeLote,
  proveedorDesdeLotes,
} from "./inventarioHubData";

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

test("proveedor visible es el lote activo con más piezas", () => {
  const lotes = [
    { id: 1, cantidad_actual: 2, activo: true, proveedores: { nombre: "El Surtidor de su Farmacia" } },
    { id: 2, cantidad_actual: 8, activo: true, proveedores: { nombre: "Nadro" } },
    { id: 3, cantidad_actual: 20, activo: false, proveedores: { nombre: "Viejo" } },
  ];
  expect(loteObjetivoProveedor(lotes).id).toBe(2);
  expect(proveedorDesdeLotes(lotes)).toBe("Nadro");
});

test("sin nombre en lotes, el proveedor de tabla queda vacío", () => {
  expect(proveedorDesdeLotes([{ id: 1, cantidad_actual: 4, activo: true }])).toBe("");
});

test("el patch de ficha no manda productos.proveedor", () => {
  expect(patchProductoSinColumnaProveedor({ nombre: "Alcohol", proveedor: "Nadro" })).toEqual({
    nombre: "Alcohol",
  });
  expect(patchProductoSinColumnaProveedor({ precio: 20 })).toEqual({ precio: 20 });
});
