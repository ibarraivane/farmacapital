import {
  agruparLotesPorProducto,
  columnaInexistenteDeError,
  filasJson,
  inventarioDebeSalirDelSkeleton,
  loteObjetivoProveedor,
  patchProductoSinColumnaProveedor,
  productoIdDeLote,
  proveedorDesdeLotes,
  publicarFilasInventario,
  resolverCargaLotes,
  selectSinColumnaInexistente,
  stockObjetivoAjusteInline,
  stockVisibleInventario,
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

test("la celda de stock y el clic usan los lotes, no la columna desfasada", () => {
  const afrin = { stock: 4, stock_peps: 2, stock_minimo: 5 };
  expect(stockVisibleInventario(afrin)).toBe(2);
  expect(stockObjetivoAjusteInline(afrin, 2)).toBe(4);
  expect(stockObjetivoAjusteInline(afrin, 3)).toBe(5);
  expect(stockObjetivoAjusteInline(afrin, 0)).toBe(2);
  expect(stockObjetivoAjusteInline({ stock: 4, stock_peps: 4 }, 3)).toBe(3);
  expect(stockVisibleInventario({ stock: 4 })).toBe(4);
  expect(stockVisibleInventario({ stock: 4, stock_peps: 0 })).toBe(0);
});

test("la primera página saca al inventario del skeleton sin esperar lotes", () => {
  expect(inventarioDebeSalirDelSkeleton({ filas: [], primeraPaginaLista: false })).toBe(false);
  expect(inventarioDebeSalirDelSkeleton({ filas: [{ id: 1 }], primeraPaginaLista: false })).toBe(true);
  expect(inventarioDebeSalirDelSkeleton({ filas: [], primeraPaginaLista: true })).toBe(true);
  expect(inventarioDebeSalirDelSkeleton({ filas: [], error: { message: "timeout" } })).toBe(true);
});

test("sin mapa de lotes se pintan las filas; con mapa se aplica el stock PEPS", () => {
  const filas = [{ id: 7, nombre: "Afrin", stock: 4 }];
  expect(publicarFilasInventario(filas, null)).toEqual(filas);
  const visibles = publicarFilasInventario(filas, {
    7: [{ id: 1, cantidad_actual: 2, activo: true }],
  });
  expect(visibles[0].stock_peps).toBe(2);
  expect(visibles[0].nombre).toBe("Afrin");
});

test("un select rechazado pierde solo la columna que no existe", () => {
  const error = { message: 'column productos.subcategoria does not exist' };
  expect(columnaInexistenteDeError(error)).toBe("subcategoria");
  expect(selectSinColumnaInexistente("id,nombre,subcategoria,precio", error)).toBe("id,nombre,precio");
  expect(selectSinColumnaInexistente("id,nombre", { message: "Could not find the 'notas' column of 'productos' in the schema cache" }))
    .toBe(null);
});

test("lotes: si la tabla trae filas se usan; si no, la página nueva; si no existe, el RPC completo", () => {
  expect(resolverCargaLotes({
    pagina: { data: [{ id: 1 }], error: null, unsupported: false },
    directo: null,
  })).toBe("pagina");
  expect(resolverCargaLotes({
    pagina: { data: [], error: { message: "Could not find the function" }, unsupported: true },
    directo: { data: [{ id: 9 }], error: null },
  })).toBe("directo");
  expect(resolverCargaLotes({
    pagina: { unsupported: true, error: { code: "PGRST202" } },
    directo: { data: [], error: null },
  })).toBe("completo");
});

test("el patch de ficha no manda productos.proveedor", () => {
  expect(patchProductoSinColumnaProveedor({ nombre: "Alcohol", proveedor: "Nadro" })).toEqual({
    nombre: "Alcohol",
  });
  expect(patchProductoSinColumnaProveedor({ precio: 20 })).toEqual({ precio: 20 });
});
