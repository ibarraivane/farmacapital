import {
  parseNumeroClinico,
  parseTensionArterial,
  parseSignosVitales,
  calcIMC,
  clasificarIMC,
  clasificarTA,
  clasificarFC,
  clasificarTemp,
  clasificarSat,
  puntosDesdeCitas,
  llevarTallaParaIMC,
  tendenciaCampo,
  narrarEvolucion,
  promedioCampo,
  promedioTA,
  fmtFechaCorta,
} from "./evolucionClinica";

describe("parseo clínico", () => {
  test("número acepta coma mexicana", () => {
    expect(parseNumeroClinico("72,5")).toBe(72.5);
    expect(parseNumeroClinico("")).toBeNull();
    expect(parseNumeroClinico("x")).toBeNull();
  });

  test("TA 120/80 y 120 - 80", () => {
    expect(parseTensionArterial("120/80")).toEqual({ sis: 120, dia: 80, texto: "120/80" });
    expect(parseTensionArterial("118 - 76")).toEqual({ sis: 118, dia: 76, texto: "118/76" });
    expect(parseTensionArterial("")).toBeNull();
    expect(parseTensionArterial("120")).toBeNull();
  });

  test("signos desde JSON string", () => {
    expect(parseSignosVitales('{"peso":"70"}')).toEqual({ peso: "70" });
    expect(parseSignosVitales("{no")).toBeNull();
    expect(parseSignosVitales(null)).toBeNull();
  });

  test("IMC 70 kg / 170 cm", () => {
    expect(calcIMC(70, 170)).toBe(24.2);
    expect(calcIMC(70, 0)).toBeNull();
    expect(calcIMC("68,5", "162")).toBe(26.1);
  });
});

describe("clasificaciones", () => {
  test("IMC y TA", () => {
    expect(clasificarIMC(17).id).toBe("bajo");
    expect(clasificarIMC(22).id).toBe("normal");
    expect(clasificarIMC(27).id).toBe("sobrepeso");
    expect(clasificarIMC(32).id).toBe("obesidad");
    expect(clasificarTA(142, 88).id).toBe("alta");
    expect(clasificarTA(132, 80).id).toBe("limite");
    expect(clasificarTA(118, 76).id).toBe("normal");
    expect(clasificarTA(88, 58).id).toBe("baja");
  });

  test("FC, temp y SpO2", () => {
    expect(clasificarFC(72).id).toBe("normal");
    expect(clasificarFC(110).id).toBe("alta");
    expect(clasificarTemp(38.2).id).toBe("fiebre");
    expect(clasificarTemp(36.5).id).toBe("normal");
    expect(clasificarSat(97).id).toBe("normal");
    expect(clasificarSat(93).id).toBe("limite");
    expect(clasificarSat(90).id).toBe("baja");
  });
});

const CITAS = [
  {
    id: 2,
    fecha: "2026-07-30",
    hora: "09:00",
    signos_vitales: { ta: "128/82", fc: "74", temp: "36.6", sat: "97", peso: "68.2", talla: "" },
  },
  {
    id: 1,
    fecha: "2026-04-19",
    hora: "10:00",
    signos_vitales: JSON.stringify({
      ta: "138/88",
      fc: "80",
      temp: "36.8",
      sat: "96",
      peso: "71.4",
      talla: "162",
    }),
  },
  {
    id: 3,
    fecha: "2026-08-20",
    hora: "11:00",
    signos_vitales: { ta: "", fc: "", peso: "", talla: "" },
  },
];

describe("serie de evolución", () => {
  test("ordena, ignora fichas vacías y lleva talla para IMC", () => {
    const pts = puntosDesdeCitas(CITAS);
    expect(pts.map((p) => p.id)).toEqual([1, 2]);
    expect(pts[0].peso).toBe(71.4);
    expect(pts[1].peso).toBe(68.2);
    expect(pts[1].talla).toBeNull();
    expect(pts[1].tallaEfectiva).toBe(162);
    expect(pts[1].imc).toBe(26);
  });

  test("lleva talla hacia atrás si solo está en una visita tardía", () => {
    const rows = llevarTallaParaIMC([
      { peso: 70, talla: null, imc: null },
      { peso: 69, talla: 170, imc: calcIMC(69, 170) },
    ]);
    expect(rows[0].tallaEfectiva).toBe(170);
    expect(rows[0].imc).toBe(calcIMC(70, 170));
  });

  test("tendencia de peso y promedio TA", () => {
    const pts = puntosDesdeCitas(CITAS);
    const t = tendenciaCampo(pts, "peso", { umbral: 0.5, decimales: 1, unidad: " kg" });
    expect(t.dir).toBe("down");
    expect(t.texto).toMatch(/bajó 3\.2 kg/);
    expect(promedioCampo(pts, "peso")).toBe(69.8);
    expect(promedioTA(pts).texto).toBe("133/85");
  });

  test("narración en español para la doctora", () => {
    const txt = narrarEvolucion(puntosDesdeCitas(CITAS));
    expect(txt).toMatch(/2 consultas/);
    expect(txt).toMatch(/19\/04\/2026/);
    expect(txt).toMatch(/peso bajó 3\.2 kg/);
    expect(txt).toMatch(/Última TA 128\/82/);
    expect(txt).toMatch(/IMC 26/);
    expect(txt).toMatch(/sobrepeso/);
  });

  test("vacío explica que faltan signos", () => {
    expect(narrarEvolucion([])).toMatch(/Aún no hay signos/);
    expect(fmtFechaCorta("2026-04-19")).toBe("19/04/2026");
  });
});
