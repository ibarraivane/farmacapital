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

test("detecta statement timeout de Postgres", () => {
  expect(esTimeoutPostgres("canceling statement due to statement timeout")).toBe(true);
  expect(esTimeoutPostgres("lock timeout")).toBe(true);
  expect(esTimeoutPostgres("producto no encontrado")).toBe(false);
  expect(mensajeErrorGuardadoInventario({ message: "canceling statement due to statement timeout" }))
    .toMatch(/base estaba ocupada/i);
});

test("paginaLotesDesdeRpc lee filas/hay_mas", () => {
  expect(paginaLotesDesdeRpc({ filas: [{ id: 1 }], hay_mas: true })).toEqual({
    filas: [{ id: 1 }],
    hayMas: true,
  });
  expect(paginaLotesDesdeRpc([{ id: 2 }])).toEqual({ filas: [{ id: 2 }], hayMas: false });
});

test("ejecutarConReintentoTimeout solo reintenta timeouts", async () => {
  let n = 0;
  const ok = await ejecutarConReintentoTimeout(async () => {
    n += 1;
    if (n === 1) return { error: { message: "canceling statement due to statement timeout" } };
    return { data: { ok: true }, error: null };
  }, { esperaMs: 1, dormir: async () => {} });
  expect(n).toBe(2);
  expect(ok.data).toEqual({ ok: true });

  let m = 0;
  const fail = await ejecutarConReintentoTimeout(async () => {
    m += 1;
    return { error: { message: "producto no encontrado" } };
  }, { esperaMs: 1, dormir: async () => {} });
  expect(m).toBe(1);
  expect(fail.error.message).toMatch(/producto/);
});
