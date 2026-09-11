import {
  esRecargaCategoria,
  montoRecargaParaMeta,
  sumRecargasParaMeta,
  sumarVentasConRecargas,
  nombreAtendidoRecarga,
  acumularRecargasEnMapaEmpleado,
  acumularRecargasPorDia,
} from "./recargasEnMetas";

describe("recargasEnMetas", () => {
  test("solo categoria recarga cuenta", () => {
    expect(esRecargaCategoria("recarga")).toBe(true);
    expect(esRecargaCategoria("RECARGA")).toBe(true);
    expect(esRecargaCategoria("luz")).toBe(false);
    expect(esRecargaCategoria("cfe")).toBe(false);
  });

  test("monto usa total_cobrado; CFE no suma aunque tenga monto", () => {
    expect(montoRecargaParaMeta({ categoria: "recarga", total_cobrado: 50, monto_servicio: 50 })).toBe(50);
    expect(montoRecargaParaMeta({ categoria: "luz", total_cobrado: 208, monto_servicio: 200 })).toBe(0);
    expect(montoRecargaParaMeta({ total_cobrado: 100 })).toBe(100);
    expect(montoRecargaParaMeta({ total: 30 })).toBe(30);
  });

  test("suma pedidos + recargas para el % de meta", () => {
    expect(sumarVentasConRecargas(800, [
      { categoria: "recarga", total_cobrado: 50 },
      { categoria: "recarga", total_cobrado: 100 },
      { categoria: "luz", total_cobrado: 208 },
    ])).toBe(950);
    expect(sumRecargasParaMeta([])).toBe(0);
  });

  test("agrupa por vendedora en dashboard", () => {
    const byEmp = { Ana: 500 };
    acumularRecargasEnMapaEmpleado(byEmp, [
      { categoria: "recarga", total_cobrado: 50, atendido_por_nombre: "Ana" },
      { categoria: "recarga", total_cobrado: 100, usuarios: { nombre: "Bety" } },
      { categoria: "tv", total_cobrado: 90, atendido_por_nombre: "Ana" },
    ]);
    expect(byEmp.Ana).toBe(550);
    expect(byEmp.Bety).toBe(100);
  });

  test("nombreAtendidoRecarga tiene fallback", () => {
    expect(nombreAtendidoRecarga({ atendido_por: 7 })).toBe(7);
    expect(nombreAtendidoRecarga({})).toBe("Sin asignar");
  });

  test("acumula por día para rachas de Mi Día", () => {
    const m = new Map([["2026-09-10", 400]]);
    acumularRecargasPorDia(m, [
      { total_cobrado: 50, created_at: "2026-09-10T18:00:00.000Z" },
      { total_cobrado: 20, created_at: "2026-09-11T12:00:00.000Z" },
    ]);
    expect(m.get("2026-09-10")).toBe(450);
    expect(m.get("2026-09-11")).toBe(20);
  });
});
