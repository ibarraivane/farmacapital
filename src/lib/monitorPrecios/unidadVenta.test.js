const {
  extraerUnidadVenta,
  extraerUnidadProducto,
  mismaUnidadVenta,
  diagnosticoRefRappi,
  diagnosticoRefCadena,
  ofertaRappiComparable,
  esMarcaPatente,
  esMarcaComercialMercado,
  marcaBusqueda,
} = require("./unidadVenta");

const ensureBotella = {
  nombre: "Ensure vainilla",
  presentacion: "236 ML",
  principio_activo: "Suplemento nutricional",
  precio: 65,
};

test("botella 236 ml no es un pack", () => {
  const u = extraerUnidadProducto(ensureBotella);
  expect(u.ml).toBe(236);
  expect(u.piezas).toBeNull();
});

test("6 pack y 24 pack se leen como piezas, no como ml", () => {
  expect(extraerUnidadVenta("Ensure Regular Vainilla 6 Pack 237 ml")).toMatchObject({
    ml: 237,
    piezas: 6,
  });
  expect(extraerUnidadVenta("Ensure Advance 24 pack 237ml")).toMatchObject({
    ml: 237,
    piezas: 24,
  });
  expect(extraerUnidadVenta("Ensure 6x237 ml")).toMatchObject({
    ml: 237,
    piezas: 6,
  });
});

test("polvo 400 g no se confunde con la botella", () => {
  const polvo = extraerUnidadVenta("Ensure Advance Polvo Vainilla 400 g");
  expect(polvo.g).toBe(400);
  expect(polvo.ml).toBeNull();
  expect(mismaUnidadVenta(extraerUnidadProducto(ensureBotella), polvo)).toBe(false);
});

test("236 ml y 237 ml sueltos sí son la misma botella", () => {
  const a = extraerUnidadProducto(ensureBotella);
  const b = extraerUnidadVenta("Ensure Regular Líquido Vainilla 237 ml");
  expect(mismaUnidadVenta(a, b)).toBe(true);
});

test("Ensure 236 ml no cruza con el 6-pack de $400", () => {
  expect(ofertaRappiComparable(ensureBotella, {
    nombre: "Ensure Regular Vainilla 6 Pack 237 ml",
    precio: 393,
  })).toBe(false);
  expect(ofertaRappiComparable(ensureBotella, {
    nombre: "Ensure Regular Líquido Vainilla 237 ml",
    precio: 66,
  })).toBe(true);
});

test("sin la palabra pack, $542 contra $65 es otro empaque", () => {
  const d = diagnosticoRefRappi(ensureBotella, {
    nombre_fuente: "Ensure Clinical Vainilla",
    precio: 542.99,
  });
  expect(d.ok).toBe(false);
  expect(["otro_empaque", "precio_otro_empaque"]).toContain(d.motivo);
});

test("Agrifen C/10 no se tira por el precio si el empaque coincide", () => {
  const agrifen = { nombre: "Agrifen C/10", presentacion: "C/10 tabletas", precio: 50 };
  expect(ofertaRappiComparable(agrifen, {
    nombre: "Agrifen Antigripal 10 Tabletas",
    precio: 55,
  })).toBe(true);
  expect(ofertaRappiComparable(agrifen, {
    nombre: "Agrifen Antigripal 20 Tabletas",
    precio: 90,
  })).toBe(false);
});

test("Ensure Regular no cruza con Advance, polvo, otro sabor ni Pediasure", () => {
  const ensure = { ...ensureBotella, marca: "Ensure" };
  expect(ofertaRappiComparable(ensure, {
    nombre: "Abbott Ensure Vainilla Liquido 237 Ml",
    precio: 57,
  })).toBe(true);
  expect(ofertaRappiComparable(ensure, {
    nombre: "Ensure Advance Vanilla 237Ml",
    precio: 72,
  })).toBe(false);
  expect(ofertaRappiComparable(ensure, {
    nombre: "Ensure Vainilla Next Gen 400G",
    precio: 405,
  })).toBe(false);
  expect(ofertaRappiComparable(ensure, {
    nombre: "Ensure Liquido Fresa 237 ml",
    precio: 57.5,
  })).toBe(false);
  expect(ofertaRappiComparable(ensure, {
    nombre: "Abbott Pediasure Plus Vainilla 237 Ml",
    precio: 57,
  })).toBe(false);
});

