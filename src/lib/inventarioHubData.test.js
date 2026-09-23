import {
  agruparLotesPorProducto,
  enriquecerProductoConLotes,
  filasJson,
  loteObjetivoProveedor,
  patchProductoSinColumnaProveedor,
  productoIdDeLote,
  proveedorDesdeLotes,
  stockAnaquelDeProducto,
  stockAnaquelEfectivo,
  stockDesdeLotes,
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

test("stock anaquel usa GREATEST(columna, lotes) tras Recibir sin sync", () => {
  // Columna aún en 0, lotes ya tienen piezas → no es agotado
  expect(stockAnaquelEfectivo({ stock: 0 }, [
    { cantidad_actual: 6, activo: true },
    { cantidad_actual: 0, activo: true },
  ])).toBe(6);
  // Columna con piezas, solo cascarones qty 0 → no tapa el anaquel
  expect(stockAnaquelEfectivo({ stock: 4 }, [
    { cantidad_actual: 0, activo: true },
  ])).toBe(4);
  expect(stockDesdeLotes([{ cantidad_actual: 2, activo: true }, { cantidad_actual: 3, activo: false }])).toBe(2);
});

test("enriquecer no marca agotado si lotes o columna tienen piezas", () => {
  const desdeLotes = enriquecerProductoConLotes({ id: 1, stock: 0, nombre: "A" }, [
    { id: 10, cantidad_actual: 3, activo: true },
  ]);
  expect(desdeLotes.stock_peps).toBe(3);
  expect(stockAnaquelDeProducto(desdeLotes)).toBe(3);
  expect(desdeLotes.sinLotePeps).toBe(false);

  const desdeColumna = enriquecerProductoConLotes({ id: 2, stock: 5, nombre: "B" }, [
    { id: 11, cantidad_actual: 0, activo: true },
  ]);
  expect(desdeColumna.stock_peps).toBe(5);
  expect(desdeColumna.sinLotePeps).toBe(true);

  const agotado = enriquecerProductoConLotes({ id: 3, stock: 0, nombre: "C" }, [
    { id: 12, cantidad_actual: 0, activo: true },
  ]);
  expect(agotado.stock_peps).toBe(0);
});
