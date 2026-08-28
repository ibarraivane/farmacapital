import {
  tipoAltaNormalizado,
  margenAltaRecepcion,
  precioSugeridoAltaRecepcion,
  payloadAltaRecepcion,
} from "./recepcionAlta";

test("patente 25% y genérico 60% sobre venta", () => {
  expect(tipoAltaNormalizado("patente")).toBe("marca");
  expect(margenAltaRecepcion("marca")).toBe(25);
  expect(margenAltaRecepcion("generico")).toBe(60);
  expect(precioSugeridoAltaRecepcion(204.38, "marca")).toBe(273);
  expect(precioSugeridoAltaRecepcion(77.28, "generico")).toBe(194);
});

test("el payload de alta no inventa stock ni caducidad", () => {
  const p = payloadAltaRecepcion({
    nombre: "Febrax 15 tab",
    codigo: "7501300407047",
    tipo: "patente",
    costo: 204.38,
  });
  expect(p.tipo).toBe("marca");
  expect(p.precio).toBe(273);
  expect(p.stock).toBeUndefined();
  expect(p.fecha_caducidad).toBeUndefined();
});
