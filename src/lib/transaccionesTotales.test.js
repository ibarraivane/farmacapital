import {
  filasParaSumaVentas,
  resumenTotalesTransacciones,
} from "./transaccionesTotales";

describe("filasParaSumaVentas", () => {
  const filas = [
    { id: 1, total: 100, estado: "completado", metodo_pago: "efectivo" },
    { id: 2, total: 50, estado: "cancelado", metodo_pago: "efectivo" },
    { id: 3, total: 30, estado: "pendiente", metodo_pago: "tarjeta" },
  ];

  test("con Todos los estados excluye cancelados", () => {
    expect(filasParaSumaVentas(filas, "todos").map((p) => p.id)).toEqual([1, 3]);
  });

  test("filtro cancelado sólo deja cancelados", () => {
    expect(filasParaSumaVentas(filas, "cancelado").map((p) => p.id)).toEqual([2]);
  });
});

describe("resumenTotalesTransacciones", () => {
  const filas = [
    { id: 268, total: "15", estado: "completado", metodo_pago: "efectivo" },
    { id: 269, total: "15", estado: "completado", metodo_pago: "efectivo" },
    { id: 270, total: "30", estado: "completado", metodo_pago: "efectivo" },
    { id: 271, total: "15", estado: "cancelado", metodo_pago: "efectivo" },
  ];

  test("TOTAL neto resta devoluciones y no cuenta cancelados", () => {
    const r = resumenTotalesTransacciones(
      filas,
      { total_devuelto: 15, n: 1 },
      "todos"
    );
    expect(r.brutas).toBe(60);
    expect(r.totalDevuelto).toBe(15);
    expect(r.netas).toBe(45);
    expect(r.byMetodo.efectivo).toBe(60);
    expect(r.mostrarDevoluciones).toBe(true);
  });

  test("sin devoluciones el total neto = bruto (sin cancelados)", () => {
    const r = resumenTotalesTransacciones(filas, { total_devuelto: 0, n: 0 }, "todos");
    expect(r.netas).toBe(60);
    expect(r.mostrarDevoluciones).toBe(false);
  });

  test("filtro cancelado no resta devoluciones", () => {
    const r = resumenTotalesTransacciones(
      filas,
      { total_devuelto: 15, n: 1 },
      "cancelado"
    );
    expect(r.brutas).toBe(15);
    expect(r.netas).toBe(15);
    expect(r.mostrarDevoluciones).toBe(false);
  });
});
