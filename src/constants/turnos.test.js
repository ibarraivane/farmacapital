import { idxDiaDescanso, planSemanaCaja, descansosChocan, etiquetaDiaDescanso, perfilesTurnoCaja, rangoTurno, rangoDiaCalendario, inferirTurno } from "./turnos";

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

  test("una baja no entra a la caja ni choca descansos", () => {
    const baja = { ...mary, activo: false };
    const rene = { id: 3, nombre: "Rene", rol: "vendedor", turno: "matutino", dia_descanso: 6, activo: true };
    expect(perfilesTurnoCaja([baja, ana, rene]).map((p) => p.nombre)).toEqual(["Ana", "Rene"]);
    const lun = planSemanaCaja([baja, ana, rene])[0];
    expect(lun.celdas.find((c) => c.id === 1)).toBeUndefined();
    expect(descansosChocan([baja, { ...rene, dia_descanso: 0 }])).toHaveLength(0);
  });
});

describe("rangos de turno vs crédito personal (Mi Día)", () => {
  const dia = new Date(2026, 8, 14, 15, 23, 0); // 14-sep-2026 15:23

  test("venta 15:11 queda fuera del rango de caja vespertino (corte 15:30)", () => {
    const venta = new Date(2026, 8, 14, 15, 11, 0);
    const vesp = rangoTurno(dia, "vespertino");
    expect(venta.getTime()).toBeLessThan(vesp.inicio.getTime());
    expect(inferirTurno(venta)).toBe("matutino");
  });

  test("rangoDiaCalendario incluye la venta del traslape para Mi Día", () => {
    const venta = new Date(2026, 8, 14, 15, 11, 0);
    const { inicio, fin } = rangoDiaCalendario(dia);
    expect(inicio.getHours()).toBe(0);
    expect(inicio.getMinutes()).toBe(0);
    expect(fin.getHours()).toBe(23);
    expect(venta.getTime()).toBeGreaterThanOrEqual(inicio.getTime());
    expect(venta.getTime()).toBeLessThanOrEqual(fin.getTime());
  });

  test("caja matutino y vespertino no se traslapan", () => {
    const m = rangoTurno(dia, "matutino");
    const v = rangoTurno(dia, "vespertino");
    expect(m.fin.getTime()).toBeLessThan(v.inicio.getTime());
  });
});
