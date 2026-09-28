import {
  PASO_PRECIO_VENTA,
  cifrasPrecioInventario,
  fmtPrecioInventario,
  snapPrecioVenta,
} from "./denominacionPrecio";

test("el paso mínimo es 0.5 centavos ($0.005)", () => {
  expect(PASO_PRECIO_VENTA).toBe(0.005);
});

test("snap al múltiplo de 0.005: residuo 0–2 baja, 3–4 sube", () => {
  expect(snapPrecioVenta(0)).toBe(0);
  expect(snapPrecioVenta(10)).toBe(10);
  expect(snapPrecioVenta(10.5)).toBe(10.5);
  expect(snapPrecioVenta("10,50")).toBe(10.5);

  expect(snapPrecioVenta(10.001)).toBe(10);
  expect(snapPrecioVenta(10.002)).toBe(10);
  expect(snapPrecioVenta(10.003)).toBe(10.005);
  expect(snapPrecioVenta(10.004)).toBe(10.005);
  expect(snapPrecioVenta(10.005)).toBe(10.005);
  expect(snapPrecioVenta(10.006)).toBe(10.005);
  expect(snapPrecioVenta(10.007)).toBe(10.005);
  expect(snapPrecioVenta(10.008)).toBe(10.01);
  expect(snapPrecioVenta(10.009)).toBe(10.01);

  expect(snapPrecioVenta(0.001)).toBe(0);
  expect(snapPrecioVenta(0.002)).toBe(0);
  expect(snapPrecioVenta(0.003)).toBe(0.005);
  expect(snapPrecioVenta("10.003")).toBe(10.005);
  expect(snapPrecioVenta("  10,008 ")).toBe(10.01);
});

test("un precio ya ajustado no se mueve", () => {
  expect(snapPrecioVenta(snapPrecioVenta(10.003))).toBe(10.005);
  expect(snapPrecioVenta(12.505)).toBe(12.505);
});

test("rechaza vacío, inválido y negativo", () => {
  expect(snapPrecioVenta("")).toBeNull();
  expect(snapPrecioVenta("   ")).toBeNull();
  expect(snapPrecioVenta(null)).toBeNull();
  expect(snapPrecioVenta(undefined)).toBeNull();
  expect(snapPrecioVenta(-1)).toBeNull();
  expect(snapPrecioVenta(-0.001)).toBeNull();
  expect(snapPrecioVenta("abc")).toBeNull();
  expect(snapPrecioVenta(NaN)).toBeNull();
  expect(snapPrecioVenta(Infinity)).toBeNull();
});

test("formato de inventario: 2 decimales, 3 si el medio centavo no es cero", () => {
  expect(fmtPrecioInventario(10)).toBe("$10.00");
  expect(fmtPrecioInventario(10.5)).toBe("$10.50");
  expect(fmtPrecioInventario(10.005)).toBe("$10.005");
  expect(fmtPrecioInventario(10.01)).toBe("$10.01");
  expect(fmtPrecioInventario(0)).toBe("$0.00");
  expect(fmtPrecioInventario("no")).toBe("—");
  expect(cifrasPrecioInventario(10.005)).toBe("10.005");
  expect(cifrasPrecioInventario(10)).toBe("10.00");
});
