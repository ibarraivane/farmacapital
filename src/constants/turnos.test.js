import { idxDiaDescanso, planSemanaCaja, descansosChocan, etiquetaDiaDescanso, rangoCajaDeCorte } from "./turnos";

describe("plan 6+1 (descanso y cobertura)", () => {
  const mary = { id: 1, nombre: "Mary", rol: "vendedor", turno: "matutino", dia_descanso: 0 };
  const ana  = { id: 2, nombre: "Ana",  rol: "vendedor", turno: "vespertino", dia_descanso: 1 };

  test("idxDiaDescanso: domingo es 6, lunes es 0", () => {
    expect(idxDiaDescanso(new Date(2026, 7, 17))).toBe(0); // lun 17 ago 2026
    expect(idxDiaDescanso(new Date(2026, 7, 16))).toBe(6); // dom
  });

  test("el lunes Mary descansa y Ana cubre ambos", () => {
    const lun = planSemanaCaja([mary, ana])[0];
    expect(lun.celdas.find((c) => c.id === 1).estado).toBe("descanso");
    expect(lun.celdas.find((c) => c.id === 2).estado).toBe("ambos");
  });

  test("el miércoles cada una en su turno", () => {
    const mie = planSemanaCaja([mary, ana])[2];
    expect(mie.celdas.find((c) => c.id === 1).estado).toBe("matutino");
    expect(mie.celdas.find((c) => c.id === 2).estado).toBe("vespertino");
  });

  test("dos descansos el mismo día chocan", () => {
    const choque = descansosChocan([
      mary,
      { ...ana, dia_descanso: 0 },
    ]);
    expect(choque).toHaveLength(1);
    expect(choque[0][0]).toBe(0);
  });

  test("etiqueta del día", () => {
    expect(etiquetaDiaDescanso(0)).toBe("lunes");
    expect(etiquetaDiaDescanso(5)).toBe("sábado");
  });
});

describe("rangoCajaDeCorte", () => {
  test("usa apertura y cierre del corte, no el reloj 15:30", () => {
    const { inicio, fin } = rangoCajaDeCorte({
      fecha: "2026-08-21",
      turno: "matutino",
      hora_apertura: "08:22:03.131",
      hora_cierre: "17:42:34.641",
    });
    expect(inicio.toISOString()).toBe("2026-08-21T14:22:03.000Z");
    expect(fin.toISOString()).toBe("2026-08-21T23:42:34.000Z");
  });
});
