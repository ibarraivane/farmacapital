import {
  agruparLotesPorProducto,
  ejecutarConReintentoTimeout,
  esTimeoutPostgres,
  filasJson,
  loteObjetivoProveedor,
  mensajeErrorGuardadoInventario,
  paginaLotesDesdeRpc,
  patchProductoSinColumnaProveedor,
  productoIdDeLote,
  proveedorDesdeLotes,
  rpcPostgresNoExiste,
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

test("el patch de ficha no manda productos.proveedor", () => {
  expect(patchProductoSinColumnaProveedor({ nombre: "Alcohol", proveedor: "Nadro" })).toEqual({
    nombre: "Alcohol",
  });
  expect(patchProductoSinColumnaProveedor({ precio: 20 })).toEqual({ precio: 20 });
});

test("el timeout de postgres no se muestra en crudo al guardar", () => {
  expect(esTimeoutPostgres("canceling statement due to statement timeout")).toBe(true);
  expect(esTimeoutPostgres("canceling statement due to lock timeout")).toBe(true);
  expect(esTimeoutPostgres("Producto 9 no encontrado")).toBe(false);
  expect(mensajeErrorGuardadoInventario({
    message: "canceling statement due to statement timeout",
  })).toMatch(/ocupada/);
  expect(mensajeErrorGuardadoInventario({
    message: "canceling statement due to statement timeout",
  })).not.toMatch(/canceling statement/);
  expect(mensajeErrorGuardadoInventario({ message: "Producto 9 no encontrado" })).toMatch(/no encontrado/);
});

test("la página de lotes distingue si hay más y el RPC que todavía no existe", () => {
  expect(paginaLotesDesdeRpc({ filas: [{ id: 1 }], hay_mas: true })).toEqual({
    filas: [{ id: 1 }],
    hayMas: true,
  });
  expect(paginaLotesDesdeRpc({ filas: [{ id: 2 }], hay_mas: false }).hayMas).toBe(false);
  expect(paginaLotesDesdeRpc([{ id: 3 }])).toEqual({ filas: [{ id: 3 }], hayMas: false });
  expect(paginaLotesDesdeRpc(null)).toEqual({ filas: [], hayMas: false });
  expect(rpcPostgresNoExiste({
    code: "PGRST202",
    message: "Could not find the function public.empleado_listar_lotes_inventario_pagina",
  })).toBe(true);
  expect(rpcPostgresNoExiste({ message: "canceling statement due to statement timeout" })).toBe(false);
});

test("reintenta una vez si postgres cancela por tiempo", async () => {
  let n = 0;
  const sleeps = [];
  const out = await ejecutarConReintentoTimeout(async () => {
    n += 1;
    if (n === 1) return { error: { message: "canceling statement due to statement timeout" } };
    return { data: { success: true }, error: null };
  }, { esperaMs: 5, dormir: async (ms) => { sleeps.push(ms); } });
  expect(n).toBe(2);
  expect(out.data.success).toBe(true);
  expect(sleeps).toEqual([5]);
});

test("un error de datos no se reintenta", async () => {
  let n = 0;
  const out = await ejecutarConReintentoTimeout(async () => {
    n += 1;
    return { error: { message: "Precio inválido" } };
  }, { dormir: async () => { throw new Error("no debía esperar"); } });
  expect(n).toBe(1);
  expect(out.error.message).toMatch(/Precio/);
});
