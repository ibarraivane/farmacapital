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
  expect(d.motivo).toBe("precio_otro_empaque");
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