test("Pediasure / Glucerna / Electrolit se venden sueltos, no el pack", () => {
  expect(ofertaRappiComparable(
    { nombre: "Pediasure vainilla", marca: "Pediasure", presentacion: "237 ML", precio: 69 },
    { nombre: "Pediasure Suplemento Alimenticio Vainilla", precio: 866 }
  )).toBe(false);
  expect(ofertaRappiComparable(
    { nombre: "Pediasure vainilla", marca: "Pediasure", presentacion: "237 ML", precio: 69 },
    { nombre: "Abbott Pediasure Plus Vainilla 237 Ml", precio: 57 }
  )).toBe(false);
  expect(ofertaRappiComparable(
    { nombre: "Pediasure vainilla", marca: "Pediasure", presentacion: "237 ML", precio: 69 },
    { nombre: "Pediasure Suplemento Alimenticio 10 + Vainilla", precio: 57 }
  )).toBe(false);
  expect(ofertaRappiComparable(
    { nombre: "Glucerna fresa", marca: "Glucerna", presentacion: "237 ML", precio: 69 },
    { nombre: "Glucerna Fresa 237 Ml", precio: 60.5 }
  )).toBe(true);
  expect(ofertaRappiComparable(
    { nombre: "Glucerna fresa", marca: "Glucerna", presentacion: "237 ML", precio: 69 },
    { nombre: "Glucerna Polvo Vainilla 400 gr", precio: 362 }
  )).toBe(false);
  expect(ofertaRappiComparable(
    { nombre: "Electrolit Fresa", marca: "Electrolit", presentacion: "625 ML", precio: 28 },
    { nombre: "Electrolit Fresa 4 pack 625 ml", precio: 96 }
  )).toBe(false);
  expect(ofertaRappiComparable(
    { nombre: "Electrolit Fresa", marca: "Electrolit", presentacion: "625 ML", precio: 28 },
    { nombre: "Electrolit Suero Oral Fresa 625 ml", precio: 27 }
  )).toBe(true);
});

test("notas de Advance o 'no se encontró marca' no sirven de calle", () => {
  const ensure = { ...ensureBotella, marca: "Ensure" };
  expect(diagnosticoRefRappi(ensure, {
    precio: 66,
    notas: "Vitau.mx - Ensure Advance 237ml (referencia similar)",
  }).ok).toBe(false);
  expect(diagnosticoRefRappi(ensure, {
    precio: 38.62,
    notas: "No se encontro marca Ensure; Similares maneja DIETA POLIMERICA",
  }).ok).toBe(false);
});

test("Dibar 125 ml no se compara con el de 500 ml", () => {
  expect(ofertaRappiComparable(
    { nombre: "Alcohol Etilico Rojo 96°", marca: "Dibar", presentacion: "125 ML", precio: 22 },
    { nombre: "Alcohol Dibar Rojo 96 500 ml", precio: 48 }
  )).toBe(false);
});

test("10Und y 10 Unidades son caja médica, no pack de botellas", () => {
  expect(extraerUnidadVenta("Lizovag 10Und")).toMatchObject({ piezas: 10, origenPiezas: "caja_med" });
  expect(extraerUnidadVenta("Galaver Gel 10 Unidades")).toMatchObject({
    piezas: 10,
    origenPiezas: "caja_med",
  });
  expect(extraerUnidadVenta("Ketoconazol 200 mg 10 tabletas")).toMatchObject({
    piezas: 10,
    origenPiezas: "caja_med",
  });
});

test("Lizovag genérico sí compara con ketoconazol 200 mg 10 tabletas", () => {
  const lizovag = {
    nombre: "Lizovag",
    tipo: "generico",
    principio_activo: "Ketoconazol",
    presentacion: "10Und",
    concentracion: "200 mg",
    precio: 26,
    nombre_partner: "Lizovag (200 mg)",
  };
  expect(ofertaRappiComparable(lizovag, {
    nombre: "Ketoconazol 200 mg 10 tabletas",
    precio: 28,
  })).toBe(true);
  expect(ofertaRappiComparable(lizovag, {
    nombre: "Ketoconazol 400 mg 10 tabletas",
    precio: 45,
  })).toBe(false);
  expect(ofertaRappiComparable(lizovag, {
    nombre: "Ketoconazol 200 mg 20 tabletas",
    precio: 48,
  })).toBe(false);
});

test("tableta no se compara con crema ni suspensión del mismo PA", () => {
  const lizovag = {
    nombre: "Lizovag",
    tipo: "generico",
    principio_activo: "Ketoconazol",
    presentacion: "10Und",
    concentracion: "200 mg",
    forma_farmaceutica: "tableta",
    precio: 26,
  };
  expect(ofertaRappiComparable(lizovag, {
    nombre: "Pharmalife Crema Ketoconazol",
    precio: 38,
  })).toBe(false);
  expect(ofertaRappiComparable(lizovag, {
    nombre: "Keto Conazol Suspension (2 G)",
    precio: 112,
  })).toBe(false);
  expect(ofertaRappiComparable(lizovag, {
    nombre: "Ketoconazol (200 mg)",
    precio: 37,
  })).toBe(true);
});

test("Cafiaspirina C/100 se compara con Guadalajara 100 tabletas, no con Fahorro C/40", () => {
  const caja100 = {
    nombre: "Cafiaspirina tartrato C/100",
    marca: "Cafiaspirina",
    tipo: "marca",
    principio_activo: "Acido acetilsalicilico + Caffeina",
    presentacion: "C/100",
    forma_farmaceutica: "TABLETAS",
    precio: 294,
  };
  expect(diagnosticoRefRappi(caja100, {
    nombre_fuente: "Cafiaspirina 500 mg/30 mg 100 tabletas — Farmacias Guadalajara",
    precio: 190.19,
  }).ok).toBe(true);
  expect(diagnosticoRefRappi(caja100, {
    nombre_fuente: "Cafiaspirina analgésico 40 tabletas — Farmacias del Ahorro",
    precio: 66,
  }).ok).toBe(false);
});

