import {
  addDaysISO,
  calcularNominaSemanal,
  diarioDeSemanal,
  diasHastaEnSemana,
  diasLaboralesSemana,
  etiquetaRangoSemana,
  martesDeSemana,
  viernesDeSemana,
} from "./rhSemana";

describe("semana martes–viernes", () => {
  test("sábado 22 ago 2026 cae en la semana 18–21", () => {
    expect(martesDeSemana("2026-08-22")).toBe("2026-08-18");
    expect(viernesDeSemana("2026-08-22")).toBe("2026-08-21");
    expect(diasLaboralesSemana("2026-08-22")).toEqual([
      "2026-08-18", "2026-08-19", "2026-08-20", "2026-08-21",
    ]);
  });

  test("domingo y lunes siguen en el viernes anterior", () => {
    expect(martesDeSemana("2026-08-23")).toBe("2026-08-18");
    expect(martesDeSemana("2026-08-24")).toBe("2026-08-18");
  });

  test("el martes abre semana nueva", () => {
    expect(martesDeSemana("2026-08-25")).toBe("2026-08-25");
    expect(viernesDeSemana("2026-08-25")).toBe("2026-08-28");
  });

  test("hasta el miércoles solo cuenta mar–mié", () => {
    expect(diasHastaEnSemana("2026-08-18", "2026-08-19")).toEqual([
      "2026-08-18", "2026-08-19",
    ]);
  });

  test("sábado: liquidar a hoy = semana completa", () => {
    expect(diasHastaEnSemana("2026-08-22", "2026-08-22")).toEqual([
      "2026-08-18", "2026-08-19", "2026-08-20", "2026-08-21",
    ]);
  });

  test("navegación de semanas de 7 en 7", () => {
    expect(addDaysISO("2026-08-18", 7)).toBe("2026-08-25");
    expect(addDaysISO("2026-08-18", -7)).toBe("2026-08-11");
  });

  test("etiqueta del rango", () => {
    expect(etiquetaRangoSemana("2026-08-22")).toBe("18–21 ago 2026");
  });
});

describe("pago Erika $1,133.32", () => {
  test("diario y semana completa", () => {
    expect(diarioDeSemanal(1133.32)).toBe(283.33);
    const full = calcularNominaSemanal({ salarioSemanal: 1133.32, diasTrabajo: 4 });
    expect(full).toEqual({ diario: 283.33, dias: 4, bruto: 1133.32, imss: 0, neto: 1133.32 });
  });

  test("sale el miércoles: 2 días", () => {
    const mid = calcularNominaSemanal({ salarioSemanal: 1133.32, diasTrabajo: 2 });
    expect(mid.bruto).toBe(566.66);
    expect(mid.neto).toBe(566.66);
  });

  test("IMSS apagado por defecto; si se aplica, solo el 2.375%", () => {
    const off = calcularNominaSemanal({ salarioSemanal: 1133.32, diasTrabajo: 4, aplicarImss: false });
    expect(off.imss).toBe(0);
    const on = calcularNominaSemanal({ salarioSemanal: 1133.32, diasTrabajo: 4, aplicarImss: true });
    expect(on.imss).toBe(26.92);
    expect(on.neto).toBe(1106.4);
  });
});
