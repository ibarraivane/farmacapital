import {
  finInclusivoIso,
  gananciaNetaEstMes,
  rangoReporteMexico,
  rangosDashboardMexico,
  resolverVentasAcumuladas,
  serieVentasDesdeRpc,
  sumPedidosTotal,
  sumPorDiaYmd,
  sumSeriePorDia,
} from "./dashboardVentas";
import { rangoDiaMexico } from "./fecha";

describe("rangosDashboardMexico", () => {
  test("antes de medianoche CDMX sigue siendo el viernes", () => {
    const now = new Date("2026-08-29T05:00:00.000Z"); // 23:00 CDMX del 28
    const r = rangosDashboardMexico(now);
    expect(r.hoy).toBe("2026-08-28");
    expect(r.lunes).toBe("2026-08-24");
    expect(r.inicioMes).toBe("2026-08-01");
    const tarde = new Date("2026-08-28T22:30:00.000Z").getTime();
    const medianocheSab = new Date("2026-08-29T06:00:00.000Z").getTime();
    expect(tarde).toBeGreaterThanOrEqual(new Date(r.today.start).getTime());
    expect(tarde).toBeLessThan(new Date(r.today.end).getTime());
    expect(medianocheSab).toBeGreaterThanOrEqual(new Date(r.today.end).getTime());
  });
});

describe("rangoReporteMexico", () => {
  const now = new Date("2026-08-29T05:00:00.000Z"); // viernes 28, 23:00 CDMX

  test("Hoy es el día civil, no las últimas 24 h", () => {
    const dia = rangoReporteMexico("dia", now);
    expect(dia.desdeFecha).toBe("2026-08-28");
    expect(dia.desde).toBe(rangoDiaMexico("2026-08-28").start);
    // Jueves 23:00 CDMX cae en las últimas 24 h pero NO en el viernes civil
    const juevesNoche = new Date("2026-08-28T05:00:00.000Z").getTime();
    expect(juevesNoche).toBeLessThan(new Date(dia.desde).getTime());
  });

  test("semana es lunes–hoy (no 7×24 h rodantes)", () => {
    const sem = rangoReporteMexico("semana", now);
    expect(sem.desdeFecha).toBe("2026-08-24");
    expect(sem.hastaFecha).toBe("2026-08-28");
    expect(sem.desde).toBe(rangoDiaMexico("2026-08-24").start);
  });

  test("mes es el mes calendario, no 30 días rodantes", () => {
    const mes = rangoReporteMexico("mes", now);
    expect(mes.desdeFecha).toBe("2026-08-01");
    expect(mes.desde).toBe(rangoDiaMexico("2026-08-01").start);
  });
});

describe("serieVentasDesdeRpc", () => {
  test("resta devoluciones del mismo día", () => {
    const { porDia, tickets } = serieVentasDesdeRpc([
      { dia: "2026-08-28", total: "1000", tickets: 4, devoluciones: "120" },
    ]);
    expect(porDia["2026-08-28"]).toBe(880);
    expect(tickets["2026-08-28"]).toBe(4);
  });

  test("sin campo devoluciones deja el bruto (RPC viejo)", () => {
    expect(serieVentasDesdeRpc([{ dia: "2026-08-28", total: "1000", tickets: 2 }]).porDia).toEqual({
      "2026-08-28": 1000,
    });
  });
});

describe("sumas", () => {
  test("sumPorDiaYmd solo el rango pedido", () => {
    const map = { "2026-08-27": 10, "2026-08-28": 20, "2026-08-29": 40 };
    expect(sumPorDiaYmd(map, "2026-08-28", "2026-08-28")).toBe(20);
    expect(sumPorDiaYmd(map, "2026-08-24", "2026-08-28")).toBe(30);
  });

  test("sumPedidosTotal lee total o suma", () => {
    expect(sumPedidosTotal([{ total: "10" }, { suma: 5 }])).toBe(15);
  });

  test("sumSeriePorDia suma todo el mapa", () => {
    expect(sumSeriePorDia({ "2026-08-01": 100, "2026-08-28": 50.5 })).toBe(150.5);
  });

  test("finInclusivoIso no incluye el instante de cierre exclusivo", () => {
    const { end } = rangoDiaMexico("2026-08-28");
    const incl = finInclusivoIso(end);
    expect(new Date(incl).getTime()).toBe(new Date(end).getTime() - 1);
  });
});

describe("resolverVentasAcumuladas", () => {
  test("prefiere el SUM del RPC sobre ped_todos y la serie", () => {
    expect(resolverVentasAcumuladas({
      ventasAcumuladasRpc: 9000,
      pedTodos: [{ total: 100 }],
      ventasPorDia: { "2026-08-28": 50 },
    })).toBe(9000);
  });

  test("si no hay RPC usa ped_todos (compat bundle viejo)", () => {
    expect(resolverVentasAcumuladas({
      pedTodos: [{ total: "120" }, { total: 30 }],
      ventasPorDia: { "2026-08-28": 999 },
    })).toBe(150);
  });

  test("si ped_todos viene vacío usa la serie del POS", () => {
    expect(resolverVentasAcumuladas({
      pedTodos: [],
      ventasPorDia: { "2026-08-27": 200, "2026-08-28": 300 },
    })).toBe(500);
  });

  test("sin datos queda en 0", () => {
    expect(resolverVentasAcumuladas({})).toBe(0);
  });

  test("si todo falla usa el piso (ventas del mes de Operación)", () => {
    expect(resolverVentasAcumuladas({
      pedTodos: [],
      ventasPorDia: {},
      piso: 4200,
    })).toBe(4200);
  });
});

describe("gananciaNetaEstMes", () => {
  test("55% de ventas del mes (misma fórmula del KPI Proyecto)", () => {
    expect(gananciaNetaEstMes(1000)).toBe(550);
    expect(gananciaNetaEstMes(0)).toBe(0);
  });
});
