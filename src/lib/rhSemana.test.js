import {
  addDaysISO,
  calcularNominaSemanal,
  diarioDeSemanal,
  diasHastaEnSemana,
  diasLaboralesSemana,
  esRpcRhPendiente,
  etiquetaRangoSemana,
  sabadoDeSemana,
  salarioSemanalDe,
  semanaNominaDesfasada,
  viernesDeSemana,
} from "./rhSemana";

describe("semana sábado–viernes", () => {
  test("el sábado 26 sep 2026 abre la semana que se paga el viernes 2 oct", () => {
    expect(sabadoDeSemana("2026-09-26")).toBe("2026-09-26");
    expect(viernesDeSemana("2026-09-26")).toBe("2026-10-02");
    expect(diasLaboralesSemana("2026-09-26")).toEqual([
      "2026-09-26", "2026-09-27", "2026-09-28", "2026-09-29",
      "2026-09-30", "2026-10-01", "2026-10-02",
    ]);
    expect(etiquetaRangoSemana("2026-09-26")).toBe("26 sep – 2 oct 2026");
  });

  test("martes 22 sep pertenece a la semana 19–25, con sábado domingo y lunes", () => {
    expect(sabadoDeSemana("2026-09-22")).toBe("2026-09-19");
    expect(viernesDeSemana("2026-09-22")).toBe("2026-09-25");
    expect(diasLaboralesSemana("2026-09-22")).toEqual([
      "2026-09-19", "2026-09-20", "2026-09-21", "2026-09-22",
      "2026-09-23", "2026-09-24", "2026-09-25",
    ]);
    expect(etiquetaRangoSemana("2026-09-22")).toBe("19–25 sep 2026");
  });

  test("viernes cierra esa misma semana", () => {
    expect(sabadoDeSemana("2026-09-25")).toBe("2026-09-19");
    expect(viernesDeSemana("2026-09-25")).toBe("2026-09-25");
  });

  test("hasta el miércoles cuenta sábado a miércoles", () => {
    expect(diasHastaEnSemana("2026-09-19", "2026-09-23")).toEqual([
      "2026-09-19", "2026-09-20", "2026-09-21", "2026-09-22", "2026-09-23",
    ]);
  });

  test("el sábado solo liquida ese día: la semana acaba de empezar", () => {
    expect(diasHastaEnSemana("2026-09-26", "2026-09-26")).toEqual(["2026-09-26"]);
  });

  test("navegación de semanas de 7 en 7", () => {
    expect(addDaysISO("2026-09-19", 7)).toBe("2026-09-26");
    expect(addDaysISO("2026-09-19", -7)).toBe("2026-09-12");
  });

  test("detecta una base que todavía empieza en martes", () => {
    expect(semanaNominaDesfasada({ semana_inicio: "2026-09-22" }, "2026-09-22")).toBe(true);
    expect(semanaNominaDesfasada({ semana_inicio: "2026-09-19" }, "2026-09-22")).toBe(false);
    expect(semanaNominaDesfasada(null, "2026-09-22")).toBe(false);
  });
});

describe("pago semanal sábado–viernes", () => {
  test("semana completa de $1,500 cierra en $1,500", () => {
    expect(diarioDeSemanal(1500)).toBe(214.29);
    const full = calcularNominaSemanal({ salarioSemanal: 1500, diasTrabajo: 7 });
    expect(full).toEqual({ diario: 214.29, dias: 7, bruto: 1500, imss: 0, neto: 1500 });
  });

  test("cuatro días de $1,500 usan el diario", () => {
    const mid = calcularNominaSemanal({ salarioSemanal: 1500, diasTrabajo: 4 });
    expect(mid.diario).toBe(214.29);
    expect(mid.bruto).toBe(857.16);
    expect(mid.neto).toBe(857.16);
  });

  test("Erika $1,133.32 en semana completa no pierde centavos", () => {
    expect(diarioDeSemanal(1133.32)).toBe(161.9);
    const full = calcularNominaSemanal({ salarioSemanal: 1133.32, diasTrabajo: 7 });
    expect(full.bruto).toBe(1133.32);
    expect(full.neto).toBe(1133.32);
  });

  test("dos días trabajados", () => {
    const mid = calcularNominaSemanal({ salarioSemanal: 1133.32, diasTrabajo: 2 });
    expect(mid.bruto).toBe(323.8);
    expect(mid.neto).toBe(323.8);
  });

  test("no convierte el quincenal viejo en semanal", () => {
    expect(salarioSemanalDe({ salario_semanal: 1133.32, salario_quincenal: 3500 })).toBe(1133.32);
    expect(salarioSemanalDe({ salario_quincenal: 3500 })).toBe(0);
    expect(salarioSemanalDe({ salario_semanal: 0 })).toBe(0);
  });

  test("detecta RPC de nómina semanal pendiente en la base", () => {
    expect(esRpcRhPendiente({ message: "Could not find the function public.rh_semana_empleado" })).toBe(true);
    expect(esRpcRhPendiente({ message: "Ya hay un pago registrado para esta semana" })).toBe(false);
  });

  test("IMSS apagado por defecto; si se aplica, solo el 2.375% de la semana completa", () => {
    const off = calcularNominaSemanal({ salarioSemanal: 1133.32, diasTrabajo: 7, aplicarImss: false });
    expect(off.imss).toBe(0);
    const on = calcularNominaSemanal({ salarioSemanal: 1133.32, diasTrabajo: 7, aplicarImss: true });
    expect(on.imss).toBe(26.92);
    expect(on.neto).toBe(1106.4);
  });
});
