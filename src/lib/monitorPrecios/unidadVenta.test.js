const {
  extraerUnidadVenta,
  extraerUnidadProducto,
  mismaUnidadVenta,
  diagnosticoRefRappi,
  ofertaRappiComparable,
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
