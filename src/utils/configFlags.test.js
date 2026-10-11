import { flagActiva, configFlagActiva } from "./configFlags";

describe("flagActiva", () => {
  test("acepta las formas que de verdad se capturan", () => {
    ["1", "true", "TRUE", "si", "sí", "Sí", "on", "yes", " 1 "].forEach((v) => {
      expect(flagActiva(v)).toBe(true);
    });
  });

  test("apagado por omisión: falta la clave, vacío o cualquier otra cosa", () => {
    [undefined, null, "", "  ", "0", "false", "no", "2", "apagado"].forEach((v) => {
      expect(flagActiva(v)).toBe(false);
    });
  });

  test("no se tropieza con números", () => {
    expect(flagActiva(1)).toBe(true);
    expect(flagActiva(0)).toBe(false);
  });
});

describe("configFlagActiva", () => {
  test("lee la clave del mapa de configuracion", () => {
    expect(configFlagActiva({ ticket_auto_imprimir: "1" }, "ticket_auto_imprimir")).toBe(true);
    expect(configFlagActiva({ ticket_auto_imprimir: "0" }, "ticket_auto_imprimir")).toBe(false);
  });

  test("mapa ausente o clave inexistente no truena ni enciende", () => {
    expect(configFlagActiva(null, "ticket_auto_imprimir")).toBe(false);
    expect(configFlagActiva({}, "ticket_auto_imprimir")).toBe(false);
  });
});
