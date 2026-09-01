import { folioFromCita, esFolioReceta, validarRecetaMx, stockBadgeLabel, buildRecetaHtml } from "./recetaPrint";

describe("recetaPrint", () => {
  test("folio local de respaldo", () => {
    expect(folioFromCita(42)).toBe("FC-RX-LOCAL-42");
    expect(esFolioReceta("FC-RX-2026-000123")).toBe(true);
    expect(esFolioReceta("FC-RX-LOCAL-42")).toBe(true);
    expect(esFolioReceta("RX-1")).toBe(false);
  });

  test("validarRecetaMx exige médico, cédula, dx y meds", () => {
    const bad = validarRecetaMx({});
    expect(bad.ok).toBe(false);
    expect(bad.errores.join(" ")).toMatch(/médico/i);
    expect(bad.errores.join(" ")).toMatch(/cédula/i);

    const ok = validarRecetaMx({
      medico: { nombre: "Dra. Lucio", cedula: "1234567" },
      diagnostico: "IRA",
      medicamentos: [{ medicamento: "Paracetamol 500", dosis: "1 tab", frecuencia: "c/8 h" }],
    });
    expect(ok.ok).toBe(true);
  });

  test("stock badge", () => {
    expect(stockBadgeLabel(0).tone).toBe("red");
    expect(stockBadgeLabel(2).tone).toBe("amber");
    expect(stockBadgeLabel(10).tone).toBe("green");
  });

  test("HTML carta incluye folio, cédula y consultorio (no ticket de farmacia)", () => {
    const html = buildRecetaHtml({
      folio: "FC-RX-2026-000001",
      cita: { nombre: "Ana Pérez", telefono: "5512345678", fecha: "2026-09-01", hora: "10:00" },
      medico: { nombre: "Dra. Lucio", cedula: "1234567", especialidad: "Medicina general" },
      diagnostico: "Faringitis",
      medicamentos: [{ medicamento: "Amoxicilina 500", cantidad: 1, dosis: "1 cáps", frecuencia: "c/8 h", duracion: "7 días" }],
    });
    expect(html).toContain("FC-RX-2026-000001");
    expect(html).toContain("1234567");
    expect(html).toContain("Consultorio médico");
    expect(html).toContain("Amoxicilina 500");
    expect(html).not.toContain("Punto de Venta");
  });
});
