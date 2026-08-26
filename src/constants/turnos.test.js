import { idxDiaDescanso, planSemanaCaja, descansosChocan, etiquetaDiaDescanso, perfilesTurnoCaja } from "./turnos";

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
