import { buildRecetaHtml, folioFromCita, stockBadgeLabel, validarRecetaMx } from "./recetaPrint";

describe("recetaPrint", () => {
  test("folioFromCita usa id de cita", () => {
    expect(folioFromCita(42)).toBe("RX-42");
    expect(folioFromCita("x")).toMatch(/^RX-/);
  });

  test("stockBadgeLabel umbrales", () => {
    expect(stockBadgeLabel(0).tone).toBe("red");
    expect(stockBadgeLabel(2).tone).toBe("amber");
    expect(stockBadgeLabel(10).tone).toBe("green");
  });

  test("validarRecetaMx exige cédula y diagnóstico", () => {
    const bad = validarRecetaMx({
      medico: { nombre: "Dra. X" },
      medicamentos: [{ medicamento: "Amox", dosis: "500 mg" }],
      diagnostico: "IVAS",
    });
    expect(bad.ok).toBe(false);
    expect(bad.errores.join(" ")).toMatch(/cédula/i);

    const ok = validarRecetaMx({
      medico: { nombre: "Dra. X", cedula: "1234567" },
      medicamentos: [{ medicamento: "Amox", dosis: "500 mg", frecuencia: "c/8h", duracion: "7d" }],
      diagnostico: "IVAS",
    });
    expect(ok.ok).toBe(true);
  });

  test("buildRecetaHtml marca consultorio y médico dinámico", () => {
    const html = buildRecetaHtml({
      cita: { id: 7, nombre: "Ana Pérez", telefono: "555", fecha: "2026-09-01", hora: "10:30", motivo: "Dolor" },
      diagnostico: "IVAS",
      notas: "Reposo",
      medicamentos: [{ medicamento: "Paracetamol 500", cantidad: 2, dosis: "1 tab", via: "Oral", frecuencia: "c/8h", duracion: "3 días", indicaciones: "Con alimentos" }],
      medico: { nombre: "Dr. Turno Demo", especialidad: "Medicina general", cedula: "123456", institucion: "UNAM" },
      firmaModo: "fisica",
    });
    expect(html).toContain("Consultorio médico");
    expect(html).toContain("Dr. Turno Demo");
    expect(html).toContain("123456");
    expect(html).toContain("Paracetamol 500");
    expect(html).toContain("RX-7");
    expect(html).toContain("UNAM");
    expect(html).toContain("Cédula profesional");
    expect(html).not.toContain("Farmacia · Consultorio");
    expect(html).not.toContain("Dra. Lourdes Lucio Falcón");
  });

  test("firma digital embebe imagen", () => {
    const html = buildRecetaHtml({
      cita: { id: 1, nombre: "X" },
      medico: { nombre: "Dra. A", cedula: "1" },
      firmaModo: "digital",
      firmaDataUrl: "data:image/png;base64,AAA",
      medicamentos: [{ medicamento: "Ibuprofeno", dosis: "400 mg" }],
      diagnostico: "Cefalea",
    });
    expect(html).toContain('src="data:image/png;base64,AAA"');
  });
});
