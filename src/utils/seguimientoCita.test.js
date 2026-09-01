import { fechaSeguimiento, etiquetaSeguimiento, SEGUIMIENTO_OPCIONES } from "./seguimientoCita";

describe("seguimientoCita (C1)", () => {
  test("opciones clínicas básicas", () => {
    expect(SEGUIMIENTO_OPCIONES.map((o) => o.dias)).toEqual([7, 14, 30]);
  });

  test("suma días sobre YYYY-MM-DD", () => {
    expect(fechaSeguimiento(7, "2026-09-01")).toBe("2026-09-08");
    expect(fechaSeguimiento(30, "2026-09-01")).toBe("2026-10-01");
    expect(fechaSeguimiento(0, "2026-09-01")).toBe(null);
  });

  test("etiqueta", () => {
    expect(etiquetaSeguimiento(7, "2026-09-08")).toMatch(/2026-09-08/);
    expect(etiquetaSeguimiento(null, null)).toBe("");
  });
});
