import {
  piezasPorEmpaqueDesdeNombre,
  expandirPackAPiezas,
  enriquecerRenglonPackConCatalogo,
  prepararRenglonesPackAPiezas,
} from "./recepcionPackPiezas";

describe("piezasPorEmpaqueDesdeNombre", () => {
  test("Pack 48 sobres Optims", () => {
    expect(
      piezasPorEmpaqueDesdeNombre("Pack 48 sobres Shampoo Palmolive Optims 10 ml"),
    ).toBe(48);
  });

  test("Tira 24 sachets H&S", () => {
    expect(
      piezasPorEmpaqueDesdeNombre("Tira Shampoo Head & Shoulders 24 sachets 10 ml"),
    ).toBe(24);
  });

  test("no toca C/N de medicamento", () => {
    expect(piezasPorEmpaqueDesdeNombre("Aspirina Protect C/28 tabletas")).toBeNull();
  });

  test("mayoreo dulces Orbit/Clorets 24/40PZ → 40", () => {
    expect(piezasPorEmpaqueDesdeNombre("ORBIT 4P FRESA, 24/40PZ")).toBe(40);
    expect(piezasPorEmpaqueDesdeNombre("CLORETS 4 S PLUS 24/40PZ")).toBe(40);
    expect(piezasPorEmpaqueDesdeNombre("HALLS YERBA 30/12PZ")).toBe(12);
  });

  test("Skittles 24/10PZ → 24 bolsas (no 10)", () => {
    expect(piezasPorEmpaqueDesdeNombre("SKITTLES ORIGINAL, 24/10PZ")).toBe(24);
  });
});

describe("expandirPackAPiezas", () => {
  test("1 pack Optims → 48 pzas y costo unitario", () => {
    const r = expandirPackAPiezas({
      nombre: "Pack 48 sobres Shampoo Palmolive Optims 10 ml",
      cantidad: 1,
      costo: 75.3,
    });
    expect(r.expandido).toBe(true);
    expect(r.cantidad).toBe(48);
    expect(r.costo).toBeCloseTo(75.3 / 48, 4);
    expect(r.piezas_por_empaque).toBe(48);
  });

  test("2 tiras H&S → 48 pzas", () => {
    const r = expandirPackAPiezas({
      nombre: "Tira Shampoo Head & Shoulders 24 sachets 10 ml",
      cantidad: 2,
      costo: 51.21,
    });
    expect(r.cantidad).toBe(48);
    expect(r.costo).toBe(2.1338);
  });

  test("producto suelto no se expande", () => {
    const r = expandirPackAPiezas({
      nombre: "Jabón Dove blanco 90 g",
      cantidad: 3,
      costo: 18.63,
    });
    expect(r.expandido).toBe(false);
    expect(r.cantidad).toBe(3);
    expect(r.costo).toBe(18.63);
  });
});

describe("enriquecerRenglonPackConCatalogo", () => {
  const cat = [
    {
      sku: "FC-EXP-OPT48",
      nombre: "Palmolive Optims Vital Keratina 2 en 1 sobre 10 ml",
      codigo_barras: "7509546015699",
      descripcion:
        "Se vende el sobre. Ticket Exprezo: Pack 48 sobres Shampoo Palmolive Optims 10 ml.",
    },
  ];

  test("pone el EAN de la pieza si el ticket trae el alias del pack", () => {
    const r = enriquecerRenglonPackConCatalogo(
      { nombre: "Pack 48 sobres Shampoo Palmolive Optims 10 ml", cantidad: 48, costo: 1.57 },
      cat,
    );
    expect(r.codigo).toBe("7509546015699");
    expect(r.sku).toBe("FC-EXP-OPT48");
  });

  test("no pisa un EAN que ya venía", () => {
    const r = enriquecerRenglonPackConCatalogo(
      { nombre: "Pack 48 sobres…", codigo: "7500000000000", cantidad: 1 },
      cat,
    );
    expect(r.codigo).toBe("7500000000000");
  });
});

describe("prepararRenglonesPackAPiezas", () => {
  test("pipeline completo Optims", () => {
    const [r] = prepararRenglonesPackAPiezas(
      [
        {
          nombre: "Pack 48 sobres Shampoo Palmolive Optims 10 ml",
          cantidad: 1,
          costo: 75.3,
        },
      ],
      [
        {
          sku: "FC-EXP-OPT48",
          nombre: "Palmolive Optims Vital Keratina 2 en 1 sobre 10 ml",
          codigo_barras: "7509546015699",
          descripcion: "Ticket Exprezo: Pack 48 sobres Shampoo Palmolive Optims 10 ml.",
        },
      ],
    );
    expect(r.cantidad).toBe(48);
    expect(r.costo).toBeCloseTo(75.3 / 48, 4);
    expect(r.codigo).toBe("7509546015699");
  });
});
