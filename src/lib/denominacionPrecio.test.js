import { PASO_PRECIO_VENTA, cifrasPrecioInventario, fmtPrecioInventario, snapPrecioVenta } from "./denominacionPrecio";

test("el paso mínimo es medio peso", () => {
  expect(PASO_PRECIO_VENTA).toBe(0.5);
});

test("snap al medio peso más cercano", () => {
  expect(snapPrecioVenta(10)).toBe(10);
  expect(snapPrecioVenta(10.5)).toBe(10.5);
  expect(snapPrecioVenta("10,50")).toBe(10.5);
  expect(snapPrecioVenta(10.24)).toBe(10);
  expect(snapPrecioVenta(10.25)).toBe(10.5);
  expect(snapPrecioVenta(10.74)).toBe(10.5);
  expect(snapPrecioVenta(10.75)).toBe(11);
  expect(snapPrecioVenta(1.5)).toBe(1.5);
  expect(snapPrecioVenta(1.2)).toBe(1);
  expect(snapPrecioVenta(1.3)).toBe(1.5);
  expect(snapPrecioVenta(0)).toBe(0);
  expect(snapPrecioVenta(0.2)).toBe(0);
  expect(snapPrecioVenta(0.3)).toBe(0.5);
});

test("rechaza vacío y negativo", () => {
  expect(snapPrecioVenta("")).toBeNull();
  expect(snapPrecioVenta(null)).toBeNull();
  expect(snapPrecioVenta(-1)).toBeNull();
  expect(snapPrecioVenta("abc")).toBeNull();
});

test("formato de inventario con dos decimales", () => {
  expect(fmtPrecioInventario(10)).toBe("$10.00");
  expect(fmtPrecioInventario(1.5)).toBe("$1.50");
  expect(fmtPrecioInventario("no")).toBe("—");
  expect(cifrasPrecioInventario(1.5)).toBe("1.50");
  expect(cifrasPrecioInventario("no")).toBe("");
});