test("el mismo EAN es comparable aunque el nombre no traiga la marca", () => {
  expect(ofertaRappiComparable(
    { nombre: "Lizovag", codigo_barras: "7501075717150", precio: 26 },
    { nombre: "Ketoconazol 200 mg", ean: "7501075717150", precio: 29 },
  )).toBe(true);
});

test("Contac mal etiquetado GENERICO no se compara con el genérico de Similares", () => {
  const contac = {
    nombre: "Contac Ultra",
    marca: "Contac",
    tipo: "GENERICO",
    principio_activo: "Paracetamol + Fenilefrina + Clorfenamina",
    presentacion: "C/12",
    precio: 44,
  };
  expect(marcaBusqueda(contac)).toBe("contac");
  expect(esMarcaPatente(contac)).toBe(true);
  expect(diagnosticoRefCadena(contac, "similares", {
    nombre_fuente: "CLORFENAMINA / FENILEFRINA / PARACETAMOL 24 TABLETAS",
    precio: 36,
  }).ok).toBe(false);
  expect(diagnosticoRefCadena(contac, "similares", { precio: 36 }).ok).toBe(false);
  expect(diagnosticoRefCadena(contac, "fahorro", { precio: 89 }).ok).toBe(false);
  expect(diagnosticoRefCadena(contac, "fahorro", {
    precio: 89,
    nombre_fuente: "Contac Ultra 12 tabletas — Farmacias del Ahorro",
  }).ok).toBe(true);
});

test("Del Ahorro sin nombre de góndola no compara Gentamicina 5 amp", () => {
  const caja5 = {
    nombre: "Gentamicina",
    tipo: "generico",
    principio_activo: "Gentamicina",
    presentacion: "5 AMPOLLETA",
    concentracion: "160MG/2 ML",
    forma_farmaceutica: "AMPOLLETA",
    precio: 84,
  };
  expect(diagnosticoRefCadena(caja5, "fahorro", { precio: 45.5 }).ok).toBe(false);
  expect(diagnosticoRefCadena(caja5, "fahorro", { precio: 45.5 }).motivo).toBe("sin_ficha");
});

test("XL-3 se reconoce aunque el guion parta el nombre", () => {
  const xl3 = {
    nombre: "XL-3 Xtra C/12",
    marca: "XL-3",
    tipo: "generico",
    principio_activo: "Paracetamol + Fenilefrina + Clorfenamina",
    presentacion: "C/12",
    precio: 49,
  };
  expect(marcaBusqueda(xl3)).toBe("xl3");
  expect(esMarcaPatente(xl3)).toBe(true);
  expect(diagnosticoRefCadena(xl3, "similares", {
    nombre_fuente: "CLORFENAMINA / FENILEFRINA / PARACETAMOL 24 TABLETAS",
    precio: 36,
  }).motivo).toBe("otra_marca");
  expect(diagnosticoRefRappi(xl3, {
    nombre_fuente: "XL-3 Xtra 12 tabletas — Farmacias del Ahorro",
    precio: 52,
  }).ok).toBe(true);
});

test("Amoxicilina genérica sí se compara con Similares del mismo PA", () => {
  const amox = {
    nombre: "Amoxicilina 500 mg",
    tipo: "generico",
    principio_activo: "Amoxicilina",
    presentacion: "C/12",
    precio: 32,
  };
  expect(esMarcaPatente(amox)).toBe(false);
  expect(diagnosticoRefCadena(amox, "similares", {
    nombre_fuente: "AMOXICILINA 500 MG 12 CAPSULAS",
    precio: 18,
  }).ok).toBe(true);
});

test("laboratorio tipo=marca se compara por el genérico, no por el nombre de lab", () => {
  const bactiver = {
    nombre: "Bactiver F (Sulfametoxazol/Trimetoprima)",
    marca: "Bactiver",
    tipo: "marca",
    principio_activo: "Sulfametoxazol + Trimetoprima",
    presentacion: "16 TABLETAS",
    precio: 22,
  };
  const tarmin = {
    nombre: "Tarmin 2 Mg /12",
    marca: "Tarmin",
    tipo: "marca",
    principio_activo: "Loperamida",
    presentacion: "12 TABLETAS",
    concentracion: "2 mg",
    precio: 18,
  };
  expect(esMarcaComercialMercado(bactiver)).toBe(false);
  expect(esMarcaPatente(bactiver)).toBe(false);
  expect(diagnosticoRefCadena(bactiver, "similares", {
    nombre_fuente: "TRIMETOPRIMA/SULFAMETOXAZOL 800/400 MG 16 TABLETAS",
    precio: 31,
  }).ok).toBe(true);
  expect(diagnosticoRefCadena(tarmin, "similares", {
    nombre_fuente: "LOPERAMIDA 2 MG 12 TABLETAS",
    precio: 12.5,
  }).ok).toBe(true);
});
