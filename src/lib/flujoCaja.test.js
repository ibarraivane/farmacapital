import {
  PISO_FONDO_FLUJO,
  MENSAJE_FLUJO_SIN_CONFIG,
  parseFlujoBundle,
  flujoEstaConfigurado,
  textoOrigenPiso,
  mesesSinCompraDesdeValor,
  toggleMesSinCompra,
  labelSemana,
  textoCompletitud,
  pctBarra,
  maxAbsSemanas,
} from "./flujoCaja";

describe("flujoCaja", () => {
  test("piso de fondo documentado es el 18-ago-2026 (Parte 8.7)", () => {
    expect(PISO_FONDO_FLUJO).toBe("2026-08-18");
  });

  test("el texto del piso dice que sale de la apertura, no de Ajustes", () => {
    expect(textoOrigenPiso({
      origen_piso: "sesion",
      piso_aplicado: "2026-08-18",
      saldo_inicial: 282,
    })).toMatch(/primera apertura/);
    expect(textoOrigenPiso({ origen_piso: "config", piso_aplicado: "2026-09-01", saldo_inicial: 1000 }))
      .toMatch(/override/);
  });

  test("sin apertura con fondo no está configurado y no inventa números", () => {
    const b = parseFlujoBundle({
      configurado: false,
      faltan: ["caja_sesiones.fondo_contado"],
      mensaje: MENSAJE_FLUJO_SIN_CONFIG,
    });
    expect(flujoEstaConfigurado(b)).toBe(false);
    expect(b.faltan).toEqual(["caja_sesiones.fondo_contado"]);
    expect(b.entro).toBeUndefined();
  });

  test("parsea semanas y alertas del jsonb", () => {
    const b = parseFlujoBundle({
      configurado: true,
      entro: 1000,
      semanas: [{ semana: "2026-08-31", entro: 100, medicamento: 40, nomina: 20, gastos: 10, quedo: 30 }],
      alertas: [{ tipo: "completitud", nivel: "ambar", texto: "Captura incompleta" }],
    });
    expect(flujoEstaConfigurado(b)).toBe(true);
    expect(b.semanas).toHaveLength(1);
    expect(b.alertas[0].tipo).toBe("completitud");
  });

  test("toggle de mes sin compra", () => {
    expect(mesesSinCompraDesdeValor("2026-08, 2026-09")).toEqual(["2026-08", "2026-09"]);
    expect(toggleMesSinCompra("2026-08", "2026-09", true)).toBe("2026-08,2026-09");
    expect(toggleMesSinCompra("2026-08,2026-09", "2026-09", false)).toBe("2026-08");
  });

  test("etiqueta de semana lun–dom", () => {
    expect(labelSemana("2026-08-31")).toBe("31 ago – 6 sep");
    expect(labelSemana("2026-09-07")).toBe("7–13 sep");
  });

  test("completitud nunca trata un ausente como cero limpio", () => {
    expect(textoCompletitud({ incompleta: true, tiene_nomina: false, tiene_renta: false, tiene_proveedor: false }))
      .toMatch(/no es que hayas gastado \$0/);
    expect(textoCompletitud({ incompleta: false })).toMatch(/completa/);
  });

  test("barras porcentuales sin librería", () => {
    expect(pctBarra(50, 100)).toBe(50);
    expect(pctBarra(0, 0)).toBe(0);
    expect(maxAbsSemanas([{ entro: 80, medicamento: 20, nomina: 10, gastos: 5 }])).toBe(80);
  });
});
