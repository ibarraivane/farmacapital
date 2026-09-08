import {
  costoSugeridoRecepcion,
  mensajeErrorRecepcion,
  parseCostoRecepcion,
  unidadDesdeImporte,
} from "./recepcionCosto";

test("el ticket manda sobre el catálogo", () => {
  expect(costoSugeridoRecepcion({
    item: { costo_estimado: 13.61 },
    producto: { costo: 12.92 },
  })).toBe(13.61);
});

test("si el renglón no trae costo, usa el del catálogo", () => {
  expect(costoSugeridoRecepcion({
    item: { costo_estimado: null },
    producto: { costo: 75.46 },
  })).toBe(75.46);
});

test("si tampoco hay catálogo, usa última compra", () => {
  expect(costoSugeridoRecepcion({
    item: {},
    producto: { costo: 0 },
    ultimaCompra: { precio: 59.45 },
  })).toBe(59.45);
});

test("el error de borrador se entiende en mostrador", () => {
  expect(mensajeErrorRecepcion({ message: "solo se edita una recepcion en borrador" }))
    .toMatch(/ya no está en borrador/i);
});

test("cero o vacío no sirve", () => {
  expect(parseCostoRecepcion(0)).toBeNull();
  expect(parseCostoRecepcion("")).toBeNull();
  expect(costoSugeridoRecepcion({ item: { costo_estimado: 0 }, producto: {} })).toBeNull();
});

test("Neutrogena City Mark: 2 pzas a 45.89, no el importe 91.78", () => {
  expect(unidadDesdeImporte(91.78, 2, { subtotal: 91.78 })).toBe(45.89);
  expect(unidadDesdeImporte(45.89, 2, { subtotal: 91.78 })).toBe(45.89);
  expect(costoSugeridoRecepcion({
    item: { costo_estimado: 91.78, cantidad: 2, subtotal: 91.78 },
  })).toBe(45.89);
  expect(costoSugeridoRecepcion({
    item: { costo_estimado: 45.89, cantidad: 2, subtotal: 91.78 },
  })).toBe(45.89);
});

test("si el catálogo tiene el de una y el renglón trajo el de dos, usa el de una", () => {
  expect(costoSugeridoRecepcion({
    item: { costo_estimado: 91.78, cantidad: 2 },
    producto: { costo: 45.89 },
  })).toBe(45.89);
});

test("qty 2 con costo unitario real no se parte a la mitad", () => {
  expect(costoSugeridoRecepcion({
    item: { costo_estimado: 45.89, cantidad: 2 },
    producto: { costo: 45.89 },
  })).toBe(45.89);
});
