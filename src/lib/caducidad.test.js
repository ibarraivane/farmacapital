import {
  parseCaducidadMMAA,
  formatCaducidadMesAnio,
  etiquetaCaducidadMMAA,
  etiquetaCaducidadIso,
  diasRestantesCaducidad,
  esPorCaducar,
} from "./caducidad";

describe("parseCaducidadMMAA", () => {
  test("0629 → último día de junio 2029", () => {
    expect(parseCaducidadMMAA("0629")).toBe("2029-06-30");
  });
  test("acepta 06/29 y 06-29", () => {
    expect(parseCaducidadMMAA("06/29")).toBe("2029-06-30");
    expect(parseCaducidadMMAA("06-29")).toBe("2029-06-30");
  });
  test("febrero no bisiesto", () => {
    expect(parseCaducidadMMAA("0227")).toBe("2027-02-28");
  });
  test("febrero bisiesto", () => {
    expect(parseCaducidadMMAA("0228")).toBe("2028-02-29");
  });
  test("MMYYYY", () => {
    expect(parseCaducidadMMAA("062029")).toBe("2029-06-30");
  });
  test("rechaza mes 13 y año viejo", () => {
    expect(parseCaducidadMMAA("1329")).toBeNull();
    expect(parseCaducidadMMAA("0699")).toBeNull();
    expect(parseCaducidadMMAA("")).toBeNull();
    expect(parseCaducidadMMAA("062")).toBeNull();
  });
});

describe("format / etiqueta", () => {
  test("ISO a mes/año", () => {
    expect(formatCaducidadMesAnio("2029-06-30")).toBe("06/2029");
  });
  test("preview MMAA", () => {
    expect(etiquetaCaducidadMMAA("0629")).toBe("jun 2029");
  });
  test("ISO a etiqueta corta", () => {
    expect(etiquetaCaducidadIso("2029-06-30")).toBe("jun 2029");
    expect(etiquetaCaducidadIso(null)).toBe("");
  });
});

describe("diasRestantesCaducidad", () => {
  test("cuenta días civiles", () => {
    expect(diasRestantesCaducidad("2026-06-30", "2026-06-01")).toBe(29);
    expect(diasRestantesCaducidad("2026-05-31", "2026-06-01")).toBe(-1);
  });
});

describe("esPorCaducar", () => {
  test("ventana 90 días, no vencidos", () => {
    expect(esPorCaducar(0)).toBe(true);
    expect(esPorCaducar(90)).toBe(true);
    expect(esPorCaducar(91)).toBe(false);
    expect(esPorCaducar(-1)).toBe(false);
    expect(esPorCaducar(null)).toBe(false);
  });
});
