const { partirNombreMostrador, aplicarFichaMostrador, fichaTieneIdentidad } = require("./nombreMostrador");

describe("partirNombreMostrador", () => {
  test("la dosis se queda en el nombre: 400 mg y 600 mg no colapsan", () => {
    const a = partirNombreMostrador("Ibuprofeno 400 mg 20 tabletas");
    const b = partirNombreMostrador("Ibuprofeno 600 mg 10 tabletas");
    expect(a.nombre).toBe("Ibuprofeno 400 mg");
    expect(b.nombre).toBe("Ibuprofeno 600 mg");
    expect(a.nombre).not.toBe(b.nombre);
    expect(a.presentacion).toMatch(/20/i);
    expect(b.presentacion).toMatch(/10/i);
    expect(a.concentracion).toBe("400 mg");
    expect(a.forma).toBe("Tabletas");
  });

  test("C/24 y volumen salen del nombre; la línea comercial se queda", () => {
    expect(partirNombreMostrador("Antiflu-Des C/24").nombre).toBe("Antiflu-Des");
    expect(partirNombreMostrador("Antiflu-Des C/24").presentacion).toBe("C/24");
    const adel = partirNombreMostrador("Adel 250 mg Suspensión 60 ml");
    expect(adel.nombre).toBe("Adel 250 mg");
    expect(adel.presentacion).toBe("60 ml");
    expect(adel.forma).toBe("Suspensión");
    expect(adel.concentracion).toBe("250 mg");
  });

  test("variante dermo (UV Air) no se pierde al quitar 40 ml", () => {
    const f = partirNombreMostrador(
      "La Roche-Posay Anthelios UV Air FPS 50+ Protector Solar Ligero 40 ml"
    );
    expect(f.nombre).toMatch(/Anthelios UV Air/i);
    expect(f.nombre).toMatch(/FPS\s*50/i);
    expect(f.nombre).not.toMatch(/40\s*ml/i);
    expect(f.presentacion).toBe("40 ml");
    expect(f.concentracion).toMatch(/FPS\s*50/i);
  });

  test("leche en polvo no se corta en la palabra polvo", () => {
    const f = partirNombreMostrador("Leche En Polvo Nan 1 Optimal Pro 120 G");
    expect(f.nombre).toMatch(/Leche En Polvo/i);
    expect(f.presentacion).toMatch(/120/i);
    expect(f.forma).toBeNull();
  });

  test("no inventa marca ni principio; respeta presentación ya guardada", () => {
    const f = partirNombreMostrador("Febrax 15 tab", { presentacion: "Caja 15" });
    expect(f.nombre).toBe("Febrax");
    expect(f.presentacion).toBe("Caja 15");
    expect(f).not.toHaveProperty("marca");
    expect(Object.keys(f)).not.toContain("principio_activo");
  });
});

describe("aplicarFichaMostrador", () => {
  test("saca la marca del título si ya está en la columna marca", () => {
    const ficha = aplicarFichaMostrador({
      nombre: "La Roche-Posay Anthelios UV Air FPS 50+ Protector Solar Ligero 40 ml",
      marca: "La Roche-Posay",
      presentacion: null,
    });
    expect(ficha.nombre).toMatch(/^Anthelios UV Air/i);
    expect(ficha.nombre).not.toMatch(/La Roche-Posay/i);
    expect(ficha.marca).toBe("La Roche-Posay");
    expect(ficha.presentacion).toBe("40 ml");
  });

  test("no pisa un principio activo que ya venía", () => {
    const ficha = aplicarFichaMostrador({
      nombre: "Amoxicilina 500 mg 10 tabletas",
      principio_activo: "Amoxicilina",
      marca: "Valclan",
    });
    expect(ficha.principio_activo).toBe("Amoxicilina");
    expect(ficha.marca).toBe("Valclan");
    expect(ficha.nombre).toBe("Amoxicilina 500 mg");
  });

  test("identidad de alta: marca o principio, no solo el nombre", () => {
    expect(fichaTieneIdentidad({ nombre: "Ibuprofeno 400 mg" })).toBe(false);
    expect(fichaTieneIdentidad({ nombre: "Ibuprofeno 400 mg", marca: "Genérico" })).toBe(true);
    expect(fichaTieneIdentidad({ nombre: "Ibuprofeno 400 mg", principio_activo: "Ibuprofeno" })).toBe(true);
  });
});
